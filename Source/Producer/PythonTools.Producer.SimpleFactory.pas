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
  System.SysUtils,
  PythonTools.Producer.FMXForm,
  PythonTools.Producer.VCLForm;

{ TProducerSimpleFactory }

class function TProducerSimpleFactory.CreateProducer(
  const AFrameworkType: string): IPythonCodeProducer;
begin
  if CompareText(AFrameworkType, 'FMX') = 0 then
    Result := TFMXFormProducer.Create()
  else if CompareText(AFrameworkType, 'VCL') = 0 then
    Result := TVCLFormProducer.Create()
end;

end.
