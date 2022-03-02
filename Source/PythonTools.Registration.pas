unit PythonTools.Registration;

interface

uses
  PythonTools.SplashScreen, PythonTools.Menu;

procedure Register();

implementation

procedure RegisterPythonToolsMenuServices();
begin
  with TPythonToolsMenu.Instance do
    HookMenu();
end;

procedure Register();
begin
  RegisterPythonToolsMenuServices;
end;

initialization
  AddSplashScreen();

finalization

end.
