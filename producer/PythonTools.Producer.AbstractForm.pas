unit PythonTools.Producer.AbstractForm;

interface

uses
  System.Classes, System.Generics.Collections,
  PythonTools.Producer,
  PythonTools.Model.ApplicationProducer,
  PythonTools.Model.FormProducer, System.SysUtils;

type
  TAbstractFormProducer = class abstract(TInterfacedObject)
  protected
    function GetPythonModuleName(): string; virtual; abstract;
    function GetPythonFormFileExtension(): string; virtual; abstract;
    function GetAppInitializationSection(): string; virtual; abstract;
    //File generators
    procedure GeneratePyApplicationFile(const AStream: TStream; const AModel: TApplicationProducerModel);
    procedure GeneratePyFormFile(const AStream: TStream; const AModel: TFormProducerModel);
  public

  end;

implementation

uses
  TypInfo, System.StrUtils;

const
  PY_APP_IMPORTED_FORMS =
    'from @MODULE_NAME import *'
  + sLineBreak
  + '@IMPORTED_FORMS';

  PY_APP_IMPORT =
    'from @FILE import @FORM';

  PY_MODULE_IMPORT =
    'import os'
  + sLineBreak
  + 'from @MODULE_NAME import *';

  PY_MODULE_CLASS =
    'class @CLASSNAME(@CLASSPARENT):'
  + sLineBreak
  + sLineBreak
  + sIdentation1
  + 'def __init__(self, owner):';

  PY_MODULE_PROPS =
    sIdentation2
  + '@PROPERTIES';

  PY_MODULE_LOAD_PROPS =
    sIdentation2
  + 'self.LoadProps(os.path.join(os.path.dirname(os.path.abspath(__file__)), "@FILE@FORMFILEEXT"))';

  PY_MODULE_EVTS =
    sIdentation1
  + '@EVENTS';

{ TAbstractFormProducer }

procedure TAbstractFormProducer.GeneratePyApplicationFile(
  const AStream: TStream; const AModel: TApplicationProducerModel);
begin
  var LImportedForms := String.Empty;
  for var LFormInfo in AModel.ImportedForms do begin
    if not LImportedForms.IsEmpty() then
      LImportedForms := LImportedForms + sLineBreak;

    LImportedForms := LImportedForms
      + PY_APP_IMPORT
        .Replace('@FILE', LFormInfo.FileName)
        .Replace('@FORM', LFormInfo.FormName);
  end;

  var LStrFile := String.Empty;
  if not LImportedForms.IsEmpty() then
    LStrFile :=
      PY_APP_IMPORTED_FORMS
        .Replace('@MODULE_NAME', GetPythonModuleName())
        .Replace('@IMPORTED_FORMS', LImportedForms)
      + sLineBreak
      + sLineBreak;

  LStrFile := LStrFile
    + GetAppInitializationSection()
        .Replace('@APP_TITLE', AModel.Title.QuotedString())
        .Replace('@CLASSNAME', AModel.MainForm);

  var LBytes := TEncoding.UTF8.GetBytes(LStrFile);
  AStream.WriteData(LBytes, Length(LBytes));
end;

procedure TAbstractFormProducer.GeneratePyFormFile(const AStream: TStream;
  const AModel: TFormProducerModel);
begin
  var LProps := String.Empty;
  for var LComp in AModel.ExportedComponents do begin
    if not LProps.IsEmpty() then
      LProps := LProps
        + sLineBreak
        + sIdentation2;
    LProps := LProps + 'self.' + LComp.ComponentName + ' = None';
  end;

  var LEvts := String.Empty;
  for var LEvt in AModel.ExportedEvents do begin
    if not LEvts.IsEmpty then
      LEvts := LEvts
        + sLineBreak
        + sLineBreak
        + sIdentation1;
    LEvts := LEvts + 'def ' + LEvt.MethodName + '(self';
    for var LParam in LEvt.MethodParams do begin
      LEvts := LEvts + ', ' + LParam
    end;
    LEvts := LEvts + '):'
      + sLineBreak
      + sIdentation2
      + 'pass';
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
      .Replace('@FILE', AModel.FileName)
      .Replace('@FORMFILEEXT', GetPythonFormFileExtension());

  if not LEvts.IsEmpty() then
    LStrFile := LStrFile
      + sLineBreak
      + sLineBreak
      + PY_MODULE_EVTS
        .Replace('@EVENTS', LEvts);

  if AModel.ModelInitialization.GenerateInitialization then
    LStrFile := LStrFile
    + sLineBreak
    + sLineBreak
    + GetAppInitializationSection()
      .Replace('@APP_TITLE', AModel.ModelInitialization.Title)
      .Replace('@CLASSNAME', AModel.FormName);

  var LBytes := TEncoding.UTF8.GetBytes(LStrFile);
  AStream.WriteData(LBytes, Length(LBytes));
end;

end.
