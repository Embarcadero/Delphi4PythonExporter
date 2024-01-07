unit PythonTools.Exporter.Application;

interface

uses
  ToolsAPI,
  PythonTools.Common,
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
    function BuildApplicationProducerModel: TApplicationProducerModel;
    //Exporters
    procedure DoExportApplication;
  public
    constructor Create(const AExportProjectModel: TExportProjectDesignModel;
      const AProject: IOTAProject);

    procedure ExportApplication;
  end;

implementation

uses
  System.IOUtils,
  System.Classes,
  System.SysUtils;

{ TApplicationExporter }

function TApplicationExporter.BuildApplicationProducerModel: TApplicationProducerModel;
begin
  Result := TApplicationProducerModel.Create();
  try
    Result.Directory := FModel.ApplicationDirectory;
    Result.FileName := ChangeFileExt(ExtractFileName(FProject.FileName), '');
    Result.MainForm := FModel.ApplicationMainForm.FormName;
    Result.Title := FModel.ApplicationTitle;
    Result.ImportedForms := [FModel.ApplicationMainForm];
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

  LProducerModel := BuildApplicationProducerModel();
  try
    LProducer.SavePyApplicationFile(LProducerModel, LProducerModel.Stream);
  finally
    LProducerModel.Free();
  end;
end;

procedure TApplicationExporter.ExportApplication;
begin
  DoExportApplication();
end;

end.
