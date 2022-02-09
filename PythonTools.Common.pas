unit PythonTools.Common;

interface

uses
  System.Generics.Collections;

type
  TFormNameAndFile = record
  public
    FormName: string;
    FileName: string;
  public
    constructor Create(const AFormName, AFileName: string);
  end;

  TFormNamesAndFiles = TArray<TFormNameAndFile>;
  TFormNameAndFileList = TList<TFormNameAndFile>;

  TExportedComponent = record
  public
    ComponentName: string;
  public
    constructor Create(const AComponentName: string);
  end;

  TExportedComponents = TArray<TExportedComponent>;
  TExportedComponentList = TList<TExportedComponent>;

  TExportedEvent = record
  public
    MethodName: string;
    MethodParams: TArray<string>;
  public
    constructor Create(const AMethodName: string; const AMethodParams: TArray<string>);
  end;

  TExportedEvents = TArray<TExportedEvent>;
  TExportedEventList = TList<TExportedEvent>;

implementation

{ TFormNameAndFile }

constructor TFormNameAndFile.Create(const AFormName, AFileName: string);
begin
  FormName := AFormName;
  FileName := AFileName;
end;

{ TExportedComponent }

constructor TExportedComponent.Create(const AComponentName: string);
begin
  ComponentName := AComponentName;
end;

{ TExportedEvent }

constructor TExportedEvent.Create(const AMethodName: string;
  const AMethodParams: TArray<string>);
begin
  MethodName := AMethodName;
  MethodParams := AMethodParams;
end;

end.
