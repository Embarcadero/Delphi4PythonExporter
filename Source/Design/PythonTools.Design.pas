unit PythonTools.Design;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ToolsAPI;

type
  TDesignForm = class(TForm, INTAIDEThemingServicesNotifier)
  private
    FIDEThemingNotifierId: integer;
  private
    //IOTANotifier
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
    //INTAIDEThemingServicesNotifier
    procedure ChangingTheme();
    procedure ChangedTheme();
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
  with (BorlandIDEServices as IOTAIDEThemingServices) do begin
    RegisterFormClass(TCustomFormClass(Self.ClassType));
    ApplyIDETheming();
    RegisterIDEThemingNotifier();
  end;
end;

destructor TDesignForm.Destroy;
begin
  UnRegisterIDEThemingNotifier();
  inherited;
end;

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

procedure TDesignForm.ApplyIDETheming;
begin
  with (BorlandIDEServices as IOTAIDEThemingServices) do begin
    ApplyTheme(Self);
  end;
end;

procedure TDesignForm.RegisterIDEThemingNotifier;
begin
  with (BorlandIDEServices as IOTAIDEThemingServices) do begin
    FIDEThemingNotifierId := AddNotifier(Self);
  end;
end;

procedure TDesignForm.UnRegisterIDEThemingNotifier;
begin
  with (BorlandIDEServices as IOTAIDEThemingServices) do begin
    RemoveNotifier(FIDEThemingNotifierId);
  end;
end;

end.
