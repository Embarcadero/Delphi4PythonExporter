unit PythonTools.Exporter.Form;

interface

uses
  DesignIntf,
  System.Classes, System.Generics.Collections, System.Rtti,
  PythonTools.Common,
  PythonTools.IOTAUtils,
  PythonTools.Model.Design.Project,
  PythonTools.Model.Design.Forms,
  PythonTools.Model.Producer.Form,
  PythonTools.Model.Producer.FormFile;

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
    procedure DoExportFormFileBin;
    procedure DoExportFormFileTxt;
  public
    constructor Create(const AFormInfo: TIOTAFormInfo);

    procedure ExportForm;
    procedure ExportFormFileBin;
    procedure ExportFormFileTxt;
  end;

  TFormExporterFromProject = class(TFormExporter)
  private
    FModel: TExportProjectDesignModel;
  protected
    //Producer models
    function BuildFormModel: TFormProducerModel; override;
    function BuildFormFileModel: TFormFileProducerModel; override;
  public
    constructor Create(const AModel: TExportProjectDesignModel; const  AFormInfo: TIOTAFormInfo);
  end;

  TFormExporterFromForms = class(TFormExporter)
  private
    FModel: TExportFormsDesignModel;
  protected
    //Producer models
    function BuildFormModel: TFormProducerModel; override;
    function BuildFormFileModel: TFormFileProducerModel; override;
  public
    constructor Create(const AModel: TExportFormsDesignModel; const  AFormInfo: TIOTAFormInfo);
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

procedure TFormExporter.ExportFormFileTxt;
begin
  DoExportFormFileTxt();
end;

procedure TFormExporter.ExportFormFileBin;
begin
  DoExportFormFileBin();
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
      //Directory := FDirectory;
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

procedure TFormExporter.DoExportFormFileTxt;
var
  LProducer: IPythonCodeProducer;
  LProducerModel: TFormFileProducerModel;
begin
  LProducer := TProducerSimpleFactory.CreateProducer(FormInfo.FrameworkType);
  LProducerModel := BuildFormFileModel();
  try
    LProducer.SavePyFormFileTxt(LProducerModel);
  finally
    LProducerModel.Free();
  end;
end;

procedure TFormExporter.DoExportFormFileBin;
var
  LProducer: IPythonCodeProducer;
  LProducerModel: TFormFileProducerModel;
begin
  LProducer := TProducerSimpleFactory.CreateProducer(FormInfo.FrameworkType);
  LProducerModel := BuildFormFileModel();
  try
    LProducer.SavePyFormFileBin(LProducerModel);
  finally
    LProducerModel.Free();
  end;
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
  const AFormInfo: TIOTAFormInfo);
begin
  inherited Create(AFormInfo);
  FModel := AModel;
end;

function TFormExporterFromForms.BuildFormFileModel: TFormFileProducerModel;
begin
  Result := inherited;
  Result.Directory := FModel.Directory;
end;

function TFormExporterFromForms.BuildFormModel: TFormProducerModel;
begin
  Result := inherited;
  Result.Directory := FModel.Directory;
  with Result.ModuleInitialization do begin
    GenerateInitialization := FModel.GenerateInitialization;
    Title := FModel.Title;
    MainForm := FModel.MainForm.FormName;
  end;
end;

end.
