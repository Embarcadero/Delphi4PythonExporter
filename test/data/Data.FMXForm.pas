unit Data.FMXForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs;

type
  TFmxForm = class(TForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FmxForm: TFmxForm;

implementation

{$R *.fmx}

initialization
  FmxForm := TFmxForm.Create(nil);

finalization
  FmxForm.Free();

end.
