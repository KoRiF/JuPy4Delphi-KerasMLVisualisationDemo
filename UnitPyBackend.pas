unit UnitPyBackend;

interface
uses
  PythonEngine, WrapDelphi;
type
  TPyTaskManager = Class
    PythonEngine: TPythonEngine;

    constructor Create(pyEngine: TPythonEngine); overload;
    constructor Create(Module: TPythonModule; module_name: string); overload;
    procedure PyWrap(Wrapper: TPyDelphiWrapper; Module: TPythonModule; module_name: string);  virtual;
    protected
    procedure RunScript(script: string = '');
    procedure RunScripts(const scripts: array of string);
  End;
implementation

{ TPyTaskManager }

constructor TPyTaskManager.Create(pyEngine: TPythonEngine);
begin
  Self.PythonEngine := pyEngine;
end;

constructor TPyTaskManager.Create(Module: TPythonModule; module_name: string);
var Wrapper: TPyDelphiWrapper;
begin
  Self.PythonEngine := Module.Engine;
  Self.PyWrap(nil, Module, module_name);
end;

procedure TPyTaskManager.PyWrap(Wrapper: TPyDelphiWrapper;  Module: TPythonModule; module_name: string);
begin
  if Wrapper = nil then
  begin
    Wrapper := TPyDelphiWrapper.Create(Module);
    Wrapper.Module := Module;
    Wrapper.Engine := Module.Engine;
  end;

  var Py := Wrapper.Wrap(Self);
  Module.SetVar(module_name, Py);
  PythonEngine.Py_DECREF(Py);
end;

procedure TPyTaskManager.RunScript(script: string);
begin
  PythonEngine.ExecString(UTF8Encode(script));
end;

procedure TPyTaskManager.RunScripts(const scripts: array of string);
begin
  for var i := 0 to High(scripts) do
    RunScript(scripts[i]);
end;

begin
  MaskFPUExceptions(True);
end.
