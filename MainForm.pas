unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.Generics.Collections,
  Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, SynEdit, Vcl.StdCtrls,
  PythonEngine, PythonGUIInputOutput, SynEditPythonBehaviour,
  SynEditHighlighter, SynEditCodeFolding, SynHighlighterPython,
  WrapDelphi,
  Vcl.ExtCtrls, Vcl.Mask, Vcl.Buttons, Vcl.ExtDlgs, FireDAC.UI.Intf,
  FireDAC.VCLUI.Async, FireDAC.Stan.Intf, FireDAC.Comp.UI, VclTee.TeeGDIPlus,
  VCLTee.TeEngine, VCLTee.TeeProcs, VCLTee.Chart, VCLTee.Series;

type
  TForm1 = class(TForm)
    HeaderControl1: THeaderControl;
    Panel1: TPanel;
    Splitter1: TSplitter;
    Panel2: TPanel;
    HeaderControl2: THeaderControl;
    mePythonOutput: TMemo;
    SynPythonSyn: TSynPythonSyn;
    SynEditPythonBehaviour: TSynEditPythonBehaviour;
    PythonEngine: TPythonEngine;
    PythonGUIInputOutput: TPythonGUIInputOutput;
    btnRun: TButton;
    sePythonCode: TSynEdit;

    PageControl1: TPageControl;
    TabSheetJupyter: TTabSheet;
    SynEditDataDefinition: TSynEdit;
    TabSheetDataDefinitions: TTabSheet;
    LabeledEditJupyFilePath: TLabeledEdit;
    PythonModule1: TPythonModule;
    PyDelphiWrapper1: TPyDelphiWrapper;
    CheckBoxStripCellCode: TCheckBox;
    OpenTextFileDialog1: TOpenTextFileDialog;
    ComboBoxJuPyToken: TComboBox;
    TabSheetModelTraining: TTabSheet;
    TabSheetModelTesting: TTabSheet;
    FDGUIxAsyncExecuteDialog1: TFDGUIxAsyncExecuteDialog;
    SynEditModelTraining: TSynEdit;
    SynEditModelTesting: TSynEdit;
    TabSheetMonitoring: TTabSheet;
    Chart1: TChart;
    ButtonRunTraining: TButton;
    ButtonInterrupt: TButton;
    OpenTextFileDialog_CallbackScript: TOpenTextFileDialog;
    TabSheetModelDefinition: TTabSheet;
    SynEditModelDefinition: TSynEdit;
    procedure btnRunClick(Sender: TObject);
    procedure PythonEngineBeforeLoad(Sender: TObject);
    procedure FormCreate(Sender: TObject);


    procedure ButtonClearClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure ComboBoxJuPyTokenDropDown(Sender: TObject);
    procedure ButtonRunTrainingClick(Sender: TObject);
    procedure ButtonInterruptClick(Sender: TObject);


  private
    const TAB_IX_DATADEF = 1;
    const TAB_IX_MODELDEF = 2;
    const TAB_IX_MODELTRAIN = 3;
    const TAB_IX_MONITOR = 4;
    const TAB_IX_MODELTEST = 5;

  private
    { Private declarations }
    _Interruption: boolean;
    jupyCells: TDictionary<String, String>;
    function getJupyToken: string;


    function getJupyFilepath(): string;
    function getJupySocket(): string;

    procedure LoadPySourceFromCell(const cellTag: string; SynEditPy: TSynEdit; doStrip: boolean = True);

    procedure DefineDelphiCallback();
    procedure RunTrainingSession();

    private
    SeriesByMetric: TStringList;
    function training_callback(pself, args : PPyObject): PPyObject; cdecl;

    function ScanJupyterNotebooks(): TStringList;
  public
    { Public declarations }
    property Interruption: boolean read _Interruption write _Interruption;
    property jupyFilepath: string read getJupyFilepath;
    property jupyToken: string read getJupyToken;
    property jupySocket: string read getJupySocket;
    procedure addJupyCellCode(code: string);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  FileCtrl,
  WrapDelphiVCL,
  System.Rtti,
  System.Threading,
  System.Math,
  UnitPy4DUtils,
  System.JSON;
const
  defaultHttpSocket = 'http://localhost:8888';


procedure TForm1.addJupyCellCode(code: string);
begin
  var celltext := code;
  var cellkey := extractJuPyCellKey(code);
  jupyCells.AddOrSetValue(cellkey, code);
end;

procedure TForm1.btnRunClick(Sender: TObject);
const TOKENLENGTH = 48;
begin
  if Length(ComboBoxJuPyToken.Text)<>TOKENLENGTH then
  begin
    MessageDlg('Jupyter token not recognized', TMsgDlgType.mtError, [mbCancel], 0);
    Exit;
  end;

  try
    PythonEngine.ExecString(UTF8Encode(sePythonCode.Text));

    LoadPySourceFromCell('Data Definition', SynEditDataDefinition, CheckBoxStripCellCode.Checked);
    LoadPySourceFromCell('Model Definition', SynEditModelDefinition, CheckBoxStripCellCode.Checked);
    LoadPySourceFromCell('Model Training', SynEditModelTraining, CheckBoxStripCellCode.Checked);
    LoadPySourceFromCell('Model Testing', SynEditModelTesting, CheckBoxStripCellCode.Checked);

    ShowMessage('Successfully attached to the Jupyter Notebook!');
    Self.PageControl1.ActivePageIndex := TAB_IX_DATADEF;
  except on Ex: EPySystemExit do
  end;
end;

procedure TForm1.ButtonClearClick(Sender: TObject);
begin
  //Memo1.Lines.Clear();
end;

procedure TForm1.ButtonInterruptClick(Sender: TObject);
begin
  Self.Interruption := True;
  ButtonInterrupt.Enabled := False;
  ButtonRunTraining.Enabled := True;
end;

procedure TForm1.ButtonRunTrainingClick(Sender: TObject);
begin
  ButtonInterrupt.Enabled := True;
  ButtonRunTraining.Enabled := False;

  //PythonModule1.AddDelphiMethod('training_callback', training_callback, 'training_callback');

  PythonModule1.Initialize;
  try
    DefineDelphiCallback();
    PageControl1.ActivePageIndex := TAB_IX_MONITOR;
    RunTrainingSession();
  except on Ex: EPySystemExit do
    begin
      var code := Ex.EValue;
      if (code='') or (code='0') then
      begin
        ShowMessage('Python script: Exit success');
        exit;
      end
      else raise Ex;
    end;
  end;
  ButtonInterrupt.Enabled := False;
  ButtonRunTraining.Enabled := True;
end;

procedure TForm1.ComboBoxJuPyTokenDropDown(Sender: TObject);
begin
  if (ComboBoxJuPyToken.ItemIndex < 0) or (ComboBoxJuPyToken.Text = '')  then
  begin
    var TokensList := ScanJupyterNotebooks();
    if TokensList.Count > 0 then
    begin
      ComboBoxJuPyToken.Items.Clear;
      ComboBoxJuPyToken.Items.AddStrings(TokensList);
      ComboBoxJuPyToken.ItemIndex := 0;
    end;
  end;
end;

procedure TForm1.DefineDelphiCallback;
begin
  var callbackfile := 'delphi_training_callback.py';
  if OpenTextFileDialog_CallbackScript.FileName = '' then
  begin
    OpenTextFileDialog_CallbackScript.InitialDir := ExtractFilePath(Application.ExeName);
    OpenTextFileDialog_CallbackScript.FileName := callbackfile;
  end
  else
    Exit;

  if  OpenTextFileDialog_CallbackScript.Execute() then
  begin
    if not FileExists(OpenTextFileDialog_CallbackScript.FileName) then
    begin
      OpenTextFileDialog_CallbackScript.FileName := '';
      Exit;
    end;

    var CallbackScript := TStringList.Create;
    CallbackScript.LoadFromFile(OpenTextFileDialog_CallbackScript.FileName);
    if CallbackScript.Text = '' then
    begin
      OpenTextFileDialog_CallbackScript.FileName := '';
      Exit;
    end;

    PythonEngine.ExecString(UTF8Encode(CallbackScript.Text));  //   callbackscript.Text + #$D#$A +
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  var Py := PyDelphiWrapper1.Wrap(Form1);
  PythonModule1.SetVar('delphi_form', Py);
  PythonModule1.AddDelphiMethod('training_callback', training_callback, 'training_callback');
  PythonEngine.Py_DECREF(Py);

  jupyCells := TDictionary<String, String>.Create();

  SeriesByMetric := TStringList.Create;
end;

function TForm1.getJupyFilepath: string;
begin
  RESULT := LabeledEditJupyFilePath.Text;
end;

function TForm1.getJupySocket: string;
begin
  RESULT := defaultHttpSocket;
end;

function TForm1.getJupyToken: string;
begin
  RESULT := ComboBoxJupyToken.Text;
end;


procedure TForm1.LoadPySourceFromCell(const cellTag: string; SynEditPy: TSynEdit; doStrip: boolean);
begin
    var pyCode := '';
    if jupyCells.TryGetValue(cellTag, pyCode) then
    begin
      if doStrip then
        pyCode := includeDelphiInteraction(pyCode);
      SynEditPy.Text := pyCode;
    end;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
  if OpenTextFileDialog1.Execute() then
  begin
//    LabeledEdit1.Text := OpenTextFileDialog1.FileName;
//    Memo1.Lines.LoadFromFile(OpenTextFileDialog1.FileName);
  end;
end;

function TForm1.training_callback(pself, args: PPyObject): PPyObject;
var
    varArr: Variant;
    epoch: Integer;
    first: Boolean;
    idx: Integer;
    metric: String;
    Series: TChartSeries;
    st:string;
    JSonValue: TJSONObject;
    JSONPair: TJSONPair;
begin
    Application.ProcessMessages;
    with GetPythonEngine do begin
        varArr := PyObjectAsVariant(args);
        epoch := StrToInt(VarToStr(varArr[0]));

        if not VarIsNull(varArr[1]) then begin
            st := VarToStr(varArr[1]);
            JsonValue := TJSonObject.ParseJSONValue(st) as TJSONObject;
            first := Chart1.SeriesList.Count = 0;
            try
                for JSONPair in JSonValue do begin
                    metric := JSONPair.JsonString.ToString;
                    if first then begin
                        Series := Chart1.AddSeries(TLineSeries.Create( Chart1)); //*
                        Series.Title := metric;
                        TLineSeries(Series).LinePen.Width := 3;
                        //Series.Marks.Visible := True;
                        //Series.Color := clRed;
                        SeriesByMetric.AddObject(metric, Series);
                    end
                    else begin
                        idx := SeriesByMetric.IndexOf(metric);
                        Series := SeriesByMetric.Objects[idx] as TChartSeries;
                    end;
                    Series.AddXY(epoch, JSONPair.JsonValue.AsType<double>, '');
                end;
            finally
                JsonValue.Free;
            end;
            if first then begin
                Chart1.View3D := False;
                Chart1.Legend.CheckBoxes := True;
            end;
            Chart1.Refresh;
        end;

        if Interruption then
          RESULT := PyUnicodeFromString('stop')
        else
          RESULT := ReturnNone;
    end;

end;

function TForm1.ScanJupyterNotebooks: TStringList;
const TOKENTOKEN = '?token=';
  TOKENLENGTH = 48;
begin
  RESULT := TStringList.Create;
  var cmdlines := TStringList.Create();
  //cmdlines.Add('import os');
  //cmdlines.Add('os.system(''cmd /c "jupyter notebook list"'')');
  cmdlines.Add('import subprocess');
  cmdlines.Add('result = subprocess.run(["jupyter", "notebook", "list"], stdout=subprocess.PIPE)');
  cmdlines.Add('print(result.stdout)');
  PythonEngine.ExecString(UTF8Encode(cmdlines.Text));
  for var line in PythonGUIInputOutput.Output.Lines do
  begin
    var p := Pos('?token=', line);
    if p > 0 then
    begin
      p := p - 1 + Length(TOKENTOKEN);
      var token := line.Substring(p, TOKENLENGTH);
      RESULT.Add(token);
    end;
  end;
end;

procedure TForm1.RunTrainingSession;
begin
  var dataDefScript := SynEditDataDefinition.Text;
  PythonEngine.ExecString(dataDefScript);

  var modelDefScript := SynEditModelDefinition.Text;
  PythonEngine.ExecString(modelDefScript);

  var trainingScript := SynEditModelTraining.Text;
  PythonEngine.ExecString(UTF8Encode(trainingScript));
end;

procedure TForm1.PythonEngineBeforeLoad(Sender: TObject);
begin
  PythonEngine.SetPythonHome('C:\ProgramData\Anaconda3\envs\p_38_idera');
end;

begin
  MaskFPUExceptions(True);
end.
