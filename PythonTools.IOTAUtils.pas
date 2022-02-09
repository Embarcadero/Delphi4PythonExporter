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
    FComponentNames: TList<string>;
    procedure DoListComps(const ACompName: string);
  public
    constructor Create();
    destructor Destroy(); override;

    function FindComponents(const ADesigner: IDesigner): TExportedComponents;
    function FindEvents(const ADesigner: IDesigner): TExportedEvents;

    class procedure EnumForms(const AProject: IOTAProject; const AProc: TProc<TIOTAFormInfo>);
    class function GetFormEditorFromModule(const AModule: IOTAModule): IOTAFormEditor;
  end;

implementation

uses
  TypInfo, System.Generics.Defaults;

{ TIOTAUtils }

constructor TIOTAUtils.Create;
begin
  FComponentNames := TList<string>.Create();
end;

destructor TIOTAUtils.Destroy;
begin
  FComponentNames.Free();
  inherited;
end;

procedure TIOTAUtils.DoListComps(const ACompName: string);
begin
  FComponentNames.Add(ACompName);
end;

class procedure TIOTAUtils.EnumForms(const AProject: IOTAProject;
  const AProc: TProc<TIOTAFormInfo>);
begin
  var LFormPredicate := function(AModuleInfo: IOTAModuleInfo): boolean begin
    Result := (AModuleInfo.ModuleType = omtForm)
      and not AModuleInfo.FormName.Trim().IsEmpty();
  end;

  for var I := 0 to AProject.GetModuleCount() - 1 do begin
    var LModuleInfo := AProject.GetModule(I);
    if not LFormPredicate(LModuleInfo) then
      Continue;

    var LResult: TIOTAFormInfo;
    LResult.Project := AProject;
    LResult.ModuleInfo := LModuleInfo;
    LResult.Module := LModuleInfo.OpenModule();
    LResult.Editor := TIOTAUtils.GetFormEditorFromModule(LResult.Module);
    LResult.Designer := (LResult.Editor as INTAFormEditor).FormDesigner;
    AProc(LResult);
  end;
end;

function TIOTAUtils.FindComponents(const ADesigner: IDesigner): TExportedComponents;
begin
  var LCompList := TExportedComponentList.Create();
  try
    FComponentNames.Clear();
    ADesigner.GetComponentNames(GetTypeData(TypeInfo(TComponent)), DoListComps);
    for var LCompName in FComponentNames do begin
      LCompList.Add(TExportedComponent.Create(ADesigner.GetComponent(LCompName).Name));
    end;
    Result := LCompList.ToArray();
  finally
    LCompList.Free();
  end;
end;

function TIOTAUtils.FindEvents(const ADesigner: IDesigner): TExportedEvents;

  procedure ExtractPropertyEvents(const ARttiContext: TRttiContext;
    const AComponent: TComponent; const AEvents: TExportedEventList);
  begin
    var LRttiType := ARttiContext.GetType(AComponent.ClassInfo);
    try
      for var LRttiProp in LRttiType.GetProperties() do begin
        if not (LRttiProp.Visibility = TMemberVisibility.mvPublished) then
          Continue;

        if not (LRttiProp.PropertyType is TRttiMethodType) then
          Continue;

        var LMethod := LRttiProp.GetValue(AComponent);

        if LMethod.IsEmpty then
          Continue;

        var LMethodName := ADesigner.GetMethodName(PMethod(LMethod.GetReferenceToRawData)^);
        if not ADesigner.MethodExists(LMethodName) then
          Continue;

        var LRttiMethod := LRttiProp.PropertyType as TRttiMethodType;
        var LParamList := TList<string>.Create();
        try
          for var LParam in LRttiMethod.GetParameters() do begin
            LParamList.Add(LParam.Name);
          end;

          var LEvt := TExportedEvent.Create(LMethodName, LParamList.ToArray());
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
  begin
    var LComps := FindComponents(ADesigner);
    var LCompList := TList<TComponent>.Create();
    try
      for var LCompName in LComps do begin
        LCompList.Add(ADesigner.GetComponent(LCompName.ComponentName));
      end;
      Result := LCompList.ToArray();
    finally
      LCompList.Free();
    end;
  end;

begin
  var LEvts := TExportedEventList.Create(
    TDelegatedComparer<TExportedEvent>.Create(
      function(const Left, Right: TExportedEvent): Integer begin
        Result := CompareStr(Left.MethodName, Right.MethodName);
      end));
  try
    var LRttiCtx := TRttiContext.Create();
    try
      //Extract the form events
      ExtractPropertyEvents(LRttiCtx, ADesigner.Root, LEvts);
      //Extract the component events
      for var LComponent in FindComponentRefs() do
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
begin
  if AModule = nil then
    Exit(nil);

  for var I := 0 to AModule.GetModuleFileCount - 1 do begin
    var LEditor := AModule.GetModuleFileEditor(i);
    if Supports(LEditor, IOTAFormEditor, Result) then
      Break;
  end;
end;

end.
