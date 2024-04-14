unit ufMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  WrapDelphi, PythonEngine, FMX.PythonGUIInputOutput, FMX.Memo.Types,
  FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo, FMX.StdCtrls,
  WrapDelphiClasses, uHostAPI, VarPyth, FMX.ListBox;

type
  TfrmMain = class(TForm)
    moOutput: TMemo;
    btnRun: TButton;
    moInput: TMemo;
    btnClear: TButton;
    Label1: TLabel;
    Label2: TLabel;
    cboExamples: TComboBox;
    procedure btnClearClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure cboExamplesChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    PythonEngine : TPythonEngine;
    PythonInputOutput : TPythonGUIInputOutput;
    DelphiModule : TPythonModule;
    DelphiWrapper : TPyDelphiWrapper;
    host : THostAPI;
    procedure InitPython;
    procedure readJson;
  end;



var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

Uses IOUtils, StrUtils, math, uExamples, REST.Json;


procedure TfrmMain.btnRunClick(Sender: TObject);
begin
  GetPythonEngine.ExecString(moInput.text);
end;


// This reads a simple text file. Each entry starts with a single && string
// The following line contiains the title of the example and subsequent
// line contain the example code itself. There is no error checking,
// the file has to be error free for this to work.
procedure readExamples;
var ex : TArray<string>;
    i: integer;
    exampleName : string;
    exampleStr : string;
begin
  examples := TExamples.Create;
  ex := TFile.ReadAllLines(ExtractFileDir(ParamStr(0)) + '\\examples.txt');
  i := 0;
  while i < length (ex) - 1 do
      begin
      if ex[i] = '&&' then
         begin
         inc (i);
         exampleName := ex[i];
         exampleStr := '';
         inc (i);
         while ex[i] <> '&&'  do
               begin
               exampleStr := exampleStr + sLineBreak + ex[i];
               inc (i);
               if i = length (ex) then
                  break;
               end;
         examples.felements.Add(TExample.Create (exampleName, exampleStr));
         end;
      end;
end;


procedure TfrmMain.InitPython;
begin
  try
    PythonEngine := TPythonEngine.Create(nil);
    PythonEngine.Name := 'PythonEngine';
    PythonEngine.DllPath := ExtractFileDir(ParamStr(0)) + '\\Python';
    PythonEngine.DllName := 'python311.dll';
    PythonEngine.AutoLoad := False;
    PythonEngine.FatalAbort := True;
    PythonEngine.FatalMsgDlg := True;
    PythonEngine.UseLastKnownVersion := False;
    PythonEngine.AutoFinalize := True;
    PythonEngine.PyFlags := [pfInteractive];

    PythonInputOutput:=TPythonGUIInputOutput.Create(nil);
    PythonInputOutput.Output := moOutput;
    PythonEngine.IO := PythonInputOutput;

    DelphiModule := TPythonModule.Create(nil);
    DelphiModule.Name := 'DelphiModule';
    DelphiModule.Engine := PythonEngine;
    DelphiModule.ModuleName := 'app';

    DelphiWrapper := TPyDelphiWrapper.Create(nil);
    DelphiWrapper.Name := 'pyWrapper';
    DelphiWrapper.Engine := PythonEngine;
    DelphiWrapper.Module := DelphiModule;

    PythonEngine.LoadDll;
  except
    on e:exception do
      raise Exception.Create('Error creating python components: ' + e.Message);
  end;
end;


procedure TfrmMain.btnClearClick(Sender: TObject);
begin
  moOutput.lines.Clear;
end;


// Read examples as a json file
// This works but editing the json file to add more
// examples turns out not to be very convenient so
// I created a simple text file to hold the examples
procedure TfrmMain.readJson;
var  jsonString: string;
     i : integer;
begin
  jsonString := TFile.ReadAllText('examples.json');
  examples := TJson.JsonToObject<TExamples>(jsonString);

  cboExamples.Clear;
  for i := 0 to examples.elements.Count - 1 do
      cboExamples.items.AddObject(examples.elements.Items[i].name, examples.elements.items[i]);

  cboExamples.ItemIndex := 0;
  moInput.Text := (cboExamples.items.Objects[cboExamples.ItemIndex] as TExample).exampleStr;
end;


procedure TfrmMain.cboExamplesChange(Sender: TObject);
begin
   moInput.Text := (cboExamples.items.Objects[cboExamples.ItemIndex] as TExample).exampleStr;
end;


procedure TfrmMain.FormCreate(Sender: TObject);
var i : integer;
    ex : TExample;
begin
 InitPython;

 host := THostAPI.Create ();
 DelphiWrapper.RegisterDelphiWrapper(TPyClassWrapper<THostAPI>).Initialize;
 DelphiWrapper.DefineVar('host', host);

 readExamples;

 for i := 0 to examples.felements.Count - 1 do
     cboExamples.items.AddObject(examples.felements.Items[i].fname, examples.elements.items[i]);

 cboExamples.ItemIndex := 0;
 ex := cboExamples.items.Objects[cboExamples.ItemIndex] as TExample;
 moInput.Text := ex.exampleStr;
end;

end.
