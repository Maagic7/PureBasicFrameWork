; ===========================================================================
;  FILE : PbFw_Module_RingBuffer.pb
;  NAME : Module RingBuffer [RBUF::]
;  DESC : A RingBuffer FrontEnd! Provides a all the Mothodes to
;  DESC : convert every Pointer fo a Memory Block into a RingBuffer
;  DESC : 
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
  
  EnableExplicit
  
  Structure TRingBuffer
    Array Buf.d(0)      ; The native double storage array
    Size.i              ; Total capacity of the buffer
    WriteIdx.i          ; Dynamic write cursor position
    IsFull.i            ; #True if the buffer cycled at least once
  EndStructure
  
  ; Public Interface API
  Declare.i Init(*Buf.TRingBuffer, Size.i)
  Declare   AddSingle(*Buf.TRingBuffer, Value.d)
  Declare   AddMulti(*Buf.TRingBuffer, Array SampleArray.d(1), Count.i)
  Declare.d ReadOffset(*Buf.TRingBuffer, StartIdx.i, Offset.i)
  Declare.i ReadBlock(*Buf.TRingBuffer, StartIdx.i, Length.i, Array TargetArray.d(1))
  Declare.i GetWriteIndex(*Buf.TRingBuffer)
  Declare.i IsBufferFull(*Buf.TRingBuffer)
 
EndDeclareModule

Module RBUF
  
  EnableExplicit
 
  Procedure.i Init(*Buf.TRingBuffer, Size.i)
  ; ============================================================================
  ; DESC: Allocates memory and sets up a fresh ring buffer instance
  ; ============================================================================
    If *Buf And Size > 0
      *Buf\Size     = Size
      *Buf\WriteIdx = 0
      *Buf\IsFull   = #False
      Dim *Buf\Buf(Size - 1)
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  Procedure AddSingle(*Buf.TRingBuffer, Value.d)
  ; ============================================================================
  ; DESC: Pushes a single double sample into the circular buffer
  ; ============================================================================
    If *Buf And *Buf\Size > 0
      *Buf\Buf(*Buf\WriteIdx) = Value
      
      *Buf\WriteIdx + 1
      If *Buf\WriteIdx >= *Buf\Size
        *Buf\WriteIdx = 0
        *Buf\IsFull = #True
      EndIf
    EndIf
  EndProcedure
  
   Procedure AddMulti(*Buf.TRingBuffer, Array SampleArray.d(1), Count.i)
  ; ============================================================================
  ; NAME: AddMulti
  ; DESC: High-speed ingestion of double samples into the ring buffer using CopyMemory.
  ;       Splits into maximum 2 optimized memory operations if wrapping occurs.
  ; ============================================================================
    Protected FirstBlockCnt.i, SecondBlockCnt.i
    Protected SizeOfDouble.i = SizeOf(Double) ; 8 Bytes
    
    If *Buf And SampleArray() And Count > 0 And *Buf\Size > 0
      
      ; Check if the incoming block fits linearly until the end of the buffer
      If (*Buf\WriteIdx + Count) <= *Buf\Size
        ; Scenario A: Full block fits in one single continuous memory write
        CopyMemory(@SampleArray(0), @*Buf\Buf(*Buf\WriteIdx), Count * SizeOf(Double))
        
        *Buf\WriteIdx + Count
        If *Buf\WriteIdx >= *Buf\Size
          *Buf\WriteIdx = 0
          *Buf\IsFull = #True
        EndIf
        
      Else
        ; Scenario B: Incoming data overflows the buffer end. Split into 2 operations.
        
        ; Calculate how many samples fit into the remaining space until the buffer end
        FirstBlockCnt = *Buf\Size - *Buf\WriteIdx
        
        ; Calculate how many samples will wrap around to start at index 0
        SecondBlockCnt = Count - FirstBlockCnt
        
        ; Copy 1st part: Fill up the buffer to its absolute hard end
        CopyMemory(@SampleArray(0), @*Buf\Buf(*Buf\WriteIdx), FirstBlockCnt * SizeOf(Double))
        
        ; Copy 2nd part: Wrap around and overwrite oldest data starting from Index 0
        CopyMemory(@SampleArray(FirstBlockCnt), @*Buf\Buf(0), SecondBlockCnt * SizeOf(Double))
        
        ; Update the write index to its new relative position and mark buffer full
        *Buf\WriteIdx = SecondBlockCnt
        *Buf\IsFull   = #True
        
      EndIf     
    EndIf
  EndProcedure
  
  Procedure.d ReadOffset(*Buf.TRingBuffer, StartIdx.i, Offset.i)
  ; ============================================================================
  ; DESC: Reads a value safely relative to a StartIdx using absolute integer modulo.
  ;       Handles positive and negative offsets perfectly!
  ; ============================================================================
    Protected TargetIdx.i
    If Not (*Buf And *Buf\Size > 0) : ProcedureReturn 0.0 : EndIf
    
    ; Calculate position using safe integer wrapping
    TargetIdx = (StartIdx + Offset) % *Buf\Size
    If TargetIdx < 0
      TargetIdx + *Buf\Size
    EndIf
    
    ProcedureReturn *Buf\Buf(TargetIdx)
  EndProcedure 

   Procedure.i ReadBlock(*Buf.TRingBuffer, StartIdx.i, Length.i, Array TargetArray.d(1))
  ; ============================================================================
  ; NAME: ReadBlock
  ; DESC: High-speed extraction of a linear block using optimized CopyMemory.
  ;       Handles circular wrap-around with maximum 2 memory block operations.
  ; ============================================================================
    Protected ActualLength.i = Length
    Protected CurrIdx.i = StartIdx
    Protected FirstBlockCnt.i, SecondBlockCnt.i
    Protected SizeOfDouble.i = SizeOf(Double) ; 8 Bytes
    
    If Not (*Buf And TargetArray() And Length > 0 And *Buf\Size > 0)
      ProcedureReturn 0
    EndIf
    
    ; 1. Handle partially filled buffer dynamically (No delay at startup!)
    If Not *Buf\IsFull
      If *Buf\WriteIdx = 0
        ProcedureReturn 0 ; Completely empty
      EndIf
      
      If StartIdx >= *Buf\WriteIdx Or StartIdx < 0
        CurrIdx = 0
      EndIf
      
      Protected Available.i = *Buf\WriteIdx - CurrIdx
      If ActualLength > Available
        ActualLength = Available
      EndIf
    EndIf
    
    ; Safe boundaries for circular math
    If CurrIdx < 0 : CurrIdx = 0 : EndIf
    CurrIdx = CurrIdx % *Buf\Size
    
    ; 2. Safely re-dimension the target array to match exact sample counts [INDEX]
    ReDim TargetArray(ActualLength - 1)
    
    ; 3. High-Speed Copy Logic using CopyMemory
    ; Check if the requested block extends past the linear end of the ring array
    If (CurrIdx + ActualLength) <= *Buf\Size
      ; Scenario A: The whole block fits into the buffer in one single line!
      CopyMemory(@*Buf\Buf(CurrIdx), @TargetArray(0), ActualLength * SizeOf(Double))
    Else
      ; Scenario B: Block crosses the boundary. We need exactly 2 high-speed copies.
      
      ; Calculate how many samples are left until the hard absolute end of the array
      FirstBlockCnt = *Buf\Size - CurrIdx
      
      ; Calculate how many samples wrap around to start from index 0
      SecondBlockCnt = ActualLength - FirstBlockCnt
      
      ; Copy 1st part: From Current Position to the very end of the array
      CopyMemory(@*Buf\Buf(CurrIdx), @TargetArray(0), FirstBlockCnt * SizeOfDouble)
      
      ; Copy 2nd part: From Index 0 to the remaining target slots
      CopyMemory(@*Buf\Buf(0), @TargetArray(FirstBlockCnt), SecondBlockCnt * SizeOfDouble)
    EndIf
    
    ProcedureReturn ActualLength ; Return the absolute precise number of valid elements to plot
  EndProcedure

  Procedure.i GetWriteIndex(*Buf.TRingBuffer)
    If *Buf : ProcedureReturn *Buf\WriteIdx : EndIf
    ProcedureReturn 0
  EndProcedure
  
  Procedure.i IsBufferFull(*Buf.TRingBuffer)
    If *Buf : ProcedureReturn *Buf\IsFull : EndIf
    ProcedureReturn #False
  EndProcedure

EndModule

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 28
; Folding = --
; DPIAware
; CPU = 5