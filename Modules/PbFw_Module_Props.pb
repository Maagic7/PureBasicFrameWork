; ===========================================================================
;  FILE : PbFw_Module_Props.pb
;  NAME : Module Properties [Prop::]
;  DESC : Object like Property Bag
;  DESC : It is designed for some 1000's of Properties
;  DESC : but not for multi Million!
;  DESC : Usecases: 
;  DESC :   - App Localisation
;  DESC :   - Theme and Application Settings 
;  DESC :   - Application wide MessageBoxes
;  DESC :   - Save and Restore Gadget Layout
;  DESC : Supports 
;  DESC :  - Fonts, Images, Sound, MessageBoxes, GadgetLayout
;  DESC :  - deirct export to TreeView Gadget (hirarichical keys supported)
;  DESC :  - Save all settings as JOSON, Load from JOSON
;  DESC :  - Save and Load Encrypted
; ===========================================================================
;
; AUTHOR   : Stefan Maag
; COAUTHOR : AI Assistant
; DATE     : 2026/10/29
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

; XIncludeFile "PbFw_Module_Props.pb"        ; PROPS::  Property Bag

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

; XIncludeFile "PbFw_Module_PbFw.pb"          ; PbFw::    FrameWork control Module
; XIncludeFile "PbFw_Module_PbSdk.pb"         ; PbSdk::   PureBasic SDK

XIncludeFile "PbFw_Module_FntMgr.pb"        ; FntMgr::  dynamic Font Manager
XIncludeFile "PbFw_Module_ImgMgr.pb"        ; ImgMgr::  dynamic Image Manager
XIncludeFile "PbFw_Module_SndMgr.pb"        ; SndMgr::   dynamic Sound Manager

DeclareModule PROPS
  EnableExplicit
  
  ;- Enumerations
  EnumerationBinary PropFlags
    #Prop_Flag_Long      ; A Long  is in DataL[0]
    #Prop_Flag_Color     ; A Color is in DataL[1]
    #Prop_Flag_Quad      ; A Quad  is in DataL[2..3]
    #Prop_Flag_RECT      ; Rectangle or box Data stored in DataL[0..3]
    
    #Prop_Flag_String    ; Setup as String
    #Prop_Flag_MsgBox    ; Setup as MsgBox 
     
    #Prop_Flag_Font      ; activate the Font Property
    
    #Prop_Flag_Menu
    #Prop_Flag_MenuTitel
    #Prop_Flag_MenuSubtitel
    
    #Prop_Flag_Image
    #Prop_Flag_Sound
    
    #Prop_Flag_ReadOnly  ; Flag for Editor - ReadOnly
    
    ; TODO! 
    ; #Prop_Flag_Encrypted ; Flag for SaveBag: Save it JOSON encrypted
  EndEnumeration
  
  ; index constants for DataL[] Array
  #Prop_idx_Long  = 0
  #Prop_idx_Color = 1
  #Prop_idx_Quad  = 2

  ;- Structures
  Structure TPropItem
    Key$
    ; ParentKey.s  ; Option Links to the partent node key. Empty if root.
    Flags.i       ; Type matching the PropTypes enumeration
    
    DataL.l[4]    ; Native 4x32-bit array storing complete bounds or metrics
     
    Value$        ; Storage for raw text data, configurations, or fonts
    Text$         ; Human-readable context metadata
    
    ; Internal Cached System Handles (Hidden from JSON serialization via Module logic)
    Source$       ; The defining source string (e.g., CSV descriptor for fonts)
    pbHandle.i    ; Stores the internal PB Number (#PB_Any allocation for Font/Image/Sound)
    osHandle.i    ; Stores the OS Handle (FontID/ImageID, 0 for Sounds)
   
  EndStructure
  
  Structure TPropBag
    Map Items.TPropItem()
  EndStructure

  ;- Public Interface Procedures
  Declare.i NewBag()
  Declare.i FreeBag(*This.TPropBag)
  
  Declare.i LoadBag(*This.TPropBag, FileName$)
  Declare.i SaveBag(*This.TPropBag, FileName$)
  
  Declare.i LoadBagEncrypted(*This.TPropBag, FileName$, Key256$) 
  Declare.i SaveBagEncrypted(*This.TPropBag, FileName$, Key256$)
  
  ; --- Get Set Properties
  Declare.l GetPropLong(*This.TPropBag, Key$, DefaultValue.l = 0)
  Declare.i SetPropLong(*This.TPropBag, Key$, value.l, Text$="")
  
  Declare.l GetPropColor(*This.TPropBag, Key$, DefaultValue.l = 0)
  Declare.i SetPropColor(*This.TPropBag, Key$, value.l, Text$="")
  
  Declare.q GetPropQuad(*This.TPropBag, Key$, DefaultValue.q = 0)
  Declare.i SetPropQuad(*This.TPropBag, Key$, value.q, Text$="")
  
  Declare.i GetPropRect(*This.TPropBag, Key$, *outRect.RECT)
  Declare.i SetPropRect(*This.TPropBag, Key$, X.l, Y.l, W.l, H.l, Text$="")

  Declare.s GetPropString(*This.TPropBag, Key$, Default$ = "")
  Declare.i SetPropString(*This.TPropBag, Key$, Value.s, Text$="", Font$="", Color=-1)
  
  Declare.i GetPropFont(*This.TPropBag, Key$)
  Declare.i SetPropFont(*This.TPropBag, Key$, Value.s, Text$="")
  
  Declare.i GetPropImage(*This.TPropBag, Key$)
  Declare.i SetPropImage(*This.TPropBag, Key$, File$, Text$="")
  
  Declare.i GetPropSound(*This.TPropBag, Key$)
  Declare.i SetPropSound(*This.TPropBag, Key$, File$, Text$="")
 ; -------
  
  Declare.i SetPropImage(*This.TPropBag, Key$, File$, Text$="")
  
  Declare.i GetPropFlags(*This.TPropBag, Key$)
  Declare.i DeletePropFlags(*This.TPropBag, Key$, Flags=0)
  
  Declare.i SetPropMsgBox(*This.TPropBag, Key$, Title$, Text$="")
  Declare.i MsgBox(*This.TPropBag, Key$, Flags.i = #PB_MessageRequester_Info, PARAM1$="", PARAM2$="")
  
  Declare.i SetPropMenu(*This.TPropBag, Key$, Value$, Text$, TypeFlags.i=#Prop_Flag_Menu)
  
  
  Declare.i BuildTree(*This.TPropBag, Gadget.i)
  
  Declare.i StoreGadgetLayout  (*This.TPropBag, Key$, Gadget.i, StoreFont.i = #False)
  Declare.i RestoreGadgetLayout(*This.TPropBag, Key$, Gadget.i, RestoreFont.i = #False)
  
  Declare.s GetFlagsAsString(Flags.i)
  Declare.i DebugPrintBag(*This.TPropBag, BagName.s)
  
EndDeclareModule

Module PROPS
  
  EnableExplicit
    
  Procedure.s _GetGadgetFont(*This.TPropBag, Gadget.i)
  ; ======================================================================
  ; NAME : _GetGadgetFont
  ; DESC : PureBasic-only platform-independent font string resolver using RAM cache lookup
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance for cache access
  ; VAR(Gadget.i) : The native PureBasic Gadget ID to sample from
  ; RET.s : Standardized CSV font descriptor string ("Name,Size,Style")
  ; ======================================================================
    Protected CurrentFontID.i
    
    If Not *This Or Not IsGadget(Gadget) : ProcedureReturn "" : EndIf
    
    ; Fetch the native OS Font ID handle completely platform-independent
    CurrentFontID = GetGadgetFont(Gadget)
    
    ; If the gadget uses the default system font, it might return 0 or -1
    If CurrentFontID = 0 Or CurrentFontID = -1
      ProcedureReturn "Segoe UI,10,Normal" ; Standard OS fallback descriptor
    EndIf
    
    ; Loop through our own active items to find the matching text string via the OS handle
    ; This completely bypasses the need for OS-specific API structures like LOGFONT!
    ForEach *This\Items()
      If (*This\Items()\Flags & #Prop_Flag_Font) And *This\Items()\osHandle = CurrentFontID
        ProcedureReturn *This\Items()\Source$
      EndIf
    Next
    
    ; Fallback if the font was assigned outside of the Props framework
    ProcedureReturn "Segoe UI,10,Normal"
  EndProcedure  
  
  Procedure.i NewBag()
  ; ======================================================================
  ; NAME : CreateBag
  ; DESC : Allocates memory for a new universal property container bag
  ; RET.i : Pointer to the new TPropBag structure block instance
  ; ======================================================================
    Protected *NewBag.TPropBag = AllocateStructure(TPropBag)
    ProcedureReturn *NewBag
  EndProcedure

  Procedure.i FreeBag(*This.TPropBag)
  ; ======================================================================
  ; NAME : FreeBag
  ; DESC : Safely releases fonts, images, sounds, and structural memory
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; RET.i : True if allocation purge completed successfully, else False
  ; ======================================================================
    If *This
      ForEach *This\Items()
        ; FIXED: Using updated FntMgr namespace
        If (*This\Items()\Flags & #Prop_Flag_Font) And *This\Items()\pbHandle
          FntMgr::ReleaseFont(*This\Items()\pbHandle)
        EndIf
        ; NEW: Support for ImgMgr
        If (*This\Items()\Flags & #Prop_Flag_Image) And *This\Items()\pbHandle
          ImgMgr::ReleaseImage(*This\Items()\pbHandle)
        EndIf
        ; NEW: Support for SndMgr
        If (*This\Items()\Flags & #Prop_Flag_Sound) And *This\Items()\pbHandle
          SndMgr::ReleaseSound(*This\Items()\pbHandle)
        EndIf
      Next
      ClearMap(*This\Items())
      FreeStructure(*This)
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.i LoadBag(*This.TPropBag, FileName$)
  ; ======================================================================
  ; NAME : LoadBag
  ; DESC : Imports a dynamic JSON property mapping into memory structure
  ; VAR(*This.TPropBag) : Pointer to the target property bag instance
  ; VAR(FileName$) : Full path string targeting the local source JSON file
  ; RET.i : True if the document loaded and parsed correctly, else False
  ; ======================================================================
    Protected JsonHandle.i
    If Not *This : ProcedureReturn #False : EndIf
    
    JsonHandle = LoadJSON(#PB_Any, FileName$)
    If JsonHandle
      ForEach *This\Items()
        ; FIXED: Using updated FntMgr namespace
        If (*This\Items()\Flags & #Prop_Flag_Font) And *This\Items()\pbHandle
          FntMgr::ReleaseFont(*This\Items()\pbHandle)
        EndIf
        ; NEW: Support for ImgMgr
        If (*This\Items()\Flags & #Prop_Flag_Image) And *This\Items()\pbHandle
          ImgMgr::ReleaseImage(*This\Items()\pbHandle)
        EndIf
        ; NEW: Support for SndMgr
        If (*This\Items()\Flags & #Prop_Flag_Sound) And *This\Items()\pbHandle
          SndMgr::ReleaseSound(*This\Items()\pbHandle)
        EndIf
      Next
      
      ClearMap(*This\Items())
      ExtractJSONMap(JSONValue(JsonHandle), *This\Items())
      FreeJSON(JsonHandle)
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.i SaveBag(*This.TPropBag, FileName$)
  ; ======================================================================
  ; NAME : SaveBag
  ; DESC : Serializes active container map configurations to formatted JSON data
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(FileName$) : Destination file save path target string
  ; RET.i : True if serialized file output writing succeeded, else False
  ; ======================================================================
    Protected JsonHandle.i
    Protected Result.i = #False
    
    If Not *This : ProcedureReturn #False : EndIf
    
    JsonHandle = CreateJSON(#PB_Any)
    If JsonHandle
      InsertJSONMap(JSONValue(JsonHandle), *This\Items())
      If SaveJSON(JsonHandle, FileName$, #PB_JSON_PrettyPrint)
        Result = #True
      EndIf
      FreeJSON(JsonHandle)
    EndIf
    ProcedureReturn Result
  EndProcedure
  
  ; ======================================================================
  ; NAME : LoadBagEncrypted
  ; DESC : Loads an AES-256 encrypted binary file, decrypts it and populates the map.
  ; ======================================================================
  Procedure.i LoadBagEncrypted(*This.TPropBag, FileName$, Key256$)
    Protected FileHandle.i, StringLen.i, EncryptedLen.i
    Protected *CipherMem, *DecryptedMem, JsonStr.s, JsonHandle.i
    Protected Result.i = #False
    Protected InitVector$ = "1234567890123456"
    
    If Not *This Or Len(Key256$) <> 32 : ProcedureReturn #False : EndIf
    
    FileHandle = ReadFile(#PB_Any, FileName$)
    If FileHandle
      StringLen = ReadLong(FileHandle) ; Read the original text length
      EncryptedLen = Lof(FileHandle) - 4
      
      *CipherMem = AllocateMemory(EncryptedLen)
      *DecryptedMem = AllocateMemory(EncryptedLen)
      
      If *CipherMem And *DecryptedMem
        ReadData(FileHandle, *CipherMem, EncryptedLen)
        CloseFile(FileHandle)
        
        ; Native PureBasic AES Decryption
        If AESDecoder(*CipherMem, *DecryptedMem, EncryptedLen, @Key256$, 256, @InitVector$, #PB_Cipher_CBC)
          
          JsonStr = PeekS(*DecryptedMem, StringLen, #PB_UTF8)
          JsonHandle = ParseJSON(#PB_Any, JsonStr)
          
          If JsonHandle
            ; Safely free RAM assets before rewriting the bag
            ForEach *This\Items()
              If (*This\Items()\Flags & #Prop_Flag_Font) And *This\Items()\pbHandle  : FntMgr::ReleaseFont(*This\Items()\pbHandle)  : EndIf
              If (*This\Items()\Flags & #Prop_Flag_Image) And *This\Items()\pbHandle : ImgMgr::ReleaseImage(*This\Items()\pbHandle) : EndIf
              If (*This\Items()\Flags & #Prop_Flag_Sound) And *This\Items()\pbHandle : SndMgr::ReleaseSound(*This\Items()\pbHandle) : EndIf
            Next
            
            ClearMap(*This\Items())
            ExtractJSONMap(JSONValue(JsonHandle), *This\Items())
            FreeJSON(JsonHandle)
            Result = #True
          EndIf
          
        EndIf
      EndIf
      
      If *CipherMem : FreeMemory(*CipherMem) : EndIf
      If *DecryptedMem : FreeMemory(*DecryptedMem) : EndIf
    EndIf
    
    ProcedureReturn Result
  EndProcedure

  ; ======================================================================
  ; NAME : SaveBagEncrypted
  ; DESC : Serializes the map to JSON, encrypts it via AES-256 and saves it.
  ; VAR(Key256$) : Must be exactly 32 characters long for AES-256!
  ; ======================================================================
  Procedure.i SaveBagEncrypted(*This.TPropBag, FileName$, Key256$)
    Protected JsonHandle.i, JsonStr.s, StringLen.i, EncryptedLen.i
    Protected *StringMem, *CipherMem, FileHandle.i
    Protected Result.i = #False
    Protected InitVector$ = "1234567890123456" ; 16 Byte Initialization Vector
    
    If Not *This Or Len(Key256$) <> 32 : ProcedureReturn #False : EndIf
    
    JsonHandle = CreateJSON(#PB_Any)
    If JsonHandle
      InsertJSONMap(JSONValue(JsonHandle), *This\Items())
      JsonStr = ComposeJSON(JsonHandle) 
      FreeJSON(JsonHandle)
      
      ; Calculate memory bounds (UTF-8 format ensures cross-platform stability)
      StringLen = StringByteLength(JsonStr, #PB_UTF8)
      
      ; AES requires data padded to 16-byte blocks
      EncryptedLen = ((StringLen / 16) + 1) * 16
      
      *StringMem = AllocateMemory(EncryptedLen)
      *CipherMem = AllocateMemory(EncryptedLen)
      
      If *StringMem And *CipherMem
        PokeS(*StringMem, JsonStr, StringLen, #PB_UTF8)
        
        ; Native PureBasic hardware-accelerated AES Encryption
        If AESEncoder(*StringMem, *CipherMem, EncryptedLen, @Key256$, 256, @InitVector$, #PB_Cipher_CBC)
          
          FileHandle = CreateFile(#PB_Any, FileName$)
          If FileHandle
            ; Write the unencrypted real length first so the loader knows where to cut
            WriteLong(FileHandle, StringLen) 
            ; Write the encrypted block data
            WriteData(FileHandle, *CipherMem, EncryptedLen)
            CloseFile(FileHandle)
            Result = #True
          EndIf
          
        EndIf
      EndIf
      
      If *StringMem : FreeMemory(*StringMem) : EndIf
      If *CipherMem : FreeMemory(*CipherMem) : EndIf
    EndIf
    
    ProcedureReturn Result
  EndProcedure

  Procedure.l GetPropLong(*This.TPropBag, Key$, DefaultValue.l = 0)
  ; ======================================================================
  ; NAME : GetPropertyLong
  ; DESC : Retrieves a specific 32-bit long element from the numeric array slot
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(Key$) : Target property map key string
  ; VAR(Index.i) : Array element index to query (Valid range: 0 to 3)
  ; VAR(DefaultValue.l) : Fallback configuration value if lookup fails
  ; RET.l : Returns the targeted Numeric long value, or default if not found
  ; ======================================================================
    
    If *This And FindMapElement(*This\Items(), Key$)
      ProcedureReturn *This\Items(Key$)\DataL[#Prop_idx_Long]
    EndIf
    ProcedureReturn DefaultValue
  EndProcedure

  Procedure.i SetPropLong(*This.TPropBag, Key$, value.l, Text$="")
  ; ======================================================================
  ; NAME : SetPropertyLong
  ; DESC : Writes a 32-bit long integer 
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(Key$) : Unique alphanumeric identification access key string
  ; VAR(value.l) : The value
  ; VAR(Description.s) : Optional human-readable metadata context
  ; RET.i : True if operation finished successfully, else False
  ; ======================================================================
    
    If Not *This : ProcedureReturn #False : EndIf
    
    If FindMapElement(*This\Items(), Key$) And (*This\Items(Key$)\Flags & #Prop_Flag_Font)
      If *This\Items(Key$)\pbHandle <> 0 And IsFont(*This\Items(Key$)\pbHandle)
        FreeFont(*This\Items(Key$)\pbHandle)
      EndIf
    EndIf
    
    *This\Items(Key$)\Key$        = Key$
    *This\Items(Key$)\Flags       | #Prop_Flag_Long
    *This\Items(Key$)\pbHandle    = 0
    *This\Items(Key$)\osHandle    = 0
    *This\Items(Key$)\Value$ = #Null$
    
    *This\Items(Key$)\DataL[#Prop_idx_Long]  = value
    
    If Text$ <> ""
      *This\Items(Key$)\Text$ = Text$
    EndIf
    ProcedureReturn #True
  EndProcedure
  
  Procedure.l GetPropColor(*This.TPropBag, Key$, DefaultValue.l = 0)
  ; ======================================================================
  ; NAME : GetPropColor
  ; DESC : Retrieves a specific 32-bit long element from the numeric array slot
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(Key$) : Target property map key string
  ; VAR(Index.i) : Array element index to query (Valid range: 0 to 3)
  ; VAR(DefaultValue.l) : Fallback configuration value if lookup fails
  ; RET.l : Returns the targeted Color value, or default if not found
  ; ======================================================================
    
    If *This And FindMapElement(*This\Items(), Key$)
      ProcedureReturn *This\Items(Key$)\DataL[#Prop_idx_Color]
    EndIf
    ProcedureReturn DefaultValue
  EndProcedure
  
  Procedure.i SetPropColor(*This.TPropBag, Key$, color.l, Text$="")
  ; ======================================================================
  ; NAME : SetPropertyColor
  ; DESC : Writes up a 32-bit color integer metrics into 
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(Key$) : Unique alphanumeric identification access key string
  ; VAR(value.l) : The value
  ; VAR(Description.s) : Optional human-readable metadata context
  ; RET.i : True if operation finished successfully, else False
  ; ======================================================================
    If Not *This : ProcedureReturn #False : EndIf
    
    If FindMapElement(*This\Items(), Key$) And (*This\Items(Key$)\Flags & #Prop_Flag_Font)
      If *This\Items(Key$)\pbHandle <> 0 And IsFont(*This\Items(Key$)\pbHandle)
        FreeFont(*This\Items(Key$)\pbHandle)
      EndIf
    EndIf
    
    *This\Items(Key$)\Key$       = Key$
    *This\Items(Key$)\Flags      | #Prop_Flag_Color
    *This\Items(Key$)\pbHandle   = 0
    *This\Items(Key$)\osHandle   = 0
    *This\Items(Key$)\Value$     = #Null$
    
    *This\Items(Key$)\DataL[#Prop_idx_Color]  = Color
    
    If Text$ <> ""
      *This\Items(Key$)\Text$ = Text$
    EndIf
    ProcedureReturn #True
  EndProcedure
  
  Procedure.q GetPropQuad(*This.TPropBag, Key$, DefaultValue.q = 0)
  ; ======================================================================
  ; NAME : GetPropertyQuad
  ; DESC : Merges two adjacent 32-bit longs into a single high-capacity 64-bit quad integer
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(Key$) : Target property map key string
  ; VAR(Index.i) : Target slot configuration index (1 = Quad from Long 0+1, 2 = Quad from Long 2+3)
  ; VAR(DefaultValue.q) : Fallback configuration quad value if lookup fails
  ; RET.q : Returns the combined 64-bit quad value, or default if not found
  ; ======================================================================
    Protected *pQuad.Quad
    If *This And FindMapElement(*This\Items(), Key$)
      *pQuad = @*This\Items(Key$)\DataL[#Prop_idx_Quad]
      ProcedureReturn *pQuad\q
    EndIf
    ProcedureReturn DefaultValue
  EndProcedure

  Procedure.i SetPropQuad(*This.TPropBag, Key$, value.q, Text$="")
  ; ======================================================================
  ; NAME : SetPropertyQuad
  ; DESC : Splits and writes up to two independent 64-bit quad integers into the long slots
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(Key$) : Unique alphanumeric identification access key string
  ; VAR(value.q) : The value
  ; VAR(Text$) : Optional human-readable metadata context
  ; RET.i : True if operation finished successfully, else False
  ; ======================================================================
    Protected *pQuad.Quad
    If Not *This : ProcedureReturn #False : EndIf
    
    If FindMapElement(*This\Items(), Key$) And (*This\Items(Key$)\Flags & #Prop_Flag_Font)
      If *This\Items(Key$)\pbHandle <> 0 And IsFont(*This\Items(Key$)\pbHandle)
        FreeFont(*This\Items(Key$)\pbHandle)
      EndIf
    EndIf
    
    *This\Items(Key$)\Key$    = Key$
    *This\Items(Key$)\Flags   | #Prop_Flag_Quad
      
    ; Map pointer 0 to elements 0+1 
    *pQuad = @*This\Items(Key$)\DataL[#Prop_idx_Quad]
    
    *pQuad\q = value
    
    If Text$ <> ""
      *This\Items(Key$)\Text$ = Text$
    EndIf
    ProcedureReturn #True
  EndProcedure
  
  Procedure.i GetPropRect(*This.TPropBag, Key$, *OutRect.RECT)
  ; ======================================================================
  ; NAME : GetPropRect
  ; DESC : Populates a native PureBasic RECT structure pointer with all 4 stored coordinates
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(Key$) : Target property map key string containing the Rect data
  ; VAR(*OutRect.RECT) : Pointer to the destination RECT structure to populate
  ; RET.i : True if the key was found and RECT populated, else False
  ; ======================================================================
    If Not *This Or Not *OutRect : ProcedureReturn #False : EndIf
    
    If FindMapElement(*This\Items(), Key$)
      If (*This\Items(Key$)\Flags & #Prop_Flag_Long)
        ; Copy all 4 elements directly into the fields of the native PB RECT structure
        *OutRect\left   = *This\Items(Key$)\DataL[0]
        *OutRect\top    = *This\Items(Key$)\DataL[1]
        *OutRect\right  = *This\Items(Key$)\DataL[2] ; Width
        *OutRect\bottom = *This\Items(Key$)\DataL[3] ; Height
        ProcedureReturn #True
      EndIf
    EndIf
    
    ProcedureReturn #False
  EndProcedure
  
  Procedure.i SetPropRect(*This.TPropBag, Key$, X.l, Y.l, W.l, H.l, Text$="")
  ; ======================================================================
  ; NAME : SetPropRect
  ; DESC : Writes a complete 4-element coordinate bounding box (X, Y, Width, Height)
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(Key$) : Unique alphanumeric identification access key string
  ; VAR(X.l / Y.l / W.l / H.l) : The four coordinate bounding long values
  ; VAR(Description.s) : Optional human-readable metadata context
  ; RET.i : True if operation finished successfully, else False
  ; ======================================================================
    
    If Not *This : ProcedureReturn #False : EndIf
    
    ; Clear potentially old font resources under the same key to prevent memory leaks
    If FindMapElement(*This\Items(), Key$) And (*This\Items(Key$)\Flags & #Prop_Flag_Font)
      If *This\Items(Key$)\pbHandle <> 0 And IsFont(*This\Items(Key$)\pbHandle)
        FreeFont(*This\Items(Key$)\pbHandle)
      EndIf
    EndIf
    
    *This\Items(Key$)\Key$     = Key$
    *This\Items(Key$)\Flags    | #Prop_Flag_RECT
     
    ; Pack all 4 layout fields into the native array structure slots
    *This\Items(Key$)\DataL[0] = X
    *This\Items(Key$)\DataL[1] = Y
    *This\Items(Key$)\DataL[2] = W
    *This\Items(Key$)\DataL[3] = H
    
    If Text$ <> ""
      *This\Items(Key$)\Text$ = Text$
    EndIf
    ProcedureReturn #True
  EndProcedure
  
  Procedure.s GetPropString(*This.TPropBag, Key$, Default$ = "")
  ; ======================================================================
  ; NAME : GetPropertyString
  ; DESC : Direct high-speed retrieval pipeline for text configuration data
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(Key$) : Target property map key string
  ; VAR(Default$) : Fallback configuration value if key lookup fails
  ; RET.s : Returns raw StringValue text data, or default if not found
  ; ======================================================================
    
    If *This And FindMapElement(*This\Items(), Key$)
      ProcedureReturn *This\Items(Key$)\Value$
    EndIf
    
    ProcedureReturn Default$
  EndProcedure
 
  Procedure.i SetPropString(*This.TPropBag, Key$, Value$, Text$="", Font$="", Color=-1)
  ; ======================================================================
  ; NAME : SetPropertyString
  ; DESC : Writes text configuration descriptors or font configuration paths
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(Key$) : Unique alphanumeric identification access key string
  ; VAR(Value$) : The raw string text layout or CSV font descriptor data
  ; VAR(Description.s) : Optional human-readable metadata context
  ; RET.i : True if operation finished successfully, else False
  ; ======================================================================
        
    If Not *This : ProcedureReturn #False : EndIf
    
     
    *This\Items(Key$)\Key$    = Key$
    *This\Items(Key$)\Flags   | #Prop_Flag_String
    *This\Items(Key$)\Value$  = Value$
        
    If Text$ <> ""
      *This\Items(Key$)\Text$ = Text$
    EndIf
    
    If Color <> -1
      *This\Items(Key$)\DataL[#Prop_idx_Color] = Color 
      *This\Items(Key$)\Flags  | #Prop_Flag_Color
    EndIf
    
    If Key$ <> ""
      If FindMapElement(*This\Items(), Key$) And (*This\Items(Key$)\Flags & #Prop_Flag_Font)
        If *This\Items(Key$)\pbHandle <> 0 And IsFont(*This\Items(Key$)\pbHandle)
          ; NEW: Use custom Font Manager to prevent multi loading of Fonts 
          FntMgr::ReleaseFont(*This\Items(Key$)\pbHandle)
          ; FreeFont(*This\Items(Key$)\pbHandle)
        EndIf
      EndIf
      
      *This\Items(Key$)\Flags      | #Prop_Flag_Font
      *This\Items(Key$)\pbHandle   = 0
      *This\Items(Key$)\osHandle   = 0
      *This\Items(Key$)\Source$    = Font$

    EndIf
  
    ProcedureReturn #True
  EndProcedure
  
  Procedure.i GetPropFont(*This.TPropBag, Key$)
  ; ======================================================================
  ; NAME : GetPropertyFont
  ; DESC : High-speed Font pipeline utilizing a leak-free caching engine
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(Key$) : Target property map key lookup string
  ; RET.i : The cached native PureBasic FontID handle, or 0 if failed
  ; ======================================================================
    Protected.i pbFont, Size
    Protected.i Flags = #PB_Font_HighQuality
    Protected.s Name, RawStyle
    
    If *This And FindMapElement(*This\Items(), Key$)
      If (*This\Items(Key$)\Flags & #Prop_Flag_Font) And *This\Items(Key$)\Source$ <> ""
        
        ; Optimization: Return cached handle instantly if font is already compiled
        If *This\Items(Key$)\osHandle <> 0 And IsFont(*This\Items(Key$)\pbHandle)
          ProcedureReturn *This\Items(Key$)\osHandle
        EndIf
        
        ; Parse CSV token sequences out of descriptor string
        Name = Trim(StringField(*This\Items(Key$)\Source$, 1, ","))
        Size = Val(Trim(StringField(*This\Items(Key$)\Source$, 2, ",")))
        RawStyle = LCase(Trim(StringField(*This\Items(Key$)\Source$, 3, ",")))
        
        If FindString(RawStyle, "bold")   : Flags | #PB_Font_Bold   : EndIf
        If FindString(RawStyle, "italic") : Flags | #PB_Font_Italic : EndIf
        
        ; NEW: use custom FontManger to prevent multi loads of the same Font
        pbFont = FntMgr::GetFontHandle(Name, Size, Flags)
        ; pbFont = LoadFont(#PB_Any, Name, Size, Flags)
      
        If pbFont
          *This\Items(Key$)\pbHandle = pbFont
          *This\Items(Key$)\osHandle   = FontID(pbFont)
          ProcedureReturn *This\Items(Key$)\osHandle
        EndIf
      EndIf
    EndIf
    ProcedureReturn 0
  EndProcedure
 
  Procedure.i SetPropFont(*This.TPropBag, Key$, Font$, Text$="")
  ; ======================================================================
  ; NAME : SetPropertyFont
  ; DESC : Writes a font configuration CSV descriptor string into the bag
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(Key$) : Unique alphanumeric identification access key string
  ; VAR(Font$) : The font configuration string formatted as CSV ("Name,Size,Style")
  ; VAR(Text$) : Optional human-readable metadata context
  ; RET.i : True if operation finished successfully, else False
  ; ======================================================================
    
    If Not *This : ProcedureReturn #False : EndIf
    
    ; Clear potentially old font resources under the same key to prevent memory leaks
    If FindMapElement(*This\Items(), Key$) And (*This\Items(Key$)\Flags & #Prop_Flag_Font)
      If *This\Items(Key$)\pbHandle <> 0 And IsFont(*This\Items(Key$)\pbHandle)
        ; NEW: Use custom Font Manager to prevent multi loading of Fonts 
        FntMgr::ReleaseFont(*This\Items(Key$)\pbHandle)
        ; FreeFont(*This\Items(Key$)\pbHandle)
      EndIf
    EndIf
    
    *This\Items(Key$)\Key$       = Key$
    *This\Items(Key$)\Flags      | #Prop_Flag_Font
    *This\Items(Key$)\pbHandle   = 0
    *This\Items(Key$)\osHandle   = 0
    *This\Items(Key$)\Source$    = Font$
        
    If Text$ <> ""
      *This\Items(Key$)\Text$ = Text$
    EndIf
    
    ProcedureReturn #True
  EndProcedure
  
  Procedure.i GetPropImage(*This.TPropBag, Key$)
  ; ======================================================================
  ; NAME : GetPropImage
  ; DESC : Resolves and returns the PB Image Number using the ImgMgr cache.
  ; DESC : Loads the asset dynamically if not compiled yet.
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(Key$) : Target property map key lookup string
  ; RET.i : The cached native PureBasic #Image handle, or 0 if failed
  ; ======================================================================
    If *This And FindMapElement(*This\Items(), Key$)
      If (*This\Items(Key$)\Flags & #Prop_Flag_Image) And *This\Items(Key$)\Source$ <> ""
        
        ; 1. Return cached handle instantly if image is already active
        If *This\Items(Key$)\pbHandle <> 0 And IsImage(*This\Items(Key$)\pbHandle)
          ProcedureReturn *This\Items(Key$)\pbHandle
        EndIf
        
        ; 2. Request image via Key and FilePath stored in Source$ from ImgMgr
        Protected pbImg = ImgMgr::GetImageHandle(Key$, *This\Items(Key$)\Source$)
        If pbImg
          *This\Items(Key$)\pbHandle = pbImg
          ProcedureReturn pbImg
        EndIf
      EndIf
    EndIf
    ProcedureReturn 0
  EndProcedure
 
  Procedure.i SetPropImage(*This.TPropBag, Key$, File$, Text$="")
  ; ======================================================================
  ; NAME : SetPropImage
  ; DESC : Registers an image asset file path into Source$ and safely
  ; DESC : releases any existing tracked image allocation under this key.
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(Key$) : Unique alphanumeric identification access key string
  ; VAR(File$) : The file path to the image
  ; VAR(Text$) : Optional description or metadata context text
  ; RET.i : True if operation finished successfully, else False
  ; ======================================================================
    If Not *This : ProcedureReturn #False : EndIf
    
    ; Safely release old image resource via ImgMgr before overwriting
    If FindMapElement(*This\Items(), Key$) And (*This\Items(Key$)\Flags & #Prop_Flag_Image)
      If *This\Items(Key$)\pbHandle <> 0
        ImgMgr::ReleaseImage(*This\Items(Key$)\pbHandle)
      EndIf
    EndIf
    
    *This\Items(Key$)\Key$       = Key$
    *This\Items(Key$)\Flags      = #Prop_Flag_Image
    *This\Items(Key$)\Source$    = File$  ; Stored in unified Source$ field
    *This\Items(Key$)\Value$     = #Null$ ; Kept clean for localization titles/texts
    *This\Items(Key$)\Text$      = Text$
    *This\Items(Key$)\pbHandle   = 0
    *This\Items(Key$)\osHandle   = 0
    ProcedureReturn #True
  EndProcedure  
  
  Procedure.i GetPropSound(*This.TPropBag, Key$)
  ; ======================================================================
  ; NAME : GetPropSound
  ; DESC : Resolves and returns the PB Sound Number using the SndMgr cache.
  ; DESC : Loads the asset dynamically if not compiled yet.
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(Key$) : Target property map key lookup string
  ; RET.i : The cached native PureBasic #Sound handle, or 0 if failed
  ; ======================================================================
    If *This And FindMapElement(*This\Items(), Key$)
      If (*This\Items(Key$)\Flags & #Prop_Flag_Sound) And *This\Items(Key$)\Source$ <> ""
        
        ; 1. Return cached handle instantly if sound is already active
        If *This\Items(Key$)\pbHandle <> 0 And IsSound(*This\Items(Key$)\pbHandle)
          ProcedureReturn *This\Items(Key$)\pbHandle
        EndIf
        
        ; 2. Request sound via Key and FilePath stored in Source$ from SndMgr
        Protected pbSnd = SndMgr::GetSoundHandle(Key$, *This\Items(Key$)\Source$)
        If pbSnd
          *This\Items(Key$)\pbHandle = pbSnd
          ProcedureReturn pbSnd
        EndIf
      EndIf
    EndIf
    ProcedureReturn 0
  EndProcedure

  Procedure.i SetPropSound(*This.TPropBag, Key$, File$, Text$="")
  ; ======================================================================
  ; NAME : SetPropSound
  ; DESC : Registers a sound asset file path into Source$ and safely
  ; DESC : releases any existing tracked sound allocation under this key.
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(Key$) : Unique alphanumeric identification access key string
  ; VAR(File$) : The file path to the sound file
  ; VAR(Text$) : Optional description or metadata context text
  ; RET.i : True if operation finished successfully, else False
  ; ======================================================================
    If Not *This : ProcedureReturn #False : EndIf
    
    ; Safely release old sound resource via SndMgr before overwriting
    If FindMapElement(*This\Items(), Key$) And (*This\Items(Key$)\Flags & #Prop_Flag_Sound)
      If *This\Items(Key$)\pbHandle <> 0
        SndMgr::ReleaseSound(*This\Items(Key$)\pbHandle)
      EndIf
    EndIf
    
    *This\Items(Key$)\Key$       = Key$
    *This\Items(Key$)\Flags      = #Prop_Flag_Sound
    *This\Items(Key$)\Source$    = File$  ; Stored in unified Source$ field
    *This\Items(Key$)\Value$     = #Null$ ; Kept clean for localization titles/texts
    *This\Items(Key$)\Text$      = Text$
    *This\Items(Key$)\pbHandle   = 0
    *This\Items(Key$)\osHandle   = 0
    ProcedureReturn #True
  EndProcedure
  
  Procedure.i GetPropFlags(*This.TPropBag, Key$)
    If Not *This : ProcedureReturn #False : EndIf
    
    If FindMapElement(*This\Items(), Key$)    
      ProcedureReturn *This\Items(Key$)\Flags
    EndIf
  EndProcedure
  
  Procedure.i DeletePropFlags(*This.TPropBag, Key$, Flags=0)
    If Not *This : ProcedureReturn #False : EndIf
    
    If FindMapElement(*This\Items(), Key$)
      *This\Items(Key$)\Flags & (~Flags)
      ProcedureReturn #True
    EndIf 
  EndProcedure
  
  Procedure.i SetPropMsgBox(*This.TPropBag, Key$, Title$, Text$="")
  ; ======================================================================
  ; NAME : SetPropMsgBox
  ; DESC : Writes text configuration descriptors or font configuration paths
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(Key$) : Unique alphanumeric identification access key string
  ; VAR(Title$,) : The MessageBox Titel
  ; VAR(Text$) : The MessageBox Text with Param Placeholder {PARAM1} {PARAM2}
  ; RET.i : True if operation finished successfully, else False
  ; ======================================================================
        
    If Not *This : ProcedureReturn #False : EndIf
    
    *This\Items(Key$)\Key$    = Key$
    *This\Items(Key$)\Flags   = #Prop_Flag_MsgBox
    *This\Items(Key$)\Value$  = Title$    
    *This\Items(Key$)\Text$   = Text$
      
    ProcedureReturn #True
  EndProcedure
 
  Procedure.i MsgBox(*This.TPropBag, Key$, Flags.i = #PB_MessageRequester_Info, PARAM1$="", PARAM2$="")
  ; ======================================================================
  ; NAME : MsgBox
  ; DESC : Show a PB MessageRequester() using localization tokens from Props
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(Key$) : Target property map key lookup string for the message body text
  ; VAR(Flags.i) : Native PureBasic MessageRequester flag configurations (Icon, Buttons)
  ; VAR(PARAM1$) : String which will replace {PARAM1}
  ; VAR(PARAM2$) : String which will replace {PARAM2}
  ; RET.i : Result of MessageReqeuster() - #PB_MessageRequester_Yes _No _Cancel
  ; ======================================================================
    Protected Text$, Titel$
    
    If Not *This : ProcedureReturn 0 : EndIf
    
    ; CORRECT ASSIGNMENT: Fetch fields directly from the Map Element
    If FindMapElement(*This\Items(), Key$)
      Titel$ = *This\Items(Key$)\Value$  ; <-- Title is stored in Value$ ("Welcome Back")
      Text$  = *This\Items(Key$)\Text$   ; <-- Message Body is stored in Text$ ("Hello {PARAM1}...")
    EndIf
    
    If Text$ = "" 
      Text$ = #PB_Compiler_Module + "::" + #PB_Compiler_Procedure + " - [MISSING UI TOKEN: " + Key$ + "]"
    EndIf
   
    If PARAM1$ : Text$ = ReplaceString(Text$, "{PARAM1}", PARAM1$) : EndIf
    If PARAM2$ : Text$ = ReplaceString(Text$, "{PARAM2}", PARAM2$) : EndIf
         
    ProcedureReturn MessageRequester(Titel$, Text$, Flags)
  EndProcedure  
  Procedure.i SetPropMenu(*This.TPropBag, Key$, Value$, Text$, TypeFlags.i=#Prop_Flag_Menu)
  ; ======================================================================
  ; NAME : SetPropMenu
  ; DESC : Writes text configuration descriptors or font configuration paths
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(Key$) : Unique alphanumeric identification access key string
  ; VAR(Value$) : The raw string text layout or CSV font descriptor data
  ; VAR(Text$.) : Text of Menu. Titel or Item
  ; VAR(TypeFlags) : Menu Type Flags Titel or Item    
  ; RET.i : True if operation finished successfully, else False
  ; ======================================================================
        
    If Not *This : ProcedureReturn #False : EndIf
        
    *This\Items(Key$)\Key$    = Key$
    *This\Items(Key$)\Flags   = TypeFlags
    *This\Items(Key$)\Value$  = Value$        
    *This\Items(Key$)\Text$ = Text$
  
    ProcedureReturn #True
  EndProcedure

  Procedure.i BuildTree(*This.TPropBag, TreeGadget.i)
  ; ======================================================================
  ; NAME : BuildTree
  ; DESC : Parses all path-based keys ("Node/SubNode/Key") and populates a PB TreeGadget
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(TreeGadget.i) : The native PureBasic TreeGadget ID to populate
  ; RET.i : True if the tree was built successfully, else False
  ; ======================================================================
    
    Protected NewList SortedKeys.s()
    Protected Key$, Part.s, DisplayText.s
    Protected SlashCount.i, Depth.i, i.i
    
    If Not *This Or Not IsGadget(TreeGadget) : ProcedureReturn #False : EndIf
    
    ; 1. Extract and sort keys alphabetally to guarantee structural tree order
    ForEach *This\Items()
      AddElement(SortedKeys())
      SortedKeys() = *This\Items()\Key$
    Next
    SortList(SortedKeys(), #PB_Sort_Ascending | #PB_Sort_NoCase)
    
    ; 2. Clear target gadget before injection
    ClearGadgetItems(TreeGadget)
    
    ; 3. Process sorted streams onto the TreeGadget stack
    ForEach SortedKeys()
      Key$ = SortedKeys()
      
      ; Count slashes to automatically determine the nesting depth
      SlashCount = CountString(Key$, "/")
      Depth = SlashCount
      
      ; Extract only the final element name for clean visual display layout
      If SlashCount > 0
        DisplayText = StringField(Key$, SlashCount + 1, "/")
      Else
        DisplayText = Key$
      EndIf
      
      ; Optional: Add missing parent virtual folder nodes if they don't exist explicitly
      ; (PureBasic TreeGadget safely handles direct sub-depth injections natively)
      AddGadgetItem(TreeGadget, -1, DisplayText, 0, Depth)
      
      ; Store the actual map key reference string into the item data slot for easy event queries
      SetGadgetItemData(TreeGadget, CountGadgetItems(TreeGadget) - 1, FindMapElement(*This\Items(), Key$))
    Next
    
    ClearList(SortedKeys())
    ProcedureReturn #True
  EndProcedure
    
  Procedure.i StoreGadgetLayout(*This.TPropBag, Key$, Gadget.i, StoreFont.i = #False)
  ; ======================================================================
  ; NAME : StoreGadgetLayout
  ; DESC : Reads live coordinates and optionally typography profiles into a binary-typed slot
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(Key$) : Target property map key string (e.g., "Layout/MainWindow/BtnSave")
  ; VAR(Gadget.i) : The native PureBasic Gadget ID to sample from
  ; VAR(SaveFont.i) : Optional flag. If True, type becomes #Prop_Numeric | #Prop_Font and font is saved
  ; RET.i : True if operations succeeded, else False
  ; ======================================================================
    Protected TargetFlags.i = #Prop_Flag_Long
    Protected FontData$
    
    If Not *This Or Not IsGadget(Gadget) : ProcedureReturn #False : EndIf
    
    If StoreFont
      TargetFlags = #Prop_Flag_Long | #Prop_Flag_Font
      ; Safely passing the *This pointer down into the private procedure!
      FontData$ = _GetGadgetFont(*This, Gadget)
    EndIf
    
    If FindMapElement(*This\Items(), Key$) And *This\Items(Key$)\Flags & #Prop_Flag_Font
      If *This\Items(Key$)\pbHandle <> 0 And IsFont(*This\Items(Key$)\pbHandle)
        ; NEW: Use custom Font Manager to prevent multi loading of Fonts 
        FntMgr::ReleaseFont(*This\Items(Key$)\pbHandle)
        ; FreeFont(*This\Items(Key$)\pbHandle)
      EndIf
    EndIf
    
    *This\Items(Key$)\Key$     = Key$
    *This\Items(Key$)\Flags    = TargetFlags
    *This\Items(Key$)\pbHandle = 0
    *This\Items(Key$)\osHandle = 0
    *This\Items(Key$)\Source$    = FontData$
    *This\Items(Key$)\Text$    = ""
    
    *This\Items(Key$)\DataL[0] = GadgetX(Gadget)
    *This\Items(Key$)\DataL[1] = GadgetY(Gadget)
    *This\Items(Key$)\DataL[2] = GadgetWidth(Gadget)
    *This\Items(Key$)\DataL[3] = GadgetHeight(Gadget)
    
    ProcedureReturn #True
  EndProcedure

  Procedure.i RestoreGadgetLayout(*This.TPropBag, Key$, Gadget.i, RestoreFont.i = #False)
  ; ======================================================================
  ; NAME : RestoreGadgetLayout
  ; DESC : Retrieves coordinate bounds via GetPropRect and resizes the target PB gadget
  ; VAR(*This.TPropBag) : Pointer to the active property bag instance
  ; VAR(Key$) : Target property map key string containing the layout data
  ; VAR(Gadget.i) : The native PureBasic Gadget ID to resize
  ; VAR(RestoreFont.i) : Optional flag. If True and item contains font data, applies font instantly
  ; RET.i : True if the gadget was successfully resized, else False
  ; ======================================================================
    Protected ComponentBounds.RECT
    Protected TargetFontID.i
    
    If Not *This Or Not IsGadget(Gadget) : ProcedureReturn #False : EndIf
    
    ; Use pointer-based GetPropRect engine to safely extract all coordinates at once
    If GetPropRect(*This, Key$, ComponentBounds)
      
      ; Execute native OS resizing pipeline
      ResizeGadget(Gadget, ComponentBounds\left, ComponentBounds\top, ComponentBounds\right, ComponentBounds\bottom)
      
      ; USER CONTROL CHECK: Apply font choice explicitly passed via parameter condition
      If RestoreFont And (*This\Items(Key$)\Flags & #Prop_Flag_Font)
        TargetFontID = GetPropFont(*This, Key$)
        If TargetFontID
          SetGadgetFont(Gadget, TargetFontID)
        EndIf
      EndIf
      
      ProcedureReturn #True
    EndIf
    
    ProcedureReturn #False
  EndProcedure  
  
  Procedure.s GetFlagsAsString(Flags.i)
  ; ======================================================================
  ; NAME : GetFlagsAsString
  ; DESC : Converts binary flag combinations into a human-readable CSV string.
  ; VAR(Flags.i) : The composite binary flags bitmask to analyze
  ; RET.s : Formatted text sequence (e.g., "[ Long, Color ]"), or "[ None ]"
  ; ======================================================================
    Protected FlagStr.s = ""
    
    If Flags & #Prop_Flag_Long        : FlagStr + "Long, "        : EndIf
    If Flags & #Prop_Flag_Color       : FlagStr + "Color, "       : EndIf
    If Flags & #Prop_Flag_Quad        : FlagStr + "Quad, "        : EndIf
    If Flags & #Prop_Flag_RECT        : FlagStr + "RECT, "        : EndIf
    If Flags & #Prop_Flag_String      : FlagStr + "String, "      : EndIf
    If Flags & #Prop_Flag_MsgBox      : FlagStr + "MsgBox, "      : EndIf
    If Flags & #Prop_Flag_Font        : FlagStr + "Font, "        : EndIf
    If Flags & #Prop_Flag_Menu        : FlagStr + "Menu, "        : EndIf
    If Flags & #Prop_Flag_MenuTitel   : FlagStr + "MenuTitle, "   : EndIf
    If Flags & #Prop_Flag_MenuSubtitel : FlagStr + "MenuSubtitle, " : EndIf
    If Flags & #Prop_Flag_Image       : FlagStr + "Image, "       : EndIf
    If Flags & #Prop_Flag_Sound       : FlagStr + "Sound, "       : EndIf
    
    If FlagStr <> ""
      ProcedureReturn "[ Active Types: " + Left(FlagStr, Len(FlagStr) - 2) + " ]"
    EndIf
    
    ProcedureReturn "[ Active Types: None ]"
  EndProcedure
  
  Procedure.i DebugPrintBag(*This.TPropBag, BagName.s)
  ; ======================================================================
  ; NAME : DebugPrintBag
  ; DESC : Iterates through database storage map stacks and routes metrics to console.
  ; DESC : Now supports visual output tracking for Images and Sounds.
  ; VAR(*This.TPropBag) : Pointer to the target active property bag instance
  ; VAR(BagName.s) : Decorative name string for debugging header formatting
  ; RET.i : True if process execution map finished scan loop, else False
  ; ======================================================================
    If Not *This : ProcedureReturn #False : EndIf
    Debug "--- Universal Binary Properties: [" + BagName + "] ---"
    ForEach *This\Items()
      Protected TypeStr.s = ""
      If *This\Items()\Flags & #Prop_Flag_Long   : TypeStr + "Long "   : EndIf
      If *This\Items()\Flags & #Prop_Flag_RECT   : TypeStr + "RECT "   : EndIf
      If *This\Items()\Flags & #Prop_Flag_String : TypeStr + "String " : EndIf
      If *This\Items()\Flags & #Prop_Flag_Font   : TypeStr + "Font "   : EndIf
      If *This\Items()\Flags & #Prop_Flag_Image  : TypeStr + "Image "  : EndIf
      If *This\Items()\Flags & #Prop_Flag_Sound  : TypeStr + "Sound "  : EndIf
      
      Debug "  Key: " + *This\Items()\Key$ + " | Flags: [" + Trim(TypeStr) + "] | Val0: " + Str(*This\Items()\DataL[0]) + " | Str: '" + *This\Items()\Value$ + "'"
    Next
    ProcedureReturn #True
  EndProcedure
  
EndModule

;- =====================================================================
;- REAL EXECUTION TEST CODE (Unified Framework & TreeView Sandbox)
;- =====================================================================

CompilerIf #PB_Compiler_IsMainFile
  
  ; 1. Initialize our single unified property bag instance
  Define *AppProps.Props::TPropBag = Props::NewBag()
  
  ; 2. Populate the bag with hierarchical and standard production tokens
  ; --- TreeView Paths (Category Nodes) ---
     
  Props::SetPropString(*AppProps, "Config/General/Language",   "English", "App core language token")
  Props::SetPropLong  (*AppProps, "Config/Network/ServerPort", 8080, "Target bound socket interface port")
  Props::SetPropString(*AppProps, "Config/Network/ProxyIP",  "192.168.1.100", "Proxy address bypass routing")
  
  ; --- Visual Identity & Styling Tokens ---
  Props::SetPropColor(*AppProps, "Theme/Colors/WindowBg",   RGB($2C, $3E, $50), "Main window background fill")
  Props::SetPropColor(*AppProps, "Theme/Colors/LabelTx",    RGB($EC, $F0, $F1), "Standard text foreground accent")
  Props::SetPropColor(*AppProps, "Theme/Colors/ButtonFace", RGB($E6, $7E, $22), "Button interface element background")
  Props::SetPropString(*AppProps, "Theme/Fonts/MainHeader", "Segoe UI,12,Bold", "Primary typography component")
  
  ; --- Localized User Interface Message Dialog Templates ---
  Props::SetPropString(*AppProps, "Messages/Welcome",   "Welcome to the unified Props Hierarchical Sandbox environment!", "Boot pulse")
  Props::SetPropString(*AppProps, "Messages/AskExit",   "Are you sure you want to terminate the application session?", "Exit query")
  Props::SetPropString(*AppProps, "Messages/ErrCrash",  "Critical file transaction failure. Operation aborted due to access rights.", "I/O error block")

  ; 3. Build a native OS desktop window frame using retrieved property parameters
  If OpenWindow(0, 100, 100, 750, 400, "Props Unified Framework Production Sandbox", #PB_Window_SystemMenu | #PB_Window_ScreenCentered)
    
    ; Apply skin background color directly via pipeline conversion
    SetWindowColor(0, Props::GetPropColor(*AppProps, "Theme/Colors/WindowBg"))
    
    ; --- LEFT SIDE: Hierarchical Navigation Tree View ---
    TextGadget(0, 20, 15, 300, 20, "Hierarchical Properties Structure:")
    TreeGadget(1, 20, 40, 300, 340, #PB_Tree_AlwaysShowSelection)
    
    ; --- RIGHT SIDE: Interactive UI Controls Form ---
    TextGadget(2, 350, 40, 380, 35, "Direct Content Pipe Integration Active")
    ButtonGadget(3, 350, 100, 380, 40, "Trigger Interactive Decision Box")
    ButtonGadget(4, 350, 160, 380, 40, "Simulate System Crash Dialog")
    
    ; Apply colors and typography mapping tokens straight out of the data cluster
    SetGadgetColor(0, #PB_Gadget_BackColor,  Props::GetPropColor(*AppProps, "Theme/Colors/WindowBg"))
    SetGadgetColor(0, #PB_Gadget_FrontColor, Props::GetPropColor(*AppProps, "Theme/Colors/LabelTx"))
    SetGadgetColor(2, #PB_Gadget_BackColor,  Props::GetPropColor(*AppProps, "Theme/Colors/WindowBg"))
    SetGadgetColor(2, #PB_Gadget_FrontColor, Props::GetPropColor(*AppProps, "Theme/Colors/LabelTx"))
    
    Define CompiledFont.i = Props::GetPropFont(*AppProps, "Theme/Fonts/MainHeader")
    If CompiledFont
      SetGadgetFont(0, CompiledFont)
      SetGadgetFont(2, CompiledFont)
    EndIf
    
    ; Execute the dynamic unified tree builder pipeline to build the Left Tree View!
    Props::BuildTree(*AppProps, 1)
    
    ; Expand all generated visual branches instantly for convenience
    Define ItemCount.i = CountGadgetItems(1), idx.i
    For idx = 0 To ItemCount - 1
      SetGadgetItemState(1, idx, #PB_Tree_Expanded)
    Next
    
    ; Trigger an instant informational welcome alert upon successful viewport initialization
    Props::MsgBox(*AppProps, "Messages/Welcome", #PB_MessageRequester_Ok | #PB_MessageRequester_Info)
    
    ; 4. Native window event manager loop framework tracking process
    Repeat
      Define Event.i = WaitWindowEvent()
      
      If Event = #PB_Event_Gadget
        Select EventGadget()
            
          Case 1 ; TreeView Click Diagnostics (Left Click Event)
            If EventType() = #PB_EventType_LeftClick
              Define SelectedItem.i = GetGadgetState(1)
              If SelectedItem <> -1
                ; Safely resolve the raw structure back out of the hidden gadget item memory data pointer
                Define *ItemRef.Props::TPropItem = GetGadgetItemData(1, SelectedItem)
                If *ItemRef
                  Debug "Tree Selection -> Full Path: " + *ItemRef\Key$ + " | Data Type Constant: " + Str(*ItemRef\Flags)
                EndIf
              EndIf
            EndIf
            
          Case 3 ; Interactive Question Button (Yes / No)
            Define UserChoice.i = Props::MsgBox(*AppProps, "Messages/AskExit", #PB_MessageRequester_YesNo | #PB_MessageRequester_Warning)
            If UserChoice = #PB_MessageRequester_Yes
              Debug "User verified termination sequence authorization via MsgBox pipeline."
              PostEvent(#PB_Event_CloseWindow) ; Force exit condition route loop break
            Else
              Debug "User aborted closure command vector."
            EndIf
            
          Case 4 ; Simulation of a hardware crash notice button
            Props::MsgBox(*AppProps, "Messages/ErrCrash", #PB_MessageRequester_Ok | #PB_MessageRequester_Error)
            
        EndSelect
      EndIf
      
    Until Event = #PB_Event_CloseWindow
    
    ; 5. Evaporate memory mappings and automatically free internal cached fonts cleanly
    Props::FreeBag(*AppProps)
    Debug "Memory buffers flushed and resources released. Safe shutdown sequence concluded."
    
  EndIf
  
  
CompilerEndIf



; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 10
; Folding = -------
; DPIAware
; CPU = 5