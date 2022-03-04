unit PythonTools.Model.Design.Forms;

interface

uses
  System.Classes,
  PythonTools.Common;

type
  TExportFormsDesignModel = class
  private
    FForms: TFormNamesAndFiles;
    FGenerateInitialization: boolean;
    FTitle: string;
    FMainForm: TFormNameAndFile;
    FDirectory: string;
    FFormFileKind: TFormFileKind;
  public
    property Forms: TFormNamesAndFiles read FForms write FForms;
    property GenerateInitialization: boolean read FGenerateInitialization write FGenerateInitialization;
    property Title: string read FTitle write FTitle;
    property MainForm: TFormNameAndFile read FMainForm write FMainForm;
    property Directory: string read FDirectory write FDirectory;
    property FormFileKind: TFormFileKind read FFormFileKind write FFormFileKind;
  end;

implementation

end.
