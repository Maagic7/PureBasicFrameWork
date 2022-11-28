; ===========================================================================
;  FILE : Module_ECAD_EDraw.pb
;  NAME : ECAD Electrical Drawing Functions
;  DESC : Draws the ECAD Elements defined in Modul ECAD::
;  DESC : Draw_TLine, Draw_TPolyLine, Draw_TPolygon, Draw_TRect ...
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/10/27
; VERSION  :  1.0
; COMPILER :  PureBasic 6.00
; ===========================================================================
; ChangeLog:
;             
; ============================================================================

;- ----------------------------------------------------------------------
;- Include Files
;- ----------------------------------------------------------------------

; All files are already included in ECAD_Main.pb! 
; It's just to know which Include Files are necessary

; XIncludeFile "Modules\Module_Exception.pb"
; XIncludeFile "Modules\Module_ECAD.pb"
; XIncludeFile "Modules\Module_ECAD_VDraw.pb"


DeclareModule EDraw
  
EndDeclareModule

Module EDraw
  
  EnableExplicit

  ;- ----------------------------------------------------------------------
  ;- Modul internal Functions
  ;- ----------------------------------------------------------------------
  
  ; For easier maintenance we copy the #EXCEPTION_ObjectNotExist from
  ; Module Exception to a local CONSTANT
  #ObjectNotExist = Exception::#EXCEPTION_ObjectNotExist
  
  Procedure _Exception(FName.s, ExceptionType)
    ; ======================================================================
    ; NAME: EDraw::_Exception
    ; DESC: Modul Exeption Handler
    ; VAR(FName): Function Name which caused the Exeption
    ; RET : -
    ; ======================================================================
    
    ; Call the Exception Handler Function in the Module Exception
    Exception::Exception("ECAD_EDraw", FName, ExceptionType)
    ProcedureReturn ExceptionType
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- Modul Public Functions
  ;- ----------------------------------------------------------------------

  ;- ECAD standard grafical Objects
  ;- ----------------------------------------------------------------------
    
  Procedure Draw_TLine(*Obj.ECAD::TLine)
  ; ======================================================================
  ; NAME: EDraw::Draw_TLine
  ; DESC: Draws an ECAD Line
  ; VAR(*Obj.ECAD::Line): ECAD Line Type/Obj
  ; RET : -
  ; ======================================================================
    
    Protected ret = 0
    
    If *Obj
      
      With *Obj
        ; not implemented yet
     
      EndWith  
     
    Else
      ret =_Exception("Draw_TLine", #ObjectNotExist)
    EndIf
    
    ProcedureReturn ret
  EndProcedure  
  
  Procedure Draw_TPolyLine(*Obj.ECAD::TPolyLine)
  ; ======================================================================
  ; NAME: EDraw::Draw_TPolyLine
  ; DESC: Draws an ECAD Draw_TPolyLine
  ; VAR(*Obj.ECAD::Draw_TPolyLine): ECAD Draw_TPolyLine Type/Obj
  ; RET : -
  ; ======================================================================
    
    Protected ret = 0
    
    If *Obj
      
      With *Obj
        ; not implemented yet
     
      EndWith  
     
    Else
       ret = _Exception("Draw_TPolyLine", #ObjectNotExist)
    EndIf
    
    ProcedureReturn ret
  EndProcedure  
  
  Procedure Draw_TPolygon(*Obj.ECAD::TPolygon)
  ; ======================================================================
  ; NAME: EDraw::Draw_TPolygon
  ; DESC: Draws an ECAD Polygon
  ; VAR(*Obj.ECAD::TPolygon): ECAD Draw_TPolygon Type/Obj
  ; RET : -
  ; ======================================================================
    
    Protected ret = 0
    
    If *Obj
      
      With *Obj
        ; not implemented yet
     
      EndWith  
     
    Else
      ret = _Exception("Draw_TPolygon", #ObjectNotExist)
    EndIf
    
    ProcedureReturn ret
  EndProcedure  
  
  Procedure Draw_TTriAngle(*Obj.ECAD::TTriAngle)
  ; ======================================================================
  ; NAME: EDraw::Draw_TTriAngle
  ; DESC: Draws an ECAD Triangle
  ; VAR(*Obj.ECAD::TriAngle): ECAD TriAngle Type/Obj
  ; RET : -
  ; ======================================================================
    
    Protected ret = 0
    
    If *Obj
      
      With *Obj
        ; not implemented yet
     
      EndWith  
     
    Else
      ret = _Exception("Draw_TTriAngle", #ObjectNotExist)
    EndIf
    
    ProcedureReturn ret
  EndProcedure  
  
  Procedure Draw_TRect(*Obj.ECAD::TRect)
  ; ======================================================================
  ; NAME: EDraw::Draw_TRect
  ; DESC: Draws an ECAD Rectangle
  ; VAR(*Obj.ECAD::TRect): ECAD Rectangle Type/Obj
  ; RET : -
  ; ======================================================================
    
    Protected ret = 0
    
    If *Obj
      
      With *Obj
        ; not implemented yet
     
      EndWith  
     
    Else
      ret = _Exception("Draw_TRect", #ObjectNotExist)
    EndIf
    
    ProcedureReturn ret
  EndProcedure
  
  Procedure Draw_TRoundRect(*Obj.ECAD::TRoundRect)
  ; ======================================================================
  ; NAME: EDraw::Draw_TRoundRect
  ; DESC: Draws an ECAD Round Rectangle
  ; VAR(*Obj.ECAD::TRoundRect): ECAD Rectangle Type/Obj
  ; RET : -
  ; ======================================================================
    
    Protected ret = 0
    
    If *Obj
      
      With *Obj
        ; not implemented yet
     
      EndWith  
     
    Else
      ret = _Exception("Draw_TRoundRect", #ObjectNotExist)
    EndIf
    
    ProcedureReturn ret
  EndProcedure
  
  Procedure Draw_TCircle(*Obj.ECAD::TCircle)
  ; ======================================================================
  ; NAME: EDraw::ECAD_Circle
  ; DESC: Draws an ECAD Circle
  ; VAR(*Obj.ECAD::TCircle): ECAD Circle Type/Obj
  ; RET : -
  ; ======================================================================
    
    Protected ret = 0
    
    If *Obj
      
      With *Obj
        ; not implemented yet
     
      EndWith  
     
    Else
      ret = _Exception("Draw_TCircle", #ObjectNotExist)
    EndIf
    
    ProcedureReturn ret
  EndProcedure
    
  Procedure Draw_TEllipse(*Obj.ECAD::TEllipse)
  ; ======================================================================
  ; NAME: EDraw::Draw_TEllipse
  ; DESC: Draws an ECAD Circle
  ; VAR(*Obj.ECAD::TEllipse): ECAD Ellipse Type/Obj
  ; RET : -
  ; ======================================================================
    
    Protected ret = 0
    
    If *Obj
      
      With *Obj
        ; not implemented yet
     
      EndWith  
     
    Else
      ret = _Exception("Draw_TEllipse", #ObjectNotExist)
    EndIf
    
    ProcedureReturn ret
  EndProcedure
  
  Procedure Draw_TArrow(*Obj.ECAD::TArrow)
  ; ======================================================================
  ; NAME: EDraw::Draw_TArrow
  ; DESC: Draws an ECAD Arrow
  ; VAR(*Obj.ECAD::TArrow): ECAD Arrow Type/Obj
  ; RET : -
  ; ======================================================================
    
    Protected ret = 0
    Protected P2.ECAD::TPoint, P3.ECAD::TPoint
    
    If *Obj
  
      With *Obj
        
        Select \Direction
            
          Case ECAD::#Right            ; 0°
            P2\X = \PT\x - \Length
            P3\X = P2\X
            P2\Y = \PT\y + \Width/2
            P3\Y = \PT\y - \Width/2
            
          Case ECAD::#Left             ; 180°
            P2\X = \PT\x + \Length
            P3\X = P2\X
            P2\Y = \PT\y + \Width/2
            P3\Y = \PT\y - \Width/2
            
          Case ECAD::#Up               ; 270°
            P2\X = \PT\x + \Width/2
            P3\X = \PT\x - \Width/2
            P2\Y = \PT\y + \Length
            P3\Y = P2\Y
            
          Case ECAD::#Down             ; 90°
            P2\X = \PT\x + \Width/2
            P3\X = \PT\x - \Width/2
            P2\Y = \PT\y - \Length
            P3\Y = P2\Y
            
        EndSelect
      EndWith  
       
    Else
      ret = _Exception("Draw_TArrow", #ObjectNotExist)
    EndIf
  
    ProcedureReturn ret
  EndProcedure
  
  Procedure Draw_TText(*Obj.ECAD::TText)
  ; ======================================================================
  ; NAME: EDraw::Draw_TText
  ; DESC: Draws an Draw_TText Structure
  ; VAR(*Obj.ECAD::TText) ECAD Text Structrue
  ; RET: 0 or ExeptionCode
  ; ======================================================================
    
    Protected ret = 0
    Protected TxtWidth.d, TxtHeight.d, x.d, y.d
   
    If *Obj
      
      With *Obj
        TxtWidth = VectorTextWidth(*Obj\Txt)
        TxtHeight = VectorTextHeight(*Obj\Txt)
        
        x= *Obj\Origin\X
        y= *Obj\Origin\Y
        
        Select *Obj\Align
            
          Case ECAD::#TextAlign_UpLeft
            ; Standard vor DrawVectorText is UpLeft
            ; x = x
            ; y = y 
            
          Case ECAD::#TextAlign_UpMiddle
            x = x - TxtWidth/2
            ; y = y 
            
          Case ECAD::#TextAlign_UpRight
            x = x - TxtWidth
            ; y = y + TxtHeight
            
          Case ECAD::#TextAlign_DownLeft
            ; x = x
            y = y + TxtHeight
            
          Case ECAD::#TextAlign_DownMiddle
            x = x - TxtWidth/2
            y = y + TxtHeight
            
          Case ECAD::#TextAlign_DownRight
            x = x - TxtWidth
            y = y + TxtHeight
       
        EndSelect
        
        Select *Obj\Direction
          Case ECAD::#Right
            RotateCoordinates(x, y, 0)
          Case ECAD::#Down
            RotateCoordinates(x, y, 90)
          Case ECAD::#Left
            RotateCoordinates(x, y, 180)
          Case ECAD::#Up 
            RotateCoordinates(x, y, 270)
        EndSelect
     
      EndWith  
     
    Else
      ret = _Exception("Draw_TText", #ObjectNotExist)
    EndIf
    
    ProcedureReturn ret
  EndProcedure
   
  Procedure Draw_TGraphObj(*Obj.ECAD::TGraphObj)    
  ; ======================================================================
  ; NAME: EDraw::Draw_TGraphObj
  ; DESC: Draws an Draw_TGraphObj, Draw_TGraphObj is a unspecified placeholder
  ; DESC: for a grafical Object like Line, PolyLine ...
  ; VAR(*Obj.ECAD::TGraphObj) ECAD Draw_TGraphObj Structrue
  ; RET: 0 or ExeptionCode
  ; ======================================================================

    Protected ret = 0
    
    If *Obj
      With *Obj
        ; we have a Set of different graphical Objects
        ; see ECAD_TypesAnsStructures.pb Enumeration eECAD_GraphObj
        ; all this Objects must have it's own CASE here
        
        Select \Type
          ; we don't have to check \*Obj here! It will be checked in the drawing routines 
          Case ECAD::#GraphObj_Line        ; single Line
            ret= Draw_TLine(\Obj)      ; \Obj ist the Pointer to the Object *ptr.ECAD::Draw_TLine
            
          Case ECAD::#GraphObj_PloyLine    ; Polyline
            ret= Draw_TPolyLine(\Obj)
            
          Case ECAD::#GraphObj_Polygon     ; filled Polygon structre
            ret= Draw_TPolygon(\Obj)
           
          Case ECAD::#GraphObj_Rect        ; Rectangle
            ret=Draw_TRect(\Obj)
           
          Case ECAD::#GraphObj_RoundRect   ; Rounded Rectangle
            ret= Draw_TRoundRect(\Obj)
           
          Case ECAD::#GraphObj_Circle      ; Circle
            ret= Draw_TCircle(\Obj)
            
          Case ECAD::#GraphObj_Ellipse     ; Ellipse
            ret= Draw_TEllipse(\Obj)
            
          Case ECAD::#GraphObj_TriAngle    ; Triangle
            ret= Draw_TTriangle(\Obj)
         
        EndSelect
      EndWith
      
    Else
      ret = _Exception("Draw_TText", #ObjectNotExist)     
    EndIf
    
    ProcedureReturn ret ; #True if no Error
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- ECAD Objects (Symbols, Wires, Macros, Pages ..)
  ;- ----------------------------------------------------------------------

  ; Wire
  Procedure Draw_TWire(*Obj.ECAD::TWire)
  ; ======================================================================
  ; NAME: EDraw::Draw_TWire
  ; DESC: Draws a TWire Structure
  ; VAR(*Obj.ECAD::TText) ECAD Wire Structrue
  ; RET: 0 or ExeptionCode
  ; ======================================================================
    
    Protected ret = 0
    
    If *Obj
      
      With *Obj
        ; not implemented yet
     
      EndWith  
     
    Else
      ret = _Exception("Draw_TWire", #ObjectNotExist)
    EndIf
    
    ProcedureReturn ret
  EndProcedure
  
  ; Symbol
  Procedure Draw_TSymbol(*Obj.ECAD::TSymbol)
  ; ======================================================================
  ; NAME: EDraw::Draw_TSymbol
  ; DESC: Draws a TSymbol Structure
  ; VAR(Obj.ECAD::TSymbol) ECAD Symbol Structrue
  ; RET: 0 or ExeptionCode
  ; ======================================================================
    
    Protected ret = 0
    
    If *Obj
      
      ; !!! How to handle the Position offsets???
  
      With *Obj
        ; --------------------------------------------------
        ;  Draw all ECAD-Graph-Objects
        ; --------------------------------------------------
        If ListSize(\LGraph()) 
          ResetList(\LGraph())            ; Start List from beginning
          ForEach \LGraph()
            If Draw_TGraphObj(\LGraph())  ; Subroutine to Draw  ECAD-graphical-Object
            Else
              ret= #False
            EndIf  
          Next    
        EndIf
    
        ; --------------------------------------------------
        ;  Draw all ECAD-Text-Objects
        ; --------------------------------------------------
        If ListSize(\LText()) 
          ResetList(\LText())                ; Start List from beginning
          ForEach \LText()
            If Draw_TText(\LText())       ; Subroutine to Draw ECAD-Text-Object
            Else
              ret= #False
            EndIf  
          Next    
        EndIf
      EndWith
      
    Else
      ret = _Exception("Draw_TSymbol", #ObjectNotExist)
    EndIf
    
    ProcedureReturn ret
  EndProcedure
  
  ; Seiten Schriftfeld
  Procedure Draw_TPageFrame(*Obj.ECAD::TPageFrame)
  ; ======================================================================
  ; NAME: EDraw::Draw_TPageFrame
  ; DESC: Draws a TPageFrame Structure
  ; VAR(Obj.ECAD::TSymbol) ECAD Draw_TPageFrame Structrue
  ; RET: 0 or ExeptionCode
  ; ======================================================================
    
   Protected ret = 0
    
    If *Obj
      
      With *Obj
        ; not implemented yet
     
      EndWith  
     
    Else
      ret = _Exception("Draw_TPageFrame", #ObjectNotExist)
    EndIf
    
    ProcedureReturn ret
  EndProcedure
  
  ; zeichnet ein ECAD Makro (Schaltungsvorlage)
  Procedure Draw_TMacro(*Obj.ECAD::TMacro, *Pos.ECAD::TPoint)
  ; ======================================================================
  ; NAME: EDraw::Draw_TMacro
  ; DESC: Draws an ECAD Draw_TMacro
  ; VAR(*Obj.ECAD::TMacro) ECAD Macro Structure
  ; VAR(*Pos.ECAD::TPoint) Sartpostion x,y
  ; RET: 0 or ExeptionCode
  ; ======================================================================
    
    Protected ret
    
    ; !!! ATTENTION: Until know it is not clear how to handle Position-Offset *Pos
    
    If *Obj And *Pos
      ;   List LSymbols.ECAD::TSymbol()   ; List of Symbols on Page
      ;   List LText.ECAD::TText()        ; List of Text-Objects on Page
      ;   List LWires.ECAD::TWire()       ; List of Wires on Page (connections)
      ;   List LGraph.ECAD::TGraphObj()   ; List of Graphical Objects
      
      With *Obj
      
        ; --------------------------------------------------
        ;  Draw all ECAD-Symbol-Objects
        ; --------------------------------------------------
        If ListSize(\LSymbols())
          ResetList(\LSymbols())          ; Start List from beginning
          ForEach \LSymbols()
            If Draw_TSymbol(\LSymbols())  ; Subroutine to Draw ECAD-Symbol
            Else
              ret= #False
            EndIf  
          Next    
        EndIf
        
        ; --------------------------------------------------
        ;  Draw all ECAD-Wire-Objects
        ; --------------------------------------------------
        If ListSize(\LWires())
          ResetList(\LWires())          ; Start List from beginning
          ForEach \LWires()
            If Draw_TWire(\LWires())    ; Subroutine to Draw ECAD-Wire
            Else
              ret= #False
            EndIf  
          Next    
        EndIf
        
        ; --------------------------------------------------
        ;  Draw all ECAD-Graph-Objects
        ; --------------------------------------------------
        If ListSize(\LGraph())
          ResetList(\LGraph())            ; Start List from beginning
          ForEach \LGraph()
            If Draw_TGraphObj(\LGraph())  ; Subroutine to Draw  ECAD-graphical-Object
            Else
              ret= #False
            EndIf  
          Next    
        EndIf
    
        ; --------------------------------------------------
        ;  Draw all ECAD-Text-Objects
        ; --------------------------------------------------
        If ListSize(\LText())
          ResetList(\LText())             ; Start List from beginning
          ForEach \LText()
            If Draw_TText(\LText())       ; Subroutine to Draw ECAD-Text-Object
            Else
              ret= #False
            EndIf  
          Next    
        EndIf
         
      EndWith
      
    Else
      ret = _Exception("Draw_TPageFrame", #ObjectNotExist) 
    EndIf
    
    ProcedureReturn ret
  EndProcedure
  
  ; zeichnet komplette Seite
  Procedure Draw_TPage(*Obj.ECAD::TPage)
  ; ======================================================================
  ; NAME: EcadPage
  ; DESC: Draws a complete ECAD Page
  ; VAR(*Page.ECAD::TPage) ECAD Page Structure
  ; RET: 0 or ExeptionCode
  ; ======================================================================
    
    Protected ret = 0
    
    If *Obj
      ;   List LSymbols.ECAD::TSymbol()   ; List of Symbols on Page
      ;   List LText.ECAD::TText()        ; List of Text-Objects on Page
      ;   List LWires.ECAD::TWire()       ; List of Wires on Page (connections)
      ;   List LGraph.ECAD::TGraphObj()   ; List of Graphical Objects
      
      With *Obj
        ; !!!
        If #False ; xShowFrame  ; we must look later from where we get ShwoFrame
          ret = Draw_TPageFrame(\Frame)  ; Subroutine to Draw the Page Frame
        EndIf
      
        ; --------------------------------------------------
        ;  Draw all ECAD-Symbol-Objects
        ; --------------------------------------------------
        If ListSize(\LSymbols())
          ResetList(\LSymbols())          ; Start List from beginning
          ForEach \LSymbols()
            ret= Draw_TSymbol(\LSymbols())  ; Subroutine to Draw ECAD-Symbol
          Next    
        EndIf
        
        ; --------------------------------------------------
        ;  Draw all ECAD-Wire-Objects
        ; --------------------------------------------------
        If ListSize(\LWires())
          ResetList(\LWires())        ; Start List from beginning
          ForEach \LWires()
            If Draw_TWire(\LWires())       ; Subroutine to Draw ECAD-Wire
            Else
              ret= #False             ; Error occured
            EndIf  
          Next    
        EndIf
        
        ; --------------------------------------------------
        ;  Draw all ECAD-Graph-Objects
        ; --------------------------------------------------
        If ListSize(\LGraph())
          ResetList(\LGraph())            ; Start List from beginning
          ForEach \LGraph()
            If Draw_TGraphObj(\LGraph())  ; Subroutine to Draw  ECAD-graphical-Object
            Else
              ret= #False                 ; Error occured
            EndIf  
          Next    
        EndIf
    
        ; --------------------------------------------------
        ;  Draw all ECAD-Text-Objects
        ; --------------------------------------------------
        If ListSize(\LText())
          ResetList(\LText())             ; Start List from beginning
          ForEach \LText()
            If Draw_TText(\LText())    ; Subroutine to Draw ECAD-Text-Object
            Else
              ret= #False                 ; Error occured
            EndIf  
          Next    
        EndIf
         
      EndWith
    Else
      ret = _Exception("TPage", #ObjectNotExist) 
    EndIf
    
    ProcedureReturn ret ; #True if all done, #False if an Error occured
  EndProcedure

EndModule


EnableExplicit

CompilerIf #PB_Compiler_IsMainFile
  
 ; TestCode if we run ECAD_Draw.pb as MainFile
CompilerEndIf

DisableExplicit
; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 700
; FirstLine = 608
; Folding = ----
; CPU = 2