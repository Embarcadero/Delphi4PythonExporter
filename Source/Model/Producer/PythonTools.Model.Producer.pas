unit PythonTools.Model.Producer;

interface

uses
  System.Classes,
  System.SysUtils,
  PythonTools.Common;

type
  TAbastractProducerModel = class
  private
    FDirectory: string;
    FFileName: TFileName;
    FOwned: boolean;
    FStream: TStream;
    function GetStream: TStream;
    procedure SetFileName(const Value: TFileName);
  protected
    function GetPythonFileName: string; virtual;
  public
    constructor Create(); overload; virtual;
    constructor Create(const AStream: TStream; const AOwned: boolean = true); overload;
    constructor Create(const ADirectory: string; const AFileName: TFileName); overload;
    destructor Destroy(); override;

    /// <summary>
    ///   The directory where the generated files will be saved
    /// </summary>
    property Directory: string read FDirectory write FDirectory;
    /// <summary>
    ///   The Delphi file name: used to generate the Python (.py) file name.
    /// </summary>
    property FileName: TFileName read FFileName write SetFileName;
    /// <summary>
    ///   The final Python file name.
    /// </summary>
    property PythonFileName: string read GetPythonFileName;
    /// <summary>
    ///   Producers will use this stream to save Python code.
    /// </summary>
    property Stream: TStream read GetStream;
  end;

implementation

uses
  System.IOUtils;

{ TAbastractProducerModel }

constructor TAbastractProducerModel.Create;
begin
  inherited;
end;

constructor TAbastractProducerModel.Create(const AStream: TStream;
  const AOwned: boolean);
begin
  Create();
  FStream := AStream;
  FOwned := AOwned;
end;

constructor TAbastractProducerModel.Create(const ADirectory: string;
  const AFileName: TFileName);
begin
  Create();
  FDirectory := ADirectory;
  SetFileName(AFileName);
end;

destructor TAbastractProducerModel.Destroy;
begin
  if FOwned then
    FStream.Free();
  inherited;
end;

function TAbastractProducerModel.GetPythonFileName: string;
begin
  Result := TPath.Combine(FDirectory, FFileName.AsPython());
end;

function TAbastractProducerModel.GetStream: TStream;
begin
  if not Assigned(FStream) then begin
    FStream := TFileStream.Create(GetPythonFileName(), fmCreate or fmOpenWrite or fmShareDenyWrite);
    FOwned := true;
  end;

  Result := FStream;
end;

procedure TAbastractProducerModel.SetFileName(const Value: TFileName);
begin
  FFileName := TFileName(
    ExtractFileName(Value)
      .Replace('.pas', '', [])
      .Replace('.dfm', '', [])
      .Replace('.fmx', '', [])
      .Replace('.dpr', '', [])
      .Replace('.dproj', '', [])
  );
end;

end.
