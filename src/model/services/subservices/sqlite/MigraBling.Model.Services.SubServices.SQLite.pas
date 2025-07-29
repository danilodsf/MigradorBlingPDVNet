unit MigraBling.Model.Services.SubServices.SQLite;

interface

uses
  System.Classes,
  System.Threading,
  System.SysUtils,
  System.Generics.Collections,
  MigraBling.Model.Utils,
  MigraBling.Model.Services.SubServices.Interfaces.SQLite,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.ConexaoFactory,
  MigraBling.Model.Services.SubServices.SQLite.DAOConfiguracoes,
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.Configuracao,
  MigraBling.Model.Services.SubServices.Interfaces.RegistrosMovimentados,
  MigraBling.Model.Movimentos,
  MigraBling.Model.Categorias,
  MigraBling.Model.Departamentos,
  MigraBling.Model.Colecoes,
  MigraBling.Model.Grupos,
  MigraBling.Model.Materiais,
  MigraBling.Model.Referencias,
  MigraBling.Model.Cores,
  MigraBling.Model.Tamanhos,
  MigraBling.Model.Filiais,
  MigraBling.Model.TabelaPrecos,
  MigraBling.Model.Precos,
  MigraBling.Model.Variacoes,
  MigraBling.Model.Saldos,
  MigraBling.Model.MovimentoEstoque,
  MigraBling.Model.Services.SubServices.SQLite.DAOMovimentos,
  MigraBling.Model.Services.SubServices.SQLite.DAOCategorias,
  MigraBling.Model.Services.SubServices.SQLite.DAODepartamentos,
  MigraBling.Model.Services.SubServices.SQLite.RegistrosMovimentados,
  MigraBling.Model.Services.SubServices.SQLite.DAOColecoes,
  MigraBling.Model.Services.SubServices.SQLite.DAOGrupos,
  MigraBling.Model.Services.SubServices.SQLite.DAOMateriais,
  MigraBling.Model.Services.SubServices.SQLite.DAOReferencias,
  MigraBling.Model.Services.SubServices.SQLite.DAOCores,
  MigraBling.Model.Services.SubServices.SQLite.DAOTamanhos,
  MigraBling.Model.Services.SubServices.SQLite.DAOFiliais,
  MigraBling.Model.Services.SubServices.SQLite.DAOTabelaPrecos,
  MigraBling.Model.Services.SubServices.SQLite.DAOPrecos,
  MigraBling.Model.Services.SubServices.SQLite.DAOVariacoes,
  MigraBling.Model.Services.SubServices.SQLite.DAOSaldos,
  MigraBling.Model.Services.SubServices.SQLite.DAOVendas,
  MigraBling.Model.Services.SubServices.Connection,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.QueryFactory,
  MigraBling.Model.QueryFactory;

type
  TSQLite = class(TInterfacedObject, ISQLiteService)
  private
    FConexao: IConexao;
    FConfiguracoes: IDAOConfiguracoesSQLite<TConfiguracao>;
    FConfiguracao: TConfiguracao;
    FAtivado: Boolean;
    FBuscarMovimentos: IRegistrosMovimentados;
    FMovimentos: IDAOMovimentosSQLite<TMovimento>;
    FCategorias: IDAOTabelasSQLite<TCategoria>;
    FDepartamentos: IDAOTabelasSQLite<TDepartamento>;
    FColecoes: IDAOTabelasSQLite<TColecao>;
    FGrupos: IDAOTabelasSQLite<TGrupo>;
    FMateriais: IDAOTabelasSQLite<TMaterial>;
    FReferencias: IDAOTabelasSQLite<TReferencia>;
    FCores: IDAOTabelasSQLite<TCor>;
    FTamanhos: IDAOTabelasSQLite<TTamanho>;
    FFiliais: IDAOTabelasSQLite<TFilial>;
    FTabelaPrecos: IDAOTabelasSQLite<TTabelaPreco>;
    FPrecos: IDAOTabelasSQLite<TPreco>;
    FVariacoes: IDAOTabelasSQLite<TVariacao>;
    FSaldos: IDAOTabelasSQLite<TSaldo>;
    FVendas: IDAOTabelasSQLite<TMovimentoEstoque>;

    function GetConfiguracoes: IDAOConfiguracoesSQLite<TConfiguracao>;
    function GetConfiguracao: TConfiguracao;
    function GetTempoSincronizacao: integer;
    function GetAtivado: Boolean;
    function GetBuscarMovimentosDeCadastros: IRegistrosMovimentados;
    function GetBuscarMovimentosDeProdutos: IRegistrosMovimentados;
    procedure SetConfiguracoes(AValue: IDAOConfiguracoesSQLite<TConfiguracao>);
    procedure SetConfiguracao(AValue: TConfiguracao);
    procedure SetAtivado(AValue: Boolean);
  public
    function BuscarFiliais: TDictionary<integer, Boolean>;
    procedure GravarConfigFiliaisEstoque(AValue: TDictionary<integer, Boolean>);
    procedure LimparMovimentos(AValue: IRegistrosMovimentados);
    procedure GravarMovimentos(AValue: IRegistrosMovimentados);
    procedure GravarIDsBling(AValue: IRegistrosMovimentados);
    procedure GravarVendasBling(AValue: TObjectList<TMovimentoEstoque>);
    procedure DestruirObjetos;
    property Configuracoes: IDAOConfiguracoesSQLite<TConfiguracao> read GetConfiguracoes
      write SetConfiguracoes;
    property Configuracao: TConfiguracao read GetConfiguracao write SetConfiguracao;
    property TempoSincronizacao: integer read GetTempoSincronizacao;
    property Ativado: Boolean read GetAtivado write SetAtivado;
    property BuscarMovimentosDeCadastros: IRegistrosMovimentados
      read GetBuscarMovimentosDeCadastros;
    property BuscarMovimentosDeProdutos: IRegistrosMovimentados read GetBuscarMovimentosDeProdutos;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  MigraBling.Model.LogObserver;

{ TSQLite }

constructor TSQLite.Create;
begin
  FConexao := TConnection.getSQLiteConnection;

  FConfiguracoes := TModelDaoConfiguracoes.Create(FConexao);
  FConfiguracao := FConfiguracoes.Ler(0);

  FMovimentos := TDAOMovimentosSQLite.Create(FConexao);
  FBuscarMovimentos := TSQLiteRegistrosMovimentados.Create(FConexao, FConfiguracoes);

  FCategorias := TDAOCategoriasSQLite.Create(FConexao);
  FDepartamentos := TDAODepartamentosSQLite.Create(FConexao);
  FColecoes := TDAOColecoesSQLite.Create(FConexao);
  FGrupos := TDAOGruposSQLite.Create(FConexao);
  FMateriais := TDAOMateriaisSQLite.Create(FConexao);
  FReferencias := TDAOReferenciasSQLite.Create(FConexao, FConfiguracoes);
  FCores := TDAOCoresSQLite.Create(FConexao);
  FTamanhos := TDAOTamanhosSQLite.Create(FConexao);
  FFiliais := TDAOFiliaisSQLite.Create(FConexao);
  FTabelaPrecos := TDAOTabelaPrecosSQLite.Create(FConexao);
  FPrecos := TDAOPrecosSQLite.Create(FConexao);
  FVariacoes := TDAOVariacoesSQLite.Create(FConexao);
  FSaldos := TDAOSaldosSQLite.Create(FConexao);
  FVendas := TDAOVendasSQLite.Create(FConexao, FConfiguracoes);
end;

destructor TSQLite.Destroy;
begin
  FConfiguracao.Free;
  inherited;
end;

procedure TSQLite.DestruirObjetos;
begin
  FBuscarMovimentos.DestruirObjetos;
end;

function TSQLite.GetConfiguracoes: IDAOConfiguracoesSQLite<TConfiguracao>;
begin
  Result := FConfiguracoes;
end;

function TSQLite.GetTempoSincronizacao: integer;
begin
  Result := FConfiguracao.TempoSincronizacao;
end;

procedure TSQLite.GravarMovimentos(AValue: IRegistrosMovimentados);
var
  Tasks: TArray<ITask>;
begin
  SetLength(Tasks, 14);
  Tasks[0] := TTask.Run(
    procedure
    begin
      TLogSubject.GetInstance.NotifyAll('Gravando categorias');
      FCategorias.Persistir(AValue.BuscarCategorias);
    end);
  Tasks[1] := TTask.Run(
    procedure
    begin
      TLogSubject.GetInstance.NotifyAll('Gravando departamentos');
      FDepartamentos.Persistir(AValue.BuscarDepartamentos);
    end);
  Tasks[2] := TTask.Run(
    procedure
    begin
      TLogSubject.GetInstance.NotifyAll('Gravando coleções');
      FColecoes.Persistir(AValue.BuscarColecoes);
    end);
  Tasks[3] := TTask.Run(
    procedure
    begin
      TLogSubject.GetInstance.NotifyAll('Gravando grupos');
      FGrupos.Persistir(AValue.BuscarGrupos);
    end);
  Tasks[4] := TTask.Run(
    procedure
    begin
      TLogSubject.GetInstance.NotifyAll('Gravando materiais');
      FMateriais.Persistir(AValue.BuscarMateriais);
    end);
  Tasks[5] := TTask.Run(
    procedure
    begin
      TLogSubject.GetInstance.NotifyAll('Gravando cores');
      FCores.Persistir(AValue.BuscarCores);
    end);
  Tasks[6] := TTask.Run(
    procedure
    begin
      TLogSubject.GetInstance.NotifyAll('Gravando tamanhos');
      FTamanhos.Persistir(AValue.BuscarTamanhos);
    end);
  Tasks[7] := TTask.Run(
    procedure
    begin
      TLogSubject.GetInstance.NotifyAll('Gravando filiais');
      FFiliais.Persistir(AValue.BuscarFiliais);
    end);
  Tasks[8] := TTask.Run(
    procedure
    begin
      TLogSubject.GetInstance.NotifyAll('Gravando tabelas de preços');
      FTabelaPrecos.Persistir(AValue.BuscarTabelaPrecos);
    end);
  Tasks[9] := TTask.Run(
    procedure
    begin
      TLogSubject.GetInstance.NotifyAll('Gravando preços');
      FPrecos.Persistir(AValue.BuscarPrecos);
    end);
  Tasks[10] := TTask.Run(
    procedure
    begin
      TLogSubject.GetInstance.NotifyAll('Gravando referências');
      FReferencias.Persistir(AValue.BuscarReferencias);
    end);
  Tasks[11] := TTask.Run(
    procedure
    begin
      TLogSubject.GetInstance.NotifyAll('Gravando variações');
      FVariacoes.Persistir(AValue.BuscarVariacoes);
    end);
  Tasks[12] := TTask.Run(
    procedure
    begin
      TLogSubject.GetInstance.NotifyAll('Gravando saldos');
      FSaldos.Persistir(AValue.BuscarSaldos);
    end);
  Tasks[13] := TTask.Run(
    procedure
    begin
      TLogSubject.GetInstance.NotifyAll('Gravando movimentos');
      FMovimentos.Criar(AValue.BuscarMovimentos);
    end);
  TTask.WaitForAll(Tasks);
end;

procedure TSQLite.GravarVendasBling(AValue: TObjectList<TMovimentoEstoque>);
begin
  TLogSubject.GetInstance.NotifyAll('Gravando vendas do Bling no SQLite');
end;

procedure TSQLite.LimparMovimentos;
begin
  TLogSubject.GetInstance.NotifyAll('Limpando movimentos locais');
  FBuscarMovimentos.LimparMovimentos;
end;

function TSQLite.GetAtivado: Boolean;
begin
  Result := FConfiguracao.Ativar;
end;

function TSQLite.GetBuscarMovimentosDeCadastros: IRegistrosMovimentados;
begin
  Result := FBuscarMovimentos;
  FBuscarMovimentos.LerDadosCadastrais;
end;

function TSQLite.GetBuscarMovimentosDeProdutos: IRegistrosMovimentados;
begin
  Result := FBuscarMovimentos;
  FBuscarMovimentos.LerDadosProdutos;
end;

procedure TSQLite.SetAtivado(AValue: Boolean);
begin
  FAtivado := AValue;
  FConfiguracao.Ativar := FAtivado;
  FConfiguracoes.Atualizar(FConfiguracao);
end;

function TSQLite.GetConfiguracao: TConfiguracao;
begin
  Result := FConfiguracao;
end;

procedure TSQLite.SetConfiguracao(AValue: TConfiguracao);
begin
  FConfiguracao := AValue;
end;

procedure TSQLite.SetConfiguracoes(AValue: IDAOConfiguracoesSQLite<TConfiguracao>);
begin
  FConfiguracoes := AValue;
end;

function TSQLite.BuscarFiliais: TDictionary<integer, Boolean>;
var
  LQuery: IQuery;
begin
  Result := TDictionary<integer, Boolean>.Create;

  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
  LQuery.SQL.Text := 'SELECT FIL_CODIGO, DESCONSIDERAR_ESTOQUE FROM FILIAL ';
  LQuery.Open;

  while not LQuery.EOF do
  begin
    Result.Add(LQuery.FieldByName('FIL_CODIGO').AsInteger,
      LQuery.FieldByName('DESCONSIDERAR_ESTOQUE').AsInteger = 1);
    LQuery.Next;
  end;
end;

procedure TSQLite.GravarConfigFiliaisEstoque(AValue: TDictionary<integer, Boolean>);
var
  LQuery: IQuery;
  I: integer;
  Filial: TPair<integer, Boolean>;
begin
  try
    if AValue.IsEmpty then
      exit;
    LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
    LQuery.SQL.Text := 'UPDATE FILIAL SET DESCONSIDERAR_ESTOQUE = :PDESCONSIDERAR_ESTOQUE ' +
      'WHERE FIL_CODIGO = :PFIL_CODIGO ';
    LQuery.ArraySize := AValue.Count;

    I := 0;
    for Filial in AValue do
    begin
      LQuery.ParamByName('PFIL_CODIGO').AsIntegers(I, Filial.Key);
      LQuery.ParamByName('PDESCONSIDERAR_ESTOQUE').AsIntegers(I, ifThen(Filial.Value, 0, 1));
      Inc(I);
    end;

    LQuery.Execute(AValue.Count);
  finally
    AValue.Free;
  end;
end;

procedure TSQLite.GravarIDsBling(AValue: IRegistrosMovimentados);
var
  Tasks: TArray<ITask>;
begin
  SetLength(Tasks, 5);
  Tasks[0] := TTask.Run(
    procedure
    begin
      TLogSubject.GetInstance.NotifyAll('Gravando ID Bling em categorias');
      FCategorias.GravarIDsBling(AValue.BuscarCategorias);
    end);
  Tasks[1] := TTask.Run(
    procedure
    begin
      TLogSubject.GetInstance.NotifyAll('Gravando ID Bling em departamentos');
      FDepartamentos.GravarIDsBling(AValue.BuscarDepartamentos);
      TLogSubject.GetInstance.NotifyAll('Gravando ID Bling em coleções');
      FColecoes.GravarIDsBling(AValue.BuscarColecoes);
      TLogSubject.GetInstance.NotifyAll('Gravando ID Bling em grupos');
      FGrupos.GravarIDsBling(AValue.BuscarGrupos);
      TLogSubject.GetInstance.NotifyAll('Gravando ID Bling em materiais');
      FMateriais.GravarIDsBling(AValue.BuscarMateriais);
      TLogSubject.GetInstance.NotifyAll('Gravando ID Bling em cores');
      FCores.GravarIDsBling(AValue.BuscarCores);
      TLogSubject.GetInstance.NotifyAll('Gravando ID Bling em tamanhos');
      FTamanhos.GravarIDsBling(AValue.BuscarTamanhos);
    end);
  Tasks[2] := TTask.Run(
    procedure
    begin
      TLogSubject.GetInstance.NotifyAll('Gravando ID Bling em filiais');
      FFiliais.GravarIDsBling(AValue.BuscarFiliais);
    end);
  Tasks[3] := TTask.Run(
    procedure
    begin
      TLogSubject.GetInstance.NotifyAll('Gravando ID Bling em referências');
      FReferencias.GravarIDsBling(AValue.BuscarReferencias);
    end);
  Tasks[4] := TTask.Run(
    procedure
    begin
      TLogSubject.GetInstance.NotifyAll('Gravando ID Bling em saldos');
      FSaldos.GravarIDsBling(AValue.BuscarSaldos);
    end);

  TTask.WaitForAll(Tasks);
end;

end.
