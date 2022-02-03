unit PythonTools.Producer.FMXForm;

interface

uses
  PythonTools.Producer.AbstractForm, PythonTools.Producer;

type
  TFMXFormProducer = class(TAbstractFormProducer, IPythonCodeProducer)
  protected
    function GetPythonModuleName(): string; override;
  public
    function IsValidFormInheritance(const AClass: TClass): boolean;
    procedure SavePyApplicationFile(const AModel: TApplicationProducerModel);
    procedure SavePyFormFile(const AModel: TFormProducerModel);
    procedure SavePyFormBinDfmFile(const AModel: TFormProducerModel);
  end;

implementation

uses
  System.Classes, System.SysUtils, System.IOUtils, FMX.Forms;

const
  DELPHI_FMX_MODULE_NAME = 'delphifmx';

{ TFMXFormProducer }

function TFMXFormProducer.GetPythonModuleName: string;
begin
  Result := DELPHI_FMX_MODULE_NAME;
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

procedure TFMXFormProducer.SavePyFormBinDfmFile(const AModel: TFormProducerModel);
begin

end;

end.
