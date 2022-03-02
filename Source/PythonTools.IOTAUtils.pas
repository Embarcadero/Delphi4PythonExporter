unit PythonTools.IOTAUtils;

interface

uses
  DesignIntf, ToolsAPI, System.Classes, System.Generics.Collections,
  System.SysUtils, System.Rtti, PythonTools.Common;

type
  TIOTAFormInfo = record
    Project: IOTAProject;
    ModuleInfo: IOTAModuleInfo;
    Module: IOTAModule;
    Editor: IOTAFormEditor;
    Designer: IDesigner;
  end;

  TIOTAUtils = class
  private
    class procedure EnumComps(const AFormEditor: IOTAFormEditor; const ACallback: TProc<TComponent>);
  public
    class function FindComponents(const AFormEditor: IOTAFormEditor): TExportedComponents;
    class function FindEvents(const AFormEditor: IOTAFormEditor; const ADesigner: IDesigner): TExportedEvents;

    class procedure EnumForms(const AProject: IOTAProject; const AProc: TProc<TIOTAFormInfo>);
    class function GetFormEditorFromModule(const AModule: IOTAModule): IOTAFormEditor;
  end;

implementation

uses
  TypInfo, System.Generics.Defaults;

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

    LResult.Project := AProject;
    LResult.ModuleInfo := LModuleInfo;
    LResult.Module := LModuleInfo.OpenModule();
    LResult.Editor := TIOTAUtils.GetFormEditorFromModule(LResult.Module);
    LResult.Designer := (LResult.Editor as INTAFormEditor).FormDesigner;
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
    try
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
    finally
      LRttiType.Free();
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
