; ===========================================================================
;  FILE : PbFw_Module_SndMgr.pb
;  NAME : Module Sound Manager [SndMgr::]
;  DESC : Application wide Sound Manager with automatic reference counting.
;  DESC : Optimized for dynamic localization asset loading to map unique 
;  DESC : text identifiers (Keys) to persistent runtime sound resources.
;  DESC : Because PB generates unique #Sound numbers on every dynamic asset 
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
; LICENCE  : MIT License see https://opensource.org
;            or \PbFramWork\MitLicence.txt
; ===========================================================================
;{ ChangeLog: 
;}
;{ TODO:
;}
; ===========================================================================

; XIncludeFile "PbFw_Module_SndMgr.pb"        ; SndMgr::   dynamic Sound Manager

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

; XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
; XIncludeFile "PbFw_Module_PbSdk.pb"        ; PbSdk::    PureBasic SDK

DeclareModule SndMgr
  
  EnableExplicit
  
  Structure TSoundData
    pbSound.i  ; The internal PureBasic #Sound object number (from #PB_Any)
    Key$       ; Unique identification key (e.g., "snd_welcome")
    FileName$  ; Complete file path from which the sound was loaded
    RefCount.i ; Tracker for how many components are currently using this sound
  EndStructure

  Declare.i GetSoundHandle(Key$, FileName$)
  Declare.i ReleaseSound(pbSound.i)
  Declare.i IsSoundLoaded(pbSound.i)
  Declare.i GetSoundData(pbSound.i, *outSoundData.TSoundData)
  Declare   ClearAll()
  
EndDeclareModule

Module SndMgr
  
  EnableExplicit

  Global NewMap _map_Sounds.TSoundData() ; Main cache indexed by lowercase Key$
  Global NewMap _map_Lookup.s()          ; Reverse lookup: PB SoundNo (String) -> Key$

  Procedure.i GetSoundHandle(Key$, FileName$)
  ; ======================================================================
  ; NAME : GetSoundHandle
  ; DESC : Retrieves the PB SoundNo from cache (increments RefCount),
  ; DESC : or loads the sound from disk if not cached yet.
  ; VAR(Key$)     : Unique identification key string (e.g., "snd_click")
  ; VAR(FileName$): Full file path to the target sound file
  ; RET.i : The PB SoundNo #Sound, or 0 if loading failed
  ; ======================================================================
    Protected SearchKey$ = LCase(Key$)
    
    ; 1. Check if the sound configuration already exists in cache
    If FindMapElement(_map_Sounds(), SearchKey$)
      _map_Sounds()\RefCount + 1
      ProcedureReturn _map_Sounds()\pbSound
    EndIf
    
    ; 2. Not cached yet: Load it from disk using dynamic #PB_Any identification
    Protected NewPB = LoadSound(#PB_Any, FileName$)
    If NewPB
      ; Store properties inside the tracking cache map
      _map_Sounds(SearchKey$)\pbSound   = NewPB
      _map_Sounds(SearchKey$)\Key$       = Key$
      _map_Sounds(SearchKey$)\FileName$  = FileName$
      _map_Sounds(SearchKey$)\RefCount   = 1                  ; First usage initialization
      
      ; Register reverse lookup link (Handle String -> Cache Key)
      _map_Lookup(Str(NewPB)) = SearchKey$
      
      ProcedureReturn NewPB
    EndIf
    
    ProcedureReturn 0
  EndProcedure

  Procedure.i ReleaseSound(pbSound.i)
  ; ======================================================================
  ; NAME : ReleaseSound
  ; DESC : Decrements the reference counter. Unloads the sound if count hits 0
  ; VAR(pbSound.i) : The PB SoundNo #Sound
  ; RET.b : True if handle was found and processed, else False
  ; ======================================================================
    Protected SoundKey$ = Str(pbSound)
    
    If FindMapElement(_map_Lookup(), SoundKey$)
      Protected SearchKey$ = _map_Lookup()
      
      If FindMapElement(_map_Sounds(), SearchKey$)
        _map_Sounds()\RefCount - 1
        
        ; If nobody uses this sound anymore, clean it up completely
        If _map_Sounds()\RefCount <= 0
          If IsSound(_map_Sounds()\pbSound)
            FreeSound(_map_Sounds()\pbSound)
          EndIf
          DeleteMapElement(_map_Sounds(), SearchKey$)
          DeleteMapElement(_map_Lookup(), SoundKey$)
        EndIf
        
        ProcedureReturn #True
      EndIf
    EndIf
    
    ProcedureReturn #False
  EndProcedure

  Procedure.i IsSoundLoaded(pbSound.i)
  ; ======================================================================
  ; NAME : IsSoundLoaded
  ; DESC : Checks if the PB SoundNo is currently loaded and tracked by the manager
  ; VAR(pbSound.i) : The PB SoundNo #Sound to verify
  ; RET.i : #True if tracked, else #False
  ; ======================================================================
    If FindMapElement(_map_Lookup(), Str(pbSound))
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.i GetSoundData(pbSound.i, *outSoundData.TSoundData)
  ; ======================================================================
  ; NAME : GetSoundData
  ; DESC : Resolves metadata (Key, Path, RefCount) using the PB SoundNo
  ; VAR(pbSound.i) : The PB SoundNo #Sound
  ; VAR(*outSoundData.TSoundData) : Pointer to structure receiving the data
  ; RET.b : True if the handle was resolved successfully, else False
  ; ======================================================================
    If *outSoundData = 0 : ProcedureReturn #False : EndIf
    
    Protected SoundKey$ = Str(pbSound)
    
    If FindMapElement(_map_Lookup(), SoundKey$)
      Protected SearchKey$ = _map_Lookup()
      If FindMapElement(_map_Sounds(), SearchKey$)
        ; Safely duplicates structure data including dynamic string resources
        CopyStructure(_map_Sounds(), *outSoundData, TSoundData)
        ProcedureReturn #True
      EndIf
    EndIf
    
    ProcedureReturn #False
  EndProcedure

  Procedure ClearAll()
  ; ======================================================================
  ; NAME : ClearAll
  ; DESC : Forcefully unloads all sounds from memory and clears internal maps
  ; RET  : None
  ; ======================================================================
    ForEach _map_Sounds()
      If IsSound(_map_Sounds()\pbSound)
        FreeSound(_map_Sounds()\pbSound)
      EndIf
    Next
    ClearMap(_map_Sounds())
    ClearMap(_map_Lookup())
  EndProcedure
  
EndModule

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 12
; Folding = --
; DPIAware
; CPU = 5