object frnTest: TfrnTest
  Left = 0
  Top = 0
  Caption = 'Test'
  ClientHeight = 679
  ClientWidth = 861
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  DesignSize = (
    861
    679)
  TextHeight = 15
  object lblSource: TLabel
    Left = 8
    Top = 8
    Width = 36
    Height = 15
    Caption = 'Source'
  end
  object lblLinePos: TLabel
    Left = 8
    Top = 655
    Width = 30
    Height = 17
    Caption = 'Zeile'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object lblResult: TLabel
    Left = 312
    Top = 657
    Width = 38
    Height = 17
    Caption = 'Status'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object memSource: TMemo
    Left = 8
    Top = 24
    Width = 705
    Height = 625
    ReadOnly = True
    TabOrder = 0
    OnClick = memSourceClick
    OnKeyDown = memSourceKeyDown
  end
  object btnExit: TButton
    Left = 768
    Top = 640
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Schlie'#223'en'
    TabOrder = 1
    OnClick = btnExitClick
  end
  object btnTest: TButton
    Left = 768
    Top = 609
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Test'
    TabOrder = 2
    OnClick = btnTestClick
  end
  object cbSummary: TCheckBox
    Left = 728
    Top = 27
    Width = 97
    Height = 17
    Caption = 'Summary'
    Checked = True
    State = cbChecked
    TabOrder = 3
  end
  object cbRemarks: TCheckBox
    Left = 728
    Top = 63
    Width = 97
    Height = 17
    Caption = 'Remarks'
    Checked = True
    State = cbChecked
    TabOrder = 4
  end
  object cbResult: TCheckBox
    Left = 728
    Top = 99
    Width = 97
    Height = 17
    Caption = 'Result'
    Checked = True
    State = cbChecked
    TabOrder = 5
  end
  object cbParams: TCheckBox
    Left = 728
    Top = 135
    Width = 97
    Height = 17
    Caption = 'Params'
    Checked = True
    State = cbChecked
    TabOrder = 6
  end
  object cbEnums: TCheckBox
    Left = 728
    Top = 171
    Width = 97
    Height = 17
    Caption = 'Enums'
    Checked = True
    State = cbChecked
    TabOrder = 7
  end
  object cbDocOMatic: TCheckBox
    Left = 728
    Top = 208
    Width = 97
    Height = 17
    Caption = 'Doc-O-Matic'
    Checked = True
    State = cbChecked
    TabOrder = 8
  end
  object edtZeile: TEdit
    Left = 768
    Top = 580
    Width = 72
    Height = 23
    TabOrder = 9
    Text = '202'
  end
  object cbVorgabe: TCheckBox
    Left = 768
    Top = 557
    Width = 97
    Height = 17
    Caption = 'Vorgabe'
    TabOrder = 10
  end
end
