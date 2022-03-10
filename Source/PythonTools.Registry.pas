unit PythonTools.Registry;

interface

uses
  System.SysUtils, System.Win.Registry,
  Winapi.Windows,
  PythonTools.Model.Design.Project,
  PythonTools.Model.Design.Forms;

type
  TExporterRegistry = class
  private
    class function GetBaseRegistryKey(): string;
    class procedure UseActionKey(const AKey: string; const AProc: TProc<TRegistry>);
  public
    class procedure SaveProjectModel(const AModel: TExportProjectDesignModel);
    class procedure LoadProjectModel(const AModel: TExportProjectDesignModel);

    class procedure SaveFormsModel(const AModel: TExportFormsDesignModel);
    class procedure LoadFormsModel(const AModel: TExportFormsDesignModel);
  end;

implementation

uses
  ToolsAPI,
  PythonTools.Common;

const
  PROGRAM_KEY = 'Delphi4PythonExporter';
  //Actions
  PROJECT_ACTION_KEY = 'ProjectAction';
  FORMS_ACTION_KEY = 'FormsAction';
  //Values
  DEFAULT_DIRECTORY_KEY = 'DefaultDirectory';
  DEFAULT_SHOW_IN_EXPLORER = 'DefaultShowInExplorer';
  DEFAULT_FORM_FILE_KIND = 'DefaultFormFileKind';
  //Project values
  PROJECT_TITLE_KEY = 'ProjectTile';
  PROJECT_MAIN_FORM = 'ProjectMainForm';


{ TExporterRegistry }

class function TExporterRegistry.GetBaseRegistryKey: string;
begin
   with (BorlandIDEServices as IOTAServices) do
    Result := GetBaseRegistryKey();
end;

class procedure TExporterRegistry.UseActionKey(const AKey: string;
  const AProc: TProc<TRegistry>);
var
  LRegistry: TRegistry;
begin
  LRegistry := TRegistry.Create();
  try
    LRegistry.RootKey := HKEY_CURRENT_USER;
    try
      if LRegistry.OpenKey(GetBaseRegistryKey(), false) then
      try
        if LRegistry.OpenKey(PROGRAM_KEY, true) then
        try
          if LRegistry.OpenKey(AKey, true) then
          try
            AProc(LRegistry);
          finally
            LRegistry.CloseKey();
          end;
        finally
          LRegistry.CloseKey();
        end;
      finally
        LRegistry.CloseKey();
      end;
    finally
      LRegistry.CloseKey();
    end;
  finally
    LRegistry.Free();
  end;
end;

class procedure TExporterRegistry.LoadProjectModel(
  const AModel: TExportProjectDesignModel);
begin
  UseActionKey(PROJECT_ACTION_KEY, procedure(ARegistry: TRegistry) begin
    AModel.ApplicationDirectory := ARegistry.ReadString(DEFAULT_DIRECTORY_KEY);
    if ARegistry.ValueExists(DEFAULT_SHOW_IN_EXPLORER) then
      AModel.ShowInExplorer := ARegistry.ReadBool(DEFAULT_SHOW_IN_EXPLORER);
    if ARegistry.ValueExists(DEFAULT_FORM_FILE_KIND) then
      AModel.FormFileKind := TFormFileKind(ARegistry.ReadInteger(DEFAULT_FORM_FILE_KIND));
    if ARegistry.OpenKey(GuidToString(AModel.ApplicationId), false) then
      try
        AModel.ApplicationTitle := ARegistry.ReadString(PROJECT_TITLE_KEY);
        AModel.ApplicationMainForm := TFormNameAndFile.Create(
          Copy(ARegistry.ReadString(PROJECT_MAIN_FORM),
            Pos('.', ARegistry.ReadString(PROJECT_MAIN_FORM)) + 1,
            Length(ARegistry.ReadString(PROJECT_MAIN_FORM))
              - Pos('.', ARegistry.ReadString(PROJECT_MAIN_FORM))),
            Copy(ARegistry.ReadString(PROJECT_MAIN_FORM),
            1,
            Pos('.', ARegistry.ReadString(PROJECT_MAIN_FORM)) - 1));
      finally
        ARegistry.CloseKey();
      end;
  end);
end;

class procedure TExporterRegistry.SaveProjectModel(
  const AModel: TExportProjectDesignModel);
begin
  UseActionKey(PROJECT_ACTION_KEY, procedure(ARegistry: TRegistry) begin
    ARegistry.WriteString(DEFAULT_DIRECTORY_KEY, AModel.ApplicationDirectory);
    ARegistry.WriteBool(DEFAULT_SHOW_IN_EXPLORER, AModel.ShowInExplorer);
    ARegistry.WriteInteger(DEFAULT_FORM_FILE_KIND, Integer(AModel.FormFileKind));
    if ARegistry.OpenKey(GuidToString(AModel.ApplicationId), true) then begin
      try
        ARegistry.WriteString(PROJECT_TITLE_KEY, AModel.ApplicationTitle);
        ARegistry.WriteString(PROJECT_MAIN_FORM,
          AModel.ApplicationMainForm.CombineFileAndFormName());
      finally
        ARegistry.CloseKey();
      end;
    end;

  end);
end;

class procedure TExporterRegistry.LoadFormsModel(
  const AModel: TExportFormsDesignModel);
begin
  UseActionKey(FORMS_ACTION_KEY, procedure(ARegistry: TRegistry) begin
    AModel.Directory := ARegistry.ReadString(DEFAULT_DIRECTORY_KEY);
    if ARegistry.ValueExists(DEFAULT_SHOW_IN_EXPLORER) then
      AModel.ShowInExplorer := ARegistry.ReadBool(DEFAULT_SHOW_IN_EXPLORER);
  end);
end;

class procedure TExporterRegistry.SaveFormsModel(
  const AModel: TExportFormsDesignModel);
begin
  UseActionKey(FORMS_ACTION_KEY, procedure(ARegistry: TRegistry) begin
    ARegistry.WriteString(DEFAULT_DIRECTORY_KEY, AModel.Directory);
    ARegistry.WriteBool(DEFAULT_SHOW_IN_EXPLORER, AModel.ShowInExplorer);
  end);
end;

end.
