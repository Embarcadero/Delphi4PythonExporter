unit PythonTools.Menu.ExportForms;

interface

uses
  Vcl.ActnList, Vcl.Menus;

type
  TPythonToolsExportFormsMenuAction = class(TCustomAction)
  public
    procedure AfterConstruction(); override;
  end;

  TPythonToolsExportFormsMenuItem = class(TMenuItem)
  public
    procedure AfterConstruction(); override;
  end;

implementation

{ TPythonToolsExportFormsMenuAction }

procedure TPythonToolsExportFormsMenuAction.AfterConstruction;
begin
  inherited;
  Name := 'PythonToolsExportFormsAction';
  Caption := 'Export Forms';
end;

{ TPythonToolsExportFormsMenuItem }

procedure TPythonToolsExportFormsMenuItem.AfterConstruction;
begin
  inherited;
  Name := 'PythonToolsExportFormsMenu';
end;

end.
