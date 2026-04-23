object FrmSincReferencia: TFrmSincReferencia
  Left = 0
  Top = 0
  Caption = 'Sincroniza'#231#227'o de refer'#234'ncias'
  ClientHeight = 561
  ClientWidth = 670
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
  object grdReferencias: TDBGrid
    Left = 0
    Top = 64
    Width = 670
    Height = 462
    Align = alClient
    DataSource = dsReferencias
    TabOrder = 0
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    OnCellClick = grdReferenciasCellClick
    OnDrawColumnCell = grdReferenciasDrawColumnCell
    Columns = <
      item
        Expanded = False
        FieldName = 'X'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ReadOnly = True
        Width = 30
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'REF_REFERENCIA'
        ReadOnly = True
        Width = 80
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'REF_DESCRICAO'
        ReadOnly = True
        Width = 400
        Visible = True
      end>
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 670
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 624
    object chkMarcarTudo: TCheckBox
      Left = 8
      Top = 13
      Width = 121
      Height = 17
      Caption = 'Selecionar todas'
      TabOrder = 0
      OnClick = chkMarcarTudoClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 526
    Width = 670
    Height = 35
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    DesignSize = (
      670
      35)
    object btnConfirmar: TButton
      Left = 583
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Confirmar'
      ModalResult = 1
      TabOrder = 0
      ExplicitLeft = 537
    end
    object btnCancelar: TButton
      Left = 502
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Cancelar'
      ModalResult = 2
      TabOrder = 1
      ExplicitLeft = 456
    end
  end
  object edtBuscar: TEdit
    Left = 0
    Top = 41
    Width = 670
    Height = 23
    Align = alTop
    TabOrder = 3
    TextHint = 'Buscar refer'#234'ncia'
    OnChange = edtBuscarChange
  end
  object cdsReferencias: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 288
    Top = 200
    object cdsReferenciasX: TStringField
      FieldName = 'X'
      Size = 1
    end
    object cdsReferenciasREF_REFERENCIA: TStringField
      DisplayLabel = 'Refer'#234'ncia'
      FieldName = 'REF_REFERENCIA'
      Size = 123
    end
    object cdsReferenciasREF_DESCRICAO: TStringField
      DisplayLabel = 'Descri'#231#227'o'
      FieldName = 'REF_DESCRICAO'
      Size = 1000
    end
  end
  object dsReferencias: TDataSource
    DataSet = cdsReferencias
    Left = 184
    Top = 200
  end
end
