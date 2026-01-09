; ===========================================================================
;  FILE: PbFw_Module_S7.pb
;  NAME: Module S7 
;  DESC: S7 Base Module
;  DESC: 
;  DESC: 
;  DESC: 
;  SOURCES:  
;     https://
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/01/01
; VERSION  :  0.60 not fully tested Developer Version
; COMPILER :  PureBasic 6.0 and higher
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;; ChangeLog: 
;{ 2026/01/09 S.Maag: CleanUp of Functions and Function Names -> Version to 0.60
;  2026/01/06 S.Maag: Rollback For S7 Get/Set Functions from (*hS7)-Handle Structure
;                     to (*Buf, BufByteSize). This easy way is better an more flexible!
;  2025/12/29 S.Maag: solved Bug in CheckBuffer calls
;  2025/02/15 S.Maag: added seperate Buffer for Read/Write 
;  2024/12/08 S.Maag: added some functions and reworked some 
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "..\Modules\PbFw_Module_PbFw.pb"         ; PbFw::    FrameWork control Module
XIncludeFile "..\Modules\PbFw_Module_PX.pb"           ; PX::      Purebasic Extention Module
;XIncludeFile "..\Modules\PbFw_Module_Debug.pb"       ; DBG::     Debug Module
; XIncludeFile "..\Modules\PbFw_Module_Bits.pb"       ; Bits::    Bit Operations

; XIncludeFile ""

DeclareModule S7
  
  EnableExplicit
  
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
    
  Enumeration eS7_TmrRead
    #S7_TmrRead_100ms = 100
    #S7_TmrRead_200ms = 200
    #S7_TmrRead_500ms = 500
    #S7_TmrRead_1s = 1000
    #S7_TmrRead_2s = 2000
    #S7_TmrRead_5s = 5000   
  EndEnumeration
  
  ; Siemens PLC internal Codes for the DataTypes -> used in AnyPointer
  ; $00 = NIL  : Nullpointer
  ; $01 = BOOL  
  ; $02 = BYTE
  ; $03 = CHAR
  ; $04 = WORD
  ; $05 = INT
  ; $06 = DWORD
  ; $07 = DINT
  ; $08 = REAL
  ; $09 = DATE
  ; $0A = TIME_OF_DAY
  ; $0B = TIME
  ; $0C = S5_TIME
  ; $0D = undefined
  ; $0E = DATE_AND_TIME
  ; $13 = STRING
  
  ; $17 = BLOCK_FB
  ; $18 = BLOCK_FC
  ; $19 = BLOCK_DB
  ; $1A = BLOCK_SDB
  ; $1C = COUNTER
  ; $1D = TIMER
  
  Enumeration eS7_DataType
    ; do not change any value -> same values as in the PLC 
    ; --------------------------------------------------
    ; Basic Types
    #S7_DataType_NIL = 0         ; = 0
    #S7_DataType_BOOL            ; = 1; 1 Bit
    #S7_DataType_BYTE            ; = 2; 1 Byte
    #S7_DataType_CHAR            ; = 3; 1 Byte
    #S7_DataType_WORD            ; = 4; 2 Bytes
    #S7_DataType_INT             ; = 5; 2 Bytes
    #S7_DataType_DWORD           ; = 6; 4 Bytes
    #S7_DataType_DINT            ; = 7; 4 Bytes
    #S7_DataType_REAL            ; = 8; 4 Bytes
    #S7_DataType_DATE            ; = 9; 2 Bytes
    #S7_DataType_TIME_OF_DAY     ; =10; 4 Bytes
    #S7_DataType_TIME            ; =11; 4 Bytes
    #S7_DataType_S5TIME          ; =12; 2 Bytes
    #S7_DataType_DATE_AND_TIME   ; =13; 8 Bytes    
    #S7_DataType_STRING = $13    ; =19; max 256 Bytes (max 254 Chars)
       
    ; Parameter Types (can't be used in DataBlocks)
    #S7_DataType_BLOCK_FB = $17  ; =23; 2 Bytes
    #S7_DataType_BLOCK_FC        ; =24; 2 Bytes
    #S7_DataType_BLOCK_DB        ; =25; 2 Bytes
    #S7_DataType_BLOCK_SDB       ; =26; 2 Bytes
    #S7_DataType_COUNTER         ; =27; 2 Bytes
    #S7_DataType_TIMER           ; =38; 2 Bytes
    ; --------------------------------------------------
    
    ; --- from here on the values are not defined in the Siemens Manual ----
    ; combined Types! We start at $100 = 256 as our user defined values
    #S7_DataType_POINTER = $100  ; 6 Bytes
    #S7_DataType_ANY             ; 10 Bytes  
    #S7_DataType_ARRAY           ; user defined
    #S7_DataType_STRUCT          ; user defined
    #S7_DataType_UDT             ; user defined
  EndEnumeration
  
  ; ----------------------------------------------------------------------
  ;  S7 internal constants. See Step7 documentation or Simatic Manger help
  ; ----------------------------------------------------------------------
  ; S7 Block Type ID
  Enumeration eS7_BlockType
    #S7_BlockType_OB  = $38 ; "8"     ; Organization Block 'OB'
    #S7_BlockType_DB  = $41 ; "A"     ; Data Block 'DB'
    #S7_BlockType_SDB = $42 ; "B"     ; System Data Block 'SDB'
    #S7_BlockType_FC  = $43 ; "C"     ; Function 'FC'
    #S7_BlockType_SFC = $44 ; "D"     ; System Function 'SFC'
    #S7_BlockType_FB  = $45 ; "E"     ; Function Block 'FB'
    #S7_BlockType_SFB = $46 ; "F"     ; System Function Block 'SFB'
  EndEnumeration
  
  ; Memory Area ID
  Enumeration eS7_AreaID
    #S7_AreaID_PI = $81             ; Periphery Inputs (Digital and analog inputs)
    #S7_AreaID_PQ = $82             ; Periphery Outputs (Digital and analog outputs)
    #S7_AreaID_TAG = $83            ; TAGs, Flags ('Merker')
    #S7_AreaID_DB = $84             ; Data Blocks 
    #S7_AreaD_DI = $85              ; Instance Data Blocks
    #S7_AreaID_LStack = $86         ; Local Stack        (= VAR_TEMP of the actual FB/FC)
    #S7_AreaID_FormerLStack = $87   ; Former Local Stack (= VAR_TEMP of the calling FB/FC)
    #S7_AreaID_S7Ctr = $1C          ; 28  S5/S7 format Counter C1..C255
    #S7_AreaID_S7Tmr = $1D          ; 31  S5/S7 format Timer   T1..T255
  EndEnumeration
  
  ; For PureBasic internal use, we convert the S7 BCD formated DATE_AND_TIME to decimal values
  Structure TS7_DATE_AND_TIME
    Year.l        ; [1990..2089] = S7 internal [90..99 = 1990.1999; 0..89 = 2000..2089]
    Month.l       ; [1..12]
    Day.l         ; [1..31]
    hour.l        ; [0..23]
    minute.l      ; [0..59]
    second.l      ; [0..59]
    millsec.l     ; [0..999]
    WeekDay.l     ; [1..7 = Sunday..Saturday]
  EndStructure

;   Structure TS7_TimeOfDay
;     hh.l  
;     mm.l
;     ss.l
;   EndStructure
  
  ; ----------------------------------------
  ; S7-POINTER  : PLC internal 6-Bytes
  ; ----------------------------------------
  
  ; Byte 0..1       : DB No. or 0 (Datablock number) 
  ; Byte 2          : Memory area
  ; Byte 3 Bit 3..7 : always 0 (reserve)
  ; Byte 4 Bit 0..2 : MSB of Byte Adress
  ; Byte 5          : Part of Byte Address
  ; Byte 6 Bit 3..7 : LSB of Byte Adress
  ; Byte 6 Bit 0..2 : Bit Address

  ; Attention! It is not the same Memory Model as in the PLC (in PLC POINTER is 6 Bytes)
  Structure TS7_POINTER_ITEMS   ; 8 Bytes 
    DB_No.u     ; [2 Byte]
    MemID.u     ; [2 Byte]
    ByteAddr.u  ; [2 Byte]
    BitAddr.u   ; [2 Byte] Bit-Address: 3LSB = BitNo
  EndStructure
  
  ; This Structure is used to set a 8 Byte Quad value to same Address as the PointerItems
  ; with this Trick we can use a Quad for GetPointer and SetPointer and we have a direct
  ; access to the Items. Attention we use a 8 Byte Structure here, what is a 6 Byte Structre in the PLC
  Structure TS7_POINTER
    StructureUnion              ; set 2 different views for the Pointer Value. A Quad and the ItemStruct 
      q.q
      Item.TS7_POINTER_ITEMS
    EndStructureUnion
  EndStructure
  
  ; ----------------------------------------
  ; S7-ANY-POINTER  : PLC internal 10-Bytes
  ; ----------------------------------------
  
  ; PLC internal the ANY-Pointer is 10 Byte Value
  ; Byte 0    : 10h  (fix value for S7) 
  ; Byte 1    : Datatype
  ; Byte 2..3 : Iterations
  
  ; from Byte 4 on it's a S7-POINTER
  ; Byte 4..5 : DB No. or 0  (Datablock number) 
  ; Byte 6    : Memory area
  ; Byte 7 Bit 3..7 :  always 0 (reserve)
  ; Byte 7 Bit 0..2 : MSB of Byte Adress
  ; Byte 8          :  Part of Byte Address
  ; Byte 9 Bit 3..7 : LSB of Byte Adress
  ; Byte 9 Bit 0..2 : Bit Address
  
  Structure TS7_ANY
    S7ID.a        ; [1 Byte]
    DataType.a    ; [1 Byte]
    Iterations.u  ; [2 Byte]
    DB_No.u       ; [2 Byte]
    MemID.a       ; [1 Byte]
    ByteAddr.u    ; [2 Byte]
    BitAddr.u     ; [2 Byte] Bit-Address: 3LSB = BitNo
  EndStructure    ; 
  
  ; S7 use a Stringbuffer with an max length of 255 Byte
  ; 1st Byte of the String is the lenght of the Buffer
  ; 2nd Byte is the actual length of the String
  ; if we want to manipulate the string, we must set the 2nd Byte to the correct String length <= LenStrBuffer
  Structure TS7_String
    LenBuffer.a         ; S7 max String length  = length of the String Buffer
    LenString.a         ; S7 actual length of String
    String$             ; the String 
  EndStructure
  
  ; use #BufferMaxByteIdx to cerate the ReadBuffer.a(#BufferMaxByteIdx) for your CPU
  ; if you have to Read more than 16kB in a single read, modify this constant
  
  #BufferSize32k = 1024*32                  ;  32 kByte ReadBuffer 32768
  #BufferMaxByteIdx = #BufferSize32k -1     ;  This is the UBound for your Buffer(0..#BufferMaxByteIdx)
      
  Structure TS7_CPU
    IP$                 ; CPU IP-Address String "192.168.20.2"
    pbIP.i              ; CPU IP Address in PureBasic Format, created with MakeIPAddress()
    Rack.i              ; S7 CPU-RackNo
    Slot.i              ; S7 Slot No or CPU (for S7300 is always 2)
    Online.i            ; Connection to CPU is Online
    hClient.i           ; Snap7 Client Handle for CPU
  EndStructure
    
  Structure TS7uni    ; an universal S7 variable with union access to the same address
    StructureUnion
      a.a[0]
      u.u[0]
      w.w[0]
      q.q[0]
      BYTE.a
      WORD.u
      CHAR.c
      DATE.u
      S5Time.u
      INT.w
      DINT.l
      REAL.f
      TIME.l            ; IEC Time [ms]
      TOD.l             ; TimeOfDay in [ms]
      DATE_AND_TIME.q
      ; --- Don't use the following when you use TS7uni as Pointer to a S7_Buffer, because the ByteLength of this
      ; types are not the same as in S7
      _qBool.q          ; we have to use a Quad for the Bool to overwrite the complete Memory when changing the Bool
      _qDWORD.q         ; because S7 DWORD is unsigend 32Bit, we use a Quad. To pay attention it's prefixed _q  
      _qPOINTER.q       ; in the PLC 6 Byte S7-Pointer Type
    EndStructureUnion
  EndStructure
  
  Structure TS7Buffer
    *pData.TS7uni
    ByteSize.i
  EndStructure
  
  Structure TS7var
    Name$
    S7Addr$
    
    Type.l          ; Element of ES7_VarType
    AreaID.l        ; #S7_AreaID_TAG = $83, #S7_AreaID_DB = $84 
    DBNo.l          ; DataBlock Number
    ByteStart.l     ; Byte Startaddress   
    value.TS7uni    ; The Value    
    
    TimeStampRD.q   ; milli second TimeStamp UTC Time
    TimeStampWR.q   ; milli second TimeStamp UTC Time
    Interval.i      ; Read interval
    IsInUse.i       ; Variable is in use! Read it from PLC       
    ReadType.i      ; ReadType IfInUse or Continous
  EndStructure
  
  Structure TS7VarList
    List lstVar.TS7var() 
    Map *mapVarName.TS7var()
  EndStructure
  
  Structure hS7         ; S7 Handle Structure
    CPU.TS7_CPU         ; CPU Data
    ReadBuf.TS7Buffer   ; ReadBuffer
    WriteBuf.TS7Buffer  ; WriteBuffer
    Vars.TS7VarList     ; The actual Variable List
  EndStructure
  
  ;- ----------------------------------------
  ;- Declare
  ; ----------------------------------------
  
  ; GET Functions: Read from Buffer
  Declare.i GetBit(*Buf, BufByteSize, ByteOffset.i, Bit.i)
  Declare.a GetByte(*Buf, BufByteSize, ByteOffset.i)
  Declare.u GetWord(*Buf, BufByteSize, ByteOffset.i)
  Declare.w GetInt(*Buf, BufByteSize, ByteOffset.i)
  Declare.q GetDWord(*Buf, BufByteSize, ByteOffset.i)
  Declare.l GetDInt(*Buf, BufByteSize, ByteOffset.i)
  Declare.f GetReal(*Buf, BufByteSize, ByteOffset.i)
  Declare.u GetDate(*Buf, BufByteSize, ByteOffset.i)

  Declare.q GetDateAndTime(*Buf, BufByteSize, ByteOffset.i)
  Declare.l GetTimeOfDay(*Buf, BufByteSize, ByteOffset.i)
  Declare.s GetString(*Buf, BufByteSize, ByteOffset.i)
  Declare.q GetPointer(*Buf, BufByteSize, ByteOffset.i)
  Declare.i GetAnyPointer(*Buf, BufByteSize, ByteOffset.i, *S7_ANY.TS7_ANY)
  
  ; SET Functions: Write to Buffer
  Declare.i SetByte(*Buf, BufByteSize, ByteOffset.i, value.a)
  Declare.i SetWord(*Buf, BufByteSize, ByteOffset.i, value.u)
  Declare.i SetInt(*Buf, BufByteSize, ByteOffset.i, value.w)
  Declare.i SetDWord(*Buf, BufByteSize, ByteOffset.i, value.q)
  Declare.i SetDInt(*Buf, BufByteSize, ByteOffset.i, value.l)
  Declare.i SetReal(*Buf, BufByteSize, ByteOffset.i, value.f)
  Declare.i SetDateAndTime(*Buf, BufByteSize, ByteOffset.i, S7DateAndTime.q)
  Declare.i SetString(*Buf, BufByteSize, ByteOffset, String$, lenS7StrBuf = 254)
  Declare.i SetPointer(*Buf, BufByteSize, ByteOffset.i, *S7_PTR.TS7_Pointer)
  Declare.i SetAnyPointer(*Buf, BufByteSize, ByteOffset.i, *S7_ANY.TS7_ANY)
  
  ; Miscellaneous
  Declare.a ByteToBCD(value.u)
  Declare.a BCDtoByte(bBCD.a)
  Declare.l DINTtoBCD(Value)

  Declare.l CreateS7Time(D, hh, mm, ss, ms=0)   
  Declare.u CreateS5Time(hh, mm, ss, ms=0)
  Declare.l S5Time_to_S7Time(S5T.u)
  
  Declare.q S7Date_to_UnixDate(S7_DATE.u)
  Declare.u UnixDate_to_S7Date(DATE.q) 
  
  ; S7-String-Values to Value
  Declare.l S5TimeStr_to_S7Time(S5Time$)
  Declare.l S7TimeStr_to_S7Time(S7Time$)
  Declare.l TimeOfDayStr_to_S7Time(TimeOfDay$)
  
  Declare.q S7DateStr_to_Date(S7Date$)
  Declare.u S7DateStr_to_S7Date(S7Date$)
  Declare.q S7DateAndTimeStr_to_DateAndTime(S7DateAndTime$)

  Prototype.i Parse_S7VarVal(String$, *outS7val.S7::TS7uni)
  Global Parse_S7VarVal.Parse_S7VarVal
  
  Declare.i _Parse_S7VarVal(*String, *outS7val.S7::TS7uni)
  
  ; S7-Values to S7String-Value
  Declare.s FormatS7TimeEx(TimeMS.l, Format$="%hh:%mm:%ss.%ms")
  Declare.s S7Time_to_String(TimeMS.l, cfgMS=#False)
  Declare.s S7Time_to_S7TimeStr(TimeMS.l)
  Declare.s S7Time_to_TimeOfDayStr(TimeMS.l)
  Declare.s S7Time_to_S5TimeStr(TimeMS.l)
  Declare.s S5Time_to_S5TimeStr(S5T.u)
  
  Declare.s S7Date_to_S7DateStr(S7Date.u)
  Declare.s S7Date_to_String(S7Date.u, Format$="%dd.%mm.%yyyy")
  Declare.s S7DateAndTime_to_S7DateAndTimeStr(S7DateAndTime.q)
  
  Declare.s GetS7VarTypeName(S7VarType=#S7_DataType_BYTE)

EndDeclareModule

Module S7
  
  EnableExplicit
  
  ;- ----------------------------------------------------------------------
  ;- Module private
  ;- ----------------------------------------------------------------------
 
  #S7_1BYTE_TYPE = 1        ; No of Bytes for the Buffer_Access; 1 Byte for BYTE
  #S7_2Byte_TYPE = 2        ; No of Bytes for the Buffer_Access; 2 Byte for WORD
  #S7_4Byte_TYPE = 4        ; No of Bytes for the Buffer_Access; 4 Byte for DWORD
  #S7_6Byte_TYPE = 6        ; No of Bytes for the Buffer_Access; 6 Byte for S7_POINTER
  #S7_8Byte_TYPE = 8        ; No of Bytes for the Buffer_Access; 8 Byte for QWORD (DATE_AND_TIME)
  #S7_10Byte_TYPE  = 10     ; No of Bytes for the Buffer_Access; 10 Byte for S7 ANY-POINTER
  #S7_STRING_TYPE = 256     ; No of Bytes for a S7 String with maximum length
  
  #_31Bits =  $7FFFFFFF
  #S7DateOffsetUnix = 7305  ; Days offset for 1.1.1990 : 7305 = (20*365 +5) for PB/Unix Date starting 1.1.1970 and 32874 for Windows Dates
  #SecondsPerDay = 86400    ; 24*60*60
  
  ; S5T Format - The Bits 15/14 are ignored
  ; -----------------------------
  ; x,x,tb,tb | BCD | BCD | BCD
  ; -----------------------------
  ; TimeBase tb
  ;  00 :  10ms
  ;  01 : 100ms
  ;  10 :   1s
  ;  11 :  10s
  
  ; S5-TimeBase Constants
  #_S5_Tb10ms  = 00 << 12
  #_S5_Tb100ms = 01 << 12
  #_S5_Tb1s    = 10 << 12
  #_S5_Tb10s   = 11 << 12
  #_S5_BCDMask = $FFFFFF
  
  ; Macros for Byte BCD conversion. If you want to uses nested, better use the Procedures
  ; because nested Macros may cause problems.
  Macro _mac_ByteToBcd (_Byte)
    ((((_Byte)/10)<<4)|((_Byte)%10))  
  EndMacro
  
  Macro _mac_BcdToByte (_bBCD) 
    ((_bBCD)>>4 *10 +(_bBCD)& $0F)
  EndMacro

  Procedure.i _CheckBuffer(*Buf, ByteSize, BytePos.i, S7_VarLength = #S7_1BYTE_TYPE)
  ; ============================================================================
  ;   Validity Check of Buffer() Parameter
  ;   Because of direct memory access, we must make our Buffer() operation safe!
  ;   We must do a validity check of *Buffer and BytePos. Otherwise our programm will
  ;   crash with a memory access error if we make a small mistake in our code!
  ;   to not read/write outside of the Buffer()
  ;   0 <= BytePos <= #S7_ReadBufferMax  
  ;   AND Pointer to Buffer must be valid (<>0)
  ;
  ;   RET = pReadBuf + BytePos  ;  the Pointer to the accessed value;
  ;   RET = 0                   ;  if Parameters are not valid
  ; ============================================================================
    
    ; Debug "Checkbuffer *Buf = " + Str(*Buf)
    
    If *Buf
      If BytePos >=0 And (BytePos + S7_VarLength <= ByteSize -1)
        ProcedureReturn *Buf + BytePos
      EndIf 
    EndIf
    ProcedureReturn  0
  EndProcedure
  
  Procedure.i _AllocateS7Buffers(*hS7.hS7, ByteSize=#BufferSize32k)
    Protected *pBuf 
    
    If *hS7
      With *hS7
        
        *pBuf = AllocateMemory(ByteSize)
        \ReadBuf\pData = *pBuf
        If *pBuf
          \ReadBuf\ByteSize = ByteSize
        Else
          \ReadBuf\ByteSize = 0
        EndIf       
        
        *pBuf = AllocateMemory(ByteSize)
        \WriteBuf\pData = *pBuf
        If *pBuf
          \WriteBuf\ByteSize = ByteSize
        Else
          \WriteBuf\ByteSize = 0
        EndIf       
        
        ProcedureReturn #True
      EndWith
    EndIf
    
    ProcedureReturn  #False
  EndProcedure
  
  Procedure.i _FreeS7Buffers(*hS7.hS7)
    
    If *hS7           
      OnErrorGoto(?FreeS7Buffer_Err)    ; to prevent crashing at FreeMemory if a non valid Pointer is passed!
      With *hS7
        If \ReadBuf\pData
          FreeMemory(\ReadBuf\pData)          
          \ReadBuf\pData= 0
          \ReadBuf\ByteSize = 0
        EndIf  
        
        If \WriteBuf\pData
          FreeMemory(\WriteBuf\pData)          
          \WriteBuf\pData = 0
          \WriteBuf\ByteSize = 0
        EndIf  
        
        ProcedureReturn  #True  
      EndWith
    EndIf
    
    FreeS7Buffer_Err:
    ProcedureReturn  #False
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Module public
  ;- ----------------------------------------------------------------------
  ;- GET Functions: Read from Buffer
  ;- ----------------------------------------------------------------------
    
  Procedure.i GetBit(*Buf, BufByteSize, ByteOffset.i, Bit.i)
  ; ============================================================================
  ; NAME: GetBit
  ; DESC: Reads a Bit from the S7 ReadBuffer
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; VAR(Bit) : The BitNo to Read 
  ; RET.i : The value of the Bit [0,1]
  ; ============================================================================
    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected value.i
  
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*Buf + ByteOffset) is valid
      If *pVal\a & (1 << (Bit & $07))    ; (Bit & $07) select only the lowest 3 Bits = 0..7 
        Value = 1
      Else
        Value = 0
      EndIf
    EndIf
  
    ProcedureReturn Value
  EndProcedure
  
  Procedure.a GetByte(*Buf, BufByteSize, ByteOffset.i)
  ; ============================================================================
  ; NAME: GetByte
  ; DESC: Reads a Byte from the S7 ReadBuffer
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; RET.a : The value of the Byte [0..255]
  ; ============================================================================
    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset 
   
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset)   ; returns the Pointer to the actual Value in Buffer or 0
    ; Debug "GetByte Ptr = " + Str(*pVal)
    
    If *pVal        ; Memory accessed by (*Buf + ByteOffset) is valid
      ProcedureReturn *pVal\BYTE
    Else 
      ProcedureReturn 0
    EndIf
  EndProcedure    
  
  Procedure.u GetWord(*Buf, BufByteSize, ByteOffset.i)
  ; ============================================================================
  ; NAME: GetWord
  ; DESC: Reads a WORD from the S7 ReadBuffer
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; RET.u : The value of the WORD unsigned [0..65535]
  ; ============================================================================
    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected value.TS7uni
  
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset, #S7_2Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*Buf + ByteOffset) is valid
      value\a[0] = *pVal\a[1]
      value\a[1] = *pVal\a[0]
    EndIf
    ProcedureReturn value\WORD
  EndProcedure
  
  Procedure.w GetInt(*Buf, BufByteSize, ByteOffset.i)
  ; ============================================================================
  ; NAME: GetInt
  ; DESC: Reads an INTEGER from the S7 ReadBuffer
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; RET.w : The value of the Integer signed [-32768 bis +32767]
  ; ============================================================================
    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected value.TS7uni
  
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset, #S7_2Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*Buf + ByteOffset) is valid
      value\a[0] = *pVal\a[1]
      value\a[1] = *pVal\a[0]
    EndIf
  
    ProcedureReturn value\INT
  EndProcedure
  
  Procedure.q GetDWord(*Buf, BufByteSize, ByteOffset.i)
  ; ============================================================================
  ; NAME: GetDWord
  ; DESC: Reads an DWORD from the S7 ReadBuffer
  ; DESC: Because PureBasic do not support 32Bit unsigned, we have to use the 64Bit Quad
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; RET.q : The value of the DWORD unsigned [0..4294967295]
  ; ============================================================================
    
    Protected *pVal.TS7uni       ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected value.TS7uni     ; PureBasic QUAD, 8Byte, because unsingned 32 bit is not supported
  
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset, #S7_4Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    ; Memory Model S7:  lo,hi
    ; Memory Model PC:  hi,lo
    ;                                                   Hi 32Bit                -                     Lo 32 Bit
    ;                                   Byte0, Byte1, Byte2, Byte3 - Byte4, Byte5, Byte6, Byte7, Byte8
    ;
    If *pVal        ; Memory accessed by (*Buf + ByteOffset) is valid
      value\a[0] = *pVal\a[3]
      value\a[1] = *pVal\a[2]
      value\a[2] = *pVal\a[1]
      value\a[3] = *pVal\a[0]
    EndIf
  
    ProcedureReturn value\_qDWORD
  EndProcedure
  
  Procedure.l GetDInt(*Buf, BufByteSize, ByteOffset.i)
  ; ============================================================================
  ; NAME: GetDInt
  ; DESC: Reads an DINT from the S7 ReadBuffer
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; RET.l : The value of the DINT signed [-2147483648 bis +2147483647]
  ; ============================================================================
    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected value.TS7uni
  
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset, #S7_4Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*Buf + ByteOffset) is valid
      value\a[0] = *pVal\a[3]
      value\a[1] = *pVal\a[2]
      value\a[2] = *pVal\a[1]
      value\a[3] = *pVal\a[0]
    EndIf
  
    ProcedureReturn value\DINT
  EndProcedure
  
  Procedure.f GetReal(*Buf, BufByteSize, ByteOffset.i)
  ; ============================================================================
  ; NAME: GetReal
  ; DESC: Reads a REAL from the S7 ReadBuffer
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; RET.f : The value of the REAL as 32Bit single Float
  ; ============================================================================
    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected value.TS7uni
  
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset, #S7_4Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*Buf, BufByteSize + ByteOffset) is valid
      value\a[0] = *pVal\a[3]
      value\a[1] = *pVal\a[2]
      value\a[2] = *pVal\a[1]
      value\a[3] = *pVal\a[0]
    EndIf
  
    ProcedureReturn value\REAL
  EndProcedure
  
  Procedure.u GetDate(*Buf, BufByteSize, ByteOffset.i)
  ; ============================================================================
  ; NAME: GetDate
  ; DESC: Reads a DATE from the S7 ReadBuffer. S7_DATE is an 16Bit unsigned WORD
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; RET.u : The value of the DATE as 16Bit unsigned 
  ; ============================================================================
    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected value.TS7uni
  
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset, #S7_2Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*Buf + ByteOffset) is valid
      value\a[0] = *pVal\a[1]
      value\a[1] = *pVal\a[0]
    EndIf
  
    ProcedureReturn value\DATE
  EndProcedure  
  
  Procedure.q GetDateAndTime(*Buf, BufByteSize, ByteOffset.i)
  ; ============================================================================
  ; NAME: GetDateAndTime
  ; DESC: Reads the S7 8 Byte DATE_AND_TIME vlaue into a S7_DATE_AND_TIME
  ; DESC: Structure
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB
  ; VAR(*DateTime) : Pointer to DATE_AND_TIME Structure 
  ; RET.q : The S7 DateAndTime value, 8 Bytes
  ; =========================================================================
    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected dt.q
   
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset, #S7_8Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
     If *pVal        ; Memory accessed by (*Buf + ByteOffset) is valid      
      dt = *pVal\DATE_AND_TIME 
     EndIf
     
     ProcedureReturn dt
  EndProcedure 
   
  Procedure.l GetTimeOfDay(*Buf, BufByteSize, ByteOffset.i)
  ; ============================================================================
  ; NAME: GetTimeOfDay
  ; DESC: Reads TimeOfDay Format from Buffer
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; RET.l : TimeOfDay [ms since midnight] 
  ; ============================================================================
  
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected value.TS7uni
    
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset, #S7_4Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*Buf + ByteOffset) is valid
      value\a[0] = *pVal\a[3]
      value\a[1] = *pVal\a[2]
      value\a[2] = *pVal\a[1]
      value\a[3] = *pVal\a[0]
    EndIf
     
    ProcedureReturn value\TOD
  EndProcedure    
    
  Procedure.s GetString(*Buf, BufByteSize, ByteOffset.i)
  ; ============================================================================
  ; NAME: GetString
  ; DESC: Reads a S7-String from the Buffer() an returns a PureBasic String
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; RET.s : The PB-String 
  ; ============================================================================
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected.i lenS7Str, lenS7StrBuf
    Protected.i NoOfChars
    Protected *Char.Character
    Protected.s String$
    
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset, #S7_STRING_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*Buf + ByteOffset) is valid
      
      lenS7StrBuf = *pVal\a[0]
      lenS7Str = *pVal\a[1]
      
      If lenS7Str > lenS7StrBuf
        NoOfChars = lenS7StrBuf
      Else
        NoOfChars = lenS7Str 
      EndIf
      
      String$ = Space(NoOfChars)
      *Char = @String$
      ;Debug "NoOfCahrs: " + NoOfChars
      
      *pVal + 2  ; Set Pointer to firt Character of the S7-String      
      While NoOfChars
        ; Character wise copy (This works for PB's ASCII and UniCode String Version)
        *Char\c = *pVal\a
        *Char + SizeOf(Character)
        *pVal + 1
        NoOfChars - 1
      Wend
      
    EndIf  
    ProcedureReturn String$
  EndProcedure
  
  Procedure.q GetPointer(*Buf, BufByteSize, ByteOffset.i)
  ; ============================================================================
  ; NAME: GetPointer
  ; DESC: Reads a 6 Byte S7_POINTER format from S7_Buffer()
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset): Start position in the Buffer (in Byte count) 
  ; RET.q: POINTER as extended 8 Byte Struct (6 Byte in PLC)
  ; ============================================================================
   Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + BytePos
   Protected ptr.TS7_POINTER
   
   *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset, #S7_6Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
      
   ; PLC internal 6Byte Pointer
   ; Byte 0..1       : DB No. or 0 (Datablock number) 
   ; Byte 2          : Memory area
   ; Byte 3 Bit 3..7 : always 0 (reserve)
   ; Byte 4 Bit 0..2 : MSB of Byte Adress
   ; Byte 5          : Part of Byte Address
   ; Byte 6 Bit 3..7 : LSB of Byte Adress
   ; Byte 6 Bit 0..2 : Bit Address
  
    If *pVal        ; Memory accessed by (*Buf + BytePos) is valid
      With ptr
        ; DB number [0..1]
        \Item\DB_No = PX::BSwap16(*pVal\u[0])
        ; Memory Area [2]
        \Item\MemID = *pVal\a[2]
        ; Byte [3..5] is a BitAddress 
        \Item\ByteAddr = ((*pVal\a[3]<<16 + *pVal\a[4]<<8 + *pVal\a[5]) >> 3) & $FF
        \Item\BitAddr = *pVal\a[5] & 7      ; BitAddress Part
      EndWith
    Else
      ; Error  
    EndIf
     
    ProcedureReturn ptr\q
  EndProcedure
  
  ; ----------------------------------------
  ; S7-ANY-POINTER  : PLC internal 10-Bytes
  ; ----------------------------------------
  
  ; PLC internal the ANY-Pointer is 10 Bytes
  ; Byte 0    : 10h  (fix value for S7) 
  ; Byte 1    : Datatype
  ; Byte 2..3 : Iterations
  
  ; from Byte 4 on it's a S7-POINTER
  ; Byte 4..5 : DB No. or 0  (Datablock number) 
  ; Byte 6    : Memory area
  ; Byte 7 Bit 3..7 :  always 0 (reserve)
  ; Byte 7 Bit 0..2 : MSB of Byte Adress
  ; Byte 8          :  Part of Byte Address
  ; Byte 9 Bit 3..7 : LSB of Byte Adress
  ; Byte 9 Bit 0..2 : Bit Address

  Procedure.i GetAnyPointer(*Buf, BufByteSize, ByteOffset.i, *outS7Any.TS7_ANY)
  ; ============================================================================
  ; NAME: GetAnyPointer
  ; DESC: Reads a 10Byte S7-ANY-POINTER format from S7_Buffer()
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; VAR(*outS7Any): Destination Structure to write the Data
  ; RET: #TRUE if succeeded; #FALSE if failed
  ; ============================================================================
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + BytePos
    Protected value.TS7uni
  
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset, #S7_10Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal And *outS7Any      ; Memory accessed (*Buf + BytePos) is valid
      With *outS7Any
        \S7ID = *pVal\a[0]
        \DataType = *pVal\a[1]
        \Iterations = PX::BSwap16(*pVal\u[1])
        ; now the S7_POINTER part
        \DB_No = PX::BSwap16(*pVal\u[2])
        \MemID = *pVal\a[6] 
        ; Byte [7..9] is a BitAddress 
        \ByteAddr = ((*pVal\a[7]<<16 + *pVal\a[8]<<8 + *pVal\a[9]) >> 3) & $FF
        \BitAddr = *pVal\a[9] & 7      ; BitAddress Part
      EndWith      
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- SET Functions: Write to Buffer
  ;- ----------------------------------------------------------------------
  
  Procedure.i SetBit(*Buf, BufByteSize, ByteOffset.i, BitNo.i, value.i)
  ; ============================================================================
  ; NAME: SetBit
  ; DESC: Sets a Bit in the S7 WriteBuffer
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; VAR(BitNo.i)  : Bit number [0..7]
  ; VAR(value.i) : The value of the Bit [0,1], [#False,#True]
  ; RET.i : #True if done
  ; ============================================================================  
    ; ============================================================================
    ;   Writes a single Bit into a Buffer()
    ; ============================================================================
  
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
     
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*Buf + ByteOffset) is valid
      If value 
        *pVal\BYTE = *pVal\BYTE | (1 << (BitNo & $07))      ; Set the Bit
      Else
        *pVal\BYTE = *pVal\BYTE & ~(1 << (BitNo & $07))     ; Reset the Bit; '~' Bitwise NOT Operator
      EndIf
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i SetByte(*Buf, BufByteSize, ByteOffset.i, value.a)
  ; ============================================================================
  ; NAME: SetByte
  ; DESC: Sets a Byte in the S7 WriteBuffer
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; VAR(value.u) : The usigned Byte value
  ; RET.i : #True if done
  ; ============================================================================  
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*Buf + ByteOffset) is valid
      *pVal\BYTE = value
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False 
  EndProcedure
  
  Procedure.i SetWord(*Buf, BufByteSize, ByteOffset.i, value.u)
  ; ============================================================================
  ; NAME: SetWord
  ; DESC: Sets an unsigned 16Bit WORD in the S7 WriteBuffer
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; VAR(value.u) : The usigned 16Bit WORD
  ; RET.i : #True if done
  ; ============================================================================  
  
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected *Val.TS7uni = @value
    
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset, #S7_2Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*Buf + ByteOffset) is valid
      *pVal\a[0] = *Val\a[1]
      *pVal\a[1] = *Val\a[0]
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False  
  EndProcedure
  
  Procedure.i SetInt(*Buf, BufByteSize, ByteOffset.i, value.w)
  ; ============================================================================
  ; NAME: SetInt
  ; DESC: Sets a signed 16Bit INT in the S7 WriteBuffer
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; VAR(value.w) : The signed 16Bit INT
  ; RET.i : #True if done
  ; ============================================================================    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected *Val.TS7uni = @value
    
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset, #S7_2Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*Buf + ByteOffset) is valid
      *pVal\a[0] = *Val\a[1]
      *pVal\a[1] = *Val\a[0]
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False 
  EndProcedure
  
  Procedure.i SetDWord(*Buf, BufByteSize, ByteOffset.i, value.q)
  ; ============================================================================
  ; NAME: SetDWord
  ; DESC: Sets an usigned 32Bit DWORD in the S7 WriteBuffer
  ; DESC; beause PureBasic do not support 32Bit unsigned, we must use PureBasic 8Byte Quad
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; VAR(value.q) : The 32Bit unigned value
  ; RET.i : #True if done
  ; ============================================================================      
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected *Val.TS7uni = @value
    
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset, #S7_4Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
     
    ; Memory Model S7:  hi,lo   Big Endian
    ; Memory Model PC:  lo,hi   Little Endian
    
    ;   S7 Big Endian
    ; ------------------------------------------------------------------
    ;        Hi 32Bit                  Lo 32 Bit
    ; Byte8, Byte7, Byte6, Byte5 - Byte4, Byte3, Byte2, Byte1, Byte0
    ;
    If *pVal        ; Memory accessed by (*Buf + ByteOffset) is valid
      *pVal\a[0] = *Val\a[3]
      *pVal\a[1] = *Val\a[2]
      *pVal\a[2] = *Val\a[1]
      *pVal\a[3] = *Val\a[0]
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False  
  EndProcedure
  
  Procedure.i SetDInt(*Buf, BufByteSize, ByteOffset.i, value.l)
  ; ============================================================================
  ; NAME: SetInt
  ; DESC: Sets a signed 32Bit DINT in the S7 WriteBuffer
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; VAR(value.l) : The 32Bit signed value
  ; RET.i : #True if done
  ; ============================================================================    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected *Val.TS7uni = @value
  
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset, #S7_4Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
     
    If *pVal        ; Memory accessed by (*Buf + ByteOffset) is valid
      *pVal\a[0] = *Val\a[3]
      *pVal\a[1] = *Val\a[2]
      *pVal\a[2] = *Val\a[1]
      *pVal\a[3] = *Val\a[0]
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False  
  EndProcedure
  
  Procedure.i SetReal(*Buf, BufByteSize, ByteOffset.i, value.f)
  ; ============================================================================
  ; NAME: SetReal
  ; DESC: Sets a signed 4Byte REAL in the S7 WriteBuffer
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; VAR(value.f) : The REAL value 4Byte Fload
  ; RET.i : #True if done
  ; ============================================================================    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected *Val.TS7uni = @value
  
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset, #S7_4Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
     
    If *pVal        ; Memory accessed by (*Buf + ByteOffset) is valid
      *pVal\a[0] = *Val\a[3]
      *pVal\a[1] = *Val\a[2]
      *pVal\a[2] = *Val\a[1]
      *pVal\a[3] = *Val\a[0]
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False  
  EndProcedure
  
  Procedure.i SetDate(*Buf, BufByteSize, ByteOffset.i, S7Date.u)
  ; ============================================================================
  ; NAME: SetDate
  ; DESC: Writes a DATE to the S7 Buffer. S7_DATE is an 16Bit unsigned WORD
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; VAR(S7Date) : The S7-Date Value
  ; RET.u : The value of the DATE as 16Bit unsigned 
  ; ============================================================================
    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected *value.TS7uni = @S7Date
  
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset, #S7_2Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*Buf + ByteOffset) is valid
      *pVal\a[1] = *value\a[0] 
      *pVal\a[0] = *value\a[1] 
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure  
    
  Procedure.i SetDateAndTime(*Buf, BufByteSize, ByteOffset.i, S7DateAndTime.q)
    ; ============================================================================
    ;   Writes a DateAndTime into the Buffer()
    ; ============================================================================
  
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected yy.l
   
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset, #S7_8Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*Buf + ByteOffset) is valid
      *pVal\DATE_AND_TIME = S7DateAndTime
      ProcedureReturn #True  
    EndIf
    
    ProcedureReturn #False  
  EndProcedure
  
  Procedure.i SetString(*Buf, BufByteSize, ByteOffset, String$, lenS7StrBuf = 254)
  ; ============================================================================
  ; NAME: SetString
  ; DESC: Converts a S7-Date [16Bit unsigned NoOfDates from 1.1.1990]
  ; DESC: into a formated Time-String
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; VAR(String$) : The String to write (max.254 Chars) 
  ; VAR(lenS7StrBuf) : The length of the S7 StringBuffer (see your S7 Code)
  ; RET.i : #True if succeed
  ; ============================================================================

    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected.i lenS7Str
    Protected *Char.Character
    
    lenS7Str = Len(String$)
    If lenS7StrBuf > 254 : lenS7StrBuf = 254 : EndIf  
    If lenS7Str > lenS7StrBuf : lenS7Str = lenS7StrBuf : EndIf
   
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset, lenS7Str+2)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*Buf + ByteOffset) is valid    
      *pVal\a[0] = lenS7StrBuf
      *pVal\a[1] = lenS7Str
            
      *Char = @String$
      ;Debug "NoOfCahrs: " + NoOfChars
      
      *pVal + 2  ; Set Pointer to firt Character of the S7-String
      While lenS7Str
        ; Character wise copy (This works for PB's ASCII and UniCode String Version)
        *pVal\a = *Char\c & $FF ; select only the Lo-Byte for 2-Char-PB-String 
        *pVal + 1
        *Char\c + SizeOf(Character)
        lenS7Str - 1
      Wend
      
      ProcedureReturn #True
    EndIf  
    ProcedureReturn #False
  EndProcedure 
  
  Procedure.i SetPointer(*Buf, BufByteSize, ByteOffset.i, *S7_PTR.TS7_Pointer)
  ; ============================================================================
  ; NAME: SetPointer
  ; DESC: Writes a 6 Byte S7_POINTER format to S7_Buffer()
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset): Start position in the Buffer (in Byte count) 
  ; VAR(*S7_PTR): The S7-Pointer Value
  ; RET: #TRUE if succeeded; #FALSE if failed
  ; ============================================================================
   Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + BytePos

    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset, #S7_6Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
   ; PLC internal 6Byte Pointer
   ; Byte 0..1       : DB No. or 0 (Datablock number) 
   ; Byte 2          : Memory area
   ; Byte 3 Bit 3..7 : always 0 (reserve)
   ; Byte 4 Bit 0..2 : MSB of Byte Adress
   ; Byte 5          : Part of Byte Address
   ; Byte 6 Bit 3..7 : LSB of Byte Adress
   ; Byte 6 Bit 0..2 : Bit Address
    
    If *pVal        ; Memory accessed by (*Buf + BytePos) is valid
      With *S7_PTR
        ; DB number [0..1]
        *pVal\u[0] = PX::BSwap16(\Item\DB_No)
        ; Memory Area [2]
        *pVal\a[2] = \Item\MemID
        ; Byte [3..5] is BitAddress 
        *pVal\a[3] = (\Item\ByteAddr >>13) &7    ; Upper 3 Bits of ByteAdress
        *pVal\u[4] = \Item\ByteAddr  >> 5        ; = <<3 for Bitadress >>8 to get upper byte  
        *pVal\u[5] = ((\Item\ByteAddr & $F) <<5) | (\Item\BitAddr &7) ; Insert 3Bits of Bitaddress   
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  
  Procedure.i SetAnyPointer(*Buf, BufByteSize, ByteOffset.i, *S7Any.TS7_ANY)
  ; ============================================================================
  ; NAME: SetAnyPointer
  ; DESC: Writes a 10Byte S7-ANY-POINTER format to S7_Buffer()
  ; VAR(*Buf) : Pointer to Data Buffer, BigEndian (S7 Format)
  ; VAR(BufByteSize): The size of the Buffer in Bytes  
  ; VAR(ByteOffset): Start position in the Buffer (in Byte count) 
  ; VAR(*S7Any): The ANY-Pinter to wirte   
  ; RET: #TRUE if succeeded; #FALSE if failed
  ; ============================================================================
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + BytePos
    Protected value.TS7uni
  
    *pVal = _CheckBuffer(*Buf, BufByteSize, ByteOffset, #S7_10Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal And *S7Any       ; Memory accessed (*Buf + BytePos) is valid
      With *S7Any
        *pVal\a[0] = $10      ; \S7ID always 10h for S7
        *pVal\a[1] = \DataType        
        *pVal\u[1]= PX::BSwap16(\Iterations)     
        
        ; now the S7_POINTER part
        *pVal\u[2]= PX::BSwap16(\DB_No)
        *pVal\a[6] = \MemID 
        ; Byte [7..9] is BitAddress 
        *pVal\a[7] = (\ByteAddr >>13) &7    ; Upper 3 Bits of ByteAdress
        *pVal\u[8] = \ByteAddr  >> 5        ; = <<3 for Bitadress >>8 to get upper byte  
        *pVal\u[9] = ((\ByteAddr & $F) <<5) | (\BitAddr &7) ; Insert 3Bits of Bitaddress   
      EndWith      
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- Value to Value converter
  ;- ----------------------------------------------------------------------
    
  ; TODO! Check for valid BCD or Change to Function from Module Bit
  Procedure.a ByteToBCD(value.u)
   ; ============================================================================
  ; NAME: ByteToBCD
  ; DESC: Converts a Byte Value to BCD [0..99]
  ; VAR(value.a) :  The Byte Value unsigned  
  ; RET.a : The decimal Byte value of the 2 digits [0..99]
  ; ============================================================================
    
    If value > 99 : value = 99 : EndIf
    ProcedureReturn ((value / 10) << 4) | (value % 10)
  EndProcedure 

  Procedure.a BCDtoByte(bBCD.a)
  ; ============================================================================
  ; NAME: BCDtoByte
  ; DESC: Converts a BCD coded Byte of 2 digits [0..99] into a Byte value 
  ; VAR(bBCD.a) :  The Byte Value unisgned  
  ; RET.a : The decimal Byte value of the 2 digits [0..99]
  ; ============================================================================
        
    ProcedureReturn ((bBCD >> 4) * 10) + (bBCD & $0F) 
  EndProcedure 
  
  Procedure.l DINTtoBCD(Value)
  ; ============================================================================
  ; NAME: DINTtoBCD
  ; DESC: Convert max 32 Bit INT to BCD 
  ; DESC: Negative values will be converted as positive, becaus BCD do not
  ; DESC: support sign. Sometimes '$FF' is used as sign but better you
  ; DESC: check the sing by yourself if you need!
  ; VAR(Value) : The Integer to convert, max digits = 8 at x32  16 at x64
  ; RET.i : BCD Value or -1 if Error (to much digits) 
  ; ============================================================================
  Protected ret, SHL
  
    If Value <0
      Value = - Value
    EndIf
    
    If Value > 99999999           ; max 8 digits at x32
      ProcedureReturn -1
    EndIf   
      
    While Value >0      
      ; C-Backend removes the DIV completely and use 
      ; opitmized inverse INT muliplication
      Protected mem
      mem= Value 
      Value = Value /10
      ;ret = ret +(   Remainder   ) << SHL 
      ret = ret + (mem - Value *10) << SHL
      SHL = SHL + 4         
    Wend
    
    ProcedureReturn ret  
  EndProcedure

  Procedure.l CreateS7Time(D, hh, mm, ss, ms=0)
  ; ============================================================================
  ; NAME: CreateS7Time
  ; DESC: Create S7 Time from hh,mm,ss,ms (IEC-Timer or TimeOfDay)
  ; DESC: (max. 596h 31m 23s 647ms : T#24D_20H_31M_23S_647MS)
  ; VAR(D)  : Days    
  ; VAR(hh) : Hours
  ; VAR(mm) : Minutes
  ; VAR(ss) : Seconds
  ; VAR(ms) : Milliseconds
  ; RET.l : Time in ms (max 31Bits)
  ; ============================================================================
    Protected tim.q    ; time.q and time.l
    
    ; to not run into a problem: calculate as quad because S7Time is limit to 31Bit 0..$7FFFFFFF
    tim = (D*24*3600 + hh*3600 + mm*60 + ss)*1000 + ms
    
    If tim > #_31Bits Or tim < 0
      tim = #_31Bits     ; limit S7 Time to 31Bit 
    EndIf
    
    ProcedureReturn tim
  EndProcedure  
  
  Procedure.u CreateS5Time(hh, mm, ss, ms=0)
  ; ============================================================================
  ; NAME: CreateS5Time
  ; DESC: Create S5 Time from hh,mm,ss,ms 
  ; DESC: (max.  9990 sec 2H46M30S)
  ; VAR(hh) : Hours
  ; VAR(mm) : Minutes
  ; VAR(ss) : Seconds
  ; VAR(ms) : Milliseconds
  ; RET.u : S5-Time-Format, 3Digit BCD + TimeBase 
  ; ============================================================================
            
    Protected tim, t  ; Time values ms
    Protected S5T.u   ; S5Time (BCD-Format)
    
    ; to not run into a problem: calculate as quad
    tim = (hh*3600 + mm*60 + ss)*1000 + ms
    
    If tim > 9990000
      t = 9990000
    Else 
      t = tim
    EndIf ; Limit to max 9990 sec
        
    If t <= 9990        ; 9.99s 999*1/100 TimeBase 10ms
      t = t /10         ; ms to 1/100sec
      S5T = #_S5_Tb10ms  | (DINTtoBCD(t) & #_S5_BCDMask) 
    ElseIf t <= 99900   ; 99.9s 999*1/10s TimBase 100ms
      t = t/100     
      S5T = #_S5_Tb100ms | (DINTtoBCD(t) & #_S5_BCDMask) 
    ElseIf t <= 999000  ; 999s 999*1s     TimeBase 1s
      t = t/1000     
      S5T = #_S5_Tb1s    | (DINTtoBCD(t) & #_S5_BCDMask) 
    ElseIf t <= 9990000 ; 9990s 999*10s  TimeBase 10s
      t = t/10000     
      S5T = #_S5_Tb10s   | (DINTtoBCD(t) & #_S5_BCDMask)       
    EndIf
    
    ProcedureReturn S5T
  EndProcedure
  
  Procedure.l S5Time_to_S7Time(S5T.u)
  ; ============================================================================
  ; NAME: S5Time_to_S7Time
  ; DESC: Convert the S5Time Format (3Digit BCD + TimeBase) S7Time [ms]
  ; VAR(S5T.u): The S5-Time Format value
  ; RET.i : Time in [ms], max 9990sec
  ; ============================================================================
    Protected tb      ; TimeBase
    Protected tim
    Protected digit
        
    ; 3 digits BCD coded 000...999
    digit = (S5T & $F00)      ; 100's
    PX::LimitToMax(digit, 9)  ; Limit BCD digit to 9
    tim = digit * 100
    
    digit = (S5T & $F0)       ; 10's
    PX::LimitToMax(digit, 9)  ; Limit BCD digit to 9
    tim = tim + digit * 10
    
    digit = (S5T & $F)        ; 1's
    PX::LimitToMax(digit, 9)  ; Limit BCD digit to 9
    tim = tim + digit

    tb = S5T & #_S5_Tb10s    ; Select TimeBase Bit 13/12
    
    Select tb
      Case #_S5_Tb10ms
        tim * 10
      Case #_S5_Tb100ms
        tim * 100
      Case #_S5_Tb1s
        tim * 1000
      Case #_S5_Tb10s
        tim * 10000
    EndSelect
    
    ProcedureReturn tim
  EndProcedure
    
  Procedure.q S7Date_to_UnixDate(S7_DATE.u)
  ; ============================================================================
  ; NAME: S7DATE_to_UnixDate
  ; DESC: Converts a S7-Date to the PB internal Date-Format what is Unix Date
  ; VAR(S7_DATE.u) : The S7-Date value 
  ; RET.q : PureBaisc Unix Date-Format
  ; ============================================================================
    Protected dd.q = S7_DATE ; convert S7_DATE to QUAD
    
    ; S7_DATE : Number of days starting at 1990/01/01
    ; PureBasic PC_DATE are the ellapsed seconds since 1970/01/01 0:00:00
    
    ; To get the PC_DATE we have to add the mumber of days from 
    ; 1970/01/01 up to 1989/12/31 included. This are 20Years
    ; and 5 extra days for the LeapYears 72/76/80/84/88 = 365*20 +5
    ; Seconds per Day = 24 * 60 * 60 = 86400
    ProcedureReturn (dd + #S7DateOffsetUnix) * #SecondsPerDay
  EndProcedure

  Procedure.u UnixDate_to_S7Date(DATE.q)
  ; ============================================================================
  ; NAME: UnixDate_to_S7Date
  ; DESC: Converts the PB internal Unix-Date-Format into a S7_DATE value
  ; VAR(DATE.q) : The S7-Date value 
  ; RET.u : S7 DATE Format (No of days since 1990/1/1)
  ; ============================================================================
    Protected dd.q
    
    ; PureBasic PC_DATE are the ellapsed seconds since 1970/01/01 0:00:00
    ; This is the UNIX Date Format
    
    dd = DATE / #SecondsPerDay  ; ellapsed days since 1970/01/01
    
    ProcedureReturn (dd - #S7DateOffsetUnix)  ; offset 20Years and 5 LeapDays (Feb/29)
  EndProcedure
    
  ;- ----------------------------------------------------------------------
  ;- S7-String-Values to Value
  ;- ----------------------------------------------------------------------
  
  Procedure.l S5TimeStr_to_S7Time(S5Time$)       ; S5T#2H46M30S
  ; ============================================================================
  ; NAME: S5TimeStr_to_S7Time
  ; DESC: Converts a S5-Time-String to a ms TimeValue
  ; DESC: (max. 9990s : S5T#2H46M30S)
  ; VAR(S5Time$) : S5-Time String S5T#2H46M30S
  ; RET.i : The ms Value of the S5-Time S5T#...
  ; ============================================================================
    Protected I, mem, hh, mm, ss, ms
    Protected *pC.PX::pChar
    
    S5Time$ = UCase(S5Time$)
    *pC = @S5Time$
    
    PX::CMovBeyondNext(*pC,I,'#')
    
    While *pC\c
      I=0
      While PX::IsDecChar(*pC\c[I]) ; Search first non Decimal Character without moving the Pointer
        I+1
      Wend
      ; Debug "I="+I
      mem = Val(PeekS(*pC, I+1))    ; Get the Value
       
      Select *pC\c[I]              ; Check the non Decimal Character
        Case 'H'      ; Hour
          hh = mem
          ;Debug "hh=" + hh
        Case 'M'
          If *pC\c[I+1] = 'S'       ; Milliseconds
            ms = mem
            ;Debug "ms=" + ms
            Break
          Else                      ; Minutes
            mm = mem
            ;Debug "mm=" + mm
          EndIf          
          
        Case 'S'                    ; Seconds
          ss = mem
          ;Debug "ss=" + mm           
      EndSelect
      
      I+1              
      PX::CInc(*pC,I)   ; Set CharPointer beyond the non Decimal Character
    Wend
    
    mem = (hh*3600 + mm*60 +ss)*1000 +ms
    
    ; 31Bit Limit for IEC Time
    If mem > #_31Bits Or mem < 0  ; this works in x32 and x64
      mem = #_31Bits
    EndIf
    
    ProcedureReturn mem  
  EndProcedure
  
  Procedure.l S7TimeStr_to_S7Time(S7Time$)
  ; ============================================================================
  ; NAME: S7TimeStr_to_S7Time
  ; DESC: Converts an IEC-Time-String to a ms TimeValue
  ; DESC: (max. 596h 31m 23s 647ms : T#24D_20H_31M_23S_647MS)
  ; VAR(S7Time$) : IEC-Time String in S7 Format T#_D_H_M_S_MS
  ; RET.i : The ms Value of the IEC-Time T#...
  ; ============================================================================
    Protected I, mem, D, hh, mm, ss, ms
    Protected *pC.PX::pChar
    
    S7Time$ = UCase(S7Time$)
    *pC = @S7Time$
    
    ; IEC-Time T#5D4H3M2S1MS
    PX::CMovBeyondNext(*pC,I,'#')
    
    While *pC\c                     ; until EndOfString
      I=0
      While PX::IsDecChar(*pC\c[I]) ; Find first non Decimal Char
        I +1                        ; Char Position 0..x
      Wend
      ; Debug "I="+I
      mem = Val(PeekS(*pC,I+1))
;       Debug PeekS(*pC)
;       Debug "Value=" +mem
;       Debug Chr(*pC\c[I])
      Select *pC\c[I]
        Case 'D'      ; Day
          D = mem
          ;Debug "D=" + D
        Case 'H'      ; Hour
          hh = mem
          ;Debug "hh=" + hh
        Case 'M'
          If *pC\c[I+1] = 'S'   ; Milliseconds
            ms = mem
            ;Debug "ms=" + ms
            Break               ; ms is the last
          Else                  ; Minutes
            mm = mem
            ;Debug "mm=" + mm
          EndIf
          
        Case 'S'      ; Seconds
          ss = mem
          ;Debug "ss=" + mm           
      EndSelect
      
      I+1 
      PX::CInc(*pC,I)
    Wend 
    mem = (D*24*3600 + hh*3600 + mm*60 +ss)*1000 + ms
    
    ; 31Bit Limit for IEC Time
    If mem > #_31Bits Or mem < 0  ; this works in x32 and x64
      mem = #_31Bits
    EndIf
    
    ProcedureReturn mem
  EndProcedure
  
  Procedure.l TimeOfDayStr_to_S7Time(TimeOfDay$)
  ; ============================================================================
  ; NAME: TimeOfDayStr_to_S7Time
  ; DESC: Converts a TimeOfDay-String to a ms TimeValue
  ; DESC: 
  ; VAR(TimeOfDay$) : TimeOfDay-String TOD#23:59:59:999
  ; RET.i : The ms Value of the IEC-Time T#...
  ; ============================================================================   
    Protected I, mem, hh, mm, ss, ms
    Protected *pC.PX::pChar
 
    ;TimeOfDay$ = UCase(TimeOfDay$)
    *pC = @TimeOfDay$
    
    PX::CMovBeyondNext(*pC,I,'#')
    hh=Val(PeekS(*pC,2))
    
    PX::CMovBeyondNext(*pC,I,':')
    mm=Val(PeekS(*pC,2))
    
    PX::CMovBeyondNext(*pC,I,':')
    ss=Val(PeekS(*pC,2))
    
    PX::CMovBeyondNext(*pC,I,'.')
    ms=Val(PeekS(*pC))
    
    If hh = 24 
      hh = 0
    EndIf
    
    PX::LimitToMinMax(hh, 0, 23)
    PX::LimitToMinMax(mm, 0, 59)
    PX::LimitToMinMax(ss, 0, 59)
    PX::LimitToMinMax(ms, 0, 999)
    
    mem = (hh*3600 + mm*60 +ss)*1000 + ms
    
    ; 31Bit Limit for IEC Time
    If mem > #_31Bits Or mem < 0  ; this works in x32 and x64
      mem = #_31Bits
    EndIf
    
    ProcedureReturn mem
  EndProcedure
  
  Procedure.q S7DateStr_to_Date(S7Date$)
  ; ============================================================================
  ; NAME: S7DateStr_to_Date
  ; DESC: Converts a S7-Date-String to 64Bit Unix Date (seconds since 1970/1/1)
  ; VAR(S7Date$) : S7-Date-String like D#2015-12-29
  ; RET.q : The Date Value 
  ; ============================================================================
    Protected I, Y, M, D
    Protected.q mem
    Protected *pC.PX::pChar
    
    ;S7Date$ = UCase(S7Date$)
    *pC = @S7Date$
    
    ; Date D#2015-12-29
    PX::CMovBeyondNext(*pC,I,'#')
        
    ; Year
    Y=Val(PeekS(*pC))
    ;Debug "Year = " + Str(Y)
    PX::CMovBeyondNext(*pC,I,'-')
    
    ; Month
    M=Val(PeekS(*pC))
    ;Debug "Month = " + M
    PX::CMovBeyondNext(*pC,I,'-')
    
    ; Day
    D = Val(PeekS(*pC))
    ;Debug "Day = " + D
    
    PX::LimitToMinMax(M, 0, 12)
    PX::LimitToMinMax(D, 0, 31)
   
    mem  = Date(Y,M,D,0,0,0)
    
    ProcedureReturn mem
  EndProcedure
   
  Procedure.u S7DateStr_to_S7Date(S7Date$)
  ; ============================================================================
  ; NAME: S7DateStr_to_Date
  ; DESC: Converts a S7-Date-String to a S7Date value
  ; VAR(S7Date$) : S7-Date-String like D#2015-12-29
  ; RET.q : The Date Value 
  ; ============================================================================
    Protected I, Y, M, D
    Protected.q mem
    Protected *pC.PX::pChar
    
    ;S7Date$ = UCase(S7Date$)
    *pC = @S7Date$
    
    ; Date D#2015-12-29
    PX::CMovBeyondNext(*pC,I,'#')
        
    ; Year
    Y=Val(PeekS(*pC))
    ;Debug "Year = " + Str(Y)
    PX::CMovBeyondNext(*pC,I,'-')
    
    ; Month
    M=Val(PeekS(*pC))
    ;Debug "Month = " + M
    PX::CMovBeyondNext(*pC,I,'-')
    
    ; Day
    D = Val(PeekS(*pC))
    ;Debug "Day = " + D
    
    PX::LimitToMinMax(M, 0, 12)
    PX::LimitToMinMax(D, 0, 31)
    
    mem  = Date(Y,M,D,0,0,0)
    
    ProcedureReturn UnixDate_to_S7Date(mem)
  EndProcedure
  
  Procedure.q S7DateAndTimeStr_to_DateAndTime(S7DateAndTime$)
  ; ============================================================================
  ; NAME: S7DateAndTimeStr_to_DateAndTime
  ; DESC: Converts a S7-Date-String to a S7 DateAndTime value (8 Bytes)
  ; VAR(S7DateAndTime$) : S7-DateAndTime-String like DT#90-1-1-12:10:33.000
  ; RET.q : The S7-DateAndTime-Value (BCD encoded Numbers) 
  ; ============================================================================
    Protected I, Y, M, D, hh, mm, ss, ms
    Protected.q mem
    Protected *pC.PX::pChar
    
    ;S7Date$ = UCase(S7Date$)
    *pC = @S7DateAndTime$
         
    ; Year
    PX::CMovBeyondNext(*pC,I,'#')      
    Y=Val(PeekS(*pC, 4))
    ; Month
    PX::CMovBeyondNext(*pC,I,'-')
    M=Val(PeekS(*pC, 2))
    ; Day
    PX::CMovBeyondNext(*pC,I,'-')
    D=Val(PeekS(*pC, 2))
    
    ; Hour
    PX::CMovBeyondNext(*pC,I,'-')
    hh=Val(PeekS(*pC,2))
    ; Minute
    PX::CMovBeyondNext(*pC,I,':')
    mm=Val(PeekS(*pC,2))
    ; Second
    PX::CMovBeyondNext(*pC,I,':')
    ss=Val(PeekS(*pC,2))
    ;Millisecond
    PX::CMovBeyondNext(*pC,I,'.')
    ms=Val(PeekS(*pC))
    
    If Y >= 1990 And Y <= 1999
      Y = Y - 1900
    ElseIf Y >= 2000 And Y <= 2089
      Y = Y - 2000         
    EndIf 
    
    PX::LimitToMinMax(Y, 0, 99)
    PX::LimitToMinMax(M, 0, 12)
    PX::LimitToMinMax(D, 0, 31)
    PX::LimitToMinMax(hh, 0, 24)
    PX::LimitToMinMax(mm, 0, 59)
    PX::LimitToMinMax(ss, 0, 59)
    PX::LimitToMinMax(ms, 0, 999)

    *pC = @mem    ; we need Byste access to mem what's possible with *pChar\a
    With *pC
      \a[0] = _mac_ByteToBcd(Y)
      \a[1] = _mac_ByteToBcd(M)
      \a[2] = _mac_ByteToBcd(D)
      \a[3] = _mac_ByteToBcd(hh)
      \a[4] = _mac_ByteToBcd(mm)
      \a[5] = _mac_ByteToBcd(ss)
      
      ; don't use Macro _mac_ByteToBcd from here -> use function because it's more save with combined values
      \a[6] = ByteToBCD(ms /10)
      \a[7] = ByteToBCD(DayOfWeek(Date(Y,M,D,hh,mm,ss)+1))
      \a[7] <<4   ; Shift DayOfWeek to upper BCD digit
      \a[7] = \a[7] | ByteToBCD(ms % 10)
    EndWith
    
    ProcedureReturn mem
  EndProcedure
  
  Procedure.i _Parse_S7VarVal(*String, *outS7val.TS7uni)
  ; ============================================================================
  ; NAME: Parse_S7VarVal
  ; DESC: Parse the value of a S7 Variable and return it as TS7uni Type
  ; DESC: Detect and return the S7_VarType!
  ; DESC: !!!Attention!!! Pointer Version use it as Prototype ParseS7_VarVal
  ; VAR(*String) : The String Pointer
  ; VAR(*outS7val.TS7uni) : Return Structure S7uni Type
  ; RET.i : VarType #S7_DataType_[BYTE,WORD,DWORD...] 
  ; ============================================================================
    Protected *pC.PX::pChar
    Protected l2$
    Protected type, I
    
  ;     #S7_DataType_BOOL          ; 1 Bit
  ;     #S7_DataType_BYTE          ; 1 Byte  unsigned
  ;     #S7_DataType_WORD          ; 2 Bytes unsigned
  ;     #S7_DataType_DWORD         ; 4 Bytes unsigned
  ;     #S7_DataType_INT           ; 2 Bytes
  ;     #S7_DataType_DINT          ; 4 Bytes
  ;     #S7_DataType_REAL          ; 4 Bytes
  ;     #S7_DataType_S5TIME        ; 2 Bytes
  ;     #S7_DataType_TIME          ; 4 Bytes
  ;     #S7_DataType_DATE          ; 2 Bytes
  ;     #S7_DataType_TIME_OF_DAY   ; 4 Bytes
  ;     #S7_DataType_CHAR          ; 1 Byte    
  ;     #S7_DataType_DATE_AND_TIME ; 8 Bytes
   
  ; BEGIN
  ;    S7_VarType_BOOL := FALSE; 
  ;    S7_VarType_BYTE := B#16#1; 
  ;    S7_VarType_DWORD := DW#16#123ABC; 
  ;    S7_VarType_INT := 99; 
  ;    S7_VarType_DINT := L#9876; 
  ;    S7_VarType_REAL := 3.456700e+000; 
  ;    S7_VarType_S5TIME := S5T#5M; 
  ;    S7_VarType_TIME := T#3D2H1M; 
  ;    S7_VarType_DATE := D#2015-12-29; 
  ;    S7_VarType_TIME_OF_DAY := TOD#23:59:59.999; 
  ;    S7_VarType_CHAR := 'z'; 
  ;    S7_VarType_DATE_AND_TIME := DT#90-1-1-12:10:33.000; 
  ;    S7_VarType_String := 'TestString'; 
  ; END_DATA_BLOCK
    
    
    If *String=0 Or *outS7val=0
      If *outS7val
        *outS7val\q = 0         
      EndIf     
      ProcedureReturn 0  
    EndIf
    
    *pC = *String
    *outS7val\q = 0  
    
    PX::CSkipSpaceTab(*pC)   ; set *pC after first Spaces and Tabs
    
    l2$ = PeekS(*pC,2)    ; The left 2 Chars from actual position on
    ;Debug l2$
    
    Select l2$
      ; --------------------------------------------------                           
      Case "B#"     ; Byte B#16#1; 
      ; --------------------------------------------------                           
        type = #S7_DataType_BYTE
        PX::CMovBeyondLast(*pC,I,'#')   ; move CharPointer to Char after the Last # -> '1'
        *outS7val\BYTE = Val("$" + PeekS(*pC))
        
      ; --------------------------------------------------                           
      Case "W#"      ; WORD W#16#1C
      ; --------------------------------------------------                           
        type = #S7_DataType_WORD
        PX::CMovBeyondLast(*pC,I,'#')
        *outS7val\WORD = Val("$" + PeekS(*pC))
        
      ; --------------------------------------------------                           
      Case "DW"     ; DWORD DW#16#123ABC
      ; --------------------------------------------------                           
        type = #S7_DataType_DWORD
        PX::CMovBeyondLast(*pC,I,'#')   ; Move Pointer to Char after '#'
        *outS7val\_qDWORD = Val("$" + PeekS(*pC))
        
      ; --------------------------------------------------                           
      Case "L#"     ; DINT L#9876
      ; --------------------------------------------------                           
        type = #S7_DataType_DINT
        PX::CMovBeyondNext(*pC,I,'#')
        *outS7val\DINT = Val(PeekS(*pC))  
         
      ; --------------------------------------------------                           
      Case "S5"     ; S5-Time  S5T#2H46M30S
      ; --------------------------------------------------                           
        type = #S7_DataType_S5TIME
        *outS7val\S5Time = CreateS5Time(0, 0, 0, S5TimeStr_to_S7Time(PeekS(*String)))
                 
      ; --------------------------------------------------                           
      Case "T#"     ; IEC-Time T#5D4H3M2S1MS
      ; --------------------------------------------------                           
        type = #S7_DataType_TIME
        *outS7val\TIME = S7TimeStr_to_S7Time(PeekS(*String))
        ;Debug "Time=" + *outS7val\TIME
        
      ; --------------------------------------------------                           
      Case "D#"     ; Date D#2015-12-29
      ; --------------------------------------------------                           
        type = #S7_DataType_DATE
        *outS7val\DATE = S7DateStr_to_S7Date(PeekS(*String))
        
      ; --------------------------------------------------                           
      Case "TO"     ; TIME_OF_DAY  TOD#23:59:58.567
      ; --------------------------------------------------                           
        type = #S7_DataType_TIME_OF_DAY       
        *outS7val\TOD = TimeOfDayStr_to_S7Time(PeekS(*String))
        
      ; --------------------------------------------------                           
      Case "DT"  ; DT#90-1-1-12:10:33.000;
      ; --------------------------------------------------                           
        type = #S7_DataType_DATE_AND_TIME
        *outS7val\DATE_AND_TIME = S7DateAndTimeStr_to_DateAndTime(PeekS(*String))
          
      ; --------------------------------------------------                           
      Case "FA"     ; FALSE
      ; --------------------------------------------------                           
        type = #S7_DataType_BOOL
        *outS7val\_qBool = #False  
        
      ; --------------------------------------------------                           
      Case "TR"     ; TRUE
      ; --------------------------------------------------                           
        type = #S7_DataType_BOOL
        *outS7val\_qBool = #True 
                
      ; --------------------------------------------------                           
      Default       ; CHAR, REAL, INT 
      ; --------------------------------------------------                           
        
        If *pC\c = 39                       ; ' Quote -> Char 
          type = #S7_DataType_CHAR  
          *outS7val\CHAR = *pC\c[1]             
        Else
          
          PX::CFindNext(*pC,I,'.')  ; try to find a dot - Real must have a dot
          ; Debug "dot = " + Chr(*pC\c[I])
          If *pC\c[I] = '.'   ; dot found -> Real 
            type = #S7_DataType_REAL
            *outS7val\REAL = ValF(PeekS(*pC))
     ;       Debug PeekS(*pC)      
          Else      ; INT
            type = #S7_DataType_INT        ; INT
            *outS7val\INT = Val(PeekS(*pC))
          EndIf
          
        EndIf        
    EndSelect  
    
    ProcedureReturn type
  EndProcedure
  Parse_S7VarVal=@_Parse_S7VarVal()
  
  ;- ----------------------------------------------------------------------
  ;- S7-Values to S7String-Value
  ;- ----------------------------------------------------------------------
  
  Procedure.s FormatS7TimeEx(TimeMS.l, Format$="%hh:%mm:%ss.%ms")
  ; ============================================================================
  ; NAME: FormatS7TimeEx
  ; DESC: Format a ms Time value to specified Format
  ; VAR(TimeMS.l): The ms Time Value
  ; VAR(Format$) : The Format String: valid parameters: %dd, %hh, %mm, %ss, %ms
  ; RET.s : The formated Time$
  ; ============================================================================  
    Protected dd, hh, mm, ss, ms
    Protected ret$, v$
    
    ret$ = Format$
    
    ; max TOD#23:59:59.999
    TimeMS = TimeMS & #_31Bits
    
    ms = TimeMs % 1000        ; Modulo 1000
    TimeMS = TimeMs /1000     ; now TimeMS is seconds
    
    If FindString(Format$, "%dd")
      dd = TimeMs  / #SecondsPerDay
      TimeMs = TimeMS - dd * #SecondsPerDay
      
      v$ = Str(dd)
      If dd < 10
        v$ = RSet(v$, 2, "0")         ; Format to 2 digits right aligned
      EndIf       
      ret$ = ReplaceString(ret$, "%dd", v$)
    EndIf
  
    If FindString(Format$, "%hh")
      hh = TimeMS / (3600)      ; sec -> hours
      TimeMs = TimeMS - hh *3600
      
      v$ = Str(hh)
      If dd < 10
        v$ = RSet(v$, 2, "0")
      EndIf       
      ret$ = ReplaceString(ret$, "%hh", v$)
    EndIf
     
    If FindString(Format$, "%mm")
      mm = TimeMS / 60
      TimeMS = TimeMS - mm *60
      
      v$ = Str(mm)
      If mm < 10
        v$ = RSet(v$, 2, "0")
      EndIf       
      ret$ = ReplaceString(ret$, "%mm", v$)
    EndIf
    
    If FindString(Format$, "%ss")
      ss = TimeMS
      
      v$ = Str(ss)
      If ss < 10
        v$ = RSet(v$, 2, "0")
      EndIf       
      ret$ = ReplaceString(ret$, "%ss", v$)
    EndIf
    
    If FindString(Format$, "%ms")
      v$ = Str(ms)
      If ss < 100
        v$ = RSet(v$, 3, "0")
      EndIf       
      ret$ = ReplaceString(ret$, "%ms", v$) 
    EndIf
    
    ProcedureReturn ret$      
  EndProcedure
  
  Procedure.s S7Time_to_String(TimeMS.l, cfgMS=#False)
  ; ============================================================================
  ; NAME: S7Time_to_String
  ; DESC: Converts a S7 ms Time Value to a hh:mm:ss.ms Time-String
  ; DESC: (max. 596h 31m 23s 647ms : 24D_20H_31M_23S_647MS)
  ; VAR(TimeMS.l) : the ms Time Value
  ; VAR(cfgMS) : Switch OFF/ON Milliseconds
  ; RET.s : The Time String hh:mm:ss[.ms]
  ; ============================================================================   
    Protected hh, mm, ss, ms
    Protected ret$, StrMs$
    
    ; max T#24D_20H_31M_23S_647MS
    TimeMS = TimeMS & #_31Bits
    
    ms = TimeMs % 1000        ; Modulo 1000
    TimeMS = TimeMs /1000     ; now TimeMS is seconds
           
    hh = TimeMS / (3600)      ; sec -> hours
    TimeMs = TimeMS - hh *3600
    If hh <10
      ret$ = RSet(Str(hh),2,"0")  ; Format to 2 digits right aligned
    Else
      ret$ = Str(hh)
    EndIf
    
    
    mm = TimeMS / 60
    TimeMS = TimeMS - mm *60   
    ss = TimeMS
    
    If cfgMS
      StrMs$ = "." + RSet(Str(ms),3,"0") 
    EndIf
    
    ret$ = ret$ + ":" + RSet(Str(mm),2,"0") +":" + RSet(Str(ss),2,"0") + StrMs$
    
    ProcedureReturn ret$
    
  EndProcedure
  
  Procedure.s S7Time_to_S7TimeStr(TimeMS.l)
  ; ============================================================================
  ; NAME: S7Time_to_S7TimeStr
  ; DESC: Converts a S7 ms Time Value to an IEC-Time-String
  ; DESC: (max. 596h 31m 23s 647ms : T#24D_20H_31M_23S_647MS)
  ; VAR(TimeMS.l) : the ms Time Value
  ; RET.s : The IEC-Time-String like T#1D2H3M4S5MS
  ; ============================================================================   
    Protected D, hh, mm, ss, ms
    Protected ret$
    
    ; max T#24D_20H_31M_23S_647MS
    TimeMS = TimeMS & #_31Bits
    
    ms = TimeMs % 1000        ; Modulo 1000
    TimeMS = TimeMs /1000     ; now TimeMS is seconds
       
    D = TimeMS / #SecondsPerDay    ; sec -> Days
    
    TimeMs = TimeMS - D *#SecondsPerDay
    
    hh = TimeMS / (3600)      ; sec -> hours
    TimeMs = TimeMS - hh *3600
     
    mm = TimeMS / 60
    TimeMS = TimeMS - mm *60   
    ss = TimeMS
    
    ret$ = "T#" + Str(D)+"D" + Str(hh)+"H" + Str(mm)+"M" + Str(ss)+"S" + Str(ms)+"MS"
    ProcedureReturn ret$
  EndProcedure
  
  Procedure.s S7Time_to_TimeOfDayStr(TimeMS.l)
  ; ============================================================================
  ; NAME: S7Time_to_TimeOfDayStr
  ; DESC: Converts a S7 ms Time Value to TimeOfDay-String
  ; DESC: (max. 23:59:59.999)
  ; VAR(TimeMS.l) : the ms Time Value
  ; RET.s : The TimeOfDay-String 
  ; ============================================================================   
    Protected hh, mm, ss, ms
    Protected ret$
    
    ; max TOD#23:59:59.999
    TimeMS = TimeMS & #_31Bits
    
    ms = TimeMs               ; Backup TimeMs in ms for Modulo
    TimeMS = TimeMs /1000     ; now TimeMS is seconds
    ms = ms - TimeMs * 1000   ; Modulo Rest ms
    
    hh = TimeMS / (3600)      ; sec -> hours
    TimeMs = TimeMS - hh *3600
    
    If hh > 23 : hh = 23 : EndIf
    
    mm = TimeMS / 60
    TimeMS = TimeMS - mm *60
    ss = TimeMS
    
    ret$ = "TOD#" + Str(hh)+":" + Str(mm)+":" + Str(ss)+"." + Str(ms)+"MS"
    ProcedureReturn ret$
  EndProcedure

  Procedure.s S7Time_to_S5TimeStr(TimeMS.l)
  ; ============================================================================
  ; NAME: S7Time_to_S5TimeStr
  ; DESC: Converts a S7 ms Time Value to a S5Time-String
  ; DESC: (max. 9990s : S5T#2H46M30S)
  ; VAR(TimeMS.l) : the ms Time Value
  ; RET.s : The S5Time-String like S5T#2H46M30S
  ; ============================================================================   
    Protected hh, mm, ss, ms
    Protected ret$
    
    ; max S5T#2H46M30S
    TimeMS = TimeMS & #_31Bits
    
    ms = TimeMs % 1000        ; Modulo 1000
    TimeMS = TimeMs /1000     ; now TimeMS is seconds
    
    ; Limit to 9990 sec
    If TimeMS >9990 : TimeMs = 9990 : EndIf
    
    hh = TimeMS / 3600        ; sec -> hours
    TimeMs = TimeMS - hh *3600
     
    mm = TimeMS /60
    TimeMS = TimeMS - mm *60   
    ss = TimeMS
    
    If TimeMS <= 9990         ; 9.99s 999*1/100 TimeBase 10ms
      ms = ms -(ms%10)        ; Round down to full 10ms
       
    ElseIf TimeMS <= 99900    ; 99.9s 999*1/10s TimBase 100ms
      ms = ms - (ms%100)      ; Round down to full 100ms
      
    ElseIf TimeMS <= 999000   ; 999s 999*1s     TimeBase 1s
      ms = 0                  ; Round down to full sec
       
    ElseIf TimeMS <= 9990000  ; 9990s 999*10s  TimeBase 10s
      ms = 0                  ; Round down to full sec
      ss = ss -(ss%10)        ; Round down to full 10 sec  
    EndIf
    
    ret$ = "S5T#" + Str(hh)+"H" + Str(mm)+"M" + Str(ss)+"S" + Str(ms)+"MS"
    ProcedureReturn ret$        
  EndProcedure
    
  Procedure.s S5Time_to_S5TimeStr(S5T.u)
  ; ============================================================================
  ; NAME: S5Time_to_S5TimeStr
  ; DESC: Converts a S5 Time Value to a S5Time-String
  ; DESC: (max. 9990s : S5T#2H46M30S)
  ; VAR(S5T.u) : The S5-Time-Value
  ; RET.s : The S5Time-String like S5T#2H46M30S
  ; ============================================================================   
    Protected digit, tim
    Protected ret$
    Protected tb
    
    tb = S5T & #_S5_Tb10s     ; Select TimeBase Bit 13/12
    
    ; 3 digits BCD coded 000...999
    digit = (S5T & $F00)      ; 100's
    PX::LimitToMax(digit, 9)  ; Limit BCD digit to 9
    tim = digit * 100
    
    digit = (S5T & $F0)       ; 10's
    PX::LimitToMax(digit, 9)  ; Limit BCD digit to 9
    tim = tim + digit * 10
    
    digit = (S5T & $F)        ; 1's
    PX::LimitToMax(digit, 9)  ; Limit BCD digit to 9
    tim = tim + digit
    
    Select tb
      Case #_S5_Tb10ms
        tim * 10
      Case #_S5_Tb100ms
        tim * 100
      Case #_S5_Tb1s
        tim * 1000
      Case #_S5_Tb10s
        tim * 10000
    EndSelect
    
    ProcedureReturn S7Time_to_S5TimeStr(tim)
  EndProcedure
  
  Procedure.s S7Date_to_String(S7Date.u, Format$="%dd.%mm.%yyyy")
  ; ============================================================================
  ; NAME: S7Date_to_String
  ; DESC: Converts a S7-Date [16Bit unsigned NoOfDates from 1.1.1990]
  ; DESC: into a formated Time-String
  ; VAR(S7Date.l): The S7-Date value 
  ; VAR(Format$) : The PB Format-String used for PB's FormatDate() 
  ; RET : Formated Date-String
  ; ============================================================================
   
    Protected PbDate.q 
   
    ; The S7Date Format has 16 Bits and starts at 1990/1/1 up to 2168/12/31
    ; The Windows Date-Format starts at 1=1899/12/31
    ; The PB/Unix Date-Format starts at 0=1970/1/1
    ; For Windows Date we have to add 32874 days
    ; For PB/Unix Date we have to add  7305 days! Attention: UnixDate is seconds since 1970/1/1
    
    PbDate = S7Date    
    PbDate = PbDate + #S7DateOffsetUnix  ; Offset für Umrechung S7->Windows
   
    ProcedureReturn FormatDate(Format$, (PbDate * #SecondsPerDay))
  EndProcedure

  Procedure.s S7Date_to_S7DateStr(S7Date.u)
  ; ============================================================================
  ; NAME: S7Date_to_S7DateStr
  ; DESC: Converts a S7-Date to a S7Date-String D#2025-10-19
  ; VAR(S7Date$) : S7-Date Value (Days since 1990/1/1)
  ; RET.s : The S7-Date-Value 
  ; ============================================================================
    Protected PbDate.q
       
    PbDate = S7Date    
    PbDate = PbDate + #S7DateOffsetUnix  ; Offset für Umrechung S7->Windows
    
    ProcedureReturn "D#" + "-" + Year(PbDate) + "-" + Month(PbDate) + "-" + Day(PbDate)
  EndProcedure
  
  Procedure.s S7DateAndTime_to_S7DateAndTimeStr(S7DateAndTime.q)
  ; ============================================================================
  ; NAME: S7DateAndTime_to_S7DateAndTimeStr
  ; DESC: Converts a S7-DateAndTime-Value to a S7 DateAndTime String
  ; VAR(S7DateAndTime.q) : S7-DateAndTime-Value
  ; RET.s : The S7-DateAndTime-String like DT#90-1-1-12:10:33.000 
  ; ============================================================================
    Protected Y, M, D, hh, mm, ss, ms
    Protected *pDT.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected ret$
    *pDT = @S7DateAndTime
       
    Y = _mac_BcdToByte(*pDT\a[0])
     
    If Y >= 90 And Y <= 99
      Y + 1900
    ElseIf Y >= 0 And Y <= 89
      Y + 2000       
    EndIf 
     
    M = _mac_BcdToByte(*pDT\a[1])
    D = _mac_BcdToByte(*pDT\a[2])
    
    hh = _mac_BcdToByte(*pDT\a[3])
    mm = _mac_BcdToByte(*pDT\a[4])
    ss = _mac_BcdToByte(*pDT\a[5])
    
    ms = _mac_BcdToByte(*pDT\a[6])            ; 1' and 10' digit of ms
    
    ; the upper digit is the part of ms, to lo digit is the weekday
    ; don't use the BcdToByte Macro here -> use the Function because nested Macros sometimes cause Problems in PB    
    ms = ms + BCDtoByte(*pDT\a[7] >>4)*100    ; 100' digit of ms
    
    ret$ = "DT#" + Str(Y) + "-" + Str(M) + "-" + Str(D) + "-" + Str(hh)+ ":" + Str(mm) +":" + Str(ss) + "." + Str(ms)
    
    ProcedureReturn ret$
  EndProcedure
   
  Procedure.s GetS7VarTypeName(S7VarType=#S7_DataType_BYTE)
  ; ============================================================================
  ; NAME: GetS7VarTypeName
  ; DESC: Get the Name of the S7_VarType
  ; VAR(S7VarType) : The Enum Value of the #S7_VarType
  ; RET.s : The #S7_VarType Name
  ; ============================================================================
    Protected ret$
    
    With s7var
      Select S7VarType
        Case #S7_DataType_NIL
          ret$ = "NULLPOINTER"
        Case #S7_DataType_BOOL          ; 1 Bit
          ret$ = "BOOL"
        Case #S7_DataType_BYTE          ; 1 Byte
          ret$ = "BYTE"
        Case #S7_DataType_WORD          ; 2 Bytes
          ret$ = "WORD"
        Case #S7_DataType_DWORD         ; 4 Bytes
          ret$ = "DWORD"
        Case #S7_DataType_INT           ; 2 Bytes
          ret$ = "INT"
        Case #S7_DataType_DINT          ; 4 Bytes
          ret$ = "DINT"
        Case #S7_DataType_REAL          ; 4 Bytes
          ret$ = "REAL"
        Case #S7_DataType_S5TIME        ; 2 Bytes
          ret$ = "S5TIME"
        Case #S7_DataType_TIME          ; 4 Bytes
          ret$ = "TIME"
        Case #S7_DataType_DATE          ; 2 Bytes
          ret$ = "DATE"
        Case #S7_DataType_TIME_OF_DAY   ; 4 Bytes
          ret$ = "TIME_OF_DAY"
        Case #S7_DataType_CHAR          ; 1 Byte
          ret$ = "CHAR"
        
        ; combined Types
        Case #S7_DataType_DATE_AND_TIME ; 8 Bytes
          ret$ = "DATE_AND_TIME"
        Case #S7_DataType_STRING        ; max 256 Bytes (max 254 Chars)
          ret$ = "STRING"
        Case #S7_DataType_ARRAY         ; user defined
          ret$ = "ARRAY"
        Case #S7_DataType_STRUCT        ; user defined
          ret$ = "STRUCT"
        Case #S7_DataType_UDT           ; user defined
         ret$ = "UDT"
        
        ; Parameter Types (can't be used in DataBlocks)
        Case #S7_DataType_TIMER         ; 2 Bytes
          ret$ = "TIMER"
        Case #S7_DataType_COUNTER       ; 2 Bytes
          ret$ = "COUNTER"
        Case #S7_DataType_BLOCK_FB      ; 2 Bytes
          ret$ = "BLOCK_FB"
        Case #S7_DataType_BLOCK_FC      ; 2 Bytes
          ret$ = "BLOCK_FC"
        Case #S7_DataType_BLOCK_DB      ; 2 Bytes
          ret$ = "BLOCK_DB"
        Case #S7_DataType_BLOCK_SDB     ; 2 Bytes
          ret$ = "BLOCK_SDB"
        Case #S7_DataType_POINTER       ; 6 Bytes
          ret$ = "POINTER"
        Case #S7_DataType_ANY           ; 10 Bytes
          ret$ = "ANY"     
      EndSelect
    EndWith
    ProcedureReturn ret$
  EndProcedure
  
EndModule

;- ----------------------------------------------------------------------
;- Test Code
;- ----------------------------------------------------------------------

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  UseModule S7 
  
  Define tim.l
  
  tim = CreateS7Time(0,11,2,3)
  Debug FormatS7TimeEx(tim)
  
  DisableExplicit
CompilerEndIf

; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 1080
; FirstLine = 528
; Folding = -----------
; EnableXP
; CPU = 5