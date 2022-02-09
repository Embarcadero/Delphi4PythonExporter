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

{ TExportedEvent }

constructor TExportedEvent.Create(const AMethodName: string;
  const AMethodParams: TArray<string>);
begin
  MethodName := AMethodName;
  MethodParams := AMethodParams;
end;

end.
