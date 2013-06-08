object frDump: TfrDump
  Left = 232
  Top = 111
  Caption = 'Dump'
  ClientHeight = 371
  ClientWidth = 620
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Rich: TRichEdit
    Left = 0
    Top = 0
    Width = 620
    Height = 352
    Align = alClient
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlack
    Font.Height = -12
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    PlainText = True
    ScrollBars = ssBoth
    TabOrder = 0
    WordWrap = False
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 352
    Width = 620
    Height = 19
    Panels = <>
    SimplePanel = True
  end
end
