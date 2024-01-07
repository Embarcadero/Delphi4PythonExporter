unit PythonTools.Model.Design.Project;

interface

uses
  System.Classes,
  PythonTools.Common;

type
  TExportProjectDesignModel = class
  private
    FApplicationId: TGUID;
    FApplicationName: string;
    FApplicationDirectory: string;
    FApplicationTitle: string;
    FApplicationForms: TFormNamesAndFiles;
    FApplicationMainForm: TFormNameAndFile;
    FFormFileKind: TFormFileKind;
    FFormFileMode: TFormFileMode;
    FShowInExplorer: boolean;
  public
    property ApplicationId: TGUID read FApplicationId write FApplicationId;
    property ApplicationName: string read FApplicationName write FApplicationName;
    property ApplicationTitle: string read FApplicationTitle write FApplicationTitle;
    property ApplicationForms: TFormNamesAndFiles read FApplicationForms write FApplicationForms;
    property ApplicationMainForm: TFormNameAndFile read FApplicationMainForm write FApplicationMainForm;
    property ApplicationDirectory: string read FApplicationDirectory write FApplicationDirectory;
    property FormFileKind: TFormFileKind read FFormFileKind write FFormFileKind;
    property FormFileMode: TFormFileMode read FFormFileMode write FFormFileMode;
    property ShowInExplorer: boolean read FShowInExplorer write FShowInExplorer;
  end;

implementation

{ TExportProjectModel }

end.
