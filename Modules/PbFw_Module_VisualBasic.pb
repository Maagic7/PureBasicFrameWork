; ===========================================================================
;  FILE : PbFw_Module_VisualBasic.pb
;  NAME : Module Visual Basic VB::
;  DESC : Module which implements functions similar to Visual Basic 6
;  DESC : and Visual Basic for Applications
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2024/01/12
; VERSION  :  0.0 Brainstorming Version
; COMPILER :  PureBasic 6.0
;
; https://learn.microsoft.com/en-us/previous-versions/visualstudio/visual-basic-6/aa265036(v=vs.60)
; https://learn.microsoft.com/en-us/previous-versions/visualstudio/visual-basic-6/aa243028(v=vs.60)

; LICENCE  :  MIT License see https://opensource.org/license/mit/
;             or \PbFramWork\MitLicence.txt
; ===========================================================================
; ChangeLog:
;{ 
;   
;                       
;}
;{ TODO:
;}
; ============================================================================


; ----------------------------------------------------------------------
; Include Files
; ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.pb"              ; PbFw::     FrameWork control Module
XIncludeFile "PbFw_Module_Windows.pb"           ; Win::     
XIncludeFile "PbFw_Module_OperatingSystem.pb"   ; OS::    
; XIncludeFile ""

DeclareModule VB
  ; ----------------------------------------------------------
  
  ; ======================================================================
  ;   C O N S T A N T S   A N D   S T R U C T U R E S
  ; ======================================================================
  
  ;- ----------------------------------------------------------
  ;- Constants
  ;- ----------------------------------------------------------
  
  #vbTrue = -1
  #vbFalse = 0
  
  ;- Align Property
  #vbAlignNone 	= 0 	; Size And location set at design time Or in code
  #vbAlignTop 	= 1 	; Align control To top of form
  #vbAlignBottom =2   ;	Align control To bottom of form
  #vbAlignLeft 	= 3 	; Align control To left of form
  #vbAlignRight =	4   ;	Align control To right of form
  
  ;- Alignment Property
  #vbLeftJustify = 0 	; Left align
  #vbRightJustify = 1 	; Right align
  #vbCenter       =	2   ; Center
  
  ;- AsyncType
  #vbAsyncTypePicture =	0 	  ; The Data is provided in a Picture object.
  #vbAsyncTypeFile    = 1 	  ; The Data is provided in a file that is created by Visual Basic.
  #vbAsyncTypeByteArray =	2 	; The Data is provided As a byte Array that contains the retrieved Data.  It is assumed that the control author will know how To handle the Data.
  
  ;- AsyncStatusCode
  #vbAsyncStatusCodeError = 0 	          ; An error occurred during the asynchronous download.
  #vbAsyncStatusCodeFindingResource =	1 	; AsyncRead is finding the resource specified in AsyncProperty.Status that holds the storage being downloaded.
  #vbAsyncStatusCodeConnecting =	2 	    ; AsyncRead is connecting To the resource specified in AsyncProperty.Status that holds the storage being downloaded.
  #vbAsyncStatusCodeRedirecting =	3 	    ; AsyncRead has been redirected To a different location specified in AsyncRead.Property.Status.
  #vbAsyncStatusCodeBeginDownloadData =	4 ; AsyncRead has begun receiving Data For the storage specified in AsyncProperty.Status.
  #vbAsyncStatusCodeDownloadingData =	5 	; AsyncRead has received more Data For the storage specified in AsyncProperty.Status.
  #vbAsyncStatusCodeEndDownloadData =	6 	; AsyncRead has finished receiving Data For the storage specified in AsyncProperty.Status.
  #vbAsyncStatusCodeUsingCashedCopy =	10 	; AsyncRead is retrieving the requested storage from a cached copy. AsyncProperty.Status is empty.
  #vbAsyncStatusCodeSendingRequest =	11 	; AsyncRead is requesting the storage specified in AsyncProperty.Status.
  #vbAsybcStatusCodeMIMETypeAvailable =	13 	      ; The MIME type of the requested storage is specified in AsyncProperty.Status.
  #vbAsyncStatusCodeCacheFileNameAvailable =	14 	; The filename of the local file cache For requested storage is specified in AsyncProperty.Status.
  #vbAsyncStatusCodeBeginSyncOperation =	15 	    ; The AsyncRead will operate synchronously.
  #vbAsyncstatusCodeEndSyncOperation =	16 	      ; The AsyncRead has completed synchronous operation.
  
  ;- BorderStyle Property Constants
  #vbBSNone =	0 	; No border
  #vbFixedSingle =	1 	; Fixed single
  #vbSizable =2 	; Sizable (forms only)
  #vbFixedDialog =	3 	; Fixed dialog (forms only)
  #vbFixedToolWindow =	4 	; Fixed tool window
  #vbSizableToolWindow =	5 	; Sizable tool window
    
  ;- BorderStyle Property (Shape and Line)
  #vbTransparent  = 0 	; Transparent
  #vbBSSolid      = 1 	; Solid
  #vbBSDash       =	2 	; Dash
  #vbBSDot        = 3 	; Dot
  #vbBSDashDot    = 4 	; Dash-dot
  #vbBSDashDotDot =	5 	; Dash-dot-dot
  #vbBSInsideSolid = 6 	;Inside solid
  
  ;- CallType constants
  #vbMethod =	1 ; Indicates that a method has been invoked.
  #vbGet =	2 	; Indicates a Property Get Procedure.
  #vbLet =	4 	; Indicates a Property Let Procedure.
  #vbSet =	8 	; Indicates a Property Set Procedure.
  
  ;- Comparison constants
  #vbUseCompareOption = -1 	; Performs a comparison by using the setting of the Option Compare statement.
  #vbBinaryCompare    = 0 	; Performs a binary comparison.
  #vbTextCompare      = 1 	; Performs a textual comparison.
  #vbDatabaseCompare  = 2 	; For Microsoft Access (Windows only), performs a comparison based on information contained in your database.
    
    ;- Colors
  #vbBlack    = $0 	    ; Black
  #vbRed      = $FF 	  ; Red
  #vbGreen 	  = $FF00 	; Green
  #vbYellow 	= $FFFF 	; Yellow
  #vbBlue     = $FF0000 ; Blue
  #vbMagenta 	= $FF00FF ; Magenta
  #vbCyan     = $FFFF00 ; Cyan
  #vbWhite    = $FFFFFF ; White
  
  ;- System Colors
  #vbScrollBars 	    = $80000000 	; Scroll bar color
  #vbDesktop 	        = $80000001 	; Desktop color
  #vbActiveTitleBar   = $80000002 	; Color of the title bar For the active window
  #vbInactiveTitleBar = $80000003 	; Color of the title bar For the inactive window
  #vbMenuBar          = $80000004 	; Menu background color
  #vbWindowBackground = $80000005 	; Window background color
  #vbWindowFrame      = $80000006 	; Window frame color
  #vbMenuText         = $80000007 	; Color of text on menus
  #vbWindowText       = $80000008 	; Color of text in windows
  #vbTitleBarText     = $80000009 	; Color of text in caption, size box, And scroll arrow
  #vbActiveBorder     = $8000000A 	; Border color of active window
  #vbInactiveBorder 	= $8000000B 	; Border color of inactive window
  #vbApplicationWorkspace = $8000000C 	; Background color of multiple-document Interface (MDI) applications
  #vbHighlight        = $8000000D 	; Background color of items selected in a control
  #vbHighlightText    = $8000000E 	; Text color of items selected in a control
  #vbButtonFace       = $8000000F 	; Color of shading on the face of command buttons
  #vbButtonShadow     = $80000010 	; Color of shading on the edge of command buttons
  #vbGrayText         = $80000011 	; Grayed (disabled) text
  #vbButtonText       = $80000012 	; Text color on push buttons
  #vbInactiveCaptionText = $80000013 	; Color of text in an inactive caption
  #vb3DHighlight      = $80000014 	; Highlight color For 3D display elements
  #vb3DDKShadow       = $80000015 	; Darkest shadow color For 3D display elements
  #vb3DLight          = $80000016 	; Second lightest of the 3D colors after #vb3Dhighlight
  #vb3DFace           = $8000000F 	; Color of text face
  #vb3Dshadow         = $80000010 	; Color of text shadow
  #vbInfoText         = $80000017 	; Color of text in ToolTips
  #vbInfoBackground   = $80000018 	; Background color of ToolTips
  
  ;- Date Format Constants
  #vbGeneralDate  =	0 	; Display a date And/Or time. For real numbers, display a Data And time. If there is no fractional part, display only a date. If there is no integer part, display time only. Date And time display is determined by your system settings.
  #vbLongDate 	  = 1 	; Display a date using the long date format specified in your computer's regional settings.
  #vbShortDate 	  = 2 	; Display a date using the short date format specified in your computer's regional settings.
  #vbLongTime 	  = 3 	; Display a time using the long time format specified in your computer's regional settings.
  #vbShortTime 	  = 4 	; Display a time using the short time format specified in your computer's regional settings.

  ;- ----------------------------------------------------------
  ;- Data Report Designer Constants
  ;- ----------------------------------------------------------
  
  ; Alignment Constants
  #rptJustifyLeft   =	0 	; The text is aligned left.
  #rptJustifyRight  = 1 	; The text is aligned right.
  #rptJustifyCenter = 2 	; The text is centered.
  
  ; AsyncType Constants
  #rptAsyncPreview= 0 ;	Preview mode. Occurs after invoking the Show method.
  #rptAsyncPrint  = 1 	; Indicates a job has been sent To the printer.
  #rptAsyncExport =	2 	; Indicates a file is being exported.
  
  ; BackStyle Constants
  #rptBkTransparent =	0 	; The control is transparent.
  #rptBkOpaque      = 1 	; The control is opaque.
  
  ; BorderStyle Constants
  #rptBSTransparent =	0	; The border is transparent.
  #rptBSSolid       =	1 ; The border is solid.
  #rptBSDashes      = 2	; The border consists of dashes.
  #rptBSDots        = 3	; The border consists of dots.
  #rptBSDashDot     =	4	; The border consists of dashes And dots.
  #rptBSDashDotDot  = 5	; The border consists of a dash followed by two dots.
  
  ; Error Constants
  #rptErrAccessDenied       = 8513 ; (&H2141) 	Access denied.
  #rptErrBoundCtlNotAllowed =	8551 ; (&H2167) 	; The control can't be placed in this section.
  #rptErrChapterInit        = 8521 ; (&H2149) 	Unable To initialize the chapter.
  #rptErrCollectionIsEmpty  = 8573 ; (&H217D) 	; The collection is empty.
  #rptErrCreatingFont       =	8556 ; (&H216C) 	An error occurred creating the font.
  #rptErrCreatingWindow     =	8572 ; (&H217C) 	An error occurred creating the window.
  #rptErrDuplicateKey       =	8500 ; (&H2134) 	; There is a duplicate key value in the collection.
  #rptErrExportFormatsEmpty =	8506 ; (&H213A) 	; The ExportFormats collection is empty.
  #rptErrFileAlreadyExists  = 8512 ; (&H2140) 	; The file already exists.
  #rptErrGeneralFileIO      = 8510 ; (&H213E) 	File I/O error.
  #rptErrInvalidArg         =	8507 ; (&H213B) 	An argument is invalid.
  #rptErrInvalidColIndex    = 8523 ; (&H214B) 	; The column index is invalid.
  #rptErrInvalidDataField   = 8526 ; (&H214E) 	; The Data field can't be found.
  #rptErrInvalidDateSource  = 8520 ; (&H2148) 	; The Data source is invalid.
  #rptErrInvalidFileFilter  = 8517 ; (&H2145) 	; The file filter is invalid, Or in an invalid format.
  #rptErrInvalidFileVersion = 8511 ; (&H213F) 	; The file version is invalid.
  #rptErrInvalidKey         = 8504 ; (&H2138) 	; The key is invalid.
  #rptErrInvalidName        = 8503 ; (&H2137) 	; The name is invalid.
  #rptErrInvalidPropertyValue =	380 ; (&H17C) 	A property value is invalid.
  #rptErrInvalidRowIndex    = 8524 ; (&H214C) 	; The row index is invalid.
  #rptErrInvalidRowset      = 8522 ; (&H214A) 	; The rowset is invalid.
  #rptErrInvalidTemplate    = 8516 ; (&H2144) 	; The ExportFormat template is invalid.
  #rptErrKeyNotFound        = 8501 ; (&H2135) 	; The key can't be found.
  #rptErrLineBreak          = 8553 ; (&H2169) 	An error occurred wrapping lines of text in the control.
  #rptErrMarginsTooTall     =	8541 ; (&H215D) 	Top And bottom margins are higher than the paper height.
  #rptErrMarginsTooWide     =	8540 ; (&H215C) 	Left And right margins are wider than the paper width.
  #rptErrNotAllowedInReportGenerating =	8576 ; (&H2180) 	This property Or method cannot be accessed during the generation of the report.
  #rptErrObjectNotFoundInCollection =	8574 ; (&H217E) 	; The object can't be found in the collection.
  #rptErrOutOfMemory      = 7 ;	Out of memory.
  #rptErrPathNotFound     =	8514 ; (&H2142) 	; The path can't be found.
  #rptErrPrint            = 8558 ; (&H216E) 	An error occurred during printing.
  #rptErrPrinterInfo      = 8555 ; (&H216B) 	Error obtaining printer information.
  #rptErrPrintInit        = 8557 ; (&H216D) 	An error occurred initializing the printer.
  #rptErrReportTooTall    = 8571 ; (&H217B) 	Sections do Not fit vertically on the page.
  #rptErrReportTooWide    = 8542 ; (&H215E) 	Report width is larger than the paper width.
  #rptErrSectDontMatchData = 8570 ; (&H217A) 	Report sections do Not match Data source.
  #rptErrSharingViolation = 8515 ; (&H2143) 	Cannot access the file because it is being used by another process.
  #rptErrSubscriptRange   =	9 	; The subscript is out of range.
  #rptErrTempFileName     =	8550 ; (&H2166) 	Error generating temporary filename.
  #rptErrTempFileRead     =	8554 ; (&H216A) 	Error opening Or reading from temporary file.
  #rptErrTempFileWrite    = 8552 ; (&H2168) 	Error creating Or writing To temporary file.
  #rptErrTypeMismatch     = 13 	; Type mismatch.
  #rptErrUnexpected       = 8505 ; (&H2139) 	Unexpected error.
  #rptErrUnknown          = 8502 ; (&H2136) 	General error.
  
  ; ExportFormat Constants
  #rptFmtHTML         =	0 ; HTML format.
  #rptFmtText         =	1 	; Text format.
  #rptFmtUnicodeText  =	2 	; Unicode.
  #rptFmtUnicodeHTML_UTF8 =	3 	; HTML encoded in Universal Character Set (UTF - 8)
  
  ;FunctionType Constants
  #rptFuncSum =	0 	; Sum function.
  #rptFuncAve =	1 	; Average.
  #rptFuncMin =	2 	; Minimum
  #rptFuncMax =	3 	; Maximum.
  #rptFuncRCnt =	4 	; Counts the rows in the section.
  #rptFuncVCnt =	5 	; Counts the fields With non-null values.
  #rptFuncSDEV =	6 	; Calculates the standard deviation.
  #rptFuncSERR =	7 	; Calculates the standard error.
  
  ;LineSlant Constants 
  #rptSlantNWSE =	0 	; Line slants from northwest To southeast.
  #rptSlantNESW =	1 	; Line slants from northeast To southwest.
  
  ; PageBreak Constants
  #rptPageBreakNone =	0 	; No page breaks on the section.
  #rptPageBreakBefore =	1 	; Page Break occurs before the section.
  #rptPageBreakAfter =	2 	; Page Break occurs after the section.
  #rptPageBreakBeforeAndAfter =	3 	; Page Break occurs before And after the section.
  
  ;PageRange Constants
  #rptRangeAllPages =	0 	; Print Or export all pages.
  #rptRangeFromTo =	1 	; Print Or export only the named range of pages.
  
  ;PictureAlignment Constants
  #rptPATopLeft     =	0 ; The picture appears at the top left.
  #rptPATop         = 1 ; The picture appears at the top.
  #rptPATopRight    =	2 ; The picture appears at the top right.
  #rptPARight       = 3 ; The picture appears at the right.
  #rptPABottomRight =	4 ; The picture appears at the bottom right.
  #rptPABottom      = 5 ; The picture appears at the bottom.
  #rptPABottomLeft  =	6 ; The picture appears at the bottom left.
  #rptPALeft        = 7 ; The picture appears at the left.
  #rptPACenter      = 8 ; The picture appears centered.
  
  ;Shape Constants
  #rptShpRectangle  = 0 ; Rectangle shape.
  #rptShpSquare     = 1 ; Square shape.
  #rptShpOval       = 2 ; Oval shape.
  #rptShpCircle     = 3 ; Circle shape.
  #rptShpRoundedRectangle =	4 ; Rounded rectangle shape.
  #rptShpRoundedSquare    = 5 ; Rounded square shape.

  ;- DDE Constants
  
  ; linkerr (LinkError Event)
  #vbWrongFormat      = 1 	; Another application requested Data in wrong format
  #vbDDESourceClosed  = 6 	; Destination application attempted To Continue after source closed
  #vbTooManyLinks     = 7 	; All source links are in use
  #vbDataTransferFailed =	8 	; Failure To update Data in destination
  
  ; LinkMode Property (Forms And Controls)
  #vbLinkNone     =	0 	; None
  #vbLinkSource   =	1 	; Source (forms only)
  #vbLinkAutomatic= 1 	; Automatic (controls only)
  #vbLinkManual   = 2 	; Manual (controls only)
  #vbLinkNotify   = 3 	; Notify (controls only)
  
  ; LinkMode Property (Only For backward compatibility With Visual Basic version 1.0; use new constants instead)
  #vbHot    = 1 ; Hot (controls only)
  #vbServer =	1 ; Server (forms only)
  #vbCold   =	2 ; Cold (controls only)
  
  ;- Drag-And-Drop Constants
  
  ; DragOver And OLEDragOver Event
  #vbEnter  = 0 ; Source control dragged into target
  #vbLeave  = 1 ; Source control dragged out of target
  #vbOver   =	2 ; Source control dragged from one position in target To another
  
  ; Drag Method (Controls)
  
  ; TODO! Ccheck #vbCancel
  ; #vbCancel     = 0 ; Cancel drag operation ; double defined with different Value at MsgBox
  #vbBeginDrag  = 1 ; Begin dragging control
  #vbEndDrag    = 2 ; Drop control
  
  ;OLEDragMode Property
  #vbOLEDragManual    = 0 	; Manual
  #vbOLEDragAutomatic =	1 	; Automatic
  
  ;OLEDropMode Property
  #vbOLEDropNone    = 0   ; None
  #vbOLEDropManual  = 1   ; Manual
  #vbOLEDropAutomatic = 2 ; vAutomatic
  
  ; OLE Drop Effect
  
  #vbOLEDropEffectNone =	0 	; No OLE drag/drop operation has taken place
  #vbOLEDropEffectCopy =	1 	; A mask indicating that a copy operation has taken, Or would take, place
  #vbOLEDropEffectMove =	2 	; A mask indicating that a move operation has taken, Or would take, place
  #vbOLEDropEffectScroll =	$80000000 	; A mask indicating that the drop target window has scrolled, Or will scroll
  
  ;- Drawing Constants
  
  ; DrawMode Property
  #vbBlackness =	1   ; Black
  #vbNotMergePen = 2 	; Not Merge pen
  #vbMaskNotPen =	3 	; Mask Not pen
  #vbNotCopyPen =	4 	; Not Copy pen
  #vbMaskPenNot =	5 	; Mask pen Not
  #vbInvert =	6       ; Invert
  #vbXorPen =	7       ; XOr pen
  #vbNotMaskPen =	8   ; Not Mask pen
  #vbMaskPen =	9     ; Mask pen
  #vbNotXorPen =	10 	; Not XOr pen
  #vbNop =	11        ; No operation; output remains unchanged
  #vbMergeNotPen = 12 ; Merge Not pen
  #vbCopyPen =	13    ; Copy pen
  #vbMergePenNot = 14	; Merge pen Not
  #vbMergePen =	15    ; Merge pen
  #vbWhiteness =	16  ; White 
  
  ; DrawStyle Property
  #vbSolid =	0 	    ; Solid
  #vbDash =	1 	      ; Dash
  #vbDot =	2 	      ; Dot
  #vbDashDot =	3 	  ; Dash-dot
  #vbDashDotDot =	4 	; Dash-dot-dot
  #vbInvisible =	5 	; Invisible
  #vbInsideSolid =	6 ; Inside solid

  ;- DriveType Constants
  #Unknown    = 0   ; Drive type can't be determined.
  #Removable  = 1   ; Drive has removable media. This includes all floppy drives And many other varieties of storage devices.
  #Fixed      = 2   ; Drive has fixed (nonremovable) media. This includes all hard drives, including hard drives that are removable.
  #Remote     = 3   ; Network drives. This includes drives Shared anywhere on a network.
  #CDROM      = 4   ; Drive is a CD-ROM. No distinction is made between Read-only And Read/write CD-ROM drives.
  #RAMDisk    = 5   ; Drive is a block of Random Access Memory (RAM) on the local computer that behaves like a disk drive.
  
  ;- File Attribute Constants
  #vbNormal   =	0 	  ; Normal file. No attributes are set.
  #vbReadOnly =	1 	  ; Read-only file. Attribute is Read/write.
  #vbHidden   =	2 	  ; Hidden file. Attribute is Read/write.
  #vbSystem   =	4 	  ; System file. Attribute is Read/write.
  #vbVolume   =	8 	  ; Disk drive volume label. Attribute is Read-only.
  #vbDirectory  = 16 	; Folder Or directory. Attribute is Read-only.
  #vbArchive    = 32 	; File has changed since last backup. Attribute is Read/write.
  #vbAlias      = 64 	; Link Or shortcut. Attribute is Read-only.
  #vbCompressed =	128 ; Compressed file. Attribute is Read-only. 
  
  ;- File Input/Output Constants
  #ForReading =	1 	  ; Open a file For reading only. You can't write to this file.
  #ForWriting =	2 	  ; Open a file For writing. If a file With the same name exists, its previous contents are overwritten.
  #ForAppending =	8   ; Open a file And write To the End of the file.
  
  ;- Graphics Constants
  
  ; FillStyle Property
  #vbFSSolid          = 0 ; Solid
  #vbFSTransparent    = 1 ; Transparent
  #vbHorizontalLine   = 2 ; Horizontal line
  #vbVerticalLine     = 3 ; Vertical line
  #vbUpwardDiagonal   =	4 ; Upward diagonal
  #vbDownwardDiagonal =	5 ; Downward diagonal
  ; TODO! Check #vbCrosshair
  ;#vbCrosshair        = 6 ; Cross      ; This exists double! At Mouse Constans but wiht ohter value???
  #vbDiagonalCross    = 7 ; Diagonal cross
  
  ; ScaleMode Property 
  #vbUser         =	0   ; User
  #vbTwips        = 1   ; Twips
  #vbPoints       =	2   ; Points
  #vbPixels       =	3   ; Pixels
  #vbCharacters   =	4   ; Characters
  #vbInches       = 5   ; Inches
  #vbMillimeters  = 6   ; Millimeters
  #vbCentimeters  = 7   ; Centimeters
  #vbHiMetric     =	8   ; HiMetric
  #vbContainerPosition = 9 	; Units used by the control's container to determine the control's position
  #vbContainerSize    = 10 	; Units used by the control's container to determine the control's size
  
  ; PaletteMode Property
  #vbPaletteModeHalfTone  = 0 	; Use system halftone palette
  #vbPaletteModeUseZOrder =	1 	; Use palette from topmost control that has a palette
  #vbPaletteModeCustom    = 2 	; Use palette specified in Palette property
  #vbPaletteModeContainer =	3 	; Use the container's palette for containers that support ambient Palette property
  #vbPaletteModeNone      = 4 	; Do Not use any palette
  #vbPaletteModeObject    =	5 	; Use the ActiveX designer's palette
  
  ; Help Constants
  #cdlHelpContext     = $1 	; Displays Help For a particular topic
  #cdlHelpQuit        = $2 	; Notifies the Help application that the specified Help file is no longer in use
  #cdlHelpIndex	      = $3 	; Displays the index of the specified Help file
  #cdlHelpContents    =	$3 	; Displays the contents topic in the current Help file
  #cdlHelpHelpOnHelp  = $4 	; Displays Help For using the Help application itself
  #cdlHelpSetIndex 	  = $5 	; Sets the current index For multi-index Help
  #cdlHelpSetContents = $5 	; Designates a specific topic As the contents topic
  #cdlHelpContextPopup= $8 	; Displays a topic identified by a context number
  #cdlHelpForceFile 	= $9 	; Creates a Help file that displays text in only one font
  #cdlHelpKey         = $101 	; Displays Help For a particular keyword
  #cdlHelpCommandHelp = $102 	; Displays Help For a particular command
  #cdlHelpPartialKey 	= $105 	; Calls the search engine in Windows Help  
  
  ;- Key Code Constants
  
  ; Key Codes
  #vbKeyLButton =	1 	; Left mouse button
  #vbKeyRButton =	2 	; Right mouse button
  #vbKeyCancel  = 3 	; CANCEL key
  #vbKeyMButton =	4 	; Middle mouse button
  #vbKeyBack    = 8 	; BACKSPACE key
  #vbKeyTab     =	9 	; TAB key
  #vbKeyClear   =	12 	; CLEAR key
  #vbKeyReturn  =	13 	; ENTER key
  #vbKeyShift   =	16 	; SHIFT key
  #vbKeyControl =	17 	; CTRL key
  #vbKeyMenu    = 18 	; MENU key
  #vbKeyPause   =	19  ; PAUSE key
  #vbKeyCapital =	20 	; CAPS LOCK key
  #vbKeyEscape  = 27 	; ESC key
  #vbKeySpace   = 32 	; SPACEBAR key
  #vbKeyPageUp  = 33 	; PAGE UP key
  #vbKeyPageDown= 34 	; PAGE DOWN key
  #vbKeyEnd     =	35 	; End key
  #vbKeyHome    = 36 	; HOME key
  #vbKeyLeft    = 37 	; LEFT ARROW key
  #vbKeyUp      = 38 	; UP ARROW key
  #vbKeyRight   = 39 	; RIGHT ARROW key
  #vbKeyDown    = 40 	; DOWN ARROW key
  #vbKeySelect  = 41 	; Select key
  #vbKeyPrint   = 42 	; PRINT SCREEN key
  #vbKeyExecute =	43 	; EXECUTE key
  #vbKeySnapshot= 44 	; SNAPSHOT key
  #vbKeyInsert  = 45 	; INS key
  #vbKeyDelete  = 46 	; DEL key
  #vbKeyHelp    = 47  ; HELP key
  #vbKeyNumlock = 144 ; NUM LOCK key 
  
  ; KeyA Through KeyZ Are the Same As Their ASCII
  #vbKeyA =	65 	; A key
  #vbKeyB =	66 	; B key
  #vbKeyC =	67 	; C key
  #vbKeyD =	68 	; D key
  #vbKeyE =	69 	; E key
  #vbKeyF =	70 	; F key
  #vbKeyG =	71 	; G key
  #vbKeyH =	72 	; H key
  #vbKeyI =	73 	; I key
  #vbKeyJ =	74 	; J key
  #vbKeyK =	75 	; K key
  #vbKeyL =	76 	; L key
  #vbKeyM =	77 	; M key
  #vbKeyN =	78 	; N key
  #vbKeyO =	79 	; O key
  #vbKeyP =	80 	; P key
  #vbKeyQ =	81 	; Q key
  #vbKeyR =	82 	; R key
  #vbKeyS =	83 	; S key
  #vbKeyT =	84 	; T key
  #vbKeyU =	85 	; U key
  #vbKeyV =	86 	; V key
  #vbKeyW =	87 	; W key
  #vbKeyX =	88 	; X key
  #vbKeyY =	89 	; Y key
  #vbKeyZ =	90 	; Z key
  
  ; Key0 Through Key9 Are the Same As Their ASCII Equivalents: '0' Through '9
  #vbKey0 =	48 	; 0 key
  #vbKey1 =	49 	; 1 key
  #vbKey2 =	50 	; 2 key
  #vbKey3 =	51 	; 3 key
  #vbKey4 =	52 	; 4 key
  #vbKey5 =	53 	; 5 key
  #vbKey6 =	54 	; 6 key
  #vbKey7 =	55 	; 7 key
  #vbKey8 =	56 	; 8 key
  #vbKey9 =	57 	; 9 key
  
  ; Keys on the Numeric Keypad
  #vbKeyNumpad0 =	96 	  ; 0 key
  #vbKeyNumpad1 =	97 	  ; 1 key
  #vbKeyNumpad2 =	98 	  ; 2 key
  #vbKeyNumpad3 =	99 	  ; 3 key
  #vbKeyNumpad4 =	100 	; 4 key
  #vbKeyNumpad5 =	101 	; 5 key
  #vbKeyNumpad6 =	102 	; 6 key
  #vbKeyNumpad7 =	103 	; 7 key
  #vbKeyNumpad8 =	104 	; 8 key
  #vbKeyNumpad9 =	105 	; 9 key
  #vbKeyMultiply =106 	; MULTIPLICATION Sign (*) key
  #vbKeyAdd     =	107 	; PLUS Sign (+) key
  #vbKeySeparator=108 	; ENTER (keypad) key
  #vbKeySubtract =109 	; MINUS Sign (-) key
  #vbKeyDecimal = 110 	; DECIMAL Point(.) key
  #vbKeyDivide  = 111 	; DIVISION Sign (/) key

  ; Function Keys
  #vbKeyF1 =	112 	; F1 key
  #vbKeyF2 =	113 	; F2 key
  #vbKeyF3 =	114 	; F3 key
  #vbKeyF4 =	115 	; F4 key
  #vbKeyF5 =	116 	; F5 key
  #vbKeyF6 =	117 	; F6 key
  #vbKeyF7 =	118 	; F7 key
  #vbKeyF8 =	119 	; F8 key
  #vbKeyF9 =	120 	; F9 key
  #vbKeyF10 =	121 	; F10 key
  #vbKeyF11 =	122 	; F11 key
  #vbKeyF12 =	123 	; F12 key
  #vbKeyF13 =	124 	; F13 key
  #vbKeyF14 =	125 	; F14 key
  #vbKeyF15 =	126 	; F15 key
  #vbKeyF16 =	127 	; F16 key
  
  ; Miscellaneous Constants
  
  ; AsyncRead Method
  #vbAsyncTypePicture =	0 	; Data is provided in a Picture object
  #vbAsyncTypeFile    = 1 	; Data is provided in a file provide by Visual Basic
  #vbAsyncTypeByteArray = 2 ; Data is provided in a byte Array that contains the retrieved Data
  
  ; Application Start Mode
  #vbSModeStandalone = 0 	; Stand-alone application
  #vbSModeAutomation = 1 	; Automated ActiveX component
  
  ; Buttons (Applies To CommandButton, CheckBox, And OptionButton controls)
  #vbButtonStandard   =	0 ; Buttons have standard Windows appearance
  #vbButtonGraphical  =	1 ; Buttons have graphical appearance (that is, they contain pictures, text, And/Or a non-standard BackColor)
  
  ; LoadResPicture Method
  #vbResBitmap  = 0 ; Bitmap resource
  #vbResIcon    = 1 ; Icon resource
  #vbResCursor  = 2 ; Cursor resource
  
  ; LogEvent Method
  #vbLogEventTypeError        = 1 ; Log an Error event
  #vbLogEventTypeWarning      = 2 ; Log a Warning event
  #vbLogEventTypeInformation  = 4 ; Log an Information event
  
  ; Mouse Button Parameter Masks
  #vbLeftButton   =	1	  ; Left mouse button
  #vbRightButton  = 2	  ; Right mouse button
  #vbMiddleButton =	4	  ; Middle mouse button
  
  ; QueryUnload Method
  #vbAppWindows   =	2 	  ; Current Windows session ending
  #vbFormMDIForm  = 4	    ; MDI child form is closing because the MDI form is closing
  #vbFormCode     =	1     ; Unload method invoked from code
  #vbFormControlMenu = 0 	; User has chosen Close command from the Control-menu box on a form
  #vbAppTaskManager  = 3 	; Windows Task Manager is closing the application
  
  ; Shift Parameter Masks
  #vbShiftMask  = 1 	; SHIFT key bit mask
  #vbCtrlMask   =	2 	; CTRL key bit mask
  #vbAltMask    = 4 	; ALT key bit mask 
  
  ; ZOrder Method 
  #vbBringToFront =	0 ; Bring To front
  #vbSendToBack   =	1 ; Send To back

  ; Mouse Pointer Constants
  #vbDefault    = 0 	; Default
  #vbArrow      = 1 	; Arrow
  #vbCrosshair  = 2 	; Cross
  #vbIbeam      = 3 ; I beam
  #vbIconPointer =4 	; Icon
  #vbSizePointer =5 	; Size
  #vbSizeNESW   = 6 	; Size NE, SW
  #vbSizeNS     = 7 	; Size N, S
  #vbSizeNWSE   = 8 	; Size NW, SE
  #vbSizeWE     = 9	  ; Size W, E
  #vbUpArrow    = 10 	; Up arrow
  #vbHourglass  = 11 	; Hourglass
  #vbNoDrop     = 12 	; No drop
  #vbArrowHourglass =	13 	; Arrow And hourglass
  #vbArrowQuestion =	14 	; Arrow And question mark
  #vbSizeAll    = 15 	; Size all
  #vbCustom     = 99 	; Custom icon specified by the MouseIcon property
  
  ; RasterOp Constants
  #vbDstInvert 	  = $00550009   ; Inverts the destination bitmap
  #vbMergeCopy 	  = $00C000CA 	; Combines the pattern And the source bitmap
  #vbMergePaint 	= $00BB0226 	; Combines the inverted source bitmap With the destination bitmap by using Or
  #vbNotSrcCopy 	= $00330008 	; Copies the inverted source bitmap To the destination
  #vbNotSrcErase 	= $001100A6 	; Inverts the result of combining the destination And source bitmaps by using Or
  #vbPatCopy 	    = $00F00021 	; Copies the pattern To the destination bitmap
  #vbPatInvert 	  = $005A0049 	; Combines the destination bitmap With the pattern by using XOr
  #vbPatPaint 	  = $00FB0A09 	; Combines the inverted source bitmap With the pattern by using Or. Combines the result of this operation With the destination bitmap by using Or
  #vbSrcAnd 	    = $008800C6 	; Combines pixels of the destination And source bitmaps by using And
  #vbSrcCopy 	    = $00CC0020 	; Copies the source bitmap To the destination bitmap
  #vbSrcErase 	  = $00440328 	; Inverts the destination bitmap And combines the result With the source bitmap by using And
  #vbSrcInvert 	  = $00660046 	; Combines pixels of the destination And source bitmaps by using XOr
  #vbSrcPaint 	  = $00EE0086 	; Combines pixels of the destination And source bitmaps by using Or
  
  ; SpecialFolder Constants
  #WindowsFolder    = 0 	; The Windows folder contains files installed by the Windows operating system.
  #SystemFolder     =	1 	; The System folder contains libraries, fonts, And device drivers.
  #TemporaryFolder  = 2 	; The Temp folder is used To store temporary files. Its path is found in the TMP environment variable.
  
  ; StateManagement Property Constants
  #WcNoState        = 1   ; The WebClass object will be instantiated And destroyed For every HTTP request that is processed. 
  #wcRetainInstance =	2 	; The WebClass object is instantiated when the first HTTP request is received And Not destroyed Until either the ReleaseInstance method is called Or the session times out. 
  
  ; Tristate Constants
  #vbTrue =	1 	; True
  #vbFalse = 0 	; False
  #vbUseDefault =	2 	; Use Default setting
    
  ; Variant Type Constants
  #vbVEmpty   =	0 	; Empty (uninitialized)
  #vbVNull    = 1 	; Null (no valid Data)
  #vbVInteger =	2 	; Integer Data type
  #vbVLong    = 3 	; Long integer Data type
  #vbVSingle  = 4 	; Single-precision floating-point Data type
  #vbVDouble  = 5 	; Double-precision floating-point Data type
  #vbVCurrency =6 	; Currency (scaled integer) Data type
  #vbVDate    = 7 	; Date Data type
  #vbVString  = 8 	; String Data type
  
  ; Clipboard Object Constants
  #vbCFRTF =	-16639 	; Rich Text Format (.rtf file)
  #vbCFLink =	-16640 	; DDE conversation information
  #vbCFText     =	1 	; Text (.txt file)
  #vbCFBitmap   =	2 	; Bitmap (.bmp file)
  #vbCFMetafile =	3 	; Metafile (.wmf file)
  #vbCFDIB      = 8 	; Device-independent bitmap
  #vbCFPalette  = 9 	; Color palette
  #vbCFEMetaFile = 14 	; Enhanced metafile (.emf file)
  #vbCFFiles    = 15 	; File List from Windows Explorer
  
  ;- Form Constants
  ; Show Parameters
  ;- String constants
  #vbModal =	1 	    ; Modal Form
  #vbModeless =	0 	  ; Modeless Form
  
  ; Arrange Methode For MDI Forms
  #vbCascade =	0 	      ; Cascade all nonminimized MDI child forms
  #vbTileHorizontal =	1 	; Horizontally tile all nonminimized MDI child forms
  #vbTileVertical =	2 	  ; Vertically tile all nonminimized MDI child forms
  #vbArrangeIcons =	3 	  ; Arrange icons For minimized MDI child forms
    
  ;WindowState Property  
  #vbNormal =	0 	    ; Normal
  #vbMinimized =	1 	; Minimized
  #vbMaximized =	2 	; Maximized
  
  ;- Printer Object Constants
  
  ; Printer Color Mode
  #vbPRCMMonochrome   =	1 	; Monochrome output
  #vbPRCMColor        = 2 	; Color output
  ; Duplex Printing
  #vbPRDPSimplex      = 1 	; Single-sided printing
  #vbPRDPHorizontal   =	2 	; Double-sided horizontal printing
  #vbPRDPVertical     =	3 	; Double-sided vertical printing
  ; Printer Orientation
  #vbPRORPortrait     =	1 	; Documents print With the top at the narrow side of the paper
  #vbPRORLandscape    = 2 	; Documents print With the top at the wide side of the paper
  ; Print Quality
  #vbPRPQDraft        = -1 	; Draft print quality
  #vbPRPQLow          = -2  ; Low print quality
  #vbPRPQMedium       =	-3 	; Medium print quality
  #vbPRPQHigh         =	-4 	; High print quality
  ; PaperBin Property
  #vbPRBNUpper        = 1 	; Use paper from the upper bin
  #vbPRBNLower        = 2 	; Use paper from the lower bin
  #vbPRBNMiddle       = 3 	; Use paper from the middle bin
  #vbPRBNManual       = 4 	; Wait For manual insertion of each sheet of paper
  #vbPRBNEnvelope     = 5 	; Use envelopes from the envelope feeder
  #vbPRBNEnvManual    = 6 	; Use envelopes from the envelope feeder, but wait For manual insertion
  #vbPRBNAuto         = 7 	; (Default) Use paper from the current Default bin
  #vbPRBNTractor      = 8 	; Use paper fed from the tractor feeder
  #vbPRBNSmallFmt     = 9 	; Use paper from the small paper feeder
  #vbPRBNLargeFmt     = 10 	; Use paper from the large paper bin
  #vbPRBNLargeCapacity = 11 ; Use paper from the large capacity feeder
  #vbPRBNCassette     = 14 	; Use paper from the attached cassette cartridge
  
  ; PaperSize Property
  #vbPRPSLetter       =	1 	; Letter, 8 1/2 x 11 in
  #vbPRPSLetterSmall  =	2   ; +A611Letter Small, 8 1/2 x 11 in
  #vbPRPSTabloid      =	3 	; Tabloid, 11 x 17 in
  #vbPRPSLedger       =	4 	; Ledger, 17 x 11 in
  #vbPRPSLegal        =	5 	; Legal, 8 1/2 x 14 in
  #vbPRPSStatement    =	6 	; Statement, 5 1/2 x 8 1/2 in
  #vbPRPSExecutive    =	7 	; Executive, 7 1/2 x 10 1/2 in
  #vbPRPSA3           =	8 	; A3, 297 x 420 mm
  #vbPRPSA4           =	9 	; A4, 210 x 297 mm
  #vbPRPSA4Small      = 10 	; A4 Small, 210 x 297 mm
  #vbPRPSA5           =	11 	; A5, 148 x 210 mm
  #vbPRPSB4           =	12 	; B4, 250 x 354 mm
  #vbPRPSB5           =	13 	; B5, 182 x 257 mm
  #vbPRPSFolio        = 14  ; Folio, 8 1/2 x 13 in
  #vbPRPSQuarto       =	15 	; Quarto, 215 x 275 mm
  #vbPRPS1            = 16 	; 10 x 14 in
  #vbPRPS11x17        = 17 	; 11 x 17 in
  #vbPRPSNote         =	18 	; Note, 8 1/2 x 11 in
  #vbPRPSEnv9         =	19 	; Envelope #9, 3 7/8 x 8 7/8 in
  #vbPRPSEnv10        = 20 	; Envelope #10, 4 1/8 x 9 1/2 in
  #vbPRPSEnv11        = 21 	; Envelope #11, 4 1/2 x 10 3/8 in
  #vbPRPSEnv12        = 22 	; Envelope #12, 4 1/2 x 11 in
  #vbPRPSEnv14        = 23 	; Envelope #14, 5 x 11 1/2 in
  #vbPRPSCSheet       =	24 	; C size sheet
  #vbPRPSDSheet       =	25 	; D size sheet
  #vbPRPSESheet       =	26 	; E size sheet
  #vbPRPSEnvDL        = 27 	; Envelope DL, 110 x 220 mm
  #vbPRPSEnvC3        = 29 	; Envelope C3, 324 x 458 mm
  #vbPRPSEnvC4        = 30 	; Envelope C4, 229 x 324 mm
  #vbPRPSEnvC5        = 28 	; Envelope C5, 162 x 229 mm
  #vbPRPSEnvC6        = 31 	; Envelope C6, 114 x 162 mm
  #vbPRPSEnvC65       =	32 	; Envelope C65, 114 x 229 mm
  #vbPRPSEnvB4        = 33 	; Envelope B4, 250 x 353 mm
  #vbPRPSEnvB5        = 34 	; Envelope B5, 176 x 250 mm
  #vbPRPSEnvB6        = 35 	; Envelope B6, 176 x 125 mm
  #vbPRPSEnvItaly     =	36 	; Envelope, 110 x 230 mm
  #vbPRPSEnvMonarch   =	37 	; Envelope Monarch, 3 7/8 x 7 1/2 in
  #vbPRPSEnvPersonal  = 38 	; Envelope, 3 5/8 x 6 1/2 in
  #vbPRPSFanfoldUS    = 39 	; U.S. Standard Fanfold, 14 7/8 x 11 in
  #vbPRPSFanfoldStdGerman =	40 	; German Standard Fanfold, 8 1/2 x 12 in
  #vbPRPSFanfoldLglGerman =	41 	; German Legal Fanfold, 8 1/2 x 13 in
  #vbPRPSUser         = 256 	  ; User-defined  
  
  ; StdPicture Object Constants
  #vbPicTypeNone      =	0 	; None (empty)
  #vbPicTypeBitmap    =	1 	; Bitmap type of StdPicture object
  #vbPicTypeMetafile  = 2 	; Metafile type of StdPicture object
  #vbPicTypeIcon      = 3 	; Icon type of StdPicture object
  #vbPicTypeEMetaFile = 4 	; Enhanced metafile type of StdPicture object
  
  ; Menu Accelerator Constants
  #vbMenuAccelCtrlA =	1 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlB =	2 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlC =	3 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlD =	4 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlE =	5 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlF =	6 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlG =	7 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlH =	8 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlI =	9 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlJ =	10 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlK =	11 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlL =	12 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlM =	13 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlN =	14 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlO =	15 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlP =	16 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlQ =	17 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlR =	18 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlS =	19 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlT =	20 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlU =	21 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlV =	22 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlW =	23 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlX =	24 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlY =	25 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlZ =	26 	; User-defined shortcut keystrokes
  #vbMenuAccelF1    = 27 	; User-defined shortcut keystrokes
  #vbMenuAccelF2    = 28 	; User-defined shortcut keystrokes
  #vbMenuAccelF3    = 29 	; User-defined shortcut keystrokes
  #vbMenuAccelF4    = 30 	; User-defined shortcut keystrokes
  #vbMenuAccelF5    = 31 	; User-defined shortcut keystrokes
  #vbMenuAccelF6    = 32 	; User-defined shortcut keystrokes
  #vbMenuAccelF7    = 33 	; User-defined shortcut keystrokes
  #vbMenuAccelF8    = 34 	; User-defined shortcut keystrokes
  #vbMenuAccelF9    = 35 	; User-defined shortcut keystrokes
  #vbMenuAccelF11   =	36 	; User-defined shortcut keystrokes
  #vbMenuAccelF12   =	37 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlF1 =	38 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlF2 =	39 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlF3 =	40 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlF4 =	41 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlF5 =	42 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlF6 =	43 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlF7 =	44 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlF8 =	45 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlF9 =	46 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlF11 =	47 	; User-defined shortcut keystrokes
  #vbMenuAccelCtrlF12 =	48 	; User-defined shortcut keystrokes
  #vbMenuAccelShiftF1 =	49 	; User-defined shortcut keystrokes
  #vbMenuAccelShiftF2 =	50 	; User-defined shortcut keystrokes
  #vbMenuAccelShiftF3 =	51 	; User-defined shortcut keystrokes
  #vbMenuAccelShiftF4 =	52 	; User-defined shortcut keystrokes
  #vbMenuAccelShiftF5 =	53 	; User-defined shortcut keystrokes
  #vbMenuAccelShiftF6 =	54 	; User-defined shortcut keystrokes
  #vbMenuAccelShiftF7 =	55 	; User-defined shortcut keystrokes
  #vbMenuAccelShiftF8 =	56 	; User-defined shortcut keystrokes
  #vbMenuAccelShiftF9 =	57 	; User-defined shortcut keystrokes
  #vbMenuAccelShiftF11 = 	58 	; User-defined shortcut keystrokes
  #vbMenuAccelShiftF12 =	59 	; User-defined shortcut keystrokes
  #vbMenuAccelShiftCtrlF1 =	60 	; User-defined shortcut keystrokes
  #vbMenuAccelShiftCtrlF2 =	61 	; User-defined shortcut keystrokes
  #vbMenuAccelShiftCtrlF3 =	62 	; User-defined shortcut keystrokes
  #vbMenuAccelShiftCtrlF4 =	63 	; User-defined shortcut keystrokes
  #vbMenuAccelShiftCtrlF5 =	64 	; User-defined shortcut keystrokes
  #vbMenuAccelShiftCtrlF6 =	65 	; User-defined shortcut keystrokes
  #vbMenuAccelShiftCtrlF7 =	66 	; User-defined shortcut keystrokes
  #vbMenuAccelShiftCtrlF8 =	67 	; User-defined shortcut keystrokes
  #vbMenuAccelShiftCtrlF9 =	68 	; User-defined shortcut keystrokes
  #vbMenuAccelShiftCtrlF11 = 69 ; User-defined shortcut keystrokes
  #vbMenuAccelShiftCtrlF12 = 70 ; User-defined shortcut keystrokes
  #vbMenuAccelCtrlIns =	71 	    ; User-defined shortcut keystrokes
  #vbMenuAccelShiftIns =	72 	  ; User-defined shortcut keystrokes
  #vbMenuAccelDel =	73 	        ; User-defined shortcut keystrokes
  #vbMenuAccelShiftDel = 74 	  ; User-defined shortcut keystrokes
  #vbMenuAccelAltBksp =	75 	    ; User-defined shortcut keystrokes  
  
  ;- MsgBox arguments
  #vbOKOnly =	0 	          ; OK button only (Default)
  #vbOKCancel =	1 	        ; OK And Cancel buttons
  #vbAbortRetryIgnore =	2 	; Abort, Retry, And Ignore buttons
  #vbYesNoCancel =	3 	    ; Yes, No, And Cancel buttons
  #vbYesNo =	4 	          ; Yes And No buttons
  #vbRetryCancel =	5 	    ; Retry And Cancel buttons
  #vbCritical =	16 	        ; Critical message
  #vbQuestion =	32 	        ; Warning query
  #vbExclamation =	48 	    ; Warning message
  #vbInformation =	64 	    ; Information message
  #vbDefaultButton1 =	0 	  ; First button is Default (Default)
  #vbDefaultButton2 =	256 	; Second button is Default
  #vbDefaultButton3 =	512 	; Third button is Default
  #vbDefaultButton4 	=768 	; Fourth button is Default
  #vbApplicationModal =	0 	; Application modal message Box (Default)
  #vbSystemModal =	4096 	  ; System modal message box
  #vbMsgBoxHelpButton =	16384 	    ; Adds Help button To the message box
  #vbMsgBoxSetForeground =	65536 	; Specifies the message box window As the foreground window
  #vbMsgBoxRight =	524288 	        ; Text is right aligned
  #vbMsgBoxRtlReading =	1048576 	  ; Specifies text should appear As right-To-left reading on Hebrew And Arabic systems
  
  ;- Date constants
  #vbUseSystem =	0 	; Use NLS API setting.
  #vbSunday =	1 	    ; Sunday (Default)
  #vbMonday =	2 	    ; Monday
  #vbTuesday =	3 	  ; Tuesday
  #vbWednesday =	4 	; Wednesday
  #vbThursday =	5 	  ; Thursday
  #vbFriday =	6 	    ; Friday
  #vbSaturday =	7 	  ; Saturday
  
  #vbUseSystem =	0 	    ; Use NLS API setting.
  #VbUseSystemDayOfWeek =	0 	; Use the day of the week specified in your system settings For the first day of the week.
  #VbFirstJan1 =	1 	    ; Start With week in which January 1 occurs (Default).
  #vbFirstFourDays =	2 	; Start With the first week that has at least four days in the new year.
  #vbFirstFullWeek =	3 	; Start With the first full week of the year.
    
  ; https://learn.microsoft.com/en-us/office/vba/language/reference/user-Interface-help/comparison-constants
  ; MsgBox Return values
  #vbOK = 1 	    ; OK button pressed
  #vbCancel =	2 	; Cancel button pressed
  #vbAbort =	3 	; Abort button pressed
  #vbRetry =	4 	; Retry button pressed
  #vbIgnore =	5 	; Ignore button pressed
  #vbYes =	6 	  ; Yes button pressed
  #vbNo =	7 	    ; No button pressed
  
  ; StrConv constants
  #vbUpperCase =	1 	; Converts the string To uppercase characters.
  #vbLowerCase =	2 	; Converts the string To lowercase characters.
  #vbProperCase =	3 	; Converts the first letter of every word in string To uppercase.
  #vbWide =	4 	      ; Converts narrow (single-byte) characters in string To wide (double-byte) characters. Applies To East Asia locales.
  #vbNarrow =	8 	    ; Converts wide (double-byte) characters in string To narrow (single-byte) characters. Applies To East Asia locales.
  #vbKatakana =	16 	  ; Converts Hiragana characters in string To Katakana characters. Applies To Japan only.
  #vbHiragana =	32 	  ; Converts Katakana characters in string To Hiragana characters. Applies To Japan only.
  #vbUnicode =	64 	  ; Converts the string To Unicode by using the Default code page of the system (Not available on the Macintosh).
  #vbFromUnicode 	=128 	; Converts the string from Unicode To the Default code page of the system (Not available on the Macintosh).
  
  #vbCr = #CR
  #vbLf = #LF
  #vbNewLine = #CRLF$
  #vbNullChar = 0
  #vbNullString = #Null$
  #vbTab = #TAB
  #vbBack = 8           ; Backspace
  #vbFormFeed = 12      ; Word VBA Manual - manual page break ?
  #vbVerticalTab = 11   ; Word VBA Manual - manual line Break (Shift + Enter)
  #vbObjectError =	-2147221504 ; User-defined error numbers should be greater than this value. For example: Err.Raise Number = vbObjectError + 1000
  
  Macro CBool(Value)
    Bool(Value)  
  EndMacro
  
EndDeclareModule


Module VB
  
  ; MsgBox(Promt, [Buttons As VbMsgBoxStyle = vbOKonly], [Title], [HelpFile], [Context]) As VBMsgBoxResult
  Procedure MsgBox(Promt$, Buttons=#vbOKOnly, Title$="", HelpFile$="", Context$="")
;   #vbOKOnly =	0 	          ; OK button only (Default)
;   #vbOKCancel =	1 	        ; OK And Cancel buttons
;   #vbAbortRetryIgnore =	2 	; Abort, Retry, And Ignore buttons
;   #vbYesNoCancel =	3 	    ; Yes, No, And Cancel buttons
;   #vbYesNo =	4 	          ; Yes And No buttons
;   #vbRetryCancel =	5 	    ; Retry And Cancel buttons
;   #vbCritical =	16 	        ; Critical message
;   #vbQuestion =	32 	        ; Warning query
;   #vbExclamation =	48 	    ; Warning message
;   #vbInformation =	64 	    ; Information message
;   #vbDefaultButton1 =	0 	  ; First button is Default (Default)
;   #vbDefaultButton2 =	256 	; Second button is Default
;   #vbDefaultButton3 =	512 	; Third button is Default
;   #vbDefaultButton4 	=768 	; Fourth button is Default
;   #vbApplicationModal =	0 	; Application modal message Box (Default)
;   #vbSystemModal =	4096 	  ; System modal message box
;   #vbMsgBoxHelpButton =	16384 	    ; Adds Help button To the message box
;   #vbMsgBoxSetForeground =	65536 	; Specifies the message box window As the foreground window
;   #vbMsgBoxRight =	524288 	        ; Text is right aligned
;   #vbMsgBoxRtlReading =	1048576 	  ; Specifies text should appear As right-To-left reading on Hebrew And Arabic systems
    Protected Flags 
   
    MessageRequester(Title$, Promt$, Flags)
    ; maybe use WinApi MessageBox_(hwnd, lpText, lpCaption, uType)
  EndProcedure
  
  Procedure.s StrCon(String$, Mode)
    Select mode
        Case #vbUpperCase
        Case #vbLowerCase
        Case #vbProperCase
        Case #vbWide
        Case #vbNarrow
        Case #vbKatakana
        Case #vbHiragana
        Case #vbUnicode
        Case #vbFromUnicode
    EndSelect
    
  EndProcedure
  
EndModule


; ----------------------------------------------------------------------
; VB Function List
; ----------------------------------------------------------------------
; ABS	Returns the absolute value of a number (Variant).
; And	The logical 'AND' operator (Boolean).
; APPACTIVATE	Activates an application Or window currently running on Windows.
; Array	Returns an Array containing the given values (Variant).
; ASC	Returns the ASCII / ANSI number For the first character in a text string (Integer).
; ASCW	Returns the Unicode number For the first character in a text string (Integer)
; ATN	Returns the arc-tangent of a number in radians (Double).
; BEEP	Produces a single beep noise.
; CALL	Transfers control To a subroutine Or function.
; CALLBYNAME	Returns, sets Or executes a method Or property of an object (Variant).
; CBOOL	Returns the expression converted To a boolean Data type (Boolean).
; CBYTE	Returns the expression converted To a byte Data type (Byte).
; CCUR	Returns the expression converted To a currency Data type (Currency).
; CDATE	Returns the expression converted To a date Data type (Date).
; CDBL	Returns the expression converted To a double Data type (Double).
; CDEC	Returns the expression converted To a decimal variant-subtype (Variant).
; CHDIR	Defines the current Default directory.
; CHDRIVE	Defines the current Default drive.
; CHOOSE	Returns the value from a List of values based on an index number (Variant).
; CHR	Returns the character With the corresponding ASCII / ANSI number (Variant / String).
; CHRW	Returns the character With the corresponding Unicode number (Variant / String)
; CINT	Returns the expression converted To an integer Data type (Integer).
; CLNG	Returns the expression converted To a long Data type (Long).
; CLNGLNG	Returns the expression converted To a longlong (64 bit platform) Data type.
; CLNGPTR	Returns the expression converted To a longptr Data type.
; CLOSE	Closes a text file.
; COMMAND	Returns the argument portion of the command line used To launch the application (Variant).
; COS	Returns the cosine of an angle in radians (Double).
; CREATEOBJECT	Returns a reference after creating a new ActiveX Or OLE object (Variant).
; CSNG	Returns the expression converted To a single Data type (Single).
; CSTR	Returns the expression converted To a string Data type (String).
; CURDIR	Returns the current path of a given drive (Variant / String).
; CVAR	Returns the expression converted To a variant Data type (Variant).
; CVDATE	Returns the expression converted To a variant date subtype (Variant).
; CVERR	Returns a specific type of error (Variant).
; DATE - Function	Returns the current system Date (Variant / Date).
; DATE - Statement	Defines the current system date.
; DATEADD	Returns the date With a specified time interval added (Date).
; DATEDIFF	Returns the number of a given time interval between two specified dates (Long).
; DATEPART	Returns the specified part of a given Date (Variant / Integer).
; DATESERIAL	Returns the date given a year, month And Day (Date).
; DATEVALUE	Returns the date given a string representation of a Date (Date).
; DAY	Returns the day from a given Date (Integer).
; DDB	Returns the depreciation of an asset in a single period (double Or higher declining balance method) (Double).
; DELETESETTING	Removes (Or deletes) a key Or section from the registry.
; DIR	Returns the name of a file Or directory matching a pattern Or attribute (Variant / String).
; DOEVENTS	Pauses execution To let the system process other events.
; ENVIRON	Returns information about the current operating system environment (String).
; EOF	Returns the value indicating If the End of a file has been reached (Boolean).
; EQV	The logical equivalence operator.
; ERASE	Reinitialises the elements of an Array.
; ERROR - Function	Returns the error message corresponding To a given error number (String).
; ERROR - Statement	(Err.Raise) Generates an error.
; EXP	Returns the base of natural logarithm raised To a power (Double).
; FILEATTR	Returns the file mode of the specified open file (Long).
; FILECOPY	Copies a file from one directory To another.
; FILEDATETIME	Returns the date And time when a file was created Or last modified (Date).
; FILELEN	Returns the length of a file in bytes (Long).
; FILTER	Returns an Array containing a subset of values that contain a substring (Variant).
; FIX	Returns the integer portion of a number (Data type).
; FORMAT	Returns the text string of a number Or date in a particular format (Variant / String).
; FORMATCURRENCY	Returns the expression formatted As a currency value (String).
; FORMATDATETIME	Returns the expression formatted As a date Or time (String).
; FORMATNUMBER	Returns the expression formatted As a number (String).
; FORMATPERCENT	Returns the expression formatted As a percentage (String).
; FREEFILE	Returns the Next valid free file number (Integer).
; FV	Returns the future value of a series of equal cash flows at regular intervals (Double).
; GET	Reads Data from a text file into a record.
; GETALLSETTINGS	Returns the List of key settings And their values from the registry (Variant).
; GETATTR	Returns the attributes of a given file Or directory (Integer).
; GETOBJECT	Returns the reference To an object provided by an ActiveX component.
; GETSETTING	Reads from the registry And returns the value Or key from the registry (String).
; Goto	Transfers control To the subroutine indicated by the line label.
; HEX	Returns the number converted To hexadecimal (Variant / String).
; HOUR	Returns the hour from a given time (Integer).
; IIF	Returns one of two parts, depending on the evaluation of an expression.
; IMESTATUS	Returns the current Input Method Editor mode of Microsoft Windows (Integer).
; IMP	The logical implication from two values (Variant).
; IMPLEMENTS	Specifies an Interface Or class that can be implemented in a class Module.
; INPUT - Function	Returns the open stream of an Input Or Binary file (String).
; INPUT - Statement	Reads Data from an open sequential field And assigns the Data To a variable (Long).
; INPUTBOX	Displays a dialog box allowing the user To enter some information (String).
; INSTR	Returns the position of a substring within a larger string (Long).
; INSTRREV	Returns the position of a substring within a larger string, starting at the End (Long).
; INT	Returns the integer portion of a number (Data type).
; IPMT	Returns the interest paid in a given period in a series of equal cash flows at regular intervals (Double).
; IRR	Returns the interest rate For a series of unequal cash flows at regular intervals (implicit reinvestment rate) (Double).
; IS	Compares two object reference variables.
; ISARRAY	Returns the value True Or False depending If the expression is an Array (Boolean).
; ISDATE	Returns the value True Or False depending If the expression is a Date (Boolean).
; ISEMPTY	Returns the value True Or False depending If the Variant variable has been initialised (Boolean).
; ISERROR	Returns the value True Or False depending If the expression is an error (Boolean).
; ISMISSING	Returns the value True Or False depending If the optional argument has been passed To a Procedure (Boolean).
; ISNULL	Returns the value True Or False depending If the expression contains no Data (Boolean).
; ISNUMERIC	Returns the value True Or False depending If the expression is a number (Boolean).
; ISOBJECT	Returns the value True Or False depending If the identifier represents an object (Boolean).
; JOIN	Returns a text string containing all the elements in an Array (String).
; KILL	Deletes an existing file.
; LBOUND	Returns the lower limit in a given dimension of an Array (Long).
; LCASE	Returns the text string With all characters converted To lowercase (Variant / String).
; LEFT	Returns a substring from the left of a string (Variant / String).
; LEN	Returns the number of characters in a string (Long).
; LET	Computes a value And assigns it To a new variable.
; LIKE	The pattern matching operator.
; LINE INPUT	Reads a single line from an Open sequential file And assigns it To a string.
; LOAD	Loads an object but doesn't display it.
; LOADPICTURE	Loads a picture from a file into a Picture Or Image control (IPictureDisp).
; LOC	Returns the current Read/write position within an open file (Long).
; LOCK	Locks access To parts of a file For other processes.
; LOF	Returns the length Or size of an open file, in bytes (Long).
; LOG	Returns the natural logarithm of a number (Double).
; LSET	Left aligns a string within a string variable.
; LTRIM	Returns the text string without leading spaces (Variant / String).
; MACID	Converts a four character constant To a value that can be used by Dir, Kill, Shell And AppActivate.
; MID - Function	Returns a substring from the middle, left Or right of a string (Variant / String).
; MID - Statement	Replaces a specified number of characters With characters from another string.
; MINUTE	Returns the minutes from a given time (Integer).
; MIRR	Returns the interest rate For a series of unequal cash flows at regular intervals (explicit reinvestment rate) (Double).
; MKDIR	Creates a new directory.
; MOD	Returns the remainder after division operator (Integer).
; MONTH	Returns the month from a given Date (Integer).
; MONTHNAME	Returns the month As a string (String).
; MSGBOX	Displays a dialog box displaying a message To the user (Integer).
; NAME	Renames an existing file Or directory.
; Not	The logical 'NOT' operator (Boolean).
; NOW	Returns the current system date And time (Date).
; NPER	Returns the number of periods For an investment (Double).
; NPV	Returns the present value of a series of unequal cash flows at regular intervals (Double).
; OBJPTR	Returns a LongPtr on a 64 bit version And a Long on a 32 bit version.
; OCT	Returns the number converted To octal (Variant / String).
; OPEN	Opens a text file Or CSV file.
; Or	The logical 'OR' operator (Boolean).
; PARTITION	Returns a string indicating which particular range it falls into (String).
; PMT	Returns the amount of principal And interest paid in a given period in a series of equal cash flows at regular intervals (Double).
; PPMT	Returns the amount of principal paid in a given period in a series of equal cash flows at regular intervals (Double).
; PRINT	Writes display-formatted Data To a sequential file.
; PUT	Writes Data from a record into a text file.
; PV	Returns the present value of a series of equal cash flows at regular intervals (Double).
; QBCOLOR	Returns the RGB colour corresponding To the specified colour number (Long).
; RAISEEVENT	Fires an event declared at Module level within a class, form Or document.
; RANDOMIZE	Initialises the random number generator.
; RATE	Returns the interest rate For a series of equal cash flows at regular intervals (Double).
; ReDim	Initialises And resizes a dynamic Array.
; REM	Specifies a single line of comments.
; REPLACE	Returns the text string With a number of characters replaced (String).
; RESET	Closes all files open With the Open statement.
; RGB	Returns the number representing an RGB colour value (Long).
; RIGHT	Returns a substring from the right of a string (Variant / String).
; RMDIR	Removes an existing directory.
; RND	Returns a random number between 0 And 1 (Single).
; ROUND	Returns a number rounded To a given number of decimal places (Double).
; RSET	Right aligns a string within a string variable.
; RTRIM	Returns the text string without trailing spaces (Variant / String).
; SAVEPICTURE	Saves a graphic image from an objects Picture Or Image property To a file.
; SAVESETTING	Writes To the registry And saves a section Or key in the registry.
; SECOND	Returns the seconds from a given time (Integer).
; SEEK - Function	Returns the current Read/write position within a file opened using the Open statement (Long).
; SEEK - Statement	Repositions where the Next operation in a file will occur.
; SENDKEYS	Sends keystrokes To an application.
; SET	Assigns an object reference To an object variable.
; SETATTR	Defines the attributes of a file Or directory.
; SGN	Returns the sign of a number (Integer).
; SHELL	Returns the program's task id from running an executable programs (Double).
; SIN	Returns the sine of an angle in radians (Double).
; SLN	Returns the straight-line depreciation of an asset over a single period of time (Double).
; SPACE	Returns the specified number of spaces (Variant / String).
; SPC	Inserts a specified number (n) of spaces when writing Or displaying text.
; SPLIT	Returns an Array containing a specified number of substrings (Variant).
; SQR	Returns the square root of a number (Double).
; STOP	Suspends execution.
; STR	Returns the text string of a number (Variant / String).
; STRCOMP	Returns the result of a string comparison (Integer).
; STRCONV	Returns the text string converted To a specific Case Or type (Variant / String).
; STRING	Returns a repeating character of a given length (Variant / String).
; STRPTR	Returns a LongPtr on a 64 bit version And a Long on a 32 bit version.
; STRREVERSE	Returns the text string With the characters reversed (Variant / String).
; SWITCH	Returns a value based on expressions (Variant).
; SYD	Returns the sum-of-years' digits depreciation of an asset (Double).
; TAB	Used With the Print # statement Or the Print method To position output.
; TAN	Returns the tangent of an angle (Double).
; TIME - Function	Returns the current system time (Date).
; TIME - Statement	Defines the current system time.
; TIMER	Returns the number of seconds elapsed since midnight (Single).
; TIMESERIAL	Returns the time For a specific hour, minute And Second (Date).
; TIMEVALUE	Returns the time given a string representation of a time (Date).
; TRIM	Returns the text string without leading And trailing spaces (Variant / String).
; TYPENAME	Returns the Data type of the variable As a string (String).
; TYPEOF	Returns the object Data type.
; UBOUND	Returns the upper limit in a given dimension of an Array (Long).
; UCASE	Returns the text string With all the characters converted To uppercase (Variant / String).
; UNLOAD	Removes an object from memory.
; UNLOCK	Controls access To a file.
; VAL	Returns the first number contained in a string (Double).
; VARPTR	Returns a LongPtr on a 64 bit version And a Long on a 32 bit version.
; VARTYPE	Returns the number indicating the Data type of a variable (Integer).
; WEEKDAY	Returns the number representing the day of the week For a given Date (Integer).
; WEEKDAYNAME	Returns the day of the week As a string (String).
; WIDTH	Assigns an output line width (characters) For the open file.
; WRITE	Writes Data To a sequential file.
; XOr	The logical exclusion operator.
; YEAR	Returns the year from a Date (Integer).

; Visual Basic Core Language Errors
; #Return_without_Gosub = 3
; #Invalid_Procedure_call = 5
; #Overflow = 6
; #Out_of_memory = 7
; #Subscript_out_of_range = 9
; #This_Array_is_fixed_Or_temporarily_locked = 10
; #Division_by_zero = 11
; #Type_mismatch = 13
; #Out_of_string_space = 14
; #Expression_too_complex = 16
; ; #CAN't_perform_requested_operation = 17
; #User_interrupt_occurred = 18
; #Resume_without_error = 20
; #Out_of_stack_space = 28
; ; #SUB,_Function,_Or_Property_Not_defined = 35
; #Too_many_DLL_application_clients = 47
; #Error_in_loading_DLL = 48
; #Bad_DLL_calling_convention = 49
; #Internal_error = 51
; #Bad_file_name_Or_number = 52
; #File_Not_found = 53
; #Bad_file_mode = 54
; #File_already_open = 55
; ; #Device_I/O_error = 57
; #File_already_exists = 58
; #Bad_record_length = 59
; #Disk_full = 61
; #Input_past_End_of_file = 62
; #Bad_record_number = 63
; #Too_many_files = 67
; #Device_unavailable = 68
; #Permission_denied = 70
; #Disk_Not_ready = 71
; ; #CAN't_rename_with_different_drive = 74
; ; #Path/File_access_error = 75
; #Path_Not_found = 76
; #Object_variable_Or_With_block_variable_Not_set = 91
; #For_loop_Not_initialized = 92
; #Invalid_pattern_string = 93
; #Invalid_use_of_Null = 94
; ; #CAN't_call_Friend_procedure_on_an_object_that_is_not_an_instance_of_the_defining_class = 97
; ; #A_property_Or_method_call_cannot_include_a_reference_To_a_private_object,_either_As_an_argument_Or_As_a_Return_value = 98
; #System_DLL_could_Not_be_loaded = 298
; ; #CAN't_use_character_device_names_in_specified_file_names = 320
; #Invalid_file_format = 321
; #Cant_create_necessary_temporary_file = 322
; #Invalid_format_in_resource_file = 325
; #Data_value_named_Not_found = 327
; ; #Illegal_parameter;_can't_write_arrays = 328
; #Could_Not_access_system_registry = 335
; #Component_Not_correctly_registered = 336
; #Component_Not_found = 337
; #Component_did_Not_run_correctly = 338
; #Object_already_loaded = 360
; ; #CAN't_load_or_unload_this_object = 361
; #Control_specified_Not_found = 363
; #Object_was_unloaded = 364
; #Unable_To_unload_within_this_context = 365
; ; #The_specified_file_is_out_of_date._This_program_requires_a_later_version = 368
; ; #The_specified_object_can't_be_used_as_an_owner_form_for_Show = 371
; #Invalid_property_value = 380
; ; #Invalid_property-Array_index = 381
; #Property_Set_can't_be_executed_at_run_time = 382
; #Property_Set_can't_be_used_with_a_read-only_property = 383
; #Need_property-Array_index = 385
; #Property_Set_Not_permitted = 387
; #Property_Get_can't_be_executed_at_run_time = 393
; #Property_Get_can't_be_executed_on_write-only_property = 394
; #Form_already_displayed;_can't_show_modally = 400
; #Code_must_close_topmost_modal_form_first = 402
; #Permission_To_use_object_denied = 419
; #Property_Not_found = 422
; #Property_Or_method_Not_found = 423
; #Object_required = 424
; #Invalid_object_use = 425
; #Component_can't_create_object_or_return_reference_to_this_object = 429
; #Class_doesn't_support_Automation = 430
; #File_name_Or_class_name_Not_found_during_Automation_operation = 432
; #Object_doesn't_support_this_property_or_method = 438
; #Automation_error = 440
; #Connection_To_type_library_Or_object_library_For_remote_process_has_been_lost = 442
; #Automation_object_doesn't_have_a_default_value = 443
; #Object_doesn't_support_this_action = 445
; #Object_doesn't_support_named_arguments = 446
; #Object_doesn't_support_current_locale_setting = 447
; #Named_argument_Not_found = 448
; #Argument_Not_optional_Or_invalid_property_assignment = 449
; #Wrong_number_of_arguments_Or_invalid_property_assignment = 450
; #Object_Not_a_collection = 451
; #Invalid_ordinal = 452
; #Specified_Not_found = 453
; #Code_resource_Not_found = 454
; #Code_resource_lock_error = 455
; #This_key_is_already_associated_With_an_element_of_this_collection = 457
; #Variable_uses_a_type_Not_supported_in_Visual_Basic = 458
; #This_component_doesn't_support_the_set_of_events = 459
; #Invalid_Clipboard_format = 460
; #Method_Or_Data_member_Not_found = 461
; #The_remote_server_machine_does_Not_exist_Or_is_unavailable = 462
; #Class_Not_registered_on_local_machine = 463
; #CAN't_create_AutoRedraw_image = 480
; #Invalid_picture = 481
; #Printer_error = 482
; #Printer_driver_does_Not_support_specified_property = 483
; #Problem_getting_printer_information_from_the_system._Make_sure_the_printer_is_set_up_correctly = 484
; #Invalid_picture_type = 485
; #CAN't_print_form_image_to_this_type_of_printer = 486
; #CAN't_empty_Clipboard = 520
; #CAN't_open_Clipboard = 521
; #CAN't_save_file_to_TEMP_directory = 735
; #Search_text_Not_found = 744
; #Replacements_too_long = 746
; #Out_of_memory = 31001
; #No_object = 31004
; #Class_is_Not_set = 31018
; #Unable_To_activate_object = 31027
; #Unable_To_create_embedded_object = 31032
; #Error_saving_To_file = 31036
; #Error_loading_from_file = 31037


; Code 	Message
; 3 	Return without Gosub
; 5 	Invalid Procedure call
; 6 	Overflow
; 7 	Out of memory
; 9 	Subscript out of range
; 10 	This Array is fixed Or temporarily locked
; 11 	Division by zero
; 13 	Type mismatch
; 14 	Out of string space
; 16 	Expression too complex
; 17 	Can't perform requested operation
; 18 	User interrupt occurred
; 20 	Resume without error
; 28 	Out of stack space
; 35 	Sub, Function, Or Property Not defined
; 47 	Too many DLL application clients
; 48 	Error in loading DLL
; 49 	Bad DLL calling convention
; 51 	Internal error
; 52 	Bad file name Or number
; 53 	File Not found
; 54 	Bad file mode
; 55 	File already open
; 57 	Device I/O error
; 58 	File already exists
; 59 	Bad record length
; 61 	Disk full
; 62 	Input past End of file
; 63 	Bad record number
; 67 	Too many files
; 68 	Device unavailable
; 70 	Permission denied
; 71 	Disk Not ready
; 74 	Can't rename with different drive
; 75 	Path/File access error
; 76 	Path Not found
; 91 	Object variable Or With block variable Not set
; 92 	For loop Not initialized
; 93 	Invalid pattern string
; 94 	Invalid use of Null
; 97 	Can't call Friend procedure on an object that is not an instance of the defining class
; 98 	A property Or method call cannot include a reference To a private object, either As an argument Or As a Return value
; 298 	System DLL could Not be loaded
; 320 	Can't use character device names in specified file names
; 321 	Invalid file format
; 322 	Cant create necessary temporary file
; 325 	Invalid format in resource file
; 327 	Data value named Not found
; 328 	Illegal parameter; can't write arrays
; 335 	Could Not access system registry
; 336 	Component Not correctly registered
; 337 	Component Not found
; 338 	Component did Not run correctly
; 360 	Object already loaded
; 361 	Can't load or unload this object
; 363 	Control specified Not found
; 364 	Object was unloaded
; 365 	Unable To unload within this context
; 368 	The specified file is out of date. This program requires a later version
; 371 	The specified object can't be used as an owner form for Show
; 380 	Invalid property value
; 381 	Invalid property-Array index
; 382 	Property Set can't be executed at run time
; 383 	Property Set can't be used with a read-only property
; 385 	Need property-Array index
; 387 	Property Set Not permitted
; 393 	Property Get can't be executed at run time
; 394 	Property Get can't be executed on write-only property
; 400 	Form already displayed; can't show modally
; 402 	Code must close topmost modal form first
; 419 	Permission To use object denied
; 422 	Property Not found
; 423 	Property Or method Not found
; 424 	Object required
; 425 	Invalid object use
; 429 	Component can't create object or return reference to this object
; 430 	Class doesn't support Automation
; 432 	File name Or class name Not found during Automation operation
; 438 	Object doesn't support this property or method
; 440 	Automation error
; 442 	Connection To type library Or object library For remote process has been lost
; 443 	Automation object doesn't have a default value
; 445 	Object doesn't support this action
; 446 	Object doesn't support named arguments
; 447 	Object doesn't support current locale setting
; 448 	Named argument Not found
; 449 	Argument Not optional Or invalid property assignment
; 450 	Wrong number of arguments Or invalid property assignment
; 451 	Object Not a collection
; 452 	Invalid ordinal
; 453 	Specified Not found
; 454 	Code resource Not found
; 455 	Code resource lock error
; 457 	This key is already associated With an element of this collection
; 458 	Variable uses a type Not supported in Visual Basic
; 459 	This component doesn't support the set of events
; 460 	Invalid Clipboard format
; 461 	Method Or Data member Not found
; 462 	The remote server machine does Not exist Or is unavailable
; 463 	Class Not registered on local machine
; 480 	Can't create AutoRedraw image
; 481 	Invalid picture
; 482 	Printer error
; 483 	Printer driver does Not support specified property
; 484 	Problem getting printer information from the system. Make sure the printer is set up correctly
; 485 	Invalid picture type
; 486 	Can't print form image to this type of printer
; 520 	Can't empty Clipboard
; 521 	Can't open Clipboard
; 735 	Can't save file to TEMP directory
; 744 	Search text Not found
; 746 	Replacements too long
; 31001 	Out of memory
; 31004 	No object
; 31018 	Class is Not set
; 31027 	Unable To activate object
; 31032 	Unable To create embedded object
; 31036 	Error saving To file
; 31037 	Error loading from file

;- ----------------------------------------------------------------------
;- Data Types
;- ----------------------------------------------------------------------

; Data type 	Storage size 	Range
; Boolean     2 bytes 	    True Or False
; Byte 	      1 byte 	      0 To 255
; Collection 	Unknown 	    Unknown
; Currency    8 bytes 	    -922,337,203,685,477.5808 To 922,337,203,685,477.5807
; Date 	      8 bytes 	    -657,434 (January 1, 100), To 2,958,465 (December 31, 9999)
; Decimal 	  14 bytes 	    +/-79,228,162,514,264,337,593,543,950,335 With no decimal point
;                           ; +/-7.9228162514264337593543950335 With 28 places To the right of the decimal
;                           ; Smallest non-zero number is+/-0.0000000000000000000000000001
; Dictionary  Unknown 	    Unknown
; Double      8 bytes 	    -1.79769313486231E308 To -4.94065645841247E-324 For negative values
                            ; 4.94065645841247E-324 To 1.79769313486232E308 For positive values
; Integer     2 bytes 	    -32,768 To 32,767
; Long        4 bytes 	    -2,147,483,648 To 2,147,483,647
; LongLong    8 bytes 	    -9,223,372,036,854,775,808 To 9,223,372,036,854,775,807
;                            Valid on 64-bit platforms only.
; LongPtr   (Long integer on 32-bit systems, LongLong integer on 64-bit systems) 	4 bytes on 32-bit systems
;           8 bytes on 64-bit systems 	-2,147,483,648 To 2,147,483,647 on 32-bit systems
;           -9,223,372,036,854,775,808 To 9,223,372,036,854,775,807 on 64-bit systems

; Object 	  4 bytes 	      Any Object reference
; Single  	4 bytes 	      -3.402823E38 To -1.401298E-45 For negative values
;                           1.401298E-45 To 3.402823E38 For positive values
; String (variable-length) 	10 bytes + string length 	0 To approximately 2 billion
; String (fixed-length) 	Length of string 	1 To approximately 65,400

; Variant (With numbers) 	16 bytes 	Any numeric value up To the range of a Double
; Variant (With characters) 	22 bytes + string length (24 bytes on 64-bit systems) 	Same range As For variable-length String
; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 961
; Folding = --
; Optimizer
; CPU = 5