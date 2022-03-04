unit PythonTools.Exporter.Application;

interface

uses
  ToolsAPI,
  PythonTools.Producer,
  PythonTools.Producer.SimpleFactory,
  PythonTools.Model.Design.Project,
  PythonTools.Model.Producer.Application;

type
  TApplicationExporter = class
  private
    FModel: TExportProjectDesignModel;
    FProject: IOTAProject;
  protected
    //Producers models
    function BuildApplicationModel: TApplicationProducerModel;
    //Exporters
    procedure DoExportApplication;
  public
    constructor Create(const AExportProjectModel: TExportProjectDesignModel;
      const AProject: IOTAProject);

    procedure ExportApplication;
  end;

implementation

uses
  System.SysUtils;

{ TApplicationExporter }

function TApplicationExporter.BuildApplicationModel: TApplicationProducerModel;
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

constructor TApplicationExporter.Create(
  const AExportProjectModel: TExportProjectDesignModel; const AProject: IOTAProject);
begin
  FModel := AExportProjectModel;
  FProject := AProject;
end;

procedure TApplicationExporter.DoExportApplication;
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

procedure TApplicationExporter.ExportApplication;
begin
  DoExportApplication();
end;

end.
