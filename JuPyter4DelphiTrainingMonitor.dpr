program JuPyter4DelphiTrainingMonitor;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {Form1},
  UnitPy4DUtils in 'UnitPy4DUtils.pas',
  UnitPyBackend in 'UnitPyBackend.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
