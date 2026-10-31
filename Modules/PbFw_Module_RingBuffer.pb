; ===========================================================================
;  FILE : PbFw_Module_RingBuffer.pb
;  NAME : Module RingBuffer [RBUF::]
;  DESC : A RingBuffer FrontEnd! Provides a all the Mothodes to
;  DESC : convert every Pointer fo a Memory Block into a RingBuffer
;  DESC : RingBuffer do not allocate it's memory. You have to provide
;  DESC : a Memory Block Pointer!
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2026/10/18
; VERSION  :  0.5 untested Developer Version
; COMPILER :  I hope all versions!
; OS       :  all
; ===========================================================================
; ChangeLog:
;{
;}
;{ TODO:
;}
; ===========================================================================

XIncludeFile "PbFw_Module_PX.pb"          ; PX::      Purebasic Extention Module

DeclareModule RBUF
  
  EnableExplicit
  
  Structure _TRBinternal
    *BasePtr.PX::pAny   ; Memory Base Pointer
    *pWrt.PX::pAny      ; Dynamic write cursor position
  EndStructure
  
  Structure TRingBuffer
    _int._TRBinternal   ; Internal use Data! Don't touch it!
    *pBuf.PX::pAny      ; User AnyPointer. Modifiy this Pointer for your purpose
    ByteSize.i          ; Total capacity of the buffer
    
    ItemType.i          ; [#PB_Byte, #PB_WORD, #PB_LONG, ...] 
    ItemByteSize.i      ; Bytesize of the Items -> the Buffer Item Align
    ItemMaxIdx.i        ; The maxium Item Index at current ItemByteSize
    
    IsFull.i            ; #True if the buffer cycled at least once
  EndStructure
  
  ; Public Interface 
  Declare.i Init(*RBUF.TRingBuffer, *pMemory, ByteSize.i, ItemType=#PB_Integer)
  
  ;- Add a Single Value 
  Declare.i AddByte   (*RBUF.TRingBuffer, Value.b)    
  Declare.i AddAscii  (*RBUF.TRingBuffer, Value.a)    
  Declare.i AddChar   (*RBUF.TRingBuffer, Value.c)    
  Declare.i AddUnicode(*RBUF.TRingBuffer, Value.u)    
  Declare.i AddWord   (*RBUF.TRingBuffer, Value.w)    
  Declare.i AddLong   (*RBUF.TRingBuffer, Value.l)    
  Declare.i AddInt    (*RBUF.TRingBuffer, Value.i)    
  Declare.i AddQuad   (*RBUF.TRingBuffer, Value.q)    
  Declare.i AddFloat  (*RBUF.TRingBuffer, Value.f)    
  Declare.i AddDouble (*RBUF.TRingBuffer, Value.d)    

  ;- Multiple Add Values 
  Declare.i MultiAddLong   (*RBUF.TRingBuffer, Array Values.l(1), NoOfItems=#PB_All)
  Declare.i MultiAddInt    (*RBUF.TRingBuffer, Array Values.i(1), NoOfItems=#PB_All)
  Declare.i MultiAddQuad   (*RBUF.TRingBuffer, Array Values.q(1), NoOfItems=#PB_All)
  Declare.i MultiAddFloat  (*RBUF.TRingBuffer, Array Values.f(1), NoOfItems=#PB_All)
  Declare.i MultiAddDouble (*RBUF.TRingBuffer, Array Values.d(1), NoOfItems=#PB_All)

  ;- Multiple Read 
  Declare.i MultiReadLong   (*RBUF.TRingBuffer, Array Values.l(1), NoOfItems, OffsetOfItems=0)
  Declare.i MultiReadInt    (*RBUF.TRingBuffer, Array Values.i(1), NoOfItems, OffsetOfItems=0)
  Declare.i MultiReadQuad   (*RBUF.TRingBuffer, Array Values.q(1), NoOfItems, OffsetOfItems=0)
  Declare.i MultiReadFloat  (*RBUF.TRingBuffer, Array Values.f(1), NoOfItems, OffsetOfItems=0)
  Declare.i MultiReadDouble (*RBUF.TRingBuffer, Array Values.d(1), NoOfItems, OffsetOfItems=0)
  
  ;- Index calculation 
  Declare.i GetIndex(*RBUF.TRingBuffer)
  Declare.i GetNextIndex(*RBUF.TRingBuffer, NoOfItemsNext=1)
  Declare.i GetPrevIndex(*RBUF.TRingBuffer, NoOfItemsPrevious=1)

EndDeclareModule

Module RBUF
  
  EnableExplicit
  
  ; Macro to increment the RingBuffers WritePointer caluclating the BufferOverflow
  Macro _IncWritePtr(_RBUF, _Bytes)
    _RBUF\_int\pWrt + _Bytes
    
    If _RBUF\_int\pWrt >= _RBUF\_int\BasePtr + _Bytes
      _RBUF\_int\pWrt   = _RBUF\_int\pWrt - _RBUF\ByteSize
      _RBUF\IsFull = #True
    EndIf
  EndMacro
  
  ; Macro to check if we reach BufferOverflow with a ByteOffset relative to WritePointer
  Macro _CheckBufferOverflow(_RBUF, _ByteOffset)
     Bool ((_RBUF\_int\pWrt + _ByteOffset) >= (_RBUF\_int\BasePtr + _RBUF\ByteSize))
  EndMacro
  
  ; Macro to check if we reach BufferUnderflow with a ByteOffset relative to WritePointer
  Macro _CheckBufferUnderflow(_RBUF, _ByteOffset)
     Bool ((_RBUF\_int\pWrt - _ByteOffset) < _RBUF\_int\BasePtr) 
  EndMacro
 
  Procedure.i Init(*RBUF.TRingBuffer, *pMemory, NoOfItems.i, ItemType=#PB_Integer)
  ; ============================================================================
  ; NAME: Init
  ; DESC: Initialize the Ringbuffer Instance DAta
  ; VAR(*RBUF.TRingBuffer) : Pointer to the RingBuffer Instance [*This]
  ; VAR(*pMemory) : Pointer to your Memory Block you want to use as RingBuffer
  ; VAR(NoOfItems) : NoOfItems to keep in the Ringbuffer
  ; VAR(ItemType): VarType of the Items [#PB_Byte, #PB_Word, #PB_Lomg, ...]
  ; RET.i : #True on success
  ; ============================================================================
    
    If *RBUF And *pMemory And NoOfItems > 0
      Debug "RBUF::INIT " + Str(*pMemory) + " - " + Str(*RBUF)
      With *RBUF
        \_int\BasePtr = *pMemory    ; Memory Base Pointer
        \_int\pWrt    = *pMemory    ; initial WritePointer        
        \pBuf         = *pMemory    ; user Pointer       
                 
        \IsFull   = #False          ; at start the Buffer is defined as not full
       
        Select ItemType
          Case #PB_Byte
            \ItemByteSize = SizeOf(Byte)
            \ItemType  = #PB_Byte
            
          Case #PB_Ascii
            \ItemByteSize = SizeOf(Ascii)
            \ItemType  = #PB_Byte

          Case #PB_Character
            \ItemByteSize = SizeOf(Character)
            \ItemType  = #PB_Character
             
          Case #PB_Unicode
            \ItemByteSize = SizeOf(Unicode)
            \ItemType  = #PB_Byte
            
          Case #PB_Word
            \ItemByteSize = SizeOf(Word)
            \ItemType  = #PB_Unicode

          Case #PB_Long
            \ItemByteSize = SizeOf(Long)
            \ItemType  = #PB_Byte
           
          Case #PB_Integer
            \ItemByteSize = SizeOf(Integer)
            \ItemType  = #PB_Long
            
          Case #PB_Quad
            \ItemByteSize = SizeOf(Quad)
            \ItemType  = #PB_Quad
            
          Case #PB_Float
            \ItemByteSize = SizeOf(Float)
            \ItemType  = #PB_Float
            
          Case #PB_Double
            \ItemByteSize = SizeOf(Quad)
            \ItemType  = #PB_Double
          
          Default
            \ItemByteSize = SizeOf(Integer)
            
        EndSelect      
        
        \ByteSize = \ItemByteSize * NoOfItems
        \ItemMaxIdx = NoOfItems -1            ; The maxium Item Index at current ItemByteSize   
      EndWith
      
      
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Add a Single Value 
  ;- ----------------------------------------------------------------------
  
  Procedure.i AddByte(*RBUF.TRingBuffer, Value.b)    
    If *RBUF
      *RBUF\_int\pWrt\l = Value  
      _IncWritePtr(*RBUF, SizeOf(Byte))
      ProcedureReturn SizeOf(Byte)
    EndIf
    ProcedureReturn 0
  EndProcedure
  
  Procedure.i AddAscii(*RBUF.TRingBuffer, Value.a)    
    If *RBUF
      *RBUF\_int\pWrt\l = Value  
      _IncWritePtr(*RBUF, SizeOf(Ascii))
      ProcedureReturn SizeOf(Ascii)
    EndIf  
    ProcedureReturn 0
  EndProcedure
  
  Procedure.i AddChar(*RBUF.TRingBuffer, Value.c)    
    If *RBUF
      *RBUF\_int\pWrt\l = Value  
      _IncWritePtr(*RBUF, SizeOf(Character))
      ProcedureReturn SizeOf(Character)
    EndIf  
    ProcedureReturn 0
  EndProcedure
  
  Procedure.i AddUnicode(*RBUF.TRingBuffer, Value.u)    
    If *RBUF
      *RBUF\_int\pWrt\l = Value  
      _IncWritePtr(*RBUF, SizeOf(Unicode))
      ProcedureReturn SizeOf(Unicode)
    EndIf  
    ProcedureReturn 0
  EndProcedure
  
  Procedure.i AddWord(*RBUF.TRingBuffer, Value.w)    
    If *RBUF
      *RBUF\_int\pWrt\l = Value  
      _IncWritePtr(*RBUF, SizeOf(Word))
      ProcedureReturn SizeOf(Word)
    EndIf  
    ProcedureReturn 0
  EndProcedure

  Procedure.i AddLong(*RBUF.TRingBuffer, Value.l)    
    If *RBUF
      *RBUF\_int\pWrt\l = Value  
      _IncWritePtr(*RBUF, SizeOf(Long))
      ProcedureReturn SizeOf(Long)
    EndIf  
  EndProcedure
  
  Procedure.i AddInt(*RBUF.TRingBuffer, Value.i)    
    If *RBUF
      *RBUF\_int\pWrt\i = Value  
      _IncWritePtr(*RBUF, SizeOf(Integer))             
      ProcedureReturn SizeOf(Integer)
    EndIf  
    ProcedureReturn 0
  EndProcedure
  
  Procedure.i AddQuad(*RBUF.TRingBuffer, Value.q)    
    If *RBUF
      *RBUF\_int\pWrt\q = Value  
      _IncWritePtr(*RBUF, SizeOf(Quad))             
      ProcedureReturn SizeOf(Quad)
    EndIf  
    ProcedureReturn 0
  EndProcedure

  Procedure.i AddFloat(*RBUF.TRingBuffer, Value.f)    
    If *RBUF
      *RBUF\_int\pWrt\f = Value  
      _IncWritePtr(*RBUF, SizeOf(Float))              
      ProcedureReturn SizeOf(Float)
    EndIf  
    ProcedureReturn 0
  EndProcedure

  Procedure.i AddDouble(*RBUF.TRingBuffer, Value.d)    
    If *RBUF
      *RBUF\_int\pWrt\d = Value  
      _IncWritePtr(*RBUF, SizeOf(DoubLe))             
      ProcedureReturn SizeOf(DoubLe)
    EndIf 
    ProcedureReturn 0
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Multiple Add Values 
  ;- ----------------------------------------------------------------------
  
  Procedure.i _MultiAdd(*RBUF.TRingBuffer, *Source, NoOfBytes)
  ; ======================================================================
  ; NAME: _MultiAdd
  ; DESC: internal MultiAdd function for all types of Values
  ; DESC: This function will be called by all the Public MultiAdds
  ; VAR(*RBUF.TRingBuffer): Pointer to the RingBuffer instance Data
  ; VAR(*Source): Pointer to Source Memory
  ; VAR(NoOfBytes): No of Bytes copied
  ; ======================================================================
    
    ; because it is a internal function we do not check Pointers
    ; Pointers are still checked in the Public MultiAdd Functions
    
    If NoOfBytes > *RBUF\ByteSize
      NoOfBytes = *RBUF\ByteSize
    EndIf
    
    ; if we create a BufferOverflow adding all Bytes, we have to split into two copies  
    If _CheckBufferOverflow(*RBUF, NoOfBytes)
      Protected.i BytesToCopy 
      
       ; Calculate how many samples fit into the remaining space until the buffer end
      BytesToCopy = NoOfBytes - (*RBUF\_int\BasePtr +NoOfBytes - *RBUF\_int\pWrt)
      
      ; Copy 1st part: Fill up the buffer until its end
      CopyMemory(*Source, *RBUF\_int\pWrt, BytesToCopy)
      
      ; calculate the rest Bytes
      BytesToCopy = NoOfBytes - BytesToCopy
      ; Copy 2nd part: at beginning of the Buffer
      CopyMemory(*Source, *RBUF\_int\BasePtr, BytesToCopy)
       
    Else       
      CopyMemory(*Source, *RBUF\_int\pWrt, NoOfBytes)
    EndIf
    
    ; Update the write index to its new relative position and mark buffer full
    _IncWritePtr(*RBUF, NoOfBytes)
  
    ProcedureReturn NoOfBytes
          
  EndProcedure
  
  Procedure.i MultiAddLong(*RBUF.TRingBuffer, Array Values.l(1), NoOfItems=#PB_All)
  ; ======================================================================
  ; NAME: MultiAddLong
  ; DESC: Add an Array of Long to the RingBuffer
  ; VAR(*RBUF.TRingBuffer): Pointer to the RingBuffer instance Data
  ; VAR(Values(): Array of Values to add
  ; VAR(NoOfItems): No of Items to add.
  ; RET.i : No of Bytes copied
  ; ======================================================================
           
    If *RBUF And Values()
      Protected Items = ArraySize(Values()) +1 
      
      If (NoOfItems = #PB_All) Or (Items < NoOfItems)
        NoOfItems = Items
      EndIf
      
      Protected.i ItemSize = SizeOf(Long)
      Protected.i ByteSize = ItemSize * NoOfItems
      Protected.i BytesAdd
     
      BytesAdd = _MultiAdd(*RBUF, @Values(0), ByteSize)
      ProcedureReturn BytesAdd / ItemSize
    EndIf
    
    ProcedureReturn 0    
  EndProcedure

  Procedure.i MultiAddInt(*RBUF.TRingBuffer, Array Values.i(1), NoOfItems=#PB_All)
  ; ======================================================================
  ; NAME: MultiAddInt
  ; DESC: Add an Array of Integers to the RingBuffer
  ; VAR(*RBUF.TRingBuffer): Pointer to the RingBuffer instance Data
  ; VAR(Values(): Array of Values to add
  ; VAR(NoOfItems): No of Items to add.
  ; RET.i : No of Bytes copied
  ; ====================================================================== 
    
    If *RBUF And Values()
      Protected Items = ArraySize(Values()) +1 
      
      If (NoOfItems = #PB_All) Or (Items < NoOfItems)
        NoOfItems = Items
      EndIf
      
      Protected.i ItemSize = SizeOf(Integer)
      Protected.i ByteSize = ItemSize * NoOfItems
      Protected.i BytesAdd
     
      BytesAdd = _MultiAdd(*RBUF, @Values(0), ByteSize)
      ProcedureReturn BytesAdd / ItemSize
    EndIf
    
    ProcedureReturn 0    
  EndProcedure
  
  Procedure.i MultiAddQuad(*RBUF.TRingBuffer, Array Values.q(1), NoOfItems=#PB_All)
  ; ======================================================================
  ; NAME: MultiAddInt
  ; DESC: Add an Array of Quads to the RingBuffer
  ; VAR(*RBUF.TRingBuffer): Pointer to the RingBuffer instance Data
  ; VAR(Values(): Array of Values to add
  ; VAR(NoOfItems): No of Items to add.
  ; RET.i : No of Bytes copied
  ; ======================================================================
       
    If *RBUF And Values()
      Protected Items = ArraySize(Values()) +1
      
      If (NoOfItems = #PB_All) Or (Items < NoOfItems)
        NoOfItems = Items
      EndIf
      
      Protected.i ItemSize = SizeOf(Quad)
      Protected.i ByteSize = ItemSize * NoOfItems
      Protected.i BytesAdd
      
      BytesAdd = _MultiAdd(*RBUF, @Values(0), ByteSize)
      ProcedureReturn BytesAdd / ItemSize
    EndIf
    
    ProcedureReturn 0    
  EndProcedure
  
  Procedure.i MultiAddFloat(*RBUF.TRingBuffer, Array Values.f(1), NoOfItems=#PB_All)
  ; ======================================================================
  ; NAME: MultiAddFloat
  ; DESC: Add an Array of Single Floats to the RingBuffer
  ; VAR(*RBUF.TRingBuffer): Pointer to the RingBuffer instance Data
  ; VAR(Values(): Array of Values to add
  ; VAR(NoOfItems): No of Items to add.
  ; RET.i : No of Bytes copied
  ; ======================================================================
       
    If *RBUF And Values()
      Protected Items = ArraySize(Values()) +1
      
      If (NoOfItems = #PB_All) Or (Items < NoOfItems)
        NoOfItems = Items + 1
      EndIf
      
      Protected.i ItemSize = SizeOf(Float)
      Protected.i ByteSize = ItemSize * NoOfItems
      Protected.i BytesAdd
      
      BytesAdd = _MultiAdd(*RBUF, @Values(0), ByteSize)
      ProcedureReturn BytesAdd / ItemSize
    EndIf
    
    ProcedureReturn 0    
  EndProcedure

  Procedure.i MultiAddDouble(*RBUF.TRingBuffer, Array Values.d(1), NoOfItems=#PB_All)
  ; ======================================================================
  ; NAME: MultiAddDouble
  ; DESC: Add an Array of Double Floats to the RingBuffer
  ; VAR(*RBUF.TRingBuffer): Pointer to the RingBuffer instance Data
  ; VAR(Values(): Array of Values to add
  ; VAR(NoOfItems): No of Items to add.
  ; RET.i : No of Bytes copied
  ; ======================================================================
       
    If *RBUF And Values()
      Protected Items = ArraySize(Values()) +1
      
      If (NoOfItems = #PB_All) Or (Items < NoOfItems)
        NoOfItems = Items + 1
      EndIf
      
      Protected.i ItemSize = SizeOf(Double)
      Protected.i ByteSize = ItemSize * NoOfItems
      Protected.i BytesAdd
      
      BytesAdd = _MultiAdd(*RBUF, @Values(0), ByteSize)
      ProcedureReturn BytesAdd / ItemSize
    EndIf
    
    ProcedureReturn 0    
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Multiple Read 
  ;- ----------------------------------------------------------------------
  
  Procedure.i _MultiRead(*RBUF.TRingBuffer, *Destination, NoOfBytes.i, ByteOffset)
  ; ======================================================================
  ; NAME: _MultiRead
  ; DESC: internal Function to read multiple Bytes from the RingBuffer
  ; VAR(*RBUF.TRingBuffer): Pointer to the RingBuffer instance Data
  ; VAR(*Destination): Pointer to Destionation Memory
  ; VAR(NoOfBytes): No of Bytes to read 
  ; RET.i: No of Bytes read
  ; ======================================================================
    
    ; Because it is an internal Function we do not check the Pointers here
    ; Pointers are checked in the Public Read Functions
    
    If NoOfBytes > *RBUF\ByteSize
      NoOfBytes = *RBUF\ByteSize
    EndIf
    
    ; if we create a BufferOverflow adding all Bytes, we have to split into two copies  
    If _CheckBufferUnderflow(*RBUF, NoOfBytes)
      Protected.i BytesToCopy 
      Protected *pRead = *RBUF\_int\pWrt - NoOfBytes
      
       ; Calculate how many samples fit into the remaining space until the buffer end
      ;BytesToCopy = NoOfBytes - (*RBUF\_int\BasePtr +NoOfBytes - *RBUF\_int\pWrt)
      
      ; Copy 1st part: Fill up the buffer until its end
      CopyMemory(*pRead, *Destination, BytesToCopy)
      
      ; calculate the rest Bytes
      BytesToCopy = NoOfBytes - BytesToCopy
      
      *pRead = *RBUF\_int\pWrt + *RBUF\ByteSize - NoOfBytes ; calcualte
      ; Copy 2nd part: at beginning of the Buffer
      CopyMemory(*pRead - NoOfBytes, *Destination, BytesToCopy)
       
    Else       
      CopyMemory(*pRead, *Destination, NoOfBytes)
    EndIf
       
    ProcedureReturn NoOfBytes  
  EndProcedure
  
  Procedure.i MultiReadLong(*RBUF.TRingBuffer, Array Values.l(1), NoOfItems, OffsetOfItems=0)
  ; ======================================================================
  ; NAME: MultiReadLong
  ; DESC: Read an Array of Long from the RingBuffer
  ; VAR(*RBUF.TRingBuffer): Pointer to the RingBuffer instance Data
  ; VAR(Values(): Array of Values to receive the Values from RingBuffer
  ; VAR(NoOfItems): No of Items to read. 
  ; RET.i : No of Bytes read
  ; ======================================================================
        
    If *RBUF And Values() And (NoOfItems > 0)
      Protected Items = ArraySize(Values()) +1 
      
      If Items < NoOfItems
        Dim Values(NoOfItems-1)
      EndIf
      
      Protected.i ItemSize = SizeOf(Long)
      Protected.i ByteSize = ItemSize * NoOfItems
      Protected.i BytesRead
      
      BytesRead = _MultiRead(*RBUF, @Values(0), ByteSize, OffsetOfItems * ItemSize)
      ProcedureReturn BytesRead / ItemSize
    EndIf
    ProcedureReturn 0    
  EndProcedure
  
  Procedure.i MultiReadInt(*RBUF.TRingBuffer, Array Values.i(1), NoOfItems, OffsetOfItems=0)
  ; ======================================================================
  ; NAME: MultiReadInt
  ; DESC: Read an Array of Integer from the RingBuffer
  ; VAR(*RBUF.TRingBuffer): Pointer to the RingBuffer instance Data
  ; VAR(Values(): Array of Values to receive the Values from RingBuffer
  ; VAR(NoOfItems): No of Items to read. 
  ; RET.i : No of Items read
  ; ======================================================================
    
    If *RBUF And Values() And (NoOfItems > 0)
      Protected Items = ArraySize(Values()) +1 
      
      If Items < NoOfItems
        Dim Values(NoOfItems-1)
      EndIf
      
      Protected.i ItemSize = SizeOf(Integer)
      Protected.i ByteSize = ItemSize * NoOfItems
      Protected.i BytesRead
      
      OffsetOfItems +1    ; because ptrWrite is NextItemToWrite we have to go back 1 Item
      BytesRead = _MultiRead(*RBUF, @Values(0), ByteSize, OffsetOfItems * ItemSize)      
      ProcedureReturn BytesRead / ItemSize
   EndIf
   ProcedureReturn 0    
  EndProcedure
  
  Procedure.i MultiReadQuad(*RBUF.TRingBuffer, Array Values.q(1), NoOfItems, OffsetOfItems=0)
  ; ======================================================================
  ; NAME: MultiReadQuad
  ; DESC: Read an Array of Quad from the RingBuffer
  ; VAR(*RBUF.TRingBuffer): Pointer to the RingBuffer instance Data
  ; VAR(Values(): Array of Values to receive the Values from RingBuffer
  ; VAR(NoOfItems): No of Items to read. 
  ; RET.i : No of Items read
  ; ======================================================================
    
    If *RBUF And Values() And (NoOfItems > 0)
      Protected Items = ArraySize(Values()) +1 
      
      If Items < NoOfItems
        Dim Values(NoOfItems-1)
      EndIf
      
      Protected.i ItemSize = SizeOf(Quad)
      Protected.i ByteSize = ItemSize * NoOfItems
      Protected.i BytesRead
         
      OffsetOfItems +1    ; because ptrWrite is NextItemToWrite we have to go back 1 Item
      BytesRead = _MultiRead(*RBUF, @Values(0), ByteSize, OffsetOfItems * ItemSize)      
      ProcedureReturn BytesRead / ItemSize
    EndIf
    ProcedureReturn 0    
  EndProcedure
  
  Procedure.i MultiReadFloat(*RBUF.TRingBuffer, Array Values.f(1), NoOfItems, OffsetOfItems=0)
  ; ======================================================================
  ; NAME: MultiReadFloat
  ; DESC: Read an Array of Single Floats from the RingBuffer
  ; VAR(*RBUF.TRingBuffer): Pointer to the RingBuffer instance Data
  ; VAR(Values(): Array of Values to receive the Values from RingBuffer
  ; VAR(NoOfItems): No of Items to read. 
  ; RET.i : No of Bytes read
  ; ======================================================================
        
    If *RBUF And Values() And (NoOfItems > 0)
      Protected Items = ArraySize(Values()) +1 
      
      If Items < NoOfItems
        Dim Values(NoOfItems-1)
      EndIf
      
      Protected.i ItemSize = SizeOf(Float)
      Protected.i ByteSize = ItemSize * NoOfItems
      Protected.i BytesRead
      
      OffsetOfItems +1    ; because ptrWrite is NextItemToWrite we have to go back 1 Item
      BytesRead = _MultiRead(*RBUF, @Values(0), ByteSize, OffsetOfItems * ItemSize)      
      ProcedureReturn BytesRead / ItemSize
    EndIf
    ProcedureReturn 0    
  EndProcedure
  
  Procedure.i MultiReadDouble(*RBUF.TRingBuffer, Array Values.d(1), NoOfItems, OffsetOfItems=0)
  ; ======================================================================
  ; NAME: MultiReadDouble
  ; DESC: Read an Array of Double Floats from the RingBuffer
  ; VAR(*RBUF.TRingBuffer): Pointer to the RingBuffer instance Data
  ; VAR(Values(): Array of Values to receive the Values from RingBuffer
  ; VAR(NoOfItems): No of Items to read. 
  ; RET.i : No of Bytes read
  ; ======================================================================
            
    If *RBUF And Values() And (NoOfItems > 0)
      Protected Items = ArraySize(Values()) +1 
      
      If Items < NoOfItems
        Dim Values(NoOfItems-1)
      EndIf
      
      Protected.i ItemSize = SizeOf(Double)
      Protected.i ByteSize = ItemSize * NoOfItems
      Protected.i BytesRead
      
      OffsetOfItems +1    ; because ptrWrite is NextItemToWrite we have to go back 1 Item
      BytesRead = _MultiRead(*RBUF, @Values(0), ByteSize, OffsetOfItems * ItemSize)      
      ProcedureReturn BytesRead / ItemSize
    EndIf
    ProcedureReturn 0    
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Index calculation 
  ;- ----------------------------------------------------------------------

  Procedure.i GetIndex(*RBUF.TRingBuffer)
    Protected res.i
    If *RBUF
      With *RBUF
        res = (\_int\pWrt - \_int\BasePtr) / \ItemByteSize
        
        ; If the Modulo  (\_int\pWrt - \_int\BasePtr) / \ItemByteSize is not 0
        If (res * \ItemByteSize) << (\_int\pWrt - \_int\BasePtr)
          Debug "Waring: " + #PB_Compiler_Module + "::" + #PB_Compiler_Procedure + " the RingBufferWritePointer is not correctly alined to your Data!" 
        EndIf
        
      EndWith
    EndIf
  EndProcedure
  
  Procedure.i GetNextIndex(*RBUF.TRingBuffer, NoOfItemsNext=1)
    
    Protected idx = GetIndex(*RBUF) + NoOfItemsNext 
    
    If idx > *RBUF\ItemMaxIdx
      idx = idx - *RBUF\ItemMaxIdx - 1
    EndIf
    
    ProcedureReturn idx
  EndProcedure
  
  Procedure.i GetPrevIndex(*RBUF.TRingBuffer, NoOfItemsPrevious=1)
    
    Protected idx = GetIndex(*RBUF) - NoOfItemsPrevious
    
    If idx < 0 
      idx = idx + *RBUF\ItemMaxIdx +1
    EndIf
    
    ProcedureReturn idx
  EndProcedure

EndModule

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 146
; FirstLine = 77
; Folding = ------
; DPIAware
; CPU = 5