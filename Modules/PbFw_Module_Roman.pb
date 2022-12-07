; ===========================================================================
;  FILE : Module_Roman.pb
;  NAME : Module Roman [Rom::]
;  DESC : Functions to deal with Roman numerals between [1..4999]
;  DESC : The limitatin to 4999 depends on the standard convetion 
;  DESC : which allows a max of 4 identical characters MMMMM (=40000)
;  DESC : for higher values special conventions are used which are
;  DESC : not identical. 
;  DESC : see Wikipedia https://en.wikipedia.org/wiki/Roman_numerals
;  DESC : RomanToInt(XVII) => 7; IntToRoman(20) =XX
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/11/12
; VERSION  :  1.0
; COMPILER :  PureBasic 6.0
; ===========================================================================
; ChangeLog: 
;{
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

; XIncludeFile ""

DeclareModule Rom

  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  
  ; Values for Roman digits
  #ROM_Num_I = 1        
  #ROM_Num_V = 5
  #ROM_Num_X = 10
  #ROM_Num_L = 50
  #ROM_Num_C = 100
  #ROM_Num_D = 500
  #ROM_Num_M = 1000
  
  Declare RomanToInt(sTxt.s)
  Declare.s IntToRoman(iValue.i)

EndDeclareModule


Module Rom
  EnableExplicit
  
  #ROM_SPACE = ' '  ; Constant for a single SPACE

  Structure pChar   ; virtual CHAR-ARRAY, used as Pointer to overlay on strings 
    c.c[0]          ; fixed ARRAY Of CHAR Length 0
  EndStructure

  ;- ----------------------------------------------------------------------
  ;- Module Private Functions
  ;- ----------------------------------------------------------------------
  
  Procedure _GetValueFromROMdigit(cNum.c)
    Protected RET
    
    Select cNum
      Case 'I'        ; 1
        RET = 1   
      Case 'V'        ; 5
        RET = 5
      Case 'X'        ; 10
        RET = 10
      Case 'L'        ; 50
        RET = 50
      Case 'C'        ; 100
        RET = 100
      Case 'D'        ; 500
        RET = 500
      Case 'M'        ; 1000
        RET = 1000
      Default
        RET = 0
    EndSelect
    ProcedureReturn RET 
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Module Public Functions
  ;- ----------------------------------------------------------------------

  Procedure RomanToInt(sTxt.s)
  ; ============================================================================
  ; NAME: RomanToInt
  ; DESC:
  ; VAR(sTxt.s): Roman numerals
  ; RET.i: Integer Value of Roman numeral ; If 0, it's not a valid Roman numeral
  ; ============================================================================
    Protected I, J, c.c
    Protected xSpaceAtEnd, xMaxDigit
    Protected vDigit, vNum, Lowest.Integer
    Protected IsRom = #True
    Protected *char.pChar   ; Pointer to virtual CHAR-ARRAY
    Protected actChar.c, NextChar.c
    
    Dim prevDig.c(4)        ; Array for the last 4 previous digits

    *char = @sTxt           ; overlay the String with a virtual Char-Array
        
    If Not *char            ; If *Pointer to String is #Null
      ProcedureReturn 0     ; ******** NotNumeric => EXIT PROCEDURE *********     
    EndIf
    
    I = 0
    
    ; ----------------------------------------------------------------------
    ;  Skip possible SPACEs
    ; ---------------------------------------------------------------------- 
    While *char\c[I] = #ROM_SPACE    
      I + 1
    Wend      

    ; ----------------------------------------------------------------------
    ;  Pase numerals -  check for I,V,X,L,C,D,M
    ; ---------------------------------------------------------------------- 
    
    Lowest\i = #ROM_Num_M
    
    While *char\c[I]
      
      actChar = *char\c[I]
      NextChar = *char\c[I+1]
      vDigit = 0
      
      ; Buffer of the last 5 Digits (shift register)
      prevDig(0) = prevDig(1)
      prevDig(1) = prevDig(2)
      prevDig(2) = prevDig(3)
      prevDig(3) = prevDig(4)
      prevDig(4) = actChar
      
      ; up to 4 digits of the same Value are allowed (XXXX is ok; XXXXX is not ok)
      ; with subtraction rule usually 3 of the same. But this is not a fixed rule!
      ; The substraction rule is a later development!
      xMaxDigit =#True
      For J = 1 To 4
        If prevDig(0) <>  prevDig(J)  ; if one of the 4 is a different digit => ok
          xMaxDigit = #False          ; maxLimit of Digits (3) not reached
          Break
        EndIf
      Next
      
      ; if more than 4 digits of the same value => it is not a correct Roman numeral
      If xMaxDigit
        IsRom =#False
        Debug "MaxDigits overflow"
      EndIf
      
      Select *char\c[I]
        Case #ROM_SPACE
          xSpaceAtEnd=#True     ; Space dedected : if it is not in the middle it is ok!
          Break
          
        ; ---------------------------------------------------------------------- 
        ;  valid Characters for {1..} I=1, X=10, C=100, M=1000 
        ;  because of substruction rule we have to process each character seperatly
        ; ---------------------------------------------------------------------- 
          
        Case 'I' ; 1
          vDigit = #ROM_Num_I
          
          ; subtraction rule: if on 'I' follows 'V' or 'X'
          If NextChar ='V' Or NextChar='X'
            vDigit = -#ROM_Num_I
          Else
            vDigit = #ROM_Num_I
            If _GetValueFromROMdigit(NextChar) > vDigit ; if a higher Digit follows
              IsRom =#False                             ; it is a fault
              Break
            EndIf              
          EndIf
          
        Case 'X' ; 10
          
          ; subtraction rule: if on 'X' follows 'L' or 'C'
          If NextChar ='L' Or NextChar='C'
            vDigit = -#ROM_Num_X  
          Else
            vDigit = #ROM_Num_X
            If _GetValueFromROMdigit(NextChar) > vDigit  ; if a higher Digit follows
              IsRom =#False                               ; it is a fault
              Break
            EndIf              
          EndIf
          
        ; subtraction rule: if on 'C' follows 'D' or 'M'
        Case 'C' ; 100
         
          If NextChar ='D' Or NextChar='M'
            vDigit = -#ROM_Num_C  
          Else
            vDigit = #ROM_Num_C
            If _GetValueFromROMdigit(NextChar) > vDigit ; if a higher Digit follows
              IsRom =#False                             ; it is a fault
              Break
            EndIf              
          EndIf
          
        Case 'M' ; 1000
          vDigit = #ROM_Num_M
          
        ; ---------------------------------------------------------------------- 
        ;  valid Characters for {5} V=5, L=50, D=500 
        ;  5' Values V,L,D are not affectec by substraction rule 
        ; ----------------------------------------------------------------------  
        Case 'V', 'L', 'D'
          vDigit = _GetValueFromROMdigit(actChar) ; (aktChar, NextChar, Lowest)
          
          If _GetValueFromROMdigit(NextChar) > vDigit ; if a higher Digit follows
            IsRom =#False                             ; it is a fault
            Break
          EndIf              
         Debug Chr(actChar) + " : " + vDigit
          
            
        Default   ; Any other Character is not allowed
          IsRom = #False
           Break
          
     EndSelect    
     
     vNum = vNum + vDigit   ; the actual Value of the Roman numereal
     I + 1                  ; Attention, if we leave with Break, I is not inkremented!
    Wend
    
    ; ----------------------------------------------------------------------
    ;  Skip possible SPACEs at the end
    ; ---------------------------------------------------------------------- 
    If xSpaceAtEnd
      I + 1           
      While *char\c[I]              ; if all Chars at end are Spaces it is ok 
        If *char\c[I] <> #ROM_SPACE ; if any other Char follows after the Space, it is not an INT
          IsRom = #False
        EndIf
        I + 1
      Wend      
    EndIf
    
    If IsRom 
      ProcedureReturn vNum      ; if it is a correct Roman numeral, return the integer value
    Else
      ProcedureReturn 0         ; otherwise 0 (0 does not exist in Roman Numbers, so it is not a valid Roman numeral)
    EndIf
  EndProcedure
  
  Procedure.s IntToRoman(iValue.i)
  ; ============================================================================
  ; NAME: IntToRoman
  ; DESC: converts an Integer to a Roman numeral
  ; VAR(iValue.i): The Number to convert must be [1..4999]
  ;                4999 is the maximum what can be written without special signs
  ;                or special conventions. 4999=MMMMCMXCIX    
  ; RET.i: Integer Value of Roman Value; If 0, it's not a valid Roman Value
  ; ============================================================================
    
    Protected r, m, m2
    Protected RET.s, sDigit.s
    
    If iValue >0 And iValue <5000 ; 4999 is the maximum with 4xM
      ; Debug Str(iValue) + " - START"
      ; ----------------------------------------------------------------------
      ;  M = 1000, D = 500
      ;  ---------------------------------------------------------------------- 

      m = iValue / #ROM_Num_M
      r = iValue % #ROM_Num_M   ; Rest, Modulo
       
      Select m
        Case 1
          sDigit ="M"
        Case 2
          sDigit ="MM"
        Case 3
          sDigit ="MMM"
        Case 4
          sDigit ="MMMM"
        Default
          sDigit =#Null$
      EndSelect
      
      RET + sDigit
      sDigit = #Null$
      
      m2 = r / #ROM_Num_C
      If m2 = 9
        sDigit = "CM"  ; CM=900
        r = r - (#ROM_Num_M - #ROM_Num_C)   ; the new Rest
      Else
        ; Test for 'D' => can be only one 'D' because it is half of 1000
        m = r / #ROM_Num_D
        If m = 1
          sDigit = "D"
          r = r - #ROM_Num_D    ; the new Rest
        EndIf
      EndIf  
      RET + sDigit
      ; now the maimum Rest is 400=CD
    
      ; ----------------------------------------------------------------------
      ;  C = 100, L = 50
      ;  ---------------------------------------------------------------------- 
      m = r / #ROM_Num_C
      r = r % #ROM_Num_C  ; Rest, Modulo
     
      Select m
         Case 1
          sDigit ="C"
        Case 2
          sDigit ="CC"
        Case 3
          sDigit ="CCC"
        Case 4
          sDigit ="CD"
        Default
          sDigit =#Null$         
      EndSelect
     
      RET + sDigit
      sDigit = #Null$
      
      m2 = r / #ROM_Num_X
      If m2 = 9
        sDigit = "XC" ; CX=90
        r = r - (#ROM_Num_C - #ROM_Num_X)   ; the new Rest 
      Else
        ; Test for 'L' => can be only one 'L' because it is half of 100
        m = r / #ROM_Num_L
        If m = 1
          sDigit = "L"
          r = r - #ROM_Num_L    ; the new Rest
        EndIf
      EndIf
      
      RET + sDigit
      ; now the maimum Rest is 40=XL
     
      ; ----------------------------------------------------------------------
      ;  X = 10, l = 5
      ;  ---------------------------------------------------------------------- 
      
      m = r / #ROM_Num_X
      r = r % #ROM_Num_X  ; Rest, Modulo
      
      Select m
        Case 1
          sDigit ="X"
        Case 2
          sDigit ="XX"
        Case 3
          sDigit ="XXX"
        Case 4
          sDigit ="XL"
        Default
          sDigit =#Null$
      EndSelect
      
      RET + sDigit    
      sDigit = #Null$

      If r = 9
        sDigit = "IX"   ; IX = 9
        r = r - (#ROM_Num_X - #ROM_Num_I)    ; the new Rest
      Else
        ; Test for 'D' => can be only one 'V' because it is half of 10
        m = r / #ROM_Num_V
        If m = 1
          sDigit = "V"
          r = r - #ROM_Num_V     ;  the new Rest
        EndIf
      EndIf  
      
      RET + sDigit 
      ; now the maimum Rest is 4=IV
      
      Select r
        Case 1
          sDigit = "I"
        Case 2   
          sDigit= "II"
        Case 3 
          sDigit= "III"
        Case 4  
          sDigit= "IV"
        Default
         sDigit = #Null$          
      EndSelect
      
      RET + sDigit
     
    Else 
      RET = #Null$
    EndIf
    
    ProcedureReturn RET
  EndProcedure
  
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
  
CompilerEndIf 
; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 65
; FirstLine = 336
; Folding = --
; Optimizer
; CPU = 5
; Compiler = PureBasic 6.00 LTS (Windows - x86)