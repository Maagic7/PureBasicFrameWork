; ===========================================================================
;  FILE : PbFw_Module_PX.pb
;  NAME : Module PureBasic Extentions [PX::]
;  DESC : It's a PureBasic command extention and provides functions
;  DESC : not directly integrated in PB in an optimized way!
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2025/01/07
; VERSION  :  0.56 untested Developer Version
; COMPILER :  I hope all versions!
; OS       :  all
; ===========================================================================
; ChangeLog:
;{
; 2026/01/05 S.Maag : Major changes in Character Macros. Rename INCC->CInc, DECC->CDec.
;                     Added more Character Macros for parsing. CMov[Next,Last, BeyondNext, BeyondLast]
;                     Now the workflow wiht the Intellisense is better because all Character Macros
;                     start with a C and will be listeted as Block. That's much better!
;                     Updated INCC and DECC in all PB-Framwork files.
; 2026/01/03 S.Maag : Added Macros GetBackendString()
; 2025/12/29 S.Maag : Solved Bug with *String calculatoin in TextBetween /List/Array
; 2025/12/04 S.Maag : Added Epsilon constants #PX_EpsilonF,#PX_EpsilonD
; 2025/11/28 S.Maag : Added Get/Set -PbDataSectionPtr based on code from PB Forum
;                     https://www.purebasic.fr/english/viewtopic.php?t=35658
; 2025/11/26 S.Maag : JoinList() and JoinArray(): changed Parameter Separator$="" to optional
; 2025/09/02 S.Maag : integrated IIF.pbi into PX-Module 
; 2025/08/14 S.Maag : changed pAny and pChar: removed the doubles \cc \aa..
;                     because PB support \c if \c[0] is defined. So no need to have double defintions
; 2025/08/14 S.Maag : added #PbFw_Present constant for easy StandAlone use of Module
; 2025/08/12 S.Maag : updated SplitString Array/List functions with DQuote and changed
;                     the way of implementation. 
; 2025/08/08 S.Maag : added new TextBetween(), TextBetweenList(), TextBetweenArray()
;                     now with Prototyping and special Pointer techiques for more speed,
;                     token from new SplitString-Functions.
; 2025/08/04 S.Maag : switched to new SplitString Array/List functions.
;                     Former Pointer Version had problems with splitting at double
;                     characters like "//" or ".."
; 2025/08/04 S.Maag : Added Char=247 check to UCaseChar
; 2025/07/27 S.Maag : added Macro IsLetter(_CharValue)
; 2025/07/25 S.Maag : changed Module name from PB:: to PX:: because with PB we
;            will run into name convention problems with PB-Compiler because 
;            of #PB_ use. #PX_ prevents from such problems with comiler definitions.

;            moved SetMid form String Module STR:: to PX::
;            added Stringfunctions: SetLeft(), SetMid(), SetRight()

; 2025/06/29 S.Maag : added SetGadgetTextAlign from PB-Forum by MK-Soft
; 2025/02/01 S.Maag changed to the new Framework wide Constant name scheme
;             #'Module'_ConstantName
; 2025/02/01 S.Maag : Moved TSystemColor and the basic Color Macros
;             frm Module Color to Module PB!
; 2025/01/30 S.Maag : integrated the most common Bit functions as Macros!
; 2025/01/29 S.Maag : added the RealTimecounter and RealTimeCounter/HighPerformanceTimer
;             functions from Module RTC. RTC will be obsolet in the future.
;
; 2025/01/28 S.Maag : I realized: It's better for the programming workflow
;             to have one extention module with the most common/needed functions
;             instead of a lot of special moduls. Because of that I start to move
;             the most common Functions/Macros to this Modul.
;}
;{ TODO:
;}
; ===========================================================================

; XIncludeFile "PbFw_Module_PX.pb"          ; PX::      Purebasic Extention Module

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

; XIncludeFile "PbFw_Module_PbFw.pb"        ; PbFw::   FrameWork control Module

DeclareModule PX
  
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  
  ; Epsilon is the lowest value we must add to 1 to detect (1+Epsilon > 1)
  ; Epsilon is often needed in algorithms as exit condition.
  ; See Modul Float how to caclculate this value with a Loop.
  ; or https://de.wikipedia.org/wiki/IEEE_754
  ; Single Precision : Mantissa = 23 Bit
  ; Double Precision : Manitssa = 52 Bit
  #PX_EpsilonF = 1/(1<<23)  ; 1/2²³    = 0.0000001192092 
  #PX_EpsilonD = 1/(1<<52)  ; 1/(2^52) = 0.0000000000000002220446049250313080847263336181640625
                                
  #PX_CharSize = SizeOf(Character)
  #PX_IntSize = SizeOf(Integer)
  ; #TAB    ; exists in PB. But to have same way of access, define it here too
  #PX_TAB = #TAB   ; #TAB = 9
  #PX_SPACE = 32
  
  #PX_MaxBitNo = (SizeOf(Integer)*8-1)    ; 63 for x64 and 31 for x32
  
  Enumeration ePXTextAlign
    #PX_AlignLeft
    #PX_AlignCenter
    #PX_AlignRight
  EndEnumeration
  
  ; Any or Universal Pointer (see PurePasic IDE Common.pb Structrue PTR)
  ; I modified it a little to have both single var access and var array access 
  ; The orignal PTR-Struct only has var array access (a.a[0] ... ).
  ; \a \b \c ... is the single var access and \a[0] \b[0] ... ist the multiple
  ; access like an Array
  Structure pAny         ; ATTENTION! Only use as Pointer Strukture! Do not define as a normal Var!
    StructureUnion      
      ; multiple and single access like an Array
      a.a[0]   ; ASCII   : 1 Byte unsigned  [0..255] 
      b.b[0]   ; BYTE    : 1 Byte signed    [-128..127]
      c.c[0]   ; CHAR    : 1 Byte for Ascii Chars 2 Bytes for unicode
      w.w[0]   ; WORD    : 2 Byte signed   [-32768..32767]
      u.u[0]   ; UNICODE : 2 Byte unsigned [0..65535]
      l.l[0]   ; LONG    : 4 Byte signed   [-2147483648..2147483647]
      f.f[0]   ; FLOAT   : 4 Byte
      q.q[0]   ; QUAD    : 8 Byte signed   [-9223372036854775808..9223372036854775807]
      d.d[0]   ; DOUBLE  : 8 Byte float    
      i.i[0]   ; INTEGER : 4 or 8 Byte INT, depending on System
      *p.pAny[0]; Pointer to Any (for C-like **, PointerPointer use) !VERY VERY DANGEROUS!
    EndStructureUnion
  EndStructure
  
  ; An adapted version of pAny especally for character use
  Structure pChar   ; ATTENTION! Only use as Pointer Structure! Do not define as a normal Var!
    StructureUnion
      a.a[0]     ; ASCII   : 1 Byte unsigned  [0..255] 
      c.c[0]     ; CHAR    : 1 Byte for Ascii Chars 2 Bytes for unicode
      u.u[0]     ; UNICODE : 2 Byte unsigned [0..65535]
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
    PX::DQ#TextToQuote#PX::DQ
  EndMacro
    
  ; define Constant if not defined yet
  Macro CONST(ConstName, _value)
    CompilerIf Not Defined(ConstName, #PB_Constant)
      PX::HashTag#ConstName = _value
    CompilerEndIf
  EndMacro
    
  ;- ----------------------------------------------------------------------
  ;- Macros for Directory/File operations
  ;- ----------------------------------------------------------------------

  ; FileSize ReturnValue
  ;  -1: FileNotFound
  ;  -2: It is a directory
  ; use it : result = FileExist(FullFileName)
  Macro FileExist(_FullFileName)
    Bool(FileSize(_FullFileName) >= 0)  
  EndMacro
  
  ; use it : result = DirectoryExist("C:\Windows")
  Macro DirectoryExist(_Directory)
    Bool(FileSize(_Directory) = -2)
  EndMacro
  
  ; Go one path higher in path hirarchy
  ; use it : result$ = OnePathBack("C:\Windows\System32")   ; => "C:\Windows\"
  ;          result$ = OnePathBack("C:\Windows\System32\")  ; => "C:\Windows\"  
  Macro OnePathBack(_FullPathName)
    GetPathPart(RTrim(_FullPathName, #PS$))
  EndMacro

  ;- ----------------------------------------------------------------------
  ;- Macros for Bit/Byte operations
  ;- ----------------------------------------------------------------------
  
  ; this is the absolut correct verion in all cases
  Macro ToggleBool(_value)
    Bool(_value=0)
  EndMacro
  
  ; This the fast version (a simple XOR) but if you start with an even value like 2,4,6..
  ; the first Toggle delivers #True and it should be #False.
  ; And in many cases PB needs the Bool statement to accept it as a Bool in the Code
  ; But especally in C-Backend the XOR is nearly 3x faster. In ASM aprox 1.5x
  Macro ToggleBoolFast(_value)
    ((_value)!1)
  EndMacro

  ; Get the LoByte 
  ; use it : result = GetLoByte(x)
  Macro GetLoByte(_value)
    (_value & $FF)  
  EndMacro
  
  ; use it : result = SetLoByte(x, [0..255])
  Macro SetLoByte(_value, NewLoByte)
    ((_value & ~$FF) | (NewLoByte & $FF))  
  EndMacro
  
  ; Get the HiByte
  ; use it : result = GetHiByte(x)
  Macro GetHiByte(_WordValue)
    (_WordValue>>8 & $FF)
  EndMacro  
  
  ; Set the HiByte of a Word based value
  ; use it : result = SetHiByte(x, [0..255])
  Macro SetHiByte(_WordValue, _NewHiByte)
    ((_NewHiByte<<8 & $FF) | (_WordValue & $FF))  
  EndMacro
  
  ; Swaps the 2 Bytes of a 16Bit value
  ; use it : result = BSwap16(x); x=[0..$FFFF])
  Macro BSwap16(_WordValue)
    ((_WordValue<<8 | _WordValue>>8) & $FFFF)
  EndMacro
  
  ; Get the Bit specified by BitNo from value
  ; use it : result = GetBit(value, [0..31/63])
  Macro GetBit(_value, _BitNo)
    Bool(_value & 1<< _BitNo)  
  EndMacro
  
  ; Set the Bit specified by BitNo in value
  ; use it : result = SetBit(value, [0..31/63])
  Macro SetBit(_value, _BitNo)
    (_value | 1<< _BitNo)
  EndMacro
  
  ; Reset the Bit specified by BitNo in value
  ; value & (Not(1<<BitNo))
  ; use it : result = ResetBit(value, [0..31/63])
  Macro ResetBit(_value, _BitNo)
    (_value & ~(1<< _BitNo))  
  EndMacro
  
  ; Toggle the Bit specified by BitNo in value
  ; use it : result = ToggleBit(value, [0..31/63])
  Macro ToggleBit(_value, _BitNo)
    (_value!(1<< _BitNo))  
  EndMacro
  
  ; Get the Sign Bit (highest BitNo) from value
  ; use it : result = GetSignBit(value)
  Macro GetSignBit(_value)
    Bool(_value >> PX::#PX_MaxBitNo)  
  EndMacro
  
  ; Set the Sign Bit (highest BitNo) in value
  ; use it : result = SetSignBit(value)
  Macro SetSignBit(_value)
    (_value | 1<<PX::#PX_MaxBitNo)
  EndMacro
  
  ; Reset the Sign Bit (highest BitNo) in value
  ; use it : result = ResetSignBit(value)
  Macro ResetSignBit(_value)
    (_value & ~(1<<PX::#PX_MaxBitNo))  
  EndMacro
  
 ; Toggle the Sign Bit (highest BitNo) in value
 ; use it : result = ToggleSingBit(value)
  Macro ToggleSingBit(_value)
    (_value!(1<<PX::#PX_MaxBitNo))  
  EndMacro
  
  ; Count the no of HiBits in a Byte value
  ; use it : result = BitCountByte(value)
  Macro BitCountByte(_val)
    (Bool(_val&$1)+Bool(_val&$2)+Bool(_val&$4)+Bool(_val&$8)+Bool(_val&$10)+Bool(_val&$20)+Bool(_val&$40)+Bool(_val&$80))
  EndMacro

  ;- ----------------------------------------------------------------------
  ;- Macros for Min, Max, Limit, Compare
  ;- ----------------------------------------------------------------------
  
  ; Get the lowest value from 2 values
  ; use it : result = Min(3,2)
  Macro Min(_v1, _v2)
    (_v1*Bool(_v1 <= _v2) + _v2*Bool(_v1 > _v2))
  EndMacro
  
  ; Get the highest value from 2 values
  ; use it : result = Max(3,2)
  Macro Max(_v1, _v2)
    (_v1*Bool(_v1 >= _v2) + _v2*Bool(_v1 < _v2))
  EndMacro
  
  ; Write the lowest value from 2 values to VarResult
  ; use it : MinOf2(VarResult, 3, 2)
  Macro MinOf2(_VarResult, _v1, _v2)
    If _v1 < _v2
      _VarResult = _v1
    Else
      _VarResult = _v2
    EndIf   
  EndMacro
  
  ; Write the highest value from 2 values to VarResult
  ; use it : MaxOf2(VarResult, 3, 2)
  Macro MaxOf2(_VarResult, _v1, _v2)
    If _v1 > _v2
      VarResult = _v1
    Else
      VarResult = _v2
    EndIf   
  EndMacro
  
  ; Write the lowest value from 3 values to VarResult
  ; use it: MinOf3(VarResult, 3, 2, 1)
  Macro MinOf3(_VarResult, _v1, _v2, _v3)
  	If _v3 < _v2
  		If _v3 < _v1
  			_VarResult = _v3
  		Else
  			_VarResult = _v1
  		EndIf
  	ElseIf _v2 < _v1
  		_VarResult = _v2
  	Else
  		_VarResult = _v1
  	EndIf
  EndMacro
  
  ; Write the highest value from 3 values to VarResult
  ; use it: MaxOf3(VarResult, 3, 2, 1)
  Macro MaxOf3(_VarResult, _v1, _v2, _v3)
    If _v3 > _v2
  		If _v3 > _v1
  			_VarResult = _v3
  		Else
  			_VarResult = _v1
  		EndIf
  	ElseIf _v2 > _v1
  		_VarResult = _v2
  	Else
  		_VarResult = _v1
  	EndIf
  EndMacro
  
  ; Return the value limited to min 0 or Limit a var to min 0
  ; use it with var  : MinNull(MyVar)
  ;        with value: result = MinNull(-5)
  
  ; Attention do not add brakets: '( VarOrValue * Bool(VarOrValue >0) )' -> MinNull(MyVar) will not work
  Macro MinNull(_VarOrValue)
    _VarOrValue * Bool(_VarOrValue >0)  
  EndMacro
  
  ; use it: LimitToMin(var, MinValue)
  ;         LimitToMin(var, a+b)            ; use with MinValue as Expression
  Macro LimitToMin(_var, _MinValue)
    If _var < (_MinValue) : _var = _(MinValue) : EndIf
  EndMacro
  
  ; Limit var to MaxValue
  ;   (if you want to have a LimitMax function with return, use: result = Min(var, MyMax)
  
  ; use it: LimitToMax(var, MaxValue)
  ;         LimitToMax(var, a+b)            ; use with MaxValue as Expression
  Macro LimitToMax(_var, _MaxValue)
    If _var > (_MaxValue) : _var = (_MaxValue) : EndIf
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
  Macro IsEqual(_v1, _v2, _delta)
    Bool(Abs(_v1 - _v2) <= _delta)
  EndMacro
  ; Bool(v1 <= (v2 +delta)) And (v1 >= (v2 -delta))
  
  ; (MinValue <= value <= MaxValue)
  ; use it: result = IsInRange(value, MinValue, MaxValue)
  ;         result = IsInRange(value, a-b, a+b)       ; use with MinValue, MaxValue as Expression
  Macro IsInRange(_value, _MinValue, _MaxValue)
    Bool((_value)>=(_MinValue) And (_value)<=(_MaxValue))  
  EndMacro 
  
  ; saves Min and Max values to varMin, varMax
  ; use it: SaveMinMax(100, varMin, varMax)  ; -> varMin=100, varMax=100
  ;         SaveMinMax(99, varMin, varMax)   ; -> varMin=99 , varMax=100
  ;         SaveMinMax(101, varMin, varMax)  ; -> varMin=99 , varMax=101
  Macro SaveMinMax (_value, _varMin, _varMax)
    If _value > _varMax
      _varMax = _value
    ElseIf _value < _varMin
      _varMin = _value  
    EndIf
  EndMacro  
  
  ;- ----------------------------------------------------------------------
  ;- Macros for IIF()
  ;- ----------------------------------------------------------------------
 
  ; similar to the VB IIf Function
  ; use it : IIf(varReturn, A>1000, "large", "small")
  Macro IIF(_varReturn, _Expression, _valTrue, _valFalse)
    If Bool(_Expression)
      _varReturn = _valTrue
    Else
      _varReturn = _valFalse  
    EndIf
  EndMacro
  
  ;IIFe without Return -> execute TruePart or FalsePart
  ; use it: IIF(a=b, c+d, c*d)
  ;         IIF(a=b, x=1, x=0)
  Macro IIFe(_Expression, _TrueExpression, _FalseExpression)
    If _Expression
      _TrueExpression
    Else
      _FalseExpression
    EndIf   
  EndMacro
      
  ; IIFn with Numeric retrurn 
  ; use it: numVar = IIF(a=b, 1, 2)
  Macro IIFn(_Expression, _TruePart, _FalsePart)
    (Bool(_Expression) * _TruePart + Bool(Not(_Expression)) * _FalsePart)    
  EndMacro
    
  ; IIFs with String return from True/False String 
  ; use it: IIFs(A>1000, large, small)
  Macro IIFs(_Expression, _TrueString, _FalseString)
    PeekS(@_TrueString, -Bool(_Expression)) + PeekS(@_FalseString, -Bool(Not(_Expression)))
  EndMacro
  
  ; This idea I found at PB-Forum
  ; IIFsf with String return from a True/False StringField
  ; use it: IIFsf(A>1000, "large|small")
  Macro IIFsf(_Expression, _TrueFalseStrField, _sepStr="|")
    StringField(_TrueFalseStrField, 2-Bool(_Expression), _sepStr)
  EndMacro
  
  ; The GetBackendString is a fork of the IIFsf()
  Macro GetBackendString()
    StringField("ASM-Backend|C-Backend", #PB_Compiler_Backend+1 , "|")
  EndMacro

  ;- ----------------------------------------------------------------------
  ;- Macros for Math
  ;- ----------------------------------------------------------------------

  ; Because PB do not have a square function x².
  ; It is possible to use expression : y = SQ(3+2)  = 25
  ; use it: result = SQ(value)
  ;         result = SQ(a+b)        ; use with value as Expression
  Macro SQ(_value)
    ((_value)*(_value))
  EndMacro
  
  ; because PB do not have a cubic function x³
  ; use it: result = CUB(value)
  ;         result = CUB(a+b)       ; use with value as Expression
  Macro CUB(_value)
    ((_value)*(_value)*(_value))
  EndMacro
  
  ; Calculate hypothenuse with Pythagoras
  ; use it: C = Hypothenuse(A, B)
  Macro Hypothenuse(_A, _B)
    Sqr(_A*_A + _B*_B)
  EndMacro
  
  ; Lerp : Blending between A..B from 0..100% with T={0..1}
  ; Be sure to pass FloatingPoint values to the Macro
  ; _A [Float] : Startvalue A 
  ; _B [Float] : Endvalue   B
  ; _T [Float] : Time Value {0..1} = {0..100%}
  ; RET [Float] : Lerped Value V in the Range {ValStart..ValEnd}
  ; use it: V = Lerp(A, B, T)
  Macro Lerp(_A, _B, _T)    
    (_B-_A) * _T + _A   ; A*(1-T) + B*T
  EndMacro
  
  ; InverseLerp : Get the BlendingTime T{0..1} of the Value V in the Range [A..B]
  ; _A [Float] : Startvalue A 
  ; _B [Float] : Endvalue   B
  ; _V [Float] : Time Value {0..1} = {0..100%}
  ; RET [Float] : Blendig Time T of the Value V {0..1} = {0..100%}
  ;
  ; use it: T = UnLerp(A, B, V)
  Macro UnLerp(_A, _B, _V)
    (_V-_A)/(_B-_A)
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
  Macro Scale(_value, _inMin, _inMax, _outMin, _outMax)
    ((_value - _inMin) * (_outMax - _outMin) / (_inMax - _inMin) + _outMin)
  EndMacro
  
  ;   MIN=-100 MAX=100 VALUE=20 : ret= -20
  ;   MIN=  20 MAX=100 VALUE=20 : ret= 100
  ;                    VALUE=50 : ret=  70 
  
  ; use it: result = InvertRange(value, 0, 100) to change from [0..100] to [100..0]
  Macro InvertRange(_value, _RangeMin, _RangeMax)
    ; ret = Max - Val + Min
    (_RangeMin + _RangeMax - _value)
  EndMacro    

  ;- ----------------------------------------------------------------------
  ;- Macros for Number to String Conversion
  ;- ----------------------------------------------------------------------

  ; create a right aligned Hex$ with leading '0'. The stringlength
  ; depends on the function: Word - HexW, Long - HecxL, Quad - HexQ
  ; use it: result$ = HexW(value)
  Macro HexW(_value)
    RSet(Hex(_value, #PB_Word), 4, "0")
  EndMacro

  ; use it: result$ = HexL(value)
  Macro HexL(_value)
    RSet(Hex(_value, #PB_Long), 8, "0")
  EndMacro
  
  ; use it: result$ = HexQ(value)
  Macro HexQ(_value)
    RSet(Hex(_value, #PB_Quad), 16, "0")
  EndMacro
  
  ; Bin(_value, #PB_Byte) converts only the LoByte to Bin
  ; use it: Binary$ = BinB(value)
  Macro BinB(_value)  
    RSet(Bin(_value, #PB_Byte), 8, "0")
  EndMacro
  
  ; use it: Binary$ = BinW(value)
  Macro BinW(_value)
    BinB(_value>>8)+"."+BinB(_value)
  EndMacro
  
  ; use it: Binary$ = BinL(value)
  Macro BinL(_value)
    BinB(_value>>24)+"."+BinB(_value>>16)+"."+BinB(_value>>8)+"."+BinB(_value)
  EndMacro
 
  ; use it: Number$ = No2StrI(IntValue, length)
  Macro No2StrI(_IntValue, _lenght)
    RSet(Str(_IntValue), _lenght)
  EndMacro
  
  ; use it: Number$ = No2StrF(IntValue, length, [decimals])
  Macro No2StrF(_floatValue, _lenght, _decimals=3)
    RSet(StrF(_floatValue, _decimals), _lenght)
  EndMacro
  
  ; use it: Number$ = No2StrD(IntValue, length, [decimals])
  Macro No2StrD(_doubleValue, _lenght, _decimals=3)
    RSet(StrD(_doubleValue, _decimals), _lenght)
  EndMacro
 
  ;- ----------------------------------------------------------------------
  ;- Macros for Chara parsing with pChar
  ;- ----------------------------------------------------------------------
  
  ; With CInc, CDec for Charpointer operations instead of *MyCharPointer + [1,2], -[1,2]
  ; you can do a search for CharPointer operations. You don't have to care about CharSize! 

  ; Decrement CharPointer
  ; use it: CDec(MyCharPointer, [1..n])
  ;     or  MyNewCharPointer = CDec(MyOldCharPointer, [1..n])
  Macro CDec(_pChar, _cnt=1)
    _pChar - (_cnt)*PX::#PX_CharSize
  EndMacro
  
  ; Increment CharPointer
  ; use it: CInc(MyCharPointer, [1..n])
  ;     or  MyNewCharPointer = CInc(MyOldCharPointer, [1..n])
  Macro CInc(_pChar, _cnt=1)
    _pChar + (_cnt)*PX::#PX_CharSize
  EndMacro
  
  ; Move CharPointer to skip all TAB and SPACE
  ; use it: CSkipSpaceTab(MyCharPointer) 
  Macro CSkipSpaceTab(_pChar)
    While _pChar\c = 32 Or _pChar\c = 9
      _pChar + PX::#PX_CharSize
    Wend
  EndMacro
 
  ; Move CharPointer to Next specified Char
  ; use it: CMovNext(MyCharPointer, ':')
  Macro CMovNext(_pChar, _CharValue)
    While _pChar\c
      If _pChar\c = _CharValue
        Break
      EndIf
      _pChar + PX::#PX_CharSize 
    Wend
  EndMacro
  
  ; Move CharPointer to Last specified Char
  ; use it: CMovLast(MyCharPointer, j, ':')
  Macro CMovLast(_pChar, _varCnt, _CharValue)
    _varCnt = 0
    While _pChar\c[_varCnt]
      If _pChar\c[_varCnt] = _CharValue
        _pChar + _varCnt * SizeOf(Character)
        _varCnt=0
      EndIf
      _varCnt+1
    Wend
  EndMacro
  
  ; Move CharPointer to Next Decimal Char 0..9
  ; use it: CMovNextDecimal(MyCharPointer, ':')
  Macro CMovNextDecimal(_pChar)
    While _pChar\c
      If _pChar\c >='0' And _pChar\c <='9' 
        Break
      EndIf
      _pChar + PX::#PX_CharSize 
    Wend
  EndMacro
  
  ; Move CharPointer to Next non Decimal Char : Not[0..9]
  ; use it: CMovNextNonDecimal(MyCharPointer)
  Macro CMovNextNonDecimal(_pChar, _CharValue)
    While _pChar\c
      If _pChar\c >='0' And _pChar\c <='9'
        _pChar + PX::#PX_CharSize
      Else
        Break
      EndIf
    Wend
  EndMacro

  ; Move CharPointer to 1 Char beyond next specified Char
  ; use it: CMovBeyondNext(MyCharPointer, j, ':')
  Macro CMovBeyondNext(_pChar, _varCnt, _CharValue)   
    _varCnt = 0
    While _pChar\c[_varCnt]
      If _pChar\c[_varCnt] = _CharValue
        _pChar + (_varCnt+1) * SizeOf(Character)
        Break
      EndIf
      _varCnt +1
    Wend
  EndMacro

  ; Move CharPointer to 1 Char beyond last specified Char
  ; use it: CMoveBeyondLast(MyCharPointer, j, ':')
  Macro CMovBeyondLast(_pChar, _varCnt, _CharValue)   
    _varCnt = 0
    While _pChar\c[_varCnt]
      If _pChar\c[_varCnt] = _CharValue
        _pChar + (_varCnt+1) * SizeOf(Character)
        _varCnt=0
      Else
        _varCnt +1
      EndIf
    Wend
  EndMacro
    
  ; Repleace the next specified Char without moving the Pointer _pChar
  ; Example replace the next ',' with '.' (for changing to decimal point)
  ; use it: ReplaceNextChar(MyCharPointer, j, ',', '.')
  Macro CReplaceNext(_pChar, _varCnt, _searchChar, _replaceChar)
    _varCnt = 0
    While _pChar\c[_varCnt]
      If _pChar\c[_varCnt] = _searchChar
        _pChar\c[_varCnt] = _replaceChar
        Break
      EndIf
      _varCnt + 1
    Wend
  EndMacro
  
  Macro CFindNext(_pChar, _varCnt, _searchChar)
    _varCnt = 0
    While _pChar\c[_varCnt]
      If _pChar\c[_varCnt] = _searchChar 
        Break    
      EndIf
      _varCnt +1
    Wend
  EndMacro
  
  ;- ----------------------------------------------------------------------
  ;- Macros for CHAR operations
  ;- ----------------------------------------------------------------------

  ; LowerCase a single Char in ASCii Character space, Unicode Chars are not affected!
  ; use it: result = LCaseChar(_CharValue)
  ; <<5 = *32 what is the CharDifference between Lo and Up
  Macro LCaseChar(_CharValue)
    (_CharValue + Bool((_CharValue>='A' And _CharValue<='Z') Or (_CharValue>=192 And _CharValue<=222))<<5)  
  EndMacro
  
  ; UpperCase a single Char in ASCii Character space, Unicode Chars are not affected!
  ; use it: result = UCaseChar(_CharValue)
  ; <<5 = *32 what is the CharDifference between Lo and Up
  Macro UCaseChar(_CharValue)
    (_CharValue - Bool((_CharValue>='a' And _CharValue<='z') Or (_CharValue>=224 And _CharValue<=254 And _CharValue<>247))<<5)  
  EndMacro

  ; Set a Charater variable to LoChar. It's faster than MyChar = LCaseChar(MyChar)!
  ; ASCii Character space only!
  ; use it: SetCharLo(_CharValue)
  Macro SetCharLo(_varChar)  
    Select _varChar
      Case 'A' To 'Z'
        _varChar + 32  ; a[97]-A[65]=32       
      Case 192 To 222   ; 'À'..222
        _varChar + 32  ; 224-192 = 32        
    EndSelect
  EndMacro
   
  ; Set a Charater variable to UpChar. It's faster than MyChar = UCaseChar(MyChar)
  ; ASCii Character space only!
  ; use it: SetCharUp(MyChar)
  Macro SetCharUp(_varChar)  
    Select _varChar
      Case 'a' To 'z'
        _varChar - 32  ; a[97]-A[65]=32                
      Case 247        ; '÷'
      Case 224 To 254   ; 'À'..254
        _varChar - 32  ; 254-222 = 32      
    EndSelect
  EndMacro 
  
  ; Check if Char is decimal digit : Case '0' To '9'
  ; The Bool is needed to save the result in a var: res=IsDecChar()! Without Bool only 'If IsDecChar()' is possible!
  ; use it: result = IsDecChar(_CharValue)
  Macro IsDecChar(_CharValue)
    Bool(_CharValue >='0' And _CharValue <='9')
  EndMacro
  
  ; Check if Char is Hex digit : Case '0' To '9', 'A' To 'F'
  ; use it: result = IsHexChar(_CharValue)
  Macro IsHexChar(_CharValue)
    Bool((_CharValue >='0' And _CharValue <='9') Or (_CharValue >='A' And _CharValue <='F'))
  EndMacro
  
  ; Check if Char is binary digit : Case '0', '1'
  ; use it: result = IsBinChar(MyChar)
  Macro IsBinChar(_CharValue)
    Bool(_CharValue ='0' Or _CharValue ='1')
  EndMacro
  
  ; Check if Char is SPACE or TAB : Case '9', '32'
  ; use it: result = IsSpaceTabChar(MyChar)
  Macro IsSpaceTabChar(_CharValue)
    Bool(_CharValue=9 Or _CharValue=32)
  EndMacro
  
  ; Check if Char is EndOfLineChar LF or CR : Case '10', '13'
  ; use it: result = IsEolChar(MyChar)
  Macro IsEolChar(_CharValue)
    Bool(_CharValue=10 Or _CharValue=13)
  EndMacro  
  
  ; Check if Char is plus '+' or minus '-'
  ; use it: result = IsPlusMinusChar(MyChar)
  Macro IsPlusMinusChar(_CharValue)
    Bool(_CharValue='+' Or _CharValue='-')
  EndMacro  

  ; Check if Char is multiplication '*' or division '/'
  ; use it: result = IsMulDivChar(MyChar)
  Macro IsMulDivChar(_CharValue)
    Bool(_CharValue='*' Or _CharValue='/')
  EndMacro  
  
  ; Check if Char is a letter : Case 'A' To 'Z', 'a' To 'z'
  ; use it: result = IsLetter(_CharValue)
  Macro IsLetter(_CharValue)
    Bool( (_CharValue >= 'A' And _CharValue <= 'Z') Or (_CharValue >= 'a' And _CharValue <= 'z'))  
  EndMacro
  
  ; Combines 2 Unicode Chars to a Double Char Value .l
  ; use it: result = MakeDoubleChar(13,10)  ; for CRLF 
  Macro MakeDblChar(_CharValue1, _CharValue2)
    (_CharValue2<<16 | _CharValue1)      
  EndMacro
  
  ; Combines 4 Unicode Chars to a Quad Char Value .q
  ; use it: result = MakeQuadChar('a','b', 'c', 'd')  ; for 'abcd' 
  Macro MakeQChar(_CharValue1, _CharValue2, _CharValue3, _CharValue4)
    (_CharValue4<<48 | _CharValue3<<32 | _CharValue2<<16 | _CharValue1)  
  EndMacro
     
  ;- ----------------------------------------------------------------------
  ;- Macros for COLOR operations
  ;- ----------------------------------------------------------------------
  
  ; Purebasic don't has a function to set only one channel of a Color to a new
  ; value. The usual PB Code to set RedChannel to NewValue is:
  ;   Color = RGB(NewRed, Green(Color), Blue(Color))
  
  ; The Get/Set and MakeRGB Macros are up to 30% fastern than PB's Color Functions.
  ; Because PB use Subroutine Calls for Red(), Green(), ... , RGBA(), RGB(),
  ; the PB buildin functions are slower!
  ; To get direct and correct access to the Color Channels according to the 
  ; Systems Color Order, the _SCM.TSystemColorMask Structure is used, which
  ; holds the Masks for the R,G,B,A Channels. To see how this works goto
  ; PX::InitSystemColorMask Function
  
  ; There is a second way to access the ColorChannels correct.
  ; The TSystemColor Structure. If you define a Variable or a Pointer 
  ; of TSystemColor you get multiple and direct access to each Channel 
  ; by name (\RGB\R,G,B,A or number \ch[0..3]) and to the ColorValue 
  ; itself (\col). Then you do not need the Macros!
  
  ; _SCM is a TSystemColorMask Structure
  
  ; Get Red Channel of ColorValue
  ; use it : result = GetRed(ColorValue) 
  Macro GetRed(_ColorValue)
    (_ColorValue >> PX::_SCM\shRed & $FF) 
  EndMacro
  
  ; Set Red Channel with new value
  ; use it : result = SetRed(ColorValue, NewRedValue) 
  Macro SetRed(_ColorValue, NewRed=0)
    (_ColorValue & PX::_SCM\maskRedOff) | ((NewRed) << PX::_SCM\shRed)
  EndMacro
  
  ; Get Green Channel of ColorValue
  ; use it : result = GetGreen(ColorValue) 
  Macro GetGreen(_ColorValue)
    (_ColorValue >> PX::_SCM\shGreen & $FF) 
  EndMacro
  
  ; Set Green Channel with new value
  ; use it : result = SetGreen(ColorValue, NewGreenValue) 
  Macro SetGreen(_ColorValue, NewGreen=0)
    (_ColorValue & PX::_SCM\maskGreenOff) | ((NewGreen) << PX::_SCM\shGreen)
  EndMacro
  
  ; Get Blue Channel of ColorValue
  ; use it : result = GetBlue(ColorValue) 
  Macro GetBlue(_ColorValue)
    (_ColorValue >> PX::_SCM\shBlue & $FF) 
  EndMacro
  
  ; Set Blue Channel with new value
  ; use it : result = SetBlue(ColorValue, NewBlueValue) 
  Macro SetBlue(_ColorValue, NewBlue=0)
    (_ColorValue & PX::_SCM\maskBlueOff) | ((NewBlue) << PX::_SCM\shBlue)
  EndMacro
 
  ; Get Alpha Channel of ColorValue
  ; use it : result = GetBlue(ColorValue) 
  Macro GetAlpha(_ColorValue)
    (_ColorValue >> PX::_SCM\shAlpha & $FF) 
  EndMacro
  
  ; Set Alpha Channel with new value
  ; use it : result = SetAlpha(ColorValue, NewAlphaValue) 
  Macro SetAlpha(_ColorValue, NewAlpha=255)
    (_ColorValue & PX::_SCM\maskAlphaOff) | ((NewAlpha) << PX::_SCM\shAlpha)   
  EndMacro
  
  ; Remember: If you use PB's Image drawing functions which use Alpha Channel you
  ; have to Add the Alpha=255 to your Pixels, otherwise you won't see the Image because
  ; it is fully intransparent. This is a very common fault if you are PB beginner!
  ; The SetAlphaIfNull add Alpha=255 if Alpha=0 fully intransparent
  
  ; If Alpha = 0 Then Alpha = 255 
  ; use it : SetAlphaIfNull(varColor) 
  Macro SetAlphaIfNull(_varColor)
    If Not (_varColor & PX::_SCM\maskAlpha)
      _varColor = _varColor | PX::_SCM\maskAlpha
    EndIf
  EndMacro
  
  ; make a RGBA color value from Red, Green, Blue, Alpha
  ; use it : result = MakeRGBA(R,G,B,A)
  Macro MakeRGBA(RedValue, GreenValue, BlueValue, AlphaValue = 255)
    (RedValue << PX::_SCM\shRed) | (GreenValue << PX::_SCM\shGreen) | (BlueValue << PX::_SCM\shBlue) | (AlphaValue << PX::_SCM\shAlpha)
  EndMacro
  
  ; make a RGB color value from Red, Green, Blue
  ; use it : result = MakeRGB(R,G,B)
  Macro MakeRGB(RedValue, GreenValue, BlueValue)
    (RedValue << PX::_SCM\shRed) | (GreenValue << PX::_SCM\shGreen) | (BlueValue << PX::_SCM\shBlue)
  EndMacro
  
  ; use it : SaturateColor(MyColorVar)
  Macro SaturateColor(_varColor)
    If _varColor > 255 
      _varColor = 255 
    ElseIf _varColor < 0
      _varColor = 0 
    EndIf
  EndMacro

  ; Limit the Color value to 255
  ; use it : SaturateColorMax(MyColorVar)
  Macro SaturateColorMax(_varColor)
    If _varColor > 255 : _varColor = 255 : EndIf
  EndMacro
  
  ; Blend  RedVal into ColorVar : Alpha [0..255] is the Blending for Red(ColorVar)
  ; use it : BlendRed(ColorVar, RedVal, Alpha)
  ;     or : BlendRed(ColorVar, Red(MyColor), Alpha)
  Macro BlendRed(ColorVar, RedVal, Alpha=127)
    ColorVar = (ColorVar & PX::_SCM\maskRedOff) | (((Red(ColorVar)* Alpha + RedVal *(255-Alpha))>>8) << PX::_SCM\shRed)
  EndMacro
  
  ; Blend  GreenVal into ColorVar : Alpha [0..255] is the Blending for Green(ColorVar)
  ; use it : BlendGreen(ColorVar, GreenVal, Alpha)
  ;     or : BlendGreen(ColorVar, Green(MyColor), Alpha)
  Macro BlendGreen(ColorVar, GreenVal, Alpha=127)
    ColorVar = (ColorVar & PX::_SCM\maskGreenOff) | (((Green(ColorVar)* Alpha + GreenVal *(255-Alpha))>>8) << PX::_SCM\shGreen)
  EndMacro
  
  ; Blend  BlueVal into ColorVar : Alpha [0..255] is the Blending for Blue(ColorVar)
  ; use it : BlendBlue(ColorVar, BlueVal, Alpha)
  ;     or : BlendBlue(ColorVar, Blue(MyColor), Alpha)
  Macro BlendBlue(ColorVar, BlueVal, Alpha=127)
    ColorVar = (ColorVar & PX::_SCM\maskBlueOff) | (((Blue(ColorVar)* Alpha + BlueVal *(255-Alpha))>>8) << PX::_SCM\shBlue)
  EndMacro
  
  ; Blend 2 Colors and Return blended value
  ; use it : result = BlendColors(Color1, Color2, Alpha) : Alpha is the factor for COL1
  Macro BlendColors(COL1, COL2, Alpha=127)   
    ((((Red(COL1)*Alpha + Red(COL2)*(255-Alpha))>>8)<< PX::_SCM\shRed) | (((Green(COL1)*Alpha + Green(COL2)*(255-Alpha))>>8)<< PX::_SCM\shGreen) | (((Blue(COL1)*Alpha + Blue(COL2)*(255-Alpha))>>8)<< PX::_SCM\shBlue))
  EndMacro
  
  ; Methode                 | Weight Base %              | Weight Base 1024 for >>10 use
  ; ------------------------|----------------------------|------------------------------
  ; Greyscale_Average       | (33.3, 33.3, 33.3)% =99.9  | (341, 341, 341) =1023 = 99.9%
  ; Greyscale_Standard      | (29.9, 58.7, 11.4)% =100   | (306, 601, 117) =1024 = 100%
  ; Greyscale_WeightedLight | (30.9, 60.9,  8.2)% =100   | (316, 624,  84) =1024 = 100%

  ; R = 333  ; factor = 0.333 we use integer multiplikation *1024>>10 
  ; G = 333
  ; B = 333
  Macro GreyScaleAverage(_ColorValue)
    (Red(_ColorValue)341 + Green(_ColorValue)341 + Blue(_ColorValue)341)>>10)
  EndMacro
  
  ; R = 299
  ; G = 587
  ; B = 114
  Macro GreyScaleStandard(_ColorValue)
    (Red(_ColorValue)306 + Green(_ColorValue)*601 + Blue(_ColorValue)117)>>10)
  EndMacro
  
  ; R = 309
  ; G = 609
  ; B =  82
  Macro GreyScaleWeightedLight(_ColorValue)
    (Red(_ColorValue)*316 + Green(_ColorValue)*624 + Blue(_ColorValue)*84)>>10)
  EndMacro

  ;- ----------------------------------------------------------------------
  ;- Abs() Macros to solve C-Backend 53-Bit-Abs() Problem
  ;- ----------------------------------------------------------------------
 
  ; AbsI() and AbsQ() solve tha PB's ABS() Problem at C-Backend with 53-Bit only!
  ; In ASM Backend the 80Bit Float unit is used for ABS() what works perfect for 64Bit INT.
  ; In C-Backend a MMX Version is used for ABS(). This is a problem because MMX use only 64Bit Floats
  ; with a manitassa of 53 Bits. This will cause bugs using ABS() for values >53 Bits!
  
  ; This is the optimized Abs Version (translated from Assembler to PB-Code; Source: Math.asm from Linux Asm Project
  ; X!(X>>63)-(X>>63) ; x64
  ; X!(X>>31)-(X>>31) ; x32
  
   
  ; PB 6.04 on Ryzen 5800 the Macro is nearly same speed as PB's ABS()
  ; ASM BAckend: For 100Mio calls (50% with -X and 50% with +X) :  PB_ABS() = 53ms  AbsI() = 58ms
  CompilerIf #PB_Compiler_Backend = #PB_Backend_Asm
    Macro AbsI(_IntValue)
      Abs(_IntValue)
    EndMacro
  CompilerElse  ; C-Backend
    Macro AbsI(_IntValue)
      (_IntValue ! (_IntValue >> PX::#PX_MaxBitNo) - (_IntValue >> PX::#PX_MaxBitNo))
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
  ;  ----------------------------------------------------------------------
  
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
  #PX_RTC_STOP = 0       ; STOP Timer and return the time difference since start
  #PX_RTC_START = 1      ; START Timer and return the StartValue in MicroSeconds or NanoSeconds
  #PX_RTC_READ = 2       ; Read the time value [µs] (if Timer is stopped, it's the differntial time. If timer is started it is the START-Time)
  
  #PX_RTC_MicroSeconds = 0
  #PX_RTC_NanoSeconds = 1
  
  #PX_RTC_MaxCounterNo = 15     ; Timers [0..#PX_RTC_MaxCounterNo]  = [0..15]! Change this value if you need more Timers
  
  Structure TDateAndTime        ; DateAndTime Structure to convert a TimeStamp
    wYear.w
    wMonth.w
    wDay.w
    wHour.w
    wMinute.w
    wSecond.w
    wMilliseconds.w
  EndStructure
  
  Structure TRTC                      ; Structure to hold the Timer datas
    T.q[#PX_RTC_MaxCounterNo+1]       ; Timer Value
    xRun.i[#PX_RTC_MaxCounterNo+1]    ; Timer Run-State : #False = Stop, #True = Run
  EndStructure
  
  ;- --------------------------------------------------
  ;- Declare Public Functions
  ;- --------------------------------------------------
  
  ; Basic Functions
  Declare.i RTC_Resolution()          ; Get the NanoSeconds per TickCount : >0 if CPU and OS support RTC Function
  Declare.q ElapsedMicroseconds()     ; Elapsed MicorSeconds
  Declare.q ElapsedNanoseconds()      ; Elapsed NanoSeconds
  
  ; TimeStamp Functions
  Declare.q GetTimeStamp()            ; Get Date with ms precision : TimeStamp = Date()*1000 + ms
  Declare.i TimeStampToDateAndTime(*OutDT.TDateAndTime, Timestamp.q)
  Declare.s TimeStampToString(TimeStamp.q, Format$="%yyyy/%mm/%dd-%hh:%mm:%ss")
  
  ; High Performance Timer
  Declare.q RTC(CounterNo=0, cmd=#PX_RTC_START, TimeBase=#PX_RTC_MicroSeconds)
  Declare.q RTCcal()                    ; calibarte Timer (calculate Timer Start/Stop Time for clibartion)
  Declare.i RTCget(*RTCstruct.TRTC)     ; Get a copy of the internal TimerStrucure with actual values
  
  ; --------------------------------------------------
  ; STRING Functions
  ; -------------------------------------------------- 
  
  Prototype.s QuoteString(StringToQute$, Quotes.c='"')
  Global QuoteString.QuoteString
  
  Prototype.i SetLeft(String$, StringToSet$, Length=#PB_All)
  Global SetLeft.SetLeft
  
  Prototype.i SetMid(String$, StringToSet$, Pos, Length=#PB_All)
  Global SetMid.SetMid
  
  Prototype.i SetRight(String$, StringToSet$, Length=#PB_All)
  Global SetRight.SetRight
    
  Prototype.s TextBetween(String$, Left$, Right$=#Null$)
  Global TextBetween.TextBetween
  
  Prototype.i TextBetweenList(List Out.s(), String$, Left$, Right$)
  Global TextBetweenList.TextBetweenList
  
  Declare.s ColumnText(Text$, ColWidth=12, TextAlign=#PX_AlignCenter)

  Prototype.i TextBetweenArray(Array Out.s(1), String$, Left$, Right$, ArrayRedimStep=10)
  Global TextBetweenArray.TextBetweenArray

  Prototype SplitStringArray(Array Out.s(1), String$, Separator$, DQuote=#False, ArrayRedimStep=10)
  Global SplitStringArray.SplitStringArray
  
  Prototype SplitStringList(List Out.s(), String$, Separator$, DQuote=#False, clrList= #True)
  Global SplitStringList.SplitStringList
    
  Declare.s JoinArray(Array ary.s(1), Separator$="", StartIndex=0, EndIndex=-1, *IOutLen.Integer=0)
  Declare.s JoinList(List lst.s(), Separator$="", *IOutLen.Integer=0)  
  
  Declare.i StringArrayToList(Array aryStr.s(1), List lstStr.s())
  Declare.i StringListToArray(List lstStr.s(), Array aryStr.s(1))
  
  ; --------------------------------------------------
  ; Gadgets
  ; -------------------------------------------------- 
  Declare SetGadgetTextAlign(GadgetNo, AlignType)
  
  ; --------------------------------------------------
  ; Miscellaneous
  ; -------------------------------------------------- 
  Declare SetPbDataSectionPtr (*pData) 
  Declare.i GetPbDataSectionPtr() 

EndDeclareModule

Module PX
  EnableExplicit
  
 CompilerIf Defined(PbFw, #PB_Module)
    PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  CompilerEndIf 
  
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
        
        ; import gtk Subsystem functions for Gadget TextAlign
        CompilerIf Subsystem("GTK2")
          gtk_entry_set_alignment(*entry, xalign.f)
          gtk_label_set_xalign(*label, xalign.f)
          gtk_misc_set_alignment(*label, xalign.f, yalign.f)
          
        CompilerElse ;Subsystem("QT") - Purebasic help says use 'QT' instead if 'GTK3'
          ; TODO! Check it! Maybe wrong for QT
          gtk_entry_set_alignment(*entry, xalign.f)
          gtk_label_set_xalign(*label, xalign.f)
          gtk_misc_set_alignment(*label, xalign.f, yalign.f)
         
        CompilerEndIf
        
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
            
  Procedure.i RTC_Resolution()
  ; ============================================================================
  ; NAME: RTC_Resolution
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
  _rtcRes_ns = RTC_Resolution()    ; AutoInit rtcRes_ns
      
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
  Global _RTC.TRTC  ; TimerValues Structure for Timers [0..#PX_RTC_MaxCounterNo]
  Global _RTC_Calibration.q  ; calibration ticks : Time for calling RTC() in NanoSeconds
  
  Procedure.q RTC(CounterNo=0, cmd=#PX_RTC_START, TimeBase=#PX_RTC_MicroSeconds)
  ; ============================================================================
  ; NAME: RTC
  ; DESC: RealTimeCounter, Milti-Timer/Counter of RealTimeClockTicks [ns]
  ; DESC: Provides a set of easy to use timers for software speed tests!
  ; VAR(CounterNo) : No of the Timer [0..#PX_RTC_MaxCounterNo]
  ; VAR(cmd) : #PX_RTC_START, #PX_RTC_STOP, #PX_RTC_READ
  ; VAR(TimeBase) : #PX_RTC_NanoSeconds, #PX_RTC_MicroSeconds
  ; RET.q : Elapsed Time according to CounterNo
  ; ============================================================================
         
    If CounterNo <0 Or CounterNo > #PX_RTC_MaxCounterNo
      ProcedureReturn -1
    EndIf
    
    Select cmd
        
      Case #PX_RTC_START       ; START Timer --> save actual value of QueryPerformanceCounter in DataSection
      ; ----------------------------------------------------------------------
      ;  Start the Timer
      ; ----------------------------------------------------------------------
        
        _RTC\T[CounterNo] = ElapsedNanoseconds()        
        _RTC\xRun[CounterNo] = #True         ; Set Run State = #True
        
        If TimeBase = #PX_RTC_MicroSeconds
          ProcedureReturn _RTC\T[CounterNo] / 1000
        Else        ; #PX_RTC_NanoSeconds
          ProcedureReturn _RTC\T[CounterNo]
        EndIf
         
      Case #PX_RTC_STOP        ; STOP Timer
      ; ----------------------------------------------------------------------
      ;  Stop the Timer
      ; ----------------------------------------------------------------------
        
        _RTC\T[CounterNo] = ElapsedNanoseconds() - _RTC\T[CounterNo] - _RTC_Calibration
  
        If _RTC\T[CounterNo] < 0           ; Abs() because PB's Abs() is for floats only
          _RTC\T[CounterNo] = - _RTC\T[CounterNo] 
        EndIf
        
        _RTC\xRun[CounterNo] = #False      ; Set Run State = #False 
        If TimeBase = #PX_RTC_MicroSeconds
          ProcedureReturn _RTC\T[CounterNo] / 1000
        Else        ; #PX_RTC_NanoSeconds
          ProcedureReturn _RTC\T[CounterNo]
        EndIf
        
      Case #PX_RTC_READ
      ; ----------------------------------------------------------------------
      ;  Read the Timer
      ; ----------------------------------------------------------------------
        Protected ret.q
        
        If _RTC\xRun[CounterNo]
          ret = ElapsedNanoseconds() - _RTC\T[CounterNo] - _RTC_Calibration
          If ret < 0 : ret = -ret : EndIf      
        Else
          ret= _RTC\T[CounterNo]
        EndIf
        
        If TimeBase = #PX_RTC_MicroSeconds
          ProcedureReturn _RTC\T[CounterNo] / 1000
        Else        ; #PX_RTC_NanoSeconds
          ProcedureReturn _RTC\T[CounterNo]
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
  ; DESC: For calibration Timer(#PX_RTC_MaxCounterNo) is used.
  ; DESC: So don't cal RTCcal() if this Timer is in operation!
  ; RET.q : Calibration offset for a Timer START/STOP call
  ; ============================================================================
    Protected tim.q
    
    ; detecet the Time for a Timer Start/STOP Call
    tim = ElapsedNanoseconds()
    RTC(#PX_RTC_START, #PX_RTC_MaxCounterNo, #PX_RTC_NanoSeconds)   
    RTC(#PX_RTC_STOP, #PX_RTC_MaxCounterNo, #PX_RTC_NanoSeconds)
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
  ; DESC: data for the systmens Color order RGBA
  ; DESC: PB System Color Byte Order is RGBA on all little Endian systems
  ; DESC: Windows, Linux, MacOS on x86/x64 and ARM
  ; VAR(*SCM.TSystemColorMask): The SystemColorMask variable to initialize
  ; RET.i : *SCM
  ; ============================================================================
    Protected SysCol.TSystemColor                
    Protected I, CHval
        
    SysCol\col =RGBA('R','G','B','A') ; Create the ColorValue with the unique Channel values
    
    If *SCM
      With *SCM
        ; Step 1 : step trough the 4 Bytes of the created Color and
        ; compare the value in memory with the unique Channel values
        For I = 0 To 3
          Select SysCol\ch[I] ; Access to Color with ChannelNo [0..3]
            Case 'R'          ; value for Red channel found
              \idxRed = I     ; save index for Red
            Case 'G'          ; value for Green channel found
              \idxGreen = I   ; save index for Green
            Case 'B'          ; value for Blue channel found
              \idxBlue = I    ; save index for Blue  
            Case 'A'          ; value for Alpha channel found
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
    
    CompilerIf #PB_Compiler_IsMainFile
      ; Debug the ColorChannel Order and the Pointers to the Structure Elements
      ; IDENTICAL POINTERS FOR: 
      ;   @TSystemColor= @TSystemColor\col= @TSystemColor\RGB = @TSystemColor\RGB\R = @TSystemColor\ch[0]
      
      With SysCol
        Debug "------------------------------"
        Debug "PX::InitSytemColorMask"
        Debug "Red-Channel = " + _SCM\idxRed
        Debug "Green-Channel = " + _SCM\idxGreen
        Debug "Blue-Channel = " + _SCM\idxBlue
        Debug "Alpha-Channel = " + _SCM\idxAlpha
        
        Debug "Pointers of TSystemColor Structure"
        Debug "@SysCol =" + @SysCol
        Debug "@SysCol\col =" +@\col
        Debug "@SysCol\ch[0] =" +@\ch[0]
        Debug "@SysCol\RGB =" + @\RGB
        Debug ""
        Debug "@SysCol\RGB\R =" +@\RGB\R
        Debug "@SysCol\RGB\G =" +@\RGB\G
        Debug "@SysCol\RGB\B =" +@\RGB\B
        Debug "@SysCol\RGB\A =" +@\RGB\A
        Debug "------------------------------"
      EndWith
    CompilerEndIf
    
    ; Show Error Message for programmer, if the Color Order does not fit together"
    With SysCol
      If \RGB\R <> 'R' Or \RGB\G <> 'G' Or \RGB\B <> 'B' Or \RGB\A <> 'A'
        MessageRequester("Purebasic Framework: Error in Modul: " + #PB_Compiler_Module + "/" + #PB_Compiler_Procedure, "The System Color order does not fit with the programmed one in TSystemColor")   
      EndIf
    EndWith
    
    ProcedureReturn *SCM
  EndProcedure
  
  ;- --------------------------------------------------
  ;- STRING Functions
  ;- -------------------------------------------------- 
  
  Procedure.s _QuoteString(StringToQuote$, Quotes.c='"')
    ProcedureReturn Chr(Quotes) + StringToQuote$ + Chr(Quotes)    
  EndProcedure
  QuoteString = @_QuoteString() ; Bind ProcedureAddress to Prototype
  
  Procedure.i _SetLeft(*String, *StringToSet, Length=#PB_All)
  ; ============================================================================
  ; NAME: _SetLeft
  ; DESC: Because PureBasic do not have a Function to set the left of a String,
  ; DESC: we need our own solution. PokeS is possible but do not have any
  ; DESC: plausiblity checks.
  ; DESC: !PointerVersion! use it as ProtoType SetLeft()
  ; VAR(*String) : Pointer to the main String$
  ; VAR(Length) : number or characters to insert
  ; VAR(*StringToSet): Pointer to StringToSet$
  ; RET.i : Number of copied characters
  ; ============================================================================
    Protected *Dest.pChar, *Source.pChar
    Protected cntChar, I
       
    If Length < 0
      Length = 2147483647   ; max Long
    EndIf
    
    *Source = *StringToSet
    *Dest= *String
          
    While *Source\c                 ; If Source not at EndOfString
      If *Dest\c                    ; If Destination not at EndOfString  
        *Dest\c = *Source\c         ; Destination = Source
        CInc(*Source)               ; Set Pointer to next char
        CInc(*Dest)  
        cntChar + 1                 ; count number of characters
        If cntChar >= Length
          Break
        EndIf
      Else
        Break  
      EndIf         
    Wend      
  
    ProcedureReturn cntChar
  EndProcedure
  SetLeft = @_SetLeft()   ; Bind ProcedureAddress to Prototype
  
  Procedure.i _SetMid(*String, *StringToSet, Pos, Length=#PB_All)
  ; ============================================================================
  ; NAME: _SetMid
  ; DESC: Because PureBasic do not have a Function to set the middle of a String,
  ; DESC: we need our own solution. PokeS is possible but do not have any
  ; DESC: plausiblity checks.
  ; DESC: !PointerVersion! use it as ProtoType SetMid()
  ; VAR(*String) : Pointer to the main String$
  ; VAR(Pos): Startposition for insert
  ; VAR(Length) : number or characters to insert
  ; VAR(*StringToSet): Pointer to StringToSet$
  ; RET.i : Number of copied characters
  ; ============================================================================
    Protected *Dest.pChar, *Source.pChar
    Protected cntChar, I
    
    If Pos > 0 
      
      If Length < 0
        Length = 2147483647   ; max Long
      EndIf
      
      *Source = *StringToSet
      *Dest= *String
     
      ; move *Destination-Pointer to Start-Pos and check plausiblity of Start-Pos
      For I=1 To Pos-1         
        If *Dest\c = 0
          ProcedureReturn 0       ; Start-Pos is outside of String
        Else
          CInc(*Dest)           ; increment CharPointer
        EndIf
      Next         
       
      While *Source\c                 ; If Source not at EndOfString
        If *Dest\c                    ; If Destination not at EndOfString  
          *Dest\c = *Source\c         ; Destination = Source
          CInc(*Source)               ; Set Pointer to next char
          CInc(*Dest)  
          cntChar + 1                 ; count number of characters
          If cntChar >= Length
            Break
          EndIf
        Else
          Break  
        EndIf         
      Wend
        
    EndIf
  
    ProcedureReturn cntChar
  EndProcedure
  SetMid = @_SetMid()   ; Bind ProcedureAddress to Prototype
  
  Procedure.i _SetRight(*String, *StringToSet, Length=#PB_All)
  ; ============================================================================
  ; NAME: _SetRight
  ; DESC: Because PureBasic do not have a Function to set the right of a String,
  ; DESC: we need our own solution. PokeS is possible but do not have any
  ; DESC: plausiblity checks.
  ; DESC: !PointerVersion! use it as ProtoType SetRight()
  ; VAR(*String) : Pointer to the main String$
  ; VAR(Length) : number or characters to insert
  ; VAR(*StringToSet): Pointer to StringToSet$
  ; RET.i : Number of copied characters
  ; ============================================================================
    Protected *Dest.pChar, *Source.pChar
    Protected cntChar, I
       
    If Length < 0
      Length = 2147483647   ; max Long
    EndIf
    
    *Source = *StringToSet
    *Dest= *String
        
    ; set SourcePointer to EndOfString
    While *Source\c
      ; it make sense to step trough the complete String instead of using Len()
      ; because len steps trough the complete String too!
      CInc(*Source)  
    Wend
    CDec(*Source) ; set CharPointer from EndOfString to last Character 
    
    ; set DestinationPointer to EndOfString
    While *Dest\c
      CInc(*Dest)  
    Wend
    CDec(*Dest)   ; set CharPointer from EndOfString to last Character 
    
    ; copy StringToSet Reverse Right into String
    While *Source >= *StringToSet    
      If *Dest >= *String           ; max. until 1st Character is reached
        *Dest\c = *Source\c         ; Copy Character from Source to Destination
        CDec(*Source)               ; Set Pointer to previous char
        CDec(*Dest)  
        cntChar + 1                 ; count number of characters
        If cntChar >= Length
          Break
        EndIf
      Else
        Break  
      EndIf         
    Wend      
  
    ProcedureReturn cntChar
  EndProcedure
  SetRight = @_SetRight()   ; Bind ProcedureAddress to Prototype
  
  Procedure.s ColumnText(Text$, ColWidth=12, TextAlign=#PX_AlignCenter)
  ; ============================================================================
  ; NAME: ColumnText
  ; DESC: Get a Table Column String
  ; VAR(Text$): The Columns Text
  ; VAR(ColWidth): The column width in No of characters
  ; VAR(TextAlign): How to align the text in the column #CC_Align{Left/Center/Right})
  ; RET.s : The fixed spaced String. Use a Monospaced Font to get a Table effect
  ; ============================================================================
    Protected ret.s 
    Protected lTxt = Len(Text$)
    
    Select TextAlign
        
      Case #PX_AlignCenter
        If lTxt >= ColWidth
          ret = Left(Text$, ColWidth)
        Else
          ret = Space(ColWidth)
          PX::SetMid(ret,Text$, (ColWidth-lTxt)/2)
        EndIf
        
      Case #PX_AlignLeft
        ret = LSet(Text$, ColWidth, " ")
                
      Case #PX_AlignRight
        ret = RSet(Text$, ColWidth, " ")
    
    EndSelect
    
    ProcedureReturn ret
  EndProcedure

  Procedure.s _TextBetween(*String, Left$, Right$=#Null$)
  ; ============================================================================
  ; NAME: TextBetween
  ; DESC: Gets the Text between the first two String elements Left$ and Right$
  ; DESC: Attention it is an easy version which do not support cascaded between 
  ; DESC: like in brackets "((InBrackets))". TextBetween will deliver "(InBrackets"
  ; VAR(String$) : The String
  ; VAR(Left$) : Left side like "("
  ; VAR(Right$) : Right side like ")". If Right$=#Null$ -> Return from Left$ until End
  ; RET.s : The Text between Left$ and Right$
  ; ============================================================================
    
    Protected posL, posR, xRight
    Protected Str.String, *pStr.Integer ; for hooking *String into Str.String 
    
    ; because FindString() do not accept Pointers, we have to hook the 
    ; *String and *Separator into a String-Structure, The trick is to overlay
    ; an Integer Structure over the String Structure - this is like StructureUnion
    ; but hand made!
    *pStr = @Str            ; Overlay IntergerStructure on String Structure
    *pStr\i = *String       ; Hook String into Str\s => PokeI(@Str, *String))   
    xRight = Bool(Right$)   ; Check for Right$=#Null$ to return until EndOfString
    
    posL = FindString(Str\s, Left$)   
    If posL
      *String = *String + posL*SizeOf(Character) + Len(Left$)*SizeOf(Character) - SizeOf(Character) ; Pointer to Char after Position found
      *pStr\i = *String   ; New Startposition for FindString
      
      If xRight     
        posR = FindString(Str\s, Right$)  
        If posR
          *pStr\i = 0   ; Unhook String -> delete the Pointer of the String in Str\s
          ProcedureReturn PeekS(*String, posR-1)
        EndIf
      Else    ; Right$ = #Null$ -> Return until EndOfString
        *pStr\i = 0   ; Unhook String -> delete the Pointer of the String in Str\s
        ProcedureReturn PeekS(*String) 
      EndIf     
      
    EndIf
    
    ; befor leaving the Procedure we have to unhook the Strings, otherwise PB will delete
    ; the original String allocated Memory and the original String Point to non allocated
    ; Memory.
    *pStr\i = 0   ; Unhook String -> delete the Pointer of the String in Str\s   
    ProcedureReturn #Null$
  EndProcedure
  TextBetween=@_TextBetween()
  
  Procedure.i _TextBetweenList(List Out.s(), *String, Left$, Right$)
  ; ============================================================================
  ; NAME: TextBetweenList
  ; DESC: Gets the Text between two String elements Left$ and Right$
  ; DESC: as a List. It can be used to get get the text between: <Text> or (Text)
  ; DESC: in html files. And for many other use. 
  ; VAR(List Out.s()) : The List with the found Strings
  ; VAR(*String) : Pointer to String
  ; VAR(Left$) : The left side like "("
  ; VAR(Right$) : Right side like ")"
  ; RET.i : The number of found Strings (it is identical with the ListSize)
  ; ============================================================================
    Protected posL, posR, xRight        ; Character postion of found Char 
    Protected lenBL, lenBR              ; Bytelength of Left$, Right$ 
    Protected Str.String, *pStr.Integer ; for hooking *String into Str.String 
        
    ClearList(Out())
    lenBL = Len(Left$) * SizeOf(Character)
    lenBR = Len(Right$) * SizeOf(Character)
    
    If *String=0 Or lenBL=0 Or lenBR=0
      ProcedureReturn 0  
    EndIf
    
    ; because FindString() do not accept Pointers, we have to hook the 
    ; *String and *Separator into a String-Structure, The trick is to overlay
    ; an Integer Structure over the String Structure - this is like StructureUnion
    ; but hand made!
    *pStr = @Str            ; Overlay IntergerStructure on String Structure
    *pStr\i = *String       ; Hook String into Str\s => PokeI(@Str, *String))
    xRight = Bool(Right$)   ; Check for Right$=#Null$ to return until EndOfString
    
    Repeat
      posL = FindString(Str\s, Left$)
      If posL
        *String = *String + posL*SizeOf(Character) + lenBL - SizeOf(Character)    ; Pointer to Char after Position found
        *pStr\i = *String           ; New Startposition after Left$
        posR = FindString(Str\s, Right$)
        
        If posR
          AddElement(Out())
          Out()=PeekS(*String, posR-1)
          *String = *String + posR*SizeOf(Character) + lenBR - SizeOf(Character)  ; Pointer to Char after Position found
          *pStr\i = *String         ; New Startposition after Right$
        Else
          Break        
        EndIf       
      Else
        Break
      EndIf       
    ForEver
    
    ; befor leaving the Procedure we have to unhook the String, otherwise PB will delete
    ; the original String allocated Memory and the original String Point to non allocated
    ; Memory.
    *pStr\i = 0   ; Unhook String -> delete the Pointer of the String in Str\s   
    ProcedureReturn ListSize(Out())
  EndProcedure
  TextBetweenList=@_TextBetweenList()
  
  Procedure.i _TextBetweenArray(Array Out.s(1), *String, Left$, Right$, ArrayRedimStep=10)
  ; ============================================================================
  ; NAME: TextBetweenList
  ; DESC: Gets the Text between two String elements Left$ and Right$
  ; DESC: as an Array. It can be used to get get the text between '<' '>'
  ; DESC: in html files. And for many other use. 
  ; VAR(Array Out.s(1)) : The Array with the found Strings
  ; VAR(*String) : Pointer to String
  ; VAR(Left$) : The left side like "("
  ; VAR(Right$) : Right side like ")".
  ; VAR(ArrayRedimStep) : How may entries are added to the String each ReDim
  ;                       if you know the exact No of Substrings before, use it here!
  ;                       this prevents from ReDim.
  ; RET.i : The number of found Strings (it is identical with the ListSize)
  ; ============================================================================
    Protected posL, posR, xRight        ; Character postion of found Char 
    Protected lenBL, lenBR              ; Bytelength of Left$, Right$ 
    Protected ASize, N
    Protected Str.String, *pStr.Integer ; for hooking *String into Str.String 
        
    lenBL = Len(Left$) * SizeOf(Character)
    lenBR = Len(Right$) * SizeOf(Character)
    
    If *String=0 Or lenBL=0 Or lenBR=0
      ProcedureReturn 0  
    EndIf
    
    ASize = ArraySize(Out())    
    If ASize = -1         ; not Dim
      ASize = ArrayRedimStep
      Dim Out(ASize)
    EndIf            
    
    ; because FindString() do not accept Pointers, we have to hook the 
    ; *String and *Separator into a String-Structure, The trick is to overlay
    ; an Integer Structure over the String Structure - this is like StructureUnion
    ; but hand made!
    *pStr = @Str            ; Overlay IntergerStructure on String Structure
    *pStr\i = *String       ; Hook String into Str\s => PokeI(@Str, *String))
    xRight = Bool(Right$)   ; Check for Right$=#Null$ to return until EndOfString
    
    Repeat
      posL = FindString(Str\s, Left$)
      If posL
        *String = *String + posL*SizeOf(Character) + lenBL - SizeOf(Character)    ; Pointer to Char after Position found
        *pStr\i = *String           ; New Startposition after Left$
        posR = FindString(Str\s, Right$)
        
        If posR
          If ASize < N
            ASize + ArrayRedimStep
            ReDim Out(ASize)
          EndIf            
          Out(N)=PeekS(*String, posR-1)
          *String = *String + posR*SizeOf(Character) + lenBR - SizeOf(Character)  ; Pointer to Char after Position found
          *pStr\i = *String         ; New Startposition after Right$
          N+1
        Else
          Break        
        EndIf       
      Else
        Break
      EndIf       
    ForEver
    
    ; befor leaving the Procedure we have to unhook the Strings, otherwise PB will delete
    ; the original String allocated Memory and the original String Point to non allocated
    ; Memory.
    *pStr\i = 0   ; Unhook String -> delete the Pointer of the String in Str\s   
    ProcedureReturn N
  EndProcedure
  TextBetweenArray=@_TextBetweenArray()

  Procedure.i _SplitStringArray(Array Out.s(1), *String, *Separator, DQuote=#False, ArrayRedimStep=10)
  ; ============================================================================
  ; NAME: _SplitStringArray
  ; DESC: Split a String into multiple Strings
  ; DESC: 
  ; VAR(Out.s())    : Array to return the Substrings (ArraySize >= Substrings)
  ; VAR(*String)    : Pointer to String 
  ; VAR(*Separator) : Pointer to Separator String 
  ; VAR(DQuote)     : #True=skip search for Separator in quoted text, #Flase=search everywhere  
  ; VAR(ArrayRedimStep) : How may entries are added to the String each ReDim
  ;                       if you know the exact No of Substrings before, use it here!
  ;                       this prevents from ReDim.
  ; RET.i           : No of Substrings
  ; ============================================================================
    
    Protected lsep, I, xDo, N, ASize
    Protected *pStart 
    Protected *pRead.pChar
    Protected *pSep.pChar
    
    If Not *String
      ProcedureReturn 0
    EndIf
    
    *pRead = *String        ; ReadPointer
    *pStart = *String       ; Pointer of search Start
    *pSep = *Separator      ; Pointer of Separator
         
    If *Separator
      ; lsep = Len(Separator)
      While *pSep\c[lsep]    ; Trick to get length with indexed pChar
        lsep + 1
      Wend
    EndIf
    
    ASize = ArraySize(Out())    
    
    If *Separator=0 Or lsep=0
      If ASize = -1         ; not Dim
         Dim Out(0)
      EndIf            
      Out(0) = PeekS(*String)
      ProcedureReturn 1
    EndIf
    
    If ASize = -1         ; not Dim
      ASize = ArrayRedimStep
      Dim Out(ASize)
    EndIf            
        
    Repeat      
      ; ----------------------------------------------------------------------
      If DQuote  ; skip qutoed Text for search Separator -> do not split in quotes
      ; ----------------------------------------------------------------------  
        ; move *pRead to first matching Character
        While *pRead\c <> *pSep\c
          Select *pRead\c
            Case 0    ; Break if EndOfString
              Break 
              
            Case '"'  ; DoubleQuote
              ; move *pRead to 2nd " to ignore Text in Quotes
              CInc(*pRead)  ; Char after "
              While *pRead\c <> '"'
                If *pRead\c = 0
                  Break 2
                EndIf
                CInc(*pRead)
              Wend             
          EndSelect
          CInc(*pRead)
        Wend        
      ; ----------------------------------------------------------------------
      Else    ; do not check for Text in Quotes
      ; ----------------------------------------------------------------------      
        ; move *pRead to first matching Character
        While *pRead\c <> *pSep\c
          If *pRead\c = 0    ; Break if EndOfString
            Break 
          EndIf   
          CInc(*pRead)
        Wend
        
      EndIf
      ; ----------------------------------------------------------------------
    
      If *pRead\c ; If Not EndOfString -> we found a Separator
        If lsep = 1
          ; if Len(Separator) = 1 -> split here
          xDo = #True
        Else         
          xDo = #True
          ; Check if all Characters matching?
          For I = 1 To lsep-1 ; we can start at 2nd char because 1st char is steill checked for equal
            If *pRead\c[I] <> *pSep\c[I]
              xDo = #False  ; Character do not Match -> Separator not found!
              Break
            EndIf
          Next
        EndIf
      
        ; If CompareMemoryString(*pRead, *Separator, #PB_String_CaseSensitive, lsep)= #PB_String_Equal
        If xDo  
          If ASize < N
            ASize + ArrayRedimStep
            ReDim Out(ASize)
          EndIf
        
          Out(N) = PeekS(*pStart, (*pRead - *pStart)/SizeOf(Character))
          N+1
          *pRead + lsep * SizeOf(Character)
          *pStart = *pRead
        EndIf 
      Else
        Break
      EndIf
      
    ForEver ; Until *pRead\c = 0 
    
    ; return last Element
    If ASize < N
      ASize + 1
      ReDim Out(ASize)
;     ElseIf Asize > N
;       ReDim Out(N)
    EndIf  
    Out(N) = PeekS(*pStart) 
    N+1      
    ProcedureReturn N     ; Number of Substrings        
  EndProcedure 
  SplitStringArray = @_SplitStringArray()   ; Bind ProcedureAddress to Prototype
  
  Procedure.i _SplitStringList(List Out.s(), *String, *Separator, DQuote = #False, clrList= #True)
  ; ============================================================================
  ; NAME: _SplitStringList
  ; DESC: Split a String into multiple Strings
  ; DESC: 
  ; VAR(Out.s())   : List to return the Substrings 
  ; VAR(*String)   : Pointer to String 
  ; VAR(*Separator): Pointer to Separator String 
  ; VAR(DQuote)    : #True=skip search for Separator in quoted text, #Flase=search everywhere  
  ; VAR(clrList)   : #False: Append Splits to List; #True: Clear List first
  ; RET.i          : No of Substrings
  ; ============================================================================
    
    Protected lsep, I, xDo
    Protected *pStart 
    Protected *pRead.pChar
    Protected *pSep.pChar
    
    If Not *String
      ProcedureReturn 0
    EndIf
    
    If clrList
      ClearList(Out())  
    EndIf
    
    *pRead = *String        ; ReadPointer
    *pStart = *String       ; Pointer of search Start
    *pSep = *Separator      ; Pointer of Separator
   
    If *Separator
      ; lsep = Len(Separator)
      While *pSep\c[lsep]    ; Trick to get length with indexed pChar
        lsep + 1
      Wend
    EndIf
    
    If *Separator=0 Or lsep=0
      AddElement(Out())
      Out() = PeekS(*String)
      ProcedureReturn 1
    EndIf
 
    Repeat      
      ; ----------------------------------------------------------------------
      If DQuote  ; skip qutoed Text for search Separator -> do not split in quotes
      ; ----------------------------------------------------------------------  
        ; move *pRead to first matching Character
        While *pRead\c <> *pSep\c
          Select *pRead\c
            Case 0    ; Break if EndOfString
              Break 
              
            Case '"'  ; DoubleQuote
              ; move *pRead to 2nd " to ignore Text in Quotes
              CInc(*pRead)      ; Char after "
              While *pRead\c <> '"'
                 If *pRead\c = 0
                  Break 2
                EndIf
               CInc(*pRead)  
             Wend             
          EndSelect
          CInc(*pRead)
        Wend        
      ; ----------------------------------------------------------------------
      Else    ; do not check for Text in Quotes
      ; ----------------------------------------------------------------------      
        ; move *pRead to first matching Character
        While *pRead\c <> *pSep\c
          If *pRead\c = 0    ; Break if EndOfString
            Break 
          EndIf   
          CInc(*pRead)
        Wend
        
      EndIf
      ; ----------------------------------------------------------------------
    
      If *pRead\c ; If Not EndOfString -> we found a Separator
        If lsep = 1
          ; if Len(Separator) = 1 -> split here
          xDo = #True
        Else         
          xDo = #True
          ; Check if all Characters matching?
          For I = 1 To lsep-1 ; we can start at 2nd char because 1st char is steill checked for equal
            If *pRead\c[I] <> *pSep\c[I]
              xDo = #False  ; Character do not Match -> Separator not found!
              Break
            EndIf
          Next
        EndIf
      
        ; If CompareMemoryString(*pRead, *Separator, #PB_String_CaseSensitive, lsep)= #PB_String_Equal
        If xDo  
          AddElement(Out())
          Out() = PeekS(*pStart, (*pRead - *pStart)/SizeOf(Character))      
          *pRead + lsep * SizeOf(Character)
          *pStart = *pRead
        EndIf 
      Else
         Break
      EndIf
      
    ForEver ; Until *pRead\c = 0 
    
    ; return last Element
    AddElement(Out())
    Out() = PeekS(*pStart)      
       
    ProcedureReturn ListSize(Out())     ; Number of Substrings        
  EndProcedure 
  SplitStringList = @_SplitStringList()   ; Bind ProcedureAddress to Prototype
  
  Procedure.s JoinArray(Array ary.s(1), Separator$="", StartIndex=0, EndIndex=-1, *IOutLen.Integer=0)
  ; ============================================================================
  ; NAME: JoinArray
  ; DESC: Join all ArrayElements to a single String
  ; VAR(ary.s(1))   : The String Array
  ; VAR(Separator$) : A separator String
  ; VAR(StartIndex) : The Index of the 1st Entry to start with
  ; VAR(EndIndex)   : The Index of the last Entry
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
  
  Procedure.s JoinList(List lst.s(), Separator$="", *IOutLen.Integer=0)
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
  
  Procedure.i StringArrayToList(Array aryStr.s(1), List lstStr.s())
  ; ============================================================================
  ; NAME: StringArrayToList
  ; DESC: Copies a String-Array to a StringList
  ; VAR(Array aryStr.s(1)) : The StringArray with 1 dimension
  ; VAR(List lstStr.s()) : The StringList
  ; RET.i : The number of found Strings copied
  ; ============================================================================
    Protected I, N
    
    N = ArraySize(aryStr())   
    If N
      ClearList(lstStr())     
      For I = 0 To N 
        AddElement(lstStr())
        lstStr() = aryStr(I)
      Next
    EndIf 
    ProcedureReturn N+1
  EndProcedure
  
  Procedure.i StringListToArray(List lstStr.s(), Array aryStr.s(1))
  ; ============================================================================
  ; NAME: StringListToArray
  ; DESC: Copies a StringList to a String-Array
  ; VAR(List lstStr.s()) : The StringList
  ; VAR(Array aryStr.s(1)) : The StringArray with 1 dimension
  ; RET.i : The number of found Strings copied
  ; ============================================================================
    Protected I, N
    
    N = ListSize(lstStr())   
    If N
      Dim aryStr(N-1)
      ForEach lstStr()
        aryStr(I) = lstStr()
        I + 1 
      Next
    EndIf    
    ProcedureReturn N
  EndProcedure
    
  ;- --------------------------------------------------
  ;- Gadgets
  ;- -------------------------------------------------- 
       
  Procedure SetGadgetTextAlign(GadgetNo, AlignType)
  ; ============================================================================
  ; NAME: SetGadgetTextAlign
  ; DESC: Purebasic do not support Gadget TextAlign after Gadget creation.
  ; DESC: This functions sets the TextAlign for Gadgets at Runtime 
  ; DESC: All OS
  ; DESC: !!! original from PB-Forum by mk-Soft !!!
  ; VAR(GadgetNo): PB Gadget-No
  ; VAR(AlignType): #PX_AlignLeft, #PX_AlignCenter, #PX_AlignRight 
  ; RET.i : -
  ; ============================================================================
    
    ; mk-soft and Unknown, v1.01.1, 12.06.2025
    ; https://www.purebasic.fr/english/viewtopic.php?t=87074
  
    CompilerSelect #PB_Compiler_OS
        
      CompilerCase #PB_OS_Windows
      ; ----------------------------------------------------------------------
      ;  Windows
      ; ----------------------------------------------------------------------
        Protected hwnd = GadgetID(GadgetNo)
        Protected style = GetWindowLongPtr_(hwnd, #GWL_STYLE)
        
        Select AlignType
          Case #PX_AlignLeft
            style = style & ~#ES_CENTER & ~#ES_RIGHT
          Case #PX_AlignCenter
            style = style & ~#ES_RIGHT | #ES_CENTER
          Case #PX_AlignRight
            style = style & ~#ES_CENTER | #ES_RIGHT
        EndSelect
        SetWindowLongPtr_(hwnd, #GWL_STYLE, style)
        InvalidateRect_(hwnd, 0, #True)
         
      CompilerCase #PB_OS_Linux
      ; ----------------------------------------------------------------------
      ;  Linux
      ; ----------------------------------------------------------------------
        Protected widget = GadgetID(GadgetNo)
        
        Select GadgetType(GadgetNo)
            
          Case #PB_GadgetType_String
            Select AlignType
              Case #PX_AlignLeft
                gtk_entry_set_alignment(widget, 0.0)
              Case #PX_AlignCenter
                gtk_entry_set_alignment(widget, 0.5)
              Case #PX_AlignRight
                gtk_entry_set_alignment(widget, 1.0)
            EndSelect
            
          Case #PB_GadgetType_Text
            
            CompilerIf Subsystem("GTK2")
              Select AlignType
                Case #PX_AlignLeft
                  gtk_misc_set_alignment(widget, 0.0, 0.0)
                  gtk_label_set_justify_(widget, #GTK_JUSTIFY_LEFT)
                Case #PX_AlignCenter
                  gtk_misc_set_alignment(widget, 0.5, 0.0)
                  gtk_label_set_justify_(widget, #GTK_JUSTIFY_CENTER)
                Case #PX_AlignRight
                  gtk_misc_set_alignment(widget, 1.0, 0.0)
                  gtk_label_set_justify_(widget, #GTK_JUSTIFY_RIGHT)
              EndSelect
              
            CompilerElse ; (QT or GTK3) PB help says use Subsystem "QT" instead of "GTK3"
              ; S.Maag! I guess for QT only this will not work. It will work if GTK is installed too.
              ; Normally Linux installs the GTK parallel if any GTK Application is installed under QT.
              ; Maybe a PB applikation under QT links the GTK library, so it will be installed.
              Select AlignType
                Case #PX_AlignLeft
                  gtk_label_set_xalign(widget, 0.0)
                  gtk_label_set_justify_(widget, #GTK_JUSTIFY_LEFT)
                Case #PX_AlignCenter
                  gtk_label_set_xalign(widget, 0.5)
                  gtk_label_set_justify_(widget, #GTK_JUSTIFY_CENTER)
                Case #PX_AlignRight
                  gtk_label_set_xalign(widget, 1.0)
                  gtk_label_set_justify_(widget, #GTK_JUSTIFY_RIGHT)
              EndSelect
          CompilerEndIf    
          
      EndSelect
                
      CompilerCase #PB_OS_MacOS
      ; ----------------------------------------------------------------------
      ;  MacOS
      ; ----------------------------------------------------------------------
        Select AlignType
          Case #TextLeft
            CocoaMessage(0, GadgetID(GadgetNo), "setAlignment:", #NSLeftTextAlignment)
          Case #TextCenter
            CocoaMessage(0, GadgetID(GadgetNo), "setAlignment:", #NSCenterTextAlignment)
          Case #TextRight
            CocoaMessage(0, GadgetID(GadgetNo), "setAlignment:", #NSRightTextAlignment)
        EndSelect
         
    CompilerEndSelect
    
  EndProcedure
  
  ;- --------------------------------------------------
  ;- Miscellaneous
  ;- -------------------------------------------------- 
  
  Procedure.i GetPbDataSectionPtr() 
  ; ============================================================================
  ; NAME: GetDataSectionPtr
  ; DESC: Get the PureBasic internal Datasection DataPointer.
  ; DESC: The PB_DataPointer is the PB internal variable for the DataPointer
  ; DESC; used by PB's Read command.
  ; DESC: We can't access the DataPointer directly in PB-Code. It exists 
  ; DESC: only as variable in the compiled ASM and C-Code.
  ; RET.i : The actual PB DataSection Pointer
  ; ============================================================================
    CompilerIf (#PB_Compiler_Backend = #PB_Backend_Asm)
      CompilerIf (#PB_Compiler_Processor = #PB_Processor_x86)
        !mov eax, [PB_DataPointer]
        ProcedureReturn
      CompilerElse   
        !mov rax, [PB_DataPointer]
        ProcedureReturn
      CompilerEndIf
    CompilerElse
      !return pb_datapointer;
    CompilerEndIf
  EndProcedure

  Procedure SetPbDataSectionPtr(*pData) 
  ; ============================================================================
  ; NAME: SetDataSectionPtr
  ; DESC: Set the PureBasic internal Datasection DataPointer.
  ; DESC: The PB_DataPointer is the PB internal variable For the DataPointer
  ; DESC; used by PB's Read command.
  ; DESC: We can't access the DataPointer directly in PB-Code. It exists 
  ; DESC: only as variable in the compiled ASM and C-Code.
  ; RET : -
  ; ============================================================================
    
    ; https://www.purebasic.fr/english/viewtopic.php?t=35658
    
    CompilerIf (#PB_Compiler_Backend = #PB_Backend_Asm)
      CompilerIf (#PB_Compiler_Processor = #PB_Processor_x86)
        !mov eax, [p.p_pData]
        !mov [PB_DataPointer], eax
      CompilerElse   
        !mov rax, [p.p_pData]
        !mov [PB_DataPointer], rax  
      CompilerEndIf
    CompilerElse
      ; in C we have to use LoChar for all commands
      !pb_datapointer = (unsigned char *) p_pdata;  
    CompilerEndIf
  EndProcedure
  
EndModule

CompilerIf #PB_Compiler_IsMainFile
 ; ----------------------------------------------------------------------
 ;  M O D U L E   T E S T   C O D E
 ; ---------------------------------------------------------------------- 
 
  EnableExplicit
  
  ; use the Real Macro to define floats in x32 as .f and in x64 as .d
  Define R1.PX::Real = 1.1
  Define R2.PX::Real = 1.2
  Debug R1 + R2
  
  UseModule PX
  
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
  ; or open PbFw_Module_Phonetics.pb
  
  ; with the pChar Pointer I implemented phonetic encoding of Strings
  ; for Soundex and Cologne Phonetics algortihm in an easy way!
  
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
          If IsSpaceTabChar(\c[1])  ; following is Space or Tab
            \c = 'A'
          EndIf
          
        Case 'T'
          \c = 't'    ; overwerite 'T' with 't'
          
        Case '7'
          ; !!! be very carefull with \c[-x]  \c[x]. Be sure to point to valid memory!
          If cnt > 1  ; we are at least at 2nd char, so we can go 1 back
            If \c[-1] = '9' And \c[1] = '9' ; previous Char and next Char = '9'
              \c = '0'    ; overwrite '7' with '0'
            EndIf
          EndIf
          
        Default
          
      EndSelect
     
      CInc(*pC)   ; Increment CharPointer
    Wend
  EndWith
  Debug txt$
  
  Debug ""
  Debug "------------------------------------------"
  Debug "----  SetMid(), SetLeft(), SetRight() ----"
  Debug "------------------------------------------"
  
  Define Text$ = "This is a xxxx to test Set_Left/Mid/Right-Function"

  Define Pos = FindString(Text$, "xxxx")
  Debug Text$
  Debug "SetMid 'text' at POS=" + pos
  PX::SetMid(Text$, "text", Pos)
  Debug Text$
  Debug "SetLeft 'THIS'"
  PX::SetLeft(Text$, "THIS")
  Debug Text$
  Debug "SetRight 'FUNCTION'"
  PX::SetRight(Text$, "FUNCTION")
  Debug Text$
CompilerEndIf



; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 750
; FirstLine = 706
; Folding = --------------------------
; Markers = 1351,2772
; Optimizer
; CPU = 5