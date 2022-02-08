unit PythonTools.Menu.ExportProject;

interface

uses
  ToolsAPI,
  System.Classes, System.SysUtils,
  Vcl.ActnList, Vcl.Menus, Vcl.Dialogs;

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
  System.StrUtils,
  PythonTools.Exporter.ExportProject;

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
  //Exports the current project
  var LExporter := TExportProjectExporter.Create(GetActiveProject());
  try
    if LExporter.ExportProject() then
      ShowMessage('Project successfully exported.');
  finally
    LExporter.Free();
  end;
end;

{ TPythonToolsExportProjectMenuItem }

procedure TPythonToolsExportProjectMenuItem.AfterConstruction;
begin
  inherited;
  Name := 'PythonToolsExportProjectMenu';
end;

end.
