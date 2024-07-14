{ ***********************************************************************
  * Unit Name: GX_eCodeInsightEditorExpert
  * Purpose  : Write Comments usable with Delphi Code Insight
  *            This expert offers an Edit Form to add Comments
  *            and delivers Results to the Editor
  * Author   : Michael Höfmann
  *********************************************************************** }

unit GX_eCodeInsightEditorExpert;

{$I GX_CondDefine.inc}

interface

uses
  SysUtils,
  Classes,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  ComCtrls,
  GX_Experts,
  GX_EditorExpert,
  GX_ConfigurationInfo,
  GX_BaseForm;

type
  /// <summary>
  /// Abgeleiteter Editor nach der Vorlage aus den GExperts Beispielen </summary>
  TGxCodeInsightEditorExpert = class(TEditorExpert)
  private

    // Summary for Method enabled
    FMethodSummary: Boolean;

    FRemarkSummary: Boolean;

    FResultSummary: Boolean;

    FEnumElements: Boolean;

    FParamSummary: Boolean;

    FDocOMatic: Boolean;

    /// <summary>
    /// Ausführen des Experten zur Eingabe von
    /// Kommentaren, die Code Insight konform sind
    /// </summary>
    procedure InternalExecute;

  public
    constructor Create; override;
    // optional, defaults to true
    function CanHaveShortCut: Boolean; override;
    // optional if HasConfigOptions returns false
    procedure Configure(_Owner: TWinControl); override;
    procedure Execute(Sender: TObject); override;
    // optional, defaults to GetName which in turn defaults to the class name
    Class function GetBitmapFileName: string; override;
    // optional, defaults to no shortcut
    function GetDefaultShortCut: TShortCut; override;
    function GetDisplayName: string; override;
    // optional, but recommended
    function GetHelpString: string; override;
    // optional, defaults to true
    function HasConfigOptions: Boolean; override;
    // Overrride to load any configuration settings
    procedure InternalLoadSettings(_Settings: IExpertSettings); override;
    // Overrride to save any configuration settings
    procedure InternalSaveSettings(_Settings: IExpertSettings); override;
  end;

type
  TfmCodeInsightEditorExpertConfig = class(TfmBaseForm)
    btnCancel: TButton;
    btnOK: TButton;
    lblData: TLabel;
    lblNote: TLabel;
    cbMethodSummary: TCheckBox;
    cbResultSummary: TCheckBox;
    cbRemarkSummary: TCheckBox;
    cbEnumSummary: TCheckBox;
    cbParamSummary: TCheckBox;
    cbDocOMatic: TCheckBox;
  end;

implementation

{$R *.dfm}

uses
{$IFOPT D+} GX_DbugIntf, {$ENDIF}
  Menus,
  Registry,
  ToolsAPI,
  CodeInsightEdit,
  GX_StringList,
  GX_GenericUtils,
  GX_OtaUtils,
  GX_GExperts;

Const

  cMethodSummaryKey = 'MethodSummary';
  cResultSummary    = 'ResultSummary';
  cRemarkSummary    = 'RemarkSummary';
  cEnumElements     = 'EnumElements';
  cParamSummary     = 'ParamSummary';
  cDocOMatic        = 'DocOMatic';

  { TGxSampleEditorExpert }

  // *********************************************************
  // Name: TGxSampleEditorExpert.CanHaveShortCut
  // Purpose: Determines whether this expert can have a
  // hotkey assigned to it
  // Note: If it returns false, no hotkey configuration
  // control is shown in the configuratoin dialog.
  // If your expert can have a hotkey, you can
  // simply delete this function, since the
  // inherited funtion already returns true.
  // *********************************************************
function TGxCodeInsightEditorExpert.CanHaveShortCut: Boolean;
begin
  Result := True;
end;

// *********************************************************
// Name: TGxSampleEditorExpert.Configure
// Purpose: Shows the config form and if the user selects
// OK then the settings are saved
// Note: If you have no config items, delete this method
// (and its declaration from the interface section)
// and the declaration of the form in the interface
// section, and remove the and set FHasConfigOptions
// to False in the Create method
// *********************************************************
procedure TGxCodeInsightEditorExpert.Configure(_Owner: TWinControl);
begin
  with TfmCodeInsightEditorExpertConfig.Create(_Owner) do
    try
      cbMethodSummary.Checked := FMethodSummary;
      cbResultSummary.Checked := FResultSummary;
      cbRemarkSummary.Checked := FRemarkSummary;
      cbEnumSummary.Checked   := FEnumElements;
      cbParamSummary.Checked  := FParamSummary;
      cbDocOMatic.Checked     := FDocOMatic;
      if ShowModal = mrOk then
      begin
        FMethodSummary        := cbMethodSummary.Checked;
        FResultSummary        := cbResultSummary.Checked;
        FRemarkSummary        := cbRemarkSummary.Checked;
        cbEnumSummary.Checked := cbEnumSummary.Checked;
        FParamSummary         := cbParamSummary.Checked;
        FDocOMatic            := cbDocOMatic.Checked;
        SaveSettings;
      end;
    finally
      Free;
    end;
end;

// *********************************************************
// Name: TGxSampleEditorExpert.Create
// Purpose: Sets up basic information about your editor expert
// *********************************************************
constructor TGxCodeInsightEditorExpert.Create;
begin
  inherited Create;

  // Set default values for any data
  FMethodSummary := True;
  FResultSummary := True;
  FRemarkSummary := True;
  FEnumElements  := True;
  FParamSummary  := True;
  FDocOMatic     := True;

  // LoadSettings is called automatically for the expert upon creation.
end;

// *********************************************************
// Name: TGxSampleEditorExpert.Execute
// Purpose: Called when your hot-key is pressed, this is
// where you code what the expert should do
// *********************************************************
procedure TGxCodeInsightEditorExpert.Execute(Sender: TObject);
begin
  InternalExecute;
end;

// *********************************************************
// Name: TGxSampleEditorExpert.GetBitmapFileName
// Purpose: Return the file name of an icon associated with
// the expert. Do not specify a path.
// Defaults to the expert's class name.
// Note: This bitmap must be included in the
// GXIcons.rc file which in turn can be created
// from all .bmp files located in the Images
// directory by calling the _CreateGXIconsRc.bat
// script located in that directory.
// It is possible to return an empty string. This
// signals that no icon file is available.
// You can remove this function from your expert
// and simply provide the bitmap as
// <TYourExpert>.bmp
// *********************************************************
Class function TGxCodeInsightEditorExpert.GetBitmapFileName: string;
begin
  Result := 'CodeInsight';
end;

// *********************************************************
// Name: TGxSampleEditorExpert.GetDefaultShortCut
// Purpose: The default shortcut to call your expert.
// Notes: It is perfectly fine not to assign a default
// shortcut and let the expert be called via
// the menu only. The user can always assign
// a shortcut to it in the configuration dialog.
// Available shortcuts have become a very rare
// resource in the Delphi IDE.
// The value of ShortCut is touchy, use the ShortCut
// button on the Editor Experts tab of menu item
// GExperts/GExperts Configuration... on an existing
// editor expert to see if you can use a specific
// combination for your expert.
// *********************************************************
function TGxCodeInsightEditorExpert.GetDefaultShortCut: TShortCut;
begin
  Result := Menus.ShortCut(Ord('?'), [ssCtrl, ssAlt]);
end;

// *********************************************************
// Name: TGxSampleEditorExpert.DisplayName
// Purpose: The expert name that appears in Editor Experts box on the
// Editor tab of menu item GExperts/GExperts Configuration...
// Experts tab on menu item GExperts/GExperts Configuration...
// *********************************************************
function TGxCodeInsightEditorExpert.GetDisplayName: string;
resourcestring
  SDisplayName = 'CodeInsight Comment Editor Expert';
begin
  Result := SDisplayName;
end;

// *********************************************************
// Name: TGxSampleEditorExpert.GetHelpString
// Purpose: To provide your text on what this editor expert
// does to the expert description hint that is shown
// when the user puts the mouse over the expert's icon
// in the configuration dialog.
// *********************************************************
function TGxCodeInsightEditorExpert.GetHelpString: string;
resourcestring
  SCodeInsightEditorExpertHelp = 'Enter Comments in your source file ' +
    'that will be displayed in Delphi Code Insight HOver Hints...' + sLineBreak + sLineBreak + 'Customize via Configuration Dialog';
begin
  Result := SCodeInsightEditorExpertHelp;
end;

// *********************************************************
// Name: TGxSampleEditorExpert.HasConfigOptions
// Purpose: Let the world know whether this expert has
// configuration options.
// *********************************************************
function TGxCodeInsightEditorExpert.HasConfigOptions: Boolean;
begin
  Result := True;
end;

procedure TGxCodeInsightEditorExpert.InternalExecute;
var
  SourceEditor      : IOTASourceEditor;
  LLine             : string;
  LStartPos         : Integer;
  LColumnNo         : Integer;
  LLineNo           : Integer;
  LSource           : TGXUnicodeStringList;
  LChanged          : Boolean;
  LImplementationPos: Integer;
  LOfs              : Integer;
  LInsertPos        : Integer;

  LForm: Tfrm_CodeInsightEdit;
begin
{$IFOPT D+} SendDebug('Executing TSelectionEditorExpert'); {$ENDIF}
  if not GxOtaTryGetCurrentSourceEditor(SourceEditor) then
    Exit;

  LLine := GxOtaGetCurrentLineData(LStartPos, LColumnNo, LLineNo);

  // ShowMessage('wir stehen hier:' + sLineBreak + LLine + sLineBreak +
  // Format('StartPos: %d  ColumnNo: %d  LineNo: %d',[LStartPos, LColumnNo, LLineNo]) + sLineBreak +
  // SourceEditor.FileName);

  LSource := TGXUnicodeStringList.Create;
  Try

    if not GxOtaGetActiveEditorText(LSource, False) then
      Exit; // ==>

    LImplementationPos := LSource.IndexOf('implementation');
    If (LImplementationPos >= 0) And (LImplementationPos > LLineNo) Then
    begin

      LChanged := False;

      LForm := Tfrm_CodeInsightEdit.Create(Nil);
      Try
        LForm.IsTestVersion      := False;
        LForm.OriginalSource     := LSource;
        LForm.pnlCIETop.Caption  := ExtractFileName(SourceEditor.FileName);
        LForm.MethodSummary      := FMethodSummary;
        LForm.ResultSummary      := FResultSummary;
        LForm.RemarkSummary      := FRemarkSummary;
        LForm.EnumElementSummary := FEnumElements;
        LForm.ParamSummary       := FParamSummary;
        LForm.DocOMatic          := FDocOMatic;
        LForm.LineNo             := LLineNo;
        If LForm.CanShow Then
        Begin
          LForm.ShowModal;
          LChanged := LForm.Saved;

          if LChanged then
          Begin

            LOfs       := 0;
            LInsertPos := LForm.StartLine - 1;

            LSource.BeginUpdate;

            For var i := 0 to LForm.EndLine - LForm.StartLine Do
            Begin
              LSource.Delete(LInsertPos);
            End;

            If (Trim(LSource.Strings[LInsertPos - 1]) <> EmptyStr) Then
            Begin
              LSource.Insert(LInsertPos, '');
              LOfs := 1;
            End;

            For var i := LForm.PreparedSource.Count - 1 Downto 0 Do
            Begin
              LSource.Insert(LInsertPos + LOfs, LForm.PreparedSource.Strings[i]);
            End;

            LSource.EndUpdate;

            GxOtaReplaceEditorTextWithUnicodeString(GxOtaGetCurrentSourceEditor, LSource.Text);
          End;
        End
        else
        Begin
          ShowMessage('Objekt nicht erkannt ' + sLineBreak +
            'Bitte auf die erste Zeile der Deklaration im Interface Abschnitt positionieren.');
        End;

      Finally
        FreeAndNil(LForm);
      End;
    end
    else
    begin
      ShowMessage('Eingaben bitte im Interface Teil');
    end;

  Finally
    FreeAndNil(LSource);
  End;

  IncCallCount;

end;

procedure TGxCodeInsightEditorExpert.InternalLoadSettings(_Settings: IExpertSettings);
begin
  inherited;
  FMethodSummary := _Settings.ReadBool(cMethodSummaryKey, True);
  FRemarkSummary := _Settings.ReadBool(cRemarkSummary, True);
  FResultSummary := _Settings.ReadBool(cResultSummary, True);
  FEnumElements  := _Settings.ReadBool(cEnumElements, True);
  FParamSummary  := _Settings.ReadBool(cParamSummary, True);
  FDocOMatic     := _Settings.ReadBool(cDocOMatic, True);
end;

procedure TGxCodeInsightEditorExpert.InternalSaveSettings(_Settings: IExpertSettings);
begin
  inherited;
  _Settings.WriteBool(cMethodSummaryKey, FMethodSummary);
  _Settings.WriteBool(cRemarkSummary, FRemarkSummary);
  _Settings.WriteBool(cResultSummary, FResultSummary);
  _Settings.WriteBool(cEnumElements, FEnumElements);
  _Settings.WriteBool(cParamSummary, FParamSummary);
  _Settings.WriteBool(cDocOMatic, FDocOMatic);
end;

// *******************************************************************
// Purpose: Lets GExperts know about this editor expert
// *******************************************************************
initialization

RegisterEditorExpert(TGxCodeInsightEditorExpert);

end.
