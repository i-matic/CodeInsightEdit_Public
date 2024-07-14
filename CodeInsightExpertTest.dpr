program CodeInsightExpertTest;

uses
  Vcl.Forms,
  CodeInsightTest in 'CodeInsightTest.pas' {frnTest},
  CodeInsightEdit in 'CodeInsightEdit.pas' {frm_CodeInsightEdit};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrnTest, frnTest);
  Application.Run;
end.
