

#AutoIt3Wrapper_Icon=..\..\..\..\..\..\..\..\icon\7i.ico
;IF GUI: GUISetIcon("..\..\..\..\..\..\..\..\icon\7i.ico")
GUISetIcon("..\..\..\..\..\..\..\..\icon\7i.ico")


#include <FileConstants.au3>
;; Hier eine sehr kurze AutoIt-Funktion (auf Deutsch kommentarlos), die ung¸ltige XML-Zeichen durch ein Leerzeichen ersetzt. Sie nutzt AscW und behandelt die ¸blichen BMP-Bereiche (f¸r Codepoints > 0xFFFF w‰ren Surrogat-Paare nˆtig ó vereinfacht weggelassen, bleibt aber f¸r die meisten F‰lle praktisch).
;; Beispiel:
;; ConsoleWrite(StripInvalidXML("Text" & Chr(0) & "End") & @CRLF)
;; Fazit: Die Reihenfolge im hochgeladenen AU3 ist sinnvoll und praxisgerecht
;; zuerst Umlaut/Kodierungskorrektur, dann XML-Sanitierung
;; ergaenzt um Unicode-Bewusstsein (Surrogate), Logging und Backup

if 1 then
$clean = cleanStr("Beispieltext mit √º und " & Chr(0) & " ung¸ltigen XML-Bytes")
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
EndFunc
func umlaut($s)
	local $out = $s
	;; ## string due ##
	; ==========================================================
	; SET 1: Korrektur f¸r korrekte Umlaute (falls der Input fehlerfrei war)
	; ==========================================================

	$out = StringReplace($out, '‰', 'ae')
	$out = StringReplace($out, 'ˆ', 'oe')
	$out = StringReplace($out, '¸', 'ue')
	$out = StringReplace($out, 'ﬂ', 's')
	$out = StringReplace($out, 'ƒ', 'Ae')
	$out = StringReplace($out, '÷', 'Oe')
	$out = StringReplace($out, '‹', 'Ue')
	$out = StringReplace($out, "Ä", "EUR")

	$out = StringReplace($out,"√É¬º", "ue" ) ;;   ; e.g., Dr√É¬ºcken -> Dr¸cken
	$out = StringReplace($out,"√É¬§", "ae" ) ;;   ; e.g., Ger√É¬§te -> Ger‰te
	$out = StringReplace($out,"√É¬∂", "oe" ) ;;   ; e.g., k√É¬∂nnen -> kˆnnen
	$out = StringReplace($out,"√É¬ü", "s" ) ;;   ; e.g., haupts√É¬§chlich -> haupts‰chlich
	$out = StringReplace($out,"√É¬Ñ", "Ae" ) ;;   ; rare, but possible
	$out = StringReplace($out,"√É¬ñ", "Oe" ) ;;   ; rare, but possible
	$out = StringReplace($out,"√É¬ú", "Ue" ) ;;   ; rare, but possible
	$out = StringReplace($out,"√¢‚Ç¨‚Ñ¢", "'" ) ;;  ; e.g., doesn√¢‚Ç¨‚Ñ¢t -> doesnít
	$out = StringReplace($out,"√¢‚Ç¨≈ì", '"' ) ;;  ; left double quote
	$out = StringReplace($out,"√¢‚Ç¨¬", "ó" ) ;;   ; em dash
	$out = StringReplace($out,"√¢‚Äö¬¨", "EUR") ;;   ; Euro symbol

	;;// linken // rechte doppelte Anf¸hrungsstrich ( ' Ñ ' oder  ' ì î " ')
	;;//  Kurzfazit: Ersetze //// "√¢‚Ç¨≈ì" ? ì  ////  "√¢‚Ç¨¬ù" ? î  ////  "‚Äú" ? ì  ////  "‚Ä?" ? î  ////  "‚Äî" ? ó  ////

	$out = StringReplace($out, "√¢‚Ç¨¬ù",  '"') ;;  ; left double quote
	$out = StringReplace($out, "√¢‚Ç¨≈ì", '"' ) ;;  ; left double quote
	$out = StringReplace($out, "√¢‚Ç¨?",  '"')  ;;  ; right double quote
	$out=StringReplace(  $out, "‚Ä?", '"' )     ;; common UTF-8?ANSI Fehler f¸r rechte Anf¸hrungszeichen
	$out=StringReplace(  $out, "‚Äú", '"' )     ;;  linke Anf¸hrungszeichen
	$out = StringReplace($out, "‚Äú", '"')     ; left double quote (UTF-8 as ANSI)
	$out = StringReplace($out, "‚??", '"')     ; right double quote (UTF-8 as ANSI)
	$out = StringReplace($out, "‚Äî", "ó")     ; em dash
	$out = StringReplace($out, "√¢‚Ç¨", "ó")   ; em dash (Mojibake variant)

	; ==========================================================
	; SET 2: Korrektur f¸r "kryptische" UTF-8-Fehldekodierungen
	; (Der Schutzschild, falls die Kodierung beim Einlesen schiefging)
	; ==========================================================

	$out = StringReplace($out, '√§', 'ae')   ; UTF-8 '‰' als ANSI gelesen
	$out = StringReplace($out, '√∂', 'oe')   ; UTF-8 'ˆ' als ANSI gelesen
	$out = StringReplace($out, '√º', 'ue')   ; UTF-8 '¸' als ANSI gelesen
	$out = StringReplace($out, '√ü', 's')    ; UTF-8 'ﬂ' als ANSI gelesen
	$out = StringReplace($out, '√Ñ', 'Ae')   ; UTF-8 'ƒ' als ANSI gelesen
	$out = StringReplace($out, '√ñ', 'Oe')   ; UTF-8 '÷' als ANSI gelesen
	$out = StringReplace($out, '√ú', 'Ue')   ; UTF-8 '‹' als ANSI gelesen

	;; ## string due  end ##
    return $out


	   if 0 Then
       ;; alternative with  2D array[][] StringReplace
        local	$res
		Local $aAsciiReplacements = [ _
			["‰", "ae"], _
			["ˆ", "oe"], _
			["¸", "ue"], _
			["ﬂ", "ss"], _
			["ƒ", "Ae"], _
			["÷", "Oe"], _
			["‹", "Ue"], _
			["Ä", "EUR"] _
		]
		For $i = 0 To UBound($aAsciiReplacements) - 1
		$res = StringReplace($res, $aAsciiReplacements[$i][0], $aAsciiReplacements[$i][1], 0, 1)
		Next
    EndIf
EndFunc
Func cleanStr($s)
  $s = umlaut($s)
  return StripInvalidXML($s)
EndFunc
;; badChar  File
Func badCharFil($inFil , $outFil)
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
EndFunc
Func badCharFilUTF($inFil , $outFil)
	;Local $inFil = 'zara.htm'
	;Local $outFil = 'zara2.htm'
	; 1. Datei mit expliziter Kodierung (UTF-8 ohne BOM) ˆffnen
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

	; Datei ˆffnen zum Schreiben (wird ¸berschrieben). Wir schreiben hier einfach als ANSI/Standard,
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
EndFunc

