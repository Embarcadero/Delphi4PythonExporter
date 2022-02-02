unit PythonTools.Menu.ExportProject;

interface

uses
  Vcl.ActnList, Vcl.Menus;

type
  TPythonToolsExportProjectMenuAction = class(TCustomAction)
  public
    procedure AfterConstruction(); override;
    function Update: boolean; override;
  end;

  TPythonToolsExportProjectMenuItem = class(TMenuItem)
  public
    procedure AfterConstruction(); override;
  end;


implementation

uses
  ToolsAPI;

{ TPythonToolsExportProjectMenuAction }

procedure TPythonToolsExportProjectMenuAction.AfterConstruction;
begin
  inherited;
  Name := 'PythonToolsExportProjectAction';
  Caption := 'Export Current Project';
end;

function TPythonToolsExportProjectMenuAction.Update: boolean;
begin
  Enabled := Assigned(GetActiveProject());
  Result := inherited;
end;

{ TPythonToolsExportProjectMenuItem }

procedure TPythonToolsExportProjectMenuItem.AfterConstruction;
begin
  inherited;
  Name := 'PythonToolsExportProjectMenu';
end;

end.
