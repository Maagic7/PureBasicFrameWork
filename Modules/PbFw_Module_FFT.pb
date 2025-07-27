; ===========================================================================
;  FILE: PbFw_Module_DSP.pb
;  NAME: Module Digital Signal Processing 
;  DESC: 
;  DESC: 
;  DESC: 
;  DESC: 
;  SOURCES:  
;     https://rosettacode.org/wiki/Fast_Fourier_transform#VBA
;     https://en.wikipedia.org/wiki/Cooley%E2%80%93Tukey_FFT_algorithm
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2025/04/21
; VERSION  :  0.0 Brainstorming Version
; COMPILER :  PureBasic 6.0 and higher
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
; 
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PX.pb"            ; PX::        Purebasic Extention Module
XIncludeFile "PbFw_Module_PbFw.pb"          ; PbFw::      FrameWork control Module
XIncludeFile "PbFw_Module_Debug.pb"         ; DBG::       Debug Module
XIncludeFile "PbFw_Module_Complex.pb"       ; Complex::   Complex Math Module

; XIncludeFile ""

DeclareModule DSP
  
  EnableExplicit 
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  Structure Window_Type 
    Nome.s      ; Nome della "Window":
    PMin.d      ; Valore Min. del Parametro associato.
    PMax.d      ; Valore Max. del Parametro associato.
    PCor.d      ; Valore corrente del Parametro associato.
  EndStructure
  
 
  ; DFT = Discrete Fourier Transformation
  Declare DFT()
  Declare DFT2()
  
  ; FFT = Fast Fourier Transformation
  Declare FFT()
  
  ; IFFT = Inverse Fast Fourier Transform.
  Declare IFFT()

EndDeclareModule


Module DSP
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  ; ----------------------------------------------------------------------
  ; STRUCTURES and CONSTANTS
  ; ----------------------------------------------------------------------
  
  #A0 = 0.99938       ; Coefficienti per la
  #A1 = 0.041186      ; Weber Window.
  #A2 = -1.637363   
  #A3 = 0.828217
  #B0 = 1.496611
  #B1 = -1.701521
  #B2 = 0.372793
  #B3 = 0.0650621
  
  Dim Hc.d(0)         ; Vettore dei coefficienti del Filtro.
  Dim WF.d(0)         ; Tabella dei coefficienti per Windowing.
  Dim SRE.d(0)        ; Registro a scorrimento dei Dati da Filtrare.
  
  Global.i NK, NCel   ; Ordine e numero di sezioni del filtro.
  Dim Ac.d(0)         ; Coefficienti del Filtro.
  Dim Bc.d(0)         ;      "        "     "
  Dim w.d(0)          ; Registri delle sezioni del Filtro.
  
  #NCMax = 20         ; N. Massimo di sezioni del Filtro.                                                                         ¦
  
  Dim CEB.d(2 * #NCMax + 1)   ; Vettori in uso durante la sintesi.
  Dim AN.d(4, 2)              ;    "        "     "          "
  Dim FINA.d(2)               ;    "        "     "          "
  Dim FINB.d(2)               ;    "        "     "          "
  
  ; ---- Trasformata DFT_1 ------------------------------------------------------
  
  Global.i NsDFT_1      ; N° di campioni - 1 per il calcolo della DFT.
  Global.i NFreqDFT_1   ; N° di frequenze - 1 a cui calcolare la DFT.
  Global.d NormDFT      ; Fattore di normalizzazione sul N° di campioni.
  Global.d SinMat()     ; Matrice dei seni pre-calcolati per DFT_1.
  Global.d CosMat()     ; Matrice dei coseni pre-calcolati per DFT_1.
  
  ; ---- Per routines SFFTBI e SFTTBF -------------------------------------------
  Global.i M            ; integer such that n = 2**m
  Dim S1.d(0)           ; Array of Sin() table (length >= n/8-1)
  Dim C1.d(0)           ; Array of Cos() table (length >= n/8-1)
  Dim S3.d(0)           ; Array of Sin() table (length >= n/8-1)
  Dim C3.d(0)           ; Array of Cos() table (length >= n/8-1)
  Dim ITAB.i(0)         ; integer bit reversal table (length >= sqrt(2n))
  Dim D1d(0)            ; Vettore dei dati di ingresso a base 1, come richiesto dal FORTRAN.

  ; https://de.wikipedia.org/wiki/Fensterfunktion
  ; https://en.wikipedia.org/wiki/Window_function
  
  Enumeration EWindowType
    #WindowType_None 
    #WindowType_Bartlett
    #WindowType_Bartlett_Hann
    #WindowType_Blackman
    #WindowType_Blackman_Harris
    #WindowType_Blackman_Nuttal
    #WindowType_Flat_Top
    #WindowType_Gauss
    #WindowType_Hamming_generalizzata
    #WindowType_Hamming
    #WindowType_Hanning
    #WindowType_Kaiser
    #WindowType_Lanczos
    #WindowType_Nuttal
    #WindowType_Rettangolare
    #WindowType_Triangolare
    #WindowType_Tukey
    #WindowType_Weber
    #WindowType_Welch
  EndEnumeration
  
  #MaxIdx = #PB_Compiler_EnumerationValue -1 
  
  Procedure WinTipi() As Window_Type()
;
;   Imposta i parametri dei tipi di
;   "Window" disponibili:
;    Profilo da File:       WinTipi(0)  -> non usato, in questa applicazione.
;    Bartlett:              WinTipi(1)
;    Bartlett-Hann:         WinTipi(2)
;    Blackman:              WinTipi(3)
;    Blackman-Harris:       WinTipi(4)
;    Blackman-Nuttal:       WinTipi(5)
;    Flat top:              WinTipi(6)
;    Gauss:                 WinTipi(7)
;    Hamming generalizzata: WinTipi(8)
;    Hamming:               WinTipi(9)
;    Hanning:               WinTipi(10)
;    Kaiser:                WinTipi(11)
;    Lanczos:               WinTipi(12)
;    Nuttal:                WinTipi(13)
;    Rettangolare:          WinTipi(14)
;    Triangolare:           WinTipi(15)
;    Tukey:                 WinTipi(16)
;    Weber:                 WinTipi(17)
;    Welch:                 WinTipi(18)
;
    Protected.i I
    Dim WTipi.Window_Type(#MaxIdx) 
    
    I = #WindowType_None
    WTipi(I).Nome = "--> Nome del File"
    WTipi(I).PMin = -1
    WTipi(I).PMax = -1

    I = #WindowType_Bartlett
    WTipi(I).Nome = "Bartlett"
    WTipi(I).PMin = -1
    WTipi(I).PMax = -1

    I = #WindowType_Bartlett_Hann
    WTipi(I).Nome = "Bartlett-Hann"
    WTipi(I).PMin = -1
    WTipi(I).PMax = -1

    I = #WindowType_Blackman
    WTipi(I).Nome = "Blackman"
    WTipi(I).PMin = -1
    WTipi(I).PMax = -1

    I = #WindowType_Blackman_Harris
    WTipi(I).Nome = "Blackman-Harris"
    WTipi(I).PMin = -1
    WTipi(I).PMax = -1

    I = #WindowType_Blackman_Nuttal
    WTipi(I).Nome = "Blackman-Nuttal"
    WTipi(I).PMin = -1
    WTipi(I).PMax = -1

    I = #WindowType_Flat_Top
    WTipi(I).Nome = "Flat top"
    WTipi(I).PMin = -1
    WTipi(I).PMax = -1

    I = #WindowType_Gauss
    WTipi(I).Nome = "Gauss"
    WTipi(I).PMin = 0.05
    WTipi(I).PMax = 0.5
    WTipi(I).PCor = 0.2

    I =     #WindowType_Hamming_generalizzata
    WTipi(I).Nome = "Hamming generalizzata"
    WTipi(I).PMin = 0.5
    WTipi(I).PMax = 1#
    WTipi(I).PCor = 0.5

    I = I    #WindowType_Hamming
    WTipi(I).Nome = "Hamming"
    WTipi(I).PMin = -1
    WTipi(I).PMax = -1

    I = #WindowType_Hanning
    WTipi(I).Nome = "Hanning"
    WTipi(I).PMin = -1
    WTipi(I).PMax = -1

    I = #WindowType_Kaiser
    WTipi(I).Nome = "Kaiser"
    WTipi(I).PMin = 0.5
    WTipi(I).PMax = 20
    WTipi(I).PCor = 10

    I = #WindowType_Lanczos
    WTipi(I).Nome = "Lanczos"
    WTipi(I).PMin = 0.5
    WTipi(I).PMax = 3.5
    WTipi(I).PCor = 1.4

    I = #WindowType_Nuttal
    WTipi(I).Nome = "Nuttal"
    WTipi(I).PMin = -1
    WTipi(I).PMax = -1

    I = #WindowType_Rettangolare
    WTipi(I).Nome = "Rettangolare"
    WTipi(I).PMin = -1
    WTipi(I).PMax = -1

    I = #WindowType_Triangolare
    WTipi(I).Nome = "Triangolare"
    WTipi(I).PMin = -1
    WTipi(I).PMax = -1

    I = #WindowType_Tukey
    WTipi(I).Nome = "Tukey"
    WTipi(I).PMin = 0.5
    WTipi(I).PMax = 1
    WTipi(I).PCor = 1

    I = #WindowType_Weber
    WTipi(I).Nome = "Weber"
    WTipi(I).PMin = 0.5
    WTipi(I).PMax = 1
    WTipi(I).PCor = 1

    I = #WindowType_Welch
    WTipi(I).Nome = "Welch"
    WTipi(I).PMin = 0.5
    WTipi(I).PMax = -1
    WTipi(I).PCor = -1

    WinTipi = WTipi()
    
  EndProcedure

  Procedure FFT(Array *buf.Complex::TComplex(1), Array *out.Complex::TComplex(1), begin.i, Stp.i, N.i)
    Protected.i I
    Protected.d phi
    Protected t.Complex::TComplex, c.Complex::TComplex
   
    If Stp < N 
      FFT(*out(), *buf(), begin, 2 * Stp, N)
      FFT(*out(), *buf(), begin + Stp, 2 * Stp, N)
  
      I = 0
      While I < N
        phi = -#PI * I / N
        t\re = Cos(phi)
        t\im = Sin(phi)
        
        ; cmul(@c, t, *out(begin + I + Stp))
        Complex::CMul(@c, t, *out(begin + I + Stp))
        
        *buf(begin + (I >> 1))\re = *out(begin + I)\re + c\re
        *buf(begin + (I >> 1))\im = *out(begin + I)\im + c\im
        *buf(begin + ((I + N) >> 1))\re = *out(begin + I)\re - c\re
        *buf(begin + ((I + N) >> 1))\im = *out(begin + I)\im - c\im
        
        I = I + 2 * Stp
      Wend
    EndIf
  EndProcedure
  
EndModule

;- ----------------------------------------------------------------------
;- Test Code
;  ----------------------------------------------------------------------

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  UseModule DSP
  
  Procedure show(r.i, txt.s, Array *buf.Complex::TComplex(1))
    Protected I
    Debug txt
    For I = 0 To ArraySize(*buf()) - 1
      Debug StrD(*buf(I)\re) + ", " + StrD(*buf(I)\im)
    Next
  EndProcedure

  Procedure testFFT()
    Protected.i r, I
    Dim buf.Complex::TComplex(7)
    Dim out.Complex::TComplex(7)
  
    buf(0)\re = 1 
    buf(1)\re = 1 
    buf(2)\re = 1
    buf(3)\re = 1
  
    r = 0
    show(r, "Input (real, imag):", buf())
    FFT(buf(), out(), 0, 1, 8)
    r + 1
    show(r, "Output (real, imag):", out())
  EndProcedure
  
  testFFT()
  
  DisableExplicit
CompilerEndIf




; IDE Options = PureBasic 6.20 (Windows - x64)
; CursorPosition = 115
; FirstLine = 69
; Folding = --
; Optimizer
; CPU = 5