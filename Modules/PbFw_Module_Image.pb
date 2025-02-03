; ===========================================================================
;  FILE : PbFw_Module_Image.Pb
;  NAME : Module IMG::
;  DESC : Implements Image functions
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2020/10/17
; VERSION  :  0.1 untested Developer Version
; COMPILER :  PureBasic 6.0
;
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

;- ----------------------------------------------------------------------
;- Include Files
;- ----------------------------------------------------------------------

XIncludeFile "PbFw_Module_PbFw.Pb"        ; PbFw::    FrameWork control Module
XIncludeFile "PbFw_Module_PB.pb"          ; PB::      PureBasic extention Module
XIncludeFile "PbFw_Module_Debug.Pb"       ; DBG::     Debugging and Exception handling
XIncludeFile "PbFw_Module_COLOR.Pb"       ; COLOR::   24/32 Bit Color Module
XIncludeFile "PbFw_Module_VectorColor.Pb" ; VecCol::  VectorColor Module
XIncludeFile "PbFw_Module_BUFFER.Pb"      ; Buffer::  Buffer handling Module

; XIncludeFile ""

DeclareModule IMG
  
  #PbFw_IMG_GreyScale_Standard = 0
  #PbFw_IMG_GreyScale_Average = 1
  #PbFw_IMG_GreyScale_WeightedLight = 2

  Structure TImageInfo
    PbImageNo.i             ; Purebasic ImageID #Image (Data is #Image)
    imgWidth.i              ; Image width in Pixel
    imgHeight.i             ; Image height in Pixel
    imgPixels.i             ; Total number of pixels
    imgBufferSize.i         ; Total size of Bytes needed to store the Image
    imgBufferPitch.i        ; No of Bytes for a line. There might be fillbytes after the Pixels 
    imgDepth.i              ; ImageDepth(ImageID,#Pb_Image_InternalDepth); 24 or 32
    imgPixelFormat.i        ; #Pb_PixelFormat_32Bits_RGB, #Pb_PixelFormat_24Bits_RGB ...
  EndStructure
          
  ; Structure for ImageInfo tp create ShadowCopies from PureBasic Images
  ; If we copy a PureBasic Image into an allocated Memory we loose all
  ; Informations because we can't use ImageHeight(), ImageWidth() ...
  ; with the ShadowCopy. To make programmers life easier we handle
  ; ower own InfoStructure.
  Structure TImageBuffer Extends TImageInfo
    hBuffer.BUFFER::hBuffer ; Buffer Handle. Structure form Module Buffer::
  EndStructure
  
  ; Sturcture for color Statistik of one channel
  Structure TChannel_Statistik
    used.l    ; number of differnt colors used
    min.l     ; min value of color
    max.l     ; max value of color
    avg.l     ; average value of color
    sd.f      ; standard derivation (Standardabweichung)
  EndStructure
  
  Declare.i FreeImageBuffer(*ImgBuf.TImageBuffer)

EndDeclareModule

Module IMG
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  #PbFwCfg_Module_CheckPointerException = #False
  
  ; start the Enumeration with the value for ModulSpecific Errors
  Enumeration ; DBG::#PbFw_DBG_Err_ModulSpecific
    #Err_Error1 
    #Err_Error2
  EndEnumeration
  
  Procedure _Exception(FName.s, ExceptionType)
    ; ======================================================================
    ; NAME: _Exception
    ; DESC: 
    ; VAR(FName): Function Name which caused the Exeption
    ; RET : -
    ; ======================================================================
    Protected *Text.String
    
    ProcedureReturn 0
    
    Select ExceptionType
      Case #Err_Error1
        
      Case #Err_Error2
        
    EndSelect
    
    ; Call the Exception Handler Function in the Module Exception
    DBG::Exception(#PB_Compiler_Module, FName, ExceptionType, *Text)
    ProcedureReturn ExceptionType
  EndProcedure
  
  Enumeration 0
    #PbFw_IMG_Rotate_Left
    #PbFw_IMG_Rotate_Right
    #PbFw_IMG_Flip_Horizontal
    #PbFw_IMG_Flip_Vertical
  EndEnumeration
  
  Procedure.i InitImageInfoStruct(PbImageNo, *TImageInfo.TImageInfo)
  ; ======================================================================
  ; NAME : InitImageInfoStruct
  ; DESC : Creates the the InitImageInfoStruct Structure for an Image
  ; VAR(PbImageNo) : The PureBasic #Image
  ; VAR(*TImageInfo)  : Pointer to the InitImageInfo Structure
  ; RET : #TRUE if sucseed; #FALSE if no Structure isn't created
  ; ======================================================================
    
    If IsImage(PbImageNo)
      If *TImageInfo
        If StartDrawing(ImageOutput(PbImageNo))
        
          With *TImageInfo
            \PbImageNo = PbImageNo
            \imgBufferPitch = DrawingBufferPitch()
            \imgWidth = ImageWidth(PbImageNo)
            \imgHeight = ImageHeight(PbImageNo)
            \imgPixels = \imgHeight * \imgWidth
            \imgBufferSize = \imgBufferPitch * \imgHeight 
            \imgDepth = ImageDepth(PbImageNo, #PB_Image_InternalDepth) 
            \imgPixelFormat = DrawingBufferPixelFormat()
            
            ; #PB_PixelFormat_8Bits   = 1           ; Bit 0
            ; #PB_PixelFormat_15Bits  = 2    
            ; #PB_PixelFormat_16Bits  = 4    
            ; #PB_PixelFormat_24Bits_RGB = 8  
            ; #PB_PixelFormat_24Bits_BGR = 16 
            ; #PB_PixelFormat_32Bits_RGB = 32 
            ; #PB_PixelFormat_32Bits_BGR = 64       ; Bit 6
            
            ; #PB_PixelFormat_ReversedY  = 32768    ; Bit 14
            ; #PB_PixelFormat_NoAlpha    = 65536    ; Bit 15

            ; PureBasic delivers the PixelFormat together with the ReversedY Bit
            ; with the AND NOT (& ~) we eliminate the ReversedY Bit to get only the format value
            
            Debug "ImageBufferSize  = " + \imgBufferSize
            Debug "ImageBufferPitch = " + \imgBufferPitch
            Debug "ImageWidth       = " + \imgWidth
            Debug "ImageHeight      = " + \imgHeight
        
          EndWith
        
          StopDrawing()    
          ProcedureReturn #True
        
        Else 
          _Exception(#PB_Compiler_Procedure, DBG::#PbFw_DBG_Err_DrawingNotStarted)
        EndIf
      
      Else ; PbImageNo is not an Image
        
        With *TImageInfo
          \PbImageNo = -1
          \imgBufferSize = 0
          \imgBufferPitch = 0
          \imgWidth = 0
          \imgHeight = 0
          \imgPixels = 0
          \imgDepth = 0 
          \imgPixelFormat = 0
        EndWith
        
        ProcedureReturn #False
      EndIf
    Else
      _Exception(#PB_Compiler_Procedure, DBG::#PbFw_DBG_Err_IsNotImage) 
      ProcedureReturn #False
    EndIf
  EndProcedure
  
  Procedure.i FreeImageBuffer(*ImgBuf.TImageBuffer)
    
    If *ImgBuf
      If *ImgBuf\hBuffer\_ptrMem               ; if a Buffer is allocated
        BUFFER::FreeBuffer(*ImgBuf\hBuffer)  ; free the Buffer
      EndIf
      FreeMemory(*ImgBuf)                    ; Free TImgBuffer Structure
    EndIf
    ProcedureReturn 0
  EndProcedure
  
  Procedure.i ImageToBuffer (PbImageNo, *ImgBuf.TImageBuffer)
  ; ======================================================================
  ; NAME : ImageToBuffer
  ; DESC : copies a PureBasic Image to a Buffer()
  ; DESC : SizeOf(Buffer()) and SizeOfImage will be checked
  ; DESC : if the size of Image and Buffer is differnt, the minimum size
  ; DESC : will be used as BytesToCopy
  ; VAR(PbImageNo) : The PureBasic #Image
  ; VAR(*ImgBuf)   : Pointer to the destination Buffer()
  ; RET : NoOfBytes copied
  ; ======================================================================
    
    DBG::mac_CheckPointer(*ImgBuf)
    
    If IsImage(PbImageNo) 
      
      If StartDrawing(ImageOutput(PbImageNo))
        CopyMemory(DrawingBuffer(), *ImgBuf\hBuffer\_ptrMem, *ImgBuf\hBuffer\Memsize)
        StopDrawing()
      Else 
        _Exception(#PB_Compiler_Procedure, DBG::#PbFw_DBG_Err_DrawingNotStarted)
      EndIf
    
      ProcedureReturn MemorySize(*ImgBuf)
      
    Else
       _Exception(#PB_Compiler_Procedure, DBG::#PbFw_DBG_Err_IsNotImage)     
    EndIf
        
    ProcedureReturn 0
  EndProcedure
  
  ; BufferToImage and ImageToBuffer should move to Buffer::
  Procedure.i BufferToImage(*pBuf.BUFFER::hBuffer, PbImageNo)
  ; ======================================================================
  ; NAME : BufferToImageTo
  ; DESC : copies a Buffer() to a PureBasic Image
  ; DESC : SizeOf(Buffer()) and SizeOfImage will be checked
  ; DESC : if the size of Image and Buffer is differnt, the minimum size
  ; DESC : will be used as BytesToCopy
  ; VAR(PbImageNo) : The PureBasic #Image
  ; VAR(*pBuf)  : Pointer to the destination Buffer()
  ; RET : Bytes copied
  ; ======================================================================
        
    Protected RET
    DBG::mac_CheckPointer(*pBuf)
    
    If IsImage(PbImageNo) 
      If StartDrawing(ImageOutput(PbImageNo))
        CopyMemory(*pBuf, DrawingBuffer(), MemorySize(*pBuf))
        StopDrawing()
        ProcedureReturn MemorySize(*pBuf)
      Else 
       _Exception(#PB_Compiler_Procedure, DBG::#PbFw_DBG_Err_DrawingNotStarted)
      EndIf
    Else
      _Exception(#PB_Compiler_Procedure, DBG::#PbFw_DBG_Err_IsNotImage)           
    EndIf
      
   ProcedureReturn 0
  EndProcedure
  
  Procedure.i Normalize(PbImageNo)
  ; ======================================================================
  ; NAME : Normalize
  ; DESC : Normalize image colors. Stretch the color values
  ; DESC : to get the lightest point as white and the darkest as black
  ; VAR PbImageNo : The PureBasic ImageID
  ; RET : #TRUE if sucseed; #FALSE if no Structure isn't created
  ; ======================================================================
  
    Protected ImgInf.TImageInfo
    Protected *Buffer                 ; Pointer to ImageBuffer
    Protected *pPix.PB::TSystemColor  ; Pointer to actual Pixel/Color
    
    Protected myBufferPitch           ; line lenght in Buffer
    Protected.i X,Y, min, max 
    Protected.i NewColVal, kNorm
    Protected.i xRET = #True
        
    min = 255
    
    If InitImageInfoStruct(PbImageNo, @ImgInf)
            
      If StartDrawing(ImageOutput(PbImageNo))
        *Buffer = DrawingBuffer()
        
        If *Buffer 
          ; xRET = ImageToBuffer(PbImageNo, *Buffer)
          ; Debug xRET
     
          Select (ImgInf\imgPixelFormat & $FF)
              
            Case #PB_PixelFormat_24Bits_BGR, #PB_PixelFormat_24Bits_RGB
              ; ------------------------------------------------------------  
              ;  24-Bit BGR or RGB
              ; ------------------------------------------------------------  
               
              ; We need 2 Loops for Pixel manipulation because a line in the Buffer() may contain
              ; fill Bytes. We might get a problem if we use FOR P = *Buffer To EndOfBuffer
              ; if there is maybe 1 fill Byte at the end of each line. This byte will shift the colors
              ; 1 Byte. 
              For Y = 0 To (ImgInf\imgHeight -1)
                *pPix = *Buffer + ImgInf\imgBufferPitch * Y 
                ; Debug " Py = " + *pPix
                
                For X = 0 To (ImgInf\imgWidth -1)
                  PB::SaveMinMax(*pPix\ch[0], min, max)      ; MACRO SaveMinMax
                  PB::SaveMinMax(*pPix\ch[1], min, max)
                  PB::SaveMinMax(*pPix\ch[2], min, max)
                  
                  *pPix = *pPix + 3  ; Add 3 Bytes to the actual address => Next Pixel
                  ; Debug " Py = " + Str(*pPix) + " / Y = " + Y
                Next  
              Next
              
              If (max-min) < 255      ; The color space is not completely used!
                kNorm = (256 * 255)/(max-min)    ; 255/(max-min) * IntFactor; we correct IntFactor later with >>8
                
                For Y = 0 To ImgInf\imgHeight -1
                  *pPix = *Buffer + ImgInf\imgBufferPitch * Y 
                  ; Debug " Px = " + *pPix
                  For X = 0 To ImgInf\imgWidth -1
                    ; Attention, here at 24Bit Color we have to use \ch[0..2]
                    NewColVal = ((*pPix\ch[0] - min) * kNorm) >> 8 ; /256
                    If NewColVal <=255
                      *pPix\ch[0] = NewColVal
                    Else
                      *pPix\ch[0] = 255
                    EndIf
                    
                    NewColVal = ((*pPix\ch[1] - min) * kNorm) >> 8 ; /256
                    If NewColVal <=255
                      *pPix\ch[1] = NewColVal
                    Else
                      *pPix\ch[1] = 255
                    EndIf
                    
                    NewColVal = ((*pPix\ch[2] - min) * kNorm) >> 8 ; /256
                    If NewColVal <=255
                      *pPix\ch[2] = NewColVal
                    Else
                      *pPix\ch[2] = 255
                    EndIf
                    
                    *pPix = *pPix + 3  ; Add 3 Bytes to the actual address => Next Pixel
                    ; Debug " Py = " +*pPix + " / Y = " + Y
                  Next 
                Next
              EndIf
              
      ;           Debug "Done"
      ;           Debug "*Buffer = " + *Buffer
      ;           Debug "*pPix = " + *pPix
      ;           Debug *pPix -*Buffer
              
               
            Case #PB_PixelFormat_32Bits_RGB, #PB_PixelFormat_32Bits_BGR
              ; ------------------------------------------------------------  
              ;  32-Bit RGB (Windows standard)
              ; ------------------------------------------------------------  
              ; We need 2 Loops for Pixel manipulation because a line in the Buffer() may contain
              ; fill Bytes. We might get a problem if we use FOR P = *Buffer To EndOfBuffer
              ; if there is maybe 1 fill Byte at the end of each line. This byte will shift the colors
              ; 1 Byte. 
              
              For Y = 0 To (ImgInf\imgHeight -1)
                *pPix = *Buffer + ImgInf\imgBufferPitch * Y 
                ; Debug " Py = " + *pPix
                
                For X = 0 To (ImgInf\imgWidth -1)
                  PB::SaveMinMax(*pPix\RGB\R, min, max)      ; MACRO SaveMinMax
                  PB::SaveMinMax(*pPix\RGB\G, min, max)
                  PB::SaveMinMax(*pPix\RGB\B, min, max)
                  
                  *pPix = *pPix + 4  ; Add 4 Bytes to the actual address => Next Pixel
                  ; Debug " Py = " + Str(*pPix) + " / Y = " + Y
                Next  
              Next
              
              If (max-min) < 255    ; The color space is not completely used!
                kNorm = (256 *255) / (max-min)
                
                For Y = 0 To ImgInf\imgHeight -1
                  *pPix = *Buffer + ImgInf\imgBufferPitch * Y
                  ; Debug " Px = " + *pPix
                  
                  For X = 0 To ImgInf\imgWidth -1
                    NewColVal = ((*pPix\RGB\R - min) * kNorm) >> 8 ; /256
                    If NewColVal <=255
                      *pPix\RGB\R = NewColVal
                    Else
                      *pPix\RGB\R = 255
                    EndIf
                    
                    NewColVal = ((*pPix\RGB\G - min) * kNorm) >> 8 ; /256
                    If NewColVal <=255
                      *pPix\RGB\G = NewColVal
                    Else
                      *pPix\RGB\G = 255
                    EndIf
                    
                    NewColVal = ((*pPix\RGB\B - min) * kNorm) >> 8 ; /256
                    If NewColVal <=255
                      *pPix\RGB\B = NewColVal
                    Else
                      *pPix\RGB\B = 255
                    EndIf
                    
                    *pPix = *pPix + 4  ; Add 4 Bytes to the actual address => Next Pixel
                  Next 
                Next
              EndIf             
          EndSelect         
          StopDrawing()
        Else 
          _Exception(#PB_Compiler_Procedure, DBG::#PbFw_DBG_Err_DrawingNotStarted)
          xRET = #False  
        EndIf       
      EndIf
    EndIf
    
    ProcedureReturn xRET
  EndProcedure
    
  Procedure.i GreyScaleBuffer(*pBuffer, *ImageInfo.TimageInfo, Methode = #PbFw_IMG_GreyScale_Standard)
  ; ======================================================================
  ; NAME : GreyScaleBuffer
  ; DESC : converts a colored image in the specified Buffer() into greyscale
  ; VAR(*pBuffer)    : Pointer to the ImageBuffer
  ;                   It can be the Pointer to a ShadwoCopy of an Image
  ;                   or the Pointer to the active DrawingBuffer()
  ;
  ; VAR(*ImageInfo) : The ImageInfo Structure which describes
  ;                   the details. This is necessary because if we work 
  ;                   with a ShadowCopy of a Image in memory, it is not a 
  ;                   Image identified with a PureBasic ImageID #Image.
  ;                   So we can't get any info with the standard PureBasic
  ;                   functions like ImageHeight(), ImageWidth()...
  ;                   We must collect this information befor we copy the 
  ;                   PureBasicImage into the MemoryBuffer().
  ;                   
  ; VAR(Methode)  : #PbFw_IMG_GreyScale_[Standard/Average/WeightedLight]
  ; RET : #TRUE if sucseed; #FALSE if not
  ; ======================================================================

    Protected *pPix.PB::TSystemColor  ; Pointer to actual Pixel/Color
    Protected.i GreyCol     ; the grey color value
    Protected.i X,Y,P       ; X,Y Pixel position; P pointer to PixelMemory
    Protected.i fR, fG, fB  ; WeightFactors for RED, GREEN, BLUE Channel
    Protected.i xRET = #True
       
    ; Methode                 | Weight Base %              | Weight Base 1024 for >>10 use
    ; ------------------------|----------------------------|------------------------------
    ; Greyscale_Average       | (33.3, 33.3, 33.3)% =99.9  | (341, 341, 341) =1023 = 99.9%
    ; Greyscale_Standard      | (29.9, 58.7, 11.4)% =100   | (306, 601, 117) =1024 = 100%
    ; Greyscale_WeightedLight | (30.9, 60.9,  8.2)% =100   | (316, 624,  84) =1024 = 100%

    ; Attention multiply the factors with 1024. So we can use Integer multiplication and >>10
    ; of Float multiplication
    ; Sum of all 3 factors should be 1024 (100%) here, or 1.0 for float variables
    Select methode
      Case #PbFw_IMG_GreyScale_Average
        fR = 341  ; factor = 1/3 * 1024 (10Bit)
        fG = 341
        fB = 341        
      Case #PbFw_IMG_GreyScale_Standard
        fR = 306 
        fG = 601
        fB = 117        
      Case #PbFw_IMG_GreyScale_WeightedLight
        fR = 316
        fG = 624
        fB = 84        
    EndSelect
         
    If *pBuffer And *ImageInfo   ; if we have valid Pointers
      
      Select *ImageInfo\imgPixelFormat & $FF
          
        Case #PB_PixelFormat_24Bits_RGB, #PB_PixelFormat_24Bits_BGR
          ; ------------------------------------------------------------  
          ;  24-Bit RGB (Windows standard), BGR
          ; ------------------------------------------------------------  
          
          ; We need 2 Loops for Pixel manipulation because a line in the Buffer() may contain
          ; fill Bytes. We might get a problem if we use FOR P = *pBuffer To EndOfBuffer
          ; if there is maybe 1 fill Byte at the end of each line. This byte will shift the colors
          ; 1 Byte. 
          For Y = 0 To (*ImageInfo\imgHeight -1)
            *pPix = *pBuffer + *ImageInfo\imgBufferPitch * Y 
            
            For X = 0 To (*ImageInfo\imgWidth -1)    ; process all Pixels in a line
              With *pPix
                GreyCol = (\RGB\R * fr + \RGB\G * fG + \RGB\B * fB) >>10
                \RGB\R = GreyCol
                \RGB\G = GreyCol
                \RGB\B = GreyCol
                *pPix = *pPix + 3    ; Add 3 Bytes to the actual address => Next Pixel
              EndWith  
            Next  
          Next
                 
        Case #PB_PixelFormat_32Bits_RGB, #PB_PixelFormat_32Bits_BGR
          ; ------------------------------------------------------------  
          ;  32-Bit RGBA (Windows standard), ABGR
          ; ------------------------------------------------------------  
          
          ; We need 2 Loops for Pixel manipulation because a line in the Buffer() may contain
          ; fill Bytes. We might get a problem if we use FOR P = *pBuffer To EndOfBuffer
          ; if there is maybe 1 fill Byte at the end of each line. This byte will shift the colors
          ; 1 Byte. 
          For Y = 0 To (*ImageInfo\imgHeight -1)
            *pPix = *pBuffer + *ImageInfo\imgBufferPitch * Y 
            
            For X = 0 To (*ImageInfo\imgWidth -1)    ; process all Pixels in a line
              With *pPix
                GreyCol = (\RGB\R * fr + \RGB\G * fG + \RGB\B * fB) >>10
                \RGB\R = GreyCol
                \RGB\G = GreyCol
                \RGB\B = GreyCol
                *pPix = *pPix + 4    ; Add 4 Bytes to the actual address => Next Pixel
              EndWith  
            Next  
          Next          
      EndSelect
    Else
      xRET = #False  
    EndIf
      
    ProcedureReturn xRET
  EndProcedure

  Procedure.i GreyScalePbImage(PbImageNo, Methode = #PbFw_IMG_GreyScale_Standard)
  ; ======================================================================
  ; NAME : GreyScalePbImage
  ; DESC : conerts a PureBasic Image identified by #Image into GreyScale
  ; VAR PbImageNo : The PureBasic ImageID
  ; VAR(Methode)  : #PbFw_IMG_GreyScale_[Standard/Average/WeightedLight]
  ; RET : #TRUE if sucseed; #FALSE if no Structure isn't created
  ; ======================================================================
    Protected ImgInf.TImageInfo
    Protected *Buffer
    Protected.i RET
        
    ; First we must create the detailed ImageInfo
    ; after we dan use mil_GreyScaleBuffer to GeryScale the Image in Memory 
    If InitImageInfoStruct(PbImageNo, @ImgInf)  
      StartDrawing(ImageOutput(PbImageNo))  ; Activates Image for drawing
      *Buffer = DrawingBuffer()             ; get the start address of Image 
      
      If *Buffer  ; if we have valid Buffer
        RET = GreyScaleBuffer(*Buffer, @ImgInf, Methode) ; do the GreyScalee
      EndIf     
      ; Release the Image from DrawingBuffer()! 
      ; *Buffer ist lost (invalid)!!! See PureBasicHelp of DrawingBuffer()
      StopDrawing()  
    EndIf
    
    ProcedureReturn RET
  EndProcedure
   
EndModule

; IDE Options = PureBasic 6.20 Beta 4 (Windows - x64)
; CursorPosition = 326
; FirstLine = 350
; Folding = ---
; Optimizer
; CPU = 5
; Compiler = PureBasic 6.20 Beta 4 - C Backend (Windows - x64)