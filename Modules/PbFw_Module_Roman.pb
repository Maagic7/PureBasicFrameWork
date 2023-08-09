; ===========================================================================
;  FILE : Module_Roman.pb
;  NAME : Module Roman [Rom::]
;  DESC : Functions to deal with Roman numerals between [1..4999]
;  DESC : The limitation to 4999 depends on the standard convetion 
;  DESC : which allows a max of 4 identical characters MMMMM (=40000)
;  DESC : for higher values special conventions are used which are
;  DESC : not identical. 
;  DESC : RomanToInt("XVII") => 17; IntToRoman(20) = "XX"
;  SOURCES: Wikipedia https://en.wikipedia.org/wiki/Roman_numerals
;           https://rosettacode.org/wiki/Roman_numerals/Decode#PureBasi
;           https://rosettacode.org/wiki/Roman_numerals/Encode#PureBasic
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/11/12
; VERSION  :  2.0  Release Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{ 
;  2023/08/01 S.Maag: 
;     - New IntToRoman And RomanToInt Function based on RoseattaCode
;       because it's much smarter code as my >300 line code was!
;     - Added RemoveNonRomanChars() from a String
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module

DeclareModule Rom
  
  Declare.s RemoveNonRomanChars(sRoman.s)   ; Removes all non Roman characters from a String
  Declare.i RomanToInt(sTxt.s)              ; Converts a Roman Numeral String into an Integer
  Declare.s IntToRoman(iValue.i)            ; Converts an Integer into a Roman Numeral String

EndDeclareModule


Module Rom
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  ; private Structure
  Structure TRomanNumeral
    Symbol.s 
    Value.i
  EndStructure
  
  ;- ----------------------------------------------------------------------
  ;- Module Public Functions
  ;- ----------------------------------------------------------------------
  
  Procedure.s RemoveNonRomanChars(sRoman.s)
    ; ============================================================================
    ; NAME: RemoveNonRomanChars
    ; DESC: Removes all non Roman characters from a String
    ; DESC: kepp only M,D,C,L,X,I Upcase all chars
    ; DESC: it can be used for correcting user inputs
    ; VAR(sRoman.s) : Roman Numeral String
    ; RET.s: Roman Numeral String, 
    ; ============================================================================
    
    Protected *pWrite.Character = @sRoman   ; WritePointer
    Protected *pRead.Character = @sRoman    ; ReadPointer
    Protected c.c   ; c As Character
            
  	While *pRead\c     ; While Not NullChar
  	  
  	  c = *pRead\c    ; copy to extra char variable for UCase(c)	  
  	  If c >='a' And c <='z' ; we have to UCase it
   	    c - 32 ;   UCase(c) ;  32 = 'a' - 'A'  ;  a[97]-A[65]=32
   	    *pRead\c = c ; write back UCase(c)
   	  EndIf
  	  
  	  Select c 	      
        ; ----------------------------------------------------------------------
        ; Characters to keep {M,D,C,L,X,V,I}
        ; ----------------------------------------------------------------------               	      
        Case 'M', 'D', 'C', 'L', 'X', 'V' ,'I'   ; keep  it
         	If *pWrite <> *pRead     ; if  WritePosition <> ReadPosition
        		*pWrite\c = *pRead\c   ; Copy the Character from ReadPosition to WritePosition => compacting the String
        	EndIf
        	*pWrite + SizeOf(Character) ; set new Write-Position                        
      EndSelect
      
      *pRead + SizeOf(Character) ; Set Pointer to NextChar 		
    Wend
    
    ; write the Null-Termination at last Position
 		*pWrite\c = 0
 		
 		ProcedureReturn sRoman ; Return the compacted String with Roman Numerals only
  EndProcedure

  Procedure.i RomanToInt(sRoman.s)
  ; ============================================================================
  ; NAME: RomanToInt
  ; DESC: Convert Roman Numeral to Integer
  ; VAR(sRoman.s): String containing the Roman Numeral
  ; RET.i: Integer Value of Roman numeral ; If 0, it's not a valid Roman numeral
  ; ============================================================================
    Protected I, n, lastval, RetVal
    
    For I = Len(sRoman) To 1 Step -1
      
      Select UCase(Mid(sRoman, I, 1))
        Case "M"
          n = 1000
        Case "D"
          n = 500
        Case "C"
          n = 100
        Case "L"
          n = 50
        Case "X"
          n = 10
        Case "V"
          n = 5
        Case "I"
          n = 1
        Default
          n = 0
      EndSelect
      
      If n < lastval
        RetVal - n
      Else
        RetVal + n
      EndIf
      lastval = n      
    Next 
    
    ProcedureReturn RetVal
  EndProcedure
  
  Procedure.s IntToRoman(iValue.i)
  ; ============================================================================
  ; NAME: IntToRoman
  ; DESC: converts an Integer to a Roman numeral
  ; DESC: based on 
  ; VAR(iValue.i): The Number to convert must be [1..4999]
  ;                4999 is the maximum what can be written without special signs
  ;                or special conventions. 4999=MMMMCMXCIX
  ;  
  ; RET.s: Roman numeral
  ; ============================================================================
    
    #NoOfSymbols = 12 ;0 based count

    Static init
    Static Dim refRomanNum.TRomanNumeral(#NoOfSymbols)
    Protected roman$, I
 
    ; ----------------------------------------------------------------------
    ;  Initialisation
    ; ---------------------------------------------------------------------- 
    If Not init
      Restore denominations
      For I = 0 To #NoOfSymbols
        Read.s refRomanNum(I)\Symbol
      Next
      Restore denomValues
      For I = 0 To #NoOfSymbols
        Read refRomanNum(i)\Value
      Next       
      init = #True
    EndIf
    
    ; ----------------------------------------------------------------------
    ;  Conversion
    ; ---------------------------------------------------------------------- 
    For I = 0 To #NoOfSymbols
      While iValue >= refRomanNum(i)\value
        roman$ + refRomanNum(i)\symbol
        iValue - refRomanNum(i)\value
      Wend
    Next
    ProcedureReturn roman$
  EndProcedure

  DataSection
    denominations:
    Data.s "M","CM","D","CD","C","XC","L","XL","X","IX","V","IV","I" ;0-12
    denomValues:
    Data.i  1000,900,500,400,100,90,50,40,10,9,5,4,1 ;values in decending sequential order
  EndDataSection

EndModule


CompilerIf #PB_Compiler_IsMainFile
 ; ----------------------------------------------------------------------
 ;  M O D U L E   T E S T   C O D E
 ; ---------------------------------------------------------------------- 
 
  EnableExplicit
  UseModule Rom
  
  Define s.s, v.i
  
  Debug ""
  Debug "Roman Numbers"
  s ="MCMLXXXXIV" : Debug s + " : " + Str(RomanToInt(s))
  s ="IXI" : Debug s + " : " + Str(RomanToInt(s))
  s ="XIII" : Debug s + " : " + Str(RomanToInt(s))
  s ="CMXCIX" : Debug s + " : " + Str(RomanToInt(s))
  s ="IM" : Debug s + " : " + Str(RomanToInt(s))
  s ="MMMMCMXCIX" : Debug s + " : " + Str(RomanToInt(s))
  
;   v = 99 : Debug(Str(v) + " : " + IntToRoman(v)) 
;   v = 999 : Debug(Str(v) + " : " + IntToRoman(v)) 
  v = 1984 : Debug(Str(v) + " : " + IntToRoman(v)) 
  v = 4999 : Debug(Str(v) + " : " + IntToRoman(v))
  s=IntToRoman(v) : : Debug s + " : " + Str(RomanToInt(s))
  
  s="123 MCM.LXXXX-Iv"
  Debug #Null$
  Debug "Remove non Roman Characters from: "
  Debug s
  Debug RemoveNonRomanChars("123 MCm.LXXxX-Iv")
CompilerEndIf 
; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 42
; FirstLine = 162
; Folding = --
; Optimizer
; CPU = 5