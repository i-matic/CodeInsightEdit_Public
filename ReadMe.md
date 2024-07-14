# CodeInsightExpert
Dieser Experte unterstützt das Schreiben von CodeInsight kompatiblen Kommentaren in der Delphi IDE (12 Athens)

Zunächst benötigen wir die Quelltexte aus dem Repository: https://sourceforge.net/p/gexperts/code/HEAD/tree/trunk/

Füge dann die Units GX_eCodeInsightEditorExpert und CodeInsightEdit.pas dem Projekt GExpertsRS120.DLL hinzu. 
Füge das Bitmap aus diesem Repository im Unterordner Images dem Images Order des GExperts Ordners hinzu.

Übersetze das Projekt und erzeuge die DLL.

Mit der expertManager.exe im binary Verzeichnis des GExperts Downloads gelingt die Installation in der Delphi IDE.

Nach dem nächsten Start der Delphi IDE sieht dass dann so aus:

Experten Verwaltung:
![image](https://github.com/user-attachments/assets/c450cc4c-893e-4489-a666-4bf96e5ce6b4)

Einstellen des HotKeys

Einstellen, welche Objekte kommentiert werden können

![image](https://github.com/user-attachments/assets/49672874-25b0-4220-83d5-d0790f7ae526)

Den Experten über das UnterMenü der Editor Experten des GExperts Menüs in Delphi oder per Hotkey
an der Deklarationszeile im Interface Abschnitt aufrufen.

![image](https://github.com/user-attachments/assets/b80d7f84-0ecf-4d10-85c7-dd9bdfaf21df)

Kommentare erfassen 

# Mit ESC ohne Änderungen verlassen
# Mit SHIFT+ENTER Verlassen und die Änderungen übernehmen

Duch Übernehmen werden die Änderungen an den Kommentaren zurück in den Quelltext übernommen.

Mein Dank geht an 

https://blog.dummzeuch.de/experimental-gexperts-version/

außerdem enthalten ein Testprogramm für den Experten für eigene Anpassungen
