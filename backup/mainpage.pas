unit mainpage;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, s369;

type

  { TMainForm }

  TMainForm = class(TForm)
    StartOperation: TButton;
    ShowPassword: TCheckBox;
    Password: TEdit;
    SelectOperation: TRadioGroup;
    SelectFile: TButton;
    SourceFile: TEdit;
    FileEncDecGroupBox: TGroupBox;
    OpenFile: TOpenDialog;
    procedure SelectFileClick(Sender: TObject);
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

procedure TMainForm.ShowPasswordChange(Sender: TObject);
begin
  Password.PasswordChar := '*';
  if ShowPassword.Checked then
    Password.PasswordChar := #0;
end;

procedure TMainForm.StartOperationClick(Sender: TObject);
var
  i: byte;
  EncryptFileS369, DecryptFileS369: S369Operations.TFileEncryptionDecryption;
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
  for i := 0 to Length(Password.Text) do
    Key[i] := Byte(Password.Text[i+1]);
  if SelectOperation.ItemIndex = 0 then
  begin
    EncryptFileS369 := S369Operations.TFileEncryptionDecryption.Initalize(SourceFile.Text, SourceFile.Text + '.enc', S369Operations.ES369Operation.eEncryption, Key, Length(Password.Text)-1);
    EncryptFileS369.Execute();
  end
  else
  begin
    DecryptFileS369 :=  S369Operations.TFileEncryptionDecryption.Initalize(SourceFile.Text, SourceFile.Text + '.dec', S369Operations.ES369Operation.eDecryption, Key, Length(Password.Text)-1);
    DecryptFileS369.Execute();
  end;
end;

end.

