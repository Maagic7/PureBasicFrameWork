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
; VERSION  :  2.0
; COMPILER :  PureBasic 6.0
; ===========================================================================
; ChangeLog: 
;{ 
;  2023/08/01 S.Maag: New IntToRoman and RomanToInt Function based on RoseattaCode
;                     because it's much smarter code then my >300 line code was
;}
; ===========================================================================

;{ ====================      M I T   L I C E N S E        ====================
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;} ============================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module

DeclareModule Rom
    
  Declare.i RomanToInt(sTxt.s)
  Declare.s IntToRoman(iValue.i)

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
  
  Procedure.i RomanToInt(sRoman.s)
  ; ============================================================================
  ; NAME: RomanToInt
  ; DESC: converts Roman Numeral to Integer
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

CompilerEndIf 
; IDE Options = PureBasic 6.02 LTS (Windows - x86)
; CursorPosition = 8
; Folding = --
; Optimizer
; CPU = 5