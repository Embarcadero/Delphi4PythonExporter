unit parent_window;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation;

type
  TParent_Form = class(TForm)
    my_button: TButton;
    enter_text_edit: TEdit;
    enter_text_label: TLabel;
    main_heading: TLabel;
    procedure my_buttonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Parent_Form: TParent_Form;

implementation

{$R *.fmx}

procedure TParent_Form.my_buttonClick(Sender: TObject);
begin
//
end;

end.
