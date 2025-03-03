﻿; ===========================================================================
;  FILE : PbFw_Module_PB.pb
;  NAME : Module PureBasic Extentions [PB::]
;  DESC : It's a PureBasic command extention and provides functions
;  DESC : not directly integrated in PB in an optimzed way!
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2025/01/07
; VERSION  :  0.5 untested Developer Version
; COMPILER :  I hope all versions!
; OS       :  all
; ===========================================================================
; ChangeLog:
;{
; 2025/02/01 S.Maag changed to the new Framework wide Constant name scheme
;             #'Module'_ConstantName
; 2025/02/01 S.Maag : Moved TSystemColor and the basic Color Macros
;             form Modul Color To Modul PB!
; 2025/01/30 S.Maag integrated the most common Bit functions as Macros!
; 2025/01/29 S.Maag added the RealTimecounter and RealTimeCounter/HighPerformanceTimer
;             functions from Module RTC. RTC will be obsolet in the future.
;
; 2025/01/28 S.Maag : I realized: It's better for the programming workflow
;             to have one extention modul with the most common/needed functions
;             instead of a lot of special moduls. Because of that I start to move
;             the most common Functions/Macros to this Modul.
;}
;{ TODO:
;}
; ===========================================================================

; XIncludeFile "PbFw_Module_PB.pb"          ; PB::      Purebasic Extention Module

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"        ; PbFw::   FrameWork control Module

DeclareModule PB
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
    
  #PB_CharSize = SizeOf(Character)
  #PB_IntSize = SizeOf(Integer)
  ; #TAB    ; exists in PB. But to have same way of access, define it here too
  #PB_TAB = #TAB   ; #TAB = 9
  #PB_SPACE = 32
  
  #PB_MaxBitNo = (SizeOf(Integer)*8-1)    ; 63 for x64 and 31 for x32
  
  ; Any or Universal Pointer (see PurePasic IDE Common.pb Structrue PTR)
  ; I modified it a little to have both single var access and var array access 
  ; The orignal PTR-Struct only has var array access (a.a[0] ... ).
  ; \a \b \c ... is the single var access and \aa[0] \bb[0] ... ist the multiple
  ; access like an Array
  Structure pAny         ; ATTENTION! Only use as Pointer Strukture! Do not define as a normal Var!
    StructureUnion
      ; single access
      a.a       ; ASCII   : 8 Bit unsigned  [0..255] 
      b.b       ; BYTE    : 8 Bit signed    [-128..127]
      c.c       ; CHAR    : 1 Byte for Ascii Chars 2 Bytes for unicode
      w.w       ; WORD    : 2 Byte signed   [-32768..32767]
      u.u       ; UNICODE : 2 Byte unsigned [0..65535]
      l.l       ; LONG    : 4 Byte signed   [-2147483648..2147483647]
      f.f       ; FLOAT   : 4 Byte
      q.q       ; QUAD    : 8 Byte signed   [-9223372036854775808..9223372036854775807]
      d.d       ; DOUBLE  : 8 Byte float    
      i.i       ; INTEGER : 4 or 8 Byte INT, depending on System
      ;*p.pAny   ; Pointer to Any (for C-like **, PointerPointer use) !VERY DANGEROUS!
      
      ; multiple access like an Array
      aa.a[0]   ; ASCII   : 8 Bit unsigned  [0..255] 
      bb.b[0]   ; BYTE    : 8 Bit signed    [-128..127]
      cc.c[0]   ; CHAR    : 1 Byte for Ascii Chars 2 Bytes for unicode
      ww.w[0]   ; WORD    : 2 Byte signed   [-32768..32767]
      uu.u[0]   ; UNICODE : 2 Byte unsigned [0..65535]
      ll.l[0]   ; LONG    : 4 Byte signed   [-2147483648..2147483647]
      ff.f[0]   ; FLOAT   : 4 Byte
      qq.q[0]   ; QUAD    : 8 Byte signed   [-9223372036854775808..9223372036854775807]
      dd.d[0]   ; DOUBLE  : 8 Byte float    
      ii.i[0]   ; INTEGER : 4 or 8 Byte INT, depending on System
      ; *pp.pAny[0]; Pointer to Any (for C-like **, PointerPointer use) !VERY VERY DANGEROUS!
    EndStructureUnion
  EndStructure
  
  ; An adapted version of pAny especally for character use
  Structure pChar
    StructureUnion
      a.a         ; ASCII   : 8 Bit unsigned  [0..255] 
      c.c         ; CHAR    : 1 Byte for Ascii Chars 2 Bytes for unicode
      u.u         ; UNICODE : 2 Byte unsigned [0..65535]
      aa.a[0]     ; ASCII   : 8 Bit unsigned  [0..255] 
      cc.c[0]     ; CHAR    : 1 Byte for Ascii Chars 2 Bytes for unicode
      uu.u[0]     ; UNICODE : 2 Byte unsigned [0..65535]
    EndStructureUnion
  EndStructure 
  
  ; ----------------------------------------------------------------------
  ;  Pixel and color formats
  ; ----------------------------------------------------------------------
    
  ; ABGR and RGBA Color orientation depends on Memory Model
  ; Little-Endian, Big-Endian (Intel, Motorla) 
  ; The Linux Kernel Documentation describes all possible Pixel Formats for Images
  ; see https://www.kernel.org/doc/html/v4.14/media/uapi/v4l/pixfmt-packed-rgb.html
  ; At INTEL x86 Processors the Memory Alignment is Lo|Hi
  ; what means that the Lo-Byte of a VAR is at 1st Position in Memory
  
  ; with the PureBasic Command DrawingBufferPixelFormat() we can test which Format is
  ; used. As I figured out:
  ; Standard under Purebasic Windows is ABGR32 and BGR24
      
  CompilerIf #PB_Compiler_Processor = #PB_Processor_PowerPC
    ; ----------------------------------------------------------------------
    ; This is the exception Alpha first : Motorola PowerPC
    ; ----------------------------------------------------------------------
    Structure TSystemRGBA   ;  BGRA in Memory, might be ABGR! TODO! Check it!
      ;A.a
      B.a
      G.a
      R.a
      A.a
    EndStructure
  CompilerElse    ; x86, x64; ARM32; ARM64
    ; ----------------------------------------------------------------------
    ; This is the standard Windows alignment RED=LoByte .. Alpha=HiByte
    ; In Memory RGBA but in Processor Register ABGR  
    ; ----------------------------------------------------------------------
    Structure TSystemRGBA   ; here it's RGBA in Memory
      R.a
      G.a
      B.a
      A.a
    EndStructure   
  CompilerEndIf
  
  Structure TSystemColor  ; The SystemColorStructure to have multiple access to the Color Channels!
    ; This is the trick how it works! TSystem RGBA is integrated as complete Structure, not as Pointer!
    ; This is a documented feature. See the PB help for Structure Union. There you will find the RGB example!
    ; IDENTICAL POINTERS FOR: 
    ;   @TSystemColor= @TSystemColor\col= @TSystemColor\RGB = @TSystemColor\RGB\R = @TSystemColor\ch[0]
    StructureUnion
      RGB.TSystemRGBA ; Access single color channels by name
      col.l           ; Access as 32Bit Color
      ch.a[4]         ; Access single color channels by number [0..3]                 
    EndStructureUnion
  EndStructure

  ; System Color Mask Structure to hold management data for the systems color order RGBA, ABGR or BGRA
  ; use the Function InitSytemColorMask() to intialize the Datas of a TSystemColorMask Structrue
  Structure TSystemColorMask
    idxRed.i        ; 0 based ByteIndex for Red Channel
    idxGreen.i      ; 0 based ByteIndex for Green Channel
    idxBlue.i       ; 0 based ByteIndex for Blue Channel 
    idxAlpha.i      ; 0 based ByteIndex for Alpha Channel 
    
    shRed.i         ; No of Bits to Shift for Red Channel 
    shGreen.i       ; No of Bits to Shift for Green Channel 
    shBlue.i        ; No of Bits to Shift for Blue Channel 
    shAlpha.i       ; No of Bits to Shift for Alpha Channel 
    
    maskRed.i       ; BitMask to select Red value
    maskGreen.i     ; BitMask to select Green value
    maskBlue.i      ; BitMask to select Blue value
    maskAlpha.i     ; BitMask to select Alpha value
    
    maskRedOff.i    ; BitMask to reset Red Channel
    maskGreenOff.i  ; BitMask to reset Green Channel
    maskBlueOff.i   ; BitMask to reset Blue Channel
    maskAlphaOff.i  ; BitMask to reset Alpha Channel
  EndStructure
    
  ; Declare the Init Function for the systems ColorMask Structure
  Declare InitSytemColorMask(*SCM.TSystemColorMask)
  
  Global _SCM.TSystemColorMask  
  ; init the systems Managment Data for Color order RGBA, ABGR, BGRA
  InitSytemColorMask(_SCM)

  ;- ----------------------------------------------------------------------
  ;- Macros to define something
  ;- ----------------------------------------------------------------------
  
  ; double Quotes
  Macro DQ
  "
  EndMacro
  
  Macro HashTag
  #
  EndMacro
  
  ; defines FloatingPoint Real values: As single in x32; As double in x64
  ; Use it like this: Define MyReal.Real  -> will result as MyReal.f in x32, MyReal.d in x64
  CompilerIf #PB_Compiler_64Bit
    Macro Real :d: EndMacro
  CompilerElse
    Macro Real :f: EndMacro
  CompilerEndIf

  ; Token from Module_CodeCreation CC:: ; because it is usefull sometimes
  Macro QuoteIt(TextToQuote)
    PB::DQ#TextToQuote#PB::DQ
  EndMacro
    
  ; define Constant if not defined yet
  Macro CONST(ConstName, Value)
    CompilerIf Not Defined(ConstName, #PB_Constant)
      PB::HashTag#ConstName = Value
    CompilerEndIf
  EndMacro
  
  ; Define the CompilerConstants #PB_Backend_Asm and #PB_Compiler_Backend
  ; if not exist! PB_Version < 6.00
  CONST(PB_Backend_Asm,0)
  CONST(PB_Compiler_Backend,0)
  
  ;- ----------------------------------------------------------------------
  ;- Macros for Directory/File operations
  ;- ----------------------------------------------------------------------

  ; FileSize ReturnValue
  ;  -1: FileNotFound
  ;  -2: It is a directory
  ; use it : result = FileExist(FullFileName)
  Macro FileExist(FullFileName)
    Bool(FileSize(FullFileName) >= 0)  
  EndMacro
  
  ; use it : result = DirectoryExist("C:\Windows")
  Macro DirectoryExist(Directory)
    Bool(FileSize(Directory) = -2)
  EndMacro
  
  ; Go one path higher in path hirarchy
  ; use it : result$ = OnePathBack("C:\Windows\System32")   ; => "C:\Windows\"
  ;          result$ = OnePathBack("C:\Windows\System32\")  ; => "C:\Windows\"  
  Macro OnePathBack(FullPathName)
    GetPathPart(RTrim(FullPathName, #PS$))
  EndMacro

  ;- ----------------------------------------------------------------------
  ;- Macros for Bit/Byte operations
  ;- ----------------------------------------------------------------------

  ; Get the LoByte 
  ; use it : result = GetLoByte(x)
  Macro GetLoByte(value)
    (value & $FF)  
  EndMacro
  
  ; use it : result = SetLoByte(x, [0..255])
  Macro SetLoByte(value, NewLoByte)
    ((value & ~$FF) | (NewLoByte & $FF))  
  EndMacro
  
  ; Get the HiByte
  ; use it : result = GetHiByte(x)
  Macro GetHiByte(WordValue)
    (((WordValue)>>8) & $FF)
  EndMacro  
  
  ; Set the HiByte of a Word based value
  ; use it : result = SetHiByte(x, [0..255])
  Macro SetHiByte(WordValue, NewHiByte)
    ((WordValue & ~$FF00) | ((NewHiByte & $FF)<<8))  
  EndMacro
  
  ; Swaps the 2 Bytes of a 16Bit value
  ; use it : result = BSwap16(x, [0..$FFFF])
  Macro BSwap16(WordValue)
    ((WordValue & $FF)<< 8) + (WordValue >>8)& $FF)  
  EndMacro
  
  ; Get the Bit specified by BitNo from value
  ; use it : result = GetBit(value, [0..31/63])
  Macro GetBit(value, BitNo)
    Bool(value & 1<<BitNo)  
  EndMacro
  
  ; Set the Bit specified by BitNo in value
  ; use it : result = SetBit(value, [0..31/63])
  Macro SetBit(value, BitNo)
    (value | 1<<BitNo)
  EndMacro
  
  ; Reset the Bit specified by BitNo in value
  ; value & (Not(1<<BitNo))
  ; use it : result = ResetBit(value, [0..31/63])
  Macro ResetBit(value, BitNo)
    (value & ~(1<<BitNo))  
  EndMacro
  
  ; Toggle the Bit specified by BitNo in value
  ; use it : result = ToggleBit(value, [0..31/63])
  Macro ToggleBit(value, BitNo)
    (value ! 1<<BitNo)  
  EndMacro
  
  ; Get the Sign Bit (highest BitNo) from value
  ; use it : result = GetSignBit(value)
  Macro GetSignBit(value)
    Bool(value >> PB::#PB_MaxBitNo)  
  EndMacro
  
  ; Set the Sign Bit (highest BitNo) in value
  ; use it : result = SetSignBit(value)
  Macro SetSignBit(value)
    (value | 1<<PB::#PB_MaxBitNo)
  EndMacro
  
  ; Reset the Sign Bit (highest BitNo) in value
  ; use it : result = ResetSignBit(value)
  Macro ResetSignBit(value)
    (value & ~(1<<PB::#PB_MaxBitNo))  
  EndMacro
  
 ; Toggle the Sign Bit (highest BitNo) in value
 ; use it : result = ToggleSingBit(value)
  Macro ToggleSingBit(value)
    (value ! 1<<PB::#PB_MaxBitNo)  
  EndMacro
  
  ; Count the no of HiBits in a Byte value
  ; use it : result = BitCountByte(value)
  Macro BitCountByte(val)
    (Bool(val&$1)+Bool(val&$2)+Bool(val&$4)+Bool(val&$8)+Bool(val&$10)+Bool(val&$20)+Bool(val&$40)+Bool(val&$80))
  EndMacro

  ;- ----------------------------------------------------------------------
  ;- Macros for Min, Max, Limit, Compare
  ;- ----------------------------------------------------------------------
  
  ; Get the lowest value from 2 values
  ; use it : result = Min(3,2)
  Macro Min(v1, v2)
    (v1*Bool(v1<=v2) + v2*Bool(v1>v2))
  EndMacro
  
  ; Get the highest value from 2 values
  ; use it : result = Max(3,2)
  Macro Max(v1, v2)
    (v1*Bool(v1>=v2) + v2*Bool(v1<v2))
  EndMacro
  
  ; Write the lowest value from 2 values to VarResult
  ; use it : MinOf2(VarResult, 3, 2)
  Macro MinOf2(VarResult, v1, v2)
    If v1 < v2
      VarResult = v1
    Else
      VarResult = v2
    EndIf   
  EndMacro
  
  ; Write the highest value from 2 values to VarResult
  ; use it : MaxOf2(VarResult, 3, 2)
  Macro MaxOf2(VarResult, v1, v2)
    If v1 > v2
      VarResult = v1
    Else
      VarResult = v2
    EndIf   
  EndMacro
  
  ; Write the lowest value from 3 values to VarResult
  ; use it: MinOf3(VarResult, 3, 2, 1)
  Macro MinOf3(VarResult, v1, v2, v3)
  	If v3 < v2
  		If v3 < v1
  			VarResult = v3
  		Else
  			VarResult = v1
  		EndIf
  	ElseIf v2 < v1
  		VarResult = v2
  	Else
  		VarResult = v1
  	EndIf
  EndMacro
  
  ; Write the highest value from 3 values to VarResult
  ; use it: MaxOf3(VarResult, 3, 2, 1)
  Macro MaxOf3(VarResult, v1, v2, v3)
    If v3 > v2
  		If v3 > v1
  			VarResult = v3
  		Else
  			VarResult = v1
  		EndIf
  	ElseIf v2 > v1
  		VarResult = v2
  	Else
  		VarResult = v1
  	EndIf
  EndMacro
  
  ; Return the value limited to min 0 or Limit a var to min 0
  ; use it with var  : MinNull(MyVar)
  ;        with value: result = MinNull(-5)
  
  ; Attention do not change to ( VarOrValue * Bool(VarOrValue >0) ) MinNull(MyVar) will not work
  Macro MinNull(VarOrValue)
    VarOrValue * Bool(VarOrValue >0)  
  EndMacro
  
  ; use it: LimitToMin(var, MinValue)
  ;         LimitToMin(var, a+b)            ; use with MinValue as Expression
  Macro LimitToMin(var, MinValue)
    If var < (MinValue) : var = (MinValue) : EndIf
  EndMacro
  
  ; Limit var to MaxValue
  ;   (if you want to have a LimitMax function with return, use: result = Min(var, MyMax)
  
  ; use it: LimitToMax(var, MaxValue)
  ;         LimitToMax(var, a+b)            ; use with MaxValue as Expression
  Macro LimitToMax(var, MaxValue)
    If var > (MaxValue) : var = (MaxValue) : EndIf
  EndMacro
  
  ; Limit var to MinValue and MaxValue 
  ; use it: LimitToMinMax(var, MinValue, MaxValue)
  ;         LimitToMinMax(var, a-b, a+b)            ; use with MinValue, MaxValue as Expression
  Macro LimitToMinMax(var, MinValue, MaxValue)
    If var < (MinValue) 
      var = (MinValue) 
    ElseIf var > (MaxValue)
      var = (MaxValue)
    EndIf
  EndMacro
 
  ; especally to compare FloatingPoint values. But works on all types.
  ; use it: result = IsEqual(v1, v2, delta)
  ;         result = IsEqual(v1, v2, a-b)             ; use with delta as Expression
  Macro IsEqual(v1, v2, delta)
    Bool(v1 <= (v2 +delta)) And (v1 >= (v2 -delta))
  EndMacro
  
  ; (MinValue <= value <= MaxValue)
  ; use it: result = IsInRange(value, MinValue, MaxValue)
  ;         result = IsInRange(value, a-b, a+b)       ; use with MinValue, MaxValue as Expression
  Macro IsInRange(value, MinValue, MaxValue)
    Bool((value >=(MinValue)) And (value <=(MaxValue))  
  EndMacro 
  
  ; saves Min and Max values to varMin, varMax
  ; use it: SaveMinMax(100, varMin, varMax)  ; -> varMin=100, varMax=100
  ;         SaveMinMax(99, varMin, varMax)   ; -> varMin=99 , varMax=100
  ;         SaveMinMax(101, varMin, varMax)  ; -> varMin=99 , varMax=101
  Macro SaveMinMax (value, varMin, varMax)
    If value > varMax
      varMax = value
    ElseIf value < varMin
      varMin = value  
    EndIf
  EndMacro  
  
  ; similat to the VB IIf Function
  ; use it : IIf(varReturn, A>1000, "large", "small")
  Macro IIf(varReturn, expression, valTrue, valFalse)
    If Bool(expression)
      varReturn = valTrue
    Else
      varReturn = valFalse  
    EndIf
  EndMacro

  ;- ----------------------------------------------------------------------
  ;- Macros for Math
  ;- ----------------------------------------------------------------------

  ; because PB do not have a square function x²
  ; expression use is possible : y = SQ(3+2)  = 25
  ; use it: result = SQ(value)
  ;         result = SQ(a+b)        ; use with value as Expression
  Macro SQ(value)
    ((value)*(value))
  EndMacro
  
  ; because PB do not have a cubic function x³
  ; use it: result = CUB(value)
  ;         result = CUB(a+b)       ; use with value as Expression
  Macro CUB(value)
    ((value)*(value)*(value))
  EndMacro
  
  ; Calculate hypothenuse with Pythagoras
  ; use it: C = Hypothenuse(A, B)
  Macro Hypothenuse(_A_, _B_)
    Sqr(_A_*_A_ + _B_*_B_)
  EndMacro
  
  ; Lerp : Blending between A..B from 0..100% with T={0..1}
  ; Be sure to pass FloatingPoint values to the Macro
  ; _A_ [Float] : Startvalue A 
  ; _B_ [Float] : Endvalue   B
  ; _T_ [Float] : Time Value {0..1} = {0..100%}
  ; RET [Float] : Lerped Value V in the Range {ValStart..ValEnd}
  ; use it: V = Lerp(A, B, T)
  Macro Lerp(_A_, _B_, _T_)    
    (_B_-_A_) * _T_ + _A_   ; A*(1-T) + B*T
  EndMacro
  
  ; InverseLerp : Get the BlendingTime T{0..1} of the Value V in the Range [A..B]
  ; _A_ [Float] : Startvalue A 
  ; _B_ [Float] : Endvalue   B
  ; _V_ [Float] : Time Value {0..1} = {0..100%}
  ; RET [Float] : Blendig Time T of the Value V {0..1} = {0..100%}
  ;
  ; use it: T = UnLerp(A, B, V)
  Macro UnLerp(_A_, _B_, _V_)
    (_V_-_A_)/(_B_-_A_)
  EndMacro
  
  ; Scale : scales a value which is within the Range [inMin..inMax]
  ; to the a new Range[outMin..outMax] 
  ;
  ;                        (outMax - outMinOut)
  ;  ret = (val - inMin) ------------------------  + outMin
  ;                          (inMax - inMin) 
  ;  
  ; val : The Value to scale
  ; inMin : Input Range Minimum
  ; inMax : Input Range Maximum
  ; outMin: Output Range Minimum
  ; outMax: Output Range Maximum
  ; RET : the value scaled to the Output Range [outMin..outMax]
  ;
  ; use it: result = Scale(value, -255, 255, 0, 100)  ; to rescale a Range [-255..255] to [0..100]% 
  Macro Scale(value, inMin, inMax, outMin, outMax)
    ((value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin)
  EndMacro
  
  ;   MIN=-100 MAX=100 VALUE=20 : ret= -20
  ;   MIN=  20 MAX=100 VALUE=20 : ret= 100
  ;                    VALUE=50 : ret=  70 
  
  ; use it: result = InvertRange(value, 0, 100) to change from [0..100] to [100..0]
  Macro InvertRange(value, RangeMin, RangeMax)
    ; ret = Max - Val + Min
    (RangeMin + RangeMax - value)
  EndMacro

  ;- ----------------------------------------------------------------------
  ;- Macros for Hex-String Conversion
  ;- ----------------------------------------------------------------------

  ; create a right aligned Hex$ with leading '0'. The stringlength
  ; depends on the function: Word - HexW, Long - HecxL, Quad - HexQ
  ; use it: result$ = HexW(value)
  Macro HexW(value)
    RSet(Hex(value, #PB_Word), 4, "0")
  EndMacro

  ; use it: result$ = HexL(value)
  Macro HexL(value)
    RSet(Hex(value, #PB_Long), 8, "0")
  EndMacro
  
  ; use it: result$ = HexQ(value)
  Macro HexQ(value)
    RSet(Hex(value, #PB_Quad), 16, "0")
  EndMacro

  ;- ----------------------------------------------------------------------
  ;- Macros for CHAR operations
  ;- ----------------------------------------------------------------------
  
  ; Decrement CharPointer
  ; use it: DECC(MyCharPointer, [1..n])
  ;     or  MyNewCharPointer = DECC(MyOldCharPointer, [1..n])
  Macro DECC(ptrChar)
    ptrChar - PB::#PB_CharSize ; (NoOfChars * PB::#PB_CharSize)
  EndMacro

  ; Increment CharPointer
  ; use it: INCC(MyCharPointer, [1..n])
  ;     or  MyNewCharPointer = INCC(MyOldCharPointer, [1..n])
  Macro INCC(ptrChar)
    ptrChar + PB::#PB_CharSize ; (NoOfChars * PB::#PB_CharSize)
  EndMacro
  
  ; LowerCase a single Char in ASCii Character space
  ; use it: result = LCaseChar(MyChar)
  Macro LCaseChar(MyChar)
    (MyChar + 32 * Bool( (MyChar>='A' And MyChar<='Z') Or (MyChar>=192 And MyChar<=222))  
  EndMacro
  
  ; UpperCase a single Char in ASCii Character space
  ; use it: result = UCaseChar(MyChar)
   Macro UCaseChar(MyChar)
    (MyChar - 32 * Bool( (MyChar>='a' And MyChar<='z') Or (MyChar>=224 And MyChar<=254))  
  EndMacro

  ; Set a Charater variable to LoChar. It's faster than MyChar = LCaseChar(MyChar)!
  ; ASCii Character space only!
  ; use it: SetCharLo(MyChar)
  Macro SetCharLo(VarMyChar)  
    Select VarMyChar
      Case 'A' To 'Z'
        VarMyChar + 32  ; a[97]-A[65]=32       
      Case 192 To 222   ; 'À'..222
        VarMyChar + 32  ; 224-192 = 32        
    EndSelect
  EndMacro
   
  ; Set a Charater variable to UpChar. It's faster than MyChar = UCaseChar(MyChar)
  ; ASCii Character space only!
  ; use it: SetCharUp(MyChar)
  Macro SetCharUp(VarMyChar)  
    Select VarMyChar
      Case 'a' To 'z'
        VarMyChar - 32  ; a[97]-A[65]=32                
      Case 224 To 254   ; 'À'..254
        VarMyChar - 32  ; 254-222 = 32      
    EndSelect
  EndMacro 
  
  ; Check if Char is decimal digit : Case '0' To '9'
  ; The Bool is needed to save the result in a var: res=IsDecChar()! Without Bool only 'If IsDecChar()' is possible!
  ; use it: result = IsDecChar(MyChar)
  Macro IsDecChar(MyChar)
    Bool(MyChar >='0' And MyChar <='9')
  EndMacro
  
  ; Check if Char is Hex digit : Case '0' To '9', 'A' To 'F'
  ; use it: result = IsHexChar(MyChar)
  Macro IsHexChar(MyChar)
    Bool((MyChar >='0' And MyChar <='9') Or (MyChar >='A' And MyChar <='F'))
  EndMacro
  
  ; Check if Char is binary digit : Case '0', '1'
  ; use it: result = IsBinChar(MyChar)
  Macro IsBinChar(MyChar)
    Bool(MyChar ='0' Or MyChar ='1')
  EndMacro
  
  ; Check if Char is SPACE or TAB : Case '9', '32'
  ; use it: result = IsSpaceTabChar(MyChar)
  Macro IsSpaceTabChar(MyChar)
    Bool(MyChar =9 Or MyChar =32)
  EndMacro
  
  ; Check if Char is EndOfLineChar LF or CR : Case '10', '13'
  ; use it: result = IsEolChar(MyChar)
  Macro IsEolChar(MyChar)
    Bool(MyChar =10 Or MyChar =13)
  EndMacro  
  
  ; Check if Char is plus '+' or minus '-'
  ; use it: result = IsPlusMinusChar(MyChar)
  Macro IsPlusMinusChar(MyChar)
    Bool(MyChar ='+' Or MyChar ='-')
  EndMacro  

  ; Check if Char is multiplication '*' or division '/'
  ; use it: result = IsMulDivChar(MyChar)
  Macro IsMulDivChar(MyChar)
    Bool(MyChar ='*' Or MyChar ='/')
  EndMacro  
  
  ;- ----------------------------------------------------------------------
  ;- Macros for COLOR operations
  ;- ----------------------------------------------------------------------
  
  ; Purebasic don't have function so set only one channel of a Color to a new
  ; value. The usual PB Code to set RedChannel to NewValue is:
  ;   Color = RGB(NewRed, Green(Color), Blue(Color))
  
  ; The Get/Set and MakeRGB Macros are up to 30% fastern than PB's Color Functions.
  ; Because PB use Subroutine Calls for Red(), Green(), ... , RGBA(), RGB(),
  ; the PB buildin functions are slower!
  ; To get direct and correct access to the Color Channels according to the 
  ; Systems Color Order, the _SCM.TSystemColorMask Structure is used, which
  ; holds the Masks for the R,G,B,A Channels. To see how this works goto
  ; PB::InitSystemColorMask Function
  
  ; There is a second way to access the ColorChannels correct.
  ; The TSystemColor Structure. If you define a Variable or a Pointer 
  ; of TSystemColor you get multiple and direct access to each Channel 
  ; by name (\RGB\R,G,B,A or number \ch[0..3]) and to the ColorValue 
  ; itself (\col). Then you do not need the Macros!
  
  ; _SCM is a TSystemColorMask Structure
  
  ; Get Red Channel of ColorValue
  ; use it : result = GetRed(ColorValue) 
  Macro GetRed(ColorValue)
    (ColorValue >> PB::_SCM\shRed & $FF) 
  EndMacro
  
  ; Set Red Channel with new value
  ; use it : result = SetRed(ColorValue, NewRedValue) 
  Macro SetRed(ColorValue, NewRed=0)
    (ColorValue & PB::_SCM\maskRedOff) | ((NewRed) << PB::_SCM\shRed)
  EndMacro
  
  ; Get Green Channel of ColorValue
  ; use it : result = GetGreen(ColorValue) 
  Macro GetGreen(ColorValue)
    (ColorValue >> PB::_SCM\shGreen & $FF) 
  EndMacro
  
  ; Set Green Channel with new value
  ; use it : result = SetGreen(ColorValue, NewGreenValue) 
  Macro SetGreen(ColorValue, NewGreen=0)
    (ColorValue & PB::_SCM\maskGreenOff) | ((NewGreen) << PB::_SCM\shGreen)
  EndMacro
  
  ; Get Blue Channel of ColorValue
  ; use it : result = GetBlue(ColorValue) 
  Macro GetBlue(ColorValue)
    (ColorValue >> PB::_SCM\shBlue & $FF) 
  EndMacro
  
  ; Set Blue Channel with new value
  ; use it : result = SetBlue(ColorValue, NewBlueValue) 
  Macro SetBlue(ColorValue, NewBlue=0)
    (ColorValue & PB::_SCM\maskBlueOff) | ((NewBlue) << PB::_SCM\shBlue)
  EndMacro
 
  ; Get Alpha Channel of ColorValue
  ; use it : result = GetBlue(ColorValue) 
  Macro GetAlpha(ColorValue)
    (ColorValue >> PB::_SCM\shAlpha & $FF) 
  EndMacro
  
  ; Set Alpha Channel with new value
  ; use it : result = SetAlpha(ColorValue, NewAlphaValue) 
  Macro SetAlpha(ColorValue, NewAlpha=255)
    (ColorValue & PB::_SCM\maskAlphaOff) | ((NewAlpha) << PB::_SCM\shAlpha)   
  EndMacro
  
  ; Remember: If you use PB's Image drawing functions which use Alpha Channel you
  ; have to Add the Alpha=255 to your Pixels, otherwise you won't see the Image because
  ; it is fully intransparent. This is a very common fault if you are PB beginner!
  ; The SetAlphaIfNull add Alpha=255 if Alpha=0 fully intransparent
  
  ; If Alpha = 0 Then Alpha = 255 
  ; use it : SetAlphaIfNull(varColor) 
  Macro SetAlphaIfNull(varColor)
    If Not (varColor & PB::_SCM\maskAlpha)
      varColor = varColor | PB::_SCM\maskAlpha
    EndIf
  EndMacro
  
  ; make a RGBA color value from Red, Green, Blue, Alpha
  ; use it : result = MakeRGBA(R,G,B,A)
  Macro MakeRGBA(RedValue, GreenValue, BlueValue, AlphaValue = 255)
    (RedValue << PB::_SCM\shRed) | (GreenValue << PB::_SCM\shGreen) | (BlueValue << PB::_SCM\shBlue) | (AlphaValue << PB::_SCM\shAlpha)
  EndMacro
  
  ; make a RGB color value from Red, Green, Blue
  ; use it : result = MakeRGB(R,G,B)
  Macro MakeRGB(RedValue, GreenValue, BlueValue)
    (RedValue << PB::_SCM\shRed) | (GreenValue << PB::_SCM\shGreen) | (BlueValue << PB::_SCM\shBlue)
  EndMacro
  
  ; use it : SaturateColor(MyColorVar)
  Macro SaturateColor(varColor)
    If varColor > 255 
      varColor = 255 
    ElseIf varColor < 0
      varColor = 0 
    EndIf
  EndMacro

  ; Limit the Color value to 255
  ; use it : SaturateColorMax(MyColorVar)
  Macro SaturateColorMax(varColor)
    If varColor > 255 : varColor = 255 : EndIf
  EndMacro
  
  ; Blend  RedVal into ColorVar : Alpha [0..255] is the Blending for Red(ColorVar)
  ; use it : BlendRed(ColorVar, RedVal, Alpha)
  ;     or : BlendRed(ColorVar, Red(MyColor), Alpha)
  Macro BlendRed(ColorVar, RedVal, Alpha=127)
    ColorVar = (ColorVar & PB::_SCM\maskRedOff) | (((Red(ColorVar)* Alpha + RedVal *(255-Alpha))>>8) << PB::_SCM\shRed)
  EndMacro
  
  ; Blend  GreenVal into ColorVar : Alpha [0..255] is the Blending for Green(ColorVar)
  ; use it : BlendGreen(ColorVar, GreenVal, Alpha)
  ;     or : BlendGreen(ColorVar, Green(MyColor), Alpha)
  Macro BlendGreen(ColorVar, GreenVal, Alpha=127)
    ColorVar = (ColorVar & PB::_SCM\maskGreenOff) | (((Green(ColorVar)* Alpha + GreenVal *(255-Alpha))>>8) << PB::_SCM\shGreen)
  EndMacro
  
  ; Blend  BlueVal into ColorVar : Alpha [0..255] is the Blending for Blue(ColorVar)
  ; use it : BlendBlue(ColorVar, BlueVal, Alpha)
  ;     or : BlendBlue(ColorVar, Blue(MyColor), Alpha)
  Macro BlendBlue(ColorVar, BlueVal, Alpha=127)
    ColorVar = (ColorVar & PB::_SCM\maskBlueOff) | (((Blue(ColorVar)* Alpha + BlueVal *(255-Alpha))>>8) << PB::_SCM\shBlue)
  EndMacro
  
  ; Blend 2 Colors and Return blended value
  ; use it : result = BlendColors(Color1, Color2, Alpha) : Alpha is the factor for COL1
  Macro BlendColors(COL1, COL2, Alpha=127)   
    ((((Red(COL1)*Alpha + Red(COL2)*(255-Alpha))>>8)<< PB::_SCM\shRed) | (((Green(COL1)*Alpha + Green(COL2)*(255-Alpha))>>8)<< PB::_SCM\shGreen) | (((Blue(COL1)*Alpha + Blue(COL2)*(255-Alpha))>>8)<< PB::_SCM\shBlue))
  EndMacro
  
  ; Methode                 | Weight Base %              | Weight Base 1024 for >>10 use
  ; ------------------------|----------------------------|------------------------------
  ; Greyscale_Average       | (33.3, 33.3, 33.3)% =99.9  | (341, 341, 341) =1023 = 99.9%
  ; Greyscale_Standard      | (29.9, 58.7, 11.4)% =100   | (306, 601, 117) =1024 = 100%
  ; Greyscale_WeightedLight | (30.9, 60.9,  8.2)% =100   | (316, 624,  84) =1024 = 100%

  ; R = 333  ; factor = 0.333 we use integer multiplikation *1024>>10 
  ; G = 333
  ; B = 333
  Macro GreyScaleAverage(ColorValue)
    (Red(ColorValue)341 + Green(ColorValue)341 + Blue(ColorValue)341)>>10)
  EndMacro
  
  ; R = 299
  ; G = 587
  ; B = 114
  Macro GreyScaleStandard(ColorValue)
    (Red(ColorValue)306 + Green(ColorValue)*601 + Blue(ColorValue)117)>>10)
  EndMacro
  
  ; R = 309
  ; G = 609
  ; B =  82
  Macro GreyScaleWeightedLight(ColorValue)
    (Red(ColorValue)*316 + Green(ColorValue)*624 + Blue(ColorValue)*84)>>10)
  EndMacro

  ;- ----------------------------------------------------------------------
  ;- Abs() Macros to solve C-Backend 53-Bit-Abs() Problem
  ;- ----------------------------------------------------------------------
 
  ; AbsI() and AbsQ() solve tha PB's ABS() Problem at C-Backend with 53-Bit only!
  ; In ASM Backend the 80Bit Float unit is used for ABS() what works perfect for 64Bit INT.
  ; In C-Backend a MMX Version is used for ABS(). This is a problem because MMX use only 64Bit Floats
  ; with a manitassa of 53 Bits. This will cause bugs using ABs() for values >53 Bits!
  
  ; This is the optimized Abs Version (translated from Assembler to PB-Code; Soure: Math.asm from Linux Asm Project
  ; X!(X>>63)-(X>>63) ; x64
  ; X!(X>>31)-(X>>31) ; x32
  
   
  ; PB 6.04 on Ryzen 5800 the Macro is nearly same speed as PB's ABS()
  ; ASM BAckend: For 100Mio calls (50% with -X and 50% with +X) :  PB_ABS() = 53ms  AbsI() = 58ms
  CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
    Macro AbsI(IntValue)
      Abs(IntValue)
    EndMacro
  CompilerElse  ; C-Backend
    Macro AbsI(IntValue)
      (IntValue ! (IntValue >> PB::#PB_MaxBitNo) - (IntValue >> PB::#PB_MaxBitNo))
    EndMacro
  CompilerEndIf
  
  ; only for x32 we need an extra Macro for AbsQ() which shifts 63 Bit for Quads
  CompilerIf (#PB_Compiler_Backend = #PB_Backend_Asm)
    Macro AbsQ(QuadValue)
      Abs(QuadValue)
    EndMacro
  CompilerElse  ; C-Backend or 32Bit Processor
    Macro AbsQ(QuadValue)
      (QuadValue ! (QuadValue >>63)-(QuadValue >>63))
    EndMacro
  CompilerEndIf
  
  ;- ----------------------------------------------------------------------
  ;-  RTC: RealTimeCounter & HighPerformanceTimer
  ;- ----------------------------------------------------------------------
  
  ; --------------------------------------------------
  ; Test results: i.O.
  ; --------------------------------------------------
  ;
  ; Intel/AMD            | Date       | by Name
  ; --------------------------------------------------
  ; Windows x64, PBx32   | 2024/08/27 | SMaag
  ; Windows x64, PBx64   | 2024/08/27 | SMaag
  ; Windows x32, PBx32   |            |
  
  ; Linux x64, PBx32     |            |
  ; Linux x64, PBx64     |            |
  ; Linux x32, PBx32
  
  ; MaxOS x64, PBx32     |            |
  ; MaxOS x64, PBx64     |            |
  
  ; --------------------------------------------------
  ; ARM                  | Date       | by Name
  ; --------------------------------------------------
  ; RaspII x32           |            |
  ; RaspII x64           |            |
  ; MaxOS x64, PBx32     |            |
  ; MaxOS x64, PBx64     |            |
  ; --------------------------------------------------
 
  ; Constans for the RTC 16x RealTimeCounter/HighPerformanceTimer
  #PB_RTC_STOP = 0       ; STOP Timer and return the time difference since start
  #PB_RTC_START = 1      ; START Timer and return the StartValue in MicroSeconds or NanoSeconds
  #PB_RTC_READ = 2       ; Read the time value [µs] (if Timer is stopped, it's the differntial time. If timer is started it is the START-Time)
  
  #PB_RTC_MicroSeconds = 0
  #PB_RTC_NanoSeconds = 1
  
  #PB_RTC_MaxTimerNo = 15          ; Timers [0..#PB_RTC_MaxTimerNo]  = [0..15]! Change this value if you need more Timers
  
  Structure TDateAndTime        ; DateAndTime Structure to convert a TimeStamp
    wYear.w
    wMonth.w
    wDay.w
    wHour.w
    wMinute.w
    wSecond.w
    wMilliseconds.w
  EndStructure
  
  Structure TRTC                ; Structure to hold the Timer datas
    T.q[#PB_RTC_MaxTimerNo+1]      ; Timer Value
    xRun.i[#PB_RTC_MaxTimerNo+1]   ; Timer Run-State : #False = Stop, #True = Run
  EndStructure
  
  ; Basic Functions
  Declare.i GetRtcResolution_ns()     ; Get the NanoSeconds per TickCount : >0 if CPU and OS support RTC Function
  Declare.q ElapsedMicroseconds()     ; Elapsed MicorSeconds
  Declare.q ElapsedNanoseconds()      ; Elapsed NanoSeconds
  
  ; TimeStamp Functions
  Declare.q GetTimeStamp()            ; Get Date with ms precision : TimeStamp = Date()*1000 + ms
  Declare.i TimeStampToDateAndTime(*OutDT.TDateAndTime, Timestamp.q)
  Declare.s TimeStampToString(TimeStamp.q, Format$="%yyyy/%mm/%dd-%hh:%mm:%ss")
  
  ; High Performance Timer
  Declare.q RTC(TimerNo=0, cmd=#PB_RTC_START, TimeBase=#PB_RTC_MicroSeconds)
  Declare.q RTCcal()                    ; calibarte Timer (calculate Timer Start/Stop Time for clibartion)
  Declare.i RTCget(*RTCstruct.TRTC)     ; Get a copy of the internal TimerStrucure with actual values
  
  ; --------------------------------------------------
  ; Split and Join
  ; -------------------------------------------------- 

  Prototype SplitStringArray(Array Out.s(1), String$, Separator$, ArrayRedimStep=10)
  Global SplitStringArray.SplitStringArray
  
  Prototype SplitStringList(List Out.s(), String$, Separator$, clrList= #True)
  Global SplitStringList.SplitStringList
    
  Declare.s JoinArray(Array ary.s(1), Separator$, EndIndex=-1, StartIndex=0, *IOutLen.Integer=0)
  Declare.s JoinList(List lst.s(), Separator$, *IOutLen.Integer=0)  

EndDeclareModule

Module PB
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  #_MicroBase = 1e6     ;     1.000.000 = 1MHz
  #_NanoBase  = 1e9     ; 1.000.000.000 = 1GHz
   
  ; ----------------------------------------------------------------------
  ;  Import OS specific functions
  ; ----------------------------------------------------------------------
  CompilerSelect #PB_Compiler_OS
      
    CompilerCase #PB_OS_Windows 
    ; ----------------------------------------------------------------------
    ;  Windows
    ; ----------------------------------------------------------------------
    ; QueryPerformanceFrequency() : Bool
    ;     Retrieves the frequency of the performance counter.
    ;     The frequency of the performance counter is fixed at system boot
    ;     and is consistent across all processors.
    ;     Therefore, the frequency need only be queried upon application initialization,
    ;     and the result can be cached.
      
    ; QueryPerformanceCounter-Funktion() : Bool
    ;     Retrieves the current value of the performance counter, which is a high 
    ;     resolution (<1us) time stamp that can be used For time-interval measurements.
      
    CompilerCase #PB_OS_Linux 
    ; ----------------------------------------------------------------------
    ;  Linux
    ; ----------------------------------------------------------------------
     
   		;#CLOCK_REALTIME           = 0
     		; System-wide clock that measures real (i.e., wall-clock) time. 
        ; Setting this clock requires appropriate privileges.
        ; This clock is affected by discontinuous jumps in the system time
        ;(e.g., If the system administrator manually changes the clock), 
        ; And by the incremental adjustments performed by adjtime(3) And NTP.
   		#CLOCK_MONOTONIC          = 1
     		; Clock that cannot be set and represents monotonic time since some
        ; unspecified starting point. This clock is not affected by discontinuous:
        ; jumps in the system time (e.g., If the system administrator manually;
        ; changes the clock), but is affected by the incremental adjustments 
     		; performed by adjtime(3) And NTP. 

   		;#CLOCK_PROCESS_CPUTIME_ID = 2
   		  ; High-resolution per-process timer from the CPU. 
   		
   		;#CLOCK_THREAD_CPUTIME_ID  = 3
   		  ; Thread-specific CPU-time clock.
   		
   		;#CLOCK_REALTIME_HR        = 4
  		;#CLOCK_MONOTONIC_HR       = 5
    	;#CLOCK_MONOTONIC_COARSE	  = 6
    	;#CLOCK_BOOTTIME			      = 7
    	;#CLOCK_REALTIME_ALARM		  = 8
    	;#CLOCK_BOOTTIME_ALARM		  = 9
    	
;     	struct timespec {
;     	  time_t		tv_sec
;     	  long		tv_nsec 
   		

   		; TODO! Check if correct in x32 and x64, because time_t is more or less an unspecified type! 		
      Structure timespec
        tv_sec.i            
        tv_nsec.i
      EndStructure     
      
      ; struct timeval {
      ;        time_t       tv_sec;   /* seconds since Jan. 1, 1970 */
      ;        suseconds_t  tv_usec;  /* and microseconds */
      ; 
      
      Structure timeval
        tv_sec.i    ; seconds since Jan. 1, 1970 - that's indentical with PB Date
        tv_usec.i   ; and microseconds
      EndStructure
      
      ; struct timezone {
      ;        int     tz_minuteswest; /* of Greenwich */
      ;        int     tz_dsttime;     /* type of dst correction to apply */
      
      Structure timezone
        tz_minuteswest.i 
        tz_dsttime.i
      EndStructure
      
      ; gettimeofday(struct timeval *restrict tp, void *restrict tzp);
        
      ImportC ""
       ; all functions return 0 for succeeded and -1 for error on Linux
       ; clock_gettime(), clock_getres() return 0 for success, Or -1 for failure
        clock_getres.i (clock_id.i, *res.timespec)
        clock_gettime.i(clock_id.i, *tp.timespec)
        
        ; gettimeofday(struct timeval *restrict tp, void *restrict tzp);
        gettimeofday(*tp.timeval, *tzp.timezone)      
      EndImport
           
    CompilerCase #PB_OS_MacOS     
    ; ----------------------------------------------------------------------
    ;  MacOS
    ; ----------------------------------------------------------------------
      
      ; https://developer.apple.com/documentation/driverkit/3433733-mach_timebase_info
            
      ; mach_timebase_info: Returns fraction To multiply a value in mach tick units with to convert it to nanoseconds
      ;   uint64_t mach_absolute_time(void);
      
      ; mach_absolute_time: Returns current value of a clock that increments monotonically in tick units
      ;   (starting at an arbitrary point), this clock does not increment while the system is asleep.
      ;   kern_return_t mach_timebase_info(mach_timebase_info_data_t info);
      
      ; mach_continuous_time
      ;   Returns current value of a clock that increments monotonically in tick units
      ;   (starting at an arbitrary point), including while the system is asleep.
      
      Structure mach_timespec
        tv_sec.i    ; unsigned int tv_sec;
        tv_nsec.i   ; typedef int clock_res_t;
      EndStructure
      
      ; mach_timebase_info_data_t
      ; Raw Mach Time API In general prefer to use the <time.h> API clock_gettime_nsec_np(3),
      ; which deals in the same clocks (And more) in ns units. Conversion of ns To (resp. from)
      ; tick units As returned by the mach time APIs is performed by division (resp. multiplication)
      ; with the fraction returned by mach_timebase_info().
      
      Structure mach_timebase_info_data_t
        numer.l     ; uint32_t numer;
        denom.l     ; uint32_t denom;
      EndStructure     
      
      ; struct timeval {
      ;        time_t       tv_sec;   /* seconds since Jan. 1, 1970 */
      ;        suseconds_t  tv_usec;  /* and microseconds */
      ; 
            
      Structure timeval
        tv_sec.i    ; seconds since Jan. 1, 1970  - that's indentical with PB Date
        tv_usec.i   ; and microseconds
      EndStructure
      
      ; struct timezone {
      ;        int     tz_minuteswest; /* of Greenwich */
      ;        int     tz_dsttime;     /* type of dst correction to apply */
      
      Structure timezone
        tz_minuteswest .i 
        tz_dsttime.i
      EndStructure
      
      ; gettimeofday(struct timeval *restrict tp, void *restrict tzp);
      
      ImportC ""
        ; all functions return 0 for succeeded and -1 for error on MacOS
        mach_timebase_info.i(*info.TMac_mach_timbase_info_t)
        mach_absolute_time.q()      ; counter stops in sleep mode
        mach_continuous_time.q()    ; counter works in sleep mode
        
        ; gettimeofday(struct timeval *restrict tp, void *restrict tzp);
        gettimeofday(*tp.timeval, *tzp.timezone)
      EndImport
      
  CompilerEndSelect
  
  ; Variable for RTC resolution in NanoSeconds (1 Tick = rtcRes_ns NanoSeconds) (on Ryzen 5800 this is 100)
  ; on Windows this is (1.000.000.000 / QueryPerformanceFrequnecy())
  Global.i _rtcRes_ns 
            
  Procedure.i GetRtcResolution_ns()
  ; ============================================================================
  ; NAME: GetRtcResolution_ns
  ; DESC: Returns the TickResolution in NanoSeconds per Tick
  ; DESC: Call this function first to check RTC support
  ; RET.i : NanoSeconds per Tick or 0 if RTC is not supported
  ; ============================================================================
    
    ; according to the Windows documentation of QueryPerformanceFrequency we can init once and store value!
    ; "The frequency of the performance counter is fixed at system boot and is consistent across all processors."

    _rtcRes_ns = 0    ; Set RealTimeCounter resolution = 0
    
    CompilerSelect #PB_Compiler_OS
        
      CompilerCase #PB_OS_Windows
      ; ----------------------------------------------------------------------
      ;  Windows
      ; ----------------------------------------------------------------------
        Protected v.q 
        
        If QueryPerformanceFrequency_(@v) 
          If v                             
            _rtcRes_ns = #_NanoBase / v
          EndIf          
        EndIf                
        ProcedureReturn _rtcRes_ns
        
      CompilerCase #PB_OS_Linux
      ; ----------------------------------------------------------------------
      ;  Linux
      ; ----------------------------------------------------------------------
        Protected v.timespec
        Protected ret
        
        ; return 0 for success! On error, -1 is returned and errno is set To indicate the error
        ret = clock_getres(#CLOCK_MONOTONIC,@v)
        
        If ret = 0      ; sucess
          ;TODO! Check this!
          ; as I understand, Linux delivers in v\tv_nsec the NanoSeconds per Tick
          ; but I'm not sure!
          _rtcRes_ns =  v\tv_nsec          
        EndIf
        ProcedureReturn _rtcRes_ns       
                         
      CompilerCase #PB_OS_MacOS
      ; ----------------------------------------------------------------------
      ;  MacOS
      ; ----------------------------------------------------------------------
        Protected v.mach_timebase_info_data_t
        Protected resq.q
        Protected kern_return_t     ; MacOs kernel_return value
        
        kern_return_t = mach_timebase_info(@v)
        
        If kern_return_t
          ; to be sure to not get problems at x32 we caclulate resultion in Quad first 
          resq =  (#_NanoBase * v\denom) / v\numer  ; calculate resolution in Quad
          _rtcRes_ns = res
        EndIf
        ProcedureReturn _rtcRes_ns       
               
    CompilerEndSelect
  EndProcedure
  _rtcRes_ns = GetRtcResolution_ns()    ; AutoInit rtcRes_ns
      
  Procedure.q ElapsedMicroseconds()
  ; ============================================================================
  ; NAME: ElapsedMicroSeconds
  ; DESC: Returns a value for ElapsedMicroSeconds starting at unspecific point
  ; RET.q : Elapsed MicroSeconds
  ; ============================================================================
    
    CompilerSelect #PB_Compiler_OS
        
      CompilerCase #PB_OS_Windows
      ; ----------------------------------------------------------------------
      ;  Windows
      ; ----------------------------------------------------------------------
        Protected v.Quad
        QueryPerformanceCounter_(v)      
        ; MicroSeconds = CounterTicks * ResolutionNanoSeconds / 1000
        ProcedureReturn (v\q * _rtcRes_ns) / 1000  ; normalize value to MicroSeconds
         
      CompilerCase #PB_OS_Linux
      ; ----------------------------------------------------------------------
      ;  Linux
      ; ----------------------------------------------------------------------
        Protected v.timespec
        clock_gettime(#CLOCK_MONOTONIC, @v)
        
        ProcedureReturn (v\tv_sec * #_MicroBase)  + v\tv_nsec / 1000
                
      CompilerCase #PB_OS_MacOS
      ; ----------------------------------------------------------------------
      ;  MacOS
      ; ----------------------------------------------------------------------
        Protected v.q
        v = mach_absolute_time()      ; stop in sleep mode
        ;v = mach_continuous_time()    ; countinous count in sleep mode

        ProcedureReturn (v * _rtcRes_ns) / 1000
       
    CompilerEndSelect
  
  EndProcedure
  
  Procedure.q ElapsedNanoseconds()
  ; ============================================================================
  ; NAME: ElapsedNanoSeconds
  ; DESC: Returns a value for ElapsedNanoSeconds starting at unspecific point
  ; RET.q : Elapsed NanoSeconds
  ; ============================================================================
   
    CompilerSelect #PB_Compiler_OS
        
      CompilerCase #PB_OS_Windows
      ; ----------------------------------------------------------------------
      ;  Windows
      ; ----------------------------------------------------------------------
       Protected v.Quad
        QueryPerformanceCounter_(v)      
        ; MicroSeconds = CounterTicks * ResolutionNanoSeconds / 1000
        ; Debug "QueryPerformanceCounter = " + Str(v\q)
        ProcedureReturn (v\q * _rtcRes_ns) 
         
      CompilerCase #PB_OS_Linux
      ; ----------------------------------------------------------------------
      ;  Linux
      ; ----------------------------------------------------------------------
        Protected v.timespec
        clock_gettime(#CLOCK_MONOTONIC, @v)
        
        ProcedureReturn (v\tv_sec * #_NanoBase)  + v\tv_nsec
                
      CompilerCase #PB_OS_MacOS
      ; ----------------------------------------------------------------------
      ;  MacOS
      ; ----------------------------------------------------------------------
        Protected v.q
        v = mach_absolute_time()      ; stop in sleep mode
        ;v = mach_continuous_time()  ; countinous count in sleep mode

        ProcedureReturn (v * _rtcRes_ns)
        
    CompilerEndSelect
  EndProcedure
  
  Procedure.q GetTimeStamp()
  ; ============================================================================
  ; NAME: GetTimeStamp
  ; DESC: Get Date with [ms] precision as Timestamp of UTC-Time (Greenwich Mean Time)
  ; DESC: Because PB do not support milliseconds in the Date() format, we
  ; DESC: have to read manualy the Sytem Time with high precision!
  ; DESC: To get get back a valid PB-Date   : Date= TimeStap/1000
  ; DESC: To get back the ms from TimeStamp : ms= TimpeStamp%1000    
  ; RET.q : The Date with millisecond precision : Date()*1000 + ms
  ; ============================================================================
    Protected tstmp.q    ; Timestamp
    
    ; ----------------------------------------------------------------------
    ; ts = (Date() * 1000) + (ElapsedMicroseconds()/1000) % 1000
    ; ----------------------------------------------------------------------
    ; this easy Methode don't work because the ms are not sychron with 
    ; the seconds. So many times we will get a lower time later!
    ; ----------------------------------------------------------------------    
    
    ; !We have to read the CPU System Clock with ms precision!
    
    CompilerSelect #PB_Compiler_OS
        
      CompilerCase #PB_OS_Windows
      ; ----------------------------------------------------------------------
      ;  Windows
      ; ----------------------------------------------------------------------
        Protected dt.SYSTEMTIME   ; Date and Time
        
        ; Structure SYSTEMTIME    ; predefined in PB
        ;   wYear.w
        ;   wMonth.w
        ;   wDayOfWeek.w
        ;   wDay.w
        ;   wHour.w
        ;   wMinute.w
        ;   wSecond.w
        ;   wMilliseconds.w
        ; EndStructure
        
        ; changed to UTC Time because on Mac/Linux gettimeofday delivers UTC-Time 
        GetSystemTime_(@dt)     ; SystemTime - UTC()
        ; GetLocalTime_(@dt)    ; SystemTime - LocalTime
        With dt
          tstmp = Date(\wYear, \wMonth, \wDay, \wHour, \wMinute, \wSecond) * 1000 + dt\wMilliseconds
        EndWith
        
      CompilerCase #PB_OS_Linux
      ; ----------------------------------------------------------------------
      ;  Linux
      ; ----------------------------------------------------------------------
       Protected tim.timeval, tz.timezone
       
       ;gettimeofday(*tp.timeval, *tzp.timezone)
       gettimeofday(@tim, @tz)
       tstmp = tim\tv_sec *1000 + tim\tv_usec /1000   ; add milliseconds = microseconds /1000
                
      CompilerCase #PB_OS_MacOS
      ; ----------------------------------------------------------------------
      ;  MacOS
      ; ----------------------------------------------------------------------
        Protected tim.timeval, tz.timezone
        
        ;gettimeofday(*tp.timeval, *tzp.timezone)
        gettimeofday(@tim, @tz)
        tstmp = tim\tv_sec *1000 + tim\tv_usec /1000   ; add milliseconds = microseconds /1000
    CompilerEndSelect
    
    ProcedureReturn tstmp
  EndProcedure
  
  Procedure.i TimeStampToDateAndTime(*OutDT.TDateAndTime, Timestamp.q)
  ; ============================================================================
  ; NAME: TimpeStampToDateAndTime
  ; DESC: Converts the ms based TimeStamp to a DateAndTime Structure
  ; DESC: 
  ; VAR(*OutDT.TDateAndTime) : Pointer to the returned DateAndTime Structrue
  ; VAR(Timestamp.q) : The ms based Timestamp value
  ; RET.i : *OutDT
  ; ============================================================================
   If *OutDT
      With *OutDT
        \wMilliseconds = Timestamp % 1000
        
        Timestamp = Timestamp / 1000  ; Now Timestamp is the second based PB Date
        
        \wYear   = Year(Timestamp)
        \wMonth  = Month(Timestamp)
        \wDay    = Day(Timestamp)
        \wHour   = Hour(Timestamp)
        \wMinute = Minute(Timestamp)
        \wSecond = Second(Timestamp)
     EndWith
    EndIf
    
    ProcedureReturn *OutDT
  EndProcedure
  
  Procedure.s TimeStampToString(TimeStamp.q, FormatDate$="%yyyy/%mm/%dd-%hh:%mm:%ss")
  ; ============================================================================
  ; NAME: TimeStampToString
  ; DESC: Converts the ms based TimeStamp to a formated String
  ; DESC: 
  ; VAR(Timestamp.q) : The ms based Timestamp value
  ; VAR(Format$): The Format String for PB's FormatDate()
  ; RET.s : Formated Date + ":Milliseconds"
  ; ============================================================================
    
    Protected txt.s
    Protected vDate.q = TimeStamp / 1000
        
    txt = FormatDate(FormatDate$, vDate) 
    txt + ":" + Str(TimeStamp % 1000)
    ProcedureReturn txt   
  EndProcedure
     
  ; private vars
  Global _RTC.TRTC  ; TimerValues Structure for Timers [0..#PB_RTC_MaxTimerNo]
  Global _RTC_Calibration.q  ; calibration ticks : Time for calling RTC() in NanoSeconds
  
  Procedure.q RTC(TimerNo=0, cmd=#PB_RTC_START, TimeBase=#PB_RTC_MicroSeconds)
  ; ============================================================================
  ; NAME: RTC
  ; DESC: RealTimeCounter/HighPerformanceTimer, MultiTimer
  ; DESC: Provides a set of easy to use timers for software speed tests!
  ; VAR(TimerNo) : No of the Timer [0..#PB_RTC_MaxTimerNo]
  ; VAR(cmd) : #PB_RTC_START, #PB_RTC_STOP, #PB_RTC_READ
  ; VAR(TimeBase) : #PB_RTC_NanoSeconds, #PB_RTC_MicroSeconds
  ; RET.q : Elapsed Time according to TimerNo
  ; ============================================================================
         
    If TimerNo <0 Or TimerNo > #PB_RTC_MaxTimerNo
      ProcedureReturn -1
    EndIf
    
    Select cmd
        
      Case #PB_RTC_START       ; START Timer --> save actual value of QueryPerformanceCounter in DataSection
      ; ----------------------------------------------------------------------
      ;  Start the Timer
      ; ----------------------------------------------------------------------
        
        _RTC\T[TimerNo] = ElapsedNanoseconds()        
        _RTC\xRun[TimerNo] = #True         ; Set Run State = #True
        
        If TimeBase = #PB_RTC_MicroSeconds
          ProcedureReturn _RTC\T[TimerNo] / 1000
        Else        ; #PB_RTC_NanoSeconds
          ProcedureReturn _RTC\T[TimerNo]
        EndIf
         
      Case #PB_RTC_STOP        ; STOP Timer
      ; ----------------------------------------------------------------------
      ;  Stop the Timer
      ; ----------------------------------------------------------------------
        
        _RTC\T[TimerNo] = ElapsedNanoseconds() - _RTC\T[TimerNo] - _RTC_Calibration
  
        If _RTC\T[TimerNo] < 0           ; Abs() because PB's Abs() is for floats only
          _RTC\T[TimerNo] = - _RTC\T[TimerNo] 
        EndIf
        
        _RTC\xRun[TimerNo] = #False      ; Set Run State = #False 
        If TimeBase = #PB_RTC_MicroSeconds
          ProcedureReturn _RTC\T[TimerNo] / 1000
        Else        ; #PB_RTC_NanoSeconds
          ProcedureReturn _RTC\T[TimerNo]
        EndIf
        
      Case #PB_RTC_READ
      ; ----------------------------------------------------------------------
      ;  Read the Timer
      ; ----------------------------------------------------------------------
        Protected ret.q
        
        If _RTC\xRun[TimerNo]
          ret = ElapsedNanoseconds() - _RTC\T[TimerNo] - _RTC_Calibration
          If ret < 0 : ret = -ret : EndIf      
        Else
          ret= _RTC\T[TimerNo]
        EndIf
        
        If TimeBase = #PB_RTC_MicroSeconds
          ProcedureReturn _RTC\T[TimerNo] / 1000
        Else        ; #PB_RTC_NanoSeconds
          ProcedureReturn _RTC\T[TimerNo]
        EndIf
               
    EndSelect
         
  EndProcedure
  
  Procedure.q RTCcal()
  ; ============================================================================
  ; NAME: RTCcal
  ; DESC: RTC calibration routine to test the offset for a Timer START/STOP call 
  ; DESC: After a call of RTCcal() the Calibration offset will be automatically
  ; DESC: subtracted from the Time when reading a Timer.
  ; DESC: If you do not call RTCcal() the calibration value is 0ns and
  ; DESC: you get the uncalibrated TimeValue when reading a Timer.
  ; DESC: For calibration Timer(#PB_RTC_MaxTimerNo) is used.
  ; DESC: So don't cal RTCcal() if this Timer is in operation!
  ; RET.q : Calibration offset for a Timer START/STOP call
  ; ============================================================================
    Protected tim.q
    
    ; detecet the Time for a Timer Start/STOP Call
    tim = ElapsedNanoseconds()
    RTC(#PB_RTC_START, #PB_RTC_MaxTimerNo, #PB_RTC_NanoSeconds)   
    RTC(#PB_RTC_STOP, #PB_RTC_MaxTimerNo, #PB_RTC_NanoSeconds)
    tim = ElapsedNanoseconds() - tim
    If tim <0 : tim = -tim : EndIf 
    
    _RTC_Calibration = tim
    ProcedureReturn tim     ; No of Ticks at QueryPerformanceFrequency
  EndProcedure
  
  Procedure.i RTCget(*RTCstruct.TRTC)
  ; ============================================================================
  ; NAME: RTCget
  ; DESC: Get all the internal Timer values in a TRTC Structure
  ; VAR(*RTCstruct.THP) : Pointer to Return Structure
  ; RET.i : *RTCstruct
  ; ============================================================================
    If *RTCstruct
      *RTCstruct = _RTC  
    EndIf
    
    ProcedureReturn *RTCstruct  
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;-  Implementation of Color Functions
  ;- ----------------------------------------------------------------------
  
  Procedure.i InitSytemColorMask(*SCM.TSystemColorMask)
  ; ============================================================================
  ; NAME: IntiSytemColorMask
  ; DESC: initialize a TSystemColorMask Structure with the correct management
  ; DESC: data for the systmens Color order RGBA, ABGR
  ; VAR(*SCM.TSystemColorMask): The SystemColorMask variable to initialize
  ; RET.i : *SCM
  ; ============================================================================
    Protected SysCol.TSystemColor                
    Protected.a rd, gn, bl, al    ; the standard Color oder in Memory
    Protected I, CHval
    
    ; first initialize an unique value for each ColorChannel r,g,b,a 
    rd =$11 : gn =$22 : bl =$33 : al =$44
    
    SysCol\col =RGBA(rd,gn,bl,al) ; Create the ColorValue with the unique Channel values
    
    If *SCM
      With *SCM
        ; Step 1 : step trough the 4 Bytes of the created Color and
        ; compare the value in memory with the unique Channel values
        For I = 0 To 3
          Select SysCol\ch[I] ; Access to Color with ChannelNo [0..3]
            Case rd           ; unique value for Red channel found
              \idxRed = I     ; save index for Red
            Case gn           ; unique value for Green channel found
              \idxGreen = I   ; save index for Green
             Case bl          ; unique value for Blue channel found
              \idxBlue = I    ; save index for Blue  
           Case al            ; unique value for Alpha channel found
              \idxAlpha = I   ; save index for Alpha
          EndSelect     
        Next
        
        ; Step 2 : Caluclate the Bits to Shift for each Channel       
        \shRed   = \idxRed *8
        \shGreen = \idxGreen *8
        \shBlue  = \idxBlue *8
        \shAlpha = \idxAlpha *8
        
        ; Step 3 : Calculate BitMask to filter each Channel  
        \maskRed   = ($FF << \shRed)
        \maskGreen = ($FF << \shGreen)
        \maskBlue  = ($FF << \shBlue)
        \maskAlpha = ($FF << \shAlpha)
        
        ; Step 4 : Calculate BitMask to Reset Channel to 0  
        \maskRedOff   = ~\maskRed   & $FFFFFFFF   ; limit to 32Bit
        \maskGreenOff = ~\maskGreen & $FFFFFFFF
        \maskBlueOff  = ~\maskBlue  & $FFFFFFFF
        \maskAlphaOff = ~\maskAlpha & $FFFFFFFF   
      EndWith
    EndIf
    
    ; Debug the ColorChannel Order and the Pointers to the Structure Elements
    ; IDENTICAL POINTERS FOR: 
    ;   @TSystemColor= @TSystemColor\col= @TSystemColor\RGB = @TSystemColor\RGB\R = @TSystemColor\ch[0]

    With SysCol
      Debug "------------------------------"
      Debug "PB::InitSytemColorMask"
      Debug "Red-Channel = " + _SCM\idxRed
      Debug "Green-Channel = " + _SCM\idxGreen
      Debug "Blue-Channel = " + _SCM\idxBlue
      Debug "Alpha-Channel = " + _SCM\idxAlpha
      
      Debug "Pointers of TSystemColor Structure"
      Debug "@SysCol =" + @SysCol
      Debug "@SysCol\col =" +@\col
      Debug "@SysCol\ch[0] =" +@\ch[0]
      Debug "@SysCol\RGB =" + @\RGB
      Debug "@SysCol\RGB\R =" +@\RGB\R
      Debug ""
      Debug "@SysCol\RGB\G =" +@\RGB\G
      Debug "@SysCol\RGB\B =" +@\RGB\B
      Debug "@SysCol\RGB\A =" +@\RGB\A
      Debug "------------------------------"
    EndWith
    
    ; Show Error Message for programmer, if the Color Order does not fit together"
    With SysCol
      If \RGB\R <> rd Or \RGB\G <> gn Or \RGB\B <> bl Or \RGB\A <> al
        MessageRequester("Purebasic Framework: Error in Modul: " + #PB_Compiler_Module + "/" + #PB_Compiler_Procedure, "The System Color order does not fit with the programmed one in TSystemColor")   
      EndIf
    EndWith
    
    ProcedureReturn *SCM
  EndProcedure
  
  ;- --------------------------------------------------
  ;-  Split and Join
  ;- -------------------------------------------------- 
  
  Procedure.i _SplitStringArray(Array Out.s(1), *String, *Separator, ArrayRedimStep=10)
   ; ============================================================================
    ; NAME: _SplitStringArray
    ; DESC: Split a String into multiple Strings
    ; DESC: 
    ; VAR(Out.s()) : Array to return the Substrings 
    ; VAR(*String) : Pointer to String 
    ; VAR(*Separator) : Pointer to mulit Char Separator 
    ; RET.i : No of Substrings
    ; ============================================================================
    
    Protected *ptrString.Character = *String          ; Pointer to String
    Protected *ptrSeperator.Character = *Separator    ; Pointer to Separator
    Protected *Start.Character = *String              ; Pointer to Start of SubString    
    Protected xEqual, lenSep, N, ASize, L
     
    lenSep = MemoryStringLength(*Separator)           ; Length of Separator
     
    ASize = ArraySize(Out())
     
    While *ptrString\c
    ; ----------------------------------------------------------------------
    ;  Outer Loop: Stepping trough *String
    ; ----------------------------------------------------------------------
      
      If  *ptrString\c = *ptrSeperator\c ; 1st Character of Seperator in String   
        ; Debug "Equal : " +  Chr(*ptrString\c)
        
        xEqual =#True
        
        While *ptrSeperator\c
        ; ------------------------------------------------------------------
        ;  Inner Loop: Char by Char compare Separator with String
        ; ------------------------------------------------------------------
          If *ptrString\c
            If *ptrString\c <> *ptrSeperator\c
              xEqual = #False     ; Not Equal
              Break               ; Exit While
            EndIf
          Else 
            xEqual =#False        ; Not Equal
            Break                 ; Exit While
          EndIf
          *ptrSeperator + SizeOf(Character)  ; NextChar Separator
          *ptrString + SizeOf(Character)     ; NextChar String  
        Wend
        
        ; If we found the complete Separator in String
        If xEqual
          ; Length of the String from Start up to Separator
          L =  (*ptrString - *Start)/SizeOf(Character) - lenSep 
          Out(N) = PeekS(*Start, L)
          *Start = *ptrString             ; the New Startposition
          ; Debug "Start\c= " + Str(*Start\c) + " : " + Chr(*Start\c)
          *ptrString - SizeOf(Character)  ; bo back 1 char to detected double single separators like ,,
           N + 1   
           If ASize < N
             ASize + ArrayRedimStep
             ReDim Out(ASize)
           EndIf      
        EndIf
        
      EndIf   
      *ptrSeperator = *Separator            ; Reset Pointer of Seperator to 1st Char
      *ptrString + SizeOf(Character)        ; NextChar in String
    Wend
   
    Out(N) = PeekS(*Start)  ; Part after the last Separator
    ProcedureReturn N+1     ; Number of Substrings
        
  EndProcedure
  SplitStringArray = @_SplitStringArray()   ; Bind ProcedureAddress to Prototype
  
  Procedure.i _SplitStringList(List Out.s(), *String, *Separator, clrList= #True)
   ; ============================================================================
    ; NAME: _SplitStringList
    ; DESC: Split a String into multiple Strings
    ; DESC: 
    ; VAR(Out.s())   : List to return the Substrings 
    ; VAR(*String)   : Pointer to String 
    ; VAR(*Separator): Pointer to Separator String 
    ; VAR(clrList)   : #False: Append Splits to List; #True: Clear List first
    ; RET.i          : No of Substrings
    ; ============================================================================
    
    Protected *ptrString.Character = *String          ; Pointer to String
    Protected *ptrSeperator.Character = *Separator    ; Pointer to Separator
    Protected *Start.Character = *String              ; Pointer to Start of SubString   
    Protected xEqual, lenSep, N, L
      
    lenSep = MemoryStringLength(*Separator)           ; Length of Separator
    
    If clrList
      ClearList(Out())  
    EndIf
    
    While *ptrString\c
    ; ----------------------------------------------------------------------
    ;  Outer Loop: Stepping trough *String
    ; ----------------------------------------------------------------------
      
      If  *ptrString\c = *ptrSeperator\c ; 1st Character of Seperator in String   
        ; Debug "Equal : " +  Chr(*ptrString\c)
        xEqual =#True
       
        While *ptrSeperator\c
        ; ------------------------------------------------------------------
        ;  Inner Loop: Char by Char compare Separator with String
        ; ------------------------------------------------------------------
          If *ptrString\c 
            If *ptrString\c <> *ptrSeperator\c
              xEqual = #False     ; Not Equal
              Break               ; Exit While
           EndIf
          Else 
            xEqual =#False        ; Not Equal
            Break                 ; Exit While
          EndIf
          *ptrSeperator + SizeOf(Character)  ; NextChar Separator
          *ptrString + SizeOf(Character)     ; NextChar String  
        Wend
        
        ; If we found the complete Separator in String
        If xEqual
          ; Length of the String from Start up to Separator
          L =  (*ptrString - *Start)/SizeOf(Character) - lenSep 
          AddElement(Out())
          Out() = PeekS(*Start, L)
          *Start = *ptrString             ; the New Startposition
          ; Debug "Start\c= " + Str(*Start\c) + " : " + Chr(*Start\c)
          *ptrString - SizeOf(Character)  ; bo back 1 char to detected double single separators like ,,
           N + 1   
         EndIf
        
      EndIf   
      *ptrSeperator = *Separator            ; Reset Pointer of Seperator to 1st Char
      *ptrString + SizeOf(Character)        ; NextChar in String
    Wend
   
    AddElement(Out())
    Out() = PeekS(*Start)  ; Part after the last Separator
    ProcedureReturn N+1     ; Number of Substrings
        
  EndProcedure 
  SplitStringList = @_SplitStringList()   ; Bind ProcedureAddress to Prototype
  
  Procedure.s JoinArray(Array ary.s(1), Separator$, EndIndex=-1, StartIndex=0, *IOutLen.Integer=0)
  ; ============================================================================
  ; NAME: JoinArray
  ; DESC: Join all ArrayElements to a single String
  ; VAR(ary.s(1)) : The String Array
  ; VAR(Separator$) : A separator String
  ; VAR(StartIndex) : The Index of the 1st Entry to start with
  ; VAR(StartIndex) : The Index of the last Entry
  ; VAR(*IOutLen)   : Pointer to a IntVar for optional return of Stringlenght 
  ; RET.s: the String
  ; ============================================================================
    Protected ret$
    Protected I, L, N, lenSep, ASize
    Protected *ptr
    
    lenSep = Len(Separator$)
    
    ASize = ArraySize(ary())
    If EndIndex > ASize Or EndIndex < 0
      EndIndex = ASize
    EndIf
    
    If StartIndex > EndIndex
      StartIndex = EndIndex
    EndIf
    
    N = EndIndex- StartIndex + 1
    
    If ASize
      For I = StartIndex To EndIndex
        ;L = L + LenStrFast(ary(I))    
        L = L + Len(ary(I))    
     Next    
      L = L + (N-1) * lenSep
      ret$ = Space(L)
      
      *ptr = @ret$
      
;       Debug "ptr= " + Str(*ptr)
;       Debug "-"
      
      If lenSep > 0
        For I = StartIndex To EndIndex
          If ary(I)<>#Null$
            CopyMemoryString(ary(I), @*ptr)
          EndIf
          
          If I < EndIndex
            CopyMemoryString(Separator$,@*ptr)
          EndIf
        Next
      Else
        
        For I = StartIndex To EndIndex
           If ary(I)<>#Null$
            CopyMemoryString(ary(I), @*ptr)
          EndIf
        Next
    
      EndIf
      
    EndIf
    
    If *IOutLen
      *IOutLen\i = L
    EndIf
    
    ProcedureReturn ret$
  EndProcedure
  
  Procedure.s JoinList(List lst.s(), Separator$, *IOutLen.Integer=0)
  ; ============================================================================
  ; NAME: JoinList
  ; DESC: Join all ListElements to a single String
  ; VAR(lst.s()) : The String List
  ; VAR(Separator$) : A separator String
  ; VAR(*IOutLen)   : Pointer to a IntVar for optional return of Stringlenght 
  ; RET.s: the String
  ; ============================================================================
    Protected ret$
    Protected I, L, N, lenSep
    Protected *ptr
    
    ;lenSep = MemoryStringLength(@Separator$)
    lenSep = Len(Separator$)
    
    N = ListSize(lst())
    Debug "ListLength = " + N
    
    If N
      ; ----------------------------------------
      ;  With Separator
      ; ----------------------------------------
      ForEach lst()
        L = L + Len(lst()) 
      Next
      L = L + (N-1) * lenSep
      ret$ = Space(L)
      *ptr = @ret$
            
      If lenSep > 0 
        
        ForEach lst()
           If lst()<>#Null$
            CopyMemoryString(lst(), @*ptr)
          EndIf
          
          I + 1
          If I < N
            CopyMemoryString(Separator$, @*ptr)
          EndIf
        Next
        
      Else          
      ; ----------------------------------------
      ;  Without Separator
      ; ----------------------------------------
        
        ForEach lst()
           If lst()<>#Null$
            CopyMemoryString(lst(), @*ptr)
          EndIf
        Next
    
      EndIf
      
    EndIf
    
    If *IOutLen
      *IOutLen\i = L
    EndIf
    
    ProcedureReturn ret$
  EndProcedure

EndModule

CompilerIf #PB_Compiler_IsMainFile
 ; ----------------------------------------------------------------------
 ;  M O D U L E   T E S T   C O D E
 ; ---------------------------------------------------------------------- 
 
  EnableExplicit
  
  ; use the Real Macro to define floats in x32 as .f and in x64 as .d
  Define R1.PB::Real = 1.1
  Define R2.PB::Real = 1.2
  Debug R1 + R2
  
  UseModule PB
    
  Define.s s1  
  s1 = QuoteIt(QuotetText) ; "QuotetText"
  Debug s1
  
  Define res 
  Debug "Max(1,3,2)"
  MaxOf3(res, 1,3,2)
  Debug res
  Debug "Min(3,1,2)"
  MinOf3(res, 3,1,2)
  Debug res
  
  ; Show the use of pChar
  
  Define *pC.pChar    ; define an univeral Pointer to a CharFiled 
  Define cnt
  
  Define txt$ = "I'am a TexT with 979, 679 and Tom in a String"
  *pC = @txt$ ; let the universal CharPointer point on txt$
  
  ; Let's change all 7 betwween 9  to 0, UCase all 'a' followed by a Space or Tab 
  ; and LCase all 'T'
  
  ; ----------------------------------------------------------------------
  ;  Demo pChar: make crazy String operations easy 
  ; ---------------------------------------------------------------------- 
  
  ; to see a real example with pChar, go to german forum
  ; https://www.purebasic.fr/german/viewtopic.php?t=33327
  
  ; with the pChar Pointer I implemented phonetic encoding of Strings
  ; for Soundex and Cologne Phonetis algortihm in an easy way!
  
  Debug ""
  Debug "Demo pChar Pointer use: make carzy String operations easy!"
  Debug "  Let's do this: change all 7 between 9 to 0; UCase all 'a' followed by a Space or Tab; LCase all 'T'"
  Debug ""
  Debug txt$
   
  With *pC
    While \c  ; Step trough the complete String
      cnt + 1   ; number of character
    
      Select \c
        Case 'a' 
          If IsSpaceTabChar(\cc[1])  ; following is Space or Tab
            \c = 'A'
          EndIf
          
        Case 'T'
          \c = 't'    ; overwerite 'T' with 't'
          
        Case '7'
          ; !!! be very carefull with \cc[-x]  \cc[x]. Be sure to point to valid memory!
          If cnt > 1  ; we are at least at 2nd char, so we can go 1 back
            If \cc[-1] = '9' And \cc[1] = '9' ; previous Char and next Char = '9'
              \c = '0'    ; overwrite '7' with '0'
            EndIf
          EndIf
          
        Default
          
      EndSelect
     
      INCC(*pC)   ; Increment CharPointer
    Wend
  EndWith
  Debug txt$
  
CompilerEndIf



; IDE Options = PureBasic 6.20 Beta 4 (Windows - x64)
; CursorPosition = 405
; FirstLine = 398
; Folding = ------------------
; Optimizer
; CPU = 5