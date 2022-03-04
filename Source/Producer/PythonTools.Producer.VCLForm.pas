unit PythonTools.Producer.VCLForm;

interface

uses
  PythonTools.Common,
  PythonTools.Producer,
  PythonTools.Producer.AbstractForm,
  PythonTools.Model.Producer.Application,
  PythonTools.Model.Producer.Form,
  PythonTools.Model.Producer.FormFile;

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
  Result := TFormFile('').AsPythonDfm();
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
var
  LFilePath: string;
  LStream: TStream;
begin
  LFilePath := TPath.Combine(AModel.Directory, AModel.FileName.AsPython());

  LStream := TFileStream.Create(LFilePath, fmCreate or fmOpenWrite);
  try
    GeneratePyApplicationFile(LStream, AModel);
  finally
    LStream.Free();
  end;
end;

procedure TVCLFormProducer.SavePyForm(const AModel: TFormProducerModel);
var
  LFilePath: string;
  LStream: TStream;
begin
  LFilePath := TPath.Combine(AModel.Directory, AModel.FileName.AsPython());

  LStream := TFileStream.Create(LFilePath, fmCreate or fmOpenWrite);
  try
    GeneratePyFormFile(LStream, AModel);
  finally
    LStream.Free();
  end;
end;

procedure TVCLFormProducer.SavePyFormFileBin(const AModel: TFormFileProducerModel);
var
  LFilePath: string;
  LStream: TStream;
begin
  LFilePath := TPath.Combine(AModel.Directory, AModel.FormFile.AsPythonDfm());

  LStream := TFileStream.Create(LFilePath, fmCreate or fmOpenWrite);
  try
    GeneratePyFormFileBin(LStream, AModel);
  finally
    LStream.Free();
  end;
end;

procedure TVCLFormProducer.SavePyFormFileTxt(
  const AModel: TFormFileProducerModel);
var
  LPyDfmFile: string;
  LStream: TStream;
begin
  LPyDfmFile := TPath.Combine(AModel.Directory, AModel.FormFile.AsPythonDfm());

  LStream := TFileStream.Create(LPyDfmFile, fmCreate or fmOpenWrite);
  try
    GeneratePyFormFileTxt(LStream, AModel);
  finally
    LStream.Free();
  end;
end;

end.
