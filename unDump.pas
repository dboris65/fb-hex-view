unit unDump;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TfrDump = class(TForm)
    Rich: TRichEdit;
    StatusBar: TStatusBar;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }

  public
    { Public declarations }
    in_file_name : string;
    in_file_offset, in_file_page_size : cardinal;
    in_file : TFileStream;
    function FormatDec10(s : string) : string;
    Function FileHexDump(FileName:String; offset : cardinal; in_file_page_size : cardinal):String;

  end; 

var
  frDump: TfrDump;

implementation

uses FB_HexView;

{$R *.dfm}
{$Optimization Off}
function TfrDump.FormatDec10(s : string) : string;
begin
  while Length(s) < 9 do
    s := s + ' ';
  Result := s;
end;

function TfrDump.FileHexDump(FileName:String; offset : cardinal; in_file_page_size : cardinal):String;
var byteread, suma : cardinal;
    buf: array[0..15] of AnsiChar;
    Len:Cardinal;
    i : cardinal;
    s : String;
Begin
  try
  if not FileExists(FileName) then
  begin
    ShowMessage('Datoteka ne postoji!');
    exit;
  end;
  in_file := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  in_file.Position := offset;
  Application.ProcessMessages;
  s := '';
  Result := '';
  suma := 0;
  repeat
    Application.ProcessMessages;
    Result := Result + FormatDec10(IntToHex(in_file.Position, 8)) + ' | ';
    byteread := in_file.Read(buf, 16);
    suma := suma + byteread;
    Len := Length(Buf);
    If  Len <> 0 Then begin
    For i := 0 to Len-1 Do
    Begin
      Result:=Result+IntToHex(Ord(buf[i]),2) + ' ';
      if (buf[i] in [#0 .. #31]) then
         s := s + '.'
      else
         s := s + String(AnsiChar(buf[i]));
    End;
    end;
    if Len < 16 then begin
      Len := 16 - Len;
    for I := 0 to Len do
      Result := Result + '00';
    end;
      Result := Result + ' ';
    Result := Result + ' | ' + s + #13#10;
    s := '';
  until (byteread = 0) or (suma >= in_file_page_size );
  except
     ShowMessage('Greska u citanju datoteke!');
     in_file.Free;
  end;
  in_file.Free;
End;




procedure TfrDump.FormShow(Sender: TObject);
begin
  Rich.Clear;
  Rich.Text := FileHexDump(in_file_name, in_file_offset, in_file_page_size);
end;

end.
