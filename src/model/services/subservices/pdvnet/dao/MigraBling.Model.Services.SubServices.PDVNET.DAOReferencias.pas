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
  MigraBling.Model.LogObserver, MigraBling.Model.AppControl,
  MigraBling.Model.Variacoes, Data.DB, MigraBling.Model.ReferenciasImagens;

type
  TDAOReferenciasPDVNET = class(TInterfacedObject, IDAOTabelasPDVNET<TReferencia>)
  private
    FConexao: IConexao;
    FConexaoImagens: IConexao;
    FVariacoes: IDAOTabelasPDVNETDependencia<TVariacao>;
  public
    function Ler: TObjectList<TReferencia>; overload;
    constructor Create(AConexao: IConexao; AConexaoImagens: IConexao);
  end;

implementation

uses
  MigraBling.Model.Services.SubServices.PDVNET.DAOVariacoes;

{ TDAOReferenciasPDVNET }

constructor TDAOReferenciasPDVNET.Create(AConexao: IConexao; AConexaoImagens: IConexao);
begin
  FConexao := AConexao;
  FConexaoImagens := AConexaoImagens;
  FVariacoes := TDAOVariacoesPDVNET.Create(FConexao, FConexaoImagens);
end;

function TDAOReferenciasPDVNET.Ler: TObjectList<TReferencia>;
var
  LReferencia: TReferencia;
  LQuery, LQueryImagens: IQuery;
  LVariacoes: TObjectList<TVariacao>;
  LReferenciaImagem: TReferenciaImagem;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);

  if Assigned(FConexaoImagens) then
    LQueryImagens := TQueryFactory.New.GetQuery(FConexaoImagens.Clone);

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

  if Assigned(FConexaoImagens) then
  begin
    LQueryImagens.Close;
    LQueryImagens.SQL.Text := 'select IMA_SEQ, IMA_IMAGEM from IMAGEM ' +
      'WHERE IMA_CODIGO = :pIMA_CODIGO AND IMA_IMAGEM IS NOT NULL ORDER BY IMA_SEQ';
  end;

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

    if Assigned(FConexaoImagens) then
    begin
      LQueryImagens.Close;
      LQueryImagens.ParamByName('pIMA_CODIGO').AsString := LReferencia.Referencia;
      LQueryImagens.Open;

      while not LQueryImagens.EOF do
      begin
        LReferenciaImagem := TReferenciaImagem.Create;
        LReferenciaImagem.Seq := LQueryImagens.FieldByName('IMA_SEQ').AsInteger;
        TBlobField(LQueryImagens.FieldByName('IMA_IMAGEM')).SaveToStream(LReferenciaImagem.Imagem);
        LReferenciaImagem.Imagem.Position := 0;
        LReferencia.Imagens.Add(LReferenciaImagem);
        LQueryImagens.Next;
      end;
    end;

    LVariacoes := FVariacoes.Ler(LReferencia.Referencia);
    try
      while LVariacoes.Count > 0 do
        LReferencia.Variacoes.Add(LVariacoes.Extract(LVariacoes.Last));
    finally
      LVariacoes.Free;
    end;

    Result.Add(LReferencia);
    LQuery.Next;
  end;
end;

end.
