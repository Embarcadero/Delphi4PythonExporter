unit PythonTools.Model.ExportProject;

interface

uses
  System.Classes,
  PythonTools.Common;

type
  TExportProjectModel = class
  private
    FApplicationName: string;
    FApplicationDirectory: string;
    FApplicationTitle: string;
    FApplicationForms: TFormNamesAndFiles;
    FApplicationMainForm: TFormNameAndFile;
  public
    property ApplicationName: string read FApplicationName write FApplicationName;
    property ApplicationTitle: string read FApplicationTitle write FApplicationTitle;
    property ApplicationForms: TFormNamesAndFiles read FApplicationForms write FApplicationForms;
    property ApplicationMainForm: TFormNameAndFile read FApplicationMainForm write FApplicationMainForm;
    property ApplicationDirectory: string read FApplicationDirectory write FApplicationDirectory;
  end;

implementation

{ TExportProjectModel }

end.
