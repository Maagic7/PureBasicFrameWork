VERSION 5.00
Object = "{5E9E78A0-531B-11CF-91F6-C2863C385E30}#1.0#0"; "MSFLXGRD.OCX"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "comdlg32.ocx"
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "Mscomctl.ocx"

Begin VB.Form frmSplines 
   AutoRedraw      =   -1  'True
   BorderStyle     =   1  'Fixed Single
   Caption         =   " Curve di Interpolazione con Splines"
   ClientHeight    =   6540
   ClientLeft      =   150
   ClientTop       =   435
   ClientWidth     =   9510
   Icon            =   "Splines_01.frx":0000
   LinkTopic       =   "Form1"
   LockControls    =   -1  'True
   MaxButton       =   0   'False
   ScaleHeight     =   6540
   ScaleWidth      =   9510
   StartUpPosition =   2  'CenterScreen
   Begin VB.TextBox txtEditPunti 
      Appearance      =   0  'Flat
      BeginProperty Font 
         Name            =   "Courier New"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   7920
      TabIndex        =   25
      TabStop         =   0   'False
      ToolTipText     =   "Invio per confermare"
      Top             =   2040
      Visible         =   0   'False
      Width           =   1095
   End
   Begin VB.PictureBox picStampa 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BackColor       =   &H80000005&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   855
      Left            =   600
      ScaleHeight     =   855
      ScaleWidth      =   855
      TabIndex        =   21
      Top             =   840
      Visible         =   0   'False
      Width           =   855
   End
   Begin VB.PictureBox picQuadro 
      BackColor       =   &H00E0E0E0&
      Height          =   5700
      Left            =   255
      MouseIcon       =   "Splines_01.frx":0442
      MousePointer    =   99  'Custom
      ScaleHeight     =   5640
      ScaleWidth      =   6420
      TabIndex        =   20
      TabStop         =   0   'False
      Top             =   540
      Width           =   6480
      Begin VB.CheckBox chkSegnaPc 
         Alignment       =   1  'Right Justify
         BackColor       =   &H00E0E0E0&
         Caption         =   "&p:"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   5880
         MousePointer    =   1  'Arrow
         TabIndex        =   28
         ToolTipText     =   "Segna i punti della Spline"
         Top             =   60
         Width           =   495
      End
      Begin MSComDlg.CommonDialog CMDialog1 
         Left            =   1560
         Top             =   360
         _ExtentX        =   847
         _ExtentY        =   847
         _Version        =   393216
         CancelError     =   -1  'True
      End
      Begin VB.Label zLabel11 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         Caption         =   "y:"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   4620
         TabIndex        =   32
         Top             =   60
         Width           =   195
      End
      Begin VB.Label lblY 
         BorderStyle     =   1  'Fixed Single
         Height          =   255
         Left            =   4860
         TabIndex        =   31
         Top             =   60
         Width           =   735
      End
      Begin VB.Label zLabel10 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         Caption         =   "x:"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   3540
         TabIndex        =   30
         Top             =   60
         Width           =   195
      End
      Begin VB.Label lblX 
         BorderStyle     =   1  'Fixed Single
         Height          =   255
         Left            =   3780
         TabIndex        =   29
         Top             =   60
         Width           =   735
      End
      Begin VB.Shape shpPi 
         BorderColor     =   &H000000FF&
         BorderWidth     =   3
         Height          =   255
         Index           =   0
         Left            =   2640
         Shape           =   1  'Square
         Top             =   2040
         Width           =   255
      End
      Begin VB.Line linPi 
         BorderColor     =   &H000080FF&
         Index           =   0
         X1              =   3720
         X2              =   1920
         Y1              =   3240
         Y2              =   1200
      End
   End
   Begin MSComctlLib.TabStrip tabTipoI 
      Height          =   6255
      Left            =   135
      TabIndex        =   0
      Top             =   120
      Width           =   6735
      _ExtentX        =   11880
      _ExtentY        =   11033
      HotTracking     =   -1  'True
      _Version        =   393216
      BeginProperty Tabs {1EFB6598-857C-11D1-B16A-00C0F0283628} 
         NumTabs         =   4
         BeginProperty Tab1 {1EFB659A-857C-11D1-B16A-00C0F0283628} 
            Caption         =   "Be&zier"
            Key             =   "Bezier"
            ImageVarType    =   2
         EndProperty
         BeginProperty Tab2 {1EFB659A-857C-11D1-B16A-00C0F0283628} 
            Caption         =   "&B-Spline"
            Key             =   "B-Spline"
            ImageVarType    =   2
         EndProperty
         BeginProperty Tab3 {1EFB659A-857C-11D1-B16A-00C0F0283628} 
            Caption         =   "&C-Spline"
            Key             =   "C-Spline"
            ImageVarType    =   2
         EndProperty
         BeginProperty Tab4 {1EFB659A-857C-11D1-B16A-00C0F0283628} 
            Caption         =   "&T-Spline"
            Key             =   "T-Spline"
            ImageVarType    =   2
         EndProperty
      EndProperty
   End
   Begin VB.Frame zFrame2 
      Caption         =   "Scala del grafico:"
      Height          =   1935
      Left            =   7080
      TabIndex        =   23
      Top             =   4440
      Width           =   2295
      Begin VB.CommandButton cmdSG_OK 
         Caption         =   "OK"
         Height          =   255
         Left            =   120
         TabIndex        =   19
         Top             =   1560
         Width           =   2055
      End
      Begin VB.TextBox txtYmax 
         Height          =   285
         Left            =   1320
         TabIndex        =   18
         ToolTipText     =   "OK o Invio per confermare"
         Top             =   1080
         Width           =   855
      End
      Begin VB.TextBox txtYmin 
         Height          =   285
         Left            =   120
         TabIndex        =   16
         ToolTipText     =   "OK o Invio per confermare"
         Top             =   1080
         Width           =   855
      End
      Begin VB.TextBox txtXmax 
         Height          =   285
         Left            =   1320
         TabIndex        =   14
         ToolTipText     =   "OK o Invio per confermare"
         Top             =   480
         Width           =   855
      End
      Begin VB.TextBox txtXmin 
         Height          =   285
         Left            =   120
         TabIndex        =   12
         ToolTipText     =   "OK o Invio per confermare"
         Top             =   480
         Width           =   855
      End
      Begin VB.Label zLabel09 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "®"
         BeginProperty Font 
            Name            =   "Symbol"
            Size            =   9.75
            Charset         =   2
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   960
         TabIndex        =   27
         Top             =   1080
         Width           =   375
      End
      Begin VB.Label zLabel08 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "®"
         BeginProperty Font 
            Name            =   "Symbol"
            Size            =   9.75
            Charset         =   2
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   960
         TabIndex        =   26
         Top             =   480
         Width           =   375
      End
      Begin VB.Label zLabel06 
         BackStyle       =   0  'Transparent
         Caption         =   "Ym&ax"
         Height          =   255
         Left            =   1320
         TabIndex        =   17
         Top             =   840
         Width           =   615
      End
      Begin VB.Label zLabel05 
         BackStyle       =   0  'Transparent
         Caption         =   "&Ymin"
         Height          =   255
         Left            =   120
         TabIndex        =   15
         Top             =   840
         Width           =   735
      End
      Begin VB.Label zLabel04 
         BackStyle       =   0  'Transparent
         Caption         =   "X&max"
         Height          =   255
         Left            =   1320
         TabIndex        =   13
         Top             =   240
         Width           =   615
      End
      Begin VB.Label zLabel03 
         BackStyle       =   0  'Transparent
         Caption         =   "&Xmin"
         Height          =   255
         Left            =   120
         TabIndex        =   11
         Top             =   240
         Width           =   375
      End
   End
   Begin VB.Frame zFrame1 
      Caption         =   "Parametri della curva:"
      Height          =   1575
      Left            =   7080
      TabIndex        =   22
      Top             =   2760
      Width           =   2295
      Begin VB.CommandButton cmdKZ_OK 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   270
         Left            =   720
         Picture         =   "Splines_01.frx":0660
         Style           =   1  'Graphical
         TabIndex        =   10
         Top             =   1170
         UseMaskColor    =   -1  'True
         Visible         =   0   'False
         Width           =   270
      End
      Begin VB.TextBox txtKZ 
         Height          =   285
         Left            =   120
         TabIndex        =   9
         ToolTipText     =   "OK o Invio per confermare"
         Top             =   1170
         Visible         =   0   'False
         Width           =   615
      End
      Begin VB.TextBox txtNPC 
         Height          =   285
         Left            =   1320
         TabIndex        =   6
         ToolTipText     =   "OK o Invio per confermare"
         Top             =   720
         Width           =   615
      End
      Begin VB.CommandButton cmdNPC_OK 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   270
         Left            =   1920
         Picture         =   "Splines_01.frx":0B92
         Style           =   1  'Graphical
         TabIndex        =   7
         Top             =   720
         UseMaskColor    =   -1  'True
         Width           =   270
      End
      Begin VB.TextBox txtNPI 
         Height          =   285
         Left            =   120
         TabIndex        =   3
         ToolTipText     =   "OK o Invio per confermare"
         Top             =   720
         Width           =   615
      End
      Begin VB.CommandButton cmdNPI_OK 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   270
         Left            =   720
         Picture         =   "Splines_01.frx":10C4
         Style           =   1  'Graphical
         TabIndex        =   4
         Top             =   720
         UseMaskColor    =   -1  'True
         Width           =   270
      End
      Begin VB.Label lblKZ 
         BackStyle       =   0  'Transparent
         Caption         =   "Pa&rametro         NK o VZ"
         Height          =   375
         Left            =   1080
         TabIndex        =   8
         Top             =   1110
         Width           =   1215
      End
      Begin VB.Label zLabel01 
         BackStyle       =   0  'Transparent
         Caption         =   "N. di punti &sulla curva:"
         Height          =   465
         Left            =   1320
         TabIndex        =   5
         Top             =   240
         Width           =   855
      End
      Begin VB.Label zLabel02 
         BackStyle       =   0  'Transparent
         Caption         =   "N. di punti da &interpolare:"
         Height          =   465
         Left            =   120
         TabIndex        =   2
         Top             =   240
         Width           =   1035
      End
   End
   Begin MSFlexGridLib.MSFlexGrid grdPunti 
      Height          =   2265
      Left            =   7080
      TabIndex        =   1
      TabStop         =   0   'False
      Top             =   405
      Width           =   2295
      _ExtentX        =   4048
      _ExtentY        =   3995
      _Version        =   393216
      Cols            =   3
      AllowBigSelection=   0   'False
      ScrollTrack     =   -1  'True
      Enabled         =   -1  'True
      ScrollBars      =   2
      MousePointer    =   99
      MouseIcon       =   "Splines_01.frx":15F6
   End
   Begin VB.Label zLabel07 
      BackStyle       =   0  'Transparent
      Caption         =   "Punti da interpolare:"
      Height          =   255
      Left            =   7110
      TabIndex        =   24
      Top             =   165
      Width           =   1695
   End
   Begin VB.Menu mnuCurve 
      Caption         =   "Cur&ve"
      Begin VB.Menu mnuLeggiPunti 
         Caption         =   "&Leggi File di punti da interpolare"
      End
      Begin VB.Menu mnuSalvaCurva 
         Caption         =   "&Salva la curva su File"
      End
      Begin VB.Menu zSep01 
         Caption         =   "-"
      End
      Begin VB.Menu mnuStampa 
         Caption         =   "S&tampa"
      End
      Begin VB.Menu zSep02 
         Caption         =   "-"
      End
      Begin VB.Menu mnuEsci 
         Caption         =   "&Esci"
      End
   End
   Begin VB.Menu mnuQm 
      Caption         =   "&?"
      Begin VB.Menu mnuIstruzioni 
         Caption         =   "&Istruzioni"
      End
      Begin VB.Menu zSep03 
         Caption         =   "-"
      End
      Begin VB.Menu mnuInformazioni 
         Caption         =   "In&formazioni"
      End
   End
End
Attribute VB_Name = "frmSplines"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'=================================================================
' Descrizione.....: Programma per l' interpolazione con Splines.
' Nome dei Files..: Splines_01.frm, Splines_01.frx, Splines_01.bas
'                   frmStampaFCPB.frm, frmStampaFCPB.frx
'                   frmIstr.frm , frmIstr.frx
'                   InfoCr.frm , InfoCr.frx
' Data............: 27/11/1999
' Aggiornamento...: 11/10/2001
' Versione........: 1.0 a 32 bits
' Sistema.........: Visual Basic 6.0 sotto Windows NT.
' Scritto da......: F. Languasco ®
' E-Mail..........: MC7061@mclink.it
' DownLoads a.....: http://members.xoom.virgilio.it/flanguasco/
'                   http://www.flanguasco.org
'=================================================================
'
Option Explicit
'
Dim NPI&            ' N. di punti da interpolare.
Dim Pi() As P_Type  ' Vettore dei punti da interpolare.
Dim NPC&            ' N. di punti sulla curva.
Dim Pc() As P_Type  ' Vettore dei punti della curva.
Dim NK&             ' N. di nodi per B-Spline.
Dim VZ&             ' Tensione della curva T-Spline.
'
Dim TipoI$          ' Tipo di interpolazione attiva.
'
Dim ShOx!, ShOy!    ' Offset del centro degli
                    ' indicatori dei punti.
Dim PSel&           ' Indice del punto selezionato.
'
Dim Xmin!, Xmax!    ' Coordinate minime e massime
Dim Ymin!, Ymax!    ' del Quadro.
'
Dim DirNome$        ' Folder dei Files di Splines.
Const PExt$ = "dat" ' Estensione, preferita, per i
                    ' Files di tipo Splines.
'
'
Const PxM! = 2!     ' Definizione, per la stampa, in [Pixel/mm].
                    ' Valori grandi rallentano la stampa.
                    ' Per Windows 98, in caso di errore, diminuire PxM.
'
Const BZ$ = ""
Const CS$ = ""
Const BS$ = "N. di &nodi" & vbNewLine & "2 <= NK <= NPI"
Const TS$ = "Te&nsione" & vbNewLine & "1 <= VZ <= 100"
'
Dim RS1&                ' Posizionamenti per l' "editing"
Dim CS1&                ' delle coordinate dei punti
Dim RS1_O&              ' nella tabella.
Dim CS1_O&              '
'
Dim grdPunti_Left&      '
Dim grdPunti_Top&       '
'
Dim NoPaint As Boolean  ' Evita gli eventi multipli di Paint.
'
Const PCHL& = &HC0FFFF  ' Colore di evidenza per le etichette di Posizione cursore.
'
'--- GetLocale: ----------------------------------------------------------------
Private Declare Function GetLocaleInfo Lib "kernel32" Alias "GetLocaleInfoA" _
(ByVal Locale As Long, ByVal LCType As Long, ByVal lpLCData As String _
, ByVal cchData As Long) As Long
Private Declare Function GetThreadLocale Lib "kernel32" () As Long
'
Private Const LOCALE_SDECIMAL& = &HE
Private Const LOCALE_STHOUSAND& = &HF
Private Const LOCALE_SDATE& = &H1D
Private Const LOCALE_STIME& = &H1E
Private Sub GetLocale(Optional ByRef DS$, Optional ByRef MS$ _
    , Optional ByRef GS$, Optional ByRef TS$)
'
'   Trova i separatori del sistema:
'    DS$:   separatore decimale.
'    MS$:   separatore delle migliaia.
'    GS$:   separatore dei giorni.
'    TS$:   separatore delle ore.
'
    DS$ = "  "
    MS$ = "  "
    GS$ = "  "
    TS$ = "  "
'
    GetLocaleInfo GetThreadLocale(), LOCALE_SDECIMAL, DS$, Len(DS$)
    GetLocaleInfo GetThreadLocale(), LOCALE_STHOUSAND, MS$, Len(MS$)
    GetLocaleInfo GetThreadLocale(), LOCALE_SDATE, GS$, Len(GS$)
    GetLocaleInfo GetThreadLocale(), LOCALE_STIME, TS$, Len(TS$)
'
    DS$ = Left$(DS$, 1)
    MS$ = Left$(MS$, 1)
    GS$ = Left$(GS$, 1)
    TS$ = Left$(TS$, 1)
'
'
'
End Sub
Private Function KAscNumInteri(ByVal KA% _
    , Optional ByVal NEG As Boolean = False) As Integer
'
'   Ritorna solo i caratteri validi per un campo
'   contenente un numero intero (anche negativo se
'   viene passato il valore Neg = True).
'   Tutti gli altri caratteri vengono annullati.
'   Va' usato nella procedura KeyPress di TextB come:
'   KeyAscii = KAscNumInteri(KeyAscii [, Neg])
'
    Dim KeyMinus%
    Dim TextB As TextBox    ' Solo per TextBoxes.
    'Dim TextB As Control    ' Anche per Combo, etc...
'
    Const myKeyMinus% = 45  ' E' il valore effettivamente ritornato
                            ' alla pressione del tasto - ;
                            ' vbKeySubtract (= 109) non funziona.
'
    Set TextB = Screen.ActiveControl
'
    ' Filtro per il segno "-":
    If (Left$(TextB.Text, 1) <> "-" Or TextB.SelText = TextB.Text) _
    And NEG And TextB.SelStart = 0 Then KeyMinus = myKeyMinus
'
    Select Case KA
        Case vbKey0 To vbKey9, KeyMinus, vbKeyBack
        KAscNumInteri = KA
'
        Case Else
        KAscNumInteri = 0
    End Select
'
'
'
End Function

Private Function KAscNumReali(ByVal KA As Integer _
    , Optional ByVal NEG As Boolean = False) As Integer
'
'   Ritorna solo i caratteri validi per un campo
'   contenente un numero reale (anche negativo se
'   viene passato il valore Neg = True).
'   Tutti gli altri caratteri vengono annullati.
'   Usa le impostazioni locali del separatore decimale.
'   Va' usato nella procedura KeyPress di TextB come:
'   KeyAscii = KAscNumReali(KeyAscii [, Neg])
'   Questa versione accetta anche numeri in notazione
'   scientifica.
'
    Dim KeyDecimal%, KeyMinus%, KeyE%
    Dim TextB As TextBox    ' Solo per TextBoxes.
    'Dim TextB As Control    ' Anche per Combo, etc...
    Dim SD$, SM$, myKeyDecimal%
'
    Const myKeyMinus% = 45      ' E' il valore effettivamente ritornato
                                ' alla pressione del -;
                                ' vbKeySubtract (= 109)  non funziona.
    GetLocale SD$, SM$          ' Trova le impostazioni locali dei
    myKeyDecimal% = Asc(SD$)    ' separatori decimale e delle migliaia.
'
    Set TextB = Screen.ActiveControl
'
    ' Filtro per il separatore decimale:
    If (InStr(TextB.Text, SD$) = 0 _
    And Not (TextB.SelStart = 0 And Left$(TextB.Text, 1) = "-")) _
    Or TextB.SelText = TextB.Text Then KeyDecimal = myKeyDecimal
'
    ' Filtro per il segno "-":
    If (Left$(TextB.Text, 1) <> "-" Or TextB.SelText = TextB.Text) _
    And NEG And TextB.SelStart = 0 Then KeyMinus = myKeyMinus
'
    ' Filtro per la notazione scientifica:
    If TextB.SelStart > 0 Then
        KA = Asc(UCase$(Chr$(KA)))
        If (InStr(TextB.Text, "E") = 0 _
        And Not (TextB.SelStart = 0 Or TextB.SelText = TextB.Text)) _
        And Mid$(TextB.Text, TextB.SelStart, 1) <> "-" Then KeyE = vbKeyE
'
        If Mid$(TextB.Text, TextB.SelStart, 1) = "E" Then KeyMinus = myKeyMinus
'
        If (InStr(TextB.Text, "E") > 0) _
        And (TextB.SelStart - InStr(TextB.Text, "E") >= 0) Then KeyDecimal = 0
    End If
'
    Select Case KA
        Case vbKey0 To vbKey9, KeyDecimal, KeyMinus, vbKeyBack, KeyE
        KAscNumReali = KA
'
        Case Else
        KAscNumReali = 0
    End Select
'
'
'
End Function

Private Sub chkSegnaPc_Click()
'
'
    picQuadro.Cls
    DisegnaCurva picQuadro
'
    chkSegnaPc.ToolTipText = Switch( _
    chkSegnaPc = vbUnchecked, "Segna i punti della Spline", _
    chkSegnaPc = vbChecked, "Nascondi i punti della Spline")
'
'
'
End Sub

Private Sub cmdKZ_OK_Click()
'
'
    Select Case TipoI$
        Case "B-Spline"
        If Val(txtKZ) >= 2 And Val(txtKZ) <= NPI Then
            NK = Val(txtKZ)
            picQuadro.Refresh
        Else
            txtKZ = NK
        End If
'
        Case "T-Spline"
        If Val(txtKZ) >= 1 And Val(txtKZ) <= 100 Then
            VZ = Val(txtKZ)
            picQuadro.Refresh
        Else
            txtKZ = VZ
        End If
    End Select
'
'
'
End Sub

Private Sub cmdNPI_OK_Click()
'
'
    If Val(txtNPI) >= 3 Then
        NPI = Val(txtNPI)
        If NK > NPI Then
            NK = NPI
            If TipoI$ = "B-Spline" Then txtKZ = NK
        End If
        ReDim Preserve Pi(0 To NPI - 1) ' As P_Type
        AggiornaPunti
        PosizionaPunti
    Else
        txtNPI = NPI
    End If
'
'
'
End Sub

Private Sub cmdSG_OK_Click()
'
'
    Dim X1!, X2!, Y1!, Y2!
'
    If VerificaSG(X1!, Y1!, X2!, Y2!) Then
        Xmin = X1
        Xmax = X2
        Ymin = Y1
        Ymax = Y2
'
        Quadro picQuadro, Xmin, Xmax, Ymin, Ymax, , , 2, ShOx, ShOy, , "x", "y"
        PosizionaPunti
    End If
'
'
'
End Sub

Private Sub cmdNPC_OK_Click()
'
'
    If Val(txtNPC) >= 2 Then
        NPC = Val(txtNPC)
        picQuadro.Refresh
    Else
        txtNPC = NPC
    End If
'
'
'
End Sub

Private Sub Form_Load()
'
'
    Dim CMDFilter$
'
    NPI = 6     ' N. di punti da interpolare.
    txtNPI = NPI
    NPC = 100   ' N. di punti sulla curva.
    txtNPC = NPC
'
    NK = 3      ' N. di nodi per B-Spline.
    VZ = 30     ' Tensione della curva T-Spline
'
    ' Coordinate dei punti di prova:
    ReDim Pi(0 To NPI - 1) ' As P_Type
    Pi(0).X = -10: Pi(0).Y = -3.5
    Pi(1).X = 3: Pi(1).Y = 3
    Pi(2).X = 3: Pi(2).Y = -0.01
    Pi(3).X = 5: Pi(3).Y = 3
    Pi(4).X = 7: Pi(4).Y = -4.2
    Pi(5).X = 10: Pi(5).Y = 4
'
    ' Dimensiona il quadro:
    Xmin = -10
    txtXmin = Xmin
    Ymin = -5
    txtYmin = Ymin
    Xmax = 10
    txtXmax = Xmax
    Ymax = 5
    txtYmax = Ymax
    Quadro picQuadro, Xmin, Xmax, Ymin, Ymax, , , 2, ShOx, ShOy, , "x", "y"
'
    ' Tipo di interpolazione iniziale:
    tabTipoI.Tabs("Bezier").Selected = True
'
    ' Dimensioni degli indicatori dei punti:
    shpPi(0).Width = picQuadro.ScaleX(6, vbPixels, vbUser)
    shpPi(0).Height = Abs(picQuadro.ScaleY(6, vbPixels, vbUser))
'
    ' Grafico dei punti:
    AggiornaPunti
    PosizionaPunti
'
    ' Dimensioni e titoli della tabella:
    With grdPunti
        .Cols = 3
        .ColAlignment(0) = flexAlignRightCenter
        .ColAlignment(1) = flexAlignRightCenter
        .FixedAlignment(0) = flexAlignRightCenter
        .FixedAlignment(1) = flexAlignRightCenter
        .FixedAlignment(2) = flexAlignRightCenter
'
        .ColWidth(0) = 420
        .ColWidth(1) = 765
        .ColWidth(2) = 765
'
        .Row = 0
        .Col = 0
        .Text = "I"
        .Col = 1
        .Text = "Pi(I).x"
        .Col = 2
        .Text = "Pi(I).y"
'
        grdPunti_Left = .Left + 45
        grdPunti_Top = .Top + 45
    End With
'
    ' Predisposizioni alle operazioni su file:
    DirNome$ = App.Path
    CMDFilter$ = "Dati per Splines (*." & PExt$ & ")|*." & PExt$
    CMDFilter$ = CMDFilter$ & "|Tutti i Files (*.*)|*.*"
    CMDialog1.Filter = CMDFilter$
    ' Nasconde casella Read Only, controlla esistenza Files
    ' e avverte per sovrascrittura Files:
    CMDialog1.Flags = cdlOFNHideReadOnly + cdlOFNFileMustExist _
    + cdlOFNOverwritePrompt
'
'
'
End Sub
Private Sub AggiornaPosizioniCursore(ByVal sVal1$, ByVal sVal2$)
'
'   Aggiorna i valori delle finestrelle di posizione
'   del cursore ed imposta il colore di evidenziazione:
'
    lblX = sVal1$
    lblY = sVal2$
'
    lblX.BackColor = IIf(sVal1$ = "", vbButtonFace, PCHL)
    lblY.BackColor = IIf(sVal2$ = "", vbButtonFace, PCHL)
'
'
'
End Sub

Private Sub PosizionaPunti()
'
'   Posiziona, sul grafico, Shapes e Lines:
'
    Dim I&
'
    NoPaint = True
    For I = 0 To NPI - 2
        shpPi(I).Left = Pi(I).X - ShOx
        shpPi(I).Top = Pi(I).Y + ShOy
        linPi(I).X1 = Pi(I).X
        linPi(I).Y1 = Pi(I).Y
        linPi(I).X2 = Pi(I + 1).X
        linPi(I).Y2 = Pi(I + 1).Y
    Next I
    shpPi(NPI - 1).Left = Pi(NPI - 1).X - ShOx
    shpPi(NPI - 1).Top = Pi(NPI - 1).Y + ShOy
'
    NoPaint = False
    picQuadro.Refresh
'
'
'
End Sub
Private Function TrovaPunto(ByVal X!, ByVal Y!) As Long
'
'   Ritorna l' indice della Shape visivamente
'   piu' vicina alle coordinate x, y:
'
    Dim I&, Xc!, Yc!, DsQ!, DisQ!, ShOx2!, ShOy2!
'
    ShOx2 = ShOx * ShOx
    ShOy2 = ShOy * ShOy
    DisQ = 1E+38
'
    For I = 0 To NPI - 1
        Xc = shpPi(I).Left + ShOx
        Yc = shpPi(I).Top - ShOy
        DsQ = (X - Xc) * (X - Xc) / ShOx2 _
            + (Y - Yc) * (Y - Yc) / ShOy2
        If DisQ > DsQ Then
            DisQ = DsQ
            TrovaPunto = I
        End If
    Next I
'
'
'
End Function


Private Sub Form_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
'
'
    AggiornaPosizioniCursore "", ""
'
'
'
End Sub

Private Sub Form_Unload(Cancel As Integer)
'
'
    End
'
'
'
End Sub

Private Sub grdPunti_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
'
'
    RS1 = grdPunti.Row
    CS1 = grdPunti.Col
    txtEditPunti.Visible = False
'
'
'
End Sub


Private Sub grdPunti_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
'
'
    grdPunti.Row = RS1
    grdPunti.Col = CS1
    txtEditPunti.Text = grdPunti.Text
'
    txtEditPunti.Left = grdPunti.ColPos(CS1) + grdPunti_Left
    txtEditPunti.Top = grdPunti.RowPos(RS1) + grdPunti_Top
    txtEditPunti.Width = grdPunti.ColWidth(CS1) - 15
    txtEditPunti.Height = grdPunti.RowHeight(RS1) - 15
    txtEditPunti.Visible = True
    txtEditPunti.SetFocus
'
    RS1_O = RS1
    CS1_O = CS1
'
'
'
End Sub


Private Sub mnuIstruzioni_Click()
'
'
    frmIstruzioni.Apri App.Path & "\Istr.rtf"
'
'
'
End Sub

Private Sub mnuEsci_Click()
'
'
    End
'
'
'
End Sub

Private Sub mnuInformazioni_Click()
'
'
    frmCopyright.Apri Me, vbModal
'
'
'
End Sub

Private Sub mnuLeggiPunti_Click()
'
'
    Dim FN_Temp$, M$
'
    On Error GoTo mnuLeggiPunti_ERR
'
    CMDialog1.DialogTitle = " Legge i punti da interpolare"
    CMDialog1.InitDir = DirNome$
    CMDialog1.ShowOpen
    FN_Temp$ = CMDialog1.FileName
'
    If BreakDown(FN_Temp$, DirNome$) Then
        LeggiPunti FN_Temp$
    End If
'
    Exit Sub
'
'
mnuLeggiPunti_ERR:
    If Err <> cdlCancel Then
        M$ = "Errore " & Str$(Err.Number) & vbNewLine
        M$ = M$ & Err.Description
        MsgBox M$, vbCritical, "Errore in mnuLeggiPunti " & Err.Source
    End If
'
'
'
End Sub

Private Sub mnuSalvaCurva_Click()
'
'
    Dim FN_Temp$, M$
'
    On Error GoTo mnuSalvaCurva_ERR
'
    CMDialog1.DialogTitle = " Salva i punti della curva Spline"
    CMDialog1.FileName = "*." & PExt$
    CMDialog1.InitDir = DirNome$
    CMDialog1.ShowSave
    FN_Temp$ = CMDialog1.FileName
'
    BreakDown FN_Temp$, DirNome$
    SalvaCurva FN_Temp$
'
    Exit Sub
'
'
mnuSalvaCurva_ERR:
    If Err <> cdlCancel Then
        M$ = "Errore " & Str$(Err.Number) & vbNewLine
        M$ = M$ & Err.Description
        MsgBox M$, vbCritical, "Errore in mnuSalvaCurva " & Err.Source
    End If
'
'
'
End Sub
Private Function BreakDown(ByVal Full$, Optional ByRef PName$ _
    , Optional ByRef FName$, Optional ByRef Ext$) As Boolean
'
'   Scompone un nome di File completo di Path nelle sue parti:
'   Full$  = Nome completo del File.
'   PName$ = Path del File.
'   FName$ = Nome del File con Estensione.
'   Ext$   = .Estensione del File.
'
'   Se il File non esiste scompone il nome e ritorna False.
'
    Dim Sloc&, Dot&
'
    BreakDown = Len(Dir$(Full$))
'
    If InStr(Full$, "\") Then
        FName$ = Full$
        PName$ = ""
        Sloc = InStr(FName$, "\")
        Do While Sloc <> 0
            PName$ = PName$ & Left$(FName$, Sloc)
            FName$ = Mid$(FName$, Sloc + 1)
            Sloc = InStr(FName$, "\")
        Loop
    Else
        PName$ = ""
        FName$ = Full$
    End If
'
    Dot = InStr(Full$, ".")
    If Dot <> 0 Then
        Ext$ = Mid$(Full$, Dot)
    Else
        Ext$ = ""
    End If
'
'
'
End Function
Private Sub mnuStampa_Click()
'
'   Per stampare l' immagine del grafico e'
'   necessario aggiungere al progetto il file
'   frmStampaFCPB reperibile a:
'    http://members.xoom.virgilio.it/flanguasco/
'    http://www.flanguasco.org
'
'   Eliminare quindi il MsgBox seguente ed
'   i delimitatori di commento dal codice successivo...
'
    MsgBox "Manca il Form di stampa frmStampaFCPB." & vbNewLine _
         & "Vedere le istruzioni a mnuStampa_Click," _
         , vbInformation, " Errore in Stampa"
''
'    Dim DocW&, DocH&
''
'    frmStampaFCPB.FoglioStampa DocW, DocH, vbPRORLandscape
'    picStampa.Move 0, 0 _
'    , ScaleX(PxM * DocW, vbPixels, Me.ScaleMode) _
'    , ScaleY(PxM * DocH, vbPixels, Me.ScaleMode)
''
'    Quadro picStampa, Xmin, Xmax, Ymin, Ymax, , , , , , TipoI$, "x", "y", True
'    DisegnaPunti picStampa
'    DisegnaCurva picStampa
''
'    frmStampaFCPB.StampaFCPB picStampa, 0, 0, DocW, DocH, , TipoI$, 1
'
'
'
End Sub
Private Function Ceil(ByVal X As Double) As Double
'
'   Funzione di arrotondamento, per numeri reali,
'   all' intero uguale o immediatamente superiore:
'
    If X = Int(X) Then
        Ceil = X
    Else
        Ceil = Int(X) + 1#
    End If
'
'
'
End Function
Private Sub picQuadro_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
'
'
    If Button = vbLeftButton Then
        PSel = TrovaPunto(X, Y)
        picQuadro_MouseMove Button, Shift, X, Y
    End If
'
'
'
End Sub


Private Sub picQuadro_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
'
'
    If Button = vbLeftButton Then
        NoPaint = True
        shpPi(PSel).Move X - ShOx, Y + ShOy
'
        If PSel = 0 Then
            linPi(0).X1 = X
            linPi(0).Y1 = Y
        ElseIf PSel = NPI - 1 Then
            linPi(PSel - 1).X2 = X
            linPi(PSel - 1).Y2 = Y
        Else
            linPi(PSel).X1 = X
            linPi(PSel).Y1 = Y
            linPi(PSel - 1).X2 = X
            linPi(PSel - 1).Y2 = Y
        End If
        NoPaint = False
'
        Pi(PSel).X = X
        Pi(PSel).Y = Y
        With grdPunti
            .Row = PSel + 1
            .Col = 1
            .Text = Format$(Pi(PSel).X, "#0.000")
            .Col = 2
            .Text = Format$(Pi(PSel).Y, "#0.000")
        End With
'
    ElseIf Button = 0 Then
        picQuadro.ToolTipText = ""
        picQuadro.ToolTipText = "Muovi il punto " & TrovaPunto(X, Y)
    End If
'
    AggiornaPosizioniCursore Format$(X, "#0.###"), Format$(Y, "#0.###")
'
'
'
'
'
'
End Sub


Private Sub picQuadro_Paint()
'
'
    picQuadro.Cls
'
    If Not NoPaint Then DisegnaCurva picQuadro
'
'
'
End Sub


Private Sub tabTipoI_Click()
'
'
    TipoI$ = tabTipoI.SelectedItem.Key
'
    Select Case TipoI$
        Case "Bezier"
        txtKZ.Visible = False
        cmdKZ_OK.Visible = False
        lblKZ = BZ$
'
        Case "B-Spline"
        txtKZ = NK
        txtKZ.Visible = True
        cmdKZ_OK.Visible = True
        lblKZ = BS$
'
        Case "C-Spline"
        txtKZ.Visible = False
        cmdKZ_OK.Visible = False
        lblKZ = CS$
'
        Case "T-Spline"
        txtKZ = VZ
        txtKZ.Visible = True
        cmdKZ_OK.Visible = True
        lblKZ = TS$
    End Select
'
    ' Calcola e disegna
    ' la curva Spline:
    picQuadro.Refresh
'
'
'
End Sub

Private Sub tabTipoI_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
'
'
    AggiornaPosizioniCursore "", ""
'
'
'
End Sub

Private Sub txtEditPunti_KeyPress(KeyAscii As Integer)
'
'
    Select Case KeyAscii
        Case vbKeyEscape
        txtEditPunti.Text = ""
        txtEditPunti.Visible = False
        KeyAscii = 0
'
        Case vbKeyReturn
        txtEditPunti.Visible = False
        KeyAscii = 0
'
        Case Else
        KeyAscii = KAscNumReali(KeyAscii, True)
    End Select
'
'
'
End Sub
Private Sub txtEditPunti_LostFocus()
'
'
    Dim X!, Y!
'
    If txtEditPunti.Text <> "" Then
        grdPunti.Row = RS1_O
        PSel = RS1_O - 1
'
        Select Case CS1_O
            Case 1
            grdPunti.Col = 2
            X = Val(txtEditPunti.Text)
            Y = Val(grdPunti.Text)
'
            Case 2
            grdPunti.Col = 1
            X = Val(grdPunti.Text)
            Y = Val(txtEditPunti.Text)
        End Select
'
        picQuadro_MouseMove vbLeftButton, 0, X, Y
    End If
'
    txtEditPunti.Visible = False
    txtEditPunti.Text = ""
'
'
'
End Sub


Private Sub txtKZ_KeyPress(KeyAscii As Integer)
'
'
    If KeyAscii = vbKeyReturn Then cmdKZ_OK_Click
    KeyAscii = KAscNumInteri(KeyAscii)
'
'
'
End Sub


Private Sub txtNPI_KeyPress(KeyAscii As Integer)
'
'
    If KeyAscii = vbKeyReturn Then cmdNPI_OK_Click
    KeyAscii = KAscNumInteri(KeyAscii)
'
'
'
End Sub


Private Sub txtNPC_KeyPress(KeyAscii As Integer)
'
'
    If KeyAscii = vbKeyReturn Then cmdNPC_OK_Click
    KeyAscii = KAscNumInteri(KeyAscii)
'
'
'
End Sub



Private Function Quadro(ByVal Foglio As PictureBox _
    , ByVal X0!, ByVal Xn!, ByVal Y0!, ByVal Yn! _
    , Optional ByVal FormatVX$ = "#0.0##" _
    , Optional ByVal FormatVY$ = "#0.0##" _
    , Optional ByVal Npx& = 1, Optional PxN_X!, Optional PxN_Y! _
    , Optional ByVal Titolo$ = "" _
    , Optional ByVal UnitaX$ = "" _
    , Optional ByVal UnitaY$ = "" _
    , Optional ByVal AutoRed As Boolean = False) As Boolean
'
'   Routine, di uso generale, per la scalatura di un foglio
'   adatto a rappresentare un grafico y = f(x).
'    Foglio:    PictureBox da scalare.
'    X0:        Valore minimo di ascissa da rappresentare.
'    Xn:        Valore massimo di ascissa da rappresentare.
'               Deve essere X0 < Xn.
'    Y0:        Valore minimo di ordinata da rappresentare.
'    Yn:        Valore massimo di ordinata da rappresentare.
'               Deve essere Y0 <= Yn.
'    FormatVX$: Stringa di formato dei valori sull' asse X.
'    FormatVY$: Stringa di formato dei valori sull' asse Y.
'    Npx:       N° di Pixels di cui si vuole conoscere
'    PxN_X:      larghezza in [vbUser] e
'    PxN_Y:      altezza in [vbUser].
'    Titolo$:   Titolo del grafico.
'    UnitaX$:   Unita' (o titolo) dell' asse X.
'    UnitaY$:   Unita' (o titolo) dell' asse Y.
'    AutoRed:   Stato di Foglio.AutoRedraw dopo il disegno del quadro.
'
    Dim I&, Xi!, D_X!, rrx!, Yi!, D_Y!, rry!, Tx$
    Dim QxMin!, QxMax!, QyMin!, QyMax!, b0!, bn!, TxW!
    Dim TitL!, TitT!, TitW!, TitH!, Po4_X!, Po4_Y!
    Const Log10! = 2.30258509299405 ' Log(10#)
    Const DYMin! = 0.0001           ' Ampiezza min. della scala Y.
'
    On Error GoTo Quadro_ERR
    ' Verifica la correttezza delle scale:
    If X0 >= Xn Then Err.Raise 1001, "Quadro", "Errore di scala X."
    If Y0 > Yn Then Err.Raise 1001, "Quadro", "Errore di scala Y."
'
    ' Imposta i dati di Font dei valori
    ' degli assi:
    Foglio.FontName = "MS Sans Serif"
    Foglio.FontSize = 8
    Foglio.FontBold = False
'
    ' Calcola la spaziatura dei valori scritti
    ' sull' asse X: la sequenza e' 1, 2, 2.5 e 5:
    D_X = Xn - X0
    rrx = 10! ^ Ceil(Log(D_X / 20!) / Log10)
    Do While D_X / rrx < 5!
        rrx = rrx / 2!
    Loop
    If D_X / rrx > 10! Then rrx = rrx * 2!
    X0 = rrx * Int(Round(X0 / rrx, 3))
    Xn = rrx * Ceil(Round(Xn / rrx, 3))
    D_X = Xn - X0
'
    ' Imposta una scala minima
    ' per l' asse Y:
    If Yn - Y0 < DYMin Then
        Y0 = Y0 - DYMin / 2!
        Yn = Yn + DYMin / 2!
    End If
'
    ' Calcola la spaziatura dei valori scritti
    ' sull' asse Y: la sequenza e' 1, 2, 2.5 e 5:
    D_Y = Yn - Y0
    rry = 10! ^ Ceil(Log(D_Y / 20!) / Log10)
    Do While D_Y / rry < 5!
        rry = rry / 2!
    Loop
    If D_Y / rry > 10! Then rry = rry * 2!
    Y0 = rry * Int(Round(Y0 / rry, 3))
    Yn = rry * Ceil(Round(Yn / rry, 3))
    D_Y = Yn - Y0
'
    ' Il bordo a destra dipende dalla
    ' presenza, o meno, di un' etichetta:
    If UnitaX$ = "" Then
        bn = D_X / 20!
    Else
        bn = D_X / 10!
    End If
'
    ' Il bordo a sinistra deve essere sufficiente
    ' a contenere il valore Y piu' largo:
    TxW = Foglio.TextWidth(Format$(Y0, FormatVY$) & " ")
    If TxW < Foglio.TextWidth(Format$(Yn, FormatVY$) & " ") Then
        TxW = Foglio.TextWidth(Format$(Yn, FormatVY$) & " ")
    End If
    b0 = TxW * (D_X + bn) / (Foglio.ScaleWidth - TxW)
    If b0 < D_X / 10! Then b0 = D_X / 10!
'
    ' Imposta i bordi orizzontali
    ' e verticali:
    QxMin = X0 - b0
    QxMax = Xn + bn
    QyMin = Y0 - D_Y / 10!
    QyMax = Yn + D_Y / 7!
'
    ' Cancella il Foglio e imposta la scala:
    Foglio.Picture = LoadPicture("")
    Foglio.Scale (QxMin, QyMax)-(QxMax, QyMin)
    ' La scalatura deve essere permanente:
    Foglio.AutoRedraw = True
    ' Calcola larghezza ed altezza di Npx pixels:
    PxN_X = Abs(Foglio.ScaleX(Npx, vbPixels, vbUser))
    PxN_Y = Abs(Foglio.ScaleY(Npx, vbPixels, vbUser))
    ' Calcola larghezza ed altezza di 4 points:
    Po4_X = Foglio.ScaleX(4, vbPoints, vbUser)
    Po4_Y = Foglio.ScaleY(4, vbPoints, vbUser)
'
    Foglio.DrawMode = vbCopyPen
    Foglio.DrawWidth = 1
    Foglio.DrawStyle = vbDash
    Foglio.ForeColor = vbGreen
    ' Traccia la griglia verticale e scrive
    ' i valori dell' asse X:
    For Xi = X0 To Xn + 0.1 * rrx Step rrx
        Foglio.Line (Xi, Y0)-(Xi, Yn), vbGreen
        Tx$ = Format$(Xi, FormatVX$)
        ' Verifica che il formato scelto non
        ' induca ad errori di rappresentazione:
        If Abs(Xi - Val(Tx$)) < rrx / 10 Then
            Foglio.CurrentX = Xi - Foglio.TextWidth(Tx$) / 2!
            Foglio.CurrentY = Y0 - D_Y / 70!
            Foglio.Print Tx$;
        End If
    Next Xi
    ' Scrive l' etichetta dell' asse X:
    If UnitaX$ <> "" Then
        ' Etichetta tutta a destra:
        'Foglio.CurrentX = QxMax - Foglio.TextWidth(UnitaX$ & " ")
        ' Etichetta in centro tra l' ultimo valore ed il bordo a destra:
        Foglio.CurrentX = (Foglio.CurrentX + QxMax - Foglio.TextWidth(UnitaX$)) / 2!
        Foglio.Print UnitaX$;
    End If
    ' Traccia l' asse Y:
    If (X0 <= 0!) And (0! <= Xn) Then
        Foglio.DrawStyle = vbSolid
        Foglio.Line (0!, Y0)-(0!, QyMax - D_Y / 30!), vbGreen
        Foglio.Line (0!, QyMax - D_Y / 30!) _
                   -(-Po4_X / 2!, Po4_Y + QyMax - D_Y / 30!), vbGreen
        Foglio.Line (0!, QyMax - D_Y / 30!) _
                   -(Po4_X / 2!, Po4_Y + QyMax - D_Y / 30!), vbGreen
    End If
'
    Foglio.DrawStyle = vbDash
    ' Traccia la griglia orizzontale e scrive
    ' i valori dell' asse Y:
    For Yi = Y0 To Yn + 0.1 * rry Step rry
        Foglio.Line (X0, Yi)-(Xn, Yi), vbGreen
        Tx$ = Format$(Yi, FormatVY$)
        Foglio.CurrentX = QxMin
        Foglio.CurrentY = Yi - Foglio.TextHeight(Tx$) / 2!
        Foglio.Print Tx$;
    Next Yi
    ' Scrive l' etichetta dell' asse Y:
    If UnitaY$ <> "" Then
        Foglio.CurrentX = QxMin
        Foglio.CurrentY = QyMax
        Foglio.Print UnitaY$;
    End If
    ' Traccia l' asse X:
    If (Y0 <= 0!) And (0! <= Yn) Then
        Foglio.DrawStyle = vbSolid
        Foglio.Line (X0, 0!)-(QxMax - D_X / 30!, 0!), vbGreen
        Foglio.Line (QxMax - D_X / 30!, 0!) _
                   -(QxMax - D_X / 30! - Po4_X, -Po4_Y / 2!), vbGreen
        Foglio.Line (QxMax - D_X / 30!, 0!) _
                   -(QxMax - D_X / 30! - Po4_X, Po4_Y / 2!), vbGreen
    End If
'
    ' Scrive il titolo del grafico:
    If Titolo$ <> "" Then
        Foglio.FontSize = 12
        Foglio.FontBold = True
        Foglio.ForeColor = vbRed
'
        TitW = Foglio.TextWidth(Titolo$)
        TitH = Foglio.TextHeight(Titolo$)
        ' Verifica che il titolo stia tutto nel Foglio:
        If TitW <= Foglio.ScaleWidth Then
            TitL = (QxMin + QxMax - TitW) / 2!
        ' e se no' lo taglia:
        Else
            TitL = Foglio.ScaleLeft
            Tx$ = " . . . ."
            Titolo$ = Left$(Titolo$, Int(Len(Titolo$) * _
            (Foglio.ScaleWidth - Foglio.TextWidth(Tx$)) / TitW)) & Tx$
        End If
        TitT = QyMax
        ' Cancella l' area su cui andra' scritto il titolo:
        'Foglio.Line (TitL, TitT)-(TitL + TitW, TitT + TitH), Foglio.BackColor, BF
        Foglio.CurrentX = TitL
        Foglio.CurrentY = TitT
        Foglio.Print Titolo$
    End If
'
    Foglio.DrawStyle = vbSolid
    Foglio.AutoRedraw = AutoRed
'
'
Quadro_ERR:
    Quadro = (Err = 0)
    If Err <> 0 Then
        MsgBox Err.Description, vbCritical, Err.Source
    End If
'
'
'
End Function

Private Sub DisegnaPunti(ByVal PicB As PictureBox)
'
'   Disegna sul Quadro i punti da interpolare.
'   Usato solo per la stampa con picB = picStampa:
'
    Dim rc!, I&
'
    rc = PicB.ScaleX(3, vbPixels, vbUser)
'
    PicB.Circle (Pi(0).X, Pi(0).Y), rc, vbRed
    For I = 1 To NPI - 1
        PicB.Line -(Pi(I).X, Pi(I).Y), vbRed
        PicB.Circle (Pi(I).X, Pi(I).Y), rc, vbRed
    Next I
'
'
'
End Sub

Private Sub SalvaCurva(ByVal FileNome$)
'
'   Salva, su File, le coordinate dei punti
'   della curva Spline:
'
    Dim FF%, I&
'
    FF = FreeFile
    Open FileNome For Output As #FF
'
    For I = 0 To NPC - 1
        Write #FF, Pc(I).X, Pc(I).Y
    Next I
'
    Close #FF
'
'
End Sub

Private Sub txtXmax_KeyPress(KeyAscii As Integer)
'
'
    If KeyAscii = vbKeyReturn Then cmdSG_OK_Click
    KeyAscii = KAscNumReali(KeyAscii, True)
'
'
'
End Sub


Private Sub txtXmin_KeyPress(KeyAscii As Integer)
'
'
    If KeyAscii = vbKeyReturn Then cmdSG_OK_Click
    KeyAscii = KAscNumReali(KeyAscii, True)
'
'
'
End Sub


Private Sub txtYmax_KeyPress(KeyAscii As Integer)
'
'
    If KeyAscii = vbKeyReturn Then cmdSG_OK_Click
    KeyAscii = KAscNumReali(KeyAscii, True)
'
'
'
End Sub


Private Sub txtYmin_KeyPress(KeyAscii As Integer)
'
'
    If KeyAscii = vbKeyReturn Then cmdSG_OK_Click
    KeyAscii = KAscNumReali(KeyAscii, True)
'
'
'
End Sub



Private Function VerificaSG(X1!, Y1!, X2!, Y2!) As Boolean
'
'   Verifica che i valori impostati nelle caselle
'   di "Scala del grafico" siano coerenti:
'
    Dim M$
'
    On Error Resume Next
'
    If CSng(txtXmin) >= CSng(txtXmax) Then
        M$ = "Xmin o Xmax errati" & vbNewLine
    End If
    X1 = CSng(txtXmin)
    X2 = CSng(txtXmax)
'
    If CSng(txtYmin) >= CSng(txtYmax) Then
        M$ = M$ & "Ymin o Ymax errati" & vbNewLine
    End If
    Y1 = CSng(txtYmin)
    Y2 = CSng(txtYmax)
'
    If M$ <> "" Then MsgBox M$, vbCritical _
    , " Errore nei parametri del grafico"
    VerificaSG = (M$ = "")
'
'
'
End Function

Private Sub AggiornaPunti()
'
'   Crea o cancella Shapes, Lines e righe
'   della tabella:
'
    Dim I&
'
    If NPI > shpPi.Count Then
        For I = shpPi.Count To NPI - 1
            Load shpPi(I)
            shpPi(I).Visible = True
        Next I
        For I = linPi.Count To NPI - 2
            Load linPi(I)
            linPi(I).Visible = True
        Next I
    ElseIf NPI < shpPi.Count Then
        For I = shpPi.Count - 1 To NPI Step -1
            Unload shpPi(I)
        Next I
        For I = linPi.Count - 1 To NPI - 1 Step -1
            Unload linPi(I)
        Next I
    End If
'
    With grdPunti
        .Rows = NPI + 1
        For I = 0 To NPI - 1
            .Row = I + 1
            .Col = 0
            .Text = I
            .Col = 1
            .Text = Format$(Pi(I).X, "#0.000")
            .Col = 2
            .Text = Format$(Pi(I).Y, "#0.000")
        Next I
    End With
'
'
'
End Sub

Private Sub LeggiPunti(ByVal FileNome$)
'
'   Legge, da File, le coordinate dei punti
'   da interpolare:
'
    Dim FF%, X1!, Y1!, X2!, Y2!, M$
    Dim Pi_T() As P_Type
'
    On Error GoTo LeggiPunti_ERR
'
    X1 = 1E+38
    X2 = -1E+38
    Y1 = 1E+38
    Y2 = -1E+38
    NPI = 0
'
    FF = FreeFile
    Open FileNome For Input As #FF
'
    Do
        ReDim Preserve Pi_T(0 To NPI)
        Input #FF, Pi_T(NPI).X, Pi_T(NPI).Y
'
        If X1 > Pi_T(NPI).X Then X1 = Pi_T(NPI).X
        If X2 < Pi_T(NPI).X Then X2 = Pi_T(NPI).X
        If Y1 > Pi_T(NPI).Y Then Y1 = Pi_T(NPI).Y
        If Y2 < Pi_T(NPI).Y Then Y2 = Pi_T(NPI).Y
        NPI = NPI + 1
    Loop While Not EOF(FF)
'
'
LeggiPunti_ERR:
    Close #FF
'
    If Err = 0 Then
        Pi() = Pi_T()
'
        Xmin = Int(X1)
        Xmax = Ceil(X2)
        Ymin = Int(Y1)
        Ymax = Ceil(Y2)
'
        ' Dimensiona il grafico:
        Quadro picQuadro, Xmin, Xmax, Ymin, Ymax, , , 2, ShOx, ShOy, , "x", "y"
'
        ' Grafico dei punti:
        AggiornaPunti
        PosizionaPunti
'
        txtNPI = NPI
        txtXmin = Xmin
        txtXmax = Xmax
        txtYmin = Ymin
        txtYmax = Ymax
'
    Else
        M$ = "File dati inadatto o corrotto" & vbNewLine
        M$ = M$ & "Errore " & Str$(Err.Number) & vbNewLine
        M$ = M$ & Err.Description
        MsgBox M$, vbCritical, "Errore in LeggiPunti " & Err.Source
    End If
'
'
'
End Sub

Private Sub DisegnaCurva(ByVal PicB As PictureBox)
'
'   Calcolo e tracciamento della curva Spline
'   con NPC punti:
'
    Dim I&
'
    ReDim Pc(0 To NPC - 1) ' As P_Type
'
    ' Calcola la curva:
    Select Case TipoI$
        Case "Bezier"
        Call Bezier(Pi(), Pc())
        'Call Bezier_C(Pi(), Pc())
        'Call Bezier_P(Pi(), Pc())
'
        Case "B-Spline"
        Call B_Spline(Pi(), NK, Pc())
'
        Case "C-Spline"
        Call C_Spline(Pi(), Pc())
'
        Case "T-Spline"
        Call T_Spline(Pi(), VZ, Pc())
    End Select
'
    ' Disegna la curva:
    PicB.DrawWidth = 1
    PicB.PSet (Pc(0).X, Pc(0).Y), vbBlack
    For I = 1 To NPC - 1
        PicB.Line -(Pc(I).X, Pc(I).Y), vbBlack
    Next I
'
    If chkSegnaPc = vbChecked Then
        ' Segna i punti della Spline:
        PicB.DrawWidth = 3
        For I = 0 To NPC - 1
            PicB.PSet (Pc(I).X, Pc(I).Y), vbMagenta
        Next I
    End If
'
'
'
End Sub
