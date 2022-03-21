unit PythonTools.Exporter.Project;

interface

uses
  ToolsAPI,
  PythonTools.IOTAUtils,
  PythonTools.Model.Design.Project;

type
  TProjectExporter = class
  private
    FProject: IOTAProject;
  protected
    //Checks
    procedure CheckDesigner(const AFormInfo: TIOTAFormInfo);
    //Producer models
    function BuildExportProjectModel: TExportProjectDesignModel;
  public
    constructor Create(const AProject: IOTAProject);
    //Request export project info
    function RequestExportInfo(const AModel: TExportProjectDesignModel): boolean;
    //Export the given project
    function ExportProject(): boolean;
  end;

implementation

uses
  System.SysUtils,
  ShellApi, Winapi.Windows,
  PythonTools.Exceptions, PythonTools.Common, PythonTools.Registry,
  PythonTools.Exporter.Application,
  PythonTools.Exporter.Form,
  PythonTools.Design.Project;

{ TProjectExporter }

constructor TProjectExporter.Create(const AProject: IOTAProject);
begin
  FProject := AProject;
end;

function TProjectExporter.ExportProject: boolean;
var
  LExportProjectModel: TExportProjectDesignModel;
  LAppExporter: TApplicationExporter;
begin
  LExportProjectModel := BuildExportProjectModel();
  try
    TExporterRegistry.LoadProjectModel(LExportProjectModel);
    //Request user info
    if not RequestExportInfo(LExportProjectModel) then
      Exit(false);
    TExporterRegistry.SaveProjectModel(LExportProjectModel);
    //Export the application file as the app initializer
    LAppExporter := TApplicationExporter.Create(LExportProjectModel, FProject);
    try
      LAppExporter.ExportApplication();
    finally
      LAppExporter.Free();
    end;

    //Navigate through all forms
    TIOTAUtils.EnumForms(FProject, procedure(AFormInfo: TIOTAFormInfo)
    var
      LFormExporter: TFormExporter;
    begin
      //Check for valid instances
      CheckDesigner(AFormInfo);
      //Export the current form
      LFormExporter := TFormExporterFromProject.Create(LExportProjectModel, AFormInfo);
      try
        //Export current form
        LFormExporter.ExportForm();
        //Export current form dfm/fmx
        LFormExporter.ExportFormFile(LExportProjectModel.FormFileKind);
      finally
        LFormExporter.Free();
      end;
    end);

    if LExportProjectModel.ShowInExplorer then
      ShellExecute(0, 'open', PChar(LExportProjectModel.ApplicationDirectory), nil, nil, SW_NORMAL);

    Result := true;
  finally
    LExportProjectModel.Free();
  end;
end;

procedure TProjectExporter.CheckDesigner(const AFormInfo: TIOTAFormInfo);
begin
  if not Assigned(AFormInfo.Designer) then
    raise EUnableToObtainFormDesigner.CreateFmt(
      'Unable to obtain the form designer for type %s.', [AFormInfo.FormName]);
end;

function TProjectExporter.BuildExportProjectModel: TExportProjectDesignModel;
var
  LFormInfo: TFormNameAndFileList;
begin
  Result := TExportProjectDesignModel.Create();
  try
    Result.ApplicationId := FProject.GetProjectGUID();
    Result.ApplicationName := ChangeFileExt(
      ExtractFileName(FProject.FileName), String.Empty);
    LFormInfo := TFormNameAndFileList.Create();
    try
      TIOTAUtils.EnumForms(FProject, procedure(AFormInfo: TIOTAFormInfo) begin
        LFormInfo.Add(TFormNameAndFile.Create(
          AFormInfo.FormName,
          ChangeFileExt(ExtractFileName(AFormInfo.FileName), '')));
      end);
      Result.ApplicationForms := LFormInfo.ToArray();
    finally
      LFormInfo.Free();
    end;
  except
    on E: Exception do begin
      FreeAndNil(Result);
      raise;
    end;
  end;
end;

function TProjectExporter.RequestExportInfo(
  const AModel: TExportProjectDesignModel): boolean;
var
  LForm: TProjectExportDialog;
begin
  LForm := TProjectExportDialog.Create(nil);
  try
    Result := LForm.Execute(AModel);
  finally
    LForm.Free();
  end;
end;

end.
