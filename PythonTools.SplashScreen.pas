unit PythonTools.SplashScreen;

interface

procedure AddSplashScreen();

implementation

uses
  ToolsAPI, Vcl.Imaging.pngimage;

procedure AddSplashScreen();
const
  EMB_PY_IMG = 'embarcaderopython_24px';
begin
  var LPng := TPngImage.Create();
  try
    LPng.LoadFromResourceName(HInstance, EMB_PY_IMG);
    SplashScreenServices.AddPluginBitmap('Delphi4Python - Export forms for Python', [LPng], false, 'Registered', '');
  finally
    LPng.Free();
  end;
end;

end.
