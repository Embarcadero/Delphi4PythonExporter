unit PythonTools.ExportApplication.Service;

interface

uses
  ToolsAPI,
  PythonTools.Model.ExportProject, PythonTools.Producer.SimpleFactory,
  PythonTools.Producer;

type
  TExportApplicationService = class
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

function TExportApplicationService.BuildApplicationModel: TApplicationProducerModel;
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

constructor TExportApplicationService.Create(
  const AExportProjectModel: TExportProjectModel; const AProject: IOTAProject);
begin
  FModel := AExportProjectModel;
  FProject := AProject;
end;

procedure TExportApplicationService.DoExportApplication;
begin
  var LProducer := TProducerSimpleFactory.CreateProducer(FProject.FrameworkType);
  var LProducerModel := BuildApplicationModel();
  try
    LProducer.SavePyApplicationFile(LProducerModel);
  finally
    LProducerModel.Free();
  end;
end;

procedure TExportApplicationService.ExportApplication;
begin
  DoExportApplication();
end;

end.
