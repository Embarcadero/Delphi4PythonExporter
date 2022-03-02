unit PythonTools.Model.ApplicationProducer;

interface

uses
  PythonTools.Common;

type
  TApplicationProducerModel = class
  private
    FFileName: TApplicationFile;
    FTitle: string;
    FMainForm: string;
    FImportedForms: TFormNamesAndFiles;
    FDirectory: string;
  public
    /// <summary>
    ///   The GUI application main form
    /// </summary>
    property MainForm: string read FMainForm write FMainForm;
    /// <summary>
    ///   The application title
    /// </summary>
    property Title: string read FTitle write FTitle;
    /// <summary>
    ///   The Unit name: used to generate the Python (.py) file name. Warning: Must not contain extension.
    /// </summary>
    property FileName: TApplicationFile read FFileName write FFileName;
    /// <summary>
    ///   Forms included in the import section
    /// </summary>
    property ImportedForms: TFormNamesAndFiles read FImportedForms write FImportedForms;
    /// <summary>
    ///   The directory where the generated files will be saved
    /// </summary>
    property Directory: string read FDirectory write FDirectory;
  end;

implementation

end.
