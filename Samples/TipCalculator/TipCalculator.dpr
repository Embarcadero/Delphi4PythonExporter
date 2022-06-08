program TipCalculator;

uses
  System.StartUpCopy,
  FMX.Forms,
  TipMain in 'TipMain.pas' {Main_Window};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMain_Window, Main_Window);
  Application.Run;
end.
