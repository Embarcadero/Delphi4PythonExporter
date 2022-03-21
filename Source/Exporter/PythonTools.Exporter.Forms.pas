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
  System.SysUtils, System.Generics.Collections,
  ShellApi, Winapi.Windows,
  PythonTools.Exceptions, PythonTools.Common, PythonTools.Registry,
  PythonTools.Exporter.Form,
  PythonTools.Design.Forms;

{ TFormsExporter }

function TFormsExporter.BuildExportFormsModel: TExportFormsDesignModel;
var
  LInputs: TList<TInputForm>;
  LInput: TInputForm;
begin
  Result := TExportFormsDesignModel.Create();
  try
//    Result.Title := String.Empty;
    Result.Directory := String.Empty;
    LInputs := TList<TInputForm>.Create();
    try
      TIOTAUtils.EnumForms(procedure(AFormInfo: TIOTAFormInfo) begin
        LInput.Form := TFormNameAndFile.Create(
          AFormInfo.FormName,
          ChangeFileExt(ExtractFileName(AFormInfo.FileName), ''));
        LInput.Title := AFormInfo.Caption;
        LInputs.Add(LInput);
      end);

      Result.InputForms := LInputs.ToArray();
    finally
      LInputs.Free();
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
    TExporterRegistry.LoadFormsModel(LExportModel);
    //Request user info
    if not RequestExportInfo(LExportModel) then
      Exit(false);
    TExporterRegistry.SaveFormsModel(LExportModel);

    //Export each selected form
    for I := Low(LExportModel.OutputForms) to High(LExportModel.OutputForms) do
      if TIOTAUtils.FindForm(LExportModel.OutputForms[I].Form.FormName, LFormInfo) then begin
        //Export the current form
        LFormExporter := TFormExporterFromForms.Create(LExportModel, I, LFormInfo);
        try
          //Export current form
          LFormExporter.ExportForm();
          //Export current form dfm/fmx
          LFormExporter.ExportFormFile(LExportModel.OutputForms[I].FormFileKind);
        finally
          LFormExporter.Free();
        end;
      end;

    if LExportModel.ShowInExplorer then
      ShellExecute(0, 'open', PChar(LExportModel.Directory), nil, nil, SW_NORMAL);
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
