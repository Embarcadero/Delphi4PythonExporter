unit PythonTools.Common;

interface

uses
  System.Generics.Collections, System.SysUtils;

type
  TFormFileKind = (ffkText, ffkBinary);
  TFormFileMode = (ffmDelphi, ffmPython, ffmCompatible);

  TFormNameAndFile = record
  public
    FormName: string;
    FileName: string;
  public
    constructor Create(const AFormName, AFileName: string);
    function CombineFileAndFormName(): string;
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
    function AsDfm(const AMode: TFormFileMode): string;
    function AsFmx(const AMode: TFormFileMode): string;
  end;

  TFormFileKindHelper = record helper for TFormFileKind
  public
    function ToString(): string;
    class function FromString(const AValue: string): TFormFileKind; static;
  end;

implementation

{ TFormNameAndFile }

function TFormNameAndFile.CombineFileAndFormName: string;
begin
  if (FileName = String.Empty) and (FormName = String.Empty) then
    Result := String.Empty
  else
    Result := FileName + '.' + FormName;
end;

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

function TFormFileHelper.AsDfm(const AMode: TFormFileMode): string;
begin
  case AMode of
    ffmCompatible,
    ffmDelphi:
      Result := AsDelphiDfm();
    ffmPython:
      Result := AsPythonDfm();
    else
      Result := String.Empty;
  end;
end;

function TFormFileHelper.AsFmx(const AMode: TFormFileMode): string;
begin
  case AMode of
    ffmCompatible,
    ffmDelphi:
      Result := AsDelphiFmx();
    ffmPython:
      Result := AsPythonFmx();
    else
      Result := String.Empty;
  end;
end;

{ TFormFileKindHelper }

class function TFormFileKindHelper.FromString(
  const AValue: string): TFormFileKind;
begin
  if AValue = 'Text' then
    Result := ffkText
  else if AValue = 'Binary' then
    Result := ffkBinary
  else
    raise ENotImplemented.Create('Form file kind not found.');
end;

function TFormFileKindHelper.ToString: string;
begin
  case Self of
    ffkText:
      Result := 'Text';
    ffkBinary:
      Result := 'Binary';
    else
      raise ENotImplemented.Create('Form file kind not found.');
  end;
end;

end.
