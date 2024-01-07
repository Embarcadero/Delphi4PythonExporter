unit PythonTools.Producer.VCLForm;

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
  TVCLFormProducer = class(TAbstractFormProducer, IPythonCodeProducer)
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
  System.SysUtils, System.IOUtils, Vcl.Forms,
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

function TVCLFormProducer.GetPythonFormFileExtension(
  const AMode: TFormFileMode): string;
begin
  Result := TFormFile('').AsDfm(AMode);
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
  const AModel: TApplicationProducerModel; const AStream: TStream);
begin
  GeneratePyApplicationFile(AStream, AModel);
end;

procedure TVCLFormProducer.SavePyForm(const AFormModel: TFormProducerModel;
  const AFormFileModel: TFormFileProducerModel; const AStream: TStream);
begin
  GeneratePyFormFile(AStream, AFormModel, AFormFileModel);
end;

procedure TVCLFormProducer.SavePyFormFileBin(
  const AModel: TFormFileProducerModel; const AStream: TStream);
begin
  GeneratePyFormFileBin(AStream, AModel);
end;

procedure TVCLFormProducer.SavePyFormFileTxt(
  const AModel: TFormFileProducerModel; const AStream: TStream);
begin
  GeneratePyFormFileTxt(AStream, AModel);
end;

end.
