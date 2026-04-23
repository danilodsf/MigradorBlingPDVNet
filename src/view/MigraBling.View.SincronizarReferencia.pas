unit MigraBling.View.SincronizarReferencia;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Data.DB, Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls,
  Datasnap.DBClient, Vcl.StdCtrls, System.Generics.Collections,
  MigraBling.Model.Referencias, Math;

type
  TFrmSincReferencia = class(TForm)
    grdReferencias: TDBGrid;
    Panel1: TPanel;
    cdsReferencias: TClientDataSet;
    chkMarcarTudo: TCheckBox;
    Panel2: TPanel;
    btnConfirmar: TButton;
    btnCancelar: TButton;
    dsReferencias: TDataSource;
    cdsReferenciasREF_REFERENCIA: TStringField;
    cdsReferenciasREF_DESCRICAO: TStringField;
    cdsReferenciasX: TStringField;
    edtBuscar: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure grdReferenciasDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer;
      Column: TColumn; State: TGridDrawState);
    procedure grdReferenciasCellClick(Column: TColumn);
    procedure chkMarcarTudoClick(Sender: TObject);
    procedure edtBuscarChange(Sender: TObject);
  private
    FReferencias: TObjectList<TReferencia>;
  public
    function ShowModal(AReferencias: TObjectList<TReferencia>): Integer; reintroduce;
  end;

var
  FrmSincReferencia: TFrmSincReferencia;

implementation

{$R *.dfm}
{ TFrmSincReferencia }

procedure TFrmSincReferencia.chkMarcarTudoClick(Sender: TObject);
begin
  cdsReferencias.DisableControls;
  cdsReferencias.First;
  while not cdsReferencias.Eof do
  begin
    cdsReferencias.Edit;

    if chkMarcarTudo.Checked then
      cdsReferenciasX.AsString := 'S'
    else
      cdsReferenciasX.AsString := 'N';

    cdsReferencias.Post;
    cdsReferencias.Next;
  end;
  cdsReferencias.First;
  cdsReferencias.EnableControls;;
end;

procedure TFrmSincReferencia.grdReferenciasCellClick(Column: TColumn);
begin
  if Column.Field.FieldName = 'X' then
  begin
    Column.Field.DataSet.Edit;
    if Column.Field.AsString = 'S' then
      Column.Field.AsString := 'N'
    else
      Column.Field.AsString := 'S';
  end;
end;

procedure TFrmSincReferencia.grdReferenciasDrawColumnCell(Sender: TObject; const Rect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState);
var
  Check: Integer;
  R: TRect;
begin
  if (Column.FieldName = 'X') then
  begin
    grdReferencias.Canvas.Font.Color := clWhite;
    grdReferencias.Canvas.Brush.Color := clWhite;
    grdReferencias.DefaultDrawColumnCell(Rect, DataCol, Column, State);

    grdReferencias.Canvas.FillRect(Rect);
    Check := ifthen(cdsReferencias.FieldByName(Column.FieldName).AsString = 'S', DFCS_CHECKED, 0);
    R := Rect;
    InflateRect(R, -2, -2);
    DrawFrameControl(grdReferencias.Canvas.Handle, R, DFC_BUTTON, DFCS_BUTTONCHECK or Check);
  end;
end;

procedure TFrmSincReferencia.edtBuscarChange(Sender: TObject);
begin
  cdsReferencias.Filtered := false;
  if edtBuscar.Text <> '' then
  begin
    cdsReferencias.Filter := 'REF_REFERENCIA LIKE ''%' + UpperCase(edtBuscar.Text) +
      '%'' or UPPER(REF_DESCRICAO) LIKE ''' + UpperCase(edtBuscar.Text) + '%'' ';
    cdsReferencias.Filtered := true;
  end;
end;

procedure TFrmSincReferencia.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FReferencias.Free;
end;

procedure TFrmSincReferencia.FormShow(Sender: TObject);
var
  LReferencia: TReferencia;
begin
  edtBuscar.SetFocus;
  if FReferencias.Count > 0 then
  begin
    cdsReferencias.DisableControls;
    cdsReferencias.CreateDataSet;
    for LReferencia in FReferencias do
    begin
      cdsReferencias.Append;
      cdsReferenciasX.AsString := 'N';
      cdsReferenciasREF_REFERENCIA.AsString := LReferencia.Referencia;
      cdsReferenciasREF_DESCRICAO.AsString := LReferencia.Nome + ' ' + LReferencia.Departamento +
        ' ' + LReferencia.Categoria + ' ' + LReferencia.Grupo + ' ' + LReferencia.Colecao + ' ' +
        LReferencia.Material;
      cdsReferencias.Post;
    end;
    cdsReferencias.First;
    cdsReferencias.EnableControls;
  end;
end;

function TFrmSincReferencia.ShowModal(AReferencias: TObjectList<TReferencia>): Integer;
begin
  FReferencias := AReferencias;
  result := inherited ShowModal;
end;

end.
