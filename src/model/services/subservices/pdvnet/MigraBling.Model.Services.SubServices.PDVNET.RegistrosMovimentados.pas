unit MigraBling.Model.Services.SubServices.PDVNET.RegistrosMovimentados;

interface

uses
  MigraBling.Model.Interfaces.Conexao,
  System.Generics.Collections,
  System.Classes,
  System.Threading,
  System.SysUtils,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.QueryFactory,
  MigraBling.Model.MapaEntidades,
  MigraBling.Model.Services.SubServices.Interfaces.RegistrosMovimentados,
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.BaseModel,
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
  MigraBling.Model.Services.SubServices.PDVNET.DAOMovimentos,
  MigraBling.Model.Services.SubServices.PDVNET.DAOCategorias,
  MigraBling.Model.Services.SubServices.PDVNET.DAODepartamentos,
  MigraBling.Model.Services.SubServices.PDVNET.DAOColecoes,
  MigraBling.Model.Services.SubServices.PDVNET.DAOGrupos,
  MigraBling.Model.Services.SubServices.PDVNET.DAOMateriais,
  MigraBling.Model.Services.SubServices.PDVNET.DAOReferencias,
  MigraBling.Model.Services.SubServices.PDVNET.DAOCores,
  MigraBling.Model.Services.SubServices.PDVNET.DAOTamanhos,
  MigraBling.Model.Services.SubServices.PDVNET.DAOFiliais,
  MigraBling.Model.Services.SubServices.PDVNET.DAOTabelaPrecos,
  MigraBling.Model.Services.SubServices.PDVNET.DAOPrecos,
  MigraBling.Model.Services.SubServices.PDVNET.DAOVariacoes,
  MigraBling.Model.Services.SubServices.PDVNET.DAOSaldos,
  MigraBling.Model.Services.SubServices.Interfaces.SQLite,
  MigraBling.Model.AppControl;

type
  TPDVNETRegistrosMovimentados = class(TInterfacedObject, IRegistrosMovimentados)
  private
    FConexao: IConexao;
    FMovimentos: IDAOMovimentosPDVNET<TMovimento>;
    FCategorias: IDAOTabelasPDVNET<TCategoria>;
    FDepartamentos: IDAOTabelasPDVNET<TDepartamento>;
    FColecoes: IDAOTabelasPDVNET<TColecao>;
    FGrupos: IDAOTabelasPDVNET<TGrupo>;
    FMateriais: IDAOTabelasPDVNET<TMaterial>;
    FReferencias: IDAOTabelasPDVNET<TReferencia>;
    FCores: IDAOTabelasPDVNET<TCor>;
    FTamanhos: IDAOTabelasPDVNET<TTamanho>;
    FFiliais: IDAOTabelasPDVNET<TFilial>;
    FTabelaPrecos: IDAOTabelasPDVNET<TTabelaPreco>;
    FPrecos: IDAOTabelasPDVNET<TPreco>;
    FVariacoes: IDAOTabelasPDVNET<TVariacao>;
    FSaldos: IDAOTabelasPDVNET<TSaldo>;

    FBuscarMovimentos: TObjectList<TMovimento>;
    FBuscarCategorias: TObjectList<TCategoria>;
    FBuscarDepartamentos: TObjectList<TDepartamento>;
    FBuscarColecoes: TObjectList<TColecao>;
    FBuscarGrupos: TObjectList<TGrupo>;
    FBuscarMateriais: TObjectList<TMaterial>;
    FBuscarReferencias: TObjectList<TReferencia>;
    FBuscarCores: TObjectList<TCor>;
    FBuscarTamanhos: TObjectList<TTamanho>;
    FBuscarFiliais: TObjectList<TFilial>;
    FBuscarTabelaPrecos: TObjectList<TTabelaPreco>;
    FBuscarPrecos: TObjectList<TPreco>;
    FBuscarVariacoes: TObjectList<TVariacao>;
    FBuscarSaldos: TObjectList<TSaldo>;

    function GetBuscarMovimentos: TObjectList<TMovimento>;
    function GetBuscarCategorias: TObjectList<TCategoria>;
    function GetBuscarDepartamentos: TObjectList<TDepartamento>;
    function GetBuscarColecoes: TObjectList<TColecao>;
    function GetBuscarGrupos: TObjectList<TGrupo>;
    function GetBuscarMateriais: TObjectList<TMaterial>;
    function GetBuscarReferencias: TObjectList<TReferencia>;
    function GetBuscarCores: TObjectList<TCor>;
    function GetBuscarTamanhos: TObjectList<TTamanho>;
    function GetBuscarFiliais: TObjectList<TFilial>;
    function GetBuscarTabelaPrecos: TObjectList<TTabelaPreco>;
    function GetBuscarPrecos: TObjectList<TPreco>;
    function GetBuscarVariacoes: TObjectList<TVariacao>;
    function GetBuscarSaldos: TObjectList<TSaldo>;

    procedure Apagar(ATabelaExcluir: TMapaEntidade);
    procedure Limpar<T: TBaseModel>(AListObj: TObjectList<T>; ATabela, ADescricao: string);
  public
    constructor Create(AConexao: IConexao; var AConfigurador: ISQLiteService);
    property BuscarCategorias: TObjectList<TCategoria> read GetBuscarCategorias;
    property BuscarDepartamentos: TObjectList<TDepartamento> read GetBuscarDepartamentos;
    property BuscarColecoes: TObjectList<TColecao> read GetBuscarColecoes;
    property BuscarGrupos: TObjectList<TGrupo> read GetBuscarGrupos;
    property BuscarMateriais: TObjectList<TMaterial> read GetBuscarMateriais;
    property BuscarReferencias: TObjectList<TReferencia> read GetBuscarReferencias;
    property BuscarCores: TObjectList<TCor> read GetBuscarCores;
    property BuscarTamanhos: TObjectList<TTamanho> read GetBuscarTamanhos;
    property BuscarFiliais: TObjectList<TFilial> read GetBuscarFiliais;
    property BuscarTabelaPrecos: TObjectList<TTabelaPreco> read GetBuscarTabelaPrecos;
    property BuscarPrecos: TObjectList<TPreco> read GetBuscarPrecos;
    property BuscarVariacoes: TObjectList<TVariacao> read GetBuscarVariacoes;
    property BuscarSaldos: TObjectList<TSaldo> read GetBuscarSaldos;

    property BuscarMovimentos: TObjectList<TMovimento> read GetBuscarMovimentos;

    procedure LimparMovimentos;
    procedure LerDadosCadastrais;
    procedure LerDadosProdutos;
    procedure DestruirObjetos;
  end;

implementation

uses
  MigraBling.Model.LogObserver;

{ TPDVNETRegistrosMovimentados }

constructor TPDVNETRegistrosMovimentados.Create(AConexao: IConexao;
  var AConfigurador: ISQLiteService);
begin
  FConexao := AConexao;
  FCategorias := TDAOCategoriasPDVNET.Create(FConexao);
  FDepartamentos := TDAODepartamentosPDVNET.Create(FConexao);
  FMovimentos := TDAOMovimentosPDVNET.Create(FConexao);
  FGrupos := TDAOGruposPDVNET.Create(FConexao);
  FMateriais := TDAOMateriaisPDVNET.Create(FConexao);
  FColecoes := TDAOColecoesPDVNET.Create(FConexao);
  FCores := TDAOCoresPDVNET.Create(FConexao);
  FTamanhos := TDAOTamanhosPDVNET.Create(FConexao);
  FFiliais := TDAOFiliaisPDVNET.Create(FConexao);
  FTabelaPrecos := TDAOTabelaPrecosPDVNET.Create(FConexao);
  FPrecos := TDAOPrecosPDVNET.Create(FConexao, AConfigurador);
  FVariacoes := TDAOVariacoesPDVNET.Create(FConexao);
  FReferencias := TDAOReferenciasPDVNET.Create(FConexao);
  FSaldos := TDAOSaldosPDVNET.Create(FConexao, AConfigurador);
end;

procedure TPDVNETRegistrosMovimentados.DestruirObjetos;
begin
  FreeAndNil(FBuscarMovimentos);
  FreeAndNil(FBuscarCategorias);
  FreeAndNil(FBuscarDepartamentos);
  FreeAndNil(FBuscarColecoes);
  FreeAndNil(FBuscarGrupos);
  FreeAndNil(FBuscarMateriais);
  FreeAndNil(FBuscarCores);
  FreeAndNil(FBuscarTamanhos);
  FreeAndNil(FBuscarFiliais);
  FreeAndNil(FBuscarTabelaPrecos);
  FreeAndNil(FBuscarPrecos);
  FreeAndNil(FBuscarReferencias);
  FreeAndNil(FBuscarVariacoes);
  FreeAndNil(FBuscarSaldos);
end;

function TPDVNETRegistrosMovimentados.GetBuscarCategorias: TObjectList<TCategoria>;
begin
  Result := FBuscarCategorias;
end;

function TPDVNETRegistrosMovimentados.GetBuscarColecoes: TObjectList<TColecao>;
begin
  Result := FBuscarColecoes;
end;

function TPDVNETRegistrosMovimentados.GetBuscarCores: TObjectList<TCor>;
begin
  Result := FBuscarCores;
end;

function TPDVNETRegistrosMovimentados.GetBuscarDepartamentos: TObjectList<TDepartamento>;
begin
  Result := FBuscarDepartamentos;
end;

function TPDVNETRegistrosMovimentados.GetBuscarFiliais: TObjectList<TFilial>;
begin
  Result := FBuscarFiliais;
end;

function TPDVNETRegistrosMovimentados.GetBuscarGrupos: TObjectList<TGrupo>;
begin
  Result := FBuscarGrupos;
end;

function TPDVNETRegistrosMovimentados.GetBuscarMateriais: TObjectList<TMaterial>;
begin
  Result := FBuscarMateriais;
end;

function TPDVNETRegistrosMovimentados.GetBuscarMovimentos: TObjectList<TMovimento>;
begin
  Result := FBuscarMovimentos;
end;

function TPDVNETRegistrosMovimentados.GetBuscarPrecos: TObjectList<TPreco>;
begin
  Result := FBuscarPrecos;
end;

function TPDVNETRegistrosMovimentados.GetBuscarReferencias: TObjectList<TReferencia>;
begin
  Result := FBuscarReferencias;
end;

function TPDVNETRegistrosMovimentados.GetBuscarSaldos: TObjectList<TSaldo>;
begin
  Result := FBuscarSaldos;
end;

function TPDVNETRegistrosMovimentados.GetBuscarTabelaPrecos: TObjectList<TTabelaPreco>;
begin
  Result := FBuscarTabelaPrecos;
end;

function TPDVNETRegistrosMovimentados.GetBuscarTamanhos: TObjectList<TTamanho>;
begin
  Result := FBuscarTamanhos;
end;

function TPDVNETRegistrosMovimentados.GetBuscarVariacoes: TObjectList<TVariacao>;
begin
  Result := FBuscarVariacoes;
end;

procedure TPDVNETRegistrosMovimentados.LerDadosCadastrais;
var
  Tasks: TArray<ITask>;
begin
  SetLength(Tasks, 13);

  Tasks[0] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarCategorias := FCategorias.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo categorias (' + FBuscarCategorias.Count.ToString +
        ') no PDVNET');
    end);
  Tasks[1] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarDepartamentos := FDepartamentos.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo departamentos (' +
        FBuscarDepartamentos.Count.ToString + ') no PDVNET');
    end);
  Tasks[2] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarColecoes := FColecoes.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo coleções (' + FBuscarColecoes.Count.ToString +
        ') no PDVNET');
    end);
  Tasks[3] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarGrupos := FGrupos.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo grupos (' + FBuscarGrupos.Count.ToString +
        ') no PDVNET');
    end);
  Tasks[4] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarMateriais := FMateriais.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo materiais (' + FBuscarMateriais.Count.ToString +
        ') no PDVNET');
    end);
  Tasks[5] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarCores := FCores.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo cores (' + FBuscarCores.Count.ToString +
        ') no PDVNET');
    end);
  Tasks[6] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarTamanhos := FTamanhos.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo tamanhos (' + FBuscarTamanhos.Count.ToString +
        ') no PDVNET');
    end);
  Tasks[7] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarFiliais := FFiliais.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo filiais (' + FBuscarFiliais.Count.ToString +
        ') no PDVNET');
    end);
  Tasks[8] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarTabelaPrecos := FTabelaPrecos.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo tabelas (' + FBuscarTabelaPrecos.Count.ToString +
        ') no PDVNET');
    end);
  Tasks[9] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarPrecos := FPrecos.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo preços (' + FBuscarPrecos.Count.ToString +
        ') no PDVNET');
    end);
  Tasks[10] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarVariacoes := FVariacoes.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo variações (' + FBuscarVariacoes.Count.ToString +
        ') no PDVNET');
    end);
  Tasks[11] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarSaldos := FSaldos.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo saldos (' + FBuscarSaldos.Count.ToString +
        ') no PDVNET');
    end);
  Tasks[12] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarMovimentos := FMovimentos.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo movimentos (' + FBuscarMovimentos.Count.ToString +
        ') no PDVNET');
    end);

  TTask.WaitForAll(Tasks);
end;

procedure TPDVNETRegistrosMovimentados.LerDadosProdutos;
var
  Tasks: TArray<ITask>;
begin
  SetLength(Tasks, 1);

  Tasks[0] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarReferencias := FReferencias.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo referências (' + FBuscarReferencias.Count.ToString +
        ') no PDVNET');
    end);

  TTask.WaitForAll(Tasks);
end;

procedure TPDVNETRegistrosMovimentados.Limpar<T>(AListObj: TObjectList<T>;
ATabela, ADescricao: string);
var
  LMapa: TMapaEntidade;
begin
  if AListObj.Count > 0 then
  begin
    LMapa := TMapaEntidade.Create;
    LMapa.Tabela := ATabela;
    LMapa.Descricao := ADescricao;

    TLogSubject.GetInstance.NotifyAll('Limpando movimentos de ' + ADescricao.ToLower +
      ' no PDVNET');

    Apagar(LMapa);
  end;
end;

procedure TPDVNETRegistrosMovimentados.LimparMovimentos;
var
  Tasks: TArray<ITask>;
begin
  SetLength(Tasks, 13);
  Tasks[0] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TCategoria>(FBuscarCategorias, 'MODELOS', 'Categorias');
    end);
  Tasks[1] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TDepartamento>(FBuscarDepartamentos, 'GRUPOMATERIAIS', 'Departamentos');
    end);
  Tasks[2] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TColecao>(FBuscarColecoes, 'COLECOES', 'Coleções');
    end);
  Tasks[3] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TGrupo>(FBuscarGrupos, 'MATERIAPRIMA', 'Grupos');
    end);
  Tasks[4] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TMaterial>(FBuscarMateriais, 'LINHA', 'Materiais');
    end);
  Tasks[5] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TCor>(FBuscarCores, 'CORES', 'Cores');
    end);
  Tasks[6] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TTamanho>(FBuscarTamanhos, 'TAMANHOS', 'Tamanhos');
    end);
  Tasks[7] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TFilial>(FBuscarFiliais, 'FILIAL', 'Filiais');
    end);
  Tasks[8] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TTabelaPreco>(FBuscarTabelaPrecos, 'TABELAPRECO', 'Tabela de Preços');
    end);
  Tasks[9] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TPreco>(FBuscarPrecos, 'PRECO', 'Preços');
    end);
  Tasks[10] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TReferencia>(FBuscarReferencias, 'REFERENCIAS', 'Referências');
    end);
  Tasks[11] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TVariacao>(FBuscarVariacoes, 'MATERIAIS', 'Variações');
    end);
  Tasks[12] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TSaldo>(FBuscarSaldos, 'SALDOS', 'Saldos');
    end);

  TTask.WaitForAll(Tasks);
end;

procedure TPDVNETRegistrosMovimentados.Apagar(ATabelaExcluir: TMapaEntidade);
var
  LQuery: IQuery;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
  try
    try
      LQuery.Close;
      LQuery.SQL.Text := 'DELETE FROM MOVIMENTOS_MIGRAR_BLING WHERE TABELA = :PTABELA ';
      LQuery.ParamByName('PTABELA').AsString := ATabelaExcluir.Tabela;
      LQuery.ExecSQL;
    except
      on E: Exception do
        TLogSubject.GetInstance.NotifyAll('Não foi possível excluir os dados em ' +
          ATabelaExcluir.Descricao + ' - PDVNET' + #13#10 + E.Message);
    end;
  finally
    ATabelaExcluir.Free;
  end;
end;

end.
