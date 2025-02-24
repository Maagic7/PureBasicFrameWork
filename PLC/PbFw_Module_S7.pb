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
; VERSION  :  0.5 untested Developer Version
; COMPILER :  PureBasic 6.0 and higher
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;; ChangeLog: 
;{ 2025/02/15 S.Maag: added seperate Buffer for Read/Write 
;  2024/12/08 S.Maag: added some functions And reworked some
;  
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "..\Modules\PbFw_Module_PbFw.pb"         ; PbFw::    FrameWork control Module
XIncludeFile "..\Modules\PbFw_Module_PB.pb"           ; PB::      Purebasic Extention Module
;XIncludeFile "..\Modules\PbFw_Module_Debug.pb"        ; DBG::     Debug Module
; XIncludeFile "..\Modules\PbFw_Module_Bits.pb"         ; Bits::    Bit Operations

; XIncludeFile ""

DeclareModule S7
  
  EnableExplicit
  
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  
  Enumeration ES7_TmrRead
    #S7_TmrRead_100ms = 100
    #S7_TmrRead_200ms = 200
    #S7_TmrRead_500ms = 500
    #S7_TmrRead_1s = 1000
    #S7_TmrRead_2s = 2000
    #S7_TmrRead_5s = 5000   
  EndEnumeration
  
  Enumeration ES7_VarType
    ; Basic Types
    #S7_VarType_UNKNOWN
    #S7_VarType_BOOL          ; 1 Bit
    #S7_VarType_BYTE          ; 1 Byte
    #S7_VarType_WORD          ; 2 Bytes
    #S7_VarType_DWORD         ; 4 Bytes
    #S7_VarType_INT           ; 2 Bytes
    #S7_VarType_DINT          ; 4 Bytes
    #S7_VarType_REAL          ; 4 Bytes
    #S7_VarType_S5TIME        ; 2 Bytes
    #S7_VarType_TIME          ; 4 Bytes
    #S7_VarType_DATE          ; 2 Bytes
    #S7_VarType_TIME_OF_DAY   ; 4 Bytes
    #S7_VarType_CHAR          ; 1 Byte
    
    ; combined Types
    #S7_VarType_DATE_AND_TIME ; 8 Bytes
    #S7_VarType_STRING        ; max 256 Bytes (max 254 Chars)
    #S7_VarType_ARRAY         ; user defined
    #S7_VarType_STRUCT        ; user defined
    #S7_VarType_UDT           ; user defined
    
    ; Parameter Types (can't be used in DataBlocks)
    #S7_VarType_TIMER         ; 2 Bytes
    #S7_VarType_COUNTER       ; 2 Bytes
    #S7_VarType_BLOCK_FB      ; 2 Bytes
    #S7_VarType_BLOCK_FC      ; 2 Bytes
    #S7_VarType_BLOCK_DB      ; 2 Bytes
    #S7_VarType_BLOCK_SDB     ; 2 Bytes
    #S7_VarType_POINTER       ; 6 Bytes
    #S7_VarType_ANY           ; 10 Bytes
  EndEnumeration
  
  ; ----------------------------------------------------------------------
  ;   S7 internal constants. See Step7 documentation or Simatic Manger help
  ; ----------------------------------------------------------------------
  ; S7 Block Type ID
  Enumeration ES7_BlockType
    #S7_BlockType_OB  = $38 ; "8"     ; Organization Block 'OB'
    #S7_BlockType_DB  = $41 ; "A"     ; Data Block 'DB'
    #S7_BlockType_SDB = $42 ; "B"     ; System Data Block 'SDB'
    #S7_BlockType_FC  = $43 ; "C"     ; Function 'FC'
    #S7_BlockType_SFC = $44 ; "D"     ; System Function 'SFC'
    #S7_BlockType_FB  = $45 ; "E"     ; Function Block 'FB'
    #S7_BlockType_SFB = $46 ; "F"     ; System Function Block 'SFB'
  EndEnumeration
  
  ; Memory Area ID
  Enumeration ES7_AreaID
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

  Structure TS7_TimeOfDay
    hh.l  
    mm.l
    ss.l
  EndStructure
  
  ; ----------------------------------------
  ; S7-POINTER  : PLC internal 6-Bytes
  ; ----------------------------------------
  
  Structure TS7_POINTER
    DB_No.u
    MemID.a
    Addr.l      ; Bit-Address: 3LSB = BitNo
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
    S7ID.a
    DataType.a
    Iterations.u
    ptr.TS7_POINTER
  EndStructure

  ; S7 use a Stringbuffer with an max length of 255 Byte
  ; 1st Byte of the String is the lenght of the Buffer
  ; 2nd Byte is the actual length of the String
  ; if we want to manipulate the string, we must set the 2nd Byte to the correct String length <= LenStrBuffer
  Structure TS7_String
    LenBuffer.a         ; S7 max String length  = length of the String Buffer
    LenString.a         ; S7 actual length of String
    sString.s           ; the String 
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
    Online.i            ; Connection to CPU1 is Online
    hClient.i           ; Snap7 Client Handle for CPU1
  EndStructure
  
  Structure TS7uni    ; an universal S7 variable with union access to the same address
    StructureUnion
      a.a[0]
      u.u[0]
      w.w[0]
      BYTE.a
      WORD.u
      DATE.u
      S5Time.u
      INT.w
      DINT.l
      REAL.f
      TIME.l
      DWORD.q
      DATE_AND_TIME.q
    EndStructureUnion
  EndStructure
  
  Structure TS7Buffer
    *pBuf.TS7uni
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

  Declare.i GetBit(*hS7.hS7, ByteOffset.i, Bit.i)
  Declare.a GetByte(*hS7.hS7, ByteOffset.i)
  Declare.u GetWord(*hS7.hS7, ByteOffset.i)
  Declare.w GetInt(*hS7.hS7, ByteOffset.i)
  Declare.q GetDWord(*hS7.hS7, ByteOffset.i)
  Declare.l GetDInt(*hS7.hS7, ByteOffset.i)
  Declare.f GetReal(*hS7.hS7, ByteOffset.i)
  Declare.u GetDate(*hS7.hS7, ByteOffset.i)

  Declare GetDateAndTime(*hS7.hS7, ByteOffset.i, *DateTime.TS7_DATE_AND_TIME)
  Declare.s GetTimeOfDayString(*hS7.hS7, ByteOffset.i)
  Declare.s GetString(*hS7.hS7, ByteOffset.i)
  Declare.i GetPointer(*hS7.hS7, ByteOffset.i, *S7_PTR.TS7_Pointer)
  Declare.i GetAnyPointer(*hS7.hS7, ByteOffset.i, *S7_ANY.TS7_ANY)
  
  Declare.i SetBit(*hS7.hS7, ByteOffset.i, Bit.i, value.i)
  Declare.i SetByte(*hS7.hS7, ByteOffset.i, value.a)
  Declare.i SetWord(*hS7.hS7, ByteOffset.i, value.u)
  Declare.i SetInt(*hS7.hS7, ByteOffset.i, value.w)
  Declare.i SetDWord(*hS7.hS7, ByteOffset.i, value.q)
  Declare.i SetDInt(*hS7.hS7, ByteOffset.i, value.l)
  Declare.i SetReal(*hS7.hS7, ByteOffset.i, value.f)
  Declare.i SetDateAndTime(*hS7.hS7, ByteOffset.i, *DateTime.TS7_DATE_AND_TIME)
  Declare.i SetString(*hS7.hS7, ByteOffset, String$, lenS7StrBuf = 254)
  Declare.i SetPointer(*hS7.hS7, ByteOffset.i, *S7_PTR.TS7_Pointer)
  Declare.i SetAnyPointer(*hS7.hS7, ByteOffset.i, *S7_ANY.TS7_ANY)
  
  Declare.l CreateS7Time(hh, mm, ss, ms=0)
  Declare.s S7TimeToString(TS7_Time.l)
  Declare.s S7DateToString(TS7_DATE.u, Format$="%dd.%mm.%yyyy")
  Declare.q S7_DATE_to_UnixDate(S7_DATE.u)
  
  Declare.a ByteToBCD(value.u)
  Declare.a BCDtoByte(bBCD.a)
  
EndDeclareModule

Module S7
  
  #S7_1BYTE_TYPE = 1        ; No of Bytes for the Buffer_Access; 1 Byte for BYTE
  #S7_2Byte_TYPE = 2        ; No of Bytes for the Buffer_Access; 2 Byte for WORD
  #S7_4Byte_TYPE = 4        ; No of Bytes for the Buffer_Access; 4 Byte for DWORD
  #S7_6Byte_TYPE = 6        ; No of Bytes for the Buffer_Access; 6 Byte for S7_POINTER
  #S7_8Byte_TYPE = 8        ; No of Bytes for the Buffer_Access; 8 Byte for QWORD (DATE_AND_TIME)
  #S7_10Byte_TYPE  = 10     ; No of Bytes for the Buffer_Access; 10 Byte for S7 ANY-POINTER
  #S7_STRING_TYPE = 256     ; No of Bytes for a S7 String with maximum length
    
;   Structure pSwap ; Pointer Structure for swapping
;     a.a[0]    ; unsigned Byte-Value
;     u.u[0]    ; unsigned WORD-Value
;   EndStructure

  Structure pChar   ; virtual CHAR-ARRAY, used as Pointer to overlay on strings 
    a.a[0]          ; fixed ARRAY Of CHAR Length 0
    c.c[0]          
  EndStructure
 
  Procedure.i _CheckBuffer(*Buf.TS7Buffer, BytePos.i, S7_VarLength = #S7_1BYTE_TYPE)
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
    
    If *Buf
      If BytePos >=0 And (BytePos + S7_VarLength <= *Buf\ByteSize -1)
        ProcedureReturn *Buf\ByteSize + BytePos
      EndIf 
    EndIf
    ProcedureReturn  0
  EndProcedure
  
  Procedure.i _AllocateS7Buffers(*hS7.hS7, ByteSize=S7::#BufferSize32k)
    Protected *pBuf 
    
    If *hS7
      With *hS7
        
        *pBuf = AllocateMemory(ByteSize)
        \ReadBuf\pBuf = *pBuf
        If *pBuf
          \ReadBuf\ByteSize = ByteSize
        Else
          \ReadBuf\ByteSize = 0
        EndIf       
        
        *pBuf = AllocateMemory(ByteSize)
        \WriteBuf\pBuf = *pBuf
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
        If \ReadBuf\pBuf
          FreeMemory(\ReadBuf\pBuf)          
          \ReadBuf\pBuf= 0
          \ReadBuf\ByteSize = 0
        EndIf  
        
        If \WriteBuf\pBuf
          FreeMemory(\WriteBuf\pBuf)          
          \WriteBuf\pBuf = 0
          \WriteBuf\ByteSize = 0
        EndIf  
        
        ProcedureReturn  #True  
      EndWith
    EndIf
    
    FreeS7Buffer_Err:
    ProcedureReturn  #False
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- GET Functions: Read from Buffer
  ;- ----------------------------------------------------------------------
    
  Procedure.i GetBit(*hS7.hS7, ByteOffset.i, Bit.i)
  ; ============================================================================
  ; NAME: GetBit
  ; DESC: Reads a Bit from the S7 ReadBuffer
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; VAR(Bit) : The BitNo to Read 
  ; RET.i : The value of the Bit [0,1]
  ; ============================================================================
    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected value.i
  
    *pVal = _CheckBuffer(*hS7\ReadBuf\pBuf, ByteOffset)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*hS7 + ByteOffset) is valid
      If *pVal\a & (1 << (Bit & $07))    ; (Bit & $07) select only the lowest 3 Bits = 0..7 
        Value = 1
      Else
        Value = 0
      EndIf
    EndIf
  
    ProcedureReturn Value
  EndProcedure
  
  Procedure.a GetByte(*hS7.hS7, ByteOffset.i)
  ; ============================================================================
  ; NAME: GetByte
  ; DESC: Reads a Byte from the S7 ReadBuffer
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; RET.a : The value of the Byte [0..255]
  ; ============================================================================
    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset 
   
    *pVal = _CheckBuffer(*hS7\ReadBuf\pBuf, ByteOffset)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*hS7 + ByteOffset) is valid
      ProcedureReturn *pVal\BYTE
    Else 
      ProcedureReturn 0
    EndIf
  EndProcedure    
  
  Procedure.u GetWord(*hS7.hS7, ByteOffset.i)
  ; ============================================================================
  ; NAME: GetWord
  ; DESC: Reads a WORD from the S7 ReadBuffer
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; RET.u : The value of the WORD unsigned [0..65535]
  ; ============================================================================
    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected value.TS7uni
  
    *pVal = _CheckBuffer(*hS7\ReadBuf\pBuf, ByteOffset, #S7_2Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*hS7 + ByteOffset) is valid
      value\a[0] = *pVal\a[1]
      value\a[1] = *pVal\a[0]
    EndIf
    ProcedureReturn value\WORD
  EndProcedure
  
  Procedure.w GetInt(*hS7.hS7, ByteOffset.i)
  ; ============================================================================
  ; NAME: GetInt
  ; DESC: Reads an INTEGER from the S7 ReadBuffer
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; RET.w : The value of the Integer signed [-32768 bis +32767]
  ; ============================================================================
    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected value.TS7uni
  
    *pVal = _CheckBuffer(*hS7\ReadBuf\pBuf, ByteOffset, #S7_2Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*hS7 + ByteOffset) is valid
      value\a[0] = *pVal\a[1]
      value\a[1] = *pVal\a[0]
    EndIf
  
    ProcedureReturn value\INT
  EndProcedure
  
  Procedure.q GetDWord(*hS7.hS7, ByteOffset.i)
  ; ============================================================================
  ; NAME: GetDWord
  ; DESC: Reads an DWORD from the S7 ReadBuffer
  ; DESC: Because PureBasic do not support 32Bit unsigned, we have to use the 64Bit Quad
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; RET.q : The value of the DWORD unsigned [0..4294967295]
  ; ============================================================================
    
    Protected *pVal.TS7uni       ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected value.TS7uni     ; PureBasic QUAD, 8Byte, because unsingned 32 bit is not supported
  
    *pVal = _CheckBuffer(*hS7\ReadBuf\pBuf, ByteOffset, #S7_4Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    ; Memory Model S7:  lo,hi
    ; Memory Model PC:  hi,lo
    ;                                                   Hi 32Bit                -                     Lo 32 Bit
    ;                                   Byte0, Byte1, Byte2, Byte3 - Byte4, Byte5, Byte6, Byte7, Byte8
    ;
    If *pVal        ; Memory accessed by (*hS7 + ByteOffset) is valid
      value\a[0] = *pVal\a[3]
      value\a[1] = *pVal\a[2]
      value\a[2] = *pVal\a[1]
      value\a[3] = *pVal\a[0]
    EndIf
  
    ProcedureReturn value\DWORD
  EndProcedure
  
  Procedure.l GetDInt(*hS7.hS7, ByteOffset.i)
  ; ============================================================================
  ; NAME: GetDInt
  ; DESC: Reads an DINT from the S7 ReadBuffer
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; RET.l : The value of the DINT signed [-2147483648 bis +2147483647]
  ; ============================================================================
    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected value.TS7uni
  
    *pVal = _CheckBuffer(*hS7\ReadBuf\pBuf, ByteOffset, #S7_4Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*hS7 + ByteOffset) is valid
      value\a[0] = *pVal\a[3]
      value\a[1] = *pVal\a[2]
      value\a[2] = *pVal\a[1]
      value\a[3] = *pVal\a[0]
    EndIf
  
    ProcedureReturn value\DINT
  EndProcedure
  
  Procedure.f GetReal(*hS7.hS7, ByteOffset.i)
  ; ============================================================================
  ; NAME: GetReal
  ; DESC: Reads a REAL from the S7 ReadBuffer
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; RET.f : The value of the REAL as 32Bit single Float
  ; ============================================================================
    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected value.TS7uni
  
    *pVal = _CheckBuffer(*hS7\ReadBuf\pBuf, ByteOffset, #S7_4Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*hS7.hS7 + ByteOffset) is valid
      value\a[0] = *pVal\a[3]
      value\a[1] = *pVal\a[2]
      value\a[2] = *pVal\a[1]
      value\a[3] = *pVal\a[0]
    EndIf
  
    ProcedureReturn value\REAL
  EndProcedure
  
  Procedure.u GetDate(*hS7.hS7, ByteOffset.i)
  ; ============================================================================
  ; NAME: GetDate
  ; DESC: Reads a DATE from the S7 ReadBuffer. S7_DATE is an 16Bit unsigned WORD
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; RET.u : The value of the DATE as 16Bit unsigned 
  ; ============================================================================
    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected value.TS7uni
  
    *pVal = _CheckBuffer(*hS7\ReadBuf\pBuf, ByteOffset, #S7_2Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*hS7 + ByteOffset) is valid
      value\a[0] = *pVal\a[1]
      value\a[1] = *pVal\a[0]
    EndIf
  
    ProcedureReturn value\DATE
  EndProcedure  
  
  Procedure GetDateAndTime(*hS7.hS7, ByteOffset.i, *DateTime.TS7_DATE_AND_TIME)
  ; ============================================================================
  ; NAME: GetDateAndTime
  ; DESC: Reads the S7 8 Byte DATE_AND_TIME vlaue into a S7_DATE_AND_TIME
  ; DESC: Structure
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB
  ; VAR(*DateTime) : Pointer to DATE_AND_TIME Structure 
  ; RET : -
  ; =========================================================================
    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected yy.l
   
    *pVal = _CheckBuffer(*hS7\ReadBuf\pBuf, ByteOffset, #S7_8Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
     If *pVal        ; Memory accessed by (*hS7 + ByteOffset) is valid
  
      If *DateTime
       
        yy = BCDtoByte(*pVal\a[0])
         
        If yy >= 90 And yy <= 99
          yy = yy + 1900
        ElseIf yy >= 0 And yy <= 89
          yy = yy + 2000       
        EndIf 
         
        *DateTime\Year = yy
        *DateTime\Month = BCDtoByte(*pVal\a[1])
        *DateTime\Day =   BCDtoByte(*pVal\a[2])
        *DateTime\hour =  BCDtoByte(*pVal\a[3])
        *DateTime\minute = BCDtoByte(*pVal\a[4])
        *DateTime\second = BCDtoByte(*pVal\a[5])
         
        *DateTime\WeekDay = BCDtoByte(*pVal\a[7] & $0F)      
      EndIf
    EndIf
    
  EndProcedure 
   
  Procedure.s GetTimeOfDayString(*hS7.hS7, ByteOffset.i)
  ; ============================================================================
  ; NAME: GetTimeOfDayString
  ; DESC: Reads TimeOfDay Format from Buffer and converts it so "hh:mm:ss"
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; RET.s : The Time-String formated "hh:mm:ss"
  ; ============================================================================
  
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected value.TS7uni
    
    *pVal = _CheckBuffer(*hS7\ReadBuf\pBuf, ByteOffset, #S7_4Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*hS7 + ByteOffset) is valid
      value\a[0] = *pVal\a[3]
      value\a[1] = *pVal\a[2]
      value\a[2] = *pVal\a[1]
      value\a[3] = *pVal\a[0]
    EndIf
     
    ProcedureReturn S7TimeToString(value\TIME)
  EndProcedure    
    
  Procedure.s GetString(*hS7.hS7, ByteOffset.i)
  ; ============================================================================
  ; NAME: GetString
  ; DESC: Reads a S7-String from the Buffer() an returns a PureBasic String
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; RET.s : The PB-String 
  ; ============================================================================
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected.i lenS7Str, lenS7StrBuf
    Protected.i I, NoOfChars
    Protected *Char.pChar
    Protected.s String$
    
    *pVal = _CheckBuffer(*hS7\ReadBuf\pBuf, ByteOffset, #S7_STRING_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*hS7 + ByteOffset) is valid
      
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
      For I = 0 To (NoOfChars -1)
        ; Character wise copy (This works for PB's ASCII and UniCode String Version)
        *Char\c[I] = *pVal\a[I]   
      Next    
    EndIf  
    ProcedureReturn String$
  EndProcedure
  
  Procedure.i GetPointer(*hS7.hS7, ByteOffset.i, *S7_PTR.TS7_Pointer)
  ; ============================================================================
  ; NAME: GetPointer
  ; DESC: Reads a 6 Byte S7_POINTER format from S7_Buffer()
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset): Start position in the Buffer (in Byte count) 
  ; VAR(*S7_PTR): Destination Structure to write the Data .udt_S7_ANY  
  ; RET: #TRUE if succeeded; #FALSE if failed
  ; ============================================================================
   Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + BytePos
    Protected value.TS7uni

    *pVal = _CheckBuffer(*hS7\ReadBuf\pBuf, ByteOffset, #S7_6Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
    If *pVal        ; Memory accessed by (*hS7 + BytePos) is valid
      With *S7_PTR
        ; DB number [0..1]
        value\a[1] = *pVal\a[0]
        value\a[0] = *pVal\a[1]
        \DB_No = value\WORD
        
        ; Memory Area [2]
        \MemID = *pVal\a[2]
        
        ; Adress [3..5] (it is a BitAddress
        value\a[2] = *pVal\a[3]
        value\a[1] = *pVal\a[4]
        value\a[0] = *pVal\a[5]
        \Addr = value\DINT      ; use DINT not DWORD because DWORD is a Quad and we need only 3 Bytes unsigend
      EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
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

  Procedure.i GetAnyPointer(*hS7.hS7, ByteOffset.i, *S7_ANY.TS7_ANY)
  ; ============================================================================
  ; NAME: GetAnyPointer
  ; DESC: Reads a 10Byte S7-ANY-POINTER format from S7_Buffer()
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset): Start position in the Buffer (in Byte count) 
  ; VAR(*S7_ANY): Destination Structure to write the Data
  ; RET: #TRUE if succeeded; #FALSE if failed
  ; ============================================================================
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + BytePos
    Protected value.TS7uni
  
    *pVal = _CheckBuffer(*hS7\ReadBuf\pBuf, ByteOffset, #S7_10Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed (*hS7 + BytePos) is valid
      With *S7_ANY
        \S7ID = *pVal\a[0]
        \DataType = *pVal\a[0]
       
        value\a[0] = *pVal\a[3]
        value\a[1] = *pVal\a[2]
        \Iterations = value\WORD      
      EndWith
      
      ; now the S7_POINTER part
      *pVal + 4   ; Set *pVal to Sart of Pointer Part
      With *S7_ANY\ptr
        ; DB number [0..1]
        value\a[1] = *pVal\a[0]
        value\a[0] = *pVal\a[1]
        \DB_No = value\WORD
        
        ; Memory Area [2]
        \MemID = *pVal\a[2]
        
        ; Adress [3..5] (it is a BitAddress
        value\a[2] = *pVal\a[3]
        value\a[1] = *pVal\a[4]
        value\a[0] = *pVal\a[5]
        \Addr = value\DINT        ; use DINT not DWORD because DWORD is a Quad and we need only 3 Bytes unsigend
      EndWith
      
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- SET Functions: Write to Buffer
  ;- ----------------------------------------------------------------------
  
  Procedure.i SetBit(*hS7.hS7, ByteOffset.i, BitNo.i, value.i)
  ; ============================================================================
  ; NAME: SetBit
  ; DESC: Sets a Bit in the S7 WriteBuffer
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; VAR(BitNo.i)  : Bit number [0..7]
  ; VAR(value.i) : The value of the Bit [0,1], [#False,#True]
  ; RET.i : #True if done
  ; ============================================================================  
    ; ============================================================================
    ;   Writes a single Bit into a Buffer()
    ; ============================================================================
  
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
     
    *pVal = _CheckBuffer(*hS7\WriteBuf\pBuf, ByteOffset)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*hS7 + ByteOffset) is valid
      If value 
        *pVal\BYTE = *pVal\BYTE | (1 << (BitNo & $07))      ; Set the Bit
      Else
        *pVal\BYTE = *pVal\BYTE & ~(1 << (BitNo & $07))     ; Reset the Bit; '~' Bitwise NOT Operator
      EndIf
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i SetByte(*hS7.hS7, ByteOffset.i, value.a)
  ; ============================================================================
  ; NAME: SetByte
  ; DESC: Sets a Byte in the S7 WriteBuffer
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; VAR(value.u) : The usigned Byte value
  ; RET.i : #True if done
  ; ============================================================================  
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    
    *pVal = _CheckBuffer(*hS7\WriteBuf\pBuf, ByteOffset)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*hS7 + ByteOffset) is valid
      *pVal\BYTE = value
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False 
  EndProcedure
  
  Procedure.i SetWord(*hS7.hS7, ByteOffset.i, value.u)
  ; ============================================================================
  ; NAME: SetWord
  ; DESC: Sets an unsigned 16Bit WORD in the S7 WriteBuffer
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; VAR(value.u) : The usigned 16Bit WORD
  ; RET.i : #True if done
  ; ============================================================================  
  
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected *Val.TS7uni = @value
    
    *pVal = _CheckBuffer(*hS7\WriteBuf\pBuf, ByteOffset, #S7_2Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*hS7 + ByteOffset) is valid
      *pVal\a[0] = *Val\a[1]
      *pVal\a[1] = *Val\a[0]
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False  
  EndProcedure
  
  Procedure.i SetInt(*hS7.hS7, ByteOffset.i, value.w)
  ; ============================================================================
  ; NAME: SetInt
  ; DESC: Sets a signed 16Bit INT in the S7 WriteBuffer
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; VAR(value.w) : The signed 16Bit INT
  ; RET.i : #True if done
  ; ============================================================================    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected *Val.TS7uni = @value
    
    *pVal = _CheckBuffer(*hS7\WriteBuf\pBuf, ByteOffset, #S7_2Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*hS7 + ByteOffset) is valid
      *pVal\a[0] = *Val\a[1]
      *pVal\a[1] = *Val\a[0]
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False 
  EndProcedure
  
  Procedure.i SetDWord(*hS7.hS7, ByteOffset.i, value.q)
  ; ============================================================================
  ; NAME: SetDWord
  ; DESC: Sets an usigned 32Bit DWORD in the S7 WriteBuffer
  ; DESC; beause PureBasic do not support 32Bit unsigned, we must use PureBasic 8Byte Quad
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; VAR(value.q) : The 32Bit unigned value
  ; RET.i : #True if done
  ; ============================================================================      
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected *Val.TS7uni = @value
    
    *pVal = _CheckBuffer(*hS7\WriteBuf\pBuf, ByteOffset, #S7_4Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
     
    ; Memory Model S7:  hi,lo   Big Endian
    ; Memory Model PC:  lo,hi   Little Endian
    
    ;   S7 Big Endian
    ;------------------------------------------------------------------
    ;        Hi 32Bit                  Lo 32 Bit
    ; Byte8, Byte7, Byte6, Byte5 - Byte4, Byte3, Byte2, Byte1, Byte0
    ;
    If *pVal        ; Memory accessed by (*hS7 + ByteOffset) is valid
      *pVal\a[0] = *Val\a[3]
      *pVal\a[1] = *Val\a[2]
      *pVal\a[2] = *Val\a[1]
      *pVal\a[3] = *Val\a[0]
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False  
  EndProcedure
  
  Procedure.i SetDInt(*hS7.hS7, ByteOffset.i, value.l)
  ; ============================================================================
  ; NAME: SetInt
  ; DESC: Sets a signed 32Bit DINT in the S7 WriteBuffer
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; VAR(value.l) : The 32Bit signed value
  ; RET.i : #True if done
  ; ============================================================================    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected *Val.TS7uni = @value
  
    *pVal = _CheckBuffer(*hS7\WriteBuf\pBuf, ByteOffset, #S7_4Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
     
    If *pVal        ; Memory accessed by (*hS7 + ByteOffset) is valid
      *pVal\a[0] = *Val\a[3]
      *pVal\a[1] = *Val\a[2]
      *pVal\a[2] = *Val\a[1]
      *pVal\a[3] = *Val\a[0]
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False  
  EndProcedure
  
  Procedure.i SetReal(*hS7.hS7, ByteOffset.i, value.f)
  ; ============================================================================
  ; NAME: SetReal
  ; DESC: Sets a signed 4Byte REAL in the S7 WriteBuffer
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; VAR(value.f) : The REAL value 4Byte Fload
  ; RET.i : #True if done
  ; ============================================================================    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected *Val.TS7uni = @value
  
    *pVal = _CheckBuffer(*hS7\WriteBuf\pBuf, ByteOffset, #S7_4Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
     
    If *pVal        ; Memory accessed by (*hS7 + ByteOffset) is valid
      *pVal\a[0] = *Val\a[3]
      *pVal\a[1] = *Val\a[2]
      *pVal\a[2] = *Val\a[1]
      *pVal\a[3] = *Val\a[0]
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False  
  EndProcedure
  
  Procedure.i SetDate(*hS7.hS7, ByteOffset.i, S7Date.u)
  ; ============================================================================
  ; NAME: SetDate
  ; DESC: Writes a DATE to the S7 Buffer. S7_DATE is an 16Bit unsigned WORD
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; VAR(S7Date) : The S7-Date Value
  ; RET.u : The value of the DATE as 16Bit unsigned 
  ; ============================================================================
    
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected *value.TS7uni = @S7Date
  
    *pVal = _CheckBuffer(*hS7\WriteBuf\pBuf, ByteOffset, #S7_2Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*hS7 + ByteOffset) is valid
      *pVal\a[1] = *value\a[0] 
      *pVal\a[0] = *value\a[1] 
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure  
    
  Procedure.i SetDateAndTime(*hS7.hS7, ByteOffset.i, *DateTime.TS7_DATE_AND_TIME)
    ; ============================================================================
    ;   Writes a DateAndTime into the Buffer()
    ; ============================================================================
  
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected yy.l
   
    *pVal = _CheckBuffer(*hS7\WriteBuf\pBuf, ByteOffset, #S7_8Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*hS7 + ByteOffset) is valid
      If *DateTime
         
        yy= *DateTime\Year
        
        If yy >= 1990 And yy <= 1999
          yy = yy - 1900
        ElseIf yy >= 2000 And yy <= 2089
          yy = yy - 2000         
        EndIf 
        
        *pVal\a[0] = ByteToBCD(yy & FF)
        *pVal\a[1] = ByteToBCD(*DateTime\Month)
        *pVal\a[2] = ByteToBCD(*DateTime\Day)
        *pVal\a[3] = ByteToBCD(*DateTime\hour)
        *pVal\a[4] = ByteToBCD(*DateTime\minute)
        *pVal\a[5] = ByteToBCD(*DateTime\second)
        *pVal\a[6] = 0
        *pVal\a[7] = ByteToBCD(*DateTime\WeekDay)       
      EndIf
      ProcedureReturn #True
    EndIf         
    ProcedureReturn #False     
  EndProcedure
  
  Procedure.i SetString(*hS7.hS7, ByteOffset, String$, lenS7StrBuf = 254)
  ; ============================================================================
  ; NAME: SetString
  ; DESC: Converts a S7-Date [16Bit unsigned NoOfDates from 1.1.1990]
  ; DESC: into a formated Time-String
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; VAR(String$) : The String to write (max.254 Chars) 
  ; VAR(lenS7StrBuf) : The length of the S7 StringBuffer (see your S7 Code)
  ; RET.i : #True if succeed
  ; ============================================================================

    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + ByteOffset
    Protected.i I, lenS7Str
    Protected *Char.pChar
    
    lenS7Str = Len(String$)
    If lenS7StrBuf > 254 : lenS7StrBuf = 254 : EndIf  
    If lenS7Str > lenS7StrBuf : lenS7Str = lenS7StrBuf : EndIf
   
    *pVal = _CheckBuffer(*hS7\WriteBuf\pBuf, ByteOffset, lenS7Str+2)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed by (*hS7 + ByteOffset) is valid
      
      *pVal\a[0] = lenS7StrBuf
      *pVal\a[1] = lenS7Str
            
      *Char = @String$
      ;Debug "NoOfCahrs: " + NoOfChars
      
      *pVal + 2  ; Set Pointer to firt Character of the S7-String
      For I = 0 To (lenS7Str -1)
        ; Character wise copy (This works for PB's ASCII and UniCode String Version)
        *pVal\a[I] = *Char\c[I] & $FF ; select only the Lo-Byte for 2-Char-PB-String 
      Next   
      ProcedureReturn #True
    EndIf  
    ProcedureReturn #False
  EndProcedure 
  
  Procedure.i SetPointer(*hS7.hS7, ByteOffset.i, *S7_PTR.TS7_Pointer)
  ; ============================================================================
  ; NAME: SetPointer
  ; DESC: Writes a 6 Byte S7_POINTER format to S7_Buffer()
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset): Start position in the Buffer (in Byte count) 
  ; VAR(*S7_PTR): Destination Structure to write the Data .udt_S7_ANY  
  ; RET: #TRUE if succeeded; #FALSE if failed
  ; ============================================================================
   Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + BytePos
    Protected value.TS7uni

    *pVal = _CheckBuffer(*hS7\WriteBuf\pBuf, ByteOffset, #S7_6Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
    If *pVal        ; Memory accessed by (*hS7 + BytePos) is valid
      With *S7_PTR
        ; DB number [0..1]
        value\WORD = \DB_No
        *pVal\a[0] = value\a[1] 
        *pVal\a[1] = value\a[0]
         
        ; Memory Area [2]
        *pVal\a[2] = \MemID
        
        ; Adress [3..5] (it is a BitAddress
        value\DINT = \Addr      ; use DINT not DWORD because DWORD is a Quad and we need only 3 Bytes unsigend
        *pVal\a[3] = value\a[2]
        *pVal\a[4] = value\a[1] 
        *pVal\a[5] = value\a[0]
       EndWith
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure
  
  Procedure.i SetAnyPointer(*hS7.hS7, ByteOffset.i, *S7_ANY.TS7_ANY)
  ; ============================================================================
  ; NAME: SetAnyPointer
  ; DESC: Writes a 10Byte S7-ANY-POINTER format to S7_Buffer()
  ; VAR((*hS7.hS7) : S7Buffer Structure
  ; VAR(ByteOffset): Start position in the Buffer (in Byte count) 
  ; VAR(*S7_ANY): The ANY-Pinter to wirte   
  ; RET: #TRUE if succeeded; #FALSE if failed
  ; ============================================================================
    Protected *pVal.TS7uni        ; Pointer to the actual Value accessed by pReadBuf + BytePos
    Protected value.TS7uni
  
    *pVal = _CheckBuffer(*hS7\WriteBuf\pBuf, ByteOffset, #S7_10Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
    
    If *pVal        ; Memory accessed (*hS7 + BytePos) is valid
      With *S7_ANY
        *pVal\a[0] = \S7ID
        *pVal\a[0] = \DataType 
       
        value\WORD = \Iterations     
        *pVal\a[3] = value\a[0] 
        *pVal\a[2] = value\a[1] 
      EndWith
      
      ; now the S7_POINTER part
      *pVal + 4   ; Set *pVal to Sart of Pointer Part
      With *S7_ANY\ptr
        ; DB number [0..1]
        value\WORD = \DB_No
        *pVal\a[0] = value\a[1] 
        *pVal\a[1] = value\a[0]
         
        ; Memory Area [2]
        *pVal\a[2] = \MemID
        
        ; Adress [3..5] (it is a BitAddress
        value\DINT = \Addr      ; use DINT not DWORD because DWORD is a Quad and we need only 3 Bytes unsigend
        *pVal\a[3] = value\a[2]
        *pVal\a[4] = value\a[1] 
        *pVal\a[5] = value\a[0]
      EndWith
      
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- Miscellaneous
  ;- ----------------------------------------------------------------------
  
  #_31Bits =  $7FFFFFFF

  Procedure.l CreateS7Time(hh, mm, ss, ms=0)
  ; ============================================================================
  ; NAME: CreateS7Time
  ; DESC: Create S7 Time from hh,mm,ss,ms 
  ; DESC: (max. 596h 31m 23s 647ms : T#24D_20H_31M_23S_647MS)
  ; VAR(hh) : Hours
  ; VAR(mm) : Minutes
  ; VAR(ss) : Seconds
  ; VAR(ms) : Milliseconds
  ; RET.l : S7 Time in ms
  ; ============================================================================
    Protected tq.q, tl.l    ; time.q and time.l
    
    ; to not run into a problem: calculate as quad because S7Time is limit to 31Bit 0..$7FFFFFFF
    tq = (hh*3600 + mm*60 + ss)*1000 + ms
    
    If tq > #_31Bits
      tl = #_31Bits     ; limit S7 Time to 31Bit 
    ElseIf tq < 0
      tl = 0
    Else
      tl = tq   
    EndIf
    
    ProcedureReturn tl
  EndProcedure
  
  Procedure.s S7TimeToString(S7_Time.l) ; TODO! Add a Format Parameter
  ; ============================================================================
  ; NAME: S7TimeToString
  ; DESC: Converts a S7-Time value [milli seconds] in hh:mm:ss formated String 
  ; DESC: (max. 596h 31m 23s 647ms : T#24D_20H_31M_23S_647MS)
  ; VAR(S7_Time.l) : The S7-Time value in [ms]
  ; RET.s : hh:mm:ss formated Time String 
  ; ============================================================================
    Protected res.s
    Protected.l hh,mm,ss
    
    S7_Time = S7_Time & #_31Bits
    
    hh = S7_Time / (1000*60*60)
    S7_Time = S7_Time - hh * (1000*60*60)
    
    mm = S7_Time / (1000*60)
    S7_Time = S7_Time - mm * (1000*60)
    
    ss = S7_Time / (1000)
    
    If hh < 10
      res = "0" 
    EndIf
    
    res = res + Str(hh) + ":"
    
    If mm < 10
      res = res + "0"
    EndIf
    
    res = res + Str(mm) + ":"
    
    If ss < 10
      res = res + "0"
    EndIf
    
    res = res + Str(ss)
 
    ProcedureReturn res 
  EndProcedure
  
  #S7DateOffsetUnix = 7305        ; Days offset for 1.1.1990 : 7305 = (20*365 +5) for PB/Unix Date starting 1.1.1970 and 32874 for Windows Dates
  #SecondsPerDay = 86400          ; 24*60*60

  Procedure.s S7DateToString(S7_DATE.u, Format$="%dd.%mm.%yyyy")
  ; ============================================================================
  ; NAME: S7DateToString
  ; DESC: Converts a S7-Date [16Bit unsigned NoOfDates from 1.1.1990]
  ; DESC: into a formated Time-String
  ; VAR(TS7_DATE.l) : The S7-Date value 
  ; VAR(Format%) : The PB Format-String used for PB's FormatDate() 
  ; RET : Formated Date-String
  ; ============================================================================
   
    Protected NoOfDays.i 
   
    ; Das S7Date Format hat 16 Bit und beginnt mit dem 1.1.1990 bis 31.12.2168
    ; Das Windows Date-Format beginnt mit 1=31.12.1899
    ; Das PB/Unix Date-Format gebinnt mit 0=1.1.1970
    ; Für Windows Date müssen 32874 Tage addiert werden
    ; Für PB/Unix Date müssen  7305Tage adduert werden! Achtung: UnixDate ist in Sekunden seit 1.1.1970 
    
    NoOfDays = S7_DATE    
    NoOfDays = NoOfDays + #S7DateOffsetUnix  ; Offset für Umrechung S7->Windows
   
    ProcedureReturn FormatDate(Format$, (NoOfDays * #SecondsPerDay))
  EndProcedure
  
  Procedure.q S7_DATE_to_UnixDate(S7_DATE.u)
  ; ============================================================================
  ; NAME: S7_DATE_to_UnixDate
  ; DESC: Converts a S7-Date to the PB internal Date-Format what is Unix Date
  ; VAR(S7_DATE.u) : The S7-Date value 
  ; RET.q : PureBaisc Unix Date-Format
  ; ============================================================================
    Protected dd.q = S7_DATE ; convert S7_DATE to QUAD
    
    ; S7_DATE : Number of days starting at 1990/01/01
    ; PureBasic PC_DATE are the ellapsed seconds since 1970/01/01 0:00:00
    
    ; To get the PC_DATE we have to add the mumber of days from 
    ; 1970/01/01 up to 1989/12/31 included. This are 20Years
    ; and 5 extra day from the LeapYears 72/76/80/84/88 = 365*20 +5
    ; Seconds per Day = 24 * 60 * 60 = 86400
    ProcedureReturn (dd + #S7DateOffsetUnix) * #SecondsPerDay
  EndProcedure

  Procedure.u UnixDate_to_S7_DATE(DATE.q)
  ; ============================================================================
  ; NAME: UnixDate_to_S7_DATE
  ; DESC: Converts the PB internal Unix-Date-Format into a S7_DATE value
  ; VAR(DATE.q) : The S7-Date value 
  ; RET.u : S7_DATE Format (No of days since 1990/1/1)
  ; ============================================================================
    Protected dd.q
    
    ; PureBasic PC_DATE are the ellapsed seconds since 1970/01/01 0:00:00
    ; This is the UNIX Date Format
    
    dd = DATE / #SecondsPerDay  ; ellapsed days since 1970/01/01
    
    ProcedureReturn (dd - #S7DateOffsetUnix)  ; offset 20Years and 5 LeapDays (Feb/29)
  EndProcedure
  
  ; TODO! Check for valid BCD or Change to Function from Module Bit
  Procedure.a ByteToBCD(value.a)
    ProcedureReturn ((value / 10) << 4) | (value % 10)
  EndProcedure 

  Procedure.a BCDtoByte(bBCD.a)
  ; ============================================================================
  ; NAME: BCDtoByte
  ; DESC: Converts a BCD coded Byte of 2 digits [0..99] into a Byte value 
  ; VAR(*hS7.hS7) : Pointer to the S7 READ/WRITE Buffer
  ; VAR(ByteOffset) : The ByteOffset, StartAdress in the Buffer/DB 
  ; RET.a : The decimal Byte value of the 2 digits [0..99]
  ; ============================================================================
        
    ProcedureReturn ((bBCD >> 4) * 10) + (bBCD & $0F) 
  EndProcedure 

EndModule

;- ----------------------------------------------------------------------
;- Test Code
;- ----------------------------------------------------------------------

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  ; UseModule 
  
  DisableExplicit
CompilerEndIf

; IDE Options = PureBasic 6.20 (Windows - x64)
; CursorPosition = 23
; FirstLine = 495
; Folding = -------
; EnableXP
; CPU = 5