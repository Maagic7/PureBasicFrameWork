; ===========================================================================
;  FILE: PbFw_Module_SlotMap.pb
;  NAME: Module Slot Map Engine (SMAP::)
;  DESC: High-performance generational index mapping data structure.
;  DESC: Bridges the gap between stable tracking handles and gapless arrays.
;  DESC: Leverages 1-based stable handles protecting against null-token values.
;  DESC: Supports dynamic, seamless Live Hot-Swapping between performance modes.
;  DESC: Features an In-Place dual-hierarchy layout (#SMAP_SPARSE vs #SMAP_DENSE_SLOT).
;  DESC: Provides Zero-Allocation In-Place scattering and forward compaction.
;  DESC: Features Zero-Copy Virtual Sorting directly within CPU L1/L2 Cache lines.
;  DESC: Features Mask-Free Virtual Filtering via dual-anchor index compaction.
;  DESC: Optimized for direct OpenGL/VBO vector streaming and fast UI Grids.
;  SOURCES:  
;     AI Collaborator:
;      - Architectural mapping and data-oriented memory design strategy
;      - 1-based indexing refactoring for robust null-handle safety
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; COAUTHOR :  AI Assistant
; DATE     :  2026/10/23
; VERSION  :  0.6 Verified Developer Preview (pretested ok)
; COMPILER :  PureBasic 6.0 and higher (ASM and C-Backend )
; OS       :  All (Windows, Linux, MacOS)
; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
;  2026/11/01 S.Maag fixed hotswap to keep layout compact in ConvertToSpars
;  2026/10/25 S.Maag solved bugs! Added sort and filter functions
;}
;{ TODO!
;  - Upgrade SortDenseByCallback for a CustomSort
;  - Implement optional Mutex locking wrapper for background thread stability (Thread-Safety).

;}

; ===========================================================================
;                            ARCHITECTURE NOTES: 
; ===========================================================================
;{ 
; ----------------------------------------------------------------------
;               THE POWER OF CONTIGUOUS AoS ARRAYS FOR SIMD & GPU
; ----------------------------------------------------------------------
; Modern 3D graphics engines and calculation macros do not fail because of CPU 
; clock speeds; they fail because they are waiting for data from the system RAM. 
; This data structure uses a dense AoS (Array of Structures) layout for '\pts()' 
; to exploit modern CPU architecture to its absolute maximum:
;
; 1. CPU CACHE LINES & DATA LOCALITY:
;    - RAM is slow; CPU Cache (L1, L2, L3) is incredibly fast.
;    - When a CPU requests a single coordinate (e.g., '\pts(i)\x'), it never loads
;      just that single Float. The hardware always copies a full 64-Byte chunk 
;      called a "Cache Line" from the RAM into the ultra-fast L1 CPU Cache.
;    - Because our 'TVector' structure is exactly 16 Bytes wide and packed tight
;      without any gaps, one single 64-Byte Cache Line automatically pulls 4 
;      complete 4D points into the CPU cache at once!
;    - When the SSE macros process the next point, the data is already waiting 
;      inside the CPU core. This results in near-zero "Cache Misses".
;
; 2. THE HARDWARE PREFETCH MECHANISM:
;    - Modern CPUs feature an automated component called the "Hardware Prefetcher".
;    - When this prefetcher detects that your program is iterating sequentially 
;      through a flat memory block (like our dense array), it predicts the future.
;      It starts streaming upcoming vectors from the main RAM into the L2/L3 cache 
;      *before* your loop even reaches those indices.
;    - If memory were fragmented or dynamic (like pointers/linked lists), the 
;      prefetcher would fail completely, forcing the CPU to stall and waste hundreds 
;      of clock cycles waiting for each individual coordinate.
;
; 3. GPU BURST-STREAMING (Zero-Copy DMA):
;    - Graphics cards (OpenGL/Vulkan) are pure streaming monsters. They do not want
;      to read fragmented nodes via scattered loops.
;    - Because '\pts()' is a single, contiguous array of memory, we can bypass the
;      CPU completely during rendering updates. We pass the raw memory pointer 
;      directly to OpenGL using high-speed Direct Memory Access (DMA).
;    - The GPU pulls the entire geometry data block in a single, massive 
;      burst-transfer directly into the video memory (VRAM VBO).
;
; SUMMARY:
; By combining the stable, flexible 'THandle' slot architecture for management 
; with a strictly gapless, aligned AoS layout for the actual mathematics, this 
; system delivers zero-overhead lookups for the logic, while keeping the data 
; pipeline 100% ideal for hardware vector units and high-speed graphic buses.

; ----------------------------------------------------------------------
;                  WHY TO USE A DENSE SLOT MAP
; ----------------------------------------------------------------------
; In high-performance 3D graphics and CAD processing, we face two conflicting 
; structural requirements:
;
; 1. THE DATA REQ: For optimal CPU cache locality and ultra-fast SIMD/SSE stream
;    processing, geometry coordinates ('\pts()') must be kept tightly packed in 
;    memory as a contiguous, gapless array (AoS - Array of Structures).
;
; 2. THE REF REQ: External objects like lines, faces, and CAD entities need a 
;    stable, unchanging identifier (a persistent reference or Handle) to individual 
;    points. If a point is deleted, remaining references must not break or drift.
;
; THE NAIVE BREAKDOWN:
; - If we use raw indices as references, deleting a point in the middle creates 
;   a "hole". To close the hole and keep SIMD loops happy, we must shift all 
;   subsequent elements down (an expensive O(N) memory copy). This instantly 
;   invalidates all existing external index references, breaking lines and faces.
; - If we use traditional pointers, memory becomes fragmented (bad for SIMD cache), 
;   and deleting a point leaves dangerous "dangling pointers" causing crashes.
;
; THE SLOT MAP SOLUTION:
; The Slot Map bridges this architectural gap cleanly using three distinct layers:
;
; [ External Handle ] ──► [ \slots() Array ] ──► [ \revMap() & \pts() Arrays ]
;    (Stable 64-bit ID)       (Sparse Lookup)         (Dense Contiguous Data)
;
; - \pts()   : (Dense Data): Tightly packed array containing only active 4D vectors.
; - \slots() : (Sparse Table): Indirection layer acting as permanent postal boxes.
; - \revMap(): (Reverse Map): Cross-reference used to track which handle owns 
;              which index position inside the dense data block.
;
; ADVANTAGES OF THIS ARCHITECTURE:
; - DEFRAGMENTATION: When a point is deleted, we use "Swap-With-Last". We copy 
;   the absolute last vertex in '\pts()' into the vacated slot. Memory remains 
;   100% compact and sequential for the SSE calculation macros.
; - O(1) PERFORMANCE: Resolving a handle to a point index is a direct memory 
;   offset read. No hash lookups, no tree traversal, no linear searching.
; - INF-GEN ISOLATION: By separating the stable front-facing '\slots()' from 
;   the fluid back-end memory blocks, the application logic never cares about 
;   internal defragmentation shifts under the hood.

; ----------------------------------------------------------------------
;            THE GENERATIONAL FREE-LIST CHAIN (How \hNextFree works)
; ----------------------------------------------------------------------
; To achieve fast O(1) allocations and structural speed, the Slot Map utilizes
; an inline, single-linked Free-List Chain directly inside the '\slots()' array.
;
; 1. ON INITIALIZATION & POOL EXPANSION:
;    When the pool is created or expanded via '_GrowPool()', all inactive slots
;    are chained together. We repurpose the '\slots()\idx' field of each inactive
;    slot to hold the index of the *next* available slot in line:
;
;    \hNextFree ──► [Slot 0] ──► [Slot 1] ──► [Slot 2] ──► [Slot 3] ──► -1 (Tail)
;       (Head)       \idx = 1     \idx = 2     \idx = 3     \idx = -1
;
; 2. ON ALLOCATION (AddPoint):
;    - We instantly grab the slot index that '\hNextFree' is currently pointing to.
;    - We look inside that slot's '\idx' to see who is next in line.
;    - We advance '\hNextFree' to that next slot index.
;    - The popped slot is now active, and its '\idx' is overwritten to point 
;      to the real coordinate data inside the dense '\pts()' array.
;
; 3. ON DEALLOCATION (RemovePoint):
;    - When a point is deleted, its slot index becomes vacant again.
;    - We push this newly vacated slot back onto the *top* of the free-list.
;    - To do this, we set its '\idx' to point to the *current* '\hNextFree' head.
;    - Then, we update '\hNextFree' to point to this recently deleted slot index.
;    - Crucially, we also increment its '\gen' counter. This guarantees that any 
;      old 64-bit handle floating around in lines or faces will instantly fail 
;      the generation match check, effectively blocking ghost references.
;
; This mechanic completely avoids expensive loops or O(N) linear searches when 
; searching for free handles, ensuring that allocations remain a single-cycle operation.

; ==============================================================================
;}

; XIncludeFile "PbFw_Module_PX.pb"          ; PX::      Purebasic Extention Module

DeclareModule SMAP
  EnableExplicit
  
  ; ===========================================================================
  ; OPERATIONAL MODES: MEMORY LAYOUT CONFIGURATION
  ; ===========================================================================
  ; #SMAP_SPARSE: Standard Generational SlotMap Layout
  ;   - Memory Architecture: Sparse / Discontiguous (contains memory holes).
  ;   - Data Invariant: Array payload index is rigidly locked to (SlotIdx - 1).
  ;   - Performance Trait: Maximum insertion/deletion speed O(1) via free-list.
  ;   - Best Used For: High-speed file imports, rapid batch mutations.
  ;
  ; #SMAP_DENSE_SLOT: Packed Compaction Indirection Layout
  ;   - Memory Architecture: Dense / Continuous (no memory gaps).
  ;   - Data Invariant: Array payload index is fluid, managed via a Two-Stage 
  ;                     indirection hierarchy using a reverse lookup table (revMap).
  ;   - Performance Trait: Maximum sequential iteration speed (CPU cache-line friendly).
  ;   - Best Used For: Direct OpenGL/VBO graphics streaming, SIMD processing,
  ;                     lightning-fast UI Grid sorting and filtering.
  ; ===========================================================================
  #SMAP_SPARSE     = 0
  #SMAP_DENSE = 1
  
  ; for AI: Do not change this Structure it's PureBasic proofed lo level code
  Structure THandle             ; a 64 Bit Handle: lo=Index, hi=GenerationCounter
    h.q[0]                      ; virtual Union to get idx_gen as a single 64Bit Quad  
    idx.l                       ; Dense Data Array Index (or next free slot if free)
    gen.l                       ; 32-bit Generation counter
  EndStructure
  
  Structure _TSMapInternal
    hNextFree.l                 ; Head of the handle free-list chain
    hCnt.l                      ; Total active point handle count (Visible/Virtual Count)
    hPhysicalCnt.l              ; CRITICAL FIX: Tracks the real physical item count in RAM
    hMax.l                      ; Capacity limit of the handle pool
    *RawBuffer                  ; Holds the unaligned OS pointer for FreeMemory()
   
    Array slots.THandle(0)      ; Maps Handle Index -> Generational Slot Entry
    Array revMap.THandle(0)     ; Maps Dense Data Array Index -> Handle
  EndStructure
  
  ; The public Stucture for the CAD or Game Engine 
  Structure TSMap
    Mode.l                      ; #SMAP_SPARSE or #SMAP_DENSE_SLOT
    ItemByteSize.l              ; Excact size in Bytes of each Item, Recordset
    *Data                       ; DataBuffer Pointer Aligned
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
  Declare.i ConvertToSparse(*SMAP.TSMap)

  
  ; Special acceleration indicators for SIMD-Baking and OpenGL mirroring
  Declare.i GetRawDenseBuffer(*SMAP.TSMap)        ; (.i for 64-bit Address)
  Declare.l GetActiveCount(*SMAP.TSMap)
  
  ; ===========================================================================
  ;  VIRTUAL SORTING INTERFACE
  ; ===========================================================================
  ; The comparator receives two raw pointers to your structural records.
  ; It must return:
  ;   #True  -> If *ItemA should come BEFORE *ItemB (Ascending)
  ;   #False -> If the order is correct or equal
  ; ===========================================================================
  Prototype.i Proto_CompareItems(*ItemA, *ItemB)
  Declare.i SortDenseByCallback(*SMAP.TSMap, CompareFunc.Proto_CompareItems)
  
  ; ===========================================================================
  ;  VIRTUAL FILTERING INTERFACE
  ; ===========================================================================
  ; The predicate receives a raw pointer to the structural record.
  ; It must return:
  ;   #True  -> If the item MATCHES the filter criteria (Keep it visible)
  ;   #False -> If the item should be hidden
  ; ===========================================================================
  Prototype.i Proto_FilterPredicate(*Item)
  Declare.i FilterDenseByPredicate(*SMAP.TSMap, FilterFunc.Proto_FilterPredicate)
  ; ===========================================================================
  ; PUBLIC ROUTINE: Resets all virtual sorting and filtering modifications
  
  ; ===========================================================================
  ; This restores the reverse map layer back to a perfect mirror of the 
  ; physical RAM layout, removing any active sorting policies or hidden filters.
  ; ===========================================================================
  Declare.i ResetSortAndFilter(*SMAP.TSMap)

EndDeclareModule

Module SMAP
  EnableExplicit
  
  ; ===========================================================================
  ; PRIVATE ROUTINE: Resizes the internal and continuous structures when full
  ; ===========================================================================
  
  Procedure.i _GrowPool(*SMAP.TSMap)
    Protected.l NewMax
    Protected.i I, CurrentSize, NewTotalSize
    Protected *NewRawBuffer, *NewAlignedData
    Protected.i AlignBound = 64 ; 64-Byte alignment for AVX-512 & Cache-Lines
    
    If *SMAP = 0 : ProcedureReturn #False : EndIf
    
    With *SMAP
      If \_int\hMax = 0
        NewMax = 16 
      Else
        NewMax = \_int\hMax * 2 
      EndIf
      
      ; 1. Allocate a fresh, larger raw memory buffer with padding
      NewTotalSize = (NewMax * \ItemByteSize) + AlignBound
      *NewRawBuffer = AllocateMemory(NewTotalSize, #PB_Memory_NoClear)
      If *NewRawBuffer = 0 : ProcedureReturn #False : EndIf
      
      ; Calculate the new perfectly aligned data pointer
      *NewAlignedData = (*NewRawBuffer + (AlignBound - 1)) & ~(AlignBound - 1)
      
      ; 2. If old data exists, migrate it to the new aligned destination block
      If \Data And \_int\hPhysicalCnt > 0
        CurrentSize = \_int\hMax * \ItemByteSize
        CopyMemory(\Data, *NewAlignedData, CurrentSize)
        
        ; Free the old raw OS buffer safely
        FreeMemory(\_int\RawBuffer)
      EndIf
      
      ; 3. Commit new pointer states to the manager instance
      \_int\RawBuffer = *NewRawBuffer
      \Data = *NewAlignedData
      
      ; 4. Scale management structures
      ReDim \_int\slots(NewMax)
      If \Mode = #SMAP_DENSE
        ReDim \_int\revMap(NewMax)
      EndIf
      
      For I = \_int\hMax + 1 To NewMax - 1
        \_int\slots(I)\idx = I + 1
        \_int\slots(I)\gen = 1
      Next
      
      \_int\slots(NewMax)\idx = \_int\hNextFree 
      \_int\slots(NewMax)\gen = 1
      \_int\hNextFree = \_int\hMax + 1          
      \_int\hMax = NewMax
    EndWith
    
    ProcedureReturn #True
  EndProcedure

  ; ===========================================================================
  ; CONSTRUCTOR: Allocates and initializes the 1-based slot container
  ; ===========================================================================
  
  Procedure.i New(Mode.l, ItemByteSize.l, InitalItems.l = 1024)
    Protected *SMAP.TSMap
    Protected.i I, TotalSize          
    Protected.i AlignBound = 64 ; 64-Byte alignment for AVX-512 & Cache-Lines
    
    If InitalItems <= 0 : InitalItems = 16 : EndIf
    If ItemByteSize <= 0 : ProcedureReturn 0 : EndIf
    
    *SMAP = AllocateStructure(TSMap)
    If *SMAP = 0 : ProcedureReturn 0 : EndIf
    
    With *SMAP
      \Mode = Mode
      \ItemByteSize = ItemByteSize
      \_int\hMax = InitalItems
      \_int\hCnt = 0
      \_int\hPhysicalCnt = 0
      \_int\hNextFree = 1
      
      ; Calculate the safe allocation size with 64-Byte padding
      TotalSize = (InitalItems * ItemByteSize) + AlignBound
      \_int\RawBuffer = AllocateMemory(TotalSize, #PB_Memory_NoClear)
      If \_int\RawBuffer = 0
        FreeStructure(*SMAP)
        ProcedureReturn 0
      EndIf
      
      ; MATHEMATICAL ALIGNMENT TRICK: 
      ; Align the address to the next 64-byte boundary.
      ; (Address + 63) AND ~63
      \Data = (\_int\RawBuffer + (AlignBound - 1)) & ~(AlignBound - 1)
      
      Dim \_int\slots(InitalItems)
      If \Mode = #SMAP_DENSE
        Dim \_int\revMap(InitalItems)
      EndIf
      
      For I = 1 To InitalItems - 1
        \_int\slots(I)\idx = I + 1
        \_int\slots(I)\gen = 1
      Next
      \_int\slots(InitalItems)\idx = -1
      \_int\slots(InitalItems)\gen = 1
    EndWith
    
    ProcedureReturn *SMAP
  EndProcedure

  ; ===========================================================================
  ; DESTRUCTOR: Safely cleans up all allocated memory resources
  ; ===========================================================================
   
  Procedure.i Destroy(*SMAP.TSMap)
    If *SMAP = 0 : ProcedureReturn #False : EndIf
    
    With *SMAP
      ; CRITICAL FIX: We must free the original, unaligned OS memory pointer 
      ; stored in \RawBuffer. Freeing the aligned \Data pointer directly 
      ; would cause severe OS memory manager corruption or instant crashes.
      If \_int\RawBuffer
        FreeMemory(\_int\RawBuffer)
      EndIf
      
      ; Clear structure internals and the parent instance container safely
      FreeStructure(*SMAP)
    EndWith
    
    ProcedureReturn #True
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Basic functions
  ;- ----------------------------------------------------------------------

  ; ===========================================================================
  ; PUBLIC ROUTINE: Inserts a new record into the memory storage layout
  ; ===========================================================================
  ; HIERARCHY DOCUMENTATION: TARGET INDEX GENERATION
  ; ===========================================================================
  ; This function behaves differently depending on the active storage mode, 
  ; establishing either a direct geometric address or a compact indirect address:
  ;
  ; 1. IN SPARSE MODE (#SMAP_SPARSE):
  ;    The data memory index is rigidly bound to the popped free slot index.
  ;    -> DenseIdx = SlotIdx - 1
  ;    The item's payload is written directly to this geometric offset. This 
  ;    intentionally leaves holes in memory if prior elements were deleted.
  ;
  ; 2. IN DENSE MODE (#SMAP_DENSE_SLOT):
  ;    The data memory index is decoupled from the slot. Elements are always 
  ;    appended continuously at the very end of the packed array.
  ;    -> DenseIdx = \_int\hCnt
  ;    To support this two-stage indirection, the multi-map bridge is updated:
  ;    - \_int\slots(SlotIdx)\idx = DenseIdx      (Forward Indirection)
  ;    - \_int\revMap(DenseIdx)\idx = SlotIdx     (Reverse Indirection)
  ; ===========================================================================
  Procedure.q InsertItem(*SMAP.TSMap, *DataAddress)
    Protected.l SlotIdx, DenseIdx
    Protected *TargetAddress
    Protected ReturnHandle.THandle
    
    If *SMAP = 0 Or *DataAddress = 0 : ProcedureReturn 0 : EndIf
    
    If *SMAP\_int\hNextFree = -1
      If _GrowPool(*SMAP) = #False : ProcedureReturn 0 : EndIf
    EndIf
    
    ; Poppe den freien Slot
    SlotIdx = *SMAP\_int\hNextFree
    *SMAP\_int\hNextFree = *SMAP\_int\slots(SlotIdx)\idx
    
    ; HYBRID-FIX: Da Daten bei ConvertToSparse KOMPAKT bleiben,
    ; werden neue Daten in BEIDEN Modi einfach hinten an hPhysicalCnt angehängt!
    DenseIdx = *SMAP\_int\hPhysicalCnt
    
    *TargetAddress = *SMAP\Data + (DenseIdx * *SMAP\ItemByteSize)
    CopyMemory(*DataAddress, *TargetAddress, *SMAP\ItemByteSize)
    
    ; Der Slot zeigt immer auf den echten, kompakten RAM-Index
    *SMAP\_int\slots(SlotIdx)\idx = DenseIdx
    
    ; Wenn wir im Dense-Modus sind, führen wir die revMap nach
    If *SMAP\Mode = #SMAP_DENSE
      *SMAP\_int\revMap(DenseIdx)\idx = SlotIdx
      *SMAP\_int\revMap(DenseIdx)\gen = *SMAP\_int\slots(SlotIdx)\gen
    EndIf
    
    *SMAP\_int\hCnt + 1
    *SMAP\_int\hPhysicalCnt + 1    
    
    ReturnHandle\idx = SlotIdx
    ReturnHandle\gen = *SMAP\_int\slots(SlotIdx)\gen
    ProcedureReturn ReturnHandle\h
  EndProcedure
  
  ; ===========================================================================
  ; PUBLIC ROUTINE: Removes items and handles layout-specific memory cleanup
  ; ===========================================================================
  ; HIERARCHY DOCUMENTATION: MEMORY LEAK & OVERLAP PROTECTION
  ; ===========================================================================
  ; Deletion must respect the structural rules of the active hierarchy mode:
  ;
  ; 1. IN SPARSE MODE (#SMAP_SPARSE):
  ;    No data shifting occurs. The element is simply invalidated by advancing
  ;    the generational counter (\gen + 1). The slot's index memory (\idx) 
  ;    is repurposed to point to the next free head, linking it back into the
  ;    1-based O(1) Free-List allocation chain.
  ;
  ; 2. IN DENSE MODE (#SMAP_DENSE_SLOT):
  ;    To maintain a gapless data layout for GPU/SIMD streaming without holes,
  ;    the "Swap-With-Last" paradigm is initiated:
  ;    - The dead slot's raw payload data is overwritten by the very last active 
  ;      element in the continuous array (\_int\hCnt - 1).
  ;    - The Two-Stage hierarchy allows us to locate the moved item's slot via 
  ;      the \revMap, instantly updating its forward pointer to the new gap index.
  ;    - The old dangling trailing entry in the \revMap is explicitly cleared.
  ; ===========================================================================
  Procedure.i DeleteItem(*SMAP.TSMap, hItem.q)
    Protected.l SlotIdx, DenseIdxToDelete, LastDenseIdx, MovedSlotIdx
    Protected *SourceAddress, *TargetAddress
    Protected Handle.THandle
    
    If *SMAP = 0 Or hItem = 0 : ProcedureReturn #False : EndIf
    
    Handle\h = hItem
    SlotIdx = Handle\idx ; Directly use the 1-based index
    
    ; Prevent lookups into index 0 or out of allocated bounds
    If SlotIdx <= 0 Or SlotIdx > *SMAP\_int\hMax : ProcedureReturn #False : EndIf
    If *SMAP\_int\slots(SlotIdx)\gen <> Handle\gen : ProcedureReturn #False : EndIf
    
    DenseIdxToDelete = *SMAP\_int\slots(SlotIdx)\idx
    
    If *SMAP\Mode = #SMAP_DENSE
      ; In DENSE mode, hCnt matches the active count and the physical array boundary
      LastDenseIdx = *SMAP\_int\hCnt - 1
      
      If DenseIdxToDelete < LastDenseIdx
        ; Swap-With-Last memory transfer
        *TargetAddress = *SMAP\Data + (DenseIdxToDelete * *SMAP\ItemByteSize)
        *SourceAddress = *SMAP\Data + (LastDenseIdx * *SMAP\ItemByteSize)
        CopyMemory(*SourceAddress, *TargetAddress, *SMAP\ItemByteSize)
        
        ; Update slot indices for the moved item
        MovedSlotIdx = *SMAP\_int\revMap(LastDenseIdx)\idx
        *SMAP\_int\slots(MovedSlotIdx)\idx = DenseIdxToDelete
        *SMAP\_int\revMap(DenseIdxToDelete) = *SMAP\_int\revMap(LastDenseIdx)
      EndIf
      
      ; Explicitly clear the stale last element in the reverse map
      *SMAP\_int\revMap(LastDenseIdx)\idx = 0
      *SMAP\_int\revMap(LastDenseIdx)\gen = 0
    Else
      ; Optional: Clear memory slot for cleanliness in sparse mode
      *TargetAddress = *SMAP\Data + (DenseIdxToDelete * *SMAP\ItemByteSize)
      FillMemory(*TargetAddress, *SMAP\ItemByteSize, 0)
    EndIf
    
    ; Return the slot to the free-list and increment generation to invalidate old handles
    *SMAP\_int\slots(SlotIdx)\gen + 1
    *SMAP\_int\slots(SlotIdx)\idx = *SMAP\_int\hNextFree
    *SMAP\_int\hNextFree = SlotIdx
    
    ; Decrement the active item counter (tracks pure element count for both modes)
    *SMAP\_int\hCnt - 1
    ProcedureReturn #True
  EndProcedure

  ; ===========================================================================
  ; PUBLIC ROUTINE: Delivers the RAW memory data address of a specific item
  ; ===========================================================================
  Procedure.i GetItemPtr(*SMAP.TSMap, hItem.q)
    Protected.l SlotIdx, DenseIdx
    Protected Handle.THandle
    
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
    Protected.l SlotIdx
    Protected Handle.THandle
    
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
    Protected.l SlotIdx, DenseIdx
    Protected Handle.THandle
    
    If *SMAP = 0 Or hItem = 0 : ProcedureReturn #False : EndIf
    
    Handle\h = hItem
    SlotIdx = Handle\idx
    
    With *SMAP
      If SlotIdx <= 0 Or SlotIdx > \_int\hMax : ProcedureReturn #False : EndIf
      If \_int\slots(SlotIdx)\gen <> Handle\gen : ProcedureReturn #False : EndIf
      
      DenseIdx = \_int\slots(SlotIdx)\idx
      
      If \Mode = #SMAP_DENSE
        If DenseIdx >= 0 And DenseIdx < \_int\hCnt
          If \_int\revMap(DenseIdx)\idx = SlotIdx
            ProcedureReturn #True
          EndIf
        EndIf
      Else
        ; HYBRID-SPARSE: Akzeptiert den kompakten RAM-Index [0..hPhysicalCnt-1]
        If DenseIdx >= 0 And DenseIdx < \_int\hPhysicalCnt
          ProcedureReturn #True
        EndIf
      EndIf
    EndWith
    ProcedureReturn #False
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Sparse Dense converting
  ;- ----------------------------------------------------------------------
 
  ; ===========================================================================
  ; PUBLIC ROUTINE: Converts a standard sparse map into a dense contiguous layout
  ; ===========================================================================
  Procedure.i ConvertToDense(*SMAP.TSMap, Callback.Proto_OnItemMoved = 0)
    Protected.i I
    Protected.l SlotIdx, CurrentDenseIdx, OldDenseIdx
    Protected *BaseBuffer, *Source, *Target
    Protected TmpHandle.THandle
     
    ; Boundary protection check: Only convert standard maps that aren't already dense
    If *SMAP = 0 Or *SMAP\Mode = #SMAP_DENSE : ProcedureReturn #False : EndIf
    
    With *SMAP
      ; 1. Allocate the revMap array which is mandatory for DENSE mode
      Dim \_int\revMap(\_int\hMax)
      
      ; Allocate a temporary map to flag slots that are currently inside the free-list
      Protected Dim IsFreeSlot.b(\_int\hMax)
      
      ; Traverse the free-list chain once to mark all inactive slots
      Protected NextFree.l = \_int\hNextFree
      While NextFree >= 1 And NextFree <= \_int\hMax
        IsFreeSlot(NextFree) = #True
        NextFree = \_int\slots(NextFree)\idx ; Follow the free-list chain pointer
      Wend
      
      *BaseBuffer = \Data
      
      ; 2. Linear scan through the sparse slot array to compact data
      For SlotIdx = 1 To \_int\hMax
        
        ; CRITICAL FIX: A slot is active if and only if it is NOT marked as free
        If IsFreeSlot(SlotIdx) = #False
          
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
            TmpHandle\idx = SlotIdx
            TmpHandle\gen = \_int\slots(SlotIdx)\gen
            Callback(TmpHandle\h, CurrentDenseIdx)
          EndIf
          
          CurrentDenseIdx + 1
        EndIf
      Next
      
      ; 4. Re-align the internal tracking counter and switch mode flags
      \_int\hCnt = CurrentDenseIdx
      \Mode = #SMAP_DENSE
      
      ; ----------------------------------------------------------------------
      ; CRITICAL HYBRID INVARIANT RESET
      ; ----------------------------------------------------------------------
      ; Synchronizes the global physical RAM counter with the result of the 
      ; dense forward compaction pass. This prevents subsequent insertions in 
      ; sparse-compact mode from appending new vectors behind stale, closed 
      ; memory gaps. Guarantees 100% gapless cache-locality by forcing O(1) 
      ; appends directly at the true physical end of the compact data block.
      ; ----------------------------------------------------------------------
       \_int\hPhysicalCnt = CurrentDenseIdx
    EndWith
    
    ProcedureReturn #True
  EndProcedure
  
  ; ===========================================================================
  ; PUBLIC ROUTINE: Converts a dense map back to sparse mode, restoring RAM geometry
  ; ===========================================================================
  ; ARCHITECTURAL DOCUMENTATION: THE TWO-STAGE HIERARCHY SWITCH
  ; ===========================================================================
  ; This function orchestrates the structural layout morphing from a 
  ; Two-Stage Indirection (DENSE) back to a Direct Single-Stage Mapping (SPARSE).
  ;
  ; 1. THE DENSE LAYOUT (Two-Stage Hierarchy):
  ;    - Handle Token (Immutable) -> Points to a fixed 1-based SlotIdx.
  ;    - Slot Matrix (_int\slots(SlotIdx)\idx) -> Points to a variable DenseIdx.
  ;    - Raw Data Buffer (\Data) -> Densely packed, gapless memory [0..hCnt-1].
  ;    - Reverse Map (_int\revMap(DenseIdx)) -> Points back to the SlotIdx.
  ;    * Memory is packed via Swap-With-Last. Slot indices fluctuate dynamically.
  ;
  ; 2. THE SPARSE LAYOUT (Single-Stage Hierarchy):
  ;    - Handle Token (Immutable) -> Points to a fixed 1-based SlotIdx.
  ;    - Raw Data Buffer (\Data) -> Scattered memory containing physical holes.
  ;    * CRITICAL INVARIANT: The memory index MUST strictly couple geometrically 
  ;      to the active slot: TargetSparseIdx = (SlotIdx - 1).
  ;
  ; 3. THE RESOLUTION (In-Place Reverse Scattering):
  ;    To break the Dense hierarchy without allocating new system memory, this 
  ;    routine loops BACKWARD (from hMax down to 1). Processing items in reverse 
  ;    guarantees that we safely read compressed source bytes from the front 
  ;    and scatter them to expanded target locations in the back without 
  ;    overwriting unread active data payloads (Zero-Allocation In-Place Compaction).
  ; ===========================================================================


  Procedure.i ConvertToSparse(*SMAP.TSMap)
    Protected.l DenseIdx, SlotIdx
     
    If *SMAP = 0 Or *SMAP\Mode = #SMAP_SPARSE : ProcedureReturn #False : EndIf
    
    With *SMAP
      ; OPTIMIERUNG: Keine Daten-Bytes verschieben! 
      ; Wir schreiben die kompakten Indizes zurück in die Slots.
      For DenseIdx = 0 To \_int\hCnt - 1
        SlotIdx = \_int\revMap(DenseIdx)\idx
        If SlotIdx > 0
          ; Der Slot behält seinen kompakten Index bei!
          \_int\slots(SlotIdx)\idx = DenseIdx
        EndIf
      Next
      
      ; revMap sicher löschen für reinen Sparse-Betrieb
      FreeArray(\_int\revMap())
      Dim \_int\revMap(0)
      
      \Mode = #SMAP_SPARSE
      ; hCnt repräsentiert jetzt die echten aktiven Elemente im Sparse-Modus
      \_int\hCnt = \_int\hPhysicalCnt
    EndWith
    
    ProcedureReturn #True
  EndProcedure

   
  ;- ----------------------------------------------------------------------
  ;- Sort and Filter Functions
  ;- ----------------------------------------------------------------------
 
  ; Private helper: Swaps two reverse-map slots in-place
  Procedure _SortSwapReverseMap(*SMAP.TSMap, IndexA.l, IndexB.l)
    Protected Tmp.THandle
    Tmp = *SMAP\_int\revMap(IndexA)
    *SMAP\_int\revMap(IndexA) = *SMAP\_int\revMap(IndexB)
    *SMAP\_int\revMap(IndexB) = Tmp
  EndProcedure

  ; ===========================================================================
  ; PRIVATE ROUTINE: Internal recursive QuickSort engine for the reverse map
  ; ===========================================================================
  Procedure _QuickSortReverseMap(*SMAP.TSMap, Low.l, High.l, CompareFunc.Proto_CompareItems)
    Protected.i I, J
    Protected.l PivotIdx,SlotIdxPivot, SlotIdxI, SlotIdxJ
    Protected *ItemPivot, *ItemI, *ItemJ
    
    If Low < High
      ; Select the middle element as the Pivot strategy to safeguard against pre-sorted worst-cases
      PivotIdx = Low + (High - Low) / 2
      SlotIdxPivot = *SMAP\_int\revMap(PivotIdx)\idx
      *ItemPivot = *SMAP\Data + (*SMAP\_int\slots(SlotIdxPivot)\idx * *SMAP\ItemByteSize)
      
      I = Low
      J = High
      
      Repeat
        ; Resolve and advance from the left boundary
        SlotIdxI = *SMAP\_int\revMap(I)\idx
        *ItemI = *SMAP\Data + (*SMAP\_int\slots(SlotIdxI)\idx * *SMAP\ItemByteSize)
        While CompareFunc(*ItemI, *ItemPivot) = #True
          I + 1
          SlotIdxI = *SMAP\_int\revMap(I)\idx
          *ItemI = *SMAP\Data + (*SMAP\_int\slots(SlotIdxI)\idx * *SMAP\ItemByteSize)
        Wend
        
        ; Resolve and retreat from the right boundary
        SlotIdxJ = *SMAP\_int\revMap(J)\idx
        *ItemJ = *SMAP\Data + (*SMAP\_int\slots(SlotIdxJ)\idx * *SMAP\ItemByteSize)
        While CompareFunc(*ItemPivot, *ItemJ) = #True
          J - 1
          SlotIdxJ = *SMAP\_int\revMap(J)\idx
          *ItemJ = *SMAP\Data + (*SMAP\_int\slots(SlotIdxJ)\idx * *SMAP\ItemByteSize)
        Wend
        
        ; If indices haven't crossed, rotate pointers in the lightweight index table
        If I <= J
          _SortSwapReverseMap(*SMAP, I, J)
          I + 1
          J - 1
        EndIf
      Until I > J
      
      ; Recursively slice and conquer the remaining array partitions
      If Low < J  : _QuickSortReverseMap(*SMAP, Low, J, CompareFunc)  : EndIf
      If I < High : _QuickSortReverseMap(*SMAP, I, High, CompareFunc) : EndIf
    EndIf
  EndProcedure

  ; ===========================================================================
  ; PUBLIC ROUTINE: Sorts the virtual layout order via an O(N log N) QuickSort
  ; ===========================================================================
  Procedure.i SortDenseByCallback(*SMAP.TSMap, CompareFunc.Proto_CompareItems)
    Protected.l ActiveCount
    
    ; Protection shield: Sorting is exclusive to dense, populated indirection layers
    If *SMAP = 0 Or *SMAP\Mode = #SMAP_SPARSE Or CompareFunc = 0 : ProcedureReturn #False : EndIf
    
    ActiveCount = *SMAP\_int\hCnt
    If ActiveCount <= 1 : ProcedureReturn #True : EndIf ; Nothing to sort
    
    ; Fire up the high-performance cache-friendly quicksort engine
    _QuickSortReverseMap(*SMAP, 0, ActiveCount - 1, CompareFunc)
    
    ProcedureReturn #True
  EndProcedure
  
  ; ===========================================================================
  ; PUBLIC ROUTINE: Resets all virtual sorting and filtering modifications
  ; ===========================================================================
  ; This restores the reverse map layer back to a perfect mirror of the 
  ; physical RAM layout, removing any active sorting policies or hidden filters.
  ; ===========================================================================
  Procedure.i ResetSortAndFilter(*SMAP.TSMap)
    Protected.l DenseIdx, SlotIdx
    
    ; Protection shield: Only applicable in dense mode where revMap exists
    If *SMAP = 0 Or *SMAP\Mode = #SMAP_SPARSE : ProcedureReturn #False : EndIf
    
    With *SMAP
      ; 1. Re-align the reverse map to mirror the exact physical indices stored in the slots
      For SlotIdx = 1 To \_int\hMax
        
        DenseIdx = \_int\slots(SlotIdx)\idx
        
        ; If the index points inside the historically allocated boundaries, restore the link
        If DenseIdx >= 0 And DenseIdx < \_int\hMax
          \_int\revMap(DenseIdx)\idx = SlotIdx
          \_int\revMap(DenseIdx)\gen = \_int\slots(SlotIdx)\gen
        EndIf
      Next 
      
      ; 2. CRITICAL FIX: Restore hCnt to reflect the true physical number of elements in RAM
      \_int\hCnt = \_int\hPhysicalCnt
    EndWith
    
    ProcedureReturn #True
  EndProcedure  
  
  ; ===========================================================================
  ; PUBLIC ROUTINE: Filters the virtual layout visibility without moving RAM bytes
  ; ===========================================================================
  Procedure.i FilterDenseByPredicate(*SMAP.TSMap, FilterFunc.Proto_FilterPredicate)
    Protected.l SlotIdx, DenseIdx, MatchCount
    Protected *Item
    
    ; Protection shield: Filtering is exclusive to dense mode
    If *SMAP = 0 Or *SMAP\Mode = #SMAP_SPARSE Or FilterFunc = 0 : ProcedureReturn #False : EndIf
    
    With *SMAP
      ; 1. First, reset the revMap to full physical state to ensure we scan everything
      ; We temporarily use the maximum capacity limit to rebuild the scan baseline
      Dim \_int\revMap(\_int\hMax)
      
      ; Re-align revMap to baseline entries from slots before filtering
      For SlotIdx = 1 To \_int\hMax
        DenseIdx = \_int\slots(SlotIdx)\idx
        If DenseIdx >= 0 And DenseIdx < \_int\hMax ; Look at all historically mapped indices
          ; We temporarily store them linearly in revMap to filter them
          \_int\revMap(DenseIdx)\idx = SlotIdx
          \_int\revMap(DenseIdx)\gen = \_int\slots(SlotIdx)\gen
        EndIf
      Next
      
      ; 2. Scan through all items and compress the revMap in-place with matching hits
      ; We only look up to the original active item count before this filter run
      Protected OriginalCount.l = \_int\hCnt
      
      For DenseIdx = 0 To OriginalCount - 1
        SlotIdx = \_int\revMap(DenseIdx)\idx
        
        If SlotIdx > 0
          ; Fetch the concrete physical data pointer out of the unsorted buffer
          *Item = \Data + (\_int\slots(SlotIdx)\idx * \ItemByteSize)
          
          ; Execute custom client filtering policy via user predicate
          If FilterFunc(*Item) = #True
            ; Compress matching slots to the front of the revMap array
            \_int\revMap(MatchCount) = \_int\revMap(DenseIdx)
            MatchCount + 1
          EndIf
        EndIf
      Next
      
      ; 3. Explicitly clear stale trailing slots in the reverse map
      For DenseIdx = MatchCount To OriginalCount - 1
        \_int\revMap(DenseIdx)\idx = 0
        \_int\revMap(DenseIdx)\gen = 0
      Next
      
      ; 4. Update the active tracking counter to reflect only the visible subset
      \_int\hCnt = MatchCount
    EndWith
    
    ProcedureReturn #True
  EndProcedure
EndModule

;- ----------------------------------------------------------------------
;- TestCode
;- ----------------------------------------------------------------------

CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  ; ===========================================================================
  ; CAD HARDWARE TESTS: ISOLATED WORK ENVIRONMENT
  ; ===========================================================================
  
  Structure TVector3D  ; 32-Byte aligned for future 256-Bit AVX steps
    x.d
    y.d
    z.d
    w.d
  EndStructure

  Structure pPointsBuffer
    pt.TVector3D[0]             
  EndStructure

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
    Protected idx.l, active.l, I.i
    Protected tmpPt.TVector3D
    Protected txt$
    Protected.q hPt1, hPt2, hPt3
   
    PrintN("==================================================================")
    PrintN("          TEST 1: PURE DENSE LIVE MANIPULATION & SWAP             ")
    PrintN("==================================================================")
    
    PrintN("[SMap] Creating container directly in DENSE mode...")
    *PointsMap = SMAP::New(SMAP::#SMAP_DENSE, SizeOf(TVector3D), 1024)
    If *PointsMap = 0 : PrintN("[Error] Failed allocation!") : ProcedureReturn #False : EndIf
    
    PrintN("[CAD] Inserting 3 points directly into Dense RAM...")
    tmpPt\x = 10.0 : tmpPt\y = 20.0 : tmpPt\z = 30.0 : tmpPt\w = 1.0
    hPt1 = SMAP::InsertItem(*PointsMap, @tmpPt)
    tmpPt\x = 40.0 : tmpPt\y = 50.0 : tmpPt\z = 60.0 : tmpPt\w = 1.0
    hPt2 = SMAP::InsertItem(*PointsMap, @tmpPt)
    tmpPt\x = 70.0 : tmpPt\y = 80.0 : tmpPt\z = 90.0 : tmpPt\w = 1.0
    hPt3 = SMAP::InsertItem(*PointsMap, @tmpPt)
    
    *CAD = SMAP::GetRawDenseBuffer(*PointsMap)
    idx = SMAP::GetItemIndex(*PointsMap, hPt1)
    If idx <> -1
      *CAD\pt[idx]\x = 999.99 
      PrintN("-> Verification: Pt1\x direct write value: " + StrD(*CAD\pt[idx]\x))
    EndIf
    
    PrintN("[SMap] Deleting Point 2 (Triggers runtime Swap-With-Last)...")
    SMAP::DeleteItem(*PointsMap, hPt2)
    
    PrintN("[Verification] Scanning dense storage from index 0:")
    *CAD   = SMAP::GetRawDenseBuffer(*PointsMap)
    active = SMAP::GetActiveCount(*PointsMap)
    For I = 0 To active - 1
      txt$ = "  -> RAM Slot [" + Str(I) + "]: X=" + StrD(*CAD\pt[I]\x) + " | Y=" + StrD(*CAD\pt[I]\y)
      PrintN(txt$)
    Next
    
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
    Protected idx.l, active.l, I.i
    Protected tmpPt.TVector3D
    Protected txt$
    Protected.q hPt1, hPt2, hPt3, hPt4, hPt5
    
    PrintN("==================================================================")
    PrintN("          TEST 2: SPARSE IMPORT TO DENSE BAKING CONVERSION        ")
    PrintN("==================================================================")
    
    *PointsMap = SMAP::New(SMAP::#SMAP_SPARSE, SizeOf(TVector3D), 1024)
    If *PointsMap = 0 : PrintN("[Error] Failed allocation!") : ProcedureReturn #False : EndIf
    
    PrintN("[CAD] Importing 5 points into sparse index slots...")
    tmpPt\x = 10.0 : tmpPt\y = 10.0 : tmpPt\z = 0.0 : tmpPt\w = 1.0
    hPt1 = SMAP::InsertItem(*PointsMap, @tmpPt)
    tmpPt\x = 20.0 : tmpPt\y = 20.0 : tmpPt\z = 0.0 : tmpPt\w = 1.0
    hPt2 = SMAP::InsertItem(*PointsMap, @tmpPt)
    tmpPt\x = 30.0 : tmpPt\y = 30.0 : tmpPt\z = 0.0 : tmpPt\w = 1.0
    hPt3 = SMAP::InsertItem(*PointsMap, @tmpPt)
    tmpPt\x = 40.0 : tmpPt\y = 40.0 : tmpPt\z = 0.0 : tmpPt\w = 1.0
    hPt4 = SMAP::InsertItem(*PointsMap, @tmpPt)
    tmpPt\x = 50.0 : tmpPt\y = 50.0 : tmpPt\z = 0.0 : tmpPt\w = 1.0
    hPt5 = SMAP::InsertItem(*PointsMap, @tmpPt)
    
    PrintN("[CAD] Simulating duplicate cleanup (Deleting Point 2 and Point 3)...")
    SMAP::DeleteItem(*PointsMap, hPt2)
    SMAP::DeleteItem(*PointsMap, hPt3)
    
    PrintN("[SMap] Triggering 'Bake' via ConvertToDense()...")
    SMAP::ConvertToDense(*PointsMap, @CAD_OnTopologyUpdate())
    PrintN("[SMap] Conversion finished. Mode is now: #SMAP_DENSE")
    
    PrintN("[Verification] Scanning baked buffer sequentially from index 0:")
    *CAD   = SMAP::GetRawDenseBuffer(*PointsMap)
    active = SMAP::GetActiveCount(*PointsMap)
    For I = 0 To active - 1
      txt$ = "  -> Render-Slot [" + Str(I) + "]: X=" + StrD(*CAD\pt[I]\x) + " | Y=" + StrD(*CAD\pt[I]\y)
      PrintN(txt$)
    Next
    
    SMAP::Destroy(*PointsMap)
    PrintN("[Done] Test 2 cleared safely.")
    PrintN("")
    ProcedureReturn #True
  EndProcedure

  ; ===========================================================================
  ; TEST 3: DENSE TO SPARSE LIVE HOT-SWAP (The fluid workflow test)
  ; ===========================================================================
  Procedure Test_SMapSwitchToSparse()
    Protected *PointsMap.SMAP::TSMap
    Protected *CAD.pPointsBuffer
    Protected active.l, I.i
    Protected tmpPt.TVector3D
    Protected txt$
    Protected.q hPt1, hPt2, hPt3, hPtNew
    
    PrintN("==================================================================")
    PrintN("          TEST 3: DENSE TO SPARSE LIVE HOT-SWAP                   ")
    PrintN("==================================================================")
    
    *PointsMap = SMAP::New(SMAP::#SMAP_SPARSE, SizeOf(TVector3D), 1024)
    
    PrintN("[CAD] Setup baseline points in Sparse Puffer...")
    tmpPt\x = 100.0 : tmpPt\y = 100.0 : hPt1 = SMAP::InsertItem(*PointsMap, @tmpPt)
    tmpPt\x = 200.0 : tmpPt\y = 200.0 : hPt2 = SMAP::InsertItem(*PointsMap, @tmpPt)
    tmpPt\x = 300.0 : tmpPt\y = 300.0 : hPt3 = SMAP::InsertItem(*PointsMap, @tmpPt)
    
    PrintN("[CAD] Delete Point 2 (Creates a hole at Slot index 1)...")
    SMAP::DeleteItem(*PointsMap, hPt2)
    
    PrintN("[SMap] Baking container into DENSE layout for stable GPU Render-Pass...")
    SMAP::ConvertToDense(*PointsMap, @CAD_OnTopologyUpdate())
    
    ; -------------------------------------------------------------------------
    ; THE HOT-SWAP CRUX
    ; -------------------------------------------------------------------------
    PrintN("[SMap] Triggering 'SwitchToSparse' (No data bytes will be moved!)...")
    SMAP::ConvertToSparse(*PointsMap)
    
    PrintN("[Verification] Checking Handle states after hot-swapping back to Sparse:")
    PrintN("  -> Pt 1 valid? " + Str(SMAP::IsItemValid(*PointsMap, hPt1)))
    PrintN("  -> Pt 2 valid? " + Str(SMAP::IsItemValid(*PointsMap, hPt2)) + " (Should be 0 / deleted)")
    PrintN("  -> Pt 3 valid? " + Str(SMAP::IsItemValid(*PointsMap, hPt3)))
    
    PrintN("[CAD] Simulating continuous user editing: Inserting a new Point...")
    tmpPt\x = 400.0 : tmpPt\y = 400.0
    hPtNew = SMAP::InsertItem(*PointsMap, @tmpPt)
    
    PrintN("  -> New Point valid? " + Str(SMAP::IsItemValid(*PointsMap, hPtNew)))
    
    PrintN("[Verification] Scanning full buffer to check new index layout:")
    *CAD = SMAP::GetRawDenseBuffer(*PointsMap)
    
    ; We read out the locations directly via their stable handles to look into the RAM layout
    PrintN("  -> Pt 1 location in RAM: Index " + Str(SMAP::GetItemIndex(*PointsMap, hPt1)) + " | X=" + StrD(*CAD\pt[SMAP::GetItemIndex(*PointsMap, hPt1)]\x))
    PrintN("  -> Pt 3 location in RAM: Index " + Str(SMAP::GetItemIndex(*PointsMap, hPt3)) + " | X=" + StrD(*CAD\pt[SMAP::GetItemIndex(*PointsMap, hPt3)]\x))
    PrintN("  -> New Pt location in RAM: Index " + Str(SMAP::GetItemIndex(*PointsMap, hPtNew)) + " | X=" + StrD(*CAD\pt[SMAP::GetItemIndex(*PointsMap, hPtNew)]\x))
    
    SMAP::Destroy(*PointsMap)
    PrintN("[Done] Test 3 cleared safely.")
    PrintN("")
    ProcedureReturn #True
  EndProcedure
  
    ; ===========================================================================
  ; CUSTOM CLIENT COMPARATOR: Sorts 3D Vectors by X-Coordinate (Ascending)
  ; ===========================================================================
  Procedure.i CAD_CompareByX(*ItemA.TVector3D, *ItemB.TVector3D)
    If *ItemA\x < *ItemB\x
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  ; ===========================================================================
  ; TEST 4: VIRTUAL DENSE SORTING & UNSORT VIA REVMAP
  ; ===========================================================================
  Procedure Test_SMapVirtualSorting()
    Protected *PointsMap.SMAP::TSMap
    Protected *CAD.pPointsBuffer
    Protected active.l, I.i, SlotIdx.l
    Protected tmpPt.TVector3D
    Protected txt$
    Protected.q hPt1, hPt2, hPt3
    
    PrintN("==================================================================")
    PrintN("          TEST 4: VIRTUAL DENSE SORTING & UNSORT VIA REVMAP       ")
    PrintN("==================================================================")
    
    *PointsMap = SMAP::New(SMAP::#SMAP_DENSE, SizeOf(TVector3D), 1024)
    
    ; Insert elements out of order (X=300, then X=100, then X=200)
    tmpPt\x = 300.0 : hPt1 = SMAP::InsertItem(*PointsMap, @tmpPt)
    tmpPt\x = 100.0 : hPt2 = SMAP::InsertItem(*PointsMap, @tmpPt)
    tmpPt\x = 200.0 : hPt3 = SMAP::InsertItem(*PointsMap, @tmpPt)
    
    PrintN("[CAD] Initial physical memory layout (As inserted):")
    *CAD   = SMAP::GetRawDenseBuffer(*PointsMap)
    active = SMAP::GetActiveCount(*PointsMap)
    For I = 0 To active - 1
      PrintN("  -> RAM Array Slot [" + Str(I) + "]: X=" + StrD(*CAD\pt[I]\x))
    Next
    
    ; --- 1. SORTING ---
    PrintN("[SMap] Triggering 'SortDenseByCallback' (Sorting revMap by X)...")
    SMAP::SortDenseByCallback(*PointsMap, @CAD_CompareByX())
    
    PrintN("[Grid UI] Reading data sequentially while SORTED:")
    For I = 0 To active - 1
      SlotIdx = *PointsMap\_int\revMap(I)\idx
      PrintN("  -> UI Grid Row [" + Str(I) + "]: X=" + StrD(*CAD\pt[*PointsMap\_int\slots(SlotIdx)\idx]\x))
    Next
    
    ; --- 2. UNSORTING ---
    PrintN("[SMap] Triggering 'ResetVirtualSorting' (Restoring physical order)...")
    SMAP::ResetSortAndFilter(*PointsMap)
    
    PrintN("[Grid UI] Reading data sequentially after UNSORT:")
    For I = 0 To active - 1
      SlotIdx = *PointsMap\_int\revMap(I)\idx
      PrintN("  -> UI Grid Row [" + Str(I) + "]: X=" + StrD(*CAD\pt[*PointsMap\_int\slots(SlotIdx)\idx]\x))
    Next
    
    SMAP::Destroy(*PointsMap)
    PrintN("[Done] Test 4 cleared safely.")
    PrintN("")
    ProcedureReturn #True
  EndProcedure
  
  ; ===========================================================================
  ; CUSTOM CLIENT PREDICATE: Keeps items visible if X > 150.0
  ; ===========================================================================
  Procedure.i CAD_FilterXGreaterThan150(*Item.TVector3D)
    If *Item\x > 150.0
      ProcedureReturn #True ; Keep item visible
    EndIf
    ProcedureReturn #False ; Hide item
  EndProcedure

  ; ===========================================================================
  ; TEST 5: VIRTUAL DENSE FILTERING & UNFILTER VIA REVMAP
  ; ===========================================================================
  Procedure Test_SMapVirtualFiltering()
    Protected *PointsMap.SMAP::TSMap
    Protected *CAD.pPointsBuffer
    Protected active.l, I.i, SlotIdx.l
    Protected tmpPt.TVector3D
    Protected.q hPt1, hPt2, hPt3
    
    PrintN("==================================================================")
    PrintN("          TEST 5: VIRTUAL DENSE FILTERING VIA REVMAP              ")
    PrintN("==================================================================")
    
    *PointsMap = SMAP::New(SMAP::#SMAP_DENSE, SizeOf(TVector3D), 1024)
    
    ; Insert elements (X=100, X=300, X=120)
    tmpPt\x = 100.0 : hPt1 = SMAP::InsertItem(*PointsMap, @tmpPt)
    tmpPt\x = 300.0 : hPt2 = SMAP::InsertItem(*PointsMap, @tmpPt)
    tmpPt\x = 120.0 : hPt3 = SMAP::InsertItem(*PointsMap, @tmpPt)
    
    PrintN("[CAD] Initial physical memory layout (All 3 items present):")
    *CAD   = SMAP::GetRawDenseBuffer(*PointsMap)
    active = SMAP::GetActiveCount(*PointsMap)
    For I = 0 To active - 1
      PrintN("  -> RAM Array Slot [" + Str(I) + "]: X=" + StrD(*CAD\pt[I]\x))
    Next
    
    ; --- 1. APPLY FILTER ---
    PrintN("[SMap] Triggering 'FilterDenseByPredicate' (Criteria: X > 150)...")
    SMAP::FilterDenseByPredicate(*PointsMap, @CAD_FilterXGreaterThan150())
    
    PrintN("[Grid UI / OpenGL] Reading active subset while FILTERED:")
    active = SMAP::GetActiveCount(*PointsMap)
    PrintN("  -> Active count reported by SMap: " + Str(active) + " (Should be 1)")
    
    For I = 0 To active - 1
      SlotIdx = *PointsMap\_int\revMap(I)\idx
      PrintN("  -> Visible Element [" + Str(I) + "]: X=" + StrD(*CAD\pt[*PointsMap\_int\slots(SlotIdx)\idx]\x))
    Next
    
    ; --- 2. REMOVE FILTER (UNFILTER) ---
    PrintN("[SMap] Removing filter via 'ResetVirtualSorting'...")
    SMAP::ResetSortAndFilter(*PointsMap)
    
    PrintN("[Grid UI] Reading full set after clearing filter:")
    active = SMAP::GetActiveCount(*PointsMap)
    PrintN("  -> Active count reported by SMap: " + Str(active) + " (Should be 3)")
    
    For I = 0 To active - 1
      SlotIdx = *PointsMap\_int\revMap(I)\idx
      PrintN("  -> Visible Element [" + Str(I) + "]: X=" + StrD(*CAD\pt[*PointsMap\_int\slots(SlotIdx)\idx]\x))
    Next
    
    SMAP::Destroy(*PointsMap)
    PrintN("[Done] Test 5 cleared safely.")
    PrintN("")
    ProcedureReturn #True
  EndProcedure
  
   ; ===========================================================================
  ; TEST 6: COMPLETE HYBRID LIFECYCLE (PART 1 - Max 200 Lines)
  ; ===========================================================================
  Procedure Test_SMapHybridLifecycle()
    Protected *PointsMap.SMAP::TSMap
    Protected *CAD.pPointsBuffer
    Protected active.l, I.i, SlotIdx.l, DenseIdx.l
    Protected tmpPt.TVector3D
    Protected.q hPt1, hPt2, hPt3, hPt4
    Protected status$
    
    PrintN("==================================================================")
    PrintN("          TEST 6: COMPLETE HYBRID WORKFLOW LIFECYCLE             ")
    PrintN("==================================================================")
    
    ; --- STAGE 1: SPARSE INITIALIZATION & INFRASTRUCTURE ---
    *PointsMap = SMAP::New(SMAP::#SMAP_SPARSE, SizeOf(TVector3D), 1024)
    PrintN("[STAGE 1] Initializing container in SPARSE mode...")
    
    tmpPt\x = 10.0 : hPt1 = SMAP::InsertItem(*PointsMap, @tmpPt)
    tmpPt\x = 20.0 : hPt2 = SMAP::InsertItem(*PointsMap, @tmpPt)
    tmpPt\x = 30.0 : hPt3 = SMAP::InsertItem(*PointsMap, @tmpPt)
    tmpPt\x = 40.0 : hPt4 = SMAP::InsertItem(*PointsMap, @tmpPt)
    
    PrintN("  -> [RAM Scan] Initial full memory layout (0..3):")
    *CAD = SMAP::GetRawDenseBuffer(*PointsMap)
    For I = 0 To 3
      ; Überprüfung des Status für die visuelle Beurteilung am Zeilenende
      If I = 0 : status$ = " [VALID]" : EndIf
      If I = 1 : status$ = " [VALID]" : EndIf
      If I = 2 : status$ = " [VALID]" : EndIf
      If I = 3 : status$ = " [VALID]" : EndIf
      PrintN("     -> Raw RAM Array Slot [" + Str(I) + "]: X=" + StrD(*CAD\pt[I]\x) + status$)
    Next
    
    PrintN("  -> Deleting Point 2 and Point 3 to force memory holes...")
    SMAP::DeleteItem(*PointsMap, hPt2)
    SMAP::DeleteItem(*PointsMap, hPt3)
    
    PrintN("  -> [RAM Scan] Layout after deletions (Notice unchanged memory, but invalid handles):")
    For I = 0 To 3
      If I = 0 : status$ = " [VALID]" : EndIf
      If I = 1 : status$ = " [DELETED/HOLE]" : EndIf
      If I = 2 : status$ = " [DELETED/HOLE]" : EndIf
      If I = 3 : status$ = " [VALID]" : EndIf
      PrintN("     -> Raw RAM Array Slot [" + Str(I) + "]: X=" + StrD(*CAD\pt[I]\x) + status$)
    Next
    
    ; --- STAGE 2: BAKE INTO DENSE CONVERSION ---
    PrintN("[STAGE 2] Baking container into DENSE layout for GPU rendering...")
    SMAP::ConvertToDense(*PointsMap, @CAD_OnTopologyUpdate())
    
    PrintN("  -> [RAM Scan] Packed GPU buffer (Notice variables compacted to front 0..1):")
    *CAD   = SMAP::GetRawDenseBuffer(*PointsMap)
    active = SMAP::GetActiveCount(*PointsMap)
    For I = 0 To active - 1
      PrintN("     -> Raw RAM Array Slot [" + Str(I) + "]: X=" + StrD(*CAD\pt[I]\x) + " [VALID]")
    Next
    
    ; --- STAGE 3: HOT-SWAP BACK TO SPARSE & INSERT NEW POINT ---
    PrintN("[STAGE 3] Hot-Swapping back to SPARSE mode (Zero-Copy Index Remapping)...")
    SMAP::ConvertToSparse(*PointsMap)
    
    PrintN("[CAD] Simulating post-swap editing: Inserting a brand new Point (X=500)...")
    tmpPt\x = 500.0
    Protected hPtNew = SMAP::InsertItem(*PointsMap, @tmpPt)
    
    ; --- INTERNAL SLOT TABLE VERIFICATION ---
    PrintN("  -> [Slot Table Scan] Internal Slot Layout after inserting New Point (Slots 1..4):")
    For I = 1 To 4
      SlotIdx = I
      DenseIdx = *PointsMap\_int\slots(SlotIdx)\idx
      
      status$ = " [FREE/DELETED]"
      If SlotIdx = 1 Or SlotIdx = 4
        status$ = " [ACTIVE -> Points to RAM Index " + Str(DenseIdx) + "]"
      ElseIf SlotIdx = 3
        status$ = " [NEWLY RECYCLED -> Points to RAM Index " + Str(DenseIdx) + "]"
      EndIf
      
      PrintN("     -> Slot [" + Str(SlotIdx) + "]: idx=" + Str(DenseIdx) + " | gen=" + Str(*PointsMap\_int\slots(SlotIdx)\gen) + status$)
    Next
    
    ; --- STALE HANDLE GHOST PROTECTION VERIFICATION ---
    PrintN("  -> [Ghost Reference Check] Verifying that old handles to deleted slots are blocked:")
    
    ; Validate the stale handle of point 2 (Slot 3, Gen 1) against the new item (Slot 3, Gen 2)
    If SMAP::IsItemValid(*PointsMap, hPt2) = #False
      PrintN("     -> Old hPt2 (Point 2) Status: [BLOCKED / INVALID] -> Generation mismatch protection works!")
    Else
      PrintN("     -> Old hPt2 (Point 2) Status: [ERROR] -> Ghost reference allowed!")
    EndIf
    
    If SMAP::IsItemValid(*PointsMap, hPtNew) = #True
      PrintN("     -> New hPtNew (X=500) Status: [VALID] -> Slot successfully recycled with new generation.")
    EndIf
    
    ; --- FINAL VERIFICATION OF COMPACT PHYSICAL RAM ---
    PrintN("  -> [RAM Scan] Final physical layout in SPARSE COMPACT mode:")
    *CAD = SMAP::GetRawDenseBuffer(*PointsMap)
    
    Protected PhysicalLimit.l = *PointsMap\_int\hPhysicalCnt
    For I = 0 To PhysicalLimit - 1
      status$ = " [DELETED/HOLE]"
      If SMAP::IsItemValid(*PointsMap, hPt1) And SMAP::GetItemIndex(*PointsMap, hPt1) = I
        status$ = " [VALID (Pt 1)]"
      ElseIf SMAP::IsItemValid(*PointsMap, hPt4) And SMAP::GetItemIndex(*PointsMap, hPt4) = I
        status$ = " [VALID (Pt 4)]"
      ElseIf SMAP::IsItemValid(*PointsMap, hPtNew) And SMAP::GetItemIndex(*PointsMap, hPtNew) = I
        status$ = " [VALID (New Pt)]"
      EndIf
      PrintN("     -> Raw RAM Array Slot [" + Str(I) + "]: X=" + StrD(*CAD\pt[I]\x) + status$)
    Next
    
    SMAP::Destroy(*PointsMap)
    PrintN("[Done] Test 6 cleared safely.")
    PrintN("")
    ProcedureReturn #True
  EndProcedure
  
  ; ===========================================================================
  ; MAIN EXECUTION ROUTINE
  ; ===========================================================================
  OpenConsole() 
  
  Test_SMapDense()
  Test_SMapBaking()
  Test_SMapSwitchToSparse() ; Execute the brand new Hot-Swap Test
  Test_SMapVirtualSorting() 
  Test_SMapVirtualFiltering()
  Test_SMapHybridLifecycle()
  PrintN("Press ENTER to exit...")
  Input()
CompilerEndIf

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 31
; Folding = 8-----
; DPIAware
; CPU = 5
; Compiler = PureBasic 6.41 - C Backend (Windows - x64)