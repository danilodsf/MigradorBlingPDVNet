unit MigraBling.Model.Services.SubServices.SQLite.DAOConfiguracoes;

interface

uses
  System.Generics.Collections,
  MigraBling.Model.Interfaces.Dao,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.QueryFactory,
  MigraBling.Model.QueryFactory,
  System.SysUtils,
  MigraBling.Model.Utils,
  Data.DB,
  MigraBling.Model.Configuracao;

type
  TModelDaoConfiguracoes = class(TInterfacedObject, IDAOConfiguracoesSQLite<TConfiguracao>)
  private
    FConexao: IConexao;
  public
    constructor Create(AConexao: IConexao);
    function Ler(AID: integer): TConfiguracao; overload;
    procedure Atualizar(AObj: TConfiguracao);
    procedure Criar(AObj: TConfiguracao); overload;
  end;

implementation

{ TModalDaoConfiguracoes }

procedure TModelDaoConfiguracoes.Atualizar(AObj: TConfiguracao);
var
  LQuery: IQuery;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
  LQuery.SQL.Text := 'UPDATE CONFIGURACOES SET ACCESS_TOKEN = :PACCESS_TOKEN ' +
    '   ,REFRESH_TOKEN = :PREFRESH_TOKEN, EXPIRES_IN = :PEXPIRES_IN ' +
    '   ,CLIENT_ID = :PCLIENT_ID, CLIENT_SECRET = :PCLIENT_SECRET ' +
    '   ,PDVNET_SERVER = :PPDVNET_SERVER, PDVNET_DATABASE = :PPDVNET_DATABASE ' +
    '   ,PDVNET_USERNAME = :PPDVNET_USERNAME, PDVNET_PASSWORD = :PPDVNET_PASSWORD ' +
    '   ,TEMPO_SINRONIZACAO = :PTEMPO_SINRONIZACAO, ATIVAR = :PATIVAR ' +
    '   ,QTD_ESTOQUE_SUBIR = :PQTD_ESTOQUE_SUBIR, TABELA_PRECO_PADRAO = :PTABELA_PRECO_PADRAO';

  LQuery.ParamByName('PACCESS_TOKEN').AsString := AObj.AccessToken;
  LQuery.ParamByName('PREFRESH_TOKEN').AsString := AObj.RefreshToken;
  LQuery.ParamByName('PEXPIRES_IN').AsString := DateTimeToStr(AObj.ExpiresIn);
  LQuery.ParamByName('PCLIENT_ID').AsString := AObj.ClientID;
  LQuery.ParamByName('PCLIENT_SECRET').AsString := AObj.ClientSecret;
  LQuery.ParamByName('PPDVNET_SERVER').AsString := AObj.PDVNET_Server;
  LQuery.ParamByName('PPDVNET_DATABASE').AsString := AObj.PDVNET_Database;
  LQuery.ParamByName('PPDVNET_USERNAME').AsString := AObj.PDVNET_UserName;
  LQuery.ParamByName('PPDVNET_PASSWORD').AsString := AObj.PDVNET_Password;
  LQuery.ParamByName('PTEMPO_SINRONIZACAO').AsInteger := AObj.TempoSincronizacao;
  LQuery.ParamByName('PQTD_ESTOQUE_SUBIR').AsInteger := AObj.QtdEstoqueSubtrair;
  LQuery.ParamByName('PATIVAR').AsInteger := IfThen(AObj.Ativar, 1, 0);
  LQuery.ParamByName('PTABELA_PRECO_PADRAO').AsInteger := AObj.TabelaPrecoPadrao;
  LQuery.ExecSQL;
end;

constructor TModelDaoConfiguracoes.Create(AConexao: IConexao);
begin
  FConexao := AConexao;
end;

procedure TModelDaoConfiguracoes.Criar(AObj: TConfiguracao);
var
  LQuery: IQuery;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
  LQuery.SQL.Text := 'INSERT INTO CONFIGURACOES(ACCESS_TOKEN, REFRESH_TOKEN, EXPIRES_IN, ' +
    'CLIENT_ID, CLIENT_SECRET, PDVNET_SERVER, PDVNET_DATABASE, PDVNET_USERNAME, ' +
    'PDVNET_PASSWORD, TEMPO_SINRONIZACAO, ATIVAR, QTD_ESTOQUE_SUBIR, TABELA_PRECO_PADRAO) ' +
    'VALUES(:PACCESS_TOKEN, :PREFRESH_TOKEN, :PEXPIRES_IN, :PCLIENT_ID, ' +
    ':PCLIENT_SECRET, :PPDVNET_SERVER, :PPDVNET_DATABASE, :PPDVNET_USERNAME, ' +
    ':PPDVNET_PASSWORD, :PTEMPO_SINRONIZACAO, :PATIVAR, :PQTD_ESTOQUE_SUBIR, :PTABELA_PRECO_PADRAO) ';

  LQuery.ParamByName('PACCESS_TOKEN').AsString := AObj.AccessToken;
  LQuery.ParamByName('PREFRESH_TOKEN').AsString := AObj.RefreshToken;
  LQuery.ParamByName('PEXPIRES_IN').AsString := DateTimeToStr(AObj.ExpiresIn);
  LQuery.ParamByName('PCLIENT_ID').AsString := AObj.ClientID;
  LQuery.ParamByName('PCLIENT_SECRET').AsString := AObj.ClientSecret;
  LQuery.ParamByName('PPDVNET_SERVER').AsString := AObj.PDVNET_Server;
  LQuery.ParamByName('PPDVNET_DATABASE').AsString := AObj.PDVNET_Database;
  LQuery.ParamByName('PPDVNET_USERNAME').AsString := AObj.PDVNET_UserName;
  LQuery.ParamByName('PPDVNET_PASSWORD').AsString := AObj.PDVNET_Password;
  LQuery.ParamByName('PTEMPO_SINRONIZACAO').AsInteger := AObj.TempoSincronizacao;
  LQuery.ParamByName('PATIVAR').AsInteger := IfThen(AObj.Ativar, 1, 0);
  LQuery.ParamByName('PQTD_ESTOQUE_SUBIR').AsInteger := AObj.QtdEstoqueSubtrair;
  LQuery.ParamByName('PTABELA_PRECO_PADRAO').AsInteger := AObj.TabelaPrecoPadrao;
  LQuery.ExecSQL;
end;

function TModelDaoConfiguracoes.Ler(AID: integer): TConfiguracao;
var
  LQuery: IQuery;
begin
  Result := TConfiguracao.Create;
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
  LQuery.SQL.Text := 'SELECT ACCESS_TOKEN, REFRESH_TOKEN, EXPIRES_IN, CLIENT_ID, CLIENT_SECRET, ' +
    'PDVNET_SERVER, PDVNET_DATABASE, PDVNET_USERNAME, PDVNET_PASSWORD, TEMPO_SINRONIZACAO, ' +
    'ATIVAR, QTD_ESTOQUE_SUBIR, DT_ULTIMA_CONSULTA_HOOKDECK, TABELA_PRECO_PADRAO, ' +
    'PASTA_BACKUP FROM CONFIGURACOES';
  LQuery.Open;
  if (not LQuery.IsEmpty) then
  begin
    Result.AccessToken := LQuery.FieldByName('ACCESS_TOKEN').AsString;
    Result.RefreshToken := LQuery.FieldByName('REFRESH_TOKEN').AsString;
    Result.ExpiresIn := StrToDateTime(LQuery.FieldByName('EXPIRES_IN').AsString);
    Result.ClientID := LQuery.FieldByName('CLIENT_ID').AsString;
    Result.ClientSecret := LQuery.FieldByName('CLIENT_SECRET').AsString;
    Result.PDVNET_Server := LQuery.FieldByName('PDVNET_SERVER').AsString;
    Result.PDVNET_Database := LQuery.FieldByName('PDVNET_DATABASE').AsString;
    Result.PDVNET_UserName := LQuery.FieldByName('PDVNET_USERNAME').AsString;
    Result.PDVNET_Password := LQuery.FieldByName('PDVNET_PASSWORD').AsString;
{$IFDEF DEBUG}
    Result.PDVNET_Server := '192.168.88.250';
    Result.PDVNET_UserName := 'sa';
    Result.PDVNET_Password := '*havaianas40';
{$ENDIF}
    Result.TempoSincronizacao := LQuery.FieldByName('TEMPO_SINRONIZACAO').AsInteger;
    Result.Ativar := LQuery.FieldByName('ATIVAR').AsInteger = 1;
    Result.QtdEstoqueSubtrair := LQuery.FieldByName('QTD_ESTOQUE_SUBIR').AsInteger;
    Result.DataUltimaConsultaHookDeck :=
      getDataSQLite(LQuery.FieldByName('DT_ULTIMA_CONSULTA_HOOKDECK').AsString);
    Result.TabelaPrecoPadrao := LQuery.FieldByName('TABELA_PRECO_PADRAO').AsInteger;
    if Result.TabelaPrecoPadrao <= 0 then
      Result.TabelaPrecoPadrao := 29;
    Result.PastaBackup := LQuery.FieldByName('PASTA_BACKUP').AsString;
  end;
end;

end.
