; ===========================================================================
;  FILE : Module_BUFFER.pb
;  NAME : Module BUFFER [BUFFER::]
;  DESC : Wrapper for Buffer handling 
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/11/08
; VERSION  :  0.1
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

DeclareModule BUFFER
  
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES and CONSTANTS
  ;  ----------------------------------------------------------------------
  
  #BUFFER_AlignWord     = 2
  #BUFFER_AlignLong     = 4
  #BUFFER_AlignQuad     = 8
  
  CompilerIf #PB_Compiler_32Bit    
    #BUFFER_AlignInteger  = 4
  CompilerElse
    #BUFFER_AlignInteger  = 8
  CompilerEndIf
  
  #BUFFER_AlignMemPage  = 256     ; Align Buffer Size to 256 Bytes (It's the Standard Size of a Memory-Page)
  #BUFFER_AlingSektor   = 512     ; Align Buffer Size to Standard Sektor Size (512 Bytes)
  #BUFFER_AlignSektor4K = 4096    ; Aling Buffer Size to 4K Sektor (4096 Bytes)
  #BUFFER_AlignStandard = #BUFFER_AlignInteger

  ; The UniversalPointer Structre is trick to get access to Buffer/Memory
  ; as differet PureBasic Values
  ; [4] = define a static Array with 4 valus (0..3). With [0] we get a kind
  ; of virtual Array and we just have a Pointer to each VAR-Type we want.
  ; When declaring with an array like this, we still
  ; can use the single \b, which is perfect for a universal pointer variable

  Structure TUPtr  ; Universal Pointer (see PurePasic IDE Common.pb Structrue PTR)
    StructureUnion
      a.a[0]    ; ASCII   : 8 Bit unsigned  [0..255] 
      b.b[0]    ; BYTE    : 8 Bit signed    [-128..127]
      c.c[0]    ; CAHR    : 2 Byte unsigned [0..65535]
      w.w[0]    ; WORD    : 2 Byte signed   [-32768..32767]
      u.u[0]    ; UNICODE : 2 Byte unsigned [0..65535]
      l.l[0]    ; LONG    : 4 Byte signed   [-2147483648..2147483647]
      f.f[0]    ; FLOAT   : 4 Byte
      q.q[0]    ; QUAD    : 8 Byte signed   [-9223372036854775808..9223372036854775807]
      d.d[0]    ; DOUBLE  : 8 Byte float    
      i.i[0]    ; INTEGER : 4 or 8 Byte INT, depending on System
      ; *p.TUPtr[0] ; Pointer for TUPtr (it's possible and it's done in PB-IDE Source, but why???
    EndStructureUnion
  EndStructure

  Structure hBuffer
    ptrMem.i          ; Pointer to BufferStart in Memory (ATTENTION!! Never change this value! => Programm will chrash!)
    MemSize.i         ; Allocated MemorySize in [BYTES]
    AlignMode.i       ; AlignMode (#BUFFER_AlignWord, #BUFFER_AlignLong, #BUFFER_AlignInteger ...)
    RequestedSize.i   ; the requested Size in [BYTES] (maybe lower than MemSize)
    DataSize.i        ; Size of the Datas in the Buffer [BYTES] (for User pourpose)
    *UserPtr.TUPtr    ; Univeral Pointer for user operations (actual processed BUFFER position) 
    Name.s            ; String for what ever we want: FileName of Data ... 
  EndStructure
 
  Declare.i AllocateBuffer(ReqByteSize, *hBUF.hBuffer, Align = #BUFFER_AlignStandard, ClearBuffer=#True)
  Declare FreeBuffer(*hBUF.hBuffer)
  Declare ClearBufferMemory(*hBUF.hBuffer)
  Declare FillBuffer(*hBUF.hBuffer, Value, PB_Type=#PB_Byte)
  Declare.i CloneBuffer(*hBUF.hBuffer, *hCloneBUF.hBuffer)
  Declare SwapBuffers(*hBUF_1.hBuffer, *hBUF_2.hBuffer)
  Declare ImageToBuffer(Image.i, *hBUF.hBuffer, ResizeBuffer=#True)     ; BOOL
  Declare BufferToImage(*hBUF.hBuffer, Image.i)
  Declare FileToBuffer(FileName.s, *hBUF.hBuffer, Align=#BUFFER_AlignStandard)
  Declare BufferToFile(*hBUF.hBuffer, FileName.s)
  
EndDeclareModule


Module BUFFER
 
  EnableExplicit
  
  ;- ----------------------------------------------------------------------
  ;- Module Private Functions
  ;- ----------------------------------------------------------------------
  
  Procedure _ClearBufferHandle(*hBuffer.hBuffer)
    With *hBuffer    ; Clear our BufferHandling Structure 
      \ptrMem = 0
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

  Procedure.i AllocateBuffer(ReqByteSize, *hBUF.hBuffer, Align = #BUFFER_AlignStandard, ClearBuffer=#True)
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
    
    AlignedByteSize = (ReqByteSize/Align) * Align
    
    If ReqByteSize % Align   ; Modulo Division
      AlignedByteSize + Align
    EndIf
     
    RET=  AllocateMemory(AlignedByteSize)   ; Get the Memory from OS
    
    If RET    ; **** Ok Memory allocated ***** 
      
      With *hBUF        ; Fill our BufferHandling Structure with teh correct values
        \ptrMem = RET               ; Pointer to Memory
        \RequestedSize=ReqByteSize  ; the originally requested size
        \MemSize = AlignedByteSize  ; the allocated size (with #BUFFER_AlignToMemPageToMemPage BlockSize)
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
    
    If *hBUF\ptrMem
      FreeMemory(*hBUF\ptrMem)
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
      If \ptrMem
        \MemSize = MemorySize(*hBUF\ptrMem) ; get again the allocated MemorySize
        FillMemory(\ptrMem, \MemSize)
        \DataSize = 0
        \UserPtr = \ptrMem
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
      If \ptrMem
        \MemSize = MemorySize(*hBUF\ptrMem) ; get again the allocated MemorySize
        FillMemory(\ptrMem, \MemSize, Value, PB_Type)
        \DataSize = 0
        \UserPtr = \ptrMem
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
    
    With *hBUF
      If *hBUF\ptrMem
        If AllocateBuffer(\MemSize, *hCloneBUF, \AlignMode, #False) ; do not clear Buffer
          CopyMemory(\ptrMem, *hCloneBUF, \MemSize)                 ; because we fill it with Data
          ProcedureReturn *hCloneBUF\ptrMem
        Else
          ProcedureReturn 0
        EndIf    
      EndIf
    EndWith  
  EndProcedure
  
  Procedure SwapBuffers(*hBUF_1.hBuffer, *hBUF_2.hBuffer)
  ; ============================================================================
  ; NAME: SwapBuffers
  ; DESC: Xchanges two Buffers (by xchanging the Handels)
  ; VAR(*hBUF_1.hBuffer) : Handle for Buffer 1
  ; VAR(*hBUF_2.hBuffer) : Handle for Buffer 2
  ; RET : - 
  ; ============================================================================
    
    ; swap is not in the PB Help: it exists since PB 4.x and xchanges 2 values
    ; in an optimized way
    Swap *hBUF_1, *hBUF_2   
  EndProcedure  
  
  Procedure ImageToBuffer(Image.i, *hBUF.hBuffer, ResizeBuffer=#True)
  ; ============================================================================
  ; NAME: ImageToBuffer
  ; DESC: Copies an Image to a Buffer
  ; VAR(Image) : PureBasic Image No
  ; VAR(*hBUF.hBuffer) : Handle for Buffer
  ; VAR(ResizeBuffer) : #TRUE - Extend Buffer Size if to small or CrateBuffer
  ;                     #FALSE - Creates an Error if Buffer is to small 
  ; RET : #True if succseed
  ; ============================================================================
    
    Protected RET
    
    ProcedureReturn RET
  EndProcedure
   
  Procedure BufferToImage(*hBUF.hBuffer, Image.i)
  ; ============================================================================
  ; NAME: BufferToImage
  ; DESC: Copies a Buffer to an Image
  ; VAR(*hBUF.hBuffer) : Handle for Buffer
  ; VAR(Image) : PureBasic Image No
  ; RET : #True if succseed
  ; ============================================================================
  
  EndProcedure
  
  Procedure FileToBuffer(FileName.s, *hBUF.hBuffer, Align=#BUFFER_AlignStandard)
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
        
        With *hBUF
          
          If \ptrMem                  ; Buffer Memory already exists
            FreeBuffer(*hBUF)         ; if BufferSize is to low, FreeMemory()
          EndIf
          
         If  AllocateBuffer(FileSize, *hBuf, Align) ; Allocate the Buffer Memory
          RET = ReadData(FileNo, \ptrMem, FileSize) ; Read the file data
          \DataSize = RET                           ; Set the Buffers DataSize = BytesRead
         EndIf
        EndWith
        
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
  
EndModule

; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 9
; Folding = +--
; Optimizer
; CPU = 5
; Compiler = PureBasic 6.00 LTS (Windows - x86)