; ===========================================================================
;  FILE : PbFw_Module_Float.pb
;  NAME : Module Float [Float::]
;  DESC : Extended single and double precision Float functions 
;  DESC : for Floats in IEEE 754 notation.
;  DESC : This module has a low practiacal use for developping software.
;  DESC : It's more for learning and experimental purposes
;  SOURCES: https://gafferongames.com/post/floating_point_determinism/
;           https://www.elektronikpraxis.de/vergleich-von-gleitkommazahlen-knifflig-aber-machbar-a-657052/
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/12/30
; VERSION  :  0.5 Developer Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
;  2024/02/24 S.Maag:  addes some comments and STARGATE's CompareDouble()
;}
;{ TODO: There are a lot of things to do. Especally the way of calculating
;        calculating the FPU's Single and Double Precision is not the
;        right way to get a standard Epsilon for all circumstances. 
;        It is much more complicate at it seems first!
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------


DeclareModule Float
  EnableExplicit
  
  Declare.l RoundBinL(val.l, NoOfBitsToRound = 3)   ; binary round a 32 Bit Long in the least signigicant Bits
  Declare.q RoundBinQ(val.q, NoOfBitsToRound = 3)   ; binary round a 64 Bit Quad in the least signigicant Bits

  ; Single Float Functions
  Declare.f GetFPUprecisionF()                          ; Get the FPU precision for Floats
  Declare.i GetExponentF(val.f)                         ; Get the Exponent Part of a Float
  Declare.f SetExponentF(val.f, Exp.i)                  ; Set the Exponent Part of a Float
  Declare.l GetFractionF(val.f)                         ; Get the Fraction Part of a Float
  Declare.f SetFractionF(val.f, NewFraction.l)          ; Set the Fraction Part of a Float
  Declare.f ToggleSignBitF(val.f)                       ; Toggle the sign bit of a Float
  Declare.f CreateFloatF(Fraction.l, Exp.i, Sign = #False)  ; Create a Float from Fraction, Exponent and Sign
  Declare.i IsEqualF(A.f, B.f)                          ; IsEqual Float with Auto-Tolerance according to FPU precision
  Declare.i CompareFloatF(A.f, B.f)                     ; Compare 2 Floats and return -1 for A<B; 0 for ABS(A-B)<eps; 1 for A>B
  Declare.f RoundBinF(val.f, NoOfBitsToRound = 3)       ; Binary round a Float in the least signigicant Bits
  Declare.s BinStrF(val.f)                              ; Get the binary value of a Float as BinString
  Declare.s HexStrF(val.f)                              ; Get the binary value of a Float as HexString

  ; Double Float Functions
  Declare.d GetFPUprecisionD()                          ; Get the FPU precision for Doubles
  Declare.i GetExponentD(val.d)                         ; Get the Exponent Part of a Double
  Declare.d SetExponentD(val.d, Exp.i)                  ; Set the Exponent Part of a Double
  Declare.q GetFractionD(val.d)                         ; Get the Fraction Part of a Double
  Declare.d SetFractionD(val.d, NewFraction.q)          ; Set the Fraction Part of a Double
  Declare.d ToggleSignBitD(val.d)                       ; Toggle the sign bit of a Double
  Declare.d CreateFloatD(Fraction.q, Exp.i, Sign = #False)  ; Create a Double from Fraction, Exponent And Sign
  Declare.i IsEqualD(A.d, B.d)                          ; IsEqual Float With Auto-Tolerance according To FPU precision
  Declare.i CompareFloatD(A.d, B.d)                     ; Compare 2 Floats and return -1 for A<B; 0 for ABS(A-B)<eps; 1 for A>B
  Declare.d RoundBinD(val.d, NoOfBitsToRound = 3)       ; Binary round a Double in the least signigicant Bits
  Declare.s BinStrD(val.d)                              ; Get the binary value of a Double as BinString
  Declare.s HexStrD(val.d)                              ; Get the binary value of a Double as HexString
  
  Macro mac_IsEqualFloat(A, B, tolerance)
    Bool (Abs(A-B) < tolerance)  
  EndMacro
  
EndDeclareModule

Module Float
  EnableExplicit
  
  ; Format 32 Bit single Float Exponent [-126..127]
  ;      Sign  Exponent[8] Fraction[23] 
  ;      0     00000000    00000000000000000000000
  ; Bit  31    [30 - 23]  [22        -         0]
  
  ; No. of decimal digits = 7   
  
  ; Format 64 Bit double Float [-1022..1023]
  ;      Sign  Exponent[11]  Fraction[52] 
  ;      0     00000000000   0000 00000000 00000000 00000000 00000000 00000000 00000000
  ; Bit  63    [62  -   52]  [51                                                     0]
  
  ; No. of decimal digits = 16   
  
  ; for 1.0 the Exponent = 0 + BaseExp = 127 for single and 1023 for double
  ; for 2.0 the Exponent = 1 + BaseExp = 128 for single and 1024 for double
  ; for 4.0 the Exponent = 2 + BaseExp = 129 for single and 1025 for double
 
  #BaseExponentF = 127   ; middle value for signed  88it => represents EXP=0
  #BaseExponentD = 1023  ; middle value for signed 11Bit => represents EXP=0
  
  #FractionMaskF = $007FFFFF              ; remove  9 Bits at left: 1 Sing + 8 Exponent
  #FractionMaskD = $000FFFFFFFFFFFFF      ; remove 12 Bits at left: 1 Sing + 11 Exponent
  
  #FractionMaskInvF = $FF800000           ; keep  9 Bits at left: 1 Sing + 8 Exponent
  #FractionMaskInvD = $FFF0000000000000   ; keep 12 Bits at left: 1 Sing + 11 Exponent
  
  #ExponentMaskF = $7F800000              ; keep the  8 Bits of the Exponent
  #ExponentMaskD = $7FF0000000000000      ; keep the 11 Bits of the Exponent
  
  #ExponentMaskInvF = $807FFFFF           ; clear the  8 Bits of the Exponent
  #ExponentMaskInvD = $8000FFFFFFFFFFFF   ; clear the 11 Bits of the Exponent

  Structure TFloat
    StructureUnion 
      d.d ; [0]
      q.q ; [0]
      f.f ; [0]
      l.l ; [0]
      a.a[0]
    EndStructureUnion
  EndStructure
  
  Global mem_Precsion_Single.f
  Global mem_Precsion_Double.d
  
  ;- --------------------------------------------------
  ;- Private Functions
  ;- --------------------------------------------------

  ; Private
  Procedure.d _CalcSinglePrecision()
  ; ======================================================================
  ; NAME: CalcSinglePrecision
  ; DESC: Calcualtes the floating Point single precision 
  ; DESC: The precision is the minimal value we must add to
  ; DESC: 1.0 so it will be not longer dedected as 1.0.
  ; DESC: (1.0 + PUprecision) <> 1.0
  ; RET.f : The single precision
  ; ====================================================================== 
    Protected.f FPr, s
  
    ; IT CARRIES OUT AN APPROXIMATION OF MACHINE PRECISION
    FPr = 1.0  
    s = FPr + 1.0
    While s > 1.0
      FPr = 0.5 * FPr
      s = FPr + 1.0
    Wend
    ProcedureReturn FPr * 2.0
  EndProcedure
  
  ; Private
  Procedure.d _CalcDoublePrecision()
  ; ======================================================================
  ; NAME: CalcDoublePrecision
  ; DESC: Calcualtes the floating Point single precision 
  ; DESC: The precision is the minimal value we must add to
  ; DESC: 1.0 so it will be not longer dedected as 1.0.
  ; DESC: (1.0 + PUprecision) <> 1.0
  ; RET.f : The double precision
  ; ====================================================================== 
    Protected.d FPr, s
   
    ; IT CARRIES OUT AN APPROXIMATION OF MACHINE PRECISION
    FPr = 1.0  
    s = FPr + 1.0
    While s > 1.0
      FPr = 0.5 * FPr
      s = FPr + 1.0
    Wend
    ProcedureReturn FPr * 2.0
  EndProcedure
  
  ;- --------------------------------------------------
  ;- Integer Functions
  ;- --------------------------------------------------

  Procedure.l RoundBinL(val.l, NoOfBitsToRound = 3)
  ; ======================================================================
  ; NAME: RoundBinL
  ; DESC: Binary round a 32 Bit Long. It rounds the least significant
  ; DESC: Bits up or down. If we round the 3 LSB:
  ; DESC: 000..011 will be rounded down to 000. 
  ; DESC: 100..111 will be rounded up to 1000
  ; VAR(val.l): The Long value
  ; VAR(NoOfBitsToRound): The number of the least significant Bits to round
  ; RET.l : Rounded value 
  ; ====================================================================== 
    Protected.l rndMask
    
    ; calculate the RoundingMask. The least significant bits NoOfBitsToRound are set to '1' 
    rndMask = (1 << NoOfBitsToRound -1) & $FFFF  ;  & $FFFF limits round to max 16 LSB
    
    ; Debug "Value    = " + Bin(val, #PB_Long)
    ; Debug "RoundMask = " + Bin(rndMask, #PB_Word)
    
    ; If the LSBs of value >= rndMask/2+1 -> Round Up; for rndMask = 7 %111  (rndMask >>1 +1) = 4
    If val & rndMask >= ((rndMask >> 1) + 1)
      ; Round up! Set the Bits to '1' and Add 1
      val = val| rndMask + 1
      ;Debug "Round Up"
    Else
      ; Round down! Set the Bits to '0'    
      val = val  & ~rndMask  ; ~rndMask = Not(rndMask)
      ;Debug "Round Down"
    EndIf
    
    ProcedureReturn val
  EndProcedure
  
  Procedure.q RoundBinQ(val.q, NoOfBitsToRound = 3)
  ; ======================================================================
  ; NAME: RoundBinL
  ; DESC: Binary round a 64 Bit Quad. It rounds the least significant
  ; DESC: Bits up or down. If we round the 3 LSB:
  ; DESC: 000..011 will be rounded down to 000. 
  ; DESC: 100..111 will be rounded up to 1000
  ; VAR(val.q): The Quad value
  ; VAR(NoOfBitsToRound): The number of the least significant Bits to round
  ; RET.q : Rounded value
  ; ====================================================================== 
    Protected.q rndMask
    
    ; calculate the RoundingMask. The least significant bits NoOfBitsToRound are set to '1' 
    rndMask = (1 << NoOfBitsToRound -1) & $FFFFFFFF  ;  & $FFFF$FFFF limits round to max 32 LSB
    
    ; Debug "Value    = " + Bin(val, #PB_Quad)
    ; Debug "RoundMask = " + Bin(rndMask, #PB_Long)
     
    ; If the LSBs of value >= rndMask/2+1 -> Round Up; for rndMask = 7 %111  (rndMask >>1 +1) = 4
    If val & rndMask >= ((rndMask >> 1) + 1)
      ; Round up! Set the Bits to '1' and Add 1
      val = val| rndMask + 1
      Debug "Round Up"
    Else
      ; Round down! Set the Bits to '0'    
      val = val  & ~rndMask  ; ~rndMask = Not(rndMask)
      Debug "Round Down"
    EndIf
    
    ProcedureReturn val
  EndProcedure

  ;- --------------------------------------------------
  ;- Single Float Functions
  ;- --------------------------------------------------
  
  Procedure.f GetFPUprecisionF()
   ; ======================================================================
  ; NAME: GetFPUprecisionF
  ; DESC: Returns the Floation Point presicion for 16Bit Floats
  ; DESC: The precision is the minimal value we must add to
  ; DESC: 1.0 so it will be not longer dedected as 1.0.
  ; DESC: (1.0 + PUprecision) <> 1.0
  ; DESC: If you need the presicion for differnt values, nultiply it
  ; DESC: with the precision from 1.0. 
  ; DESC; The precision For 8: FPr(8) = 8 * FPUprecision
  ; RET.i : The precision for 1.0
  ; ======================================================================    
    ProcedureReturn mem_Precsion_Single
  EndProcedure
  
  Procedure.i GetExponentF(val.f)
  ; ======================================================================
  ; NAME: GetExponentF
  ; DESC: Returns the Exponent value of a single precision Float
  ; VAR(val.f): the Float value
  ; RET.i : Value of the Exponent 
  ; ====================================================================== 
    Protected *ptr.TFloat = @val
      
    ProcedureReturn (*ptr\l & #ExponentMaskF) >> 23 - #BaseExponentF   
  EndProcedure
   
  Procedure.f SetExponentF(val.f, NewExp.i)
  ; ======================================================================
  ; NAME: SetExponentF
  ; DESC: Sets a new Exponent of a single precision Float
  ; VAR(val.f): the Float value
  ; VAR(NewExp.i): the new Exponent Base 2 als signed 8it
  ; RET.f : Single Float value with the new Exponent 
  ; ====================================================================== 
    Protected *ptr.TFloat = @val
    
    ; NewExp = ((NewExp + #BaseExponentF) & $F) << 23
    
    NewExp = ((NewExp + #BaseExponentF) << 24) >> 1
    
    *ptr\l = (*ptr\l & #ExponentMaskInvF) | NewExp 
    ProcedureReturn val
  EndProcedure
  
  Procedure.l GetFractionF(val.f)
  ; ======================================================================
  ; NAME: GetFractionF
  ; DESC: Gets the raw value of the fraction part from a Single Float
  ; DESC: Attention: it is not the decimal value of the Float. Just the 
  ; DESC: Bits as an Integer
  ; VAR(val.f): the Float value
  ; RET.f : The Single Float value with the new fraction part
  ; ====================================================================== 
    Protected *ptr.Long = @val
    
    ProcedureReturn *ptr\l & #FractionMaskF   
  EndProcedure
  
  Procedure.f SetFractionF(val.f, NewFraction.l)
  ; ======================================================================
  ; NAME: SetFractionF
  ; DESC: Sets the raw value of the fraction part from at a Single Float
  ; DESC: Attention: it is not the decimal value of the Float. Just the 
  ; DESC: Bits as an Integer
  ; VAR(val.f): the Float value
  ; VAR(NewFraction.l): the new fraction part as raw 23 bit value
  ; RET.l : The raw Bits of the fraction as 32 Bit Integer (23 Bits)
  ; ====================================================================== 
    Protected *ptr.TFloat = @val
    
    *ptr\l = *ptr\l & #FractionMaskInvF  
    ; Debug "Sing & Exp = " + Hex(*ptr\l,#PB_Long)  
    ; Debug "NewFraction = " + Hex(NewFraction,#PB_Long)    
    *ptr\l = *ptr\l | (NewFraction & #FractionMaskF)
    ; Debug "New Value = " + Hex(*ptr\l,#PB_Long)
    ProcedureReturn val
  EndProcedure
 
  Procedure.f ToggleSignBitF(val.f)
  ; ======================================================================
  ; NAME: ToggleSignBitf
  ; DESC: Toggles the Sing Bit of a Single Float
  ; VAR(val.f): the Float value
  ; RET.f : Single Float value with inverted sing Bit
  ; ====================================================================== 
    Protected *ptr.Long = @val
    
    *ptr\l ! $80000000 ; XOr
    ProcedureReturn val
  EndProcedure
  
  Procedure.f CreateFloatF(Fraction.l, Exp.i, Sign = #False)
  ; ======================================================================
  ; NAME: CreateFloatF
  ; DESC: Create a Single Float from Fraction, Exponent and Sign
  ; VAR(Fraction.l): the fraction part as raw Bits (23 Bits)
  ; VAR(Exp.i): the Exponent part as raw Bits (8 Bits)
  ; VAR(Sign): The Sign-Bit value: #True for negative values
  ; RET.f : The Single Float
  ; ====================================================================== 
    Protected val.TFloat
    
    If Sign
      val\l = $80000000   ; negative sign  
    EndIf
    
    Exp = ((Exp + #BaseExponentF) << 24) >> 1
    val\l = (val\l & #ExponentMaskInvF) | Exp
    val\l = val\l | (Fraction & #FractionMaskF)

    ProcedureReturn val\f   
  EndProcedure
  
  Procedure.i IsEqualF(A.f, B.f)
  ; ======================================================================
  ; NAME: IsEqualF
  ; DESC: Are 2 Floats nearly equal? 
  ; DESC: The machine tolerance for 16Bit Floats is used for the tolerance
  ; VAR(A.f): Float A
  ; VAR(B.f): Float B    
  ; RET.i : #Ture if A and B are equal BOOL(ABS(A-B)<tolerance)
  ; ====================================================================== 
    Protected.f eps
    
    If A > B
      eps = A * mem_Precsion_Single  
    Else
      eps = B * mem_Precsion_Single
    EndIf
    
    If Abs(A-B) < eps
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure

  Procedure.i CompareFloatF(A.f, B.f)
  ; ======================================================================
  ; NAME: CompareFloatF
  ; DESC: Compares to single Floats with an interval of the machine 
  ; DESC: precision
  ; DESC: The machine tolerance for 16Bit Floats is used for the tolerance
  ; VAR(A.f): Float A
  ; VAR(B.f): Float B    
  ; RET.i : 0 if nearly equal A~B ; 1 if A>B; -1 if A<B 
  ; ====================================================================== 
    Protected.f eps
    Protected.i comp
    
    If A > B
      eps = A * mem_Precsion_Single  
      comp = 1
    Else
      eps = B * mem_Precsion_Single
      comp = -1
    EndIf
    
    If Abs(A-B) < eps
      ProcedureReturn 0
    Else
      ProcedureReturn comp
    EndIf  
  EndProcedure
    
  Procedure.f RoundBinF(val.f, NoOfBitsToRound = 3)
  ; ======================================================================
  ; NAME: RoundBinF
  ; DESC: Binary round the fraction part of a Float. It rounds the least
  ; DESC: significant Bits up or down. It uses RoundBinL() for  
  ; DESC: rounding the 23Bit Fraction part.
  ; VAR(val.f): The Float value
  ; VAR(NoOfBitsToRound): The number of the least significant Bits to round
  ; RET.f: Rounded value
  ; ====================================================================== 
   Protected *ptr.Long = @val
    Protected.l frac
    
    frac =  RoundBinL(*ptr\l & #FractionMaskF, NoOfBitsToRound)  
    
    *ptr\l =  (*ptr\l & #FractionMaskInvF) | frac
    
    ProcedureReturn val
  EndProcedure
  
  Procedure.s BinStrF(val.f)
  ; ======================================================================
  ; NAME: BinStrF
  ; DESC: Get the Dual notation from raw Bits of a Float
  ; VAR(val.f): The Float value
  ; RET.s: The binary value of the Float as BinString  
  ; ====================================================================== 
   Protected *ptr.Long = @val
    
   ProcedureReturn RSet(Bin(*ptr\l, #PB_Long), 32, "0") 
  EndProcedure
  
  Procedure.s HexStrF(val.f)
  ; ======================================================================
  ; NAME: HexStrF
  ; DESC: Get the Hex notation from raw Bits of a Float
  ; VAR(val.f): The Float value
  ; RET.s: The binary value of the Float as HexString  
  ; ====================================================================== 
    Protected *ptr.Long = @val
    
    ProcedureReturn RSet(Hex(*ptr\l, #PB_Long), 8, "0")
  EndProcedure

  ;- --------------------------------------------------
  ;- Double Float Functions
  ;- --------------------------------------------------
  
  Procedure.d GetFPUprecisionD()
  ; ======================================================================
  ; NAME: GetFPUprecisionD
  ; DESC: Returns the Floation Point presicion for 64Bit Floats
  ; DESC: The precision is the minimal value we must add to
  ; DESC: 1.0 so it will be not longer dedected as 1.0.
  ; DESC: (1.0 + PUprecision) <> 1.0
  ; DESC: If you need the presicion for differnt values, nultiply it
  ; DESC: with the precision from 1.0. 
  ; DESC; The precision For 8: FPr(8) = 8 * FPUprecision
  ; RET.i : The precision for 1.0
  ; ====================================================================== 
   ProcedureReturn mem_Precsion_Double
  EndProcedure

  Procedure.i GetExponentD(val.d)
  ; ======================================================================
  ; NAME: GetExponentd
  ; DESC: Returns the Exponent value of a double precision Float
  ; VAR(val.d): the Float value
  ; RET.i : Value of the Exponent 
  ; ====================================================================== 
    Protected *ptr.TFloat = @val
      
    ProcedureReturn (*ptr\q & #ExponentMaskD) >> 52 - #BaseExponentD  
  EndProcedure
  
  Procedure.d SetExponentD(val.d, NewExp.i)
  ; ======================================================================
  ; NAME: SetExponentD
  ; DESC: Sets a new Exponent of a doulbe precision Float
  ; VAR(val.d): the Float value
  ; VAR(NewExp.i): the new Exponent Base 2 als signed 15it
  ; RET.f : Double Float value with the new Exponent 
  ; ====================================================================== 
    Protected *ptr.TFloat = @val
    
    NewExp = ((NewExp + #BaseExponentD) << 53) >> 1
    
    *ptr\q = (*ptr\q & #ExponentMaskInvD) | NewExp 
    ProcedureReturn *ptr\d
  EndProcedure
  
  Procedure.q GetFractionD(val.d)
  ; ======================================================================
  ; NAME: GetFractionF
  ; DESC: Gets the raw value of the fraction part from a Single Float
  ; DESC: Attention: it is not the decimal value of the Float. Just the 
  ; DESC: Bits as an Integer
  ; VAR(val.d): the Float value
  ; RET.q : The raw Bits of the fraction as 64 Bit Integer (52 Bits)
  ; ====================================================================== 
    Protected *ptr.TFloat = @val
    
    ProcedureReturn *ptr\q & #FractionMaskD   
  EndProcedure
  
  Procedure.d SetFractionD(val.d, NewFraction.q)
  ; ======================================================================
  ; NAME: SetFractionD
  ; DESC: Sets the raw value of the fraction part from at a Double Float
  ; DESC: Attention: it is not the decimal value of the Float. Just the 
  ; DESC: Bits as an Integer
  ; VAR(val.d): the Float value
  ; VAR(NewFraction.ql): the new fraction part as raw 23 bit value
  ; RET.d : The Double Float value with the new fraction part
  ; ====================================================================== 
    Protected *ptr.TFloat = @val
    
    *ptr\q & #FractionMaskInvD  
    *ptr\q | (NewFraction & #FractionMaskD)
    
    ProcedureReturn *ptr\d
  EndProcedure

  Procedure.d ToggleSignBitD(val.d)
  ; ======================================================================
  ; NAME: ToggleSignBitD
  ; DESC: Toggles the Sing Bit of a Double Float
  ; VAR(val.d): the Float value
  ; RET.d : Double Float value with inverted sing Bit
  ; ====================================================================== 
    Protected *ptr.TFloat = @val
   
    *ptr\q ! $8000000000000000 ;  XOr
    ProcedureReturn *ptr\d  
  EndProcedure
  
  Procedure.d CreateFloatD(Fraction.q, Exp.i, Sign = #False)
  ; ======================================================================
  ; NAME: CreateFloatD
  ; DESC: Create a Double Float from Fraction, Exponent and Sign
  ; VAR(Fraction.q): the fraction part as raw Bits (52 Bits)
  ; VAR(Exp.i): the Exponent part as raw Bits (11 Bits)
  ; VAR(Sign): The Sign-Bit value, #True for negative values
  ; RET.d : The Double Float
  ; ====================================================================== 
   Protected val.TFloat
    
    If Sign
      val\q = $8000000000000000   ; negative sign  
    EndIf
    
    Exp = ((Exp + #BaseExponentD) << 53) >> 1
    val\q = (val\q & #ExponentMaskInvD) | Exp
    val\q = val\q | (Fraction & #FractionMaskD)

    ProcedureReturn val\d   
  EndProcedure
  
  Procedure.i IsEqualD(A.d, B.d)
  ; ======================================================================
  ; NAME: IsEqualD
  ; DESC: Are 2 Doubles nearly equal? 
  ; DESC: The machine tolerance for 32 Bit Floats is used for the tolerance
  ; VAR(A.d): Float A
  ; VAR(B.d): Float B    
  ; RET.i : #Ture if A and B are equal BOOL(ABS(A-B)<tolerance)
  ; ====================================================================== 
    Protected.d eps
     
    If A > B
      eps = A * mem_Precsion_Double  
    Else
      eps = B * mem_Precsion_Double
    EndIf
    
    If Abs(A-B) < eps
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False  
  EndProcedure

  Procedure.i CompareFloatD(A.d, B.d)
  ; ======================================================================
  ; NAME: CompareFloatD
  ; DESC: Compares to single Floats with an interval of the machine 
  ; DESC: precision
  ; DESC: The machine tolerance for 16Bit Floats is used for the tolerance
  ; VAR(A.f): Float A
  ; VAR(B.f): Float B    
  ; RET.i : 0 if nearly equal A~B ; 1 if A>B; -1 if A<B 
  ; ====================================================================== 
    Protected.d eps
    Protected.i comp
    
    If A > B
      eps = A * mem_Precsion_Double  
      comp = 1
    Else
      eps = B * mem_Precsion_Double
      comp = -1
    EndIf
    
    If Abs(A-B) < eps
      ProcedureReturn 0
    Else
      ProcedureReturn comp
    EndIf  
  EndProcedure
    
  Procedure.d RoundBinD(val.d, NoOfBitsToRound = 3)
  ; ======================================================================
  ; NAME: RoundBinD
  ; DESC: Binary round the fraction part of a Double. It rounds the least
  ; DESC: significant Bits up or down. It uses RoundBinQ() for  
  ; DESC: rounding the 53Bit Fraction part.
  ; VAR(val.d): The Double value
  ; VAR(NoOfBitsToRound): The number of the least significant Bits to round
  ; RET.d: Rounded value
  ; ====================================================================== 
    Protected *ptr.Quad = @val
    Protected.q frac
    
    frac = RoundBinQ(*ptr\q & #FractionMaskF, NoOfBitsToRound)  
    
    *ptr\q =  (*ptr\q & #FractionMaskInvF) | frac
    
    ProcedureReturn val
  EndProcedure
  
  Procedure.s BinStrD(val.d)
  ; ======================================================================
  ; NAME: BinStrF
  ; DESC: Get the Dual notation from raw Bits of a Double
  ; VAR(val.d): The Double value
  ; RET.s: The binary value of the Double as BinString  
  ; ====================================================================== 
    Protected *ptr.Quad = @val
    
    ProcedureReturn RSet(Bin(*ptr\q, #PB_Quad), 64, "0") 
  EndProcedure
  
  Procedure.s HexStrD(val.d)
  ; ======================================================================
  ; NAME: HexStrD
  ; DESC: Get the Hex notation from raw Bits of a Double
  ; VAR(val.d): The Double value
  ; RET.s: The binary value of the Double as HexString  
  ; ====================================================================== 
    Protected *ptr.Quad = @val
    
    ProcedureReturn RSet(Hex(*ptr\q, #PB_Quad), 16, "0")
  EndProcedure
  
  Procedure.i CompareDouble(Double1.d, Double2.d, BitAccuracy.i=46)
    ; Code by STARGÅTE; PB-Forum
    ; https://www.purebasic.fr/german/viewtopic.php?t=33098
      
    Protected *Double1.Quad = @Double1
  	Protected *Double2.Quad = @Double2
  	Protected Sign.i, Exponent.q, Fraction.q
  	Protected.q Uncertainty = 1<<(52-BitAccuracy) - 1
  	
  	Sign        = *Double2\q>>63 & 1    - *Double1\q>>63 & 1
  	
  	Debug "Sign = " + Sign
  	
  	Exponent    = *Double2\q>>52 & $7FF - *Double1\q>>52 & $7FF
  	
  	If Sign <> 0 Or Exponent > 1 Or Exponent < -1
  		; Die zweite Zahl ist deutlich kleiner oder deutlich größer
  		If Double1 > Double2
  			ProcedureReturn 1
  		ElseIf Double1 < Double2
  			ProcedureReturn -1
  		EndIf
  	ElseIf Exponent = -1
  		; Die zweite Zahl ist etwas kleiner
  		Sign     = 1 - 2 * (*Double2\q >>63 & 1)
  		Fraction = ( (*Double2\q & $FFFFFFFFFFFFF) - (*Double1\q & $FFFFFFFFFFFFF)|1<<52 ) * Sign
  		If Fraction < -Uncertainty
  			ProcedureReturn 1
  		ElseIf Fraction > Uncertainty
  			ProcedureReturn -1
  		EndIf
  	ElseIf Exponent = 1
  		; Die zweite Zahl ist etwas größer
  		Sign     = 1 - 2 * (*Double2\q >>63 & 1)
  		Fraction = ( (*Double2\q & $FFFFFFFFFFFFF)|1<<52 - (*Double1\q & $FFFFFFFFFFFFF) ) * Sign
  		If Fraction < -Uncertainty
  			ProcedureReturn 1
  		ElseIf Fraction > Uncertainty
  			ProcedureReturn -1
  		EndIf
  	Else
  		; Die Zahlen sind fast gleich
  		Sign     = 1 - 2 * (*Double2\q >>63 & 1)
  		Fraction = ( *Double2\q & $FFFFFFFFFFFFF - *Double1\q & $FFFFFFFFFFFFF ) * Sign
  		If Fraction < -Uncertainty
  			ProcedureReturn 1
  		ElseIf Fraction > Uncertainty
  			ProcedureReturn -1
  		EndIf
  	EndIf
  	
  	ProcedureReturn 0
	
  EndProcedure

  ; INIT
  mem_Precsion_Single = _CalcSinglePrecision()
  mem_Precsion_Double = _CalcDoublePrecision()

EndModule


EnableExplicit
UseModule Float

Define xf.f, xd.d

xf= 0.0001

Debug "Single"
Debug ToggleSignBitF(xf)
Debug "Fraction = " + Str(GetFractionF(xf))
Debug "Exponent = " + GetExponentF(xf)
Debug SetExponentF(xf, 2)
xf = SetFractionF(0, $FFFF)
Debug "NewFloat"
Debug xf

Debug GetFractionF(xf)

xd = 1.0
Debug " "
Debug "Double"
Debug GetExponentd(xd) ; -128
Debug SetExponentF(xd, 2)

Debug "Binary notation"

Debug BinStrF(xf)

; Test CompareDouble, by STARGÅTE
; Debug CompareDouble(1.0, 2.0)
; Debug CompareDouble(3.0, 2.0)
; 
; Debug "---"
; 
; Debug CompareDouble(1.000000000000001,  0.999999999999999)  ; Ist in den höchsten 46 Bit gleich.
; Debug          Bool(1.000000000000001 > 0.999999999999999)
; 
; Debug "---"
; 
; Debug CompareDouble(1.000000000001, 0.999999999999)  ; Ist in den höchsten 46 Bit größer.
; Debug CompareDouble(1.000000000001, 0.999999999999, 35) ; Ist in den höchsten 35 Bit gleich.
; 
; Debug "---"
; 
; Debug CompareDouble(1.001, 1.002, 8)
; Debug CompareDouble(1001, 1002, 8)
; Debug CompareDouble(1001, 1003, 8)

; IDE Options = PureBasic 6.04 LTS (Windows - x64)
; CursorPosition = 42
; Folding = ------
; Optimizer
; CPU = 5