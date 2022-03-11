unit PythonTools.Design.Project;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.StdCtrls, Vcl.Buttons,
  PythonTools.Design,
  PythonTools.Common,
  PythonTools.Model.Design.Project, Vcl.WinXCtrls;

{$WARN SYMBOL_PLATFORM OFF}

type
  TProjectExportDialog = class(TDesignForm)
    pnlHeader: TPanel;
    plnFooter: TPanel;
    pnlAppDir: TPanel;
    pnlAppSettings: TPanel;
    imgExport: TImage;
    lblExport: TLabel;
    lblProjectName: TLabel;
    spHeader: TShape;
    lblAppTitle: TLabel;
    edtApplicationTitle: TEdit;
    lblAppMainForm: TLabel;
    cbApplicationMainForm: TComboBox;
    FileOpenDialog1: TFileOpenDialog;
    lblApplicationDirectory: TLabel;
    edtApplicationDirectory: TEdit;
    btnCancel: TButton;
    btnExport: TButton;
    pnlFormFileKind: TPanel;
    lblFormFileKind: TLabel;
    swFormFileKind: TToggleSwitch;
    Label1: TLabel;
    Label2: TLabel;
    llblNotification: TLinkLabel;
    pnlContents: TPanel;
    lbForms: TListBox;
    pnlClient: TPanel;
    cbShowExportedFiles: TCheckBox;
    btnSelectDir: TButton;
    procedure btnExportClick(Sender: TObject);
    procedure btnSelectDirClick(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure Label2Click(Sender: TObject);
    procedure llblNotificationLinkClick(Sender: TObject; const Link: string;
      LinkType: TSysLinkType);
    procedure FormShow(Sender: TObject);
  private
    procedure EnableHorizontalScrollBar(const AListBox: TListBox);
  public
    function Execute(const AModel: TExportProjectDesignModel): boolean;
  end;

var
  ProjectExportDialog: TProjectExportDialog;

implementation

{$R *.dfm}

uses ShellApi;

procedure TProjectExportDialog.btnExportClick(Sender: TObject);
begin
  //Make some validations
  if Trim(edtApplicationTitle.Text) = String.Empty then
    raise Exception.Create('Type the Application Title.');

  if cbApplicationMainForm.ItemIndex = -1 then
    raise Exception.Create('Select the Application Main Form');

  if Trim(edtApplicationDirectory.Text) = String.Empty then
    raise Exception.Create('Select the Application Directory.');

  ModalResult := mrOk;
end;

procedure TProjectExportDialog.EnableHorizontalScrollBar(
  const AListBox: TListBox);
var
  I: integer;
  LMaxWidth: integer;
  LWidth: integer;
begin
  inherited;
  LMaxWidth := AListBox.Width;
  for I := 0 to Pred(AListBox.Items.Count) do begin
    LWidth := Canvas.TextWidth(AListBox.Items[I]);
    if LWidth > LMaxWidth then
      LMaxWidth := LWidth;
  end;

  if (LMaxWidth > AListBox.Width) then
    SendMessage(AListBox.Handle, LB_SETHORIZONTALEXTENT,
      LMaxWidth + GetSystemMetrics(SM_CXFRAME), 0);
end;

function TProjectExportDialog.Execute(const AModel: TExportProjectDesignModel): boolean;
var
  LFormNameAndFile: TFormNameAndFile;
begin
  lblProjectName.Caption := AModel.ApplicationName;
  edtApplicationTitle.Text := AModel.ApplicationTitle;
  edtApplicationDirectory.Text := AModel.ApplicationDirectory;
  cbShowExportedFiles.Checked := AModel.ShowInExplorer;

  for LFormNameAndFile in AModel.ApplicationForms do begin
    cbApplicationMainForm.Items.Add(LFormNameAndFile.CombineFileAndFormName());
    lbForms.Items.Add(LFormNameAndFile.CombineFileAndFormName());
  end;

  if (AModel.ApplicationMainForm.CombineFileAndFormName() <> String.Empty) then
    cbApplicationMainForm.ItemIndex := cbApplicationMainForm.Items.IndexOf(
      AModel.ApplicationMainForm.CombineFileAndFormName())
  else if (cbApplicationMainForm.Items.Count > 0) then
    cbApplicationMainForm.ItemIndex := 0;

  case AModel.FormFileKind of
    ffkText: swFormFileKind.State := tssOff;
    ffkBinary: swFormFileKind.State := tssOn;
  end;

  Result := ShowModal() = mrOk;

  if not Result then
    Exit();

  AModel.ApplicationTitle := edtApplicationTitle.Text;
  AModel.ApplicationMainForm := AModel.ApplicationForms[cbApplicationMainForm.ItemIndex];
  AModel.ApplicationDirectory := edtApplicationDirectory.Text;
  Amodel.ShowInExplorer := cbShowExportedFiles.Checked;

  case swFormFileKind.State of
    tssOff: AModel.FormFileKind := ffkText;
    tssOn: AModel.FormFileKind := ffkBinary;
  end;
end;

procedure TProjectExportDialog.FormShow(Sender: TObject);
begin
  inherited;
  EnableHorizontalScrollBar(lbForms);
end;

procedure TProjectExportDialog.Label1Click(Sender: TObject);
begin
  swFormFileKind.State := tssOn;
end;

procedure TProjectExportDialog.Label2Click(Sender: TObject);
begin
  swFormFileKind.State := tssOff;
end;

procedure TProjectExportDialog.llblNotificationLinkClick(Sender: TObject;
  const Link: string; LinkType: TSysLinkType);
Begin
  ShellExecute(0, 'open', pchar(Link), nil, nil, SW_NORMAL);
end;

procedure TProjectExportDialog.btnSelectDirClick(Sender: TObject);
begin
  with FileOpenDialog1 do begin
    DefaultFolder := edtApplicationDirectory.Text;
    FileName := edtApplicationDirectory.Text;
    if Execute then
      edtApplicationDirectory.Text := FileName
    else
      edtApplicationDirectory.Text := String.Empty;
  end;
end;

end.
