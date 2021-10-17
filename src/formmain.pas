unit formmain;

{$mode objfpc}{$H+}

{ APITester v 0.1.

  Made in 2021 by P Bjørn Biermann Madsen

  APITester is based on RPCTester made by NosoCoin Project.

  This is free and unencumbered software released into the public domain.

  Anyone is free to copy, modify, publish, use, compile, sell, or
  distribute this software, either in source code form or as a compiled
  binary, for any purpose, commercial or non-commercial, and by any
  means.

  In jurisdictions that recognize copyright laws, the author or authors
  of this software dedicate any and all copyright interest in the
  software to the public domain. We make this dedication for the benefit
  of the public at large and to the detriment of our heirs and
  successors. We intend this dedication to be an overt act of
  relinquishment in perpetuity of all present and future rights to this
  software under copyright law.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
  IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
  OTHER DEALINGS IN THE SOFTWARE.

  For more information, please refer to <http://unlicense.org/>
  }

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Strutils, fpjson, opensslsockets, fphttpclient;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    btnSend: TButton;
    cbMethod: TComboBox;
    CheckBox1: TCheckBox;
    edtServerAddress: TEdit;
    edtParams: TEdit;
    gbServer: TGroupBox;
    gbMethod: TGroupBox;
    gbParams: TGroupBox;
    lblHelp: TLabel;
    memHelp: TMemo;
    memLog: TMemo;
    panControlHelp: TPanel;
    panHelp: TPanel;
    panControl: TPanel;
    procedure btnSendClick(Sender: TObject);
    procedure cbMethodChange(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure ClearInputs;
    procedure DisplayHelp;
    function FPHTTPSimpleGet(URL: string): string;
  public

  end;

var
  frmMain: TfrmMain;

const
  cDefaultServerAddress = 'explorer.nosocoin.com';
  cVersion = '0.1';

resourcestring
  rsFormCaption = 'Noso API Tester';
  rsTextHintParams = 'Params';
  rsMethodMainNet =
    'Method MainNet returns: lastblock, lastblockhash, headershash, '+
    'summaryhash, pending, supply.' + #13#13 +
    'Parameter: -';
  rsMethodBlock =
    'Method Block returns: number, timestart, timeend, timetotal, last20, '+
    'totaltransactions, difficulty, target, solution, lastblockhash, '+
    'nextdifficulty, miner, feespayed, reward of the specified block.' + #13#13 +
    'Parameter: Block Number';
  rsMethodBlockOrders =
    'Method BlockOrders returns: a list of the orders on the specified block.' + #13#13 +
    'Parameter: Block Number';
  rsMethodOrder =
    'Method Order returns: timestamp, block, receiver, amount, reference of '+
    'the specified order.' + #13#13 +
    'Parameters: Order ID' ;
  rsMethodAddress =
    'Method Address returns: balance,incoming,outgoing of the specified'+
    ' addresses.' + #13#13 +
    'Parameter: Address' ;

implementation

{$R *.lfm}

{ TfrmMain }

function TfrmMain.FPHTTPSimpleGet(URL: string): string;
begin
  Result := '';
  With TFPHttpClient.Create(Nil) do
  try
    try
      Result := Get(URL);
    except
      on E: Exception do
        Result := 'Error: ' + E.Message;
    end;
  finally
    Free;
  end;
end;

// change method combobox
procedure TfrmMain.cbMethodChange(Sender: TObject);
Begin
ClearInputs;
case cbMethod.ItemIndex of
  0:begin  // mainnet
    end;
  1:begin  // block
    edtParams.Visible:= True;
    end;
  2:begin  // blockorders
    edtParams.Visible:= True;
    end;
  3:begin  // order
    edtParams.Visible:= True;
    end;
  4:begin  // address
    edtParams.Visible:= True;
    end;
end;
DisplayHelp;
End;

procedure TfrmMain.CheckBox1Change(Sender: TObject);
begin
  if CheckBox1.Checked then  edtServerAddress.Text := 'nosoexplorer.yz317.com'
  else edtServerAddress.Text := 'explorer.nosocoin.com';
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  Caption:= rsFormCaption + ' v' + cVersion;
  edtServerAddress.Text:= cDefaultServerAddress;
  cbMethod.ItemIndex:= 0;
  ClearInputs;
  DisplayHelp;
end;

procedure TfrmMain.ClearInputs;
begin
  edtParams.Visible:= False;
  edtParams.Text:= '';
  edtParams.TextHint:= rsTextHintParams;
end;

procedure TfrmMain.DisplayHelp;
Begin
case cbMethod.ItemIndex of
  0:begin
    memHelp.Text:= rsMethodMainNet;
    end;
  1:begin
    memHelp.Text:= rsMethodBlock;
    end;
  2:begin
    memHelp.Text:= rsMethodBlockOrders;
    end;
  3:begin
    memHelp.Text:= rsMethodOrder;
    end;
  4:begin
    memHelp.Text:= rsMethodAddress;
    end;
end;
End;

// SEND REQUEST
procedure TfrmMain.btnSendClick(Sender: TObject);
var
  r: String = '';
  s: String = '';
begin
  memLog.Lines.Clear;
  s := LowerCase(DelSpace(cbMethod.Items[cbMethod.ItemIndex]));
  if edtParams.Text <> '' then s:=s + '/' + DelSpace(edtParams.Text);
  memLog.Lines.Add('https://' + edtServerAddress.Text + '/api/v1/' + s + '.json');

  r := FPHTTPSimpleGet('https://' + edtServerAddress.Text + '/api/v1/' + s + '.json');

  memLog.Lines.Add('');
  memLog.Lines.Add(r);
End;

END.
