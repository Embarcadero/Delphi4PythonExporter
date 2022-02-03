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
    procedure SavePyFile(const AModel: TFormProducerModel);
    procedure SavePyBinDfmFile(const AModel: TFormProducerModel);
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

procedure TFMXFormProducer.SavePyFile(const AModel: TFormProducerModel);
begin
  var LFilePath := TPath.Combine(AModel.Directory,
    ChangeFileExt(AModel.FileName, '.py'));

  var LStream := TFileStream.Create(LFilePath, fmCreate or fmOpenWrite);
  try
    GenerateFormPyFile(LStream, AModel);
  finally
    LStream.Free();
  end;
end;

procedure TFMXFormProducer.SavePyBinDfmFile(const AModel: TFormProducerModel);
begin

end;

end.
