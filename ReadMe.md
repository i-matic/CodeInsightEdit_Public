# CodeInsightExpert
Dieser Experte unterstützt das Schreiben von CodeInsight kompatiblen Kommentaren in der Delphi IDE (12 Athens)

Zunächst benötigen wir die Quelltexte aus dem Repository: https://sourceforge.net/p/gexperts/code/HEAD/tree/trunk/

Füge dann die Units GX_eCodeInsightEditorExpert und CodeInsightEdit.pas dem Projekt GExpertsRS120.DLL hinzu. 
Füge das Bitmap aus diesem Repository im Unterordner Images dem Images Order des GExperts Ordners hinzu.

Übersetze das Projekt und erzeuge die DLL.

Mit der expertManager.exe im binary Verzeichnis des GExperts Downloads gelingt die Installation in der Delphi IDE.

Nach dem nächsten Start der Delphi IDE sieht dass dann so aus:

Experten Verwaltung:

![CodeInsight01](https://github.com/user-attachments/assets/4acfa7f6-88aa-42cf-be54-c84411b49bd7)


Einstellen des HotKeys

Einstellen, welche Objekte kommentiert werden können

![CodeInsight02](https://github.com/user-attachments/assets/32e6f17a-f851-4278-ba70-768b15fe5c08)


Den Experten über das UnterMenü der Editor Experten des GExperts Menüs in Delphi oder per Hotkey
an der Deklarationszeile im Interface Abschnitt aufrufen.

![CodeInsight03](https://github.com/user-attachments/assets/9afd827f-4f93-4171-91df-5df3bd7a8610)


Kommentare erfassen 

# Mit ESC ohne Änderungen verlassen
# Mit SHIFT+ENTER Verlassen und die Änderungen übernehmen

Duch Übernehmen werden die Änderungen an den Kommentaren zurück in den Quelltext übernommen.

Mein Dank geht an 

https://blog.dummzeuch.de/experimental-gexperts-version/

außerdem enthalten ein Testprogramm für den Experten für eigene Anpassungen
