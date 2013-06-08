program FBHexView;

uses
  Forms,
  FB_HexView in 'FB_HexView.pas' {frGlavna},
  unDump in 'unDump.pas' {frDump},
  RecordNumber in 'RecordNumber.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrGlavna, frGlavna);
  Application.CreateForm(TfrDump, frDump);
  Application.Run;
end.
