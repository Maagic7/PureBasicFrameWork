; ===========================================================================
;  FILE : Module_ECAD_SYMBOL.pb
;  NAME : Module SYMBOL
;  DESC : Functions for ECAD Symbols
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/10/30
; VERSION  :  1.0
; COMPILER :  PureBasic 6.0
; ===========================================================================
; ChangeLog:
;             
; ============================================================================


; ECAD Symboldatei .sym
; Zahlendarstellung Little Endian Lo first
; 
; =======================================
; Symbole Sym Ecad 8
; =======================================
; 18 Byte [Dateiheader]
; For Each Symbol
;   10 Bytes ???
; 	4 Byte Long Symbolnummer
; 	2 Byte      wahrschneilich Subklasse ID (immer $01xy)
; 	40 ASCII Subklasse
; 	
; Ende Symbol 4xFF + 4x00 [FF FF FF FF 00 00 00 00]
; 
; 02 05 : vor Font  0205 Arial.{Size}
; 
; 
; Symbolende
; ECAD9: 02 FF 02 FF 02 FF (NextSymbol Klassifizierung 00, 01, 02)

;- ----------------------------------------------------------------------
;- Include Files
;- ----------------------------------------------------------------------

; Module for Buffer handling  
XIncludeFile "Module_BUFFER.pb"       ; BUFFER::
; Module for String handling
XIncludeFile "Module_STRING.pb"       ; STR::


DeclareModule SYMBOL
  ; 2x Long Positionswert Textausrichtung/Drehwinkel
  ; Hinweis, Funktion, 0=90°, 1=0°, 2=270°, 3=180°
  ; Struct
  ;   x.l
  ;   y.l
  ;   Textpositionierung.a 
  ;   TextWinkel.a   
  ; Endstruct
  
  ; Texte
  ; [15] 
  ; [FontNameZeichen][FontName][AnzahlZeichen][Text] 
  ; die Strings haben keine 0 am Ende, dafür wird ein Byte mit der Zeichenlänge vorgestellt
  
  Structure RAW_SymbolText
    TextSize.f  ; 4Byte float wahrscheinlich
    FontFlags.a
    Winkel.a    ; Byte 4.5 (0..)
    X.l
    Y.l
    Ausrichtung.a  ; 0=links 1=Mitte, 2=rechts oben unten wird direkt mit der Positionskoordinate verrechnet
    LFont.a
    FontName.s
    LText.a
    Text.s
  EndStructure
  
  
  ; leeres Symbol
  ; [Bytes]
  ; [5]  = 00
  ; [1]  = 08  BMK Winkel 8=0°, 4=90°, 2=180°, 1=270°
  ; [8]  = 00
  ; [4]  = SymbolNr.
  ; [1]  = 01 SOH
  ; [1]  = SubID
  ; [13] = 00  SubIDName ASCII
  ; [01] = 01 SOH
  ; [4]  = 
  ; [01] = 01 SOH
  ; [4]  = 
  ; [01] = 01 SOH
  ; [4]  = 
  ; [01] = 01 SOH
  ; [11] 
  ; [1]  = 03 ETX
  ; [4]  = 
  ; [1]  = 03 ETX
  ; [17]   =BMK Position
  ; [4]  = FF FF FF FF = Symbol Ende
  
  
  #SYMB_ECAD8_END = $FFFFFFFF  ; lo,hi in Datei FF FF FF FF 00 00 00 00 
  ; ein leeres Symbol ist 208Bytes lang
  ; [14] unbekannt  ; Byte 6 is $08 bei neuen leeren Symbolen
  ; [04] Symbol Nummer
  ; [02] Subklasse ID
  ; [40] Subklasse Name Ascii Text
  ; [xx] Daten
  ; [08] Symbol Ende [FF FF FF FF] da letztes Symbol auf FFFF FFFF endet, die  4x$00 ist somit am Anfang
  Structure TSymRawECAD8    ; Rohdatenstruktur Sybole in Datei
    ID.i          ; 4 Byte Symbol-Nummer
    SubID.i       ; Subklasse ID
    SubName.s     ; Bezeichnung Subklasse ASCII-Text
    hBuf.BUFFER::hBuffer  ; Buffer Handle Daten
  EndStructure
  
  Structure TSymRawECAD9 ; Rohdatenstruktur Sybole in Datei
    
  EndStructure
  
  ; Subklasse ID
  ; $01 gefolgt von  $01 wird bereits bei leeren Symbolen eingetragen; ASCII $01 = SOH StartOfHeading
  ; $05 =05   - Diode
  ; $10 =16   - Zweiwegeschließer
  ; $0C =12   - bei Induktivität
  ; $0B =11   - bei Kondensator
  
  ; $11 =17 Sicherungs Hauptelement
  
  ; $12 =18  Schalter Hauptelement
EndDeclareModule


Module SYMBOL
  
  EnableExplicit
  
  
  
EndModule


CompilerIf #PB_Compiler_IsMainFile
  
  EnableExplicit
  
  UseModule SYMBOL
  
  
CompilerEndIf

; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 69
; FirstLine = 21
; Folding = -
; Optimizer
; Compiler = PureBasic 6.00 LTS (Windows - x86)