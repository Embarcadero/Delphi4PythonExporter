unit PythonTools.Design.Forms;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.StdCtrls, Vcl.Buttons,
  PythonTools.Model.Design.Forms;

type
  TFormsExportDialog = class(TForm)
    FileOpenDialog1: TFileOpenDialog;
    pnlHeader: TPanel;
    imgExport: TImage;
    lblDescription: TLabel;
    lblExport: TLabel;
    spHeader: TShape;
    pnlContents: TPanel;
    lbForms: TListBox;
    pnlCenter: TPanel;
    pnlFormFileKind: TPanel;
    lblFormFileKind: TLabel;
    rgFormFileKind: TRadioGroup;
    pnlExpOpts: TPanel;
    lblExpOpts: TLabel;
    pnlDir: TPanel;
    lblDirectory: TLabel;
    btnSelectDir: TSpeedButton;
    edtDirectory: TEdit;
    pnlSettings: TPanel;
    lblAppTitle: TLabel;
    edtTitle: TEdit;
    plnFooter: TPanel;
    btnCancel: TButton;
    btnExport: TButton;
    cbMainForm: TComboBox;
    lbForm: TLabel;
    pnlInitialization: TPanel;
    cbGenerateInitialization: TCheckBox;
    procedure cbGenerateInitializationClick(Sender: TObject);
    procedure btnExportClick(Sender: TObject);
    procedure btnSelectDirClick(Sender: TObject);
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure lbFormsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    function Execute(const AModel: TExportFormsDesignModel): boolean;
  end;

var
  FormsExportDialog: TFormsExportDialog;

implementation

uses
  PythonTools.Common;

{$R *.dfm}

procedure TFormsExportDialog.btnExportClick(Sender: TObject);
begin
  //Make some validations
  if cbMainForm.Items.Count = 0 then
    raise Exception.Create('Select one form at least.');

  if cbGenerateInitialization.Checked then begin
    if Trim(edtTitle.Text) = String.Empty then
      raise Exception.Create('Type the Title.');

    if cbMainForm.ItemIndex = -1 then
      raise Exception.Create('Select the Main Form');
  end;

  if Trim(edtDirectory.Text) = String.Empty then
    raise Exception.Create('Select the Directory.');

  ModalResult := mrOk;
end;

procedure TFormsExportDialog.btnSelectDirClick(Sender: TObject);
begin
  with FileOpenDialog1 do begin
    DefaultFolder := edtDirectory.Text;
    FileName := edtDirectory.Text;
    if Execute then
      edtDirectory.Text := FileName
    else
      edtDirectory.Text := String.Empty;
  end;
end;

procedure TFormsExportDialog.cbGenerateInitializationClick(Sender: TObject);
begin
  pnlSettings.Visible := cbGenerateInitialization.Checked;
end;

function TFormsExportDialog.Execute(const AModel: TExportFormsDesignModel): boolean;
var
  LFormNamesAndFiles: TFormNameAndFileList;
  LFormNameAndFile: TFormNameAndFile;
  I: integer;
begin
  lbForms.Clear();
  for LFormNameAndFile in AModel.Forms do begin
    lbForms.Items.Add(LFormNameAndFile.FileName + '.' + LFormNameAndFile.FormName);
  end;

  edtDirectory.Text := AModel.Directory;

  case AModel.FormFileKind of
    ffkText: rgFormFileKind.ItemIndex := 0;
    ffkBinary: rgFormFileKind.ItemIndex := 1;
  end;

  Result := ShowModal() = mrOk;

  if not Result then
    Exit();

  LFormNamesAndFiles := TFormNameAndFileList.Create();
  try
    for I := 0 to lbForms.Items.Count -1 do begin
      if lbForms.Selected[I] then
        LFormNamesAndFiles.Add(AModel.Forms[I]);
    end;
    AModel.Forms := LFormNamesAndFiles.ToArray();
  finally
    LFormNamesAndFiles.Free();
  end;

  AModel.GenerateInitialization := cbGenerateInitialization.Checked;
  if cbGenerateInitialization.Checked then begin
    AModel.Title := edtTitle.Text;
    AModel.MainForm := AModel.Forms[cbMainForm.ItemIndex];
  end else begin
    AModel.Title := String.Empty;
    AModel.MainForm := Default(TFormNameAndFile);
  end;

  AModel.Directory := edtDirectory.Text;

  case rgFormFileKind.ItemIndex of
    0: AModel.FormFileKind := ffkText;
    1: AModel.FormFileKind := ffkBinary;
  end;
end;

procedure TFormsExportDialog.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  //Resize := false;
end;

procedure TFormsExportDialog.FormShow(Sender: TObject);
begin
  pnlSettings.Visible := false;
end;

procedure TFormsExportDialog.lbFormsClick(Sender: TObject);
var
  LMainForm: string;
begin
  if cbMainForm.ItemIndex > -1 then
    LMainForm := cbMainForm.Items.Names[cbMainForm.ItemIndex]
  else
    LMainForm := String.Empty;

  cbMainForm.Clear();
  lbForms.CopySelection(cbMainForm);

  if not LMainForm.IsEmpty and (cbMainForm.Items.IndexOf(LMainForm) > -1) then
    cbMainForm.ItemIndex := cbMainForm.Items.IndexOf(LMainForm)
  else if (cbMainForm.Items.Count = 1) then
    cbMainForm.ItemIndex := 0
  else
    cbMainForm.ItemIndex := -1;
end;

end.
