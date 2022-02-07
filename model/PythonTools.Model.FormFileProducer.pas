unit PythonTools.Model.FormFileProducer;

interface

uses
  System.Classes;

type
  TFormFilePath = type string;

  TFormFileProducerModel = class
  private
    FFileName: string;
    FDirectory: string;
    FFormFilePath: TFormFilePath;
    FForm: TComponent;
  public
    /// <summary>
    ///   The .dfm file name
    /// </summary>
    property FileName: string read FFileName write FFileName;
    /// <summary>
    ///   The directory where the generated files will be saved
    /// </summary>
    property Directory: string read FDirectory write FDirectory;
    /// <summary>
    ///   The .dfm/.fmx file path
    /// </summary>
    property FormFilePath: TFormFilePath read FFormFilePath write FFormFilePath;
    /// <summary>
    ///   The exported form
    /// </summary>
    property Form: TComponent read FForm write FForm;
  end;

  TFormFilePathHelper = record helper for TFormFilePath
  public
    function AsDfm(): string;
    function AsFmx(): string;
  end;

implementation

uses
  System.SysUtils;

{ TFormFilePathHelper }

function TFormFilePathHelper.AsDfm: string;
begin
  Result := ChangeFileExt(Self, '.dfm');
end;

function TFormFilePathHelper.AsFmx: string;
begin
  Result := ChangeFileExt(Self, '.fmx');
end;

end.
