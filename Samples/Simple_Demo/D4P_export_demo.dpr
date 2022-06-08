program D4P_export_demo;

uses
  System.StartUpCopy,
  FMX.Forms,
  parent_window in 'parent_window.pas' {Parent_Form},
  child_window in 'child_window.pas' {Child_Form};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TParent_Form, Parent_Form);
  Application.CreateForm(TChild_Form, Child_Form);
  Application.Run;
end.
