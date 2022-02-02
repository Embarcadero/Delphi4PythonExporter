unit PythonTools.SplashScreen;

interface

procedure AddSplashScreen();

implementation

uses
  ToolsAPI, Vcl.Graphics;

procedure AddSplashScreen();
const
  EMB_PY_IMG = 'embarcaderopython_24px';
begin
  var LBmp := TBitmap.Create();
  try
    LBmp.LoadFromResourceName(HInstance, EMB_PY_IMG);
    SplashScreenServices.AddPluginBitmap('Delphi4Python Experts', LBmp.Handle, false, 'Registered', '');
  finally
    LBmp.Free();
  end;
end;

end.
