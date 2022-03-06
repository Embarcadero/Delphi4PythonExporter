unit PythonTools.Menu.ExportForms;

interface

uses
  Vcl.ActnList, Vcl.Menus;

type
  TPythonToolsExportFormsMenuAction = class(TCustomAction)
  private
    procedure DoExportForms(Sender: TObject);
  public
    procedure AfterConstruction(); override;

    function Update: boolean; override;
  end;

  TPythonToolsExportFormsMenuItem = class(TMenuItem)
  public
    procedure AfterConstruction(); override;
  end;

implementation

uses
  Vcl.Dialogs,
  PythonTools.IOTAUtils,
  PythonTools.Exporter.Forms;

{ TPythonToolsExportFormsMenuAction }

procedure TPythonToolsExportFormsMenuAction.AfterConstruction;
begin
  inherited;
  Name := 'PythonToolsExportFormsAction';
  Caption := 'Export Forms';
  OnExecute := DoExportForms;
end;

procedure TPythonToolsExportFormsMenuAction.DoExportForms(Sender: TObject);
var
  LExporter: TFormsExporter;
begin
  //Exports the current project
  LExporter := TFormsExporter.Create();
  try
    if LExporter.ExportForms() then
      ShowMessage('Forms successfully exported.');
  finally
    LExporter.Free();
  end;
end;

function TPythonToolsExportFormsMenuAction.Update: boolean;
begin
  Enabled := TIOTAUtils.HasForms();
  Result := inherited;
end;

{ TPythonToolsExportFormsMenuItem }

procedure TPythonToolsExportFormsMenuItem.AfterConstruction;
begin
  inherited;
  Name := 'PythonToolsExportFormsMenu';
end;

end.
