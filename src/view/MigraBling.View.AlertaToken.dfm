object FrmAlertaToken: TFrmAlertaToken
  Left = 0
  Top = 0
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Aten'#231#227'o'
  ClientHeight = 93
  ClientWidth = 487
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnClose = FormClose
  OnShow = FormShow
  TextHeight = 15
  object Label1: TLabel
    Left = 0
    Top = 0
    Width = 487
    Height = 56
    Align = alClient
    Alignment = taCenter
    Caption = 'O Token do Bling expirou'#13#10#201' necess'#225'rio refazer o login'
    Layout = tlCenter
    ExplicitWidth = 142
    ExplicitHeight = 30
  end
  object Panel1: TPanel
    Left = 0
    Top = 56
    Width = 487
    Height = 37
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = 55
    object Button1: TButton
      Left = 400
      Top = 8
      Width = 75
      Height = 25
      Caption = 'OK'
      ModalResult = 1
      TabOrder = 0
    end
  end
  object tmrNotifica: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = tmrNotificaTimer
    Left = 56
    Top = 16
  end
end
