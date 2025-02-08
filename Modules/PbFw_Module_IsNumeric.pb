; ===========================================================================
;  FILE : Module_IsNumeric.pb
;  NAME : Module IsNUmeric [IsNum::]
;  DESC : Numeric String Functions 
;  DESC : Checks whether a string can be interpreted as a numeric value
;  DESC : It's just a check not a conversion. Generally this functions
;  DESC : are helpful wehen dealing with CSV-Files to dedect the type
;  DESC : of an entry, which is unknown in CSV-Files.
;  DESC :
;  DESC : Each function exists in 2 Version, a standard version, where
;  DESC : the String is copied and a Pointer-Version, which use direct
;  DESC : String-Pointer. The Standard-Version just calls the Pointer-Version
;  DESC : The Pointer-Version is with '_' at the End. 
;  DESC : IsInteger() is the Standard-Version IsInteger_() the Pointer-Version
;  DESC : 
;  DESC : IsBinary()  - checks whether binary interpretation is possible
;  DESC : IsHex()     - checks whether hexadecimal interpretation is possible
;  DESC : IsInteger() - checks whether integer interpretation is possible
;  DESC : IsFloat()   - checks whether floating point interpretation is possible
;  DESC : IsDate()    - checks whether date/time interpretation is possible
;  DESC : IsCurrency()- checks whether currency interpretation is possible
;  DESC : IsPercent() - checks whether percent (%) interpretation is possible
;  DESC : IsNumeric() - a combinated check of IsInteger() and IsFloat()
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/11/13
; VERSION  :  0.5 Developer Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog: 
;{
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"       ; PbFw::   FrameWork control Module
XIncludeFile "PbFw_Module_PB.pb"         ; PB::     Purebasic Extention Module

; XIncludeFile ""

DeclareModule IsNum

  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  
  ; For binary Enumerations we use 'x' as Prefix to see it's a binary
  EnumerationBinary
    #IsNum_xBIN        ; binary
    #IsNum_xHEX        ; Hex
    #IsNum_xINT        ; Integer
    #IsNum_xFLOAT      ; Float
    #IsNum_xCUR        ; Currency
    #IsNum_xDATE       ; Date
  EndEnumeration
  
  Enumeration 1
    #IsNum_AllowPrefix    ; allow a Prefix (for Binary [%] or HEX [$])
    #IsNum_ForcePrefix    ; a Prefix must be used for Binary or HEX otherwise it is an Error
  EndEnumeration
  
  ; over the Prototype Calls the String$ is automatically convertet to *String
  ; with this Methode we generate a ByRef Call of Strings what is faster than 
  ; a ByVal Call what copies the String to Stack. The PB internal String
  ; Functions like ReplaceString() or FindStrin() use simlar system.
  Prototype.i IsBinary(String$, BinPrefix.c='%', UsePrefix=#IsNum_AllowPrefix)
  Global IsBinary.IsBinary    ; define Prototype-Handler for IsBinary
  
  Prototype.i IsHex (String$, HexPrefix.c='$', UsePrefix=#IsNum_AllowPrefix)
  Global IsHex.IsHex          ; define Prototype-Handler for IsHex
  
  Prototype.i IsInteger (String$) 
  Global IsInteger.IsInteger  ; define Prototype-Handler for IsInteger
  
  Prototype.i IsFloat (String$, DecimalChar.c='.')
  Global IsFloat.IsFloat      ; define Prototype-Handler for IsFloat
  
  Prototype.i IsDate (String$) 
  Global IsDate.IsDate        ; define Prototype-Handler for IsDate
  
  Prototype.i IsCurrency (String$, DecimalChar.c=',', TsdChar.c='.', UseTsdChar=#IsNum_AllowPrefix)
  Global IsCurrency.IsCurrency  ; define Prototype-Handler for IsCurrency
  
  Prototype.i IsPercent (String$, DecimalChar.c='.')    
  Global IsPercent.IsPercent    ; define Prototype-Handler for IsPercent
 
  Prototype.i IsNumeric(String$, cDecimalChar.c='.')
  Global IsNumeric.IsNumeric    ; define Prototype-Handler for IsNumeric

EndDeclareModule

Module IsNum
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
    
  ;- ----------------------------------------------------------------------
  ;- Module Private Functions
  ;- ----------------------------------------------------------------------
   
  ;- ----------------------------------------------------------------------
  ;- Module Public Functions as Protytypes
  ;- ---------------------------------------------------------------------- 

  Procedure.i _IsBinary(*String, BinPrefix.c='%', UsePrefix=#IsNum_AllowPrefix)
  ; ============================================================================
  ; NAME: _IsBinary
  ; DESC: checks whether binary interpretation of the String is possible
  ; DESC: [%] [0,1]
  ; VAR(String$): String to test
  ; VAR(BinPrefix.c): Prefix to identify binary numerals; mostly '%' or 'x'
  ; VAR(UsePrefix): #IsNum_AllowPrefix = Prefix can be there 
  ;                 #IsNum_ForcePrefix = Prefix must be there otherwise it is 
  ;                 not a valid Binary
  ;  RET.i: If it is a binary: Number of Digits, otherwise 0
  ; ============================================================================
    
    Protected RET, Digits
    Protected xPrefix, xSpaceAtEnd
    Protected xIsBin = #True
    Protected *pC.PB::pChar     ; Pointer to virtual CHAR-ARRAY
    
    *pC = *String             ; overlay the String with a virtual Char-Array
    If Not *pC                ; If *Pointer to String is #Null
      ProcedureReturn 0       ; ******** NotNumeric => EXIT PROCEDURE *********     
    EndIf
    
    ; Skip Tab and Spaces at beginning    
    While PB::IsSpaceTabChar(*pC\c)
      PB::INCC(*pC)   ; increment CharPointer
    Wend
    
    ; ----------------------------------------------------------------------
    ;  Check for BinPrefix [%]
    ; ----------------------------------------------------------------------    
     
    If UsePrefix = #IsNum_AllowPrefix
      If *pC\c = BinPrefix
        xPrefix =#True
      EndIf
    ElseIf UsePrefix = #IsNum_ForcePrefix
      If *pC\c = BinPrefix
        xPrefix = #True
      Else
        xIsBIN = #False
      EndIf
    EndIf      
    
    If xPrefix    
      PB::INCC(*pC)   ; increment CharPointer
    EndIf

    ; ----------------------------------------------------------------------
    ;  Parse Number - Check for Digits '0' to '1'
    ; ---------------------------------------------------------------------- 
    If xIsBin        ; only if binary is still possible
    
      While *pC\c     
        Select *pC\c
          Case #TAB, PB::#PB_SPACE
            xSpaceAtEnd=#True   ; Space dedected : if it is not in the middle it is ok!
            Break
            
          Case '0', '1'
            Digits + 1          ; count Digits
                        
          Default
            xIsBin = #False
            Break
           
        EndSelect      
        PB::INCC(*pC)   ; increment CharPointer : Attention when leaving While with Break Pointer is not incremented
      Wend      
      ; ----------------------------------------------------------------------
      ;  Skip possible SPACEs at the end
      ; ---------------------------------------------------------------------- 
      If xSpaceAtEnd        
        While *pC\c                  ; if all Chars at end are TABs/SPACEs it is ok f
          If Not PB::IsSpaceTabChar(*pC\c) ; if any other Char follows after the Space, it is not an INT
            xIsBin = #False
          EndIf
          PB::INCC(*pC)   ; increment CharPointer             
        Wend      
      EndIf
      
      If xIsBIN 
        ProcedureReturn Digits      ; if it is a Binary, return the number of Digits
      Else
        ProcedureReturn 0           ; otherwise 0
      EndIf
    EndIf  
  EndProcedure
  IsBinary = @_IsBinary()     ; Bind ProcedureAdress to the PrototypeHandler
  
  Procedure.i _IsHex(*String, HexPrefix.c='$', UsePrefix=#IsNum_AllowPrefix)
  ; ============================================================================
  ; NAME: _IsHex
  ; DESC:
  ; DESC: [$] [0..9, A..F]
  ; VAR(String$): String to test
  ; VAR(HexPrefix.c): Prefix to identify HEX numerals; mostly '$' 
  ; VAR(UsePrefix): #IsNum_AllowPrefix = Prefix can be there 
  ;                 #IsNum_ForcePrefix = Prefix must be there otherwise it is 
  ;                 not a valid Binary
  ; RET.i: If it is a HEX: Number of Digits, otherwise 0
  ; ============================================================================
    
    Protected RET, Digits
    Protected xPrefix, xSpaceAtEnd
    Protected xIsHex = #True
    Protected *pC.PB::pChar       ; Pointer to virtual CHAR-ARRAY
    
    *pC = *String           ; overlay the String with a virtual Char-Array       
    If Not *pC           ; If *Pointer to String is #Null
      ProcedureReturn 0    ; ******** NotNumeric => EXIT PROCEDURE *********     
    EndIf
        
    ; Skip Tab and Spaces at beginning    
    While PB::IsSpaceTabChar(*pC\c)
      PB::INCC(*pC)   ; increment CharPointer
    Wend
    
    ; ----------------------------------------------------------------------
    ;  Check for HexPrefix [$]
    ; ----------------------------------------------------------------------    
    
    If UsePrefix = #IsNum_AllowPrefix
      If *pC\c = HexPrefix
        xPrefix =#True
      EndIf
    ElseIf UsePrefix = #IsNum_ForcePrefix
      If *pC\c = HexPrefix
        xPrefix = #True
      Else
        xIsHex = #False
      EndIf
    EndIf    
    
    If xPrefix    
      PB::INCC(*pC)   ; increment CharPointer
    EndIf

    ; ----------------------------------------------------------------------
    ;  Parse Number - Check for Digits '0' to '9' AND 'A' to 'F'
    ; ---------------------------------------------------------------------- 
    If xIsHex        ; only if binary is still possible
    
      While *pC\c
        Select *pC\c
          Case #TAB, PB::#PB_SPACE
            xSpaceAtEnd=#True   ; TAB, Space dedected : if it is not in the middle it is ok!
            Break
            
          Case '0' To '9', 'A' To 'F'
            Digits + 1          ; count Digits
                        
          Default
            xIsHex = #False
            Break          
        EndSelect      
        PB::INCC(*pC)   ; increment CharPointer
      Wend
      
      ; ----------------------------------------------------------------------
      ;  Skip possible SPACEs at the end
      ; ---------------------------------------------------------------------- 
      If xIsHex And xSpaceAtEnd             
        While *pC\c                         ; if all Chars at end are Spaces it is ok 
          If Not PB::IsSpaceTabChar(*pC\c)  ; if any other Char follows after the Space, it is not an INT
            xIsHex = #False
          EndIf
          PB::INCC(*pC)   ; increment CharPointer
        Wend      
      EndIf
          
      If xIsHex
        ProcedureReturn Digits      ; if it is a HEX, return the number of Digits
      Else
        ProcedureReturn 0           ; otherwise 0
      EndIf
    EndIf
  EndProcedure
  IsHex = @_IsHex()     ; Bind ProcedureAdress to the PrototypeHandler
  
  Procedure.i _IsInteger(*String)
  ; ============================================================================
  ; NAME: _IsInteger
  ; DESC: [+,-] [0..9]
  ; VAR(String$): String to test
  ; RET.i: If it is an Integer: Number of Digits, otherwise 0
  ; ============================================================================
    
    Protected RET, Digits
    Protected xSign, xNegativ, xSpaceAtEnd
    Protected xIsINT = #True
    Protected *pC.PB::pChar   ; Pointer to virtual CHAR-ARRAY
    
    *pC = *String          ; overlay the String with a virtual Char-Array        
    If Not *pC            ; If *Pointer to String is #Null
      ProcedureReturn 0     ; ******** NotNumeric => EXIT PROCEDURE *********     
    EndIf
    
    ; Skip Tab and Spaces at beginning    
    While PB::IsSpaceTabChar(*pC\c)
      PB::INCC(*pC)   ; increment CharPointer
    Wend

    ; ----------------------------------------------------------------------
    ;  Check for '+', '-' 
    ; ----------------------------------------------------------------------    
    If *pC\c ='+'
      xSign = #True  
    ElseIf *pC\c ='-'
      xSign = #True 
      xNegativ = #True          
    EndIf
    
    If xSign    
      PB::INCC(*pC)   ; increment CharPointer
    EndIf
   
    ; ----------------------------------------------------------------------
    ;  Parse Number - Check for Digits '0' to '9'
    ; ---------------------------------------------------------------------- 
    While *pC\c    
      Select *pC\c
          
        Case #TAB, PB::#PB_SPACE
          xSpaceAtEnd=#True   ; Space dedected : if it is not in the middle it is ok!
          Break
          
        Case '0' To '9'
          Digits + 1          ; count Digits
                    
        Default               ; any other Char is not allowed in an Integer
          xIsINT = #False      ; Is not an Integer
          Break
         
     EndSelect      
     PB::INCC(*pC)   ; increment CharPointer   
   Wend
   
    ; ----------------------------------------------------------------------
    ;  Skip possible SPACEs at the end
    ; ---------------------------------------------------------------------- 
    If xIsINT And xSpaceAtEnd
      While *pC\c       ; if all Chars at end are Spaces it is ok 
        If Not PB::IsSpaceTabChar(*pC\c) ; if any other Char follows after the Space, it is not an INT
          xIsINT = #False
          Break
        EndIf
        PB::INCC(*pC)   ; increment CharPointer   
      Wend      
    EndIf
    
    If xIsINT 
      ProcedureReturn Digits      ; if it is an Integer, return the number of Digits
    Else
      ProcedureReturn 0           ; otherwise 0
    EndIf   
  EndProcedure
  IsInteger = @_IsInteger()     ; Bind ProcedureAdress to the PrototypeHandler
  
  Procedure.i _IsFloat(*String, DecimalChar.c='.')
  ; ============================================================================
  ; NAME: _IsFloat
  ; DESC:
  ; DESC:   [+,-] [0..9] [.] [0..9] [e,E][+,-] [0..9]
  ; VAR(String$): String to test
  ; RET.i: If it is an Integer: Number of Digits, otherwise 0
  ; ============================================================================
    
    Protected RET, Digits, ExpDigits
    Protected xSign, xNegativ, xDecimal, xSpaceAtEnd, xExp, xExpNegative
    Protected xIsFloat = #True
    Protected *pC.PB::pChar       ; Pointer to virtual CHAR-ARRAY
    
    *pC = *String         ; overlay the String with a virtual Char-Array
    If Not *pC            ; If *Pointer to String is #Null
      ProcedureReturn 0     ; ******** NotNumeric => EXIT PROCEDURE *********     
    EndIf
    
    ; Skip Tab and Spaces at beginning    
    While PB::IsSpaceTabChar(*pC\c)
      PB::INCC(*pC)   ; increment CharPointer
    Wend

    ; ----------------------------------------------------------------------
    ;  Check for '+', '-' 
    ; ----------------------------------------------------------------------    
    If *pC\c ='+'
      xSign = #True  
    ElseIf *pC\c ='-'
      xSign = #True 
      xNegativ = #True          
    EndIf
    
    If xSign    
      PB::INCC(*pC)   ; increment CharPointer
    EndIf
    
    ; ----------------------------------------------------------------------
    ;  Parse Number
    ; ---------------------------------------------------------------------- 
    While *pC\c      
      Select *pC\c
          
        Case #TAB, PB::#PB_SPACE              ; Tab or Space
          xSpaceAtEnd=#True     ; Space dedected : if it is not in the middle it is ok!
          Break
          
        Case '0' To '9'
          Digits + 1          ; count Digits
        
        Case DecimalChar
          If Not xDecimal     ; if first Decimal Char in Number
            xDecimal = #True 
          Else                ; Decimal Char found twice
            xIsFloat = #False
            Break
          EndIf
          
        Case 'e', 'E'
          ; Check if E follows a '+' or '-'
          If *pC\cc[1] = '-'
            xExpNegative = #True
            xExp =#True
            PB::INCC(*pC)   ; increment CharPointer
          ElseIf *pC\cc[1] = '+'
            xExp =#True
            PB::INCC(*pC)   ; increment CharPointer
          Else
            xIsFloat =#False
            Break
          EndIf
          
        Default                 ; any other Char is not allowed in an Integer
          xIsFloat = #False      ; Is not an Integer
          Break      
     EndSelect      
     PB::INCC(*pC)   ; increment CharPointer
    Wend   
    ; ----------------------------------------------------------------------
    ;  Parse Exponent
    ; ---------------------------------------------------------------------- 
    If xExp And xIsFloat
      While *pC\c
        Select *pC\c
          Case #TAB, PB::#PB_SPACE
            xSpaceAtEnd=#True     ; Space dedected : if it is not in the middle it is ok!
            Break        
          Case '0' To '9'
            ExpDigits + 1  
          Default
            xIsFloat = #False  
            Break
        EndSelect       
        PB::INCC(*pC)   ; increment CharPointer
      Wend         
    EndIf
    
    ; if Exponent-Length = 0 and 'e' or 'E' was detected
    If ExpDigits = 0 And xExp
      xIsFloat = #False
    EndIf   
    ; ----------------------------------------------------------------------
    ;  Skip possible SPACEs at the end
    ; ---------------------------------------------------------------------- 
    If xSpaceAtEnd And xIsFloat
      While *pC\c       ; if all Chars at end are Spaces it is ok for an Integer
        If Not PB::IsSpaceTabChar(*pC\c) ; If any other Char follows after the Space, it is nov valid
          xIsFloat = #False
          Break
        EndIf
        PB::INCC(*pC)   ; increment CharPointer      
      Wend      
    EndIf
    
    If xIsFloat 
      ProcedureReturn Digits      ; if it is a Float, return the number of Digits without Decimal-Point
    Else
      ProcedureReturn 0           ; otherwise 0
    EndIf   
  EndProcedure 
  IsFloat = @_IsFloat()     ; Bind ProcedureAdress to the PrototypeHandler
    
  Procedure.i _IsDate(*String)
  ; ============================================================================
  ; NAME: _IsDate
  ; DESC:
  ; VAR(String$): String to test
  ; RET.i: If it is a possible Date: Number of Digits, otherwise 0
  ; ============================================================================
    
    ; !!! under development !!!
    
    Protected RET, Digits
    Protected xSpaceAtEnd
    Protected xYear, xMonth, xDay, xHour, xMin, xSec, xMilliSec
    Protected IsDate = #True
    Protected *pC.PB::pChar   ; Pointer to virtual CHAR-ARRAY
    
    *pC = *String          ; overlay the String with a virtual Char-Array        
    If Not *pC            ; If *Pointer to String is #Null
      ProcedureReturn 0     ; ******** NotNumeric => EXIT PROCEDURE *********     
    EndIf
    
    ; Skip Tab and Spaces at beginning    
    While PB::IsSpaceTabChar(*pC\c)
      PB::INCC(*pC)   ; increment CharPointer
    Wend
    ; ----------------------------------------------------------------------
    ;  Parse Number
    ; ---------------------------------------------------------------------- 
    While *pC\c    
      Select *pC\c
          
        Case 6, 32
          xSpaceAtEnd=#True     ; Space dedected : if it is not in the middle it is ok!
          Break
          
        Case '0' To '9'
          Digits + 1          ; count Digits
        
        Case '/', '.'
          
        Case ':'
          
        Default                 ; any other Char is not allowed in an Integer
          IsDate = #False      ; Is not an Integer
          Break
         
     EndSelect      
     PB::INCC(*pC)   ; increment CharPointer
    Wend
    ; ----------------------------------------------------------------------
    ;  Skip possible SPACEs at the end
    ; ---------------------------------------------------------------------- 
    If IsDate And xSpaceAtEnd And IsDate
      While *pC\c       ; if all Chars at end are TABs, Spaces it is ok
        If Not PB::IsSpaceTabChar(*pC\c) ; If any other Char follows after the Space, it is nov valid
          IsDate = #False
          Break
        EndIf
        PB::INCC(*pC)   ; increment CharPointer
      Wend      
    EndIf
    
    If IsDate
      ProcedureReturn Digits      ; if it is a Float, return the number of Digits without Decimal-Point
    Else
      ProcedureReturn 0           ; otherwise 0
    EndIf 
  EndProcedure
  IsDate = @_IsDate()     ; Bind ProcedureAdress to the PrototypeHandler
  
  Procedure.i _IsCurrency(*String, DecimalChar.c=',', TsdChar.c='.', UseTsdChar=#IsNum_AllowPrefix)
  ; ============================================================================
  ; NAME: _IsCurrency
  ; DESC:
  ; DESC: [+,-] [0..9][.] [0..9][.] .. [,][0..9, .-][EUR, $, €, ...]
  ; VAR(String$): String to test
  ; RET.i: If it is a possible Currency: Number of Digits, otherwise 0
  ; ============================================================================
    
    ; !!! under development !!!

    Protected RET, Digits
    Protected xSign, xNegativ, xDecimal, xSpaceAtEnd
    Protected xIsCur = #True
    Protected *pC.PB::pChar   ; Pointer to virtual CHAR-ARRAY
    
    *pC = *String          ; overlay the String with a virtual Char-Array        
    If Not *pC            ; If *Pointer to String is #Null
      ProcedureReturn 0     ; ******** NotNumeric => EXIT PROCEDURE *********     
    EndIf
        
    ; Skip Tab and Spaces at beginning    
    While PB::IsSpaceTabChar(*pC\c)
      PB::INCC(*pC)   ; increment CharPointer
    Wend
    
    ; ----------------------------------------------------------------------
    ;  Check for '+', '-' 
    ; ----------------------------------------------------------------------    
    If *pC\c ='+'
      xSign = #True  
    ElseIf *pC\c ='-'
      xSign = #True 
      xNegativ = #True          
    EndIf
    
    If xSign    
      PB::INCC(*pC)   ; increment CharPointer
    EndIf
    
    ; ----------------------------------------------------------------------
    ;  Parse Number
    ; ---------------------------------------------------------------------- 
    While *pC\c  
      Select *pC\c         
          
        Case #TAB, PB::#PB_SPACE
          xSpaceAtEnd=#True     ; Space dedected : if it is not in the middle it is ok!
          Break
          
        Case '0' To '9'
          Digits + 1          ; count Digits
        
        Case DecimalChar
          If Not xDecimal     ; if first Decimal Char in Number
            xDecimal = #True 
          Else                ; Decimal Char found twice
            xIsCur = #False
            Break
          EndIf
          
        Case TsdChar
          
        Default                 ; any other Char is not allowed in an Integer
          xIsCur = #False      ; Is not an Integer
          Break
         
      EndSelect      
      PB::INCC(*pC)   ; increment CharPointer
    Wend   
    ; ----------------------------------------------------------------------
    ;  Skip possible SPACEs at the end
    ; ---------------------------------------------------------------------- 
    If xIsCur And xSpaceAtEnd And xIsCur
      While *pC\c       ; if all Chars at end are Spaces it is ok for an Integer
        If Not PB::IsSpaceTabChar(*pC\c) ; if any other Char follows after the Space, it is not valid
          xIsCur = #False
          Break
        EndIf
        PB::INCC(*pC)   ; increment CharPointer
      Wend      
    EndIf
    
    If xIsCur
      ProcedureReturn Digits      ; if it is a Float, return the number of Digits without Decimal-Point
    Else
      ProcedureReturn 0           ; otherwise 0
    EndIf   
  EndProcedure
  IsCurrency = @_IsCurrency()     ; Bind ProcedureAdress to the PrototypeHandler
   
  Procedure.i _IsPercent(*String, DecimalChar.c='.')
  ; ============================================================================
  ; NAME: _IsPercent
  ; DESC: Check whether percent (%) interpretation is possible
  ; DESC: [+,-] [0..9] [.] [0..9] [%]
  ; VAR(String$): String to test
  ; RET.i: If it is a possible Percent Value: Number of Digits, otherwise 0
  ; ============================================================================
    Protected I, RET, Digits, c.c
    Protected xSign, xNegativ, xSpaceAtEnd
    Protected xIsPercent = #True, xPercentChar
    Protected *pC.PB::pChar   ; Pointer to virtual CHAR-ARRAY
    
    *pC = *String          ; overlay the String with a virtual Char-Array        
    If Not *pC            ; If *Pointer to String is #Null
      ProcedureReturn 0     ; ******** NotNumeric => EXIT PROCEDURE *********     
    EndIf
    
   ; Skip Tab and Spaces at beginning    
    While PB::IsSpaceTabChar(*pC\c)
      PB::INCC(*pC)   ; increment CharPointer
    Wend
    
    ; ----------------------------------------------------------------------
    ;  Check for '+', '-' 
    ; ----------------------------------------------------------------------    
    If *pC\c ='+'
      xSign = #True  
    ElseIf *pC\c ='-'
      xSign = #True 
      xNegativ = #True          
    EndIf
    
    If xSign    
      PB::INCC(*pC)   ; increment CharPointer
    EndIf
    
    ; ----------------------------------------------------------------------
    ;  Parse Number
    ; ---------------------------------------------------------------------- 
    While *pC\c    
      Select *pC\c
          
        Case #TAB, PB::#PB_SPACE              ; TAB, Space
          xSpaceAtEnd=#True     ; Space dedected : if it is not in the middle it is ok!
          Break
          
        Case '0' To '9'
          Digits + 1            ; count Digits
        
        Case DecimalChar
          If Not xIsPercent      ; if first Decimal Char in Number
            xIsPercent = #True 
          Else                  ; Decimal Char found twice
            xIsPercent = #False
            Break
          EndIf
          
        Case '%'
          xPercentChar = #True  ; '%' found
          xSpaceAtEnd=#True     ; check Space at END : if it is not in the middle it is ok!
          Break
          
        Default                 ; any other Char is not allowed in an Integer
          xIsPercent = #False    ; Is not an Percent-Value
          Break
         
     EndSelect      
     PB::INCC(*pC)   ; increment CharPointer
    Wend   
    ; ----------------------------------------------------------------------
    ;  Skip possible SPACEs at the end
    ; ---------------------------------------------------------------------- 
    If xIsPercent And xSpaceAtEnd      ; if we left While with break and have to detect End-Spaces
      PB::INCC(*pC)   ; increment CharPointer
      If Not xPercentChar       ; % must be detected, we allow 1Space after the Number
        If  *pC\c ='%'   
          xPercentChar =#True   ;'%'found
          PB::INCC(*pC)   ; increment CharPointer
        EndIf
      EndIf 
      
      While *pC\cc          ; if all Chars at end are Spaces it is ok 
        If Not PB::IsSpaceTabChar(*pC\c) ; if any other Char follows after the Space, it is not valid
          xIsPercent = #False
          Break
        EndIf
        I + 1
      Wend      
    EndIf
    
    If xIsPercent And xPercentChar
      ProcedureReturn Digits      ; if it is an Integer, return the number of Digits
    Else
      ProcedureReturn 0           ; otherwise 0
    EndIf    
  EndProcedure
  IsPercent = @_IsPercent()     ; Bind ProcedureAdress to the PrototypeHandler
  
  Procedure.i _IsNumeric(*String, cDecimalChar.c='.')
  ; ============================================================================
  ; NAME: _IsNumeric
  ; DESC: 
  ; DESC: 
  ; VAR(String$): String to test
  ; RET.i: If it is a possible numeric value: Number of Digits, otherwise 0
  ; ============================================================================
    Protected RET
    Protected IntDigits   
    Protected FloatDigits 
    
    IntDigits = _IsInteger(*String)
    FloatDigits = _IsFloat(*String, cDecimalChar)
    
    If IntDigits : RET | #IsNum_xINT : EndIf
    If FloatDigits : RET | #IsNum_xFLOAT : EndIf

    ProcedureReturn RET
  EndProcedure
  IsNumeric = @_IsNumeric()     ; Bind ProcedureAdress to the PrototypeHandler
  
  ;- ----------------------------------------------------------------------
  ;- Module Public Functions
  ;- ----------------------------------------------------------------------

EndModule

 CompilerIf #PB_Compiler_IsMainFile
 ; ----------------------------------------------------------------------
 ;  M O D U L E   T E S T   C O D E
 ; ---------------------------------------------------------------------- 
 
  EnableExplicit
  UseModule IsNUM
 
  Procedure.s check(sText.s, DecChar='.', HexPrefix.c=#Null, BinPrefix=#Null)
    Protected NumType, RET.s
    
    ; NumType = IsNumeric(sText, DecChar, HexPrefix, BinPrefix)
    NumType = IsNumeric(sText)
  
    sText = "'" + sText +"'"
    sText = sText + Space(20-Len(sText)) + #TAB$ 
    
    If NumType
      If NumType & #IsNum_xINT
        Ret = "IsINT : "
      EndIf
      
      If NumType & #IsNum_xBIN
        RET = RET + "IsBin : "
      EndIf
      
      If NumType & #IsNum_xHEX
        Ret = RET + "IsHEX : "
      EndIf
      
      If NumType & #IsNum_xFLOAT
        Ret = RET + "IsFloat : "
      EndIf
  
      RET = sText + " :  " + RET 
    Else
      RET = sText + "  : Not Numeric : " 
    EndIf
    
    ProcedureReturn RET
  EndProcedure
    
  Procedure.s dbg (Digits, sText.s, NumType)
    Protected txt.s, RET.s, res.s
 
    sText = "'" + sText +"'"
    sText = sText + Space(25-Len(sText)) + #TAB$ + #TAB$
    
    If Digits 
      res = " = TRUE"
    Else
      res = " = FALSE"      
    EndIf
    
      
    Select NumType
      Case #IsNum_xBIN
        txt = "IsBin"
        
      Case #IsNum_xHEX
        txt = "IsHex"
       
      Case #IsNum_xINT
       txt = "IsInt"
        
      Case #IsNum_xFLOAT
        txt = "IsHex"
        
      Default
        txt = "NoType"
       
    EndSelect   
        
    RET = sText +  " :  " + txt + res 
    
    If Digits
      RET = RET + "  :  Digits = " + Str(Digits)
    EndIf
    
    Debug RET
  EndProcedure
  
  Debug check("-234.0")
    
CompilerEndIf 
; IDE Options = PureBasic 6.20 Beta 4 (Windows - x64)
; CursorPosition = 741
; FirstLine = 684
; Folding = ---
; Markers = 99
; Optimizer
; CPU = 5