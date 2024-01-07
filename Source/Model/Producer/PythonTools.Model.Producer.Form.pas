unit PythonTools.Model.Producer.Form;

interface

uses
  System.Rtti,
  System.Classes,
  PythonTools.Common,
  PythonTools.Model.Producer;

type
  TBaseFormProducerModel = class(TAbastractProducerModel)
  private type
    TModuleInitialization = class
    private
      FGenerateInitialization: boolean;
      FTitle: string;
      FMainForm: string;
    public
      /// <summary>
      ///   Generate the Python module app GUI initialization section
      /// </summary>
      property GenerateInitialization: boolean read FGenerateInitialization write FGenerateInitialization;
      /// <summary>
      ///   The GUI application title
      /// </summary>
      property Title: string read FTitle write FTitle;
      /// <summary>
      ///   The GUI application Main Form
      /// </summary>
      property MainForm: string read FMainForm write FMainForm;
    end;
  private
    FFormName: string;
    FFormParentName: string;
    FExportedComponents: TExportedComponents;
    FModuleInitialization: TModuleInitialization;
    FExportedEvents: TExportedEvents;
  public
    constructor Create(); override;
    destructor Destroy(); override;
    /// <summary>
    ///   The Form name: used to generate the Python class name
    /// </summary>
    property FormName: string read FFormName write FFormName;
    /// <summary>
    ///   The Form parent class name: used to the Form inheritance chain
    /// </summary>
    property FormParentName: string read FFormParentName write FFormParentName;
    /// <summary>
    ///   List of exported components
    /// </summary>
    property ExportedComponents: TExportedComponents read FExportedComponents write FExportedComponents;
    /// <summary>
    ///   List of exported events
    /// </summary>
    property ExportedEvents: TExportedEvents read FExportedEvents write FExportedEvents;
    /// <summary>
    ///   Generates the model initialization section
    /// </summary>
    property ModuleInitialization: TModuleInitialization read FModuleInitialization;
  end;

  TFormProducerModel = class(TBaseFormProducerModel);

implementation

{ TBaseFormProducerModel }

constructor TBaseFormProducerModel.Create;
begin
  inherited;
  FModuleInitialization := TModuleInitialization.Create();
end;

destructor TBaseFormProducerModel.Destroy;
begin
  FModuleInitialization.Free();
  inherited;
end;

end.
