unit PythonTools.Producer;

interface

uses
  System.Classes, System.Generics.Collections,
  PythonTools.Common,
  PythonTools.Model.Producer.Application,
  PythonTools.Model.Producer.Form,
  PythonTools.Model.Producer.FormFile;

type
  IPythonCodeProducer = interface
    ['{D3A5C0FE-EAF4-4301-9DA9-E867B3081E21}']
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

const
  //Using 4 spaces identation
  sIdentation1 = '    ';
  sIdentation2 = sIdentation1 + sIdentation1;

implementation

end.
