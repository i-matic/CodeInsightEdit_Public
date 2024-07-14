unit CodeInsightTest;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  CodeInsightEdit,
  GX_StringList,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.Grids;

type

  /// <summary>
  /// aa
  /// </summary>
  TfrnTest = class(TForm)
  memSource: TMemo;
    lblSource: TLabel;
    btnExit: TButton;
    btnTest: TButton;
    lblLinePos: TLabel;
    cbSummary: TCheckBox;
    cbRemarks: TCheckBox;
    cbResult: TCheckBox;
    cbParams: TCheckBox;
    cbEnums: TCheckBox;
    cbDocOMatic: TCheckBox;
    edtZeile: TEdit;
    cbVorgabe: TCheckBox;
    lblResult: TLabel;
    procedure memSourceClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure memSourceKeyDown(
      Sender : TObject;
      var Key: Word;
      Shift  : TShiftState);
    procedure btnTestClick(Sender: TObject);
    procedure StringGrid1DrawCell(
      Sender    : TObject;
      ACol, ARow: LongInt;
      Rect      : TRect;
      State     : TGridDrawState);
  private
    { Private-Deklarationen }

    FOriginalSource: TGXUnicodeStringList;

    procedure InitData;

    procedure ExitData;

    function GetMemoLineNo: Integer;

    procedure ShowLineNo;

  public
    { Public-Deklarationen }

    constructor Create(AOwner: TComponent); override;

    destructor Destroy; override;

  end;

var
  frnTest: TfrnTest;

implementation

{$R *.dfm}

procedure TfrnTest.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrnTest.btnTestClick(Sender: TObject);
Var
  LForm     : Tfrm_CodeInsightEdit;
  LLineNo   : Integer;
  LChanged  : Boolean;
  LInsertPos: Integer;
  LOfs      : Integer;
begin
  LChanged := False;

  If cbVorgabe.Checked Then
  Begin
    LLineNo := StrToIntDef(edtZeile.Text, 32);
  End
  Else
  Begin
    LLineNo := GetMemoLineNo;
  End;

  LForm := Tfrm_CodeInsightEdit.Create(Nil);
  Try
    LForm.IsTestVersion      := True;
    LForm.OriginalSource     := FOriginalSource;
    LForm.pnlCIETop.Caption  := 'Test';
    LForm.MethodSummary      := cbSummary.Checked;
    LForm.ResultSummary      := cbResult.Checked;
    LForm.RemarkSummary      := cbRemarks.Checked;
    LForm.EnumElementSummary := cbEnums.Checked;
    LForm.ParamSummary       := cbParams.Checked;
    LForm.DocOMatic          := cbDocOMatic.Checked;
    LForm.LineNo             := LLineNo;
    If LForm.CanShow Then
    Begin
      LForm.ShowModal;
      LChanged          := LForm.Saved;
      cbSummary.Checked := LForm.MethodSummary;

      if LChanged then
      Begin
        lblResult.Caption := 'Gespeichert';
        LOfs              := 0;
        LInsertPos        := LForm.StartLine - 1;

        memSource.Lines.BeginUpdate;

        For var i := 0 to LForm.EndLine - LForm.StartLine Do
        Begin
          memSource.Lines.Delete(LInsertPos);
        End;

        If (Trim(memSource.Lines.Strings[LInsertPos - 1]) <> EmptyStr) Then
        Begin
          memSource.Lines.Insert(LInsertPos, '');
          LOfs := 1;
        End;

        For var i := LForm.PreparedSource.Count - 1 Downto 0 Do
        Begin
          memSource.Lines.Insert(LInsertPos + LOfs, LForm.PreparedSource.Strings[i]);
        End;

        memSource.Lines.EndUpdate;

      end
      else
      Begin
        lblResult.Caption := 'Abgebrochen';
      End;
    End
    else
    Begin

      ShowMessage(LForm.Fehler);
    End;

  Finally
    FreeAndNil(LForm);
  End;
end;

constructor TfrnTest.Create(AOwner: TComponent);
begin
  inherited;
  InitData;
end;

destructor TfrnTest.Destroy;
begin
  ExitData;
  inherited;
end;

procedure TfrnTest.ExitData;
begin
  FreeAndNil(FOriginalSource);
end;

function TfrnTest.GetMemoLineNo: Integer;
begin
  Result := SendMessage(memSource.Handle, EM_LINEFROMCHAR, memSource.SelStart + memSource.SelLength, 0);
end;

procedure TfrnTest.InitData;
begin
  FOriginalSource := TGXUnicodeStringList.Create;
  FOriginalSource.LoadFromFile('Z:\VM Shared\Delphi Daten\gexperts\Source\CodeInsightExpert_Alt\CodeInsightEdit.pas');
  For var i := 0 To FOriginalSource.Count - 1 Do
  Begin
    memSource.Lines.Add(FOriginalSource.Strings[i]);
  End;
end;

procedure TfrnTest.memSourceClick(Sender: TObject);
begin
  ShowLineNo;
end;

procedure TfrnTest.memSourceKeyDown(
  Sender : TObject;
  var Key: Word;
  Shift  : TShiftState);
begin
  ShowLineNo;
end;

procedure TfrnTest.ShowLineNo;
Var
  LLineNo: Integer;
begin
  LLineNo            := GetMemoLineNo;
  lblLinePos.Caption := 'Zeile: ' + IntToStr(LLineNo + 1);
end;

procedure TfrnTest.StringGrid1DrawCell(
  Sender    : TObject;
  ACol, ARow: LongInt;
  Rect      : TRect;
  State     : TGridDrawState);
var
  LRect: TRect;
begin
  If (ACol = 0) Then
  Begin
    LRect.Left         := Rect.Left + 2;
    LRect.Top          := Rect.Top + 2;
    LRect.Width        := Rect.Width - 4;
    LRect.Height       := Rect.Height - 4;
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := clBlue;
    Canvas.FillRect(LRect);
    Canvas.TextRect(Rect, 4, 4, 'Test');
  End;
end;

end.

