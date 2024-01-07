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
    FFormFileMode: TFormFileMode;
  public
    constructor Create(const AForm: TFormNameAndFile;
      const AGenerateInitialization: boolean;
      const ATitle: string;
      const AFormFileKind: TFormFileKind;
      const AFormFileMode: TFormFileMode);

    property Form: TFormNameAndFile read FForm write FForm;
    property GenerateInitialization: boolean read FGenerateInitialization write FGenerateInitialization;
    property Title: string read FTitle write FTitle;
    property FormFileKind: TFormFileKind read FFormFileKind write FFormFileKind;
    property FormFileMode: TFormFileMode read FFormFileMode write FFormFileMode;
  end;

  TInputForm = record
  private
    FForm: TFormNameAndFile;
    FTitle: string;
  public
    property Form: TFormNameAndFile read FForm write FForm;
    property Title: string read FTitle write FTitle;
  end;

  TExportFormsDesignModel = class
  private
    FInputForms: TArray<TInputForm>;
    FDirectory: string;
    FOutputForms: TArray<TOutputForm>;
    FShowInExplorer: boolean;
  public
    property InputForms: TArray<TInputForm> read FInputForms write FInputForms;
    property OutputForms: TArray<TOutputForm> read FOutputForms write FOutputForms;
    property Directory: string read FDirectory write FDirectory;
    property ShowInExplorer: boolean read FShowInExplorer write FShowInExplorer;
  end;

implementation

{ TOutputForm }

constructor TOutputForm.Create(const AForm: TFormNameAndFile;
  const AGenerateInitialization: boolean; const ATitle: string;
  const AFormFileKind: TFormFileKind; const AFormFileMode: TFormFileMode);
begin
  Form := AForm;
  GenerateInitialization := AGenerateInitialization;
  Title := ATitle;
  FormFileKind := AFormFileKind;
  FormFileMode := AFormFileMode;
end;

end.
