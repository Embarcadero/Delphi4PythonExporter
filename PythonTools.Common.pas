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

implementation

{ TFormNameAndFile }

constructor TFormNameAndFile.Create(const AFormName, AFileName: string);
begin
  FormName := AFormName;
  FileName := AFileName;
end;

end.
