unit CodeInsightEdit;

interface

{DEFINE TESTLOGGING }

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.TypInfo,
  System.StrUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Grids,
{$IFDEF  TESTLOGGING}
  CodeSiteLogging,
{$ENDIF}
  GX_StringList,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  System.ImageList,
  Vcl.ImgList,
  Vcl.StdCtrls,
  Vcl.ExtCtrls;

type

  /// <summary>
  /// Aufzählung der verschiedenen Elemente
  /// von Kommentaren
  /// </summary>
  TCICommentParts = (

    /// <summary>
    /// unbekanntes Element
    /// </summary>
    cic_UnKnown,

    /// <summary>
    /// Element für eine zusammenfassende Beschreibung
    /// </summary>
    cic_Summary,

    /// <summary>
    /// Element für die Beschreibung des Ergebnisses
    /// </summary>
    cic_Result,

    /// <summary>
    /// Element für weitere Hinweise
    /// </summary>
    cic_Remark,

    /// <summary>
    /// Methoden Parameter Part
    /// </summary>
    cic_Param,

    /// <summary>
    /// Doc-O-Matic Property Part
    /// </summary>
    cic_DocOMatic

    );

  /// <summary>
  /// nächste Aktion des Parsers bei der Analyse bisher vorhandener Kommentare
  /// </summary>
  TParseNextOperation = (

    /// <summary>
    /// weiter im regulären Ablauf
    /// </summary>
    pno_Continue,

    /// <summary>
    /// diese Zeile überspringen
    /// </summary>
    pno_Skip,

    /// <summary>
    /// Kommentar eines Parameters setzen
    /// </summary>
    pno_SetParamComment,

    /// <summary>
    /// den ENum Name ermitteln
    /// </summary>
    pno_GetEnumName,

    /// <summary>
    /// eine Doc-O-Matic Eigenschaft setzen
    /// </summary>
    pno_SetDocOMatic

    );

  TCIObjectTypes = (

    /// <summary>
    /// nicht erkanntes zu kommentierendes Objekt
    /// </summary>
    cio_Unknown,

    /// <summary>
    /// zu kommentierendes Attribut erkannt
    /// </summary>
    cio_Attribute,

    /// <summary>
    /// zu kommentierende Prozedur erkannt
    /// </summary>
    cio_Procedure,

    /// <summary>
    /// zu kommentierende Funktion erkannt
    /// </summary>
    cio_Function,

    /// <summary>
    /// zu kommentierenden Aufzählungstyp erkannt
    /// </summary>
    cio_Enum,

    /// <summary>
    /// zu kommentierende Klasse erkannt
    /// </summary>
    cio_Class,

    /// <summary>
    /// Doc-OMatic Element erkannt
    /// </summary>
    cio_DocOMatic,

    /// <summary>
    /// zu kommentierendes Property erkannt
    /// </summary>
    cio_Property);

  /// <summary>
  /// Formular zum Erfassen der Kommentare
  /// </summary>
  /// <remarks>
  /// Im Gegensatz zu Documentation Insight, dass ich lange Zeit genutzt habe und
  /// nun für Delphi 12 nicht mehr verfügbar ist, erfolgen die Eingaben in einem modalen
  /// Fenster. Damit entfallen die nervigen Exceptions, wenn man während der Kommentierung
  /// den Bezeichner geändert hat.
  /// Ruhe vor den Exceptions hatte man erst nach einem Neustart der IDE.
  /// </remarks>
  Tfrm_CodeInsightEdit = class(TForm)
    pnlCIETop: TPanel;
    pnlCIEMain: TPanel;
    pnlCIEBottom: TPanel;
    btnOk: TButton;
    btnCancel: TButton;
    lblObjectName: TLabel;
    sbEdit: TScrollBox;
    cbObjectTypes: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormKeyDown(
      Sender : TObject;
      var Key: Word;
      Shift  : TShiftState);
  private

    /// <summary>
    /// Attribut um sich zu merken, ob der Anwender die Änderungen übernehmen möchte oder nicht
    /// </summary>
    FSaved: Boolean;

    /// <summary>
    /// Merker, ob es sich um eine Testversion handelt. Bei der Testversion können
    /// zusätzliche Ausgaben über das CodeSite Logging Tool ausgegeben werden
    /// </summary>
    FTestVersion: Boolean;

    /// <summary>
    /// Kann ein Objekt nicht ermittelt werden, oder wurden
    /// für alle möglichen Elemente die Eingaben deaktiviert,
    /// wird über dieses Property die entsprechende Fehlermeldung
    /// ausgegeben
    /// </summary>
    FFehler: string;

    /// <summary>
    /// Beim Einlesen des zu überarbeitenden Quelltext Abschnittes
    /// wird die aktuelle Einrückung ermittelt und hier gespeichert,
    /// damit die Ausgabe auch bündig erfolgt
    /// </summary>
    FIndent: Integer;

    /// <summary>
    /// Beim Einlesen des zu überarbeitenden Quelltext Abschnittes
    /// wird die erste Quelltextzeile ermittelt und hier gespeichert
    /// Der eingelesene Quelltext Abschnitt umfasst Kommentare und Definition bis zum Semikolon.
    /// </summary>
    FStartLine: Integer;

    /// <summary>
    /// Beim Einlesen des zu überarbeitenden Quelltext Abschnittes
    /// wird die letzte Quelltextzeile ermittelt und hier gespeichert
    /// Der eingelesene Quelltext Abschnitt umfasst Kommentare und Definition bis zum Semikolon.
    /// </summary>
    FEndLine: Integer;

    /// <summary>
    /// Da bei Enums die Kommentare der Element nicht vor
    /// der Deklaration, sondern vor den Elementen steht,
    /// wird dieser Merker genutzt um zu unterscheiden, ob
    /// das aktuelle SUMMARY Element zur Definition des ENums
    /// oder zum Enum Elelement gehört
    /// </summary>
    FEnumDefinitionPassed: Boolean;

    /// <summary>
    /// Bei der Ausgabe der ENum Kommentare muss das Enum Statement
    /// neu aufgebaut werden, weil sich die Kommentare innerhalb des Statements befinden.
    /// In diesem String wird die ENum Definition gespeichert
    /// </summary>
    FENumDefinition: string;

    /// <summary>
    /// In diesem Feld wird gespeichert, ob ein Element zur Kommentierung gefunden
    /// werden konnte. Wurde keines gefunden, wird das Eingabe Formular nicht angzeigt,
    /// sondern eine Fehlermeldung statt dessen
    /// </summary>
    FCanShow: Boolean;

    /// <summary>
    /// Schalter aus den Einstellungen
    /// Wenn aktiv können auch Doc-O-Matic Parameter verwaltet werden
    /// </summary>
    FDocOMatic: Boolean;

    /// <summary>
    /// Schalter aus den Einstellungen
    /// Zusammenfassende Beschreibung des Objektes aktiviert
    /// </summary>
    FObjectSummary: Boolean;

    /// <summary>
    /// Schalter aus den Einstellungen
    /// Beschreibung des Methoden Ergebnisses aktiviert
    /// </summary>
    FResultSummary: Boolean;

    /// <summary>
    /// Schalter aus den Einstellungen
    /// Erfassung von Ergänzenden Hinweisen zu einem Objekt aktiviert
    /// </summary>
    FRemarkSummary: Boolean;

    /// <summary>
    /// Schalter aus den Einstellungen
    /// Kommentierung einzelner ENum Elemente aktiviert
    /// </summary>
    FEnumElementSummary: Boolean;

    /// <summary>
    /// Schalter aus den Einstellungen
    /// Beschreibung von Aufruf Parametern aktiviert
    /// </summary>
    FParamSummary: Boolean;

    /// <summary>
    /// Der Objekt Typ der beim Parsen des übernommenen Quelltext
    /// Abschnittes ermittelt wurde. Wurde keiner ermittelt,
    /// dann kann das Eingabe Fenster nicht geöffnet werden.
    /// </summary>
    FObjectType: TCIObjectTypes;

    /// <summary>
    /// In dieser Liste befindet sich der Original Quelltext.
    /// Wird von GExperts übergeben
    /// </summary>
    FOriginalSource: TGXUnicodeStringList;

    /// <summary>
    /// Überschrift über der Objekt Summary
    /// </summary>
    FObjectSumLabel: TLabel;

    /// <summary>
    /// Eingabe Memo für die Objekt Zusammenfassung
    /// </summary>
    FObjectSumMemo: TMemo;

    /// <summary>
    /// Label für die Überschrift zur Eingabe der
    /// Beschreibung des Ergebnisses einer Methode
    /// </summary>
    FMethResLabel: TLabel;

    /// <summary>
    /// Eingabe Memo für das Methoden Ergebnis
    /// </summary>
    FMethResMemo: TMemo;

    /// <summary>
    /// Label für die Überschrift zur Eingabe der
    /// ergänzenden Beschreibung des Objektes
    /// </summary>
    FMethRemLabel: TLabel;

    /// <summary>
    /// Eingabe Memo für die ergänzende Beschreibung des Objektes
    /// </summary>
    FMethRemMemo: TMemo;

    /// <summary>
    /// Label für die Überschrift zur Eingabe der
    /// Eingabe von Aufzählungstypen Beschreibungen
    /// </summary>
    FEnumLabel: TLabel;

    /// <summary>
    /// StringGrid zur Erfassung der Beschreibung der
    /// einzelnen Elemente des Aufzählungstypen
    /// </summary>
    FEnumElements: TStringGrid;

    /// <summary>
    /// Label für die Überschrift zur Eingabe der
    /// Beschreibungen zu Methoden Parametern
    /// </summary>
    FParamLabel: TLabel;

    /// <summary>
    /// StringGrid zur Erfassung der Beschreibung der
    /// einzelnen Parameter eine Methode
    /// </summary>
    FParamElements: TStringGrid;

    /// <summary>
    /// Liste mit allen Parameter einer Methode
    /// </summary>
    FParamList: TStringList;

    /// <summary>
    /// Label für die Überschrift zur Eingabe der
    /// Parameter für eine Doc-O-Matic Ausgabe
    /// </summary>
    FDocOMaticLabel: TLabel;

    /// <summary>
    /// StringGrid zur Erfassung der Doc-O-Matic Parameter
    /// </summary>
    FDocOMaticElements: TStringGrid;

    /// <summary>
    /// Liste mit allen Parameter für eine Doc-O-Matic Ausgabe
    /// </summary>
    FDocOMaticList: TStringList;

    /// <summary>
    /// Speichert die Zeilennummer im Original Quelltext
    /// Buffer mit der der Kommentierungsexperte aufgerufen wurde.
    /// Der Setter dazu ruft den Parser auf, der das Objekt ermittelt.
    /// Auf dem Rückweg in den Quelltext Editor wird die Quelltext Position
    /// durch die Elemente FStartLine und FEndLine bestimmt.
    /// FLineNo ist  nur der Anhaltspunkt für den Aufruf. Selektiert wird
    /// das gesamte Statement, dass kommentiert werden soll. Das ist in
    /// der Regel und je nach Formatierung, länger als eine Zeile
    /// </summary>
    FLineNo: Integer;

    /// <summary>
    /// Liste mit den einzelnen ENum Elementen
    /// </summary>
    FEnumList: TStringList;

    /// <summary>
    /// Nach der Übergabe der Zeile, in der sich der Cursor befand,
    /// als der Experte aufgerufen wurde, wird mit der Methode GetCIObject
    /// das gesamte Statement oberhalb und unterhalb dieser Zeile ermittelt
    /// und in dieser Liste abgelegt
    /// </summary>
    FSourcePart: TStringList;

    /// <summary>
    /// In dieser Liste wird der Quelltext mit den neuen Kommentaren zusammen
    /// gesetzt, bevor er an den Delphi Editor zurück gegeben wird
    /// </summary>
    FPreparedSource: TStringList;

    /// <summary>
    /// In dieser Liste sind die Instruktionen des
    /// zu beschreibenden Objektes enthalten. Dieser Liste wird in
    /// der Regel der Kommentar voran gestellt
    /// </summary>
    FInstructionPart: TStringList;

    { Private-Deklarationen }

    /// <summary>
    /// Initialisierung von Klassen Objekten
    /// </summary>
    procedure InitData;

    /// <summary>
    /// Bereinigung von Klassen Objekten
    /// </summary>
    procedure ExitData;

    /// <summary>
    /// Übergeordnete Methode um die Kommentierung
    /// aufzubereiten. Ruft die anderen Write Methoden auf
    /// </summary>
    procedure WritePreparedSource;

    /// <summary>
    /// Ausgabe des Instruktionsteils
    /// </summary>
    procedure WriteInstructionPart;

    /// <summary>
    /// Ausgabe der Kommentare zu Enums
    /// </summary>
    procedure WriteEnumElements;

    /// <summary>
    /// Ausgabe der Parameter für Doc-O-Matic
    /// </summary>
    procedure WriteDocOMatic;

    /// <summary>
    /// Ausgabe der Kommentierung für Methoden Parameter
    /// </summary>
    procedure WriteParams;

    /// <summary>
    /// Ausgabe der zusammenfassenden Objekt Beschreibung
    /// </summary>
    procedure WriteSummary;

    /// <summary>
    /// Ausgabe der Beschreibung des Methoden Ergebnisses
    /// </summary>
    procedure WriteResult;

    /// <summary>
    /// Ausgabe der erfassten ergänzenden Bemerkungen
    /// zum Objekt
    /// </summary>
    procedure WriteRemarks;

    /// <summary>
    /// Untermethode, die den Inhalt eines Memos, in
    /// dem ein Kommentar erfasst wurde, ausgibt
    /// </summary>
    /// <param name="AMemo">
    /// Memo, dessen Kommentar ausgegeben werden soll
    /// </param>
    procedure WriteMemoContent(AMemo: TMemo);

    /// <summary>
    /// Methode, die den führenden String für einen Kommentar
    /// in der Delphi Insight Konvention unter Berücksichtigung
    /// der Einrückung (FIndent) zurück gibt
    /// </summary>
    function LeadingLine: string;

    /// <summary>
    /// Methode, die den führenden String unter Berücksichtigung
    /// der Einrückung (FIndent) zurück gibt
    /// </summary>
    /// <result>
    /// Dieser String ist KEIN Kommentar, sondern für die
    /// Ausgabe der Instruktionen da
    /// </result>
    function IndentLine: string;

    /// <summary>
    /// In der Combobox oben rechts, wird der erkannte Objekt
    /// Typ angezeigt. Diese Methode macht aus dem Objekt
    /// Typ Aufzählungstypen einen verständlichen Text
    /// </summary>
    /// <param name="AObjType">
    /// aktueller Objekt Typ
    /// </param>
    /// <result>
    /// Lesbarer und verständlicher Text
    /// </result>
    function GetObjectTypeStr(Const AObjType: TCIObjectTypes): string;

    /// <property name="title" value="Initialsierung des Eingabe Bereiches" />
    /// <property name="titleimg" value="indicator-abstract-16" />
    /// <summary>
    /// je nach Objekt Typ sind unterschiedliche Eingabe Felder erforderlich
    /// Diese Methode erstellt die erforderlichen Eingabe Felder und
    /// Beschriftungen und konfiguriert sie
    /// </summary>
    procedure InitScrollBox;

    /// <summary>
    /// Diese Methode initialisiert die Combobox oben rechts mit
    /// den vorhandenen Objekt Typen
    /// </summary>
    procedure InitObjectTypes;

    /// <summary>
    /// Diese Methode ermittelt die aktuelle Einrückung anhand des
    /// übergebenen Strings
    /// </summary>
    /// <param name="ASource">
    /// Quelltext Zeile
    /// </param>
    /// <remarks>
    /// Das Ergebnis wird im Klassenfeld FIndent gespeichert
    /// </remarks>
    procedure GetIndent(const ASource: String);

    /// <summary>
    /// Diese Methode wird von Setter zu FLineNo aufgerufen und
    /// ermittelt anhand des gewählten Quelltext Blocks den Objekt Typen
    /// </summary>
    /// <remarks>
    /// In der Methode wird auch bestimmt, ob es sich um ein Objekt handelt, was unterstützt wird.
    /// Die FCanShow Eigenschaft wird hier gesetzt
    /// </remarks>
    procedure GetCIObject;

    /// <summary>
    /// Ermittlung des Instruktionsteils des Quelltext Abschnitts, der
    /// ausgewählt wurde
    /// </summary>
    procedure GetInstructionPart;

    /// <summary>
    /// Vor der Anzeige des Experten ist der vorhandene Kommentar
    /// aufzubereiten und auf die Eingabe Felder zu verteilen.
    /// Dazu wird hier GetObjectComment aufgerufen
    /// </summary>
    procedure InitCommentAsItIs;

    /// <summary>
    /// Aufbereitung des vorhandenen Kommentars zu Eingabe
    /// </summary>
    procedure GetObjectComment;

    /// <summary>
    /// Setzen eines Doc-O-Matic Parameters
    /// in das Grid zur Anzeige und Bearbeitung
    /// </summary>
    /// <param name="ADocOMaticValue">
    /// Wert des Propertys
    /// </param>
    /// <param name="ADocOMaticName">
    /// Name des Propertys
    /// </param>
    procedure SetDocOMaticValue(Const ADocOMaticValue, ADocOMaticName: String);

    /// <summary>
    /// Name und Wert eines Propertys aus einem
    /// bereits vorhandenen Kommentars übermitteln
    /// Der Kommentar wird in Value übergeben
    /// Zurück gegeben werden dann Name und Value
    /// </summary>
    /// <param name="ADocOMaticName">
    /// Name des Propertys
    /// </param>
    /// <param name="ADocOMaticValue">
    /// Wert des Propertys
    /// </param>
    procedure GetDocOMaticNameAndValue(Var ADocOMaticName, ADocOMaticValue: String);

    /// <summary>
    /// einen bereits vorhandenen Kommentar für einen Parameter
    /// in die Tabelle des Eingabe Formulars übernehmen
    /// </summary>
    /// <param name="AComment">
    /// Kommentar
    /// </param>
    /// <param name="AParamName">
    /// Parameter Name
    /// </param>
    procedure SetParamComment(Const AComment, AParamName: String);

    /// <summary>
    /// Einen bereits vorhandenen Kommentar zu einem ENum in
    /// die Eingabe Tabelle des Formulars übernehmen
    /// </summary>
    /// <param name="AEnumComment">
    /// Kommentar zum Enum
    /// </param>
    /// <param name="AEnumName">
    /// Name des ENum
    /// </param>
    procedure SetEnumComment(Const AEnumComment, AEnumName: String);

    /// <summary>
    /// Aus den bisherigen Kommentaren das Kommentar Element, oder
    /// den Kommentar Typen ermitteln (SUMMARY, RESULT etc.)
    /// Anhand des Tokens (geöffnet oder geschlossen) auch die
    /// nächste Aktion des Parsers ermitteln und ggf. auch das Namens
    /// Attribut für z.B. den Parameter Namen ermitteln und zurück geben
    /// </summary>
    /// <param name="AStr">
    /// aktuell verarbeitete Zeile
    /// </param>
    /// <param name="ACurrent">
    /// aktueller Kommentar Typ
    /// </param>
    /// <param name="AParamName">
    /// ggf. Name des Parameters zurück geben
    /// </param>
    /// <param name="ANextOperation">
    /// nächste Operation des Parsers
    /// </param>
    function GetComType(
      Const AStr        : String;
      Const ACurrent    : TCICommentParts;
      Var AParamName    : String;
      Var ANextOperation: TParseNextOperation): TCICommentParts;

    /// <summary>
    /// Hat der übergebene String eine Code Insight Comment Markierung
    /// also die drei Slashes
    /// </summary>
    /// <param name="ALine">
    /// zu testende Zeile
    /// </param>
    function HasCICMark(Const ALine: string): Boolean;

    /// <summary>
    /// Entfernen einer eventuell vorhandenen Code Insight Comment Markierung
    /// </summary>
    /// <param name="ALine">
    /// zu prüfende Zeile
    /// </param>
    function RemoveCICMark(Const ALine: string): String;

    /// <summary>
    /// stellt fest, ob in der Quelltext Zeile ein
    /// in Delphi reserviertes Wort enthalten ist um
    /// ein Ende Kriterium in die Vervollständigung nach
    /// Oben des Quelltext Ausschnittes zu ermitteln
    /// </summary>
    /// <param name="ASource">
    /// Die zu untersuchende Quelltextzeile
    /// </param>
    /// <param name="AKlammerAuf">
    /// aktuelle Anzahl der geöffneten Klammern bis zu dieser Zeile
    /// </param>
    /// <param name="AKlammerZu">
    /// aktuelle Anzahl der geschlossenen Klammern bis zu dieser Zeile
    /// </param>
    /// <result>
    /// Liefert TRUE zurück, wenn in der Zeile ASource
    /// ein reserviertes Wort am Anfang gefunden wurde oder
    /// die Zeile nur aus einem reservierten Wort bestanden hat
    /// </result>
    /// <remarks>
    /// Klickt der User mitten in eine Deklaration, dann
    /// muss diese zur Vervollständigung nach oben komplettiert werden.
    /// Nur nach unten ist das Semikolon ein Merkmal, dass das Ende
    /// des Befehles erkennen lässt (unter Berücksichtigung der Klammern)
    /// </remarks>
    function IstReserviertesWort(
      Const ASource                : String;
      Const AKlammerAuf, AKlammerZu: Integer): Boolean;

    /// <summary>
    /// Den Teil in der Scroll Box initialisieren, der für die Eingabe
    /// der Objekt Zusammenfassung erforderlich ist
    /// </summary>
    /// <param name="ATop">
    /// Top Position in der Scroll Box
    /// </param>
    /// <param name="ALeft">
    /// Left Position in der Scroll Box
    /// </param>
    procedure InitMethodSummaryPart(
      Var ATop   : Integer;
      Const ALeft: Integer = 10);

    /// <summary>
    /// Den Teil in der Scroll Box initialisieren, der für die Kommentierung
    /// des Methoden Ergebnisses erforderlich ist
    /// </summary>
    /// <param name="ATop">
    /// Top Position in der Scroll Box
    /// </param>
    /// <param name="ALeft">
    /// Left Position in der Scroll Box
    /// </param>
    procedure InitMethodResultPart(
      Var ATop   : Integer;
      Const ALeft: Integer = 10);

    /// <summary>
    /// Den Teil in der Scroll Box initialisieren, der für die ergänzende
    /// Kommentierung des Objektes erforderlich ist
    /// </summary>
    /// <param name="ATop">
    /// Top Position in der Scroll Box
    /// </param>
    /// <param name="ALeft">
    /// Left Position in der Scroll Box
    /// </param>
    procedure InitMethodRemarksPart(
      Var ATop   : Integer;
      Const ALeft: Integer = 10);

    /// <summary>
    /// Den Teil in der Scroll Box initialisieren, der für die
    /// Kommentierung von Aufzählungs Elementen erforderlich ist
    /// </summary>
    /// <param name="ATop">
    /// Top Position in der Scroll Box
    /// </param>
    /// <param name="ALeft">
    /// Left Position in der Scroll Box
    /// </param>
    procedure InitEnumElementPart(
      Var ATop   : Integer;
      Const ALeft: Integer = 10);

    /// <summary>
    /// Den Teil in der Scroll Box initialisieren, der für die
    /// Kommentierung von Methoden Parametern erforderlich ist
    /// </summary>
    /// <param name="ATop">
    /// Top Position in der Scroll Box
    /// </param>
    /// <param name="ALeft">
    /// Left Position in der Scroll Box
    /// </param>
    procedure InitParamPart(
      Var ATop   : Integer;
      Const ALeft: Integer = 10);

    /// <summary>
    /// Den Teil in der Scroll Box initialisieren, der für die
    /// Kommentierung von Doc-O-Matic Parametern erforderlich ist
    /// </summary>
    /// <param name="ATop">
    /// Top Position in der Scroll Box
    /// </param>
    /// <param name="ALeft">
    /// Left Position in der Scroll Box
    /// </param>
    procedure InitDocOMaticPart(
      Var ATop   : Integer;
      Const ALeft: Integer = 10);

    /// <summary>
    /// Den Bezeichner Namen eines Objektes bestimmen
    /// </summary>
    /// <param name="ALine">
    /// Zeile mit der Definition des Objektes
    /// </param>
    function GetObjectName(Const ALine: string): string;

    /// <summary>
    /// Ist die übergebene Zeile eine Definition für
    /// einen Aufzählungstypen
    /// </summary>
    /// <param name="ALine">
    /// zu prüfende Zeile
    /// </param>
    /// <result>
    /// TRUE, wenn es sich bei der Zeile um eine Aufzählungsdeklaration handelt, sonst FALSE
    /// </result>
    Function CheckEnumDefinitionLine(const ALine: String): Boolean;

    /// <summary>
    /// Ermittelt aus einer Zeile die einzelnen ENum Elemente
    /// </summary>
    /// <param name="AStr">
    /// Zeile mit der Enum Definition
    /// </param>
    procedure GetEnumList(Const AStr: String);

    /// <summary>
    /// Ermittelt aus einer Zeile die einzelnen Parameter einer Methode
    /// </summary>
    /// <param name="AStr">
    /// Zeile mit der Enum Definition
    /// </param>
    /// <param name="APropParam">
    /// Parameter von Propertys
    /// </param>
    procedure GetParamList(
      Const AStr      : String;
      Const APropParam: Boolean = False);

    /// <summary>
    /// Name einer Methode ermitteln
    /// </summary>
    /// <param name="AStr">
    /// Quelltext Zeile
    /// </param>
    /// <param name="AStart">
    /// Start der Untersuchung auf den Namen
    /// </param>
    /// <result>
    /// Gibt den Namen der Methode zurück
    /// </result>
    function GetFunctionName(
      Const AStr  : string;
      Const AStart: Integer): string;

    /// <summary>
    /// Name der Klasse ermitteln
    /// </summary>
    /// <param name="AStr">
    /// zu prüfende Zeile
    /// </param>
    /// <param name="AStart">
    /// Start der Überprüfung
    /// </param>
    /// <result>
    /// Gibt den Namen der Klasse zurück
    /// </result>
    function GetClassName(
      Const AStr  : string;
      Const AStart: Integer): string;

    // Getter und Setter
    procedure SetFMethodSummary(const Value: Boolean);
    procedure SetFLineNo(const Value: Integer);
    procedure SetFRemarkSummary(const Value: Boolean);
    procedure SetFResultSummary(const Value: Boolean);
    procedure SetFEnumElementSummary(const Value: Boolean);
    procedure SetFParamSummary(const Value: Boolean);
    procedure SetFDocOMatic(const Value: Boolean);
    procedure SetFTestVersion(const Value: Boolean);
    function GetOriginalLine(ALineNo: Integer): string;

  public
    { Public-Deklarationen }

    /// <summary>
    /// Konstruktor des Formulars
    /// </summary>
    /// <param name="AOwner">
    /// Parent des Formulars
    /// </param>
    constructor Create(AOwner: TComponent); override;

    /// <summary>
    /// Destruktor
    /// </summary>
    destructor Destroy; override;

    /// <summary>
    /// Veröffentlichung von FSaved
    /// </summary>
    property Saved: Boolean read FSaved;

    /// <summary>
    /// Veröffentlichung von FOriginalSource
    /// </summary>
    property OriginalSource: TGXUnicodeStringList Read FOriginalSource write FOriginalSource;

    /// <summary>
    /// Rückgabe einer bestimmten Quelltext Zeile
    /// </summary>
    /// <param name="ALineNo">
    /// Zeilen Nummer
    /// </param>
    /// <remarks>
    /// Wenn die Zeilennummer nicht vorhanden ist, dann wird ein Leer String zurück gegeben
    /// </remarks>
    property OriginaLine[ALineNo: Integer]: string Read GetOriginalLine;

    /// <summary>
    /// Lesen und Setzen der Zeilennummer
    /// Durch das Setzen der Zeilennummer wird die Analyse des Quelltextes
    /// gestartet und versucht das zu kommentierende Objekt zu ermitteln
    /// Das Setzen der Zeilennummer muss daher zuletzt unmittelbar vor
    /// ShowModal erfolgen
    /// </summary>
    property LineNo: Integer Read FLineNo write SetFLineNo;

    /// <summary>
    /// Objekt Beschreibung eingeschaltet
    /// </summary>
    /// <remarks>
    /// Der Name ist etwas irreführend, aber da es die gleiche Art der
    /// Beschreibung, wie bei den Methoden ist, passt das auch
    /// </remarks>
    Property MethodSummary: Boolean read FObjectSummary write SetFMethodSummary;

    /// <summary>
    /// Ergebnis Beschreibung bei Methoden eingeschaltet ?
    /// </summary>
    Property ResultSummary: Boolean Read FResultSummary write SetFResultSummary;

    /// <summary>
    /// ergänzende Objekt Beschreibung eingeschaltet ?
    /// </summary>
    Property RemarkSummary: Boolean Read FRemarkSummary write SetFRemarkSummary;

    /// <summary>
    /// Enum Kommentierung eingeschaltet ?
    /// </summary>
    Property EnumElementSummary: Boolean read FEnumElementSummary write SetFEnumElementSummary;

    /// <summary>
    /// Parameter Kommentierung eingeschaltet ?
    /// </summary>
    property ParamSummary: Boolean Read FParamSummary write SetFParamSummary;

    /// <summary>
    /// Doc-O-Matic Unterstützung eingeschaltet ?
    /// </summary>
    property DocOMatic: Boolean Read FDocOMatic Write SetFDocOMatic;

    /// <summary>
    /// Rückgabe, ob der Editor angezeigt werden kann oder
    /// nicht
    /// </summary>
    property CanShow: Boolean read FCanShow;

    /// <summary>
    /// Rückgabe eines Fehlertextes
    /// </summary>
    property Fehler: string Read FFehler;

    /// <summary>
    /// Rückgabe der ersten geänderten Zeile, bezogen auf
    /// den ursprünglichen Quelltext
    /// </summary>
    property StartLine: Integer Read FStartLine;

    /// <summary>
    /// Rückgabe der letzten geänderten Zeile, bezogen auf
    /// den ursprünglichen Quelltext
    /// </summary>
    property EndLine: Integer Read FEndLine;

    /// <summary>
    /// Lesen und Schreiben von FPreparedSource
    /// </summary>
    /// <remarks>
    /// Property dient der Rückgabe des kommentierten Quelltextes
    /// </remarks>
    property PreparedSource: TStringList Read FPreparedSource;

    /// <summary>
    /// Lesen und Schreiben von FObjectType
    /// </summary>
    property ObjectType: TCIObjectTypes Read FObjectType Write FObjectType;

    /// <summary>
    /// Lesen und Schreiben von FIsTestVersion
    /// </summary>
    property IsTestVersion: Boolean read FTestVersion write SetFTestVersion;

  end;

implementation

{$R *.dfm}

Const

  /// <summary>
  /// Gesamt Rand der Elemente in der Scroll Box
  /// Hälfte rechts, Hälfte links
  /// </summary>
  cRand = 20;

  /// <summary>
  /// Summary Kommentar ein
  /// </summary>
  cSummaryOn = '<summary>';

  /// <summary>
  /// Summary Kommentar aus
  /// </summary>
  cSummaryOff = '</summary>';

  /// <summary>
  /// Remarks Kommentar ein
  /// </summary>
  cRemarksOn = '<remarks>';

  /// <summary>
  /// Remarks Kommentar aus
  /// </summary>
  cRemarksOff = '</remarks>';

  /// <summary>
  /// Result Kommentar ein
  /// </summary>
  cResultOn = '<result>';

  /// <summary>
  /// Result Kommentar aus
  /// </summary>
  cResultOff = '</result>';

  /// <summary>
  /// Parameter Kommentar ein
  /// </summary>
  cParamOn = '<param';

  /// <summary>
  /// Parameter Kommentar aus
  /// </summary>
  cParamOff = '</param';

  /// <summary>
  /// Value Kommentar ein (Doc-O-Matic Äquivalent zu SUMMARY)
  /// </summary>
  cValueOn = '<value>';

  /// <summary>
  /// Value Kommentar aus (Doc-O-Matic Äquivalent zu SUMMARY)
  /// </summary>
  cValueOff = '</value>';

  /// <summary>
  /// Doc-O-Matic Property Eintrag Beginn
  /// Die Korrekten Einstellungen zur Kommentierun in Doc-O-Matic beachten !
  /// </summary>
  cDocOMaticOn = '<property';

  /// <summary>
  /// Doc-O-Matic Property Eintrag Ende
  /// Die Korrekten Einstellungen zur Kommentierun in Doc-O-Matic beachten !
  /// </summary>
  cDocOMaticOff = ' />';

  { Tfrm_CodeInsightEdit }

procedure Tfrm_CodeInsightEdit.btnCancelClick(Sender: TObject);
begin
  FSaved := False;
  FPreparedSource.Clear;
  Close;
end;

procedure Tfrm_CodeInsightEdit.btnOkClick(Sender: TObject);
begin
  FSaved := True;
  WritePreparedSource;
  Close;
end;

function Tfrm_CodeInsightEdit.CheckEnumDefinitionLine(const ALine: String): Boolean;
Var
  LStrOhneBlank: string;
begin
  Result := False;
  If Not HasCICMark(ALine) Then
  Begin
    LStrOhneBlank := Trim(ALine);
    LStrOhneBlank := StringReplace(LStrOhneBlank, ' ', '', [rfReplaceAll]);
    LStrOhneBlank := LowerCase(LStrOhneBlank);
    Result        := (Pos('=(', LStrOhneBlank) > 0);
  End;
end;

constructor Tfrm_CodeInsightEdit.Create(AOwner: TComponent);
begin
  inherited;
  InitData;
end;

destructor Tfrm_CodeInsightEdit.Destroy;
begin
  ExitData;
  inherited;
end;

procedure Tfrm_CodeInsightEdit.ExitData;
begin
  FreeAndNil(FSourcePart);
  FreeAndNil(FInstructionPart);
  FreeAndNil(FParamList);
  FreeAndNil(FDocOMaticList);
  FreeAndNil(FEnumList);
  FreeAndNil(FPreparedSource);
end;

procedure Tfrm_CodeInsightEdit.FormKeyDown(
  Sender : TObject;
  var Key: Word;
  Shift  : TShiftState);
begin
  If (Key = VK_ESCAPE) Then
  Begin
    btnCancelClick(Sender);
  End;
  If (ssShift in Shift) Then
  Begin
    If (Key = VK_RETURN) Then
    Begin
      Key := 0;
      btnOkClick(Sender);
    End;
  End;
end;

procedure Tfrm_CodeInsightEdit.FormShow(Sender: TObject);
begin
  InitScrollBox;
  InitCommentAsItIs;
end;

function Tfrm_CodeInsightEdit.GetClassName(
  const AStr  : string;
  const AStart: Integer): string;
Var
  LPos: Integer;
begin
  Result := '';
  LPos   := AStart;
  While (LPos <= Length(AStr)) And (Not(Ord(AStr[LPos]) in [Ord(' '), Ord('=')])) Do
  Begin
    Result := Result + Copy(AStr, LPos, 1);
    LPos   := LPos + 1;
  End;
end;

function Tfrm_CodeInsightEdit.GetComType(
  const AStr        : String;
  Const ACurrent    : TCICommentParts;
  Var AParamName    : String;
  Var ANextOperation: TParseNextOperation): TCICommentParts;
Var
  LPos: Integer;
begin
  Result         := ACurrent;
  ANextOperation := pno_Continue;

  If FObjectSummary Then
  Begin
    If SameText(cValueOn, Copy(AStr, 1, Length(cValueOn))) Then
    Begin
      Result         := cic_Summary;
      ANextOperation := pno_Skip;
      If Not FEnumDefinitionPassed Then
      Begin
        FObjectSumMemo.Lines.Clear;
      End;
    End;

    If SameText(cValueOff, Copy(AStr, 1, Length(cValueOff))) Then
    Begin
      Result := cic_UnKnown;
      If FEnumDefinitionPassed Then
      Begin
        ANextOperation := pno_GetEnumName;
      End;
    End;

    If SameText(cSummaryOn, Copy(AStr, 1, Length(cSummaryOn))) Then
    Begin
      Result         := cic_Summary;
      ANextOperation := pno_Skip;
      If Not FEnumDefinitionPassed Then
      Begin
        FObjectSumMemo.Lines.Clear;
      End;
    End;

    If SameText(cSummaryOff, Copy(AStr, 1, Length(cSummaryOff))) Then
    Begin
      Result := cic_UnKnown;
      If FEnumDefinitionPassed Then
      Begin
        ANextOperation := pno_GetEnumName;
      End;
    End;
  End;

  If FRemarkSummary Then
  Begin
    If SameText(cRemarksOn, Copy(AStr, 1, Length(cRemarksOn))) Then
    Begin
      Result         := cic_Remark;
      ANextOperation := pno_Skip;
      FMethRemMemo.Lines.Clear;
    End;
    If SameText(cRemarksOff, Copy(AStr, 1, Length(cRemarksOff))) Then
    Begin
      Result := cic_UnKnown;
    End;
  End;

  If FResultSummary Then
  Begin
    If SameText(cResultOn, Copy(AStr, 1, Length(cResultOn))) Then
    Begin
      Result         := cic_Result;
      ANextOperation := pno_Skip;
      FMethResMemo.Lines.Clear;
    End;
    If SameText(cResultOff, Copy(AStr, 1, Length(cResultOff))) Then
    Begin
      Result := cic_UnKnown;
    End;
  End;

  If FParamSummary Then
  Begin
    If SameText(cParamOn, Copy(AStr, 1, Length(cParamOn))) Then
    Begin
      Result := cic_Param;
      // FMethResMemo.Lines.Clear;
      ANextOperation := pno_Skip;

      LPos := Pos('name="', LowerCase(AStr));
      If (LPos > 0) Then
      Begin
        // <param name="ANode">
        AParamName := Copy(AStr, LPos + 6, Length(AStr));
        LPos       := Pos('"', AParamName);
        If (LPos > 0) Then
        Begin
          AParamName := Copy(AParamName, 1, LPos - 1);
        End;
      End;

{$IFDEF  TESTLOGGING}
      CodeSite.Send('Parameter Name: >' + AStr + '<  --->' + AParamName + '<');
{$ENDIF}
    End;
    If SameText(cParamOff, Copy(AStr, 1, Length(cParamOff))) Then
    Begin
      Result         := cic_UnKnown;
      ANextOperation := pno_SetParamComment;
    End;
  End;

  If FDocOMatic Then
  Begin
    If SameText(cDocOMaticOn, Copy(AStr, 1, Length(cDocOMaticOn))) Then
    Begin
{$IFDEF  TESTLOGGING}
      CodeSite.Send('Doc-O-Matic On: ' + sLineBreak + AStr);
{$ENDIF}
      Result         := cic_DocOMatic;
      ANextOperation := pno_Continue;
    End;
    If SameText(cDocOMaticOff, RightStr(AStr, Length(cDocOMaticOff))) Then
    Begin
{$IFDEF  TESTLOGGING}
      CodeSite.Send('Doc-O-Matic Off: ' + sLineBreak + AStr);
{$ENDIF}
      Result         := cic_UnKnown;
      ANextOperation := pno_SetDocOMatic;
    End;
  End;

end;

procedure Tfrm_CodeInsightEdit.GetDocOMaticNameAndValue(var ADocOMaticName, ADocOMaticValue: String);
Var
  LValue   : string;
  LPosName : Integer;
  LPosValue: Integer;
  LName    : string;
  LValueStr: string;
begin
  LValue := ADocOMaticValue;
  If (LValue <> EmptyStr) Then
  Begin
    LPosName := Pos('name="', LValue);
    LName    := Copy(LValue, LPosName + 6, Length(LValue));
    LPosName := Pos('"', LName);
    If (LPosName > 0) Then
    begin
      LName          := Copy(LName, 1, LPosName - 1);
      ADocOMaticName := LName;
    end;
    LPosValue := Pos('value="', LValue);
    LValueStr := Copy(LValue, LPosValue + 7, Length(LValue));
    LPosValue := Pos('"', LValueStr);
    If (LPosValue > 0) Then
    Begin
      LValueStr       := Copy(LValueStr, 1, LPosValue - 1);
      ADocOMaticValue := LValueStr;
    End;
{$IFDEF  TESTLOGGING}
    CodeSite.Send('Doc-O-Matic Input: ' + LValue);
    CodeSite.Send('Doc-O-Matic Name : ' + ADocOMaticName);
    CodeSite.Send('Doc-O-Matic Value: ' + ADocOMaticValue);
{$ENDIF}
  End;
end;

procedure Tfrm_CodeInsightEdit.GetEnumList(const AStr: String);
Var
  LPosStart: Integer;
  LPosEnd  : Integer;
  LStr     : string;
  LElements: TArray<String>;
begin
  FEnumList.Clear;
  LPosStart := Pos('(', AStr);
  LPosEnd   := Pos(')', AStr);
  If (LPosStart > 0) and (LPosEnd > LPosStart) Then
  Begin
    // TEnum = (te_Test, te_Test2);
    // 1234567890123456789012
    // 1         2
    //
    LStr      := Copy(AStr, LPosStart + 1, LPosEnd - LPosStart - 1);
    LElements := SplitString(LStr, ',');
    If (Length(LElements) > 0) then
    Begin
      For var i := Low(LElements) To High(LElements) Do
      Begin
        FEnumList.Add(LElements[i]);
      End;
    End;
  End;
end;

function Tfrm_CodeInsightEdit.GetFunctionName(
  const AStr  : string;
  const AStart: Integer): string;
Var
  LPos: Integer;
begin
  Result := '';
  LPos   := AStart;
  While (LPos <= Length(AStr)) And (Not(Ord(AStr[LPos]) in [Ord(' '), Ord('('), Ord(':'), Ord(';')])) Do
  Begin
    Result := Result + Copy(AStr, LPos, 1);
    LPos   := LPos + 1;
  End;
end;

procedure Tfrm_CodeInsightEdit.GetIndent(const ASource: String);
begin
  FIndent := 0;
  If (Length(ASource) > 0) Then
  Begin
    For var i := 1 to Length(ASource) Do
    begin
      If (ASource[i] <> ' ') Then
      Begin
        FIndent := i - 1;
        Break;
      End;
    end;
  End;
end;

procedure Tfrm_CodeInsightEdit.GetInstructionPart;
Var
  LStr: string;
begin
  FInstructionPart.Clear;
  For Var i := 0 To FSourcePart.Count - 1 Do
  begin
    LStr := FSourcePart.Strings[i];
    If Not HasCICMark(LStr) Then
    Begin
      FInstructionPart.Add(LStr);
    End;
  end;
end;

procedure Tfrm_CodeInsightEdit.GetObjectComment;
Var
  LStr           : string;
  LComType       : TCICommentParts;
  LParamName     : string;
  LNextOperation : TParseNextOperation;
  LEnumName      : string;
  LEnumComment   : string;
  LParamComment  : string;
  LDocOMaticName : string;
  LDocOMaticValue: string;
  LPos           : Integer;

begin
  LParamName            := EmptyStr;
  LEnumComment          := EmptyStr;
  LParamComment         := EmptyStr;
  LEnumName             := EmptyStr;
  LDocOMaticName        := EmptyStr;
  LDocOMaticValue       := EmptyStr;
  FEnumDefinitionPassed := False;

  For Var i := 0 To FSourcePart.Count - 1 Do
  Begin
    LStr := FSourcePart.Strings[i];

    If (Trim(LStr) = EmptyStr) Then
    Begin
      Continue;
    End;

    If (FObjectType = cio_Enum) And (FEnumDefinitionPassed = False) Then
    Begin
      If (LEnumComment <> EmptyStr) Then
      Begin
        FObjectSumMemo.Text := LEnumComment;
      End;
      FEnumDefinitionPassed := CheckEnumDefinitionLine(LStr);
      If FEnumDefinitionPassed then
      Begin
        FENumDefinition := LStr;
      End;
    End;

    If FEnumElementSummary And (LNextOperation = pno_GetEnumName) Then
    Begin
      LEnumName := LStr;
      LPos      := Pos(',', LStr);
      If (LPos > 0) then
      Begin
        LEnumName := Copy(LStr, 1, LPos - 1);
      End;
      LPos := Pos(');', LStr);
      If (LPos > 0) then
      Begin
        LEnumName := Copy(LStr, 1, LPos - 1);
      End;
      SetEnumComment(LEnumComment, Trim(LEnumName));
      LEnumComment   := EmptyStr;
      LEnumName      := EmptyStr;
      LNextOperation := pno_Continue;
      Continue;
    End
    Else
    Begin

      If HasCICMark(LStr) Then
      Begin
        LStr := RemoveCICMark(LStr);

        LComType := GetComType(LStr, LComType, LParamName, LNextOperation);
        If (LNextOperation in [pno_Skip, pno_GetEnumName]) then
        Begin
          Continue;
        End;

        If FParamSummary And (LNextOperation = pno_SetParamComment) then
        Begin
          SetParamComment(LParamComment, Trim(LParamName));
          LNextOperation := pno_Continue;
          LParamName     := EmptyStr;
          LParamComment  := EmptyStr;
          Continue;
        End;

        If FDocOMatic And (LNextOperation = pno_SetDocOMatic) Then
        begin

{$IFDEF  TESTLOGGING}
          CodeSite.Send('Operation SetDocOMatic');
{$ENDIF}
          If (LDocOMaticValue = EmptyStr) Then
          begin
            LDocOMaticValue := LStr;
          end;

          GetDocOMaticNameAndValue(LDocOMaticName, LDocOMaticValue);
          SetDocOMaticValue(LDocOMaticValue, LDocOMaticName);
          LDocOMaticName  := EmptyStr;
          LDocOMaticValue := EmptyStr;
          LNextOperation  := pno_Continue;
          Continue;
        end;

        If (LComType = cic_Summary) Then
        Begin
          If FObjectSummary And (FObjectType <> cio_Enum) then
          Begin
            FObjectSumMemo.Lines.Add(LStr);
          End
          Else
          Begin
            // Enum Object
            If FEnumElementSummary then
            Begin
              If Not FEnumDefinitionPassed Then
              Begin
                // Bis zur Enum Definition die Summary dem Objekt selbst zuschreiben
                FObjectSumMemo.Lines.Add(LStr);
              End
              Else
              Begin
                // Sonst dem Element selbst zuschreiben
                If (LEnumComment = EmptyStr) Then
                Begin
                  LEnumComment := LStr;
                end
                else
                begin
                  LEnumComment := LEnumComment + LStr;
                End;
              End;
            End;
          End;
        End;

        If FRemarkSummary And (LComType = cic_Remark) Then
        Begin
          FMethRemMemo.Lines.Add(LStr);
        End;

        If FResultSummary And (LComType = cic_Result) Then
        Begin
          FMethResMemo.Lines.Add(LStr);
        End;

        If FParamSummary And (LComType = cic_Param) Then
        Begin
          If (LParamComment = EmptyStr) Then
          Begin
            LParamComment := LStr;
          end
          else
          begin
            LParamComment := LParamComment + ' ' + LStr;
          End;
        End;

        If FDocOMatic And (LComType = cic_DocOMatic) Then
        Begin
{$IFDEF  TESTLOGGING}
          CodeSite.Send('Concat Doc-O-Matic: ' + sLineBreak + LStr);
{$ENDIF}
          If (LDocOMaticValue = EmptyStr) Then
          Begin
            LDocOMaticValue := LStr;
          end
          else
          begin
            LDocOMaticValue := LDocOMaticValue + ' ' + LStr;
          End;
        End;

      End;

    End;
  End;
end;

function Tfrm_CodeInsightEdit.GetObjectName(const ALine: string): string;
Var
  LStr         : string;
  LStrOhneBlank: string;
begin
  Result        := ALine;
  LStr          := Trim(ALine);
  LStrOhneBlank := StringReplace(LStr, ' ', '', [rfReplaceAll]);
  LStrOhneBlank := LowerCase(LStrOhneBlank);
  FObjectType   := cio_Unknown;

  // class function
  If SameText(LeftStr(LStr, 6), 'class ') And (Pos('=class', LStrOhneBlank) = 0) Then
  Begin
    LStr := Copy(LStr, 7, Length(LStr));
    LStr := Trim(LStr);
  End;

  // function
  If SameText(LeftStr(LStr, 9), 'function ') Then
  Begin
    FObjectType := cio_Function;
    Result      := GetFunctionName(LStr, 10);
    GetParamList(LStr);
  End;

  // procedure
  If (FObjectType = cio_Unknown) And SameText(LeftStr(LStr, 10), 'procedure ') Then
  Begin
    FObjectType := cio_Procedure;
    Result      := GetFunctionName(LStr, 11);
    GetParamList(LStr);
  End;

  // destructor
  If (FObjectType = cio_Unknown) And SameText(LeftStr(LStr, 11), 'destructor ') Then
  Begin
    FObjectType := cio_Procedure;
    Result      := GetFunctionName(LStr, 12);
    GetParamList(LStr);
  End;

  // constructor
  If (FObjectType = cio_Unknown) And SameText(LeftStr(LStr, 12), 'constructor ') Then
  Begin
    FObjectType := cio_Procedure;
    Result      := GetFunctionName(LStr, 13);
    GetParamList(LStr);
  End;

  // property
  If (FObjectType = cio_Unknown) And SameText(LeftStr(LStr, 9), 'property ') Then
  Begin
    FObjectType := cio_Property;
    Result      := GetFunctionName(LStr, 10);
    GetParamList(LStr, True);
  End;

  // class
  If (FObjectType = cio_Unknown) And (Pos('=class', LStrOhneBlank) > 0) Then
  Begin
    FObjectType := cio_Class;
    Result      := GetClassName(LStr, 1);
  End;

  // Enum
  If (FObjectType = cio_Unknown) And (Pos('=(', LStrOhneBlank) > 0) Then
  Begin
    FObjectType := cio_Enum;
    GetEnumList(LStr);
    Result := GetClassName(LStr, 1);
  End;

  // Attribute
  If (FObjectType = cio_Unknown) And (Pos(':', LStrOhneBlank) > 0) Then
  Begin
    FObjectType := cio_Attribute;
    Result      := GetFunctionName(LStr, 1);
  End;

  cbObjectTypes.ItemIndex := Integer(FObjectType);

end;

function Tfrm_CodeInsightEdit.GetObjectTypeStr(const AObjType: TCIObjectTypes): string;
begin
  Case AObjType of
    cio_Unknown:
      Result := 'unbekannt';
    cio_Attribute:
      Result := 'Attribut';
    cio_Procedure:
      Result := 'Procedure';
    cio_Function:
      Result := 'Function';
    cio_Enum:
      Result := 'Enumeration';
    cio_Class:
      Result := 'Class';
    cio_DocOMatic:
      Result := 'Doc-O-Matic';
    cio_Property:
      Result := 'Property';
  Else
    Result := '<nicht hinterlegt>';
  End;
end;

function Tfrm_CodeInsightEdit.GetOriginalLine(ALineNo: Integer): string;
begin
  If (ALineNo > 0) And (ALineNo < FOriginalSource.Count) Then
  Begin
    Result := FOriginalSource.Strings[ALineNo];
  End
  Else
  Begin
    Result := '';
  End;
end;

procedure Tfrm_CodeInsightEdit.GetParamList(
  Const AStr      : String;
  Const APropParam: Boolean);
Var
  LPosStart: Integer;
  LPosEnd  : Integer;
  LStr     : string;
  LParam   : string;
  LElements: TArray<String>;
  LStacked : TArray<String>;
begin
  FParamList.Clear;
  If APropParam then
  Begin
    LPosStart := Pos('[', AStr);
    LPosEnd   := Pos(']', AStr);
  End
  Else
  Begin
    LPosStart := Pos('(', AStr);
    LPosEnd   := Pos(')', AStr);
  End;
  If (LPosStart > 0) and (LPosEnd > LPosStart) Then
  Begin
    LStr := Copy(AStr, LPosStart + 1, LPosEnd - LPosStart - 1);
    // CodeSite.Send('GetParameter Input:' + AStr);
    // CodeSite.Send('Parameter Liste:' + LStr);
    LElements := SplitString(LStr, ';');
    // CodeSite.Send('ElementCount:' + IntToStr(Length(LElements)));
    If (Length(LElements) > 0) then
    Begin
      For var i := Low(LElements) To High(LElements) Do
      Begin
        LParam := Trim(LElements[i]);

        if SameText(LeftStr(LParam, 4), 'out ') then
        Begin
          LParam := Copy(LParam, 5, Length(LParam));
        End;

        if SameText(LeftStr(LParam, 4), 'var ') then
        Begin
          LParam := Copy(LParam, 5, Length(LParam));
        End;

        if SameText(LeftStr(LParam, 6), 'const ') then
        Begin
          LParam := Copy(LParam, 7, Length(LParam));
        End;

        If (Pos(':', LParam) > 0) Then
        Begin
          LParam := Copy(LParam, 1, Pos(':', LParam) - 1);
        End;

        If (Pos(',', LParam) > 0) then
        Begin
          LStacked  := SplitString(LParam, ',');
          For var j := Low(LStacked) To High(LStacked) Do
          Begin
            LParam := Trim(LStacked[j]);
            // CodeSite.Send('Param added: ' + LParam);
            FParamList.Add(LParam);
          End;
        end
        else
        begin
          // CodeSite.Send('Param added: ' + LParam);
          FParamList.Add(LParam);
        End;

      End;
    End;
  End;
end;

function Tfrm_CodeInsightEdit.HasCICMark(const ALine: string): Boolean;
begin
  Result := (LeftStr(Trim(ALine), 3) = '///');
end;

function Tfrm_CodeInsightEdit.IndentLine: string;
begin
  Result := DupeString(' ', FIndent);
end;

procedure Tfrm_CodeInsightEdit.InitCommentAsItIs;
begin
  If FCanShow Then
  Begin
    // Objekt erkannt
    GetObjectComment;
  End;
end;

procedure Tfrm_CodeInsightEdit.InitData;
begin
  FENumDefinition := EmptyStr;
  FTestVersion    := False;
{$IFDEF  TESTLOGGING}
  CodeSite.Enabled := False;
{$ENDIF}
  FSaved           := False;
  FCanShow         := False;
  FObjectSummary   := False;
  FObjectType      := cio_Unknown;
  FEnumList        := TStringList.Create;
  FSourcePart      := TStringList.Create;
  FParamList       := TStringList.Create;
  FDocOMaticList   := TStringList.Create;
  FPreparedSource  := TStringList.Create;
  FInstructionPart := TStringList.Create;
  InitObjectTypes;
end;

procedure Tfrm_CodeInsightEdit.InitDocOMaticPart(
  var ATop   : Integer;
  const ALeft: Integer);
Const
  cColCount                                         = 2;
  cHeaderText: Array [0 .. cColCount - 1] Of string = ('Parameter', 'Value');

Var
  LColWidth: Integer;
  LMaxWidth: Integer;
  LStr     : string;
begin
  FDocOMaticLabel         := TLabel.Create(sbEdit);
  FDocOMaticLabel.Parent  := sbEdit;
  FDocOMaticLabel.Caption := GetObjectTypeStr(FObjectType) + ' Doc-O-Matic Elements';
  FDocOMaticLabel.Top     := ATop;
  FDocOMaticLabel.Left    := ALeft;
  ATop                    := ATop + FDocOMaticLabel.Height + 10;

  FDocOMaticElements                  := TStringGrid.Create(sbEdit);
  FDocOMaticElements.Parent           := sbEdit;
  FDocOMaticElements.Left             := ALeft;
  FDocOMaticElements.Top              := ATop;
  FDocOMaticElements.Height           := 200;
  FDocOMaticElements.Font.Size        := 11;
  FDocOMaticElements.Font.Color       := clRed;
  FDocOMaticElements.DefaultRowHeight := 24;
  FDocOMaticElements.Options          := FDocOMaticElements.Options + [goColSizing];
  FDocOMaticElements.Options          := FDocOMaticElements.Options + [goRowSizing];
  FDocOMaticElements.Options          := FDocOMaticElements.Options + [goEditing];
  FDocOMaticElements.Options          := FDocOMaticElements.Options + [goDrawFocusSelected];

  FDocOMaticElements.Width := sbEdit.Width - cRand;

  FDocOMaticElements.ColCount := cColCount;
  FDocOMaticElements.RowCount := 2;

  FDocOMaticElements.BeginUpdate;
  LMaxWidth    := 0;
  For var LRow := 0 To FDocOMaticElements.RowCount - 1 Do
  Begin
    For Var LCol := 0 To cColCount - 1 Do
    begin
      If (LRow = 0) Then
      Begin
        FDocOMaticElements.Cells[LCol, LRow] := cHeaderText[LCol];
        If (LCol = 0) Then
        Begin
          LMaxWidth := FDocOMaticElements.Canvas.TextWidth(cHeaderText[LCol]) + 10;
        End;
      end
      else
      Begin
        FDocOMaticElements.Cells[LCol, LRow] := '';
      End;
    end;
  End;
  FDocOMaticElements.EndUpdate;

  If (LMaxWidth > 0) Then
  begin
    FDocOMaticElements.ColWidths[0] := LMaxWidth + 24;
    FDocOMaticElements.ColWidths[1] := FDocOMaticElements.ClientWidth - FDocOMaticElements.ColWidths[0] - 10;
  end;

  FDocOMaticElements.Anchors := [TAnchorKind.akLeft, TAnchorKind.akTop, TAnchorKind.akRight];
  ATop                       := ATop + FDocOMaticElements.Height + 10;

end;

procedure Tfrm_CodeInsightEdit.InitEnumElementPart(
  var ATop   : Integer;
  const ALeft: Integer);

Const
  cColCount                                         = 2;
  cHeaderText: Array [0 .. cColCount - 1] Of string = ('Enum', 'Comment');

Var
  LColWidth: Integer;
  LMaxWidth: Integer;
  LStr     : string;
begin
  FEnumLabel         := TLabel.Create(sbEdit);
  FEnumLabel.Parent  := sbEdit;
  FEnumLabel.Caption := GetObjectTypeStr(FObjectType) + ' Summary';
  FEnumLabel.Top     := ATop;
  FEnumLabel.Left    := ALeft;
  ATop               := ATop + FEnumLabel.Height + 10;

  FEnumElements                  := TStringGrid.Create(sbEdit);
  FEnumElements.Parent           := sbEdit;
  FEnumElements.Left             := ALeft;
  FEnumElements.Top              := ATop;
  FEnumElements.Height           := 100;
  FEnumElements.Font.Size        := 11;
  FEnumElements.Font.Color       := clNavy;
  FEnumElements.DefaultRowHeight := 24;
  FEnumElements.Options          := FEnumElements.Options + [goColSizing];
  FEnumElements.Options          := FEnumElements.Options + [goRowSizing];
  FEnumElements.Options          := FEnumElements.Options + [goEditing];
  FEnumElements.Options          := FEnumElements.Options + [goDrawFocusSelected];

  if (FEnumList.Count > 0) then
  begin
    FEnumElements.Height := 20 + (FEnumList.Count + 1) * FEnumElements.DefaultRowHeight;
  end;

  FEnumElements.Width := sbEdit.Width - cRand;

  FEnumElements.ColCount := cColCount;
  If (FEnumList.Count = 0) Then
  Begin
    FEnumElements.RowCount := 2;
  end
  Else
  Begin
    FEnumElements.RowCount := FEnumList.Count + 1;
  End;

  FEnumElements.BeginUpdate;
  LMaxWidth    := 0;
  For var LRow := 0 To FEnumElements.RowCount - 1 Do
  Begin
    For Var LCol := 0 To cColCount - 1 Do
    begin
      If (LRow = 0) Then
      Begin
        FEnumElements.Cells[LCol, LRow] := cHeaderText[LCol];
        If (LCol = 0) Then
        Begin
          LMaxWidth := FEnumElements.Canvas.TextWidth(cHeaderText[LCol]) + 10;
        End;
      end
      else
      Begin
        If (LCol = 0) Then
        Begin
          If (FEnumList.Count > 0) And (LRow - 1 < FEnumList.Count) Then
          Begin
            LStr                            := FEnumList.Strings[LRow - 1];
            FEnumElements.Cells[LCol, LRow] := Trim(LStr);
            LColWidth                       := FEnumElements.Canvas.TextWidth(LStr) + 10;
            If (LColWidth > LMaxWidth) Then
            Begin
              LMaxWidth := LColWidth;
            End;
          End
          Else
          Begin
            FEnumElements.Cells[LCol, LRow] := '';
          End;
        End
        Else
        Begin
          FEnumElements.Cells[LCol, LRow] := '';
        End;
      End;
    end;
  End;
  FEnumElements.EndUpdate;

  If (LMaxWidth > 0) Then
  begin
    FEnumElements.ColWidths[0] := LMaxWidth + 24;
    FEnumElements.ColWidths[1] := FEnumElements.ClientWidth - FEnumElements.ColWidths[0] - 10;
  end;

  FEnumElements.Anchors := [TAnchorKind.akLeft, TAnchorKind.akTop, TAnchorKind.akRight];
  ATop                  := ATop + FEnumElements.Height + 10;

end;

procedure Tfrm_CodeInsightEdit.GetCIObject;
Var
  LStr       : string;
  LSource    : string;
  LKlammerAuf: Integer;
  LKlammerZu : Integer;
  LCheck01   : Boolean;
  LCheck02   : Boolean;

  Procedure CheckKlammer(Const ASource: String);
  begin
    If (Pos('(', ASource) > 0) Then
    Begin
      Inc(LKlammerAuf);
    End;

    If (Pos(')', ASource) > 0) Then
    Begin
      Inc(LKlammerZu);
    End;
  end;

  procedure AdjustRange(Const ALineNo: Integer);
  Begin
    If (ALineNo > FEndLine) Then
    Begin
      FEndLine := ALineNo;
    End;
    If (ALineNo < FStartLine) Then
    Begin
      FStartLine := ALineNo;
    End;
  End;

begin
  If Assigned(FOriginalSource) Then
  Begin

    FFehler := '';

    FSourcePart.Clear;
    LKlammerAuf := 0;
    LKlammerZu  := 0;

    For Var i := FLineNo To FOriginalSource.Count - 1 Do
    begin

      LSource := FOriginalSource.Strings[i - 1];

      FSourcePart.Add(LSource);

      If (i = FLineNo) then
      Begin
        FStartLine := FLineNo;
        FEndLine   := FLineNo;
        GetIndent(LSource);
      End
      else
      Begin
        AdjustRange(i);
      End;

      If HasCICMark(LSource) Then
      Begin
        Continue;
      End;

      CheckKlammer(LSource);

      // CodeSite.EnterMethod('GetCIObject');
      // CodeSite.Send(LSource);
      // CodeSite.Send(Format('Auf:%d  Zu:%d', [LKlammerAuf, LKlammerZu]));
      // CodeSite.ExitMethod('GetCIObject');

      If (i = FLineNo) Then
      Begin
        LStr := LSource;
      end
      Else
      Begin
        LStr := LStr + ' ' + LSource;
      End;

      // auf jeden Fall aufhören, wenn das Semikolon kommt !
      If (Pos(';', LStr) > 0) And (LKlammerZu >= LKlammerAuf) Then
      Begin
        Break;
      End;

    end;

    // CodeSite.Send('Part 1: ' + LStr);

    // jetzt nach oben, solange die Klammern nicht mehr offen
    // oder es noch Kommentar Zeilen sind
    For Var i := FLineNo - 1 downto 1 Do
    Begin
      LSource := FOriginalSource.Strings[i - 1];
      If (Trim(LSource) = EmptyStr) Then
      Begin
        Continue;
      End;

      If (HasCICMark(LSource) Or (LKlammerAuf <> LKlammerZu)) And
        (IstReserviertesWort(LSource, LKlammerAuf, LKlammerZu) = False) Then
      Begin
        If Not HasCICMark(LSource) Then
        Begin
          LStr := LSource + ' ' + LStr;
        End;

        FSourcePart.Insert(0, LSource);

        AdjustRange(i);

      end
      else
      Begin
        Break;
      End;

      CheckKlammer(LSource);

    End;

{$IFDEF  TESTLOGGING}
    // CodeSite.Send('Part 2: ' + LStr);
    CodeSite.Send('SourcePart: ' + Format('StartLine: %d  EndLine: %d', [FStartLine, FEndLine]) + sLineBreak + FSourcePart.Text);
{$ENDIF}
    lblObjectName.Caption := 'Object: ' + GetObjectName(LStr);

    LCheck01 := (FObjectType <> cio_Unknown);
    If Not LCheck01 Then
    Begin
      FFehler := 'Objekt nicht erkannt ' + sLineBreak +
        'Bitte auf die erste Zeile der Deklaration im Interface Abschnitt positionieren.';
    end;

    LCheck02 := (FDocOMatic Or FObjectSummary Or FResultSummary or FRemarkSummary or FEnumElementSummary Or FParamSummary);
    If Not LCheck02 Then
    Begin
      FFehler := 'Kein Element aktiviert zum Bearbeiten ' + sLineBreak +
        'Bitte in den Optionen mindestens ein Element für die Bearbeitung aktivieren.';
    end;

    FCanShow := LCheck01 And LCheck02;

    FInstructionPart.Clear;
    If FCanShow Then
    Begin
      GetInstructionPart;
    end;

  End;
end;

procedure Tfrm_CodeInsightEdit.InitMethodRemarksPart(
  var ATop   : Integer;
  const ALeft: Integer);
begin
  FMethRemLabel         := TLabel.Create(sbEdit);
  FMethRemLabel.Parent  := sbEdit;
  FMethRemLabel.Caption := GetObjectTypeStr(FObjectType) + ' Remarks';
  FMethRemLabel.Top     := ATop;
  FMethRemLabel.Left    := ALeft;
  ATop                  := ATop + FMethRemLabel.Height + 10;

  FMethRemMemo        := TMemo.Create(sbEdit);
  FMethRemMemo.Parent := sbEdit;
  FMethRemMemo.Lines.Clear;
  FMethRemMemo.Left       := ALeft;
  FMethRemMemo.Top        := ATop;
  FMethRemMemo.Height     := 100;
  FMethRemMemo.Font.Size  := 11;
  FMethRemMemo.Font.Color := clMaroon;
  FMethRemMemo.Width      := sbEdit.Width - cRand;
  FMethRemMemo.Anchors    := [TAnchorKind.akLeft, TAnchorKind.akTop, TAnchorKind.akRight];
  ATop                    := ATop + FMethRemMemo.Height + 10;
end;

procedure Tfrm_CodeInsightEdit.InitMethodResultPart(
  var ATop   : Integer;
  const ALeft: Integer);
begin
  FMethResLabel         := TLabel.Create(sbEdit);
  FMethResLabel.Parent  := sbEdit;
  FMethResLabel.Caption := GetObjectTypeStr(FObjectType) + ' Result';
  FMethResLabel.Top     := ATop;
  FMethResLabel.Left    := ALeft;
  ATop                  := ATop + FMethResLabel.Height + 10;

  FMethResMemo        := TMemo.Create(sbEdit);
  FMethResMemo.Parent := sbEdit;
  FMethResMemo.Lines.Clear;
  FMethResMemo.Left       := ALeft;
  FMethResMemo.Top        := ATop;
  FMethResMemo.Height     := 100;
  FMethResMemo.Font.Size  := 11;
  FMethResMemo.Font.Color := clGreen;
  FMethResMemo.Width      := sbEdit.Width - cRand;
  FMethResMemo.Anchors    := [TAnchorKind.akLeft, TAnchorKind.akTop, TAnchorKind.akRight];
  ATop                    := ATop + FMethResMemo.Height + 10;
end;

procedure Tfrm_CodeInsightEdit.InitMethodSummaryPart(
  var ATop   : Integer;
  Const ALeft: Integer = 10);
begin
  FObjectSumLabel         := TLabel.Create(sbEdit);
  FObjectSumLabel.Parent  := sbEdit;
  FObjectSumLabel.Caption := GetObjectTypeStr(FObjectType) + ' Summary';
  FObjectSumLabel.Top     := ATop;
  FObjectSumLabel.Left    := ALeft;
  ATop                    := ATop + FObjectSumLabel.Height + 10;

  FObjectSumMemo        := TMemo.Create(sbEdit);
  FObjectSumMemo.Parent := sbEdit;
  FObjectSumMemo.Lines.Clear;
  FObjectSumMemo.Left       := ALeft;
  FObjectSumMemo.Top        := ATop;
  FObjectSumMemo.Height     := 100;
  FObjectSumMemo.Width      := sbEdit.Width - cRand;
  FObjectSumMemo.Font.Size  := 11;
  FObjectSumMemo.Font.Color := clBlue;
  FObjectSumMemo.Anchors    := [TAnchorKind.akLeft, TAnchorKind.akTop, TAnchorKind.akRight];
  ATop                      := ATop + FObjectSumMemo.Height + 10;
end;

procedure Tfrm_CodeInsightEdit.InitObjectTypes;
Var
  LObjType: TCIObjectTypes;

begin
  cbObjectTypes.Clear;
  For LObjType := Low(TCIObjectTypes) To High(TCIObjectTypes) Do
  Begin
    cbObjectTypes.AddItem(GetObjectTypeStr(LObjType), Nil);
  End;
  cbObjectTypes.ItemIndex := Integer(FObjectType);
end;

procedure Tfrm_CodeInsightEdit.InitParamPart(
  var ATop   : Integer;
  const ALeft: Integer);
Const
  cColCount                                         = 2;
  cHeaderText: Array [0 .. cColCount - 1] Of string = ('Parameter', 'Comment');

Var
  LColWidth: Integer;
  LMaxWidth: Integer;
  LStr     : string;
begin
  FParamLabel         := TLabel.Create(sbEdit);
  FParamLabel.Parent  := sbEdit;
  FParamLabel.Caption := GetObjectTypeStr(FObjectType) + ' Parameter';
  FParamLabel.Top     := ATop;
  FParamLabel.Left    := ALeft;
  ATop                := ATop + FParamLabel.Height + 10;

  FParamElements                  := TStringGrid.Create(sbEdit);
  FParamElements.Parent           := sbEdit;
  FParamElements.Left             := ALeft;
  FParamElements.Top              := ATop;
  FParamElements.Height           := 100;
  FParamElements.Font.Size        := 11;
  FParamElements.Font.Color       := clOlive;
  FParamElements.DefaultRowHeight := 24;
  FParamElements.Options          := FParamElements.Options + [goColSizing];
  FParamElements.Options          := FParamElements.Options + [goRowSizing];
  FParamElements.Options          := FParamElements.Options + [goEditing];
  FParamElements.Options          := FParamElements.Options + [goDrawFocusSelected];

  if (FParamList.Count > 0) then
  begin
    FParamElements.Height := 20 + (FParamList.Count + 1) * FParamElements.DefaultRowHeight;
  end;

  FParamElements.Width := sbEdit.Width - cRand;

  FParamElements.ColCount := cColCount;
  If (FParamList.Count = 0) Then
  Begin
    FParamElements.RowCount := 2;
  end
  Else
  Begin
    FParamElements.RowCount := FParamList.Count + 1;
  End;

  FParamElements.BeginUpdate;
  LMaxWidth    := 0;
  For var LRow := 0 To FParamElements.RowCount - 1 Do
  Begin
    For Var LCol := 0 To cColCount - 1 Do
    begin
      If (LRow = 0) Then
      Begin
        FParamElements.Cells[LCol, LRow] := cHeaderText[LCol];
        If (LCol = 0) Then
        Begin
          LMaxWidth := FParamElements.Canvas.TextWidth(cHeaderText[LCol]) + 10;
        End;
      end
      else
      Begin
        If (LCol = 0) Then
        Begin
          If (FParamList.Count > 0) And (LRow - 1 < FParamList.Count) Then
          Begin
            LStr                             := FParamList.Strings[LRow - 1];
            FParamElements.Cells[LCol, LRow] := Trim(LStr);
            LColWidth                        := FParamElements.Canvas.TextWidth(LStr) + 10;
            If (LColWidth > LMaxWidth) Then
            Begin
              LMaxWidth := LColWidth;
            End;
          End
          Else
          Begin
            FParamElements.Cells[LCol, LRow] := '';
          End;
        End
        Else
        Begin
          FParamElements.Cells[LCol, LRow] := '';
        End;
      End;
    end;
  End;
  FParamElements.EndUpdate;

  If (LMaxWidth > 0) Then
  begin
    FParamElements.ColWidths[0] := LMaxWidth + 24;
    FParamElements.ColWidths[1] := FParamElements.ClientWidth - FParamElements.ColWidths[0] - 10;
  end;

  FParamElements.Anchors := [TAnchorKind.akLeft, TAnchorKind.akTop, TAnchorKind.akRight];
  ATop                   := ATop + FParamElements.Height + 10;

end;

procedure Tfrm_CodeInsightEdit.InitScrollBox;
Var
  LLeft: Integer;
  LTop : Integer;
begin

  LLeft := cRand Div 2;
  LTop  := cRand Div 2;

  sbEdit.LockDrawing;

  If FObjectSummary Then
  Begin
    InitMethodSummaryPart(LTop, LLeft);
  End;

  If FEnumElementSummary and (FObjectType = cio_Enum) And (FEnumList.Count > 0) Then
  begin
    InitEnumElementPart(LTop, LLeft);
  end;

  If FParamSummary and (FObjectType in [cio_Function, cio_Procedure, cio_Property]) And (FParamList.Count > 0) Then
  begin
    InitParamPart(LTop, LLeft);
  end;

  If FResultSummary and (FObjectType = cio_Function) Then
  Begin
    InitMethodResultPart(LTop, LLeft);
  End;

  If FRemarkSummary And (FObjectType in [cio_Procedure, cio_Function, cio_Class, cio_Property]) Then
  Begin
    InitMethodRemarksPart(LTop, LLeft);
  End;

  If FDocOMatic Then
  Begin
    InitDocOMaticPart(LTop, LLeft);
  End;

  sbEdit.UnlockDrawing;
end;

function Tfrm_CodeInsightEdit.IstReserviertesWort(
  const ASource                : String;
  Const AKlammerAuf, AKlammerZu: Integer): Boolean;
Var
  LStr: string;
begin
  Result := False;
  // CodeSite.EnterMethod('IstReserviertesWort');
  if (Pos(';', ASource) > 0) And (AKlammerAuf = AKlammerZu) then
  Begin
    Result := True;
  End
  Else
  Begin
    LStr := Trim(ASource);
    If (Pos(' ', LStr) > 0) Then
    Begin
      LStr := Copy(LStr, 1, Pos(' ', LStr) - 1);
    End;
    Result := SameText('type', LStr) Or (SameText('const', LStr) And (AKlammerAuf = AKlammerZu)) Or
      (SameText('var', LStr) and (AKlammerAuf = AKlammerZu)) Or SameText('strict', LStr) Or SameText('private', LStr) Or
      SameText('protected', LStr) Or SameText('public', LStr) Or SameText('published', LStr);
  End;
  // CodeSite.Send('Input: ' + ASource);
  // CodeSite.Send(Format('Auf:%d  Zu:%d', [AKlammerAuf, AKlammerZu]));
  // CodeSite.Send('Result: ' + BoolToStr(Result, True));
  // CodeSite.ExitMethod('IstReserviertesWort');
end;

function Tfrm_CodeInsightEdit.LeadingLine: string;
begin
  Result := DupeString(' ', FIndent) + '/// ';
end;

function Tfrm_CodeInsightEdit.RemoveCICMark(const ALine: string): String;
begin
  Result := ALine;

  If HasCICMark(ALine) Then
  Begin
    Result := Trim(ALine);
    Result := Copy(Result, 4, Length(Result));
    Result := Trim(Result);
  End;

end;

procedure Tfrm_CodeInsightEdit.SetDocOMaticValue(const ADocOMaticValue, ADocOMaticName: String);
begin
  If FDocOMatic And Assigned(FDocOMaticElements) Then
  Begin
    If (FDocOMaticElements.Cells[0, FDocOMaticElements.RowCount - 1] <> EmptyStr) Then
    Begin
      FDocOMaticElements.RowCount := FDocOMaticElements.RowCount + 1;
    End;
    FDocOMaticElements.Cells[0, FDocOMaticElements.RowCount - 1] := ADocOMaticName;
    FDocOMaticElements.Cells[1, FDocOMaticElements.RowCount - 1] := ADocOMaticValue;
  End;
end;

procedure Tfrm_CodeInsightEdit.SetEnumComment(const AEnumComment, AEnumName: String);
Var
  LCellText: string;
begin
  If FEnumElementSummary Then
  Begin
{$IFDEF  TESTLOGGING}
    CodeSite.Send('Setzen Enum Kommentar >' + AEnumComment + '< für >' + AEnumName + '<');
{$ENDIF}
    for Var i := 1 to FEnumElements.RowCount - 1 do
    begin
      If SameText(FEnumElements.Cells[0, i], AEnumName) Then
      Begin
        LCellText := FEnumElements.Cells[1, i];
        If (LCellText = '') Then
        Begin
          FEnumElements.Cells[1, i] := AEnumComment;
        end
        else
        begin
          FEnumElements.Cells[1, i] := FEnumElements.Cells[1, i] + ' ' + AEnumComment;
        End;
        Break;
      End;
    end;
  End;
end;

procedure Tfrm_CodeInsightEdit.SetFDocOMatic(const Value: Boolean);
begin
  FDocOMatic := Value;
end;

procedure Tfrm_CodeInsightEdit.SetFEnumElementSummary(const Value: Boolean);
begin
  FEnumElementSummary := Value;
end;

procedure Tfrm_CodeInsightEdit.SetFLineNo(const Value: Integer);
begin
  FLineNo := Value;
  If (FLineNo > 0) Then
  Begin
    If FEnumElementSummary And (Not FObjectSummary) Then
    Begin
      FObjectSummary := True;
    End;
    GetCIObject;
  End;
end;

procedure Tfrm_CodeInsightEdit.SetFMethodSummary(const Value: Boolean);
begin
  FObjectSummary := Value;
end;

procedure Tfrm_CodeInsightEdit.SetFParamSummary(const Value: Boolean);
begin
  FParamSummary := Value;
end;

procedure Tfrm_CodeInsightEdit.SetFRemarkSummary(const Value: Boolean);
begin
  FRemarkSummary := Value;
end;

procedure Tfrm_CodeInsightEdit.SetFResultSummary(const Value: Boolean);
begin
  FResultSummary := Value;
end;

procedure Tfrm_CodeInsightEdit.SetFTestVersion(const Value: Boolean);
begin
  FTestVersion := Value;
{$IFDEF  TESTLOGGING}
  CodeSite.Enabled := FTestVersion;
{$ENDIF}
end;

procedure Tfrm_CodeInsightEdit.SetParamComment(const AComment, AParamName: String);
Var
  LCellText: string;
begin
  If FParamSummary Then
  Begin

{$IFDEF  TESTLOGGING}
    CodeSite.Send('Setzen Parameter Kommentar >' + AComment + '< für >' + AParamName + '<');
{$ENDIF}
    for Var i := 1 to FParamElements.RowCount - 1 do
    begin
      If SameText(FParamElements.Cells[0, i], AParamName) Then
      Begin
        LCellText := FParamElements.Cells[1, i];
        If (LCellText = '') Then
        Begin
          FParamElements.Cells[1, i] := AComment;
        end
        else
        begin
          FParamElements.Cells[1, i] := FParamElements.Cells[1, i] + ' ' + AComment;
        End;
        Break;
      End;
    end;
  End;
end;

procedure Tfrm_CodeInsightEdit.WriteDocOMatic;
Var
  LStr  : string;
  LName : string;
  LValue: string;
begin
  If FDocOMatic Then
  Begin
    If (FDocOMaticElements.RowCount >= 2) Then
    Begin
      for Var i := 1 to FDocOMaticElements.RowCount - 1 do
      Begin
        LName  := FDocOMaticElements.Cells[0, i];
        LValue := FDocOMaticElements.Cells[1, i];
        If (Trim(LName) <> EmptyStr) Then
        Begin
          LStr := LeadingLine + cDocOMaticOn + ' name="' + LName + '" value="' + LValue + '"' + cDocOMaticOff;
          FPreparedSource.Add(LStr);
        End;
      End;
    End;
  End;
end;

procedure Tfrm_CodeInsightEdit.WriteEnumElements;
Var
  LStr  : string;
  LName : string;
  LValue: string;
begin
  If FEnumElementSummary And Assigned(FEnumElements) And (FEnumElements.RowCount >= 2) And (FEnumElements.Cells[0, 1] <> EmptyStr)
    And (FENumDefinition <> EmptyStr) Then
  Begin
    LStr := Trim(FENumDefinition);
    FPreparedSource.Add(IndentLine + LStr);
    FPreparedSource.Add(IndentLine);

    for Var i := 1 to FEnumElements.RowCount - 1 do
    Begin
      LName  := FEnumElements.Cells[0, i];
      LValue := FEnumElements.Cells[1, i];
      If (Trim(LValue) <> EmptyStr) Then
      Begin
        LStr := LeadingLine + cSummaryOn;
        FPreparedSource.Add(LStr);

        LStr := LeadingLine + LValue;
        FPreparedSource.Add(LStr);

        LStr := LeadingLine + cSummaryOff;
        FPreparedSource.Add(LStr);
      End;

      If (i = FEnumElements.RowCount - 1) Then
      Begin
        LStr := LName;
      end
      Else
      Begin
        LStr := LName + ',';
      End;
      FPreparedSource.Add(IndentLine + LStr);
      FPreparedSource.Add(IndentLine);

    End;

    LStr := ');';
    FPreparedSource.Add(IndentLine + LStr);
  End;
end;

procedure Tfrm_CodeInsightEdit.WriteInstructionPart;
Var
  LStr: string;
begin

  // CodeSite.Send('Instruction Part: ' + FInstructionPart.Text);

  If (FInstructionPart.Count > 0) Then
  begin
    For Var i := 0 To FInstructionPart.Count - 1 Do
    Begin
      LStr := FInstructionPart.Strings[i];
      If (Trim(LStr) <> EmptyStr) Then
      Begin
        LStr := IndentLine + Trim(LStr);
        FPreparedSource.Add(LStr);
      End;
    End;
  end;
end;

procedure Tfrm_CodeInsightEdit.WriteMemoContent(AMemo: TMemo);
Var
  LStr: string;
begin
  If Assigned(AMemo) Then
  begin
    If (AMemo.Lines.Count > 0) Then
    Begin
      For var i := 0 to AMemo.Lines.Count - 1 Do
      Begin
        FPreparedSource.Add(LeadingLine + AMemo.Lines.Strings[i]);
      End;
    End;
  end;
end;

procedure Tfrm_CodeInsightEdit.WriteParams;
Var
  LStr  : string;
  LName : string;
  LValue: string;
begin
  If FParamSummary And Assigned(FParamElements) Then
  Begin
    If (FParamElements.RowCount >= 2) Then
    Begin
      for Var i := 1 to FParamElements.RowCount - 1 do
      Begin
        LName  := FParamElements.Cells[0, i];
        LValue := FParamElements.Cells[1, i];
        If (Trim(LName) <> EmptyStr) Then
        Begin
          LStr := LeadingLine + cParamOn + ' name="' + LName + '">';
          FPreparedSource.Add(LStr);
          LStr := LeadingLine + LValue;
          FPreparedSource.Add(LStr);
          LStr := LeadingLine + cParamOff + '>';
          FPreparedSource.Add(LStr);
        End;
      End;
    End;
  End;
end;

procedure Tfrm_CodeInsightEdit.WritePreparedSource;
begin
  // Den formatierten Quelltext mit den Kommentaren ausgeben
  WriteDocOMatic;

  WriteSummary;

  If (FObjectType = cio_Enum) Then
  Begin
    WriteEnumElements;
  End;

  WriteParams;

  WriteResult;

  WriteRemarks;

  If (FObjectType <> cio_Enum) Then
  Begin
    WriteInstructionPart;
  End;

  iF (FObjectType = cio_Enum) Then
  Begin
    FPreparedSource.Add(IndentLine);
  End;

  If IsTestVersion Then
  Begin
    FPreparedSource.SaveToFile('C:\Users\Win10Pro\Documents\GExpert Backup\Test.TXT');
  End;
end;

procedure Tfrm_CodeInsightEdit.WriteRemarks;
begin
  If FRemarkSummary And Assigned(FMethRemMemo) And (FMethRemMemo.Lines.Count > 0) Then
  begin
    FPreparedSource.Add(LeadingLine + cRemarksOn);
    WriteMemoContent(FMethRemMemo);
    FPreparedSource.Add(LeadingLine + cRemarksOff);
  end;
end;

procedure Tfrm_CodeInsightEdit.WriteResult;
begin
  If FResultSummary And Assigned(FMethResMemo) And (FMethResMemo.Lines.Count > 0) Then
  begin
    FPreparedSource.Add(LeadingLine + cResultOn);
    WriteMemoContent(FMethResMemo);
    FPreparedSource.Add(LeadingLine + cResultOff);
  end;
end;

procedure Tfrm_CodeInsightEdit.WriteSummary;
begin
  If FObjectSummary And Assigned(FObjectSumMemo) And (FObjectSumMemo.Lines.Count > 0) Then
  begin
    FPreparedSource.Add(LeadingLine + cSummaryOn);
    WriteMemoContent(FObjectSumMemo);
    FPreparedSource.Add(LeadingLine + cSummaryOff);
  end;
end;

end.
