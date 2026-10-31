Enumeration
  #STEP_TYPE_UNKNOWN
  #STEP_TYPE_NUMBER     ; Floats, Integers
  #STEP_TYPE_STRING     ; Text in ' '
  #STEP_TYPE_REFERENCE  ; Verweise wie #123
  #STEP_TYPE_LIST       ; Verschachtelte Listen in ( )
  #STEP_TYPE_ENUM       ; Aufzählungen wie .TRUE., .FRONT.
EndEnumeration

Structure STEP_Parameter
  Type.i                ; Welcher Typ liegt vor?
  Value.s               ; Der Rohtext oder numerische Wert als String
  RefID.i               ; Wenn Typ = #STEP_TYPE_REFERENCE, hier die nackte Zahl speichern
  
  ; Für verschachtelte Listen (z.B. Koordinaten-Tripel oder Listen von IDs)
  List SubParameter.STEP_Parameter() 
EndStructure

Structure STEP_Entity
  ID.i                  ; Die eindeutige ID (z.B. 1040 aus #1040)
  Name.s                ; Der Entitätsname (z.B. "CARTESIAN_POINT")
  
  ; Alle Parameter dieser Entität in der exakten Reihenfolge der Datei
  List Parameters.STEP_Parameter()
EndStructure

; Die Hauptdatenbank aller Objekte im Speicher für blitzschnellen Zugriff per ID
Global NewMap STEP_Database.STEP_Entity()
; IDE Options = PureBasic 6.30 (Windows - x64)
; CursorPosition = 27
; DPIAware
; CPU = 5