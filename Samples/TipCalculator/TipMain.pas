unit TipMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit,
  FMX.EditBox, FMX.SpinBox, FMX.Controls.Presentation, FMX.StdCtrls,
  Data.Bind.EngExt, Fmx.Bind.DBEngExt, System.Rtti,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Components,
  FMX.Objects, FMX.ListBox, FMX.Layouts;

type
  TMain_Window = class(TForm)
    styleGold: TStyleBook;
    styleRuby: TStyleBook;
    styleLight: TStyleBook;
    ListBox1: TListBox;
    ListBoxItem1: TListBoxItem;
    editTotal: TSpinBox;
    ListBoxItem2: TListBoxItem;
    ListBoxItem3: TListBoxItem;
    ListBoxItem4: TListBoxItem;
    ListBoxItem5: TListBoxItem;
    Label7: TLabel;
    Label6: TLabel;
    editTip: TSpinBox;
    trackTip: TTrackBar;
    ListBoxItem6: TListBoxItem;
    ListBoxItem7: TListBoxItem;
    trackPeople: TTrackBar;
    editPeople: TSpinBox;
    Label3: TLabel;
    Layout2: TLayout;
    ListBoxItem8: TListBoxItem;
    bill_plus_tip: TEdit;
    per_person_share: TEdit;
    Label1: TLabel;
    Label5: TLabel;
    ListBoxItem9: TListBoxItem;
    gold_style_btn: TButton;
    ruby_style_btn: TButton;
    light_style_btn: TButton;
    default_style: TButton;
    procedure gold_style_btnClick(Sender: TObject);
    procedure ruby_style_btnClick(Sender: TObject);
    procedure light_style_btnClick(Sender: TObject);
    procedure default_styleClick(Sender: TObject);
    procedure editTipChange(Sender: TObject);
    procedure trackTipChange(Sender: TObject);
    procedure editPeopleChange(Sender: TObject);
    procedure trackPeopleChange(Sender: TObject);
    procedure btnUpClick(Sender: TObject);
    procedure btnDownClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Main_Window: TMain_Window;

implementation

{$R *.fmx}

procedure TMain_Window.gold_style_btnClick(Sender: TObject);
begin
  StyleBook := styleGold;
end;

procedure TMain_Window.ruby_style_btnClick(Sender: TObject);
begin
  StyleBook := styleRuby;
end;

procedure TMain_Window.light_style_btnClick(Sender: TObject);
begin
  StyleBook := styleLight;
end;

procedure TMain_Window.btnDownClick(Sender: TObject);
begin
//
end;

procedure TMain_Window.btnUpClick(Sender: TObject);
begin
//
end;

procedure TMain_Window.default_styleClick(Sender: TObject);
begin
  StyleBook := nil;
end;

procedure TMain_Window.editPeopleChange(Sender: TObject);
begin
//
end;

procedure TMain_Window.editTipChange(Sender: TObject);
begin
//
end;

procedure TMain_Window.trackPeopleChange(Sender: TObject);
begin
//
end;

procedure TMain_Window.trackTipChange(Sender: TObject);
begin
//
end;

end.
