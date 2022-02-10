unit PythonTools.Producer.FMXForm;

interface

uses
  PythonTools.Common,
  PythonTools.Producer,
  PythonTools.Producer.AbstractForm,
  PythonTools.Model.ApplicationProducer,
  PythonTools.Model.FormProducer,
  PythonTools.Model.FormFileProducer;

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
begin
  var LFilePath := TPath.Combine(AModel.Directory, AModel.FileName.AsPython());

  var LStream := TFileStream.Create(LFilePath, fmCreate or fmOpenWrite);
  try
    GeneratePyApplicationFile(LStream, AModel);
  finally
    LStream.Free();
  end;
end;

procedure TFMXFormProducer.SavePyForm(const AModel: TFormProducerModel);
begin
  var LFilePath := TPath.Combine(AModel.Directory, AModel.FileName.AsPython());

  var LStream := TFileStream.Create(LFilePath, fmCreate or fmOpenWrite);
  try
    GeneratePyFormFile(LStream, AModel);
  finally
    LStream.Free();
  end;
end;

procedure TFMXFormProducer.SavePyFormFileBin(const AModel: TFormFileProducerModel);
begin
  var LFilePath := TPath.Combine(AModel.Directory, AModel.FormFile.AsPythonFmx());

  var LStream := TFileStream.Create(LFilePath, fmCreate or fmOpenWrite);
  try
    LStream.WriteComponent(AModel.Form);
  finally
    LStream.Free();
  end;
end;

procedure TFMXFormProducer.SavePyFormFileTxt(
  const AModel: TFormFileProducerModel);
begin
  var LFmxFile := AModel.FormFilePath.AsDelphiFmx();
  if not TFile.Exists(LFmxFile) then
    raise EFormFileNotFound.CreateFmt('Fmx file not found at: %s', [LFmxFile]);

  var LPyFmxFile := TPath.Combine(
    AModel.Directory,
    AModel.FormFile.AsPythonFmx()
  );

  TFile.Copy(LFmxFile, LPyFmxFile, true);
end;

end.
