unit PythonTools.Exceptions;

interface

uses
  System.SysUtils;

type
  EFormInheritanceNotSupported = class(Exception)
  end;

  EUnableToObtainFormDesigner = class(Exception)
  end;

implementation

end.
