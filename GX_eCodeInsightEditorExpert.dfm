object fmCodeInsightEditorExpertConfig: TfmCodeInsightEditorExpertConfig
  Left = 381
  Top = 212
  BorderStyle = bsDialog
  Caption = 'Code Insight Editor Expert Config'
  ClientHeight = 314
  ClientWidth = 564
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Tahoma'
  Font.Style = []
  TextHeight = 14
  object lblNote: TLabel
    Left = 8
    Top = 12
    Width = 548
    Height = 16
    Alignment = taCenter
    AutoSize = False
    Caption = 'Umfang der Code Insight Eingabe'
  end
  object lblData: TLabel
    Left = 8
    Top = 261
    Width = 154
    Height = 14
    Alignment = taRightJustify
    Caption = 'Data is saved to the registry'
  end
  object btnOK: TButton
    Left = 481
    Top = 281
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 8
    Top = 281
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object cbMethodSummary: TCheckBox
    Left = 8
    Top = 48
    Width = 209
    Height = 17
    Caption = 'Methoden Zusammenfassung'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 2
  end
  object cbResultSummary: TCheckBox
    Left = 8
    Top = 89
    Width = 209
    Height = 17
    Caption = 'R'#252'ckgabewert Beschreibung'
    TabOrder = 3
  end
  object cbRemarkSummary: TCheckBox
    Left = 8
    Top = 92
    Width = 209
    Height = 17
    Caption = 'Weiterf'#252'hrende Hinweise'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
  end
  object cbEnumSummary: TCheckBox
    Left = 8
    Top = 136
    Width = 265
    Height = 17
    Caption = 'Elemente von Aufz'#228'hlungstypen'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 5
  end
  object cbParamSummary: TCheckBox
    Left = 8
    Top = 180
    Width = 353
    Height = 17
    Caption = 'Beschreibung einzelner Methoden Parameter'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 6
  end
  object cbDocOMatic: TCheckBox
    Left = 8
    Top = 224
    Width = 177
    Height = 17
    Caption = 'Doc-O-Matic Support'
    Font.Charset = ANSI_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 7
  end
end
