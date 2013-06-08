object frGlavna: TfrGlavna
  Left = 0
  Top = 0
  Caption = 'frGlavna'
  ClientHeight = 461
  ClientWidth = 922
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  WindowState = wsMaximized
  PixelsPerInch = 96
  TextHeight = 13
  object PageControl: TPageControl
    Left = 0
    Top = 0
    Width = 922
    Height = 461
    ActivePage = PageOsnovna
    Align = alClient
    TabOrder = 0
    object PageOsnovna: TTabSheet
      Caption = 'Osnovna'
      ImageIndex = 5
      object pnTop0: TPanel
        Left = 0
        Top = 0
        Width = 914
        Height = 57
        Align = alTop
        Ctl3D = True
        ParentBackground = False
        ParentCtl3D = False
        TabOrder = 0
        object btUcitaj: TButton
          Left = 24
          Top = 9
          Width = 75
          Height = 25
          Caption = 'U'#269'itaj'
          TabOrder = 0
          OnClick = btUcitajClick
        end
      end
      object pnClient0: TPanel
        Left = 0
        Top = 57
        Width = 914
        Height = 376
        Align = alClient
        Caption = 'pnClient0'
        ParentBackground = False
        TabOrder = 1
        object pnPIP0: TPanel
          Left = 1
          Top = 1
          Width = 120
          Height = 374
          Align = alLeft
          Caption = 'pnPIP0'
          TabOrder = 0
          object pnPIP0TOP: TPanel
            Left = 1
            Top = 1
            Width = 118
            Height = 24
            Align = alTop
            Caption = 'Page Inventory Page'
            ParentBackground = False
            TabOrder = 0
          end
          object lbPIP: TListBox
            Left = 1
            Top = 25
            Width = 118
            Height = 348
            Hint = '2x klik'
            Align = alClient
            ItemHeight = 13
            ParentShowHint = False
            ShowHint = True
            TabOrder = 1
            OnDblClick = lbPIPDblClick
          end
        end
        object pnTip1: TPanel
          Left = 121
          Top = 1
          Width = 120
          Height = 374
          Align = alLeft
          Caption = 'pnTip1'
          TabOrder = 1
          object pnTIP1top: TPanel
            Left = 1
            Top = 1
            Width = 118
            Height = 24
            Align = alTop
            Caption = 'Trans.Inventory Page'
            ParentBackground = False
            TabOrder = 0
          end
          object lbTIP: TListBox
            Left = 1
            Top = 25
            Width = 118
            Height = 348
            Hint = '2x klik'
            Align = alClient
            ItemHeight = 13
            ParentShowHint = False
            ShowHint = True
            TabOrder = 1
            OnDblClick = lbTIPDblClick
          end
        end
        object pnPointer0x04: TPanel
          Left = 241
          Top = 1
          Width = 120
          Height = 374
          Align = alLeft
          Caption = 'pnPointer0x04'
          TabOrder = 2
          object pnPointer0x04top: TPanel
            Left = 1
            Top = 1
            Width = 118
            Height = 24
            Align = alTop
            Caption = 'Pointer Page'
            ParentBackground = False
            TabOrder = 0
          end
          object lbPointerTOP: TListBox
            Left = 1
            Top = 25
            Width = 118
            Height = 348
            Hint = '2x klik'
            Align = alClient
            ItemHeight = 13
            ParentShowHint = False
            ShowHint = True
            TabOrder = 1
            OnDblClick = lbPointerTOPDblClick
          end
        end
        object pnIndexRoot0x06: TPanel
          Left = 481
          Top = 1
          Width = 120
          Height = 374
          Align = alLeft
          Caption = 'pnIndexRoot0x06'
          ParentBackground = False
          TabOrder = 3
          object pnIndexRoot0x06top: TPanel
            Left = 1
            Top = 1
            Width = 118
            Height = 24
            Align = alTop
            Caption = 'Index Root Page'
            ParentBackground = False
            TabOrder = 0
          end
          object lbIndexRoot0x06: TListBox
            Left = 1
            Top = 25
            Width = 118
            Height = 348
            Hint = '2x klik'
            Align = alClient
            ItemHeight = 13
            ParentShowHint = False
            ShowHint = True
            TabOrder = 1
            OnDblClick = lbIndexRoot0x06DblClick
          end
        end
        object pnIndexBTree0x07: TPanel
          Left = 601
          Top = 1
          Width = 120
          Height = 374
          Align = alLeft
          Caption = 'pnIndexBTree0x07'
          TabOrder = 4
          object pnIndexBTree0x07top: TPanel
            Left = 1
            Top = 1
            Width = 118
            Height = 24
            Align = alTop
            Caption = 'Index BTree Page'
            ParentBackground = False
            TabOrder = 0
          end
          object lbIndexBTree0x07: TListBox
            Left = 1
            Top = 25
            Width = 118
            Height = 348
            Hint = '2x klik'
            Align = alClient
            ItemHeight = 13
            ParentShowHint = False
            ShowHint = True
            TabOrder = 1
            OnDblClick = lbIndexBTree0x07DblClick
          end
        end
        object pnDataPage0x05: TPanel
          Left = 361
          Top = 1
          Width = 120
          Height = 374
          Align = alLeft
          Caption = 'pnDataPage0x05'
          TabOrder = 5
          object pnDataPage0x05top: TPanel
            Left = 1
            Top = 1
            Width = 118
            Height = 24
            Align = alTop
            Caption = 'Data Page'
            ParentBackground = False
            TabOrder = 0
          end
          object lbDataPage0x05: TListBox
            Left = 1
            Top = 25
            Width = 118
            Height = 348
            Hint = '2x klik'
            Align = alClient
            ItemHeight = 13
            ParentShowHint = False
            ShowHint = True
            TabOrder = 1
            OnDblClick = lbDataPage0x05DblClick
          end
        end
        object Memo1: TMemo
          Left = 721
          Top = 1
          Width = 192
          Height = 374
          Align = alClient
          Lines.Strings = (
            'Dugmetom Ucitaj biramo bazu '
            'podataka koju posmatramo. '
            ''
            'Nakon toga, 2x klik na List-boxove sa '
            'lijeve strane otvara odgovarajucu '
            'stranicu baze podataka na odabranoj '
            'adresi.'
            ''
            'Primjedba:'
            'Pri dnu List-boxova obicno su '
            'stranice koje sadrze podatke.'
            'U vrhu List-boxova se nalaze stranice '
            'koje odredjuju sistemske tabele.'
            ''
            'U istom direktorijumu u kojem se '
            'nalazi program, nalazi se i baza '
            'podataka test.fdb.'
            '')
          TabOrder = 6
        end
      end
    end
    object Page0x01Header: TTabSheet
      Caption = '0x01 - DB Header Page'
      object mDatabaseHeaderPage: TMemo
        Left = 0
        Top = 65
        Width = 914
        Height = 349
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 0
      end
      object StatusBar1: TStatusBar
        Left = 0
        Top = 414
        Width = 914
        Height = 19
        Panels = <
          item
            Width = 50
          end>
      end
      object pnHeaderPage0x01TOP: TPanel
        Left = 0
        Top = 0
        Width = 914
        Height = 65
        Align = alTop
        ParentBackground = False
        TabOrder = 2
        object rgPrikazi: TRadioGroup
          Left = 0
          Top = 10
          Width = 185
          Height = 49
          Caption = 'rgPrikazi'
          ItemIndex = 0
          Items.Strings = (
            'Dec'
            'Hex')
          TabOrder = 0
          OnClick = rgPrikaziClick
        end
        object btDBHeaderPageHex: TButton
          Left = 264
          Top = 16
          Width = 89
          Height = 33
          Caption = 'HexDump'
          TabOrder = 1
          OnClick = btDBHeaderPageHexClick
        end
      end
    end
    object Page0x02PiP: TTabSheet
      Caption = '0x02 - Page Inventory Page'
      ImageIndex = 1
      object pnPIP0x02TOP: TPanel
        Left = 0
        Top = 0
        Width = 914
        Height = 65
        Align = alTop
        ParentBackground = False
        TabOrder = 0
        object rgPrikaziPIP: TRadioGroup
          Left = 0
          Top = 10
          Width = 185
          Height = 49
          Caption = 'rgPrikazi'
          ItemIndex = 0
          Items.Strings = (
            'Dec'
            'Hex')
          TabOrder = 0
          OnClick = rgPrikaziPIPClick
        end
        object btPIPPageHex: TButton
          Left = 264
          Top = 16
          Width = 89
          Height = 33
          Caption = 'HexDump'
          TabOrder = 1
          OnClick = btPIPPageHexClick
        end
      end
      object mPIP: TMemo
        Left = 0
        Top = 65
        Width = 914
        Height = 368
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 1
      end
    end
    object Page0x03TransactionInventoryPage: TTabSheet
      Caption = '0x03 - Transaction Inventory Page'
      ImageIndex = 2
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 914
        Height = 65
        Align = alTop
        ParentBackground = False
        TabOrder = 0
        object rgPrikaziTRansactionIP: TRadioGroup
          Left = 0
          Top = 10
          Width = 185
          Height = 49
          Caption = 'rgPrikazi'
          ItemIndex = 0
          Items.Strings = (
            'Dec'
            'Hex')
          TabOrder = 0
          OnClick = rgPrikaziTRansactionIPClick
        end
        object btTIPPageHex: TButton
          Left = 264
          Top = 16
          Width = 89
          Height = 33
          Caption = 'HexDump'
          TabOrder = 1
          OnClick = btTIPPageHexClick
        end
      end
      object mTransactionIP: TMemo
        Left = 0
        Top = 65
        Width = 914
        Height = 368
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 1
      end
    end
    object Page0x04PointerPage: TTabSheet
      Caption = '0x04 - Pointer Page'
      ImageIndex = 3
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 914
        Height = 65
        Align = alTop
        ParentBackground = False
        TabOrder = 0
        object rgPrikaziPointerPage: TRadioGroup
          Left = 0
          Top = 10
          Width = 185
          Height = 49
          Caption = 'rgPrikazi'
          ItemIndex = 0
          Items.Strings = (
            'Dec'
            'Hex')
          TabOrder = 0
          OnClick = rgPrikaziPointerPageClick
        end
        object btPointerPageHex: TButton
          Left = 264
          Top = 16
          Width = 89
          Height = 33
          Caption = 'HexDump'
          TabOrder = 1
          OnClick = btPointerPageHexClick
        end
      end
      object mPointerPage: TMemo
        Left = 0
        Top = 65
        Width = 914
        Height = 368
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 1
      end
    end
    object Page0x05DataPage: TTabSheet
      Caption = '0x05 Data Page'
      ImageIndex = 7
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 914
        Height = 65
        Align = alTop
        ParentBackground = False
        TabOrder = 0
        object rgPrikaziDataPage: TRadioGroup
          Left = 0
          Top = 10
          Width = 185
          Height = 49
          Caption = 'rgPrikazi'
          ItemIndex = 0
          Items.Strings = (
            'Dec'
            'Hex')
          TabOrder = 0
          OnClick = rgPrikaziDataPageClick
        end
        object btDataPageHex: TButton
          Left = 264
          Top = 16
          Width = 89
          Height = 33
          Caption = 'HexDump'
          TabOrder = 1
          OnClick = btDataPageHexClick
        end
      end
      object mDataPage: TMemo
        Left = 0
        Top = 65
        Width = 784
        Height = 368
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 1
      end
      object pnDATAdesno: TPanel
        Left = 784
        Top = 65
        Width = 130
        Height = 368
        Align = alRight
        Caption = 'pnDATAright'
        ParentBackground = False
        TabOrder = 2
        object lbDATA_dpg_repeat: TListBox
          Left = 1
          Top = 25
          Width = 128
          Height = 342
          Align = alClient
          BiDiMode = bdLeftToRight
          ItemHeight = 13
          ParentBiDiMode = False
          TabOrder = 0
          OnDblClick = lbDATA_dpg_repeatDblClick
        end
        object pnDATAup: TPanel
          Left = 1
          Top = 1
          Width = 128
          Height = 24
          Align = alTop
          Caption = 'Niz DPG_repeat'
          TabOrder = 1
        end
      end
    end
    object Page0x06IndexRoot: TTabSheet
      Caption = 'Pg0x06 Index Root'
      ImageIndex = 4
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 914
        Height = 65
        Align = alTop
        ParentBackground = False
        TabOrder = 0
        object rgPrikaziIndexRoot: TRadioGroup
          Left = 0
          Top = 10
          Width = 185
          Height = 49
          Caption = 'rgPrikazi'
          ItemIndex = 0
          Items.Strings = (
            'Dec'
            'Hex')
          TabOrder = 0
          OnClick = rgPrikaziIndexRootClick
        end
        object btIndexPageHex: TButton
          Left = 264
          Top = 16
          Width = 89
          Height = 33
          Caption = 'HexDump'
          TabOrder = 1
          OnClick = btIndexPageHexClick
        end
      end
      object mIndexRoot: TMemo
        Left = 0
        Top = 65
        Width = 784
        Height = 368
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 1
      end
      object pnINDEXROOTright: TPanel
        Left = 784
        Top = 65
        Width = 130
        Height = 368
        Align = alRight
        Caption = 'pnINDEXROOTright'
        ParentBackground = False
        TabOrder = 2
        object lbIndexRoot_irt_desc: TListBox
          Left = 1
          Top = 33
          Width = 128
          Height = 334
          Align = alClient
          BiDiMode = bdLeftToRight
          ItemHeight = 13
          ParentBiDiMode = False
          TabOrder = 0
          OnDblClick = lbIndexRoot_irt_descDblClick
        end
        object pnINDEXROOTtop: TPanel
          Left = 1
          Top = 1
          Width = 128
          Height = 32
          Align = alTop
          TabOrder = 1
          object Label1: TLabel
            Left = 4
            Top = 4
            Width = 109
            Height = 26
            Caption = 'irt_desc: Pokazuje na  Tirtd_ods11 '
            WordWrap = True
          end
        end
      end
    end
    object Page0x07IndexBtreePage: TTabSheet
      Caption = '0x07 Index Btree'
      ImageIndex = 6
      object pnIndBTREE0x07TOP: TPanel
        Left = 0
        Top = 0
        Width = 914
        Height = 65
        Align = alTop
        ParentBackground = False
        TabOrder = 0
        object rgPrikaziIndexBtree: TRadioGroup
          Left = 0
          Top = 10
          Width = 185
          Height = 49
          Caption = 'rgPrikazi'
          ItemIndex = 0
          Items.Strings = (
            'Dec'
            'Hex')
          TabOrder = 0
          OnClick = rgPrikaziIndexBtreeClick
        end
        object btIndexBTreeHexDump: TButton
          Left = 264
          Top = 16
          Width = 89
          Height = 33
          Caption = 'HexDump'
          TabOrder = 1
          OnClick = btIndexBTreeHexDumpClick
        end
      end
      object mIndexBtree: TMemo
        Left = 0
        Top = 65
        Width = 914
        Height = 368
        Align = alClient
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 1
      end
    end
  end
  object OpenDialog1: TOpenDialog
    Filter = '*.fdb|*.fdb'
    Left = 208
    Top = 40
  end
end
