{$I PythonTools.inc}

unit PythonTools.SplashScreen;

interface

procedure AddSplashScreen();

implementation

uses
  ToolsAPI, Vcl.Graphics, Vcl.Imaging.pngimage;

procedure AddSplashScreen();
const
  EMB_PY_IMG = 'embarcaderopython_24px';
var
  LImg: {$IFDEF DELPHI11_UP}TPngImage{$ELSE}TBitmap{$ENDIF DELPHI11_UP};
begin
  LImg := {$IFDEF DELPHI11_UP}TPngImage{$ELSE}TBitmap{$ENDIF DELPHI11_UP}.Create();
  try
    LImg.LoadFromResourceName(HInstance, EMB_PY_IMG);
    {$IFDEF DELPHI11_UP}
    SplashScreenServices.AddPluginBitmap('Delphi4Python - Export forms for Python', [LImg], false, 'Registered', '');
    {$ELSE}
    SplashScreenServices.AddPluginBitmap('Delphi4Python - Export forms for Python', LImg.Handle, false, 'Registered', '');
    {$ENDIF DELPHI11_UP}
  finally
    LImg.Free();
  end;
end;

end.
