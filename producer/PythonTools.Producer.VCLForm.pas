unit PythonTools.Producer.VCLForm;

interface

uses
  PythonTools.Producer.AbstractForm, PythonTools.Producer;

type
  TVCLFormProducer = class(TAbstractFormProducer, IPythonCodeProducer)
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
  System.SysUtils, System.IOUtils, System.Classes, Vcl.Forms;

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

procedure TVCLFormProducer.SavePyFormFile(const AModel: TFormProducerModel);
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

procedure TVCLFormProducer.SavePyFormBinDfmFile(const AModel: TDfmProducerModel);
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
