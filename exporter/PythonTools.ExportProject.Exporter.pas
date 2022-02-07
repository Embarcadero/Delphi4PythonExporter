unit PythonTools.ExportProject.Exporter;

interface

uses
  ToolsAPI,
  PythonTools.IOTAUtils, PythonTools.Model.ExportProject;

type
  TExportProjectExporter = class
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
    function ExportProject(): boolean;
  end;

implementation

uses
  System.SysUtils,
  PythonTools.Common, PythonTools.Exceptions,
  PythonTools.ExportApplication.Exporter,
  PythonTools.ExportForm.Exporter,
  PythonTools.ExportProject.Design;

{ TExportProjectService }

constructor TExportProjectExporter.Create(const AProject: IOTAProject);
begin
  FProject := AProject;
end;

function TExportProjectExporter.ExportProject: boolean;
begin
  var LExportProjectModel := BuildExportProjectModel();
  try
    //Request user info
    if not RequestExportInfo(LExportProjectModel) then
      Exit(false);
    //Export the application file as the app initializer
    var LAppExporter := TExportApplicationExporter.Create(LExportProjectModel, FProject);
    try
      LAppExporter.ExportApplication();
    finally
      LAppExporter.Free();
    end;

    //Navigate through all forms
    TIOTAUtils.EnumForms(FProject, procedure(AFormInfo: TIOTAFormInfo) begin
      //Check for valid instances
      CheckDesigner(AFormInfo);
      //Export the current form
      var LFormExporter := TExportFormExporter.Create(LExportProjectModel, AFormInfo);
      try
        //Export current form
        LFormExporter.ExportForm();
        //Export current form dfm
        if (LExportProjectModel.FormFileKind = ffkText) then
          LFormExporter.ExportFormFileTxt()
        else if (LExportProjectModel.FormFileKind = ffkBinary) then
          LFormExporter.ExportFormFileBin()
        else
          raise EInvalidFormFileKind.Create('Invalid form file kind.');
      finally
        LFormExporter.Free();
      end;
    end);
    Result := true;
  finally
    LExportProjectModel.Free();
  end;
end;

procedure TExportProjectExporter.CheckDesigner(const AFormInfo: TIOTAFormInfo);
begin
  if not Assigned(AFormInfo.Designer) then
    raise EUnableToObtainFormDesigner.CreateFmt(
      'Unable to obtain the form designer for type %s.', [AFormInfo.ModuleInfo.FormName]);
end;

function TExportProjectExporter.BuildExportProjectModel: TExportProjectModel;
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

function TExportProjectExporter.RequestExportInfo(
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
