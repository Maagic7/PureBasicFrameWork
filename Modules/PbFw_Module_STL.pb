; ===========================================================================
;  FILE : Module_STL.pb
;  NAME : Module STL
;  DESC : Implements 3D STL File Import 
;  DESC : Supports STL-ASCII-Format and STL-Binary-Format
;  DESC : STL-Format is a 3D Surface Format (Mesh-Format)
;  DESC : See Wikipeida for STL-Format description
;  DESC : English:  https://en.wikipedia.org/wiki/STL_(file_format)
;  DESC : German:   https://de.wikipedia.org/wiki/STL-Schnittstelle
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/11/10
; VERSION  :  0.1
; COMPILER :  PureBasic 6.0
; ===========================================================================
; ChangeLog:
;{
;}
; ============================================================================

;{ ====================      M I T   L I C E N S E        ====================
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;} ============================================================================
;

;{ ====================   S T L   F I L E   F O R M A T   ====================

; ----------------------------------------------------------------------
;    STL ASCII File Format
; ----------------------------------------------------------------------

;   solid name
;    {For Each Facet}
;     facet normal n1 n2 n3
;       outer loop
;         vertex p1x p1y p1z
;         vertex p2x p2y p2z
;         vertex p3x p3y p3z
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
;     REAL32[3]       -   12 Bytes : Normalenvektor x,y,z (each 4 Bytes)
;     REAL32[3]       -   12 Bytes : Vertex 1
;     REAL32[3]       -   12 Bytes : Vertex 2
;     REAL32[3]       -   12 Bytes : Vertex 3
;     UINT16          -    2 Bytes : Attribute byte count [usually it is 0]
;   End
;}

;- ----------------------------------------------------------------------
;- Include Files
;- ----------------------------------------------------------------------

 XIncludeFile "PbFw_Module_BUFFER.pb"    ; BUFFER:: Module for Buffer handling
 XIncludeFile "PbFw_Module_IsNumeric.pb" ; STR:     Module for String Functions

DeclareModule STL
  
  Enumeration 
    #STL_UNKNOWN = 0  ; Constant for unkown File Format 
    #STL_ASCII        ; Constant for STL ASCII File Format
    #STL_BINARY       ; Constant for STL BINARY File Format
  EndEnumeration
  
  Structure TPoint3D  
    X.d
    Y.d
    Z.d
  EndStructure
  
  ; Structure for a Facet (Triangle)
  Structure TFacet
    N.TPoint3D
    V1.TPoint3D
    V2.TPoint3D
    V3.TPoint3D
  EndStructure
  
  Structure TSolid        ; Structure for a SOLID STL_Object
    Name.s                ; Name of the Solid
    NoOfFacets.q          ; Number of Facets (Triangles) 
    List Facet.TFacet()   ; List   of Facets (Triangles)
  EndStructure
  
  Declare.i LoadSTL(FileName.s, *STLobj.TSolid, STL_FORMAT=#STL_UNKNOWN)
  Declare.i SaveSTL(FileName.s, *STLobj.TSolid, STL_FORMAT=#STL_ASCII)
  
EndDeclareModule

Module STL
  
  EnableExplicit  
  
  ;- ----------------------------------------------------------------------
  ;- Module Private Functions
  ;- ----------------------------------------------------------------------
    
  Procedure.s _FindLineInFile(File, Find$)
    Protected sL.s
    Protected xFound 
    
    While Not Eof(File)
      sl = LCase(Trim(ReadString(File, #PB_Ascii)))
      If sl
        If FindString(sl, Find$)  
          xFound = #True
        EndIf  
      EndIf
    Wend
    
    If xFound
      ProcedureReturn sl
    Else
      ProcedureReturn #Null$
    EndIf
    
  EndProcedure
 
  Procedure _Parse_Vector(Text.s, *Pt3D.TPoint3D)
  ; ============================================================================
  ; NAME: _Parse_Vector
  ; DESC: Parse a Line wich contains Vector coordinates [x,y,z]
  ; DESC: Any text before the coordiantes will be skiped (like: "facet normal" or "vertex" 
  ; VAR(Text) : The Text String (must be trimmed)
  ; VAR(*Pt3D.TPoint3Dd) : 3D-Point which to return the x,y,z coordiates
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
          x = ValD(fld)
          fld = StringField(Text,I+1," ")   ; Next Field (it's y-coordinate)
          y = ValD(fld)
          fld = StringField(Text,I+2," ")   ; Next Field (it's z-coordinate)
          z = ValD(fld)
          
          RET = #True
          Break     ; we got all 3 coordinates
        EndIf
        
      Else          ; END of StringField() reached
        Break  
      EndIf
      
    ForEver  ; Until ForEver because we leave with BREAK
    
    ; Return the 3DPoint-coordiantes
    With *Pt3D
      \X = x
      \Y = y
      \Z = z
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
    Protected pt.TPoint3D
    
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
              ; read Number of Facets as Quad and set Hix32=0 because Value is a UINT32
              N = \UserPtr\q[0] & $FFFFFFFF  ; Read UINT32 into a QUAD
              
              If N
                *STLobj\NoOfFacets = N
                \UserPtr +4       ; Set UserPointer to StartOfFacets
                
                ; ********** FOR EACH FACET **********
  
                ;    (LastByteToAccess with UPtr) <= (DataEnd)
                While (\UserPtr +#FACET_ByteSize) <= (\ptrMem + \DataSize)
                  
                  AddElement(*STLobj\Facet())   ; add a New Element to FacetList()
                  
                  ; With the Trick of the Universal User Pointer Buffer::TUptr we get
                  ; a direct Memory Access of each Type like an ARRAY()
                  ; starting at PointerValue
                  
                  ; normal vector
                  *STLobj\Facet()\N\X = \UserPtr\f[0] 
                  *STLobj\Facet()\N\Y = \UserPtr\f[1] 
                  *STLobj\Facet()\N\Z = \UserPtr\f[2] 
                  
                  ; vertex 1
                  *STLobj\Facet()\V1\X = \UserPtr\f[3] 
                  *STLobj\Facet()\V1\Y = \UserPtr\f[4] 
                  *STLobj\Facet()\V1\Z = \UserPtr\f[5] 
                   
                  ; vertex 2
                  *STLobj\Facet()\V2\X = \UserPtr\f[6] 
                  *STLobj\Facet()\V2\Y = \UserPtr\f[7] 
                  *STLobj\Facet()\V2\Z = \UserPtr\f[8] 
                  
                  ; vertex 3
                  *STLobj\Facet()\V3\X = \UserPtr\f[9] 
                  *STLobj\Facet()\V3\Y = \UserPtr\f[10] 
                  *STLobj\Facet()\V3\Z = \UserPtr\f[11] 
                  
                  \UserPtr +#FACET_ByteSize  ; Set the UserPointer to next Facet
                  cnt +1 ; count the Facests read. At the end, this must be same as NoOfFacests specified
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
    Protected pt.TPoint3D
    Protected FileNo, pos
    Protected.s sLine, Name
    
    FileNo = ReadFile(#PB_Any, FileName)     
    If FileNo And *STLobj
      
      ClearList(*STLobj\Facet())      
      sLine = _FindLineInFile(FileNo,"solid")
      
      If sLine
        Name = Trim(StringField(sLine, 2, " "))
      EndIf    
      
      ClearList(*STLobj\Facet())     
      Repeat
        sLine = _FindLineInFile(FileNo,"facet")
        
        If sLine
          cnt + 1     ; Facets Count

          AddElement(*STLobj\Facet()) 
          _Parse_Vector(sLine, pt)
          *STLobj\Facet()\N = pt
          
          sLine = _FindLineInFile(FileNo,"vertex")
          _Parse_Vector(sLine, pt)
          *STLobj\Facet()\V1 = pt
          
          sLine = _FindLineInFile(FileNo,"vertex")
          _Parse_Vector(sLine, pt)
          *STLobj\Facet()\V2 = pt
         
          sLine = _FindLineInFile(FileNo,"vertex")
          _Parse_Vector(sLine, pt)
          *STLobj\Facet()\V3 = pt
          
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
  
  Procedure.i LoadSTL(FileName.s, *STLobj.TSolid, STL_FORMAT=#STL_UNKNOWN)
  ; ============================================================================
  ; NAME: LoadSTL
  ; DESC: Load a STL-File in ASCII or binary Format and
  ; DESC: returns a STL-Solid Structure which conatains all the Triangles.
  ; DESC: To display the STL you have to create a Mesh() with all the Triangles.
  ; VAR(FileName.s) : Full FileName (with full Path)
  ; VAR(*STLobj.TSolid) : Pointer of your TSolid Structure which receive the STL-Object
  ; VAR(STL_FORMAT): #STL_UNKNOWN try to detect format automatically (ASII or BINARY)
  ; RET.i : NoOfTriangelsRead of #NULL
  ; ============================================================================
    
    Protected RET    
    
    If STL_FORMAT = #STL_UNKNOWN
      ; Try to find out which Type it is
    EndIf
    
    If STL_FORMAT = #STL_BINARY
      RET = _LoadSTL_Binary(FileName, *STLobj)
      
    ElseIf STL_FORMAT = #STL_ASCII
      RET = _LoadSTL_ASCII(FileName, *STLobj)
    EndIf   
     
    ProcedureReturn RET  ; Return NoOfTriangelsRead
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
  
EndModule

CompilerIf #PB_Compiler_IsMainFile
  
  ; Testcode
  
CompilerEndIf

; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 16
; Folding = ---
; Optimizer
; CPU = 5
; Compiler = PureBasic 6.00 LTS (Windows - x86)