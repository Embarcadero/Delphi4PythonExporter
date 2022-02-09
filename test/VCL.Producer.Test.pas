unit VCL.Producer.Test;

interface

uses
  DUnitX.TestFramework,
  PythonTools.Common,
  PythonTools.Producer,
  PythonTools.Producer.SimpleFactory,
  PythonTools.Model.ApplicationProducer;

type
  [TestFixture]
  TProducerTest = class
  private
    FProducer: IPythonCodeProducer;
    FApplicationModel: TApplicationProducerModel;

    function GetFilesDir(): string;
    function BuildApplicationModel(): TApplicationProducerModel;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure CheckFormInheritance();
    [Test]
    procedure GenerateApplication();
  end;

implementation

uses
  System.SysUtils, System.IOUtils, System.Classes, Vcl.Forms;

procedure TProducerTest.Setup;
begin
  FProducer := TProducerSimpleFactory.CreateProducer('VCL');
  FApplicationModel := BuildApplicationModel();
end;

procedure TProducerTest.TearDown;
begin
  FApplicationModel.Free();
  FProducer := nil;
  TDirectory.Delete(GetFilesDir(), true);
end;

function TProducerTest.GetFilesDir: string;
begin
  Result := TPath.Combine(ExtractFileDir(ParamStr(0)), 'testfiles');
  if not TDirectory.Exists(Result) then
    TDirectory.CreateDirectory(Result);
end;

function TProducerTest.BuildApplicationModel: TApplicationProducerModel;
const
  UNIT_NAME = 'UnitFormTest';
  FORM_NAME = 'FormTest';
begin
  Result := TApplicationProducerModel.Create();
  try
    Result.Directory := GetFilesDir();
    Result.FileName := UNIT_NAME;

    Result.Title := 'Test';
    Result.MainForm := FORM_NAME;

    var LForms := TFormNameAndFileList.Create();
    try
      LForms.Add(TFormNameAndFile.Create(FORM_NAME, UNIT_NAME));
      Result.ImportedForms := LForms.ToArray();
    finally
      LForms.Free();
    end;
  except
    on E: Exception do begin
      FreeAndNil(Result);
      raise;
    end;
  end;
end;

procedure TProducerTest.CheckFormInheritance;
begin
  Assert.IsTrue(FProducer.IsValidFormInheritance(TForm));
end;

procedure TProducerTest.GenerateApplication;
begin
  //Save the project file
  FProducer.SavePyApplicationFile(FApplicationModel);

  //Check for the generated file
  var LFilePath := TPath.Combine(FApplicationModel.Directory, ChangeFileExt(FApplicationModel.FileName, '.py'));
  Assert.IsTrue(TFile.Exists(LFilePath));

  var LStrings := TStringList.Create();
  try
    LStrings.LoadFromFile(LFilePath);

//    from delphivcl import *
//    from UnitFormTest import FormTest
//
//    def main():
//        Application.Initialize()
//        Application.Title = 'Test'
//        MainForm = FormTest(Application)
//        MainForm.Show()
//        FreeConsole()
//        Application.Run()
//
//    if __name__ == '__main__':
//        main()

    Assert.IsTrue(LStrings.Count = 13);
    Assert.IsTrue(LStrings[0] = 'from delphivcl import *');
    Assert.IsTrue(LStrings[1] = 'from UnitFormTest import FormTest');
    Assert.IsTrue(LStrings[2] = String.Empty);
    Assert.IsTrue(LStrings[3] = 'def main():');
    Assert.IsTrue(LStrings[4] = sIdentation1 + 'Application.Initialize()');
    Assert.IsTrue(LStrings[5] = sIdentation1 + 'Application.Title = ''Test''');
    Assert.IsTrue(LStrings[6] = sIdentation1 + 'MainForm = FormTest(Application)');
    Assert.IsTrue(LStrings[7] = sIdentation1 + 'MainForm.Show()');
    Assert.IsTrue(LStrings[8] = sIdentation1 + 'FreeConsole()');
    Assert.IsTrue(LStrings[9] = sIdentation1 + 'Application.Run()');
    Assert.IsTrue(LStrings[10] = String.Empty);
    Assert.IsTrue(LStrings[11] = 'if __name__ == ''__main__'':');
    Assert.IsTrue(LStrings[12] = sIdentation1 + 'main()');
  finally
    LStrings.Free();
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TProducerTest);

end.
