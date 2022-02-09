unit VCL.Producer.Test;

interface

uses
  DUnitX.TestFramework,
  PythonTools.Common,
  PythonTools.Producer,
  PythonTools.Producer.SimpleFactory,
  PythonTools.Model.ApplicationProducer,
  PythonTools.Model.FormProducer;

type
  [TestFixture]
  TProducerTest = class
  private
    FProducer: IPythonCodeProducer;
    FApplicationModel: TApplicationProducerModel;
    FFormModel: TFormProducerModel;

    function GetFilesDir(): string;
    function BuildApplicationModel(): TApplicationProducerModel;
    function BuildFormModel(): TFormProducerModel;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure CheckFormInheritance();
    [Test]
    procedure GenerateApplication();
    [Test]
    procedure GenerateForm();
  end;

implementation

uses
  System.SysUtils, System.IOUtils, System.Classes, Vcl.Forms;

procedure TProducerTest.Setup;
begin
  FProducer := TProducerSimpleFactory.CreateProducer('VCL');
  FApplicationModel := BuildApplicationModel();
  FFormModel := BuildFormModel();
end;

procedure TProducerTest.TearDown;
begin
  FFormModel.Free();
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
  UNIT_NAME = 'UnitProjectTest';
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

function TProducerTest.BuildFormModel: TFormProducerModel;
const
  UNIT_NAME = 'UnitFormTest';
  FORM_NAME = 'FormTest';
begin
  Result := TFormProducerModel.Create();
  try
    Result.Directory := GetFilesDir();
    Result.FileName := UNIT_NAME;

    Result.FormName := FORM_NAME;
    Result.FormParentName := TForm.ClassName.Replace('T', '');

    var LExportCompList := TExportedComponentList.Create();
    try
      LExportCompList.Add(TExportedComponent.Create('Comp1'));
      Result.ExportedComponents := LExportCompList.ToArray();
    finally
      LExportCompList.Free();
    end;

    var LExporEvtList := TExportedEventList.Create();
    try
      LExporEvtList.Add(TExportedEvent.Create('Event1',
        TArray<string>.Create('Param1', 'Param2')));
      Result.ExportedEvents := LExporEvtList.ToArray();
    finally
      LExporEvtList.Free();
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

    {** this is what we excpect **}
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
    Assert.IsTrue(LStrings[1] = Format('from %s import %s', [
      FApplicationModel.ImportedForms[0].FileName,
      FApplicationModel.ImportedForms[0].FormName]));
    Assert.IsTrue(LStrings[2] = String.Empty);
    Assert.IsTrue(LStrings[3] = 'def main():');
    Assert.IsTrue(LStrings[4] = sIdentation1 + 'Application.Initialize()');
    Assert.IsTrue(LStrings[5] = sIdentation1 + Format('Application.Title = %s', [
      FApplicationModel.Title.QuotedString()]));
    Assert.IsTrue(LStrings[6] = sIdentation1 + Format('MainForm = %s(Application)', [
      FApplicationModel.MainForm]));
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

procedure TProducerTest.GenerateForm;
begin
  //Save the form file
  FProducer.SavePyForm(FFormModel);

  //Check for the generated file
  var LFilePath := TPath.Combine(FFormModel.Directory, ChangeFileExt(FFormModel.FileName, '.py'));
  Assert.IsTrue(TFile.Exists(LFilePath));

  var LStrings := TStringList.Create();
  try
    LStrings.LoadFromFile(LFilePath);
    {** this is what we excpect **}
//    import os
//    from delphivcl import *
//
//    class FormTest(Form):
//
//        def __init__(self, owner):
//            self.Comp1 = None
//            self.LoadProps(os.path.join(os.path.dirname(os.path.abspath(__file__)), "UnitFormTest.pydfm"))
//
//        def Event1(self, Param1, Param2):
//            pass

    Assert.IsTrue(LStrings.Count = 11);
    Assert.IsTrue(LStrings[0] = 'import os');
    Assert.IsTrue(LStrings[1] = 'from delphivcl import *');
    Assert.IsTrue(LStrings[2] = String.Empty);
    Assert.IsTrue(LStrings[3] = Format('class %s(Form):', [FFormModel.FormName]));
    Assert.IsTrue(LStrings[4] = String.Empty);
    Assert.IsTrue(LStrings[5] = sIdentation1 + 'def __init__(self, owner):');
    Assert.IsTrue(LStrings[6] = sIdentation2 + Format('self.%s = None', [
      FFormModel.ExportedComponents[0].ComponentName]));
    Assert.IsTrue(LStrings[7] = sIdentation2 + Format('self.LoadProps(os.path.join(os.path.dirname(os.path.abspath(__file__)), "%s.pydfm"))', [
      FFormModel.FileName]));
    Assert.IsTrue(LStrings[8] = String.Empty);
    Assert.IsTrue(LStrings[9] = sIdentation1 + Format('def %s(self, %s, %s):', [
      FFormModel.ExportedEvents[0].MethodName,
      FFormModel.ExportedEvents[0].MethodParams[0],
      FFormModel.ExportedEvents[0].MethodParams[1]]));
    Assert.IsTrue(LStrings[10] = sIdentation2 +'pass');
  finally
    LStrings.Free();
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TProducerTest);

end.
