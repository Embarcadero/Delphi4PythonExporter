unit PythonTools.Model.Producer.Application;

interface

uses
  PythonTools.Common,
  PythonTools.Model.Producer;

type
  TApplicationProducerModel = class(TAbastractProducerModel)
  private
    FTitle: string;
    FMainForm: string;
    FImportedForms: TFormNamesAndFiles;
    function GetApplicationFile: TApplicationFile;
  protected
    function GetPythonFileName: string; override;
  public
    /// <summary>
    ///   The application file name.
    /// </summary>
    property ApplicationFile: TApplicationFile read GetApplicationFile;
    /// <summary>
    ///   The GUI application main form
    /// </summary>
    property MainForm: string read FMainForm write FMainForm;
    /// <summary>
    ///   The application title
    /// </summary>
    property Title: string read FTitle write FTitle;
    /// <summary>
    ///   Forms included in the import section
    /// </summary>
    property ImportedForms: TFormNamesAndFiles read FImportedForms write FImportedForms;
  end;

implementation

uses
  System.IOUtils;

{ TApplicationProducerModel }

function TApplicationProducerModel.GetApplicationFile: TApplicationFile;
begin
  Result := TApplicationFile(FileName);
end;

function TApplicationProducerModel.GetPythonFileName: string;
begin
  Result := TPath.Combine(Directory, ApplicationFile.AsPython())
end;

end.
