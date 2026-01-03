; ===========================================================================
; FILE: S7_Auxiliary_Functions.pbi
; NAME: S7 Auxiliary Functions
; DESC: Auxiliary functions to handle and modifiy S7 Data Structures
; DESC: for Siemens PLC S7-300/400
; ===========================================================================
;
; AUTHOR   :  Stefan Maag; Bavaria/Germany
; DATE     :  2019/05/20
; VERSION  :  1.0
; COMPILER :  PureBasic 5.70(Windows - x86)
; ===========================================================================
; ChangeLog:
; 2026/01/03: reactivated this include file for S7 Auxillary Functions
;             because sometimes it is better to use this instead of Moudle_S7
;             which do not accept direct *Buffer Pointer 
;             (it use a S7-Handle Structure) 
; 2021/04/02: added ProcedureReturn #TRUE, #FALSE for all S7_SET functions
; ============================================================================
;

; MIT License
;{
; Permission is hereby granted, free of charge, to any person obtaining
; a copy of this software and associated documentation files (the "Software"),
; ´to deal in the Software without restriction, including without limitation
; the rights to use, copy, modify, merge, publish, distribute, sublicense,
; and/or sell copies of the Software, and to permit persons to whom the
; Software is furnished to do so, subject to the following conditions:
; The above copyright notice and this permission notice shall be included
; in all copies or substantial portions of the Software.
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
; OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
; DEALINGS IN THE SOFTWARE. 
;}

; we need UTC DATE_AND_TIME functions to convert between PC-DATE and 
; S7_DATA_AND_TIME
XIncludeFile "UTC_DATE_TIME.pbi"

EnableExplicit

; ============================================================================
;    C O N S T A N T S
; ============================================================================
;{
; use #S7_ReadBufferMax to cerate the S7_ReadBuffer.a(#S7_ReadBufferMax) for your CPU
; if you have to Read more than 16kB in a single read, modify this constant

#S7_ReadBufferSize = 1024*16                   ;  16 kByte ReadBuffer 16384
#S7_ReadBufferMax = #S7_ReadBufferSize -1      ;  This is the UBound for your S7_Buffer(0..#S7_ReadBufferMax)

#S7_1BYTE_TYPE = 1         ; No of Bytes for the Buffer_Access; 1 Byte for BYTE
#S7_2Byte_TYPE = 2         ; No of Bytes for the Buffer_Access; 2 Byte for WORD
#S7_4Byte_TYPE = 4         ; No of Bytes for the Buffer_Access; 4 Byte for DWORD
#S7_8Byte_TYPE = 8         ; No of Bytes for the Buffer_Access; 8 Byte for QWORD (DATE_AND_TIME)
#S7_POINTER_TYPE = 6       ; No of Bytes for the Buffer_Access; 6 Byte for S7_POINTER
#S7_ANY_TYPE  = 10         ; No of Bytes for the Buffer_Access; 10 Byte for S7 ANY-POINTER
#S7_STRING_TYPE = 256      ; No of Bytes for a S7 String with maximum length

Enumeration S7_VarType
  #S7_VarType_UNKNOWN
  #S7_VarType_BOOL
  #S7_VarType_BYTE
  #S7_VarType_CHAR
  #S7_VarType_WORD
  #S7_VarType_DWORD
  #S7_VarType_INT
  #S7_VarType_DINT
  #S7_VarType_REAL
  #S7_VarType_S5TIME
  #S7_VarType_TIME
  #S7_VarType_DATE
  #S7_VarType_TIME_OF_DAY
  #S7_VarType_DATE_AND_TIME
  #S7_VarType_STRING
  #S7_VarType_ARRAY
  #S7_VarType_STRUCT
  #S7_VarType_UDT
  #S7_VarType_ANY
EndEnumeration

; ----------------------------------------------------------------------
;   S7 internal constants. See Step7 documentation or Simatic Manger help
; ----------------------------------------------------------------------
; S7 Block Type ID
Enumeration S7_BlockType
  #S7_BlockType_OB  = $38 ; "8"     ; Organization Block 'OB'
  #S7_BlockType_DB  = $41 ; "A"     ; Data Block 'DB'
  #S7_BlockType_SDB = $42 ; "B"     ; System Data Block 'SDB'
  #S7_BlockType_FC  = $43 ; "C"     ; Function 'FC'
  #S7_BlockType_SFC = $44 ; "D"     ; System Function 'SFC'
  #S7_BlockType_FB  = $45 ; "E"     ; Function Block 'FB'
  #S7_BlockType_SFB = $46 ; "F"     ; System Function Block 'SFB'
EndEnumeration

; Memory Area ID
Enumeration S7_AreaID
  #S7_AreaID_PI = $81            ; Periphery Inputs (Digital and analog inputs)
  #S7_AreaID_PQ = $82            ; Periphery Outputs (Digital and analog outputs)
  #S7_AreaID_FLAGs = $83         ; TAGs, Flags ('Merker')
  #S7_AreaID_DB = $84            ; Data Blocks 
  #S7_AreaD_DI = $85            ; Instance Data Blocks
  #S7_AreaID_LStack = $86        ; Local Stack        (= VAR_TEMP of the actual FB/FC)
  #S7_AreaID_FormerLStack = $87  ; Former Local Stack (= VAR_TEMP of the calling FB/FC)
  #S7_AreaID_S7Ctr = $1C         ; 28  S5/S7 format Counter C1..C255
  #S7_AreaID_S7Tmr = $1D         ; 31  S5/S7 format Timer   T1..T255
EndEnumeration

;}

; ============================================================================
;   S7 internal Structures. See Step7 documentation or Simatic Manger help
; ============================================================================
;{
; PLC internal the DATE_AND_TIME is a 8 Byte BCD coded value (1Byte = 2 BCD digits)
; Byte 0 : Year
; Byte 1 : Month
; Byte 2 : Day
; Byte 3 : Hour
; Byte 4 : Minute
; Byte 5 : Second
; Byte 6 : the 2 hi digits of millisecond
; Byte 7 Bit 5..7 : lo digit of millisecond
; Byte 7 Bit 0..3 : Weekday [1=Sunday .. 7=Saturday]

; For PureBasic internal use, we convert the S7 BCD formated DATE_AND_TIME to decimal values
Structure udt_S7_DATE_AND_TIME
  Year.l        ; [1990..2089] = S7 internal [90..99 = 1990.1999; 0..89 = 2000..2089]
  Month.l       ; [1..12]
  Day.l         ; [1..31]
  hour.l        ; [0..23]
  minute.l      ; [0..59]
  second.l      ; [0..59]
  millsec.l     ; [0..999]
  WeekDay.l     ; [1..7 = Sunday..Saturday]
EndStructure

Structure udt_S7_TimeOfDay
  hh.l  
  mm.l
  ss.l
EndStructure

; ----------------------------------------
; S7-POINTER  : PLC internal 6-Bytes
; ----------------------------------------

Structure udt_S7_POINTER
  DB_No.u
  MemID.c
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

Structure udt_S7_ANY
  S7ID.c
  DataType.c
  Iterations.u
  ptr.udt_S7_POINTER
EndStructure

; S7 use a Stringbuffer with an max length of 255 Byte
; 1st Byte of the String is the lenght of the Buffer
; 2nd Byte is the actual length of the String
; if we want to manipulate the string, we must set the 2nd Byte to the correct String length <= LenStrBuffer
Structure udt_S7_String
  LenStrBuffer.a      ; S7 max String length  = length of the String Buffer
  LenString.a         ; S7 actual length of String
  sString.s           ; the String 
EndStructure

;}


;- ----------------------------------------------------------------------
;- S7 <-> PB-Var MemCopy with Endianess
;- ----------------------------------------------------------------------

; ****************************************************************************
;   First some memory access functions for the S7 Read Buffer.
;   Because of different Byte order on S7 and x86 systems, we have to change
;   the Byte order when copying data between the S7_READ_BUFFER() and our
;   PureBasic variables.
;   S7 Byte Order : Big Endian    : HiByte - LoByte
;   x86 Byte Order: Little Endian : LoByte - HiByte
;
;   Because PureBasic do not natively support ByteSwap, we
;   use the PureBasic inline Assembler function to realize it.
; ****************************************************************************

Procedure S7_MemCopy_WORD(*Source, *Destination)
; ======================================================================
;  NAME: S7_MemCopy_WORD
;  DESC: Copies a WORD (2 Bytes) between S7_Buffer and PureBasic variables 
;  VAR(*Source)     : Pointer to source memory
;  VAR(*Destination): Pinter to destnation memory  
;  RET:  -
; ====================================================================== 

  !xor eax, eax ; set EAX = 0
  !mov ax, word [p.p_Source]  ; load memory accessed by *Source
  !xchg al, ah  ; for 16 Bit ByteSwap it's the Exchange command 
  ; !rol ax, 8  ; alternative way with RotateLeft 8Bit
  !mov word [p.p_Destination], ax
EndProcedure

Procedure S7_MemCopy_DWORD(*Source, *Destination)
; ======================================================================
;  NAME: S7_MemCopy_DWORD
;  DESC: Copies a DWORD (4 Bytes) between S7_Buffer and PureBasic variables 
;  VAR(*Source)     : Pointer to source memory
;  VAR(*Destination): Pointer to destnation memory  
;  RET:  -
; ====================================================================== 
  !mov eax, dword [p.p_Source]
  !bswap eax
  !mov dword [p.p_Destination], eax
 EndProcedure

Procedure.q S7_MemCopy_QWORD(*Source, *Destination)
; ======================================================================
;  NAME: S7_MemCopy_QWORD
;  DESC: Copies a QWORD (8 Bytes) between S7_Buffer and PureBasic variables 
;  VAR(*Source)     : Pointer to source memory
;  VAR(*Destination): Pointer to destnation memory  
;  RET:  -
; ====================================================================== 
 
  CompilerIf #PB_Compiler_Processor=#PB_Processor_x64
    !mov rax, qword [p.p_Source]
    !bswap rax
    !mov qword [p.p_Destination], rax
  CompilerElse  ; at x32 programms we must do 2x32Bit BSWAP
    !mov edx, dword [p.p_Source]
    !mov eax, dword [p.v_Source + 4]
    !bswap edx
    !bswap eax
    ; Attention we changed now only Byte order in Lo/Hi DWORD
    ; when copying to destionation, we must switch Lo/Hi DWORD too.
    ; We have to exchange eax/edx
    !mov dword [p.v_Destination + 4], edx
    !mov dword [p.p_Destination], edx
  CompilerEndIf
  
EndProcedure

Procedure.i CheckBuffer(*Buffer, BytePos.i, S7_VAR_TYPE = #S7_1BYTE_TYPE)
  ; ============================================================================
  ;   Validity Check of Buffer() Parameter
  ;   Because of direct memory access, we must make our Buffer() operation safe!
  ;   We must do a validity check of *Buffer and BytePos. Otherwise our programm will
  ;   crash with a memory access error if we make a small mistake in our code!
  ;   to not read/write outside of the Buffer()
  ;
  ;   Attention!  To work correctly out Buffer() must be initialized with 
  ;                       Dim S7_ReadBuffer(#S7_ReadBufferMax)
  ;                       If you use access to 2 ore more CPU's, handle a seperate 
  ;                       Buffer() for each CP'U
  ;
  ;    0 <= BytePos <= #S7_ReadBufferMax  
  ;   AND Pointer to Buffer must be valid (<>0)
  ;
  ;   RET = pBuffer + BytePos  ;  the Pointer to the accessed value;
  ;   RET = 0              ;  if Parameters are not valid
  ; ============================================================================
  
  If BytePos >=0 And (BytePos + S7_VAR_TYPE -1 <= #S7_ReadBufferMax) And *Buffer
      ProcedureReturn *Buffer + BytePos
  Else
      ProcedureReturn  0
  EndIf
EndProcedure

;- ----------------------------------------------------------------------
;- Miscellaneous
;- ----------------------------------------------------------------------

Procedure.a S7_BCDtoByte(bBCD.a)
; ============================================================================
; NAME: S7_BCDtoByte
; DESC: Converts a S7_BCD (2 digits packed BCD) into a unsingned Byte Value
; RET:  unsigned Byte value (00..99)
; ============================================================================
  ProcedureReturn ((bBCD >> 4) * 10) + (bBCD & $0F)
EndProcedure 

Procedure.a S7_WORDtoBCD(Value.u) 
; ============================================================================
; NAME: S7_WORDtoBCD
; DESC: Converts a PureBasic unsigned Word [0..99] into a (2 digits packed S7_BCD) 
; RET:  unsigned Byte containing 2 ditigits BCD convertet value
; ============================================================================
  ProcedureReturn ((Value / 10) << 4) | (Value % 10)
EndProcedure 

#S7DateOffsetUnix = 7305        ; Days offset for 1.1.1990 : 7305 = (20*365 +5) for PB/Unix Date starting 1.1.1970 and 32874 for Windows Dates
#SecondsPerDay = 86400          ; 24*60*60

Procedure.s S7_DateToString(S7_DATE.u, Format$="%dd.%mm.%yyyy")
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

Procedure.u S7_UnixDate_to_S7_DATE(DATE.q)
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

;- ----------------------------------------------------------------------
;- S7_SET_/GET_:  Functions to Read/Write S7_Buffer()
;- ----------------------------------------------------------------------

; ************************ GET/SET BYTE ***************************************
  
Procedure.i S7_GetBit(*Buffer, BytePos.i, Bit.i)
; ============================================================================
; NAME: S7_GetBit
; DESC: Reads a single Bit from S7_Buffer() an Returns it as PureBasic Integer
; VAR(*Buffer): Pointer to the S7_Buffer()
; VAR(BytePos): Start position in the Buffer (in Byte count) 
; VAR(Bit):     Bitposition [0..7]
; RET:  Returns the Value of the Bit: 0 or 1
; ============================================================================
  
  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos
  Protected Value.i

  *pVal = CheckBuffer(*Buffer, BytePos, #S7_1BYTE_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
  If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid
    If PeekA(*pVal) & (1 << (Bit & 7))    ; (Bit & 7) select only the lowest 3 Bits = 0..7 
        Value = 1
    Else
        Value = 0
    EndIf
   EndIf

  ProcedureReturn Value
EndProcedure

Procedure S7_SetBit(*Buffer, BytePos.i, Bit.i, Value.i)
; ============================================================================
; NAME: S7_SetBit
; DESC: Writes a single Bit into a S7_Buffer()
; VAR(*Buffer): Pointer to the S7_Buffer()
; VAR(BytePos): Start position in the Buffer (in Byte count) 
; VAR(Bit):     Bit number to set
; VAR(Value):   New value for the Bit [0,1]
; RET:  #TRUE if succeeded; #FALSE if failed
; ============================================================================

  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos
  
  *pVal = CheckBuffer(*Buffer, BytePos)   ; returns the Pointer to the actual Value in Buffer or 0
  
  If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid
    If Value 
      PokeA(*pVal, PeekA(*pVal) | (1 << (Bit & $07)))
    ElseIf Value = 0
      PokeA(*pVal, PeekA(*pVal) & ~(1 << (Bit & $07)))
    EndIf
    ProcedureReturn #True
  Else
    ProcedureReturn #False      
  EndIf

EndProcedure

; ************************ GET/SET BYTE ***************************************

Procedure.a S7_GetByte(*Buffer, BytePos.i)
; ============================================================================
; NAME: S7_GetByte
; DESC: Reads a Byte from S7_Buffer() and Returns it as PureBasic Byte in ASCII Format 0..255
; VAR(*Buffer): Pointer to the S7_Buffer()
; VAR(BytePos): Start position in the Buffer (in Byte count) 
; RET:  Returns the unsigned Value of the S7_Byte
; ============================================================================
  
  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos 
  Protected Value.a

  *pVal = CheckBuffer(*Buffer, BytePos, #S7_1BYTE_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
  If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid
    Value = PeekA(*pVal)
  EndIf

  ProcedureReturn Value
EndProcedure

Procedure S7_SetByte(*Buffer, BytePos.i, Value.a)
; ============================================================================
; NAME: S7_SetByte
; DESC: Writes a Byte into a S7_Buffer()
; VAR(*Buffer): Pointer to the S7_Buffer()
; VAR(BytePos): Start position in the Buffer (in Byte count) 
; VAR(Value):   New value for the Byte [0..255]
; RET:  #TRUE if succeeded; #FALSE if failed
; ============================================================================

  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos
  
  *pVal = CheckBuffer(*Buffer, BytePos, #S7_1Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
  If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid
      PokeA(*pVal, Value)
    ProcedureReturn #True
  Else
    ProcedureReturn #False      
  EndIf

EndProcedure

; ************************ GET/SET WORD ***************************************

Procedure.u S7_GetWord(*Buffer, BytePos.i)
; ============================================================================
; NAME: S7_GetWord
; DESC: Reads 16Bit from S7_Buffer() an Returns it as PureBasic unsigned 16Bit
; VAR(*Buffer): Pointer to the S7_Buffer()
; VAR(BytePos): Start position in the Buffer (in Byte count) 
; RET:  Returns the unsigned Value of the S7_WORD [0..65535]
; ============================================================================
  
  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos
  Protected ret.u

  *pVal = CheckBuffer(*Buffer, BytePos, #S7_2BYTE_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
  If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid
    S7_MemCopy_WORD(*pVal, @ret) 
  EndIf
  ProcedureReturn ret
  
EndProcedure

Procedure S7_SetWord(*Buffer, BytePos.i, Value.u)
; ============================================================================
; NAME: S7_SetWord
; DESC: Writes a unsigned 16Bit WORD into S7_Buffer()
; VAR(*Buffer): Pointer to the S7_Buffer()
; VAR(BytePos): Start position in the Buffer (in Byte count) 
; VAR(Value):   New value for the WORD [0..65535]
; RET:  #TRUE if succeeded; #FALSE if failed
; ============================================================================

  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos
  
  *pVal = CheckBuffer(*Buffer, BytePos, #S7_2Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
  If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid
    S7_MemCopy_WORD(@Value, *pVal)
    ProcedureReturn #True
  Else
    ProcedureReturn #False      
  EndIf

EndProcedure

; ************************ GET/SET INT ***************************************

Procedure.w S7_GetInt(*Buffer, BytePos.i)
; ============================================================================
; NAME: S7_GetInt
; DESC: Reads 16Bit from S7_Buffer() an Returns it as PureBasic signed 16Bit
; VAR(*Buffer): Pointer to the S7_Buffer()
; VAR(BytePos): Start position in the Buffer (in Byte count) 
; RET:  Returns the signed Value of the S7_INT [-32768..32767]
; ============================================================================
  
  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos
  Protected ret.w

  *pVal = CheckBuffer(*Buffer, BytePos, #S7_2BYTE_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
  If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid
    S7_MemCopy_WORD(*pVal, @ret) 
  EndIf

  ProcedureReturn ret
EndProcedure

Procedure S7_SetInt(*Buffer, BytePos.i, Value.w)
; ============================================================================
; NAME: S7_SetInt
; DESC: Writes a signed 16Bit INT into S7_Buffer()
; VAR(*Buffer): Pointer to the S7_Buffer()
; VAR(BytePos): Start position in the Buffer (in Byte count) 
; VAR(Value):   New value for the INT [-32768..32767]
; RET:  #TRUE if succeeded; #FALSE if failed
; ============================================================================

  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos
  
  *pVal = CheckBuffer(*Buffer, BytePos, #S7_2Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
  If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid
    S7_MemCopy_WORD(@Value, *pVal)
  EndIf

EndProcedure

; ************************ GET/SET DWORD *************************************

Procedure.q S7_GetDWord(*Buffer, BytePos.i)
; ============================================================================
; NAME: S7_GetDWord
; DESC: Reads 32Bit from S7_Buffer() an Returns it as PureBasic 64Bit Quad 
; DESC: Because PureBasic do not support 32Bit unsigned, we have to use the 64Bit Quad
; DESC: to get an unsigned S7_DWORD
; VAR(*Buffer): Pointer to the S7_Buffer()
; VAR(BytePos): Start position in the Buffer (in Byte count) 
; RET:  Returns the unsigned Value of the S7_DWORD [0..4294967295]
; ============================================================================
  
  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos
  Protected ret.q     ; PureBasic QUAD, 8Byte, because unsingned 32 bit is not supported

  *pVal = CheckBuffer(*Buffer, BytePos, #S7_4BYTE_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
  ; Memory Model S7:  lo,hi
  ; Memory Model PC:  hi,lo
  ;                                      Hi 32Bit                -                     Lo 32 Bit
  ;                                   Byte0, Byte1, Byte2, Byte3 - Byte4, Byte5, Byte6, Byte7, Byte8
  ;
  ; on PC side PureBasic.Quad to get the unsigned 32Bit value 
  If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid
    S7_MemCopy_DWORD(*pVal, @ret) 
 EndIf

  ProcedureReturn ret
EndProcedure

Procedure S7_SetDWord(*Buffer, BytePos.i, Value.q)
; ============================================================================
; NAME: S7_SetDWord
; DESC: Writes a  unsigned 32Bit WORD into S7_Buffer()
; DESC: beause PureBasic do not support 32Bit unsigned, we must use PureBasic 8Byte Quad
; VAR(*Buffer): Pointer to the S7_Buffer()
; VAR(BytePos): Start position in the Buffer (in Byte count) 
; VAR(Value):   New value for the DWORD [0..4294967295]
; RET:  #TRUE if succeeded; #FALSE if failed
; ============================================================================

  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos
  
  *pVal = CheckBuffer(*Buffer, BytePos, #S7_4Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
  ; Memory Model S7:  lo,hi
  ; Memory Model PC:  hi,lo
  ;                                                   Hi 32Bit                -                     Lo 32 Bit
  ;                                   Byte0, Byte1, Byte2, Byte3 - Byte4, Byte5, Byte6, Byte7, Byte8
  ;
  ; on PC side PureBasic.Quad we mut access the Bytes 4..7 the get the unsigned 32Bit value 
  If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid
    S7_MemCopy_DWORD(@Value, *pVal)
    ProcedureReturn #True
  Else
    ProcedureReturn #False      
  EndIf

EndProcedure

; ************************ GET/SET DINT **************************************

Procedure.l S7_GetDInt(*Buffer, BytePos.i)
; ============================================================================
; NAME: S7_GetDInt
; DESC: Reads 32Bit from S7_Buffer() an Returns it As PureBasic 32Bit singed Long
; VAR(*Buffer): Pointer to the S7_Buffer()
; VAR(BytePos): Start position in the Buffer (in Byte count) 
; RET:  Returns the signed Value of the S7_DINT [-2147483648..2147483647]
; ============================================================================
  
  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos
  Protected ret.l

  *pVal = CheckBuffer(*Buffer, BytePos, #S7_4BYTE_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
   If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid
    S7_MemCopy_DWORD(*pVal, @ret) 
 EndIf

  ProcedureReturn ret
EndProcedure

Procedure S7_SetDInt(*Buffer, BytePos.i, Value.l)
; ============================================================================
; NAME: S7_SetDInt
; DESC: Writes a  signed 32Bit DINT into S7_Buffer()
; VAR(*Buffer): Pointer to the S7_Buffer()
; VAR(BytePos): Start position in the Buffer (in Byte count) 
; VAR(Value):   New value for the DINT [-2147483648..2147483647]
; RET:  #TRUE if succeeded; #FALSE if failed
; ============================================================================

  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos
  
  *pVal = CheckBuffer(*Buffer, BytePos, #S7_4Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
  If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid
    S7_MemCopy_DWORD(@Value, *pVal)
    ProcedureReturn #True
  Else
    ProcedureReturn #False      
  EndIf

EndProcedure

; ************************ GET/SET REAL **************************************

Procedure.f S7_GetReal(*Buffer, BytePos.i)
; ============================================================================
; NAME: S7_GetReal
; DESC: Reads 32Bit from S7_Buffer() an Returns it As PureBasic 32Bit FLOAT
; VAR(*Buffer): Pointer to the S7_Buffer()
; VAR(BytePos): Start position in the Buffer (in Byte count) 
; RET:  Returns the signed Value of the S7_REAL  
; ============================================================================
  
  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos
  Protected ret.f

   *pVal = CheckBuffer(*Buffer, BytePos, #S7_4BYTE_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
   If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid
     S7_MemCopy_DWORD(*pVal, @ret) 
   EndIf

  ProcedureReturn ret
EndProcedure

Procedure S7_SetReal(*Buffer, BytePos.i, Value.f)
; ============================================================================
; NAME: S7_SetReal
; DESC: Writes a  4Byte REAL into S7_Buffer()
; VAR(*Buffer): Pointer to the S7_Buffer()
; VAR(BytePos): Start position in the Buffer (in Byte count) 
; VAR(Value):   New value for the REAL
; RET:  #TRUE if succeeded; #FALSE if failed
; ============================================================================

  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos
  
  *pVal = CheckBuffer(*Buffer, BytePos, #S7_4Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
  If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid
    S7_MemCopy_DWORD(@Value, *pVal)
    ProcedureReturn #True
  Else
    ProcedureReturn #False      
  EndIf

EndProcedure

; ************************ GET/SET STRING ************************************

 Procedure.s S7_GetString(*Buffer, BytePos.i)
; ============================================================================
; NAME: S7_GetString
; DESC: Reads a S7-String from S7_Buffer() an convert it to a PureBasic String
; VAR(*Buffer): Pointer to the S7_Buffer()
; VAR(BytePos): Start position in the Buffer (in Byte count) 
; RET:  Returns the CAHAR() Part of a S7_STRING as a PureBasic String 
; ============================================================================
   
  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos
  Protected.i LenString, LenStringBuffer
  Protected.i I, NoOfCharsToRead
  Protected.a MyChar
  Protected.s sString
  
  *pVal = CheckBuffer(*Buffer, BytePos, #S7_STRING_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
  If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid
    
    LenStringBuffer = PeekB(*pVal)
    LenString = PeekB(*pVal +1)
    
    If LenString > LenStringBuffer
      NoOfCharsToRead = LenStringBuffer
    Else
      NoOfcharsToRead = LenString 
    EndIf
    
    ;Debug "NoOfCahrs: " + NoOfCharsToRead
    ; sString = Space(NoOfCharsToRead)
    
    For I = 0 To (NoOfcharsToRead -1)
      MyChar = PeekA(*pVal + 2 + I)
      sString = sString + Chr(MyChar) 
      ;Debug "MyChar: " + Chr(MyChar) 
    Next
    
    ; Debug Str(lenstringBuffer) + " : " + Str(LenString) + " : " + sString
  EndIf
  
  ProcedureReturn sString
  
EndProcedure

Procedure.i S7_SetString(*Buffer, BytePos.i, sString.s)
; ============================================================================
; NAME: S7_SetString
; DESC: Writes a S7-String into S7_Buffer() 
; RET:  #TRUE if succeeded; #FALSE if failed
; ============================================================================
  
  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos
  Protected.i LenString, LenStringBuffer
  Protected.i I, NoOfCharsToWrite
  Protected.a MyChar
  
  ; ACHTUNG: wir müssen dafür sorgen, dass wir auch wirklich einen ASCII String schreiben
  ; PureBasic liefert je nach Einstellung auch UnicodeStrings. Sicherheitshalber müssen
  ; wir das überprüfen und in ASCII-String wandeln. Evtl. könnte man dafür auch den
  ; PseudoType p-ascii verwenden. Könnte aber sein, dass die Pseudotypes nur bei
  ; mit Prototype deklarierten Funktionen aus DLLs arbeiten!
  
  *pVal = CheckBuffer(*Buffer, BytePos, #S7_STRING_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
  If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid
    
    ; Hier Code für String schreiben noch erstellen!
    ; ACHTUNG! Überprüfung, dass wir nicht über den Buffer() hinaus schreiben
    
    ProcedureReturn #True
  Else
    ProcedureReturn #False      
  EndIf
  
EndProcedure

; ************************ GET/SET DATE_AND_TIME *****************************

Procedure S7_GetDateTime(*Buffer, BytePos.i, *DateTime.udt_S7_DATE_AND_TIME)
; ============================================================================
; NAME: S7_GetDateTime
; DESC: Reads 8Byte from S7_Buffer() an Returns it As S7_DATE_AND_TIME
; VAR(*Buffer): Pointer to the S7_Buffer()
; VAR(BytePos): Start position in the Buffer (in Byte count) 
; VAR(*DateTime): Pointer to our PureBasic DATE_AND_TIME Structure
; RET:  Returns S7_DATE_AND_TIME as a Structure  
; ============================================================================
  
  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos
  Protected DateTime.udt_S7_DATE_AND_TIME, yy.l
 
   *pVal = CheckBuffer(*Buffer, BytePos, #S7_8BYTE_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
    If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid

      If *DateTime
     
        yy = S7_BCDtoByte(PeekA(*pVal))
       
        If yy < 90        ; 00..89
          yy = yy + 2000
        Else              ; 90..99
          yy = yy + 1990
        EndIf
        
        *DateTime\Year   = yy
        *DateTime\Month  = S7_BCDtoByte(PeekA(*pVal + 1))
        *DateTime\Day    = S7_BCDtoByte(PeekA(*pVal + 2))
        *DateTime\hour   = S7_BCDtoByte(PeekA(*pVal + 3))
        *DateTime\minute = S7_BCDtoByte(PeekA(*pVal + 4))
        *DateTime\second = S7_BCDtoByte(PeekA(*pVal + 5))
       
        *DateTime\WeekDay = S7_BCDtoByte(PeekA(*pVal + 7) & $0F)
     
      EndIf
   EndIf 
 
 EndProcedure
 
Procedure.i S7_SetDateTime(*Buffer, BytePos.i, *DateTime.udt_S7_DATE_AND_TIME)
; ============================================================================
; NAME: S7_SetDateTimeAt
; DESC: Writes a  S7_DateAndTime into S7_Buffer()
; RET:  #TRUE if succeeded; #FALSE if failed
; ============================================================================

  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos
  Protected yy.l
 
  *pVal = CheckBuffer(*Buffer, BytePos, #S7_8Byte_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
  If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid
    If *DateTime
       
      yy= *DateTime\Year
     
      If yy >= 1990 And yy <= 1999
        yy = yy - 1900
      ElseIf yy >= 2000 And yy <= 2089
        yy = yy - 2000         
      EndIf 
     
      PokeA(*pVal    , S7_WORDtoBCD(yy))
      PokeA(*pVal+1, S7_WORDtoBCD(*DateTime\Month))
      PokeA(*pVal+2, S7_WORDtoBCD(*DateTime\Day))
      PokeA(*pVal+3, S7_WORDtoBCD(*DateTime\hour))
      PokeA(*pVal+4, S7_WORDtoBCD(*DateTime\minute))
      PokeA(*pVal+5, S7_WORDtoBCD(*DateTime\second))
      PokeA(*pVal+6, 0)
      PokeA(*pVal+7, S7_WORDtoBCD(*DateTime\WeekDay))
     
    EndIf
    ProcedureReturn #True
  Else
    ProcedureReturn #False      
  EndIf
   
EndProcedure

; ************************ GET/SET POINTER ***********************************

Procedure.i S7_GetPointer(*Buffer, BytePos.i, *S7_PTR.udt_S7_POINTER)
; ============================================================================
; NAME: S7_GetPointer
; DESC: Reads a 6Byte S7-POINTER format from S7_Buffer()
; VAR(*Buffer): Pointer to the S7_Buffer()
; VAR(BytePos): Start position in the Buffer (in Byte count) 
; VAR(*S7_PTR): Destination Structure to write the Data .udt_S7_POINTER 
; RET: #TRUE if succeeded; #FALSE if failed
; ============================================================================

  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos

   *pVal = CheckBuffer(*Buffer, BytePos, #S7_POINTER_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
   If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid
     S7_MemCopy_WORD(*pVal, @*S7_PTR\DB_No)
     S7_MemCopy_DWORD(*pVal+2, @*S7_PTR\Addr)   ; copies Address and MemID
     *S7_PTR\Addr = *S7_PTR\Addr & $FFF         ; remove MemID from Address
     
     *S7_PTR\MemID = PeekC(*pVal + 2)           ; Memory Area ID
     ProcedureReturn #True
   Else
      ProcedureReturn #False
   EndIf
 
EndProcedure

Procedure.i S7_SetPointer(*Buffer, BytePos.i, *S7_PTR.udt_S7_POINTER)
  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos
  Protected ret

   *pVal = CheckBuffer(*Buffer, BytePos, #S7_POINTER_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
   If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid
     S7_MemCopy_WORD(@*S7_PTR\DB_No, *pVal)
     S7_MemCopy_DWORD(@*S7_PTR\Addr, *pVal+2)   ; copies Address with MemID=0
     PokeC(*pVal + 2, *S7_PTR\MemID)            ; overwerite MemID with the correct value
     ProcedureReturn #True
   Else
     ProcedureReturn #False
   EndIf
  
EndProcedure

; ************************ GET/SET ANY ***************************************

Procedure.i S7_GetAnyPointer(*Buffer, BytePos.i, *S7_ANY.udt_S7_ANY)
; ============================================================================
; NAME: S7_GetAnyPointer
; DESC: Reads a 10Byte S7-ANY-POINTER format from S7_Buffer()
; VAR(*Buffer): Pointer to the S7_Buffer()
; VAR(BytePos): Start position in the Buffer (in Byte count) 
; VAR(*S7_ANY): Destination Structure to write the Data .udt_S7_ANY  
; RET: #TRUE if succeeded; #FALSE if failed
; ============================================================================
  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos
  Protected ret

   *pVal = CheckBuffer(*Buffer, BytePos, #S7_ANY_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
   If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid
     *S7_ANY\S7ID = PeekC(*pVal)
     *S7_ANY\DataType = PeekC(*pVal+1)
     S7_MemCopy_WORD(*pVal+2, @*S7_ANY\Iterations)
     S7_GetPointer(*pVal, 4, @*S7_ANY\ptr)
     ProcedureReturn #True
   Else
      ProcedureReturn #False
   EndIf
 
EndProcedure

Procedure.i S7_SetAnyPointer(*Buffer, BytePos.i, *S7_ANY.udt_S7_ANY)
  Protected *pVal        ; Pointer to the actual Value accessed by pBuffer + BytePos
  Protected ret

   *pVal = CheckBuffer(*Buffer, BytePos, #S7_ANY_TYPE)   ; returns the Pointer to the actual Value in Buffer or 0
  
   If *pVal        ; Memory accessed by (*Buffer + BytePos) is valid
     PokeA(*pVal,*S7_ANY\S7ID)
     PokeA(*pVal+1, *S7_ANY\DataType)
     S7_MemCopy_WORD(@*S7_ANY\Iterations, *pVal+2)
     S7_SetPointer(*pVal, 4, *S7_ANY\ptr)
     ProcedureReturn #True
   Else
      ProcedureReturn #False
   EndIf
 
EndProcedure

DisableExplicit
; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 267
; FirstLine = 834
; Folding = +--+--
; Optimizer
; EnableXP
; CPU = 5