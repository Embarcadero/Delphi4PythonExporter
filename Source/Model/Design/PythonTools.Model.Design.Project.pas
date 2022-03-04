unit PythonTools.Model.Design.Project;

interface

uses
  System.Classes,
  PythonTools.Common;

type
  TExportProjectDesignModel = class
  private
    FApplicationName: string;
    FApplicationDirectory: string;
    FApplicationTitle: string;
    FApplicationForms: TFormNamesAndFiles;
    FApplicationMainForm: TFormNameAndFile;
    FFormFileKind: TFormFileKind;
  public
    property ApplicationName: string read FApplicationName write FApplicationName;
    property ApplicationTitle: string read FApplicationTitle write FApplicationTitle;
    property ApplicationForms: TFormNamesAndFiles read FApplicationForms write FApplicationForms;
    property ApplicationMainForm: TFormNameAndFile read FApplicationMainForm write FApplicationMainForm;
    property ApplicationDirectory: string read FApplicationDirectory write FApplicationDirectory;
    property FormFileKind: TFormFileKind read FFormFileKind write FFormFileKind;
  end;

implementation

{ TExportProjectModel }

end.
