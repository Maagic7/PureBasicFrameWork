; ===========================================================================
;  FILE : PbFw_Module_SVG.pb
;  NAME : Module SVG Grafics [SVG::]
;  DESC : SVG Grafic Functions 
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2023/07/17
; VERSION  :  0.0 Brainstorming
; COMPILER :  PureBasic 6.0
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

; https://drafts.csswg.org/css-color/#hsl-To-rgb

; https://drafts.csswg.org/css-color/

DataSection ; SVG Colors
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
; IDE Options = PureBasic 6.02 LTS (Windows - x64)
; CursorPosition = 82
; Folding = -
; Optimizer
; CPU = 5