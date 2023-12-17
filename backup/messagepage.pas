unit messagepage;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Graphics;

type

  { TMessagePage }

  TMessagePage = class(TForm)
    CloseMessagePage: TButton;
    MessageSection: TMemo;
  private

  public

  end;

var
  MessagePage1: TMessagePage;

implementation

{$R *.lfm}

end.

