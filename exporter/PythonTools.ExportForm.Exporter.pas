unit PythonTools.ExportForm.Exporter;

interface

uses
  DesignIntf, System.Classes, System.Generics.Collections,
  PythonTools.IOTAUtils,
  PythonTools.Model.ExportProject,
  PythonTools.Model.FormProducer,
  PythonTools.Model.FormFileProducer;

type
  TExportFormExporter = class
  private
    FModel: TExportProjectModel;
    FFormInfo: TIOTAFormInfo;
    //Utils
    function FindComponents(const ADesigner: IDesigner): TArray<TComponent>;
  protected
     //Producer models
    function BuildFormModel: TFormProducerModel;
    function BuildFormFileModel: TFormFileProducerModel;
    //Exporters
    procedure DoExportForm;
    procedure DoExportFormFileBin;
    procedure DoExportFormFileTxt;
  public
    constructor Create(const AModel: TExportProjectModel; AFormInfo: TIOTAFormInfo);

    procedure ExportForm;
    procedure ExportFormFileBin;
    procedure ExportFormFileTxt;
  end;

implementation

uses
  System.SysUtils, PythonTools.Exceptions, PythonTools.Producer.SimpleFactory;

{ TExportFormService }

constructor TExportFormExporter.Create(const AModel: TExportProjectModel;
  AFormInfo: TIOTAFormInfo);
begin
  FModel := AModel;
  FFormInfo := AFormInfo;
end;

function TExportFormExporter.FindComponents(
  const ADesigner: IDesigner): TArray<TComponent>;
begin
  var LIOTAUtils := TIOTAUtils.Create();
  try
    Result := LIOTAUtils.FindComponents(ADesigner);
  finally
    LIOTAUtils.Free();
  end;
end;

procedure TExportFormExporter.ExportForm;
begin
  DoExportForm();
end;

procedure TExportFormExporter.ExportFormFileTxt;
begin
  DoExportFormFileTxt();
end;

procedure TExportFormExporter.ExportFormFileBin;
begin
  DoExportFormFileBin();
end;

function TExportFormExporter.BuildFormModel: TFormProducerModel;
begin
  Result := TFormProducerModel.Create();
  try
    with Result do begin
      FormName := FFormInfo.ModuleInfo.FormName;
      FormParentName := System.Copy(
        FFormInfo.Designer.Root.ClassParent.ClassName,
        2,
        FFormInfo.Designer.Root.ClassParent.ClassName.Length);
      FileName := ChangeFileExt(ExtractFileName(FFormInfo.ModuleInfo.FileName), '');
      Directory := FModel.ApplicationDirectory;
      ExportedComponents := FindComponents(FFormInfo.Designer);
      with ModelInitialization do begin
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

function TExportFormExporter.BuildFormFileModel: TFormFileProducerModel;
begin
  Result := TFormFileProducerModel.Create();
  try
    with Result do begin
      FileName := ChangeFileExt(ExtractFileName(FFormInfo.ModuleInfo.FileName), '');
      Directory := FModel.ApplicationDirectory;
      FormFilePath := ChangeFileExt(FFormInfo.ModuleInfo.FileName, '');
      Form := FFormInfo.Designer.Root;
    end;
  except
    on E: Exception do begin
      FreeAndNil(Result);
      raise;
    end;
  end;
end;

procedure TExportFormExporter.DoExportForm;
begin
  var LProducer := TProducerSimpleFactory.CreateProducer(FFormInfo.Project.FrameworkType);
  if not LProducer.IsValidFormInheritance(FFormInfo.Designer.Root.ClassParent) then
    raise EFormInheritanceNotSupported.CreateFmt(
      '%s TForm direct inheritance only', [FFormInfo.Project.FrameworkType]);

  var LProducerModel := BuildFormModel();
  try
    LProducer.SavePyForm(LProducerModel);
  finally
    LProducerModel.Free();
  end;
end;

procedure TExportFormExporter.DoExportFormFileTxt;
begin
  var LProducer := TProducerSimpleFactory.CreateProducer(FFormInfo.Project.FrameworkType);
  var LProducerModel := BuildFormFileModel();
  try
    LProducer.SavePyFormFileTxt(LProducerModel);
  finally
    LProducerModel.Free();
  end;
end;

procedure TExportFormExporter.DoExportFormFileBin;
begin
  var LProducer := TProducerSimpleFactory.CreateProducer(FFormInfo.Project.FrameworkType);
  var LProducerModel := BuildFormFileModel();
  try
    LProducer.SavePyFormFileBin(LProducerModel);
  finally
    LProducerModel.Free();
  end;
end;

end.
