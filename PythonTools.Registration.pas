unit PythonTools.Registration;

interface

uses
  PythonTools.Menu;

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
finalization

end.
