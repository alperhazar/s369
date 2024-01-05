unit s369;

interface

const
  S369BSize = $FF;
  RCount = $11;
  Sx: array [$0..$F] of Byte = ($4 ,$A ,$9 ,$2 ,$D ,$8 ,$0 ,$E ,$6 ,$B ,$1 ,$C ,$7 ,$F ,$5 ,$3);
  Sy: array [$0..$F] of Byte = ($1 ,$7 ,$E ,$D ,$0 ,$5 ,$8 ,$3 ,$4 ,$F ,$A ,$6 ,$9 ,$C ,$B ,$2);

type
  TS369Data = array [$00..S369BSize] of Byte;
  TS369 = class
    private
      SBox, RSBox, IV: TS369Data;
      RKeys: array [$00..RCount] of TS369Data;
    public
      constructor Initalize(Key: TS369Data; KeyLength: Byte);
      procedure Encrypt(var Data: TS369Data);
      procedure Decrypt(var Data: TS369Data);
  end;

implementation

constructor TS369.Initalize(Key: TS369Data; KeyLength: Byte);
var
  I, J, A, B: Byte;
begin
  for I := $00 to S369BSize do
    SBox[I] := I;
  IV := SBox;
  for I := $00 to KeyLength do
    IV[I] := not (IV[I] xor Key[I]);
  for I := $00 to S369BSize do
  begin
    for J := $00 to S369BSize - $01 do
      IV[J+$01] := IV[J] xor ((((Sx[IV[J+$01] shr $04] + Sx[IV[J+$01] and $0F]) mod $10) shl $04) or ((Sy[IV[J+$01] shr $04] + Sy[IV[J+$01] and $0F]) mod $10));
    IV[$00] := IV[S369BSize] xor ((((Sy[IV[$00] shr $04] + Sy[IV[$00] and $0F]) mod $10) shl $04) or ((Sx[IV[$00] shr $04] + Sx[IV[$00] and $0F]) mod $10));
  end;
  for I := $00 to RCount do
  begin
    for J := $00 to S369BSize - $01 do
      IV[J+$01] := IV[J] xor IV[J+$01];
    IV[$00] := IV[S369BSize] xor IV[$00];
    RKeys[I] := IV;
  end;
  for I := $00 to RCount - $01 do
  begin
    for J := $00 to S369BSize do
    begin
      A := SBox[RKeys[I][J]];
      B := SBox[RKeys[I+$01][J]];
      SBox[RKeys[I][J]] := B;
      SBox[RKeys[I+$01][J]] := A;
    end;
  end;
  for I := $00 to RCount do
    for J := $00 to S369BSize do
      RKeys[I][J] := SBox[RKeys[I][J]];
  for I := $00 to S369BSize do
    RSBox[SBox[I]] := I;
end;

procedure TS369.Encrypt(var Data: TS369Data);
var
  I, J, A, B: Byte;
begin
  for I := $00 to RCount do
  begin
    for J := $00 to S369BSize do
      Data[J] := SBox[Data[J] xor RKeys[I][J]];
    for J := $00 to S369BSize - $01 do
    begin
      A := Data[RKeys[I][J]];
      B := Data[RKeys[I][J+$01]];
      Data[RKeys[I][J]] := (((A and $0F)) shl $04) or (B shr $04);
      Data[RKeys[I][J+$01]] := (((B and $0F)) shl $04) or (A shr $04);
      Data[RKeys[I][J]] := ((Data[RKeys[I][J]] and $01) shl $07) or (Data[RKeys[I][J]] shr $01);
      Data[RKeys[I][J+$01]] := ((Data[RKeys[I][J+$01]] and $01) shl $07) or (Data[RKeys[I][J+$01]] shr $01);
    end;
  end;
  for I := $00 to S369BSize do
    Data[I] := SBox[Data[I]];
end;

procedure TS369.Decrypt(var Data: TS369Data);
var
  I, J, A, B: Byte;
begin
  for I := $00 to S369BSize do
    Data[I] := RSBox[Data[I]];
  for I := RCount downto $00 do
  begin
    for J := S369BSize - $01 downto $00 do
    begin
      Data[RKeys[I][J]] := ((Data[RKeys[I][J]] and $80) shr $07) or (Data[RKeys[I][J]] shl $01);
      Data[RKeys[I][J+$01]] := ((Data[RKeys[I][J+$01]] and $80) shr $07) or (Data[RKeys[I][J+$01]] shl $01);
      A := Data[RKeys[I][J]];
      B := Data[RKeys[I][J+$01]];
      Data[RKeys[I][J]] := (((B and $0F)) shl $04) or (A shr $04);
      Data[RKeys[I][J+$01]] := (((A and $0F)) shl $04) or (B shr $04);
    end;
    for J := $00 to S369BSize do
      Data[J] := RSBox[Data[J]] xor RKeys[I][J];
  end;
end;

end.
