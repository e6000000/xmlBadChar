

#AutoIt3Wrapper_Icon=..\..\..\..\..\..\..\..\icon\7i.ico
;IF GUI: GUISetIcon("..\..\..\..\..\..\..\..\icon\7i.ico")
GUISetIcon("..\..\..\..\..\..\..\..\icon\7i.ico")


#include <FileConstants.au3>
;; Hier eine sehr kurze AutoIt-Funktion (auf Deutsch kommentarlos), die ungültige XML-Zeichen durch ein Leerzeichen ersetzt. Sie nutzt AscW und behandelt die üblichen BMP-Bereiche (für Codepoints > 0xFFFF wären Surrogat-Paare nötig — vereinfacht weggelassen, bleibt aber für die meisten Fälle praktisch).
;; Beispiel:
;; ConsoleWrite(StripInvalidXML("Text" & Chr(0) & "End") & @CRLF)
;; Fazit: Die Reihenfolge im hochgeladenen AU3 ist sinnvoll und praxisgerecht
;; zuerst Umlaut/Kodierungskorrektur, dann XML-Sanitierung
;; ergaenzt um Unicode-Bewusstsein (Surrogate), Logging und Backup

If 1 Then
	$clean = cleanStr("Beispieltext mit Ã¼ und " & Chr(0) & " ungültigen XML-Bytes")
	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $clean = ' & $clean & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
EndIf

;; badChar  String
Func StripInvalidXML($s)  ;; string
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
EndFunc   ;==>StripInvalidXML
Func umlaut($s)
	Local $out = $s
	;; ## string due ##
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
	$out = StringReplace($out, "€", "EUR")

	$out = StringReplace($out, "ÃƒÂ¼", "ue") ;;   ; e.g., DrÃƒÂ¼cken -> Drücken
	$out = StringReplace($out, "ÃƒÂ¤", "ae") ;;   ; e.g., GerÃƒÂ¤te -> Geräte
	$out = StringReplace($out, "ÃƒÂ¶", "oe") ;;   ; e.g., kÃƒÂ¶nnen -> können
	$out = StringReplace($out, "ÃƒÂŸ", "s") ;;   ; e.g., hauptsÃƒÂ¤chlich -> hauptsächlich
	$out = StringReplace($out, "ÃƒÂ„", "Ae") ;;   ; rare, but possible
	$out = StringReplace($out, "ÃƒÂ–", "Oe") ;;   ; rare, but possible
	$out = StringReplace($out, "ÃƒÂœ", "Ue") ;;   ; rare, but possible
	$out = StringReplace($out, "Ã¢â‚¬â„¢", "'") ;;  ; e.g., doesnÃ¢â‚¬â„¢t -> doesn’t
	$out = StringReplace($out, "Ã¢â‚¬Å“", '"') ;;  ; left double quote
	$out = StringReplace($out, "Ã¢â‚¬Â", "—") ;;   ; em dash
	$out = StringReplace($out, "Ã¢â€šÂ¬", "EUR") ;;   ; Euro symbol

	;;// linken // rechte doppelte Anführungsstrich ( ' „ ' oder  ' “ ” " ')
	;;//  Kurzfazit: Ersetze //// "Ã¢â‚¬Å“" ? “  ////  "Ã¢â‚¬Â" ? ”  ////  "â€œ" ? “  ////  "â€?" ? ”  ////  "â€”" ? —  ////

	$out = StringReplace($out, "Ã¢â‚¬Â", '"')  ;;  ; left double quote
	$out = StringReplace($out, "Ã¢â‚¬Å“", '"')  ;;  ; left double quote
	$out = StringReplace($out, "Ã¢â‚¬?", '"')   ;;  ; right double quote
	$out = StringReplace($out, "â€?", '"')      ;; common UTF-8?ANSI Fehler für rechte Anführungszeichen
	$out = StringReplace($out, "â€œ", '"')      ;;  linke Anführungszeichen
	$out = StringReplace($out, "â€œ", '"')     ; left double quote (UTF-8 as ANSI)
	$out = StringReplace($out, "â??", '"')     ; right double quote (UTF-8 as ANSI)
	$out = StringReplace($out, "â€”", "—")     ; em dash
	$out = StringReplace($out, "Ã¢â‚¬", "—")   ; em dash (Mojibake variant)

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

	;; ## string due  end ##
	Return $out


	If 0 Then
		;; alternative with  2D array[][] StringReplace
		Local $res
		Local $aAsciiReplacements = [ _
				["ä", "ae"], _
				["ö", "oe"], _
				["ü", "ue"], _
				["ß", "ss"], _
				["Ä", "Ae"], _
				["Ö", "Oe"], _
				["Ü", "Ue"], _
				["€", "EUR"] _
				]
		For $i = 0 To UBound($aAsciiReplacements) - 1
			$res = StringReplace($res, $aAsciiReplacements[$i][0], $aAsciiReplacements[$i][1], 0, 1)
		Next
	EndIf
EndFunc   ;==>umlaut
Func cleanStr($s)
	$s = umlaut($s)
	Return StripInvalidXML($s)
EndFunc   ;==>cleanStr
;; badChar  File
Func badCharFil($inFil, $outFil)
	; Read the file
	;local  $inFil ="in.txt"
	; $outFil = "out.txt"

	Local $in = FileRead($inFil)
	If @error Then
		MsgBox(16, "Error", "Could not read file 'in.txt'.")
		Return
	EndIf

	;; ## string due ##
	$in = umlaut($in)
	$in = StripInvalidXML($in)
	;; ## string due  end ##

	; Write the result to "out.txt"
	FileDelete($outFil)
	FileWrite($outFil, $in)
	If @error Then
		MsgBox(16, "Error", "Could not write to 'out.txt'." & $outFil)
	Else
		MsgBox(64, "Success", "Text converted and saved to 'out.txt'." & $outFil)
	EndIf
EndFunc   ;==>badCharFil
Func badCharFilUTF($inFil, $outFil)
	;Local $inFil = 'zara.htm'
	;Local $outFil = 'zara2.htm'
	; 1. Datei mit expliziter Kodierung (UTF-8 ohne BOM) öffnen
	; 0 = Lesen, 16 = UTF-8 ohne BOM
	Local $hFile = FileOpen($inFil, 0 + 16)
	If $hFile = -1 Then
		MsgBox(16, "Fehler", "Datei '" & $inFil & "' Could not read file.")
		Exit
	EndIf
	Local $in = FileRead($hFile)
	FileClose($hFile)

	;; ## string due ##
	$in = umlaut($in)
	$in = StripInvalidXML($in)
	;; ## string due  end ##

	; Datei öffnen zum Schreiben (wird überschrieben). Wir schreiben hier einfach als ANSI/Standard,
	; da alle Umlaute in ASCII-Zeichen ('ae', 'oe', etc.) umgewandelt wurden.
	FileDelete($outFil)
	Local $hFile_out = FileOpen($outFil, 1)  ; after DEL append reicht
	If $hFile_out = -1 Then
		MsgBox(16, "Fehler", "Ausgabedatei konnte nicht geschrieben werden.")
		Exit
	EndIf

	FileWrite($hFile_out, $in)
	FileClose($hFile_out)

	MsgBox(64, "Fertig", "Die Datei wurde erfolgreich verarbeitet und in '" & $outFil & "' gespeichert.")
EndFunc   ;==>badCharFilUTF

