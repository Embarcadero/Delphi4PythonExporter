unit PythonTools.Model.FormFileProducer;

interface

uses
  System.Classes,
  PythonTools.Common;

type
  TFormFileProducerModel = class
  private
    FFormFile: TFormFile;
    FDirectory: string;
    FFormFilePath: TFormFilePath;
    FForm: TComponent;
  public
    /// <summary>
    ///   The .dfm/.fmx file name. Warning: Must not contain extension.
    /// </summary>
    property FormFile: TFormFile read FFormFile write FFormFile;
    /// <summary>
    ///   The directory where the generated files will be saved
    /// </summary>
    property Directory: string read FDirectory write FDirectory;
    /// <summary>
    ///   The .dfm/.fmx file path. Warning: Must not contain extension.
    /// </summary>
    property FormFilePath: TFormFilePath read FFormFilePath write FFormFilePath;
    /// <summary>
    ///   The exported form
    /// </summary>
    property Form: TComponent read FForm write FForm;
  end;

implementation

end.
