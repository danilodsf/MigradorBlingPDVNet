unit MigraBling.Model.Services.SubServices.PDVNET.DAOVariacoes;

interface

uses
  System.Generics.Collections,
  System.SysUtils,
  MigraBling.Model.Variacoes,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.QueryFactory,
  MigraBling.Model.LogObserver,
  MigraBling.Model.AppControl,
  MigraBling.Model.Saldos,
  Data.DB,
  MigraBling.Model.ReferenciasImagens;

type
  TDAOVariacoesPDVNET = class(TInterfacedObject, IDAOTabelasPDVNET<TVariacao>,
    IDAOTabelasPDVNETDependencia<TVariacao>)
  private
    FConexao: IConexao;
    FConexaoImagens: IConexao;
    FSaldos: IDAOTabelasPDVNETDependencia<TSaldo>;
  public
    function Ler: TObjectList<TVariacao>; overload;
    function Ler(AID: string): TObjectList<TVariacao>; overload;
    constructor Create(AConexao: IConexao; AConexaoImagens: IConexao);
  end;

implementation

uses
  MigraBling.Model.Services.SubServices.PDVNET.DAOSaldos;

{ TDAOVariacoesPDVNET }

constructor TDAOVariacoesPDVNET.Create(AConexao: IConexao; AConexaoImagens: IConexao);
begin
  FConexao := AConexao;
  FConexaoImagens := AConexaoImagens;
  FSaldos := TDAOSaldosPDVNET.Create(FConexao);
end;

function TDAOVariacoesPDVNET.Ler: TObjectList<TVariacao>;
var
  LVariacao: TVariacao;
  LQuery, LQueryImagens: IQuery;
  LReferenciaImagem: TReferenciaImagem;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);

  if Assigned(FConexaoImagens) then
    LQueryImagens := TQueryFactory.New.GetQuery(FConexaoImagens.Clone);

  Result := TObjectList<TVariacao>.Create;

  LQuery.Close;
  LQuery.SQL.Text := 'SELECT MAT_CODIGO, MAT_REFERENCIA, MAT_COR, MAT_TAMANHO, ' +
    'MAT_INATIVO, MMB.TIPO, MMB.ID_REG, MMB.ID, MAT_SITE FROM MOVIMENTOS_MIGRAR_BLING MMB ' +
    'LEFT JOIN MATERIAIS ON (MAT_CODIGO = MMB.ID_REG) ' +
    'LEFT JOIN REFERENCIAS R ON (REF_REFERENCIA = MAT_REFERENCIA) ' +
    'LEFT JOIN REFERENCIASITE on ((RES_COLECAO = REF_COLECAO) and (RES_REFERENCIA = REF_REFERENCIA)) '
    + 'WHERE MMB.TABELA = ''MATERIAIS'' ';
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

    LVariacao := TVariacao.Create;
    LVariacao.ID := LQuery.FieldByName('ID_REG').AsString.Trim;
    LVariacao.ID_Movimento := LQuery.FieldByName('ID').AsString;
    LVariacao.Referencia := LQuery.FieldByName('MAT_REFERENCIA').AsString;
    LVariacao.Cor := LQuery.FieldByName('MAT_COR').AsInteger;
    LVariacao.Tamanho := LQuery.FieldByName('MAT_TAMANHO').AsInteger;
    LVariacao.Inativo := LQuery.FieldByName('MAT_INATIVO').AsBoolean;
    LVariacao.TipoReg := LQuery.FieldByName('TIPO').AsString;
    LVariacao.Exibir := (LQuery.FieldByName('MAT_SITE').AsInteger in [1, 3]);

    if Assigned(FConexaoImagens) then
    begin
      LQueryImagens.Close;
      LQueryImagens.ParamByName('pIMA_CODIGO').AsString := LVariacao.ID;
      LQueryImagens.Open;

      while not LQueryImagens.EOF do
      begin
        LReferenciaImagem := TReferenciaImagem.Create;
        LReferenciaImagem.Seq := LQueryImagens.FieldByName('IMA_SEQ').AsInteger;
        TBlobField(LQueryImagens.FieldByName('IMA_IMAGEM')).SaveToStream(LReferenciaImagem.Imagem);
        LReferenciaImagem.Imagem.Position := 0;
        LVariacao.Imagens.Add(LReferenciaImagem);
        LQueryImagens.Next;
      end;
    end;

    Result.Add(LVariacao);
    LQuery.Next;
  end;
end;

function TDAOVariacoesPDVNET.Ler(AID: string): TObjectList<TVariacao>;
var
  LVariacao: TVariacao;
  LQuery, LQueryImagens: IQuery;
  LSaldos: TObjectList<TSaldo>;
  LReferenciaImagem: TReferenciaImagem;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);

  if Assigned(FConexaoImagens) then
    LQueryImagens := TQueryFactory.New.GetQuery(FConexaoImagens.Clone);

  Result := TObjectList<TVariacao>.Create;

  LQuery.Close;
  LQuery.SQL.Text := 'SELECT MAT_CODIGO, MAT_REFERENCIA, MAT_COR, MAT_TAMANHO, ' +
    'MAT_INATIVO, MAT_SITE FROM MATERIAIS  ' +
    'LEFT JOIN REFERENCIAS R ON (REF_REFERENCIA = MAT_REFERENCIA) ' +
    'LEFT JOIN REFERENCIASITE on ((RES_COLECAO = REF_COLECAO) and (RES_REFERENCIA = REF_REFERENCIA)) '
    + 'WHERE REF_REFERENCIA = :REF_REFERENCIA ';
  LQuery.ParamByName('REF_REFERENCIA').AsString := AID;
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

    LVariacao := TVariacao.Create;
    LVariacao.ID := LQuery.FieldByName('MAT_CODIGO').AsString.Trim;
    LVariacao.Referencia := LQuery.FieldByName('MAT_REFERENCIA').AsString;
    LVariacao.Cor := LQuery.FieldByName('MAT_COR').AsInteger;
    LVariacao.Tamanho := LQuery.FieldByName('MAT_TAMANHO').AsInteger;
    LVariacao.Inativo := LQuery.FieldByName('MAT_INATIVO').AsBoolean;
    LVariacao.Exibir := (LQuery.FieldByName('MAT_SITE').AsInteger in [1, 3]);
    LVariacao.TipoReg := 'U';

    if Assigned(FConexaoImagens) then
    begin
      LQueryImagens.Close;
      LQueryImagens.ParamByName('pIMA_CODIGO').AsString := LVariacao.ID;
      LQueryImagens.Open;

      while not LQueryImagens.EOF do
      begin
        LReferenciaImagem := TReferenciaImagem.Create;
        LReferenciaImagem.Seq := LQueryImagens.FieldByName('IMA_SEQ').AsInteger;
        TBlobField(LQueryImagens.FieldByName('IMA_IMAGEM')).SaveToStream(LReferenciaImagem.Imagem);
        LReferenciaImagem.Imagem.Position := 0;
        LVariacao.Imagens.Add(LReferenciaImagem);
        LQueryImagens.Next;
      end;
    end;

    LSaldos := FSaldos.Ler(LVariacao.ID);
    try
      while LSaldos.Count > 0 do
        LVariacao.Saldos.Add(LSaldos.Extract(LSaldos.Last));
    finally
      LSaldos.Free;
    end;

    Result.Add(LVariacao);
    LQuery.Next;
  end;

end;

end.
