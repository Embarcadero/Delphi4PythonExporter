unit Data.VCLForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TVclForm = class(TForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  VclForm: TVclForm;

implementation

{$R *.dfm}

initialization
  VclForm := TVclForm.Create(nil);

finalization
  VclForm.Free();

end.
