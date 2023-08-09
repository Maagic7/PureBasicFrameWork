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

XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module

; XIncludeFile ""

DeclareModule IsNum

  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  
  ; For binary Enumerations we use 'x' as Prefix to see it's a binary
  EnumerationBinary
    #PbfW_IsNum_xBIN        ; binary
    #PbfW_IsNum_xHEX        ; Hex
    #PbfW_IsNum_xINT        ; Integer
    #PbfW_IsNum_xFLOAT      ; Float
    #PbfW_IsNum_xCUR        ; Currency
    #PbfW_IsNum_xDATE       ; Date
  EndEnumeration
  
  Enumeration 1
    #PbfW_IsNum_AllowPrefix    ; allow a Prefix (for Binary [%] or HEX [$])
    #PbfW_IsNum_ForcePrefix    ; a Prefix must be used for Binary or HEX otherwise it is an Error
  EndEnumeration
  
  ; over the Prototype Calls the String$ is automatically convertet to *String
  ; with this Methode we generate a ByRef Call of Strings what is faster than 
  ; a ByVal Call what copies the String to Stack. The PB internal String
  ; Functions like ReplaceString() or FindStrin() use simlar system.
  Prototype.i IsBinary(String$, BinPrefix.c='%', UsePrefix=#PbfW_IsNum_AllowPrefix)
  Global IsBinary.IsBinary    ; define Prototype-Handler for IsBinary
  
  Prototype.i IsHex (String$, HexPrefix.c='$', UsePrefix=#PbfW_IsNum_AllowPrefix)
  Global IsHex.IsHex          ; define Prototype-Handler for IsHex
  
  Prototype.i IsInteger (String$) 
  Global IsInteger.IsInteger  ; define Prototype-Handler for IsInteger
  
  Prototype.i IsFloat (String$, DecimalChar.c='.')
  Global IsFloat.IsFloat      ; define Prototype-Handler for IsFloat
  
  Prototype.i IsDate (String$) 
  Global IsDate.IsDate        ; define Prototype-Handler for IsDate
  
  Prototype.i IsCurrency (String$, DecimalChar.c=',', TsdChar.c='.', UseTsdChar=#PbfW_IsNum_AllowPrefix)
  Global IsCurrency.IsCurrency  ; define Prototype-Handler for IsCurrency
  
  Prototype.i IsPercent (String$, DecimalChar.c='.')    
  Global IsPercent.IsPercent    ; define Prototype-Handler for IsPercent
 
  Prototype.i IsNumeric(String$, cDecimalChar.c='.')
  Global IsNumeric.IsNumeric    ; define Prototype-Handler for IsNumeric

EndDeclareModule

Module IsNum
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  #PbfW_IsNum_SPACE = ' '  ; Constant for a single SPACE
  
  Structure pChar   ; virtual CHAR-ARRAY, used as Pointer to overlay on strings 
    c.c[0]          ; fixed ARRAY Of CHAR Length 0
  EndStructure

  ;- ----------------------------------------------------------------------
  ;- Module Private Functions
  ;- ----------------------------------------------------------------------
    
  ;- ----------------------------------------------------------------------
  ;- Module Public Functions as Protytypes
  ;- ---------------------------------------------------------------------- 

  Procedure.i _IsBinary(*String, BinPrefix.c='%', UsePrefix=#PbfW_IsNum_AllowPrefix)
  ; ============================================================================
  ; NAME: _IsBinary
  ; DESC: checks whether binary interpretation of the String is possible
  ; DESC: [%] [0,1]
  ; VAR(String$): String to test
  ; VAR(BinPrefix.c): Prefix to identify binary numerals; mostly '%' or 'x'
  ; VAR(UsePrefix): #PbfW_IsNum_AllowPrefix = Prefix can be there 
  ;                 #PbfW_IsNum_ForcePrefix = Prefix must be there otherwise it is 
  ;                 not a valid Binary
  ;  RET.i: If it is a binary: Number of Digits, otherwise 0
  ; ============================================================================
    
    Protected I, RET, Digits, c.c
    Protected xPrefix, xSpaceAtEnd
    Protected IsBin = #True
    Protected *char.pChar     ; Pointer to virtual CHAR-ARRAY
    
    *char = *String             ; overlay the String with a virtual Char-Array
    If Not *char              ; If *Pointer to String is #Null
      ProcedureReturn 0       ; ******** NotNumeric => EXIT PROCEDURE *********     
    EndIf
    
    I = 0   
    ; Skip Spaces at beginning
    While *char\c[I]= #PbfW_IsNum_SPACE
      I + 1
    Wend    
    ; ----------------------------------------------------------------------
    ;  Check for BinPrefix [%]
    ; ----------------------------------------------------------------------    
    c=*char\c[I]
    
    If UsePrefix = #PbfW_IsNum_AllowPrefix
      If c = BinPrefix
        xPrefix =#True
      EndIf
    ElseIf UsePrefix = #PbfW_IsNum_ForcePrefix
      If c = BinPrefix
        xPrefix = #True
      Else
        IsBIN = #False
      EndIf
    EndIf      
    ; ----------------------------------------------------------------------
    ;  Parse Number - Check for Digits '0' to '1'
    ; ---------------------------------------------------------------------- 
    If IsBin        ; only if binary is still possible
    
      While *char\c[I]       
        Select *char\c[I]
          Case #PbfW_IsNum_SPACE
            xSpaceAtEnd=#True   ; Space dedected : if it is not in the middle it is ok!
          Break
            
          Case '0', '1'
            Digits + 1          ; count Digits
                        
          Default
            IsBin = #False
            Break
           
       EndSelect      
        I + 1         ; Attention if we leave with Break, I is not inkremented
      Wend      
      ; ----------------------------------------------------------------------
      ;  Skip possible SPACEs at the end
      ; ---------------------------------------------------------------------- 
      If xSpaceAtEnd
        I + 1           
        While *char\c[I]                  ; if all Chars at end are Spaces it is ok for an Integer
          If *char\c[I] <> #PbfW_IsNum_SPACE   ; if any other Char follows after the Space, it is not an INT
            IsBin = #False
          EndIf
          I + 1       
        Wend      
      EndIf
      
      If IsBIN 
        ProcedureReturn Digits      ; if it is a Binary, return the number of Digits
      Else
        ProcedureReturn 0           ; otherwise 0
      EndIf
    EndIf  
  EndProcedure
  IsBinary = @_IsBinary()     ; Bind ProcedureAdress to the PrototypeHandler
  
  Procedure.i _IsHex(*String, HexPrefix.c='$', UsePrefix=#PbfW_IsNum_AllowPrefix)
  ; ============================================================================
  ; NAME: _IsHex
  ; DESC:
  ; DESC: [$] [0..9, A..F]
  ; VAR(String$): String to test
  ; VAR(HexPrefix.c): Prefix to identify HEX numerals; mostly '$' 
  ; VAR(UsePrefix): #PbfW_IsNum_AllowPrefix = Prefix can be there 
  ;                 #PbfW_IsNum_ForcePrefix = Prefix must be there otherwise it is 
  ;                 not a valid Binary
  ; RET.i: If it is a HEX: Number of Digits, otherwise 0
  ; ============================================================================
    
    Protected I, RET, Digits, c.c
    Protected xPrefix, xSpaceAtEnd
    Protected IsHex = #True
    Protected *char.pChar       ; Pointer to virtual CHAR-ARRAY
    
    *char = *String           ; overlay the String with a virtual Char-Array       
    If Not *char           ; If *Pointer to String is #Null
      ProcedureReturn 0    ; ******** NotNumeric => EXIT PROCEDURE *********     
    EndIf
    
    I = 0
    
    ; Skip Spaces at beginning
    While *char\c[I]= #PbfW_IsNum_SPACE
      I + 1
    Wend   
    ; ----------------------------------------------------------------------
    ;  Check for HexPrefix [$]
    ; ----------------------------------------------------------------------    
    c=*char\c[I]
    
    If UsePrefix = #PbfW_IsNum_AllowPrefix
      If c = HexPrefix
        xPrefix =#True
      EndIf
    ElseIf UsePrefix = #PbfW_IsNum_ForcePrefix
      If c = HexPrefix
        xPrefix = #True
      Else
        IsHex = #False
      EndIf
    EndIf    
    If xPrefix : I+1 : EndIf   
    
    ; ----------------------------------------------------------------------
    ;  Parse Number - Check for Digits '0' to '9' AND 'A' to 'F'
    ; ---------------------------------------------------------------------- 
    If IsHex        ; only if binary is still possible
    
      While *char\c[I]
        Select *char\c[I]
          Case #PbfW_IsNum_SPACE
            xSpaceAtEnd=#True   ; Space dedected : if it is not in the middle it is ok!
            Break
            
          Case '0' To '9', 'A' To 'F'
            Digits + 1          ; count Digits
                        
          Default
            IsHex = #False
            Break
           
        EndSelect      
        I + 1           ; Attention if we leave with Break, I is not inkremented
      Wend
      
      ; ----------------------------------------------------------------------
      ;  Skip possible SPACEs at the end
      ; ---------------------------------------------------------------------- 
      If IsHex And xSpaceAtEnd
        I + 1           
        While *char\c[I]                  ; if all Chars at end are Spaces it is ok for an Integer
          If *char\c[I] <> #PbfW_IsNum_SPACE   ; if any other Char follows after the Space, it is not an INT
            IsHex = #False
          EndIf
          I + 1
        Wend      
      EndIf
          
      If IsHex
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
    
    Protected I, RET, Digits, c.c
    Protected xSign, xNegativ, xSpaceAtEnd
    Protected IsInt = #True
    Protected *char.pChar   ; Pointer to virtual CHAR-ARRAY
    
    *char = *String          ; overlay the String with a virtual Char-Array        
    If Not *char            ; If *Pointer to String is #Null
      ProcedureReturn 0     ; ******** NotNumeric => EXIT PROCEDURE *********     
    EndIf
    
    I = 0   
    ; ----------------------------------------------------------------------
    ;  Check for '+', '-' and skip Spaces
    ; ---------------------------------------------------------------------- 
    While *char\c[I]      
      Select *char\c[I]
        Case #PbfW_IsNum_SPACE
          ; Skip leading Spaces! Do nothing!
        Case '+'
          xSign = #True
          
        Case '-'
          xSign = #True
          xNegativ = #True          
          Break
          
        Default
         Break         
     EndSelect      
      I + 1     ; if we leave with Break, I is not inkremented
    Wend   
    ; ----------------------------------------------------------------------
    ;  Parse Number - Check for Digits '0' to '9'
    ; ---------------------------------------------------------------------- 
    While *char\c[I]     
      Select *char\c[I]
          
        Case #PbfW_IsNum_SPACE
          xSpaceAtEnd=#True   ; Space dedected : if it is not in the middle it is ok!
          Break
          
        Case '0' To '9'
          Digits + 1          ; count Digits
                    
        Default               ; any other Char is not allowed in an Integer
          IsINT = #False      ; Is not an Integer
          Break
         
     EndSelect      
        I + 1                 ; Attention if we leave with break, I is not inkremented
    Wend   
    ; ----------------------------------------------------------------------
    ;  Skip possible SPACEs at the end
    ; ---------------------------------------------------------------------- 
    If IsINT And xSpaceAtEnd
      I + 1           
      While *char\c[I]       ; if all Chars at end are Spaces it is ok 
        If *char\c[I] <> #PbfW_IsNum_SPACE ; if any other Char follows after the Space, it is not an INT
          IsINT = #False
        EndIf
        I + 1
      Wend      
    EndIf
    
    If IsInt 
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
    
    Protected I, RET, Digits, ExpDigits, c.c
    Protected xSign, xNegativ, xDecimal, xSpaceAtEnd, xExp, xExpNegative
    Protected IsFloat = #True
    Protected *char.pChar       ; Pointer to virtual CHAR-ARRAY
    
    *char = *String         ; overlay the String with a virtual Char-Array
    If Not *char            ; If *Pointer to String is #Null
      ProcedureReturn 0     ; ******** NotNumeric => EXIT PROCEDURE *********     
    EndIf
    
    I = 0   
    ; ----------------------------------------------------------------------
    ;  Check for '+', '-' and skip Spaces
    ; ---------------------------------------------------------------------- 
    While *char\c[I]      
      Select *char\c[I]
        Case #PbfW_IsNum_SPACE
          ; Skip leading Spaces! Do nothing!         
        Case '+'
          xSign = #True
          Break
          
        Case '-'
          xSign = #True
          xNegativ = #True          
          Break
          
        Default
          Break        
     EndSelect      
      I + 1     ; 
    Wend  
    If xSign : I+1 : EndIf  
    
    ; ----------------------------------------------------------------------
    ;  Parse Number
    ; ---------------------------------------------------------------------- 
    While *char\c[I]      
      Select *char\c[I]
          
        Case #PbfW_IsNum_SPACE
          xSpaceAtEnd=#True     ; Space dedected : if it is not in the middle it is ok!
          Break
          
        Case '0' To '9'
          Digits + 1          ; count Digits
        
        Case DecimalChar
          If Not xDecimal     ; if first Decimal Char in Number
            xDecimal = #True 
          Else                ; Decimal Char found twice
            IsFloat = #False
            Break
          EndIf
          
        Case 'e', 'E'
          ; Check if E follows a '+' or '-'
          If *char\c[I+1] = '-'
            xExpNegative = #True
            xExp =#True
            I + 1                   ; set Index to Next Char because '-' is ok
          ElseIf *char\c[I+1] = '+'
            xExp =#True
            I + 1                   ; set Index to Next Char because '+' is ok
          Else
            IsFloat =#False
            Break
          EndIf
          
        Default                 ; any other Char is not allowed in an Integer
          IsFloat = #False      ; Is not an Integer
          Break
         
     EndSelect      
        I + 1                   ; Attention if we leave with break, I is not inkremented
    Wend   
    ; ----------------------------------------------------------------------
    ;  Parse Exponent
    ; ---------------------------------------------------------------------- 
    If xExp And IsFloat
      While *char\c[I]
        Select *char\c[I]
          Case #PbfW_IsNum_SPACE
            xSpaceAtEnd=#True     ; Space dedected : if it is not in the middle it is ok!
            Break        
          Case '0' To '9'
            ExpDigits + 1  
          Default
            IsFloat = #False  
            Break
        EndSelect       
      Wend         
    EndIf
    
    ; if Exponent-Length = 0 and 'e' or 'E' was detected
    If ExpDigits = 0 And xExp
      IsFloat = #False
    EndIf   
    ; ----------------------------------------------------------------------
    ;  Skip possible SPACEs at the end
    ; ---------------------------------------------------------------------- 
    If xSpaceAtEnd And IsFloat
      I + 1           
      While *char\c[I]       ; if all Chars at end are Spaces it is ok for an Integer
        If *char\c[I] <> #PbfW_IsNum_SPACE ; if any other Char follows after the Space, it is not an INT
          IsFloat = #False
        EndIf
        I + 1
      Wend      
    EndIf
    
    If IsFloat 
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
    
    Protected I, RET, Digits, c.c
    Protected xSpaceAtEnd
    Protected xYear, xMonth, xDay, xHour, xMin, xSec, xMilliSec
    Protected IsDate = #True
    Protected *char.pChar   ; Pointer to virtual CHAR-ARRAY
    
    *char = *String          ; overlay the String with a virtual Char-Array        
    If Not *char            ; If *Pointer to String is #Null
      ProcedureReturn 0     ; ******** NotNumeric => EXIT PROCEDURE *********     
    EndIf
    
    I = 0    
    ; Skip leading Spaces
    While *char\c[I]= #PbfW_IsNum_SPACE
      I + 1
    Wend
    ; ----------------------------------------------------------------------
    ;  Parse Number
    ; ---------------------------------------------------------------------- 
    While *char\c[I]     
      Select *char\c[I]
          
        Case #PbfW_IsNum_SPACE
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
        I + 1                   ; Attention if we leave with break, I is not inkremented
    Wend
    ; ----------------------------------------------------------------------
    ;  Skip possible SPACEs at the end
    ; ---------------------------------------------------------------------- 
    If IsDate And xSpaceAtEnd And IsDate
      I + 1           
      While *char\c[I]       ; if all Chars at end are Spaces it is ok for an Integer
        If *char\c[I] <> #PbfW_IsNum_SPACE ; if any other Char follows after the Space, it is not an INT
          IsDate = #False
        EndIf
        I + 1
      Wend      
    EndIf
    
    If IsDate
      ProcedureReturn Digits      ; if it is a Float, return the number of Digits without Decimal-Point
    Else
      ProcedureReturn 0           ; otherwise 0
    EndIf 
  EndProcedure
  IsDate = @_IsDate()     ; Bind ProcedureAdress to the PrototypeHandler
  
  Procedure.i _IsCurrency(*String, DecimalChar.c=',', TsdChar.c='.', UseTsdChar=#PbfW_IsNum_AllowPrefix)
  ; ============================================================================
  ; NAME: _IsCurrency
  ; DESC:
  ; DESC: [+,-] [0..9][.] [0..9][.] .. [,][0..9, .-][EUR, $, €, ...]
  ; VAR(String$): String to test
  ; RET.i: If it is a possible Currency: Number of Digits, otherwise 0
  ; ============================================================================
    
    ; !!! under development !!!

    Protected I, RET, Digits, c.c
    Protected xSign, xNegativ, xDecimal, xSpaceAtEnd
    Protected IsCur = #True
    Protected *char.pChar   ; Pointer to virtual CHAR-ARRAY
    
    *char = *String          ; overlay the String with a virtual Char-Array        
    If Not *char            ; If *Pointer to String is #Null
      ProcedureReturn 0     ; ******** NotNumeric => EXIT PROCEDURE *********     
    EndIf
    
    I = 0
    
    ; Skip Spaces at beginning
    While *char\c[I]= #PbfW_IsNum_SPACE
      I + 1
    Wend   
    ; ----------------------------------------------------------------------
    ;  Check for '+', '-' and skip Spaces
    ; ---------------------------------------------------------------------- 
    While *char\c[I]      
      Select *char\c[I]
        Case #PbfW_IsNum_SPACE
        ; Skip leading Spaces! Do nothing!  
        Case '+'
          xSign = #True
          Break
          
        Case '-'
          xSign = #True
          xNegativ = #True          
          Break
          
        Default
          Break        
     EndSelect      
      I + 1     ; 
    Wend    
    If xSign : I+1 : EndIf
    
    ; ----------------------------------------------------------------------
    ;  Parse Number
    ; ---------------------------------------------------------------------- 
    While *char\c[I]  
      Select *char\c[I]         
          
        Case #PbfW_IsNum_SPACE
          xSpaceAtEnd=#True     ; Space dedected : if it is not in the middle it is ok!
          Break
          
        Case '0' To '9'
          Digits + 1          ; count Digits
        
        Case DecimalChar
          If Not xDecimal     ; if first Decimal Char in Number
            xDecimal = #True 
          Else                ; Decimal Char found twice
            IsCur = #False
            Break
          EndIf
          
        Case TsdChar
          
        Default                 ; any other Char is not allowed in an Integer
          IsCur = #False      ; Is not an Integer
          Break
         
     EndSelect      
        I + 1                   ; Attention if we leave with break, I is not inkremented
    Wend   
    ; ----------------------------------------------------------------------
    ;  Skip possible SPACEs at the end
    ; ---------------------------------------------------------------------- 
    If IsCur And xSpaceAtEnd And IsCur
      I + 1           
      While *char\c[I]       ; if all Chars at end are Spaces it is ok for an Integer
        If *char\c[I] <> #PbfW_IsNum_SPACE ; if any other Char follows after the Space, it is not an INT
          IsCur = #False
        EndIf
        I + 1
      Wend      
    EndIf
    
    If IsCur
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
    Protected IsPercent = #True, xPercentChar
    Protected *char.pChar   ; Pointer to virtual CHAR-ARRAY
    
    *char = *String          ; overlay the String with a virtual Char-Array        
    If Not *char            ; If *Pointer to String is #Null
      ProcedureReturn 0     ; ******** NotNumeric => EXIT PROCEDURE *********     
    EndIf
    
    I = 0   
    ; ----------------------------------------------------------------------
    ;  Check for '+', '-' and skip Spaces
    ; ---------------------------------------------------------------------- 
    While *char\c[I]     
      Select *char\c[I]
        Case #PbfW_IsNum_SPACE
          
        Case '+'
          xSign = #True
          
        Case '-'
          xSign = #True
          xNegativ = #True          
          Break
          
        Default
          Break         
     EndSelect      
      I + 1     ; if we leave with Break, I is not inkremented
    Wend    
    If xSign : I+1 : EndIf
    
    ; ----------------------------------------------------------------------
    ;  Parse Number
    ; ---------------------------------------------------------------------- 
    While *char\c[I]      
      Select *char\c[I]
          
        Case #PbfW_IsNum_SPACE
          xSpaceAtEnd=#True     ; Space dedected : if it is not in the middle it is ok!
          Break
          
        Case '0' To '9'
          Digits + 1            ; count Digits
        
        Case DecimalChar
          If Not IsPercent      ; if first Decimal Char in Number
            IsPercent = #True 
          Else                  ; Decimal Char found twice
            IsPercent = #False
            Break
          EndIf
          
        Case '%'
          xPercentChar = #True  ; '%' found
          xSpaceAtEnd=#True     ; check Space at END : if it is not in the middle it is ok!
          Break
          
        Default                 ; any other Char is not allowed in an Integer
          IsPercent = #False    ; Is not an Percent-Value
          Break
         
     EndSelect      
        I + 1                   ; Attention if we leave with break, I is not inkremented
    Wend   
    ; ----------------------------------------------------------------------
    ;  Skip possible SPACEs at the end
    ; ---------------------------------------------------------------------- 
    If IsPercent And xSpaceAtEnd      ; if we left While with break and have to detect End-Spaces
      I + 1             ; we have to go to the next Char first, because we are still at last checked char
      If Not xPercentChar       ; % must be detected, we allow 1Space after the Number
        If  *char\c[I] ='%'   
          xPercentChar =#True   ;'%'found
          I + 1                 ; Set to next Char! From now on only Spaces are allowed
        EndIf
      EndIf 
      
      While *char\c[I]          ; if all Chars at end are Spaces it is ok 
        If *char\c[I] <> #PbfW_IsNum_SPACE ; if any other Char follows after the Space, it is not an INT
          IsPercent = #False
        EndIf
        I + 1
      Wend      
    EndIf
    
    If IsPercent And xPercentChar
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
    
    If IntDigits : RET | #PbfW_IsNum_xINT : EndIf
    If FloatDigits : RET | #PbfW_IsNum_xFLOAT : EndIf

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
      If NumType & #PbfW_IsNum_xINT
        Ret = "IsINT : "
      EndIf
      
      If NumType & #PbfW_IsNum_xBIN
        RET = RET + "IsBin : "
      EndIf
      
      If NumType & #PbfW_IsNum_xHEX
        Ret = RET + "IsHEX : "
      EndIf
      
      If NumType & #PbfW_IsNum_xFLOAT
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
      Case #PbfW_IsNum_xBIN
        txt = "IsBin"
        
      Case #PbfW_IsNum_xHEX
        txt = "IsHex"
       
      Case #PbfW_IsNum_xINT
       txt = "IsInt"
        
      Case #PbfW_IsNum_xFLOAT
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
    
CompilerEndIf 
; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 39
; Folding = ---
; Markers = 98
; Optimizer
; CPU = 5
; Compiler = PureBasic 6.00 LTS (Windows - x86)