unit FB_HexView;
{$POINTERMATH ON}

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, RecordNumber;

type
  SChar = Shortint;
  SShort = Smallint;
  UShort = Word;
  SLong = Longint;
  ULong = LongWord;

  THdr_Header = packed record
    page_type: Shortint; // ili SChar;
    page_flags: Byte;
    page_checksum: Word; // ili USHORT;
    page_generation: LongWord; // ili ULONG;
    page_sequence_number: LongWord; // ili ULONG;
    page_reserved: LongWord; // ili ULONG;
  end;

  THeader_Page = packed record
    pagHdr_Header: THdr_Header; // prethodno deklarisani THdr_Header
    hdr_page_size: Word; // ili USHORT;
    hdr_ods_version: Word; // ili USHORT;
    hdr_PAGES: Longint; // ili SLONG;
    hdr_next_page: LongWord; // ili ULONG;
    hdr_oldest_transaction: Longint; // ili SLONG;
    hdr_oldest_active: Longint; // ili SLONG;
    hdr_next_transaction: Longint; // ili SLONG;
    hdr_sequence: Word; // ili USHORT;
    hdr_flags: Word; // ili USHORT;
    hdr_creation_date: array [0 .. 1] of Longint; // ili SLONG;
    hdr_attachment_id: Longint; // ili SLONG;
    hdr_shadow_count: Longint; // ili SLONG;
    hdr_implementation: Smallint; // ili SSHORT;
    hdr_ods_minor: Word; // ili USHORT;
    hdr_ods_minor_original: Word; // ili USHORT;
    hdr_end: Word; // ili USHORT;
    hdr_page_buffers: LongWord; // ili ULONG;
    hdr_bumped_transaction: Longint; // ili SLONG;
    hdr_oldest_snapshot: Longint; // ili SLONG;
    hdr_backup_pages: Longint; // ili SLONG;
    hdr_misc: array [0 .. 2] of Longint; // ili SLONG;
    hdr_data: array [0 .. 0] of UCHAR; // ili Byte, u Windows.pas
  end;

  TPageInvPage = packed record
    pagHdr_Header: THdr_Header; // prethodno deklarisani THdr_Header
    pip_min: Longint; // ili SLONG;
    pip_bits: array [0 .. 32] of UCHAR; // ili Byte, u Windows.pas
    // Izvorno array [0..0]
    // niz je zaista dugacak do kraja stranice
    // ovdje je samo kao primjer prikazano 32 bajta
  end;

  TTransactionInvPage = packed record
    pagHdr_Header: THdr_Header; // prethodno deklarisani THdr_Header
    tip_next: Longint; // ili SLONG;
    tip_transactions: array [0 .. 32] of UCHAR; // ili Byte, u Windows.pas
    // Izvorno array [0..0]
    // niz je zaista dugacak do kraja stranice
    // ovdje je samo kao primjer prikazano 32 bajta
  end;

  TPointerPage = packed record
    pagHdr_Header: THdr_Header; // prethodno deklarisani THdr_Header
    ppg_sequence: Longint; // ili SLONG;
    ppg_next: Longint; // ili SLONG;
    ppg_count: Word; // ili UShort
    ppg_relation: Word; // ili UShort
    ppg_min_space: Word; // ili UShort
    ppg_max_space: Word; // ili UShort
    ppg_page: array [0 .. 32] of Longint; // ili SLONG
  end;

  { ** u sastavu TData Page ** }
  PDpg_repeat = ^TDpg_repeat;

  TDpg_repeat = packed record
    dpg_offset: Word; // ili UShort
    dpg_length: Word; // ili Byte, u Windows.pas
  end;

  TDataPage = packed record
    pagHdr_Header: THdr_Header; // prethodno deklarisani THdr_Header
    dpg_sequence: Longint; // ili SLONG;
    dpg_relation: Word; // ili UShort;
    dpg_count: Word; // ili UShort
    dpg_repeat: array [0 .. 0] of TDpg_repeat;
  end;

  TRhd_UNfragmented = packed record
    rhd_transaction: Longint; // ili SLONG;
    rhd_b_page: Longint; // ili SLONG;
    rhd_b_line: Word; // ili UShort;
    rhd_flags: Word; // ili UShort
    rhd_format: Byte; // ili Byte, u Windows.pas
    rhd_data: Byte; // array [0..0] of UCHAR;           // ili Byte, u Windows.pas
  end;

  TRhd_FRAGMENTED = packed record
    rhdf_transaction: Longint; // ili SLONG;
    rhdf_b_page: Longint; // ili SLONG;
    rhdf_b_line: Word; // ili UShort;
    rhdf_flags: Word; // ili UShort
    rhdf_format: UCHAR; // ili Byte, u Windows.pas
    rhdf_f_page: Longint; // ili SLONG;
    rhdf_f_line: Word; // ili UShort
    rhdf_data: array [0 .. 0] of UCHAR; // ili Byte, u Windows.pas
  end;
  { ** KRAJ u sastavu TData Page ** }

  { ** u sastavu TIndexRoot Page ** }
  // TUnion = packed record
  // case integer of
  // 0 : (irt_selectivity : real);              // ili float
  // 1 : (irt_transaction : Longint);           // ili SLONG;
  // end;
  PIrt_repeat = ^TIrt_repeat;

  TIrt_repeat = packed record
    irt_root: Longint; // ili SLONG;
    // ??? VELIKI UPITNIK - vise se ne koristi irt_selectivity ???, tako da nema potrebe za UNION-om
    // irt_stuff : TUnion;
    irt_transaction: Longint; // ili SLONG;
    irt_desc: Word; // ili UShort
    irt_keys: UCHAR; // ili Byte, u Windows.pas
    irt_flags: UCHAR; // ili Byte, u Windows.pas
  end;

  TIndexRootPage = packed record
    pagHdr_Header: THdr_Header; // prethodno deklarisani THdr_Header
    irt_relation: Word; // ili UShort;
    irt_count: Word; // ili UShort;
    Irt_repeat: array [0 .. 0] of TIrt_repeat;
  end;

  Tirtd_ods11 = packed record
    Irtd_field: Word;
    Irtd_itype: Word;
    Irtd_selectivity: Single;
  end;
  { ** KRAJ u sastavu TIndexRoot Page ** }

  { ** POCETAK u sastavu Index Btree Page ** }
  TIndexBtreePage = packed record
    pagHdr_Header: THdr_Header; // prethodno deklarisani THdr_Header
    btr_sibling: Longint; // ili SLONG;
    btr_left_sibling: Longint; // ili SLONG;
    btr_prefix_total: Longint; // ili SLONG;
    btr_relation: Word; // ili UShort;
    btr_length: Word; // ili UShort;
    btr_id: UCHAR; // ili Byte, u Windows.pas
    btr_level: UCHAR; // ili Byte, u Windows.pas
  end;

  TIndexJumpInfo = packed record
    firstNodeOffset: Word; // ili UShort;
    jumpAreaSize: Word; // ili UShort;
    jumpers: UCHAR; // ili Byte, u Windows.pas
  end;

  TIndexJumpNode = packed record
    nodePointer: Longint; // UCHAR*  pointer to where this node can be read from the page
    prefix: Word; // ili UShort;;        // length of prefix against previous jump node
    length: Word; // ili UShort;        // length of data in jump node (together with prefix this is prefix for pointing node)
    offset: Word; // ili UShort;        // offset to node in page
    data: Longint; // ili UCHAR*// Data can be read from here
  end;

  PIndexNode = ^TIndexNode;

  TIndexNode = packed record
    nodePointer: PByte; // UCHAR*  pointer to where this node can be read from the page
    prefix: Word; // ili UShort;;        // length of prefix against previous jump node
    length: Word; // ili UShort;        // length of data in jump node (together with prefix this is prefix for pointing node)
    pageNumber: Longint; // UCHAR*  pointer to where this node can be read from the page
    data: PByte; // ili UCHAR*// Data can be read from here
    RecordNumber: TRecordNumber; // UCHAR*  pointer to where this node can be read from the page
    isEndBucket: boolean;
    isEndLevel: boolean;
  end;

  { ** KRAJ u sastavu Index Btree Page ** }

  TfrGlavna = class(TForm)
    PageControl: TPageControl;
    Page0x01Header: TTabSheet;
    Page0x02PiP: TTabSheet;
    mDatabaseHeaderPage: TMemo;
    OpenDialog1: TOpenDialog;
    StatusBar1: TStatusBar;
    pnHeaderPage0x01TOP: TPanel;
    rgPrikazi: TRadioGroup;
    pnPIP0x02TOP: TPanel;
    rgPrikaziPIP: TRadioGroup;
    mPIP: TMemo;
    Page0x03TransactionInventoryPage: TTabSheet;
    Panel1: TPanel;
    rgPrikaziTRansactionIP: TRadioGroup;
    mTransactionIP: TMemo;
    Page0x04PointerPage: TTabSheet;
    Panel2: TPanel;
    rgPrikaziPointerPage: TRadioGroup;
    mPointerPage: TMemo;
    Page0x06IndexRoot: TTabSheet;
    Panel3: TPanel;
    rgPrikaziIndexRoot: TRadioGroup;
    mIndexRoot: TMemo;
    PageOsnovna: TTabSheet;
    pnTop0: TPanel;
    pnClient0: TPanel;
    pnPIP0: TPanel;
    pnPIP0TOP: TPanel;
    lbPIP: TListBox;
    pnTip1: TPanel;
    pnTIP1top: TPanel;
    lbTIP: TListBox;
    pnPointer0x04: TPanel;
    pnPointer0x04top: TPanel;
    lbPointerTOP: TListBox;
    pnIndexRoot0x06: TPanel;
    pnIndexRoot0x06top: TPanel;
    lbIndexRoot0x06: TListBox;
    pnIndexBTree0x07: TPanel;
    pnIndexBTree0x07top: TPanel;
    lbIndexBTree0x07: TListBox;
    btUcitaj: TButton;
    Page0x07IndexBtreePage: TTabSheet;
    pnIndBTREE0x07TOP: TPanel;
    rgPrikaziIndexBtree: TRadioGroup;
    mIndexBtree: TMemo;
    btIndexBTreeHexDump: TButton;
    Page0x05DataPage: TTabSheet;
    Panel4: TPanel;
    rgPrikaziDataPage: TRadioGroup;
    btDataPageHex: TButton;
    mDataPage: TMemo;
    pnDataPage0x05: TPanel;
    pnDataPage0x05top: TPanel;
    lbDataPage0x05: TListBox;
    btDBHeaderPageHex: TButton;
    btPIPPageHex: TButton;
    btTIPPageHex: TButton;
    btPointerPageHex: TButton;
    btIndexPageHex: TButton;
    pnDATAdesno: TPanel;
    lbDATA_dpg_repeat: TListBox;
    pnDATAup: TPanel;
    pnINDEXROOTright: TPanel;
    lbIndexRoot_irt_desc: TListBox;
    pnINDEXROOTtop: TPanel;
    Label1: TLabel;
    Memo1: TMemo;
    procedure btUcitajClick(Sender: TObject);
    procedure rgPrikaziClick(Sender: TObject);
    procedure rgPrikaziPIPClick(Sender: TObject);
    procedure rgPrikaziTRansactionIPClick(Sender: TObject);
    procedure rgPrikaziPointerPageClick(Sender: TObject);
    procedure lbIndexRoot0x06DblClick(Sender: TObject);
    procedure rgPrikaziIndexRootClick(Sender: TObject);
    procedure lbIndexBTree0x07DblClick(Sender: TObject);
    procedure rgPrikaziIndexBtreeClick(Sender: TObject);
    procedure btIndexBTreeHexDumpClick(Sender: TObject);
    procedure btDataPageHexClick(Sender: TObject);
    procedure lbDataPage0x05DblClick(Sender: TObject);
    procedure rgPrikaziDataPageClick(Sender: TObject);
    procedure btDBHeaderPageHexClick(Sender: TObject);
    procedure btPIPPageHexClick(Sender: TObject);
    procedure btTIPPageHexClick(Sender: TObject);
    procedure btPointerPageHexClick(Sender: TObject);
    procedure lbPointerTOPDblClick(Sender: TObject);
    procedure lbDATA_dpg_repeatDblClick(Sender: TObject);
    procedure btIndexPageHexClick(Sender: TObject);
    procedure lbIndexRoot_irt_descDblClick(Sender: TObject);
    procedure lbTIPDblClick(Sender: TObject);
    procedure lbPIPDblClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
    Hdr_Header: THdr_Header; // ima ga svaka stranica
    Header_Page: THeader_Page; // tip 0x01, database header page
    PageInvPage: TPageInvPage; // tip 0x02, Page Inventory Page (PIP)
    TransactionInvPage: TTransactionInvPage; // tip 0x03, Transaction Inventory Page (TIP)
    PointerPage: TPointerPage; // tip 0x04, Pointer Page

    DataPage: TDataPage; // tip 0x05, Data Page
    Rhd_UNfragmented: TRhd_UNfragmented;
    Rhd_FRAGMENTED: TRhd_FRAGMENTED;

    IndexRootPage: TIndexRootPage; // tip 0x06, Index Root Page
    NizIrt_repeat: array [0 .. 2] of TIrt_repeat;
    // dio strane 0x06, Index Root Page
    { *** TIndexBtreePage *** }
    IndexBtreePage: TIndexBtreePage; // tip 0x07, Index BTree Page
    IndexJumpInfo: TIndexJumpInfo;
    IndexJumpNode: TIndexJumpNode;
    IndexNode: TIndexNode;
    { *** KRAJ TIndexBtreePage *** }
    in_file: TFileStream;
    in_file_name: string;
    FirstTIPPage, FirstPIPPage, FirstPointerPage, FirstIndexRootPage,
      FirstIndexBTreePage, FirstDataPage: integer;

    function ReadNode(var IndexNode: TIndexNode; pagePointer: PByte;
      flags: Byte; leafNode: boolean): PByte;

    function RLE_Decode(B1: Byte; B2: Byte): integer;
    function RLE_Decompress(s: string): string;
    function GetDataPageFlags(w: Word): string;
    function StringToHex(buf: string): string;
    function BoolToStr(Val: boolean): String;

    function FormatDec(s: string): string;
    function FormatDecRight(s: string; mjesta: integer): string;
    function ByteToBin(b: Byte): string;
    procedure GetHeaderPage;
    procedure OffsetBinarno(Ptr: PByte; memo: TMemo; dec: boolean);
    procedure OffsetBinarnoPIP(Ptr: PByte; memo: TMemo; dec: boolean);
    procedure OffsetLongInt(Ptr: PLongint; memo: TMemo; dec: boolean);
    procedure GetPIP(offset: integer);
    procedure GetTransactionIP(offset: integer);
    procedure GetPointerPage(offset: integer);

    procedure GetDataPage(offset: integer);
    procedure IndexRootPageDescriptor(Ptr: PIrt_repeat; memo: TMemo;
      PgOffset: integer);
    procedure GetIndexRootPage(offset: integer);
    procedure GetIndexBtreePage(offset: integer);
  end;

var
  frGlavna: TfrGlavna;

implementation

uses unDump;
{$R *.dfm}

function TfrGlavna.BoolToStr(Val: boolean): String;
begin
  if Val = True then
    result := 'True'
  else
    result := 'False';
end;
{$O-}

function TfrGlavna.ReadNode(var IndexNode: TIndexNode; pagePointer: PByte;
  flags: Byte; leafNode: boolean): PByte;
var
  localPointer: PByte;
  internalFlags: Byte;
  number: INT64;
  tmp: Longint;
begin
  number := 0;

  IndexNode.nodePointer := pagePointer;
  IndexNode.RecordNumber := TRecordNumber.Create();
  if ((flags and btr_large_keys) = btr_large_keys) then
  begin
    localPointer := pagePointer;
    internalFlags := (localPointer^);
    inc(localPointer);

    number := (INT64(internalFlags) and INT64($1F));
    internalFlags := ((internalFlags and $E0) shr 5);

    if (internalFlags = BTN_END_LEVEL_FLAG) then
      IndexNode.isEndLevel := True
    else
      IndexNode.isEndLevel := false;
    if (internalFlags = BTN_END_BUCKET_FLAG) then
      IndexNode.isEndBucket := True
    else
      IndexNode.isEndBucket := false;
    // Ako je zadnji END_LEVEL marker - kraj
    if (IndexNode.isEndLevel) then
    begin
      IndexNode.prefix := 0;
      IndexNode.length := 0;
      IndexNode.RecordNumber.setValue(0);
      IndexNode.pageNumber := 0;
      result := localPointer;
      exit;
    end;

    // Preostali biti broja number
    tmp := Byte(localPointer^);
    inc(localPointer);
    number := number or ((tmp and $7F) shl 5);
    if (tmp >= 128) then
    begin
      tmp := Byte(localPointer^);
      inc(localPointer);
      number := number or ((tmp and $7F) shl 12);
      if (tmp >= 128) then
      begin
        tmp := Byte(localPointer^);
        inc(localPointer);
        number := number or ((tmp and $7F) shl 19);
        if (tmp >= 128) then
        begin
          tmp := Byte(localPointer^);
          inc(localPointer);
          number := number or ((tmp and $7F) shl 26);
          if (tmp >= 128) then
          begin
            tmp := Byte(localPointer^);
            inc(localPointer);
            number := number or ((INT64(tmp) and $7F) shl 33);
          end; // (tmp >= 128 - cetvrti put)
        end; // (tmp >= 128 - treci put)
      end; // (tmp >= 128 - drugi put)
    end; // (tmp >= 128 - prvi put)
    IndexNode.RecordNumber.setValue(number);

    if not leafNode then
    begin
      // Broj stranice za cvorove koji nisu listovi
      tmp := Byte(localPointer^);
      inc(localPointer);
      number := (tmp and $7F);
      if (tmp >= 128) then
      begin
        tmp := Byte(localPointer^);
        inc(localPointer);
        number := number or ((tmp and $7F) shl 7);
        if (tmp >= 128) then
        begin
          tmp := Byte(localPointer^);
          inc(localPointer);
          number := number or ((tmp and $7F) shl 14);
          if (tmp >= 128) then
          begin
            tmp := Byte(localPointer^);
            inc(localPointer);
            number := number or ((tmp and $7F) shl 21);
            if (tmp >= 128) then
            begin
              tmp := Byte(localPointer^);
              inc(localPointer);
              number := number or ((tmp and $7F) shl 28);
            end; // (tmp >= 128 - cetvrti put)
          end; // (tmp >= 128 - treci put)
        end; // (tmp >= 128 - drugi put)
      end; // (tmp >= 128 - prvi put)
    end; // not LeafNode

    if (internalFlags = BTN_ZERO_PREFIX_ZERO_LENGTH_FLAG) then
    begin
      // Prefix je nula
      IndexNode.prefix := 0;
    end
    else
    begin
      // Daj prefix
      tmp := Byte(localPointer^);
      inc(localPointer);
      IndexNode.prefix := (tmp and $7F);
      if (tmp and $80) = $80 then
      begin
        tmp := Byte(localPointer^);
        inc(localPointer);
        IndexNode.prefix := IndexNode.prefix or ((tmp and $7F) shl 7);
        // We get 14 bits at this point
      end
    end;

    if ((internalFlags = BTN_ZERO_LENGTH_FLAG) or (internalFlags =
          BTN_ZERO_PREFIX_ZERO_LENGTH_FLAG)) then
    begin
      // Duzina je nula
      IndexNode.length := 0;
    end
    else if (internalFlags = BTN_ONE_LENGTH_FLAG) then
    begin
      // Duzina je jedan
      IndexNode.length := 1;
    end
    else
    begin
      // daj duzinu
      tmp := Byte(localPointer^);
      inc(localPointer);

      IndexNode.length := (tmp and $7F);

      if (tmp and $80) = $80 then
      begin
        tmp := Byte(localPointer^);
        inc(localPointer);
        IndexNode.length := IndexNode.length or ((tmp and $7F) shl 7);
        // We get 14 bits at this point
      end
    end;
    // Get pointer where data starts
    IndexNode.data := localPointer;
    inc(localPointer, IndexNode.length);

    result := localPointer;
    exit;

  end
  else
  begin
    IndexNode.prefix := Byte(pagePointer^);
    inc(pagePointer);
    IndexNode.length := Byte(pagePointer^);
    inc(pagePointer);
    if (leafNode) then
    begin
      // Nice sign extension should happen here
      IndexNode.RecordNumber.setValue(get_long(pagePointer));
      if (IndexNode.RecordNumber.getValue() = END_LEVEL) then
        IndexNode.isEndLevel := True
      else
        IndexNode.isEndLevel := false;
      if (IndexNode.RecordNumber.getValue() = END_BUCKET) then
        IndexNode.isEndBucket := True
      else
        IndexNode.isEndBucket := false;
    end
    else
    begin
      IndexNode.pageNumber := get_long(pagePointer);
      if (IndexNode.pageNumber = END_LEVEL) then
        IndexNode.isEndLevel := True
      else
        IndexNode.isEndLevel := false;

      if (IndexNode.pageNumber = END_BUCKET) then
        IndexNode.isEndBucket := True
      else
        IndexNode.isEndBucket := false;
    end;
    inc(pagePointer, sizeof(Longint));
  end;
  IndexNode.RecordNumber.Free;
end;
{$O-}

function TfrGlavna.RLE_Decompress(s: string): string;
var
  i, j, num, num2, counter: integer;
begin
  i := 1;
  counter := 1;
  result := '  Null maska: ';
  while i < length(s) do
  begin
    num := RLE_Decode(Byte(s[i]), Byte(s[i + 1]));
    if num = 0 then
      exit;
    num2 := num;
    if num < 0 then
    begin
      while num < 0 do
      begin
        result := result + IntToHex(Byte(s[i + 1]), 2) + ' ';
        inc(num);
      end;
    end
    else
    begin
      j := 1;
      while j <= num do
      begin
        result := result + IntToHex(Byte(s[i + j]), 2) + ' ';
        inc(j);
      end;
    end;
    if num2 < 0 then
      inc(i, 2)
    else
      inc(i, num2 + 1);
    if counter = 2 then
      result := result + chr(13) + chr(10) + '  Podaci: ';
    inc(counter);
  end;

end;

function TfrGlavna.RLE_Decode(B1: Byte; B2: Byte): integer;
var
  s: AnsiString;
  i: integer;
begin
  if (B1 and 128) = 128 then
    result := B1 - 256
  else
    result := B1;
end;

function TfrGlavna.FormatDec(s: string): string;
begin
  while length(s) < 25 do
    s := s + ' ';
  result := s;
end;

function TfrGlavna.FormatDecRight(s: string; mjesta: integer): string;
begin
  while length(s) < mjesta do
    Insert(' ', s, 1);
  result := s;
end;

procedure TfrGlavna.btDataPageHexClick(Sender: TObject);
begin
  if in_file_name = '' then
  begin
    ShowMessage('Ucitajte neku datoteku!');
    exit;
  end;
  if lbDataPage0x05.ItemIndex < 0 then
  begin
    ShowMessage('Odaberite jednu Data stranicu u Data list box-u!');
    exit;
  end;
  frDump.in_file_name := in_file_name;
  frDump.in_file_offset := StrToInt
    (lbDataPage0x05.Items[lbDataPage0x05.ItemIndex]);
  frDump.in_file_page_size := Header_Page.hdr_page_size;
  frDump.Caption := 'Dump - ' + in_file_name;
  frDump.Show;

end;

procedure TfrGlavna.btDBHeaderPageHexClick(Sender: TObject);
begin
  if in_file_name = '' then
  begin
    ShowMessage('Ucitajte neku datoteku!');
    exit;
  end;

  frDump.in_file_name := in_file_name;
  frDump.in_file_offset := 0;
  frDump.in_file_page_size := Header_Page.hdr_page_size;
  frDump.Caption := 'Dump - ' + in_file_name;
  frDump.Show;
end;

procedure TfrGlavna.btIndexBTreeHexDumpClick(Sender: TObject);
begin
  if in_file_name = '' then
  begin
    ShowMessage('Ucitajte neku datoteku!');
    exit;
  end;
  if lbIndexBTree0x07.ItemIndex < 0 then
  begin
    ShowMessage('Odaberite jednu BTree stranicu u BTree list box-u!');
    exit;
  end;
  frDump.in_file_name := in_file_name;
  frDump.in_file_offset := StrToInt
    (lbIndexBTree0x07.Items[lbIndexBTree0x07.ItemIndex]);
  frDump.in_file_page_size := Header_Page.hdr_page_size;
  frDump.Caption := 'Dump - ' + in_file_name;
  frDump.Show;
end;

procedure TfrGlavna.btIndexPageHexClick(Sender: TObject);
begin
  if in_file_name = '' then
  begin
    ShowMessage('Ucitajte neku datoteku!');
    exit;
  end;
  if lbIndexRoot0x06.ItemIndex < 0 then
  begin
    ShowMessage
      ('Odaberite jednu Indeks Root stranicu u Indeks Root list box-u!');
    exit;
  end;
  frDump.in_file_name := in_file_name;
  frDump.in_file_offset := StrToInt
    (lbIndexRoot0x06.Items[lbIndexRoot0x06.ItemIndex]);
  frDump.in_file_page_size := Header_Page.hdr_page_size;
  frDump.Caption := 'Dump - ' + in_file_name;
  frDump.Show;
end;

procedure TfrGlavna.btPIPPageHexClick(Sender: TObject);
begin
  if in_file_name = '' then
  begin
    ShowMessage('Ucitajte neku datoteku!');
    exit;
  end;
  if lbPIP.ItemIndex < 0 then
  begin
    ShowMessage('Odaberite jednu PIP stranicu u PIP list box-u!');
    exit;
  end;
  frDump.in_file_name := in_file_name;
  frDump.in_file_offset := StrToInt(lbPIP.Items[lbPIP.ItemIndex]);
  frDump.in_file_page_size := Header_Page.hdr_page_size;
  frDump.Caption := 'Dump - ' + in_file_name;
  frDump.Show;
end;

procedure TfrGlavna.btPointerPageHexClick(Sender: TObject);
begin
  if in_file_name = '' then
  begin
    ShowMessage('Ucitajte neku datoteku!');
    exit;
  end;
  if lbTIP.ItemIndex < 0 then
  begin
    ShowMessage('Odaberite jednu Pointer stranicu u Pointer list box-u!');
    exit;
  end;
  frDump.in_file_name := in_file_name;
  frDump.in_file_offset := StrToInt(lbPointerTOP.Items[lbPointerTOP.ItemIndex]);
  frDump.in_file_page_size := Header_Page.hdr_page_size;
  frDump.Caption := 'Dump - ' + in_file_name;
  frDump.Show;

end;

procedure TfrGlavna.btTIPPageHexClick(Sender: TObject);
begin
  if in_file_name = '' then
  begin
    ShowMessage('Ucitajte neku datoteku!');
    exit;
  end;
  if lbTIP.ItemIndex < 0 then
  begin
    ShowMessage('Odaberite jednu TIP stranicu u TIP list box-u!');
    exit;
  end;
  frDump.in_file_name := in_file_name;
  frDump.in_file_offset := StrToInt(lbTIP.Items[lbTIP.ItemIndex]);
  frDump.in_file_page_size := Header_Page.hdr_page_size;
  frDump.Caption := 'Dump - ' + in_file_name;
  frDump.Show;
end;

function TfrGlavna.ByteToBin(b: Byte): string;
var
  bin: string;
  counter: short;
begin
  bin := '';
  counter := 0;
  while counter < 8 do
  begin
    if (b AND $80) = $80 then
      bin := bin + '1'
    else
      bin := bin + '0';
    b := b SHL 1;
    inc(counter);
  end;
  result := bin;
end;

procedure TfrGlavna.GetHeaderPage;
begin
  if not assigned(in_file) then
    exit;

  if frGlavna.rgPrikazi.ItemIndex = 0 then
  begin
    with frGlavna.mDatabaseHeaderPage do
    begin
      Lines.Clear;
      Lines.Add('Database Header Page');
      with frGlavna.Header_Page do
      begin
        Lines.Add('    START of Standard page header');
        Lines.Add('        page_type:            ' + FormatDec
            (IntToStr(pagHdr_Header.page_type)) +
            ' | Oznaceni bajt. 0x0 - nedefinisano, 0x1 - Header Page, 0x2 - Page Inventory Page...');
        Lines.Add('        page_flags:           ' + FormatDec
            (IntToStr(pagHdr_Header.page_flags)) +
            ' | Neoznaceni bajt, razliciti flegovi');
        Lines.Add('        page_checksum:        ' + FormatDec
            (IntToStr(pagHdr_Header.page_checksum)) +
            ' | Dva neoznacena bajta. Checksum se vise ne koristi (uvijek je 12345). Moguce je da ce od ver.3.0 imati drugu svrhu.');
        Lines.Add('        page_generation:      ' + FormatDec
            (IntToStr(pagHdr_Header.page_generation)) +
            ' | Cetiri neoznacena bajta. Uvecava se svaki put kada stranicu upisemo na disk (npr. backup-om)');
        Lines.Add('        page_sequence_number: ' + FormatDec
            (IntToStr(pagHdr_Header.page_sequence_number)) +
            ' | Cetiri neoznacena bajta. Ranije ih je koristio Write Ahead Log. Trenutno ih koristi nbackup.');
        Lines.Add('        page_reserved:        ' + FormatDec
            (IntToStr(pagHdr_Header.page_reserved)) +
            ' | Cetiri neoznacena bajta. Rezervisani su za buducu upotrebu.');
        Lines.Add('    END of Standard page header');
        Lines.Add('    hdr_page_size:            ' + FormatDec
            (IntToStr(hdr_page_size)) +
            ' | Dva neoznacena bajta. Prikazuju velicinu bilo koje stranice u bazi podataka.');
        Lines.Add('    hdr_ods_version:          ' + FormatDec
            (IntToStr(hdr_ods_version)) +
            ' | Dva neoznacena bajta. Osnovna verzija ODS-a (On-Disk Structure). Broj verzije dobija se AND-om sa 0x8000 (Little Endian). Za podverzije pogledati hdr_ods_minor.');
        Lines.Add('    hdr_PAGES:                ' + FormatDec
            (IntToStr(hdr_PAGES)) +
            ' | Cetiri oznacena bajta. Broj stranice na kojoj se nalazi prva pokazivacka (pointer) strana koja pokazuje prema tabeli RDB$PAGES. Na osnovu nje, FB pronalazi sve ostale stranice sa meta-podacima.');
        Lines.Add('    hdr_next_page:            ' + FormatDec
            (IntToStr(hdr_next_page)) +
            ' | Cetiri neoznacena bajta. Ako se koristi multi-file baza podataka, pokazuje broj Header stranice u slijedecem fajlu u bazi.');
        Lines.Add('    hdr_oldest_transaction:   ' + FormatDec
            (IntToStr(hdr_oldest_transaction)) +
            ' | Cetiri oznacena bajta. ID najstarije aktivne transakcije. Aktivna = Uncommited, Limbo ili Rolled-Back transakcija.');
        Lines.Add('    hdr_oldest_active:        ' + FormatDec
            (IntToStr(hdr_oldest_active)) +
            ' | Cetiri oznacena bajta. Pokazuje koji je bio ID najstarije aktivne transakcije u momentu startovanja bilo koje druge transakcije.');
        Lines.Add('    hdr_next_transaction:     ' + FormatDec
            (IntToStr(hdr_next_transaction)) +
            ' | Cetiri oznacena bajta. Pokazuju koji ID ce dobiti slijedeca transakcija koja bude pokrenuta.');
        Lines.Add('    hdr_sequence:             ' + FormatDec
            (IntToStr(hdr_sequence)) +
            ' | Dva neoznacena bajta. Sekvencijalni broj ove datoteke u okviru baze. Za Multi-file baze podataka.');
        Lines.Add('    hdr_flags:                ' + FormatDec
            (IntToStr(hdr_flags)) +
            ' | Dva neoznacena bajta. Razliciti flagovi. Npr. 0x01 - hdr_active_shadow, 0x02 - hdr_force_write, ..., 0x100 - hdr_sql_dialect_3, ...');
        Lines.Add('    hdr_creation_date[0]:     ' + FormatDec
            (IntToStr(hdr_creation_date[0])) +
            ' | Dva puta po cetiri oznacena bajta (osam ukupno). Datum/vrijeme kada je baza kreirana/rekreirana iz backup-a u FB internom formatu.');
        Lines.Add('    hdr_creation_date[1]:     ' + FormatDec
            (IntToStr(hdr_creation_date[1])) +
            ' | Broj dana od 17 Nov.1858. Broj sati/minuta dobija se dijeljenjem drugog podatka sa 3600000.');
        Lines.Add('    hdr_attachment_id:        ' + FormatDec
            (IntToStr(hdr_attachment_id)) +
            ' | Cetiri oznacena bajta. ID koji ce dobiti slijedeca konekcija prema ovoj bazi. Bilo koja baza koja premasi 2^32 -1 mora biti back-upovana i ponovo rollback-ovana.');
        Lines.Add('    hdr_shadow_count:         ' + FormatDec
            (IntToStr(hdr_shadow_count)) +
            ' | Cetiri oznacena bajta. Sluzi za sinhronizaciju sa Shadow datotekom.');
        Lines.Add('    hdr_implementation:       ' + FormatDec
            (IntToStr(hdr_implementation)) +
            ' | Dva oznacena bajta. Indicira u kom okruzenju je baza kreirana. Rjesava probleme vezane za little/big endian konverziju.');
        Lines.Add('    hdr_ods_minor:            ' + FormatDec
            (IntToStr(hdr_ods_minor)) +
            ' | Dva oznacena bajta. Podverzija ODS-a.');
        Lines.Add('    hdr_ods_minor_original:   ' + FormatDec
            (IntToStr(hdr_ods_minor_original)) +
            ' | Dva neoznacena bajta. Koja je bila podverzija ODS-a kada je baza inicijalno kreirana.');
        Lines.Add('    hdr_end:                  ' + FormatDec
            (IntToStr(hdr_end)) +
            ' | Dva neoznacena bajta. Pokazuje na kom offset-u zavrsava hdr_data, odnosno gdje pocinje ''grumenje'' (clumplets).');
        Lines.Add('    hdr_page_buffers:         ' + FormatDec
            (IntToStr(hdr_page_buffers)) +
            ' | Cetiri neoznacena bajta. Broj buffer-a koji se koriste za kes. Ako je nula, onda se koristi default vrijednost.');
        Lines.Add('    hdr_bumped_transaction:   ' + FormatDec
            (IntToStr(hdr_bumped_transaction)) +
            ' | Cetiri oznacena bajta. Trenutno se ne koristi i uvjek je 1. Koristice se za optimizaciju log-a u buducim verzijama.');
        Lines.Add('    hdr_oldest_snapshot:      ' + FormatDec
            (IntToStr(hdr_oldest_snapshot)) +
            ' | Cetiri oznacena bajta. Broj najstarijeg snapshot-a aktivne transakcije (confusing and redundant variant of Oldest Active Transaction)');
        Lines.Add('    hdr_backup_pages:         ' + FormatDec
            (IntToStr(hdr_backup_pages)) +
            ' | Cetiri oznacena bajta. Broj stranica koje su trenutno zakljucane od strane nbackup-a.');
        Lines.Add('    hdr_misc[0]:              ' + FormatDec
            (IntToStr(hdr_misc[0])) +
            ' | Tri puta po cetiri oznacena bajta (dvanaest ukupno). Trenutno se ne koristi.');
        Lines.Add('    hdr_misc[1]:              ' + FormatDec
            (IntToStr(hdr_misc[1])));
        Lines.Add('    hdr_misc[2]:              ' + FormatDec
            (IntToStr(hdr_misc[2])));
        Lines.Add('    hdr_data[0]:              ' + FormatDec
            (IntToStr(hdr_data[0])) +
            ' | Jedan bajt. Pocetak Clumpleta (grumenja). Clumplet je struktura varijabline duzine koja drzi razlicite podatke o bazi.');
      end; // with frGlavna.Header_Page do
    end; // with frGlavna.mDatabaseHeaderPage do
  end
  else
  begin
    with frGlavna.mDatabaseHeaderPage do
    begin
      Lines.Clear;
      Lines.Add('Database Header Page');
      with frGlavna.Header_Page do
      begin
        Lines.Add('    START of Standard page header');
        Lines.Add('        page_type:            ' + FormatDec
            (IntToHex(pagHdr_Header.page_type, 2)) +
            ' | Oznaceni bajt. 0x0 - nedefinisano, 0x1 - Header Page, 0x2 - Page Inventory Page...');
        Lines.Add('        page_flags:           ' + FormatDec
            (IntToHex(pagHdr_Header.page_flags, 2)) +
            ' | Neoznaceni bajt, razliciti flegovi');
        Lines.Add('        page_checksum:        ' + FormatDec
            (IntToHex(pagHdr_Header.page_checksum, 4)) +
            ' | Dva neoznacena bajta. Checksum se vise ne koristi (uvijek je 12345). Moguce je da ce od ver.3.0 imati drugu svrhu.');
        Lines.Add('        page_generation:      ' + FormatDec
            (IntToHex(pagHdr_Header.page_generation, 8)) +
            ' | Cetiri neoznacena bajta. Uvecava se svaki put kada stranicu upisemo na disk (npr. backup-om)');
        Lines.Add('        page_sequence_number: ' + FormatDec
            (IntToHex(pagHdr_Header.page_sequence_number, 8)) +
            ' | Cetiri neoznacena bajta. Ranije ih je koristio Write Ahead Log. Trenutno ih koristi nbackup.');
        Lines.Add('        page_reserved:        ' + FormatDec
            (IntToHex(pagHdr_Header.page_reserved, 8)) +
            ' | Cetiri neoznacena bajta. Rezervisani su za buducu upotrebu.');
        Lines.Add('    END of Standard page header');
        Lines.Add('    hdr_page_size:            ' + FormatDec
            (IntToHex(hdr_page_size, 4)) +
            ' | Dva neoznacena bajta. Prikazuju velicinu bilo koje stranice u bazi podataka.');
        Lines.Add('    hdr_ods_version:          ' + FormatDec
            (IntToHex(hdr_ods_version, 4)) +
            ' | Dva neoznacena bajta. Osnovna verzija ODS-a (On-Disk Structure). Broj verzije dobija se AND-om sa 0x8000 (Little Endian). Za podverzije pogledati hdr_ods_minor.');
        Lines.Add('    hdr_PAGES:                ' + FormatDec
            (IntToHex(hdr_PAGES, 8)) +
            ' | Cetiri oznacena bajta. Broj stranice na kojoj se nalazi prva pokazivacka (pointer) strana koja pokazuje prema tabeli RDB$PAGES. Na osnovu nje, FB pronalazi sve ostale stranice sa meta-podacima.');
        Lines.Add('    hdr_next_page:            ' + FormatDec
            (IntToHex(hdr_next_page, 8)) +
            ' | Cetiri neoznacena bajta. Ako se koristi multi-file baza podataka, pokazuje broj Header stranice u slijedecem fajlu u bazi.');
        Lines.Add('    hdr_oldest_transaction:   ' + FormatDec
            (IntToHex(hdr_oldest_transaction, 8)) +
            ' | Cetiri oznacena bajta. ID najstarije aktivne transakcije. Aktivna = Uncommited, Limbo ili Rolled-Back transakcija.');
        Lines.Add('    hdr_oldest_active:        ' + FormatDec
            (IntToHex(hdr_oldest_active, 8)) +
            ' | Cetiri oznacena bajta. Pokazuje koji je bio ID najstarije aktivne transakcije u momentu startovanja bilo koje druge transakcije.');
        Lines.Add('    hdr_next_transaction:     ' + FormatDec
            (IntToHex(hdr_next_transaction, 8)) +
            ' | Cetiri oznacena bajta. Pokazuju koji ID ce dobiti slijedeca transakcija koja bude pokrenuta.');
        Lines.Add('    hdr_sequence:             ' + FormatDec
            (IntToHex(hdr_sequence, 4)) +
            ' | Dva neoznacena bajta. Sekvencijalni broj ove datoteke u okviru baze. Za Multi-file baze podataka.');
        Lines.Add('    hdr_flags:                ' + FormatDec
            (IntToHex(hdr_flags, 4)) +
            ' | Dva neoznacena bajta. Razliciti flagovi. Npr. 0x01 - hdr_active_shadow, 0x02 - hdr_force_write, ..., 0x100 - hdr_sql_dialect_3, ...');
        Lines.Add('    hdr_creation_date[0]:     ' + FormatDec
            (IntToHex(hdr_creation_date[0], 8)) +
            ' | Dva puta po cetiri oznacena bajta (osam ukupno). Datum/vrijeme kada je baza kreirana/rekreirana iz backup-a u FB internom formatu.');
        Lines.Add('    hdr_creation_date[1]:     ' + FormatDec
            (IntToHex(hdr_creation_date[1], 8)) +
            ' | Broj dana od 17 Nov.1858. Broj sati/minuta dobija se dijeljenjem drugog podatka sa 3600000.');
        Lines.Add('    hdr_attachment_id:        ' + FormatDec
            (IntToHex(hdr_attachment_id, 8)) +
            ' | Cetiri oznacena bajta. ID koji ce dobiti slijedeca konekcija prema ovoj bazi. Bilo koja baza koja premasi 2^32 -1 mora biti back-upovana i ponovo rollback-ovana.');
        Lines.Add('    hdr_shadow_count:         ' + FormatDec
            (IntToHex(hdr_shadow_count, 8)) +
            ' | Cetiri oznacena bajta. Sluzi za sinhronizaciju sa Shadow datotekom.');
        Lines.Add('    hdr_implementation:       ' + FormatDec
            (IntToHex(hdr_implementation, 4)) +
            ' | Dva oznacena bajta. Indicira u kom okruzenju je baza kreirana. Rjesava probleme vezane za little/big endian konverziju.');
        Lines.Add('    hdr_ods_minor:            ' + FormatDec
            (IntToHex(hdr_ods_minor, 4)) +
            ' | Dva oznacena bajta. Podverzija ODS-a.');
        Lines.Add('    hdr_ods_minor_original:   ' + FormatDec
            (IntToHex(hdr_ods_minor_original, 4)) +
            ' | Dva neoznacena bajta. Koja je bila podverzija ODS-a kada je baza inicijalno kreirana.');
        Lines.Add('    hdr_end:                  ' + FormatDec
            (IntToHex(hdr_end, 4)) +
            ' | Dva neoznacena bajta. Pokazuje na kom offset-u zavrsava hdr_data, odnosno gdje pocinje ''grumenje'' (clumplets).');
        Lines.Add('    hdr_page_buffers:         ' + FormatDec
            (IntToHex(hdr_page_buffers, 8)) +
            ' | Cetiri neoznacena bajta. Broj buffer-a koji se koriste za kes. Ako je nula, onda se koristi default vrijednost.');
        Lines.Add('    hdr_bumped_transaction:   ' + FormatDec
            (IntToHex(hdr_bumped_transaction, 8)) +
            ' | Cetiri oznacena bajta. Trenutno se ne koristi i uvjek je 1. Koristice se za optimizaciju log-a u buducim verzijama.');
        Lines.Add('    hdr_oldest_snapshot:      ' + FormatDec
            (IntToHex(hdr_oldest_snapshot, 8)) +
            ' | Cetiri oznacena bajta. Broj najstarijeg snapshot-a aktivne transakcije (confusing and redundant variant of Oldest Active Transaction)');
        Lines.Add('    hdr_backup_pages:         ' + FormatDec
            (IntToHex(hdr_backup_pages, 8)) +
            ' | Cetiri oznacena bajta. Broj stranica koje su trenutno zakljucane od strane nbackup-a.');
        Lines.Add('    hdr_misc[0]:              ' + FormatDec
            (IntToHex(hdr_misc[0], 8)) +
            ' | Tri puta po cetiri oznacena bajta (dvanaest ukupno). Trenutno se ne koristi.');
        Lines.Add('    hdr_misc[1]:              ' + FormatDec
            (IntToHex(hdr_misc[1], 8)));
        Lines.Add('    hdr_misc[2]:              ' + FormatDec
            (IntToHex(hdr_misc[2], 8)));
        Lines.Add('    hdr_data[0]:              ' + FormatDec
            (IntToHex(hdr_data[0], 2)) +
            ' | Jedan bajt. Pocetak Clumpleta (grumenja). Clumplet je struktura varijabline duzine koja drzi razlicite podatke o bazi.');
      end; // with frGlavna.Header_Page do
    end; // with frGlavna.mDatabaseHeaderPage do
  end;
end;

procedure TfrGlavna.OffsetLongInt(Ptr: PLongint; memo: TMemo; dec: boolean);
var
  s: string;
begin
  if dec then
  begin
    with memo do
    begin
      s := 'Pojedinacni elementi:  ' + #13#10 + IntToStr(20)
        + ':' + FormatDecRight(IntToStr(Ptr^), 8);
      inc(Ptr);
      s := s + ' ' + FormatDecRight(IntToStr(Ptr^), 8);
      inc(Ptr);
      s := s + ' ' + FormatDecRight(IntToStr(Ptr^), 8);
      inc(Ptr);
      s := s + ' ' + FormatDecRight(IntToStr(Ptr^), 8);
      inc(Ptr);
      Lines.Add(s);
      s := IntToStr(36) + ':' + FormatDecRight(IntToStr(Ptr^), 8);
      inc(Ptr);
      s := s + ' ' + FormatDecRight(IntToStr(Ptr^), 8);
      inc(Ptr);
      s := s + ' ' + FormatDecRight(IntToStr(Ptr^), 8);
      inc(Ptr);
      s := s + ' ' + FormatDecRight(IntToStr(Ptr^), 8) + ' ... ';
      Lines.Add(s);
    end;
  end
  else
  begin
    with memo do
    begin
      s := 'Pojedinacni elementi:  ' + #13#10 + IntToStr(20)
        + ':' + FormatDecRight(IntToHex(Ptr^, 8), 8);
      inc(Ptr);
      s := s + ' ' + FormatDecRight(IntToHex(Ptr^, 8), 8);
      inc(Ptr);
      s := s + ' ' + FormatDecRight(IntToHex(Ptr^, 8), 8);
      inc(Ptr);
      s := s + ' ' + FormatDecRight(IntToHex(Ptr^, 8), 8);
      inc(Ptr);
      Lines.Add(s);
      s := IntToStr(36) + ':' + FormatDecRight(IntToHex(Ptr^, 8), 8);
      inc(Ptr);
      s := s + ' ' + FormatDecRight(IntToHex(Ptr^, 8), 8);
      inc(Ptr);
      s := s + ' ' + FormatDecRight(IntToHex(Ptr^, 8), 8);
      inc(Ptr);
      s := s + ' ' + FormatDecRight(IntToHex(Ptr^, 8), 8) + ' ... ';
      Lines.Add(s);
    end;
  end;
end;

procedure TfrGlavna.OffsetBinarno(Ptr: PByte; memo: TMemo; dec: boolean);
var
  s: string;
begin
  if dec then
  begin
    with memo do
    begin
      s := 'Pojedinacni biti:  ' + #13#10 + IntToStr(20) + ':' + ByteToBin
        (Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      Lines.Add(s);
      s := IntToStr(36) + ':' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      Lines.Add(s);
      s := IntToStr(52) + ':' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      Lines.Add(s);
      s := IntToStr(68) + ':' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^) + ' ... ';
      Lines.Add(s);
    end;
  end
  else
  begin
    with memo do
    begin
      s := 'Pojedinacni biti:  ' + #13#10 + IntToHex(20, 8) + ':' + ByteToBin
        (Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      Lines.Add(s);
      s := IntToHex(36, 8) + ':' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      Lines.Add(s);
      s := IntToHex(52, 8) + ':' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      Lines.Add(s);
      s := IntToHex(68, 8) + ':' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^) + ' ... ';
      Lines.Add(s);
    end;
  end;

end;

procedure TfrGlavna.OffsetBinarnoPIP(Ptr: PByte; memo: TMemo; dec: boolean);
var
  s: string;
begin
  if dec then
  begin
    with memo do
    begin
      s := 'Pojedinacni biti:  ' + #13#10 + IntToStr(20) + ':' + ByteToBin
        (Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      Lines.Add(s);
      s := IntToStr(28) + ':' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      Lines.Add(s);
      s := IntToStr(36) + ':' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      Lines.Add(s);
      s := IntToStr(44) + ':' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^) + ' ... ';
      Lines.Add(s);
    end;
  end
  else
  begin
    with memo do
    begin
      s := 'Pojedinacni biti:  ' + #13#10 + IntToHex(20, 8) + ':' + ByteToBin
        (Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      Lines.Add(s);
      s := IntToHex(28, 8) + ':' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      Lines.Add(s);
      s := IntToHex(36, 8) + ':' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      Lines.Add(s);
      s := IntToHex(44, 8) + ':' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^);
      inc(Ptr);
      s := s + ' ' + ByteToBin(Ptr^) + ' ... ';
      Lines.Add(s);
    end;
  end;

end;

procedure TfrGlavna.GetPIP(offset: integer);
var
  Ptr: PByte;
begin
  if not assigned(in_file) then
    exit;
  if Trim(in_file_name) = '' then
  begin
    ShowMessage('Ucitajte neku datoteku!');
    exit;
  end;

  in_file := TFileStream.Create(in_file_name, fmOpenRead or fmShareDenyNone);
  in_file.Position := offset;
  in_file.Read(PageInvPage, sizeof(PageInvPage));
  in_file.Free;

  if frGlavna.rgPrikaziPIP.ItemIndex = 0 then
  begin
    with mPIP do
    begin
      Lines.Clear;
      Lines.Add('Page Inventory Page');
      with frGlavna.PageInvPage do
      begin
        Lines.Add(
          '    START of Standard page header - svaka stranica ima na pocetku standardno zaglavlje');
        Lines.Add('        page_type:            ' + FormatDec
            (IntToStr(pagHdr_Header.page_type)) +
            ' | Oznaceni bajt. 0x0 - nedefinisano, 0x1 - Header Page, 0x2 - Page Inventory Page...');
        Lines.Add('        page_flags:           ' + FormatDec
            (IntToStr(pagHdr_Header.page_flags)) +
            ' | Neoznaceni bajt, razliciti flegovi');
        Lines.Add('        page_checksum:        ' + FormatDec
            (IntToStr(pagHdr_Header.page_checksum)) +
            ' | Dva neoznacena bajta. Checksum se vise ne koristi (uvijek je 12345). Moguce je da ce od ver.3.0 imati drugu svrhu.');
        Lines.Add('        page_generation:      ' + FormatDec
            (IntToStr(pagHdr_Header.page_generation)) +
            ' | Cetiri neoznacena bajta. Uvecava se svaki put kada stranicu upisemo na disk (npr. backup-om)');
        Lines.Add('        page_sequence_number: ' + FormatDec
            (IntToStr(pagHdr_Header.page_sequence_number)) +
            ' | Cetiri neoznacena bajta. Ranije ih je koristio Write Ahead Log. Trenutno ih koristi nbackup.');
        Lines.Add('        page_reserved:        ' + FormatDec
            (IntToStr(pagHdr_Header.page_reserved)) +
            ' | Cetiri neoznacena bajta. Rezervisani su za buducu upotrebu.');
        Lines.Add('    END of Standard page header');
        Lines.Add('    Pip_min:                  ' + FormatDec
            (IntToStr(pip_min)) +
            ' | Cetiri oznacena bajta. Prikazuju koliko je bita na ovoj PIP strani zauzeto/slobodno za upotrebu.');
        Lines.Add('    Pip_bits[0]:              ' + FormatDec
            (IntToStr(pip_bits[0])) +
            ' | Jedan bajt. Pocetak niza pojedinacnih bita, gdje svaki bit u nizu predstavlja jednu stranicu. Ako je bit postavljen (1), stranica je slobodna, a ako nije (0) onda je zauzeta.');
        Lines.Add(
          '                                                        | Ako su stranice dugacke 4096 bajta, preostaje jos 4076 bajta za predstavljanje stranica. ');
        Lines.Add(
          '                                                        | U svakom bajtu po 8 bita, znaci do kraja ove PIP stranice imamo prostora da predstavimo ');
        Lines.Add(
          '                                                        | 32,608 stranica, prije nego sto se pojavi potreba za novom PIP stranicom.');
        Lines.Add('');
        Ptr := @PageInvPage.pip_bits[1];
        OffsetBinarnoPIP(Ptr, mPIP, True { true znaci formatiraj decimalno } );
      end; // with frGlavna.PageInvPage do
    end; // with mPIP do
  end
  else
  begin
    with mPIP do
    begin
      Lines.Clear;
      Lines.Add('Page Inventory Page');
      with frGlavna.PageInvPage do
      begin
        Lines.Add(
          '    START of Standard page header - svaka stranica ima na pocetku standardno zaglavlje');
        Lines.Add('        page_type:            ' + FormatDec
            (IntToHex(pagHdr_Header.page_type, 2)) +
            ' | Oznaceni bajt. 0x0 - nedefinisano, 0x1 - Header Page, 0x2 - Page Inventory Page...');
        Lines.Add('        page_flags:           ' + FormatDec
            (IntToHex(pagHdr_Header.page_flags, 2)) +
            ' | Neoznaceni bajt, razliciti flegovi');
        Lines.Add('        page_checksum:        ' + FormatDec
            (IntToHex(pagHdr_Header.page_checksum, 4)) +
            ' | Dva neoznacena bajta. Checksum se vise ne koristi (uvijek je 12345). Moguce je da ce od ver.3.0 imati drugu svrhu.');
        Lines.Add('        page_generation:      ' + FormatDec
            (IntToHex(pagHdr_Header.page_generation, 8)) +
            ' | Cetiri neoznacena bajta. Uvecava se svaki put kada stranicu upisemo na disk (npr. backup-om)');
        Lines.Add('        page_sequence_number: ' + FormatDec
            (IntToHex(pagHdr_Header.page_sequence_number, 8)) +
            ' | Cetiri neoznacena bajta. Ranije ih je koristio Write Ahead Log. Trenutno ih koristi nbackup.');
        Lines.Add('        page_reserved:        ' + FormatDec
            (IntToHex(pagHdr_Header.page_reserved, 8)) +
            ' | Cetiri neoznacena bajta. Rezervisani su za buducu upotrebu.');
        Lines.Add('    END of Standard page header');
        Lines.Add('    Pip_min:                  ' + FormatDec
            (IntToHex(pip_min, 8)) +
            ' | Cetiri oznacena bajta. Prikazuju koliko je bita na ovoj PIP strani zauzeto/slobodno za upotrebu.');
        Lines.Add('    Pip_bits[0]:              ' + FormatDec
            (IntToHex(pip_bits[0], 2)) +
            ' | Jedan bajt. Pocetak niza pojedinacnih bita, gdje svaki bit u nizu predstavlja jednu stranicu. Ako je bit postavljen (1), stranica je slobodna, a ako nije (0) onda je zauzeta.');
        Lines.Add(
          '                                                        | Ako su stranice dugacke 4096 bajta, preostaje jos 4076 bajta za predstavljanje stranica. ');
        Lines.Add(
          '                                                        | U svakom bajtu po 8 bita, znaci do kraja ove PIP stranice imamo prostora da predstavimo ');
        Lines.Add(
          '                                                        | 32,608 stranica, prije nego sto se pojavi potreba za novom PIP stranicom.');
        Lines.Add('');
        Ptr := @PageInvPage.pip_bits[1];
        OffsetBinarnoPIP(Ptr, mPIP, false);
      end; // with frGlavna.PageInvPage do
    end; // with mPIP do
  end;

end;

procedure TfrGlavna.GetTransactionIP(offset: integer);
var
  Ptr: PByte;
begin
  if not assigned(in_file) then
    exit;
  if Trim(in_file_name) = '' then
  begin
    ShowMessage('Ucitajte neku datoteku!');
    exit;
  end;

  in_file := TFileStream.Create(in_file_name, fmOpenRead or fmShareDenyNone);
  in_file.Position := offset;
  in_file.Read(TransactionInvPage, sizeof(TransactionInvPage));
  in_file.Free;

  if frGlavna.rgPrikaziTRansactionIP.ItemIndex = 0 then
  begin
    with mTransactionIP do
    begin
      Lines.Clear;
      Lines.Add('Transaction Inventory Page');
      Lines.Add('Offset u datoteci: ' + IntToStr
          (FirstTIPPage * Header_Page.hdr_page_size));
      with frGlavna.TransactionInvPage do
      begin
        Lines.Add(
          '    START of Standard page header - svaka stranica ima na pocetku standardno zaglavlje');
        Lines.Add('        page_type:            ' + FormatDec
            (IntToStr(pagHdr_Header.page_type)) +
            ' | Oznaceni bajt. 0x0 - nedefinisano, 0x1 - Header Page, 0x2 - Page Inventory Page...');
        Lines.Add('        page_flags:           ' + FormatDec
            (IntToStr(pagHdr_Header.page_flags)) +
            ' | Neoznaceni bajt, razliciti flegovi');
        Lines.Add('        page_checksum:        ' + FormatDec
            (IntToStr(pagHdr_Header.page_checksum)) +
            ' | Dva neoznacena bajta. Checksum se vise ne koristi (uvijek je 12345). Moguce je da ce od ver.3.0 imati drugu svrhu.');
        Lines.Add('        page_generation:      ' + FormatDec
            (IntToStr(pagHdr_Header.page_generation)) +
            ' | Cetiri neoznacena bajta. Uvecava se svaki put kada stranicu upisemo na disk (npr. backup-om)');
        Lines.Add('        page_sequence_number: ' + FormatDec
            (IntToStr(pagHdr_Header.page_sequence_number)) +
            ' | Cetiri neoznacena bajta. Ranije ih je koristio Write Ahead Log. Trenutno ih koristi nbackup.');
        Lines.Add('        page_reserved:        ' + FormatDec
            (IntToStr(pagHdr_Header.page_reserved)) +
            ' | Cetiri neoznacena bajta. Rezervisani su za buducu upotrebu.');
        Lines.Add('    END of Standard page header');
        Lines.Add('    Tip_next:                 ' + FormatDec
            (IntToStr(tip_next)) +
            ' | Cetiri oznacena bajta. Broj stranice na kojoj se nalazi slijedeca TIP stranica.');
        Lines.Add('    tip_transactions[0]:      ' + FormatDec
            (IntToStr(tip_transactions[0])) +
            ' | Jedan bajt. Pocetak niza pojedinacnih bita, gdje svaki par bita predstavlja jednu transakciju i njeno stanje.');
        Lines.Add(
          '                                                        | Vrijednosti: 0x00 - transakcija je aktivna ili jos nije startovala, ');
        Lines.Add(
          '                                                        |              0x01 - transakcija je Limbo (dvofazna transakcija - prva faza je potvrdjena, ali druga faza jos nije), ');
        Lines.Add(
          '                                                        |              0x02 - transakcija je ''mrtva'' - rollback-ovana');
        Lines.Add(
          '                                                        |              0x03 - transakcija je potvrdjena - commit-ovana');
        Lines.Add('');
        Ptr := @TransactionInvPage.tip_transactions[0];
        OffsetBinarno(Ptr, mTransactionIP, True
          { true znaci formatiraj decimalno } );
      end; // with frGlavna.PageInvPage do
    end; // with mPIP do
  end
  else
  begin
    with mTransactionIP do
    begin
      Lines.Clear;
      Lines.Add('Transaction Inventory Page');
      Lines.Add('Offset u datoteci: ' + IntToHex
          (FirstTIPPage * Header_Page.hdr_page_size, 12));
      with frGlavna.TransactionInvPage do
      begin
        Lines.Add(
          '    START of Standard page header - svaka stranica ima na pocetku standardno zaglavlje');
        Lines.Add('        page_type:            ' + FormatDec
            (IntToHex(pagHdr_Header.page_type, 2)) +
            ' | Oznaceni bajt. 0x0 - nedefinisano, 0x1 - Header Page, 0x2 - Page Inventory Page...');
        Lines.Add('        page_flags:           ' + FormatDec
            (IntToHex(pagHdr_Header.page_flags, 2)) +
            ' | Neoznaceni bajt, razliciti flegovi');
        Lines.Add('        page_checksum:        ' + FormatDec
            (IntToHex(pagHdr_Header.page_checksum, 4)) +
            ' | Dva neoznacena bajta. Checksum se vise ne koristi (uvijek je 12345). Moguce je da ce od ver.3.0 imati drugu svrhu.');
        Lines.Add('        page_generation:      ' + FormatDec
            (IntToHex(pagHdr_Header.page_generation, 8)) +
            ' | Cetiri neoznacena bajta. Uvecava se svaki put kada stranicu upisemo na disk (npr. backup-om)');
        Lines.Add('        page_sequence_number: ' + FormatDec
            (IntToHex(pagHdr_Header.page_sequence_number, 8)) +
            ' | Cetiri neoznacena bajta. Ranije ih je koristio Write Ahead Log. Trenutno ih koristi nbackup.');
        Lines.Add('        page_reserved:        ' + FormatDec
            (IntToHex(pagHdr_Header.page_reserved, 8)) +
            ' | Cetiri neoznacena bajta. Rezervisani su za buducu upotrebu.');
        Lines.Add('    END of Standard page header');
        Lines.Add('    Tip_next:                 ' + FormatDec
            (IntToHex(tip_next, 8)) +
            ' | Cetiri oznacena bajta. Prikazuju koliko je bita na ovoj PIP strani slobodno za upotrebu.');
        Lines.Add('    tip_transactions[0]:      ' + FormatDec
            (IntToHex(tip_transactions[0], 2)) +
            ' | Jedan bajt. Pocetak niza pojedinacnih bita, gdje svaki par bita predstavlja jednu transakciju i njeno stanje.');
        Lines.Add(
          '                                                        | Vrijednosti: 0x00 - transakcija je aktivna ili jos nije startovala, ');
        Lines.Add(
          '                                                        |              0x01 - transakcija je Limbo (dvofazna transakcija - prva faza je potvrdjena, ali druga faza jos nije), ');
        Lines.Add(
          '                                                        |              0x02 - transakcija je ''mrtva'' - rollback-ovana');
        Lines.Add(
          '                                                        |              0x03 - transakcija je potvrdjena - commit-ovana');
        Lines.Add('');
        Ptr := @TransactionInvPage.tip_transactions[0];
        OffsetBinarno(Ptr, mTransactionIP, false);
      end; // with frGlavna.PageInvPage do
    end; // with mPIP do
  end;

end;

procedure TfrGlavna.lbDataPage0x05DblClick(Sender: TObject);
begin
  GetDataPage(StrToInt(lbDataPage0x05.Items[lbDataPage0x05.ItemIndex]));
  PageControl.ActivePage := Page0x05DataPage;
end;

function TfrGlavna.GetDataPageFlags(w: Word): string;
begin
  result := '';
  if (w and 1) = 1 then
    result := result + ' | Logicki obrisan';
  if (w and 2) = 2 then
    result := result + ' | Stara verzija';
  if (w and 4) = 4 then
    result := result + ' | Fragment';
  if (w and 8) = 8 then
    result := result + ' | Nekompletan';
  if (w and 16) = 16 then
    result := result + ' | Nije slog vec BLOB';
  if (w and 32) = 32 then
    result := result + ' | BLOB ili, ako je bit 4 nula razlika(delta)';
  if (w and 64) = 64 then
    result := result + ' | Veliki objekat';
  if (w and 128) = 128 then
    result := result + ' | Ostecen objekat';
  if (w and 256) = 256 then
    result := result + ' | Oznacen za Garbage Collection';

end;

function TfrGlavna.StringToHex(buf: string): string;
var
  Len: Cardinal;
  i: Cardinal;
  s: string;
begin
  s := '';
  result := '';
  Len := length(buf);
  If Len <> 0 Then
  begin
    For i := 0 to Len - 1 Do
    Begin
      result := result + IntToHex(Ord(buf[i]), 2) + ' ';
      if (buf[i] in [#0 .. #31]) then
        s := s + '.'
      else
        s := s + String(AnsiChar(buf[i]));
    end;
  end;
  if Len < 16 then
  begin
    Len := 16 - Len;
    for i := 0 to Len do
      result := result + '00';
  end;
  result := result + ' ';
  result := result + ' | ' + s;
end;

procedure TfrGlavna.lbDATA_dpg_repeatDblClick(Sender: TObject);
var
  s: AnsiString;
  rez, flegovi: string;
begin
  if rgPrikaziDataPage.ItemIndex = 0 then
  begin
    in_file := TFileStream.Create(in_file_name, fmOpenRead or fmShareDenyNone);
    { *** idemo na kraj stranice *** }
    in_file.Position := StrToInt
      (lbDataPage0x05.Items[lbDataPage0x05.ItemIndex]) + StrToInt
      (Trim(lbDATA_dpg_repeat.Items[lbDATA_dpg_repeat.ItemIndex]));

    // in_file.Read(Rhd_fragmented, SizeOf(Rhd_fragmented));
    in_file.Read(Rhd_UNfragmented, sizeof(Rhd_UNfragmented));
    SetLength(s, integer(lbDATA_dpg_repeat.Items.Objects
          [lbDATA_dpg_repeat.ItemIndex]));
    // prvi batj podataka je vec ucitan
    in_file.Position := in_file.Position - 1;
    in_file.ReadBuffer(Pointer(s)^, integer(lbDATA_dpg_repeat.Items.Objects
          [lbDATA_dpg_repeat.ItemIndex]));
    in_file.Free;
    with mDataPage do
    begin
      Lines.Add('----------------------------------------------');
      Lines.Add(
        'Adresa = DataPage(Offset u datoteci) + dpg_repeat[n].Dpg_offset');
      Lines.Add('Adresa = ' + lbDataPage0x05.Items[lbDataPage0x05.ItemIndex]
          + ' + ' + Trim(lbDATA_dpg_repeat.Items[lbDATA_dpg_repeat.ItemIndex]));
      with Rhd_UNfragmented do
      begin
        Lines.Add('   rhd_transaction:         ' + FormatDec
            (IntToStr(rhd_transaction)) +
            ' | Cetiri oznacena bajta. Broj transakcije koja je kreirala ovaj rekord.');
        Lines.Add('   rhd_b_page:              ' + FormatDec
            (IntToStr(rhd_b_page)) +
            ' | Cetiri oznacena bajta. Rekordova ''Back Pointer'' stranica.');
        Lines.Add('   rhd_b_line:              ' + FormatDec
            (IntToStr(rhd_b_line)) +
            ' | Dva neoznacena bajta. Rekordov ''Back Line Pointer''.');
        flegovi := GetDataPageFlags(rhd_flags);
        Lines.Add('   rhd_flags:               ' + FormatDec
            (IntToStr(rhd_flags)) + flegovi); // + ' | Dva neoznacena bajta. Razliciti flegovi');
        Lines.Add('   rhd_format:              ' + FormatDec
            (IntToStr(rhd_format)) +
            ' | Jedan neoznacen bajt. Verzija formata ovog rekorda.');
        Lines.Add('   rhd_data:                ' + FormatDec
            (IntToStr(rhd_data)) +
            ' | Jedan neoznacen bajt. Prvi bajt podataka.');
      end; // with Rhd_UNfragmented
      if (Rhd_UNfragmented.rhd_flags and 2) = 2 then
      begin
        mDataPage.Lines.Add('Sazeti podaci: ');
        mDataPage.Lines.Add(StringToHex(s));
        mDataPage.Lines.Add('  Stara verzija! ')
      end
      else
      begin
        mDataPage.Lines.Add('Sazeti podaci: ');
        mDataPage.Lines.Add('  ' + StringToHex(s));
        mDataPage.Lines.Add('Dekompresovani podaci: ');
        rez := RLE_Decompress(s);
        mDataPage.Lines.Add(rez);
      end;
    end;
  end
  else
  begin
    in_file := TFileStream.Create(in_file_name, fmOpenRead or fmShareDenyNone);
    { *** idemo na kraj stranice *** }
    in_file.Position := StrToInt
      (lbDataPage0x05.Items[lbDataPage0x05.ItemIndex]) + StrToInt
      ('$' + Trim(lbDATA_dpg_repeat.Items[lbDATA_dpg_repeat.ItemIndex]));

    // in_file.Read(Rhd_fragmented, SizeOf(Rhd_fragmented));
    in_file.Read(Rhd_UNfragmented, sizeof(Rhd_UNfragmented));
    SetLength(s, integer(lbDATA_dpg_repeat.Items.Objects
          [lbDATA_dpg_repeat.ItemIndex]));
    // prvi bajt podataka je vec ucitan
    in_file.Position := in_file.Position - 1;
    in_file.ReadBuffer(Pointer(s)^, integer(lbDATA_dpg_repeat.Items.Objects
          [lbDATA_dpg_repeat.ItemIndex]));
    in_file.Free;

    with mDataPage do
    begin
      Lines.Add('----------------------------------------------');
      Lines.Add(
        'Adresa = DataPage(Offset u datoteci) + dpg_repeat[n].Dpg_offset');

      Lines.Add('Adresa = ' + IntToHex
          (StrToInt(lbDataPage0x05.Items[lbDataPage0x05.ItemIndex]), 8)
          + ' + ' + IntToHex(StrToInt(Trim('$' + lbDATA_dpg_repeat.Items
                [lbDATA_dpg_repeat.ItemIndex])), 8));
      with Rhd_UNfragmented do
      begin
        Lines.Add('   rhd_transaction:         ' + FormatDec
            (IntToHex(rhd_transaction, 8)) +
            ' | Cetiri oznacena bajta. Broj transakcije koja je kreirala ovaj rekord.');
        Lines.Add('   rhd_b_page:              ' + FormatDec
            (IntToHex(rhd_b_page, 8)) +
            ' | Cetiri oznacena bajta. Rekordova ''Back Pointer'' stranica.');
        Lines.Add('   rhd_b_line:              ' + FormatDec
            (IntToHex(rhd_b_line, 4)) +
            ' | Dva neoznacena bajta. Rekordov ''Back Line Pointer''.');
        flegovi := GetDataPageFlags(rhd_flags);
        Lines.Add('   rhd_flags:               ' + FormatDec
            (IntToHex(rhd_flags, 4)) + flegovi); // + FormatDec(IntToHex(rhd_flags, 4)) + ' | Dva neoznacena bajta. Razliciti flegovi');
        Lines.Add('   rhd_format:              ' + FormatDec
            (IntToHex(rhd_format, 2)) +
            ' | Jedan neoznacen bajt. Verzija formata ovog rekorda.');
        Lines.Add('   rhd_data:                ' + FormatDec
            (IntToHex(rhd_data, 2)) +
            ' | Jedan neoznacen bajt. Prvi bajt podataka.');
      end; // with Rhd_UNfragmented
      if (Rhd_UNfragmented.rhd_flags and 2) = 2 then
      begin
        mDataPage.Lines.Add('Sazeti podaci: ');
        mDataPage.Lines.Add(StringToHex(s));
        mDataPage.Lines.Add('  Stara verzija! ')
      end
      else
      begin
        mDataPage.Lines.Add('Sazeti podaci: ');
        mDataPage.Lines.Add('  ' + StringToHex(s));
        mDataPage.Lines.Add('Dekompresovani podaci: ');
        rez := RLE_Decompress(s);
        mDataPage.Lines.Add(rez);
      end;
    end;
  end

end;

procedure TfrGlavna.lbIndexBTree0x07DblClick(Sender: TObject);
begin
  GetIndexBtreePage(StrToInt(lbIndexBTree0x07.Items[lbIndexBTree0x07.ItemIndex])
    );
  PageControl.ActivePage := Page0x07IndexBtreePage;
end;

procedure TfrGlavna.lbIndexRoot0x06DblClick(Sender: TObject);
begin
  GetIndexRootPage(StrToInt(lbIndexRoot0x06.Items[lbIndexRoot0x06.ItemIndex]));
  PageControl.ActivePage := Page0x06IndexRoot;
end;

procedure TfrGlavna.lbIndexRoot_irt_descDblClick(Sender: TObject);
var
  rez: string;
  irtd_ods11: Tirtd_ods11;
  Ptr: PIrt_repeat;
  Irt_repeat: TIrt_repeat;
  PgOffset: integer;
begin

  if rgPrikaziIndexRoot.ItemIndex = 0 then
  begin
    in_file := TFileStream.Create(in_file_name, fmOpenRead or fmShareDenyNone);

    PgOffset := integer(lbIndexRoot_irt_desc.Items.Objects
        [lbIndexRoot_irt_desc.ItemIndex]);
    in_file.Position := StrToInt
      (lbIndexRoot0x06.Items[lbIndexRoot0x06.ItemIndex]) + PgOffset;
    in_file.Read(Irt_repeat, sizeof(TIrt_repeat));
    Ptr := @Irt_repeat;
    IndexRootPageDescriptor(Ptr, mIndexRoot, PgOffset);

    in_file.Position := StrToInt
      (lbIndexRoot0x06.Items[lbIndexRoot0x06.ItemIndex]) + StrToInt
      (Trim(lbIndexRoot_irt_desc.Items[lbIndexRoot_irt_desc.ItemIndex]));
    in_file.Read(irtd_ods11, sizeof(Tirtd_ods11));
    in_file.Free;
    with mIndexRoot do
    begin
      Lines.Add('Tirtd_ods11: ');
      Lines.Add('  -------------------------------------------------------');
      Lines.Add(
        '  Adresa = IndexRoot(Offset u datoteci) + irt_repeat[n].irt_desc');
      Lines.Add('  Adresa = ' + lbIndexRoot0x06.Items
          [lbIndexRoot0x06.ItemIndex] + ' + ' + Trim
          (lbIndexRoot_irt_desc.Items[lbIndexRoot_irt_desc.ItemIndex]));
      with irtd_ods11 do
      begin
        Lines.Add('     irtd_field:              ' + FormatDec
            (IntToStr(Irtd_field)) +
            ' | Dva neoznacena bajta. Broj kolone (polja) koja cini ovaj indeks.');
        Lines.Add('     irtd_itype:              ' + FormatDec
            (IntToStr(Irtd_itype)) + ' | Dva neoznacena bajta. Tip podatka.');
      end; // with irtd_ods11
    end;
  end
  else
  begin
    in_file := TFileStream.Create(in_file_name, fmOpenRead or fmShareDenyNone);

    PgOffset := integer(lbIndexRoot_irt_desc.Items.Objects
        [lbIndexRoot_irt_desc.ItemIndex]);
    in_file.Position := StrToInt
      (lbIndexRoot0x06.Items[lbIndexRoot0x06.ItemIndex]) + PgOffset;
    in_file.Read(Irt_repeat, sizeof(TIrt_repeat));
    Ptr := @Irt_repeat;
    IndexRootPageDescriptor(Ptr, mIndexRoot, PgOffset);

    in_file.Position := StrToInt
      (lbIndexRoot0x06.Items[lbIndexRoot0x06.ItemIndex]) + StrToInt
      ('$' + Trim(lbIndexRoot_irt_desc.Items[lbIndexRoot_irt_desc.ItemIndex]));
    in_file.Read(irtd_ods11, sizeof(Tirtd_ods11));
    in_file.Free;
    with mIndexRoot do
    begin
      Lines.Add('Tirtd_ods11: ');
      Lines.Add('  -------------------------------------------------------');
      Lines.Add(
        '  Adresa = IndexRoot(Offset u datoteci) + irt_repeat[n].irt_desc');
      Lines.Add('  Adresa = ' + IntToHex
          (StrToInt(lbIndexRoot0x06.Items[lbIndexRoot0x06.ItemIndex]), 8)
          + ' + ' + Trim(lbIndexRoot_irt_desc.Items
            [lbIndexRoot_irt_desc.ItemIndex]));
      with irtd_ods11 do
      begin
        Lines.Add('     irtd_field:              ' + FormatDec
            (IntToHex(Irtd_field, 4)) +
            ' | Dva neoznacena bajta. Broj kolone (polja) koja cini ovaj indeks.');
        Lines.Add('     irtd_itype:              ' + FormatDec
            (IntToHex(Irtd_itype, 4)) +
            ' | Dva neoznacena bajta. Tip podatka.');
      end; // with irtd_ods11
    end;
  end;
  if (irtd_ods11.Irtd_itype = 0) then
    rez := rez +
      '                              : Polje je numericko, ali nije 64-bitni integer'
  else if (irtd_ods11.Irtd_itype = 1) then
    rez := rez + '                              : Polje je tipa string'
  else if (irtd_ods11.Irtd_itype = 3) then
    rez := rez + '                              : Polje je niz bajta'
  else if (irtd_ods11.Irtd_itype = 4) then
    rez := rez + '                              : Polje sadrzi metapodatke'
  else if (irtd_ods11.Irtd_itype = 5) then
    rez := rez + '                              : Polje je tipa Date'
  else if (irtd_ods11.Irtd_itype = 6) then
    rez := rez + '                              : Polje je tipa Time'
  else if (irtd_ods11.Irtd_itype = 7) then
    rez := rez + '                              : Polje je tipa TimeStamp'
  else if (irtd_ods11.Irtd_itype = 8) then
    rez := rez +
      '                              : Polje je numericko i jeste 64-bitni integer';
  mIndexRoot.Lines.Add(rez);
  mIndexRoot.Lines.Add('     Irtd_selectivity:   ' + FormatFloat
      ('0.000000000', irtd_ods11.Irtd_selectivity) +
      '                    | Cetiri bajta. Selektivnost indeksa.');
  mIndexRoot.Lines.Add(
    '  -------------------------------------------------------');

end;

procedure TfrGlavna.lbPIPDblClick(Sender: TObject);
begin
  GetPIP(StrToInt(lbPIP.Items[lbPIP.ItemIndex]));
  PageControl.ActivePage := Page0x02PiP;
end;

procedure TfrGlavna.lbPointerTOPDblClick(Sender: TObject);
begin
  GetPointerPage(StrToInt(lbPointerTOP.Items[lbPointerTOP.ItemIndex]));
  PageControl.ActivePage := Page0x04PointerPage;
end;

procedure TfrGlavna.lbTIPDblClick(Sender: TObject);
begin
  GetTransactionIP(StrToInt(lbTIP.Items[lbTIP.ItemIndex]));
  PageControl.ActivePage := Page0x03TransactionInventoryPage;
end;

procedure TfrGlavna.GetPointerPage(offset: integer);
var
  Ptr: PLongint;
begin
  if not assigned(in_file) then
    exit;
  if Trim(in_file_name) = '' then
  begin
    ShowMessage('Ucitajte neku datoteku!');
    exit;
  end;

  in_file := TFileStream.Create(in_file_name, fmOpenRead or fmShareDenyNone);
  in_file.Position := offset;
  in_file.Read(PointerPage, sizeof(PointerPage));
  in_file.Free;

  if frGlavna.rgPrikaziPointerPage.ItemIndex = 0 then
  begin
    with mPointerPage do
    begin
      Lines.Clear;
      Lines.Add('Pointer Page');
      Lines.Add('Offset u datoteci: ' + IntToStr(offset));
      with frGlavna.PointerPage do
      begin
        Lines.Add(
          '    START of Standard page header - svaka stranica ima na pocetku standardno zaglavlje');
        Lines.Add('        page_type:            ' + FormatDec
            (IntToStr(pagHdr_Header.page_type)) +
            ' | Oznaceni bajt. 0x0 - nedefinisano, 0x1 - Header Page, 0x2 - Page Inventory Page...');
        Lines.Add('        page_flags:           ' + FormatDec
            (IntToStr(pagHdr_Header.page_flags)) +
            ' | Neoznaceni bajt, razliciti flegovi');
        Lines.Add('        page_checksum:        ' + FormatDec
            (IntToStr(pagHdr_Header.page_checksum)) +
            ' | Dva neoznacena bajta. Checksum se vise ne koristi (uvijek je 12345). Moguce je da ce od ver.3.0 imati drugu svrhu.');
        Lines.Add('        page_generation:      ' + FormatDec
            (IntToStr(pagHdr_Header.page_generation)) +
            ' | Cetiri neoznacena bajta. Uvecava se svaki put kada stranicu upisemo na disk (npr. backup-om)');
        Lines.Add('        page_sequence_number: ' + FormatDec
            (IntToStr(pagHdr_Header.page_sequence_number)) +
            ' | Cetiri neoznacena bajta. Ranije ih je koristio Write Ahead Log. Trenutno ih koristi nbackup.');
        Lines.Add('        page_reserved:        ' + FormatDec
            (IntToStr(pagHdr_Header.page_reserved)) +
            ' | Cetiri neoznacena bajta. Rezervisani su za buducu upotrebu.');
        Lines.Add('    END of Standard page header');
        Lines.Add('    --------------------------------------------------');
        Lines.Add('    page_flags = 1 oznacava zadnju stranicu ovog tipa.');
        Lines.Add('    --------------------------------------------------');
        Lines.Add('    ppg_sequence:             ' + FormatDec
            (IntToStr(ppg_sequence)) +
            ' | Cetiri oznacena bajta. Sekvencijalni broj ove stranice u nizu pointer stranica.');
        Lines.Add('    ppg_next:                 ' + FormatDec
            (IntToStr(ppg_next)) +
            ' | Cetiri oznacena bajta. Broj slijedece pointer stranice. Nula indicira zadnju stranicu');
        Lines.Add('    ppg_count:                ' + FormatDec
            (IntToStr(ppg_count)) +
            ' | Dva neoznacena bajta. Broj aktivnih slotova u ppg_page[] nizu.'
          );
        Lines.Add('    ppg_relation:             ' + FormatDec
            (IntToStr(ppg_relation)) +
            ' | Dva neoznacena bajta. Ovo polje drzi ID relacije (RDB$RELATIONS.RDB$REALTION_ID) za tabelu koju predstavlja ova pointer stranica.');
        Lines.Add('    ppg_min_space:            ' + FormatDec
            (IntToStr(ppg_min_space)) +
            ' | Dva neoznacena bajta. Pokazuje na prvu stavku u ppg_page nizu koja ima slobodnog prostora na strani.');
        Lines.Add('    ppg_max_space:            ' + FormatDec
            (IntToStr(ppg_max_space)) +
            ' | Dva neoznacena bajta. Do sada nije koristeno. Namjera je bila da pokazuje na zadnju stavku u ppg_page nizu koja ima slobodnog prostora.');
        Lines.Add('    ppg_page[0]:              ' + FormatDec
            (IntToStr(ppg_page[0])) +
            ' | Cetiri oznacena bajta. Pocetak niza u kom svaka stavka drzi broj stranice na kojoj se nalazi dio podataka odabrane tabele.');
        Lines.Add(
          '                                                        | Prva relacija je RDB$PAGES. Mozemo je vidjeti pomocu upita ''select * from RDB$RELATIONS''.');

        Lines.Add('');
        Ptr := @PointerPage.ppg_page[0];
        OffsetLongInt(Ptr, mPointerPage, True { true znaci formatiraj dec } );
      end; // with frGlavna.PageInvPage do
    end; // with mPIP do
  end
  else
  begin
    with mPointerPage do
    begin
      Lines.Clear;
      Lines.Add('Pointer Page');
      Lines.Add('Offset u datoteci: ' + IntToHex(offset, 12));
      with frGlavna.PointerPage do
      begin
        Lines.Add(
          '    START of Standard page header - svaka stranica ima na pocetku standardno zaglavlje');
        Lines.Add('        page_type:            ' + FormatDec
            (IntToHex(pagHdr_Header.page_type, 2)) +
            ' | Oznaceni bajt. 0x0 - nedefinisano, 0x1 - Header Page, 0x2 - Page Inventory Page...');
        Lines.Add('        page_flags:           ' + FormatDec
            (IntToHex(pagHdr_Header.page_flags, 2)) +
            ' | Neoznaceni bajt, razliciti flegovi');
        Lines.Add('        page_checksum:        ' + FormatDec
            (IntToHex(pagHdr_Header.page_checksum, 4)) +
            ' | Dva neoznacena bajta. Checksum se vise ne koristi (uvijek je 12345). Moguce je da ce od ver.3.0 imati drugu svrhu.');
        Lines.Add('        page_generation:      ' + FormatDec
            (IntToHex(pagHdr_Header.page_generation, 8)) +
            ' | Cetiri neoznacena bajta. Uvecava se svaki put kada stranicu upisemo na disk (npr. backup-om)');
        Lines.Add('        page_sequence_number: ' + FormatDec
            (IntToHex(pagHdr_Header.page_sequence_number, 8)) +
            ' | Cetiri neoznacena bajta. Ranije ih je koristio Write Ahead Log. Trenutno ih koristi nbackup.');
        Lines.Add('        page_reserved:        ' + FormatDec
            (IntToHex(pagHdr_Header.page_reserved, 8)) +
            ' | Cetiri neoznacena bajta. Rezervisani su za buducu upotrebu.');
        Lines.Add('    END of Standard page header');
        Lines.Add('    --------------------------------------------------');
        Lines.Add('    page_flags = 1 oznacava zadnju stranicu ovog tipa.');
        Lines.Add('    --------------------------------------------------');
        Lines.Add('    ppg_sequence:             ' + FormatDec
            (IntToHex(ppg_sequence, 8)) +
            ' | Cetiri oznacena bajta. Sekvencijalni broj ove stranice u nizu pointer stranica.');
        Lines.Add('    ppg_next:                 ' + FormatDec
            (IntToHex(ppg_next, 8)) +
            ' | Cetiri oznacena bajta. Broj slijedece pointer stranice. Nula indicira zadnju stranicu');
        Lines.Add('    ppg_count:                ' + FormatDec
            (IntToHex(ppg_count, 4)) +
            ' | Dva neoznacena bajta. Broj aktivnih slotova u ppg_page[] nizu.'
          );
        Lines.Add('    ppg_relation:             ' + FormatDec
            (IntToHex(ppg_relation, 4)) +
            ' | Dva neoznacena bajta. Ovo polje drzi ID relacije (RDB$RELATIONS.RDB$REALTION_ID) za tabelu koju predstavlja ova pointer stranica.');
        Lines.Add('    ppg_min_space:            ' + FormatDec
            (IntToHex(ppg_min_space, 4)) +
            ' | Dva neoznacena bajta. Pokazuje na prvu stavku u ppg_page nizu koja ima slobodnog prostora na strani.');
        Lines.Add('    ppg_max_space:            ' + FormatDec
            (IntToHex(ppg_max_space, 4)) +
            ' | Dva neoznacena bajta. Do sada nije koristeno. Namjera je bila da pokazuje na zadnju stavku u ppg_page nizu koja ima slobodnog prostora.');
        Lines.Add('    ppg_page[0]:              ' + FormatDec
            (IntToHex(ppg_page[0], 8)) +
            ' | Cetiri oznacena bajta. Pocetak niza u kom svaka stavka drzi broj stranice na kojoj se nalazi dio podataka odabrane tabele.');
        Lines.Add(
          '                                                        | Prva relacija je RDB$PAGES. Mozemo je vidjeti pomocu upita ''select * from RDB$RELATIONS''.');

        Lines.Add('');
        Ptr := @PointerPage.ppg_page[0];
        OffsetLongInt(Ptr, mPointerPage, false { false znaci formatiraj hex } );
      end; // with frGlavna.PageInvPage do
    end; // with mPIP do
  end;

end;

procedure TfrGlavna.GetDataPage(offset: integer);
var
  listDPG_Repeat: TDpg_repeat;
  i: integer;
begin
  if Trim(in_file_name) = '' then
  begin
    ShowMessage('Ucitajte neku datoteku!');
    exit;
  end;
  // IndexDataPage
  in_file := TFileStream.Create(in_file_name, fmOpenRead or fmShareDenyNone);
  in_file.Position := offset;
  in_file.Read(DataPage, sizeof(DataPage));
  in_file.Free;

  // decimalni prikaz
  if frGlavna.rgPrikaziDataPage.ItemIndex = 0 then
  begin
    with mDataPage do
    begin
      Lines.Clear;
      Lines.Add('Data Page');
      Lines.Add('Offset u datoteci: ' + IntToStr(offset));
      Lines.Add('');
      Lines.Add('Duzina DataPage header-a: ' + IntToStr(sizeof(DataPage)));
      Lines.Add('POCETAK DataPage header-a');
      with frGlavna.DataPage do
      begin
        Lines.Add(
          'POCETAK Standard page header-a - svaka stranica ima na pocetku standardno zaglavlje');
        Lines.Add('    page_type:                ' + FormatDec
            (IntToStr(pagHdr_Header.page_type)) +
            ' | Oznaceni bajt. 0x05 - Data Page (0x0 - nedefinisano, 0x1 - Header Page, 0x2 - Page Inventory Page...)');
        Lines.Add('    page_flags:               ' + FormatDec
            (IntToStr(pagHdr_Header.page_flags)) +
            ' | Neoznaceni bajt, razliciti flegovi.');
        Lines.Add('    page_checksum:            ' + FormatDec
            (IntToStr(pagHdr_Header.page_checksum)) +
            ' | Dva neoznacena bajta. Checksum se vise ne koristi (uvijek je 12345). Moguce je da ce od ver.3.0 imati drugu svrhu.');
        Lines.Add('    page_generation:          ' + FormatDec
            (IntToStr(pagHdr_Header.page_generation)) +
            ' | Cetiri neoznacena bajta. Uvecava se svaki put kada stranicu upisemo na disk (npr. backup-om)');
        Lines.Add('    page_sequence_number:     ' + FormatDec
            (IntToStr(pagHdr_Header.page_sequence_number)) +
            ' | Cetiri neoznacena bajta. Ranije ih je koristio Write Ahead Log. Trenutno ih koristi nbackup.');
        Lines.Add('    page_reserved:            ' + FormatDec
            (IntToStr(pagHdr_Header.page_reserved)) +
            ' | Cetiri neoznacena bajta. Rezervisani su za buducu upotrebu.');
        Lines.Add('KRAJ Standard page header-a');
        Lines.Add('    dpg_sequence:             ' + FormatDec
            (IntToStr(dpg_sequence)) +
            ' | Cetiri oznacena bajta. Redni broj OVE stranice u listi stranica koja je dodjeljena OVOJ tabeli.');
        Lines.Add('    Dpg_relation:             ' + FormatDec
            (IntToStr(dpg_relation)) +
            ' | Dva neoznacena bajta. ID relacije (RDB$RELATION_ID u RDB$RELATIONS) ove tabele.');
        Lines.Add('    Dpg_count:                ' + FormatDec
            (IntToStr(dpg_count)) +
            ' | Dva neoznacena bajta. Broj rekorda (ili fragmenata rekorda) koji su zapisani na ovoj stranici (broj stavki u nizu Dpg_rpt).');

        Lines.Add(
          '    dpg_repeat:                                         | Niz dvobajtnih vrijednosti (dpg_offset, dpg_length).');
        Lines.Add('    dpg_repeat[0].Dpg_offset: ' + FormatDec
            (IntToStr(dpg_repeat[0].dpg_offset)) +
            ' | Dva neoznacena bajta. Offset (na stranici) na kojoj pocinje fragment rekorda');
        Lines.Add('    dpg_repeat[0].Dpg_length: ' + FormatDec
            (IntToStr(dpg_repeat[0].dpg_length)) +
            ' | Dva neoznacena bajta. Duzina fragmenta rekorda u bajtima.');
        Lines.Add('KRAJ Data header-a');
        Lines.Add('');

        in_file := TFileStream.Create(in_file_name,
          fmOpenRead or fmShareDenyNone);
        { *** DPG?Repeat niz *** }
        in_file.Position := offset + sizeof(DataPage);
        lbDATA_dpg_repeat.Items.Clear;
        lbDATA_dpg_repeat.AddItem(IntToStr(DataPage.dpg_repeat[0].dpg_offset),
          TObject(DataPage.dpg_repeat[0].dpg_length));
        for i := 1 to DataPage.dpg_count - 1 do
        begin
          in_file.Read(listDPG_Repeat, sizeof(listDPG_Repeat));
          lbDATA_dpg_repeat.AddItem(IntToStr(listDPG_Repeat.dpg_offset), TObject
              (listDPG_Repeat.dpg_length));
          // lbDATA_dpg_repeat.Items.Add(IntToStr(listDPG_Repeat.dpg_offset));
        end;

        { *** idemo na kraj stranice *** }
        in_file.Position := offset + dpg_repeat[0].dpg_offset;
        in_file.Read(Rhd_UNfragmented, sizeof(Rhd_UNfragmented));
        in_file.Free;

        Lines.Add('Na dnu stranice nalazi se prva TRhd_UNfragmented struktura');
        Lines.Add(
          'Adresa = DataPage(Offset u datoteci) + dpg_repeat[0].Dpg_offset');
        Lines.Add('Adresa = ' + IntToStr(offset) + ' + ' + IntToStr
            (dpg_repeat[0].dpg_offset));

        with Rhd_UNfragmented do
        begin
          Lines.Add('   rhd_transaction:         ' + FormatDec
              (IntToStr(rhd_transaction)) +
              ' | Cetiri oznacena bajta. Broj transakcije koja je kreirala ovaj rekord.');
          Lines.Add('   rhd_b_page:              ' + FormatDec
              (IntToStr(rhd_b_page)) +
              ' | Cetiri oznacena bajta. Rekordova ''Back Pointer'' stranica.');
          Lines.Add('   rhd_b_line:              ' + FormatDec
              (IntToStr(rhd_b_line)) +
              ' | Dva neoznacena bajta. Rekordov ''Back Line Pointer''.');
          Lines.Add('   rhd_flags:               ' + FormatDec
              (IntToStr(rhd_flags)) +
              ' | Dva neoznacena bajta. Razliciti flegovi');
          Lines.Add('   rhd_format:              ' + FormatDec
              (IntToStr(rhd_format)) +
              ' | Jedan neoznacen bajt. Verzija formata ovog rekorda.');
          Lines.Add('   rhd_data:                ' + FormatDec
              (IntToStr(rhd_data)) +
              ' | Jedan neoznacen bajt. Prvi bajt podataka.');
        end; // with Rhd_UNfragmented

      end; // with frGlavna.DataPage do

    end; // with mPIP do
  end
  else
  begin
    with mDataPage do
    begin
      Lines.Clear;
      Lines.Add('Data Page');
      Lines.Add('Offset u datoteci: ' + IntToHex(offset, 8));
      Lines.Add('');
      Lines.Add('Duzina DataPage header-a: ' + IntToStr(sizeof(DataPage)));
      Lines.Add('POCETAK DataPage header-a');
      with frGlavna.DataPage do
      begin
        Lines.Add(
          'POCETAK Standard page header-a - svaka stranica ima na pocetku standardno zaglavlje');
        Lines.Add('    page_type:                ' + FormatDec
            (IntToHex(pagHdr_Header.page_type, 2)) +
            ' | Oznaceni bajt. 0x0 - nedefinisano, 0x1 - Header Page, 0x2 - Page Inventory Page...');
        Lines.Add('    page_flags:               ' + FormatDec
            (IntToHex(pagHdr_Header.page_flags, 2)) +
            ' | Neoznaceni bajt, razliciti flegovi');
        Lines.Add('    page_checksum:            ' + FormatDec
            (IntToHex(pagHdr_Header.page_checksum, 4)) +
            ' | Dva neoznacena bajta. Checksum se vise ne koristi (uvijek je 12345). Moguce je da ce od ver.3.0 imati drugu svrhu.');
        Lines.Add('    page_generation:          ' + FormatDec
            (IntToHex(pagHdr_Header.page_generation, 8)) +
            ' | Cetiri neoznacena bajta. Uvecava se svaki put kada stranicu upisemo na disk (npr. backup-om)');
        Lines.Add('    page_sequence_number:     ' + FormatDec
            (IntToHex(pagHdr_Header.page_sequence_number, 8)) +
            ' | Cetiri neoznacena bajta. Ranije ih je koristio Write Ahead Log. Trenutno ih koristi nbackup.');
        Lines.Add('    page_reserved:            ' + FormatDec
            (IntToHex(pagHdr_Header.page_reserved, 8)) +
            ' | Cetiri neoznacena bajta. Rezervisani su za buducu upotrebu.');
        Lines.Add('KRAJ Standard page header-a');

        Lines.Add('    dpg_sequence:             ' + FormatDec
            (IntToHex(dpg_sequence, 8)) +
            ' | Cetiri oznacena bajta. Redni broj OVE stranice u listi stranica koja je dodjeljena OVOJ tabeli.');
        Lines.Add('    Dpg_relation:             ' + FormatDec
            (IntToHex(dpg_relation, 4)) +
            ' | Dva neoznacena bajta. ID relacije (RDB$RELATION_ID u RDB$RELATIONS) ove tabele.');
        Lines.Add('    Dpg_count:                ' + FormatDec
            (IntToHex(dpg_count, 4)) +
            ' | Dva neoznacena bajta. Broj rekorda (ili fragmenata rekorda) koji su zapisani na ovoj stranici (broj stavki u nizu Dpg_rpt).');

        Lines.Add(
          '    dpg_repeat:                                         | Niz dvobajtnih vrijednosti (dpg_offset, dpg_length).');
        Lines.Add('    dpg_repeat[0].Dpg_offset: ' + FormatDec
            (IntToHex(dpg_repeat[0].dpg_offset, 4)) +
            ' | Dva neoznacena bajta. Offset (na stranici) na kojoj pocinje fragment rekorda');
        Lines.Add('    dpg_repeat[0].Dpg_length: ' + FormatDec
            (IntToHex(dpg_repeat[0].dpg_length, 4)) +
            ' | Dva neoznacena bajta. Duzina fragmenta rekorda u bajtima/');
        Lines.Add('KRAJ Data header-a');
        Lines.Add('');

        in_file := TFileStream.Create(in_file_name,
          fmOpenRead or fmShareDenyNone);
        { *** DPG?Repeat niz *** }
        in_file.Position := offset + sizeof(DataPage);
        lbDATA_dpg_repeat.Items.Clear;
        lbDATA_dpg_repeat.AddItem
          (FormatDec(IntToHex(DataPage.dpg_repeat[0].dpg_offset, 8)), TObject
            (DataPage.dpg_repeat[0].dpg_length));

        // lbDATA_dpg_repeat.Items.Add( FormatDec(IntToHex(DataPage.dpg_repeat[0].dpg_offset, 8)) );
        for i := 1 to DataPage.dpg_count - 1 do
        begin
          in_file.Read(listDPG_Repeat, sizeof(listDPG_Repeat));
          lbDATA_dpg_repeat.AddItem
            (FormatDec(IntToHex(listDPG_Repeat.dpg_offset, 8)), TObject
              (listDPG_Repeat.dpg_length));
          // lbDATA_dpg_repeat.Items.Add(FormatDec(IntToHex(listDPG_Repeat.dpg_offset, 8)));
        end;

        { *** idemo na kraj stranice *** }
        in_file.Position := offset + dpg_repeat[0].dpg_offset;
        in_file.Read(Rhd_UNfragmented, sizeof(Rhd_UNfragmented));
        in_file.Free;

        Lines.Add('Na dnu stranice nalazi se prva TRhd_UNfragmented struktura');
        Lines.Add(
          'Adresa = DataPage(Offset u datoteci) + dpg_repeat[0].Dpg_offset');
        Lines.Add('Adresa = ' + IntToHex(offset, 8) + ' + ' + IntToHex
            (dpg_repeat[0].dpg_offset, 8));

        with Rhd_UNfragmented do
        begin
          Lines.Add('   rhd_transaction:         ' + FormatDec
              (IntToHex(rhd_transaction, 8)) +
              ' | Cetiri oznacena bajta. Broj transakcije koja je kreirala ovaj rekord.');
          Lines.Add('   rhd_b_page:              ' + FormatDec
              (IntToHex(rhd_b_page, 8)) +
              ' | Cetiri oznacena bajta. Rekordova ''Back Pointer'' stranica.');
          Lines.Add('   rhd_b_line:              ' + FormatDec
              (IntToHex(rhd_b_line, 4)) +
              ' | Dva neoznacena bajta. Rekordov ''Back Line Pointer''.');
          Lines.Add('   rhd_flags:               ' + FormatDec
              (IntToHex(rhd_flags, 4)) +
              ' | Dva neoznacena bajta. Razliciti flegovi');
          Lines.Add('   rhd_format:              ' + FormatDec
              (IntToHex(rhd_format, 2)) +
              ' | Jedan neoznacen bajt. Verzija formata ovog rekorda.');
          Lines.Add('   rhd_data:                ' + FormatDec
              (IntToHex(rhd_data, 2)) +
              ' | Jedan neoznacen bajt. Prvi bajt podataka.');
        end; // with Rhd_UNfragmented

      end; // with frGlavna.DataPage do

    end; // with mPIP do
  end;

end;

procedure TfrGlavna.IndexRootPageDescriptor(Ptr: PIrt_repeat; memo: TMemo;
  PgOffset: integer);
var
  iTmp, i: integer;
  sTmp: string;
begin

  with memo do
  begin
    if frGlavna.rgPrikaziIndexRoot.ItemIndex = 0 then
    begin
      Lines.Add('Irt_repeat na offsetu ' + IntToStr(PgOffset));
      Lines.Add('  -------------------------------------------------------');
      Lines.Add(
        '  Stavka u nizu indeks deskriptora (Irt_repeat). Kako se dodaju indeksi, tako se dodaju deskriptori od vrha ka dnu stranice.');
      Lines.Add('  irt_repeat[n].irt_root:                    ' + FormatDec
          (IntToStr(Ptr^.irt_root)) +
          ' | Cetiri oznacena bajta. Broj prve BTree stranice (0x07) na kojoj se nalazi pocetak ovog indeksa.');
      Lines.Add('  irt_repeat[n].irt_transaction:             ' + FormatDec
          (IntToStr(Ptr^.irt_transaction)) +
          ' | Cetiri oznacena bajta. Polje tipa UNION. irt_selectivity koji pokazuje selektivnost indeksa ili irt_transaction.');
      Lines.Add(
        '                                                                       | Ako je indeks u procesu kreiranja, ovdje ce biti ID transakcije koja ga obradjuje, inace nula.');
      Lines.Add('  irt_repeat[n].irt_desc:                    ' + FormatDec
          (IntToStr(Ptr^.irt_desc)) +
          ' | Dva neoznacena bajta. Offset od pocetka stranice prema deskriptorima polja indeksa (prema najvisoj adresi - dnu stranice).');
      Lines.Add(
        '                                                                       | Da bi izracunali stvarnu adresu, ovom polju treba dodati adresu pocetka stranice.');
      Lines.Add('  irt_repeat[n].irt_keys:                    ' + FormatDec
          (IntToStr(Ptr^.irt_keys)) +
          ' | Jedan neoznacen bajt. Broj kljuceva (kolona) ovog indeksa.');
      Lines.Add('  irt_repeat[n].irt_flags:                   ' + FormatDec
          (IntToStr(Ptr^.irt_flags)) +
          ' | Jedan neoznacen bajt. Razliciti flegovi.');
    end
    else
    begin
      Lines.Add('Irt_repeat na offsetu ' + IntToHex(PgOffset, 8));
      Lines.Add('  -------------------------------------------------------');
      Lines.Add(
        '  Stavka u nizu indeks deskriptora (Irt_repeat). Kako se dodaju indeksi, tako se dodaju deskriptori od vrha ka dnu stranice.');
      Lines.Add('  irt_repeat[n].irt_root:                    ' + FormatDec
          (IntToHex(Ptr^.irt_root, 8)) +
          ' | Cetiri oznacena bajta. Broj prve BTree stranice (0x07) na kojoj se nalazi pocetak ovog indeksa.');
      Lines.Add('  irt_repeat[n].irt_transaction:             ' + FormatDec
          (IntToHex(Ptr^.irt_transaction, 8)) +
          ' | Cetiri oznacena bajta. Polje tipa UNION. irt_selectivity koji pokazuje selektivnost indeksa ili irt_transaction.');
      Lines.Add(
        '                                                                       | Ako je indeks u procesu kreiranja, ovdje ce biti ID transakcije koja ga obradjuje, inace nula.');
      Lines.Add('  irt_repeat[n].irt_desc:                    ' + FormatDec
          (IntToHex(Ptr^.irt_desc, 4)) +
          ' | Dva neoznacena bajta. Offset od pocetka stranice prema deskriptorima polja indeksa (prema najvisoj adresi - dnu stranice).');
      Lines.Add(
        '                                                                       | Da bi izracunali stvarnu adresu, ovom polju treba dodati adresu pocetka stranice.');
      Lines.Add('  irt_repeat[n].irt_keys:                    ' + FormatDec
          (IntToHex(Ptr^.irt_keys, 2)) +
          ' | Jedan neoznacen bajt. Broj kljuceva (kolona) ovog indeksa.');
      Lines.Add('  irt_repeat[n].irt_flags:                   ' + FormatDec
          (IntToHex(Ptr^.irt_flags, 2)) +
          ' | Jedan neoznacen bajt. Razliciti flegovi.');
    end;

    sTmp := '                Bitovi: 0, 1, 2  |  Indeks: ';
    if (Ptr^.irt_flags and 1) = 1 then
      sTmp := sTmp + '<je UNIQUE>  '
    else
      sTmp := sTmp + '<nije UNIQUE>  ';

    if (Ptr^.irt_flags and 2) = 2 then
      sTmp := sTmp + '<je opadajuci (descending)>  '
    else
      sTmp := sTmp + '<je rastuci (ascending)>  ';

    if (Ptr^.irt_flags and 4) = 4 then
      sTmp := sTmp + '<kreiranje indeksa je u toku>  '
    else
      sTmp := sTmp + '<kreiranje indeksa je zavrseno (nije u toku)>  ';
    Lines.Add(sTmp);

    sTmp := '                Bitovi: 3, 4, 5  |  Indeks: ';
    if (Ptr^.irt_flags and 8) = 8 then
      sTmp := sTmp + '<je FOREIGN KEY>  '
    else
      sTmp := sTmp + '<nije FOREIGN KEY>  ';

    if (Ptr^.irt_flags and 16) = 16 then
      sTmp := sTmp + '<je PRIMARY KEY>  '
    else
      sTmp := sTmp + '<nije PRIMARY KEY>  ';

    if (Ptr^.irt_flags and 32) = 32 then
      sTmp := sTmp + '<indeks na osnovu izraza (Expression Based)>  '
    else
      sTmp := sTmp + '<Nije indeks na osnovu izraza (Not Expression Based)>  ';
    Lines.Add(sTmp);
    Lines.Add('  -------------------------------------------------------');

  end;
end;

procedure TfrGlavna.GetIndexRootPage(offset: integer);
var
  Ptr: PIrt_repeat;
  i, iTmp: integer;
  sTmp: string;
  Irt_rpt: TIrt_repeat;
begin
  if Trim(in_file_name) = '' then
  begin
    ShowMessage('Ucitajte neku datoteku!');
    exit;
  end;
  // IndexRootPage
  in_file := TFileStream.Create(in_file_name, fmOpenRead or fmShareDenyNone);
  in_file.Position := offset;
  in_file.Read(IndexRootPage, sizeof(IndexRootPage));

  in_file.Free;

  // decimalni prikaz
  if frGlavna.rgPrikaziIndexRoot.ItemIndex = 0 then
  begin
    with mIndexRoot do
    begin
      Lines.Clear;
      Lines.Add('Index Root Page');
      Lines.Add('Offset u datoteci: ' + IntToStr(offset));
      with frGlavna.IndexRootPage do
      begin
        Lines.Add(
          'START of Standard page header - svaka stranica ima na pocetku standardno zaglavlje');
        Lines.Add('    page_type:                ' + FormatDec
            (IntToStr(pagHdr_Header.page_type)) +
            ' | Oznaceni bajt. 0x06 - Index Root Page (0x0 - nedefinisano, 0x1 - Header Page, 0x2 - Page Inventory Page...)');
        Lines.Add('    page_flags:               ' + FormatDec
            (IntToStr(pagHdr_Header.page_flags)) +
            ' | Neoznaceni bajt, razliciti flegovi. Ne koriste se za ovaj tip stranice.');
        Lines.Add('    page_checksum:            ' + FormatDec
            (IntToStr(pagHdr_Header.page_checksum)) +
            ' | Dva neoznacena bajta. Checksum se vise ne koristi (uvijek je 12345). Moguce je da ce od ver.3.0 imati drugu svrhu.');
        Lines.Add('    page_generation:          ' + FormatDec
            (IntToStr(pagHdr_Header.page_generation)) +
            ' | Cetiri neoznacena bajta. Uvecava se svaki put kada stranicu upisemo na disk (npr. backup-om)');
        Lines.Add('    page_sequence_number:     ' + FormatDec
            (IntToStr(pagHdr_Header.page_sequence_number)) +
            ' | Cetiri neoznacena bajta. Ranije ih je koristio Write Ahead Log. Trenutno ih koristi nbackup.');
        Lines.Add('    page_reserved:            ' + FormatDec
            (IntToStr(pagHdr_Header.page_reserved)) +
            ' | Cetiri neoznacena bajta. Rezervisani su za buducu upotrebu.');
        Lines.Add('END of Standard page header');
        Lines.Add('irt_relation:                 ' + FormatDec
            (IntToStr(irt_relation)) +
            ' | Dva neoznacena bajta. ID relacije. Isti kao u RDB$RELATIONS.RDB$RELATION_ID.');
        Lines.Add('irt_count:                    ' + FormatDec
            (IntToStr(irt_count)) +
            ' | Dva neoznacena bajta. Broj indeksa definisanih za ovu stranicu. Cak i ako nema indeksa, stranica ce postojati, ali ce irt_count biti nula.');

        // Prva stavka u nizu irt_repeat
        Ptr := @IndexRootPage.Irt_repeat[0];
        IndexRootPageDescriptor(Ptr, mIndexRoot, 20);

        in_file := TFileStream.Create(in_file_name,
          fmOpenRead or fmShareDenyNone);
        { *** DPG?Repeat niz *** }
        in_file.Position := offset + sizeof(IndexRootPage);

        lbIndexRoot_irt_desc.Items.Clear;
        // lbIndexRoot_irt_desc.Items.Add( IntToStr(IndexRootPage.irt_repeat[0].irt_desc) );
        // Dno strane                                      Vrh strane
        lbIndexRoot_irt_desc.AddItem
          (IntToStr(IndexRootPage.Irt_repeat[0].irt_desc), TObject
            (sizeof(THdr_Header) + 4));
        for i := 1 to IndexRootPage.irt_count - 1 do
        begin
          in_file.Read(Irt_rpt, sizeof(TIrt_repeat));
          // lbIndexRoot_irt_desc.Items.Add(IntToStr(Irt_rpt.irt_desc) );
          lbIndexRoot_irt_desc.AddItem(IntToStr(Irt_rpt.irt_desc), TObject
              (sizeof(THdr_Header) + 4 + i * sizeof(TIrt_repeat)));
        end;
        in_file.Free;
      end; // with frGlavna.PageInvPage do
    end; // with mPIP do
  end
  else
  begin
    with mIndexRoot do
    begin
      Lines.Clear;
      Lines.Add('Index Root Page');
      Lines.Add('Offset u datoteci: ' + IntToHex(offset, 8));
      with frGlavna.IndexRootPage do
      begin
        Lines.Add(
          'START of Standard page header - svaka stranica ima na pocetku standardno zaglavlje');
        Lines.Add('    page_type:                ' + FormatDec
            (IntToHex(pagHdr_Header.page_type, 2)) +
            ' | Oznaceni bajt. 0x06 - Index Root Page (0x0 - nedefinisano, 0x1 - Header Page, 0x2 - Page Inventory Page...');
        Lines.Add('    page_flags:               ' + FormatDec
            (IntToHex(pagHdr_Header.page_flags, 2)) +
            ' | Neoznaceni bajt, razliciti flegovi. Ne koriste se za ovaj tip stranice.');
        Lines.Add('    page_checksum:            ' + FormatDec
            (IntToHex(pagHdr_Header.page_checksum, 4)) +
            ' | Dva neoznacena bajta. Checksum se vise ne koristi (uvijek je 12345). Moguce je da ce od ver.3.0 imati drugu svrhu.');
        Lines.Add('    page_generation:          ' + FormatDec
            (IntToHex(pagHdr_Header.page_generation, 8)) +
            ' | Cetiri neoznacena bajta. Uvecava se svaki put kada stranicu upisemo na disk (npr. backup-om)');
        Lines.Add('    page_sequence_number:     ' + FormatDec
            (IntToHex(pagHdr_Header.page_sequence_number, 8)) +
            ' | Cetiri neoznacena bajta. Ranije ih je koristio Write Ahead Log. Trenutno ih koristi nbackup.');
        Lines.Add('    page_reserved:            ' + FormatDec
            (IntToHex(pagHdr_Header.page_reserved, 8)) +
            ' | Cetiri neoznacena bajta. Rezervisani su za buducu upotrebu.');
        Lines.Add('END of Standard page header');

        Lines.Add('irt_relation:                 ' + FormatDec
            (IntToHex(irt_relation, 4)) +
            ' | Dva neoznacena bajta. ID relacije. Isti kao u RDB$RELATIONS.RDB$RELATION_ID.');
        Lines.Add('irt_count:                    ' + FormatDec
            (IntToHex(irt_count, 4)) +
            ' | Dva neoznacena bajta. Broj indeksa definisanih za ovu stranicu. Cak i ako nema indeksa, stranica ce postojati, ali ce irt_count biti nula.');

        Ptr := @IndexRootPage.Irt_repeat[0];
        IndexRootPageDescriptor(Ptr, mIndexRoot, 20);

        in_file := TFileStream.Create(in_file_name,
          fmOpenRead or fmShareDenyNone);
        { *** DPG?Repeat niz *** }
        in_file.Position := offset + sizeof(IndexRootPage);

        lbIndexRoot_irt_desc.Items.Clear;
        // lbIndexRoot_irt_desc.Items.Add(IntToHex(IndexRootPage.irt_repeat[0].irt_desc, 8) );
        lbIndexRoot_irt_desc.AddItem
          (IntToHex(IndexRootPage.Irt_repeat[0].irt_desc, 8), TObject
            (sizeof(THdr_Header) + 4));
        for i := 1 to IndexRootPage.irt_count - 1 do
        begin
          in_file.Read(Irt_rpt, sizeof(TIrt_repeat));
          // lbIndexRoot_irt_desc.Items.Add(IntToHex(Irt_rpt.irt_desc, 8) );
          lbIndexRoot_irt_desc.AddItem(IntToHex(Irt_rpt.irt_desc, 8), TObject
              (sizeof(THdr_Header) + 4 + i * sizeof(TIrt_repeat)));
        end;
        in_file.Free;
      end; // with frGlavna.PageInvPage do
    end; // with mPIP do
  end;

end;

procedure TfrGlavna.GetIndexBtreePage(offset: integer);
var
  ChData: array [0 .. 100] of Byte;
  PB: PByte;
  btr_level: boolean;
  IndexNode2, IndexNode3: TIndexNode;
begin
try
  if Trim(in_file_name) = '' then
  begin
    ShowMessage('Ucitajte neku datoteku!');
    exit;
  end;
  // IndexBtreePage
  in_file := TFileStream.Create(in_file_name, fmOpenRead or fmShareDenyNone);
  in_file.Position := offset;
  in_file.Read(IndexBtreePage, sizeof(IndexBtreePage));
  in_file.Read(IndexJumpInfo, sizeof(IndexJumpInfo));
  in_file.Position := offset + IndexJumpInfo.firstNodeOffset;
  in_file.Read(ChData, 100);

  btr_level := false;
  if IndexBtreePage.btr_level = 0 then // jeste list
    btr_level := True;
  PB := ReadNode(IndexNode, @(ChData), IndexBtreePage.pagHdr_Header.page_flags,
    btr_level);
  PB := ReadNode(IndexNode2, PB, IndexBtreePage.pagHdr_Header.page_flags,
    btr_level);
  PB := ReadNode(IndexNode3, PB, IndexBtreePage.pagHdr_Header.page_flags,
    btr_level);
  // in_file.Read(IndexJumpNode, SizeOf(IndexJumpNode));
  in_file.Free;

  // decimalni prikaz
  if frGlavna.rgPrikaziIndexBtree.ItemIndex = 0 then
  begin
    with mIndexBtree do
    begin
      Lines.Clear;
      Lines.Add('Index BTree Page');
      Lines.Add('Offset u datoteci: ' + IntToStr(offset));
      Lines.Add('');
      Lines.Add('Duzina B-Tree header-a: ' + IntToStr(sizeof(IndexBtreePage)));
      Lines.Add('POCETAK B-Tree header-a');
      with frGlavna.IndexBtreePage do
      begin
        Lines.Add(
          'POCETAK Standard page header-a - svaka stranica ima na pocetku standardno zaglavlje');
        Lines.Add('    page_type:                ' + FormatDec(IntToStr(pagHdr_Header.page_type)) +
            ' | Oznaceni bajt. 0x07 - Index BTree Page (0x7 - Index BTree Page. 0x0 - nedefinisano, 0x1 - Header Page, 0x2 - Page Inventory Page...)');
        Lines.Add('    page_flags:               ' + FormatDec(IntToStr(pagHdr_Header.page_flags)) +
            ' | Neoznaceni bajt, razliciti flegovi. Ne koriste se za ovaj tip stranice.');
        Lines.Add('    page_checksum:            ' + FormatDec(IntToStr(pagHdr_Header.page_checksum)) +
            ' | Dva neoznacena bajta. Checksum se vise ne koristi (uvijek je 12345). Moguce je da ce od ver.3.0 imati drugu svrhu.');
        Lines.Add('    page_generation:          ' + FormatDec(IntToStr(pagHdr_Header.page_generation)) +
            ' | Cetiri neoznacena bajta. Uvecava se svaki put kada stranicu upisemo na disk (npr. backup-om)');
        Lines.Add('    page_sequence_number:     ' + FormatDec(IntToStr(pagHdr_Header.page_sequence_number)) +
            ' | Cetiri neoznacena bajta. Ranije ih je koristio Write Ahead Log. Trenutno ih koristi nbackup.');
        Lines.Add('    page_reserved:            ' + FormatDec(IntToStr(pagHdr_Header.page_reserved)) +
            ' | Cetiri neoznacena bajta. Rezervisani su za buducu upotrebu.');
        Lines.Add('KRAJ Standard page header-a');
        Lines.Add('    btr_sibling:              ' + FormatDec(IntToStr(btr_sibling)) +
            ' | Cetiri neoznacena bajta. Broj slijedece BTree stranice ovog indeksa.');
        Lines.Add('    btr_left_sibling:         ' + FormatDec(IntToStr(btr_left_sibling)) +
            ' | Cetiri neoznacena bajta. Broj prethodne BTree stranice ovog indeksa.');
        Lines.Add('    btr_prefix_total:         ' + FormatDec(IntToStr(btr_prefix_total)) +
            ' | Cetiri neoznacena bajta. Suma svih bajta snimljenih na ovu stranicu pomocu Prefix kompresije.');

        Lines.Add('    btr_relation:             ' + FormatDec(IntToStr(btr_relation)) +
            ' | Dva neoznacena bajta. ID relacije (RDB$RELATION_ID u RDB$RELATIONS) kojoj pripada ovaj indeks.');
        Lines.Add('    btr_length:               ' + FormatDec(IntToStr(btr_length)) +
            ' | Dva neoznacena bajta. Broj bajta PODATAKA koji su upisani na ovu stranicu. Koristi se kao offset prema prvom slobodnom bajtu.');
        Lines.Add('    btr_id:                   ' + FormatDec(IntToStr(btr_id)) +
            ' | Jedan neoznacen bajt. ID ovoga indeksa (RDB$INDEX_ID u RDB$INDICES).');
        Lines.Add('    btr_level:                ' + FormatDec(IntToStr(btr_level)) +
            ' | Jedan neoznacen bajt. Nivo indeksa. Nula ako je ovo list (leaf node).');
        Lines.Add('KRAJ B-Tree header-a');
        Lines.Add('');
      end; // with frGlavna.IndexBTreePage do

      with frGlavna.IndexJumpInfo do
      begin
        Lines.Add('Duzina IndexJumpInfo strukture: ' + IntToStr
            (sizeof(IndexJumpInfo)));
        Lines.Add('POCETAK IndexJumpInfo strukture');
        Lines.Add('    firstNodeOffset:          ' + FormatDec
            (IntToStr(firstNodeOffset)) +
            ' | Dva neoznacena bajta. Offset, u bajtima, prvog od indeks cvorova (nodova).');
        Lines.Add('    jumpAreaSize:             ' + FormatDec
            (IntToStr(jumpAreaSize)) +
            ' | Dva neoznacena bajta. Broj slobodnih bajta koji preostaju prije kreiranja novog jump noda.');
        Lines.Add('    jumpers:                  ' + FormatDec
            (IntToStr(jumpers)) +
            ' | Jedan neoznacen bajt. Ukupan broj Jump nodova na ovoj stranici. Moze ih biti maksimalno 255.');
        Lines.Add('KRAJ IndexJumpInfo strukture');
        Lines.Add('');
      end; // with frGlavna.IndexJumpInfo

      Lines.Add(IntToStr(ChData[0]) + ' ' + IntToStr(ChData[1]) + ' ' + IntToStr
          (ChData[2]) + ' ' + IntToStr(ChData[3]) + ' ' + IntToStr(ChData[4])
          + ' ' + IntToStr(ChData[5]) + '... ');
      with IndexNode do
      begin
        Lines.Add('POCETAK IndexNode strukture');
        Lines.Add('    nodePointer:          ' + FormatDec
            (IntToStr(integer(nodePointer[0]))) +
            ' | Char*. Pokazivac na mjesto gdje se ovaj nod moze ocitati sa stranice.');
        Lines.Add('    prefix:               ' + FormatDec(IntToStr(integer(prefix))) +
            ' | Dva neoznacena bajta. Velicina sazetog (komprimovanog) prefiksa.');
        Lines.Add('    length:               ' + FormatDec(IntToStr(integer(length))) +
            ' | Dva neoznacena bajta. Duzina podatka u nodu.');
        Lines.Add('    pageNumber:           ' + FormatDec(IntToStr(integer(pageNumber))) +
            ' | Cetiri oznacena bajta. Broj stranice.');
        Lines.Add('    data:                 ' + FormatDec(IntToStr(integer(data[0]))) +
            ' | Jedan neoznacen bajt. Pocetak podataka.');
        Lines.Add('    recordNumber:         ' + FormatDec(IntToStr(integer(RecordNumber.getValue))) +
            ' | Objekat TRecordNumber. Prikazana je samo vrijednost dobijena od funkcije getValue().');
        Lines.Add('    isEndBucket:          ' + BoolToStr(isEndBucket) +
            ' | Jedan bajt (Bool). Pokazuje da li je ovo zadnji bucket (cabar).'
          );
        Lines.Add('    isEndLevel:           ' + BoolToStr(isEndBucket) +
            ' | Jedan bajt (Bool). Pokazuje da li je ovo zadnji nivo indeksa.');
        Lines.Add('KRAJ IndexNode strukture');
        Lines.Add('');
      end;

      {
        with frGlavna.IndexJumpNode do
        begin
        Lines.Add('Duzina IndexJumpNode strukture: ' + IntToStr(SizeOf(TIndexJumpNode)));
        Lines.Add('POCETAK IndexJumpNode strukture');
        Lines.Add('    nodePointer:          ' + FormatDec(IntToStr(Integer(nodePointer))) + ' | Jedan neoznacen bajt. Pokazivac na mjesto gdje se ovaj nod moze ocitati sa stranice.');
        Lines.Add('    prefix:             ' + FormatDec(IntToStr(prefix)) + ' | Dva neoznacena bajta. Prefiks u odnosu na prethodni Jump nod.');
        Lines.Add('    length:                  ' + FormatDec(IntToStr(length)) + ' | Dva neoznacena bajta. Duzina podataka u Jump Nodu.');
        Lines.Add('    offset:                  ' + FormatDec(IntToStr(offset)) + ' | Dva neoznacena bajta. Ofset do ovog noda na ovoj stranici.');
        Lines.Add('    data:                  ' + FormatDec(IntToStr(Byte(data))) + ' | Jedan neoznacen bajt. Podaci.');
        Lines.Add('KRAJ IndexJumpNode strukture');
        Lines.Add('');
        end; // with frGlavna.IndexJumpNode
        }
    end; // with mPIP do
  end
  else
  begin
    with mIndexBtree do
    begin
      Lines.Clear;
      Lines.Add('Index BTree Page');
      Lines.Add('Offset u datoteci: ' + IntToHex(offset, 8));
      Lines.Add('');
      Lines.Add('POCETAK B-Tree header-a');
      with frGlavna.IndexBtreePage do
      begin
        Lines.Add(
          'POCETAK Standard page header-a - svaka stranica ima na pocetku standardno zaglavlje');
        Lines.Add('    page_type:                ' + FormatDec(IntToHex(pagHdr_Header.page_type, 2)) +
            ' | Oznaceni bajt. 0x7 - Index BTree Page. 0x0 - nedefinisano, 0x1 - Header Page, 0x2 - Page Inventory Page...');
        Lines.Add('    page_flags:               ' + FormatDec(IntToHex(pagHdr_Header.page_flags, 2)) +
            ' | Neoznaceni bajt, razliciti flegovi');
        Lines.Add('    page_checksum:            ' + FormatDec(IntToHex(pagHdr_Header.page_checksum, 4)) +
            ' | Dva neoznacena bajta. Checksum se vise ne koristi (uvijek je 12345). Moguce je da ce od ver.3.0 imati drugu svrhu.');
        Lines.Add('    page_generation:          ' + FormatDec(IntToHex(pagHdr_Header.page_generation, 8)) +
            ' | Cetiri neoznacena bajta. Uvecava se svaki put kada stranicu upisemo na disk (npr. backup-om)');
        Lines.Add('    page_sequence_number:     ' + FormatDec(IntToHex(pagHdr_Header.page_sequence_number, 8)) +
            ' | Cetiri neoznacena bajta. Ranije ih je koristio Write Ahead Log. Trenutno ih koristi nbackup.');
        Lines.Add('    page_reserved:            ' + FormatDec(IntToHex(pagHdr_Header.page_reserved, 8)) +
            ' | Cetiri neoznacena bajta. Rezervisani su za buducu upotrebu.');
        Lines.Add('KRAJ Standard page header-a');
        Lines.Add('    btr_sibling:              ' + FormatDec(IntToHex(btr_sibling, 8)) +
            ' | Cetiri neoznacena bajta. Broj slijedece BTree stranice ovog indeksa.');
        Lines.Add('    btr_left_sibling:         ' + FormatDec(IntToHex(btr_left_sibling, 8)) +
            ' | Cetiri neoznacena bajta. Broj prethodne BTree stranice ovog indeksa.');
        Lines.Add('    btr_prefix_total:         ' + FormatDec(IntToHex(btr_prefix_total, 8)) +
            ' | Cetiri neoznacena bajta. Suma svih bajta snimljenih na ovu stranicu pomocu Prefix kompresije.');

        Lines.Add('    btr_relation:             ' + FormatDec(IntToHex(btr_relation, 4)) +
            ' | Dva neoznacena bajta. ID relacije (RDB$RELATION_ID u RDB$RELATIONS) kojoj pripada ovaj indeks.');
        Lines.Add('    btr_length:               ' + FormatDec(IntToHex(btr_length, 4)) +
            ' | Dva neoznacena bajta. Broj bajta PODATAKA koji su upisani na ovu stranicu. Koristi se kao offset prema prvom slobodnom bajtu.');
        Lines.Add('    btr_id:                   ' + FormatDec(IntToHex(btr_id, 2)) +
            ' | Jedan neoznacen bajt. ID ovoga indeksa (RDB$INDEX_ID u RDB$INDICES).');
        Lines.Add('    btr_level:                ' + FormatDec(IntToHex(btr_level, 2)) +
            ' | Jedan neoznacen bajt. Nivo indeksa. Nula ako je ovo list (leaf node).');
        Lines.Add('KRAJ B-Tree header-a');
        Lines.Add('');
      end; // with frGlavna.IndexBTreePage do

      with frGlavna.IndexJumpInfo do
      begin
        Lines.Add('POCETAK IndexJumpInfo strukture');
        Lines.Add('    firstNodeOffset:          ' + FormatDec
            (IntToHex(firstNodeOffset, 4)) +
            ' | Dva neoznacena bajta. Offset, u bajtima, prvog od indeks cvorova (nodova).');
        Lines.Add('    jumpAreaSize:             ' + FormatDec(IntToHex(jumpAreaSize, 4)) +
            ' | Dva neoznacena bajta. Broj slobodnih bajta koji preostaju prije kreiranja novog jump noda.');
        Lines.Add('    jumpers:                  ' + FormatDec(IntToHex(jumpers, 2)) +
            ' | Jedan neoznacen bajt. Ukupan broj Jump nodova na ovoj stranici. Moze ih biti maksimalno 255.');
        Lines.Add('KRAJ IndexJumpInfo strukture');
        Lines.Add('');
      end; // with frGlavna.IndexJumpInfo

      Lines.Add(IntToHex(integer(ChData[0]), 2) + ' ' + IntToHex
          (integer(ChData[1]), 2) + ' ' + IntToHex(integer(ChData[2]), 2)
          + ' ' + IntToHex(integer(ChData[3]), 2) + ' ' + IntToHex
          (integer(ChData[4]), 2) + ' ' + IntToHex(integer(ChData[5]), 2)
          + '... ');
      with IndexNode do
      begin
        Lines.Add
          ('POCETAK IndexNode strukture - struktura zahtjeva dekodiranje');
        Lines.Add('    nodePointer:          ' + FormatDec(IntToHex(integer(nodePointer[0]), 2)) +
            ' | Char*. Pokazivac na mjesto gdje se ovaj nod moze ocitati sa stranice.');
        Lines.Add('    prefix:               ' + FormatDec(IntToHex(integer(prefix), 2)) +
            ' | Dva neoznacena bajta. Velicina sazetog (komprimovanog) prefiksa.');
        Lines.Add('    length:               ' + FormatDec(IntToHex(integer(length), 2)) +
            ' | Dva neoznacena bajta. Duzina podatka u nodu.');
        Lines.Add('    pageNumber:           ' + FormatDec(IntToHex(integer(pageNumber), 8)) +
            ' | Cetiri oznacena bajta. Broj stranice.');
        Lines.Add('    data:                 ' + FormatDec(IntToHex(integer(data[0]), 2)) +
            ' | Jedan neoznacen bajt. Pocetak podataka.');
        Lines.Add('    recordNumber:         ' + FormatDec(IntToHex(integer(RecordNumber.getValue), 16)) +
            ' | Objekat TRecordNumber. Prikazana je samo vrijednost dobijena od funkcije getValue().');
        Lines.Add('    isEndBucket:          ' + BoolToStr(isEndBucket) +
            ' | Jedan bajt (Bool). Pokazuje da li je ovo zadnji bucket (cabar).'
          );
        Lines.Add('    isEndLevel:           ' + BoolToStr(isEndBucket) +
            ' | Jedan bajt (Bool). Pokazuje da li je ovo zadnji nivo indeksa.');
        Lines.Add('KRAJ IndexNode strukture');
        Lines.Add('');
      end;

      with IndexNode2 do
      begin
        Lines.Add
          ('POCETAK IndexNode strukture - struktura zahtjeva dekodiranje');
        Lines.Add('    nodePointer:          ' + FormatDec(IntToHex(integer(nodePointer[0]), 2)) +
            ' | Char*. Pokazivac na mjesto gdje se ovaj nod moze ocitati sa stranice.');
        Lines.Add('    prefix:               ' + FormatDec(IntToHex(integer(prefix), 2)) +
            ' | Dva neoznacena bajta. Velicina sazetog (komprimovanog) prefiksa.');
        Lines.Add('    length:               ' + FormatDec(IntToHex(integer(length), 2)) +
            ' | Dva neoznacena bajta. Duzina podatka u nodu.');
        Lines.Add('    pageNumber:           ' + FormatDec(IntToHex(integer(pageNumber), 8)) +
            ' | Cetiri oznacena bajta. Broj stranice.');
        Lines.Add('    data:                 ' + FormatDec(IntToHex(integer(data[0]), 2)) +
            ' | Jedan neoznacen bajt. Pocetak podataka.');
        Lines.Add('    recordNumber:         ' + FormatDec(IntToHex(integer(RecordNumber.getValue), 16)) +
            ' | Objekat TRecordNumber. Prikazana je samo vrijednost dobijena od funkcije getValue().');
        Lines.Add('    isEndBucket:          ' + BoolToStr(isEndBucket) +
            ' | Jedan bajt (Bool). Pokazuje da li je ovo zadnji bucket (cabar).'
          );
        Lines.Add('    isEndLevel:           ' + BoolToStr(isEndBucket) +
            ' | Jedan bajt (Bool). Pokazuje da li je ovo zadnji nivo indeksa.');
        Lines.Add('KRAJ IndexNode strukture');
        Lines.Add('');
      end;
      with IndexNode3 do
      begin
        Lines.Add
          ('POCETAK IndexNode strukture - struktura zahtjeva dekodiranje');
        Lines.Add('    nodePointer:          ' + FormatDec(IntToHex(integer(nodePointer[0]), 2)) +
            ' | Char*. Pokazivac na mjesto gdje se ovaj nod moze ocitati sa stranice.');
        Lines.Add('    prefix:               ' + FormatDec(IntToHex(integer(prefix), 2)) +
            ' | Dva neoznacena bajta. Velicina sazetog (komprimovanog) prefiksa.');
        Lines.Add('    length:               ' + FormatDec(IntToHex(integer(length), 2)) +
            ' | Dva neoznacena bajta. Duzina podatka u nodu.');
        Lines.Add('    pageNumber:           ' + FormatDec(IntToHex(integer(pageNumber), 8)) +
            ' | Cetiri oznacena bajta. Broj stranice.');
        Lines.Add('    data:                 ' + FormatDec(IntToHex(integer(data[0]), 2)) +
            ' | Jedan neoznacen bajt. Pocetak podataka.');
        Lines.Add('    recordNumber:         ' + FormatDec(IntToHex(integer(RecordNumber.getValue), 16)) +
            ' | Objekat TRecordNumber. Prikazana je samo vrijednost dobijena od funkcije getValue().');
        Lines.Add('    isEndBucket:          ' + BoolToStr(isEndBucket) +
            ' | Jedan bajt (Bool). Pokazuje da li je ovo zadnji bucket (cabar).'
          );
        Lines.Add('    isEndLevel:           ' + BoolToStr(isEndBucket) +
            ' | Jedan bajt (Bool). Pokazuje da li je ovo zadnji nivo indeksa.');
        Lines.Add('KRAJ IndexNode strukture');
        Lines.Add('');
      end;
      {
        PIndexNode = ^TIndexNode;
        TIndexNode = packed record
        nodePointer : PAnsiChar;    // UCHAR*  pointer to where this node can be read from the page
        prefix   : Word;        // ili UShort;;        // length of prefix against previous jump node
        length  : Word;         // ili UShort;        // length of data in jump node (together with prefix this is prefix for pointing node)
        pageNumber : LongInt;    // UCHAR*  pointer to where this node can be read from the page
        data : PAnsiChar;        // ili UCHAR*// Data can be read from here
        recordNumber : TRecordNumber;    // UCHAR*  pointer to where this node can be read from the page
        isEndBucket : boolean;
        isEndLevel : boolean;
        end;

        with frGlavna.IndexJumpNode do
        begin
        Lines.Add('POCETAK IndexJumpNode strukture');
        Lines.Add('    nodePointer:          ' + FormatDec(IntToHex(Byte(nodePointer), 2)) + ' | Jedan neoznacen bajt. Pokazivac na mjesto gdje se ovaj nod moze ocitati sa stranice.');
        Lines.Add('    prefix:             ' + FormatDec(IntToHex(prefix, 4)) + ' | Dva neoznacena bajta. Prefiks u odnosu na prethodni Jump nod.');
        Lines.Add('    length:                  ' + FormatDec(IntToHex(length, 4)) + ' | Dva neoznacena bajta. Duzina podataka u Jump Nodu.');
        Lines.Add('    offset:                  ' + FormatDec(IntToHex(offset, 4)) + ' | Dva neoznacena bajta. Ofset do ovog noda na ovoj stranici.');
        Lines.Add('    data:                  ' + FormatDec(IntToHex(Byte(data), 2)) + ' | Jedan neoznacen bajt. Podaci.');
        Lines.Add('KRAJ IndexJumpNode strukture');
        Lines.Add('');
        end; // with frGlavna.IndexJumpNode
        }
    end; // with mPIP do
  end;

except
  ;
end;
end;

procedure TfrGlavna.rgPrikaziClick(Sender: TObject);
begin
  GetHeaderPage;
end;

procedure TfrGlavna.rgPrikaziDataPageClick(Sender: TObject);
begin
  GetDataPage(StrToInt(lbDataPage0x05.Items[lbDataPage0x05.ItemIndex]));
end;

procedure TfrGlavna.rgPrikaziIndexBtreeClick(Sender: TObject);
begin
  GetIndexBtreePage(StrToInt(lbIndexBTree0x07.Items[lbIndexBTree0x07.ItemIndex])
    );
end;

procedure TfrGlavna.rgPrikaziIndexRootClick(Sender: TObject);
begin
  GetIndexRootPage(StrToInt(lbIndexRoot0x06.Items[lbIndexRoot0x06.ItemIndex]));
end;

procedure TfrGlavna.rgPrikaziPIPClick(Sender: TObject);
begin
  GetPIP(StrToInt(lbPIP.Items[lbPIP.ItemIndex]));
end;

procedure TfrGlavna.rgPrikaziPointerPageClick(Sender: TObject);
begin
  GetPointerPage(StrToInt(lbPointerTOP.Items[lbPointerTOP.ItemIndex]));
end;

procedure TfrGlavna.rgPrikaziTRansactionIPClick(Sender: TObject);
begin
  GetTransactionIP(StrToInt(lbTIP.Items[lbTIP.ItemIndex]));
end;

procedure TfrGlavna.btUcitajClick(Sender: TObject);
var
  b: Byte;
  i: integer;
begin

  OpenDialog1.Title := 'Odaberite ulaznu datoteku (*.fdb)';
  if OpenDialog1.Execute then
    in_file_name := OpenDialog1.FileName
  else
    exit;

  lbPIP.Items.Clear;
  lbTIP.Items.Clear;
  lbPointerTOP.Items.Clear;
  lbDataPage0x05.Items.Clear;
  lbIndexRoot0x06.Items.Clear;
  lbIndexBTree0x07.Items.Clear;

  StatusBar1.Panels.Items[0].Text := 'Ucitana: ' + OpenDialog1.FileName;
  in_file := TFileStream.Create(in_file_name, fmOpenRead or fmShareDenyNone);
  // in_file.LoadFromFile(in_file_name);

  // HeaderPage
  in_file.Position := 0;
  in_file.Read(Header_Page, sizeof(Header_Page));
  GetHeaderPage;

  i := 0;
  FirstTIPPage := 0;
  FirstPIPPage := 0;
  FirstPointerPage := 0;
  FirstIndexRootPage := 0;
  FirstIndexBTreePage := 0;
  FirstDataPage := 0;

  while (i <= in_file.Size / Header_Page.hdr_page_size) do
  begin
    in_file.Position := i * Header_Page.hdr_page_size;
    in_file.Read(b, 1);
    case b of
      0:
        begin
          //mDatabaseHeaderPage.Lines.Add(IntToStr(in_file.Position - 1)
          //    + ',  ' + IntToStr(b) + ', Nedefinisana stranica');
        end;
      1:
        begin
          //mDatabaseHeaderPage.Lines.Add(IntToStr(in_file.Position - 1)
          //    + ',  ' + IntToStr(b) + ', Database Header Page');
        end;
      2:
        begin
          //mDatabaseHeaderPage.Lines.Add(IntToStr(in_file.Position - 1)
          //    + ',  ' + IntToStr(b) + ', Page Inventory Page');
          if FirstPIPPage = 0 then
            FirstPIPPage := i;
          lbPIP.Items.Add(IntToStr(in_file.Position - 1));
        end;
      3:
        begin
          //mDatabaseHeaderPage.Lines.Add(IntToStr(in_file.Position - 1)
          //    + ',  ' + IntToStr(b) + ', Transaction Inventory Page');
          if FirstTIPPage = 0 then
            FirstTIPPage := i;
          lbTIP.Items.Add(IntToStr(in_file.Position - 1));
        end;
      4:
        begin
          //mDatabaseHeaderPage.Lines.Add(IntToStr(in_file.Position - 1)
          //    + ',  ' + IntToStr(b) + ', Pointer Page');
          if FirstPointerPage = 0 then
            FirstPointerPage := i;
          lbPointerTOP.Items.Add(IntToStr(in_file.Position - 1));
        end;
      5:
        begin
          //mDatabaseHeaderPage.Lines.Add(IntToStr(in_file.Position - 1)
          //    + ',  ' + IntToStr(b) + ', Data Page');
          if FirstDataPage = 0 then
            FirstDataPage := i;
          lbDataPage0x05.Items.Add(IntToStr(in_file.Position - 1));
        end;
      6:
        begin
          //mDatabaseHeaderPage.Lines.Add(IntToStr(in_file.Position - 1)
          //    + ',  ' + IntToStr(b) + ', Index Root Page');
          if FirstIndexRootPage = 0 then
            FirstIndexRootPage := i;
          lbIndexRoot0x06.Items.Add(IntToStr(in_file.Position - 1));
        end;
      7:
        begin
          //mDatabaseHeaderPage.Lines.Add(IntToStr(in_file.Position - 1)
          //    + ',  ' + IntToStr(b) + ', Index B-Tree Page');
          if FirstIndexBTreePage = 0 then
            FirstIndexBTreePage := i;
          lbIndexBTree0x07.Items.Add(IntToStr(in_file.Position - 1));
        end;
      8:
        begin
          //mDatabaseHeaderPage.Lines.Add(IntToStr(in_file.Position - 1)
          //    + ',  ' + IntToStr(b) + ', Blob Page');
        end;
      9:
        begin
          //mDatabaseHeaderPage.Lines.Add(IntToStr(in_file.Position - 1)
          //    + ',  ' + IntToStr(b) + ', Generator Page');
        end;
      10:
        begin
          //mDatabaseHeaderPage.Lines.Add(IntToStr(in_file.Position - 1)
          //    + ',  ' + IntToStr(b) + ', Write Ahead Log Page. Ne koristi se');
        end;
    end;

    // if (FirstTIPPage <> 0) and (i > 250) then
    // begin
    // mDatabaseHeaderPage.Lines.Add('...');
    // break;
    // end;
    inc(i);
  end;

  // PIP
  in_file.Free;
  GetPIP(FirstPIPPage * Header_Page.hdr_page_size);
  lbPIP.ItemIndex := 0;

  // TIP
  // in_file.Position := FirstTIPPage*Header_Page.hdr_page_size;
  // in_file.Read(TransactionInvPage, SizeOf(TransactionInvPage));
  GetTransactionIP(FirstTIPPage * Header_Page.hdr_page_size);
  lbTIP.ItemIndex := 0;

  // PointerPage
  // in_file.Position := FirstPointerPage*Header_Page.hdr_page_size;
  // in_file.Read(PointerPage, SizeOf(PointerPage));
  GetPointerPage(FirstPointerPage * Header_Page.hdr_page_size);
  lbPointerTOP.ItemIndex := 0;

  // IndexRootPage
  // in_file.Position := FirstIndexRootPage*Header_Page.hdr_page_size;
  // in_file.Read(IndexRootPage, SizeOf(IndexRootPage));

  GetIndexRootPage(FirstIndexRootPage * Header_Page.hdr_page_size);
  lbIndexRoot0x06.ItemIndex := 0;
  GetIndexBtreePage(FirstIndexBTreePage * Header_Page.hdr_page_size);
  lbIndexBTree0x07.ItemIndex := 0;

  GetDataPage(FirstDataPage * Header_Page.hdr_page_size);
  lbDataPage0x05.ItemIndex := 0;
end;

end.
