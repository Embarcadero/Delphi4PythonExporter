unit VCL.Producer.Test;

interface

uses
  DUnitX.TestFramework,
  PythonTools.Common,
  PythonTools.Producer,
  PythonTools.Producer.SimpleFactory,
  PythonTools.Model.Producer.Application,
  PythonTools.Model.Producer.Form,
  PythonTools.Model.Producer.FormFile;

type
  [TestFixture]
  TVCLProducerTest = class
  private
    FProducer: IPythonCodeProducer;
    FApplicationModel: TApplicationProducerModel;
    FFormModel: TFormProducerModel;
    FFormFileModel: TFormFileProducerModel;

    function GetFilesDir(): string;
    function GetDataDir(): string;

    function BuildApplicationModel(): TApplicationProducerModel;
    function BuildFormModel(): TFormProducerModel;
    function BuildFormFileModel(): TFormFileProducerModel;
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
    [Test]
    procedure GenerateFormFileBin();
    [Test]
    procedure GenerateFormFileTxt();
  end;

implementation

uses
  System.SysUtils, System.IOUtils, System.Classes, Vcl.Forms, Data.VCLForm;

procedure TVCLProducerTest.Setup;
begin
  FProducer := TProducerSimpleFactory.CreateProducer('VCL');
  FApplicationModel := BuildApplicationModel();
  FFormModel := BuildFormModel();
  FFormFileModel := BuildFormFileModel();
end;

procedure TVCLProducerTest.TearDown;
begin
  FFormFileModel.Free();
  FFormModel.Free();
  FApplicationModel.Free();
  FProducer := nil;
  TDirectory.Delete(GetFilesDir(), true);
end;

function TVCLProducerTest.GetDataDir: string;
begin
  Result := TDirectory.GetParent(TDirectory.GetParent(ExtractFileDir(ParamStr(0))));
  Result := TPath.Combine(Result, 'data');
end;

function TVCLProducerTest.GetFilesDir: string;
begin
  Result := TPath.Combine(ExtractFileDir(ParamStr(0)), 'testfiles');
  if not TDirectory.Exists(Result) then
    TDirectory.CreateDirectory(Result);
end;

function TVCLProducerTest.BuildApplicationModel: TApplicationProducerModel;
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

function TVCLProducerTest.BuildFormFileModel: TFormFileProducerModel;
begin
  Result := TFormFileProducerModel.Create();
  try
    Result.Directory := GetFilesDir();
    Result.FileName := 'Data.VCLForm';
    var LStream := TFileStream.Create(TPath.Combine(GetDataDir(), 'Data.VCLForm.dfm'), fmOpenRead);
    try
      Result.FormResource := LStream;
      Result.FormResource.Position := 0;
    finally
      LStream.Free();
    end;
    Result.Form := VclForm;
    Result.Mode := TFormFileMode.ffmPython;
    Result.FrameworkType := 'VCL';
  except
    on E: Exception do begin
      FreeAndNil(Result);
      raise;
    end;
  end;
end;

function TVCLProducerTest.BuildFormModel: TFormProducerModel;
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

procedure TVCLProducerTest.CheckFormInheritance;
begin
  Assert.IsTrue(FProducer.IsValidFormInheritance(TForm));
end;

procedure TVCLProducerTest.GenerateApplication;
begin
  //Save the project file
  FProducer.SavePyApplicationFile(FApplicationModel, FApplicationModel.Stream);
  FApplicationModel.Stream.Position := 0;

  //Check for the generated file
  var LFilePath := TPath.Combine(FApplicationModel.Directory, FApplicationModel.FileName.AsPython());
  Assert.IsTrue(TFile.Exists(LFilePath));

  var LStrings := TStringList.Create();
  try
    LStrings.LoadFromStream(FApplicationModel.Stream);

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

procedure TVCLProducerTest.GenerateForm;
begin
  //Save the form file
  FProducer.SavePyForm(FFormModel, FFormFileModel, FFormModel.Stream);
  FFormModel.Stream.Position := 0;

  //Check for the generated file
  var LFilePath := TPath.Combine(FFormModel.Directory, FFormModel.FileName.AsPython());
  Assert.IsTrue(TFile.Exists(LFilePath));

  var LStrings := TStringList.Create();
  try
    LStrings.LoadFromStream(FFormModel.Stream);
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
    Assert.IsTrue(LStrings[7] = sIdentation2
      + Format('self.LoadProps(os.path.join(os.path.dirname(os.path.abspath(__file__)), "%s%s"))', [
      FFormModel.FileName, TFormFile('').AsPythonDfm()]));
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

procedure TVCLProducerTest.GenerateFormFileBin;
begin
  //Save the project file
  FProducer.SavePyFormFileBin(FFormFileModel, FFormFileModel.Stream);

  //Check for the generated file
  var LFilePath := TPath.Combine(FFormFileModel.Directory, FFormFileModel.FormFile.AsPythonDfm());
  Assert.IsTrue(TFile.Exists(LFilePath));

  var LStream := TFileStream.Create(LFilePath, fmOpenRead or fmShareDenyNone);
  try
    var LReader := TReader.Create(LStream, 4096);
    try
      var LForm := TVclForm.CreateNew(nil);
      try
        try
          LReader.ReadRootComponent(LForm);
        except
          on E: Exception do
            Assert.Fail(E.Message);
        end;
      finally
        LForm.Free();
      end;
    finally
      LReader.Free();
    end;
  finally
    LStream.Free();
  end;
end;

procedure TVCLProducerTest.GenerateFormFileTxt;
begin
  //Save the project file
  FProducer.SavePyFormFileTxt(FFormFileModel, FFormFileModel.Stream);

  //Check for the generated file
  var LFilePath := TPath.Combine(FFormFileModel.Directory, FFormFileModel.FormFile.AsPythonDfm());
  Assert.IsTrue(TFile.Exists(LFilePath));

  var LInput := TFileStream.Create(LFilePath, fmOpenRead or fmShareDenyNone);
  try
    var LOutput := TMemoryStream.Create();
    try
      ObjectTextToBinary(LInput, LOutput);
      var LReader := TReader.Create(LOutput, 4096);
      try
        var LForm := TVclForm.CreateNew(nil);
        try
          try
            LOutput.Position := 0;
            LReader.ReadRootComponent(LForm);
          except
            on E: Exception do
              Assert.Fail(E.Message);
          end;
        finally
          LForm.Free();
        end;
      finally
        LReader.Free();
      end;
    finally
      LOutput.Free();
    end;
  finally
    LInput.Free();
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TVCLProducerTest);

end.
