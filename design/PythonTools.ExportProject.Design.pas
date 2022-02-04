unit PythonTools.ExportProject.Design;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  Vcl.StdCtrls, Vcl.Buttons, PythonTools.Model.ExportProject,
  PythonTools.Common;

type
  TProjectExport = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    imgExport: TImage;
    lblExport: TLabel;
    lblProjectName: TLabel;
    Shape1: TShape;
    Label1: TLabel;
    edtApplicationTitle: TEdit;
    Label2: TLabel;
    cbApplicationMainForm: TComboBox;
    FileOpenDialog1: TFileOpenDialog;
    lblApplicationDirectory: TLabel;
    edtApplicationDirectory: TEdit;
    btnCancel: TButton;
    btnExport: TButton;
    SpeedButton1: TSpeedButton;
    procedure FormCanResize(Sender: TObject; var NewWidth, NewHeight: Integer;
      var Resize: Boolean);
    procedure btnExportClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    function Execute(const AModel: TExportProjectModel): boolean;
  end;

var
  ProjectExport: TProjectExport;

implementation

{$R *.dfm}

procedure TProjectExport.btnExportClick(Sender: TObject);
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

function TProjectExport.Execute(const AModel: TExportProjectModel): boolean;
begin
  lblProjectName.Caption := AModel.ApplicationName;
  for var LFormNameAndFile in AModel.ApplicationForms do begin
    cbApplicationMainForm.Items.Add(LFormNameAndFile.FileName + '.' + LFormNameAndFile.FormName);
  end;
  if cbApplicationMainForm.Items.Count > 0 then
    cbApplicationMainForm.ItemIndex := 0;
  edtApplicationDirectory.Text := AModel.ApplicationDirectory;

  Result := ShowModal() = mrOk;

  if not Result then
    Exit();

  AModel.ApplicationTitle := edtApplicationTitle.Text;
  AModel.ApplicationMainForm := AModel.ApplicationForms[cbApplicationMainForm.ItemIndex];
  AModel.ApplicationDirectory := edtApplicationDirectory.Text;
end;

procedure TProjectExport.FormCanResize(Sender: TObject; var NewWidth,
  NewHeight: Integer; var Resize: Boolean);
begin
  Resize := false;
end;

procedure TProjectExport.SpeedButton1Click(Sender: TObject);
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
