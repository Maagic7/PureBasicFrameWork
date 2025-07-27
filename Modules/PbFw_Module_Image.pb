; ===========================================================================
;  FILE : PbFw_Module_Image.Pb
;  NAME : Module IMG::
;  DESC : Implements Image functions
;  DESC : 
;  SOURCES: for PosterizeBuffer
;             https://www.purebasic.fr/english/viewtopic.php?p=626438&hilit=DrawingBufferPixelFormat#p626438
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
;{ 2025/02/08 S.Maag some reworks done
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
XIncludeFile "PbFw_Module_PX.pb"          ; PX::      PureBasic extention Module
XIncludeFile "PbFw_Module_Debug.Pb"       ; DBG::     Debugging and Exception handling
XIncludeFile "PbFw_Module_COLOR.Pb"       ; COLOR::   24/32 Bit Color Module
XIncludeFile "PbFw_Module_VectorColor.Pb" ; VecCol::  VectorColor Module
XIncludeFile "PbFw_Module_Buffer.Pb"      ; BUF::     Buffer handling Module

; XIncludeFile ""

DeclareModule IMG
  
  #IMG_GreyScale_Standard = 0
  #IMG_GreyScale_Average = 1
  #IMG_GreyScale_WeightedLight = 2
  
  Enumeration PbFw_IMG_Dither                 ; DitherMethode
    #IMG_Dither_No                       ; 0 = no dither
    #IMG_Dither_SierraLite               ; 1 = Sierra Lite (error diffusion)
    #IMG_Dither_ShiauFan                 ; 2 = Shiau-Fan (error diffusion)
    #IMG_Dither_BlueNoise                ; 3 = 16x16 blue noise matrix
    #IMG_Dither_Bayer                    ; 4 = 16x16 bayer matrix
    #IMG_Dither_6x6_clustered            ; 5 = 6x6 clustered dot
    #IMG_Dither_6x8_clustered            ; 6 = 6x8 clustered dot
    #IMG_Dither_6x6_diagonal_lines1      ; 7 = 6x6 diagonal lines 1
    #IMG_Dither_6x6_diagonal_lines2      ; 8 = 6x6 diagonal lines 2
  EndEnumeration

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
    hBuffer.BUF::hBuffer ; Buffer Handle. Structure form Module Buffer::
  EndStructure
  
  ; Sturcture for color Statistik of one channel
  Structure TChannel_Statistik
    used.l    ; number of differnt colors used
    min.l     ; min value of color
    max.l     ; max value of color
    avg.l     ; average value of color
    sd.f      ; standard derivation (Standardabweichung)
  EndStructure
  
  Declare.i InitImageInfoStruct(PbImageNo, *TImageInfo.TImageInfo, xStartDrawing=#False)
  Declare.i FreeImageBuffer(*ImgBuf.TImageBuffer)
  Declare.i ImageToBuffer(PbImageNo, *ImgBuf.TImageBuffer)
  Declare.i BufferToImage(*pBuf.BUF::hBuffer, PbImageNo)
  Declare.i NormalizeBuffer(*pBuffer, *ImageInfo.TimageInfo)
  Declare.i GreyScaleBuffer(*pBuffer, *ImageInfo.TimageInfo, Methode=#IMG_GreyScale_Standard)
  Declare.i GreyScaleImage(PbImageNo, Methode=#IMG_GreyScale_Standard)
  Declare.i NegativeBuffer(*pBuffer, *ImageInfo.TimageInfo)
  Declare.i NegativeChannelBuffer(*pBuffer, *ImageInfo.TimageInfo, Channel=#Red)
  Declare.i InvertBuffer(*pBuffer, *ImageInfo.TimageInfo)
  Declare.i InvertChannelBuffer(*pBuffer, *ImageInfo.TimageInfo, Channel=#Red)
  Declare.i BrightnessBuffer(*pBuffer, *ImageInfo.TimageInfo, AddBrightAll=0, AddBrightRed=0, AddBrightGreen=0, AddBrightBlue=0)
  Declare.i GammaBuffer(*pBuffer, *ImageInfo.TimageInfo, GammaAll.f=1.0, GammaRed.f=1.0, GammaGreen.f=1.0, GammaBlue.f=1.0)
  Declare.i PosterizeBuffer(*pBuffer, *ImageInfo.TImageInfo, Levels=4, DitherMethode=#IMG_Dither_No, xGrayscale=#False, GammOn=#True, Gamma.f=2.23)
  Declare.i PosterizeImage(PbImageNo, Levels=4, DitherMethode=#IMG_Dither_No, xGrayscale=#False, GammOn=#True, Gamma.f=2.23)
  Declare.i NormalizeImage(PbImageNo)
  Declare.i NegativeImage(PbImageNo)
  Declare.i NegativeChannelImage(PbImageNo, Channel=#Red)
  Declare.i InvertChannelImage(PbImageNo, Channel=#Red)
  Declare.i BrightnessImage(PbImageNo, AddBrightAll=0, AddBrightRed=0, AddBrightGreen=0, AddBrightBlue=0)
  Declare.i GammaImage(PbImageNo, GammaAll.f=1.0, GammaRed.f=1.0, GammaGreen.f=1.0, GammaBlue.f=1.0)

EndDeclareModule

Module IMG
  
  EnableExplicit
  PbFw::ListModule(#PB_Compiler_Module)  ; Lists the Module in the ModuleList (for statistics)
  
  #PbFwCfg_Module_CheckPointerException = #False
  #_Float_1div255  = 1/255.0
  ; start the Enumeration with the value for ModulSpecific Errors
  Enumeration ; DBG::#DBG_Err_ModulSpecific
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
    #IMG_Rotate_Left
    #IMG_Rotate_Right
    #IMG_Flip_Horizontal
    #IMG_Flip_Vertical
  EndEnumeration
  
  Procedure.i InitImageInfoStruct(PbImageNo, *TImageInfo.TImageInfo, xStartDrawing=#False)
  ; ======================================================================
  ; NAME : InitImageInfoStruct
  ; DESC : Creates the the InitImageInfoStruct Structure for an Image
  ; VAR(PbImageNo) : The PureBasic #Image
  ; VAR(*TImageInfo)  : Pointer to the InitImageInfo Structure
  ; VAR(xStartDrawing) ; #True: keep the Startdrawing alive (do not call Stopdrawing)
  ; RET : #TRUE if sucseed; #FALSE if Structure isn't created
  ; ======================================================================
    Protected ret 
      
    If IsImage(PbImageNo) And *TImageInfo      
        
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
           
          Debug "ImageBufferSize  = " + \imgBufferSize
          Debug "ImageBufferPitch = " + \imgBufferPitch
          Debug "ImageWidth       = " + \imgWidth
          Debug "ImageHeight      = " + \imgHeight
          Debug "ImageDepth       = " + \imgDepth
          
          If \imgPixelFormat = #PB_PixelFormat_24Bits_BGR Or \imgPixelFormat = #PB_PixelFormat_32Bits_BGR 
            Debug "Image is BGR"
          Else
            Debug "Image is RGB"
         EndIf 
          
        EndWith
       
        ; switch off drawing
        If Not xStartDrawing
          StopDrawing()
        EndIf
       
        ret = #True
      Else 
        _Exception(#PB_Compiler_Procedure, DBG::#DBG_Err_DrawingNotStarted)
      EndIf
    EndIf
    
    ; clrear ImageInfo Struct if there was an error!
    If Not ret         
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
      _Exception(#PB_Compiler_Procedure, DBG::#DBG_Err_IsNotImage) 
    EndIf
      
    ProcedureReturn ret
  EndProcedure
  
  Procedure.i FreeImageBuffer(*ImgBuf.TImageBuffer)
    
    If *ImgBuf
      If *ImgBuf\hBuffer\_ptrMem               ; if a Buffer is allocated
        BUF::FreeBuffer(*ImgBuf\hBuffer)  ; free the Buffer
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
        _Exception(#PB_Compiler_Procedure, DBG::#DBG_Err_DrawingNotStarted)
      EndIf
    
      ProcedureReturn MemorySize(*ImgBuf)
      
    Else
       _Exception(#PB_Compiler_Procedure, DBG::#DBG_Err_IsNotImage)     
    EndIf
        
    ProcedureReturn 0
  EndProcedure
  
  ; BufferToImage and ImageToBuffer should move to Buffer::
  Procedure.i BufferToImage(*pBuf.BUF::hBuffer, PbImageNo)
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
       _Exception(#PB_Compiler_Procedure, DBG::#DBG_Err_DrawingNotStarted)
      EndIf
    Else
      _Exception(#PB_Compiler_Procedure, DBG::#DBG_Err_IsNotImage)           
    EndIf
      
    ProcedureReturn 0
  EndProcedure
  
  Procedure.i BrightnessBuffer(*pBuffer, *ImageInfo.TimageInfo, AddBrightAll=0, AddBrightRed=0, AddBrightGreen=0, AddBrightBlue=0)
  ; ======================================================================
  ; NAME : BrightnessBuffer
  ; DESC : Change the Brightness of an Image in a Buffer
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
  ; VAR(AddBrightAll)  : The Brightness to change at all Colors R,G and B
  ;                      internal AddBrightAll is added to AddBright[Red/Green/Blue]
  ; VAR(AddBrightRed)  : The Brightness to change at Red    [-255..255]
  ; VAR(AddBrightGreen): The Brightness to change at Green  [-255..255]
  ; VAR(AddBrightBlue) : The Brightness to change at Blue   [-255..255]
  ; RET : #TRUE if sucseed; #FALSE if not
  ; ======================================================================
    Protected *pPix.PX::TSystemColor  ; Pointer to actual Pixel/Color
    Protected.i X, Y, BytesPerPixel       ; X,Y Pixel position
    Protected.i r,g,b
    Protected.i xRET = #True
    
    AddBrightRed + AddBrightAll
    AddBrightGreen + AddBrightAll
    AddBrightBlue + AddBrightAll
    
    ; [-100..100] = [-255..255]
    PX::LimitToMinMax(AddBrightRed, -255, 255)
    PX::LimitToMinMax(AddBrightGreen, -255, 255)
    PX::LimitToMinMax(AddBrightBlue, -255, 255)
      
    If *pBuffer And *ImageInfo   ; if we have valid Pointers
      
      BytesPerPixel = *ImageInfo\imgDepth >>3     
      ; We need 2 Loops for Pixel manipulation because a line in the Buffer() may contain
      ; fill Bytes. We might get a problem if we use FOR P = *pBuffer To EndOfBuffer
      ; if there is maybe 1 fill Byte at the end of each line. This byte will shift the colors
      ; 1 Byte. 
      For Y = 0 To (*ImageInfo\imgHeight -1)
        *pPix = *pBuffer + *ImageInfo\imgBufferPitch * Y 
        
        For X = 0 To (*ImageInfo\imgWidth -1)    ; process all Pixels in a line
          With *pPix              
            ; at TSystemColor R,G,B switches with the System color order to B,G,R
            ; I hope this is the same as PB_PixelFormat_.._BGR and we do not need 2 prog. parts
            r = \RGB\R + AddBrightRed
            PX::SaturateColor(r)          ; [0..255]
            \RGB\R = r
            
            g= \RGB\G + AddBrightGreen
            PX::SaturateColor(g)          ; [0..255]
            \RGB\G = g
            
            b= \RGB\B + AddBrightBlue
            PX::SaturateColor(b)          ; [0..255]
            \RGB\B = b
            
            *pPix = *pPix + BytesPerPixel    ; Next Pixel
          EndWith  
        Next  
      Next                 
    Else
      xRET = #False  
    EndIf
      
    ProcedureReturn xRET   
  EndProcedure
  
  Procedure.i BrightnessImage(PbImageNo, AddBrightAll=0, AddBrightRed=0, AddBrightGreen=0, AddBrightBlue=0)
    Protected ImageInfo.TImageInfo
    Protected *buf, ret 
    
    ret = InitImageInfoStruct(PbImageNo, ImageInfo, #True)
    If ret
      *buf = DrawingBuffer()
      If *buf
          ret = BrightnessBuffer(*buf, ImageInfo, AddBrightAll, AddBrightRed, AddBrightGreen, AddBrightBlue)
      Else
          ret = #False
      EndIf
      StopDrawing()
    EndIf
    
    ProcedureReturn ret   
  EndProcedure
  
  Structure _LUT      ; Lookup Table Structure to create 256 Value Lookup Table on Stack
    StructureUnion
      l.l[256]        ; 0..255
      f.f[256]
    EndStructureUnion
  EndStructure
  
  Procedure.i GammaBuffer(*pBuffer, *ImageInfo.TimageInfo, GammaAll.f=1.0, GammaRed.f=1.0, GammaGreen.f=1.0, GammaBlue.f=1.0)
  ; ======================================================================
  ; NAME : GammaBuffer
  ; DESC : Change the Gamma of an Image in a Buffer
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
  ; VAR(GammaAll)  : The Gamma to change at all Colors R,G and B
  ;                      internal AddBrightAll is multiplied with AddBright[Red/Green/Blue]
  ; VAR(GammaRed)  : The Gamma to change at Red    [0.01 .. 4.99]
  ; VAR(GammaGreen): The Gamma to change at Green  [0.01 .. 4.99]
  ; VAR(GammaBlue) : The Gamma to change at Blue   [0.01 .. 4.99]
  ; RET : #TRUE if sucseed; #FALSE if not
  ; ======================================================================
    
    Protected *pPix.PX::TSystemColor  ; Pointer to actual Pixel/Color in SystemColorOrder
    Protected.i X, Y, I, BytesPerPixel      ; X,Y Pixel position
    Protected.i r, g, b
    Protected.i xRET = #True
    Protected memf.f
    
    #_GammaMin_ = 0.01    ; Limit of Gamma [0.01 .. 4.99] as PaintShop do!
    #_GammaMax_ = 4.99
    
    PX::LimitToMinMax(GammaAll, #_GammaMin_, #_GammaMax_)
    GammaRed = GammaAll * GammaRed  
    GammaGreen = GammaAll * GammaGreen
    GammaBlue = GammaAll * GammaBlue
    
    PX::LimitToMinMax(GammaRed, #_GammaMin_, #_GammaMax_)
    PX::LimitToMinMax(GammaGreen, #_GammaMin_, #_GammaMax_)
    PX::LimitToMinMax(GammaBlue, #_GammaMin_, #_GammaMax_)
    
    GammaRed = 1/GammaRed  
    GammaGreen = 1/GammaGreen
    GammaBlue = 1/GammaBlue
    
    Protected GltR._LUT
    Protected GltG._LUT
    Protected GltB._LUT
       
    ; Gamma Lookup Tables on Stack
    For I = 0 To 255
      memf = I * #_Float_1div255
      GltR\l[I] = Pow(memf, GammaRed) * 255
      GltG\l[I] = Pow(memf, GammaGreen) * 255
      GltB\l[I] = Pow(memf, GammaBlue) * 255
    Next
    
    If *pBuffer And *ImageInfo   ; if we have valid Pointers   
      BytesPerPixel =  *ImageInfo\imgDepth >>3     
      ; We need 2 Loops for Pixel manipulation because a line in the Buffer() may contain
      ; fill Bytes. We might get a problem if we use FOR P = *pBuffer To EndOfBuffer
      ; if there is maybe 1 fill Byte at the end of each line. This byte will shift the colors
      ; 1 Byte. 
      For Y = 0 To (*ImageInfo\imgHeight -1)
        *pPix = *pBuffer + *ImageInfo\imgBufferPitch * Y 
        
        For X = 0 To (*ImageInfo\imgWidth -1)    ; process all Pixels in a line
          With *pPix 
            ; at TSystemColor R,G,B switches with the System color order to B,G,R
            ; I hope this is the same as PB_PixelFormat_.._BGR and we do not need 2 prog. parts
            \RGB\R = GltR\l[\RGB\R]
            \RGB\G = GltG\l[\RGB\G]
            \RGB\B = GltG\l[\RGB\B]                
            *pPix = *pPix + BytesPerPixel    ; Next Pixel
          EndWith  
        Next  
      Next
                 
     Else
      xRET = #False  
    EndIf
      
    ProcedureReturn xRET   
  EndProcedure
  
  Procedure.i GammaImage(PbImageNo, GammaAll.f=1.0, GammaRed.f=1.0, GammaGreen.f=1.0, GammaBlue.f=1.0)
    Protected ImageInfo.TImageInfo
    Protected *buf, ret 
    
    ret = InitImageInfoStruct(PbImageNo, ImageInfo, #True)
    If ret
      *buf = DrawingBuffer()
      If *buf
          ret = GammaBuffer(*buf, ImageInfo, GammaAll, GammaRed, GammaGreen, GammaBlue)
      Else
          ret = #False
      EndIf
      StopDrawing()
    EndIf
    
    ProcedureReturn ret   
  EndProcedure
   
  Procedure.i GreyScaleBuffer(*pBuffer, *ImageInfo.TimageInfo, Methode = #IMG_GreyScale_Standard)
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
  ; VAR(Methode)  : #IMG_GreyScale_[Standard/Average/WeightedLight]
  ; RET : #TRUE if sucseed; #FALSE if not
  ; ======================================================================

    Protected *pPix.PX::TSystemColor  ; Pointer to actual Pixel/Color
    Protected.i GreyCol               ; the grey color value
    Protected.i X, Y, BytesPerPixel   ; X,Y Pixel position
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
      Case #IMG_GreyScale_Average
        fR = 341  ; factor = 1/3 * 1024 (10Bit)
        fG = 341
        fB = 341        
      Case #IMG_GreyScale_Standard
        fR = 306 
        fG = 601
        fB = 117        
      Case #IMG_GreyScale_WeightedLight
        fR = 316
        fG = 624
        fB = 84        
    EndSelect
         
    If *pBuffer And *ImageInfo   ; if we have valid Pointers
      BytesPerPixel = *ImageInfo\imgDepth >>3                              
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
            *pPix = *pPix + BytesPerPixel    ; Next Pixel
          EndWith  
        Next  
      Next
                 
    Else
      xRET = #False  
    EndIf
    
    ProcedureReturn xRET
  EndProcedure

  Procedure.i GreyScaleImage(PbImageNo, Methode = #IMG_GreyScale_Standard)
  ; ======================================================================
  ; NAME : GreyScaleImage
  ; DESC : conerts a PureBasic Image identified by #Image into GreyScale
  ; VAR PbImageNo : The PureBasic ImageID
  ; VAR(Methode)  : #IMG_GreyScale_[Standard/Average/WeightedLight]
  ; RET : #TRUE if sucseed; #FALSE if no Structure isn't created
  ; ======================================================================
    Protected ImgInf.TImageInfo
    Protected *Buffer
    Protected.i xRET
        
    ; First we must create the detailed ImageInfo
    ; after we dan use mil_GreyScaleBuffer to GeryScale the Image in Memory 
    If InitImageInfoStruct(PbImageNo, @ImgInf)  
      StartDrawing(ImageOutput(PbImageNo))  ; Activates Image for drawing
      *Buffer = DrawingBuffer()             ; get the start address of Image 
      
      If *Buffer  ; if we have valid Buffer
        xRET = GreyScaleBuffer(*Buffer, @ImgInf, Methode) ; do the GreyScalee
      EndIf     
      ; Release the Image from DrawingBuffer()! 
      ; *Buffer ist lost (invalid)!!! See PureBasicHelp of DrawingBuffer()
      StopDrawing()  
    EndIf
    
    ProcedureReturn xRET
  EndProcedure
  
  Procedure.i InvertBuffer(*pBuffer, *ImageInfo.TimageInfo)
  ; ======================================================================
  ; NAME : InvertBuffer
  ; DESC : Invert the Colorsof an Image in Buffer Color = Not Color
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
  ; VAR(Channel)  : The Color Channel #Red, #Green or #Blue
  ; RET : #TRUE if sucseed; #FALSE if not
  ; ======================================================================
    Protected *pPix.PX::TSystemColor  ; Pointer to actual Pixel/Color
    Protected.i X, Y, BytesPerPixel   ; X,Y Pixel position
    Protected.i xRET = #True
          
    If *pBuffer And *ImageInfo   ; if we have valid Pointers
      
      BytesPerPixel = *ImageInfo\imgDepth >>3              
      ; We need 2 Loops for Pixel manipulation because a line in the Buffer() may contain
      ; fill Bytes. We might get a problem if we use FOR P = *pBuffer To EndOfBuffer
      ; if there is maybe 1 fill Byte at the end of each line. This byte will shift the colors
      ; 1 Byte. 
      For Y = 0 To (*ImageInfo\imgHeight -1)
        *pPix = *pBuffer + *ImageInfo\imgBufferPitch * Y 
        
        For X = 0 To (*ImageInfo\imgWidth -1)   ; process all Pixels in a line
          With *pPix               
            \RGB\R = ~\RGB\R
            \RGB\G = ~\RGB\G
            \RGB\B = ~\RGB\B              
            *pPix = *pPix + BytesPerPixel       ; Next Pixel
          EndWith  
        Next  
      Next
                 
    Else
      xRET = #False  
    EndIf
      
    ProcedureReturn xRET   
  EndProcedure
  
  Procedure.i InvertChannelBuffer(*pBuffer, *ImageInfo.TimageInfo, Channel=#Red)
  ; ======================================================================
  ; NAME : InvertChannelBuffer
  ; DESC : Inverts a single Channel (Red, Green or blue) of an Image in Buffer 
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
  ; VAR(Channel)  : The Color Channel #Red, #Green or #Blue
  ; RET : #TRUE if sucseed; #FALSE if not
  ; ======================================================================
    Protected *pPix.PX::TSystemColor  ; Pointer to actual Pixel/Color
    Protected.i X, Y, BytesPerPixel       ; X,Y Pixel position
    Protected.i ChNo, xRET = #True
    
    Select Channel  ; only allow #Red, #Green, #Blue
      Case #Red
        ChNo = PX::_SCM\idxRed
      Case #Green
        ChNo = PX::_SCM\idxGreen
      Case #Blue
        ChNo = PX::_SCM\idxBlue
      Default
        ProcedureReturn #False
    EndSelect
                 
    If *pBuffer And *ImageInfo   ; if we have valid Pointers
      BytesPerPixel = *ImageInfo\imgDepth >>3     
      ; We need 2 Loops for Pixel manipulation because a line in the Buffer() may contain
      ; fill Bytes. We might get a problem if we use FOR P = *pBuffer To EndOfBuffer
      ; if there is maybe 1 fill Byte at the end of each line. This byte will shift the colors
      ; 1 Byte. 
      For Y = 0 To (*ImageInfo\imgHeight -1)
        *pPix = *pBuffer + *ImageInfo\imgBufferPitch * Y 
        
        For X = 0 To (*ImageInfo\imgWidth -1)   ; process all Pixels in a line
          With *pPix               
            \ch[ChNo] = ~\ch[ChNo]
            *pPix = *pPix + BytesPerPixel       ; Next Pixel
          EndWith  
        Next  
      Next
                 
    Else
      xRET = #False  
    EndIf
      
    ProcedureReturn xRET  
  EndProcedure
  
  Procedure.i InvertChannelImage(PbImageNo, Channel=#Red)
    Protected ImageInfo.TImageInfo
    Protected *buf, ret 
    
    ret = InitImageInfoStruct(PbImageNo, ImageInfo, #True)
    If ret
      *buf = DrawingBuffer()
      If *buf
          ret = InvertChannelBuffer(*buf, ImageInfo, Channel)
      Else
          ret = #False
      EndIf
      StopDrawing()
    EndIf
    
    ProcedureReturn ret   
  EndProcedure
  
  Procedure.i NegativeBuffer(*pBuffer, *ImageInfo.TimageInfo)
  ; ======================================================================
  ; NAME : NegativeBuffer
  ; DESC : Negative an Image in Buffer
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
  ; RET : #TRUE if sucseed; #FALSE if not
  ; ======================================================================
    Protected *pPix.PX::TSystemColor  ; Pointer to actual Pixel/Color
    Protected.i X, Y, BytesPerPixel   ; X,Y Pixel position; P pointer to PixelMemory
    Protected.i xRET = #True
          
    If *pBuffer And *ImageInfo   ; if we have valid Pointers
      
      BytesPerPixel = *ImageInfo\imgDepth >>3                       
      ; We need 2 Loops for Pixel manipulation because a line in the Buffer() may contain
      ; fill Bytes. We might get a problem if we use FOR P = *pBuffer To EndOfBuffer
      ; if there is maybe 1 fill Byte at the end of each line. This byte will shift the colors
      ; 1 Byte. 
      For Y = 0 To (*ImageInfo\imgHeight -1)
        *pPix = *pBuffer + *ImageInfo\imgBufferPitch * Y 
        
        For X = 0 To (*ImageInfo\imgWidth -1)    ; process all Pixels in a line
          With *pPix               
            \RGB\R = 255- \RGB\R
            \RGB\G = 255- \RGB\G
            \RGB\B = 255- \RGB\B              
            *pPix = *pPix + 3    ; Next Pixel
          EndWith  
        Next  
      Next
                 
    Else
      xRET = #False  
    EndIf
      
    ProcedureReturn xRET   
  EndProcedure
  
  Procedure.i NegativeChannelBuffer(*pBuffer, *ImageInfo.TimageInfo, Channel=#Red)
  ; ======================================================================
  ; NAME : NegativeChannelBuffer
  ; DESC : Negative a Color Channel Red,Green or Blue of an Image in Buffer
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
  ; VAR(Channel)  : The Color Channel #Red, #Green or #Blue
  ; RET : #TRUE if sucseed; #FALSE if not
  ; ======================================================================
    Protected *pPix.PX::TSystemColor  ; Pointer to actual Pixel/Color
    Protected.i X, Y, BytesPerPixel   ; X,Y Pixel position
    Protected.i ChNo, xRET = #True
    
    Select Channel  ; only allow #Red, #Green, #Blue
      Case #Red
        ChNo = PX::_SCM\idxRed
      Case #Green
        ChNo = PX::_SCM\idxGreen
      Case #Blue
        ChNo = PX::_SCM\idxBlue
      Default
        ProcedureReturn #False
    EndSelect
                 
    If *pBuffer And *ImageInfo   ; if we have valid Pointers
      BytesPerPixel = *ImageInfo\imgDepth >>3              
      ; We need 2 Loops for Pixel manipulation because a line in the Buffer() may contain
      ; fill Bytes. We might get a problem if we use FOR P = *pBuffer To EndOfBuffer
      ; if there is maybe 1 fill Byte at the end of each line. This byte will shift the colors
      ; 1 Byte. 
      For Y = 0 To (*ImageInfo\imgHeight -1)
        *pPix = *pBuffer + *ImageInfo\imgBufferPitch * Y 
        
        For X = 0 To (*ImageInfo\imgWidth -1)    ; process all Pixels in a line
          With *pPix               
            \ch[ChNo] = 255- \ch[ChNo]
            *pPix = *pPix + BytesPerPixel    ; Next Pixel
          EndWith  
        Next  
      Next
                 
    Else
      xRET = #False  
    EndIf
      
    ProcedureReturn xRET  
  EndProcedure
  
  Procedure.i NegativeImage(PbImageNo)
    Protected ImageInfo.TImageInfo
    Protected *buf, ret 
    
    ret = InitImageInfoStruct(PbImageNo, ImageInfo, #True)
    If ret
      *buf = DrawingBuffer()
      If *buf
        ret = NegativeBuffer(*buf, ImageInfo)
      Else
        ret = #False
      EndIf
      StopDrawing()
    EndIf
    
    ProcedureReturn ret   
  EndProcedure
  
  Procedure.i NegativeChannelImage(PbImageNo, Channel=#Red)
    Protected ImageInfo.TImageInfo
    Protected *buf, ret 
    
    ret = InitImageInfoStruct(PbImageNo, ImageInfo, #True)
    If ret
      *buf = DrawingBuffer()
      If *buf
        ret = NegativeChannelBuffer(*buf, ImageInfo, Channel)
      Else
        ret = #False
      EndIf
      StopDrawing()
    EndIf
    
    ProcedureReturn ret   
  EndProcedure
 
  Procedure.i NormalizeBuffer(*pBuffer, *ImageInfo.TimageInfo)
  ; ======================================================================
  ; NAME : NormalizeBuffer
  ; DESC : Normalize colors of an image in a Buffer.
  ; DESC : Stretch the color values To use the
  ; DESC : The complete Color Space [0..255]. Get the lightest point 
  ; DESC : as white and the darkest as black.
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
  ; RET : #TRUE if sucseed; #FALSE if no Structure isn't created
  ; ======================================================================


    Protected *pPix.PX::TSystemColor  ; Pointer to actual Pixel/Color
    Protected.i X, Y, BytesPerPixel   ; X,Y Pixel position
    Protected.i xRET = #True
    Protected.i min, max, kNorm, NewColVal   
          
    If *pBuffer And *ImageInfo   ; if we have valid Pointers
      BytesPerPixel = *ImageInfo\imgDepth >>3                              
      ; We need 2 Loops for Pixel manipulation because a line in the Buffer() may contain
      ; fill Bytes. We might get a problem if we use FOR P = *pBuffer To EndOfBuffer
      ; if there is maybe 1 fill Byte at the end of each line. This byte will shift the colors
      ; 1 Byte. 
      For Y = 0 To (*ImageInfo\imgHeight -1)
        *pPix = *pBuffer + *ImageInfo\imgBufferPitch * Y 
        ; Debug " Py = " + *pPix
        
        For X = 0 To (*ImageInfo\imgWidth -1)
          PX::SaveMinMax(*pPix\ch[0], min, max)       ; MACRO SaveMinMax
          PX::SaveMinMax(*pPix\ch[1], min, max)
          PX::SaveMinMax(*pPix\ch[2], min, max)
          
          *pPix = *pPix + BytesPerPixel  ; Next Pixel
          ; Debug " Py = " + Str(*pPix) + " / Y = " + Y
        Next  
      Next

      If (max-min) < 255      ; The color space is not completely used!
        kNorm = (256 * 255)/(max-min)    ; 255/(max-min) * IntFactor; we correct IntFactor later with >>8
        
        For Y = 0 To *ImageInfo\imgHeight -1
          *pPix = *pBuffer + *ImageInfo\imgBufferPitch * Y 
          ; Debug " Px = " + *pPix
          For X = 0 To *ImageInfo\imgWidth -1
            ; Attention, here at 24Bit Color we have to use \ch[0..2]
            NewColVal = ((*pPix\ch[0] - min) * kNorm) >> 8  ; /256
            PX::SaturateColorMax(NewColVal)
            *pPix\ch[0] = NewColVal
            
            NewColVal = ((*pPix\ch[1] - min) * kNorm) >> 8  ; /256
            PX::SaturateColorMax(NewColVal)
            *pPix\ch[1] = NewColVal
            
            NewColVal = ((*pPix\ch[2] - min) * kNorm) >> 8  ; /256
            PX::SaturateColorMax(NewColVal)
            *pPix\ch[2] = NewColVal
             
            *pPix = *pPix + BytesPerPixel  ; Next Pixel
            ; Debug " Py = " +*pPix + " / Y = " + Y
          Next 
        Next
      EndIf
                 
    Else
      xRET = #False  
    EndIf
    
    ProcedureReturn xRET
  EndProcedure
  
  Procedure.i NormalizeImage(PbImageNo)
    Protected ImageInfo.TImageInfo
    Protected *buf, ret 
    
    ret = InitImageInfoStruct(PbImageNo, ImageInfo, #True)  ; Create ImageInfo and keep Drawing On
    If ret
      *buf = DrawingBuffer()
      If *buf
          ret = NormalizeBuffer(*buf, ImageInfo)
      Else
          ret = #False
      EndIf
      StopDrawing()
    EndIf
    
    ProcedureReturn ret   
  EndProcedure
   
  Procedure.i PosterizeBuffer(*pBuffer, *ImageInfo.TImageInfo, Levels=4, DitherMethode=#IMG_Dither_No, xGrayscale=#False, GammOn=#True, Gamma.f=2.23)
  ; ======================================================================
  ; NAME : PosterizeBuffer
  ; DESC : Posterize an Image in a Buffer with Dithering and Gamma correction
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
  ; VAR(Levels)  : Posterize Levels [2..64]
  ; VAR(DitherMethode) : Dither Methode
  ;       #IMG_Dither_No                       ; 0 = no dither
  ;       #IMG_Dither_SierraLite               ; 1 = Sierra Lite (error diffusion)
  ;       #IMG_Dither_ShiauFan                 ; 2 = Shiau-Fan (error diffusion)
  ;       #IMG_Dither_BlueNoise                ; 3 = 16x16 blue noise matrix
  ;       #IMG_Dither_Bayer                    ; 4 = 16x16 bayer matrix
  ;       #IMG_Dither_6x6_clustered            ; 5 = 6x6 clustered dot
  ;       #IMG_Dither_6x8_clustered            ; 6 = 6x8 clustered dot
  ;       #IMG_Dither_6x6_diagonal_lines1      ; 7 = 6x6 diagonal lines 1
  ;       #IMG_Dither_6x6_diagonal_lines2      ; 8 = 6x6 diagonal lines 2
  ; VAR(xGrayscale): True: grayscale the image
  ; VAR(GammOn): Ture : activates the Gamma correction with standard 2.23
  ; VAR(Gamma) : Gamma correction factor [0.01 .. 4.99]
  ; RET : #TRUE if sucseed; #FALSE if not
  ; ======================================================================
  
    ; Posterize (2024-08-31)
    ; by wilbert
    ; https://www.purebasic.fr/english/viewtopic.php?p=626438&hilit=DrawingBufferPixelFormat#p626438
      
    ; Error diffusion matrices: http://caca.zoy.org/study/part3.html
    ; Sierra Lite       
    ;     |   X | 1/2
    ; 1/4 | 1/4 |  
    
    ; Shiau-Fan
    ;      |       |      |  X  | 1/2
    ; 1/16 |  1/16 | 1/8 | 1/4  |
  
    Protected.l c0, c1, c2, dx, dy, I, L, m0, m2, mx, my, n, pitch, t, x, y
    Protected.Ascii *c, *dm, *e, *pLine
    
    Debug "PosterizeBuffer"
    
    ; limit levels [2, 64]
    If Levels<2: Levels=2: ElseIf Levels>64: Levels=64: EndIf
    
    If *pBuffer And *ImageInfo.TimageInfo
      Levels-1
      ; fill lookup tables
      Protected Dim LUT0a.l(255)
      Protected Dim LUT0b.a(255)    ; level index in LUT1
      Protected Dim LUT1a.l(Levels)
      Protected Dim LUT1b.l(Levels) ; delta to next level
      Protected Dim LUT1c.l(Levels) ; halfway to next level
      Protected Dim LUT1d.a(Levels) ; output value for level
      
      If Gamma < 0.01 : Gamma = 0.01 : ElseIf Gamma > 4.99 : Gamma = 4.99 : EndIf ; Gamma limits from PaintShop
      
      If GammOn   ; Gamma correction
        For I = 0 To 255
          LUT0a(I) = 1e9*Pow(I*#_Float_1div255, Gamma)
        Next    
      Else
        For I = 0 To 255
          LUT0a(I) = $400000*I
        Next            
      EndIf
        
      LUT1a(Levels) = LUT0a(255)
      LUT1c(Levels) = $7fffffff; there is no halfway to next level
      LUT1d(Levels) = 255
      
      For I = Levels -1 To 0 Step -1
        L = 255 *I / Levels
        LUT1a(I) = LUT0a(L)
        LUT1b(I) = LUT1a(I+1)-LUT1a(I)
        LUT1c(I) = (LUT1a(I+1)+LUT1a(I))>>1
        LUT1d(I) = L
      Next
      
      For I = 0 To 255
        L = Levels * I /255
        If DitherMethode
          LUT0b(I) = L; level index
        Else
          LUT0b(I) = LUT1d(L-(LUT1c(L)-LUT0a(I))>>31); closest color value
        EndIf
      Next
      
      ; update the image pixels
      mx = *ImageInfo\imgWidth-1  ; OutputWidth()-1
      my = *ImageInfo\imgHeight-1 ; OutputHeight()-1
      n = *ImageInfo\imgDepth >>3 -2  ; OutputDepth()>>3 -2
      
      Debug "mx = " + mx
      Debug "my = " + my
      
      If DitherMethode=#IMG_Dither_SierraLite Or DitherMethode=#IMG_Dither_ShiauFan
        ; error diffusion buffers
        Protected Dim _c0.l(mx+3)
        Protected Dim _c1.l(mx+3)
        Protected Dim _c2.l(mx+3)
        
      ElseIf DitherMethode
        
        Protected Dim dm.q(31)
        
        Select DitherMethode
            
          Case #IMG_Dither_Bayer
            ; 16x16 Bayer data
            dx=16: dy=16
            dm(00)=$a8288808a0208000: dm(01)=$aa2a8a0aa2228202: dm(02)=$68e848c860e040c0: dm(03)=$6aea4aca62e242c2
            dm(04)=$9818b8389010b030: dm(05)=$9a1aba3a9212b232: dm(06)=$58d878f850d070f0: dm(07)=$5ada7afa52d272f2
            dm(08)=$a4248404ac2c8c0c: dm(09)=$a6268606ae2e8e0e: dm(10)=$64e444c46cec4ccc: dm(11)=$66e646c66eee4ece
            dm(12)=$9414b4349c1cbc3c: dm(13)=$9616b6369e1ebe3e: dm(14)=$54d474f45cdc7cfc: dm(15)=$56d676f65ede7efe
            dm(16)=$ab2b8b0ba3238303: dm(17)=$a9298909a1218101: dm(18)=$6beb4bcb63e343c3: dm(19)=$69e949c961e141c1
            dm(20)=$9b1bbb3b9313b333: dm(21)=$9919b9399111b131: dm(22)=$5bdb7bfb53d373f3: dm(23)=$59d979f951d171f1
            dm(24)=$a7278707af2f8f0f: dm(25)=$a5258505ad2d8d0d: dm(26)=$67e747c76fef4fcf: dm(27)=$65e545c56ded4dcd
            dm(28)=$9717b7379f1fbf3f: dm(29)=$9515b5359d1dbd3d: dm(30)=$57d777f75fdf7fff: dm(31)=$55d575f55ddd7dfd
            
          Case #IMG_Dither_6x6_clustered
            ; 6x6 clustered dot (converted from image magick)
            dx=6: dy=6
            dm(00)=$f8dc23156a87b1bf: dm(01)=$7895eacd32075ca3: dm(02)=$87b1bf23156a404e: dm(03)=$4e78a3f8dc32075c
            dm(04)=$95eacd40
            
          Case #IMG_Dither_6x8_clustered
            ; 6x8 clustered dot
            dx=6: dy=8
            dm(00)=$1045a5af855a507a: dm(01)=$c525053ae4efba1b: dm(02)=$9acf8f653070dafa: dm(03)=$efba5a507aa5af85
            dm(04)=$3adafac51b1045e4: dm(05)=$6530709acf8f2505
            
          Case #IMG_Dither_6x6_diagonal_lines1
            ; 6x6 diagonal lines 1
            dx=6: dy=6
            dm(00)=$4aca27fba651d17c: dm(01)=$19ed98437520f49f: dm(02)=$3cbc6712e691c36e: dm(03)=$59048a35b5600bdf
            dm(04)=$d8832eae
            
          Case #IMG_Dither_6x6_diagonal_lines2
            ; 6x6 diagonal lines 2
            dx=6: dy=6
            dm(00)=$ed98277cd1fba651: dm(01)=$0b60b5df43196ec3: dm(02)=$d8832e0459ae8a35: dm(03)=$4a20bce6913c1267
            dm(04)=$75caf49f  
            
          Default:
            ; 16x16 blue noise taken data from LDR_LLL1_42.png by Christoph Peters (CC0 license)
            dx=16: dy=16
            dm(00)=$f78c1a26f289e7ae: dm(01)=$5264cc9130a469c1: dm(02)=$0862d5a97b5e1c71: dm(03)=$05a6187a550e49ce
            dm(04)=$b272e4560199bfd8: dm(05)=$96f825bcedd99736: dm(06)=$e99f2f41b6fe3b2b: dm(07)=$8047d13e6dac851d
            dm(08)=$510fc283d2134f66: dm(09)=$e2b55b9d002a60fb: dm(10)=$7994236beb90aac8: dm(11)=$0b8b16f576deca40
            dm(12)=$a8e1cb5c337720f3: dm(13)=$7034c34db08e14bb: dm(14)=$04f44a0da5db4558: dm(15)=$a2e8821ee5315768
            dm(16)=$3a28b38afabd0395: dm(17)=$27cd639a43d3a186: dm(18)=$da986e541b8165d7: dm(19)=$b93d06ff6f0ceec5
            dm(20)=$197ceccf3f2eadf1: dm(21)=$177d53beaf7f225f: dm(22)=$b74607a0c4e67348: dm(23)=$8da7dc2c92374ef9
            dm(24)=$8f32d6612493095a: dm(25)=$35f66715ead0a36c: dm(26)=$c611ab8450fcb4d4: dm(27)=$c0219ec7754202e3
            dm(28)=$59f074df126a9b10: dm(29)=$78874c0a5d88b129: dm(30)=$3c9c4bba38c9442d: dm(31)=$ddef39b8fde01f7e
            
        EndSelect
      EndIf
      
      If *ImageInfo\imgPixelFormat & (#PB_PixelFormat_24Bits_BGR|#PB_PixelFormat_32Bits_BGR)  ; DrawingBufferPixelFormat()
        m0=29: m2=77; BGR
      Else
        m0=77: m2=29; RGB
      EndIf
      
      If *ImageInfo\imgPixelFormat & #PB_PixelFormat_ReversedY
        *pLine = *pBuffer + *ImageInfo\imgBufferPitch*my      ;  DrawingBuffer()+DrawingBufferPitch()*my
        pitch = - *ImageInfo\imgBufferPitch                   ; -DrawingBufferPitch()
      Else
        *pLine = *pBuffer
        pitch = *ImageInfo\imgBufferPitch
      EndIf
      Debug "Pitch = " + pitch
      
      If xGrayscale      
        Debug "Grayscale"
        If DitherMethode<=0
          For y=0 To my
            *c = *pLine         
            ; posterize only (gray)
            For x=0 To mx
              L = *c\a * m0
              *c+1 : L = L + *c\a *150
              *c+1 : L=(L+ *c\a * m2 +128)>>8
              
              *c-2
              L=LUT0b(L)
              
              *c\a=L
              *c+1 : *c\a=L
              *c+1 : *c\a=L
              *c+n
            Next x
            *pLine + pitch
          Next y    
          
        ElseIf DitherMethode=#IMG_Dither_SierraLite
          
          For y=0 To my
            *c = *pLine         
            ; Sierra Lite error diffusion dither (gray)
            c0=0
            For x=0 To mx
              L= *c\a * m0
              *c+1 :L+ *c\a *150
              *c+1 : L=(L+ *c\a *m2 +128)>>8
              
              *c-2
              I=LUT0b(L)
              L=LUT0a(L) + c0>>1 +(_c0(x)+_c0(x+1))>>2
              I-(LUT1c(I)-L)>>31
              
              c0=L-LUT1a(I)
              _c0(x)=c0: L=LUT1d(I)
              
              *c\a=L
              *c+1 : *c\a=L
              *c+1 : *c\a=L
              *c+n
            Next x
            *pLine + pitch
          Next y    
          
        ElseIf DitherMethode=#IMG_Dither_ShiauFan
          
          For y=0 To my
            *c = *pLine         
            ; Shiau-Fan error diffusion dither (gray)
            c0=0
            For x=0 To mx
              L=*c\a*m0: *c+1: L+*c\a*150: *c+1: L=(L+*c\a*m2+128)>>8: *c-2
              I=LUT0b(L): L=LUT0a(L)+c0>>1+_c0(x)>>2+_c0(x+1)>>3+(_c0(x+2)+_c0(x+3))>>4
              I-(LUT1c(I)-L)>>31: c0=L-LUT1a(I)
              _c0(x)=c0
              L=LUT1d(I)
              *c\a=L: *c+1: *c\a=L: *c+1: *c\a=L: *c+n
            Next
           *pLine + pitch
          Next y    
          
        Else
          
          For y=0 To my
            *c = *pLine         
            ; ordered dither (gray)
            *dm=@dm()+(y % dy)*dx: *e= *dm + dx -2
            For x=0 To mx
              t=*dm\a<<1+1: *dm=*dm+1-(dx&((*e-*dm)>>31)); threshold
              L=*c\a*m0: *c+1: L+*c\a*150: *c+1: L=(L+*c\a*m2+128)>>8: *c-2
              I=LUT0b(L): I-(t*((LUT1b(I))>>9)+LUT1a(I)-LUT0a(L))>>31: L=LUT1d(I)
              *c\a=L: *c+1: *c\a=L: *c+1: *c\a=L: *c+n
            Next
            *pLine + pitch
          Next y    
        EndIf
        
      Else
        
        If DitherMethode<=0
          For y=0 To my
            *c = *pLine         
            ; posterize only (color)
            For x=0 To mx-1
              ;Debug "x = " + x
              *c\a= LUT0b(*c\a)
              *c+1
              *c\a=LUT0b(*c\a)
              *c+1
              *c\a=LUT0b(*c\a)
              *c+n
            Next
            *pLine + pitch
          Next y    
          
        ElseIf DitherMethode=#IMG_Dither_SierraLite
          For y=0 To my
            *c=*pLine         
            ; Sierra Lite error diffusion dither (color)
            c0=0: c1=0: c2=0
            For x=0 To mx
              L=LUT0a(*c\a)+c0>>1+(_c0(x)+_c0(x+1))>>2; c0
              I=LUT0b(*c\a): I-(LUT1c(I)-L)>>31: c0=L-LUT1a(I): _c0(x)=c0
              *c\a=LUT1d(I): *c+1     
              L=LUT0a(*c\a)+c1>>1+(_c1(x)+_c1(x+1))>>2; c1
              I=LUT0b(*c\a): I-(LUT1c(I)-L)>>31: c1=L-LUT1a(I): _c1(x)=c1
              *c\a=LUT1d(I): *c+1
              L=LUT0a(*c\a)+c2>>1+(_c2(x)+_c2(x+1))>>2; c2
              I=LUT0b(*c\a): I-(LUT1c(I)-L)>>31: c2=L-LUT1a(I): _c2(x)=c2
              *c\a=LUT1d(I): *c+n        
            Next
            *pLine + pitch
          Next y    
          
        ElseIf DitherMethode=#IMG_Dither_ShiauFan
          
          For y=0 To my
            *c=*pLine         
            ; Shiau-Fan error diffusion dither (color)
            c0=0: c1=0: c2=0
            For x=0 To mx
              L=LUT0a(*c\a)+c0>>1+_c0(x)>>2+_c0(x+1)>>3+(_c0(x+2)+_c0(x+3))>>4; c0
              I=LUT0b(*c\a): I-(LUT1c(I)-L)>>31: c0=L-LUT1a(I): _c0(x)=c0
              *c\a=LUT1d(I): *c+1     
              L=LUT0a(*c\a)+c1>>1+_c1(x)>>2+_c1(x+1)>>3+(_c1(x+2)+_c1(x+3))>>4; c1
              I=LUT0b(*c\a): I-(LUT1c(I)-L)>>31: c1=L-LUT1a(I): _c1(x)=c1
              *c\a=LUT1d(I): *c+1
              L=LUT0a(*c\a)+c2>>1+_c2(x)>>2+_c2(x+1)>>3+(_c2(x+2)+_c2(x+3))>>4; c2
              I=LUT0b(*c\a): I-(LUT1c(I)-L)>>31: c2=L-LUT1a(I): _c2(x)=c2
              *c\a=LUT1d(I): *c+n        
            Next
            *pLine + pitch
          Next y    
         
        Else
          
          For y=0 To my
            *c=*pLine         
            ; ordered dither (color)
            *dm=@dm()+(y%dy)*dx: *e=*dm+dx-2
            For x=0 To mx
              t=*dm\a<<1+1: *dm=*dm+1-(dx&((*e-*dm)>>31)); threshold
              I=LUT0b(*c\a): I-(t*((LUT1b(I))>>9)+LUT1a(I)-LUT0a(*c\a))>>31; c0
              *c\a=LUT1d(I): *c+1
              I=LUT0b(*c\a): I-(t*((LUT1b(I))>>9)+LUT1a(I)-LUT0a(*c\a))>>31; c1
              *c\a=LUT1d(I): *c+1
              I=LUT0b(*c\a): I-(t*((LUT1b(I))>>9)+LUT1a(I)-LUT0a(*c\a))>>31; c2
              *c\a=LUT1d(I): *c+n
            Next
            *pLine + pitch
          Next y    
        EndIf 
      EndIf
       
      ProcedureReturn mx * my ; #True
      
    Else   
      ProcedureReturn 0
    EndIf
  EndProcedure
  
  Procedure.i PosterizeImage(PbImageNo, Levels=4, DitherMethode=#IMG_Dither_No, xGrayscale=#False, GammOn=#True, Gamma.f=2.23)
    Protected ImageInfo.TImageInfo
    Protected *buf, ret 
    
    ret = InitImageInfoStruct(PbImageNo, ImageInfo, #True)  ; create ImageInfo and keep Drawing On
    If ret
      *buf = DrawingBuffer()
      ret = PosterizeBuffer(*buf, ImageInfo, Levels, DitherMethode, xGrayscale, GammOn, Gamma)
      StopDrawing()     ; Drawing was started at InitImageInfoStruct()
    EndIf
    
    ProcedureReturn ret   
  EndProcedure
  
EndModule

CompilerIf #PB_Compiler_IsMainFile
 ; ----------------------------------------------------------------------
 ;  M O D U L E   T E S T   C O D E
 ; ---------------------------------------------------------------------- 
 
  EnableExplicit
  Define Event
  Define File.s
  Define.d scale, scaleY
  
  UseJPEGImageDecoder()
  UsePNGImageDecoder()
  
  UseModule IMG
  
  If OpenWindow(0, 0, 0, 990, 580, "Image posterization (and dithering)", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_ScreenCentered)
    ImageGadget(0, 10, 10, 480, 480, 0, #PB_Image_Border)
    ImageGadget(1, 500, 10, 480, 480, 0, #PB_Image_Border)
    ButtonGadget(2, 20, 520, 120, 30, "Load image")
    TrackBarGadget(3, 180, 520, 220, 30, 2, 32, #PB_TrackBar_Ticks)
    SetGadgetState(3, 4)
    TextGadget(4, 410, 520, 80, 30, "4 Levels")
    ComboBoxGadget(5, 500, 520, 160, 30)
    AddGadgetItem(5, -1, "Posterize only")
    AddGadgetItem(5, -1, "Sierra Lite")
    AddGadgetItem(5, -1, "Shiau-Fan")
    AddGadgetItem(5, -1, "16x16 blue noise")
    AddGadgetItem(5, -1, "16x16 bayer")
    AddGadgetItem(5, -1, "6x6 clustered dot")
    AddGadgetItem(5, -1, "6x8 clustered dot")
    AddGadgetItem(5, -1, "6x6 diagonal lines 1")
    AddGadgetItem(5, -1, "6x6 diagonal lines 2")
    SetGadgetState(5, 0)
    CheckBoxGadget(6, 710, 520, 90, 30, "Grayscale")
    CheckBoxGadget(7, 810, 520, 160, 30, "Gamma correction")
    SetGadgetState(7, #True)  
    
    Repeat
      Event = WaitWindowEvent()
      If Event = #PB_Event_Gadget
        Select EventGadget()
          Case 2; load image
            File = OpenFileRequester("Choose image file", GetCurrentDirectory(), "", 0)
            If File And LoadImage(0, File)
              scale = DesktopScaledX(480)/ImageWidth(0)
              scaleY = DesktopScaledY(480)/ImageHeight(0)
              If scaleY<scale: scale=scaleY: EndIf
              If scale<1
                ResizeImage(0, ImageWidth(0)*scale, ImageHeight(0)*scale)   
              EndIf
              SetGadgetState(0, ImageID(0))
            EndIf
          Case 3; levels
            SetGadgetText(4, Str(GetGadgetState(3))+" Levels")
        EndSelect
        
        If IsImage(0)
          ; update result image
          CopyImage(0,1)
          PosterizeImage(1, GetGadgetState(3), GetGadgetState(5), GetGadgetState(6), GetGadgetState(7))
          SetGadgetState(1, ImageID(1))
        EndIf
      EndIf
    Until Event = #PB_Event_CloseWindow
  EndIf
  
CompilerEndIf
; IDE Options = PureBasic 6.21 (Windows - x64)
; CursorPosition = 936
; FirstLine = 909
; Folding = -----
; Optimizer
; CPU = 5