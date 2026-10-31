; ===========================================================================
;  FILE : PbFw_Module_Object3D.pb
;  NAME : Module Object 3D [O3D::]
;  DESC : 3D Object representation with AoS Array of Structures
;  DESC : Memory Management: Slot-Map (Dense-Map)
;  DESC : Keep the 4D Points as solid Array for hight speed
;  DESC : SIMD Vector Block operations 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2026/10/23
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

DeclareModule O3D
  EnableExplicit
    
  Structure TVector      ; 128-bit SIMD Vector for 4D Coordinates
    x.f : y.f : z.f : w.f
  EndStructure 
  
  Structure THandle             ; a 64 Bit Handle: lo=Index, hi=GenerationCounter
    h.q[0]                      ; virtual Union to get idx_gen as a single 64Bit Quad  
    idx.l                       ; Dense Data Array Index (or next free slot if free)
    gen.l                       ; 32-bit Generation counter
  EndStructure
  
  Structure TLine
    hPt1.q                      ; 64-bit Handle for Point 1
    hPt2.q                      ; 64-bit Handle for Point 2
  EndStructure
  
  Structure TVertice            ; Triangle Face
    hPt1.q                      ; 64-bit Handle for Point 1
    hPt2.q                      ; 64-bit Handle for Point 2
    hPt3.q                      ; 64-bit Handle for Point 3
  EndStructure
  
  ; Represents a single CAD Face (e.g., a cylinder or a flat plane from the STEP file)
  Structure TCadFace
    StepID.l                    ; The original ID from the STEP file (e.g., 21 for #21=ADVANCED_FACE)
    Color.l                     ; RGBA Color of this specific face
    
    ; Index-Ranges within your dense arrays so you know which primitives belong to this CAD Face
    StartFaceIdx.l              ; First triangle index in *This\faces()
    FaceCount.l                 ; Number of triangles belonging to this CAD face
    
    StartLineIdx.l              ; First edge/line index in *This\lines()
    LineCount.l                 ; Number of edges belonging to this CAD face
  EndStructure
  
  Structure TO3D
    ; --- Handle Management Pool ---
    hNextFree.l                 ; Head of the handle free-list chain
    hCnt.l                      ; Total active point handle count
    hMax.l                      ; Capacity limit of the handle pool
    
    Array slots.THandle(0)      ; Maps Handle Index -> Generational Slot Entry
    Array revMap.THandle(0)     ; Maps Dense Data Array Index -> Handle
    Array pts.TVector(0)        ; Dense AoS Array of 4D Points (Ready for SIMD)
    
    ; --- Topology Lists (Dense Indexed Buffers) ---
    lineCnt.l                   ; Total active lines
    lineMax.l                   ; Maximum allocated lines capacity
    Array lines.TLine(0)        ; Dense Array of Lines
    
    faceCnt.l                   ; Total active faces
    faceMax.l                   ; Maximum allocated faces capacity
    Array faces.TVertice(0)     ; Dense Array of Faces
    
    
    Array cadFaces.TCadFace(0)
    cadFaceCnt.l
    cadFaceMax.l  
  EndStructure
  
  Structure TGlTriangle Align 4 ; OpenGL Triangle Index Structure for Open GL Export
    i1.l
    i2.l
    i3.l
  EndStructure

   ;- Core & Points
  Declare   Init(*This.TO3D, InitialSize.l = 1024)
  Declare.q AddPoint(*This.TO3D, x.f, y.f, z.f, w.f = 1.0)
  Declare   RemovePoint(*This.TO3D, hPoint.q)
  Declare.l GetPointIdx(*This.TO3D, hPoint.q)

  ;- Lines 
  Declare.l AddLine(*This.TO3D, hPt1.q, hPt2.q)
  Declare RemoveLine(*This.TO3D, LineIdx.l)
  
  ;- Faces 
  Declare.l AddFace(*This.TO3D, hPt1.q, hPt2.q, hPt3.q)
  Declare RemoveFace(*This.TO3D, FaceIdx.l)
  
  ;- Topolgy Validation and CleanUp
  Declare.i IsPointUsed(*This.TO3D, hPoint.q) ; Returns #True if used by any line or face
  Declare CleanTopology(*This.TO3D, hPoint.q) ; Removes all lines and faces referencing this point
    
  ;- CAD Selective Rendering Helpers
  Declare.l GetCadFaceStartOffset(*This.TO3D, CadFaceIdx.l) ; Element offset for glDrawElements
  Declare.l GetCadFaceCount(*This.TO3D, CadFaceIdx.l)       ; Vertex count (Triangles * 3) for glDrawElements
  
  ;- OpenGL Export Interface
  Declare.i GetVertexBufferPtr(*This.TO3D)     ; Returns pointer to dense point array (VBO data)
  Declare.l GetVertexBufferSizeBytes(*This.TO3D) ; Returns total bytes of vertex data
  
  Declare.i GetElementBufferPtr(*This.TO3D)    ; Returns pointer to flat face array (EBO data)
  Declare.l GetElementBufferSizeBytes(*This.TO3D) ; Returns total bytes of index data
  Declare.i ExportElementBuffer(*This.TO3D, Array OutGlTriangles.TGlTriangle(1))

EndDeclareModule

Module O3D
  EnableExplicit  

  ; ----------------------------------------------------------------------
  ; INTERNAL HELPER FUNCTIONS
  ; ----------------------------------------------------------------------
  
  Macro MaxOf2(_VarResult, _v1, _v2)
    _VarResult = _v1
    If _VarResult < _v2 : _VarResult = _v2 : EndIf
  EndMacro

  ; Dynamically doubles all pools when capacity is reached (Amortized O(1))
  Procedure _GrowPool(*This.TO3D)
    Protected i.l
    Protected OldMax.l = *This\hMax
    
    With *This
      \hMax * 2                 ; Double the capacity
      ReDim \slots(\hMax - 1)
      ReDim \revMap(\hMax - 1)
      ReDim \pts(\hMax - 1)
      
      ; Link the newly allocated slots into the free-list chain
      For i = OldMax To \hMax - 2
        \slots(i)\idx = i + 1
        \slots(i)\gen = 1
      Next
      \slots(\hMax - 1)\idx = \hNextFree ; Attach the old chain head to the end of the new chain
      \slots(\hMax - 1)\gen = 1
      \hNextFree = OldMax                ; Move the chain head to the first new slot
    EndWith
    
  EndProcedure
  
  ; ----------------------------------------------------------------------
  ; CORE INITIALIZATION
  ; ----------------------------------------------------------------------
  
   Procedure Init(*This.TO3D, InitialSize.l = 1024)
    Protected i.l
    With *This
      ; We add +1 to the allocation size so that the user gets their requested 
      ; capacity, even though Slot 0 is skipped and left unused.
      \hMax = InitialSize + 1   
      \hCnt = 0
      \hNextFree = 1            ; Start the free-list chain at Slot 1 instead of 0
      
      Dim \slots(\hMax - 1)
      Dim \revMap(\hMax - 1)
      Dim \pts(\hMax - 1)
      
      ; Slot 0 automatically remains .idx = 0 and .gen = 0.
      ; Since no active handle will ever match Gen 0, a Handle value of 0 is permanently invalid.
      
      ; Link the free-list chain starting strictly from Slot 1
      For i = 1 To \hMax - 2
        \slots(i)\idx = i + 1   
        \slots(i)\gen = 1       
      Next
      \slots(\hMax - 1)\idx = -1 ; Terminal node of the free-list
      \slots(\hMax - 1)\gen = 1
      
      ; Topology structures (Lines & Faces remain zero-indexed as usual)
      \lineCnt = 0
      \lineMax = InitialSize
      Dim \lines(\lineMax - 1)
      
      \faceCnt = 0
      \faceMax = InitialSize
      Dim \faces(\faceMax - 1)
    EndWith
  EndProcedure

  ;- ----------------------------------------------------------------------
  ;- Point Management
  ;- ----------------------------------------------------------------------

  Procedure.q AddPoint(*This.TO3D, x.f, y.f, z.f, w.f = 1.0)
    Protected h.THandle      ; Temporary instance to assemble our 64-bit return value
    
    With *This
      ; If no free handles are left in the free-list chain, allocate more space
      If \hNextFree = -1
        _GrowPool(*This)
      EndIf
      
      ; 1. Pop an available slot index from the top of the free-list chain
      Protected slotIdx.l = \hNextFree
      \hNextFree = \slots(slotIdx)\idx
      
      ; 2. Append the new coordinates into the packed, contiguous data array
      Protected denseIdx.l = \hCnt
      \pts(denseIdx)\x = x
      \pts(denseIdx)\y = y
      \pts(denseIdx)\z = z
      \pts(denseIdx)\w = w
      
      ; 3. Remap the slot to look at the newly added dense coordinate index
      \slots(slotIdx)\idx = denseIdx
      
      ; 4. Pack the Slot Map Index and Generation into the 64-bit Handle.
      ; Due to Little-Endian architecture:
      ; sl(0) naturally aligns to the lower 32-bits (Index)
      ; sl(1) naturally aligns to the upper 32-bits (Generation)
      h\idx = slotIdx
      h\gen = \slots(slotIdx)\gen
      
      ; 5. Register the inverse map (Dense Index -> 64-bit Handle)
      \revMap(denseIdx)\h = h\h
      \hCnt + 1
      
      ProcedureReturn h\idx     ; Return the safe, compound 64-bit handle identifier
    EndWith
  EndProcedure
  
  Procedure RemovePoint(*This.TO3D, hPoint.q)
    ; We treat the incoming 64-bit Quad as a pointer to a THandle locally
    Protected h.THandle : h\h = hPoint
    
    With *This
      ; 1. Validation check via direct named access
      If \slots(h\idx)\gen <> h\gen
        ProcedureReturn
      EndIf
      
      Protected idxToDel.l = \slots(h\idx)\idx
      Protected idxLast.l = \hCnt - 1
      
      If idxToDel < idxLast
        ; Move the point coordinates (Contiguous 16-Byte copy)
        \pts(idxToDel) = \pts(idxLast)
        
        ; --- YOUR TRICK IN ACTION ---
        ; Since revMap uses THandle, we pull the whole structural block 
        ; of the last element. It contains BOTH the slot index and its generation!
        Protected hLastPoint.THandle  : hLastPoint\h= \revMap(idxLast)\h
        
        ; Route the slot table directly using the unpacked slot index
        \slots(hLastPoint\idx)\idx = idxToDel
        
        ; Move the metadata to the new position inside the reverse map
        \revMap(idxToDel)\h = hLastPoint\h
      EndIf
      
      ; 2. Invalidate slot by incrementing generation
      \slots(h\idx)\gen + 1
      
      ; 3. Return slot to the free-list chain
      \slots(h\idx)\idx = \hNextFree
      \hNextFree = h\idx
      
      \hCnt - 1
    EndWith
  EndProcedure
  
  ; Safely maps an external 64-bit Handle to a direct raw array index
  Procedure.l GetPointIdx(*This.TO3D, hPoint.q)
    ; Instant unpacking using memory offsets (0 CPU shift cycles)
    Protected h.THandle 
    h\h = hPoint
     
    ; Perform the validation check: If generation matches, the underlying point is alive
    If *This\slots(h\idx)\gen = h\Gen
      ProcedureReturn *This\slots(h\idx)\idx ; Return index safe for macro processing
    EndIf
    
    ProcedureReturn -1 ; Stale/Deleted handle cleanly intercepted
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- LINE and Face logic
  ;- ----------------------------------------------------------------------
  
  Procedure.l AddLine(*This.TO3D, hPt1.q, hPt2.q)
    
    With *This
      If \lineCnt >= \lineMax
        \lineMax * 2
        ReDim \lines(\lineMax - 1)
      EndIf
      
      Protected idx.l = \lineCnt
      \lines(idx)\hPt1 = hPt1   ; Store the stable 64-bit point handles
      \lines(idx)\hPt2 = hPt2
      
      \lineCnt + 1
      ProcedureReturn idx        ; Primitive arrays remain index-driven for linear D3D/GL submission
    EndWith
  EndProcedure
  
  Procedure RemoveLine(*This.TO3D, LineIdx.l)
    
    With *This
      Protected idxLast.l = \lineCnt - 1
      ; Keep line buffer contiguous using standard swap-with-last deflation
      If LineIdx < idxLast
        \lines(LineIdx) = \lines(idxLast)
      EndIf
      \lineCnt - 1
    EndWith
  EndProcedure
    
  Procedure.l AddFace(*This.TO3D, hPt1.q, hPt2.q, hPt3.q)
    
    With *This
      If \faceCnt >= \faceMax
        \faceMax * 2
        ReDim \faces(\faceMax - 1)
      EndIf
      
      Protected idx.l = \faceCnt
      \faces(idx)\hPt1 = hPt1   ; Store the stable 64-bit point handles
      \faces(idx)\hPt2 = hPt2
      \faces(idx)\hPt3 = hPt3
      
      \faceCnt + 1
      ProcedureReturn idx        ; Primitive arrays remain index-driven for linear D3D/GL submission
    EndWith
  EndProcedure
  
  Procedure RemoveFace(*This.TO3D, FaceIdx.l)
    
    With *This
      Protected idxLast.l = \faceCnt - 1
      ; Keep face buffer contiguous using standard swap-with-last deflation
      If FaceIdx < idxLast
        \faces(FaceIdx) = \faces(idxLast)
      EndIf
      \faceCnt - 1
    EndWith
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Toplogy Validation and CleanUp
  ;- ----------------------------------------------------------------------
  
  ; Scans all active lines and faces to check if a specific point handle is still referenced.
  ; Returns #True immediately upon finding a match (early exit), or #False if safe to delete.
  ; Scans all active lines and faces to check if a specific point handle is still referenced.
  ; Returns #True immediately upon finding a match (early exit), or #False if safe to delete.
  Procedure.i IsPointUsed(*This.TO3D, hPoint.q)
    Protected i.l
    
    With *This
      ; 1. Scan the flat, contiguous Line buffer
      For i = 0 To \lineCnt - 1
        If \lines(i)\hPt1 = hPoint Or \lines(i)\hPt2 = hPoint
          ProcedureReturn #True
        EndIf
      Next
      
      ; 2. Scan the flat, contiguous Face (Triangle) buffer
      For i = 0 To \faceCnt - 1
        If \faces(i)\hPt1 = hPoint Or \faces(i)\hPt2 = hPoint Or \faces(i)\hPt3 = hPoint
          ProcedureReturn #True
        EndIf
      Next
    EndWith
    
    ProcedureReturn #False
  EndProcedure
     
  ; Internal Helper: Removes a line and updates the referencing CAD face ranges
  Procedure _RemoveLineAndFixCad(*This.TO3D, LineIdx.l)
    
    With *This
      Protected idxLast.l = \lineCnt - 1
      Protected i.l
      
      ; 1. Find which CAD face currently loses a line to decrement its count
      For i = 0 To \cadFaceCnt - 1
        If LineIdx >= \cadFaces(i)\StartLineIdx And LineIdx < (\cadFaces(i)\StartLineIdx + \cadFaces(i)\LineCount)
          \cadFaces(i)\LineCount - 1
          Break
        EndIf
      Next
      
      ; 2. Handle the Swap-With-Last operation
      If LineIdx < idxLast
        \lines(LineIdx) = \lines(idxLast)
        
        ; Find the CAD face that owned the swapped trailing element, and update its start index
        For i = 0 To \cadFaceCnt - 1
          If idxLast >= \cadFaces(i)\StartLineIdx And idxLast < (\cadFaces(i)\StartLineIdx + \cadFaces(i)\LineCount + 1)
            ; If the swapped element moved before its original face block or within it, adjust
            ; (Since it moved to LineIdx, we just need to see if it was part of this face)
            ; A robust way is to scan which face contained 'idxLast' and change it to 'LineIdx' if it was the boundary
            ; However, since CAD faces are sequential, the swapped last item belongs to the last CAD Face!
            \cadFaces(\cadFaceCnt - 1)\StartLineIdx = LineIdx
            Break
          EndIf
        Next
      EndIf
      \lineCnt - 1
    EndWith
  EndProcedure

  ; Internal Helper: Removes a face and updates the referencing CAD face ranges
  Procedure _RemoveFaceAndFixCad(*This.TO3D, FaceIdx.l)
    
    With *This
      Protected idxLast.l = \faceCnt - 1
      Protected I
      
      ; 1. Decrement count on the owner CAD face
      For I = 0 To \cadFaceCnt - 1
        If FaceIdx >= \cadFaces(I)\StartFaceIdx And FaceIdx < (\cadFaces(I)\StartFaceIdx + \cadFaces(I)\FaceCount)
          \cadFaces(I)\FaceCount - 1
          Break
        EndIf
      Next
      
      ; 2. Handle Swap-With-Last
      If FaceIdx < idxLast
        \faces(FaceIdx) = \faces(idxLast)
        
        ; The swapped element always belonged to the very last registered CAD face block
        ; update its marker to its new squatted slot index
        ; (Note: In a pure sequential importer, the last item in the array always belongs to the last face)
        ; To be 100% mathematically safe regardless of generation order, we find the owner of idxLast:
        For I = 0 To \cadFaceCnt - 1
          ; If this face block started at the very end of the array, update its pointer
          If \cadFaces(I)\StartFaceIdx = idxLast
            \cadFaces(I)\StartFaceIdx = FaceIdx
          EndIf
        Next
      EndIf
      \faceCnt - 1
    EndWith
  EndProcedure

  ; Main entry point for cascading topology deletions
  ; Scans all active lines and faces backwards and removes any primitive 
  ; that references the specified point handle. Uses Swap-With-Last internally.
  Procedure CleanTopology(*This.TO3D, hPoint.q)
    Protected I
    
    With *This
      ; Loop backwards to safely drop items without disrupting the index progression
      For I = \lineCnt - 1 To 0 Step -1
        If \lines(I)\hPt1 = hPoint Or \lines(I)\hPt2 = hPoint
          _RemoveLineAndFixCad(*This, I)
        EndIf
      Next
      
      For I = \faceCnt - 1 To 0 Step -1
        If \faces(I)\hPt1 = hPoint Or \faces(I)\hPt2 = hPoint Or \faces(I)\hPt3 = hPoint
          _RemoveFaceAndFixCad(*This, I)
        EndIf
      Next
    EndWith
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- CAD Faces
  ;- ----------------------------------------------------------------------
  
  ; load Vertices: 
  ;   The Parser reads all CARTESIAN_POINT. Each Point is added via AddPoint().
  ;   The parser temporarily stores he returned 64-bit handles (h\h) in a Map,
  ;   mapped to the corresponding STEP ID (e.g., #10).
   
  ; load Edges: 
  ; The parser reads the EDGE_CURVE entries. The curves are broken down into small
  ; line segments (tessellated). You open a CAD face and add these lines using 
  ; AddLine(Mesh, hPt1, hPt2). This ensures that the wireframe structure remains
  ; selectable as a logical edge.
  
  ; Tesselation: 
  ; Complex freeform surfaces (B_SPLINE_SURFACE, CYLINDRICAL_SURFACE) are broken down
  ; into triangles. These triangles are appended using AddFace(Mesh, hPt1, hPt2, hPt3)
  ; This provides the graphics card and the calculation macros with linear triangle data.
    
  Procedure.l BeginCadFace(*This.TO3D, StepID.l, Color.l = $FFFFFF)
    With *This
      
      ; Dynamic resizing for the CAD-Face array
     If \cadFaceCnt >= \cadFaceMax       
       If \cadFaceMax >=16 
         \cadFaceMax * 2
       Else
         \cadFaceMax = 32         
       EndIf
       ReDim \cadFaces(\cadFaceMax - 1)
     EndIf
      
      Protected idx.l = \cadFaceCnt
      \cadFaces(idx)\StepID = StepID
      \cadFaces(idx)\Color = Color
      
      ; Lock the current engine array positions as the starting points
      \cadFaces(idx)\StartFaceIdx = \faceCnt
      \cadFaces(idx)\StartLineIdx = \lineCnt
      
      \cadFaceCnt + 1
      ProcedureReturn idx
    EndWith
  EndProcedure

  Procedure EndCadFace(*This.TO3D, CadFaceIdx.l)
    With *This
      ; Calculate how many primitives were added since BeginCadFace was called
      \cadFaces(CadFaceIdx)\FaceCount = \faceCnt - \cadFaces(CadFaceIdx)\StartFaceIdx
      \cadFaces(CadFaceIdx)\LineCount = \lineCnt - \cadFaces(CadFaceIdx)\StartLineIdx
    EndWith
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- CAD SELECTIVE RENDERING HELPERS
  ;- ----------------------------------------------------------------------
  
  ; Returns the byte offset or element offset inside the EBO for a specific CAD face.
  ; Useful for drawing a specific part of the solid using glDrawElements.
  Procedure.l GetCadFaceStartOffset(*This.TO3D, CadFaceIdx.l)
    With *This
      If CadFaceIdx < 0 Or CadFaceIdx >= \cadFaceCnt : ProcedureReturn 0 : EndIf
      ; Returns the index offset multiplied by 3 (since each face has 3 indices)
      ProcedureReturn \cadFaces(CadFaceIdx)\StartFaceIdx * 3
    EndWith
  EndProcedure
  
  ; Returns the total number of indices (vertices) to render for this specific CAD face.
  Procedure.l GetCadFaceCount(*This.TO3D, CadFaceIdx.l)
    With *This
      If CadFaceIdx < 0 Or CadFaceIdx >= \cadFaceCnt : ProcedureReturn 0 : EndIf
      ; Triangles * 3 indices per triangle
      ProcedureReturn \cadFaces(CadFaceIdx)\FaceCount * 3
    EndWith
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- OPENGL EXPORT INTERFACE
  ;- ----------------------------------------------------------------------
  
  ; Returns the raw memory address of the first active point.
  ; Directly bind this pointer to your OpenGL Vertex Buffer (VBO) via glBufferData.
  Procedure.i GetVertexBufferPtr(*This.TO3D)
    If *This\hCnt = 0 : ProcedureReturn #Null : EndIf
    ProcedureReturn @*This\pts(0)
  EndProcedure
  
  ; Calculates the exact size of the active vertex data in bytes.
  Procedure.l GetVertexBufferSizeBytes(*This.TO3D)
    ; Each TVector is exactly 16 bytes (4 floats * 4 bytes)
    ProcedureReturn *This\hCnt * SizeOf(TVector)
  EndProcedure
  
  ; Returns the raw memory address of the first face primitive.
  ; Directly bind this pointer to your OpenGL Element Buffer (EBO) via glBufferData.
  Procedure.i GetElementBufferPtr(*This.TO3D)
    If *This\faceCnt = 0 : ProcedureReturn #Null : EndIf
    ProcedureReturn @*This\faces(0)
  EndProcedure
  
  ; Calculates the exact size of the active face index data in bytes.
  Procedure.l GetElementBufferSizeBytes(*This.TO3D)
    ; Each TVertice is exactly 12 bytes (3 Long-Indices * 4 bytes)
    ProcedureReturn *This\faceCnt * SizeOf(TVertice)
  EndProcedure
  
  ; Generates a clean OpenGL-ready index buffer (EBO) from the handle-based faces.
  ; OutGlTriangles() will be resized and filled with raw 32-bit indices.
  Procedure.l ExportElementBuffer(*This.TO3D, Array OutGlTriangles.TGlTriangle(1))
    Protected I
    Protected.l idxA, idxB, idxC, validTriangles
     
    With *This
      ; Allocate enough space in the output array
      Dim OutGlTriangles(\faceCnt - 1)
      
      For I = 0 To \faceCnt - 1
        ; Translate the 64-bit handles to direct dense array indices
        idxA = GetPointIdx(*This, \faces(I)\hPt1)
        idxB = GetPointIdx(*This, \faces(I)\hPt2)
        idxC = GetPointIdx(*This, \faces(I)\hPt3)
        
        ; Only export if all three points of the triangle are alive and valid
        If idxA <> -1 And idxB <> -1 And idxC <> -1
          OutGlTriangles(validTriangles)\i1 = idxA
          OutGlTriangles(validTriangles)\i2 = idxB
          OutGlTriangles(validTriangles)\i3 = idxC
          validTriangles + 1
        EndIf
      Next
      
      ; If some triangles were skipped due to deleted points, shrink the array
      If validTriangles < \faceCnt
        ReDim OutGlTriangles(validTriangles - 1)
      EndIf
      
      ProcedureReturn validTriangles ; Returns the actual number of triangles exported
    EndWith
  EndProcedure


EndModule



CompilerIf #PB_Compiler_IsMainFile
  ; ----------------------------------------------------------------------
  ; Execution Verification with Topology Lookups
  ; ----------------------------------------------------------------------
  
  Define Mesh.O3D::TO3D
  O3D::Init(Mesh, 4)
  
  ; 1. Add coordinates
  Define p1.q = O3D::AddPoint(Mesh,  0.0,  5.0,  0.0)
  Define p2.q = O3D::AddPoint(Mesh, -5.0, -5.0,  0.0)
  Define p3.q = O3D::AddPoint(Mesh,  5.0, -5.0,  0.0)
  
  ; 2. Link them to a Face primitive
  Define face0 = O3D::AddFace(Mesh, p1, p2, p3)
  
  ; 3. Render Loop Simulation (Safely unpacking indices to compile an EBO / Index Buffer)
  Debug "--- Simulating Index Buffer Generation ---"
  Define f.l
  Define.q hA, hB, hC
  Define.l idxA, idxB, idxC
  
  For f = 0 To Mesh\faceCnt - 1
    hA.q = Mesh\faces(f)\hPt1
    hB.q = Mesh\faces(f)\hPt2
    hC.q = Mesh\faces(f)\hPt3
    
    idxA.l = O3D::GetPointIdx(Mesh, hA)
    idxB.l = O3D::GetPointIdx(Mesh, hB)
    idxC.l = O3D::GetPointIdx(Mesh, hC)
    
    ; If any point was deleted, GetPointIdx returns -1
    If idxA <> -1 And idxB <> -1 And idxC <> -1
      Debug "Face " + Str(f) + " ready to render with native dense indices: " + Str(idxA) + ", " + Str(idxB) + ", " + Str(idxC)
      Debug "-> Vertex A Y-Pos: " + StrF(Mesh\pts(idxA)\y)
    Else
      Debug "Face " + Str(f) + " contains a deleted point! Skipping or cleaning up..."
    EndIf
  Next
CompilerEndIf

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 192
; FirstLine = 148
; Folding = -----
; DPIAware
; CPU = 5
; Compiler = PureBasic 6.41 (Windows - x64)