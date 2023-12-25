unit mainpage;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, s369;

type

  { TMainForm }

  TMainForm = class(TForm)
    Label1: TLabel;
    Results: TMemo;
    StartOperation: TButton;
    ShowPassword: TCheckBox;
    Password: TEdit;
    SelectOperation: TRadioGroup;
    SelectFile: TButton;
    SourceFile: TEdit;
    FileEncDecGroupBox: TGroupBox;
    OpenFile: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure SelectFileClick(Sender: TObject);
    procedure SelectOperationClick(Sender: TObject);
    procedure ShowPasswordChange(Sender: TObject);
    procedure StartOperationClick(Sender: TObject);
  private

  public

  end;

var
  Key: s369.TS369Data;
  MainForm: TMainForm;

implementation

uses
  S369Operations; // Non-global uses

{$R *.lfm}

{ TMainForm }

procedure TMainForm.SelectFileClick(Sender: TObject);
begin
  if OpenFile.Execute then
    SourceFile.Text := OpenFile.FileName;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin

end;

procedure TMainForm.SelectOperationClick(Sender: TObject);
begin
  SourceFile.Text := '';
  Password.Text := '';
end;

procedure TMainForm.ShowPasswordChange(Sender: TObject);
begin
  Password.PasswordChar := '*';
  if ShowPassword.Checked then
    Password.PasswordChar := #0;
end;

procedure TMainForm.StartOperationClick(Sender: TObject);
var
  i: byte;
  EncryptFileS369, DecryptFileS369: TFileEncryptionDecryption;
begin
  if not FileExists(SourceFile.Text) then
  begin
    Application.MessageBox('Source File Not Found!', 'Error');
    Exit;
  end;
  if Password.Text = '' then
  begin
    Application.MessageBox('Password Empty!', 'Error');
    Exit;
  end;
  for I := 0 to Length(Password.Text) - 1 do
    Key[I] := Byte(Password.Text[I+1]);
  if SelectOperation.ItemIndex = 0 then
    EncryptFileS369 := S369Operations.TFileEncryptionDecryption.DoProcess(SourceFile.Text,
                    SourceFile.Text + '.enc', S369Operations.ES369Operation.eEncryption,
                    Key, Length(Password.Text)-1)
  else
    DecryptFileS369 :=  S369Operations.TFileEncryptionDecryption.DoProcess(SourceFile.Text,
                    SourceFile.Text + '.dec', S369Operations.ES369Operation.eDecryption,
                    Key, Length(Password.Text)-1);
end;

end.

