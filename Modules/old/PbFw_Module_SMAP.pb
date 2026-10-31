; ===========================================================================
;  FILE: PbFw_Module_SMAP.pb
;  NAME: Module Slot Map Engine (SMAP::)
;  DESC: High-performance generational index mapping data structure.
;  DESC: Bridges the gap between stable tracking handles and gapless arrays.
;  DESC: Leverages 1-based stable handles protecting against null values.
;  DESC: Supports a dynamic contiguous dense layout for SIMD and OpenGL pipelines.
;  SOURCES:  
;     AI Collaborator:
;      - Architectural mapping and data-oriented memory design strategy
;      - 1-based indexing refactoring for robust null-handle safety
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; COAUTHOR :  AI Collaborator
; DATE     :  2026/10/23
; VERSION  :  0.5 Verified Developer Preview (Syntax Error Free)
; COMPILER :  PureBasic 6.0 and higher (ASM and C-Backend )
; OS       :  All (Windows, Linux, MacOS)
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================

; XIncludeFile "PbFw_Module_PX.pb"          ; PX::      Purebasic Extention Module

DeclareModule SMAP
  EnableExplicit
  
  #SMAP_SLOT       = 0
  #SMAP_DENSE_SLOT = 1

  ; for AI: Do not change this Structure it's PureBasic proofed lo level code
  Structure THandle             ; a 64 Bit Handle: lo=Index, hi=GenerationCounter
    h.q[0]                      ; virtual Union to get idx_gen as a single 64Bit Quad  
    idx.l                       ; Dense Data Array Index (or next free slot if free)
    gen.l                       ; 32-bit Generation counter
  EndStructure
  
  ; SMap internal management Structure! Do not maipulate from outside
  Structure _TSMapInternal
    hNextFree.l                 ; Head of the handle free-list chain
    hCnt.l                      ; Total active point handle count
    hMax.l                      ; Capacity limit of the handle pool
    
    Array slots.THandle(0)      ; Maps Handle Index -> Generational Slot Entry
    Array revMap.THandle(0)     ; Maps Dense Data Array Index -> Handle
  EndStructure

 ; The public Stucture for the CAD or Game Engine 
  Structure TSMap
    Mode.l                      ; #SMAP_SLOT or #SMAP_DENSE_SLOT
    ItemByteSize.l              ; Excact size in Bytes of each Item, Recordset
    *Data                       ; DataBuffer Pointer   
    _int._TSMapInternal         ; Interna structure for Handle Mangement
  EndStructure  

  ; public API Interface
  Declare.i New(Mode.l, ItemByteSize.l, InitalItems.l = 1024)
  Declare.i Destroy(*SMAP.TSMap)

  Declare.q InsertItem(*SMAP.TSMap, *DataAddress)
  Declare.i DeleteItem(*SMAP.TSMap, hItem.q)
  Declare.i GetItemPtr(*SMAP.TSMap, hItem.q)   ; Delivers RAW DataPointer (.i für 64-Bit Adresse)
  Declare.l GetItemIndex(*SMAP.TSMap, hItem.q) ; Delivers the Array Index [0..Items]
  
  ; High-level validation check for the parent CAD program
  Declare.i IsItemValid(*SMAP.TSMap, hItem.q)

  ; --- Baking & Conversion Utilities ---
  
  ; ===========================================================================
  ;  TOPOLOGY UPDATE CALLBACK DOCUMENTATION
  ; ===========================================================================
  ; Why do we pass both the Handle and the new Dense Index to the callback?
  ;
  ; 1. THE HANDLE (hItem): Tells the parent CAD program WHICH item moved. 
  ;    The 64-bit handle itself remains completely immutable and stable.
  ;
  ; 2. THE DENSE INDEX (NewDenseIdx): Tells the parent CAD WHERE the item landed.
  ;    Graphics hardware (OpenGL) cannot process 64-bit generation handles. 
  ;    To render triangles fluently, OpenGL requires raw, contiguous array indices
  ;    inside the Element Buffer Object (EBO / Index Buffer).
  ;
  ; By delivering the new array index directly from the SMap compaction loop,
  ; the parent CAD program can synchronize its GPU index buffer in a single 
  ; O(1) pass, completely eliminating the need for expensive secondary lookups.
  ; ===========================================================================
  ; The callback informs the CAD about which Handle moved to which new Dense Index
  Prototype.i Proto_OnItemMoved(Handle.q, NewDenseIdx.l)

  ; Converts a standard sparse slot map flit-frame into a dense gapless array layout
  Declare.i ConvertToDense(*SMAP.TSMap, Callback.Proto_OnItemMoved = 0)
  
  ; Special acceleration indicators for SIMD-Baking and OpenGL mirroring
  Declare.i GetRawDenseBuffer(*SMAP.TSMap)        ; (.i for 64-bit Address)
  Declare.l GetActiveCount(*SMAP.TSMap)
EndDeclareModule

Module SMAP
  EnableExplicit
  
  ; ===========================================================================
  ; PRIVATE ROUTINE: Resizes the internal and continuous structures when full
  ; ===========================================================================
  Procedure.i _GrowPool(*SMAP.TSMap)
    Protected NewMax.l
    Protected *NewBuffer, i.l
    
    If *SMAP = 0 : ProcedureReturn #False : EndIf
    
    With *SMAP
      NewMax = \_int\hMax * 2 ; Double the capacity deterministically
      
      ; 1. Safely resize the raw data byte payload via OS memory manager
       *NewBuffer = ReAllocateMemory(\Data, NewMax * \ItemByteSize, #PB_Memory_NoClear)
      If *NewBuffer = 0 : ProcedureReturn #False : EndIf 
      
      \Data = *NewBuffer
      
      ; 2. Resize tracking arrays to NewMax to hold indices from 1 to NewMax
      ReDim \_int\slots(NewMax)
      If \Mode = #SMAP_DENSE_SLOT
        ReDim \_int\revMap(NewMax)
      EndIf
      
      ; 3. Re-link the newly created empty slots into the 1-based free-list chain
      For i = \_int\hMax + 1 To NewMax - 1
        \_int\slots(i)\idx = i + 1
        \_int\slots(i)\gen = 1
      Next i
      \_int\slots(NewMax)\idx = \_int\hNextFree ; Connect end of new chain to old free head
      \_int\hNextFree = \_int\hMax + 1          ; Set head to first newly allocated slot index (1-based)
      
      \_int\hMax = NewMax
    EndWith
    
    ProcedureReturn #True
  EndProcedure

  ; ===========================================================================
  ; CONSTRUCTOR: Allocates and initializes the 1-based slot container
  ; ===========================================================================
  Procedure.i New(Mode.l, ItemByteSize.l, InitalItems.l = 1024)
    Protected *SMAP.TSMap
    Protected i.l
    
    If ItemByteSize <= 0 Or InitalItems <= 0 : ProcedureReturn 0 : EndIf
    
    *SMAP = AllocateMemory(SizeOf(TSMap))
    If *SMAP = 0 : ProcedureReturn 0 : EndIf
    
    With *SMAP
      \Mode         = Mode
      \ItemByteSize = ItemByteSize
      
      \_int\hNextFree = 1 ; First free slot is strictly index 1
      \_int\hCnt      = 0
      \_int\hMax      = InitalItems
      
      ; Dimension to hMax to allow valid lookups from index 1 to hMax
      Dim \_int\slots(\_int\hMax)
      
      ; Slot 0 is strictly marked as invalid/dead space
      \_int\slots(0)\idx = 0
      \_int\slots(0)\gen = 0
      
      If Mode = #SMAP_DENSE_SLOT
        Dim \_int\revMap(\_int\hMax)
      EndIf
      
      ; Initialize the free-list chain using purely 1-based indexing
      For i = 1 To \_int\hMax - 1
        \_int\slots(i)\idx = i + 1
        \_int\slots(i)\gen = 1
      Next i
      \_int\slots(\_int\hMax)\idx = -1 ; End of chain indicator
      \_int\slots(\_int\hMax)\gen = 1
      
      ; Allocate continuous byte storage for raw item records directly into the any-pointer
      \Data = AllocateMemory(\_int\hMax * \ItemByteSize, #PB_Memory_NoClear)
      If \Data = 0
        FreeMemory(*SMAP)
        ProcedureReturn 0
      EndIf
    EndWith
    
    ProcedureReturn *SMAP
  EndProcedure

  ; ===========================================================================
  ; DESTRUCTOR: Safely cleans up all allocated memory resources
  ; ===========================================================================
  Procedure.i Destroy(*SMAP.TSMap)
    If *SMAP = 0 : ProcedureReturn #False : EndIf
    
    With *SMAP
      ; Free the raw data block directly held by the pointer variable
      If \Data
        FreeMemory(\Data)
      EndIf
      
      ; Free internal tracking arrays
      Dim \_int\slots(0)
      Dim \_int\revMap(0)
    EndWith
    
    FreeMemory(*SMAP)
    ProcedureReturn #True
  EndProcedure
   
  ; ===========================================================================
  ; PUBLIC ROUTINE: Inserts raw byte payloads into the data block
  ; ===========================================================================
  Procedure.q InsertItem(*SMAP.TSMap, *DataAddress)
    Protected SlotIdx.l, DenseIdx.l
    Protected *TargetAddress
    Protected ReturnHandle.THandle
    
    If *SMAP = 0 Or *DataAddress = 0 : ProcedureReturn 0 : EndIf
    
    If *SMAP\_int\hNextFree = -1
      If _GrowPool(*SMAP) = #False : ProcedureReturn 0 : EndIf
    EndIf
    
    ; Pop the next free slot index (Guaranteed to be >= 1)
    SlotIdx = *SMAP\_int\hNextFree
    *SMAP\_int\hNextFree = *SMAP\_int\slots(SlotIdx)\idx
    
    ; Dense array indexing remains 0-based for optimal layout [0..hCnt-1]
    If *SMAP\Mode = #SMAP_DENSE_SLOT
      DenseIdx = *SMAP\_int\hCnt
    Else
      DenseIdx = SlotIdx - 1 ; Maps 1-based slot to 0-based data storage index
    EndIf
    
    *TargetAddress = *SMAP\Data + (DenseIdx * *SMAP\ItemByteSize)
    
    CopyMemory(*DataAddress, *TargetAddress, *SMAP\ItemByteSize)
    
    *SMAP\_int\slots(SlotIdx)\idx = DenseIdx
    
    If *SMAP\Mode = #SMAP_DENSE_SLOT
      *SMAP\_int\revMap(DenseIdx)\idx = SlotIdx
      *SMAP\_int\revMap(DenseIdx)\gen = *SMAP\_int\slots(SlotIdx)\gen
    EndIf
    
    *SMAP\_int\hCnt + 1
    
    ; Package and return the external handle (Internal index is already 1-based)
    ReturnHandle\idx = SlotIdx
    ReturnHandle\gen = *SMAP\_int\slots(SlotIdx)\gen
    ProcedureReturn ReturnHandle\h
  EndProcedure

  ; ===========================================================================
  ; PUBLIC ROUTINE: Removes items and triggers Swap-With-Last for DENSE maps
  ; ===========================================================================
  Procedure.i DeleteItem(*SMAP.TSMap, hItem.q)
    Protected Handle.THandle
    Protected SlotIdx.l, DenseIdxToDelete.l, LastDenseIdx.l
    Protected MovedSlotIdx.l
    Protected *SourceAddress, *TargetAddress
    
    If *SMAP = 0 Or hItem = 0 : ProcedureReturn #False : EndIf
    
    Handle\h = hItem
    SlotIdx = Handle\idx ; Directly use the 1-based index
    
    ; Prevent lookups into index 0 or out of allocated bounds
    If SlotIdx <= 0 Or SlotIdx > *SMAP\_int\hMax : ProcedureReturn #False : EndIf
    If *SMAP\_int\slots(SlotIdx)\gen <> Handle\gen : ProcedureReturn #False : EndIf
    
    DenseIdxToDelete = *SMAP\_int\slots(SlotIdx)\idx
    LastDenseIdx     = *SMAP\_int\hCnt - 1
    
    If *SMAP\Mode = #SMAP_DENSE_SLOT And DenseIdxToDelete < LastDenseIdx
      *TargetAddress = *SMAP\Data + (DenseIdxToDelete * *SMAP\ItemByteSize)
      *SourceAddress = *SMAP\Data + (LastDenseIdx * *SMAP\ItemByteSize)
      
      CopyMemory(*SourceAddress, *TargetAddress, *SMAP\ItemByteSize)
      
      MovedSlotIdx = *SMAP\_int\revMap(LastDenseIdx)\idx
      *SMAP\_int\slots(MovedSlotIdx)\idx = DenseIdxToDelete
      *SMAP\_int\revMap(DenseIdxToDelete) = *SMAP\_int\revMap(LastDenseIdx)
    EndIf
    
    *SMAP\_int\slots(SlotIdx)\gen + 1
    *SMAP\_int\slots(SlotIdx)\idx = *SMAP\_int\hNextFree
    *SMAP\_int\hNextFree = SlotIdx
    
    *SMAP\_int\hCnt - 1
    ProcedureReturn #True
  EndProcedure

  ; ===========================================================================
  ; PUBLIC ROUTINE: Delivers the RAW memory data address of a specific item
  ; ===========================================================================
  Procedure.i GetItemPtr(*SMAP.TSMap, hItem.q)
    Protected Handle.THandle
    Protected SlotIdx.l, DenseIdx.l
    
    If *SMAP = 0 Or hItem = 0 : ProcedureReturn 0 : EndIf
    
    Handle\h = hItem
    SlotIdx = Handle\idx
    
    If SlotIdx <= 0 Or SlotIdx > *SMAP\_int\hMax   : ProcedureReturn 0 : EndIf
    If *SMAP\_int\slots(SlotIdx)\gen <> Handle\gen : ProcedureReturn 0 : EndIf
    
    DenseIdx = *SMAP\_int\slots(SlotIdx)\idx
    ProcedureReturn *SMAP\Data + (DenseIdx * *SMAP\ItemByteSize)
  EndProcedure

  ; ===========================================================================
  ; PUBLIC ROUTINE: Delivers the active linear array index [0..Items]
  ; ===========================================================================
  Procedure.l GetItemIndex(*SMAP.TSMap, hItem.q)
    Protected Handle.THandle
    Protected SlotIdx.l
    
    If *SMAP = 0 Or hItem = 0 : ProcedureReturn -1 : EndIf
    
    Handle\h = hItem
    SlotIdx = Handle\idx
    
    If SlotIdx <= 0 Or SlotIdx > *SMAP\_int\hMax   : ProcedureReturn -1 : EndIf
    If *SMAP\_int\slots(SlotIdx)\gen <> Handle\gen : ProcedureReturn -1 : EndIf
    
    ProcedureReturn *SMAP\_int\slots(SlotIdx)\idx
  EndProcedure

  ; ===========================================================================
  ; PUBLIC ROUTINE: Returns the base address of the gapless data buffer (DENSE)
  ; ===========================================================================
  Procedure.i GetRawDenseBuffer(*SMAP.TSMap)
    If *SMAP
      ProcedureReturn *SMAP\Data
    EndIf
    ProcedureReturn 0
  EndProcedure

  ; ===========================================================================
  ; PUBLIC ROUTINE: Returns total count of currently active item records
  ; ===========================================================================
  Procedure.l GetActiveCount(*SMAP.TSMap)
    If *SMAP
      ProcedureReturn *SMAP\_int\hCnt
    EndIf
    ProcedureReturn 0
  EndProcedure
  
    ; ===========================================================================
  ; PUBLIC ROUTINE: Validates in O(1) if a given Handle is active and correct
  ; ===========================================================================
  Procedure.i IsItemValid(*SMAP.TSMap, hItem.q)
    Protected Handle.THandle
    Protected SlotIdx.l, DenseIdx.l
    
    ; 1. Boundary & Pointer Protection Checks
    If *SMAP = 0 Or hItem = 0 : ProcedureReturn #False : EndIf
    
    Handle\h = hItem
    SlotIdx = Handle\idx
    
    With *SMAP
      ; 2. Validate array boundaries
      If SlotIdx <= 0 Or SlotIdx > \_int\hMax : ProcedureReturn #False : EndIf
      
      ; 3. Check if generation matches the handle token
      If \_int\slots(SlotIdx)\gen <> Handle\gen : ProcedureReturn #False : EndIf
      
      DenseIdx = \_int\slots(SlotIdx)\idx
      
      ; 4. Cross-check internal memory mapping to guarantee it's not a dead link
      If \Mode = #SMAP_DENSE_SLOT
        If DenseIdx >= 0 And DenseIdx < \_int\hCnt
          If \_int\revMap(DenseIdx)\idx = SlotIdx
            ProcedureReturn #True
          EndIf
        EndIf
      Else
        If DenseIdx = SlotIdx - 1
          ProcedureReturn #True
        EndIf
      EndIf
    EndWith
    
    ProcedureReturn #False
  EndProcedure

  ; ===========================================================================
  ; PUBLIC ROUTINE: Converts a standard sparse map into a dense contiguous layout
  ; ===========================================================================
  Procedure.i ConvertToDense(*SMAP.TSMap, Callback.Proto_OnItemMoved = 0)
    Protected SlotIdx.l, CurrentDenseIdx.l = 0
    Protected OldDenseIdx.l
    Protected *BaseBuffer, *Source, *Target
    Protected TmpHandle.THandle
    
    ; Boundary protection check: Only convert standard maps that aren't already dense
    If *SMAP = 0 Or *SMAP\Mode = #SMAP_DENSE_SLOT : ProcedureReturn #False : EndIf
    
    With *SMAP
      ; 1. Allocate the revMap array which is mandatory for DENSE mode
      Dim \_int\revMap(\_int\hMax)
      
      *BaseBuffer = \Data
      
      ; 2. Linear scan through the sparse slot array to compact data
      For SlotIdx = 1 To \_int\hMax
        
        ; Build a temporary internal handle to utilize our robust IsItemValid validation shield
        TmpHandle\idx = SlotIdx
        TmpHandle\gen = \_int\slots(SlotIdx)\gen
        
        If IsItemValid(*SMAP, TmpHandle\h)
          
          OldDenseIdx = \_int\slots(SlotIdx)\idx
          
          ; If the item is not already at its final destination, shift the raw bytes forward
          If OldDenseIdx <> CurrentDenseIdx
            *Source = *BaseBuffer + (OldDenseIdx * \ItemByteSize)
            *Target = *BaseBuffer + (CurrentDenseIdx * \ItemByteSize)
            CopyMemory(*Source, *Target, \ItemByteSize)
          EndIf
          
          ; Establish the new dense tracking layout
          \_int\slots(SlotIdx)\idx = CurrentDenseIdx
          \_int\revMap(CurrentDenseIdx)\idx = SlotIdx
          \_int\revMap(CurrentDenseIdx)\gen = \_int\slots(SlotIdx)\gen
          
          ; 3. Trigger the topology update callback for the parent CAD program if registered
          If Callback
            Callback(TmpHandle\h, CurrentDenseIdx)
          EndIf
          
          CurrentDenseIdx + 1
        EndIf
      Next SlotIdx
      
      ; 4. Re-align the internal tracking counter and switch mode flags
      \_int\hCnt = CurrentDenseIdx
      \Mode = #SMAP_DENSE_SLOT
    EndWith
    
    ProcedureReturn #True
  EndProcedure

EndModule

;- TestCode

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  ; ===========================================================================
  ; CAD HARDWARE TESTS: ISOLATED WORK ENVIRONMENT
  ; ===========================================================================
  
  ; Define the concrete CAD Data Structure (64-Bit Float Vector)
  Structure TVector3D  ; 32-Byte aligned for future 256-Bit AVX steps
    x.d
    y.d
    z.d
    w.d
  EndStructure

  ; Define the Structured Array Pointer for the CAD-side Direct Access
  Structure pPointsBuffer
    pt.TVector3D[0]             ; [0] declaration for infinite structural pointer mapping
  EndStructure

  ; --- CAD TOPOLOGY UPDATE CALLBACK ---
  Procedure.i CAD_OnTopologyUpdate(hPoint.q, NewDenseIdx.l)
    PrintN("  -> [Callback] Point-Handle " + Str(hPoint) + " moved to new OpenGL Vertex-Index: " + Str(NewDenseIdx))
    ProcedureReturn #True
  EndProcedure


  ; ===========================================================================
  ; TEST 1: PURE DENSE MODE LIVE MANIPULATION 
  ; ===========================================================================
  Procedure Test_SMapDense()
    Protected *PointsMap.SMAP::TSMap
    Protected *CAD.pPointsBuffer
    Protected hPt1.SMAP::THandle, hPt2.SMAP::THandle, hPt3.SMAP::THandle
    Protected idx.l, active.l, i.l
    Protected tmpPt.TVector3D
    Protected txt$
    
    PrintN("==================================================================")
    PrintN("          TEST 1: PURE DENSE LIVE MANIPULATION & SWAP             ")
    PrintN("==================================================================")
    
    ; Initialize SMap directly in DENSE mode for OpenGL/SIMD
    PrintN("[SMap] Creating container directly in DENSE mode...")
    *PointsMap = SMAP::New(SMAP::#SMAP_DENSE_SLOT, SizeOf(TVector3D), 1024)
    If *PointsMap = 0 : PrintN("[Error] Failed allocation!") : ProcedureReturn #False : EndIf
    
    PrintN("[CAD] Inserting 3 points directly into Dense RAM...")
    tmpPt\x = 10.0 : tmpPt\y = 20.0 : tmpPt\z = 30.0 : tmpPt\w = 1.0
    hPt1\h = SMAP::InsertItem(*PointsMap, @tmpPt)
    
    tmpPt\x = 40.0 : tmpPt\y = 50.0 : tmpPt\z = 60.0 : tmpPt\w = 1.0
    hPt2\h = SMAP::InsertItem(*PointsMap, @tmpPt)
    
    tmpPt\x = 70.0 : tmpPt\y = 80.0 : tmpPt\z = 90.0 : tmpPt\w = 1.0
    hPt3\h = SMAP::InsertItem(*PointsMap, @tmpPt)
    
    ; Direct Memory Modification via structured pointer
    *CAD = SMAP::GetRawDenseBuffer(*PointsMap)
    idx = SMAP::GetItemIndex(*PointsMap, hPt1\h)
    If idx <> -1
      *CAD\pt[idx]\x = 999.99 
      PrintN("-> Verification: Pt1\x direct write value: " + StrD(*CAD\pt[idx]\x))
    EndIf
    
    ; Trigger instant Swap-With-Last inside Dense Memory
    PrintN("[SMap] Deleting Point 2 (Triggers runtime Swap-With-Last)...")
    SMAP::DeleteItem(*PointsMap, hPt2\h)
    
    ; Scan memory to prove contiguity
    PrintN("[Verification] Scanning dense storage from index 0:")
    *CAD   = SMAP::GetRawDenseBuffer(*PointsMap)
    active = SMAP::GetActiveCount(*PointsMap)
    
    For i = 0 To active - 1
      txt$ = "  -> RAM Slot [" + Str(i) + "]: X=" + StrD(*CAD\pt[i]\x) + " | Y=" + StrD(*CAD\pt[i]\y)
      PrintN(txt$)
    Next i
    
    SMAP::Destroy(*PointsMap)
    PrintN("[Done] Test 1 cleared safely.")
    PrintN("")
    ProcedureReturn #True
  EndProcedure


  ; ===========================================================================
  ; TEST 2: SPARSE IMPORT TO DENSE BAKING CONVERSION (The baking test)
  ; ===========================================================================
  Procedure Test_SMapBaking()
    Protected *PointsMap.SMAP::TSMap
    Protected *CAD.pPointsBuffer
    Protected hPt1.SMAP::THandle, hPt2.SMAP::THandle, hPt3.SMAP::THandle, hPt4.SMAP::THandle
    Protected idx.l, active.l, i.l
    Protected tmpPt.TVector3D
    Protected txt$
    
    PrintN("==================================================================")
    PrintN("          TEST 2: SPARSE IMPORT TO DENSE BAKING CONVERSION        ")
    PrintN("==================================================================")
    
    ; Initialize SMap in standard SLOT mode (Optimal for fast file imports)
    PrintN("[SMap] Creating container in standard sparse SLOT mode...")
    *PointsMap = SMAP::New(SMAP::#SMAP_SLOT, SizeOf(TVector3D), 1024)
    If *PointsMap = 0 : PrintN("[Error] Failed allocation!") : ProcedureReturn #False : EndIf
    
    PrintN("[CAD] Importing 4 points into sparse index slots...")
    tmpPt\x = 10.0 : tmpPt\y = 10.0 : tmpPt\z = 0.0 : tmpPt\w = 1.0
    hPt1\h = SMAP::InsertItem(*PointsMap, @tmpPt)
    
    tmpPt\x = 20.0 : tmpPt\y = 20.0 : tmpPt\z = 0.0 : tmpPt\w = 1.0
    hPt2\h = SMAP::InsertItem(*PointsMap, @tmpPt)
    
    tmpPt\x = 30.0 : tmpPt\y = 30.0 : tmpPt\z = 0.0 : tmpPt\w = 1.0
    hPt3\h = SMAP::InsertItem(*PointsMap, @tmpPt)
    
    tmpPt\x = 40.0 : tmpPt\y = 40.0 : tmpPt\z = 0.0 : tmpPt\w = 1.0
    hPt4\h = SMAP::InsertItem(*PointsMap, @tmpPt)
    
    ; Delete items in O(1) to create holes in memory
    PrintN("[CAD] Simulating duplicate cleanup (Deleting Point 2 and Point 3)...")
    SMAP::DeleteItem(*PointsMap, hPt2\h)
    SMAP::DeleteItem(*PointsMap, hPt3\h)
    
    PrintN("[Verification] Checking Handle states in sparse memory:")
    PrintN("  -> Pt 1 valid? " + Str(SMAP::IsItemValid(*PointsMap, hPt1\h)))
    PrintN("  -> Pt 2 valid? " + Str(SMAP::IsItemValid(*PointsMap, hPt2\h)))
    PrintN("  -> Pt 3 valid? " + Str(SMAP::IsItemValid(*PointsMap, hPt3\h)))
    PrintN("  -> Pt 4 valid? " + Str(SMAP::IsItemValid(*PointsMap, hPt4\h)))
    
    ; Execute the compaction and fire the synchronization callback
    PrintN("[SMap] Triggering 'Bake' via ConvertToDense()...")
    SMAP::ConvertToDense(*PointsMap, @CAD_OnTopologyUpdate())
    
    PrintN("[SMap] Conversion finished. Mode is now: #SMAP_DENSE_SLOT")
    
    ; Scan memory blocks to prove gapless arrangement
    PrintN("[Verification] Scanning baked buffer sequentially from index 0:")
    *CAD   = SMAP::GetRawDenseBuffer(*PointsMap)
    active = SMAP::GetActiveCount(*PointsMap)
    
    For i = 0 To active - 1
      txt$ = "  -> Render-Slot [" + Str(i) + "]: X=" + StrD(*CAD\pt[i]\x) + " | Y=" + StrD(*CAD\pt[i]\y)
      PrintN(txt$)
    Next i
    
    SMAP::Destroy(*PointsMap)
    PrintN("[Done] Test 2 cleared safely.")
    PrintN("")
    ProcedureReturn #True
  EndProcedure


  ; ===========================================================================
  ; MAIN EXECUTION ROUTINE
  ; ===========================================================================
  OpenConsole() ; Fire up the native PureBasic character window
  
  ; Execute selected architecture environments
  Test_SMapDense()
  Test_SMapBaking()
  
  PrintN("Press ENTER to exit...")
  Input()
CompilerEndIf

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 30
; FirstLine = 120
; Folding = ---
; DPIAware
; CPU = 5
; Compiler = PureBasic 6.41 - C Backend (Windows - x64)