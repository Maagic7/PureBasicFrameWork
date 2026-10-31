; ===========================================================================
;  FILE : PbFw_Module_FntMgr.pb
;  NAME : Module Font Manager [FntMgr::]
;  DESC : Application wide Font Mamager with automatic
;  DESC : reference counting. Optimized for dynamic runtime loading
;  DESC : font allocations to eliminate system GDI handle leaks.
;  DESC : Because PB creates with every LoadFont() a new FontObject
;  DESC : even it is already loaded. Loading same Font 100 times creates
;  DESC : 100 FontObjects. With native PB you can not get back the 
;  DESC : Fontdata by Handle. There are two ways to solve that problem: 
;  DESC : Use OS API or a custom Font Manager
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

; XIncludeFile "PbFw_Module_FONT.pb"        ; FntMgr::   dynamic Font Manager

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

; XIncludeFile "PbFw_Module_PbFw.pb"         ; PbFw::     FrameWork control Module
; XIncludeFile "PbFw_Module_PbSdk.pb"        ; PbSdk::    PureBasic SDK

DeclareModule FntMgr
  
  EnableExplicit
  
  Structure TFontData
    pbFont.i  ; The internal PureBasic #Font object number
    ;hFont.i   ; OS Font Handle FontID(pbFont)  *** DOES NOT MAKE SENSE ***
    Name$     ; The clean font family name (e.g., "Arial")
    Size.i    ; The vertical font height in points (Pt)
    Flags.i   ; Applied style modifiers like #PB_Font_Bold
    RefCount.i; Tracker for how many items currently use this font
  EndStructure

  Declare.i GetFontHandle(Name$, Size.i, Flags.i = 0)
  Declare.i ReleaseFont(pbFont.i)
  Declare.i IsFontLoaded(pbFont.i)                       
  Declare.i GetFontData(pbFont.i, *outFontData.TFontData)
  Declare   ClearAll()
  
EndDeclareModule

Module FntMgr  
  
  EnableExplicit

  Global NewMap _map_Fonts.TFontData()  ; detailed Font Datas
  Global NewMap _map_Lookup.s()         ; FontNo lookup table

  Procedure.i GetFontHandle(Name$, Size.i, Flags.i = 0)
  ; ======================================================================
  ; NAME : GetFontHandle
  ; DESC : Retrieves the PB FontNo from cache (increments RefCount),
  ; DESC : and load the Font if not loaded.
  ; VAR(Name$) : Exact name of the Font family
  ; VAR(Size.i) : Font Size
  ; VAR(Flags.i): Optional style Flags (e.g., #PB_Font_Bold)
  ; RET.i : The PB FontNo #Font
  ; ======================================================================
    Protected Key$ = LCase(Name$) + "_" + Str(Size) + "_" + Str(Flags)
    
    ; 1. Check if the font configuration already exists in cache
    If FindMapElement(_map_Fonts(), Key$)
      _map_Fonts()\RefCount + 1 ; Increment usage counter
      ProcedureReturn _map_Fonts()\pbFont
    EndIf
    
    ; 2. Not cached yet: load it using dynamic #PB_Any identification
    Protected NewPB = LoadFont(#PB_Any, Name$, Size, Flags)
    If NewPB
      ; Store properties inside the tracking cache map
      _map_Fonts(Key$)\pbFont   = NewPB
      ; _Cache(Key$)\hFont    = FontID(NewPB)
      _map_Fonts(Key$)\Name$    = Name$
      _map_Fonts(Key$)\Size     = Size
      _map_Fonts(Key$)\Flags    = Flags
      _map_Fonts(Key$)\RefCount = 1 ; First usage initialization
      
      ; Register reverse lookup link (Handle String -> Cache Key)
      _map_Lookup(Str(_map_Fonts()\pbFont)) = Key$
      
      ProcedureReturn _map_Fonts()\pbFont
    EndIf
    
    ProcedureReturn 0
  EndProcedure

  Procedure.i ReleaseFont(pbFont.i)
  ; ======================================================================
  ; NAME : ReleaseFont
  ; DESC : Decrements the reference counter. Unloads the font if count hits 0
  ; VAR(pbFont.i) : The PB FontNo #Font
  ; RET.b : True if handle was found and processed, else False
  ; ======================================================================
    
    If FindMapElement(_map_Lookup(), Str(pbFont))
      Protected Key$ = _map_Lookup()
      If FindMapElement(_map_Fonts(), Key$)
        
        _map_Fonts()\RefCount - 1 ; Decrement reference counter
        
        ; If nobody uses this font anymore, clean it up completely
        If _map_Fonts()\RefCount <= 0
          If IsFont(_map_Fonts()\pbFont)
            FreeFont(_map_Fonts()\pbFont)
          EndIf
          DeleteMapElement(_map_Fonts())
          DeleteMapElement(_map_Lookup())
        EndIf
        
        ProcedureReturn #True
      EndIf
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i IsFontLoaded(pbFont.i)
  ; ======================================================================
  ; NAME : IsFontLoaded
  ; DESC : Prüft, ob die PB FontNo im Font Manager geladen und registriert ist
  ; VAR(pbFont.i) : Die zu prüfende PB FontNo #Font
  ; RET.i : #True wenn geladen, ansonsten #False
  ; ======================================================================
    If FindMapElement(_map_Lookup(), Str(pbFont))
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  Procedure.i GetFontData(pbFont.i, *outFontData.TFontData)
  ; ======================================================================
  ; NAME : GetFontData
  ; DESC : Resolves metadata (Name, Size, Flags, RefCount) using a raw OS font handle
  ; VAR(pbFont.i) : The PB FontNo #Font 
  ; VAR(*DetailsOut.TFontData) : Pointer to structure receiving the data
  ; RET.b : True if the handle was resolved successfully, else False
  ; ======================================================================
    If *outFontData = 0 : ProcedureReturn #False : EndIf
    
    Protected FontKey$ = Str(pbFont)
    
    If FindMapElement(_map_Lookup(), FontKey$)
      Protected CacheKey$ = _map_Lookup()
      If FindMapElement(_map_Fonts(), CacheKey$)
        CopyStructure(_map_Fonts(), *outFontData, TFontData)
        ProcedureReturn #True
      EndIf
    EndIf
    
    ProcedureReturn #False
  EndProcedure

  Procedure ClearAll()
  ; ======================================================================
  ; NAME : ClearAll
  ; DESC : Forcefully unloads all fonts from memory and clears internal maps
  ; RET   : None
  ; ======================================================================
    ForEach _map_Fonts()
      If IsFont(_map_Fonts()\pbFont)
        FreeFont(_map_Fonts()\pbFont)
      EndIf
    Next
    ClearMap(_map_Fonts())
    ClearMap(_map_Lookup())
  EndProcedure
  
EndModule

; ======================================================================
; MODULE TEST RUN
; ======================================================================
CompilerIf #PB_Compiler_IsMainFile
  
  EnableExplicit
  
  ; Requesting the same font twice
  Define hFont1 = FntMgr::GetFontHandle("Arial", 12)
  Define hFont2 = FntMgr::GetFontHandle("Arial", 12) ; RefCount is now 2
  
  Define Info.FntMgr::TFontData
  If FntMgr::GetFontData(hFont1, @Info)
    Debug "Current RefCount (should be 2): " + Str(Info\RefCount)
  EndIf
  
  ; Release the first usage
  FntMgr::ReleaseFont(hFont1)
  
  If FntMgr::GetFontData(hFont1, @Info)
    Debug "Current RefCount (should be 1): " + Str(Info\RefCount)
  Else
    Debug "Font was already completely removed!"
  EndIf
  
  ; Release the second usage -> Font triggers internal FreeFont()
  FntMgr::ReleaseFont(hFont2)
  
  If FntMgr::GetFontData(hFont1, @Info)
    Debug "Font still exists?!"
  Else
    Debug "Success: Font automatically deleted because RefCount hit 0!"
  EndIf
CompilerEndIf

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 13
; Folding = --
; DPIAware
; CPU = 5