unit PythonTools.Model.Producer.FormFile;
interface
uses
  System.Classes,
  PythonTools.Common,
  PythonTools.Model.Producer;
type
  TFormFileProducerModel = class(TAbastractProducerModel)
  private
    FForm: TComponent;
    FFormResource: TStream;
    FMode: TFormFileMode;
    FFrameworkType: string;
    function GetFormFile: TFormFile;
    procedure SetFormResource(const Value: TStream);
  protected
    function GetPythonFileName: string; override;
  public
    constructor Create(); overload; override;
    constructor Create(const AFrameworkType, ADirectory: string; const AFileName: TFileName); overload;
    destructor Destroy(); override;
    /// <summary>
    ///   The .dfm/.fmx file name.
    /// </summary>
    property FormFile: TFormFile read GetFormFile;
    /// <summary>
    ///   The exported form
    /// </summary>
    property Form: TComponent read FForm write FForm;
    /// <summary>
    ///   The .dfm/.fmx text stream.
    /// </summary>
    property FormResource: TStream read FFormResource write SetFormResource;
    /// <summary>
    ///   Delphi and Python can share the same .dfm/.fmx in compatible mode.
    /// </summary>
    property Mode: TFormFileMode read FMode write FMode;
    /// <summary>
    ///   Define if we're going to use .dfm or .fmx.
    /// </summary>
    property FrameworkType: string read FFrameworkType write FFrameworkType;
  end;
implementation
uses
  System.IOUtils;
{ TFormFileProducerModel }
constructor TFormFileProducerModel.Create;
begin
  inherited;
  FFormResource := TMemoryStream.Create();
  FMode := TFormFileMode.ffmCompatible;
end;
constructor TFormFileProducerModel.Create(const AFrameworkType,
  ADirectory: string; const AFileName: TFileName);
begin
  inherited Create(ADirectory, AFileName);
  FFrameworkType := AFrameworkType;
end;

destructor TFormFileProducerModel.Destroy;
begin
  FFormResource.Free();
  inherited;
end;
function TFormFileProducerModel.GetPythonFileName: string;
begin
  if FFrameworkType = 'VCL' then
    Result := TPath.Combine(Directory, FormFile.AsDfm(FMode))
  else if FFrameworkType = 'FMX' then
    Result := TPath.Combine(Directory, FormFile.AsFmx(FMode))
  else
    Result := inherited;
end;
function TFormFileProducerModel.GetFormFile: TFormFile;
begin
  Result := TFormFile(FileName);
end;

procedure TFormFileProducerModel.SetFormResource(const Value: TStream);
begin
  FFormResource.Size := 0;
  FFormResource.Position := 0;
  FFormResource.CopyFrom(Value, Value.Size);
end;
end.
