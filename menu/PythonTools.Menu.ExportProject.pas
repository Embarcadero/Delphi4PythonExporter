unit PythonTools.Menu.ExportProject;

interface

uses
  DesignIntf, ToolsAPI, 
  System.Classes, System.SysUtils,  System.Generics.Collections,
  Vcl.ActnList, Vcl.Menus, Vcl.Dialogs,
  PythonTools.Common, PythonTools.Producer, PythonTools.Exceptions, 
  PythonTools.Model.ExportProject;

type
  TPythonToolsExportProjectMenuAction = class(TCustomAction)
  private
    procedure DoExportProject(Sender: TObject);
    //Utils
    function FindComponents(const ADesigner: IDesigner): TArray<TComponent>;
    procedure EnumForms(const AProject: IOTAProject; 
      const AProc: TProc<IOTAModuleInfo>);
    //Export project info
    function RequestExportInfo(const AModel: TExportProjectModel): boolean;
    //Producer models
    function BuildExportProjectModel(
      const AProject: IOTAProject): TExportProjectModel;
    function BuildApplicationModel(
      const AProject: IOTAProject;
      const AExportPorjectModel: TExportProjectModel): TApplicationProducerModel;
    function BuildFormModel(const AProject: IOTAProject;
      const AModuleInfo: IOTAModuleInfo;
      const AFormDesigner: IDesigner): TFormProducerModel;
    //Exporters
    function ExportForm(const AExportProjectModel: TExportProjectModel;
      const AProject: IOTAProject;
      const AModuleInfo: IOTAModuleInfo): TFormNameAndFile;
    procedure ExportProject(const AExportProjectModel: TExportProjectModel;
      const AProject: IOTAProject);
  public
    constructor Create(AOwner: TComponent); override;

    function Update: boolean; override;
  end;

  TPythonToolsExportProjectMenuItem = class(TMenuItem)
  public
    procedure AfterConstruction(); override;
  end;

implementation

uses
  System.StrUtils,
  PythonTools.IOTAUtils, PythonTools.Producer.SimpleFactory,
  PythonTools.ExportProject.Design;

{ TPythonToolsExportProjectMenuAction }

constructor TPythonToolsExportProjectMenuAction.Create(AOwner: TComponent);
begin
  inherited;
  Name := 'PythonToolsExportProjectAction';
  Caption := 'Export Current Project';
  OnExecute := DoExportProject;
end;

function TPythonToolsExportProjectMenuAction.Update: boolean;
begin
  Enabled := Assigned(GetActiveProject());
  Result := inherited;
end;

function TPythonToolsExportProjectMenuAction.FindComponents(
  const ADesigner: IDesigner): TArray<TComponent>;
begin
  var LIOTAUtils := TIOTAUtils.Create();
  try
    Result := LIOTAUtils.FindComponents(ADesigner);
  finally
    LIOTAUtils.Free();
  end;
end;

procedure TPythonToolsExportProjectMenuAction.EnumForms(
  const AProject: IOTAProject; const AProc: TProc<IOTAModuleInfo>);
begin
  for var I := 0 to AProject.GetModuleCount() - 1 do begin
    var LModuleInfo := AProject.GetModule(I);
    if (LModuleInfo.ModuleType = omtForm) then begin
      if not LModuleInfo.FormName.Trim().IsEmpty() then begin
        AProc(LModuleInfo);
      end;
    end;
  end;
end;

function TPythonToolsExportProjectMenuAction.RequestExportInfo(
  const AModel: TExportProjectModel): boolean;
begin
  var LForm := TProjectExport.Create(nil);
  try
    Result := LForm.Execute(AModel);
  finally
    LForm.Free();
  end;
end;

function TPythonToolsExportProjectMenuAction.BuildExportProjectModel(
  const AProject: IOTAProject): TExportProjectModel;
begin
  Result := TExportProjectModel.Create();
  try
    Result.ApplicationName := ChangeFileExt(
      ExtractFileName(AProject.FileName), String.Empty);
    Result.ApplicationDirectory := ExtractFileDir(AProject.FileName);
    var LFormInfo := TFormNameAndFileList.Create();
    try
      EnumForms(AProject, procedure(AModuleInfo: IOTAModuleInfo) begin
        LFormInfo.Add(TFormNameAndFile.Create(
          AModuleInfo.FormName,
          ChangeFileExt(ExtractFileName(AModuleInfo.FileName), '')));
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

function TPythonToolsExportProjectMenuAction.BuildApplicationModel(
  const AProject: IOTAProject;
  const AExportPorjectModel: TExportProjectModel): TApplicationProducerModel;
begin
  Result := TApplicationProducerModel.Create();
  try
    with Result do begin
      MainForm := AExportPorjectModel.ApplicationMainForm.FormName;
      Title := AExportPorjectModel.ApplicationTitle;
      FileName := ChangeFileExt(ExtractFileName(AProject.FileName), '');
      ImportedForms := [AExportPorjectModel.ApplicationMainForm];
    end;
  except
    on E: Exception do begin
      FreeAndNil(Result);
      raise;
    end;
  end;
end;

function TPythonToolsExportProjectMenuAction.BuildFormModel(
  const AProject: IOTAProject; const AModuleInfo: IOTAModuleInfo;
  const AFormDesigner: IDesigner): TFormProducerModel;
begin
  Result := TFormProducerModel.Create();
  try
    with Result do begin
      FormName := AModuleInfo.FormName;
      FormParentName := System.Copy(
        AFormDesigner.Root.ClassParent.ClassName,
        2,
        AFormDesigner.Root.ClassParent.ClassName.Length);
      FileName := ChangeFileExt(ExtractFileName(AModuleInfo.FileName), '');
      ExportedComponents := FindComponents(AFormDesigner);
      with ModelInitialization do begin
        GenerateInitialization := false;
      end;
    end;
  except
    on E: Exception do begin
      FreeAndNil(Result);
      raise;
    end;
  end;
end;

procedure TPythonToolsExportProjectMenuAction.DoExportProject(Sender: TObject);
begin
  //Get the current project
  var LProject := GetActiveProject();
  //Request user info
  var LExportProjectModel := BuildExportProjectModel(LProject);
  try
    //Request info where files will be saved and more...
    if not RequestExportInfo(LExportProjectModel) then
      Exit;     
    //Export the application file as the app initializer
    ExportProject(LExportProjectModel, LProject);
    //Navigate through all forms
    EnumForms(LProject, procedure(AModuleInfo: IOTAModuleInfo) begin
      //Export current form
      ExportForm(LExportProjectModel, LProject, AModuleInfo);
    end);    
  finally
    LExportProjectModel.Free();
  end;
end;

procedure TPythonToolsExportProjectMenuAction.ExportProject(
  const AExportProjectModel: TExportProjectModel;
  const AProject: IOTAProject);
begin
  var LProducer := TProducerSimpleFactory.CreateProducer(AProject.FrameworkType);
  var LProducerModel := BuildApplicationModel(AProject, AExportProjectModel);
  try
    LProducerModel.Directory := AExportProjectModel.ApplicationDirectory;
    LProducer.SavePyApplicationFile(LProducerModel);
  finally
    LProducerModel.Free();
  end;
end;

function TPythonToolsExportProjectMenuAction.ExportForm(
  const AExportProjectModel: TExportProjectModel;
  const AProject: IOTAProject; const AModuleInfo: IOTAModuleInfo): TFormNameAndFile;
begin
  var LModule := AModuleInfo.OpenModule();
  var LFormEditor := TIOTAUtils.GetFormEditorFromModule(LModule);
  var LFormDesigner := (LFormEditor as INTAFormEditor).FormDesigner;
  if Assigned(LFormDesigner) then begin
    var LProducer := TProducerSimpleFactory.CreateProducer(AProject.FrameworkType);
    if not LProducer.IsValidFormInheritance(LFormDesigner.Root.ClassParent) then
      raise EFormInheritanceNotSupported.CreateFmt(
        '%s TForm direct inheritance only', [AProject.FrameworkType]);

    var LProducerModel := BuildFormModel(AProject, AModuleInfo, LFormDesigner);
    try
      LProducerModel.Directory := AExportProjectModel.ApplicationDirectory;
      LProducer.SavePyFormFile(LProducerModel);
      Result := TFormNameAndFile.Create(LProducerModel.FormName, LProducerModel.FileName);
    finally
      LProducerModel.Free();
    end;
  end else
    raise EUnableToObtainFormDesigner.CreateFmt(
      'Unable to obtain the form designer for type %s.', [AModuleInfo.FormName]);
end;

{ TPythonToolsExportProjectMenuItem }

procedure TPythonToolsExportProjectMenuItem.AfterConstruction;
begin
  inherited;
  Name := 'PythonToolsExportProjectMenu';
end;

end.
