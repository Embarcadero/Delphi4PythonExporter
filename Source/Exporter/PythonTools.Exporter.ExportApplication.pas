unit PythonTools.Exporter.ExportApplication;

interface

uses
  ToolsAPI,
  PythonTools.Producer,
  PythonTools.Producer.SimpleFactory,
  PythonTools.Model.ExportProject,
  PythonTools.Model.ApplicationProducer;

type
  TExportApplicationExporter = class
  private
    FModel: TExportProjectModel;
    FProject: IOTAProject;
  protected
    //Producers models
    function BuildApplicationModel: TApplicationProducerModel;
    //Exporters
    procedure DoExportApplication;
  public
    constructor Create(const AExportProjectModel: TExportProjectModel;
      const AProject: IOTAProject);

    procedure ExportApplication;
  end;

implementation

uses
  System.SysUtils;

{ TExportApplicationService }

function TExportApplicationExporter.BuildApplicationModel: TApplicationProducerModel;
begin
  Result := TApplicationProducerModel.Create();
  try
    with Result do begin
      MainForm := FModel.ApplicationMainForm.FormName;
      Title := FModel.ApplicationTitle;
      FileName := ChangeFileExt(ExtractFileName(FProject.FileName), '');
      ImportedForms := [FModel.ApplicationMainForm];
      Directory := FModel.ApplicationDirectory;
    end;
  except
    on E: Exception do begin
      FreeAndNil(Result);
      raise;
    end;
  end;
end;

constructor TExportApplicationExporter.Create(
  const AExportProjectModel: TExportProjectModel; const AProject: IOTAProject);
begin
  FModel := AExportProjectModel;
  FProject := AProject;
end;

procedure TExportApplicationExporter.DoExportApplication;
var
  LProducer: IPythonCodeProducer;
  LProducerModel: TApplicationProducerModel;
begin
  LProducer := TProducerSimpleFactory.CreateProducer(FProject.FrameworkType);
  LProducerModel := BuildApplicationModel();
  try
    LProducer.SavePyApplicationFile(LProducerModel);
  finally
    LProducerModel.Free();
  end;
end;

procedure TExportApplicationExporter.ExportApplication;
begin
  DoExportApplication();
end;

end.
