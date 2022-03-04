unit PythonTools.Producer.FMXForm;

interface

uses
  PythonTools.Common,
  PythonTools.Producer,
  PythonTools.Producer.AbstractForm,
  PythonTools.Model.Producer.Application,
  PythonTools.Model.Producer.Form,
  PythonTools.Model.Producer.FormFile;

type
  TFMXFormProducer = class(TAbstractFormProducer, IPythonCodeProducer)
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
  System.Classes, System.SysUtils, System.IOUtils, FMX.Forms,
  PythonTools.Exceptions;

const
  DELPHI_FMX_MODULE_NAME = 'delphifmx';
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
  + 'Application.MainForm = @CLASSNAME(Application)'
  + sLineBreak
  + sIdentation1
  + 'Application.MainForm.Show()'
  + sLineBreak
  + sIdentation1
  + 'Application.Run()'
  + sLineBreak
  + sIdentation1
  + 'Application.MainForm.Destroy()'
  + sLineBreak
  + sLineBreak
  + 'if __name__ == ''__main__'':'
  + sLineBreak
  + sIdentation1
  + 'main()'
  + sLineBreak;

{ TFMXFormProducer }

function TFMXFormProducer.GetPythonFormFileExtension: string;
begin
  Result := TFormFile('').AsPythonFmx;
end;

function TFMXFormProducer.GetPythonModuleName: string;
begin
  Result := DELPHI_FMX_MODULE_NAME;
end;

function TFMXFormProducer.GetAppInitializationSection: string;
begin
  Result := PY_MODULE_APP_INITIALIZATION;
end;

function TFMXFormProducer.IsValidFormInheritance(const AClass: TClass): boolean;
begin
  Result := AClass = TForm;
end;

procedure TFMXFormProducer.SavePyApplicationFile(
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

procedure TFMXFormProducer.SavePyForm(const AModel: TFormProducerModel);
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

procedure TFMXFormProducer.SavePyFormFileBin(const AModel: TFormFileProducerModel);
var
  LFilePath: string;
  LStream: TStream;
begin
  LFilePath := TPath.Combine(AModel.Directory, AModel.FormFile.AsPythonFmx());

  LStream := TFileStream.Create(LFilePath, fmCreate or fmOpenWrite);
  try
    GeneratePyFormFileBin(LStream, AModel);
  finally
    LStream.Free();
  end;
end;

procedure TFMXFormProducer.SavePyFormFileTxt(
  const AModel: TFormFileProducerModel);
var
  LPyFmxFile: string;
  LStream: TStream;
begin
  LPyFmxFile := TPath.Combine(AModel.Directory, AModel.FormFile.AsPythonFmx());

  LStream := TFileStream.Create(LPyFmxFile, fmCreate or fmOpenWrite);
  try
    GeneratePyFormFileTxt(LStream, AModel);
  finally
    LStream.Free();
  end;
end;

end.
