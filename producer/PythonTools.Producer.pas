unit PythonTools.Producer;

interface

uses
  System.Classes, System.Generics.Collections,
  PythonTools.Common,
  PythonTools.Model.ApplicationProducer,
  PythonTools.Model.FormProducer,
  PythonTools.Model.FormFileProducer;

type
  IPythonCodeProducer = interface
    ['{D3A5C0FE-EAF4-4301-9DA9-E867B3081E21}']
    function IsValidFormInheritance(const AClass: TClass): boolean;
    procedure SavePyApplicationFile(const AModel: TApplicationProducerModel);
    procedure SavePyForm(const AModel: TFormProducerModel);
    procedure SavePyFormFileBin(const AModel: TFormFileProducerModel);
    procedure SavePyFormFileTxt(const AModel: TFormFileProducerModel);
  end;

implementation

end.
