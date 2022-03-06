unit PythonTools.Model.Design.Forms;

interface

uses
  System.Classes,
  PythonTools.Common;

type
  TOutputForm = record
  private
    FForm: TFormNameAndFile;
    FGenerateInitialization: boolean;
    FTitle: string;
    FFormFileKind: TFormFileKind;
  public
    constructor Create(const AForm: TFormNameAndFile;
      const AGenerateInitialization: boolean;
      const ATitle: string;
      const AFormFileKind: TFormFileKind);

    property Form: TFormNameAndFile read FForm write FForm;
    property GenerateInitialization: boolean read FGenerateInitialization write FGenerateInitialization;
    property Title: string read FTitle write FTitle;
    property FormFileKind: TFormFileKind read FFormFileKind write FFormFileKind;
  end;

  TExportFormsDesignModel = class
  private
    FInputForms: TFormNamesAndFiles;
    FDirectory: string;
    FOutputForms: TArray<TOutputForm>;
  public
    property InputForms: TFormNamesAndFiles read FInputForms write FInputForms;
    property OutputForms: TArray<TOutputForm> read FOutputForms write FOutputForms;
    property Directory: string read FDirectory write FDirectory;
  end;

implementation

{ TOutputForm }

constructor TOutputForm.Create(const AForm: TFormNameAndFile;
  const AGenerateInitialization: boolean; const ATitle: string;
  const AFormFileKind: TFormFileKind);
begin
  Form := AForm;
  GenerateInitialization := AGenerateInitialization;
  Title := ATitle;
  FormFileKind := AFormFileKind;
end;

end.
