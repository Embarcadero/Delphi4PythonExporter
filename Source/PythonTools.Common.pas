unit PythonTools.Common;

interface

uses
  System.Generics.Collections, System.SysUtils;

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

  TApplicationFile = System.SysUtils.TFileName;
  TFileName = System.SysUtils.TFileName;
  TFormFile = type string;
  TFormFilePath = TFormFile;

  TApplicationFileHelper = record helper for TApplicationFile
  public
    function AsDelphi(): string;
    function AsPython(): string;
  end;

  TFileNameHelper = record helper for TFileName
  public
    function AsDelphi(): string;
    function AsPython(): string;
  end;

  TFormFileHelper = record helper for TFormFile
  public
    function AsDelphiDfm(): string;
    function AsDelphiFmx(): string;

    function AsPythonDfm(): string;
    function AsPythonFmx(): string;
  end;

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

{ TApplicationFileHelper }

function TApplicationFileHelper.AsDelphi: string;
begin
  Result := Self + '.dpr'
end;

function TApplicationFileHelper.AsPython: string;
begin
  Result := Self + '.py'
end;

{ TFileNameHelper }

function TFileNameHelper.AsDelphi: string;
begin
  Result := Self + '.pas';
end;

function TFileNameHelper.AsPython: string;
begin
  Result := Self + '.py';
end;

{ TFormFileHelper }

function TFormFileHelper.AsDelphiDfm: string;
begin
  Result := Self + '.dfm';
end;

function TFormFileHelper.AsDelphiFmx: string;
begin
  Result := Self + '.fmx';
end;

function TFormFileHelper.AsPythonDfm: string;
begin
  Result := Self + '.pydfm';
end;

function TFormFileHelper.AsPythonFmx: string;
begin
  Result := Self + '.pyfmx';
end;

end.
