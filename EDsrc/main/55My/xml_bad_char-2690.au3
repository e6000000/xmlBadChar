

#AutoIt3Wrapper_Icon=..\..\..\..\..\..\..\..\icon\7i.ico
;IF GUI: GUISetIcon("..\..\..\..\..\..\..\..\icon\7i.ico")
GUISetIcon("..\..\..\..\..\..\..\..\icon\7i.ico")


#include <FileConstants.au3>
;; Hier eine sehr kurze AutoIt-Funktion (auf Deutsch kommentarlos), die ungültige XML-Zeichen durch ein Leerzeichen ersetzt. Sie nutzt AscW und behandelt die üblichen BMP-Bereiche (für Codepoints > 0xFFFF wären Surrogat-Paare nötig — vereinfacht weggelassen, bleibt aber für die meisten Fälle praktisch).
;; Beispiel:
;; ConsoleWrite(StripInvalidXML("Text" & Chr(0) & "End") & @CRLF)

Func StripInvalidXML($s)
    If StringLen($s) = 0 Then Return ""
    Local $out = ""
    For $i = 1 To StringLen($s)
        Local $ch = StringMid($s, $i, 1)
        Local $c = AscW($ch)
        If $c = 9 Or $c = 10 Or $c = 13 Or ($c >= 32 And $c <= 0xD7FF) Or ($c >= 0xE000 And $c <= 0xFFFD) Then
            $out &= $ch
        Else
            $out &= " "
        EndIf
    Next
    Return $out
EndFunc
Func badchar($inFil , $outFil)
  return  ConvertText($inFil , $outFil)
EndFunc
Func ConvertText($inFil , $outFil)
    ; Read the file
    ;local  $inFil ="in.txt"
	; $outFil = "out.txt"

    Local $sText = FileRead($inFil)
    If @error Then
        MsgBox(16, "Error", "Could not read file 'in.txt'.")
        Return
    EndIf

    ; Step 1: Correct misencoded sequences
    Local $aEncodingFixes = [ _
        ["ÃƒÂ¼", "ü"], _  ; e.g., DrÃƒÂ¼cken -> Drücken
        ["ÃƒÂ¤", "ä"], _  ; e.g., GerÃƒÂ¤te -> Geräte
        ["ÃƒÂ¶", "ö"], _  ; e.g., kÃƒÂ¶nnen -> können
        ["ÃƒÂŸ", "ß"], _  ; e.g., hauptsÃƒÂ¤chlich -> hauptsächlich
        ["ÃƒÂ„", "Ä"], _  ; rare, but possible
        ["ÃƒÂ–", "Ö"], _  ; rare, but possible
        ["ÃƒÂœ", "Ü"], _  ; rare, but possible
        ["Ã¢â‚¬â„¢", "’"], _ ; e.g., doesnÃ¢â‚¬â„¢t -> doesn’t
        ["Ã¢â‚¬Å“", "“"], _ ; left double quote
        ["Ã¢â‚¬Â", "—"], _  ; em dash
        ["Ã¢â€šÂ¬", "€"] _  ; Euro symbol
    ]
    For $i = 0 To UBound($aEncodingFixes) - 1
        $sText = StringReplace($sText, $aEncodingFixes[$i][0], $aEncodingFixes[$i][1], 0, 1)
    Next

    ; Step 2: Convert special characters to ASCII equivalents
    Local $aAsciiReplacements = [ _
        ["ä", "ae"], _
        ["ö", "oe"], _
        ["ü", "ue"], _
        ["ß", "ss"], _
        ["Ä", "Ae"], _
        ["Ö", "Oe"], _
        ["Ü", "Ue"], _
        ["€", "EUR"] _ ; Optional: convert Euro to "EUR"
    ]
    For $i = 0 To UBound($aAsciiReplacements) - 1
        $sText = StringReplace($sText, $aAsciiReplacements[$i][0], $aAsciiReplacements[$i][1], 0, 1)
    Next

    ; Step 3: Replace internet link placeholders with numbered references
    Local $iLinkNumber = 1
    While StringInStr($sText, "[link]")
        $sText = StringReplace($sText, "[link]", "(" & $iLinkNumber & ")", 1)
        $iLinkNumber += 1
    WEnd

    ; Write the result to "out.txt"
    FileWrite($outFil, $sText)
    If @error Then
        MsgBox(16, "Error", "Could not write to 'out.txt'.")
    Else
        MsgBox(64, "Success", "Text converted and saved to 'out.txt'.")
    EndIf
EndFunc
Func umlaut($inFil , $outFil)
	;Local $inFil = 'zara.htm'
	;Local $outFil = 'zara2.htm'

	; 1. Datei mit expliziter Kodierung (UTF-8 ohne BOM) öffnen
	; 0 = Lesen, 16 = UTF-8 ohne BOM
	Local $hFile = FileOpen($inFil, 0 + 16)

	; Prüfen, ob die Datei erfolgreich geöffnet wurde
	If $hFile = -1 Then
		MsgBox(16, "Fehler", "Datei '" & $inFil & "' konnte nicht geöffnet werden.")
		Exit
	EndIf

	; Den gesamten Inhalt der Datei einlesen
	Local $in = FileRead($hFile)
	FileClose($hFile)

	; Variable für das Ergebnis
	Local $out = $in

	; ==========================================================
	; SET 1: Korrektur für korrekte Umlaute (falls der Input fehlerfrei war)
	; ==========================================================

	$out = StringReplace($out, 'ä', 'ae')
	$out = StringReplace($out, 'ö', 'oe')
	$out = StringReplace($out, 'ü', 'ue')
	$out = StringReplace($out, 'ß', 's')
	$out = StringReplace($out, 'Ä', 'Ae')
	$out = StringReplace($out, 'Ö', 'Oe')
	$out = StringReplace($out, 'Ü', 'Ue')

	; ==========================================================
	; SET 2: Korrektur für "kryptische" UTF-8-Fehldekodierungen
	; (Der Schutzschild, falls die Kodierung beim Einlesen schiefging)
	; ==========================================================

	$out = StringReplace($out, 'Ã¤', 'ae')   ; UTF-8 'ä' als ANSI gelesen
	$out = StringReplace($out, 'Ã¶', 'oe')   ; UTF-8 'ö' als ANSI gelesen
	$out = StringReplace($out, 'Ã¼', 'ue')   ; UTF-8 'ü' als ANSI gelesen
	$out = StringReplace($out, 'ÃŸ', 's')    ; UTF-8 'ß' als ANSI gelesen
	$out = StringReplace($out, 'Ã„', 'Ae')   ; UTF-8 'Ä' als ANSI gelesen
	$out = StringReplace($out, 'Ã–', 'Oe')   ; UTF-8 'Ö' als ANSI gelesen
	$out = StringReplace($out, 'Ãœ', 'Ue')   ; UTF-8 'Ü' als ANSI gelesen

	; ==========================================================
	; Ergebnis schreiben
	; ==========================================================

	; Datei öffnen zum Schreiben (wird überschrieben). Wir schreiben hier einfach als ANSI/Standard,
	; da alle Umlaute in ASCII-Zeichen ('ae', 'oe', etc.) umgewandelt wurden.
	Local $hFile_out = FileOpen($outFil, 2)
	If $hFile_out = -1 Then
		MsgBox(16, "Fehler", "Ausgabedatei konnte nicht geschrieben werden.")
		Exit
	EndIf

	FileWrite($hFile_out, $out)
	FileClose($hFile_out)

	MsgBox(64, "Fertig", "Die Datei wurde erfolgreich verarbeitet und in '" & $outFil & "' gespeichert.")
EndFunc   ;==>umalut
Func umlaut_OLD($inFil , $outFil)
	;~ Local $inFil = 'zara.htm'
	;~ Local $outFil = 'zara2.htm'
	;~ Local $in = FileRead($inFil)

	;~ ; Replace all umlauts
	;~ Local $out = StringReplace(   $in, 'ä', 'ae')
	;~ 		$out = StringReplace($out, 'ö', 'oe')
	;~ 		$out = StringReplace($out, 'ü', 'ue')
	;~ 		$out = StringReplace($out, 'ß', 's')
	;~ 		$out = StringReplace($out, 'Ä', 'Ae')
	;~ 		$out = StringReplace($out, 'Ö', 'Oe')
	;~ 		$out = StringReplace($out, 'Ü', 'Ue')

	;~ $out = StringReplace($out, 'Ã¤', 'ae')
	;~ $out = StringReplace($out, 'Ã¶', 'oe')
	;~ $out = StringReplace($out, 'Ã¼', 'ue')
	;~ $out = StringReplace($out, 'ÃŸ', 's')
	;~ $out = StringReplace($out, 'Ã„', 'Ae')
	;~ $out = StringReplace($out, 'Ã–', 'Oe')
	;~ $out = StringReplace($out, 'Ãœ', 'Ue')

	;~ ; Write the result
	;~ FileWrite($outFil, $out)
EndFunc

