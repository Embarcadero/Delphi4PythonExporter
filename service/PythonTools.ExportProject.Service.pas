unit PythonTools.ExportProject.Service;

interface

uses
  ToolsAPI,
  PythonTools.IOTAUtils, PythonTools.Model.ExportProject;

type
  TExportProjectService = class
  private
    FProject: IOTAProject;
  protected
    //Checks
    procedure CheckDesigner(const AFormInfo: TIOTAFormInfo);
    //Producer models
    function BuildExportProjectModel: TExportProjectModel;
  public
    constructor Create(const AProject: IOTAProject);
    //Request export project info
    function RequestExportInfo(const AModel: TExportProjectModel): boolean;
    //Export the given project
    procedure ExportProject();
  end;

implementation

uses
  System.SysUtils,
  PythonTools.Common, PythonTools.Exceptions,
  PythonTools.ExportApplication.Service,
  PythonTools.ExportForm.Service,
  PythonTools.ExportProject.Design;

{ TExportProjectService }

constructor TExportProjectService.Create(const AProject: IOTAProject);
begin
  FProject := AProject;
end;

procedure TExportProjectService.ExportProject;
begin
  var LExportProjectModel := BuildExportProjectModel();
  try
    //Request user info
    if not RequestExportInfo(LExportProjectModel) then
      Exit;
    //Export the application file as the app initializer
    var LAppService := TExportApplicationService.Create(LExportProjectModel, FProject);
    try
      LAppService.ExportApplication();
    finally
      LAppService.Free();
    end;

    //Navigate through all forms
    TIOTAUtils.EnumForms(FProject, procedure(AFormInfo: TIOTAFormInfo) begin
      //Check for valid instances
      CheckDesigner(AFormInfo);
      //Export the current form
      var LService := TExportFormService.Create(LExportProjectModel, AFormInfo);
      try
        //Export current form
        LService.ExportForm();
        //Export current form dfm
        LService.ExportBinDfm();
      finally
        LService.Free();
      end;
    end);
  finally
    LExportProjectModel.Free();
  end;
end;

procedure TExportProjectService.CheckDesigner(const AFormInfo: TIOTAFormInfo);
begin
  if not Assigned(AFormInfo.Designer) then
    raise EUnableToObtainFormDesigner.CreateFmt(
      'Unable to obtain the form designer for type %s.', [AFormInfo.ModuleInfo.FormName]);
end;

function TExportProjectService.BuildExportProjectModel: TExportProjectModel;
begin
  Result := TExportProjectModel.Create();
  try
    Result.ApplicationName := ChangeFileExt(
      ExtractFileName(FProject.FileName), String.Empty);
    Result.ApplicationDirectory := ExtractFileDir(FProject.FileName);
    var LFormInfo := TFormNameAndFileList.Create();
    try
      TIOTAUtils.EnumForms(FProject, procedure(AFormInfo: TIOTAFormInfo) begin
        LFormInfo.Add(TFormNameAndFile.Create(
          AFormInfo.ModuleInfo.FormName,
          ChangeFileExt(ExtractFileName(AFormInfo.ModuleInfo.FileName), '')));
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

function TExportProjectService.RequestExportInfo(
  const AModel: TExportProjectModel): boolean;
begin
  var LForm := TProjectExportDialog.Create(nil);
  try
    Result := LForm.Execute(AModel);
  finally
    LForm.Free();
  end;
end;

end.
