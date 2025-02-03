; ===========================================================================
;  FILE : Module_STL.pb
;  NAME : Module STL
;  DESC : Implements 3D STL File Import 
;  DESC : Supports STL-ASCII-Format and STL-Binary-Format
;  DESC : STL-Format is a 3D Surface Format (Mesh-Format)
;  DESC : See Wikipeida for STL-Format description
;  DESC : English:  https://en.wikipedia.org/wiki/STL_(file_format)
;  DESC : German:   https://de.wikipedia.org/wiki/STL-Schnittstelle
;
;  SOURCES: 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/11/10
; VERSION  :  0.5 Developer Version
; COMPILER :  PureBasic 6.0
; ===========================================================================
;{ ChangeLog: 
;   2025/01/20 S.Maag : adapted to changed AnyPointer definiton from TUptr to pAny
 
;}
;{ TODO:
;}
; ===========================================================================


;{ ====================   S T L   F I L E   F O R M A T   ====================

; ----------------------------------------------------------------------
;    STL ASCII File Format
; ----------------------------------------------------------------------

;   solid name
;    {For Each Facet}
;     facet normal n1 n2 n3
;       outer loop
;         vertex p1_x p1_y p1_z
;         vertex p2_x p2_y p2_z
;         vertex p3_x p3_y p3_z
;       endloop
;     endfacet
;     
;   endsolid name

; ----------------------------------------------------------------------
;   STL binary File Format
; ----------------------------------------------------------------------

;   Values are coded as 32Bit-Float in Little-Endian
;   UINT8[80]         -   80 Bytes : File Header (mostly an ASCII TEXT)
;   UINT32            -   4 Bytes  : Number of Facets (Triangles)
;   ForEach Facet  -  [50 Bytes]
;     REAL32[3]       -   12 Bytes : NormalenVector x,y,z (each 4 Bytes)
;     REAL32[3]       -   12 Bytes : Vertex 1
;     REAL32[3]       -   12 Bytes : Vertex 2
;     REAL32[3]       -   12 Bytes : Vertex 3
;     UINT16          -    2 Bytes : Attribute byte count [usually it is 0]
;   End
;}

;- ----------------------------------------------------------------------
;- Include Files
;- ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"        ; PbFw::    FrameWork control Module
XIncludeFile "PbFw_Module_BUFFER.pb"      ; BUFFER::  Module for Buffer handling
XIncludeFile "PbFw_Module_IsNumeric.pb"   ; STR::     Module for String Functions
XIncludeFile "PbFw_Module_VECTORf.pb"     ; VECf::    single precision Vector Module
    
DeclareModule STL
  
  Enumeration 
    #STL_UNKNOWN = 0  ; Constant for unkown File Format 
    #STL_ASCII        ; Constant for STL ASCII File Format
    #STL_BINARY       ; Constant for STL BINARY File Format
  EndEnumeration
  
  ;- ----------------------------------------------------------------------
  ;- Constants for Units (values token from Module_IGES) 
  ; ----------------------------------------------------------------------
  #STL_Inches = 1
  #STL_Millimeters = 2
  #STL_Custom = 3
  #STL_Feet = 4
  #STL_Miles = 5
  #STL_Meters = 6
  #STL_Kilometers = 7
  #STL_Mils = 8
  #STL_Microns = 9
  #STL_Centimeters = 10
  #STL_MicroInches = 11

  ; Structure for a Facet (Triangle)
  Structure TFacet
    V1.VECf::TVector
    V2.VECf::TVector
    V3.VECf::TVector
    N.VECf::TVector
  EndStructure
  
  Structure TSolid        ; Structure for a SOLID STL_Object
    Name.s                ; Name of the Solid
    NoOfFacets.q          ; Number of Facets (Triangles) 
    Min.Vecf::TVector     ; Coordiates Min-Values 
    Max.Vecf::TVector     ; Coordiates Max-Values
    List Facet.TFacet()   ; List   of Facets (Triangles)
  EndStructure
  
  Declare.i LoadSTL(FileName.s, *STLobj.TSolid, STL_FORMAT=#STL_UNKNOWN)
  Declare.i SaveSTL(FileName.s, *STLobj.TSolid, STL_FORMAT=#STL_ASCII)
  Declare.i Calculate_MinMax(*STLobj.TSolid)

  Declare.i STL_To_NewMesh( List FACET.TFacet(), Color.q=$FF7F7F7F) ; RGBA (127,127,127,255)
  
EndDeclareModule

Module STL
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  ;- ----------------------------------------------------------------------
  ;- Module Private Functions
  ;- ----------------------------------------------------------------------
    
  Procedure.s _FindLineInFile(File, Find$)
    Protected sL.s
    Protected xFound 
    
    Debug "Find := " + Find$
    
    While Not Eof(File)
      sL = LCase(Trim(ReadString(File, #PB_Ascii)))
      Debug "SL : " + sL
      If sl
        If FindString(sl, Find$)  
          xFound = #True
          Break
        EndIf  
      EndIf
    Wend
    
    If xFound
      ProcedureReturn sL
    Else
      ProcedureReturn #Null$
    EndIf
    
  EndProcedure
 
  Procedure _Parse_Vector(Text.s, *Vector.VECf::TVector)
  ; ============================================================================
  ; NAME: _Parse_Vector
  ; DESC: Parse a Line wich contains Vector coordinates [x,y,z]
  ; DESC: Any text before the coordiantes will be skiped (like: "facet normal" or "vertex" 
  ; VAR(Text) : The Text String (must be trimmed)
  ; VAR(*Vector.VECf::TVector) : 3D-Vector which contains the returned x,y,z coordiates
  ; RET.i : #FALSE if no numeric value found
  ; ============================================================================
    
    Protected I, RET
    Protected fld.s
    Protected.d x,y,z
        
    ; in a correct ASCII STL-File there should be no double SPACEs
    ; but to be sure, we remove it! Because StringField() with double SPACE is a Problem!
    While FindString(Text,"  ")             ; find double Spaces in the middle            
      Text = ReplaceString(Text,"  ", " ")  ; Replace double Spaces with single Space
    Wend
    
    Repeat      ; Find first numeric Value
      I+1       ; StringField must start with index 1
      
      ;   For k = 1 To 7
      ;     Debug StringField("Hello I am  a splitted string", k, " ")
      ;   Next

      fld = StringField(Text,I," ")           
      If fld        ; If fld is a valid String otherwise we are at the END
                       
        If IsNum::IsFloat(fld)  ; first numeric value found (it's x-coordinate)
          x = ValF(fld)
          fld = StringField(Text,I+1," ")   ; Next Field (it's y-coordinate)
          y = ValF(fld)
          fld = StringField(Text,I+2," ")   ; Next Field (it's z-coordinate)
          z = ValF(fld)
          
          RET = #True
          Break     ; we got all 3 coordinates
        EndIf
        
      Else          ; END of StringField() reached
        Break  
      EndIf
      
    ForEver  ; Until ForEver because we leave with BREAK
    
    ; Return the 3DPoint-coordiantes
    With *Vector
      \X = x
      \Y = y
      \Z = z
      Debug "X = " + \X
      Debug "Y = " + \Y
      Debug "Z = " + \Z
    EndWith
    
    ProcedureReturn RET  ; returns #TRUE if numeric values found
  EndProcedure
  
  Procedure.i _LoadSTL_Binary(FileName.s, *STLobj.TSolid)
  ; ============================================================================
  ; NAME: _LoadSTL_Binary
  ; DESC: Load a STL-File in binary Format and
  ; DESC: returns a STL-Solid Structure which conatains all the Triangles.
  ; VAR(FileName.s) : Full FileName (with full Path)
  ; VAR(*STLobj.TSolid) : Pointer of your TSolid Structure which receive the STL-Object
  ; RET.i : NumberOfTriangles of #Null
  ; ============================================================================
    
    Protected hBUF.BUFFER::hBuffer    ; Buffer Handle Structure (Module BUFFER)
    Protected N.q, cnt.q
    
    ;   Values are coded as 32Bit-Float in Little-Endian
    ;   UINT8[80]         -   80 Bytes : File Header (mostly an ASCII TEXT)
    ;   UINT32            -   4 Bytes  : Number of Facets (Triangles)
    ;   ForEach Facet  -  [50 Bytes]
    ;     REAL32[3]       -   12 Bytes : Normalenvektor x,y,z (each 4 Bytes)
    ;     REAL32[3]       -   12 Bytes : Vertex 1
    ;     REAL32[3]       -   12 Bytes : Vertex 2
    ;     REAL32[3]       -   12 Bytes : Vertex 3
    ;     UINT16          -    2 Bytes : Attribute byte count [usually it is 0]
    ;   End

    #FACET_ByteSize = 50
    
    If *STLobj  
      If BUFFER::FileToBuffer(FileName, hBuf)  ; Read the complete File into a Buffer
        
        If hBuf\DataSize >=134    ; if it is not to short for a STL File with at least 1 FACET
                                  ; must be [80] Header + [4] NoOfFacets + n*[50] FacetData = [134]
          
          ClearList(*STLobj\Facet())
          
          With hBuf
            If \UserPtr          ; in a new Buffer, the UserPtr starts at \ptrMem
              \UserPtr + 80      ; Set User Pointer to NoOfTriangles
              ; read Number of Facets as Quad and Rset Hix32 because Value is a UINT32
              N = \UserPtr\qq[0] & $FFFFFFFF  ; Read UINT32 into a QUAD
              
              If N
                *STLobj\NoOfFacets = N
                \UserPtr +4       ; Set UserPointer to StartOfFacets
                
                ; ********** FOR EACH FACET **********
  
                ;    (LastByteToAccess with UPtr) <= (DataEnd)
                While (\UserPtr +#FACET_ByteSize) <= (\_ptrMem + \DataSize)
                  
                  AddElement(*STLobj\Facet())   ; add a New Element to FacetList()
                  
                  ; With the Trick of the Universal User Pointer Buffer::TUptr we get
                  ; a direct Memory Access of each Type like an ARRAY()
                  ; starting at PointerValue
                  
                  ; normal vector
                  *STLobj\Facet()\N\X = \UserPtr\ff[0] 
                  *STLobj\Facet()\N\Y = \UserPtr\ff[1] 
                  *STLobj\Facet()\N\Z = \UserPtr\ff[2] 
                  
                  ; vertex 1
                  *STLobj\Facet()\V1\X = \UserPtr\ff[3] 
                  *STLobj\Facet()\V1\Y = \UserPtr\ff[4] 
                  *STLobj\Facet()\V1\Z = \UserPtr\ff[5] 
                   
                  ; vertex 2
                  *STLobj\Facet()\V2\X = \UserPtr\ff[6] 
                  *STLobj\Facet()\V2\Y = \UserPtr\ff[7] 
                  *STLobj\Facet()\V2\Z = \UserPtr\ff[8] 
                  
                  ; vertex 3
                  *STLobj\Facet()\V3\X = \UserPtr\ff[9] 
                  *STLobj\Facet()\V3\Y = \UserPtr\ff[10] 
                  *STLobj\Facet()\V3\Z = \UserPtr\ff[11] 
                  
                  \UserPtr + #FACET_ByteSize  ; Set the UserPointer to next Facet
                  cnt +1 ; count the Facets read. At the end, this must be same as NoOfFacests specified
                Wend
                
                ; ********** END FOR EACH FACET **********
                
                Debug "STL binary File"
                Debug "  STL NoOfFacets = " + Str(N)
                Debug "  FacetsRead     = " + Str(cnt)
  
                If N = cnt    ; NoOfFacets in File is same as FacetsRead
                  ; NoOfFacests specified in STL File is idetntical withFacetsRead
                Else
                  ; NoOfFacests specified in STL File is not same as FacetsRead
                EndIf
                
              EndIf
            EndIf
          EndWith 
        Else
          ; File to short for a STL wiht at least 1 Facet
        EndIf
      Else
          ; Buffer not created
      EndIf    
    EndIf
     
    ProcedureReturn cnt ; NumberOfTriangelRead
  EndProcedure
       
 Procedure.i _LoadSTL_ASCII(FileName.s, *STLobj.TSolid)
  ; ============================================================================
  ; NAME: _LoadSTL_ACII
  ; DESC: Load a STL-File in ASCII Format and
  ; DESC: returns a STL-Solid Structure which conatains all the Triangles.
  ; VAR(FileName.s) : Full FileName (with full Path)
  ; VAR(*STLobj.TSolid) : Pointer of your TSolid Structure which receive the STL-Object
  ; RET.i : NumberOfTriangles of #Null
  ; ============================================================================
   
    Protected cnt.q
    Protected Vector.VECf::TVector
    Protected FileNo, pos
    Protected.s sLine, Name
    
    Debug FileName
    
    FileNo = ReadFile(#PB_Any, FileName)     
    If FileNo And *STLobj
      Debug "-> Load STL-FILE"
      
      ClearList(*STLobj\Facet())      
      ; sLine = _FindLineInFile(FileNo,"solid")
      Debug "The Line := " + sLine
      
      If sLine
        Name = Trim(StringField(sLine, 2, " "))
        Debug sLine
      EndIf    
      
      ClearList(*STLobj\Facet())     
      Repeat
        sLine = _FindLineInFile(FileNo,"facet")
        
        If sLine
          cnt + 1     ; Facets Count

          AddElement(*STLobj\Facet()) 
          _Parse_Vector(sLine, Vector)
          *STLobj\Facet()\N = Vector
          
          sLine = _FindLineInFile(FileNo,"vertex")
          _Parse_Vector(sLine, Vector)
          *STLobj\Facet()\V1 = Vector
          
          sLine = _FindLineInFile(FileNo,"vertex")
          _Parse_Vector(sLine, Vector)
          *STLobj\Facet()\V2 = Vector
         
          sLine = _FindLineInFile(FileNo,"vertex")
          _Parse_Vector(sLine, Vector)
          *STLobj\Facet()\V3 = Vector
          
        Else
          Break
        EndIf  
      ForEver   ; Exit with BREAK                      
    EndIf
    
    ProcedureReturn cnt ; NumberOfTriangelRead
 EndProcedure
 
  ;- ----------------------------------------------------------------------
  ;- Module Public Functions
  ;- ----------------------------------------------------------------------
 
  Procedure.i Calculate_MinMax(*STLobj.TSolid)
  ; ============================================================================
  ; NAME: Calculate_MinMax 
  ; DESC: Calculates Min and Max Coordinates of the STL-Object
  ; DESC: and save it in the STLobj \Min and \Max Vector
  ; VAR(*STLobj.TSolid): Pointer to STL-Solid-Object
  ; RET.i : #TRUE if done
  ; ============================================================================
    Protected RET
      
    If *STLobj
      
      If ListSize(*STLobj\Facet())        
        ResetList(*STLobj\Facet())      
        
        With *STLobj
          VECf::Vector_Set(\Min, Infinity(), Infinity(), Infinity(), Infinity())        ; Clear Min-Coordinates        
          VECf::Vector_Set(\Max, -Infinity(), -Infinity(), -Infinity(), -Infinity())    ; Clear Max-Coordinates
          ForEach \Facet() 
            VECf::Vector_Min(\Min, \Facet()\V1, \Facet()\V2)
            VECf::Vector_Min(\Min, \Min, \Facet()\V3)
            VECf::Vector_Max(\Max, \Facet()\V1, \Facet()\V2)
            VECf::Vector_Max(\Max, \Max, \Facet()\V3)
          Next  
        EndWith       
        
        RET = #True
      EndIf
      
    Else
      ; Exception  
    EndIf
    
    ProcedureReturn RET
  EndProcedure

  Procedure.i LoadSTL(FileName.s, *STLobj.TSolid, STL_FORMAT=#STL_UNKNOWN)
  ; ============================================================================
  ; NAME: LoadSTL
  ; DESC: Load a STL-File in ASCII or binary Format and
  ; DESC: returns a STL-Solid Structure which conatains all the Triangles.
  ; DESC: To display the STL you have to create a Mesh() with all the Triangles.
  ; VAR(FileName.s) : Full FileName (with full Path)
  ; VAR(*STLobj.TSolid) : Pointer of your TSolid Structure which receive the STL-Object
  ; VAR(STL_FORMAT): #STL_UNKNOWN try to detect format automatically (ASII or BINARY)
  ; RET.i : NoOfTriangelsRead 
  ; ============================================================================
    
    Debug "Load-STL"
    
    Protected RET    
    
    If STL_FORMAT = #STL_UNKNOWN
      ; TODO!
      ; Try to find out which Type it is
    EndIf
    
    If STL_FORMAT = #STL_BINARY
      RET = _LoadSTL_Binary(FileName, *STLobj)            
    ElseIf STL_FORMAT = #STL_ASCII     
      RET = _LoadSTL_ASCII(FileName, *STLobj)
    EndIf       
    
    If RET
      Calculate_MinMax(*STLobj)
      VECf::mac_Debug_Vector(*STLobj\Min)
      VECf::mac_Debug_Vector(*STLobj\Max)
    EndIf
    
    ProcedureReturn RET  ; Return NoOfTriangelsLoad
  EndProcedure
  
  Procedure.i SaveSTL(FileName.s, *STLobj.TSolid, STL_FORMAT=#STL_ASCII)
  ; ============================================================================
  ; NAME: SaveSTL
  ; DESC: Saves a STL-Object in ASCII or binary Format
  ; VAR(FileName.s): Full FileName (with full Path)
  ; VAR(*STLobj.TSolid): TSolid Structure which contains the STL-Object
  ; VAR(STL_FORMAT): USE STL-File-Format #STL_ASCII or #STL_BINARY
  ; RET.i : FileFormat saved #STL_ASCII, #STL_BINARY, if Error: #STL_UNKNOWN=0
  ; ============================================================================
    
    Protected hBUF.BUFFER::hBuffer    ; BufferHandle Structure (Module BUFFER)
    Protected STL_TYPE

    If STL_FORMAT = #STL_ASCII        ; Save as STL-ASCII-Format
      
      STL_TYPE = #STL_ASCII
      
    ElseIf STL_FORMAT = #STL_BINARY   ; Save as STL-Binary-Format
      
      STL_TYPE = #STL_BINARY
    Else                              ; can not save other formats!
      
      STL_TYPE = #STL_UNKNOWN
    EndIf    
    
    ProcedureReturn STL_TYPE
  EndProcedure
    
  Procedure.i STL_To_NewMesh(List FACET.TFacet(), Color.q=$FF7F7F7F) ; RGBA (127,127,127,255)
  ; ============================================================================
  ; NAME: STL_To_NewMesh 
  ; DESC: Creates a NewMesh(#PB_Mesh_TriangleList) out of the STL Data
  ; VAR(FileName.s): Full FileName (with full Path)
  ; VAR(List FACET.TFacet(): FACET()-List (Triangle-List)
  ; VAR(Color.q): Color
  ; RET.i : PureBasic #MeshID (<>0 it Mesh is created)
  ; ============================================================================
    Protected.i NewMesh, I, Err
    
    NewMesh=CreateMesh(#PB_Any, #PB_Mesh_TriangleList) ; #PB_Mesh_PointList
    Debug "Mesh = " + NewMesh
    
    If NewMesh
      
      If ListSize(FACET())
        I = 1
        ForEach FACET()
          
          With FACET()\V1
            MeshVertexPosition(\x, \y, \z)
            MeshVertexColor(Color)
          EndWith 
          
          With FACET()\V2
            MeshVertexPosition(\x, \y, \z)
            MeshVertexColor(Color)
          EndWith 
          
          With FACET()\V3
            MeshVertexPosition(\x, \y, \z)
            MeshVertexColor(Color)
          EndWith 
          
          ; MeshFace(I, I+1, I+2)
          I + 3
        Next
        
        FinishMesh(#True)   ; #True = finsish as static Mesh; #False = finish as dynamic Mesh
        
      Else
        Err = #True
      EndIf
        
      If Err
        FreeMesh(NewMesh)
        NewMesh = 0
      EndIf
      
    EndIf
    
    ProcedureReturn NewMesh
  EndProcedure
  
  Procedure Mesh_To_STL(MyMeshNo, List FACET.TFacet())
    
  EndProcedure
  
EndModule

CompilerIf #PB_Compiler_IsMainFile
  ;- ----------------------------------------------------------------------
  ;- TEST-CODE
  ;- ----------------------------------------------------------------------
  
  UseModule STL
  
  #CameraSpeed = 1

  IncludeFile #PB_Compiler_Home + "examples/3d/Screen3DRequester.pb"
  
    EnableExplicit

  Define.f KeyX, KeyY, MouseX, MouseY, Quit
  Define.i FileName.s
  Define.i NoOfTriangles, MeshNo 
  
  Define MySTL.TSolid
    
  
  If InitEngine3D()
    
    Add3DArchive(#PB_Compiler_Home + "examples/3d/Data/Textures", #PB_3DArchive_FileSystem)
    
    InitSprite()
    InitKeyboard()
    InitMouse()
    
    If Screen3DRequester()
      
      FileName=OpenFileRequester("Open STL-File", "", "*.STL", 0)
      NoOfTriangles= LoadSTL(FileName, MySTL, #STL_BINARY)
      Debug FileName + " : NoOfTriangles = " + NoOfTriangles
      
      MeshNo = STL_To_NewMesh(MySTL\Facet(), RGBA(0,255,0,255))
      
;       MeshNo = 0
;       CreateCylinder(0, 0.5, 1)

      CreateTexture(0, 16, 16)
      Define TextureID = TextureID(0)
      
      CreateMaterial(0, LoadTexture(0, "clouds.jpg"))
      
      SetMaterialColor(0, #PB_Material_DiffuseColor, RGB(100,100,0))
      
      ;MaterialShadingMode(0, #PB_Material_Phong|#PB_Material_Wireframe    )
      MaterialShadingMode(0, #PB_Material_Flat|#PB_Material_Wireframe)
      
      MaterialShininess(0, 5)
      
      CreateEntity(0, MeshID(MeshNo), MaterialID(0))
      EntityRenderMode(0, #PB_Entity_CastShadow)    
      
      CreateCamera(0, 0, 0, 100, 100)
      
;       MoveCamera(0, 4, 2, 6, #PB_Absolute | #PB_Local)
;       CameraLookAt(0, 0, 0, 0)

      MoveCamera(0, 100, 100, 100, #PB_Absolute| #PB_Local)
      CameraProjectionMode(0, #PB_Camera_Perspective )
      
      ;CreateWater(0, 0, -150, 0, 150, #PB_World_WaterHighQuality|#PB_World_WaterSun|#PB_World_WaterCaustics                    )
      Sun(-200, 200, -100, RGB(255,128,128))
      ;SkyDome("clouds.jpg", 500)
      CreateLight(1, RGB(128,128,128),  -200, 200, -100)
      DisableLightShadows(1, #False)
      
      Repeat
        Screen3DEvents()
        
        If ExamineMouse()
          MouseX = -MouseDeltaX() * #CameraSpeed * 0.05
          MouseY = -MouseDeltaY() * #CameraSpeed * 0.05
        EndIf
        
        If ExamineKeyboard()
          
          If KeyboardPushed(#PB_Key_Left)
            RotateEntity(0, 0, -5, 0, #PB_Relative)
            
          ElseIf KeyboardPushed(#PB_Key_Right)
            RotateEntity(0, 0, 5, 0, #PB_Relative)
            
          Else
            KeyX = 0
          EndIf
          
          If KeyboardPushed(#PB_Key_Up)
            RotateEntity(0, -5, 0, 0, #PB_Relative)
            
          ElseIf KeyboardPushed(#PB_Key_Down)
            RotateEntity(0, 5, 0, 0, #PB_Relative)
            
          Else
            KeyY = 0
          EndIf
          
        EndIf
        
        RotateCamera(0, MouseY, MouseX, 0, #PB_Relative)
        MoveCamera  (0, KeyX, KeyY, 2)
        
        RenderWorld()
        ;Screen3DState()      
        FlipBuffers()
      Until KeyboardPushed(#PB_Key_Escape) Or Quit = 1
    EndIf
    
  Else
    MessageRequester("Error", "The 3D Engine can't be initialized", 0)
  EndIf

CompilerEndIf

; IDE Options = PureBasic 6.20 Beta 4 (Windows - x64)
; CursorPosition = 266
; FirstLine = 236
; Folding = ---
; Optimizer
; CPU = 5