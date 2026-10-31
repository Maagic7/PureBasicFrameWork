; ===========================================================================
; FILE : PbFw_Module_SVG.pb
; NAME : Module SVG Grafics [SVG::]
; DESC : SVG Grafic Functions
; DESC :
; SOURCES : https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorial/Patterns
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/07/17
; VERSION  :  0.10 Brainstorming Version
; COMPILER :  PureBasic 6.30
; ===========================================================================
; ChangeLog:
;{
;}
; ===========================================================================

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

;- ----------------------------------------------------------------------
;- Include Files
;  ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_VDraw.pb"
Enumeration 1 ; SVG elements
  #SVG_Element_Box
  #SVG_Element_Circle
  #SVG_Element_Text
  #SVG_Element_WrappedText
  #SVG_Element_TextPath
  #SVG_Element_Line
  #SVG_Element_Ellipse
  #SVG_Element_Polyline
  #SVG_Element_Polygon
  #SVG_Element_Path
  #SVG_Element_Image
  #SVG_Element_PBImage
  #SVG_Element_Base64Image
  #SVG_Element_ForeignObject
  #SVG_Element_Group
  #SVG_Element_GroupCloser
  #SVG_Element_Comment
  #SVG_Element_CustomCode
EndEnumeration
; -----------------------------------------------------
; Shape	      |   Tag     | Description
; -----------------------------------------------------
; Rectangle   | <rect>    | rectangle
; Circle      | <circle>  | circle
; Ellipse     | <ellipse> | ellipse
; Line        | <line>    | line
; Polygon     | <polygon> | closed polygon shape
; Polyline    |<polyline> | polyline
; Path        | <path>    | custom path


; <rect x="50" y="50" width="100" height="50" fill="blue" stroke="black" stroke-width="2"/>
; <circle cx="100" cy="100" r="50" fill="red"/>
; <ellipse cx="100" cy="100" rx="80" ry="50" fill="green"/>
; <line x1="10" y1="10" x2="200" y2="100" stroke="black" stroke-width="2"/>
; <polygon points="50,10 90,90 10,90" fill="yellow" stroke="black"/>
; <path d="M10 80 C40 10, 65 10, 95 80 S150 150, 180 80" stroke="black" fill="transparent"/>
;          M=MoveTo x y


;<path d="M798 951H118L522.7 81z" fill="#FFACC2" />
; M798 951 → Moves To a slightly different x position (798 instead of 908).
; H118 → Draws a horizontal line To x = 118.
; L522.7 81 → Draws a line To (522.7, 81).
; z → Closes the shape.
; fill="#FFACC2" → Fills the shape With a lighter pink (#FFACC2).

; commands
; M x y : Move to the absolute coordinates x,y
; m x y : Move to the right x and down y (or left and up if negative values)
; L x y : Draw a straight line to the absolute coordinates x,y
; l x y : Draw a straight line to a point that is relatively right x and down y (or left and up if negative values)
; H x   : Draw a line horizontally to the exact coordinate x
; h x   : Draw a line horizontally relatively to the right x (or to the left if a negative value)
; V y   : Draw a line vertically to the exact coordinate y
; v y   : Draw a line vertically relatively down y (or up if a negative value)
; Z or z: Draw a straight line back to the start of the path

; C cX1,cY1 cX2,cY2 eX,eY : Draw a bezier curve based on two bezier control points and end at specified coordinates
; c                       ; same as C but relative values
; S cX2,cY2 eX,eY : Basically a C command that assumes the first bezier control point is a reflection of the
;                   last bezier point used in the previous S or C command
; s               : same as S but relative values
; Q cX,cY eX,eY   : Draw a bezier curve based a single bezier control point and end at specified coordinates
; q               : same as Q but relative values
; T eX,eY         : Basically a Q command that assumes the first bezier control point is a reflection of the
;                   last bezier point used in the previous Q or T command
; t               : same as T but relative values
; A rX,rY rotation, arc, sweep, eX,eY : Draw an arc that is based on the curve an oval makes. First define the width and height
;                 of the oval. Then the rotation of the oval. Along with the end point, this makes two possible ovals.
;                 So the arc and sweep are either 0 or 1 and determine which oval and which path it will take.
; a               ; same as A but relative

; https://drafts.csswg.org/css-color/#hsl-To-rgb
; https://drafts.csswg.org/css-color/


;- ======================================================================
;- MODULE DECLARATION
;- ======================================================================

DeclareModule SVG

  EnableExplicit

  ; ====================================================================
  ; Core SVG Document Management
  ; ====================================================================
  Declare.i SVG_Create(width.i, height.i, viewBoxX.i = 0, viewBoxY.i = 0, viewBoxW.i = 0, viewBoxH.i = 0)
  Declare.i SVG_Close(svgID.i)
  Declare.i SVG_GetWidth(svgID.i)
  Declare.i SVG_GetHeight(svgID.i)
  Declare.i SVG_SetViewBox(svgID.i, x.i, y.i, width.i, height.i)
  Declare.s SVG_Export(svgID.i, fileName.s = "")

  ; ====================================================================
  ; Shape Creation Procedures
  ; ====================================================================
  Declare.i SVG_AddRect(svgID.i, x.f, y.f, width.f, height.f, fill.s = "blue", stroke.s = "black", strokeWidth.f = 1)
  Declare.i SVG_AddCircle(svgID.i, cx.f, cy.f, r.f, fill.s = "blue", stroke.s = "black", strokeWidth.f = 1)
  Declare.i SVG_AddEllipse(svgID.i, cx.f, cy.f, rx.f, ry.f, fill.s = "blue", stroke.s = "black", strokeWidth.f = 1)
  Declare.i SVG_AddLine(svgID.i, x1.f, y1.f, x2.f, y2.f, stroke.s = "black", strokeWidth.f = 1)
  Declare.i SVG_AddPolyline(svgID.i, points.s, fill.s = "none", stroke.s = "black", strokeWidth.f = 1)
  Declare.i SVG_AddPolygon(svgID.i, points.s, fill.s = "blue", stroke.s = "black", strokeWidth.f = 1)

  ; ====================================================================
  ; Path Operations
  ; ====================================================================
  Declare.i SVG_AddPath(svgID.i, fill.s = "none", stroke.s = "black", strokeWidth.f = 1)
  Declare.i SVG_PathMoveTo(svgID.i, elementID.i, x.f, y.f, absolute.i = #True)
  Declare.i SVG_PathLineTo(svgID.i, elementID.i, x.f, y.f, absolute.i = #True)
  Declare.i SVG_PathHorizontal(svgID.i, elementID.i, x.f, absolute.i = #True)
  Declare.i SVG_PathVertical(svgID.i, elementID.i, y.f, absolute.i = #True)
  Declare.i SVG_PathCubicBezier(svgID.i, elementID.i, x1.f, y1.f, x2.f, y2.f, x.f, y.f, absolute.i = #True)
  Declare.i SVG_PathQuadraticBezier(svgID.i, elementID.i, xc.f, yc.f, x.f, y.f, absolute.i = #True)
  Declare.i SVG_PathArc(svgID.i, elementID.i, rx.f, ry.f, rotation.f, arc.i, sweep.i, x.f, y.f, absolute.i = #True)
  Declare.i SVG_PathClose(svgID.i, elementID.i)

  ; ====================================================================
  ; Text Operations
  ; ====================================================================
  Declare.i SVG_AddText(svgID.i, text.s, x.f, y.f, fontSize.i = 12, fontFamily.s = "Arial", fill.s = "black")
  Declare.i SVG_AddTextPath(svgID.i, text.s, pathID.i, startOffset.f = 0, fontSize.i = 12, fill.s = "black")
  Declare.i SVG_AddWrappedText(svgID.i, text.s, x.f, y.f, maxWidth.f, fontSize.i = 12, fontFamily.s = "Arial", fill.s = "black")

  ; ====================================================================
  ; Attribute Manipulation
  ; ====================================================================
  Declare.i SVG_SetFill(svgID.i, elementID.i, fillColor.s)
  Declare.i SVG_SetStroke(svgID.i, elementID.i, strokeColor.s, strokeWidth.f = 1)
  Declare.i SVG_SetOpacity(svgID.i, elementID.i, opacity.f)
  Declare.i SVG_SetTransform(svgID.i, elementID.i, transformString.s)
  Declare.i SVG_SetStyle(svgID.i, elementID.i, styleString.s)
  Declare.i SVG_SetAttribute(svgID.i, elementID.i, attributeName.s, attributeValue.s)

  ; ====================================================================
  ; Grouping and Containers
  ; ====================================================================
  Declare.i SVG_GroupOpen(svgID.i, id.s = "")
  Declare.i SVG_GroupClose(svgID.i)
  Declare.i SVG_AddGroup(svgID.i, id.s = "")
  Declare.i SVG_SetGroupTransform(svgID.i, groupID.i, transformString.s)

  ; ====================================================================
  ; Images
  ; ====================================================================
  Declare.i SVG_AddImage(svgID.i, href.s, x.f, y.f, width.f, height.f)
  Declare.i SVG_AddBase64Image(svgID.i, imageData.s, mimeType.s, x.f, y.f, width.f, height.f)

  ; ====================================================================
  ; Filters and Effects
  ; ====================================================================
  Declare.i SVG_AddGradient(svgID.i, gradientID.s, type.s, color1.s, color2.s)
  Declare.i SVG_AddGradientStop(svgID.i, gradientID.i, offset.f, color.s)
  Declare.i SVG_AddPattern(svgID.i, patternID.s, href.s, x.f, y.f, width.f, height.f)
  Declare.i SVG_AddFilter(svgID.i, filterID.s)
  Declare.i SVG_AddClipPath(svgID.i, clipPathID.s)
  Declare.i SVG_AddShadow(svgID.i, elementID.i, offsetX.f, offsetY.f, blur.f, color.s)

  ; ====================================================================
  ; Color and Utility Functions
  ; ====================================================================
  Declare.s SVG_ColorNameToHex(colorName.s)
  Declare.i SVG_HexToRGB(hexColor.s, *red.Integer, *green.Integer, *blue.Integer)
  Declare.s SVG_RGBToHex(red.i, green.i, blue.i)
  Declare.i SVG_StringToPoints(pointString.s, Array points.f(2))
  Declare.s SVG_GenerateID()
  Declare.i SVG_ValidateColor(colorString.s)

  ; rendering helpers
  Declare.i SVG_Render(svgID.i, offsetX.f = 0, offsetY.f = 0)
  Declare.s SVG_GetAttribute(tag.s, attr.s)
  Declare.i SVG_ParseColor(color.s)

EndDeclareModule

;- ======================================================================
;- MODULE IMPLEMENTATION
;- ======================================================================

Module SVG

  EnableExplicit
  ; ====================================================================
  ; Internal Data Structures
  ; ====================================================================
  Structure SVG_Document
    id.i
    width.i
    height.i
    viewBoxX.i
    viewBoxY.i
    viewBoxW.i
    viewBoxH.i
    content.s
    elementCount.i
  EndStructure

  Structure SVG_Element
    id.i
    type.a
    properties.s ; Stores attributes as key-value pairs
    pathData.s ; For path elements
  EndStructure

  ; Global management
  Global NextSVGID.i = 0
  Global NextElementID.i = 0

  Global Map SVGDocuments.SVG_Document()
  Global Map SVGElements.SVG_Element()
  ; map for named colors (hex strings)
  Structure SVG_ColorEntry
    hex.s
  EndStructure
  Global Map SVGColorMap.SVG_ColorEntry()

  ; ====================================================================
  ; CORE: Document Management
  ; ====================================================================
  Procedure.i SVG_Create(width.i, height.i, viewBoxX.i = 0, viewBoxY.i = 0, viewBoxW.i = 0, viewBoxH.i = 0)
    ; ================================================================
    ; Create a new SVG document
    ; ================================================================
    Protected svgID.i = NextSVGID
    NextSVGID + 1

    SVGDocuments(Str(svgID))\id = svgID
    SVGDocuments(Str(svgID))\width = width
    SVGDocuments(Str(svgID))\height = height
    SVGDocuments(Str(svgID))\viewBoxX = viewBoxX
    SVGDocuments(Str(svgID))\viewBoxY = viewBoxY
    SVGDocuments(Str(svgID))\viewBoxW = viewBoxW
    SVGDocuments(Str(svgID))\viewBoxH = viewBoxH
    SVGDocuments(Str(svgID))\content = ""
    SVGDocuments(Str(svgID))\elementCount = 0

    ProcedureReturn svgID
  EndProcedure

  Procedure.i SVG_Close(svgID.i)
    ; ================================================================
    ; Close and cleanup SVG document
    ; ================================================================
    If FindMapElement(SVGDocuments(), Str(svgID))
      DeleteMapElement(SVGDocuments())
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.s SVG_Export(svgID.i, fileName.s = "")
    ; ================================================================
    ; Export SVG to string or file
    ; ================================================================
    Protected svgString.s
    Protected document.SVG_Document

    If Not FindMapElement(SVGDocuments(), Str(svgID))
      ProcedureReturn ""
    EndIf

    document = SVGDocuments(Str(svgID))

    ; Build SVG header
    svgString = "<?xml version='1.0' encoding='UTF-8'?>" + #CRLF$
    svgString + "<svg xmlns='http://www.w3.org/2000/svg' "
    svgString + "width='" + Str(document\width) + "' "
    svgString + "height='" + Str(document\height) + "' "

    ; Add viewBox if specified
    If document\viewBoxW > 0 And document\viewBoxH > 0
      svgString + "viewBox='" + Str(document\viewBoxX) + " " + Str(document\viewBoxY) + " " + Str(document\viewBoxW) + " " + Str(document\viewBoxH) + "' "
    EndIf

    svgString + ">" + #CRLF$
    svgString + document\content
    svgString + "</svg>" + #CRLF$

    ; Optionally save to file
    If fileName <> ""
      If CreateFile(0, fileName)
        WriteString(0, svgString)
        CloseFile(0)
      EndIf
    EndIf

    ProcedureReturn svgString
  EndProcedure

  ; ====================================================================
  ; SHAPES: Rectangle, Circle, Ellipse, Lines
  ; ====================================================================
  Procedure.i SVG_AddRect(svgID.i, x.f, y.f, width.f, height.f, fill.s = "blue", stroke.s = "black", strokeWidth.f = 1)
    ; ================================================================
    ; Add rectangle to SVG
    ; ================================================================
    Protected elementID.i = NextElementID
    Protected rectTag.s

    NextElementID + 1

    ; include id attribute so it can be referenced later
    rectTag = "  <rect id='elem_" + Str(elementID) + "' x='" + StrF(x) + "' y='" + StrF(y) + "' width='" + StrF(width) + "' height='" + StrF(height) + "' "
    rectTag + "fill='" + fill + "' stroke='" + stroke + "' stroke-width='" + StrF(strokeWidth) + "'/>" + #CRLF$

    If FindMapElement(SVGDocuments(), Str(svgID))
      SVGDocuments(Str(svgID))\content + rectTag
      SVGDocuments(Str(svgID))\elementCount + 1
    EndIf

    ProcedureReturn elementID
  EndProcedure

  Procedure.i SVG_AddCircle(svgID.i, cx.f, cy.f, r.f, fill.s = "blue", stroke.s = "black", strokeWidth.f = 1)
    ; ================================================================
    ; Add circle to SVG
    ; ================================================================
    Protected elementID.i = NextElementID
    Protected circleTag.s

    NextElementID + 1

    circleTag = "  <circle id='elem_" + Str(elementID) + "' cx='" + StrF(cx) + "' cy='" + StrF(cy) + "' r='" + StrF(r) + "' "
    circleTag + "fill='" + fill + "' stroke='" + stroke + "' stroke-width='" + StrF(strokeWidth) + "'/>" + #CRLF$

    If FindMapElement(SVGDocuments(), Str(svgID))
      SVGDocuments(Str(svgID))\content + circleTag
      SVGDocuments(Str(svgID))\elementCount + 1
    EndIf

    ProcedureReturn elementID
  EndProcedure

  Procedure.i SVG_AddEllipse(svgID.i, cx.f, cy.f, rx.f, ry.f, fill.s = "blue", stroke.s = "black", strokeWidth.f = 1)
    ; ================================================================
    ; Add ellipse to SVG
    ; ================================================================
    Protected elementID.i = NextElementID
    Protected ellipseTag.s

    NextElementID + 1

    ellipseTag = "  <ellipse id='elem_" + Str(elementID) + "' cx='" + StrF(cx) + "' cy='" + StrF(cy) + "' rx='" + StrF(rx) + "' ry='" + StrF(ry) + "' "
    ellipseTag + "fill='" + fill + "' stroke='" + stroke + "' stroke-width='" + StrF(strokeWidth) + "'/>" + #CRLF$

    If FindMapElement(SVGDocuments(), Str(svgID))
      SVGDocuments(Str(svgID))\content + ellipseTag
      SVGDocuments(Str(svgID))\elementCount + 1
    EndIf

    ProcedureReturn elementID
  EndProcedure

  Procedure.i SVG_AddLine(svgID.i, x1.f, y1.f, x2.f, y2.f, stroke.s = "black", strokeWidth.f = 1)
    ; ================================================================
    ; Add line to SVG
    ; ================================================================
    Protected elementID.i = NextElementID
    Protected lineTag.s

    NextElementID + 1

    lineTag = "  <line id='elem_" + Str(elementID) + "' x1='" + StrF(x1) + "' y1='" + StrF(y1) + "' x2='" + StrF(x2) + "' y2='" + StrF(y2) + "' "
    lineTag + "stroke='" + stroke + "' stroke-width='" + StrF(strokeWidth) + "'/>" + #CRLF$

    If FindMapElement(SVGDocuments(), Str(svgID))
      SVGDocuments(Str(svgID))\content + lineTag
      SVGDocuments(Str(svgID))\elementCount + 1
    EndIf

    ProcedureReturn elementID
  EndProcedure

  Procedure.i SVG_AddPolyline(svgID.i, points.s, fill.s = "none", stroke.s = "black", strokeWidth.f = 1)
    ; ================================================================
    ; Add polyline to SVG
    ; ================================================================
    Protected elementID.i = NextElementID
    Protected polylineTag.s

    NextElementID + 1

    polylineTag = "  <polyline id='elem_" + Str(elementID) + "' points='" + points + "' fill='" + fill + "' stroke='" + stroke + "' stroke-width='" + StrF(strokeWidth) + "'/>" + #CRLF$

    If FindMapElement(SVGDocuments(), Str(svgID))
      SVGDocuments(Str(svgID))\content + polylineTag
      SVGDocuments(Str(svgID))\elementCount + 1
    EndIf

    ProcedureReturn elementID
  EndProcedure

  Procedure.i SVG_AddPolygon(svgID.i, points.s, fill.s = "blue", stroke.s = "black", strokeWidth.f = 1)
    ; ================================================================
    ; Add polygon to SVG
    ; ================================================================
    Protected elementID.i = NextElementID
    Protected polygonTag.s

    NextElementID + 1

    polygonTag = "  <polygon id='elem_" + Str(elementID) + "' points='" + points + "' fill='" + fill + "' stroke='" + stroke + "' stroke-width='" + StrF(strokeWidth) + "'/>" + #CRLF$

    If FindMapElement(SVGDocuments(), Str(svgID))
      SVGDocuments(Str(svgID))\content + polygonTag
      SVGDocuments(Str(svgID))\elementCount + 1
    EndIf

    ProcedureReturn elementID
  EndProcedure

  ; ====================================================================
  ; PATHS: Complex path operations
  ; ====================================================================
  Procedure.i SVG_AddPath(svgID.i, fill.s = "none", stroke.s = "black", strokeWidth.f = 1)
    ; ================================================================
    ; Create a new path element (used with other SVG_Path* procedures)
    ; ================================================================
    Protected elementID.i = NextElementID

    NextElementID + 1

    ; Store path element info (actual path data built incrementally)
    SVGElements(Str(elementID))\id = elementID
    SVGElements(Str(elementID))\type = #SVG_Element_Path
    SVGElements(Str(elementID))\pathData = ""
    SVGElements(Str(elementID))\properties = "fill:" + fill + ";stroke:" + stroke + ";stroke-width:" + StrF(strokeWidth)

    ProcedureReturn elementID
  EndProcedure

  Procedure.i SVG_PathMoveTo(svgID.i, elementID.i, x.f, y.f, absolute.i = #True)
    ; ================================================================
    ; Move path pen to coordinate (M for absolute, m for relative)
    ; ================================================================
    If FindMapElement(SVGElements(), Str(elementID))
      If absolute
        SVGElements(Str(elementID))\pathData + "M " + StrF(x) + " " + StrF(y) + " "
      Else
        SVGElements(Str(elementID))\pathData + "m " + StrF(x) + " " + StrF(y) + " "
      EndIf
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.i SVG_PathLineTo(svgID.i, elementID.i, x.f, y.f, absolute.i = #True)
    ; ================================================================
    ; Draw line in path (L for absolute, l for relative)
    ; ================================================================
    If FindMapElement(SVGElements(), Str(elementID))
      If absolute
        SVGElements(Str(elementID))\pathData + "L " + StrF(x) + " " + StrF(y) + " "
      Else
        SVGElements(Str(elementID))\pathData + "l " + StrF(x) + " " + StrF(y) + " "
      EndIf
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.i SVG_PathHorizontal(svgID.i, elementID.i, x.f, absolute.i = #True)
    ; ================================================================
    ; Draw horizontal line (H for absolute, h for relative)
    ; ================================================================
    If FindMapElement(SVGElements(), Str(elementID))
      If absolute
        SVGElements(Str(elementID))\pathData + "H " + StrF(x) + " "
      Else
        SVGElements(Str(elementID))\pathData + "h " + StrF(x) + " "
      EndIf
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.i SVG_PathVertical(svgID.i, elementID.i, y.f, absolute.i = #True)
    ; ================================================================
    ; Draw vertical line (V for absolute, v for relative)
    ; ================================================================
    If FindMapElement(SVGElements(), Str(elementID))
      If absolute
        SVGElements(Str(elementID))\pathData + "V " + StrF(y) + " "
      Else
        SVGElements(Str(elementID))\pathData + "v " + StrF(y) + " "
      EndIf
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.i SVG_PathCubicBezier(svgID.i, elementID.i, x1.f, y1.f, x2.f, y2.f, x.f, y.f, absolute.i = #True)
    ; ================================================================
    ; Draw cubic Bezier curve (C for absolute, c for relative)
    ; ================================================================
    If FindMapElement(SVGElements(), Str(elementID))
      If absolute
        SVGElements(Str(elementID))\pathData + "C " + StrF(x1) + " " + StrF(y1) + " " + StrF(x2) + " " + StrF(y2) + " " + StrF(x) + " " + StrF(y) + " "
      Else
        SVGElements(Str(elementID))\pathData + "c " + StrF(x1) + " " + StrF(y1) + " " + StrF(x2) + " " + StrF(y2) + " " + StrF(x) + " " + StrF(y) + " "
      EndIf
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.i SVG_PathQuadraticBezier(svgID.i, elementID.i, xc.f, yc.f, x.f, y.f, absolute.i = #True)
    ; ================================================================
    ; Draw quadratic Bezier curve (Q for absolute, q for relative)
    ; ================================================================
    If FindMapElement(SVGElements(), Str(elementID))
      If absolute
        SVGElements(Str(elementID))\pathData + "Q " + StrF(xc) + " " + StrF(yc) + " " + StrF(x) + " " + StrF(y) + " "
      Else
        SVGElements(Str(elementID))\pathData + "q " + StrF(xc) + " " + StrF(yc) + " " + StrF(x) + " " + StrF(y) + " "
      EndIf
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.i SVG_PathArc(svgID.i, elementID.i, rx.f, ry.f, rotation.f, arc.i, sweep.i, x.f, y.f, absolute.i = #True)
    ; ================================================================
    ; Draw arc (A for absolute, a for relative)
    ; ================================================================
    If FindMapElement(SVGElements(), Str(elementID))
      If absolute
        SVGElements(Str(elementID))\pathData + "A " + StrF(rx) + " " + StrF(ry) + " " + StrF(rotation) + " " + Str(arc) + " " + Str(sweep) + " " + StrF(x) + " " + StrF(y) + " "
      Else
        SVGElements(Str(elementID))\pathData + "a " + StrF(rx) + " " + StrF(ry) + " " + StrF(rotation) + " " + Str(arc) + " " + Str(sweep) + " " + StrF(x) + " " + StrF(y) + " "
      EndIf
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.i SVG_PathClose(svgID.i, elementID.i)
    ; ================================================================
    ; Close path (Z command)
    ; ================================================================
    If FindMapElement(SVGElements(), Str(elementID))
      SVGElements(Str(elementID))\pathData + "Z "

      ; Now add the complete path to SVG document
      Protected pathTag.s = "  <path id='elem_" + Str(elementID) + "' d='" + SVGElements(Str(elementID))\pathData + "' " + SVGElements(Str(elementID))\properties + "/>" + #CRLF$

      If FindMapElement(SVGDocuments(), Str(svgID))
        SVGDocuments(Str(svgID))\content + pathTag
        SVGDocuments(Str(svgID))\elementCount + 1
      EndIf

      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  ; ====================================================================
  ; UTILITIES: Color conversion and helper functions
  ; ====================================================================
  Procedure SVG_InitColorMap()
    ; ================================================================
    ; Populate SVGColorMap from data section
    ; ================================================================
    Static initialized.i = 0
    If initialized
      ProcedureReturn
    EndIf
    initialized = 1
    Protected colorData.s

    RestorePoint (@StartColors)
    StartColors:
    Read.s colorData
    While colorData <> ""
      Protected name.s = Trim(StringField(colorData, 1, ","))
      Protected hex.s = Trim(StringField(colorData, 2, ","))
      If name <> "" And hex <> ""
        AddMapElement(SVGColorMap(), LCase(name))\hex = hex
      EndIf
      Read.s colorData
    Wend
  EndProcedure

  Procedure.s SVG_ColorNameToHex(colorName.s)
    ; ================================================================
    ; Convert color name to hex code using lookup map
    ; ================================================================
    SVG_InitColorMap()
    Protected key.s = LCase(colorName)
    If FindMapElement(SVGColorMap(), key)
      ProcedureReturn SVGColorMap(key)\hex
    EndIf
    ProcedureReturn ""
  EndProcedure

  Procedure.i SVG_HexToRGB(hexColor.s, *red.Integer, *green.Integer, *blue.Integer)
    ; ================================================================
    ; Convert hex color to RGB components
    ; ================================================================
    Protected hex.s = UCase(hexColor)
    Protected value.i

    If Left(hex, 1) = "#"
      hex = Mid(hex, 2)
    EndIf

    If Len(hex) = 6
      *red\i = Val("$" + Mid(hex, 1, 2))
      *green\i = Val("$" + Mid(hex, 3, 2))
      *blue\i = Val("$" + Mid(hex, 5, 2))
      ProcedureReturn #True
    EndIf

    ProcedureReturn #False
  EndProcedure

  Procedure.s SVG_RGBToHex(red.i, green.i, blue.i)
    ; ================================================================
    ; Convert RGB to hex color
    ; ================================================================
    ProcedureReturn "$" + RSet(Hex(red), 2, "0") + RSet(Hex(green), 2, "0") + RSet(Hex(blue), 2, "0")
  EndProcedure

  Procedure.i SVG_ValidateColor(colorString.s)
    ; ================================================================
    ; Check if color is valid hex or named color
    ; ================================================================
    If Left(colorString, 1) = "$" And Len(colorString) = 7
      ProcedureReturn #True ; Valid hex
    EndIf
    If SVG_ColorNameToHex(colorString) <> ""
      ProcedureReturn #True ; Valid named color
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.s SVG_GenerateID()
    ; ================================================================
    ; Generate unique ID for elements
    ; ================================================================
    Static IDCounter
    IDCounter + 1
    ProcedureReturn "elem_" + Str(IDCounter)
  EndProcedure

  ; ====================================================================
  ; PLACEHOLDERS: Additional procedures to be implemented
  ; ====================================================================
  Procedure.i SVG_GetWidth(svgID.i)
    If FindMapElement(SVGDocuments(), Str(svgID))
      ProcedureReturn SVGDocuments(Str(svgID))\width
    EndIf
    ProcedureReturn 0
  EndProcedure

  Procedure.i SVG_GetHeight(svgID.i)
    If FindMapElement(SVGDocuments(), Str(svgID))
      ProcedureReturn SVGDocuments(Str(svgID))\height
    EndIf
    ProcedureReturn 0
  EndProcedure

  Procedure.i SVG_SetViewBox(svgID.i, x.i, y.i, width.i, height.i)
    If FindMapElement(SVGDocuments(), Str(svgID))
      SVGDocuments(Str(svgID))\viewBoxX = x
      SVGDocuments(Str(svgID))\viewBoxY = y
      SVGDocuments(Str(svgID))\viewBoxW = width
      SVGDocuments(Str(svgID))\viewBoxH = height
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.i GetNextElementID()
    ; ================================================================
    ; Return globally unique element identifier
    ; ================================================================
    static NextElementID
    NextElementID + 1
    ProcedureReturn NextElementID
  EndProcedure

  Procedure.i _SVG_GetColor(colorStr.s)
    If colorStr = "none" Or colorStr = "" : ProcedureReturn #PB_Default : EndIf
    Protected c = SVG_ParseColor(colorStr)
    If c = -1 : ProcedureReturn #PB_Default : EndIf
    ProcedureReturn c
  EndProcedure

  Procedure _SVG_RenderNode(node.i, offsetX.f, offsetY.f)
    If node = 0 : ProcedureReturn : EndIf

    Protected name.s = XMLNodeName(node)
    Protected stroke.s = GetXMLAttribute(node, "stroke")
    Protected fill.s = GetXMLAttribute(node, "fill")
    Protected sw.s = GetXMLAttribute(node, "stroke-width")

    Protected strokeColor.i = _SVG_GetColor(stroke)
    Protected fillColor.i = _SVG_GetColor(fill)
    Protected strokeWidth.d = ValD(sw)

    If sw = "" : strokeWidth = 1.0 : EndIf
    If stroke = "none" : strokeWidth = 0 : EndIf

    VDraw::V_SetStroke(strokeWidth)

    Select name
      Case "g" ; Group
        Protected child = ChildXMLNode(node)
        While child
          _SVG_RenderNode(child, offsetX, offsetY)
          child = NextXMLNode(child)
        Wend

      Case "rect"
        VDraw::V_Box(offsetX + ValD(GetXMLAttribute(node, "x")), offsetY + ValD(GetXMLAttribute(node, "y")), ValD(GetXMLAttribute(node, "width")), ValD(GetXMLAttribute(node, "height")), strokeColor, fillColor)

      Case "circle"
        VDraw::V_Circle(offsetX + ValD(GetXMLAttribute(node, "cx")), offsetY + ValD(GetXMLAttribute(node, "cy")), ValD(GetXMLAttribute(node, "r")), strokeColor, fillColor)

      Case "ellipse"
        VDraw::V_Ellipse(offsetX + ValD(GetXMLAttribute(node, "cx")), offsetY + ValD(GetXMLAttribute(node, "cy")), ValD(GetXMLAttribute(node, "rx")), ValD(GetXMLAttribute(node, "ry")), strokeColor, fillColor)

      Case "line"
        VDraw::V_LineXY(offsetX + ValD(GetXMLAttribute(node, "x1")), offsetY + ValD(GetXMLAttribute(node, "y1")), offsetX + ValD(GetXMLAttribute(node, "x2")), offsetY + ValD(GetXMLAttribute(node, "y2")), strokeColor)

      Case "text"
        VDraw::V_Text(offsetX + ValD(GetXMLAttribute(node, "x")), offsetY + ValD(GetXMLAttribute(node, "y")), GetXMLNodeText(node), fillColor)

      Case "path"
        Protected d.s = GetXMLAttribute(node, "d")
        Protected i, count, cmd.s, val.s
        Protected curX.d, curY.d, startX.d, startY.d
        Protected p.i = 1, l = Len(d)

        MovePathCursor(offsetX, offsetY) ; Reset

        While p <= l
          cmd = Mid(d, p, 1)
          If cmd = " " Or cmd = ","
            p + 1
            Continue
          EndIf

          ; Simple parser assuming space delimited values as generated by this module
          Select cmd
            Case "M", "m" ; MoveTo
              p + 2
              curX = ValD(StringField(Mid(d, p), 1, " ")) : curY = ValD(StringField(Mid(d, p), 2, " "))
              If cmd = "m" : curX + startX : curY + startY : EndIf
              MovePathCursor(offsetX + curX, offsetY + curY)
              startX = curX : startY = curY
              p + Len(StringField(Mid(d, p), 1, " ")) + 1 + Len(StringField(Mid(d, p), 2, " "))

            Case "L", "l" ; LineTo
              p + 2
              curX = ValD(StringField(Mid(d, p), 1, " ")) : curY = ValD(StringField(Mid(d, p), 2, " "))
              If cmd = "l" : curX + PathCursorX() - offsetX : curY + PathCursorY() - offsetY : EndIf
              AddPathLine(offsetX + curX, offsetY + curY)
              p + Len(StringField(Mid(d, p), 1, " ")) + 1 + Len(StringField(Mid(d, p), 2, " "))

            Case "H", "h" ; Horizontal
              p + 2
              curX = ValD(StringField(Mid(d, p), 1, " "))
              If cmd = "h" : curX + PathCursorX() - offsetX : EndIf
              AddPathLine(offsetX + curX, PathCursorY())
              p + Len(StringField(Mid(d, p), 1, " "))

            Case "V", "v" ; Vertical
              p + 2
              curY = ValD(StringField(Mid(d, p), 1, " "))
              If cmd = "v" : curY + PathCursorY() - offsetY : EndIf
              AddPathLine(PathCursorX(), offsetY + curY)
              p + Len(StringField(Mid(d, p), 1, " "))

            Case "C", "c" ; Cubic Bezier
              p + 2
              Protected x1.d, y1.d, x2.d, y2.d, x3.d, y3.d
              x1 = ValD(StringField(Mid(d, p), 1, " ")) : y1 = ValD(StringField(Mid(d, p), 2, " "))
              x2 = ValD(StringField(Mid(d, p), 3, " ")) : y2 = ValD(StringField(Mid(d, p), 4, " "))
              x3 = ValD(StringField(Mid(d, p), 5, " ")) : y3 = ValD(StringField(Mid(d, p), 6, " "))
              If cmd = "c"
                Protected px.d = PathCursorX() - offsetX, py.d = PathCursorY() - offsetY
                x1 + px : y1 + py : x2 + px : y2 + py : x3 + px : y3 + py
              EndIf
              AddPathCurve(offsetX + x1, offsetY + y1, offsetX + x2, offsetY + y2, offsetX + x3, offsetY + y3)
              p + Len(StringField(Mid(d, p), 1, " ")) + 1 + Len(StringField(Mid(d, p), 2, " ")) + 1 + Len(StringField(Mid(d, p), 3, " ")) + 1 + Len(StringField(Mid(d, p), 4, " ")) + 1 + Len(StringField(Mid(d, p), 5, " ")) + 1 + Len(StringField(Mid(d, p), 6, " "))

            Case "Z", "z"
              ClosePath()
              p + 1

            Default
              p + 1
          EndSelect
        Wend

        If fillColor <> #PB_Default
          VectorSourceColor(fillColor)
          FillPath(#PB_Path_Preserve)
        EndIf
        If strokeWidth > 0 And strokeColor <> #PB_Default
          VectorSourceColor(strokeColor)
          StrokePath(strokeWidth)
        EndIf

    EndSelect
  EndProcedure

  Procedure.i SVG_Render(svgID.i, offsetX.f = 0, offsetY.f = 0)
    Protected xmlString.s = SVG_Export(svgID)
    If xmlString = "" : ProcedureReturn #False : EndIf

    Protected *Buffer = UTF8(xmlString)
    Protected xml.i = CatchXML(#PB_Any, *Buffer, MemorySize(*Buffer))
    FreeMemory(*Buffer)

    If xml And XMLStatus(xml) = #PB_XML_Success
      _SVG_RenderNode(MainXMLNode(xml), offsetX, offsetY)
      FreeXML(xml)
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.s SVG_GetAttribute(tag.s, attr.s)
    Protected key.s = attr + "='"
    Protected pos.i = FindString(tag, key)
    If pos
      pos + Len(key)
      Protected endPos.i = FindString(tag, "'", pos)
      If endPos
        ProcedureReturn Mid(tag, pos, endPos - pos)
      EndIf
    EndIf
    ProcedureReturn ""
  EndProcedure

  Procedure.i SVG_ParseColor(color.s)
    Protected hex.s = color
    Protected r, g, b
    If Left(color, 1) <> "#"
      hex = SVG_ColorNameToHex(color)
    EndIf

    If hex = "" : ProcedureReturn -1 : EndIf
    SVG_HexToRGB(hex, @r, @g, @b)
    ProcedureReturn RGB(r, g, b)
  EndProcedure

  ; Text operations (stubs)
  Procedure.i SVG_AddText(svgID.i, text.s, x.f, y.f, fontSize.i = 12, fontFamily.s = "Arial", fill.s = "black")
    ; ================================================================
    ; Insert text element into document
    ; ================================================================
    Protected elementID.i = GetNextElementID()
    Protected tag.s = "  <text id='elem_" + Str(elementID) + "' x='" + StrF(x) + "' y='" + StrF(y) + "' "
    tag + "font-size='" + Str(fontSize) + "' font-family='" + fontFamily + "' fill='" + fill + "'>" + text + "</text>" + #CRLF$

    If FindMapElement(SVGDocuments(), Str(svgID))
      SVGDocuments(Str(svgID))\content + tag
      SVGDocuments(Str(svgID))\elementCount + 1
    EndIf

    ProcedureReturn elementID
  EndProcedure

  Procedure.i SVG_AddTextPath(svgID.i, text.s, pathID.i, startOffset.f = 0, fontSize.i = 12, fill.s = "black")
    ; ================================================================
    ; Insert text attached to a path element
    ; ================================================================
    Protected elementID.i = GetNextElementID()
    Protected tag.s = "  <text id='elem_" + Str(elementID) + "' font-size='" + Str(fontSize) + "' fill='" + fill + "'>" + #CRLF$
    tag + "    <textPath href='#elem_" + Str(pathID) + "' startOffset='" + StrF(startOffset) + "'>" + text + "</textPath>" + #CRLF$
    tag + "  </text>" + #CRLF$

    If FindMapElement(SVGDocuments(), Str(svgID))
      SVGDocuments(Str(svgID))\content + tag
      SVGDocuments(Str(svgID))\elementCount + 1
    EndIf

    ProcedureReturn elementID
  EndProcedure

  Procedure.i SVG_AddWrappedText(svgID.i, text.s, x.f, y.f, maxWidth.f, fontSize.i = 12, fontFamily.s = "Arial", fill.s = "black")
    ; simple wrapper - real wrapping requires measuring text, not implemented
    ProcedureReturn SVG_AddText(svgID, text, x, y, fontSize, fontFamily, fill)
  EndProcedure

  ; Attribute operations (stubs)
  Procedure.i SVG_SetFill(svgID.i, elementID.i, fillColor.s)
    ProcedureReturn SVG_SetAttribute(svgID, elementID, "fill", fillColor)
  EndProcedure

  Procedure.i SVG_SetStroke(svgID.i, elementID.i, strokeColor.s, strokeWidth.f = 1)
    Protected ok1.i = SVG_SetAttribute(svgID, elementID, "stroke", strokeColor)
    Protected ok2.i = SVG_SetAttribute(svgID, elementID, "stroke-width", StrF(strokeWidth))
    ProcedureReturn ok1 & ok2
  EndProcedure

  Procedure.i SVG_SetOpacity(svgID.i, elementID.i, opacity.f)
    ProcedureReturn SVG_SetAttribute(svgID, elementID, "opacity", StrF(opacity))
  EndProcedure

  Procedure.i SVG_SetTransform(svgID.i, elementID.i, transformString.s)
    ProcedureReturn SVG_SetAttribute(svgID, elementID, "transform", transformString)
  EndProcedure

  Procedure.i SVG_SetStyle(svgID.i, elementID.i, styleString.s)
    ProcedureReturn SVG_SetAttribute(svgID, elementID, "style", styleString)
  EndProcedure

  Procedure.i SVG_SetAttribute(svgID.i, elementID.i, attributeName.s, attributeValue.s)
    ; naive search-and-replace within stored content
    If Not FindMapElement(SVGDocuments(), Str(svgID))
      ProcedureReturn #False
    EndIf
    Protected content.s = SVGDocuments(Str(svgID))\content
    Protected idStr.s = "id='elem_" + Str(elementID) + "'"
    Protected pos.i = FindString(content, idStr)
    If pos = 0
      ProcedureReturn #False
    EndIf

    Protected attrKey.s = attributeName + "='"
    Protected attrPos.i = FindString(content, attrKey, pos)
    If attrPos > 0
      Protected endQuote.i = FindString(content, "'", attrPos + Len(attrKey))
      If endQuote > 0
        content = Mid(content, 1, attrPos-1) + attributeName + "='" + attributeValue + "'" + Mid(content, endQuote + 1)
      EndIf
    Else
      ; insert before closing bracket
      Protected closePos.i = FindString(content, "/>", pos)
      If closePos = 0
        closePos = FindString(content, ">", pos)
      EndIf
      If closePos > 0
        content = Mid(content, 1, closePos-1) + " " + attributeName + "='" + attributeValue + "'" + Mid(content, closePos)
      EndIf
    EndIf

    SVGDocuments(Str(svgID))\content = content
    ProcedureReturn #True
  EndProcedure

  ; Group operations (stubs)
  Procedure.i SVG_GroupOpen(svgID.i, id.s = "")
    Protected elementID.i = GetNextElementID()
    Protected tag.s = "  <g id='elem_" + Str(elementID) + "'"
    If id <> "" : tag + " data-id='" + id + "'" : EndIf
    tag + ">" + #CRLF$
    If FindMapElement(SVGDocuments(), Str(svgID))
      SVGDocuments(Str(svgID))\content + tag
      SVGDocuments(Str(svgID))\elementCount + 1
    EndIf
    ProcedureReturn elementID
  EndProcedure

  Procedure.i SVG_GroupClose(svgID.i)
    If FindMapElement(SVGDocuments(), Str(svgID))
      SVGDocuments(Str(svgID))\content + "  </g>" + #CRLF$
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.i SVG_AddGroup(svgID.i, id.s = "")
    Protected grpID.i = SVG_GroupOpen(svgID, id)
    SVG_GroupClose(svgID)
    ProcedureReturn grpID
  EndProcedure

  Procedure.i SVG_SetGroupTransform(svgID.i, groupID.i, transformString.s)
    ProcedureReturn SVG_SetTransform(svgID, groupID, transformString)
  EndProcedure

  ; Image operations (stubs)
  Procedure.i SVG_AddImage(svgID.i, href.s, x.f, y.f, width.f, height.f)
    Protected elementID.i = GetNextElementID()
    Protected tag.s = "  <image id='elem_" + Str(elementID) + "' href='" + href + "' x='" + StrF(x) + "' y='" + StrF(y) + "' "
    tag + "width='" + StrF(width) + "' height='" + StrF(height) + "'/>" + #CRLF$
    If FindMapElement(SVGDocuments(), Str(svgID))
      SVGDocuments(Str(svgID))\content + tag
      SVGDocuments(Str(svgID))\elementCount + 1
    EndIf
    ProcedureReturn elementID
  EndProcedure

  Procedure.i SVG_AddBase64Image(svgID.i, imageData.s, mimeType.s, x.f, y.f, width.f, height.f)
    Protected elementID.i = GetNextElementID()
    Protected dataUri.s = "data:" + mimeType + ";base64," + imageData
    Protected tag.s = "  <image id='elem_" + Str(elementID) + "' href='" + dataUri + "' x='" + StrF(x) + "' y='" + StrF(y) + "' "
    tag + "width='" + StrF(width) + "' height='" + StrF(height) + "'/>" + #CRLF$
    If FindMapElement(SVGDocuments(), Str(svgID))
      SVGDocuments(Str(svgID))\content + tag
      SVGDocuments(Str(svgID))\elementCount + 1
    EndIf
    ProcedureReturn elementID
  EndProcedure

  ; Effects and filters (stubs)
  Procedure.i SVG_AddGradient(svgID.i, gradientID.s, type.s, color1.s, color2.s)
    Protected elementID.i = GetNextElementID()
    Protected gradTag.s = "  <defs>" + #CRLF$
    gradTag + "    <" + type + " id='" + gradientID + "'>" + #CRLF$
    gradTag + "      <stop offset='0%' stop-color='" + color1 + "'/>" + #CRLF$
    gradTag + "      <stop offset='100%' stop-color='" + color2 + "'/>" + #CRLF$
    gradTag + "    </" + type + ">" + #CRLF$
    gradTag + "  </defs>" + #CRLF$
    If FindMapElement(SVGDocuments(), Str(svgID))
      SVGDocuments(Str(svgID))\content + gradTag
      SVGDocuments(Str(svgID))\elementCount + 1
    EndIf
    ProcedureReturn elementID
  EndProcedure

  Procedure.i SVG_AddGradientStop(svgID.i, gradientID.i, offset.f, color.s)
    ; already handled in SVG_AddGradient: no additional work
    ProcedureReturn #True
  EndProcedure

  Procedure.i SVG_AddPattern(svgID.i, patternID.s, href.s, x.f, y.f, width.f, height.f)
    Protected elementID.i = GetNextElementID()
    Protected tag.s = "  <defs>" + #CRLF$
    tag + "    <pattern id='" + patternID + "' x='" + StrF(x) + "' y='" + StrF(y) + "' width='" + StrF(width) + "' height='" + StrF(height) + "'>" + #CRLF$
    tag + "      <image href='" + href + "' width='" + StrF(width) + "' height='" + StrF(height) + "'/>" + #CRLF$
    tag + "    </pattern>" + #CRLF$
    tag + "  </defs>" + #CRLF$
    If FindMapElement(SVGDocuments(), Str(svgID))
      SVGDocuments(Str(svgID))\content + tag
      SVGDocuments(Str(svgID))\elementCount + 1
    EndIf
    ProcedureReturn elementID
  EndProcedure

  Procedure.i SVG_AddFilter(svgID.i, filterID.s)
    Protected elementID.i = GetNextElementID()
    Protected tag.s = "  <defs>" + #CRLF$
    tag + "    <filter id='" + filterID + "'></filter>" + #CRLF$
    tag + "  </defs>" + #CRLF$
    If FindMapElement(SVGDocuments(), Str(svgID))
      SVGDocuments(Str(svgID))\content + tag
      SVGDocuments(Str(svgID))\elementCount + 1
    EndIf
    ProcedureReturn elementID
  EndProcedure

  Procedure.i SVG_AddClipPath(svgID.i, clipPathID.s)
    Protected elementID.i = GetNextElementID()
    Protected tag.s = "  <defs>" + #CRLF$
    tag + "    <clipPath id='" + clipPathID + "'></clipPath>" + #CRLF$
    tag + "  </defs>" + #CRLF$
    If FindMapElement(SVGDocuments(), Str(svgID))
      SVGDocuments(Str(svgID))\content + tag
      SVGDocuments(Str(svgID))\elementCount + 1
    EndIf
    ProcedureReturn elementID
  EndProcedure

  Procedure.i SVG_AddShadow(svgID.i, elementID.i, offsetX.f, offsetY.f, blur.f, color.s)
    Protected shadowID.s = "shadow_" + Str(elementID)
    Protected filterTag.s
    filterTag = "  <defs>" + #CRLF$
    filterTag + "    <filter id='" + shadowID + "'>" + #CRLF$
    filterTag + "      <feDropShadow dx='" + StrF(offsetX) + "' dy='" + StrF(offsetY) + "' stdDeviation='" + StrF(blur) + "' flood-color='" + color + "'/>" + #CRLF$
    filterTag + "    </filter>" + #CRLF$
    filterTag + "  </defs>" + #CRLF$
    If FindMapElement(SVGDocuments(), Str(svgID))
      SVGDocuments(Str(svgID))\content + filterTag
      SVGDocuments(Str(svgID))\elementCount + 1
      SVG_SetAttribute(svgID, elementID, "filter", "url(#" + shadowID + ")")
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure

  Procedure.i SVG_StringToPoints(pointString.s, Array points.f(2))
    Protected count.i = 0
    Protected pair.s
    For i = 1 To CountString(pointString, " ") + 1
      pair = StringField(pointString, i, " ")
      If pair <> ""
        Protected commaPos.i = FindString(pair, ",")
        If commaPos > 0
          points(count, 0) = ValF(Left(pair, commaPos-1))
          points(count, 1) = ValF(Mid(pair, commaPos + 1))
          count + 1
        EndIf
      EndIf
    Next
    ProcedureReturn count
  EndProcedure

  DataSection ; SVG Colors #RRGGBB
    Data.s "aliceblue, #F0F8FF "
    Data.s "antiquewhite, #FAEBD7 "
    Data.s "aqua, #00FFFF "
    Data.s "aquamarine, #7FFFD4 "
    Data.s "azure, #F0FFFF "
    Data.s "beige, #F5F5DC "
    Data.s "bisque, #FFE4C4 "
    Data.s "black, #000000 "
    Data.s "blanchedalmond, #FFEBCD "
    Data.s "blue, #0000FF "
    Data.s "blueviolet, #8A2BE2 "
    Data.s "brown, #A52A2A "
    Data.s "burlywood, #DEB887 "
    Data.s "cadetblue, #5F9EA0 "
    Data.s "chartreuse, #7FFF00 "
    Data.s "chocolate, #D2691E "
    Data.s "coral, #FF7F50 "
    Data.s "cornflowerblue, #6495ED "
    Data.s "cornsilk, #FFF8DC "
    Data.s "crimson, #DC143C "
    Data.s "cyan, #00FFFF "
    Data.s "darkblue, #00008B "
    Data.s "darkcyan, #008B8B "
    Data.s "darkgoldenrod, #B8860B "
    Data.s "darkgray, #A9A9A9 "
    Data.s "darkgreen, #006400 "
    Data.s "darkgrey, #A9A9A9 "
    Data.s "darkkhaki, #BDB76B "
    Data.s "darkmagenta, #8B008B "
    Data.s "darkolivegreen, #556B2F "
    Data.s "darkorange, #FF8C00 "
    Data.s "darkorchid, #9932CC "
    Data.s "darkred, #8B0000 "
    Data.s "darksalmon, #E9967A "
    Data.s "darkseagreen, #8FBC8F "
    Data.s "darkslateblue, #483D8B "
    Data.s "darkslategray, #2F4F4F "
    Data.s "darkslategrey, #2F4F4F "
    Data.s "darkturquoise, #00CED1 "
    Data.s "darkviolet, #9400D3 "
    Data.s "deeppink, #FF1493 "
    Data.s "deepskyblue, #00BFFF "
    Data.s "dimgray, #696969 "
    Data.s "dimgrey, #696969 "
    Data.s "dodgerblue, #1E90FF "
    Data.s "firebrick, #B22222 "
    Data.s "floralwhite, #FFFAF0 "
    Data.s "forestgreen, #228B22 "
    Data.s "fuchsia, #FF00FF "
    Data.s "gainsboro, #DCDCDC "
    Data.s "ghostwhite, #F8F8FF "
    Data.s "gold, #FFD700 "
    Data.s "goldenrod, #DAA520 "
    Data.s "gray, #808080 "
    Data.s "green, #008000 "
    Data.s "greenyellow, #ADFF2F "
    Data.s "grey, #808080 "
    Data.s "honeydew, #F0FFF0 "
    Data.s "hotpink, #FF69B4 "
    Data.s "indianred, #CD5C5C "
    Data.s "indigo, #4B0082 "
    Data.s "ivory, #FFFFF0 "
    Data.s "khaki, #F0E68C "
    Data.s "lavender, #E6E6FA "
    Data.s "lavenderblush , #FFF0F5 "
    Data.s "lawngreen, #7CFC00 "
    Data.s "lemonchiffon, #FFFACD "
    Data.s "lightblue, #ADD8E6 "
    Data.s "lightcoral, #F08080 "
    Data.s "lightcyan, #E0FFFF "
    Data.s "lightgoldenrodyellow, #FAFAD2 "
    Data.s "lightgray, #D3D3D3 "
    Data.s "lightgreen, #90EE90 "
    Data.s "lightgrey, #D3D3D3 "
    Data.s "lightpink, #FFB6C1 "
    Data.s "lightsalmon, #FFA07A "
    Data.s "lightseagreen, #20B2AA "
    Data.s "lightskyblue, #87CEFA "
    Data.s "lightslategray, #778899 "
    Data.s "lightslategrey, #778899 "
    Data.s "lightsteelblue, #B0C4DE "
    Data.s "lightyellow, #FFFFE0 "
    Data.s "lime, #00FF00 "
    Data.s "limegreen, #32CD32 "
    Data.s "linen, #FAF0E6 "
    Data.s "magenta, #FF00FF "
    Data.s "maroon, #800000 "
    Data.s "mediumaquamarine, #66CDAA "
    Data.s "mediumblue, #0000CD "
    Data.s "mediumorchid, #BA55D3 "
    Data.s "mediumpurple, #9370DB "
    Data.s "mediumseagreen, #3CB371 "
    Data.s "mediumslateblue, #7B68EE "
    Data.s "mediumspringgreen, #00FA9A "
    Data.s "mediumturquoise, #48D1CC "
    Data.s "mediumvioletred, #C71585 "
    Data.s "midnightblue, #191970 "
    Data.s "mintcream, #F5FFFA "
    Data.s "mistyrose, #FFE4E1 "
    Data.s "moccasin, #FFE4B5 "
    Data.s "navajowhite, #FFDEAD "
    Data.s "navy, #000080 "
    Data.s "oldlace, #FDF5E6 "
    Data.s "olive, #808000 "
    Data.s "olivedrab, #6B8E23 "
    Data.s "orange, #FFA500 "
    Data.s "orangered, #FF4500 "
    Data.s "orchid, #DA70D6 "
    Data.s "palegoldenrod, #EEE8AA "
    Data.s "palegreen, #98FB98 "
    Data.s "paleturquoise, #AFEEEE "
    Data.s "palevioletred, #DB7093 "
    Data.s "papayawhip, #FFEFD5 "
    Data.s "peachpuff, #FFDAB9 "
    Data.s "peru, #CD853F "
    Data.s "pink, #FFC0CB "
    Data.s "plum, #DDA0DD "
    Data.s "powderblue, #B0E0E6 "
    Data.s "purple, #800080 "
    Data.s "rebeccapurple, #663399 "
    Data.s "red, #FF0000 "
    Data.s "rosybrown, #BC8F8F "
    Data.s "royalblue, #4169E1 "
    Data.s "saddlebrown, #8B4513 "
    Data.s "salmon, #FA8072 "
    Data.s "sandybrown, #F4A460 "
    Data.s "seagreen, #2E8B57 "
    Data.s "seashell, #FFF5EE "
    Data.s "sienna, #A0522D "
    Data.s "silver, #C0C0C0 "
    Data.s "skyblue, #87CEEB "
    Data.s "slateblue, #6A5ACD "
    Data.s "slategray, #708090 "
    Data.s "slategrey, #708090 "
    Data.s "snow, #FFFAFA "
    Data.s "springgreen, #00FF7F "
    Data.s "steelblue, #4682B4 "
    Data.s "tan, #D2B48C "
    Data.s "teal, #008080 "
    Data.s "thistle, #D8BFD8 "
    Data.s "tomato, #FF6347 "
    Data.s "turquoise, #40E0D0 "
    Data.s "violet, #EE82EE "
    Data.s "wheat, #F5DEB3 "
    Data.s "white, #FFFFFF "
    Data.s "whitesmoke, #F5F5F5 "
    Data.s "yellow, #FFFF00 "
    Data.s "yellowgreen, #9ACD32 "

  EndDataSection

EndModule

; ============================================================================
; EXAMPLE USAGE
; ============================================================================
;{
; Protected mysvg = SVG::SVG_Create(400, 300)
;
; ; Add some shapes
; SVG::SVG_AddRect(mysvg, 10, 10, 100, 50, "lightblue", "navy", 2)
; SVG::SVG_AddCircle(mysvg, 200, 100, 40, "red", "darkred", 2)
; SVG::SVG_AddEllipse(mysvg, 300, 200, 60, 40, "yellow", "orange", 3)
;
; ; Create a path
; Protected pathID = SVG::SVG_AddPath(mysvg, "none", "green", 2)
; SVG::SVG_PathMoveTo(mysvg, pathID, 10, 80)
; SVG::SVG_PathLineTo(mysvg, pathID, 50, 150)
; SVG::SVG_PathCubicBezier(mysvg, pathID, 75, 100, 125, 100, 150, 80)
; SVG::SVG_PathClose(mysvg, pathID)
;
; ; Export to file
; SVG::SVG_Export(mysvg, "output.svg")
; SVG::SVG_Close(mysvg)
;}

; IDE Options = PureBasic 6.30 (Windows - x64)
; CursorPosition = 159
; FirstLine = 198
; Folding = -
; Optimizer
; CPU = 5