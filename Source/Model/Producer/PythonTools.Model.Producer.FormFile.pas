unit PythonTools.Model.Producer.FormFile;

interface

uses
  System.Classes,
  PythonTools.Common;

type
  TFormFileProducerModel = class
  private
    FFormFile: TFormFile;
    FDirectory: string;
    FForm: TComponent;
    FFormResource: TStream;
    procedure SetFormResource(const Value: TStream);
  public
    constructor Create();
    destructor Destroy(); override;

    /// <summary>
    ///   The .dfm/.fmx file name. Warning: Must not contain extension.
    /// </summary>
    property FormFile: TFormFile read FFormFile write FFormFile;
    /// <summary>
    ///   The directory where the generated files will be saved
    /// </summary>
    property Directory: string read FDirectory write FDirectory;
    /// <summary>
    ///   The exported form
    /// </summary>
    property Form: TComponent read FForm write FForm;
    /// <summary>
    ///   The .dfm/.fmx text stream.
    /// </summary>
    property FormResource: TStream read FFormResource write SetFormResource;
  end;

implementation

{ TFormFileProducerModel }

constructor TFormFileProducerModel.Create;
begin
  FFormResource := TMemoryStream.Create();
end;

destructor TFormFileProducerModel.Destroy;
begin
  FFormResource.Free();
  inherited;
end;

procedure TFormFileProducerModel.SetFormResource(const Value: TStream);
begin
  FFormResource.Size := 0;
  FFormResource.Position := 0;
  FFormResource.CopyFrom(Value, Value.Size);
end;

end.
