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
  VCLTee.TeEngine, VCLTee.TeeProcs, VCLTee.Chart, VCLTee.Series, Vcl.Grids,
  Vcl.Samples.Spin;

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
    OpenTextFileDialogTrainingData: TOpenTextFileDialog;
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
    ButtonTestModel: TButton;
    StringGridXtrain: TStringGrid;
    StringGridYtrain: TStringGrid;
    SpinEditTrainSamplesNumber: TSpinEdit;
    SpinEditTrainFeaturesNumber: TSpinEdit;
    LabeledEditTrainDataFile: TLabeledEdit;
    StringGridXtest: TStringGrid;
    StringGridYtest: TStringGrid;
    SpinEditTestSamplesNumber: TSpinEdit;
    LabeledEditTestDataFile: TLabeledEdit;
    SpeedButtonLoadTrainData: TSpeedButton;
    ButtonPassTrainData: TButton;
    SpeedButtonLoadTestData: TSpeedButton;
    OpenTextFileDialogTestData: TOpenTextFileDialog;
    SpinEditTestFeaturesNumber: TSpinEdit;
    TabSheetPlots: TTabSheet;
    SynEditPlotting: TSynEdit;
    ButtonPlots: TButton;
    procedure btnRunClick(Sender: TObject);
    procedure PythonEngineBeforeLoad(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    procedure ComboBoxJuPyTokenDropDown(Sender: TObject);
    procedure ButtonRunTrainingClick(Sender: TObject);
    procedure ButtonInterruptClick(Sender: TObject);
    procedure ButtonTestModelClick(Sender: TObject);
    procedure SpinEditTrainSamplesNumberChange(Sender: TObject);
    procedure SpinEditTrainFeaturesNumberChange(Sender: TObject);
    procedure SpeedButtonLoadTrainDataClick(Sender: TObject);
    procedure ButtonPassTrainDataClick(Sender: TObject);
    procedure SpinEditTestSamplesNumberChange(Sender: TObject);
    procedure SpeedButtonLoadTestDataClick(Sender: TObject);
    procedure ButtonPlotsClick(Sender: TObject);


  private
    const TAB_IX_DATADEF = 1;
    const TAB_IX_MODELDEF = 2;
    const TAB_IX_MODELTRAIN = 3;
    const TAB_IX_MONITOR = 4;
    const TAB_IX_MODELTEST = 5;
    const TAB_IX_PLOTS = 6;
  private
    { Private declarations }
    _Interruption: boolean;
    jupyCells: TDictionary<String, String>;
    function getJupyToken: string;


    function getJupyFilepath(): string;
    function getJupySocket(): string;

    procedure LoadPySourceFromCell(const cellTag: string; SynEditPy: TSynEdit; doStrip: boolean = True);

    procedure DefineDelphiCallback();
    function RunTrainingSession(): boolean;
    procedure RunTesting();
    procedure ShowPlots();

    procedure ReshapeDataGrid(SpEdNSamples, SpEdNFeatures: TSpinEdit; GridX, GridY: TStringGrid);
    procedure LoadDataToGrid(DataFilename: string; Delimiter: char; GridX, GridY: TStringGrid; SpinSamples, SpinFeatures: TSpinEdit);
    procedure ExecFillPyListFromGrid(Identifier: string; Grid: TStringGrid; dims: Integer = 1);
    procedure ExecFillGridColumnFromPyList(Identifier: string; Grid: TStringGrid; ColIx: Integer);
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
  System.JSON,
  VarPyth;
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
    LoadPySourceFromCell('Resulting Plots', SynEditPlotting, CheckBoxStripCellCode.Checked);

    ShowMessage('Successfully attached to the Jupyter Notebook!');
    Self.PageControl1.ActivePageIndex := TAB_IX_DATADEF;
  except on Ex: EPySystemExit do
  end;
end;

procedure TForm1.ButtonInterruptClick(Sender: TObject);
begin
  Self.Interruption := True;
  ButtonInterrupt.Enabled := False;
  ButtonRunTraining.Enabled := True;
end;

procedure TForm1.ButtonPassTrainDataClick(Sender: TObject);
begin
  ExecFillPyListFromGrid('XX', StringGridXtrain, 2);
  ExecFillPyListFromGrid('yy', StringGridYtrain);

  var dataDefScript := SynEditDataDefinition.Text;
  PythonEngine.ExecString(dataDefScript);

  PageControl1.ActivePageIndex := TAB_IX_MODELTRAIN;
end;

procedure TForm1.ButtonPlotsClick(Sender: TObject);
begin
  ShowPlots();
  PageControl1.ActivePageIndex := TAB_IX_MODELTRAIN;
end;

procedure TForm1.ButtonRunTrainingClick(Sender: TObject);
var isTrainSessionCompleted: boolean;
begin
  Self.Interruption := False;
  ButtonInterrupt.Enabled := True;
  ButtonRunTraining.Enabled := False;

  //PythonModule1.AddDelphiMethod('training_callback', training_callback, 'training_callback');

  PythonModule1.Initialize;
  try
  try
    DefineDelphiCallback();
    PageControl1.ActivePageIndex := TAB_IX_MONITOR;
    isTrainSessionCompleted := RunTrainingSession();
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
  finally
    ButtonInterrupt.Enabled := False;
    ButtonRunTraining.Enabled := True;
  end;
  if isTrainSessionCompleted then
    PageControl1.ActivePageIndex := TAB_IX_MODELTEST
  else
    PageControl1.ActivePageIndex := TAB_IX_MODELTRAIN;
end;

procedure TForm1.ButtonTestModelClick(Sender: TObject);
begin
  ExecFillPyListFromGrid('XX_test', StringGridXtest, 2);
  ExecFillPyListFromGrid('yy_test', StringGridYtest);

  RunTesting();

  ExecFillGridColumnFromPyList('yy_pred', StringGridYtest, 1);
  ExecFillGridColumnFromPyList('errors', StringGridYtest, 2);

  PageControl1.ActivePageIndex := TAB_IX_PLOTS;
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

procedure TForm1.ExecFillGridColumnFromPyList(Identifier: string;
  Grid: TStringGrid; ColIx: Integer);
var
  offset: Integer;
begin
  offset := Grid.FixedRows;
  var GridMaxRowIx := Grid.RowCount - offset - 1;
  with PythonEngine do
    for var row := 0 to GridMaxRowIx do
    begin
      var PPyObj := EvalString(String.Format('%s[%d]', [Identifier, row]));
      Grid.Cells[colIx, offset + row] := PyObjectAsString(PPyObj);
    end;
end;

procedure TForm1.ExecFillPyListFromGrid(Identifier: string; Grid: TStringGrid;
  dims: Integer);
begin
  with PythonEngine do
  begin
    var Ndatarows := Grid.RowCount - Grid.FixedRows;
    PythonEngine.ExecString(String.Format('%s = [None]* %d',[Identifier, Ndatarows]));
    for var  row := 0 to Ndatarows - 1 do
    begin
      if dims = 1 then
      begin
        PythonEngine.ExecString(String.Format('%s[%d] = %s',[Identifier, row, Grid.Cells[0, row + 1]]));
        continue;
      end;

      var Ndatacolumns := Grid.ColCount;
      PythonEngine.ExecString(String.Format('%s_ = [None]* %d',[Identifier, Ndatacolumns]));
      for var col := 0 to Ndatacolumns - 1 do
        PythonEngine.ExecString(String.Format('%s_[%d] = %s',[Identifier, col, Grid.Cells[col, row + 1]]));

      PythonEngine.ExecString(String.Format('%s[%d] = %s_',[Identifier, row, Identifier]));
    end;
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

  StringGridXtrain.Cells[0, 0] := 'X';
  StringGridYtrain.Cells[0, 0] := 'Y';

  StringGridXtest.Cells[0, 0] := 'X';
  StringGridYTest.Cells[0, 0] := 'Y0';
  StringGridYTest.Cells[1, 0] := 'Ytest';
  StringGridYTest.Cells[2, 0] := 'error';
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


procedure TForm1.LoadDataToGrid(DataFilename: string; Delimiter: char; GridX, GridY: TStringGrid; SpinSamples, SpinFeatures: TSpinEdit);
begin
  //clear data
  GridX.RowCount := GridX.FixedRows;
  GridY.RowCount := GridY.FixedRows;

  var FileDataList := TStringList.Create;
  try
    var LineDataList := TStringList.Create;
    LineDataList.Delimiter := Delimiter;
    try
      FileDataList.LoadFromFile(DataFileName);
      GridX.ColCount := 0;

      GridX.RowCount := 1 + FileDataList.Count;
      GridX.FixedRows := 1;

      GridY.RowCount := 1 + FileDataList.Count;
      GridY.FixedRows := 1;

      for var Row := 0 to FileDataList.Count-1 do
      begin
        LineDataList.DelimitedText := FileDataList[Row];

        GridY.Cells[0, Row + 1] := LineDataList[0];

        var NLineFeatures := LineDataList.Count - 1;
        if NLineFeatures > GridX.ColCount then
          GridX.ColCount := NLineFeatures;

        for var Col := 0 to NLineFeatures - 1 do
            GridX.Cells[Col, Row + 1] := LineDataList[Col + 1]

      end;
      SpinFeatures.Text := IntToStr(GridX.ColCount);
      SpinSamples.Text := IntToStr(GridY.RowCount - 1);
    finally
      LineDataList.Free;
    end;
  finally
    FileDataList.Free;
  end;
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

procedure TForm1.ShowPlots;
begin
  var plottingScript := SynEditPlotting.Text;
  PythonEngine.ExecString(UTF8Encode(plottingScript));
end;

procedure TForm1.SpeedButtonLoadTestDataClick(Sender: TObject);
begin
  if not FileExists(LabeledEditTestDataFile.Text) then
    if  OpenTextFileDialogTestData.Execute() then
      LabeledEditTestDataFile.Text := OpenTextFileDialogTestData.FileName
    else
      Exit;

  LoadDataToGrid(LabeledEditTestDataFile.Text, TAB, StringGridXtest, StringGridYtest, SpinEditTestSamplesNumber, SpinEditTestFeaturesNumber);

end;

procedure TForm1.SpeedButtonLoadTrainDataClick(Sender: TObject);
begin
  if not FileExists(LabeledEditTrainDataFile.Text) then
    if  OpenTextFileDialogTrainingData.Execute() then
      LabeledEditTrainDataFile.Text := OpenTextFileDialogTrainingData.FileName
    else
      Exit;

  LoadDataToGrid(LabeledEditTrainDataFile.Text, TAB, StringGridXtrain, StringGridYtrain, SpinEditTrainSamplesNumber, SpinEditTrainFeaturesNumber);

end;

procedure TForm1.SpinEditTestSamplesNumberChange(Sender: TObject);
begin
  if StringGridYtest.RowCount = 1 + StrToInt(SpinEditTestSamplesNumber.Text) then
    Exit;

  ReshapeDataGrid(SpinEditTrainSamplesNumber, SpinEditTrainFeaturesNumber, StringGridXtrain, StringGridYtrain);
  LabeledEditTrainDataFile.Text := '';
end;

procedure TForm1.SpinEditTrainFeaturesNumberChange(Sender: TObject);
begin
  if StringGridXtrain.ColCount = StrToInt(SpinEditTrainFeaturesNumber.Text) then
    Exit;

  ReshapeDataGrid(SpinEditTrainSamplesNumber, SpinEditTrainFeaturesNumber, StringGridXtrain, StringGridYtrain);
  LabeledEditTrainDataFile.Text := '';
end;

procedure TForm1.SpinEditTrainSamplesNumberChange(Sender: TObject);
begin
  if StringGridYtrain.RowCount = 1 + StrToInt(SpinEditTrainSamplesNumber.Text) then
    Exit;

  ReshapeDataGrid(SpinEditTrainSamplesNumber, SpinEditTrainFeaturesNumber, StringGridXtrain, StringGridYtrain);
  LabeledEditTrainDataFile.Text := '';
end;

procedure TForm1.ReshapeDataGrid(SpEdNSamples, SpEdNFeatures: TSpinEdit; GridX,
  GridY: TStringGrid);
begin
  var NSamples := StrToInt(SpEdNSamples.Text);
  if SpEdNFeatures <> nil then
  begin
    var NFeatures := StrToInt(SpEdNFeatures.Text);
    GridX.ColCount := NFeatures + GridX.FixedCols;
  end;
  GridX.RowCount := Nsamples + GridX.FixedRows;
  GridY.RowCount := Nsamples + GridY.FixedRows;


  GridY.ColCount := 1 + GridY.FixedCols;
end;

procedure TForm1.RunTesting;
begin
  var testingScript := SynEditModelTesting.Text;
  PythonEngine.ExecString(UTF8Encode(testingScript));
end;

function TForm1.RunTrainingSession(): boolean;
begin
  var modelDefScript := SynEditModelDefinition.Text;
  PythonEngine.ExecString(modelDefScript);

  var trainingScript := SynEditModelTraining.Text;
  PythonEngine.ExecString(UTF8Encode(trainingScript));

  RESULT := not Self.Interruption;
end;

procedure TForm1.PythonEngineBeforeLoad(Sender: TObject);
begin
  PythonEngine.SetPythonHome('C:\ProgramData\Anaconda3\envs\p_38_idera');
end;

begin
  MaskFPUExceptions(True);
end.
