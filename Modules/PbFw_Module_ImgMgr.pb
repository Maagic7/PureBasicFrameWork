; ===========================================================================
;  FILE : PbFw_Module_ImgMgr.pb
;  NAME : Module Image Manager [ImgMgr::]
;  DESC : Application wide Image Manager with automatic reference counting.
;  DESC : Optimized for dynamic localization asset loading to map unique 
;  DESC : text identifiers (Keys) to persistent runtime image resources.
;  DESC : Because PB generates unique #Image numbers on every dynamic asset 
;  DESC : request, loading similar language elements could result in redundant
;  DESC : allocations. This custom manager ensures structured reverse 
;  DESC : lookup and precise property evaluation by its native handle.
; ===========================================================================
;
; AUTHOR   : Stefan Maag
; COAUTHOR : AI Assistant
; DATE     : 2026/10/30
; VERSION  : 0.5 pretested Developer Version
; COMPILER : PureBasic 6.0
;
; LICENCE  : MIT License see https://opensource.org/license/mit/
;            or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
;}
;{ TODO:
;}
; ===========================================================================

; XIncludeFile "PbFw_Module_ImgMgr.pb"        ; ImgMgr::   dynamic Image Manager

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

; XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
; XIncludeFile "PbFw_Module_PbSdk.pb"        ; PbSdk::    PureBasic SDK

DeclareModule ImgMgr
  
  EnableExplicit
  
  Structure TImageData
    pbImage.i  ; The internal PureBasic #Image object number (from #PB_Any)
    ;hImage.i   ; OS Image Handle FontID(pbFont) -> Commented out for now
    Key$       ; Unique identification key (e.g., "logo_main")
    FileName$  ; Complete file path from which the image was loaded
    Width.i    ; Automatically resolved width of the image in pixels
    Height.i   ; Automatically resolved height of the image in pixels
    RefCount.i ; Tracker for how many components are currently using this image
  EndStructure

  Declare.i GetImageHandle(Key$, FileName$)
  Declare.i ReleaseImage(pbImage.i)
  Declare.i IsImageLoaded(pbImage.i)
  Declare.i GetImageData(pbImage.i, *outImageData.TImageData)
  Declare   ClearAll()
  
EndDeclareModule

Module ImgMgr
  
  EnableExplicit

  Global NewMap _map_Images.TImageData() ; Main cache indexed by lowercase Key$
  Global NewMap _map_Lookup.s()          ; Reverse lookup: PB ImageNo (String) -> Key$

  Procedure.i GetImageHandle(Key$, FileName$)
  ; ======================================================================
  ; NAME : GetImageHandle
  ; DESC : Retrieves the PB ImageNo from cache (increments RefCount),
  ; DESC : or loads the image from disk if not cached yet.
  ; VAR(Key$)     : Unique identification key string (e.g., "icon_edit")
  ; VAR(FileName$): Full file path to the target image file
  ; RET.i : The PB ImageNo #Image, or 0 if loading failed
  ; ======================================================================
    Protected SearchKey$ = LCase(Key$)
    
    ; 1. Check if the image configuration already exists in cache
    If FindMapElement(_map_Images(), SearchKey$)
      _map_Images()\RefCount + 1
      ProcedureReturn _map_Images()\pbImage
    EndIf
    
    ; 2. Not cached yet: Load it from disk using dynamic #PB_Any identification
    Protected NewPB = LoadImage(#PB_Any, FileName$)
    If NewPB
      ; Store properties inside the tracking cache map
      _map_Images(SearchKey$)\pbImage  = NewPB
      ;_map_Images(SearchKey$)\hImage   = ImageID(NewPB)
      _map_Images(SearchKey$)\Key$       = Key$
      _map_Images(SearchKey$)\FileName$  = FileName$
      _map_Images(SearchKey$)\Width      = ImageWidth(NewPB)  ; Automatically extract dimensions
      _map_Images(SearchKey$)\Height     = ImageHeight(NewPB) ; Automatically extract dimensions
      _map_Images(SearchKey$)\RefCount   = 1                  ; First usage initialization
      
      ; Register reverse lookup link (Handle String -> Cache Key)
      _map_Lookup(Str(NewPB)) = SearchKey$
      
      ProcedureReturn NewPB
    EndIf
    
    ProcedureReturn 0
  EndProcedure

  Procedure.i ReleaseImage(pbImage.i)
  ; ======================================================================
  ; NAME : ReleaseImage
  ; DESC : Decrements the reference counter. Unloads the image if count hits 0
  ; VAR(pbImage.i) : The PB ImageNo #Image
  ; RET.b : True if handle was found and processed, else False
  ; ======================================================================
    Protected ImageKey$ = Str(pbImage)
    
    If FindMapElement(_map_Lookup(), ImageKey$)
      Protected SearchKey$ = _map_Lookup()
      
      If FindMapElement(_map_Images(), SearchKey$)
        _map_Images()\RefCount - 1
        
        ; If nobody uses this image anymore, clean it up completely
        If _map_Images()\RefCount <= 0
          If IsImage(_map_Images()\pbImage)
            FreeImage(_map_Images()\pbImage)
          EndIf
          DeleteMapElement(_map_Images(), SearchKey$)
          DeleteMapElement(_map_Lookup(), ImageKey$)
        EndIf
        
        ProcedureReturn #True
      EndIf
    EndIf
    
    ProcedureReturn #False
  EndProcedure

  Procedure.i IsImageLoaded(pbImage.i)
  ; ======================================================================
  ; NAME : IsImageLoaded
  ; DESC : Checks if the PB ImageNo is currently loaded and tracked by the manager
  ; VAR(pbImage.i) : The PB ImageNo #Image to verify
  ; RET.i : #True if tracked, else #False
  ; ======================================================================
    If FindMapElement(_map_Lookup(), Str(pbImage))
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.i GetImageData(pbImage.i, *outImageData.TImageData)
  ; ======================================================================
  ; NAME : GetImageData
  ; DESC : Resolves metadata (Key, Path, Dimensions, RefCount) using the PB ImageNo
  ; VAR(pbImage.i) : The PB ImageNo #Image
  ; VAR(*outImageData.TImageData) : Pointer to structure receiving the data
  ; RET.b : True if the handle was resolved successfully, else False
  ; ======================================================================
    If *outImageData = 0 : ProcedureReturn #False : EndIf
    
    Protected ImageKey$ = Str(pbImage)
    
    If FindMapElement(_map_Lookup(), ImageKey$)
      Protected SearchKey$ = _map_Lookup()
      If FindMapElement(_map_Images(), SearchKey$)
        ; Safely duplicates structure data including dynamic string resources
        CopyStructure(_map_Images(), *outImageData, TImageData)
        ProcedureReturn #True
      EndIf
    EndIf
    
    ProcedureReturn #False
  EndProcedure

  Procedure ClearAll()
  ; ======================================================================
  ; NAME : ClearAll
  ; DESC : unload all images from memory and clear internal maps
  ; RET  : None
  ; ======================================================================
    ForEach _map_Images()
      If IsImage(_map_Images()\pbImage)
        FreeImage(_map_Images()\pbImage)
      EndIf
    Next
    ClearMap(_map_Images())
    ClearMap(_map_Lookup())
  EndProcedure
  
EndModule

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 79
; FirstLine = 55
; Folding = --
; DPIAware
; CPU = 5