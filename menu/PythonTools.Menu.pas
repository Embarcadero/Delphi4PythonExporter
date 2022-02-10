unit PythonTools.Menu;

interface

uses
  ToolsAPI, System.SysUtils, System.Classes, System.Generics.Collections,
  Winapi.Messages,
  Vcl.Menus, Vcl.ImgList, Vcl.Graphics, Vcl.ActnList, Vcl.Controls;

type
  TToolsMenuEventHook = class;

  TPythonToolsMenu = class
  private
    class var FInstance: TPythonToolsMenu;
    class procedure Initialize();
    class procedure Finalize();
  private
    FToolsMenuItems: TObjectList<TMenuItem>;
    FToolsMenuHook: TToolsMenuEventHook;
    function GetINTAServices(): INTAServices;
    function LoadPythonToolMenuImage(): integer;

    procedure DoCreateMenuHooked(Sender: TObject);
    procedure DoDestroyMenu();
  public
    constructor Create();    
    destructor Destroy(); override;

    //Include the PythonTools menu under Tools
    procedure BuildMenu();

    //Hook the menu creation to a event
    procedure HookMenu();
    procedure UnHookMenu();

    function BuildPythonToolsSeparatorMenuItem(): TMenuItem;
    function BuildPythonToolsMenuItem(const ACallback: TProc<TMenuItem, TCustomAction>): TMenuItem;
    function BuildPythonToolsExportProjectMenuItem(AOwner: TMenuItem): TMenuItem;
    function BuildPythonToolsExportFormsMenuItem(AOwner: TMenuItem): TMenuItem;

    class property Instance: TPythonToolsMenu read FInstance;
  end;

  {**** We're creating the menu after the first user's click on the "Tools" menu.                   ****}
  {**** The coreide lib rebuilds the "Tools" menu, removing unknown items at the ending of the list ****}
  TToolsMenuEventHook = class
  private
    FMenuItem: TMenuItem;
    FHook: TNotifyEvent;
    FDefaultAction: TNotifyEvent;
    procedure DoEvent(Sender: TObject);
  public
    constructor Create(AMenuItem: TMenuItem); reintroduce;
    destructor Destroy(); override;

    procedure Hook(AEvt: TNotifyEvent);
    procedure UnHook(AEvt: TNotifyEvent);
  end;

implementation

uses
  Vcl.Imaging.pngimage,
  PythonTools.Menu.ExportProject, PythonTools.Menu.ExportForms;

const
  sToolsMenu = 'ToolsMenu';
  sPythonToolsMenuItem = 'PythonToolsMenuItem';

type
  TPythonToolsMenuAction = class(TCustomAction)
  end;

  TPythonToolsMenuItem = class(TMenuItem)
  end;

{ TPythonToolsMenu }

constructor TPythonToolsMenu.Create;
begin
  FToolsMenuItems := TObjectList<TMenuItem>.Create();
  FToolsMenuHook := TToolsMenuEventHook.Create(
    GetINTAServices().MainMenu.Items.Find('Tools'));
end;

destructor TPythonToolsMenu.Destroy;
begin
  DoDestroyMenu();
  FToolsMenuItems.Free();
  FToolsMenuHook.Free();
  inherited;
end;

class procedure TPythonToolsMenu.Initialize;
begin
  FInstance := TPythonToolsMenu.Create();
end;

class procedure TPythonToolsMenu.Finalize;
begin
  FInstance.Free();
end;

function TPythonToolsMenu.GetINTAServices: INTAServices;
begin
  if not Supports(BorlandIDEServices, INTAServices, Result) then
    raise Exception.Create('An error ocurred while accessing the IDE services.');
end;

procedure TPythonToolsMenu.HookMenu;
begin
  if Assigned(FToolsMenuHook) then
    FToolsMenuHook.Hook(DoCreateMenuHooked);
end;

procedure TPythonToolsMenu.UnHookMenu;
begin
  if Assigned(FToolsMenuHook) then
    FToolsMenuHook.UnHook(DoCreateMenuHooked);
end;

procedure TPythonToolsMenu.BuildMenu;
begin
  var LServices := GetINTAServices();
  LServices.MenuBeginUpdate();
  try
    //Tools->---------
    LServices.AddActionMenu(sToolsMenu, nil, BuildPythonToolsSeparatorMenuItem(), true, true);
    //Tools->Export to Python
    BuildPythonToolsMenuItem(procedure(AMenuItem: TMenuItem; AAction: TCustomAction) begin
      LServices.AddActionMenu(sToolsMenu, AAction, AMenuItem, true, true);
      AMenuItem.Add([
        //Tools->Export to Python->Export Current Project
        BuildPythonToolsExportProjectMenuItem(AMenuItem),
        //Tools->Export to Python->Export Forms
        BuildPythonToolsExportFormsMenuItem(AMenuItem)
      ]);
    end);
  finally
    LServices.MenuEndUpdate();
  end;
end;

function TPythonToolsMenu.LoadPythonToolMenuImage(): integer;
const
  EMB_PY_IMG = 'embarcaderopython_16px';
begin
  var LPng := TPngImage.Create();
  try
    LPng.LoadFromResourceName(HInstance, EMB_PY_IMG);
    Result := GetINTAServices().AddImage(EMB_PY_IMG, [LPng]);
  finally
    LPng.Free();
  end;
end;

function TPythonToolsMenu.BuildPythonToolsExportFormsMenuItem(AOwner: TMenuItem): TMenuItem;
begin
  Result := TPythonToolsExportFormsMenuItem.Create(AOwner);
  Result.Action := TPythonToolsExportFormsMenuAction.Create(Result);
  Result.Visible := false;
end;

function TPythonToolsMenu.BuildPythonToolsExportProjectMenuItem(AOwner: TMenuItem): TMenuItem;
begin
  Result := TPythonToolsExportProjectMenuItem.Create(AOwner);
  Result.Action := TPythonToolsExportProjectMenuAction.Create(Result);
end;

function TPythonToolsMenu.BuildPythonToolsMenuItem(
  const ACallback: TProc<TMenuItem, TCustomAction>): TMenuItem;
begin
  Result := TPythonToolsMenuItem.Create(nil);
  try
    var LAction := TPythonToolsMenuAction.Create(Result);
    LAction.Caption := 'Export to Python';
    LAction.ImageIndex := LoadPythonToolMenuImage();
    ACallback(Result, TCustomAction(Result.Action));
    Result.Action := LAction;
    Result.Name := sPythonToolsMenuItem;
    Result.ImageIndex := LAction.ImageIndex;
    Result.AutoHotkeys := maAutomatic;
  finally
    FToolsMenuItems.Add(Result)
  end;
end;

function TPythonToolsMenu.BuildPythonToolsSeparatorMenuItem: TMenuItem;
begin
  Result := TMenuItem.Create(nil);
  try
    Result.Caption := '-';
  finally
    FToolsMenuItems.Add(Result);
  end;
end;

procedure TPythonToolsMenu.DoCreateMenuHooked(Sender: TObject);
begin
  try
    BuildMenu();
  finally
    UnHookMenu();
  end;
end;

procedure TPythonToolsMenu.DoDestroyMenu;
begin
  var LRoot := GetINTAServices().MainMenu.Items.Find('Tools');
  if Assigned(LRoot) then begin
    with GetINTAServices() do begin
      MenuBeginUpdate();
      try
        for var LMenuItem in FToolsMenuItems do begin
          LRoot.Remove(LMenuItem);
        end;
        FToolsMenuItems.Clear();
      finally
        MenuEndUpdate();
      end;
    end;
  end;
end;

{ TToolsMenuEventHook }

constructor TToolsMenuEventHook.Create(AMenuItem: TMenuItem);
begin
  inherited Create();
  FMenuItem := AMenuItem;
  if Assigned(FMenuItem.Action) and Assigned(FMenuItem.Action.OnExecute) then begin
    FDefaultAction := FMenuItem.Action.OnExecute;
    FMenuItem.Action.OnExecute := DoEvent;
  end else begin
    if Assigned(FMenuItem.OnClick) then
      FDefaultAction := FMenuItem.OnClick
    else
      FDefaultAction := nil;
    FMenuItem.OnClick := DoEvent;
  end;
end;

destructor TToolsMenuEventHook.Destroy;
begin
  if Assigned(FMenuItem.Action) and Assigned(FMenuItem.Action.OnExecute) then begin
    FMenuItem.Action.OnExecute := FDefaultAction;
  end else begin
    FMenuItem.OnClick := FDefaultAction;
  end;
  inherited;
end;

procedure TToolsMenuEventHook.DoEvent(Sender: TObject);
begin
  if Assigned(FDefaultAction) then
    FDefaultAction(Sender);

  if Assigned(FHook) then
    FHook(Sender);
end;

procedure TToolsMenuEventHook.Hook(AEvt: TNotifyEvent);
begin
  FHook := AEvt;
end;

procedure TToolsMenuEventHook.UnHook(AEvt: TNotifyEvent);
begin
  if (TMethod(FHook).Code = TMethod(AEvt).Code)
    and (TMethod(FHook).Data = TMethod(AEvt).Data) then
      FHook := nil;
end;

initialization
  TPythonToolsMenu.Initialize();

finalization
  TPythonToolsMenu.Finalize();

end.
