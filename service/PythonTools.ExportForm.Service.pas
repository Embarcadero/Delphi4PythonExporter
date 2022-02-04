unit PythonTools.ExportForm.Service;

interface

uses
  DesignIntf, System.Classes, System.Generics.Collections,
  PythonTools.Model.ExportProject, PythonTools.IOTAUtils, PythonTools.Producer;

type
  TExportFormService = class
  private
    FModel: TExportProjectModel;
    FFormInfo: TIOTAFormInfo;
    //Utils
    function FindComponents(const ADesigner: IDesigner): TArray<TComponent>;
  protected
     //Producer models
    function BuildFormModel: TFormProducerModel;
    function BuildDfmModel: TDfmProducerModel;
    //Exporters
    procedure DoExportForm;
    procedure DoExportBinDfm;
  public
    constructor Create(const AModel: TExportProjectModel; AFormInfo: TIOTAFormInfo);

    procedure ExportForm;
    procedure ExportBinDfm;
  end;

implementation

uses
  System.SysUtils, PythonTools.Exceptions, PythonTools.Producer.SimpleFactory;

{ TExportFormService }

constructor TExportFormService.Create(const AModel: TExportProjectModel;
  AFormInfo: TIOTAFormInfo);
begin
  FModel := AModel;
  FFormInfo := AFormInfo;
end;

function TExportFormService.FindComponents(
  const ADesigner: IDesigner): TArray<TComponent>;
begin
  var LIOTAUtils := TIOTAUtils.Create();
  try
    Result := LIOTAUtils.FindComponents(ADesigner);
  finally
    LIOTAUtils.Free();
  end;
end;

procedure TExportFormService.ExportForm;
begin
  DoExportForm();
end;

procedure TExportFormService.ExportBinDfm;
begin
  DoExportBinDfm();
end;

function TExportFormService.BuildFormModel: TFormProducerModel;
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

function TExportFormService.BuildDfmModel: TDfmProducerModel;
begin
  Result := TDfmProducerModel.Create();
  try
    with Result do begin
      FileName := ChangeFileExt(ExtractFileName(FFormInfo.ModuleInfo.FileName), '');
      Form := FFormInfo.Designer.Root;
      Directory := FModel.ApplicationDirectory;
    end;
  except
    on E: Exception do begin
      FreeAndNil(Result);
      raise;
    end;
  end;
end;

procedure TExportFormService.DoExportForm;
begin
  var LProducer := TProducerSimpleFactory.CreateProducer(FFormInfo.Project.FrameworkType);
  if not LProducer.IsValidFormInheritance(FFormInfo.Designer.Root.ClassParent) then
    raise EFormInheritanceNotSupported.CreateFmt(
      '%s TForm direct inheritance only', [FFormInfo.Project.FrameworkType]);

  var LProducerModel := BuildFormModel();
  try
    LProducer.SavePyFormFile(LProducerModel);
  finally
    LProducerModel.Free();
  end;
end;

procedure TExportFormService.DoExportBinDfm;
begin
  var LProducer := TProducerSimpleFactory.CreateProducer(FFormInfo.Project.FrameworkType);
  var LProducerModel := BuildDfmModel();
  try
    LProducer.SavePyFormBinDfmFile(LProducerModel);
  finally
    LProducerModel.Free();
  end;
end;

end.
