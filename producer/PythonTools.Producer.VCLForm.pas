unit PythonTools.Producer.VCLForm;

interface

uses
  PythonTools.Producer,
  PythonTools.Producer.AbstractForm,
  PythonTools.Model.ApplicationProducer,
  PythonTools.Model.FormProducer,
  PythonTools.Model.FormFileProducer;

type
  TVCLFormProducer = class(TAbstractFormProducer, IPythonCodeProducer)
  protected
    function GetPythonModuleName(): string; override;
    function GetPythonFormFileExtension(): string; override;
    function GetAppInitializationSection(): string; override;
  public
    function IsValidFormInheritance(const AClass: TClass): boolean;
    procedure SavePyApplicationFile(const AModel: TApplicationProducerModel);
    procedure SavePyForm(const AModel: TFormProducerModel);
    procedure SavePyFormFileBin(const AModel: TFormFileProducerModel);
    procedure SavePyFormFileTxt(const AModel: TFormFileProducerModel);
  end;

implementation

uses
  System.SysUtils, System.IOUtils, System.Classes, Vcl.Forms,
  PythonTools.Exceptions;

const
  DELPHI_VCL_MODULE_NAME = 'delphivcl';
  PY_MODULE_APP_INITIALIZATION =
    'def main():'
  + sLineBreak
  + sIdentation1
  + 'Application.Initialize()'
  + sLineBreak
  + sIdentation1
  + 'Application.Title = @APP_TITLE'
  + sLineBreak
  + sIdentation1
  + 'MainForm = @CLASSNAME(Application)'
  + sLineBreak
  + sIdentation1
  + 'MainForm.Show()'
  + sLineBreak
  + sIdentation1
  + 'FreeConsole()'
  + sLineBreak
  + sIdentation1
  + 'Application.Run()'
  + sLineBreak
  + sLineBreak
  + 'if __name__ == ''__main__'':'
  + sLineBreak
  + sIdentation1
  + 'main()'
  + sLineBreak;

{ TVCLFormProducer }

function TVCLFormProducer.GetPythonFormFileExtension: string;
begin
  Result := '.pydfm';
end;

function TVCLFormProducer.GetPythonModuleName: string;
begin
  Result := DELPHI_VCL_MODULE_NAME;
end;

function TVCLFormProducer.GetAppInitializationSection: string;
begin
  Result := PY_MODULE_APP_INITIALIZATION;
end;

function TVCLFormProducer.IsValidFormInheritance(const AClass: TClass): boolean;
begin
  Result := AClass = TForm;
end;

procedure TVCLFormProducer.SavePyApplicationFile(
  const AModel: TApplicationProducerModel);
begin
  var LFilePath := TPath.Combine(AModel.Directory,
    ChangeFileExt(AModel.FileName, '.py'));

  var LStream := TFileStream.Create(LFilePath, fmCreate or fmOpenWrite);
  try
    GeneratePyApplicationFile(LStream, AModel);
  finally
    LStream.Free();
  end;
end;

procedure TVCLFormProducer.SavePyForm(const AModel: TFormProducerModel);
begin
  var LFilePath := TPath.Combine(AModel.Directory,
    ChangeFileExt(AModel.FileName, '.py'));

  var LStream := TFileStream.Create(LFilePath, fmCreate or fmOpenWrite);
  try
    GeneratePyFormFile(LStream, AModel);
  finally
    LStream.Free();
  end;
end;

procedure TVCLFormProducer.SavePyFormFileBin(const AModel: TFormFileProducerModel);
begin
  var LFilePath := TPath.Combine(AModel.Directory,
    ChangeFileExt(AModel.FileName, '.pydfm'));

  var LStream := TFileStream.Create(LFilePath, fmCreate or fmOpenWrite);
  try
    LStream.WriteComponent(AModel.Form);
  finally
    LStream.Free();
  end;
end;

procedure TVCLFormProducer.SavePyFormFileTxt(
  const AModel: TFormFileProducerModel);
begin
  var LDfmFile := AModel.FormFilePath.AsDfm();
  if not TFile.Exists(LDfmFile) then
    raise EFormFileNotFound.CreateFmt('Dfm file not found at: %s', [LDfmFile]);

  var LPyDfm := TPath.Combine(
    AModel.Directory,
    ExtractFileName(ChangeFileExt(LDfmFile, '.pydfm'))
  );

  TFile.Copy(LDfmFile, LPyDfm, true);
end;

end.
