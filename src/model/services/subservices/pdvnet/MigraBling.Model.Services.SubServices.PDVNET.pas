unit MigraBling.Model.Services.SubServices.PDVNET;

interface

uses
  System.Classes,
  System.Generics.Collections,
  MigraBling.Model.Services.SubServices.Interfaces.PDVNET,
  MigraBling.Model.Configuracao,
  MigraBling.Model.Services.SubServices.Interfaces.SQLite,
  MigraBling.Model.ConexaoFactory,
  MigraBling.Model.QueryFactory,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.Conexao, System.SysUtils,
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.Services.SubServices.Interfaces.RegistrosMovimentados,
  MigraBling.Model.Services.SubServices.PDVNET.RegistrosMovimentados,
  MigraBling.Model.Services.SubServices.Connection,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Referencias,
  MigraBling.Model.ConexaoProvider,
  MigraBling.Model.Utils,
  MigraBling.Model.TabelaDados, Vcl.Dialogs;

type
  TPDVNETService = class(TInterfacedObject, IPDVNETService)
  private
    FConfigurador: ISQLiteService;
    FConexao: IConexao;
    FBuscarMovimentos: IRegistrosMovimentados;
    function GetBancoConfigurado: Boolean;
    procedure TabelaMovimentos;
    procedure Triggers;
    function GetTabelasSinc: TDictionary<string, TTabelaDados>;
    procedure CriarTrigger(ATabelaOrigem: string; ATabelaDados: TTabelaDados);
    procedure DadosTabela(AListaTabelas: TDictionary<string, TTabelaDados>;
      ATabelaOrigem, ATabelaDestino, APKValue, ACondicaoInserirDadosInicial: string;
      APKComposto: string = '');
    procedure CriarRegistrosMovimentacao(ATabelaOrigem: string; ATabelaDados: TTabelaDados);
    function GetBuscarMovimentos: IRegistrosMovimentados;
  public
    property BancoConfigurado: Boolean read GetBancoConfigurado;
    property BuscarMovimentos: IRegistrosMovimentados read GetBuscarMovimentos;
    procedure CriarEstruturaSincronizacao;
    procedure LimparMovimentos(AValue: IRegistrosMovimentados);
    procedure DestruirObjetos;
    function TestarConexaoSQLServer: Boolean;
    function BuscarFiliais: TDictionary<integer, string>;
    function BuscarTabelasDePreco: TOrderedDictionary<integer, string>;
    function BuscarReferencias: TObjectList<TReferencia>;
    procedure SincronizarReferencias(AReferencias: TList<string>);
    constructor Create(AConfigurador: ISQLiteService);
  end;

implementation

{ TPDVNETService }

function TPDVNETService.BuscarFiliais: TDictionary<integer, string>;
var
  LQuery: IQuery;
begin
  Result := TDictionary<integer, string>.Create;
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
  LQuery.Close;
  LQuery.SQL.Text := 'SELECT FIL_CODIGO, FIL_RAZAO_SOCIAL FROM FILIAL ';
  LQuery.Open;

  while not LQuery.EOF do
  begin
    Result.Add(LQuery.FieldByName('FIL_CODIGO').AsInteger, LQuery.FieldByName('FIL_RAZAO_SOCIAL')
      .AsString);
    LQuery.Next;
  end;
end;

function TPDVNETService.BuscarReferencias: TObjectList<TReferencia>;
var
  LQuery: IQuery;
  LReferencia: TReferencia;
begin
  Result := TObjectList<TReferencia>.Create;

  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
  LQuery.SQL.Text := ' SELECT REF_DESCRICAO, REF_REFERENCIA, ' +
    'GRUM_DESCRICAO, MOD_DESCRICAO, MAP_DESCRICAO, COL_DESCRICAO, LIN_DESCRICAO ' +
    'FROM REFERENCIAS R ' +
    'LEFT JOIN REFERENCIASITE on ((RES_COLECAO = REF_COLECAO) and (RES_REFERENCIA = REF_REFERENCIA)) '
    + 'LEFT JOIN NCM on (REF_NCM = NCM_CODIGO) LEFT JOIN UNIDADES on (REF_UNIDADE2 = UNI_CODIGO) ' +
    'LEFT JOIN MATERIAPRIMA MAP ON (MAP_CODIGO = REF_MATERIA) ' +
    'LEFT JOIN GRUPOMATERIAIS GRUM ON (GRUM_CODIGO = REF_GRUPO) ' +
    'LEFT JOIN LINHA LIN ON (LIN_CODIGO = REF_LINHA) ' +
    'LEFT JOIN COLECOES COL ON (COL_CODIGO = REF_COLECAO) ' +
    'LEFT JOIN MODELOS MOD ON (MOD_CODIGO = REF_MODELO) ' +
    'WHERE REF_DESCRICAO <> '''' AND REF_SITE = 1 AND RES_NOME <> '''' ' + 'AND REF_INATIVO2 = 0 ' +
    'ORDER BY REF_REFERENCIA';
  LQuery.Open;

  while not LQuery.EOF do
  begin
    LReferencia := TReferencia.Create;
    LReferencia.Referencia := LQuery.FieldByName('REF_REFERENCIA').AsString.Trim;
    LReferencia.Nome := LQuery.FieldByName('REF_DESCRICAO').AsString.Trim;
    LReferencia.Departamento := LQuery.FieldByName('GRUM_DESCRICAO').AsString.Trim;
    LReferencia.Categoria := LQuery.FieldByName('MOD_DESCRICAO').AsString.Trim;
    LReferencia.Grupo := LQuery.FieldByName('MAP_DESCRICAO').AsString.Trim;
    LReferencia.Colecao := LQuery.FieldByName('COL_DESCRICAO').AsString.Trim;
    LReferencia.Material := LQuery.FieldByName('LIN_DESCRICAO').AsString.Trim;

    Result.Add(LReferencia);
    LQuery.Next;
  end;
end;

function TPDVNETService.BuscarTabelasDePreco: TOrderedDictionary<integer, string>;
var
  LQuery: IQuery;
begin
  Result := TOrderedDictionary<integer, string>.Create;

  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
  LQuery.SQL.Text := 'SELECT TAB_CODIGO, TAB_DESCRICAO FROM TABELAPRECO WHERE TAB_INATIVO = 0 ';
  LQuery.Open;

  while not LQuery.EOF do
  begin
    Result.Add(LQuery.FieldByName('TAB_CODIGO').AsInteger, LQuery.FieldByName('TAB_DESCRICAO')
      .AsString);
    LQuery.Next;
  end;
end;

constructor TPDVNETService.Create(AConfigurador: ISQLiteService);
var
  LConfiguracoes: TConfiguracao;
begin
  FConfigurador := AConfigurador;
  LConfiguracoes := FConfigurador.Configuracoes.Ler(0);
  try
    FConexao := TConnection.getSQLServerConnection(LConfiguracoes);
  finally
    LConfiguracoes.Free;
  end;

  FBuscarMovimentos := TPDVNETRegistrosMovimentados.Create(FConexao, FConfigurador);
end;

procedure TPDVNETService.CriarEstruturaSincronizacao;
begin
  FConexao.Connected := true;
  try
    try
      FConexao.StartTransaction;
      TabelaMovimentos;
      Triggers;
      FConexao.Commit;
    except
      FConexao.RollBack;
      raise;
    end;
  finally
    FConexao.Connected := false;
  end;
end;

function TPDVNETService.GetBancoConfigurado: Boolean;
var
  LQuery: IQuery;
  LConexao: IConexao;
begin
  LConexao := FConexao.Clone;
  if not LConexao.Connected then
    exit(false);

  LQuery := TQueryFactory.New.GetQuery(LConexao);
  LQuery.Close;
  LQuery.SQL.Text := 'SELECT 1 FROM INFORMATION_SCHEMA.TABLES ' +
    'WHERE TABLE_NAME = ''MOVIMENTOS_MIGRAR_BLING'' ';
  LQuery.Open;
  Result := LQuery.RecordCount > 0;
end;

function TPDVNETService.GetBuscarMovimentos: IRegistrosMovimentados;
begin
  Result := FBuscarMovimentos;
  FBuscarMovimentos.LerDadosCadastrais;
  FBuscarMovimentos.LerDadosProdutos;
end;

procedure TPDVNETService.TabelaMovimentos;
var
  LQuery1, LQuery2: IQuery;
begin
  try
    LQuery1 := TQueryFactory.New.GetQuery(FConexao);
    LQuery1.Close;
    LQuery1.SQL.Text := 'IF OBJECT_ID(''MOVIMENTOS_MIGRAR_BLING'', ''U'') IS NOT NULL ' +
      'DROP TABLE MOVIMENTOS_MIGRAR_BLING ';
    LQuery1.ExecSQL;

    LQuery2 := TQueryFactory.New.GetQuery(FConexao);
    LQuery2.Close;
    LQuery2.SQL.Text := 'CREATE TABLE MOVIMENTOS_MIGRAR_BLING ( ' + #13#10 +
      '    ID INT IDENTITY(1,1) PRIMARY KEY NOT NULL, ' + #13#10 +
      '    ID_REG VARCHAR(60) NOT NULL, ' + #13#10 + '    TABELA VARCHAR(60) NOT NULL, ' + #13#10 +
      '    TIPO CHAR(1) NOT NULL, ' + #13#10 + '    DATA DATETIME NOT NULL DEFAULT GETDATE())';
    LQuery2.ExecSQL;
    TLogSubject.GetInstance.NotifyAll('Tabela de movimentos criada no PDVNET');
  except
    on E: Exception do
    begin
      TLogSubject.GetInstance.NotifyAll('Não foi possível criar a estrutura da tabela.' + #13#10 +
        E.Message);
    end;
  end;
end;

function TPDVNETService.TestarConexaoSQLServer: Boolean;
var
  LConexao: IConexao;
  LConfiguracoes: TConfiguracao;
begin
  LConfiguracoes := FConfigurador.Configuracoes.Ler(0);
  try
    try
      LConexao := TConexaoFactory.New.GetConexao({$IFDEF USE_FD_MSSQL}dpFD{$ELSE}dpADO{$ENDIF});
      LConexao.BaseConectada := 'PDVNET';
      LConexao.Params.Add('Server=' + LConfiguracoes.PDVNET_Server);
      LConexao.Params.Add('OSAuthent=No');
      LConexao.Params.Add('Database=' + LConfiguracoes.PDVNET_Database);
      LConexao.Params.Add('User_Name=' + LConfiguracoes.PDVNET_UserName);
      LConexao.Params.Add('Password=' + LConfiguracoes.PDVNET_Password);
      LConexao.Params.Add('LoginTimeout=2');
      LConexao.Params.Add('DriverID=MSSQL');
      LConexao.Params.Add('MARS=Yes');
      LConexao.Connected := true;
      Result := true;
    except
      on E: Exception do
      begin
        ShowMessage(E.Message);
        Result := false;
      end;
    end;
  finally
    LConfiguracoes.Free;
  end;
end;

procedure TPDVNETService.Triggers;
var
  Tabelas: TDictionary<string, TTabelaDados>;
  Tabela: TPair<string, TTabelaDados>;
begin
  Tabelas := GetTabelasSinc;
  try
    for Tabela in Tabelas do
    begin
      CriarTrigger(Tabela.Key, Tabela.Value);
      CriarRegistrosMovimentacao(Tabela.Key, Tabela.Value);
    end;
  finally
    Tabelas.Free;
  end;
end;

function TPDVNETService.GetTabelasSinc: TDictionary<string, TTabelaDados>;
begin
  Result := TDictionary<string, TTabelaDados>.Create;
  DadosTabela(Result, 'GRUPOMATERIAIS', 'GRUPOMATERIAIS', 'GRUM_CODIGO', 'GRUM_INATIVO2=0');
  DadosTabela(Result, 'MODELOS', 'MODELOS', 'MOD_CODIGO', 'MOD_INATIVO2=0');
  DadosTabela(Result, 'COLECOES', 'COLECOES', 'COL_CODIGO', 'COL_INATIVO2=0');
  DadosTabela(Result, 'MATERIAPRIMA', 'MATERIAPRIMA', 'MAP_CODIGO', 'MAP_INATIVO2=0');
  DadosTabela(Result, 'LINHA', 'LINHA', 'LIN_CODIGO', 'LIN_INATIVO2=0');
  DadosTabela(Result, 'MATERIAIS', 'MATERIAIS', 'MAT_CODIGO', 'MAT_INATIVO=0');
  DadosTabela(Result, 'REFERENCIAS', 'REFERENCIAS', 'REF_REFERENCIA', 'REF_INATIVO2=0');
  DadosTabela(Result, 'CORES', 'CORES', 'COR_CODIGO', 'COR_INATIVO2=0');
  DadosTabela(Result, 'TAMANHOS', 'TAMANHOS', 'TAM_CODIGO', 'TAM_INATIVO=0');
  DadosTabela(Result, 'FILIAL', 'FILIAL', 'FIL_CODIGO', 'FIL_INATIVA=0');
  DadosTabela(Result, 'TABELAPRECO', 'TABELAPRECO', 'TAB_CODIGO', 'TAB_INATIVO = 0');
  DadosTabela(Result, 'SALDOS', 'SALDOS', 'SAL_PRODUTO', '',
    'CAST(SAL_FILIAL AS VARCHAR) + ''.'' + CAST(SAL_PRODUTO AS VARCHAR)');
  DadosTabela(Result, 'PRECO', 'PRECO', 'PRE_PRODUTO', '',
    'CAST(PRE_TABELA AS VARCHAR) + ''.'' + CAST(PRE_PRODUTO AS VARCHAR)');
end;

procedure TPDVNETService.LimparMovimentos(AValue: IRegistrosMovimentados);
begin
  FBuscarMovimentos.LimparMovimentos;
end;

procedure TPDVNETService.SincronizarReferencias(AReferencias: TList<string>);
var
  LQuery: IQuery;
  LReferencia: string;
begin
  try
    LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
    LQuery.SQL.Text := ' INSERT INTO MOVIMENTOS_MIGRAR_BLING (ID_REG, TABELA, TIPO) VALUES ';

    for LReferencia in AReferencias do
    begin
      LQuery.SQL.Add('( ' + LReferencia + ',''REFERENCIAS'',''U'' )' +
        IfThen(LReferencia = AReferencias.Last, ';', ','));
    end;

    LQuery.SQL.Text := LQuery.SQL.Text.Trim;
    LQuery.SQL.Text := Copy(LQuery.SQL.Text, 1, Length(LQuery.SQL.Text) - 1);

    if AReferencias.Count > 0 then
      LQuery.ExecSQL;
  finally
    AReferencias.Free;
  end;
end;

procedure TPDVNETService.DadosTabela(AListaTabelas: TDictionary<string, TTabelaDados>;
  ATabelaOrigem, ATabelaDestino, APKValue, ACondicaoInserirDadosInicial: string;
  APKComposto: string = '');
var
  dados: TTabelaDados;
begin
  TLogSubject.GetInstance.NotifyAll('Criando estrutura para ' + ATabelaOrigem + ' no PDVNET');
  dados.PK := APKValue;
  dados.PKComposto := APKComposto;
  dados.CondicaoInserirDadosInicial := ACondicaoInserirDadosInicial;

  dados.TabelaDestino := ATabelaDestino;
  AListaTabelas.Add(ATabelaOrigem, dados);
end;

procedure TPDVNETService.DestruirObjetos;
begin
  FBuscarMovimentos.DestruirObjetos;
end;

procedure TPDVNETService.CriarRegistrosMovimentacao(ATabelaOrigem: string;
  ATabelaDados: TTabelaDados);
var
  LQuery: IQuery;
  LCondicao: string;
begin
  LCondicao := ATabelaDados.CondicaoInserirDadosInicial;
  try
    LQuery := TQueryFactory.New.GetQuery(FConexao);
    LQuery.Close;
    LQuery.SQL.Text := 'UPDATE ' + ATabelaOrigem + ' SET ' + ATabelaDados.PK + ' = ' +
      ATabelaDados.PK + IfThen(LCondicao <> '', ' WHERE ' + LCondicao, '');
    LQuery.ExecSQL;
    TLogSubject.GetInstance.NotifyAll('Criando registros de movimentações no PDVNET');
  except
    on E: Exception do
      TLogSubject.GetInstance.NotifyAll
        ('Não foi possível criar os registros de movimentação para a tabela ' + ATabelaOrigem +
        #13#10 + E.Message);
  end;
end;

procedure TPDVNETService.CriarTrigger(ATabelaOrigem: string; ATabelaDados: TTabelaDados);
var
  LQuery1, LQuery2: IQuery;
  PK: string;
begin
  PK := ATabelaDados.PK;
  if (ATabelaDados.PKComposto <> '') then
    PK := ATabelaDados.PKComposto;
  try
    LQuery1 := TQueryFactory.New.GetQuery(FConexao);
    LQuery1.Close;
    LQuery1.SQL.Text := 'IF OBJECT_ID(''TRG_' + ATabelaOrigem +
      '_SYNC_BLING'', ''TR'') IS NOT NULL ' + 'DROP TRIGGER TRG_' + ATabelaOrigem + '_SYNC_BLING;';
    LQuery1.ExecSQL;

    LQuery2 := TQueryFactory.New.GetQuery(FConexao);
    LQuery2.Close;
    LQuery2.SQL.Text := 'CREATE TRIGGER TRG_' + ATabelaOrigem + '_SYNC_BLING ' + #13#10 + 'ON ' +
      ATabelaOrigem + #13#10 + 'AFTER INSERT, UPDATE, DELETE ' + #13#10 + 'AS ' + #13#10 + 'BEGIN '
      + #13#10 + '  SET NOCOUNT ON; ' + #13#10 + #13#10 +
      '  IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted) ' + #13#10 +
      '  BEGIN ' + #13#10 + '    INSERT INTO MOVIMENTOS_MIGRAR_BLING (ID_REG, TABELA, TIPO) ' +
      #13#10 + '    SELECT ' + PK + ', ''' + ATabelaDados.TabelaDestino + ''', ''I'' ' + #13#10 +
      '    FROM inserted; ' + #13#10 + '  END ' + #13#10 + ' ' + #13#10 +
      '  IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted) ' + #13#10 +
      '  BEGIN ' + #13#10 + '    INSERT INTO MOVIMENTOS_MIGRAR_BLING (ID_REG, TABELA, TIPO) ' +
      #13#10 + '    SELECT ' + PK + ', ''' + ATabelaDados.TabelaDestino + ''', ''U'' ' + #13#10 +
      '    FROM inserted; ' + #13#10 + '  END ' + #13#10 + ' ' + #13#10 +
      '  IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted) ' + #13#10 +
      '  BEGIN ' + #13#10 + '    INSERT INTO MOVIMENTOS_MIGRAR_BLING (ID_REG, TABELA, TIPO) ' +
      #13#10 + '    SELECT ' + PK + ', ''' + ATabelaDados.TabelaDestino + ''', ''D'' ' + #13#10 +
      '    FROM deleted; ' + #13#10 + '  END ' + #13#10 + ' END ';
    LQuery2.ExecSQL;
    TLogSubject.GetInstance.NotifyAll('Trigger criada para ' + ATabelaOrigem + ' no PDVNET');
  except
    on E: Exception do
      TLogSubject.GetInstance.NotifyAll('Não foi possível criar a trigger para a tabela ' +
        ATabelaOrigem + #13#10 + E.Message);
  end;

end;

end.
