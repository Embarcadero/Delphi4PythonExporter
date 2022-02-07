unit PythonTools.Producer.FMXForm;

interface

uses
  PythonTools.Producer.AbstractForm, PythonTools.Producer;

type
  TFMXFormProducer = class(TAbstractFormProducer, IPythonCodeProducer)
  protected
    function GetPythonModuleName(): string; override;
    function GetAppInitializationSection(): string; override;
  public
    function IsValidFormInheritance(const AClass: TClass): boolean;
    procedure SavePyApplicationFile(const AModel: TApplicationProducerModel);
    procedure SavePyFormFile(const AModel: TFormProducerModel);
    procedure SavePyFormBinDfmFile(const AModel: TDfmProducerModel);
  end;

implementation

uses
  System.Classes, System.SysUtils, System.IOUtils, FMX.Forms;

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

procedure TFMXFormProducer.SavePyFormFile(const AModel: TFormProducerModel);
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

procedure TFMXFormProducer.SavePyFormBinDfmFile(const AModel: TDfmProducerModel);
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

end.
