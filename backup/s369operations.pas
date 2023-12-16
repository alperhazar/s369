unit S369Operations;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, s369, mainpage;

type

  REncryptedFileHeader = record
    RawFileHash: TS369Data;
    FileEncryptionHash: TS369Data;
    RawFileLength: Int64;
  end;

  ES369Operation = (eEncryption, eDecryption);

  { TFileEncryptionDecryption }

  TFileEncryptionDecryption = class(TThread)
    protected
      FS369: TS369;
      FKey: S369.TS369Data;
      FKeyLength: Byte;
      FOperation: ES369Operation;
      FEncryptedFileHeader: REncryptedFileHeader;
      FSourceFileName, FDestinationFileName: string;
      FEncryptedFileHeaderFile: file of REncryptedFileHeader;
      FFileReader, FFileWriter: TFileStream;
      FFileSize: Int64;
      procedure Execute(); override;
      function CalculateFileHash(): TS369Data;
      function CalculateEncryptionHash(): TS369Data;
    public
      constructor Initalize(SourceFileName, DestinationFileName: string;
        Operation: ES369Operation; Key: S369.TS369Data; KeyLength: Byte);
  end;

implementation

{ TFileEncryptionDecryption }

procedure TFileEncryptionDecryption.Execute;
var
  I: Int64;
  J: Integer;
  K: Byte;
  Buf, Buf2: TS369Data;
begin
  mainpage.MainForm.StartOperation.Enabled := False;
  mainpage.MainForm.Refresh;
  mainpage.MainForm.SelectOperation.Caption := 'Please wait...';
  FillChar(Buf, SizeOf(Buf), 0);
  FillChar(Buf2, SizeOf(Buf2), 0);
  case FOperation of
    ES369Operation.eEncryption: begin
      FFileReader := TFileStream.Create(FSourceFileName, fmOpenRead);
      FFileSize := FFileReader.Size;
      FFileReader.Free;
      with FEncryptedFileHeader do
      begin
        RawFileLength := FFileSize;
        RawFileHash := Self.CalculateFileHash();
        FileEncryptionHash := Self.CalculateEncryptionHash();
      end;
      AssignFile(FEncryptedFileHeaderFile, FDestinationFileName);
      Rewrite(FEncryptedFileHeaderFile);
      Write(FEncryptedFileHeaderFile, FEncryptedFileHeader);
      CloseFile(FEncryptedFileHeaderFile);
      FFileWriter := TFileStream.Create(FDestinationFileName, fmOpenReadWrite);
      FFileWriter.Position := SizeOf(REncryptedFileHeader);
      FFileReader := TFileStream.Create(FSourceFileName, fmOpenRead);
      I := FFileSize;
      while I > 0 do
      begin
        J := FFileReader.Read(Buf, SizeOf(Buf));
        if J > 0 then
        begin
          FS369.Encrypt(Buf2);
          for K := 0 to s369.S369BSize do
            Buf[K] := Buf[K] xor Buf2[K];
          FFileWriter.Write(Buf, SizeOf(Buf));
          I := I - J;
        end;
      end;
      FFileWriter.Free;
      FFileReader.Free;
    end;
    ES369Operation.eDecryption: begin
      AssignFile(FEncryptedFileHeaderFile, FSourceFileName);
      Reset(FEncryptedFileHeaderFile);
      Read(FEncryptedFileHeaderFile, FEncryptedFileHeader);
      CloseFile(FEncryptedFileHeaderFile);
      for K := 0 to SizeOf(FEncryptedFileHeader.FileEncryptionHash)-1 do
        if FEncryptedFileHeader.FileEncryptionHash[K] <> Self.CalculateEncryptionHash()[K] then
      FFileReader := TFileStream.Create(FSourceFileName, fmOpenRead);
      FFileSize := FEncryptedFileHeader.RawFileLength;
      FFileWriter := TFileStream.Create(FDestinationFileName, fmCreate);
      FFileReader.Position := SizeOf(FEncryptedFileHeader);
      I := FFileSize;
      while I > 0 do
      begin
        J := FFileReader.Read(Buf, SizeOf(Buf));
        if J > 0 then
        begin
          FS369.Encrypt(Buf2);
          for K := 0 to s369.S369BSize do
            Buf[K] := Buf[K] xor Buf2[K];
          FFileWriter.Write(Buf, SizeOf(Buf));
          I := I - J;
        end;
      end;
      FFileWriter.Size := FFileSize;
      FFileWriter.Free;
      FFileReader.Free;
    end;
  end;
  mainpage.MainForm.Refresh;
  mainpage.MainForm.SelectOperation.Caption := 'Start Operation';
  mainpage.MainForm.StartOperation.Enabled := True;
  Self.Destroy;
end;

function TFileEncryptionDecryption.CalculateFileHash():
  TS369Data;
var
  I: Int64;
  J: Integer;
  K: Byte;
  F: TFileStream;
  Buf, Buf2: TS369Data;
  S: TS369;
begin
  F := TFileStream.Create(FSourceFileName, fmOpenRead);
  I := F.Size;
  FillChar(Buf, SizeOf(Buf), 0);
  FillChar(Buf2, SizeOf(Buf2), 0);
  S := TS369.Initalize(Buf, SizeOf(Buf) - 1);
  while I > 0 do
  begin
    J := F.Read(Buf, SizeOf(Buf));
    if J > 0 then
    begin
      for K := 0 to SizeOf(Buf2) - 1 do
        Buf[K] := Buf[K] xor Buf2[K];
      S.Encrypt(Buf);
      Buf2 := Buf;
      I := I - J;
    end;
  end;
  Result := Buf;
  F.Destroy;
  S.Destroy;
end;

function TFileEncryptionDecryption.CalculateEncryptionHash: TS369Data;
var
  S: TS369;
  Buf, Buf2: TS369Data;
begin
  Buf := FKey;
  S := TS369.Initalize(Buf, FKeyLength);
  FillChar(Buf2, SizeOf(Buf2), 0);
  S.Encrypt(Buf2);
  Result := Buf2;
  S.Destroy;
end;

constructor TFileEncryptionDecryption.Initalize(SourceFileName,
  DestinationFileName: string; Operation: ES369Operation; Key: S369.TS369Data;
  KeyLength: Byte);
var
  Buf: TS369Data;
begin
  inherited Create(False);
  FillChar(Buf, SizeOf(Buf), 0);
  FSourceFileName := SourceFileName;
  FDestinationFileName := DestinationFileName;
  FOperation := Operation;
  FKey := Key;
  FKeyLength := KeyLength;
  FS369 := TS369.Initalize(FKey, FKeyLength);
  if FileExists(FDestinationFileName) then
    raise Exception.Create('Destination file already exists!');
end;

end.
