unit PythonTools.IOTAUtils;

interface

uses
  DesignIntf, System.Classes, System.Generics.Collections, ToolsAPI,
  System.SysUtils;

type
  TIOTAUtils = class
  private
    FComponentNames: TList<string>;
    procedure DoListComps(const ACompName: string);
  public
    constructor Create();
    destructor Destroy(); override;

    function FindComponents(const ADesigner: IDesigner): TArray<TComponent>;

    class function GetFormEditorFromModule(const AModule: IOTAModule): IOTAFormEditor;
  end;

implementation

uses
  TypInfo;

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

function TIOTAUtils.FindComponents(const ADesigner: IDesigner): TArray<TComponent>;
begin
  var LCompList := TList<TComponent>.Create();
  try
    FComponentNames.Clear();
    ADesigner.GetComponentNames(GetTypeData(TypeInfo(TComponent)), DoListComps);
    for var LCompName in FComponentNames do begin
      LCompList.Add(ADesigner.GetComponent(LCompName));
    end;
    Result := LCompList.ToArray();
  finally
    LCompList.Free();
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
