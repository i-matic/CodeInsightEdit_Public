object frm_CodeInsightEdit: Tfrm_CodeInsightEdit
  Left = 0
  Top = 0
  Caption = 'Erfassung von Code Insight konformen Kommentaren'
  ClientHeight = 745
  ClientWidth = 802
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 15
  object pnlCIETop: TPanel
    Left = 0
    Top = 0
    Width = 802
    Height = 41
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object pnlCIEMain: TPanel
    Left = 0
    Top = 41
    Width = 802
    Height = 663
    Align = alClient
    TabOrder = 1
    DesignSize = (
      802
      663)
    object lblObjectName: TLabel
      Left = 16
      Top = 16
      Width = 108
      Height = 21
      Caption = 'lblObjectName'
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI Semibold'
      Font.Style = [fsBold, fsItalic]
      ParentFont = False
    end
    object sbEdit: TScrollBox
      Left = 16
      Top = 56
      Width = 773
      Height = 584
      Anchors = [akLeft, akTop, akRight, akBottom]
      TabOrder = 0
    end
    object cbObjectTypes: TComboBox
      Left = 608
      Top = 18
      Width = 181
      Height = 23
      Anchors = [akTop, akRight]
      TabOrder = 1
      Text = 'cbObjectTypes'
    end
  end
  object pnlCIEBottom: TPanel
    Left = 0
    Top = 704
    Width = 802
    Height = 41
    Align = alBottom
    TabOrder = 2
    DesignSize = (
      802
      41)
    object btnOk: TButton
      Left = 714
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = #220'bernehmen'
      TabOrder = 0
      OnClick = btnOkClick
    end
    object btnCancel: TButton
      Left = 633
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Abbrechen'
      TabOrder = 1
      OnClick = btnCancelClick
    end
  end
end
