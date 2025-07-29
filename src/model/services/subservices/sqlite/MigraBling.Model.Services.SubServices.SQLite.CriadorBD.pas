unit MigraBling.Model.Services.SubServices.SQLite.CriadorBD;

interface

uses
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.QueryFactory, System.SysUtils;

type
  TCriadorBD = class
  private
    class procedure tabCamposCustomizados(AQuery: IQuery);
    class procedure tabCamposColecoes(AQuery: IQuery);
    class procedure tabConfiguracoes(AQuery: IQuery);
    class procedure tabCores(AQuery: IQuery);
    class procedure tabFilial(AQuery: IQuery);
    class procedure tabGrupoMateriais(AQuery: IQuery);
    class procedure tabLinha(AQuery: IQuery);
    class procedure tabMateriais(AQuery: IQuery);
    class procedure tabMateriaPrima(AQuery: IQuery);
    class procedure tabModelos(AQuery: IQuery);
    class procedure tabMovimentosEstoque(AQuery: IQuery);
    class procedure tabMovimentosMigrarBling(AQuery: IQuery);
    class procedure tabPreco(AQuery: IQuery);
    class procedure tabReferencias(AQuery: IQuery);
    class procedure tabSaldos(AQuery: IQuery);
    class procedure tabTabelaPreco(AQuery: IQuery);
    class procedure tabTamanhos(AQuery: IQuery);
    class procedure tabVersao(AQuery: IQuery);

    class procedure AtualizarVersao_1(AQuery: IQuery);
  public
    class procedure CriarBancoDeDados(AConexao: IConexao);
    class procedure AtualizarBancoDeDados(AConexao: IConexao);
  end;

implementation

{ TCriadorBD }

class procedure TCriadorBD.AtualizarVersao_1(AQuery: IQuery);
begin
  try
//    AQuery.Connection.StartTransaction;
//
//    AQuery.SQL.Clear;
//    AQuery.SQL.Text := 'ATUALIZAR BANCO CASO SEJA NECESSARIO';
//    AQuery.ExecSQL;
//
//    AQuery.SQL.Clear;
//    AQuery.SQL.Text := 'UPDATE VERSAO SET NUMERO = 1';
//    AQuery.ExecSQL;
//
//    AQuery.Connection.Commit;
  except
    on E: Exception do
    begin
      AQuery.Connection.Rollback;
      raise Exception.Create(E.Message);
    end;
  end;
end;

class procedure TCriadorBD.AtualizarBancoDeDados(AConexao: IConexao);
var
  FQuery: IQuery;
  FVersaoAtual: integer;
begin
  AConexao.Open;
  FQuery := TQueryFactory.New.GetQuery(AConexao);
  FQuery.SQL.Clear;
  FQuery.SQL.Text := 'SELECT NUMERO FROM VERSAO';
  FQuery.Open;
  FVersaoAtual := FQuery.FieldByName('NUMERO').AsInteger;

  if FVersaoAtual = 0 then
    AtualizarVersao_1(FQuery);
end;

class procedure TCriadorBD.CriarBancoDeDados(AConexao: IConexao);
var
  FQuery: IQuery;
begin
  try
    AConexao.Open;
    FQuery := TQueryFactory.New.GetQuery(AConexao);

    tabCamposCustomizados(FQuery);
    tabCamposColecoes(FQuery);
    tabConfiguracoes(FQuery);
    tabCores(FQuery);
    tabFilial(FQuery);
    tabGrupoMateriais(FQuery);
    tabLinha(FQuery);
    tabMateriais(FQuery);
    tabMateriaPrima(FQuery);
    tabModelos(FQuery);
    tabMovimentosEstoque(FQuery);
    tabMovimentosMigrarBling(FQuery);
    tabPreco(FQuery);
    tabReferencias(FQuery);
    tabSaldos(FQuery);
    tabTabelaPreco(FQuery);
    tabTamanhos(FQuery);
    tabVersao(FQuery);
  except
    on E: Exception do
    begin
      FQuery.Connection.Rollback;
      raise Exception.Create(E.Message);
    end;
  end;
end;

class procedure TCriadorBD.tabCamposCustomizados(AQuery: IQuery);
begin
  AQuery.SQL.Clear;
  AQuery.SQL.Add('CREATE TABLE "CAMPOS_CUSTOMIZADOS" (');
  AQuery.SQL.Add('"ID"	INTEGER,');
  AQuery.SQL.Add('"ID_BLING"	TEXT,');
  AQuery.SQL.Add('"DESCRICAO"	TEXT,');
  AQuery.SQL.Add('"TABELA"	TEXT,');
  AQuery.SQL.Add('PRIMARY KEY("ID"))');
  AQuery.ExecSQL;
end;

class procedure TCriadorBD.tabCamposColecoes(AQuery: IQuery);
begin
  AQuery.SQL.Clear;
  AQuery.SQL.Add('CREATE TABLE "COLECOES" (');
  AQuery.SQL.Add('"COL_CODIGO"	INTEGER,');
  AQuery.SQL.Add('"COL_DESCRICAO"	TEXT,');
  AQuery.SQL.Add('"COL_INATIVO2"	INTEGER,');
  AQuery.SQL.Add('"EXCLUIDO"	INTEGER,');
  AQuery.SQL.Add('"ID_BLING"	TEXT,');
  AQuery.SQL.Add('PRIMARY KEY("COL_CODIGO"))');
  AQuery.ExecSQL;
end;

class procedure TCriadorBD.tabConfiguracoes(AQuery: IQuery);
begin
  AQuery.SQL.Clear;
  AQuery.SQL.Add('CREATE TABLE "CONFIGURACOES" (');
  AQuery.SQL.Add('"ACCESS_TOKEN"	TEXT,');
  AQuery.SQL.Add('"REFRESH_TOKEN"	TEXT,');
  AQuery.SQL.Add('"EXPIRES_IN"	TEXT,');
  AQuery.SQL.Add('"CLIENT_ID"	TEXT,');
  AQuery.SQL.Add('"CLIENT_SECRET"	TEXT,');
  AQuery.SQL.Add('"PDVNET_SERVER"	TEXT,');
  AQuery.SQL.Add('"PDVNET_DATABASE"	TEXT,');
  AQuery.SQL.Add('"PDVNET_USERNAME"	TEXT,');
  AQuery.SQL.Add('"PDVNET_PASSWORD"	TEXT,');
  AQuery.SQL.Add('"TEMPO_SINRONIZACAO"	INTEGER,');
  AQuery.SQL.Add('"ATIVAR"	INTEGER,');
  AQuery.SQL.Add('"QTD_ESTOQUE_SUBIR"	INTEGER,');
  AQuery.SQL.Add('"DT_ULTIMA_CONSULTA_HOOKDECK"	TEXT,');
  AQuery.SQL.Add('"TABELA_PRECO_PADRAO"	INTEGER DEFAULT 29,');
  AQuery.SQL.Add('"PASTA_BACKUP"	TEXT)');
  AQuery.ExecSQL;
end;

class procedure TCriadorBD.tabCores(AQuery: IQuery);
begin
  AQuery.SQL.Clear;
  AQuery.SQL.Add('CREATE TABLE "CORES" (');
  AQuery.SQL.Add('"COR_CODIGO"	INTEGER,');
  AQuery.SQL.Add('"COR_DESCRICAO"	TEXT,');
  AQuery.SQL.Add('"COR_INATIVO2"	INTEGER,');
  AQuery.SQL.Add('"EXCLUIDO"	INTEGER, ID_BLING TEXT,');
  AQuery.SQL.Add('PRIMARY KEY("COR_CODIGO"))');
  AQuery.ExecSQL;
end;

class procedure TCriadorBD.tabFilial(AQuery: IQuery);
begin
  AQuery.SQL.Clear;
  AQuery.SQL.Add('CREATE TABLE "FILIAL" (');
  AQuery.SQL.Add('"FIL_CODIGO"	INTEGER,');
  AQuery.SQL.Add('"FIL_RAZAO_SOCIAL"	TEXT,');
  AQuery.SQL.Add('"FIL_INATIVA"	INTEGER,');
  AQuery.SQL.Add('"EXCLUIDO"	INTEGER,');
  AQuery.SQL.Add('"ID_BLING"	TEXT,');
  AQuery.SQL.Add('"DESCONSIDERAR_ESTOQUE"	INTEGER,');
  AQuery.SQL.Add('PRIMARY KEY("FIL_CODIGO"))');
  AQuery.ExecSQL;
end;

class procedure TCriadorBD.tabGrupoMateriais(AQuery: IQuery);
begin
  AQuery.SQL.Clear;
  AQuery.SQL.Add('CREATE TABLE "GRUPOMATERIAIS" (');
  AQuery.SQL.Add('"GRUM_CODIGO"	INTEGER,');
  AQuery.SQL.Add('"GRUM_DESCRICAO"	TEXT,');
  AQuery.SQL.Add('"GRUM_INATIVO2"	INTEGER,');
  AQuery.SQL.Add('"EXCLUIDO"	INTEGER,');
  AQuery.SQL.Add('"ID_BLING"	TEXT,');
  AQuery.SQL.Add('PRIMARY KEY("GRUM_CODIGO"))');
  AQuery.ExecSQL;
end;

class procedure TCriadorBD.tabLinha(AQuery: IQuery);
begin
  AQuery.SQL.Clear;
  AQuery.SQL.Add('CREATE TABLE "LINHA" (');
  AQuery.SQL.Add('"LIN_CODIGO"	INTEGER,');
  AQuery.SQL.Add('"LIN_DESCRICAO"	TEXT,');
  AQuery.SQL.Add('"LIN_INATIVO2"	INTEGER,');
  AQuery.SQL.Add('"EXCLUIDO"	INTEGER,');
  AQuery.SQL.Add('"ID_BLING"	TEXT,');
  AQuery.SQL.Add('PRIMARY KEY("LIN_CODIGO"))');
  AQuery.ExecSQL;
end;

class procedure TCriadorBD.tabMateriais(AQuery: IQuery);
begin
  AQuery.SQL.Clear;
  AQuery.SQL.Add('CREATE TABLE "MATERIAIS" (');
  AQuery.SQL.Add('"MAT_CODIGO"	TEXT,');
  AQuery.SQL.Add('"MAT_REFERENCIA"	TEXT,');
  AQuery.SQL.Add('"MAT_COR"	INTEGER,');
  AQuery.SQL.Add('"MAT_TAMANHO"	INTEGER,');
  AQuery.SQL.Add('"MAT_INATIVO"	INTEGER,');
  AQuery.SQL.Add('"EXCLUIDO"	INTEGER,');
  AQuery.SQL.Add('"ID_BLING"	TEXT,');
  AQuery.SQL.Add('"MAT_EXIBIR"	INTEGER,');
  AQuery.SQL.Add('COR_VINCULO_ID_BLING TEXT,');
  AQuery.SQL.Add('TAMANHO_VINCULO_ID_BLING TEXT,');
  AQuery.SQL.Add('PRIMARY KEY("MAT_CODIGO"))');
  AQuery.ExecSQL;
end;

class procedure TCriadorBD.tabMateriaPrima(AQuery: IQuery);
begin
  AQuery.SQL.Clear;
  AQuery.SQL.Add('CREATE TABLE "MATERIAPRIMA" (');
  AQuery.SQL.Add('"MAP_CODIGO"	INTEGER,');
  AQuery.SQL.Add('"MAP_DESCRICAO"	TEXT,');
  AQuery.SQL.Add('"MAP_INATIVO2"	INTEGER,');
  AQuery.SQL.Add('"EXCLUIDO"	INTEGER,');
  AQuery.SQL.Add('"ID_BLING"	TEXT,');
  AQuery.SQL.Add('PRIMARY KEY("MAP_CODIGO"))');
  AQuery.ExecSQL;
end;

class procedure TCriadorBD.tabModelos(AQuery: IQuery);
begin
  AQuery.SQL.Clear;
  AQuery.SQL.Add('CREATE TABLE "MODELOS" (');
  AQuery.SQL.Add('"MOD_CODIGO"	INTEGER NOT NULL,');
  AQuery.SQL.Add('"MOD_DESCRICAO"	TEXT,');
  AQuery.SQL.Add('"MOD_INATIVO2"	INTEGER,');
  AQuery.SQL.Add('"EXCLUIDO"	INTEGER DEFAULT 0,');
  AQuery.SQL.Add('"ID_BLING"	TEXT,');
  AQuery.SQL.Add('PRIMARY KEY("MOD_CODIGO"))');
  AQuery.ExecSQL;
end;

class procedure TCriadorBD.tabMovimentosEstoque(AQuery: IQuery);
begin
  AQuery.SQL.Clear;
  AQuery.SQL.Add('CREATE TABLE "MOVIMENTOS_ESTOQUE_BLING" (');
  AQuery.SQL.Add('"ID"	INTEGER,');
  AQuery.SQL.Add('"ID_PRODUTO_BLING"	TEXT,');
  AQuery.SQL.Add('"ID_FILIAL"	TEXT,');
  AQuery.SQL.Add('"QUANTIDADE_VENDIDA"	INTEGER,');
  AQuery.SQL.Add('"SALDO_ANTERIOR"	INTEGER,');
  AQuery.SQL.Add('"DATA"	TEXT,');
  AQuery.SQL.Add('"PROCESSADO"	INTEGER DEFAULT 0,');
  AQuery.SQL.Add('PRIMARY KEY("ID" AUTOINCREMENT))');
  AQuery.ExecSQL;
end;

class procedure TCriadorBD.tabMovimentosMigrarBling(AQuery: IQuery);
begin
  AQuery.SQL.Clear;
  AQuery.SQL.Add('CREATE TABLE "MOVIMENTOS_MIGRAR_BLING" (');
  AQuery.SQL.Add('"ID"	INTEGER,');
  AQuery.SQL.Add('"ID_REG"	TEXT,');
  AQuery.SQL.Add('"TABELA"	TEXT,');
  AQuery.SQL.Add('"TIPO"	TEXT,');
  AQuery.SQL.Add('"DATA"	TEXT,');
  AQuery.SQL.Add('PRIMARY KEY("ID"))');
  AQuery.ExecSQL;
end;

class procedure TCriadorBD.tabPreco(AQuery: IQuery);
begin
  AQuery.SQL.Clear;
  AQuery.SQL.Add('CREATE TABLE "PRECO" (');
  AQuery.SQL.Add('"PRE_ID"	TEXT,');
  AQuery.SQL.Add('"PRE_PRODUTO"	TEXT,');
  AQuery.SQL.Add('"PRE_TABELA"	INTEGER,');
  AQuery.SQL.Add('"PRE_PRECO1"	NUMERIC,');
  AQuery.SQL.Add('"PRE_PRECO2"	NUMERIC,');
  AQuery.SQL.Add('"EXCLUIDO"	INTEGER,');
  AQuery.SQL.Add('PRIMARY KEY("PRE_ID"))');
  AQuery.ExecSQL;
end;

class procedure TCriadorBD.tabReferencias(AQuery: IQuery);
begin
  AQuery.SQL.Clear;
  AQuery.SQL.Add('CREATE TABLE "REFERENCIAS" (');
  AQuery.SQL.Add('"REF_REFERENCIA"	TEXT,');
  AQuery.SQL.Add('"REF_DESCRICAO"	TEXT,');
  AQuery.SQL.Add('"REF_DESCRICAO_CURTA"	TEXT,');
  AQuery.SQL.Add('"REF_DESCRICAO_LONGA"	TEXT,');
  AQuery.SQL.Add('"REF_PESO"	REAL,');
  AQuery.SQL.Add('"REF_ALTURA"	REAL,');
  AQuery.SQL.Add('"REF_LARGURA"	REAL,');
  AQuery.SQL.Add('"REF_PROFUNDIDADE"	REAL,');
  AQuery.SQL.Add('"REF_MATERIA"	INTEGER,');
  AQuery.SQL.Add('"REF_COLECAO"	INTEGER,');
  AQuery.SQL.Add('"REF_GRUPO"	INTEGER,');
  AQuery.SQL.Add('"REF_LINHA"	INTEGER,');
  AQuery.SQL.Add('"REF_MODELO"	INTEGER,');
  AQuery.SQL.Add('"REF_NCM"	TEXT,');
  AQuery.SQL.Add('"REF_UNIDADE"	TEXT,');
  AQuery.SQL.Add('"REF_EXIBIR"	INTEGER,');
  AQuery.SQL.Add('"REF_INATIVO2"	INTEGER,');
  AQuery.SQL.Add('"EXCLUIDO"	INTEGER,');
  AQuery.SQL.Add('"ID_BLING"	TEXT,');
  AQuery.SQL.Add('"CATEGORIA_VINCULO_ID_BLING"	TEXT,');
  AQuery.SQL.Add('"DEPARTAMENTO_VINCULO_ID_BLING"	TEXT,');
  AQuery.SQL.Add('"COLECAO_VINCULO_ID_BLING"	TEXT,');
  AQuery.SQL.Add('"GRUPO_VINCULO_ID_BLING"	TEXT,');
  AQuery.SQL.Add('"MATERIAL_VINCULO_ID_BLING"	TEXT,');
  AQuery.SQL.Add('COR_VINCULO_ID_BLING TEXT,');
  AQuery.SQL.Add('TAMANHO_VINCULO_ID_BLING TEXT,');
  AQuery.SQL.Add('PRIMARY KEY("REF_REFERENCIA"))');
  AQuery.ExecSQL;
end;

class procedure TCriadorBD.tabSaldos(AQuery: IQuery);
begin
  AQuery.SQL.Clear;
  AQuery.SQL.Add('CREATE TABLE "SALDOS" (');
  AQuery.SQL.Add('"SAL_ID"	TEXT,');
  AQuery.SQL.Add('"SAL_PRODUTO"	TEXT,');
  AQuery.SQL.Add('"SAL_FILIAL"	INTEGER,');
  AQuery.SQL.Add('"SAL_SALDO"	REAL,');
  AQuery.SQL.Add('"ID_BLING"	TEXT,');
  AQuery.SQL.Add('"EXCLUIDO"	INTEGER,');
  AQuery.SQL.Add('PRIMARY KEY("SAL_ID"))');
  AQuery.ExecSQL;
end;

class procedure TCriadorBD.tabTabelaPreco(AQuery: IQuery);
begin
  AQuery.SQL.Clear;
  AQuery.SQL.Add('CREATE TABLE "TABELAPRECO" (');
  AQuery.SQL.Add('"TAB_CODIGO"	INTEGER,');
  AQuery.SQL.Add('"TAB_DESCRICAO"	TEXT,');
  AQuery.SQL.Add('"TAB_INATIVO"	INTEGER,');
  AQuery.SQL.Add('"TAB_EXCLUIDO"	INTEGER,');
  AQuery.SQL.Add('PRIMARY KEY("TAB_CODIGO"))');
  AQuery.ExecSQL;
end;

class procedure TCriadorBD.tabTamanhos(AQuery: IQuery);
begin
  AQuery.SQL.Clear;
  AQuery.SQL.Add('CREATE TABLE "TAMANHOS" (');
  AQuery.SQL.Add('"TAM_CODIGO"	INTEGER,');
  AQuery.SQL.Add('"TAM_TAMANHO"	TEXT,');
  AQuery.SQL.Add('"TAM_ORDEM"	INTEGER,');
  AQuery.SQL.Add('"TAM_INATIVO"	INTEGER,');
  AQuery.SQL.Add('"EXCLUIDO"	INTEGER,');
  AQuery.SQL.Add('ID_BLING TEXT,');
  AQuery.SQL.Add('PRIMARY KEY("TAM_CODIGO"))');
  AQuery.ExecSQL;
end;

class procedure TCriadorBD.tabVersao(AQuery: IQuery);
begin
  AQuery.Connection.StartTransaction;
  AQuery.SQL.Clear;
  AQuery.SQL.Add('CREATE TABLE "VERSAO" (');
  AQuery.SQL.Add('"NUMERO"	INTEGER)');
  AQuery.ExecSQL;
  AQuery.SQL.Clear;
  AQuery.SQL.Add('INSERT INTO VERSAO(NUMERO) VALUES (0)');
  AQuery.ExecSQL;
  AQuery.Connection.Commit;
end;

end.
