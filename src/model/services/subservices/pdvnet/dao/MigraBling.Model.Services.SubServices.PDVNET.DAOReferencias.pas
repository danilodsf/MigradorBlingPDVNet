unit MigraBling.Model.Services.SubServices.PDVNET.DAOReferencias;

interface

uses
  MigraBling.Model.Referencias,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.QueryFactory,
  System.Generics.Collections,
  System.SysUtils,
  MigraBling.Model.LogObserver, MigraBling.Model.AppControl;

type
  TDAOReferenciasPDVNET = class(TInterfacedObject, IDAOTabelasPDVNET<TReferencia>)
  private
    FConexao: IConexao;
  public
    function Ler: TObjectList<TReferencia>;
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOReferenciasPDVNET }

constructor TDAOReferenciasPDVNET.Create(AConexao: IConexao);
begin
  FConexao := AConexao;
end;

function TDAOReferenciasPDVNET.Ler: TObjectList<TReferencia>;
var
  LReferencia: TReferencia;
  LQuery, LQuery2: IQuery;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
  LQuery2 := TQueryFactory.New.GetQuery(FConexao.Clone);

  LQuery2.Close;
  LQuery2.SQL.Text := 'SELECT MAT_CODIGO, MAT_COR, MAT_TAMANHO, MAT_INATIVO ' + 'FROM MATERIAIS ' +
    'WHERE MAT_REFERENCIA = :PMAT_REFERENCIA ';

  Result := TObjectList<TReferencia>.Create;
  LQuery.Close;
  LQuery.SQL.Text := 'SELECT REF_COLECAO, REF_REFERENCIA, RES_NOME, RES_DESCRICAO, ' +
    'RES_DESCRICAO_CURTA, RES_PESO, RES_ALTURA, RES_LARGURA, RES_PROFUNDIDADE, REF_MATERIA, ' +
    'REF_GRUPO, REF_LINHA, REF_MODELO, REF_INATIVO2, NCM_NCM, UNI_DESCRICAO, MMB.TIPO, ' +
    'MMB.ID_REG, MMB.ID, REF_SITE FROM MOVIMENTOS_MIGRAR_BLING MMB ' +
    'LEFT JOIN REFERENCIAS R ON (R.REF_REFERENCIA = MMB.ID_REG) ' +
    'LEFT JOIN REFERENCIASITE on ((RES_COLECAO = REF_COLECAO) and (RES_REFERENCIA = REF_REFERENCIA)) '
    + 'LEFT JOIN NCM on (REF_NCM = NCM_CODIGO) LEFT JOIN UNIDADES on (REF_UNIDADE2 = UNI_CODIGO) ' +
    'WHERE MMB.TABELA = ''REFERENCIAS'' ';
  LQuery.Open;
  while not LQuery.EOF do
  begin
    if TAppControl.AppFinalizando then
      break;

    LReferencia := TReferencia.Create;
    LReferencia.ID_Movimento := LQuery.FieldByName('ID').AsString;
    LReferencia.Colecao := LQuery.FieldByName('REF_COLECAO').AsString;
    LReferencia.Referencia := LQuery.FieldByName('ID_REG').AsString.Trim;
    LReferencia.Exibir := LQuery.FieldByName('REF_SITE').AsBoolean;
    LReferencia.Nome := LQuery.FieldByName('RES_NOME').AsString;
    LReferencia.Descricao := LQuery.FieldByName('RES_DESCRICAO').AsString;
    LReferencia.Descricao_Complementar := LQuery.FieldByName('RES_DESCRICAO_CURTA').AsString;
    LReferencia.Peso := LQuery.FieldByName('RES_PESO').AsFloat;
    LReferencia.Altura := LQuery.FieldByName('RES_ALTURA').AsFloat;
    LReferencia.Largura := LQuery.FieldByName('RES_LARGURA').AsFloat;
    LReferencia.Profundidade := LQuery.FieldByName('RES_PROFUNDIDADE').AsFloat;
    LReferencia.Grupo := LQuery.FieldByName('REF_MATERIA').AsString;
    LReferencia.Departamento := LQuery.FieldByName('REF_GRUPO').AsString;
    LReferencia.Material := LQuery.FieldByName('REF_LINHA').AsString;
    LReferencia.Categoria := LQuery.FieldByName('REF_MODELO').AsString;
    LReferencia.NCM := LQuery.FieldByName('NCM_NCM').AsString;
    LReferencia.Unidade := LQuery.FieldByName('UNI_DESCRICAO').AsString;
    LReferencia.Inativo := LQuery.FieldByName('REF_INATIVO2').AsBoolean;
    LReferencia.TipoReg := LQuery.FieldByName('TIPO').AsString;

    Result.Add(LReferencia);
    LQuery.Next;
  end;
end;

end.
