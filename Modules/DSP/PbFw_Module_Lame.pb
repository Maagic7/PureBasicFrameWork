; =====================================================================
; LAME NATIVE C-API WRAPPER FÜR PUREBASIC
; =====================================================================

DeclareModule LAME
  EnableExplicit
  
  ; =====================================================================
  ; LAME MP3 BITRATEN-KONSTANTEN (MPEG-1)
  ; =====================================================================
  
  ; --- Niedrige Qualität (ideal für Sprache oder stark komprimierte Vorschauen) ---
  #LAME_BitRate_32  = 32   ; 32 kBit
  #LAME_BitRate_40  = 40   ; 32 kBit
  #LAME_BitRate_48  = 48
  #LAME_BitRate_56  = 56
  #LAME_BitRate_64  = 64
  
  ; --- Mittlere Qualität (guter Kompromiss für Radio-Streams / Standard-Web) ---
  #LAME_BitRate_80  = 80
  #LAME_BitRate_96  = 96
  #LAME_BitRate_112 = 112
  #LAME_BitRate_128 = 128 ; Ehemaliger Internet-Standard
  #LAME_BitRate_160 = 160
  
  ; --- Hohe Qualität (Empfohlen für Musik und deine DSP-Ausgabe) ---
  #LAME_BitRate_192 = 192 ; Sehr gute Balance zwischen Dateigröße und Transparenz
  #LAME_BitRate_224 = 224
  #LAME_BitRate_256 = 256
  #LAME_BitRate_320 = 320 ; Das absolute Maximum der MP3-Spezifikation (Archivqualität)
  
  #LAME_QUALITY_0 = 0 ; Absolutes Maximum (sehr langsam)
  #LAME_QUALITY_1 = 1
  #LAME_QUALITY_2 = 2 ; Empfohlen für High-Fidelity
  #LAME_QUALITY_3 = 3
  #LAME_QUALITY_4 = 4
  #LAME_QUALITY_5 = 5 ; Standardmittelweg
  #LAME_QUALITY_6 = 6
  #LAME_QUALITY_7 = 7 ; Schnelle Echtzeit-Codierung
  #LAME_QUALITY_8 = 8
  #LAME_QUALITY_9 = 9 ; Schnellstmöglich (schlechte Qualität)
  
  ; =====================================================================
  ; LAME API FEHLER-CODES (RÜCKGABEWERTE)
  ; =====================================================================
  ; Werte > 0 sind dann die anzahl der Bytes oder Frames
  #LAME_OK                =  0 ; Alles in Ordnung / Erfolgreich
  #LAME_GENERIC_ERROR     = -1 ; Allgemeiner Fehler (z.B. falsche Parameter)
  #LAME_MALLOC_ERROR      = -2 ; Speicherfehler (LAME konnte intern keinen RAM reservieren)
  #LAME_BITRATE_ERROR     = -3 ; Die gewählte Bitrate wird nicht unterstützt
  #LAME_SAMPLERATE_ERROR  = -4 ; Die gewählte Samplerate wird nicht unterstützt
  #LAME_BAD_INITIALIZATION= -5 ; lame_init_params() wurde nicht oder fehlerhaft aufgerufen
  
  ; --- LAME VBR Modi (variable BitRate) ---
  #LAME_VBR_OFF = 0   ; VBR aus (Standard = CBR-Modus)
  #LAME_VBR_MT  = 1   ; VBR-Mark Taylor (Alt, selten genutzt)
  #LAME_VBR_RH  = 2   ; VBR-Robert Hegemann (Der Standard- und Standard-VBR-Modus)
  #LAME_VBR_MTR = 4  ; VBR-Mark Taylor / Robert Hegemann (Moderner, schnellerer VBR-Algorithmus)

   ; --- LAME VBR Qualitätsstufen (V0 bis V9) ---
  #LAME_VBR_Q0 = 0 ; "V0" -> Beste Qualität, Bitrate ca. 220–260 kbps (nahezu transparent)
  #LAME_VBR_Q2 = 2 ; "V2" -> Der weltweite Standard-Sweet-Spot! Ca. 170–210 kbps (exzellent)
  #LAME_VBR_Q4 = 4 ; "V4" -> Guter Kompromiss für tragbare Geräte, ca. 140–160 kbps
  #LAME_VBR_Q6 = 6 ; "V6" -> Akzeptable Qualität, ca. 100–120 kbps
  #LAME_VBR_Q9 = 9 ; "V9" -> Schlechteste Qualität, kleinste Datei, ca. 65–85 kbps 
  
  ; --- Basis- und Konfigurationsfunktionen ---
  PrototypeC.i lame_init()      ; Returns the *gfp
  PrototypeC.l lame_init_params(*gfp)
  PrototypeC.l lame_close(*gfp)
  
  ; --- Setter für Audio-Eigenschaften ---
  PrototypeC.l lame_set_in_samplerate(*gfp, rate.l)
  PrototypeC.l lame_set_num_channels(*gfp, channels.l)
  PrototypeC.l lame_set_out_samplerate(*gfp, rate.l)
  
  ; --- Setter für Bitraten / Qualität ---
  PrototypeC.l lame_set_brate(*gfp, bitrate.l)
  PrototypeC.l lame_set_quality(*gfp, quality.l) ; 2 = hoch, 5 = medium, 7 = schnell
  ; variable Bitrate
  PrototypeC.l lame_set_VBR(*gfp, vbr_mode.l)    
  PrototypeC.l lame_set_VBR_q(*gfp, vbr_q.l)     ; VBR Qualität (0 = beste, 9 = schlechteste)
  
  ; --- Die Enkodierungs-Funktionen ---
  ; 1. Für getrennte 16-Bit Integer Buffer (Short)
  PrototypeC.l lame_encode_buffer(*gfp, *pcm_l, *pcm_r, nsamples.l, *mp3buf, mp3buf_size.l)
  ; 2. Für verschachtelte (Interleaved) 16-Bit Integer Buffer (L,R,L,R...)
  PrototypeC.l lame_encode_buffer_interleaved(*gfp, *pcm_16raw, nsamples.l, *mp3buf, mp3buf_size.l)
  ; 3. Für getrennte 32-Bit Fließkomma Buffer (Float - ideal für DSPs!)
  PrototypeC.l lame_encode_buffer_float(*gfp, *pcm_l, *pcm_r, nsamples.l, *mp3buf, mp3buf_size.l)
  ; 4. Für verschachtelte 32-Bit Fließkomma Buffer (Float Interleaved)
  PrototypeC.l lame_encode_buffer_interleaved_ieee_float(*gfp, *pcm_floatraw, nsamples.l, *mp3buf, mp3buf_size.l)
  
  ; --- Finale Funktionen ---
  PrototypeC.l lame_encode_flush(*gfp, *mp3buf, mp3buf_size.l)
  PrototypeC.i lame_mp3_tags_write(*gfp, *file) ; Schreibt optional VBR-Tags am Ende
  
  ; --- Globale Funktionsvariablen ---
  Global lame_init.lame_init
  Global lame_init_params.lame_init_params
  Global lame_close.lame_close
  
  Global lame_set_in_samplerate.lame_set_in_samplerate
  Global lame_set_num_channels.lame_set_num_channels
  Global lame_set_out_samplerate.lame_set_out_samplerate
  Global lame_set_brate.lame_set_brate
  Global lame_set_quality.lame_set_quality
  Global lame_set_VBR.lame_set_VBR
  Global lame_set_VBR_q.lame_set_VBR_q
  
  Global lame_encode_buffer.lame_encode_buffer
  Global lame_encode_buffer_interleaved.lame_encode_buffer_interleaved
  Global lame_encode_buffer_float.lame_encode_buffer_float
  Global lame_encode_buffer_interleaved_ieee_float.lame_encode_buffer_interleaved_ieee_float
  Global lame_encode_flush.lame_encode_flush
  Global lame_mp3_tags_write.lame_mp3_tags_write
  
  Declare.i CalculateMP3BufferSize(nSamples.i)
  Declare.i LoadLameAPI(dllPath$ = "libmp3lame.dll")

EndDeclareModule

Module LAME
  EnableExplicit
  
  ; Faustformel zur Berechnung der sicheren MP3-Buffergröße:
  ; nSamples = Anzahl der Audio-Samples (pro Kanal!), die du JETZT enkodieren willst.
  Procedure.i CalculateMP3BufferSize(nSamples.i)
    Protected size.i
    size = Int(1.25 * nSamples + 7200)
    ProcedureReturn size
  EndProcedure

  Procedure.i LoadLameAPI(dllPath$ = "libmp3lame.dll")
    Protected lib = OpenLibrary(#PB_Any, dllPath$)
    If lib
      lame_init              = GetFunction(lib, "lame_init")
      lame_init_params       = GetFunction(lib, "lame_init_params")
      lame_close             = GetFunction(lib, "lame_close")
      lame_set_in_samplerate = GetFunction(lib, "lame_set_in_samplerate")
      lame_set_num_channels  = GetFunction(lib, "lame_set_num_channels")
      lame_set_out_samplerate= GetFunction(lib, "lame_set_out_samplerate")
      lame_set_brate         = GetFunction(lib, "lame_set_brate")
      lame_set_quality       = GetFunction(lib, "lame_set_quality")
      lame_set_VBR           = GetFunction(lib, "lame_set_VBR")
      lame_set_VBR_q         = GetFunction(lib, "lame_set_VBR_q")
      lame_encode_buffer     = GetFunction(lib, "lame_encode_buffer")
      lame_encode_buffer_interleaved = GetFunction(lib, "lame_encode_buffer_interleaved")
      lame_encode_buffer_float = GetFunction(lib, "lame_encode_buffer_float")
      lame_encode_buffer_interleaved_ieee_float = GetFunction(lib, "lame_encode_buffer_interleaved_ieee_float")
      lame_encode_flush      = GetFunction(lib, "lame_encode_flush")
      lame_mp3_tags_write    = GetFunction(lib, "lame_mp3_tags_write")
      ProcedureReturn lib
    EndIf
    ProcedureReturn #False
  EndProcedure
EndModule


CompilerIf #PB_Compiler_IsMainFile
  EnableExplicit
  
  UseModule LAME
  

  Define hLameDll = LoadLameAPI()
  If hLameDll = 0 : MessageRequester("Error", "LAME DLL not found!") : End : EndIf
  
  ; 1. LAME Instanz erstellen
  Define *gfp = lame_init()
  
  ; 2. Setup (Anpassen an deine DSP-Quelle)
  lame_set_in_samplerate(*gfp, 44100)
  lame_set_num_channels(*gfp, 2)
  lame_set_brate(*gfp, 192) ; 192 kbps Konstante Bitrate (CBR)
  
  ; 3. Parameter aktivieren
  lame_init_params(*gfp)
  
  ; --- HIER STARTET DEINE AUDIO-SCHLEIFE ---
  ; Nehmen wir an, du verarbeitest Blöcke von 4096 Samples
  Define.l sampleCount = 4096 
  Define.i mp3BufferSize = CalculateMP3BufferSize(sampleCount)
  Define *mp3Buffer = AllocateMemory(mp3BufferSize)
  
  ; [DEIN CODE]: 1. Hole PCM Daten in deine DSP
  ; [DEIN CODE]: 2. Berechne Filter / FFT / EQ in PureBasic auf deinen Buffern (*myLeftChannel, *myRightChannel)
  
  Define *myLeftChannel, *myRightChannel
  ; 3. Übergabe der manipulierten Floats an LAME
  Define bytesProduced
  bytesProduced = lame_encode_buffer_float(*gfp, *myLeftChannel, *myRightChannel, sampleCount, *mp3Buffer, mp3BufferSize)
  
  If bytesProduced > 0
    ; 'bytesProduced' gibt an, wie viele fertige MP3-Bytes im '*mp3Buffer' liegen.
    ; Diese Bytes kannst du jetzt direkt mit WriteData() in eine Datei schreiben!
  EndIf
  
  FreeMemory(*mp3Buffer)
  ; --- ENDE DER SCHLEIFE ---
  
  ; 4. Finalisieren (Wichtig, um den letzten Rest aus dem Encoder zu kratzen!)
  Define *flushBuffer = AllocateMemory(7200)
  Define.l flushBytes = lame_encode_flush(*gfp, *flushBuffer, 7200)
  If flushBytes > 0
    ; Auch diese restlichen Bytes in die Datei schreiben
  EndIf
  FreeMemory(*flushBuffer)
  
  ; 5. Schließen und Speicher freigeben
  lame_close(*gfp)
  CloseLibrary(hLameDll)
  
  
CompilerEndIf

; IDE Options = PureBasic 6.41 (Windows - x64)
; CursorPosition = 133
; Folding = -
; DPIAware
; CPU = 5