object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'JuPy4Delphi with Training Monitoring Demo'
  ClientHeight = 599
  ClientWidth = 942
  Color = clBtnFace
  CustomTitleBar.CaptionAlignment = taCenter
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 0
    Width = 942
    Height = 3
    Cursor = crVSplit
    Align = alTop
    ResizeStyle = rsUpdate
    ExplicitTop = 201
    ExplicitWidth = 383
  end
  object Panel2: TPanel
    Left = 0
    Top = 400
    Width = 942
    Height = 199
    Align = alBottom
    TabOrder = 1
    object HeaderControl2: THeaderControl
      Left = 1
      Top = 1
      Width = 940
      Height = 23
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      Sections = <
        item
          Alignment = taCenter
          AutoSize = True
          ImageIndex = -1
          Text = 'Python Output'
          Width = 940
        end>
      ParentFont = False
    end
    object mePythonOutput: TMemo
      Left = 1
      Top = 27
      Width = 940
      Height = 171
      Align = alBottom
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Consolas'
      Font.Style = []
      ParentFont = False
      TabOrder = 1
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 3
    Width = 942
    Height = 391
    Align = alTop
    ParentBackground = False
    ParentColor = True
    TabOrder = 0
    object PageControl1: TPageControl
      Left = 1
      Top = 26
      Width = 940
      Height = 364
      ActivePage = TabSheetJupyter
      Align = alClient
      TabOrder = 0
      object TabSheetJupyter: TTabSheet
        Caption = 'Jupyter  '
        object sePythonCode: TSynEdit
          Left = 0
          Top = 48
          Width = 932
          Height = 257
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Consolas'
          Font.Style = []
          Font.Quality = fqClearTypeNatural
          TabOrder = 0
          UseCodeFolding = False
          Gutter.Font.Charset = DEFAULT_CHARSET
          Gutter.Font.Color = clWindowText
          Gutter.Font.Height = -11
          Gutter.Font.Name = 'Consolas'
          Gutter.Font.Style = []
          Highlighter = SynPythonSyn
          Lines.Strings = (
            '# -*- coding: utf-8 -*-'
            '"""'
            'Created on Sat Feb  5 10:32:58 2022'
            ''
            '@author: KoRiF'
            '"""'
            
              '#https://stackoverflow.com/questions/54475896/interact-with-jupy' +
              'ter-notebooks-via-api'
            'import json'
            'import requests'
            'import datetime'
            'import uuid'
            '#from pprint import pprint'
            
              'from websocket import create_connection #https://pypi.org/projec' +
              't/websocket-client/'
            'import socket'
            ''
            #39#39#39'{'
            '"""%'
            '}'#39#39#39
            'from delphi_module import delphi_form'
            ''
            'notebook_path = delphi_form.jupyFilepath'
            'base = delphi_form.jupySocket #'#39'http://localhost:8888'#39
            'token = delphi_form.jupyToken'
            ''
            #39#39#39'{'
            '%"""'
            '}'#39#39#39
            ''
            ''
            #39#39#39'$'
            '# The token is written on stdout when you start the notebook'
            'notebook_path = '#39'/Untitled.ipynb'#39
            'base = '#39'http://localhost:8888'#39'#'#39'http://localhost:9999'#39
            'token = '#39'67383dec0de54d40908840a56d6589be26a2d28d5abd22b6'#39
            '$'#39#39#39
            ''
            'headers = {'#39'Authorization'#39': '#39'Token '#39' + token}'
            'url = base + '#39'/api/kernels'#39' #'
            'response = requests.post(url,headers=headers)'
            
              'kernel = json.loads(response.text) # get kernel info as json her' +
              'e'
            ''
            '# Load the notebook and get the code of each cell'
            'url = base + '#39'/api/contents'#39' + notebook_path'
            'response = requests.get(url,headers=headers)'
            
              'file = json.loads(response.text) #get notebook content as json h' +
              'ere'
            'filecontent = file['#39'content'#39']'
            'print(filecontent['#39'cells'#39'])'
            
              'code = [ c['#39'source'#39'] for c in file['#39'content'#39']['#39'cells'#39'] if len(c[' +
              #39'source'#39'])>0 ] # get the list of code text blocks'
            ''
            ''
            ''
            ''
            '# Execution request/reply is done on websockets channels'
            '##ws = socket.socket(socket.AF_INET, socket.SOCK_STREAM)'
            
              'ws = create_connection("ws://localhost:8888/api/kernels/"+kernel' +
              '["id"]+"/channels",'
            '     header=headers)'
            ''
            '#ws.connect(("localhost", 8888))'
            ''
            
              'def send_execute_request(code): # do not send anything really, j' +
              'ust create properly formatted request'
            '    msg_type = '#39'execute_request'#39';'
            '    content = { '#39'code'#39' : code, '#39'silent'#39':False }'
            '    hdr = { '#39'msg_id'#39' : uuid.uuid1().hex,'
            '        '#39'username'#39': '#39'test'#39','
            '        '#39'session'#39': uuid.uuid1().hex,'
            '        '#39'data'#39': datetime.datetime.now().isoformat(),'
            '        '#39'msg_type'#39': msg_type,'
            '        '#39'version'#39' : '#39'5.0'#39' }'
            '    msg = { '#39'header'#39': hdr, '#39'parent_header'#39': hdr,'
            '        '#39'metadata'#39': {},'
            '        '#39'content'#39': content }'
            '    return msg'
            ''
            'for piece in code:  # execute the codes cell by cell'
            '    delphi_form.addJupyCellCode(piece)'
            '    '#39#39#39'$'
            '    ws.send(json.dumps(send_execute_request(piece)))'
            '    $'#39#39#39
            ''
            #39#39#39'$'
            
              '# We ignore all the other messages, we just get the code executi' +
              'on output'
            
              '# (this needs to be improved for production to take into account' +
              ' errors, large cell output, images, etc.)'
            'for i in range(0, len(code)):'
            '    msg_type = '#39#39';'
            '    while msg_type != "stream":'
            '        rsp = json.loads(ws.recv())'
            '        msg_type = rsp["msg_type"]'
            '    print(rsp["content"]["text"])'
            ''
            'ws.close()'
            '$'#39#39#39)
        end
        object btnRun: TButton
          Left = 0
          Top = 308
          Width = 170
          Height = 25
          Align = alCustom
          Caption = 'Run Attach Jupyter '
          TabOrder = 1
          OnClick = btnRunClick
        end
        object LabeledEditJupyFilePath: TLabeledEdit
          Left = 224
          Top = 21
          Width = 233
          Height = 21
          EditLabel.Width = 125
          EditLabel.Height = 13
          EditLabel.Caption = 'Jupyter Notebook filepath'
          TabOrder = 2
          Text = '/AnacondaProjects/DelphiTrainingMonitorNotebook.ipynb'
        end
        object CheckBoxStripCellCode: TCheckBox
          Left = 192
          Top = 311
          Width = 185
          Height = 17
          Caption = 'Strip Cell Delphi Interaction Code'
          Checked = True
          State = cbChecked
          TabOrder = 3
        end
        object ComboBoxJuPyToken: TComboBox
          Left = 3
          Top = 21
          Width = 198
          Height = 21
          TabOrder = 4
          Text = '<Enter Notebook Token here ...>'
          OnDropDown = ComboBoxJuPyTokenDropDown
        end
      end
      object TabSheetDataDefinitions: TTabSheet
        Caption = 'Data'
        ImageIndex = 1
        object SpeedButtonLoadTrainData: TSpeedButton
          Left = 279
          Top = 13
          Width = 18
          Height = 21
          OnClick = SpeedButtonLoadTrainDataClick
        end
        object SynEditDataDefinition: TSynEdit
          Left = 312
          Top = 0
          Width = 617
          Height = 313
          Align = alCustom
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Consolas'
          Font.Style = []
          Font.Quality = fqClearTypeNatural
          TabOrder = 0
          UseCodeFolding = False
          Gutter.Font.Charset = DEFAULT_CHARSET
          Gutter.Font.Color = clWindowText
          Gutter.Font.Height = -11
          Gutter.Font.Name = 'Consolas'
          Gutter.Font.Style = []
          Highlighter = SynPythonSyn
        end
        object StringGridXtrain: TStringGrid
          Left = 48
          Top = 40
          Width = 174
          Height = 197
          ColCount = 11
          DefaultColWidth = 32
          DefaultRowHeight = 16
          RowCount = 10
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goFixedRowDefAlign]
          TabOrder = 1
          RowHeights = (
            16
            16
            16
            16
            16
            16
            16
            16
            16
            16)
        end
        object StringGridYtrain: TStringGrid
          Left = 217
          Top = 40
          Width = 89
          Height = 197
          ColCount = 1
          DefaultColWidth = 32
          DefaultRowHeight = 16
          FixedCols = 0
          RowCount = 10
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing, goFixedRowDefAlign]
          TabOrder = 2
          RowHeights = (
            16
            16
            16
            16
            16
            15
            16
            16
            16
            16)
        end
        object SpinEditTrainSamplesNumber: TSpinEdit
          Left = 1
          Top = 40
          Width = 41
          Height = 22
          MaxValue = 0
          MinValue = 0
          TabOrder = 3
          Value = 0
          OnChange = SpinEditTrainSamplesNumberChange
        end
        object SpinEditTrainFeaturesNumber: TSpinEdit
          Left = 48
          Top = 12
          Width = 33
          Height = 22
          MaxValue = 0
          MinValue = 0
          TabOrder = 4
          Value = 0
          OnChange = SpinEditTrainFeaturesNumberChange
        end
        object LabeledEditTrainDataFile: TLabeledEdit
          Left = 87
          Top = 13
          Width = 194
          Height = 21
          EditLabel.Width = 69
          EditLabel.Height = 13
          EditLabel.Caption = 'Train Data File'
          TabOrder = 5
          Text = ''
        end
        object ButtonPassTrainData: TButton
          Left = 144
          Top = 299
          Width = 153
          Height = 25
          Caption = 'Pass Data To Python Script'
          TabOrder = 6
          OnClick = ButtonPassTrainDataClick
        end
      end
      object TabSheetModelDefinition: TTabSheet
        Caption = 'Model'
        ImageIndex = 2
        object SynEditModelDefinition: TSynEdit
          Left = 8
          Top = 8
          Width = 911
          Height = 313
          Align = alCustom
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Consolas'
          Font.Style = []
          Font.Quality = fqClearTypeNatural
          TabOrder = 0
          UseCodeFolding = False
          Gutter.Font.Charset = DEFAULT_CHARSET
          Gutter.Font.Color = clWindowText
          Gutter.Font.Height = -11
          Gutter.Font.Name = 'Consolas'
          Gutter.Font.Style = []
          Highlighter = SynPythonSyn
        end
      end
      object TabSheetModelTraining: TTabSheet
        Caption = 'Training'
        ImageIndex = 3
        object SynEditModelTraining: TSynEdit
          Left = 0
          Top = 0
          Width = 908
          Height = 212
          Align = alCustom
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Consolas'
          Font.Style = []
          Font.Quality = fqClearTypeNatural
          TabOrder = 0
          UseCodeFolding = False
          Gutter.Font.Charset = DEFAULT_CHARSET
          Gutter.Font.Color = clWindowText
          Gutter.Font.Height = -11
          Gutter.Font.Name = 'Consolas'
          Gutter.Font.Style = []
          Highlighter = SynPythonSyn
        end
        object ButtonRunTraining: TButton
          Left = 0
          Top = 308
          Width = 75
          Height = 25
          Caption = 'Train'
          TabOrder = 1
          OnClick = ButtonRunTrainingClick
        end
      end
      object TabSheetMonitoring: TTabSheet
        Caption = 'Monitoring'
        ImageIndex = 4
        object Chart1: TChart
          Left = 0
          Top = 5
          Width = 932
          Height = 297
          Legend.Alignment = laLeft
          Legend.CheckBoxes = True
          Legend.Title.Text.Strings = (
            'Metrics')
          Legend.VertSpacing = 28
          Title.Text.Strings = (
            'TChart')
          Title.Visible = False
          Chart3DPercent = 5
          View3D = False
          Align = alCustom
          TabOrder = 0
          DefaultCanvas = 'TGDIPlusCanvas'
          PrintMargins = (
            15
            37
            15
            37)
          ColorPaletteIndex = 13
        end
        object ButtonInterrupt: TButton
          Left = 854
          Top = 308
          Width = 75
          Height = 25
          Caption = 'Interrupt'
          TabOrder = 1
          OnClick = ButtonInterruptClick
        end
      end
      object TabSheetModelTesting: TTabSheet
        Caption = 'Testing'
        ImageIndex = 5
        object SpeedButtonLoadTestData: TSpeedButton
          Left = 287
          Top = 21
          Width = 18
          Height = 21
          OnClick = SpeedButtonLoadTestDataClick
        end
        object SynEditModelTesting: TSynEdit
          Left = 328
          Top = 5
          Width = 607
          Height = 297
          Align = alCustom
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Consolas'
          Font.Style = []
          Font.Quality = fqClearTypeNatural
          TabOrder = 0
          UseCodeFolding = False
          Gutter.Font.Charset = DEFAULT_CHARSET
          Gutter.Font.Color = clWindowText
          Gutter.Font.Height = -11
          Gutter.Font.Name = 'Consolas'
          Gutter.Font.Style = []
          Highlighter = SynPythonSyn
        end
        object ButtonTestModel: TButton
          Left = 816
          Top = 308
          Width = 95
          Height = 25
          Caption = 'Test'
          TabOrder = 1
          OnClick = ButtonTestModelClick
        end
        object StringGridXtest: TStringGrid
          Left = 56
          Top = 48
          Width = 174
          Height = 197
          ColCount = 11
          DefaultColWidth = 32
          DefaultRowHeight = 16
          RowCount = 10
          TabOrder = 2
          RowHeights = (
            16
            16
            16
            16
            16
            16
            16
            16
            16
            16)
        end
        object StringGridYtest: TStringGrid
          Left = 225
          Top = 48
          Width = 89
          Height = 197
          ColCount = 2
          DefaultColWidth = 32
          DefaultRowHeight = 16
          RowCount = 10
          TabOrder = 3
          RowHeights = (
            16
            16
            16
            16
            16
            15
            16
            16
            16
            16)
        end
        object SpinEditTestSamplesNumber: TSpinEdit
          Left = 9
          Top = 48
          Width = 41
          Height = 22
          MaxValue = 0
          MinValue = 0
          TabOrder = 4
          Value = 0
          OnChange = SpinEditTestSamplesNumberChange
        end
        object LabeledEditTestDataFile: TLabeledEdit
          Left = 95
          Top = 21
          Width = 194
          Height = 21
          EditLabel.Width = 66
          EditLabel.Height = 13
          EditLabel.Caption = 'Test Data File'
          TabOrder = 5
          Text = ''
        end
        object SpinEditTestFeaturesNumber: TSpinEdit
          Left = 56
          Top = 20
          Width = 33
          Height = 22
          MaxValue = 0
          MinValue = 0
          TabOrder = 6
          Value = 0
          OnChange = SpinEditTrainFeaturesNumberChange
        end
      end
    end
    object HeaderControl1: THeaderControl
      Left = 1
      Top = 1
      Width = 940
      Height = 25
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      Sections = <
        item
          Alignment = taCenter
          AutoSize = True
          ImageIndex = -1
          Text = 'Python Source code'
          Width = 940
        end>
      ParentFont = False
    end
  end
  object SynPythonSyn: TSynPythonSyn
    Options.AutoDetectEnabled = False
    Options.AutoDetectLineLimit = 0
    Options.Visible = False
    Left = 760
    Top = 32
  end
  object SynEditPythonBehaviour: TSynEditPythonBehaviour
    Editor = sePythonCode
    Left = 760
    Top = 80
  end
  object PythonEngine: TPythonEngine
    DllPath = 'c:\ProgramData\Anaconda3\envs\p_38_idera'
    OnBeforeLoad = PythonEngineBeforeLoad
    IO = PythonGUIInputOutput
    Left = 880
    Top = 32
  end
  object PythonGUIInputOutput: TPythonGUIInputOutput
    UnicodeIO = True
    RawOutput = False
    Output = mePythonOutput
    Left = 880
    Top = 80
  end
  object PythonModule1: TPythonModule
    Engine = PythonEngine
    ModuleName = 'delphi_module'
    Errors = <>
    Left = 757
    Top = 149
  end
  object PyDelphiWrapper1: TPyDelphiWrapper
    Engine = PythonEngine
    Left = 877
    Top = 149
  end
  object OpenTextFileDialogTrainingData: TOpenTextFileDialog
    Filter = 'Tab separated values|*.tsv'
    Title = 'Open Training Data'
    Left = 253
    Top = 61
  end
  object FDGUIxAsyncExecuteDialog1: TFDGUIxAsyncExecuteDialog
    Provider = 'Forms'
    Left = 768
    Top = 96
  end
  object OpenTextFileDialog_CallbackScript: TOpenTextFileDialog
    DefaultExt = 'py'
    Title = 'Open Callback Definition Script'
    Left = 253
    Top = 357
  end
  object OpenTextFileDialogTestData: TOpenTextFileDialog
    Filter = 'Tab separated values|*.tsv'
    Title = 'Open Training Data'
    Left = 261
    Top = 69
  end
end
