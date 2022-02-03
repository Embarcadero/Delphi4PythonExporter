unit PythonTools.Producer.SimpleFactory;

interface

uses
  PythonTools.Producer;

type
  TProducerSimpleFactory = class
  public
    class function CreateProducer(const AFrameworkType: string): IPythonCodeProducer;
  end;

implementation

uses
  PythonTools.Producer.FMXForm, PythonTools.Producer.VCLForm;

{ TProducerSimpleFactory }

class function TProducerSimpleFactory.CreateProducer(
  const AFrameworkType: string): IPythonCodeProducer;
begin
  if AFrameworkType = 'FMX' then
    Result := TFMXFormProducer.Create()
  else if AFrameworkType = 'VCL' then
    Result := TVCLFormProducer.Create()
end;

end.
