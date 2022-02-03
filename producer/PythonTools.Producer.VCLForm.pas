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
    procedure SavePyFile(const AModel: TFormProducerModel);
    procedure SavePyBinDfmFile(const AModel: TFormProducerModel);
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

function TVCLFormProducer.IsValidFormInheritance(const AClass: TClass): boolean;
begin
  raise ENotImplemented.Create('Not implemented');
end;

procedure TVCLFormProducer.SavePyBinDfmFile(const AModel: TFormProducerModel);
begin
  raise ENotImplemented.Create('Not implemented');
end;

procedure TVCLFormProducer.SavePyFile(const AModel: TFormProducerModel);
begin
  raise ENotImplemented.Create('Not implemented');
end;

end.
