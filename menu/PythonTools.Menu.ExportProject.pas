unit PythonTools.Menu.ExportProject;

interface

uses
  System.Classes, Vcl.ActnList, Vcl.Menus;

type
  TPythonToolsExportProjectMenuAction = class(TCustomAction)
  private
    procedure DoExportProject(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;

    function Update: boolean; override;
  end;

  TPythonToolsExportProjectMenuItem = class(TMenuItem)
  public
    procedure AfterConstruction(); override;
  end;

implementation

uses
  ToolsAPI, System.SysUtils;

function GetFormEditorFromModule(Module: IOTAModule): IOTAFormEditor;
begin
  if Module = nil then
    Exit(nil);

  for var I := 0 to Module.GetModuleFileCount - 1 do begin
    var LEditor := Module.GetModuleFileEditor(i);
    if Supports(LEditor, IOTAFormEditor, Result) then
      Break;
  end;
end;

{ TPythonToolsExportProjectMenuAction }

constructor TPythonToolsExportProjectMenuAction.Create(AOwner: TComponent);
begin
  inherited;
  Name := 'PythonToolsExportProjectAction';
  Caption := 'Export Current Project';
  OnExecute := DoExportProject;
end;

function TPythonToolsExportProjectMenuAction.Update: boolean;
begin
  Enabled := Assigned(GetActiveProject());
  Result := inherited;
end;

procedure TPythonToolsExportProjectMenuAction.DoExportProject(Sender: TObject);
begin
  //Navigate through all forms
  var LProject := GetActiveProject();
  for var I := 0 to LProject.GetModuleCount() - 1 do begin
    var LModuleInfo := LProject.GetModule(I);
    if (LModuleInfo.ModuleType = omtForm) then begin
      if not LModuleInfo.FormName.Trim().IsEmpty() then begin
        var LModule := LModuleInfo.OpenModule();
        var LFormEditor := GetFormEditorFromModule(LModule);
        if LProject.FrameworkType = 'FMX' then begin

        end else if LProject.FrameworkType = 'VCL' then begin

        end;
      end;
    end;
  end;
end;

{ TPythonToolsExportProjectMenuItem }

procedure TPythonToolsExportProjectMenuItem.AfterConstruction;
begin
  inherited;
  Name := 'PythonToolsExportProjectMenu';
end;

end.
