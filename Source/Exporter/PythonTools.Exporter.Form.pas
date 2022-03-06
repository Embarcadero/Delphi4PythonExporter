unit PythonTools.Exporter.Form;

interface

uses
  DesignIntf,
  System.Classes, System.Generics.Collections, System.Rtti,
  PythonTools.Common,
  PythonTools.IOTAUtils,
  PythonTools.Model.Producer.Form,
  PythonTools.Model.Producer.FormFile,
  PythonTools.Model.Design.Forms,
  PythonTools.Model.Design.Project;

type
  TFormExporter = class abstract
  private
    //Utils
    function FindComponents(): TExportedComponents;
    function FindEvents(): TExportedEvents;
  protected
    FormInfo: TIOTAFormInfo;
    //Producer models
    function BuildFormModel: TFormProducerModel; virtual;
    function BuildFormFileModel: TFormFileProducerModel; virtual;
    //Exporters
    procedure DoExportForm(const AModel: TFormProducerModel);
    procedure DoExportFormFileBin(const AModel: TFormFileProducerModel);
    procedure DoExportFormFileTxt(const AModel: TFormFileProducerModel);
  public
    constructor Create(const AFormInfo: TIOTAFormInfo);

    procedure ExportForm;
    procedure ExportFormFile(const AFormFileKind: TFormFileKind);
  end;

  TFormExporterFromProject = class sealed(TFormExporter)
  private
    FModel: TExportProjectDesignModel;
  protected
    //Producer models
    function BuildFormModel: TFormProducerModel; override;
    function BuildFormFileModel: TFormFileProducerModel; override;
  public
    constructor Create(const AModel: TExportProjectDesignModel; const  AFormInfo: TIOTAFormInfo);
  end;

  TFormExporterFromForms = class sealed(TFormExporter)
  private
    FModel: TExportFormsDesignModel;
    FCurrentForm: integer;
  protected
    //Producer models
    function BuildFormModel: TFormProducerModel; override;
    function BuildFormFileModel: TFormFileProducerModel; override;
  public
    constructor Create(const AModel: TExportFormsDesignModel;
      const ACurrentForm: integer; const  AFormInfo: TIOTAFormInfo);
  end;

implementation

uses
  System.SysUtils,
  PythonTools.Exceptions,
  PythonTools.Producer,
  PythonTools.Producer.SimpleFactory;

{ TFormExporter }

constructor TFormExporter.Create(const AFormInfo: TIOTAFormInfo);
begin
  FormInfo := AFormInfo;
end;

function TFormExporter.FindComponents(): TExportedComponents;
begin
  Result := TIOTAUtils.FindComponents(FormInfo.Editor);
end;

function TFormExporter.FindEvents(): TExportedEvents;
begin
  Result := TIOTAUtils.FindEvents(FormInfo.Editor, FormInfo.Designer);
end;

procedure TFormExporter.ExportForm;
var
  LProducerModel: TFormProducerModel;
begin
  LProducerModel := BuildFormModel();
  try
    DoExportForm(LProducerModel);
  finally
    LProducerModel.Free();
  end;
end;

procedure TFormExporter.ExportFormFile(const AFormFileKind: TFormFileKind);
var
  LProducerModel: TFormFileProducerModel;
begin
  LProducerModel := BuildFormFileModel();
  try
    if (AFormFileKind = ffkText) then
      DoExportFormFileTxt(LProducerModel)
    else if (AFormFileKind = ffkBinary) then
      DoExportFormFileBin(LProducerModel)
    else
      raise EInvalidFormFileKind.Create('Invalid form file kind.');
  finally
    LProducerModel.Free();
  end;
end;

function TFormExporter.BuildFormModel: TFormProducerModel;
begin
  Result := TFormProducerModel.Create();
  try
    with Result do begin
      FormName := FormInfo.FormName;
      FormParentName := System.Copy(
        FormInfo.Designer.Root.ClassParent.ClassName,
        2,
        FormInfo.Designer.Root.ClassParent.ClassName.Length);
      FileName := ChangeFileExt(ExtractFileName(FormInfo.FileName), '');
      ExportedComponents := FindComponents();
      ExportedEvents := FindEvents();
      with ModuleInitialization do begin
        GenerateInitialization := false;
      end;
    end;
  except
    on E: Exception do begin
      FreeAndNil(Result);
      raise;
    end;
  end;
end;

function TFormExporter.BuildFormFileModel: TFormFileProducerModel;
var
  LStreamAdapter: TStreamAdapter;
begin
  Result := TFormFileProducerModel.Create();
  try
    with Result do begin
      FormFile := ChangeFileExt(ExtractFileName(FormInfo.FileName), '');
      Form := FormInfo.Designer.Root;
      LStreamAdapter := TStreamAdapter.Create(FormResource);
      FormInfo.Editor.GetFormResource(LStreamAdapter);
      FormResource.Position := 0;
    end;
  except
    on E: Exception do begin
      FreeAndNil(Result);
      raise;
    end;
  end;
end;

procedure TFormExporter.DoExportForm(const AModel: TFormProducerModel);
var
  LProducer: IPythonCodeProducer;
begin
  LProducer := TProducerSimpleFactory.CreateProducer(FormInfo.FrameworkType);

  if not LProducer.IsValidFormInheritance(FormInfo.Designer.Root.ClassParent) then
    raise EFormInheritanceNotSupported.CreateFmt(
      '%s TForm direct inheritance only', [FormInfo.FrameworkType]);

  LProducer.SavePyForm(AModel);
end;

procedure TFormExporter.DoExportFormFileTxt(const AModel: TFormFileProducerModel);
var
  LProducer: IPythonCodeProducer;
begin
  LProducer := TProducerSimpleFactory.CreateProducer(FormInfo.FrameworkType);
  LProducer.SavePyFormFileTxt(AModel);
end;

procedure TFormExporter.DoExportFormFileBin(const AModel: TFormFileProducerModel);
var
  LProducer: IPythonCodeProducer;
begin
  LProducer := TProducerSimpleFactory.CreateProducer(FormInfo.FrameworkType);
  LProducer.SavePyFormFileBin(AModel);
end;

{ TFormExporterFromProject }

constructor TFormExporterFromProject.Create(
  const AModel: TExportProjectDesignModel; const AFormInfo: TIOTAFormInfo);
begin
  inherited Create(AFormInfo);
  FModel := AModel;
end;

function TFormExporterFromProject.BuildFormFileModel: TFormFileProducerModel;
begin
  Result := inherited;
  Result.Directory := FModel.ApplicationDirectory;
end;

function TFormExporterFromProject.BuildFormModel: TFormProducerModel;
begin
  Result := inherited;
  Result.Directory := FModel.ApplicationDirectory;
end;

{ TFormExporterFromForms }

constructor TFormExporterFromForms.Create(const AModel: TExportFormsDesignModel;
  const ACurrentForm: integer; const AFormInfo: TIOTAFormInfo);
begin
  inherited Create(AFormInfo);
  FModel := AModel;
  FCurrentForm := ACurrentForm;
end;

function TFormExporterFromForms.BuildFormFileModel: TFormFileProducerModel;
begin
  Result := inherited;
  Result.Directory := FModel.Directory;
end;

function TFormExporterFromForms.BuildFormModel: TFormProducerModel;
var
  LForm: TOutputForm;
begin
  Result := inherited;
  Result.Directory := FModel.Directory;
  with Result.ModuleInitialization do begin
    LForm := FModel.OutputForms[FCurrentForm];
    //Generate the initialization section for the MainForm only
    if LForm.GenerateInitialization
      and (Result.FormName = LForm.Form.FormName) then
    begin
      GenerateInitialization := true;
      Title := LForm.Title;
      MainForm := LForm.Form.FormName;
    end else
      GenerateInitialization := false;
  end;
end;

end.
