unit PythonTools.Producer.VCLForm;

interface

uses
  PythonTools.Producer.AbstractForm, PythonTools.Producer;

type
  TVCLFormProducer = class(TAbstractFormProducer, IPythonCodeProducer)
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
  System.SysUtils;

const
  DELPHI_VCL_MODULE_NAME = 'delphivcl';

{ TVCLFormProducer }

function TVCLFormProducer.GetPythonModuleName: string;
begin
  Result := DELPHI_VCL_MODULE_NAME;
end;

procedure TVCLFormProducer.SavePyApplicationFile(
  const AModel: TApplicationProducerModel);
begin
  raise ENotImplemented.Create('Not implemented');
end;

function TVCLFormProducer.IsValidFormInheritance(const AClass: TClass): boolean;
begin
  raise ENotImplemented.Create('Not implemented');
end;

procedure TVCLFormProducer.SavePyFormFile(const AModel: TFormProducerModel);
begin
  raise ENotImplemented.Create('Not implemented');
end;

procedure TVCLFormProducer.SavePyFormBinDfmFile(const AModel: TFormProducerModel);
begin
  raise ENotImplemented.Create('Not implemented');
end;

end.
