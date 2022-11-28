; ===========================================================================
;  FILE : Module_ECAD_DB.pb
;  NAME : Module Database [DB::]
;  DESC : Implements the ECAD Database Access
;  DESC : 
; ===========================================================================
;
; AUTHOR   :  Stefan Maag
; DATE     :  2022/05/10
; VERSION  :  1.0
; COMPILER :  PureBasic 5.73
; ===========================================================================
; ChangeLog: 
; ===========================================================================

;- ----------------------------------------------------------------------
;- Include Files
;- ----------------------------------------------------------------------

; XIncludeFile ""

DeclareModule DB
  ;- ----------------------------------------------------------------------
  ;- STRUCTURES for Recordsets
  ;- ----------------------------------------------------------------------
  
  
  ; Language dependent texts
  Structure TLStr   ;Type Language Strings
    DE.s            ; german
    EN.s            ; english
    FR.s            ; french
    NL.s            ; netherlands
    ES.s            ; spanisch
    PL.s            ; polish
    TR.s            ; turkish
  EndStructure
  
  ;- ADERN
  Structure TRec_ADERN
    FARBCODE.q
    ZAEHLER.q
    CODE.q
  EndStructure
  
  ;- BAUFORM
  Structure TRec_BAUFORM
    ID1.q
    ID2.q
    BEZEICHNUNG.s
    BASIS.s
    HILFSGERAET.s
    ANBAUORT.s
    SUBKLASSE.q
    ANSCHLAGMITTEL.q
    HOEHE.d
    BREITE.d
    TIEFE.d
    DURCHMESSER.d
    MITTEX.d
    MITTEY.d
    AUFSCHNAPPLINIE.d
    KONTAKTE.s
    ANSCHLUESSE.s
    TEXT.s
  EndStructure
  
  ;- COMM
  Structure TRec_COMM
    BENUTZER.s
    COMPUTER.s
    TABELLE.q
    AKTION.q
    ZEIT.q
    ID1.q
    ID2.q
    ID3.q
    ID4.q
  EndStructure
  
  ;- EINZLGER
  Structure TRec_EINZLGER
    ID.q
    HERSTELLER.q
    TYPENBEZEICHNUNG.s
    HILFSGERAET.s
    LAGERNUMMER.s
    LIEFERANT.q
    BESTELLNUMMER.s
    BASIS.s
    LISTENPREIS.q
    RABATT.q
    EINKAUFSPREIS.q
    GEMEINKOSTEN.q
    VERKAUFSPREIS.q
    GUELTIGKEIT.q
    VERPACKUNGSEINHEIT.s
    LAGERBESTAND_IST.q
    LAGERBESTAND_MIN.q
    VERFUEGBARKEIT.q
    SUBKLASSE.q
    MINDESTKRITERIUM.q
    KONTAKTE.s
    SPULENSPANNUNG.q
    SPULEAC.s
    SCHALTSTROM.q
    SCHALTLEISTUNG.d
    VERLUSTLEISTUNG.d
    HALTELEISTUNG.d
    HOEHE.d
    BREITE.d
    TIEFE.d
    AUFSCHNAPPLINIE.d
    SICHERHEITSABSTAND.d
    EINBAUZEIT.d
    GEWICHT.d
    ANBAUORT.s
    BAUFORM.s
    BAUGROESSE.s
    STAFFELGRENZE1.q
    RABATTSTAFFEL1.q
    STAFFELGRENZE2.q
    RABATTSTAFFEL2.q
    STAFFELGRENZE3.q
    RABATTSTAFFEL3.q
    WAEHRUNG.s
    FREQUENZMIN.d
    FREQUENZMAX.d
    FREQUENZNENN.d
    FARBE1.q
    FARBE2.q
    FARBE3.q
    DURCHMESSER.d
    MITTEX.d
    MITTEY.d
    ARTIKELNAME.s
    BILDTYP.s
    BILD.i
    ANSCHLAGMITTEL.q
    URL.s
    TEXT.s
    ANSCHLUESSE.s
    ANZSCHIENE.q
    BAUFORMID1.q
    BAUFORMID2.q
    SERIE.q
    ANTIQUE.q
  EndStructure
  
  ;- ETIKETT
  Structure TRec_ETIKETT
    ID.q
    ANZAHLX.q
    ANZAHLY.q
    BEZEICHNUNG.s
    RANDOBEN.d
    RANDLINKS.d
    ETIKETTENBREITE.d
    ETIKETTENHOEHE.d
    ABSTANDX.d
    ABSTANDY.d
    ENDLOS.s
    ZEILEN.q
    FONTNAME.s
    FONTHOEHE.q
    FONTSTYLE.q
  EndStructure
  
  ;- EXAKTKRIT
  Structure TRec_EXAKTKRIT
    ID.q
    SUBKLASSEID.q
    EXAKTKRITERIUM.s
    TXT.TLStr         ; Language dependent texts [DE, EN, NL, ES, TR]
  EndStructure
  
  ;- FARBCODE
  Structure TRec_FARBCODE
    ID.q
    FARBCODE_D.s
    FARBCODE_EN.s
    FARBCODE_NL.s
    FARBCODE_S.s
    FARBCODE_TR.s
    TXT.TLStr         ; Language dependent texts [DE, EN, NL, ES, TR]
  EndStructure
  
  ;- GERKLASS
  Structure TRec_GERKLASS
    HAUPTKLASSE.q
    TXT.TLStr         ; Language dependent texts [DE, EN, NL, ES, TR]
  EndStructure
  
  ;- GERTAB
  Structure TRec_GERTAB
    ID.q
    SUBKLASSE.q
    HAUPTKLASSE.q
    EBN_BMK.s
    TXT.TLStr         ; Language dependent texts [DE, EN, NL, ES, TR]
    BMK.TLStr         ; Language dependent texts [DE, EN, NL, ES, TR]
  EndStructure
  
  ;- HERSTTAB
  Structure TRec_HERSTTAB
    ID.q
    KUERZEL.s
    FIRMA.s
    ANSPRECHPARTNER.s
    POSTFACH.s
    STRASSE.s
    STAAT.s
    POSTLEITZAHL.s
    ORT.s
    VORWAHL.s
    RUFNUMMER.s
    DURCHWAHL.s
    TEXT.s
    FAXNUMMER.s
    CADCABELBEZ.s
  EndStructure
  
  ;- IMPORTEURE
  Structure TRec_IMPORTEURE
    ID.q
    NAME.s
  EndStructure
  
  ;- IMPORTKLASSEN
  Structure TRec_IMPORTKLASSEN
    ID.q
    IMPORTEUR.q
    KLASSE.q
    KLASSENEU.q
    HILFSGERAET.s
    SUBKLASSE.q
    BEZEICHNUNG.s
  EndStructure
  
  ;- KABEL
  Structure TRec_KABEL
    KABELTYP.q
    ID.q
    AUSSENDURCHMESSER.d
    GEWICHT.d
    KUPFERZAHL.d
    BIEGERADIUS.d
    TXT.TLStr         ; Language dependent texts [DE, EN, NL, ES, TR]
    HERSTELLER.s
    BESTELLNUMMER.s
  EndStructure
  
  ;- KABELBUENDEL
  Structure TRec_KABELBUENDEL
    KABEL.q
    ID.q
    BUENDELCODE.s
    ADERNZAHL.q
    FARBCODE.q
    PAARE.q
    BETRIEBSSPANNUNG.q
    QUERSCHNITT.q
    PE.q
    SCHIRM.s
    TXT.TLStr         ; Language dependent texts [DE, EN, NL, ES, TR]
    AWG.s
  EndStructure
  
  ;- KABELTYP
  Structure TRec_KABELTYP
    ID.q
    KABELTYP.s
    TEMP_FEST_MIN.q
    TEMP_FEST_MAX.q
    TEMP_BEWEGT_MIN.q
    TEMP_BEWEGT_MAX.q
    ANTIQUE.q
  EndStructure
  
  ;- LIEFER
  Structure TRec_LIEFER
    ID.q
    KUERZEL.s
    FIRMA.s
    ANSPRECHPARTNER.s
    POSTFACH.s
    STRASSE.s
    STAAT.s
    POSTLEITZAHL.s
    ORT.s
    VORWAHL.s
    RUFNUMMER.s
    DURCHWAHL.s
    FAXNUMMER.s
    MINDESTBESTELLWERT.q
    TEXT.s
    ZAHLUNGSBEDINGUNGEN.s
  EndStructure
  
  ;- MINKRIT
  Structure TRec_MINKRIT
    ID.q
    EXAKTKRITERIUM.q
    MINDESTKRITERIUM.q
    TXT.TLStr         ; Language dependent texts [DE, EN, NL, ES, TR]
  EndStructure
  
  ;- SERIEN
  Structure TRec_SERIEN
    ID.q
    HERSTELLER.q
    NAME.s
    GERKLASS.q
    ANTIQUE.q
  EndStructure
  
  ;- VNSKLASSE
  Structure TRec_VNSKLASSE
    ID.q
    PRODUKT.s
    NAME.s
    ART.s
    KLASSE.q
    SUBKLASSE.q
  EndStructure
  
  ;- ZUSGER_0
  Structure TRec_ZUSGER_0
    HAUPTELEMENT.q
    MINDESTKRITERIUM.q
    KOMBINATION.q
    TEXT.s
  EndStructure
  
  ;- ZUSGER_1
  Structure TRec_ZUSGER_1
    KOMBINATION.q
    ZAEHLER.q
    HILFSELEMENT.q
    ANZAHL.q
  EndStructure
  
  ;- ----------------------------------------------------------------------
  ;- STRUCTERS for Gadgets 
  ;- ----------------------------------------------------------------------
  ;- ADERN
  Structure TGadgetEx
    ID.i
    Name.s 
    Tag.s
  EndStructure
  
  Structure TGadgets_ADERN ; Structure for Recordset Gadgets
    lbl_FARBCODE.i
    txt_FARBCODE.i
    lbl_ZAEHLER.i
    txt_ZAEHLER.i
    lbl_CODE.i
    txt_CODE.i
  EndStructure
  Global Gadgets_ADERN.TGadgets_ADERN
  
  ;- BAUFORM
  Structure TGadgets_BAUFORM ; Structure for Recordset Gadgets
    lbl_ID1.i
    txt_ID1.i
    lbl_ID2.i
    txt_ID2.i
    lbl_BEZEICHNUNG.i
    txt_BEZEICHNUNG.i
    lbl_BASIS.i
    txt_BASIS.i
    lbl_HILFSGERAET.i
    txt_HILFSGERAET.i
    lbl_ANBAUORT.i
    txt_ANBAUORT.i
    lbl_SUBKLASSE.i
    txt_SUBKLASSE.i
    lbl_ANSCHLAGMITTEL.i
    txt_ANSCHLAGMITTEL.i
    lbl_HOEHE.i
    txt_HOEHE.i
    lbl_BREITE.i
    txt_BREITE.i
    lbl_TIEFE.i
    txt_TIEFE.i
    lbl_DURCHMESSER.i
    txt_DURCHMESSER.i
    lbl_MITTEX.i
    txt_MITTEX.i
    lbl_MITTEY.i
    txt_MITTEY.i
    lbl_AUFSCHNAPPLINIE.i
    txt_AUFSCHNAPPLINIE.i
    lbl_KONTAKTE.i
    txt_KONTAKTE.i
    lbl_ANSCHLUESSE.i
    txt_ANSCHLUESSE.i
    lbl_TEXT.i
    txt_TEXT.i
  EndStructure
  Global Gadgets_BAUFORM.TGadgets_BAUFORM
  
  ;- COMM
  Structure TGadgets_COMM ; Structure for Recordset Gadgets
    lbl_BENUTZER.i
    txt_BENUTZER.i
    lbl_COMPUTER.i
    txt_COMPUTER.i
    lbl_TABELLE.i
    txt_TABELLE.i
    lbl_AKTION.i
    txt_AKTION.i
    lbl_ZEIT.i
    txt_ZEIT.i
    lbl_ID1.i
    txt_ID1.i
    lbl_ID2.i
    txt_ID2.i
    lbl_ID3.i
    txt_ID3.i
    lbl_ID4.i
    txt_ID4.i
  EndStructure
  Global Gadgets_COMM.TGadgets_COMM
  
  ;- EINZLGER
  Structure TGadgets_EINZLGER ; Structure for Recordset Gadgets
    lbl_ID.i
    txt_ID.i
    lbl_HERSTELLER.i
    txt_HERSTELLER.i
    lbl_TYPENBEZEICHNUNG.i
    txt_TYPENBEZEICHNUNG.i
    lbl_HILFSGERAET.i
    txt_HILFSGERAET.i
    lbl_LAGERNUMMER.i
    txt_LAGERNUMMER.i
    lbl_LIEFERANT.i
    txt_LIEFERANT.i
    lbl_BESTELLNUMMER.i
    txt_BESTELLNUMMER.i
    lbl_BASIS.i
    txt_BASIS.i
    lbl_LISTENPREIS.i
    txt_LISTENPREIS.i
    lbl_RABATT.i
    txt_RABATT.i
    lbl_EINKAUFSPREIS.i
    txt_EINKAUFSPREIS.i
    lbl_GEMEINKOSTEN.i
    txt_GEMEINKOSTEN.i
    lbl_VERKAUFSPREIS.i
    txt_VERKAUFSPREIS.i
    lbl_GUELTIGKEIT.i
    txt_GUELTIGKEIT.i
    lbl_VERPACKUNGSEINHEIT.i
    txt_VERPACKUNGSEINHEIT.i
    lbl_LAGERBESTAND_IST.i
    txt_LAGERBESTAND_IST.i
    lbl_LAGERBESTAND_MIN.i
    txt_LAGERBESTAND_MIN.i
    lbl_VERFUEGBARKEIT.i
    txt_VERFUEGBARKEIT.i
    lbl_SUBKLASSE.i
    txt_SUBKLASSE.i
    lbl_MINDESTKRITERIUM.i
    txt_MINDESTKRITERIUM.i
    lbl_KONTAKTE.i
    txt_KONTAKTE.i
    lbl_SPULENSPANNUNG.i
    txt_SPULENSPANNUNG.i
    lbl_SPULEAC.i
    txt_SPULEAC.i
    lbl_SCHALTSTROM.i
    txt_SCHALTSTROM.i
    lbl_SCHALTLEISTUNG.i
    txt_SCHALTLEISTUNG.i
    lbl_VERLUSTLEISTUNG.i
    txt_VERLUSTLEISTUNG.i
    lbl_HALTELEISTUNG.i
    txt_HALTELEISTUNG.i
    lbl_HOEHE.i
    txt_HOEHE.i
    lbl_BREITE.i
    txt_BREITE.i
    lbl_TIEFE.i
    txt_TIEFE.i
    lbl_AUFSCHNAPPLINIE.i
    txt_AUFSCHNAPPLINIE.i
    lbl_SICHERHEITSABSTAND.i
    txt_SICHERHEITSABSTAND.i
    lbl_EINBAUZEIT.i
    txt_EINBAUZEIT.i
    lbl_GEWICHT.i
    txt_GEWICHT.i
    lbl_ANBAUORT.i
    txt_ANBAUORT.i
    lbl_BAUFORM.i
    txt_BAUFORM.i
    lbl_BAUGROESSE.i
    txt_BAUGROESSE.i
    lbl_STAFFELGRENZE1.i
    txt_STAFFELGRENZE1.i
    lbl_RABATTSTAFFEL1.i
    txt_RABATTSTAFFEL1.i
    lbl_STAFFELGRENZE2.i
    txt_STAFFELGRENZE2.i
    lbl_RABATTSTAFFEL2.i
    txt_RABATTSTAFFEL2.i
    lbl_STAFFELGRENZE3.i
    txt_STAFFELGRENZE3.i
    lbl_RABATTSTAFFEL3.i
    txt_RABATTSTAFFEL3.i
    lbl_WAEHRUNG.i
    txt_WAEHRUNG.i
    lbl_FREQUENZMIN.i
    txt_FREQUENZMIN.i
    lbl_FREQUENZMAX.i
    txt_FREQUENZMAX.i
    lbl_FREQUENZNENN.i
    txt_FREQUENZNENN.i
    lbl_FARBE1.i
    txt_FARBE1.i
    lbl_FARBE2.i
    txt_FARBE2.i
    lbl_FARBE3.i
    txt_FARBE3.i
    lbl_DURCHMESSER.i
    txt_DURCHMESSER.i
    lbl_MITTEX.i
    txt_MITTEX.i
    lbl_MITTEY.i
    txt_MITTEY.i
    lbl_ARTIKELNAME.i
    txt_ARTIKELNAME.i
    lbl_BILDTYP.i
    txt_BILDTYP.i
    lbl_BILD.i
    txt_BILD.i
    lbl_ANSCHLAGMITTEL.i
    txt_ANSCHLAGMITTEL.i
    lbl_URL.i
    txt_URL.i
    lbl_TEXT.i
    txt_TEXT.i
    lbl_ANSCHLUESSE.i
    txt_ANSCHLUESSE.i
    lbl_ANZSCHIENE.i
    txt_ANZSCHIENE.i
    lbl_BAUFORMID1.i
    txt_BAUFORMID1.i
    lbl_BAUFORMID2.i
    txt_BAUFORMID2.i
    lbl_SERIE.i
    txt_SERIE.i
    lbl_ANTIQUE.i
    txt_ANTIQUE.i
  EndStructure
  Global Gadgets_EINZLGER.TGadgets_EINZLGER
  
  ;- ETIKETT
  Structure TGadgets_ETIKETT ; Structure for Recordset Gadgets
    lbl_ID.i
    txt_ID.i
    lbl_ANZAHLX.i
    txt_ANZAHLX.i
    lbl_ANZAHLY.i
    txt_ANZAHLY.i
    lbl_BEZEICHNUNG.i
    txt_BEZEICHNUNG.i
    lbl_RANDOBEN.i
    txt_RANDOBEN.i
    lbl_RANDLINKS.i
    txt_RANDLINKS.i
    lbl_ETIKETTENBREITE.i
    txt_ETIKETTENBREITE.i
    lbl_ETIKETTENHOEHE.i
    txt_ETIKETTENHOEHE.i
    lbl_ABSTANDX.i
    txt_ABSTANDX.i
    lbl_ABSTANDY.i
    txt_ABSTANDY.i
    lbl_ENDLOS.i
    txt_ENDLOS.i
    lbl_ZEILEN.i
    txt_ZEILEN.i
    lbl_FONTNAME.i
    txt_FONTNAME.i
    lbl_FONTHOEHE.i
    txt_FONTHOEHE.i
    lbl_FONTSTYLE.i
    txt_FONTSTYLE.i
  EndStructure
  Global Gadgets_ETIKETT.TGadgets_ETIKETT
  
  ;- EXAKTKRIT
  Structure TGadgets_EXAKTKRIT ; Structure for Recordset Gadgets
    lbl_ID.i
    txt_ID.i
    lbl_SUBKLASSEID.i
    txt_SUBKLASSEID.i
    lbl_EXAKTKRITERIUM.i
    txt_EXAKTKRITERIUM.i
    lbl_DE.i
    txt_DE.i
    lbl_EN.i
    txt_EN.i
    lbl_FR.i
    txt_FR.i
    lbl_NL.i
    txt_NL.i
    lbl_ES.i
    txt_ES.i
    lbl_PL.i
    txt_PL.i
    lbl_TR.i
    txt_TR.i
  EndStructure
  Global Gadgets_EXAKTKRIT.TGadgets_EXAKTKRIT
  
  ;- FARBCODE
  Structure TGadgets_FARBCODE ; Structure for Recordset Gadgets
    lbl_ID.i
    txt_ID.i
    lbl_FARBCODE_DE.i
    txt_FARBCODE_DE.i
    lbl_FARBCODE_EN.i
    txt_FARBCODE_EN.i
    lbl_FARBCODE_NL.i
    txt_FARBCODE_NL.i
    lbl_FARBCODE_ES.i
    txt_FARBCODE_ES.i
    lbl_FARBCODE_TR.i
    txt_FARBCODE_TR.i
    lbl_DE.i
    txt_DE.i
    lbl_EN.i
    txt_EN.i
    lbl_NL.i
    txt_NL.i
    lbl_ES.i
    txt_ES.i
    lbl_TR.i
    txt_TR.i
  EndStructure
  Global Gadgets_FARBCODE.TGadgets_FARBCODE
  
  ;- GERKLASS
  Structure TGadgets_GERKLASS ; Structure for Recordset Gadgets
    lbl_HAUPTKLASSE.i
    txt_HAUPTKLASSE.i
    lbl_DE.i
    txt_DE.i
    lbl_EN.i
    txt_EN.i
    lbl_FR.i
    txt_FR.i
    lbl_NL.i
    txt_NL.i
    lbl_ES.i
    txt_ES.i
    lbl_PL.i
    txt_PL.i
    lbl_TR.i
    txt_TR.i
  EndStructure
  Global Gadgets_GERKLASS.TGadgets_GERKLASS
  
  ;- GERTAB
  Structure TGadgets_GERTAB ; Structure for Recordset Gadgets
    lbl_ID.i
    txt_ID.i
    lbl_SUBKLASSE.i
    txt_SUBKLASSE.i
    lbl_HAUPTKLASSE.i
    txt_HAUPTKLASSE.i
    lbl_EBN_BMK.i
    txt_EBN_BMK.i
    lbl_DE.i
    txt_DE.i
    lbl_EN.i
    txt_EN.i
    lbl_FR.i
    txt_FR.i
    lbl_NL.i
    txt_NL.i
    lbl_ES.i
    txt_ES.i
    lbl_PL.i
    txt_PL.i
    lbl_TR.i
    txt_TR.i
    lbl_BMK_DE.i
    txt_BMK_DE.i
    lbl_BMK_EN.i
    txt_BMK_EN.i
    lbl_BMK_FR.i
    txt_BMK_FR.i
    lbl_BMK_NL.i
    txt_BMK_NL.i
    lbl_BMK_ES.i
    txt_BMK_ES.i
    lbl_BMK_PL.i
    txt_BMK_PL.i
    lbl_BMK_TR.i
    txt_BMK_TR.i
  EndStructure
  Global Gadgets_GERTAB.TGadgets_GERTAB
  
  ;- HERSTTAB
  Structure TGadgets_HERSTTAB ; Structure for Recordset Gadgets
    lbl_ID.i
    txt_ID.i
    lbl_KUERZEL.i
    txt_KUERZEL.i
    lbl_FIRMA.i
    txt_FIRMA.i
    lbl_ANSPRECHPARTNER.i
    txt_ANSPRECHPARTNER.i
    lbl_POSTFACH.i
    txt_POSTFACH.i
    lbl_STRASSE.i
    txt_STRASSE.i
    lbl_STAAT.i
    txt_STAAT.i
    lbl_POSTLEITZAHL.i
    txt_POSTLEITZAHL.i
    lbl_ORT.i
    txt_ORT.i
    lbl_VORWAHL.i
    txt_VORWAHL.i
    lbl_RUFNUMMER.i
    txt_RUFNUMMER.i
    lbl_DURCHWAHL.i
    txt_DURCHWAHL.i
    lbl_TEXT.i
    txt_TEXT.i
    lbl_FAXNUMMER.i
    txt_FAXNUMMER.i
    lbl_CADCABELBEZ.i
    txt_CADCABELBEZ.i
  EndStructure
  Global Gadgets_HERSTTAB.TGadgets_HERSTTAB
  
  ;- IMPORTEURE
  Structure TGadgets_IMPORTEURE ; Structure for Recordset Gadgets
    lbl_ID.i
    txt_ID.i
    lbl_NAME.i
    txt_NAME.i
  EndStructure
  Global Gadgets_IMPORTEURE.TGadgets_IMPORTEURE
  
  ;- IMPORTKLASSEN
  Structure TGadgets_IMPORTKLASSEN ; Structure for Recordset Gadgets
    lbl_ID.i
    txt_ID.i
    lbl_IMPORTEUR.i
    txt_IMPORTEUR.i
    lbl_KLASSE.i
    txt_KLASSE.i
    lbl_KLASSENEU.i
    txt_KLASSENEU.i
    lbl_HILFSGERAET.i
    txt_HILFSGERAET.i
    lbl_SUBKLASSE.i
    txt_SUBKLASSE.i
    lbl_BEZEICHNUNG.i
    txt_BEZEICHNUNG.i
  EndStructure
  Global Gadgets_IMPORTKLASSEN.TGadgets_IMPORTKLASSEN
  
  ;- KABEL
  Structure TGadgets_KABEL ; Structure for Recordset Gadgets
    lbl_KABELTYP.i
    txt_KABELTYP.i
    lbl_ID.i
    txt_ID.i
    lbl_AUSSENDURCHMESSER.i
    txt_AUSSENDURCHMESSER.i
    lbl_GEWICHT.i
    txt_GEWICHT.i
    lbl_KUPFERZAHL.i
    txt_KUPFERZAHL.i
    lbl_BIEGERADIUS.i
    txt_BIEGERADIUS.i
    lbl_DE.i
    txt_DE.i
    lbl_EN.i
    txt_EN.i
    lbl_NL.i
    txt_NL.i
    lbl_ES.i
    txt_ES.i
    lbl_TR.i
    txt_TR.i
    lbl_HERSTELLER.i
    txt_HERSTELLER.i
    lbl_BESTELLNUMMER.i
    txt_BESTELLNUMMER.i
  EndStructure
  Global Gadgets_KABEL.TGadgets_KABEL
  
  ;- KABELBUENDEL
  Structure TGadgets_KABELBUENDEL ; Structure for Recordset Gadgets
    lbl_KABEL.i
    txt_KABEL.i
    lbl_ID.i
    txt_ID.i
    lbl_BUENDELCODE.i
    txt_BUENDELCODE.i
    lbl_ADERNZAHL.i
    txt_ADERNZAHL.i
    lbl_FARBCODE.i
    txt_FARBCODE.i
    lbl_PAARE.i
    txt_PAARE.i
    lbl_BETRIEBSSPANNUNG.i
    txt_BETRIEBSSPANNUNG.i
    lbl_QUERSCHNITT.i
    txt_QUERSCHNITT.i
    lbl_PE.i
    txt_PE.i
    lbl_SCHIRM.i
    txt_SCHIRM.i
    lbl_DE.i
    txt_DE.i
    lbl_EN.i
    txt_EN.i
    lbl_NL.i
    txt_NL.i
    lbl_ES.i
    txt_ES.i
    lbl_TR.i
    txt_TR.i
    lbl_AWG.i
    txt_AWG.i
  EndStructure
  Global Gadgets_KABELBUENDEL.TGadgets_KABELBUENDEL
  
  ;- KABELTYP
  Structure TGadgets_KABELTYP ; Structure for Recordset Gadgets
    lbl_ID.i
    txt_ID.i
    lbl_KABELTYP.i
    txt_KABELTYP.i
    lbl_TEMP_FEST_MIN.i
    txt_TEMP_FEST_MIN.i
    lbl_TEMP_FEST_MAX.i
    txt_TEMP_FEST_MAX.i
    lbl_TEMP_BEWEGT_MIN.i
    txt_TEMP_BEWEGT_MIN.i
    lbl_TEMP_BEWEGT_MAX.i
    txt_TEMP_BEWEGT_MAX.i
    lbl_ANTIQUE.i
    txt_ANTIQUE.i
  EndStructure
  Global Gadgets_KABELTYP.TGadgets_KABELTYP
  
  ;- LIEFER
  Structure TGadgets_LIEFER ; Structure for Recordset Gadgets
    lbl_ID.i
    txt_ID.i
    lbl_KUERZEL.i
    txt_KUERZEL.i
    lbl_FIRMA.i
    txt_FIRMA.i
    lbl_ANSPRECHPARTNER.i
    txt_ANSPRECHPARTNER.i
    lbl_POSTFACH.i
    txt_POSTFACH.i
    lbl_STRASSE.i
    txt_STRASSE.i
    lbl_STAAT.i
    txt_STAAT.i
    lbl_POSTLEITZAHL.i
    txt_POSTLEITZAHL.i
    lbl_ORT.i
    txt_ORT.i
    lbl_VORWAHL.i
    txt_VORWAHL.i
    lbl_RUFNUMMER.i
    txt_RUFNUMMER.i
    lbl_DURCHWAHL.i
    txt_DURCHWAHL.i
    lbl_FAXNUMMER.i
    txt_FAXNUMMER.i
    lbl_MINDESTBESTELLWERT.i
    txt_MINDESTBESTELLWERT.i
    lbl_TEXT.i
    txt_TEXT.i
    lbl_ZAHLUNGSBEDINGUNGEN.i
    txt_ZAHLUNGSBEDINGUNGEN.i
  EndStructure
  Global Gadgets_LIEFER.TGadgets_LIEFER
  
  ;- MINKRIT
  Structure TGadgets_MINKRIT ; Structure for Recordset Gadgets
    lbl_ID.i
    txt_ID.i
    lbl_EXAKTKRITERIUM.i
    txt_EXAKTKRITERIUM.i
    lbl_MINDESTKRITERIUM.i
    txt_MINDESTKRITERIUM.i
    lbl_DE.i
    txt_DE.i
    lbl_EN.i
    txt_EN.i
    lbl_FR.i
    txt_FR.i
    lbl_NL.i
    txt_NL.i
    lbl_ES.i
    txt_ES.i
    lbl_PL.i
    txt_PL.i
    lbl_TR.i
    txt_TR.i
  EndStructure
  Global Gadgets_MINKRIT.TGadgets_MINKRIT
  
  ;- SERIEN
  Structure TGadgets_SERIEN ; Structure for Recordset Gadgets
    lbl_ID.i
    txt_ID.i
    lbl_HERSTELLER.i
    txt_HERSTELLER.i
    lbl_NAME.i
    txt_NAME.i
    lbl_GERKLASS.i
    txt_GERKLASS.i
    lbl_ANTIQUE.i
    txt_ANTIQUE.i
  EndStructure
  Global Gadgets_SERIEN.TGadgets_SERIEN
  
  ;- VNSKLASSE
  Structure TGadgets_VNSKLASSE ; Structure for Recordset Gadgets
    lbl_ID.i
    txt_ID.i
    lbl_PRODUKT.i
    txt_PRODUKT.i
    lbl_NAME.i
    txt_NAME.i
    lbl_ART.i
    txt_ART.i
    lbl_KLASSE.i
    txt_KLASSE.i
    lbl_SUBKLASSE.i
    txt_SUBKLASSE.i
  EndStructure
  Global Gadgets_VNSKLASSE.TGadgets_VNSKLASSE
  
  ;- ZUSGER_0
  Structure TGadgets_ZUSGER_0 ; Structure for Recordset Gadgets
    lbl_HAUPTELEMENT.i
    txt_HAUPTELEMENT.i
    lbl_MINDESTKRITERIUM.i
    txt_MINDESTKRITERIUM.i
    lbl_KOMBINATION.i
    txt_KOMBINATION.i
    lbl_TEXT.i
    txt_TEXT.i
  EndStructure
  Global Gadgets_ZUSGER_0.TGadgets_ZUSGER_0
  
  ;- ZUSGER_1
  Structure TGadgets_ZUSGER_1 ; Structure for Recordset Gadgets
    lbl_KOMBINATION.i
    txt_KOMBINATION.i
    lbl_ZAEHLER.i
    txt_ZAEHLER.i
    lbl_HILFSELEMENT.i
    txt_HILFSELEMENT.i
    lbl_ANZAHL.i
    txt_ANZAHL.i
  EndStructure
  
  Global Gadgets_ZUSGER_1.TGadgets_ZUSGER_1

EndDeclareModule

Module DB
  EnableExplicit

  ;- ----------------------------------------------------------------------
  ;- PROCEDURES ReadRec
  ;- ----------------------------------------------------------------------

  Procedure ReadRec_ADERN(hDB, sField.s, sVal.s, *Rec.TRec_ADERN)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from ADERN WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          \FARBCODE = GetDatabaseQuad(hdb, 0)
          \ZAEHLER = GetDatabaseQuad(hdb, 1)
          \CODE = GetDatabaseQuad(hdb, 2)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure ReadRec_BAUFORM(hDB, sField.s, sVal.s, *Rec.TRec_BAUFORM)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from BAUFORM WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          \ID1 = GetDatabaseQuad(hdb, 0)
          \ID2 = GetDatabaseQuad(hdb, 1)
          \BEZEICHNUNG = GetDatabaseString(hdb, 2)
          \BASIS = GetDatabaseString(hdb, 3)
          \HILFSGERAET = GetDatabaseString(hdb, 4)
          \ANBAUORT = GetDatabaseString(hdb, 5)
          \SUBKLASSE = GetDatabaseQuad(hdb, 6)
          \ANSCHLAGMITTEL = GetDatabaseQuad(hdb, 7)
          \HOEHE = GetDatabaseDouble(hdb, 8)
          \BREITE = GetDatabaseDouble(hdb, 9)
          \TIEFE = GetDatabaseDouble(hdb, 10)
          \DURCHMESSER = GetDatabaseDouble(hdb, 11)
          \MITTEX = GetDatabaseDouble(hdb, 12)
          \MITTEY = GetDatabaseDouble(hdb, 13)
          \AUFSCHNAPPLINIE = GetDatabaseDouble(hdb, 14)
          \KONTAKTE = GetDatabaseString(hdb, 15)
          \ANSCHLUESSE = GetDatabaseString(hdb, 16)
          \TEXT = GetDatabaseString(hdb, 17)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure ReadRec_COMM(hDB, sField.s, sVal.s, *Rec.TRec_COMM)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from COMM WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          \BENUTZER = GetDatabaseString(hdb, 0)
          \COMPUTER = GetDatabaseString(hdb, 1)
          \TABELLE = GetDatabaseQuad(hdb, 2)
          \AKTION = GetDatabaseQuad(hdb, 3)
          \ZEIT = GetDatabaseQuad(hdb, 4)
          \ID1 = GetDatabaseQuad(hdb, 5)
          \ID2 = GetDatabaseQuad(hdb, 6)
          \ID3 = GetDatabaseQuad(hdb, 7)
          \ID4 = GetDatabaseQuad(hdb, 8)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure ReadRec_EINZLGER(hDB, sField.s, sVal.s, *Rec.TRec_EINZLGER)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from EINZLGER WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          \ID = GetDatabaseQuad(hdb, 0)
          \HERSTELLER = GetDatabaseQuad(hdb, 1)
          \TYPENBEZEICHNUNG = GetDatabaseString(hdb, 2)
          \HILFSGERAET = GetDatabaseString(hdb, 3)
          \LAGERNUMMER = GetDatabaseString(hdb, 4)
          \LIEFERANT = GetDatabaseQuad(hdb, 5)
          \BESTELLNUMMER = GetDatabaseString(hdb, 6)
          \BASIS = GetDatabaseString(hdb, 7)
          \LISTENPREIS = GetDatabaseQuad(hdb, 8)
          \RABATT = GetDatabaseQuad(hdb, 9)
          \EINKAUFSPREIS = GetDatabaseQuad(hdb, 10)
          \GEMEINKOSTEN = GetDatabaseQuad(hdb, 11)
          \VERKAUFSPREIS = GetDatabaseQuad(hdb, 12)
          \GUELTIGKEIT = GetDatabaseQuad(hdb, 13)
          \VERPACKUNGSEINHEIT = GetDatabaseString(hdb, 14)
          \LAGERBESTAND_IST = GetDatabaseQuad(hdb, 15)
          \LAGERBESTAND_MIN = GetDatabaseQuad(hdb, 16)
          \VERFUEGBARKEIT = GetDatabaseQuad(hdb, 17)
          \SUBKLASSE = GetDatabaseQuad(hdb, 18)
          \MINDESTKRITERIUM = GetDatabaseQuad(hdb, 19)
          \KONTAKTE = GetDatabaseString(hdb, 20)
          \SPULENSPANNUNG = GetDatabaseQuad(hdb, 21)
          \SPULEAC = GetDatabaseString(hdb, 22)
          \SCHALTSTROM = GetDatabaseQuad(hdb, 23)
          \SCHALTLEISTUNG = GetDatabaseDouble(hdb, 24)
          \VERLUSTLEISTUNG = GetDatabaseDouble(hdb, 25)
          \HALTELEISTUNG = GetDatabaseDouble(hdb, 26)
          \HOEHE = GetDatabaseDouble(hdb, 27)
          \BREITE = GetDatabaseDouble(hdb, 28)
          \TIEFE = GetDatabaseDouble(hdb, 29)
          \AUFSCHNAPPLINIE = GetDatabaseDouble(hdb, 30)
          \SICHERHEITSABSTAND = GetDatabaseDouble(hdb, 31)
          \EINBAUZEIT = GetDatabaseDouble(hdb, 32)
          \GEWICHT = GetDatabaseDouble(hdb, 33)
          \ANBAUORT = GetDatabaseString(hdb, 34)
          \BAUFORM = GetDatabaseString(hdb, 35)
          \BAUGROESSE = GetDatabaseString(hdb, 36)
          \STAFFELGRENZE1 = GetDatabaseQuad(hdb, 37)
          \RABATTSTAFFEL1 = GetDatabaseQuad(hdb, 38)
          \STAFFELGRENZE2 = GetDatabaseQuad(hdb, 39)
          \RABATTSTAFFEL2 = GetDatabaseQuad(hdb, 40)
          \STAFFELGRENZE3 = GetDatabaseQuad(hdb, 41)
          \RABATTSTAFFEL3 = GetDatabaseQuad(hdb, 42)
          \WAEHRUNG = GetDatabaseString(hdb, 43)
          \FREQUENZMIN = GetDatabaseDouble(hdb, 44)
          \FREQUENZMAX = GetDatabaseDouble(hdb, 45)
          \FREQUENZNENN = GetDatabaseDouble(hdb, 46)
          \FARBE1 = GetDatabaseQuad(hdb, 47)
          \FARBE2 = GetDatabaseQuad(hdb, 48)
          \FARBE3 = GetDatabaseQuad(hdb, 49)
          \DURCHMESSER = GetDatabaseDouble(hdb, 50)
          \MITTEX = GetDatabaseDouble(hdb, 51)
          \MITTEY = GetDatabaseDouble(hdb, 52)
          \ARTIKELNAME = GetDatabaseString(hdb, 53)
          \BILDTYP = GetDatabaseString(hdb, 54)
          \BILD = GetDatabaseQuad(hdb, 55)
          \ANSCHLAGMITTEL = GetDatabaseQuad(hdb, 56)
          \URL = GetDatabaseString(hdb, 57)
          \TEXT = GetDatabaseString(hdb, 58)
          \ANSCHLUESSE = GetDatabaseString(hdb, 59)
          \ANZSCHIENE = GetDatabaseQuad(hdb, 60)
          \BAUFORMID1 = GetDatabaseQuad(hdb, 61)
          \BAUFORMID2 = GetDatabaseQuad(hdb, 62)
          \SERIE = GetDatabaseQuad(hdb, 63)
          \ANTIQUE = GetDatabaseQuad(hdb, 64)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure ReadRec_ETIKETT(hDB, sField.s, sVal.s, *Rec.TRec_ETIKETT)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from ETIKETT WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          \ID = GetDatabaseQuad(hdb, 0)
          \ANZAHLX = GetDatabaseQuad(hdb, 1)
          \ANZAHLY = GetDatabaseQuad(hdb, 2)
          \BEZEICHNUNG = GetDatabaseString(hdb, 3)
          \RANDOBEN = GetDatabaseDouble(hdb, 4)
          \RANDLINKS = GetDatabaseDouble(hdb, 5)
          \ETIKETTENBREITE = GetDatabaseDouble(hdb, 6)
          \ETIKETTENHOEHE = GetDatabaseDouble(hdb, 7)
          \ABSTANDX = GetDatabaseDouble(hdb, 8)
          \ABSTANDY = GetDatabaseDouble(hdb, 9)
          \ENDLOS = GetDatabaseString(hdb, 10)
          \ZEILEN = GetDatabaseQuad(hdb, 11)
          \FONTNAME = GetDatabaseString(hdb, 12)
          \FONTHOEHE = GetDatabaseQuad(hdb, 13)
          \FONTSTYLE = GetDatabaseQuad(hdb, 14)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure ReadRec_EXAKTKRIT(hDB, sField.s, sVal.s, *Rec.TRec_EXAKTKRIT)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from EXAKTKRIT WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          \ID = GetDatabaseQuad(hdb, 0)
          \SUBKLASSEID = GetDatabaseQuad(hdb, 1)
          \EXAKTKRITERIUM = GetDatabaseString(hdb, 2)
          \TXT\DE = GetDatabaseString(hdb, 3)
          \TXT\EN = GetDatabaseString(hdb, 4)
          \TXT\FR = GetDatabaseString(hdb, 5)
          \TXT\NL = GetDatabaseString(hdb, 6)
          \TXT\ES = GetDatabaseString(hdb, 7)
          \TXT\PL = GetDatabaseString(hdb, 8)
          \TXT\TR = GetDatabaseString(hdb, 9)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure ReadRec_FARBCODE(hDB, sField.s, sVal.s, *Rec.TRec_FARBCODE)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from FARBCODE WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          \ID = GetDatabaseQuad(hdb, 0)
          \FARBCODE_D = GetDatabaseString(hdb, 1)
          \FARBCODE_EN = GetDatabaseString(hdb, 2)
          \FARBCODE_NL = GetDatabaseString(hdb, 3)
          \FARBCODE_S = GetDatabaseString(hdb, 4)
          \FARBCODE_TR = GetDatabaseString(hdb, 5)
          \TXT\DE = GetDatabaseString(hdb, 6)
          \TXT\EN = GetDatabaseString(hdb, 7)
          \TXT\NL = GetDatabaseString(hdb, 8)
          \TXT\ES = GetDatabaseString(hdb, 9)
          \TXT\TR = GetDatabaseString(hdb, 10)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure ReadRec_GERKLASS(hDB, sField.s, sVal.s, *Rec.TRec_GERKLASS)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from GERKLASS WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          \HAUPTKLASSE = GetDatabaseQuad(hdb, 0)
          \TXT\DE = GetDatabaseString(hdb, 1)
          \TXT\EN = GetDatabaseString(hdb, 2)
          \TXT\FR = GetDatabaseString(hdb, 3)
          \TXT\NL = GetDatabaseString(hdb, 4)
          \TXT\ES = GetDatabaseString(hdb, 5)
          \TXT\PL = GetDatabaseString(hdb, 6)
          \TXT\TR = GetDatabaseString(hdb, 7)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure ReadRec_GERTAB(hDB, sField.s, sVal.s, *Rec.TRec_GERTAB)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from GERTAB WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          \ID = GetDatabaseQuad(hdb, 0)
          \SUBKLASSE = GetDatabaseQuad(hdb, 1)
          \HAUPTKLASSE = GetDatabaseQuad(hdb, 2)
          \EBN_BMK = GetDatabaseString(hdb, 3)
          \TXT\DE = GetDatabaseString(hdb, 4)
          \TXT\EN = GetDatabaseString(hdb, 5)
          \TXT\FR = GetDatabaseString(hdb, 6)
          \TXT\NL = GetDatabaseString(hdb, 7)
          \TXT\ES = GetDatabaseString(hdb, 8)
          \TXT\PL = GetDatabaseString(hdb, 9)
          \TXT\TR = GetDatabaseString(hdb, 10)
          \BMK\DE = GetDatabaseString(hdb, 11)
          \BMK\EN = GetDatabaseString(hdb, 12)
          \BMK\FR = GetDatabaseString(hdb, 13)
          \BMK\NL = GetDatabaseString(hdb, 14)
          \BMK\ES = GetDatabaseString(hdb, 15)
          \BMK\PL = GetDatabaseString(hdb, 16)
          \BMK\TR = GetDatabaseString(hdb, 17)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure ReadRec_HERSTTAB(hDB, sField.s, sVal.s, *Rec.TRec_HERSTTAB)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from HERSTTAB WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          \ID = GetDatabaseQuad(hdb, 0)
          \KUERZEL = GetDatabaseString(hdb, 1)
          \FIRMA = GetDatabaseString(hdb, 2)
          \ANSPRECHPARTNER = GetDatabaseString(hdb, 3)
          \POSTFACH = GetDatabaseString(hdb, 4)
          \STRASSE = GetDatabaseString(hdb, 5)
          \STAAT = GetDatabaseString(hdb, 6)
          \POSTLEITZAHL = GetDatabaseString(hdb, 7)
          \ORT = GetDatabaseString(hdb, 8)
          \VORWAHL = GetDatabaseString(hdb, 9)
          \RUFNUMMER = GetDatabaseString(hdb, 10)
          \DURCHWAHL = GetDatabaseString(hdb, 11)
          \TEXT = GetDatabaseString(hdb, 12)
          \FAXNUMMER = GetDatabaseString(hdb, 13)
          \CADCABELBEZ = GetDatabaseString(hdb, 14)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure ReadRec_IMPORTEURE(hDB, sField.s, sVal.s, *Rec.TRec_IMPORTEURE)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from IMPORTEURE WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          \ID = GetDatabaseQuad(hdb, 0)
          \NAME = GetDatabaseString(hdb, 1)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure ReadRec_IMPORTKLASSEN(hDB, sField.s, sVal.s, *Rec.TRec_IMPORTKLASSEN)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from IMPORTKLASSEN WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          \ID = GetDatabaseQuad(hdb, 0)
          \IMPORTEUR = GetDatabaseQuad(hdb, 1)
          \KLASSE = GetDatabaseQuad(hdb, 2)
          \KLASSENEU = GetDatabaseQuad(hdb, 3)
          \HILFSGERAET = GetDatabaseString(hdb, 4)
          \SUBKLASSE = GetDatabaseQuad(hdb, 5)
          \BEZEICHNUNG = GetDatabaseString(hdb, 6)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure ReadRec_KABEL(hDB, sField.s, sVal.s, *Rec.TRec_KABEL)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from KABEL WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          \KABELTYP = GetDatabaseQuad(hdb, 0)
          \ID = GetDatabaseQuad(hdb, 1)
          \AUSSENDURCHMESSER = GetDatabaseDouble(hdb, 2)
          \GEWICHT = GetDatabaseDouble(hdb, 3)
          \KUPFERZAHL = GetDatabaseDouble(hdb, 4)
          \BIEGERADIUS = GetDatabaseDouble(hdb, 5)
          \TXT\DE = GetDatabaseString(hdb, 6)
          \TXT\EN = GetDatabaseString(hdb, 7)
          \TXT\NL = GetDatabaseString(hdb, 8)
          \TXT\ES = GetDatabaseString(hdb, 9)
          \TXT\TR = GetDatabaseString(hdb, 10)
          \HERSTELLER = GetDatabaseString(hdb, 11)
          \BESTELLNUMMER = GetDatabaseString(hdb, 12)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure ReadRec_KABELBUENDEL(hDB, sField.s, sVal.s, *Rec.TRec_KABELBUENDEL)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from KABELBUENDEL WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          \KABEL = GetDatabaseQuad(hdb, 0)
          \ID = GetDatabaseQuad(hdb, 1)
          \BUENDELCODE = GetDatabaseString(hdb, 2)
          \ADERNZAHL = GetDatabaseQuad(hdb, 3)
          \FARBCODE = GetDatabaseQuad(hdb, 4)
          \PAARE = GetDatabaseQuad(hdb, 5)
          \BETRIEBSSPANNUNG = GetDatabaseQuad(hdb, 6)
          \QUERSCHNITT = GetDatabaseQuad(hdb, 7)
          \PE = GetDatabaseQuad(hdb, 8)
          \SCHIRM = GetDatabaseString(hdb, 9)
          \TXT\DE = GetDatabaseString(hdb, 10)
          \TXT\EN = GetDatabaseString(hdb, 11)
          \TXT\NL = GetDatabaseString(hdb, 12)
          \TXT\ES = GetDatabaseString(hdb, 13)
          \TXT\TR = GetDatabaseString(hdb, 14)
          \AWG = GetDatabaseString(hdb, 15)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure ReadRec_KABELTYP(hDB, sField.s, sVal.s, *Rec.TRec_KABELTYP)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from KABELTYP WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          \ID = GetDatabaseQuad(hdb, 0)
          \KABELTYP = GetDatabaseString(hdb, 1)
          \TEMP_FEST_MIN = GetDatabaseQuad(hdb, 2)
          \TEMP_FEST_MAX = GetDatabaseQuad(hdb, 3)
          \TEMP_BEWEGT_MIN = GetDatabaseQuad(hdb, 4)
          \TEMP_BEWEGT_MAX = GetDatabaseQuad(hdb, 5)
          \ANTIQUE = GetDatabaseQuad(hdb, 6)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure ReadRec_LIEFER(hDB, sField.s, sVal.s, *Rec.TRec_LIEFER)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from LIEFER WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          \ID = GetDatabaseQuad(hdb, 0)
          \KUERZEL = GetDatabaseString(hdb, 1)
          \FIRMA = GetDatabaseString(hdb, 2)
          \ANSPRECHPARTNER = GetDatabaseString(hdb, 3)
          \POSTFACH = GetDatabaseString(hdb, 4)
          \STRASSE = GetDatabaseString(hdb, 5)
          \STAAT = GetDatabaseString(hdb, 6)
          \POSTLEITZAHL = GetDatabaseString(hdb, 7)
          \ORT = GetDatabaseString(hdb, 8)
          \VORWAHL = GetDatabaseString(hdb, 9)
          \RUFNUMMER = GetDatabaseString(hdb, 10)
          \DURCHWAHL = GetDatabaseString(hdb, 11)
          \FAXNUMMER = GetDatabaseString(hdb, 12)
          \MINDESTBESTELLWERT = GetDatabaseQuad(hdb, 13)
          \TEXT = GetDatabaseString(hdb, 14)
          \ZAHLUNGSBEDINGUNGEN = GetDatabaseString(hdb, 15)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure ReadRec_MINKRIT(hDB, sField.s, sVal.s, *Rec.TRec_MINKRIT)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from MINKRIT WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          \ID = GetDatabaseQuad(hdb, 0)
          \EXAKTKRITERIUM = GetDatabaseQuad(hdb, 1)
          \MINDESTKRITERIUM = GetDatabaseQuad(hdb, 2)
          \TXT\DE = GetDatabaseString(hdb, 3)
          \TXT\EN = GetDatabaseString(hdb, 4)
          \TXT\FR = GetDatabaseString(hdb, 5)
          \TXT\NL = GetDatabaseString(hdb, 6)
          \TXT\ES = GetDatabaseString(hdb, 7)
          \TXT\PL = GetDatabaseString(hdb, 8)
          \TXT\TR = GetDatabaseString(hdb, 9)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure ReadRec_SERIEN(hDB, sField.s, sVal.s, *Rec.TRec_SERIEN)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from SERIEN WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          \ID = GetDatabaseQuad(hdb, 0)
          \HERSTELLER = GetDatabaseQuad(hdb, 1)
          \NAME = GetDatabaseString(hdb, 2)
          \GERKLASS = GetDatabaseQuad(hdb, 3)
          \ANTIQUE = GetDatabaseQuad(hdb, 4)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure ReadRec_VNSKLASSE(hDB, sField.s, sVal.s, *Rec.TRec_VNSKLASSE)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from VNSKLASSE WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          \ID = GetDatabaseQuad(hdb, 0)
          \PRODUKT = GetDatabaseString(hdb, 1)
          \NAME = GetDatabaseString(hdb, 2)
          \ART = GetDatabaseString(hdb, 3)
          \KLASSE = GetDatabaseQuad(hdb, 4)
          \SUBKLASSE = GetDatabaseQuad(hdb, 5)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure ReadRec_ZUSGER_0(hDB, sField.s, sVal.s, *Rec.TRec_ZUSGER_0)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from ZUSGER_0 WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          \HAUPTELEMENT = GetDatabaseQuad(hdb, 0)
          \MINDESTKRITERIUM = GetDatabaseQuad(hdb, 1)
          \KOMBINATION = GetDatabaseQuad(hdb, 2)
          \TEXT = GetDatabaseString(hdb, 3)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure ReadRec_ZUSGER_1(hDB, sField.s, sVal.s, *Rec.TRec_ZUSGER_1)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from ZUSGER_1 WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          \KOMBINATION = GetDatabaseQuad(hdb, 0)
          \ZAEHLER = GetDatabaseQuad(hdb, 1)
          \HILFSELEMENT = GetDatabaseQuad(hdb, 2)
          \ANZAHL = GetDatabaseQuad(hdb, 3)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- PROCEDURES WriteRec
  ;- ----------------------------------------------------------------------
  
  Procedure WriteRec_ADERN(hDB, sField.s, sVal.s, *Rec.TRec_ADERN)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from ADERN WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          SetDatabaseQuad(hdb, 0, *Rec\FARBCODE)
          SetDatabaseQuad(hdb, 1, *Rec\ZAEHLER)
          SetDatabaseQuad(hdb, 2, *Rec\CODE)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure WriteRec_BAUFORM(hDB, sField.s, sVal.s, *Rec.TRec_BAUFORM)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from BAUFORM WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          SetDatabaseQuad(hdb, 0, *Rec\ID1)
          SetDatabaseQuad(hdb, 1, *Rec\ID2)
          SetDatabaseString(hdb, 2, *Rec\BEZEICHNUNG)
          SetDatabaseString(hdb, 3, *Rec\BASIS)
          SetDatabaseString(hdb, 4, *Rec\HILFSGERAET)
          SetDatabaseString(hdb, 5, *Rec\ANBAUORT)
          SetDatabaseQuad(hdb, 6, *Rec\SUBKLASSE)
          SetDatabaseQuad(hdb, 7, *Rec\ANSCHLAGMITTEL)
          SetDatabaseDouble(hdb, 8, *Rec\HOEHE)
          SetDatabaseDouble(hdb, 9, *Rec\BREITE)
          SetDatabaseDouble(hdb, 10, *Rec\TIEFE)
          SetDatabaseDouble(hdb, 11, *Rec\DURCHMESSER)
          SetDatabaseDouble(hdb, 12, *Rec\MITTEX)
          SetDatabaseDouble(hdb, 13, *Rec\MITTEY)
          SetDatabaseDouble(hdb, 14, *Rec\AUFSCHNAPPLINIE)
          SetDatabaseString(hdb, 15, *Rec\KONTAKTE)
          SetDatabaseString(hdb, 16, *Rec\ANSCHLUESSE)
          SetDatabaseString(hdb, 17, *Rec\TEXT)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure WriteRec_COMM(hDB, sField.s, sVal.s, *Rec.TRec_COMM)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from COMM WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          SetDatabaseString(hdb, 0, *Rec\BENUTZER)
          SetDatabaseString(hdb, 1, *Rec\COMPUTER)
          SetDatabaseQuad(hdb, 2, *Rec\TABELLE)
          SetDatabaseQuad(hdb, 3, *Rec\AKTION)
          SetDatabaseQuad(hdb, 4, *Rec\ZEIT)
          SetDatabaseQuad(hdb, 5, *Rec\ID1)
          SetDatabaseQuad(hdb, 6, *Rec\ID2)
          SetDatabaseQuad(hdb, 7, *Rec\ID3)
          SetDatabaseQuad(hdb, 8, *Rec\ID4)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure WriteRec_EINZLGER(hDB, sField.s, sVal.s, *Rec.TRec_EINZLGER)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from EINZLGER WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          SetDatabaseQuad(hdb, 0, *Rec\ID)
          SetDatabaseQuad(hdb, 1, *Rec\HERSTELLER)
          SetDatabaseString(hdb, 2, *Rec\TYPENBEZEICHNUNG)
          SetDatabaseString(hdb, 3, *Rec\HILFSGERAET)
          SetDatabaseString(hdb, 4, *Rec\LAGERNUMMER)
          SetDatabaseQuad(hdb, 5, *Rec\LIEFERANT)
          SetDatabaseString(hdb, 6, *Rec\BESTELLNUMMER)
          SetDatabaseString(hdb, 7, *Rec\BASIS)
          SetDatabaseQuad(hdb, 8, *Rec\LISTENPREIS)
          SetDatabaseQuad(hdb, 9, *Rec\RABATT)
          SetDatabaseQuad(hdb, 10, *Rec\EINKAUFSPREIS)
          SetDatabaseQuad(hdb, 11, *Rec\GEMEINKOSTEN)
          SetDatabaseQuad(hdb, 12, *Rec\VERKAUFSPREIS)
          SetDatabaseQuad(hdb, 13, *Rec\GUELTIGKEIT)
          SetDatabaseString(hdb, 14, *Rec\VERPACKUNGSEINHEIT)
          SetDatabaseQuad(hdb, 15, *Rec\LAGERBESTAND_IST)
          SetDatabaseQuad(hdb, 16, *Rec\LAGERBESTAND_MIN)
          SetDatabaseQuad(hdb, 17, *Rec\VERFUEGBARKEIT)
          SetDatabaseQuad(hdb, 18, *Rec\SUBKLASSE)
          SetDatabaseQuad(hdb, 19, *Rec\MINDESTKRITERIUM)
          SetDatabaseString(hdb, 20, *Rec\KONTAKTE)
          SetDatabaseQuad(hdb, 21, *Rec\SPULENSPANNUNG)
          SetDatabaseString(hdb, 22, *Rec\SPULEAC)
          SetDatabaseQuad(hdb, 23, *Rec\SCHALTSTROM)
          SetDatabaseDouble(hdb, 24, *Rec\SCHALTLEISTUNG)
          SetDatabaseDouble(hdb, 25, *Rec\VERLUSTLEISTUNG)
          SetDatabaseDouble(hdb, 26, *Rec\HALTELEISTUNG)
          SetDatabaseDouble(hdb, 27, *Rec\HOEHE)
          SetDatabaseDouble(hdb, 28, *Rec\BREITE)
          SetDatabaseDouble(hdb, 29, *Rec\TIEFE)
          SetDatabaseDouble(hdb, 30, *Rec\AUFSCHNAPPLINIE)
          SetDatabaseDouble(hdb, 31, *Rec\SICHERHEITSABSTAND)
          SetDatabaseDouble(hdb, 32, *Rec\EINBAUZEIT)
          SetDatabaseDouble(hdb, 33, *Rec\GEWICHT)
          SetDatabaseString(hdb, 34, *Rec\ANBAUORT)
          SetDatabaseString(hdb, 35, *Rec\BAUFORM)
          SetDatabaseString(hdb, 36, *Rec\BAUGROESSE)
          SetDatabaseQuad(hdb, 37, *Rec\STAFFELGRENZE1)
          SetDatabaseQuad(hdb, 38, *Rec\RABATTSTAFFEL1)
          SetDatabaseQuad(hdb, 39, *Rec\STAFFELGRENZE2)
          SetDatabaseQuad(hdb, 40, *Rec\RABATTSTAFFEL2)
          SetDatabaseQuad(hdb, 41, *Rec\STAFFELGRENZE3)
          SetDatabaseQuad(hdb, 42, *Rec\RABATTSTAFFEL3)
          SetDatabaseString(hdb, 43, *Rec\WAEHRUNG)
          SetDatabaseDouble(hdb, 44, *Rec\FREQUENZMIN)
          SetDatabaseDouble(hdb, 45, *Rec\FREQUENZMAX)
          SetDatabaseDouble(hdb, 46, *Rec\FREQUENZNENN)
          SetDatabaseQuad(hdb, 47, *Rec\FARBE1)
          SetDatabaseQuad(hdb, 48, *Rec\FARBE2)
          SetDatabaseQuad(hdb, 49, *Rec\FARBE3)
          SetDatabaseDouble(hdb, 50, *Rec\DURCHMESSER)
          SetDatabaseDouble(hdb, 51, *Rec\MITTEX)
          SetDatabaseDouble(hdb, 52, *Rec\MITTEY)
          SetDatabaseString(hdb, 53, *Rec\ARTIKELNAME)
          SetDatabaseString(hdb, 54, *Rec\BILDTYP)
          SetDatabaseQuad(hdb, 56, *Rec\ANSCHLAGMITTEL)
          SetDatabaseString(hdb, 57, *Rec\URL)
          SetDatabaseString(hdb, 58, *Rec\TEXT)
          SetDatabaseString(hdb, 59, *Rec\ANSCHLUESSE)
          SetDatabaseQuad(hdb, 60, *Rec\ANZSCHIENE)
          SetDatabaseQuad(hdb, 61, *Rec\BAUFORMID1)
          SetDatabaseQuad(hdb, 62, *Rec\BAUFORMID2)
          SetDatabaseQuad(hdb, 63, *Rec\SERIE)
          SetDatabaseQuad(hdb, 64, *Rec\ANTIQUE)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure WriteRec_ETIKETT(hDB, sField.s, sVal.s, *Rec.TRec_ETIKETT)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from ETIKETT WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          SetDatabaseQuad(hdb, 0, *Rec\ID)
          SetDatabaseQuad(hdb, 1, *Rec\ANZAHLX)
          SetDatabaseQuad(hdb, 2, *Rec\ANZAHLY)
          SetDatabaseString(hdb, 3, *Rec\BEZEICHNUNG)
          SetDatabaseDouble(hdb, 4, *Rec\RANDOBEN)
          SetDatabaseDouble(hdb, 5, *Rec\RANDLINKS)
          SetDatabaseDouble(hdb, 6, *Rec\ETIKETTENBREITE)
          SetDatabaseDouble(hdb, 7, *Rec\ETIKETTENHOEHE)
          SetDatabaseDouble(hdb, 8, *Rec\ABSTANDX)
          SetDatabaseDouble(hdb, 9, *Rec\ABSTANDY)
          SetDatabaseString(hdb, 10, *Rec\ENDLOS)
          SetDatabaseQuad(hdb, 11, *Rec\ZEILEN)
          SetDatabaseString(hdb, 12, *Rec\FONTNAME)
          SetDatabaseQuad(hdb, 13, *Rec\FONTHOEHE)
          SetDatabaseQuad(hdb, 14, *Rec\FONTSTYLE)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure WriteRec_EXAKTKRIT(hDB, sField.s, sVal.s, *Rec.TRec_EXAKTKRIT)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from EXAKTKRIT WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          SetDatabaseQuad(hdb, 0, *Rec\ID)
          SetDatabaseQuad(hdb, 1, *Rec\SUBKLASSEID)
          SetDatabaseString(hdb, 2, *Rec\EXAKTKRITERIUM)
          SetDatabaseString(hdb, 3, *Rec\TXT\DE)
          SetDatabaseString(hdb, 4, *Rec\TXT\EN)
          SetDatabaseString(hdb, 5, *Rec\TXT\FR)
          SetDatabaseString(hdb, 6, *Rec\TXT\NL)
          SetDatabaseString(hdb, 7, *Rec\TXT\ES)
          SetDatabaseString(hdb, 8, *Rec\TXT\PL)
          SetDatabaseString(hdb, 9, *Rec\TXT\TR)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure WriteRec_FARBCODE(hDB, sField.s, sVal.s, *Rec.TRec_FARBCODE)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from FARBCODE WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          SetDatabaseQuad(hdb, 0, *Rec\ID)
          SetDatabaseString(hdb, 1, *Rec\FARBCODE_D)
          SetDatabaseString(hdb, 2, *Rec\FARBCODE_EN)
          SetDatabaseString(hdb, 3, *Rec\FARBCODE_NL)
          SetDatabaseString(hdb, 4, *Rec\FARBCODE_S)
          SetDatabaseString(hdb, 5, *Rec\FARBCODE_TR)
          SetDatabaseString(hdb, 6, *Rec\TXT\DE)
          SetDatabaseString(hdb, 7, *Rec\TXT\EN)
          SetDatabaseString(hdb, 8, *Rec\TXT\NL)
          SetDatabaseString(hdb, 9, *Rec\TXT\ES)
          SetDatabaseString(hdb, 10, *Rec\TXT\TR)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure WriteRec_GERKLASS(hDB, sField.s, sVal.s, *Rec.TRec_GERKLASS)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from GERKLASS WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          SetDatabaseQuad(hdb, 0, *Rec\HAUPTKLASSE)
          SetDatabaseString(hdb, 1, *Rec\TXT\DE)
          SetDatabaseString(hdb, 2, *Rec\TXT\EN)
          SetDatabaseString(hdb, 3, *Rec\TXT\FR)
          SetDatabaseString(hdb, 4, *Rec\TXT\NL)
          SetDatabaseString(hdb, 5, *Rec\TXT\ES)
          SetDatabaseString(hdb, 6, *Rec\TXT\PL)
          SetDatabaseString(hdb, 7, *Rec\TXT\TR)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure WriteRec_GERTAB(hDB, sField.s, sVal.s, *Rec.TRec_GERTAB)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from GERTAB WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          SetDatabaseQuad(hdb, 0, *Rec\ID)
          SetDatabaseQuad(hdb, 1, *Rec\SUBKLASSE)
          SetDatabaseQuad(hdb, 2, *Rec\HAUPTKLASSE)
          SetDatabaseString(hdb, 3, *Rec\EBN_BMK)
          SetDatabaseString(hdb, 4, *Rec\TXT\DE)
          SetDatabaseString(hdb, 5, *Rec\TXT\EN)
          SetDatabaseString(hdb, 6, *Rec\TXT\FR)
          SetDatabaseString(hdb, 7, *Rec\TXT\NL)
          SetDatabaseString(hdb, 8, *Rec\TXT\ES)
          SetDatabaseString(hdb, 9, *Rec\TXT\PL)
          SetDatabaseString(hdb, 10, *Rec\TXT\TR)
          SetDatabaseString(hdb, 11, *Rec\BMK\DE)
          SetDatabaseString(hdb, 12, *Rec\BMK\EN)
          SetDatabaseString(hdb, 13, *Rec\BMK\FR)
          SetDatabaseString(hdb, 14, *Rec\BMK\NL)
          SetDatabaseString(hdb, 15, *Rec\BMK\ES)
          SetDatabaseString(hdb, 16, *Rec\BMK\PL)
          SetDatabaseString(hdb, 17, *Rec\BMK\TR)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure WriteRec_HERSTTAB(hDB, sField.s, sVal.s, *Rec.TRec_HERSTTAB)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from HERSTTAB WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          SetDatabaseQuad(hdb, 0, *Rec\ID)
          SetDatabaseString(hdb, 1, *Rec\KUERZEL)
          SetDatabaseString(hdb, 2, *Rec\FIRMA)
          SetDatabaseString(hdb, 3, *Rec\ANSPRECHPARTNER)
          SetDatabaseString(hdb, 4, *Rec\POSTFACH)
          SetDatabaseString(hdb, 5, *Rec\STRASSE)
          SetDatabaseString(hdb, 6, *Rec\STAAT)
          SetDatabaseString(hdb, 7, *Rec\POSTLEITZAHL)
          SetDatabaseString(hdb, 8, *Rec\ORT)
          SetDatabaseString(hdb, 9, *Rec\VORWAHL)
          SetDatabaseString(hdb, 10, *Rec\RUFNUMMER)
          SetDatabaseString(hdb, 11, *Rec\DURCHWAHL)
          SetDatabaseString(hdb, 12, *Rec\TEXT)
          SetDatabaseString(hdb, 13, *Rec\FAXNUMMER)
          SetDatabaseString(hdb, 14, *Rec\CADCABELBEZ)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure WriteRec_IMPORTEURE(hDB, sField.s, sVal.s, *Rec.TRec_IMPORTEURE)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from IMPORTEURE WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          SetDatabaseQuad(hdb, 0, *Rec\ID)
          SetDatabaseString(hdb, 1, *Rec\NAME)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure WriteRec_IMPORTKLASSEN(hDB, sField.s, sVal.s, *Rec.TRec_IMPORTKLASSEN)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from IMPORTKLASSEN WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          SetDatabaseQuad(hdb, 0, *Rec\ID)
          SetDatabaseQuad(hdb, 1, *Rec\IMPORTEUR)
          SetDatabaseQuad(hdb, 2, *Rec\KLASSE)
          SetDatabaseQuad(hdb, 3, *Rec\KLASSENEU)
          SetDatabaseString(hdb, 4, *Rec\HILFSGERAET)
          SetDatabaseQuad(hdb, 5, *Rec\SUBKLASSE)
          SetDatabaseString(hdb, 6, *Rec\BEZEICHNUNG)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure WriteRec_KABEL(hDB, sField.s, sVal.s, *Rec.TRec_KABEL)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from KABEL WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          SetDatabaseQuad(hdb, 0, *Rec\KABELTYP)
          SetDatabaseQuad(hdb, 1, *Rec\ID)
          SetDatabaseDouble(hdb, 2, *Rec\AUSSENDURCHMESSER)
          SetDatabaseDouble(hdb, 3, *Rec\GEWICHT)
          SetDatabaseDouble(hdb, 4, *Rec\KUPFERZAHL)
          SetDatabaseDouble(hdb, 5, *Rec\BIEGERADIUS)
          SetDatabaseString(hdb, 6, *Rec\TXT\DE)
          SetDatabaseString(hdb, 7, *Rec\TXT\EN)
          SetDatabaseString(hdb, 8, *Rec\TXT\NL)
          SetDatabaseString(hdb, 9, *Rec\TXT\ES)
          SetDatabaseString(hdb, 10, *Rec\TXT\TR)
          SetDatabaseString(hdb, 11, *Rec\HERSTELLER)
          SetDatabaseString(hdb, 12, *Rec\BESTELLNUMMER)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure WriteRec_KABELBUENDEL(hDB, sField.s, sVal.s, *Rec.TRec_KABELBUENDEL)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from KABELBUENDEL WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          SetDatabaseQuad(hdb, 0, *Rec\KABEL)
          SetDatabaseQuad(hdb, 1, *Rec\ID)
          SetDatabaseString(hdb, 2, *Rec\BUENDELCODE)
          SetDatabaseQuad(hdb, 3, *Rec\ADERNZAHL)
          SetDatabaseQuad(hdb, 4, *Rec\FARBCODE)
          SetDatabaseQuad(hdb, 5, *Rec\PAARE)
          SetDatabaseQuad(hdb, 6, *Rec\BETRIEBSSPANNUNG)
          SetDatabaseQuad(hdb, 7, *Rec\QUERSCHNITT)
          SetDatabaseQuad(hdb, 8, *Rec\PE)
          SetDatabaseString(hdb, 9, *Rec\SCHIRM)
          SetDatabaseString(hdb, 10, *Rec\TXT\DE)
          SetDatabaseString(hdb, 11, *Rec\TXT\EN)
          SetDatabaseString(hdb, 12, *Rec\TXT\NL)
          SetDatabaseString(hdb, 13, *Rec\TXT\ES)
          SetDatabaseString(hdb, 14, *Rec\TXT\TR)
          SetDatabaseString(hdb, 15, *Rec\AWG)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure WriteRec_KABELTYP(hDB, sField.s, sVal.s, *Rec.TRec_KABELTYP)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from KABELTYP WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          SetDatabaseQuad(hdb, 0, *Rec\ID)
          SetDatabaseString(hdb, 1, *Rec\KABELTYP)
          SetDatabaseQuad(hdb, 2, *Rec\TEMP_FEST_MIN)
          SetDatabaseQuad(hdb, 3, *Rec\TEMP_FEST_MAX)
          SetDatabaseQuad(hdb, 4, *Rec\TEMP_BEWEGT_MIN)
          SetDatabaseQuad(hdb, 5, *Rec\TEMP_BEWEGT_MAX)
          SetDatabaseQuad(hdb, 6, *Rec\ANTIQUE)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure WriteRec_LIEFER(hDB, sField.s, sVal.s, *Rec.TRec_LIEFER)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from LIEFER WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          SetDatabaseQuad(hdb, 0, *Rec\ID)
          SetDatabaseString(hdb, 1, *Rec\KUERZEL)
          SetDatabaseString(hdb, 2, *Rec\FIRMA)
          SetDatabaseString(hdb, 3, *Rec\ANSPRECHPARTNER)
          SetDatabaseString(hdb, 4, *Rec\POSTFACH)
          SetDatabaseString(hdb, 5, *Rec\STRASSE)
          SetDatabaseString(hdb, 6, *Rec\STAAT)
          SetDatabaseString(hdb, 7, *Rec\POSTLEITZAHL)
          SetDatabaseString(hdb, 8, *Rec\ORT)
          SetDatabaseString(hdb, 9, *Rec\VORWAHL)
          SetDatabaseString(hdb, 10, *Rec\RUFNUMMER)
          SetDatabaseString(hdb, 11, *Rec\DURCHWAHL)
          SetDatabaseString(hdb, 12, *Rec\FAXNUMMER)
          SetDatabaseQuad(hdb, 13, *Rec\MINDESTBESTELLWERT)
          SetDatabaseString(hdb, 14, *Rec\TEXT)
          SetDatabaseString(hdb, 15, *Rec\ZAHLUNGSBEDINGUNGEN)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure WriteRec_MINKRIT(hDB, sField.s, sVal.s, *Rec.TRec_MINKRIT)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from MINKRIT WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          SetDatabaseQuad(hdb, 0, *Rec\ID)
          SetDatabaseQuad(hdb, 1, *Rec\EXAKTKRITERIUM)
          SetDatabaseQuad(hdb, 2, *Rec\MINDESTKRITERIUM)
          SetDatabaseString(hdb, 3, *Rec\TXT\DE)
          SetDatabaseString(hdb, 4, *Rec\TXT\EN)
          SetDatabaseString(hdb, 5, *Rec\TXT\FR)
          SetDatabaseString(hdb, 6, *Rec\TXT\NL)
          SetDatabaseString(hdb, 7, *Rec\TXT\ES)
          SetDatabaseString(hdb, 8, *Rec\TXT\PL)
          SetDatabaseString(hdb, 9, *Rec\TXT\TR)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure WriteRec_SERIEN(hDB, sField.s, sVal.s, *Rec.TRec_SERIEN)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from SERIEN WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          SetDatabaseQuad(hdb, 0, *Rec\ID)
          SetDatabaseQuad(hdb, 1, *Rec\HERSTELLER)
          SetDatabaseString(hdb, 2, *Rec\NAME)
          SetDatabaseQuad(hdb, 3, *Rec\GERKLASS)
          SetDatabaseQuad(hdb, 4, *Rec\ANTIQUE)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure WriteRec_VNSKLASSE(hDB, sField.s, sVal.s, *Rec.TRec_VNSKLASSE)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from VNSKLASSE WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          SetDatabaseQuad(hdb, 0, *Rec\ID)
          SetDatabaseString(hdb, 1, *Rec\PRODUKT)
          SetDatabaseString(hdb, 2, *Rec\NAME)
          SetDatabaseString(hdb, 3, *Rec\ART)
          SetDatabaseQuad(hdb, 4, *Rec\KLASSE)
          SetDatabaseQuad(hdb, 5, *Rec\SUBKLASSE)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure WriteRec_ZUSGER_0(hDB, sField.s, sVal.s, *Rec.TRec_ZUSGER_0)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from ZUSGER_0 WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          SetDatabaseQuad(hdb, 0, *Rec\HAUPTELEMENT)
          SetDatabaseQuad(hdb, 1, *Rec\MINDESTKRITERIUM)
          SetDatabaseQuad(hdb, 2, *Rec\KOMBINATION)
          SetDatabaseString(hdb, 3, *Rec\TEXT)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  Procedure WriteRec_ZUSGER_1(hDB, sField.s, sVal.s, *Rec.TRec_ZUSGER_1)
    Protected ret = #True 
    Protected SQL.s 
  
    SQL = "Select * from ZUSGER_1 WHERE " + sField + " = " + sVal
  
    If DatabaseQuery(hdb,SQL) 
      If NextDatabaseRow(hDB) 
        With *Rec 
          SetDatabaseQuad(hdb, 0, *Rec\KOMBINATION)
          SetDatabaseQuad(hdb, 1, *Rec\ZAEHLER)
          SetDatabaseQuad(hdb, 2, *Rec\HILFSELEMENT)
          SetDatabaseQuad(hdb, 3, *Rec\ANZAHL)
        EndWith 
      Else 
        ret = #False 
      EndIf 
      FinishDatabaseQuery(hDB) 
    Else 
      ret = #False 
    EndIf 
  
    ProcedureReturn ret 
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- PROTOTYPES
  ;- ----------------------------------------------------------------------
  
   Prototype.i TProcDBReadRec(hDB, sField.s, sVal.s, *Rec) 
   Prototype.i TProcDBWriteRec(hDB, sField.s, sVal.s, *Rec) 
  
   Global NewMap pReadRec.i()      ; Pointer for all ReadRec-Functions 
   Global NewMap pWriteRec.i()     ; Pointer for all WriteRec-Functions 
  
   ; Add all Functions Pointer of ReadRec-, WriteRec- TabNames to the MAPs pReadRec(), pWriteRec()
  
   pReadRec("ADERN") =  @ReadRec_ADERN()
   pWriteRec("ADERN") = @WriteRec_ADERN()
  
   pReadRec("BAUFORM") =  @ReadRec_BAUFORM()
   pWriteRec("BAUFORM") = @WriteRec_BAUFORM()
  
   pReadRec("COMM") =  @ReadRec_COMM()
   pWriteRec("COMM") = @WriteRec_COMM()
  
   pReadRec("EINZLGER") =  @ReadRec_EINZLGER()
   pWriteRec("EINZLGER") = @WriteRec_EINZLGER()
  
   pReadRec("ETIKETT") =  @ReadRec_ETIKETT()
   pWriteRec("ETIKETT") = @WriteRec_ETIKETT()
  
   pReadRec("EXAKTKRIT") =  @ReadRec_EXAKTKRIT()
   pWriteRec("EXAKTKRIT") = @WriteRec_EXAKTKRIT()
  
   pReadRec("FARBCODE") =  @ReadRec_FARBCODE()
   pWriteRec("FARBCODE") = @WriteRec_FARBCODE()
  
   pReadRec("GERKLASS") =  @ReadRec_GERKLASS()
   pWriteRec("GERKLASS") = @WriteRec_GERKLASS()
  
   pReadRec("GERTAB") =  @ReadRec_GERTAB()
   pWriteRec("GERTAB") = @WriteRec_GERTAB()
  
   pReadRec("HERSTTAB") =  @ReadRec_HERSTTAB()
   pWriteRec("HERSTTAB") = @WriteRec_HERSTTAB()
  
   pReadRec("IMPORTEURE") =  @ReadRec_IMPORTEURE()
   pWriteRec("IMPORTEURE") = @WriteRec_IMPORTEURE()
  
   pReadRec("IMPORTKLASSEN") =  @ReadRec_IMPORTKLASSEN()
   pWriteRec("IMPORTKLASSEN") = @WriteRec_IMPORTKLASSEN()
  
   pReadRec("KABEL") =  @ReadRec_KABEL()
   pWriteRec("KABEL") = @WriteRec_KABEL()
  
   pReadRec("KABELBUENDEL") =  @ReadRec_KABELBUENDEL()
   pWriteRec("KABELBUENDEL") = @WriteRec_KABELBUENDEL()
  
   pReadRec("KABELTYP") =  @ReadRec_KABELTYP()
   pWriteRec("KABELTYP") = @WriteRec_KABELTYP()
  
   pReadRec("LIEFER") =  @ReadRec_LIEFER()
   pWriteRec("LIEFER") = @WriteRec_LIEFER()
  
   pReadRec("MINKRIT") =  @ReadRec_MINKRIT()
   pWriteRec("MINKRIT") = @WriteRec_MINKRIT()
  
   pReadRec("SERIEN") =  @ReadRec_SERIEN()
   pWriteRec("SERIEN") = @WriteRec_SERIEN()
  
   pReadRec("VNSKLASSE") =  @ReadRec_VNSKLASSE()
   pWriteRec("VNSKLASSE") = @WriteRec_VNSKLASSE()
  
   pReadRec("ZUSGER_0") =  @ReadRec_ZUSGER_0()
   pWriteRec("ZUSGER_0") = @WriteRec_ZUSGER_0()
  
   pReadRec("ZUSGER_1") =  @ReadRec_ZUSGER_1()
   pWriteRec("ZUSGER_1") = @WriteRec_ZUSGER_1()
  
  Procedure ReadRec(TabName.s, hDB, sField.s, sVal.s, *Rec) 
    Protected DBReadRec.TProcDBReadRec 
  
    If  FindMapElement(pReadRec(), TabName) 
      DBReadRec = pReadRec()              ; Get the Pointer to the correct ReadRec_[TableName]
      DBReadRec(hdb, sField, sVal, *Rec)  ; Call the correct Function ReadRec_[TableName]
    EndIf
  
  EndProcedure
  
  ;- ----------------------------------------------------------------------
  ;- CREATE GADGETS 
  ;- ----------------------------------------------------------------------
  ; ADERN
  Procedure Create_Gadgets_ADERN() 
    Protected x, y, w, h, dx, dy 
  
    x= 10: y=10: w=150: h=26 
  
    dx=w+20 
    dy=h+10 
  
    With Gadgets_ADERN
      \lbl_FARBCODE = TextGadget(#PB_Any, x, y, w, h, "FARBCODE") ; Label
      \txt_FARBCODE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ZAEHLER = TextGadget(#PB_Any, x, y, w, h, "ZAEHLER") ; Label
      \txt_ZAEHLER = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_CODE = TextGadget(#PB_Any, x, y, w, h, "CODE") ; Label
      \txt_CODE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
    EndWith 
  EndProcedure 
  
  ; BAUFORM
  Procedure Create_Gadgets_BAUFORM() 
    Protected x, y, w, h, dx, dy 
  
    x= 10: y=10: w=150: h=26 
  
    dx=w+20 
    dy=h+10 
  
    With Gadgets_BAUFORM
      \lbl_ID1 = TextGadget(#PB_Any, x, y, w, h, "ID1") ; Label
      \txt_ID1 = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ID2 = TextGadget(#PB_Any, x, y, w, h, "ID2") ; Label
      \txt_ID2 = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BEZEICHNUNG = TextGadget(#PB_Any, x, y, w, h, "BEZEICHNUNG") ; Label
      \txt_BEZEICHNUNG = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BASIS = TextGadget(#PB_Any, x, y, w, h, "BASIS") ; Label
      \txt_BASIS = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_HILFSGERAET = TextGadget(#PB_Any, x, y, w, h, "HILFSGERAET") ; Label
      \txt_HILFSGERAET = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ANBAUORT = TextGadget(#PB_Any, x, y, w, h, "ANBAUORT") ; Label
      \txt_ANBAUORT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_SUBKLASSE = TextGadget(#PB_Any, x, y, w, h, "SUBKLASSE") ; Label
      \txt_SUBKLASSE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ANSCHLAGMITTEL = TextGadget(#PB_Any, x, y, w, h, "ANSCHLAGMITTEL") ; Label
      \txt_ANSCHLAGMITTEL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_HOEHE = TextGadget(#PB_Any, x, y, w, h, "HOEHE") ; Label
      \txt_HOEHE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BREITE = TextGadget(#PB_Any, x, y, w, h, "BREITE") ; Label
      \txt_BREITE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_TIEFE = TextGadget(#PB_Any, x, y, w, h, "TIEFE") ; Label
      \txt_TIEFE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_DURCHMESSER = TextGadget(#PB_Any, x, y, w, h, "DURCHMESSER") ; Label
      \txt_DURCHMESSER = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_MITTEX = TextGadget(#PB_Any, x, y, w, h, "MITTEX") ; Label
      \txt_MITTEX = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_MITTEY = TextGadget(#PB_Any, x, y, w, h, "MITTEY") ; Label
      \txt_MITTEY = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_AUFSCHNAPPLINIE = TextGadget(#PB_Any, x, y, w, h, "AUFSCHNAPPLINIE") ; Label
      \txt_AUFSCHNAPPLINIE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_KONTAKTE = TextGadget(#PB_Any, x, y, w, h, "KONTAKTE") ; Label
      \txt_KONTAKTE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ANSCHLUESSE = TextGadget(#PB_Any, x, y, w, h, "ANSCHLUESSE") ; Label
      \txt_ANSCHLUESSE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_TEXT = TextGadget(#PB_Any, x, y, w, h, "TEXT") ; Label
      \txt_TEXT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
    EndWith 
  EndProcedure 
  
  ; COMM
  Procedure Create_Gadgets_COMM() 
    Protected x, y, w, h, dx, dy 
  
    x= 10: y=10: w=150: h=26 
  
    dx=w+20 
    dy=h+10 
  
    With Gadgets_COMM
      \lbl_BENUTZER = TextGadget(#PB_Any, x, y, w, h, "BENUTZER") ; Label
      \txt_BENUTZER = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_COMPUTER = TextGadget(#PB_Any, x, y, w, h, "COMPUTER") ; Label
      \txt_COMPUTER = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_TABELLE = TextGadget(#PB_Any, x, y, w, h, "TABELLE") ; Label
      \txt_TABELLE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_AKTION = TextGadget(#PB_Any, x, y, w, h, "AKTION") ; Label
      \txt_AKTION = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ZEIT = TextGadget(#PB_Any, x, y, w, h, "ZEIT") ; Label
      \txt_ZEIT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ID1 = TextGadget(#PB_Any, x, y, w, h, "ID1") ; Label
      \txt_ID1 = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ID2 = TextGadget(#PB_Any, x, y, w, h, "ID2") ; Label
      \txt_ID2 = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ID3 = TextGadget(#PB_Any, x, y, w, h, "ID3") ; Label
      \txt_ID3 = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ID4 = TextGadget(#PB_Any, x, y, w, h, "ID4") ; Label
      \txt_ID4 = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
    EndWith 
  EndProcedure 
  
  ; EINZLGER
  Procedure Create_Gadgets_EINZLGER() 
    Protected x, y, w, h, dx, dy 
  
    x= 10: y=10: w=150: h=26 
  
    dx=w+20 
    dy=h+10 
  
    With Gadgets_EINZLGER
      \lbl_ID = TextGadget(#PB_Any, x, y, w, h, "ID") ; Label
      \txt_ID = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_HERSTELLER = TextGadget(#PB_Any, x, y, w, h, "HERSTELLER") ; Label
      \txt_HERSTELLER = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_TYPENBEZEICHNUNG = TextGadget(#PB_Any, x, y, w, h, "TYPENBEZEICHNUNG") ; Label
      \txt_TYPENBEZEICHNUNG = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_HILFSGERAET = TextGadget(#PB_Any, x, y, w, h, "HILFSGERAET") ; Label
      \txt_HILFSGERAET = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_LAGERNUMMER = TextGadget(#PB_Any, x, y, w, h, "LAGERNUMMER") ; Label
      \txt_LAGERNUMMER = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_LIEFERANT = TextGadget(#PB_Any, x, y, w, h, "LIEFERANT") ; Label
      \txt_LIEFERANT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BESTELLNUMMER = TextGadget(#PB_Any, x, y, w, h, "BESTELLNUMMER") ; Label
      \txt_BESTELLNUMMER = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BASIS = TextGadget(#PB_Any, x, y, w, h, "BASIS") ; Label
      \txt_BASIS = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_LISTENPREIS = TextGadget(#PB_Any, x, y, w, h, "LISTENPREIS") ; Label
      \txt_LISTENPREIS = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_RABATT = TextGadget(#PB_Any, x, y, w, h, "RABATT") ; Label
      \txt_RABATT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_EINKAUFSPREIS = TextGadget(#PB_Any, x, y, w, h, "EINKAUFSPREIS") ; Label
      \txt_EINKAUFSPREIS = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_GEMEINKOSTEN = TextGadget(#PB_Any, x, y, w, h, "GEMEINKOSTEN") ; Label
      \txt_GEMEINKOSTEN = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_VERKAUFSPREIS = TextGadget(#PB_Any, x, y, w, h, "VERKAUFSPREIS") ; Label
      \txt_VERKAUFSPREIS = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_GUELTIGKEIT = TextGadget(#PB_Any, x, y, w, h, "GUELTIGKEIT") ; Label
      \txt_GUELTIGKEIT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_VERPACKUNGSEINHEIT = TextGadget(#PB_Any, x, y, w, h, "VERPACKUNGSEINHEIT") ; Label
      \txt_VERPACKUNGSEINHEIT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_LAGERBESTAND_IST = TextGadget(#PB_Any, x, y, w, h, "LAGERBESTAND_IST") ; Label
      \txt_LAGERBESTAND_IST = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_LAGERBESTAND_MIN = TextGadget(#PB_Any, x, y, w, h, "LAGERBESTAND_MIN") ; Label
      \txt_LAGERBESTAND_MIN = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_VERFUEGBARKEIT = TextGadget(#PB_Any, x, y, w, h, "VERFUEGBARKEIT") ; Label
      \txt_VERFUEGBARKEIT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_SUBKLASSE = TextGadget(#PB_Any, x, y, w, h, "SUBKLASSE") ; Label
      \txt_SUBKLASSE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_MINDESTKRITERIUM = TextGadget(#PB_Any, x, y, w, h, "MINDESTKRITERIUM") ; Label
      \txt_MINDESTKRITERIUM = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_KONTAKTE = TextGadget(#PB_Any, x, y, w, h, "KONTAKTE") ; Label
      \txt_KONTAKTE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_SPULENSPANNUNG = TextGadget(#PB_Any, x, y, w, h, "SPULENSPANNUNG") ; Label
      \txt_SPULENSPANNUNG = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_SPULEAC = TextGadget(#PB_Any, x, y, w, h, "SPULEAC") ; Label
      \txt_SPULEAC = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_SCHALTSTROM = TextGadget(#PB_Any, x, y, w, h, "SCHALTSTROM") ; Label
      \txt_SCHALTSTROM = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_SCHALTLEISTUNG = TextGadget(#PB_Any, x, y, w, h, "SCHALTLEISTUNG") ; Label
      \txt_SCHALTLEISTUNG = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_VERLUSTLEISTUNG = TextGadget(#PB_Any, x, y, w, h, "VERLUSTLEISTUNG") ; Label
      \txt_VERLUSTLEISTUNG = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_HALTELEISTUNG = TextGadget(#PB_Any, x, y, w, h, "HALTELEISTUNG") ; Label
      \txt_HALTELEISTUNG = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_HOEHE = TextGadget(#PB_Any, x, y, w, h, "HOEHE") ; Label
      \txt_HOEHE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BREITE = TextGadget(#PB_Any, x, y, w, h, "BREITE") ; Label
      \txt_BREITE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_TIEFE = TextGadget(#PB_Any, x, y, w, h, "TIEFE") ; Label
      \txt_TIEFE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_AUFSCHNAPPLINIE = TextGadget(#PB_Any, x, y, w, h, "AUFSCHNAPPLINIE") ; Label
      \txt_AUFSCHNAPPLINIE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_SICHERHEITSABSTAND = TextGadget(#PB_Any, x, y, w, h, "SICHERHEITSABSTAND") ; Label
      \txt_SICHERHEITSABSTAND = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_EINBAUZEIT = TextGadget(#PB_Any, x, y, w, h, "EINBAUZEIT") ; Label
      \txt_EINBAUZEIT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_GEWICHT = TextGadget(#PB_Any, x, y, w, h, "GEWICHT") ; Label
      \txt_GEWICHT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ANBAUORT = TextGadget(#PB_Any, x, y, w, h, "ANBAUORT") ; Label
      \txt_ANBAUORT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BAUFORM = TextGadget(#PB_Any, x, y, w, h, "BAUFORM") ; Label
      \txt_BAUFORM = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BAUGROESSE = TextGadget(#PB_Any, x, y, w, h, "BAUGROESSE") ; Label
      \txt_BAUGROESSE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_STAFFELGRENZE1 = TextGadget(#PB_Any, x, y, w, h, "STAFFELGRENZE1") ; Label
      \txt_STAFFELGRENZE1 = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_RABATTSTAFFEL1 = TextGadget(#PB_Any, x, y, w, h, "RABATTSTAFFEL1") ; Label
      \txt_RABATTSTAFFEL1 = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_STAFFELGRENZE2 = TextGadget(#PB_Any, x, y, w, h, "STAFFELGRENZE2") ; Label
      \txt_STAFFELGRENZE2 = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_RABATTSTAFFEL2 = TextGadget(#PB_Any, x, y, w, h, "RABATTSTAFFEL2") ; Label
      \txt_RABATTSTAFFEL2 = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_STAFFELGRENZE3 = TextGadget(#PB_Any, x, y, w, h, "STAFFELGRENZE3") ; Label
      \txt_STAFFELGRENZE3 = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_RABATTSTAFFEL3 = TextGadget(#PB_Any, x, y, w, h, "RABATTSTAFFEL3") ; Label
      \txt_RABATTSTAFFEL3 = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_WAEHRUNG = TextGadget(#PB_Any, x, y, w, h, "WAEHRUNG") ; Label
      \txt_WAEHRUNG = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FREQUENZMIN = TextGadget(#PB_Any, x, y, w, h, "FREQUENZMIN") ; Label
      \txt_FREQUENZMIN = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FREQUENZMAX = TextGadget(#PB_Any, x, y, w, h, "FREQUENZMAX") ; Label
      \txt_FREQUENZMAX = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FREQUENZNENN = TextGadget(#PB_Any, x, y, w, h, "FREQUENZNENN") ; Label
      \txt_FREQUENZNENN = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FARBE1 = TextGadget(#PB_Any, x, y, w, h, "FARBE1") ; Label
      \txt_FARBE1 = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FARBE2 = TextGadget(#PB_Any, x, y, w, h, "FARBE2") ; Label
      \txt_FARBE2 = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FARBE3 = TextGadget(#PB_Any, x, y, w, h, "FARBE3") ; Label
      \txt_FARBE3 = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_DURCHMESSER = TextGadget(#PB_Any, x, y, w, h, "DURCHMESSER") ; Label
      \txt_DURCHMESSER = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_MITTEX = TextGadget(#PB_Any, x, y, w, h, "MITTEX") ; Label
      \txt_MITTEX = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_MITTEY = TextGadget(#PB_Any, x, y, w, h, "MITTEY") ; Label
      \txt_MITTEY = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ARTIKELNAME = TextGadget(#PB_Any, x, y, w, h, "ARTIKELNAME") ; Label
      \txt_ARTIKELNAME = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BILDTYP = TextGadget(#PB_Any, x, y, w, h, "BILDTYP") ; Label
      \txt_BILDTYP = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BILD = TextGadget(#PB_Any, x, y, w, h, "BILD") ; Label
      \txt_BILD = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ANSCHLAGMITTEL = TextGadget(#PB_Any, x, y, w, h, "ANSCHLAGMITTEL") ; Label
      \txt_ANSCHLAGMITTEL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_URL = TextGadget(#PB_Any, x, y, w, h, "URL") ; Label
      \txt_URL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_TEXT = TextGadget(#PB_Any, x, y, w, h, "TEXT") ; Label
      \txt_TEXT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ANSCHLUESSE = TextGadget(#PB_Any, x, y, w, h, "ANSCHLUESSE") ; Label
      \txt_ANSCHLUESSE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ANZSCHIENE = TextGadget(#PB_Any, x, y, w, h, "ANZSCHIENE") ; Label
      \txt_ANZSCHIENE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BAUFORMID1 = TextGadget(#PB_Any, x, y, w, h, "BAUFORMID1") ; Label
      \txt_BAUFORMID1 = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BAUFORMID2 = TextGadget(#PB_Any, x, y, w, h, "BAUFORMID2") ; Label
      \txt_BAUFORMID2 = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_SERIE = TextGadget(#PB_Any, x, y, w, h, "SERIE") ; Label
      \txt_SERIE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ANTIQUE = TextGadget(#PB_Any, x, y, w, h, "ANTIQUE") ; Label
      \txt_ANTIQUE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
    EndWith 
  EndProcedure 
  
  ; ETIKETT
  Procedure Create_Gadgets_ETIKETT() 
    Protected x, y, w, h, dx, dy 
  
    x= 10: y=10: w=150: h=26 
  
    dx=w+20 
    dy=h+10 
  
    With Gadgets_ETIKETT
      \lbl_ID = TextGadget(#PB_Any, x, y, w, h, "ID") ; Label
      \txt_ID = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ANZAHLX = TextGadget(#PB_Any, x, y, w, h, "ANZAHLX") ; Label
      \txt_ANZAHLX = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ANZAHLY = TextGadget(#PB_Any, x, y, w, h, "ANZAHLY") ; Label
      \txt_ANZAHLY = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BEZEICHNUNG = TextGadget(#PB_Any, x, y, w, h, "BEZEICHNUNG") ; Label
      \txt_BEZEICHNUNG = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_RANDOBEN = TextGadget(#PB_Any, x, y, w, h, "RANDOBEN") ; Label
      \txt_RANDOBEN = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_RANDLINKS = TextGadget(#PB_Any, x, y, w, h, "RANDLINKS") ; Label
      \txt_RANDLINKS = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ETIKETTENBREITE = TextGadget(#PB_Any, x, y, w, h, "ETIKETTENBREITE") ; Label
      \txt_ETIKETTENBREITE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ETIKETTENHOEHE = TextGadget(#PB_Any, x, y, w, h, "ETIKETTENHOEHE") ; Label
      \txt_ETIKETTENHOEHE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ABSTANDX = TextGadget(#PB_Any, x, y, w, h, "ABSTANDX") ; Label
      \txt_ABSTANDX = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ABSTANDY = TextGadget(#PB_Any, x, y, w, h, "ABSTANDY") ; Label
      \txt_ABSTANDY = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ENDLOS = TextGadget(#PB_Any, x, y, w, h, "ENDLOS") ; Label
      \txt_ENDLOS = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ZEILEN = TextGadget(#PB_Any, x, y, w, h, "ZEILEN") ; Label
      \txt_ZEILEN = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FONTNAME = TextGadget(#PB_Any, x, y, w, h, "FONTNAME") ; Label
      \txt_FONTNAME = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FONTHOEHE = TextGadget(#PB_Any, x, y, w, h, "FONTHOEHE") ; Label
      \txt_FONTHOEHE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FONTSTYLE = TextGadget(#PB_Any, x, y, w, h, "FONTSTYLE") ; Label
      \txt_FONTSTYLE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
    EndWith 
  EndProcedure 
  
  ; EXAKTKRIT
  Procedure Create_Gadgets_EXAKTKRIT() 
    Protected x, y, w, h, dx, dy 
  
    x= 10: y=10: w=150: h=26 
  
    dx=w+20 
    dy=h+10 
  
    With Gadgets_EXAKTKRIT
      \lbl_ID = TextGadget(#PB_Any, x, y, w, h, "ID") ; Label
      \txt_ID = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_SUBKLASSEID = TextGadget(#PB_Any, x, y, w, h, "SUBKLASSEID") ; Label
      \txt_SUBKLASSEID = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_EXAKTKRITERIUM = TextGadget(#PB_Any, x, y, w, h, "EXAKTKRITERIUM") ; Label
      \txt_EXAKTKRITERIUM = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_DE = TextGadget(#PB_Any, x, y, w, h, "DE") ; Label
      \txt_DE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_EN = TextGadget(#PB_Any, x, y, w, h, "EN") ; Label
      \txt_EN = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FR = TextGadget(#PB_Any, x, y, w, h, "FR") ; Label
      \txt_FR = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_NL = TextGadget(#PB_Any, x, y, w, h, "NL") ; Label
      \txt_NL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ES = TextGadget(#PB_Any, x, y, w, h, "ES") ; Label
      \txt_ES = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_PL = TextGadget(#PB_Any, x, y, w, h, "PL") ; Label
      \txt_PL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_TR = TextGadget(#PB_Any, x, y, w, h, "TR") ; Label
      \txt_TR = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
    EndWith 
  EndProcedure 
  
  ; FARBCODE
  Procedure Create_Gadgets_FARBCODE() 
    Protected x, y, w, h, dx, dy 
  
    x= 10: y=10: w=150: h=26 
  
    dx=w+20 
    dy=h+10 
  
    With Gadgets_FARBCODE
      \lbl_ID = TextGadget(#PB_Any, x, y, w, h, "ID") ; Label
      \txt_ID = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FARBCODE_DE = TextGadget(#PB_Any, x, y, w, h, "FARBCODE_D") ; Label
      \txt_FARBCODE_DE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FARBCODE_EN = TextGadget(#PB_Any, x, y, w, h, "FARBCODE_EN") ; Label
      \txt_FARBCODE_EN = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FARBCODE_NL = TextGadget(#PB_Any, x, y, w, h, "FARBCODE_NL") ; Label
      \txt_FARBCODE_NL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FARBCODE_ES = TextGadget(#PB_Any, x, y, w, h, "FARBCODE_S") ; Label
      \txt_FARBCODE_ES = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FARBCODE_TR = TextGadget(#PB_Any, x, y, w, h, "FARBCODE_TR") ; Label
      \txt_FARBCODE_TR = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_DE = TextGadget(#PB_Any, x, y, w, h, "D") ; Label
      \txt_DE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_EN = TextGadget(#PB_Any, x, y, w, h, "EN") ; Label
      \txt_EN = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_NL = TextGadget(#PB_Any, x, y, w, h, "NL") ; Label
      \txt_NL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ES = TextGadget(#PB_Any, x, y, w, h, "S") ; Label
      \txt_ES = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_TR = TextGadget(#PB_Any, x, y, w, h, "TR") ; Label
      \txt_TR = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
    EndWith 
  EndProcedure 
  
  ; GERKLASS
  Procedure Create_Gadgets_GERKLASS() 
    Protected x, y, w, h, dx, dy 
  
    x= 10: y=10: w=150: h=26 
  
    dx=w+20 
    dy=h+10 
  
    With Gadgets_GERKLASS
      \lbl_HAUPTKLASSE = TextGadget(#PB_Any, x, y, w, h, "HAUPTKLASSE") ; Label
      \txt_HAUPTKLASSE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_DE = TextGadget(#PB_Any, x, y, w, h, "D") ; Label
      \txt_DE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_EN = TextGadget(#PB_Any, x, y, w, h, "EN") ; Label
      \txt_EN = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FR = TextGadget(#PB_Any, x, y, w, h, "F") ; Label
      \txt_FR = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_NL = TextGadget(#PB_Any, x, y, w, h, "NL") ; Label
      \txt_NL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ES = TextGadget(#PB_Any, x, y, w, h, "S") ; Label
      \txt_ES = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_PL = TextGadget(#PB_Any, x, y, w, h, "PL") ; Label
      \txt_PL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_TR = TextGadget(#PB_Any, x, y, w, h, "TR") ; Label
      \txt_TR = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
    EndWith 
  EndProcedure 
  
  ; GERTAB
  Procedure Create_Gadgets_GERTAB() 
    Protected x, y, w, h, dx, dy 
  
    x= 10: y=10: w=150: h=26 
  
    dx=w+20 
    dy=h+10 
  
    With Gadgets_GERTAB
      \lbl_ID = TextGadget(#PB_Any, x, y, w, h, "ID") ; Label
      \txt_ID = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_SUBKLASSE = TextGadget(#PB_Any, x, y, w, h, "SUBKLASSE") ; Label
      \txt_SUBKLASSE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_HAUPTKLASSE = TextGadget(#PB_Any, x, y, w, h, "HAUPTKLASSE") ; Label
      \txt_HAUPTKLASSE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_EBN_BMK = TextGadget(#PB_Any, x, y, w, h, "EBN_BMK") ; Label
      \txt_EBN_BMK = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_DE = TextGadget(#PB_Any, x, y, w, h, "D") ; Label
      \txt_DE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_EN = TextGadget(#PB_Any, x, y, w, h, "EN") ; Label
      \txt_EN = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FR = TextGadget(#PB_Any, x, y, w, h, "F") ; Label
      \txt_FR = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_NL = TextGadget(#PB_Any, x, y, w, h, "NL") ; Label
      \txt_NL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ES = TextGadget(#PB_Any, x, y, w, h, "S") ; Label
      \txt_ES = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_PL = TextGadget(#PB_Any, x, y, w, h, "PL") ; Label
      \txt_PL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_TR = TextGadget(#PB_Any, x, y, w, h, "TR") ; Label
      \txt_TR = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BMK_DE = TextGadget(#PB_Any, x, y, w, h, "BMK_D") ; Label
      \txt_BMK_DE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BMK_EN = TextGadget(#PB_Any, x, y, w, h, "BMK_EN") ; Label
      \txt_BMK_EN = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BMK_FR = TextGadget(#PB_Any, x, y, w, h, "BMK_F") ; Label
      \txt_BMK_FR = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BMK_NL = TextGadget(#PB_Any, x, y, w, h, "BMK_NL") ; Label
      \txt_BMK_NL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BMK_ES = TextGadget(#PB_Any, x, y, w, h, "BMK_S") ; Label
      \txt_BMK_ES = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BMK_PL = TextGadget(#PB_Any, x, y, w, h, "BMK_PL") ; Label
      \txt_BMK_PL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BMK_TR = TextGadget(#PB_Any, x, y, w, h, "BMK_TR") ; Label
      \txt_BMK_TR = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
    EndWith 
  EndProcedure 
  
  ; HERSTTAB
  Procedure Create_Gadgets_HERSTTAB() 
    Protected x, y, w, h, dx, dy 
  
    x= 10: y=10: w=150: h=26 
  
    dx=w+20 
    dy=h+10 
  
    With Gadgets_HERSTTAB
      \lbl_ID = TextGadget(#PB_Any, x, y, w, h, "ID") ; Label
      \txt_ID = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_KUERZEL = TextGadget(#PB_Any, x, y, w, h, "KUERZEL") ; Label
      \txt_KUERZEL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FIRMA = TextGadget(#PB_Any, x, y, w, h, "FIRMA") ; Label
      \txt_FIRMA = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ANSPRECHPARTNER = TextGadget(#PB_Any, x, y, w, h, "ANSPRECHPARTNER") ; Label
      \txt_ANSPRECHPARTNER = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_POSTFACH = TextGadget(#PB_Any, x, y, w, h, "POSTFACH") ; Label
      \txt_POSTFACH = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_STRASSE = TextGadget(#PB_Any, x, y, w, h, "STRASSE") ; Label
      \txt_STRASSE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_STAAT = TextGadget(#PB_Any, x, y, w, h, "STAAT") ; Label
      \txt_STAAT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_POSTLEITZAHL = TextGadget(#PB_Any, x, y, w, h, "POSTLEITZAHL") ; Label
      \txt_POSTLEITZAHL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ORT = TextGadget(#PB_Any, x, y, w, h, "ORT") ; Label
      \txt_ORT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_VORWAHL = TextGadget(#PB_Any, x, y, w, h, "VORWAHL") ; Label
      \txt_VORWAHL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_RUFNUMMER = TextGadget(#PB_Any, x, y, w, h, "RUFNUMMER") ; Label
      \txt_RUFNUMMER = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_DURCHWAHL = TextGadget(#PB_Any, x, y, w, h, "DURCHWAHL") ; Label
      \txt_DURCHWAHL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_TEXT = TextGadget(#PB_Any, x, y, w, h, "TEXT") ; Label
      \txt_TEXT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FAXNUMMER = TextGadget(#PB_Any, x, y, w, h, "FAXNUMMER") ; Label
      \txt_FAXNUMMER = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_CADCABELBEZ = TextGadget(#PB_Any, x, y, w, h, "CADCABELBEZ") ; Label
      \txt_CADCABELBEZ = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
    EndWith 
  EndProcedure 
  
  ; IMPORTEURE
  Procedure Create_Gadgets_IMPORTEURE() 
    Protected x, y, w, h, dx, dy 
  
    x= 10: y=10: w=150: h=26 
  
    dx=w+20 
    dy=h+10 
  
    With Gadgets_IMPORTEURE
      \lbl_ID = TextGadget(#PB_Any, x, y, w, h, "ID") ; Label
      \txt_ID = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_NAME = TextGadget(#PB_Any, x, y, w, h, "NAME") ; Label
      \txt_NAME = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
    EndWith 
  EndProcedure 
  
  ; IMPORTKLASSEN
  Procedure Create_Gadgets_IMPORTKLASSEN() 
    Protected x, y, w, h, dx, dy 
  
    x= 10: y=10: w=150: h=26 
  
    dx=w+20 
    dy=h+10 
  
    With Gadgets_IMPORTKLASSEN
      \lbl_ID = TextGadget(#PB_Any, x, y, w, h, "ID") ; Label
      \txt_ID = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_IMPORTEUR = TextGadget(#PB_Any, x, y, w, h, "IMPORTEUR") ; Label
      \txt_IMPORTEUR = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_KLASSE = TextGadget(#PB_Any, x, y, w, h, "KLASSE") ; Label
      \txt_KLASSE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_KLASSENEU = TextGadget(#PB_Any, x, y, w, h, "KLASSENEU") ; Label
      \txt_KLASSENEU = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_HILFSGERAET = TextGadget(#PB_Any, x, y, w, h, "HILFSGERAET") ; Label
      \txt_HILFSGERAET = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_SUBKLASSE = TextGadget(#PB_Any, x, y, w, h, "SUBKLASSE") ; Label
      \txt_SUBKLASSE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BEZEICHNUNG = TextGadget(#PB_Any, x, y, w, h, "BEZEICHNUNG") ; Label
      \txt_BEZEICHNUNG = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
    EndWith 
  EndProcedure 
  
  ; KABEL
  Procedure Create_Gadgets_KABEL() 
    Protected x, y, w, h, dx, dy 
  
    x= 10: y=10: w=150: h=26 
  
    dx=w+20 
    dy=h+10 
  
    With Gadgets_KABEL
      \lbl_KABELTYP = TextGadget(#PB_Any, x, y, w, h, "KABELTYP") ; Label
      \txt_KABELTYP = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ID = TextGadget(#PB_Any, x, y, w, h, "ID") ; Label
      \txt_ID = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_AUSSENDURCHMESSER = TextGadget(#PB_Any, x, y, w, h, "AUSSENDURCHMESSER") ; Label
      \txt_AUSSENDURCHMESSER = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_GEWICHT = TextGadget(#PB_Any, x, y, w, h, "GEWICHT") ; Label
      \txt_GEWICHT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_KUPFERZAHL = TextGadget(#PB_Any, x, y, w, h, "KUPFERZAHL") ; Label
      \txt_KUPFERZAHL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BIEGERADIUS = TextGadget(#PB_Any, x, y, w, h, "BIEGERADIUS") ; Label
      \txt_BIEGERADIUS = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_DE = TextGadget(#PB_Any, x, y, w, h, "D") ; Label
      \txt_DE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_EN = TextGadget(#PB_Any, x, y, w, h, "EN") ; Label
      \txt_EN = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_NL = TextGadget(#PB_Any, x, y, w, h, "NL") ; Label
      \txt_NL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ES = TextGadget(#PB_Any, x, y, w, h, "S") ; Label
      \txt_ES = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_TR = TextGadget(#PB_Any, x, y, w, h, "TR") ; Label
      \txt_TR = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_HERSTELLER = TextGadget(#PB_Any, x, y, w, h, "HERSTELLER") ; Label
      \txt_HERSTELLER = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BESTELLNUMMER = TextGadget(#PB_Any, x, y, w, h, "BESTELLNUMMER") ; Label
      \txt_BESTELLNUMMER = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
    EndWith 
  EndProcedure 
  
  ; KABELBUENDEL
  Procedure Create_Gadgets_KABELBUENDEL() 
    Protected x, y, w, h, dx, dy 
  
    x= 10: y=10: w=150: h=26 
  
    dx=w+20 
    dy=h+10 
  
    With Gadgets_KABELBUENDEL
      \lbl_KABEL = TextGadget(#PB_Any, x, y, w, h, "KABEL") ; Label
      \txt_KABEL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ID = TextGadget(#PB_Any, x, y, w, h, "ID") ; Label
      \txt_ID = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BUENDELCODE = TextGadget(#PB_Any, x, y, w, h, "BUENDELCODE") ; Label
      \txt_BUENDELCODE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ADERNZAHL = TextGadget(#PB_Any, x, y, w, h, "ADERNZAHL") ; Label
      \txt_ADERNZAHL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FARBCODE = TextGadget(#PB_Any, x, y, w, h, "FARBCODE") ; Label
      \txt_FARBCODE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_PAARE = TextGadget(#PB_Any, x, y, w, h, "PAARE") ; Label
      \txt_PAARE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_BETRIEBSSPANNUNG = TextGadget(#PB_Any, x, y, w, h, "BETRIEBSSPANNUNG") ; Label
      \txt_BETRIEBSSPANNUNG = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_QUERSCHNITT = TextGadget(#PB_Any, x, y, w, h, "QUERSCHNITT") ; Label
      \txt_QUERSCHNITT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_PE = TextGadget(#PB_Any, x, y, w, h, "PE") ; Label
      \txt_PE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_SCHIRM = TextGadget(#PB_Any, x, y, w, h, "SCHIRM") ; Label
      \txt_SCHIRM = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_DE = TextGadget(#PB_Any, x, y, w, h, "D") ; Label
      \txt_DE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_EN = TextGadget(#PB_Any, x, y, w, h, "EN") ; Label
      \txt_EN = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_NL = TextGadget(#PB_Any, x, y, w, h, "NL") ; Label
      \txt_NL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ES = TextGadget(#PB_Any, x, y, w, h, "S") ; Label
      \txt_ES = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_TR = TextGadget(#PB_Any, x, y, w, h, "TR") ; Label
      \txt_TR = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_AWG = TextGadget(#PB_Any, x, y, w, h, "AWG") ; Label
      \txt_AWG = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
    EndWith 
  EndProcedure 
  
  ; KABELTYP
  Procedure Create_Gadgets_KABELTYP() 
    Protected x, y, w, h, dx, dy 
  
    x= 10: y=10: w=150: h=26 
  
    dx=w+20 
    dy=h+10 
  
    With Gadgets_KABELTYP
      \lbl_ID = TextGadget(#PB_Any, x, y, w, h, "ID") ; Label
      \txt_ID = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_KABELTYP = TextGadget(#PB_Any, x, y, w, h, "KABELTYP") ; Label
      \txt_KABELTYP = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_TEMP_FEST_MIN = TextGadget(#PB_Any, x, y, w, h, "TEMP_FEST_MIN") ; Label
      \txt_TEMP_FEST_MIN = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_TEMP_FEST_MAX = TextGadget(#PB_Any, x, y, w, h, "TEMP_FEST_MAX") ; Label
      \txt_TEMP_FEST_MAX = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_TEMP_BEWEGT_MIN = TextGadget(#PB_Any, x, y, w, h, "TEMP_BEWEGT_MIN") ; Label
      \txt_TEMP_BEWEGT_MIN = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_TEMP_BEWEGT_MAX = TextGadget(#PB_Any, x, y, w, h, "TEMP_BEWEGT_MAX") ; Label
      \txt_TEMP_BEWEGT_MAX = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ANTIQUE = TextGadget(#PB_Any, x, y, w, h, "ANTIQUE") ; Label
      \txt_ANTIQUE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
    EndWith 
  EndProcedure 
  
  ; LIEFER
  Procedure Create_Gadgets_LIEFER() 
    Protected x, y, w, h, dx, dy 
  
    x= 10: y=10: w=150: h=26 
  
    dx=w+20 
    dy=h+10 
  
    With Gadgets_LIEFER
      \lbl_ID = TextGadget(#PB_Any, x, y, w, h, "ID") ; Label
      \txt_ID = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_KUERZEL = TextGadget(#PB_Any, x, y, w, h, "KUERZEL") ; Label
      \txt_KUERZEL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FIRMA = TextGadget(#PB_Any, x, y, w, h, "FIRMA") ; Label
      \txt_FIRMA = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ANSPRECHPARTNER = TextGadget(#PB_Any, x, y, w, h, "ANSPRECHPARTNER") ; Label
      \txt_ANSPRECHPARTNER = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_POSTFACH = TextGadget(#PB_Any, x, y, w, h, "POSTFACH") ; Label
      \txt_POSTFACH = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_STRASSE = TextGadget(#PB_Any, x, y, w, h, "STRASSE") ; Label
      \txt_STRASSE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_STAAT = TextGadget(#PB_Any, x, y, w, h, "STAAT") ; Label
      \txt_STAAT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_POSTLEITZAHL = TextGadget(#PB_Any, x, y, w, h, "POSTLEITZAHL") ; Label
      \txt_POSTLEITZAHL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ORT = TextGadget(#PB_Any, x, y, w, h, "ORT") ; Label
      \txt_ORT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_VORWAHL = TextGadget(#PB_Any, x, y, w, h, "VORWAHL") ; Label
      \txt_VORWAHL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_RUFNUMMER = TextGadget(#PB_Any, x, y, w, h, "RUFNUMMER") ; Label
      \txt_RUFNUMMER = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_DURCHWAHL = TextGadget(#PB_Any, x, y, w, h, "DURCHWAHL") ; Label
      \txt_DURCHWAHL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FAXNUMMER = TextGadget(#PB_Any, x, y, w, h, "FAXNUMMER") ; Label
      \txt_FAXNUMMER = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_MINDESTBESTELLWERT = TextGadget(#PB_Any, x, y, w, h, "MINDESTBESTELLWERT") ; Label
      \txt_MINDESTBESTELLWERT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_TEXT = TextGadget(#PB_Any, x, y, w, h, "TEXT") ; Label
      \txt_TEXT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ZAHLUNGSBEDINGUNGEN = TextGadget(#PB_Any, x, y, w, h, "ZAHLUNGSBEDINGUNGEN") ; Label
      \txt_ZAHLUNGSBEDINGUNGEN = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
    EndWith 
  EndProcedure 
  
  ; MINKRIT
  Procedure Create_Gadgets_MINKRIT() 
    Protected x, y, w, h, dx, dy 
  
    x= 10: y=10: w=150: h=26 
  
    dx=w+20 
    dy=h+10 
  
    With Gadgets_MINKRIT
      \lbl_ID = TextGadget(#PB_Any, x, y, w, h, "ID") ; Label
      \txt_ID = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_EXAKTKRITERIUM = TextGadget(#PB_Any, x, y, w, h, "EXAKTKRITERIUM") ; Label
      \txt_EXAKTKRITERIUM = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_MINDESTKRITERIUM = TextGadget(#PB_Any, x, y, w, h, "MINDESTKRITERIUM") ; Label
      \txt_MINDESTKRITERIUM = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_DE = TextGadget(#PB_Any, x, y, w, h, "D") ; Label
      \txt_DE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_EN = TextGadget(#PB_Any, x, y, w, h, "EN") ; Label
      \txt_EN = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_FR = TextGadget(#PB_Any, x, y, w, h, "F") ; Label
      \txt_FR = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_NL = TextGadget(#PB_Any, x, y, w, h, "NL") ; Label
      \txt_NL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ES = TextGadget(#PB_Any, x, y, w, h, "S") ; Label
      \txt_ES = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_PL = TextGadget(#PB_Any, x, y, w, h, "PL") ; Label
      \txt_PL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_TR = TextGadget(#PB_Any, x, y, w, h, "TR") ; Label
      \txt_TR = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
    EndWith 
  EndProcedure 
  
  ; SERIEN
  Procedure Create_Gadgets_SERIEN() 
    Protected x, y, w, h, dx, dy 
  
    x= 10: y=10: w=150: h=26 
  
    dx=w+20 
    dy=h+10 
  
    With Gadgets_SERIEN
      \lbl_ID = TextGadget(#PB_Any, x, y, w, h, "ID") ; Label
      \txt_ID = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_HERSTELLER = TextGadget(#PB_Any, x, y, w, h, "HERSTELLER") ; Label
      \txt_HERSTELLER = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_NAME = TextGadget(#PB_Any, x, y, w, h, "NAME") ; Label
      \txt_NAME = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_GERKLASS = TextGadget(#PB_Any, x, y, w, h, "GERKLASS") ; Label
      \txt_GERKLASS = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ANTIQUE = TextGadget(#PB_Any, x, y, w, h, "ANTIQUE") ; Label
      \txt_ANTIQUE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
    EndWith 
  EndProcedure 
  
  ; VNSKLASSE
  Procedure Create_Gadgets_VNSKLASSE() 
    Protected x, y, w, h, dx, dy 
  
    x= 10: y=10: w=150: h=26 
  
    dx=w+20 
    dy=h+10 
  
    With Gadgets_VNSKLASSE
      \lbl_ID = TextGadget(#PB_Any, x, y, w, h, "ID") ; Label
      \txt_ID = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_PRODUKT = TextGadget(#PB_Any, x, y, w, h, "PRODUKT") ; Label
      \txt_PRODUKT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_NAME = TextGadget(#PB_Any, x, y, w, h, "NAME") ; Label
      \txt_NAME = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ART = TextGadget(#PB_Any, x, y, w, h, "ART") ; Label
      \txt_ART = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_KLASSE = TextGadget(#PB_Any, x, y, w, h, "KLASSE") ; Label
      \txt_KLASSE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_SUBKLASSE = TextGadget(#PB_Any, x, y, w, h, "SUBKLASSE") ; Label
      \txt_SUBKLASSE = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
    EndWith 
  EndProcedure 
  
  ; ZUSGER_0
  Procedure Create_Gadgets_ZUSGER_0() 
    Protected x, y, w, h, dx, dy 
  
    x= 10: y=10: w=150: h=26 
  
    dx=w+20 
    dy=h+10 
  
    With Gadgets_ZUSGER_0
      \lbl_HAUPTELEMENT = TextGadget(#PB_Any, x, y, w, h, "HAUPTELEMENT") ; Label
      \txt_HAUPTELEMENT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_MINDESTKRITERIUM = TextGadget(#PB_Any, x, y, w, h, "MINDESTKRITERIUM") ; Label
      \txt_MINDESTKRITERIUM = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_KOMBINATION = TextGadget(#PB_Any, x, y, w, h, "KOMBINATION") ; Label
      \txt_KOMBINATION = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_TEXT = TextGadget(#PB_Any, x, y, w, h, "TEXT") ; Label
      \txt_TEXT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
    EndWith 
  EndProcedure 
  
  ; ZUSGER_1
  Procedure Create_Gadgets_ZUSGER_1() 
    Protected x, y, w, h, dx, dy 
  
    x= 10: y=10: w=150: h=26 
  
    dx=w+20 
    dy=h+10 
  
    With Gadgets_ZUSGER_1
      \lbl_KOMBINATION = TextGadget(#PB_Any, x, y, w, h, "KOMBINATION") ; Label
      \txt_KOMBINATION = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ZAEHLER = TextGadget(#PB_Any, x, y, w, h, "ZAEHLER") ; Label
      \txt_ZAEHLER = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_HILFSELEMENT = TextGadget(#PB_Any, x, y, w, h, "HILFSELEMENT") ; Label
      \txt_HILFSELEMENT = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
      \lbl_ANZAHL = TextGadget(#PB_Any, x, y, w, h, "ANZAHL") ; Label
      \txt_ANZAHL = StringGadget(#PB_Any, x+dx, y, w, h, "Text")  ; Text
      y+dy 
    EndWith 
  EndProcedure 
  
  
  ;- ----------------------------------------------------------------------
  ;- RECORD TO GADGETS 
  ;- ----------------------------------------------------------------------
  ; ADERN
  Procedure RecToGadgets_ADERN(*Rec.TRec_ADERN)
    With Gadgets_ADERN
      SetGadgetItemText(\txt_FARBCODE, 0, Str(*Rec\FARBCODE))
      SetGadgetItemText(\txt_ZAEHLER, 0, Str(*Rec\ZAEHLER))
      SetGadgetItemText(\txt_CODE, 0, Str(*Rec\CODE))
    EndWith 
  EndProcedure 
  
  ; BAUFORM
  Procedure RecToGadgets_BAUFORM(*Rec.TRec_BAUFORM)
    With Gadgets_BAUFORM
      SetGadgetItemText(\txt_ID1, 0, Str(*Rec\ID1))
      SetGadgetItemText(\txt_ID2, 0, Str(*Rec\ID2))
      SetGadgetItemText(\txt_BEZEICHNUNG, 0, *Rec\BEZEICHNUNG)
      SetGadgetItemText(\txt_BASIS, 0, *Rec\BASIS)
      SetGadgetItemText(\txt_HILFSGERAET, 0, *Rec\HILFSGERAET)
      SetGadgetItemText(\txt_ANBAUORT, 0, *Rec\ANBAUORT)
      SetGadgetItemText(\txt_SUBKLASSE, 0, Str(*Rec\SUBKLASSE))
      SetGadgetItemText(\txt_ANSCHLAGMITTEL, 0, Str(*Rec\ANSCHLAGMITTEL))
      SetGadgetItemText(\txt_HOEHE, 0, Str(*Rec\HOEHE))
      SetGadgetItemText(\txt_BREITE, 0, Str(*Rec\BREITE))
      SetGadgetItemText(\txt_TIEFE, 0, Str(*Rec\TIEFE))
      SetGadgetItemText(\txt_DURCHMESSER, 0, Str(*Rec\DURCHMESSER))
      SetGadgetItemText(\txt_MITTEX, 0, Str(*Rec\MITTEX))
      SetGadgetItemText(\txt_MITTEY, 0, Str(*Rec\MITTEY))
      SetGadgetItemText(\txt_AUFSCHNAPPLINIE, 0, Str(*Rec\AUFSCHNAPPLINIE))
      SetGadgetItemText(\txt_KONTAKTE, 0, *Rec\KONTAKTE)
      SetGadgetItemText(\txt_ANSCHLUESSE, 0, *Rec\ANSCHLUESSE)
      SetGadgetItemText(\txt_TEXT, 0, *Rec\TEXT)
    EndWith 
  EndProcedure 
  
  ; COMM
  Procedure RecToGadgets_COMM(*Rec.TRec_COMM)
    With Gadgets_COMM
      SetGadgetItemText(\txt_BENUTZER, 0, *Rec\BENUTZER)
      SetGadgetItemText(\txt_COMPUTER, 0, *Rec\COMPUTER)
      SetGadgetItemText(\txt_TABELLE, 0, Str(*Rec\TABELLE))
      SetGadgetItemText(\txt_AKTION, 0, Str(*Rec\AKTION))
      SetGadgetItemText(\txt_ZEIT, 0, Str(*Rec\ZEIT))
      SetGadgetItemText(\txt_ID1, 0, Str(*Rec\ID1))
      SetGadgetItemText(\txt_ID2, 0, Str(*Rec\ID2))
      SetGadgetItemText(\txt_ID3, 0, Str(*Rec\ID3))
      SetGadgetItemText(\txt_ID4, 0, Str(*Rec\ID4))
    EndWith 
  EndProcedure 
  
  ; EINZLGER
  Procedure RecToGadgets_EINZLGER(*Rec.TRec_EINZLGER)
    With Gadgets_EINZLGER
      SetGadgetItemText(\txt_ID, 0, Str(*Rec\ID))
      SetGadgetItemText(\txt_HERSTELLER, 0, Str(*Rec\HERSTELLER))
      SetGadgetItemText(\txt_TYPENBEZEICHNUNG, 0, *Rec\TYPENBEZEICHNUNG)
      SetGadgetItemText(\txt_HILFSGERAET, 0, *Rec\HILFSGERAET)
      SetGadgetItemText(\txt_LAGERNUMMER, 0, *Rec\LAGERNUMMER)
      SetGadgetItemText(\txt_LIEFERANT, 0, Str(*Rec\LIEFERANT))
      SetGadgetItemText(\txt_BESTELLNUMMER, 0, *Rec\BESTELLNUMMER)
      SetGadgetItemText(\txt_BASIS, 0, *Rec\BASIS)
      SetGadgetItemText(\txt_LISTENPREIS, 0, Str(*Rec\LISTENPREIS))
      SetGadgetItemText(\txt_RABATT, 0, Str(*Rec\RABATT))
      SetGadgetItemText(\txt_EINKAUFSPREIS, 0, Str(*Rec\EINKAUFSPREIS))
      SetGadgetItemText(\txt_GEMEINKOSTEN, 0, Str(*Rec\GEMEINKOSTEN))
      SetGadgetItemText(\txt_VERKAUFSPREIS, 0, Str(*Rec\VERKAUFSPREIS))
      SetGadgetItemText(\txt_GUELTIGKEIT, 0, Str(*Rec\GUELTIGKEIT))
      SetGadgetItemText(\txt_VERPACKUNGSEINHEIT, 0, *Rec\VERPACKUNGSEINHEIT)
      SetGadgetItemText(\txt_LAGERBESTAND_IST, 0, Str(*Rec\LAGERBESTAND_IST))
      SetGadgetItemText(\txt_LAGERBESTAND_MIN, 0, Str(*Rec\LAGERBESTAND_MIN))
      SetGadgetItemText(\txt_VERFUEGBARKEIT, 0, Str(*Rec\VERFUEGBARKEIT))
      SetGadgetItemText(\txt_SUBKLASSE, 0, Str(*Rec\SUBKLASSE))
      SetGadgetItemText(\txt_MINDESTKRITERIUM, 0, Str(*Rec\MINDESTKRITERIUM))
      SetGadgetItemText(\txt_KONTAKTE, 0, *Rec\KONTAKTE)
      SetGadgetItemText(\txt_SPULENSPANNUNG, 0, Str(*Rec\SPULENSPANNUNG))
      SetGadgetItemText(\txt_SPULEAC, 0, *Rec\SPULEAC)
      SetGadgetItemText(\txt_SCHALTSTROM, 0, Str(*Rec\SCHALTSTROM))
      SetGadgetItemText(\txt_SCHALTLEISTUNG, 0, Str(*Rec\SCHALTLEISTUNG))
      SetGadgetItemText(\txt_VERLUSTLEISTUNG, 0, Str(*Rec\VERLUSTLEISTUNG))
      SetGadgetItemText(\txt_HALTELEISTUNG, 0, Str(*Rec\HALTELEISTUNG))
      SetGadgetItemText(\txt_HOEHE, 0, Str(*Rec\HOEHE))
      SetGadgetItemText(\txt_BREITE, 0, Str(*Rec\BREITE))
      SetGadgetItemText(\txt_TIEFE, 0, Str(*Rec\TIEFE))
      SetGadgetItemText(\txt_AUFSCHNAPPLINIE, 0, Str(*Rec\AUFSCHNAPPLINIE))
      SetGadgetItemText(\txt_SICHERHEITSABSTAND, 0, Str(*Rec\SICHERHEITSABSTAND))
      SetGadgetItemText(\txt_EINBAUZEIT, 0, Str(*Rec\EINBAUZEIT))
      SetGadgetItemText(\txt_GEWICHT, 0, Str(*Rec\GEWICHT))
      SetGadgetItemText(\txt_ANBAUORT, 0, *Rec\ANBAUORT)
      SetGadgetItemText(\txt_BAUFORM, 0, *Rec\BAUFORM)
      SetGadgetItemText(\txt_BAUGROESSE, 0, *Rec\BAUGROESSE)
      SetGadgetItemText(\txt_STAFFELGRENZE1, 0, Str(*Rec\STAFFELGRENZE1))
      SetGadgetItemText(\txt_RABATTSTAFFEL1, 0, Str(*Rec\RABATTSTAFFEL1))
      SetGadgetItemText(\txt_STAFFELGRENZE2, 0, Str(*Rec\STAFFELGRENZE2))
      SetGadgetItemText(\txt_RABATTSTAFFEL2, 0, Str(*Rec\RABATTSTAFFEL2))
      SetGadgetItemText(\txt_STAFFELGRENZE3, 0, Str(*Rec\STAFFELGRENZE3))
      SetGadgetItemText(\txt_RABATTSTAFFEL3, 0, Str(*Rec\RABATTSTAFFEL3))
      SetGadgetItemText(\txt_WAEHRUNG, 0, *Rec\WAEHRUNG)
      SetGadgetItemText(\txt_FREQUENZMIN, 0, Str(*Rec\FREQUENZMIN))
      SetGadgetItemText(\txt_FREQUENZMAX, 0, Str(*Rec\FREQUENZMAX))
      SetGadgetItemText(\txt_FREQUENZNENN, 0, Str(*Rec\FREQUENZNENN))
      SetGadgetItemText(\txt_FARBE1, 0, Str(*Rec\FARBE1))
      SetGadgetItemText(\txt_FARBE2, 0, Str(*Rec\FARBE2))
      SetGadgetItemText(\txt_FARBE3, 0, Str(*Rec\FARBE3))
      SetGadgetItemText(\txt_DURCHMESSER, 0, Str(*Rec\DURCHMESSER))
      SetGadgetItemText(\txt_MITTEX, 0, Str(*Rec\MITTEX))
      SetGadgetItemText(\txt_MITTEY, 0, Str(*Rec\MITTEY))
      SetGadgetItemText(\txt_ARTIKELNAME, 0, *Rec\ARTIKELNAME)
      SetGadgetItemText(\txt_BILDTYP, 0, *Rec\BILDTYP)
      SetGadgetItemText(\txt_BILDTYP, 0, *Rec\BILDTYP)
      SetGadgetItemText(\txt_ANSCHLAGMITTEL, 0, Str(*Rec\ANSCHLAGMITTEL))
      SetGadgetItemText(\txt_URL, 0, *Rec\URL)
      SetGadgetItemText(\txt_TEXT, 0, *Rec\TEXT)
      SetGadgetItemText(\txt_ANSCHLUESSE, 0, *Rec\ANSCHLUESSE)
      SetGadgetItemText(\txt_ANZSCHIENE, 0, Str(*Rec\ANZSCHIENE))
      SetGadgetItemText(\txt_BAUFORMID1, 0, Str(*Rec\BAUFORMID1))
      SetGadgetItemText(\txt_BAUFORMID2, 0, Str(*Rec\BAUFORMID2))
      SetGadgetItemText(\txt_SERIE, 0, Str(*Rec\SERIE))
      SetGadgetItemText(\txt_ANTIQUE, 0, Str(*Rec\ANTIQUE))
    EndWith 
  EndProcedure 
  
  ; ETIKETT
  Procedure RecToGadgets_ETIKETT(*Rec.TRec_ETIKETT)
    With Gadgets_ETIKETT
      SetGadgetItemText(\txt_ID, 0, Str(*Rec\ID))
      SetGadgetItemText(\txt_ANZAHLX, 0, Str(*Rec\ANZAHLX))
      SetGadgetItemText(\txt_ANZAHLY, 0, Str(*Rec\ANZAHLY))
      SetGadgetItemText(\txt_BEZEICHNUNG, 0, *Rec\BEZEICHNUNG)
      SetGadgetItemText(\txt_RANDOBEN, 0, Str(*Rec\RANDOBEN))
      SetGadgetItemText(\txt_RANDLINKS, 0, Str(*Rec\RANDLINKS))
      SetGadgetItemText(\txt_ETIKETTENBREITE, 0, Str(*Rec\ETIKETTENBREITE))
      SetGadgetItemText(\txt_ETIKETTENHOEHE, 0, Str(*Rec\ETIKETTENHOEHE))
      SetGadgetItemText(\txt_ABSTANDX, 0, Str(*Rec\ABSTANDX))
      SetGadgetItemText(\txt_ABSTANDY, 0, Str(*Rec\ABSTANDY))
      SetGadgetItemText(\txt_ENDLOS, 0, *Rec\ENDLOS)
      SetGadgetItemText(\txt_ZEILEN, 0, Str(*Rec\ZEILEN))
      SetGadgetItemText(\txt_FONTNAME, 0, *Rec\FONTNAME)
      SetGadgetItemText(\txt_FONTHOEHE, 0, Str(*Rec\FONTHOEHE))
      SetGadgetItemText(\txt_FONTSTYLE, 0, Str(*Rec\FONTSTYLE))
    EndWith 
  EndProcedure 
  
  ; EXAKTKRIT
  Procedure RecToGadgets_EXAKTKRIT(*Rec.TRec_EXAKTKRIT)
    With Gadgets_EXAKTKRIT
      SetGadgetItemText(\txt_ID, 0, Str(*Rec\ID))
      SetGadgetItemText(\txt_SUBKLASSEID, 0, Str(*Rec\SUBKLASSEID))
      SetGadgetItemText(\txt_EXAKTKRITERIUM, 0, *Rec\EXAKTKRITERIUM)
      SetGadgetItemText(\txt_DE, 0, *Rec\TXT\DE)
      SetGadgetItemText(\txt_EN, 0, *Rec\TXT\EN)
      SetGadgetItemText(\txt_FR, 0, *Rec\TXT\FR)
      SetGadgetItemText(\txt_NL, 0, *Rec\TXT\NL)
      SetGadgetItemText(\txt_ES, 0, *Rec\TXT\ES)
      SetGadgetItemText(\txt_PL, 0, *Rec\TXT\PL)
      SetGadgetItemText(\txt_TR, 0, *Rec\TXT\TR)
    EndWith 
  EndProcedure 
  
  ; FARBCODE
  Procedure RecToGadgets_FARBCODE(*Rec.TRec_FARBCODE)
    With Gadgets_FARBCODE
      SetGadgetItemText(\txt_ID, 0, Str(*Rec\ID))
      SetGadgetItemText(\txt_FARBCODE_DE, 0, *Rec\FARBCODE_D)
      SetGadgetItemText(\txt_FARBCODE_EN, 0, *Rec\FARBCODE_EN)
      SetGadgetItemText(\txt_FARBCODE_NL, 0, *Rec\FARBCODE_NL)
      SetGadgetItemText(\txt_FARBCODE_ES, 0, *Rec\FARBCODE_S)
      SetGadgetItemText(\txt_FARBCODE_TR, 0, *Rec\FARBCODE_TR)
      SetGadgetItemText(\txt_DE, 0, *Rec\TXT\DE)
      SetGadgetItemText(\txt_EN, 0, *Rec\TXT\EN)
      SetGadgetItemText(\txt_NL, 0, *Rec\TXT\NL)
      SetGadgetItemText(\txt_ES, 0, *Rec\TXT\ES)
      SetGadgetItemText(\txt_TR, 0, *Rec\TXT\TR)
    EndWith 
  EndProcedure 
  
  ; GERKLASS
  Procedure RecToGadgets_GERKLASS(*Rec.TRec_GERKLASS)
    With Gadgets_GERKLASS
      SetGadgetItemText(\txt_HAUPTKLASSE, 0, Str(*Rec\HAUPTKLASSE))
      SetGadgetItemText(\txt_DE, 0, *Rec\TXT\DE)
      SetGadgetItemText(\txt_EN, 0, *Rec\TXT\EN)
      SetGadgetItemText(\txt_FR, 0, *Rec\TXT\FR)
      SetGadgetItemText(\txt_NL, 0, *Rec\TXT\NL)
      SetGadgetItemText(\txt_ES, 0, *Rec\TXT\ES)
      SetGadgetItemText(\txt_PL, 0, *Rec\TXT\PL)
      SetGadgetItemText(\txt_TR, 0, *Rec\TXT\TR)
    EndWith 
  EndProcedure 
  
  ; GERTAB
  Procedure RecToGadgets_GERTAB(*Rec.TRec_GERTAB)
    With Gadgets_GERTAB
      SetGadgetItemText(\txt_ID, 0, Str(*Rec\ID))
      SetGadgetItemText(\txt_SUBKLASSE, 0, Str(*Rec\SUBKLASSE))
      SetGadgetItemText(\txt_HAUPTKLASSE, 0, Str(*Rec\HAUPTKLASSE))
      SetGadgetItemText(\txt_EBN_BMK, 0, *Rec\EBN_BMK)
      SetGadgetItemText(\txt_DE, 0, *Rec\TXT\DE)
      SetGadgetItemText(\txt_EN, 0, *Rec\TXT\EN)
      SetGadgetItemText(\txt_FR, 0, *Rec\TXT\FR)
      SetGadgetItemText(\txt_NL, 0, *Rec\TXT\NL)
      SetGadgetItemText(\txt_ES, 0, *Rec\TXT\ES)
      SetGadgetItemText(\txt_PL, 0, *Rec\TXT\PL)
      SetGadgetItemText(\txt_TR, 0, *Rec\TXT\TR)
      SetGadgetItemText(\txt_BMK_DE, 0, *Rec\BMK\DE)
      SetGadgetItemText(\txt_BMK_EN, 0, *Rec\BMK\EN)
      SetGadgetItemText(\txt_BMK_FR, 0, *Rec\BMK\FR)
      SetGadgetItemText(\txt_BMK_NL, 0, *Rec\BMK\NL)
      SetGadgetItemText(\txt_BMK_ES, 0, *Rec\BMK\ES)
      SetGadgetItemText(\txt_BMK_PL, 0, *Rec\BMK\PL)
      SetGadgetItemText(\txt_BMK_TR, 0, *Rec\BMK\TR)
    EndWith 
  EndProcedure 
  
  ; HERSTTAB
  Procedure RecToGadgets_HERSTTAB(*Rec.TRec_HERSTTAB)
    With Gadgets_HERSTTAB
      SetGadgetItemText(\txt_ID, 0, Str(*Rec\ID))
      SetGadgetItemText(\txt_KUERZEL, 0, *Rec\KUERZEL)
      SetGadgetItemText(\txt_FIRMA, 0, *Rec\FIRMA)
      SetGadgetItemText(\txt_ANSPRECHPARTNER, 0, *Rec\ANSPRECHPARTNER)
      SetGadgetItemText(\txt_POSTFACH, 0, *Rec\POSTFACH)
      SetGadgetItemText(\txt_STRASSE, 0, *Rec\STRASSE)
      SetGadgetItemText(\txt_STAAT, 0, *Rec\STAAT)
      SetGadgetItemText(\txt_POSTLEITZAHL, 0, *Rec\POSTLEITZAHL)
      SetGadgetItemText(\txt_ORT, 0, *Rec\ORT)
      SetGadgetItemText(\txt_VORWAHL, 0, *Rec\VORWAHL)
      SetGadgetItemText(\txt_RUFNUMMER, 0, *Rec\RUFNUMMER)
      SetGadgetItemText(\txt_DURCHWAHL, 0, *Rec\DURCHWAHL)
      SetGadgetItemText(\txt_TEXT, 0, *Rec\TEXT)
      SetGadgetItemText(\txt_FAXNUMMER, 0, *Rec\FAXNUMMER)
      SetGadgetItemText(\txt_CADCABELBEZ, 0, *Rec\CADCABELBEZ)
    EndWith 
  EndProcedure 
  
  ; IMPORTEURE
  Procedure RecToGadgets_IMPORTEURE(*Rec.TRec_IMPORTEURE)
    With Gadgets_IMPORTEURE
      SetGadgetItemText(\txt_ID, 0, Str(*Rec\ID))
      SetGadgetItemText(\txt_NAME, 0, *Rec\NAME)
    EndWith 
  EndProcedure 
  
  ; IMPORTKLASSEN
  Procedure RecToGadgets_IMPORTKLASSEN(*Rec.TRec_IMPORTKLASSEN)
    With Gadgets_IMPORTKLASSEN
      SetGadgetItemText(\txt_ID, 0, Str(*Rec\ID))
      SetGadgetItemText(\txt_IMPORTEUR, 0, Str(*Rec\IMPORTEUR))
      SetGadgetItemText(\txt_KLASSE, 0, Str(*Rec\KLASSE))
      SetGadgetItemText(\txt_KLASSENEU, 0, Str(*Rec\KLASSENEU))
      SetGadgetItemText(\txt_HILFSGERAET, 0, *Rec\HILFSGERAET)
      SetGadgetItemText(\txt_SUBKLASSE, 0, Str(*Rec\SUBKLASSE))
      SetGadgetItemText(\txt_BEZEICHNUNG, 0, *Rec\BEZEICHNUNG)
    EndWith 
  EndProcedure 
  
  ; KABEL
  Procedure RecToGadgets_KABEL(*Rec.TRec_KABEL)
    With Gadgets_KABEL
      SetGadgetItemText(\txt_KABELTYP, 0, Str(*Rec\KABELTYP))
      SetGadgetItemText(\txt_ID, 0, Str(*Rec\ID))
      SetGadgetItemText(\txt_AUSSENDURCHMESSER, 0, Str(*Rec\AUSSENDURCHMESSER))
      SetGadgetItemText(\txt_GEWICHT, 0, Str(*Rec\GEWICHT))
      SetGadgetItemText(\txt_KUPFERZAHL, 0, Str(*Rec\KUPFERZAHL))
      SetGadgetItemText(\txt_BIEGERADIUS, 0, Str(*Rec\BIEGERADIUS))
      SetGadgetItemText(\txt_DE, 0, *Rec\TXT\DE)
      SetGadgetItemText(\txt_EN, 0, *Rec\TXT\EN)
      SetGadgetItemText(\txt_NL, 0, *Rec\TXT\NL)
      SetGadgetItemText(\txt_ES, 0, *Rec\TXT\ES)
      SetGadgetItemText(\txt_TR, 0, *Rec\TXT\TR)
      SetGadgetItemText(\txt_HERSTELLER, 0, *Rec\HERSTELLER)
      SetGadgetItemText(\txt_BESTELLNUMMER, 0, *Rec\BESTELLNUMMER)
    EndWith 
  EndProcedure 
  
  ; KABELBUENDEL
  Procedure RecToGadgets_KABELBUENDEL(*Rec.TRec_KABELBUENDEL)
    With Gadgets_KABELBUENDEL
      SetGadgetItemText(\txt_KABEL, 0, Str(*Rec\KABEL))
      SetGadgetItemText(\txt_ID, 0, Str(*Rec\ID))
      SetGadgetItemText(\txt_BUENDELCODE, 0, *Rec\BUENDELCODE)
      SetGadgetItemText(\txt_ADERNZAHL, 0, Str(*Rec\ADERNZAHL))
      SetGadgetItemText(\txt_FARBCODE, 0, Str(*Rec\FARBCODE))
      SetGadgetItemText(\txt_PAARE, 0, Str(*Rec\PAARE))
      SetGadgetItemText(\txt_BETRIEBSSPANNUNG, 0, Str(*Rec\BETRIEBSSPANNUNG))
      SetGadgetItemText(\txt_QUERSCHNITT, 0, Str(*Rec\QUERSCHNITT))
      SetGadgetItemText(\txt_PE, 0, Str(*Rec\PE))
      SetGadgetItemText(\txt_SCHIRM, 0, *Rec\SCHIRM)
      SetGadgetItemText(\txt_DE, 0, *Rec\TXT\DE)
      SetGadgetItemText(\txt_EN, 0, *Rec\TXT\EN)
      SetGadgetItemText(\txt_NL, 0, *Rec\TXT\NL)
      SetGadgetItemText(\txt_ES, 0, *Rec\TXT\ES)
      SetGadgetItemText(\txt_TR, 0, *Rec\TXT\TR)
      SetGadgetItemText(\txt_AWG, 0, *Rec\AWG)
    EndWith 
  EndProcedure 
  
  ; KABELTYP
  Procedure RecToGadgets_KABELTYP(*Rec.TRec_KABELTYP)
    With Gadgets_KABELTYP
      SetGadgetItemText(\txt_ID, 0, Str(*Rec\ID))
      SetGadgetItemText(\txt_KABELTYP, 0, *Rec\KABELTYP)
      SetGadgetItemText(\txt_TEMP_FEST_MIN, 0, Str(*Rec\TEMP_FEST_MIN))
      SetGadgetItemText(\txt_TEMP_FEST_MAX, 0, Str(*Rec\TEMP_FEST_MAX))
      SetGadgetItemText(\txt_TEMP_BEWEGT_MIN, 0, Str(*Rec\TEMP_BEWEGT_MIN))
      SetGadgetItemText(\txt_TEMP_BEWEGT_MAX, 0, Str(*Rec\TEMP_BEWEGT_MAX))
      SetGadgetItemText(\txt_ANTIQUE, 0, Str(*Rec\ANTIQUE))
    EndWith 
  EndProcedure 
  
  ; LIEFER
  Procedure RecToGadgets_LIEFER(*Rec.TRec_LIEFER)
    With Gadgets_LIEFER
      SetGadgetItemText(\txt_ID, 0, Str(*Rec\ID))
      SetGadgetItemText(\txt_KUERZEL, 0, *Rec\KUERZEL)
      SetGadgetItemText(\txt_FIRMA, 0, *Rec\FIRMA)
      SetGadgetItemText(\txt_ANSPRECHPARTNER, 0, *Rec\ANSPRECHPARTNER)
      SetGadgetItemText(\txt_POSTFACH, 0, *Rec\POSTFACH)
      SetGadgetItemText(\txt_STRASSE, 0, *Rec\STRASSE)
      SetGadgetItemText(\txt_STAAT, 0, *Rec\STAAT)
      SetGadgetItemText(\txt_POSTLEITZAHL, 0, *Rec\POSTLEITZAHL)
      SetGadgetItemText(\txt_ORT, 0, *Rec\ORT)
      SetGadgetItemText(\txt_VORWAHL, 0, *Rec\VORWAHL)
      SetGadgetItemText(\txt_RUFNUMMER, 0, *Rec\RUFNUMMER)
      SetGadgetItemText(\txt_DURCHWAHL, 0, *Rec\DURCHWAHL)
      SetGadgetItemText(\txt_FAXNUMMER, 0, *Rec\FAXNUMMER)
      SetGadgetItemText(\txt_MINDESTBESTELLWERT, 0, Str(*Rec\MINDESTBESTELLWERT))
      SetGadgetItemText(\txt_TEXT, 0, *Rec\TEXT)
      SetGadgetItemText(\txt_ZAHLUNGSBEDINGUNGEN, 0, *Rec\ZAHLUNGSBEDINGUNGEN)
    EndWith 
  EndProcedure 
  
  ; MINKRIT
  Procedure RecToGadgets_MINKRIT(*Rec.TRec_MINKRIT)
    With Gadgets_MINKRIT
      SetGadgetItemText(\txt_ID, 0, Str(*Rec\ID))
      SetGadgetItemText(\txt_EXAKTKRITERIUM, 0, Str(*Rec\EXAKTKRITERIUM))
      SetGadgetItemText(\txt_MINDESTKRITERIUM, 0, Str(*Rec\MINDESTKRITERIUM))
      SetGadgetItemText(\txt_DE, 0, *Rec\TXT\DE)
      SetGadgetItemText(\txt_EN, 0, *Rec\TXT\EN)
      SetGadgetItemText(\txt_FR, 0, *Rec\TXT\FR)
      SetGadgetItemText(\txt_NL, 0, *Rec\TXT\NL)
      SetGadgetItemText(\txt_ES, 0, *Rec\TXT\ES)
      SetGadgetItemText(\txt_PL, 0, *Rec\TXT\PL)
      SetGadgetItemText(\txt_TR, 0, *Rec\TXT\TR)
    EndWith 
  EndProcedure 
  
  ; SERIEN
  Procedure RecToGadgets_SERIEN(*Rec.TRec_SERIEN)
    With Gadgets_SERIEN
      SetGadgetItemText(\txt_ID, 0, Str(*Rec\ID))
      SetGadgetItemText(\txt_HERSTELLER, 0, Str(*Rec\HERSTELLER))
      SetGadgetItemText(\txt_NAME, 0, *Rec\NAME)
      SetGadgetItemText(\txt_GERKLASS, 0, Str(*Rec\GERKLASS))
      SetGadgetItemText(\txt_ANTIQUE, 0, Str(*Rec\ANTIQUE))
    EndWith 
  EndProcedure 
  
  ; VNSKLASSE
  Procedure RecToGadgets_VNSKLASSE(*Rec.TRec_VNSKLASSE)
    With Gadgets_VNSKLASSE
      SetGadgetItemText(\txt_ID, 0, Str(*Rec\ID))
      SetGadgetItemText(\txt_PRODUKT, 0, *Rec\PRODUKT)
      SetGadgetItemText(\txt_NAME, 0, *Rec\NAME)
      SetGadgetItemText(\txt_ART, 0, *Rec\ART)
      SetGadgetItemText(\txt_KLASSE, 0, Str(*Rec\KLASSE))
      SetGadgetItemText(\txt_SUBKLASSE, 0, Str(*Rec\SUBKLASSE))
    EndWith 
  EndProcedure 
  
  ; ZUSGER_0
  Procedure RecToGadgets_ZUSGER_0(*Rec.TRec_ZUSGER_0)
    With Gadgets_ZUSGER_0
      SetGadgetItemText(\txt_HAUPTELEMENT, 0, Str(*Rec\HAUPTELEMENT))
      SetGadgetItemText(\txt_MINDESTKRITERIUM, 0, Str(*Rec\MINDESTKRITERIUM))
      SetGadgetItemText(\txt_KOMBINATION, 0, Str(*Rec\KOMBINATION))
      SetGadgetItemText(\txt_TEXT, 0, *Rec\TEXT)
    EndWith 
  EndProcedure 
  
  ; ZUSGER_1
  Procedure RecToGadgets_ZUSGER_1(*Rec.TRec_ZUSGER_1)
    With Gadgets_ZUSGER_1
      SetGadgetItemText(\txt_KOMBINATION, 0, Str(*Rec\KOMBINATION))
      SetGadgetItemText(\txt_ZAEHLER, 0, Str(*Rec\ZAEHLER))
      SetGadgetItemText(\txt_HILFSELEMENT, 0, Str(*Rec\HILFSELEMENT))
      SetGadgetItemText(\txt_ANZAHL, 0, Str(*Rec\ANZAHL))
    EndWith 
  EndProcedure 
  
EndModule



; IDE Options = PureBasic 6.00 LTS (Windows - x86)
; CursorPosition = 3940
; FirstLine = 3843
; Folding = ---------------
; CPU = 2