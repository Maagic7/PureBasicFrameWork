; ===========================================================================
;  FILE : PbFw_Module_Buffer.pb
;  NAME : Module BUFFER [BUF::]
;  DESC : Wrapper for Buffer handling 
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/11/08
; VERSION  :  0.1 untested Developer Version
; COMPILER :  PureBasic 6.0
;
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
;   2025/02/08 S.Maag : BUFFER:: ist to long for the workflow. Changed to BUF::
;   2025/02/06 S.Maag : Added Functions for Bit-Buffers
;   2025/01/20 S.Maag : Moved the general Any-Pointer definition TUptr from
;                       Module Buffer:: to PX:: and changend Name to pAny 
;                       AllocateBuffer() option ClearBuffer=#False was not o.k.
;}
;{ TODO:
;}
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

 XIncludeFile "PbFw_Module_PX.pb"           ; PX::     Purebasic Extention Module
 XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::   FrameWork control Module
 XIncludeFile "PbFw_Module_Debug.pb"        ; DBG::    Debug Module
 XIncludeFile "PbFw_Module_Bit.pb"          ; BIT::    Bit Operation Module

DeclareModule BUF
  
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  
  #BUF_AlignWord     = 2
  #BUF_AlignLong     = 4
  #BUF_AlignQuad     = 8
  #BUF_AlignDQuad    = 16
  #BUF_AlignInteger  = SizeOf(Integer)
   
  #BUF_AlingSektor   = 512      ; Align Buffer Size to Standard Sektor Size (512 Bytes)
  #BUF_AlignMemPage  = 4096     ; Align Buffer Size to 4094 Bytes (It's the Standard Size of a Memory-Page)
  #BUF_AlignSektor4K = 4096     ; Aling Buffer Size to 4K Sektor (4096 Bytes)
  
  ; 2025/01/20 : Now hBuffer use AnyPointer from Modul PX:: instead of it's own TUptr definition
  Structure hBuffer
    *_ptrMem.PX::pAny ; Pointer to BufferStart in Memory (ATTENTION!! Never change this value! => Programm will chrash!)
    *UserPtr.PX::pAny ; Any Pointer (actual processed BUFFER position)
    AlignMode.i       ; AlignMode (#BUF_AlignWord, #BUF_AlignLong, #BUF_AlignInteger ...)
    MemSize.i         ; Allocated MemorySize in [BYTES]
    RequestedSize.i   ; the requested Size in [BYTES] (maybe lower than MemSize)
    DataSize.i        ; Size of the Datas in the Buffer [BYTES] (for User pourpose)
    Pitch.i           ; BufferPitch (Row length in Byte, for Image or fixed String use)
    Lines.i           ; BufferLines (No of Columns, for Image or fixed String use)
    Name.s            ; String for what ever we want: FileName of Data ... 
  EndStructure
 
  Declare.i AllocateBuffer(ReqByteSize, *hBUF.hBuffer, Align = #BUF_AlignInteger, ClearBuffer=#True)
  Declare FreeBuffer(*hBUF.hBuffer)
  Declare ClearBufferMemory(*hBUF.hBuffer)
  Declare FillBuffer(*hBUF.hBuffer, Value, PB_Type=#PB_Byte)
  Declare.i CloneBuffer(*hBUF.hBuffer, *hCloneBUF.hBuffer)
  Declare FileToBuffer(FileName.s, *hBUF.hBuffer, Align=#BUF_AlignInteger)
  Declare BufferToFile(*hBUF.hBuffer, FileName.s)
  Declare.i ReadBit(*hBUF.hBuffer, BitNo)
  Declare.i WriteBit(*hBUF.hBuffer, BitNo, NewBitValue=#True)

EndDeclareModule


Module BUF
 
  EnableExplicit
  
  ;- ----------------------------------------------------------------------
  ;- PbFw Module local configurations
  ;  ----------------------------------------------------------------------
  #PbFwCfg_Module_CheckPointerException = #True     ; This constant must have same Name in all Modules. On/Off PoninterExeption for this Module

  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  ;- ----------------------------------------------------------------------
  ;- Module Private Functions
  ;- ----------------------------------------------------------------------
  
  Procedure _ClearBufferHandle(*hBuffer.hBuffer)
    With *hBuffer    ; Clear our BufferHandling Structure 
      \_ptrMem = 0
      \MemSize = 0
      \AlignMode = 0
      \RequestedSize=0
      \DataSize = 0
      \UserPtr = 0
      \Name =""
    EndWith 
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Module Public Functions
  ;- ----------------------------------------------------------------------

  Procedure.i AllocateBuffer(ReqByteSize, *hBUF.hBuffer, Align = #BUF_AlignInteger, ClearBuffer=#True)
  ; ============================================================================
  ; NAME: AllocateBuffer
  ; DESC: Allocate the Memory for the Buffer
  ; VAR(ReqByteSize) :  Requestet Size of the Buffer; Real size will be aligend
  ; VAR(Align) : Byte Aling: real size will be alligned to fit n*Align   
  ; VAR(ClearBuffer) : #TRUE : fills the Buffer with 0
  ;                    #FALSE: keep the memory as it is (it may contain trash)
  ; RET.i: Adress of Memory
  ; ============================================================================
    
    Protected AlignedByteSize, RET
    
    AlignedByteSize = (ReqByteSize / Align) * Align
    
    If ReqByteSize % Align   ; Modulo Division
      AlignedByteSize + Align
    EndIf
    
    If ClearBuffer
      RET= AllocateMemory(AlignedByteSize)   ; Get the Memory from OS and fill with 0
    Else
      RET= AllocateMemory(AlignedByteSize, #PB_Memory_NoClear)   ; Get the Memory from OS and do not clear
    EndIf
    
    If RET    ; **** Ok Memory allocated ***** 
      
      With *hBUF        ; Fill our BufferHandling Structure with teh correct values
        \_ptrMem = RET               ; Pointer to Memory
        \RequestedSize=ReqByteSize  ; the originally requested size
        \MemSize = AlignedByteSize  ; the allocated size (with #BUF_AlignToMemPageToMemPage BlockSize)
        \AlignMode = Align          ; The Byte Align Mode
        \DataSize = 0               ; the Size of our Data in the Buffer (for User purepose)
        \UserPtr = RET              ; Universal Pointer for user purpose (is set to BufferStart)
      EndWith
      ProcedureReturn RET
      
    Else  ; *****  ERROR: Memory not allocated *****
      
      _ClearBufferHandle(*hBUF)
      ProcedureReturn 0
    EndIf
        
  EndProcedure
  
  Procedure FreeBuffer(*hBUF.hBuffer)
  ; ============================================================================
  ; NAME: FreeBuffer
  ; DESC: Destroy the Buffer and realease the Memory (FreeMemory())
  ; VAR(*hBUF.hBuffer) :  Handle for the Buffer
  ; RET.i: Adress of Memory
  ; ============================================================================
    
    If *hBUF\_ptrMem
      FreeMemory(*hBUF\_ptrMem)
    EndIf
    
    _ClearBufferHandle(*hBUF)
    
  EndProcedure
  
  Procedure ClearBufferMemory(*hBUF.hBuffer)
  ; ============================================================================
  ; NAME: ClearBufferMemory
  ; DESC: fills the Buffer Memory with 0, Set DataSize=0, UserPtr=[StartOfBuffer]
  ; VAR(*hBUF.hBuffer) : Handle for the Buffer
  ; RET: -
  ; ============================================================================
    
    With *hBUF
      If \_ptrMem
        \MemSize = MemorySize(*hBUF\_ptrMem) ; get again the allocated MemorySize
        FillMemory(\_ptrMem, \MemSize)
        \DataSize = 0
        \UserPtr = \_ptrMem
      EndIf
    EndWith
  EndProcedure
  
  Procedure FillBuffer(*hBUF.hBuffer, Value, PB_Type=#PB_Byte)
  ; ============================================================================
  ; NAME: FillBuffer
  ; DESC: fills the Buffer Memory with Value, Set DataSize=0, UserPtr=[StartOfBuffer]
  ; VAR(*hBUF.hBuffer) : Handle for the Buffer
  ; VAR(Value)  : Value to fill
  ; VAR(PB_Type) : PureBasic FillType : #PB_Byte, #PB_Ascii, #PB_Word
  ;                #PB_Unicode, #PB_Character, #PB_Long, #PB_Integer       
  ; RET: -
  ; ============================================================================
    
    With *hBUF
      If \_ptrMem
        \MemSize = MemorySize(*hBUF\_ptrMem) ; get again the allocated MemorySize
        FillMemory(\_ptrMem, \MemSize, Value, PB_Type)
        \DataSize = 0
        \UserPtr = \_ptrMem
      EndIf
    EndWith
  EndProcedure
  
  Procedure.i CloneBuffer(*hBUF.hBuffer, *hCloneBUF.hBuffer)
  ; ============================================================================
  ; NAME: CloneBuffer
  ; DESC: Clones a Buffer (with Data)
  ; VAR(*hBUF.hBuffer) : Handle for source Buffer 
  ; VAR(*hCloneBUF.hBuffer) : Handle for the coloned Buffer
  ; RET : Pointer to CloneBuffer or 0 if Clone is not created (Error)
  ; ============================================================================
    
    DBG::mac_CheckPointer2(*hBUF, *hCloneBUF)
    
    With *hBUF
      If *hBUF\_ptrMem
        If AllocateBuffer(\MemSize, *hCloneBUF, \AlignMode, #False) ; do not clear Buffer
          CopyMemory(\_ptrMem, *hCloneBUF, \MemSize)                 ; because we fill it with Data
          ProcedureReturn *hCloneBUF\_ptrMem
        Else
          ProcedureReturn 0
        EndIf    
      EndIf
    EndWith  
  EndProcedure
      
  Procedure FileToBuffer(FileName.s, *hBUF.hBuffer, Align=#BUF_AlignInteger)
  ; ============================================================================
  ; NAME: FileToBuffer
  ; DESC: Copies a File to a Buffer
  ; VAR(FileName.s) : Full FileName (with full Path)
  ; VAR(*hBUF.hBuffer) : Handle for Buffer
  ; VAR(Align) : Byte Aling: real size will be alligned to fit n*Align   
  ; RET : BytesRead or #Null 
  ; ============================================================================
    
    Protected FileNo.i, FileSize.q, RET
    
    If *hBUF
      FileNo = ReadFile(#PB_Any, FileName)
      
      If FileNo
        FileSize = Lof(FileNo)        ; LOF() = LengthOfFile
        
        If FileSize > 0
          With *hBUF
            
            If \_ptrMem                 ; Buffer Memory already exists
              FreeBuffer(*hBUF)         ; if BufferSize is to low, FreeMemory()
            EndIf
            
            If  AllocateBuffer(FileSize, *hBuf, Align)    ; Allocate the Buffer Memory
              RET = ReadData(FileNo, \_ptrMem, FileSize)  ; Read the file data
              \DataSize = RET                             ; Set the Buffers DataSize = BytesRead
            EndIf
          EndWith
        EndIf
      
        CloseFile(FileNo)     ; Close the File
      EndIf    
    EndIf
    ProcedureReturn RET   ; Return BytesRead
  EndProcedure 
  
  Procedure BufferToFile(*hBUF.hBuffer, FileName.s)
  ; ============================================================================
  ; NAME: BufferToFile
  ; DESC: Writes the Buffer into a File
  ; VAR(*hBUF.hBuffer) : Handle for Buffer
  ; VAR(FileName.s) : Full FileName (with full Path)
  ; RET : #True if succseed
  ; ============================================================================
    
  EndProcedure 
  
  ;- ----------------------------------------------------------------------
  ;- Functions for Bit-Buffers
  ;- ----------------------------------------------------------------------

  Procedure.i ReadBit(*hBUF.hBuffer, BitNo)
  ; ============================================================================
  ; NAME: ReadBit
  ; DESC: Read the Value from a Bit in the Buffer
  ; VAR(*hBUF.hBuffer) : Handle for Buffer
  ; VAR(BitNo) : The No of the Bit [0..n] 
  ; RET : The value of the Bit [#False, #True]
  ; ============================================================================
    Protected BitValue, ByteNo, BitNoByte
    
    ByteNo = BitNo >> 8
    BitNoByte = BitNo - ByteNo
    
    If ByteNo < *hBUF\MemSize
      BitValue = (*hBUF\_ptrMem + ByteNo) & (1 << BitNoByte)
    EndIf
    
    ProcedureReturn BitValue
  EndProcedure
  
  Procedure.i WriteBit(*hBUF.hBuffer, BitNo, NewBitValue=#True)
  ; ============================================================================
  ; NAME: ReadBit
  ; DESC: WriteBit a Bit in the Buffer
  ; VAR(*hBUF.hBuffer) : Handle for Buffer
  ; VAR(BitNo) : The No of the Bit [0..n] 
  ; RET : #True if succeed
  ; ============================================================================
   Protected ByteNo, BitNoByte, NewByteValue
   
    BitNo = BitNo & $FF
     
    ByteNo = BitNo >> 8
    BitNoByte = BitNo - ByteNo
    If ByteNo < *hBuf\MemSize
      If NewBitValue
        *hBUF\_ptrMem\aa[ByteNo] = *hBUF\_ptrMem\aa[ByteNo] | 1<<BitNoByte
      Else
        *hBUF\_ptrMem\aa[ByteNo] = *hBUF\_ptrMem\aa[ByteNo] & ~(1<<BitNoByte)
      EndIf
      ProcedureReturn #True
    Else
      ProcedureReturn #False
    EndIf
    
  EndProcedure
  
  Procedure.i CountBits(*hBUF.hBuffer, ByteNoStart=0, NoOfBytes=0)
  ; ============================================================================
  ; NAME: CountBits
  ; DESC: Count the number of Hi Bits in the Buffer
  ; VAR(*hBUF.hBuffer) : Handle for Buffer
  ; VAR(BitNo) : The No of the StartByte [0 .. \Memsize-1]
  ; VAR(NoOfBytes) : NoOfBytes to count [1 .. \Memsize]; <=0; count all Bytes
  ; RET : No of Hi Bits 
  ; ============================================================================
    Protected cnt, *pBuf.PX::pAny, *pEnd
       
    If NoOfBytes <= 0 Or NoOfBytes > *hBUF\MemSize
      NoOfBytes = *hBUF\MemSize     
    EndIf
    
    *pBuf = *hBUF\_ptrMem
    *pEnd = *pBuf + NoOfBytes -1   
    
    ; 1st process INT as long as possible
    While *pBuf + (SizeOf(Integer)-1) <= *pEnd
      cnt = cnt + BIT::BitCountINT(*pBuf\i)     
      *pBuf + SizeOf(Integer)  
    Wend
    
    ; 2nd process remaining bytes
    While *pBuf <= *pEnd
      cnt = cnt + BIT::BitCount16(*pBuf\a)
      *pBuf + 1  
    Wend      
   
    ProcedureReturn cnt
  EndProcedure
  
EndModule

; IDE Options = PureBasic 6.20 Beta 4 (Windows - x64)
; CursorPosition = 16
; Folding = ---
; Optimizer
; CPU = 5