{$I PythonTools.inc}
unit PythonTools.Design;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ToolsAPI;

type
  TDesignForm = class(TForm {$IFDEF DELPHI10_2_UP}, INTAIDEThemingServicesNotifier{$ENDIF DELPHI10_2_UP})
  private
    {$IFDEF DELPHI10_2_UP}
    FIDEThemingNotifierId: integer;
    {$ENDIF DELPHI10_2_UP}
  private
    {$IFDEF DELPHI10_2_UP}
    //IOTANotifier
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
    //INTAIDEThemingServicesNotifier
    procedure ChangingTheme();
    procedure ChangedTheme();
    {$ENDIF DELPHI10_2_UP}
  protected
    procedure RegisterIDEThemingNotifier();
    procedure UnRegisterIDEThemingNotifier();
    procedure ApplyIDETheming();
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
  end;

var
  DesignForm: TDesignForm;

implementation

{$R *.dfm}

{ TDesignForm }

constructor TDesignForm.Create(AOwner: TComponent);
begin
  inherited;
{$IFDEF DELPHI10_2_UP}
  {$IFDEF DELPHI10_4_UP}
  with (BorlandIDEServices as IOTAIDEThemingServices) do begin
  {$ELSE}
  with (BorlandIDEServices as IOTAIDEThemingServices250) do begin
  {$ENDIF DELPHI10_4_UP}
    RegisterFormClass(TCustomFormClass(Self.ClassType));
    ApplyIDETheming();
    RegisterIDEThemingNotifier();
  end;
{$ENDIF DELPHI10_2_UP}
end;

destructor TDesignForm.Destroy;
begin
  UnRegisterIDEThemingNotifier();
  inherited;
end;

{$IFDEF DELPHI10_2_UP}

procedure TDesignForm.AfterSave;
begin
end;

procedure TDesignForm.BeforeSave;
begin
end;

procedure TDesignForm.Destroyed;
begin
end;

procedure TDesignForm.Modified;
begin
end;

procedure TDesignForm.ChangingTheme;
begin
end;

procedure TDesignForm.ChangedTheme;
begin
  ApplyIDETheming();
end;

{$ENDIF DELPHI10_2_UP}

procedure TDesignForm.ApplyIDETheming;
begin
{$IFDEF DELPHI10_2_UP}
  with (BorlandIDEServices as IOTAIDEThemingServices) do begin
    ApplyTheme(Self);
  end;
{$ENDIF DELPHI10_2_UP}
end;

procedure TDesignForm.RegisterIDEThemingNotifier;
begin
{$IFDEF DELPHI10_2_UP}
  with (BorlandIDEServices as IOTAIDEThemingServices) do begin
    FIDEThemingNotifierId := AddNotifier(Self);
  end;
{$ENDIF DELPHI10_2_UP}
end;

procedure TDesignForm.UnRegisterIDEThemingNotifier;
begin
{$IFDEF DELPHI10_2_UP}
  with (BorlandIDEServices as IOTAIDEThemingServices) do begin
    RemoveNotifier(FIDEThemingNotifierId);
  end;
{$ENDIF DELPHI10_2_UP}
end;

end.
