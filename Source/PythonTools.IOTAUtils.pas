unit PythonTools.IOTAUtils;

interface

uses
  DesignIntf, ToolsAPI,
  System.Classes, System.Generics.Collections, System.SysUtils, System.Rtti,
  PythonTools.Common;

type
  TIOTAFormInfo = record
    FormName: string;
    FileName: string;
    Caption: string;
    FrameworkType: string;
    Module: IOTAModule;
    Editor: IOTAFormEditor;
    Designer: IDesigner;
  end;

  TFormClassName = string;
  TFormGlobalVarName = string;
  TDprEntry = TPair<TFormClassName, TFormGlobalVarName>;
  TDprEntries = TArray<TDprEntry>;

  TIOTAUtils = class
  private
    class function ModuleIsPas(const AModule: IOTAModule): boolean;
    class function ModuleIsCpp(const AModule: IOTAModule): boolean;
    class function ModuleIsForm(const AModule: IOTAModule): boolean;
    class function ModuleIsExportable(const AModule: IOTAModule): boolean;
    class procedure EnumComps(const AFormEditor: IOTAFormEditor; const ACallback: TProc<TComponent>);
    class function GetFormCaption(const AComponent: TComponent): string;
    class function ScanDprEntries(const AProject: IOTAProject): TDprEntries;
  public
    class function FindComponents(const AFormEditor: IOTAFormEditor): TExportedComponents;
    class function FindEvents(const AFormEditor: IOTAFormEditor; const ADesigner: IDesigner): TExportedEvents;
    class function HasForms(): boolean;
    class procedure EnumForms(const AProc: TProc<TIOTAFormInfo>); overload;
    class procedure EnumForms(const AProject: IOTAProject; const AProc: TProc<TIOTAFormInfo>); overload;
    class function FindForm(const AFormName: string; out AFormInfo: TIOTAFormInfo): boolean;
    class function FindDelphiProjectEditor(const AProject: IOTAProject): IOTAEditor;
    class function GuessMainForm(const AProject: IOTAProject): IOTAModule;
    class function GetEditorContentFromEditor(const AEditor: IOTAEditor): IOTAEditorContent;
    class function GetFormEditorFromModule(const AModule: IOTAModule): IOTAFormEditor;
    class function GetFrameworkTypeFromDesigner(const ADesigner: IDesigner): string;
  end;

implementation

uses
  System.TypInfo,
  System.Generics.Defaults,
  System.RegularExpressions,
  Vcl.AxCtrls,
  Vcl.Forms,
  Fmx.Forms,
  PythonTools.Exceptions;

{ TIOTAUtils }

class procedure TIOTAUtils.EnumForms(const AProject: IOTAProject;
  const AProc: TProc<TIOTAFormInfo>);
var
  LFormPredicate: TPredicate<IOTAModuleInfo>;
  I: integer;
  LModuleInfo: IOTAModuleInfo;
  LResult: TIOTAFormInfo;
begin
  LFormPredicate := function(AModuleInfo: IOTAModuleInfo): boolean begin
    Result := (AModuleInfo.ModuleType = omtForm)
      and not AModuleInfo.FormName.Trim().IsEmpty();
  end;
  for I := 0 to AProject.GetModuleCount() - 1 do begin
    LModuleInfo := AProject.GetModule(I);
    if not LFormPredicate(LModuleInfo) then
      Continue;
    LResult.Module := LModuleInfo.OpenModule();
    LResult.Editor := TIOTAUtils.GetFormEditorFromModule(LResult.Module);
    LResult.Designer := (LResult.Editor as INTAFormEditor).FormDesigner;
    LResult.FileName := LModuleInfo.FileName;
    LResult.FormName := LModuleInfo.FormName;
    LResult.Caption := GetFormCaption(LResult.Designer.Root);
    LResult.FrameworkType := GetFrameworkTypeFromDesigner(LResult.Designer);
    AProc(LResult);
  end;
end;

class procedure TIOTAUtils.EnumForms(const AProc: TProc<TIOTAFormInfo>);
var
  I: integer;
  LModuleServices: IOTAModuleServices;
  LProject: IOTAProject;
  LModule: IOTAModule;
  LEditor: IOTAFormEditor;
  LDesigner: IDesigner;
  LResult: TIOTAFormInfo;
begin
  LModuleServices := (BorlandIDEServices as IOTAModuleServices);
  //User has created a project and added files on it.
  if Assigned(LModuleServices.MainProjectGroup) then begin
    for I := 0 to LModuleServices.MainProjectGroup.ProjectCount - 1 do begin
      LProject := LModuleServices.MainProjectGroup.Projects[I];
      EnumForms(LProject, AProc);
    end;
  end else
    //User has created files out of a project.
    for I := 0 to LModuleServices.ModuleCount - 1 do begin
      LModule := LModuleServices.Modules[I];
      LEditor := GetFormEditorFromModule(LModule);
      if not ModuleIsExportable(LModule) then
        Continue;
      LDesigner := (LEditor as INTAFormEditor).FormDesigner;
      if not Assigned(LDesigner) then
        Continue;
      LResult.FileName := LModule.FileName;
      LResult.FormName := LDesigner.Root.Name;
      LResult.Caption := GetFormCaption(LDesigner.Root);
      LResult.FrameworkType := GetFrameworkTypeFromDesigner(LDesigner);
      LResult.Module := LModule;
      LResult.Editor := LEditor;
      LResult.Designer := LDesigner;
      AProc(LResult);
    end;
end;

class function TIOTAUtils.FindComponents(const AFormEditor: IOTAFormEditor): TExportedComponents;
var
  LCompList: TExportedComponentList;
begin       
  LCompList := TExportedComponentList.Create();
  try 
    EnumComps(AFormEditor, procedure(AComponent: TComponent) begin 
      LCompList.Add(TExportedComponent.Create(AComponent.Name));
    end);
    Result := LCompList.ToArray();
  finally
    LCompList.Free();
  end;
end;

class function TIOTAUtils.FindDelphiProjectEditor(
  const AProject: IOTAProject): IOTAEditor;
var
  I: Integer;
begin
  for I := 0 to AProject.ModuleFileCount -1 do
    if AProject.ModuleFileEditors[I].FileName.EndsWith('.dpr') then
      Exit(AProject.ModuleFileEditors[I]);

  Result := nil;
end;

class function TIOTAUtils.FindEvents(const AFormEditor: IOTAFormEditor; const ADesigner: IDesigner): TExportedEvents;
  procedure ExtractPropertyEvents(const ARttiContext: TRttiContext;
    const AComponent: TComponent; const AEvents: TExportedEventList);
  var
    LRttiType: TRttiType;
    LRttiProp: TRttiProperty;
    LMethod: TValue;
    LMethodName: string;
    LRttiMethod: TRttiMethodType;
    LParamList: TList<string>;
    LParam: TRttiParameter;
    LEvt: TExportedEvent;
  begin
    LRttiType := ARttiContext.GetType(AComponent.ClassInfo);
    for LRttiProp in LRttiType.GetProperties() do begin
      if not (LRttiProp.Visibility = TMemberVisibility.mvPublished) then
        Continue;
      if not (LRttiProp.PropertyType is TRttiMethodType) then
        Continue;
      LMethod := LRttiProp.GetValue(AComponent);
      if LMethod.IsEmpty then
        Continue;

      LMethodName := ADesigner.GetMethodName(PMethod(LMethod.GetReferenceToRawData)^);
      if not ADesigner.MethodExists(LMethodName) then
        Continue;

      LRttiMethod := LRttiProp.PropertyType as TRttiMethodType;
      LParamList := TList<string>.Create();
      try
        for LParam in LRttiMethod.GetParameters() do begin
          LParamList.Add(LParam.Name);
        end;
        LEvt := TExportedEvent.Create(LMethodName, LParamList.ToArray());
        if not AEvents.Contains(LEvt) then
          AEvents.Add(LEvt);
      finally
        LParamList.Free();
      end;
    end;
  end;
  function FindComponentRefs(): TArray<TComponent>;
  var
    LCompList: TList<TComponent>;
  begin    
    LCompList := TList<TComponent>.Create();
    try
      EnumComps(AFormEditor, procedure(AComponent: TComponent) begin 
        LCompList.Add(AComponent);
      end);
          
      Result := LCompList.ToArray();
    finally
      LCompList.Free();
    end;
  end;
var
  LEvts: TExportedEventList;
  LRttiCtx: TRttiContext;
  LComponent: TComponent;
begin
  LEvts := TExportedEventList.Create(
    TDelegatedComparer<TExportedEvent>.Create(
      function(const Left, Right: TExportedEvent): Integer begin
        Result := CompareStr(Left.MethodName, Right.MethodName);
      end));

  try      
    LRttiCtx := TRttiContext.Create();
    try
      //Extract the form events
      ExtractPropertyEvents(LRttiCtx, ADesigner.Root, LEvts);
      //Extract the component events
      for LComponent in FindComponentRefs() do
        ExtractPropertyEvents(LRttiCtx, LComponent, LEvts);
    finally
      LRttiCtx.Free();
    end;
    Result := LEvts.ToArray();
  finally
    LEvts.Free();
  end;
end;

class function TIOTAUtils.FindForm(const AFormName: string; out AFormInfo: TIOTAFormInfo): boolean;
var
  LModuleServices: IOTAModuleServices;
  LModule: IOTAModule;
  LEditor: IOTAFormEditor;
  LDesigner: IDesigner;
begin
  LModuleServices := (BorlandIDEServices as IOTAModuleServices);
  LModule := LModuleServices.FindFormModule(AFormName);
  if not Assigned(LModule) then
    Exit(false);

  LEditor := GetFormEditorFromModule(LModule);
  if not Assigned(LEditor) then
    Exit(false);

  LDesigner := (LEditor as INTAFormEditor).FormDesigner;
  if not Assigned(LDesigner) then
    Exit(false);

  AFormInfo.FileName := LModule.FileName;
  AFormInfo.FormName := LDesigner.Root.Name;
  AFormInfo.FrameworkType := GetFrameworkTypeFromDesigner(LDesigner);
  AFormInfo.Module := LModule;
  AFormInfo.Editor := LEditor;
  AFormInfo.Designer := LDesigner;
  Result := true;
end;

class function TIOTAUtils.GetEditorContentFromEditor(
  const AEditor: IOTAEditor): IOTAEditorContent;
begin
  if not Supports(AEditor, IOTAEditorContent, Result) then
    Result := nil;
end;

class function TIOTAUtils.GetFormCaption(const AComponent: TComponent): string;
begin
  if AComponent is Vcl.Forms.TForm then
    Result := Vcl.Forms.TForm(AComponent).Caption
  else if AComponent is Fmx.Forms.TForm then
    Result := Fmx.Forms.TForm(AComponent).Caption
  else
    Result := String.Empty;
end;

class function TIOTAUtils.GetFormEditorFromModule(const AModule: IOTAModule): IOTAFormEditor;
var
  I: integer;
  LEditor: IOTAEditor;
begin
  if AModule = nil then
    Exit(nil);

  for I := 0 to AModule.GetModuleFileCount - 1 do begin
    LEditor := AModule.GetModuleFileEditor(i);
    if Supports(LEditor, IOTAFormEditor, Result) then
      Break;
  end;
end;

class function TIOTAUtils.GetFrameworkTypeFromDesigner(
  const ADesigner: IDesigner): string;
begin
  if CompareText(ADesigner.DesignerExtention, 'dfm') = 0 then
    Result := 'VCL'
  else if CompareText(ADesigner.DesignerExtention, 'fmx') = 0 then
    Result := 'FMX'
  else
    raise EUnknownFrameworkType.Create('Unknown framework type.');
end;

class function TIOTAUtils.GuessMainForm(
  const AProject: IOTAProject): IOTAModule;
var
  LEntries: TDprEntries;
  LModuleServices: IOTAModuleServices;
begin
  LEntries := ScanDprEntries(AProject);
  if not Assigned(LEntries) then
    Exit(nil);

  LModuleServices := (BorlandIDEServices as IOTAModuleServices);
  Result := LModuleServices.FindFormModule(LEntries[Low(LEntries)].Value);
end;

class function TIOTAUtils.HasForms: boolean;
var
  LModuleServices: IOTAModuleServices;
  I: Integer;
  LModule: IOTAModule;
begin
  LModuleServices := (BorlandIDEServices as IOTAModuleServices);
  for I := 0 to LModuleServices.ModuleCount - 1 do begin
    LModule := LModuleServices.Modules[I];
    if ModuleIsExportable(LModule) then
      Exit(true);
  end;
  Result := false;
end;

class function TIOTAUtils.ModuleIsForm(const AModule: IOTAModule): boolean;
var
  LEditor: IOTAFormEditor;
  LDesigner: IDesigner;
  LRoot: TComponent;
begin
  LEditor := GetFormEditorFromModule(AModule);
  if not Assigned(LEditor) then
    Exit(false);
  LDesigner := (LEditor as INTAFormEditor).FormDesigner;
  if not Assigned(LDesigner) then
    Exit(false);
  LRoot := LDesigner.Root;
  if not Assigned(LRoot) then
    Exit(false);
  if not (LRoot.InheritsFrom(Vcl.Forms.TForm)
    or LRoot.InheritsFrom(Fmx.Forms.TForm)) then
      Exit(false);
  Result := true;
end;

class function TIOTAUtils.ModuleIsPas(const AModule: IOTAModule): boolean;
begin
  Result := SameText(ExtractFileExt(AModule.FileName), '.pas');
end;

class function TIOTAUtils.ScanDprEntries(
  const AProject: IOTAProject): TDprEntries;
var
  I: integer;
  LEditor: IOTAEditor;
  LEditorContent: IOTAEditorContent;
  LOleStream: TStream;
  LStream: TStringStream;
  LMatches: TMatchCollection;
  LValues: string;
  LPair: TArray<string>;
begin
  LEditor := FindDelphiProjectEditor(AProject);
  if not Assigned(LEditor) then
    Exit(nil);

  LEditorContent := GetEditorContentFromEditor(LEditor);
  if not Assigned(LEditorContent) then
    Exit(nil);

  LOleStream := TOleStream.Create(LEditorContent.Content);
  try
    LStream := TStringStream.Create('');
    try
      LStream.CopyFrom(LOleStream);

      LMatches := TRegEx.Matches(
        LStream.DataString,
        'Application.CreateForm\((.*?)\);',
        [roIgnoreCase, roMultiLine]);

    finally
      LStream.Free();
    end;
  finally
    LOleStream.Free();
  end;

  if (LMatches.Count = 0) then
    Exit(nil);

  LValues := String.Empty;
  for I := 0 to LMatches.Count - 1 do
    LValues := LValues + LMatches.Item[I].Value + sLineBreak;

  LMatches := TRegEx.Matches(
    LValues,
    '\((.*?)\)',
    [roIgnoreCase, roMultiLine]);

  for I := 0 to LMatches.Count - 1 do begin
    LPair := LMatches.Item[I].Value
      .Replace('(', '', [])
      .Replace(')', '', [])
      .Replace(' ', '', [rfReplaceAll])
      .Split([',']);

    if Length(LPair) <> 2 then
      Continue;

    Result := Result + [
      TDprEntry.Create(
        LPair[Low(LPair)],
        LPair[Low(LPair) + 1])
    ];
  end;
end;

class function TIOTAUtils.ModuleIsCpp(const AModule: IOTAModule): boolean;
begin
  Result := SameText(ExtractFileExt(AModule.FileName), '.cpp');
end;

class function TIOTAUtils.ModuleIsExportable(
  const AModule: IOTAModule): boolean;
begin
  Result := (ModuleIsPas(AModule) or ModuleIsCpp(AModule))
    and ModuleIsForm(AModule);
end;

class procedure TIOTAUtils.EnumComps(const AFormEditor: IOTAFormEditor;
  const ACallback: TProc<TComponent>);
var
  LRoot: IOTAComponent;
  I: integer;
  LComp: TComponent;
begin
  if not Assigned(ACallback) then
    Exit;
  LRoot := AFormEditor.GetRootComponent();
  if not Assigned(LRoot) then
    Exit;
  
  for I := 0 to LRoot.GetComponentCount() - 1 do begin
    LComp := TComponent(LRoot.GetComponent(I).GetComponentHandle());
    if not Assigned(LComp) then
      Continue;
       
    ACallback(LComp);
  end;
end;

end.
