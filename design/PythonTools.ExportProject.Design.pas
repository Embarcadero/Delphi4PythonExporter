unit PythonTools.ExportProject.Design;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.StdCtrls, Vcl.Buttons, PythonTools.Model.ExportProject,
  PythonTools.Common;

type
  TProjectExportDialog = class(TForm)
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
    btnSelectDir: TSpeedButton;
    pnlFormFileKind: TPanel;
    pnlExpOpts: TPanel;
    lblExpOpts: TLabel;
    rgFormFileKind: TRadioGroup;
    lblFormFileKind: TLabel;
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure btnExportClick(Sender: TObject);
    procedure btnSelectDirClick(Sender: TObject);
  private
    { Private declarations }
  public
    function Execute(const AModel: TExportProjectModel): boolean;
  end;

var
  ProjectExportDialog: TProjectExportDialog;

implementation

{$R *.dfm}

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

function TProjectExportDialog.Execute(const AModel: TExportProjectModel): boolean;
begin
  lblProjectName.Caption := AModel.ApplicationName;
  for var LFormNameAndFile in AModel.ApplicationForms do begin
    cbApplicationMainForm.Items.Add(LFormNameAndFile.FileName + '.' + LFormNameAndFile.FormName);
  end;
  if cbApplicationMainForm.Items.Count > 0 then
    cbApplicationMainForm.ItemIndex := 0;
  edtApplicationDirectory.Text := AModel.ApplicationDirectory;

  case AModel.FormFileKind of
    ffkText: rgFormFileKind.ItemIndex := 0;
    ffkBinary: rgFormFileKind.ItemIndex := 1;
  end;

  Result := ShowModal() = mrOk;

  if not Result then
    Exit();

  AModel.ApplicationTitle := edtApplicationTitle.Text;
  AModel.ApplicationMainForm := AModel.ApplicationForms[cbApplicationMainForm.ItemIndex];
  AModel.ApplicationDirectory := edtApplicationDirectory.Text;

  case rgFormFileKind.ItemIndex of
    0: AModel.FormFileKind := ffkText;
    1: AModel.FormFileKind := ffkBinary;
  end;
end;

procedure TProjectExportDialog.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  Resize := false;
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
