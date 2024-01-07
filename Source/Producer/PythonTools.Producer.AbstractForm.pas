unit PythonTools.Producer.AbstractForm;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections,
  PythonTools.Common,
  PythonTools.Producer,
  PythonTools.Model.Producer.Application,
  PythonTools.Model.Producer.Form,
  PythonTools.Model.Producer.FormFile;

type
  TAbstractFormProducer = class abstract(TInterfacedObject)
  protected
    function GetPythonModuleName(): string; virtual; abstract;
    function GetPythonFormFileExtension(
      const AMode: TFormFileMode): string; virtual; abstract;
    function GetAppInitializationSection(): string; virtual; abstract;
    //File generators
    procedure GeneratePyApplicationFile(const AStream: TStream;
      const AModel: TApplicationProducerModel);
    procedure GeneratePyFormFile(const AStream: TStream;
      const AFormModel: TFormProducerModel;
      const AFormFileModel: TFormFileProducerModel);
    procedure GeneratePyFormFileBin(const AStream: TStream;
      const AModel: TFormFileProducerModel);
    procedure GeneratePyFormFileTxt(const AStream: TStream;
      const AModel: TFormFileProducerModel);
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
var
  LImportedForms: string;
  LFormInfo: TFormNameAndFile;
  LStrFile: string;
  LBytes: TBytes;
begin
  LImportedForms := String.Empty;
  for LFormInfo in AModel.ImportedForms do begin
    if not LImportedForms.IsEmpty() then
      LImportedForms := LImportedForms + sLineBreak;

    LImportedForms := LImportedForms
      + PY_APP_IMPORT
        .Replace('@FILE', LFormInfo.FileName)
        .Replace('@FORM', LFormInfo.FormName);
  end;

  LStrFile := String.Empty;
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

  LBytes := TEncoding.UTF8.GetBytes(LStrFile);
  AStream.WriteData(LBytes, Length(LBytes));
end;

procedure TAbstractFormProducer.GeneratePyFormFile(const AStream: TStream;
  const AFormModel: TFormProducerModel;
  const AFormFileModel: TFormFileProducerModel);
var
  LProps: string;
  LComp: TExportedComponent;
  LEvts: string;
  LEvt: TExportedEvent;
  LParam: string;
  LStrFile: string;
  LBytes: TBytes;
begin
  LProps := String.Empty;
  for LComp in AFormModel.ExportedComponents do begin
    if not LProps.IsEmpty() then
      LProps := LProps
        + sLineBreak
        + sIdentation2;
    LProps := LProps + 'self.' + LComp.ComponentName + ' = None';
  end;

  LEvts := String.Empty;
  for LEvt in AFormModel.ExportedEvents do begin
    if not LEvts.IsEmpty then
      LEvts := LEvts
        + sLineBreak
        + sLineBreak
        + sIdentation1;
    LEvts := LEvts + 'def ' + LEvt.MethodName + '(self';
    for LParam in LEvt.MethodParams do begin
      LEvts := LEvts + ', ' + LParam
    end;
    LEvts := LEvts + '):'
      + sLineBreak
      + sIdentation2
      + 'pass';
  end;

  LStrFile :=
    PY_MODULE_IMPORT
      .Replace('@MODULE_NAME', GetPythonModuleName())
  + sLineBreak
  + sLineBreak
  + PY_MODULE_CLASS
      .Replace('@CLASSNAME', AFormModel.FormName)
      .Replace('@CLASSPARENT', AFormModel.FormParentName);

  if not LProps.IsEmpty() then
    LStrFile := LStrFile
      + sLineBreak
      + PY_MODULE_PROPS
        .Replace('@PROPERTIES', LProps);

  LStrFile := LStrFile
    + sLineBreak
    + PY_MODULE_LOAD_PROPS
      .Replace('@FILE', AFormModel.FileName)
      .Replace('@FORMFILEEXT', GetPythonFormFileExtension(AFormFileModel.Mode));

  if not LEvts.IsEmpty() then
    LStrFile := LStrFile
      + sLineBreak
      + sLineBreak
      + PY_MODULE_EVTS
        .Replace('@EVENTS', LEvts);

  if AFormModel.ModuleInitialization.GenerateInitialization then
    LStrFile := LStrFile
    + sLineBreak
    + sLineBreak
    + GetAppInitializationSection()
      .Replace('@APP_TITLE', AFormModel.ModuleInitialization.Title.QuotedString())
      .Replace('@CLASSNAME', AFormModel.ModuleInitialization.MainForm);

  LBytes := TEncoding.UTF8.GetBytes(LStrFile);
  AStream.WriteData(LBytes, Length(LBytes));
end;

procedure TAbstractFormProducer.GeneratePyFormFileBin(const AStream: TStream;
  const AModel: TFormFileProducerModel);
begin
  AStream.WriteComponent(AModel.Form);
end;

procedure TAbstractFormProducer.GeneratePyFormFileTxt(const AStream: TStream;
  const AModel: TFormFileProducerModel);
begin
  AStream.CopyFrom(AModel.FormResource, AModel.FormResource.Size);
end;

end.
