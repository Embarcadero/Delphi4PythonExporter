unit PythonTools.Exporter.Forms;

interface

uses
  ToolsAPI,
  PythonTools.IOTAUtils,
  PythonTools.Model.Design.Forms;

type
  TFormsExporter = class
  protected
    //Producer models
    function BuildExportFormsModel: TExportFormsDesignModel;
  public
    //constructor Create(const AProject: IOTAProject);
    //Request export project info
    function RequestExportInfo(const AModel: TExportFormsDesignModel): boolean;
    //Export the given project
    function ExportForms(): boolean;
  end;

implementation

uses
  System.SysUtils,
  PythonTools.Exceptions,
  PythonTools.Common,
  PythonTools.Exporter.Form,
  PythonTools.Design.Forms;

{ TFormsExporter }

function TFormsExporter.BuildExportFormsModel: TExportFormsDesignModel;
var
  LFormInfo: TFormNameAndFileList;
begin
  Result := TExportFormsDesignModel.Create();
  try
    Result.Title := String.Empty;
    Result.Directory := String.Empty;
    LFormInfo := TFormNameAndFileList.Create();
    try
      TIOTAUtils.EnumForms(procedure(AFormInfo: TIOTAFormInfo) begin
        LFormInfo.Add(TFormNameAndFile.Create(
          AFormInfo.FormName,
          ChangeFileExt(ExtractFileName(AFormInfo.FileName), '')));
      end);
      Result.Forms := LFormInfo.ToArray();
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

function TFormsExporter.ExportForms: boolean;
var
  I: integer;
  LExportModel: TExportFormsDesignModel;
  LFormInfo: TIOTAFormInfo;
  LFormExporter: TFormExporterFromForms;
begin
  LExportModel := BuildExportFormsModel();
  try
    //Request user info
    if not RequestExportInfo(LExportModel) then
      Exit(false);

    //Navigate through all forms
    for I := Low(LExportModel.Forms) to High(LExportModel.Forms) do
      if TIOTAUtils.FindForm(LExportModel.Forms[I].FormName, LFormInfo) then begin
        //Export the current form
        LFormExporter := TFormExporterFromForms.Create(LExportModel, LFormInfo);
        try
          //Export current form
          LFormExporter.ExportForm();
          //Export current form dfm
          if (LExportModel.FormFileKind = ffkText) then
            LFormExporter.ExportFormFileTxt()
          else if (LExportModel.FormFileKind = ffkBinary) then
            LFormExporter.ExportFormFileBin()
          else
            raise EInvalidFormFileKind.Create('Invalid form file kind.');
        finally
          LFormExporter.Free();
        end;
      end;
  finally
    LExportModel.Free();
  end;
  Result := true;
end;

function TFormsExporter.RequestExportInfo(
  const AModel: TExportFormsDesignModel): boolean;
var
  LForm: TFormsExportDialog;
begin
  LForm := TFormsExportDialog.Create(nil);
  try
    Result := LForm.Execute(AModel);
  finally
    LForm.Free();
  end;
end;

end.
