unit PythonTools.Producer.FMXForm;

interface

uses
  System.Classes,
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
    function GetPythonFormFileExtension(const AMode: TFormFileMode): string; override;
    function GetAppInitializationSection(): string; override;
  public
    function IsValidFormInheritance(const AClass: TClass): boolean;

    procedure SavePyApplicationFile(
      const AModel: TApplicationProducerModel;
      const AStream: TStream);
    procedure SavePyForm(
      const AFormModel: TFormProducerModel;
      const AFormFileModel: TFormFileProducerModel;
      const AStream: TStream);
    procedure SavePyFormFileBin(
      const AModel: TFormFileProducerModel;
      const AStream: TStream);
    procedure SavePyFormFileTxt(
      const AModel: TFormFileProducerModel;
      const AStream: TStream);
  end;

implementation

uses
  System.SysUtils, System.IOUtils, FMX.Forms,
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

function TFMXFormProducer.GetPythonFormFileExtension(
  const AMode: TFormFileMode): string;
begin
  Result := TFormFile('').AsFmx(AMode);
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
  const AModel: TApplicationProducerModel; const AStream: TStream);
begin
  GeneratePyApplicationFile(AStream, AModel);
end;

procedure TFMXFormProducer.SavePyForm(const AFormModel: TFormProducerModel;
  const AFormFileModel: TFormFileProducerModel; const AStream: TStream);
begin
  GeneratePyFormFile(AStream, AFormModel, AFormFileModel);
end;

procedure TFMXFormProducer.SavePyFormFileBin(
  const AModel: TFormFileProducerModel; const AStream: TStream);
begin
  GeneratePyFormFileBin(AStream, AModel);
end;

procedure TFMXFormProducer.SavePyFormFileTxt(
  const AModel: TFormFileProducerModel; const AStream: TStream);
begin
  GeneratePyFormFileTxt(AStream, AModel);
end;

end.
