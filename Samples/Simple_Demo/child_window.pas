unit child_window;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls;

type
  TChild_Form = class(TForm)
    child_heading: TLabel;
    result_text_heading: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Child_Form: TChild_Form;

implementation

{$R *.fmx}

end.
