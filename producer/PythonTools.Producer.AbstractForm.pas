unit PythonTools.Producer.AbstractForm;

interface

uses
  DesignIntf, System.Classes, System.Generics.Collections,
  PythonTools.Producer;

type
  TAbstractFormProducer = class abstract(TInterfacedObject)
  protected
    function GetPythonModuleName(): string; virtual; abstract;
    //File generators
    procedure GenerateFormPyFile(const AStream: TStream; const AModel: TFormProducerModel);
  public

  end;

implementation

uses
  TypInfo, System.SysUtils, System.StrUtils;

const
  //Using 4 spaces identation
  sIdentation1 = '    ';
  sIdentation2 = sIdentation1 + sIdentation1;

const
  PY_MODULE_IMPORT =
    'import os'
  + sLineBreak
  + 'from @MODULE_NAME import *';

  PY_MODULE_CLASS =
    'class @CLASSNAME(@CLASSPARENT):'
  + sLineBreak
  + sIdentation1
  + 'def __init__(self, owner):';

  PY_MODULE_PROPS =
    sIdentation2
  + '@PROPERTIES';

  PY_MODULE_LOAD_PROPS =
    sIdentation2
  + 'self.LoadProps(os.path.join(os.path.dirname(os.path.abspath(__file__)), "@CLASSNAME.pydfm"))';

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

{ TAbstractFormProducer }

procedure TAbstractFormProducer.GenerateFormPyFile(const AStream: TStream;
  const AModel: TFormProducerModel);
begin
  var LProps := String.Empty;
  for var LComp in AModel.ExportedComponents do begin
    if not LProps.IsEmpty() then
      LProps := LProps + sLineBreak + '        ';
    LProps := LProps + 'self.' + LComp.Name + ' = None';
  end;

  var LStrFile :=
    PY_MODULE_IMPORT
      .Replace('@MODULE_NAME', GetPythonModuleName())
  + sLineBreak
  + sLineBreak
  + PY_MODULE_CLASS
      .Replace('@CLASSNAME', AModel.FormName)
      .Replace('@CLASSPARENT', AModel.FormParentName);

  if not LProps.IsEmpty() then
    LStrFile := LStrFile
      + sLineBreak
      + PY_MODULE_PROPS
        .Replace('@PROPERTIES', LProps);

  LStrFile := LStrFile
    + sLineBreak
    + PY_MODULE_LOAD_PROPS
      .Replace('@CLASSNAME', AModel.FormName);

  if AModel.ModelInitialization.GenerateInitialization then
    LStrFile := LStrFile
    + sLineBreak
    + sLineBreak
    + PY_MODULE_APP_INITIALIZATION
      .Replace('@APP_TITLE', AModel.ModelInitialization.Title)
      .Replace('@CLASSNAME', AModel.FormName);

  var LBytes := TEncoding.UTF8.GetBytes(LStrFile);
  AStream.WriteData(LBytes, Length(LBytes));
end;

end.
