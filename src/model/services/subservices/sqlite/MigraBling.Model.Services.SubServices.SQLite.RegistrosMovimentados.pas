unit MigraBling.Model.Services.SubServices.SQLite.RegistrosMovimentados;

interface

uses
  System.Classes,
  System.Threading,
  System.SysUtils,
  System.Generics.Collections,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.QueryFactory,
  MigraBling.Model.LogObserver,
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
  MigraBling.Model.Services.SubServices.Interfaces.RegistrosMovimentados,
  MigraBling.Model.Services.SubServices.SQLite.DAOMovimentos,
  MigraBling.Model.Services.SubServices.SQLite.DAOCategorias,
  MigraBling.Model.Services.SubServices.SQLite.DAODepartamentos,
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
  MigraBling.Model.AppControl, MigraBling.Model.Configuracao;

type
  TSQLiteRegistrosMovimentados = class(TInterfacedObject, IRegistrosMovimentados)
  private
    FConexao: IConexao;
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

    procedure Apagar(AListIDs: TDictionary<string, string>);
    procedure Limpar<T: TBaseModel>(AListObj: TObjectList<T>; ATabela: string);
  public
    constructor Create(AConexao: IConexao; AConfigurador: IDAOConfiguracoesSQLite<TConfiguracao>);
    property BuscarMovimentos: TObjectList<TMovimento> read GetBuscarMovimentos;
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

    procedure LimparMovimentos;
    procedure LerDadosCadastrais;
    procedure LerDadosProdutos;
    procedure DestruirObjetos;
  end;

implementation

{ TSQLiteRegistrosMovimentados }

constructor TSQLiteRegistrosMovimentados.Create(AConexao: IConexao;
  AConfigurador: IDAOConfiguracoesSQLite<TConfiguracao>);
begin
  FConexao := AConexao;
  FCategorias := TDAOCategoriasSQLite.Create(FConexao);
  FDepartamentos := TDAODepartamentosSQLite.Create(FConexao);
  FColecoes := TDAOColecoesSQLite.Create(FConexao);
  FGrupos := TDAOGruposSQLite.Create(FConexao);
  FMateriais := TDAOMateriaisSQLite.Create(FConexao);
  FReferencias := TDAOReferenciasSQLite.Create(FConexao, AConfigurador);
  FCores := TDAOCoresSQLite.Create(FConexao);
  FTamanhos := TDAOTamanhosSQLite.Create(FConexao);
  FFiliais := TDAOFiliaisSQLite.Create(FConexao);
  FTabelaPrecos := TDAOTabelaPrecosSQLite.Create(FConexao);
  FPrecos := TDAOPrecosSQLite.Create(FConexao);
  FVariacoes := TDAOVariacoesSQLite.Create(FConexao, AConfigurador);
  FSaldos := TDAOSaldosSQLite.Create(FConexao, AConfigurador);
  FMovimentos := nil;
end;

function TSQLiteRegistrosMovimentados.GetBuscarCategorias: TObjectList<TCategoria>;
begin
  Result := FBuscarCategorias;
end;

function TSQLiteRegistrosMovimentados.GetBuscarColecoes: TObjectList<TColecao>;
begin
  Result := FBuscarColecoes;
end;

function TSQLiteRegistrosMovimentados.GetBuscarCores: TObjectList<TCor>;
begin
  Result := FBuscarCores;
end;

function TSQLiteRegistrosMovimentados.GetBuscarDepartamentos: TObjectList<TDepartamento>;
begin
  Result := FBuscarDepartamentos;
end;

function TSQLiteRegistrosMovimentados.GetBuscarFiliais: TObjectList<TFilial>;
begin
  Result := FBuscarFiliais;
end;

function TSQLiteRegistrosMovimentados.GetBuscarGrupos: TObjectList<TGrupo>;
begin
  Result := FBuscarGrupos;
end;

function TSQLiteRegistrosMovimentados.GetBuscarMateriais: TObjectList<TMaterial>;
begin
  Result := FBuscarMateriais;
end;

function TSQLiteRegistrosMovimentados.GetBuscarMovimentos: TObjectList<TMovimento>;
begin
  Result := FBuscarMovimentos;
end;

function TSQLiteRegistrosMovimentados.GetBuscarPrecos: TObjectList<TPreco>;
begin
  Result := FBuscarPrecos;
end;

function TSQLiteRegistrosMovimentados.GetBuscarReferencias: TObjectList<TReferencia>;
begin
  Result := FBuscarReferencias;
end;

function TSQLiteRegistrosMovimentados.GetBuscarSaldos: TObjectList<TSaldo>;
begin
  Result := FBuscarSaldos;
end;

function TSQLiteRegistrosMovimentados.GetBuscarTabelaPrecos: TObjectList<TTabelaPreco>;
begin
  Result := FBuscarTabelaPrecos;
end;

function TSQLiteRegistrosMovimentados.GetBuscarTamanhos: TObjectList<TTamanho>;
begin
  Result := FBuscarTamanhos;
end;

function TSQLiteRegistrosMovimentados.GetBuscarVariacoes: TObjectList<TVariacao>;
begin
  Result := FBuscarVariacoes;
end;

procedure TSQLiteRegistrosMovimentados.LerDadosCadastrais;
var
  Tasks: TArray<ITask>;
begin
  SetLength(Tasks, 11);

  Tasks[0] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarCategorias := FCategorias.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo categorias (' + FBuscarCategorias.Count.ToString +
        ') no SQLite');
    end);
  Tasks[1] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarDepartamentos := FDepartamentos.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo departamentos (' +
        FBuscarDepartamentos.Count.ToString + ') no SQLite');
    end);
  Tasks[2] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarColecoes := FColecoes.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo coleções (' + FBuscarColecoes.Count.ToString +
        ') no SQLite');
    end);
  Tasks[3] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarGrupos := FGrupos.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo grupos (' + FBuscarGrupos.Count.ToString +
        ') no SQLite');
    end);
  Tasks[4] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarMateriais := FMateriais.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo materiais (' + FBuscarMateriais.Count.ToString +
        ') no SQLite');
    end);
  Tasks[5] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarCores := FCores.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo cores (' + FBuscarCores.Count.ToString +
        ') no SQLite');

    end);
  Tasks[6] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarTamanhos := FTamanhos.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo tamanhos (' + FBuscarTamanhos.Count.ToString +
        ') no SQLite');
    end);
  Tasks[7] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarFiliais := FFiliais.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo filiais (' + FBuscarFiliais.Count.ToString +
        ') no SQLite');
    end);
  Tasks[8] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarTabelaPrecos := FTabelaPrecos.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo tabelas de preço (' +
        FBuscarTabelaPrecos.Count.ToString + ') no SQLite');
    end);
  Tasks[9] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarPrecos := FPrecos.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo preços (' + FBuscarPrecos.Count.ToString +
        ') no SQLite');
    end);
  Tasks[10] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarVariacoes := FVariacoes.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo variações (' + FBuscarVariacoes.Count.ToString +
        ') no SQLite');
    end);

  TTask.WaitForAll(Tasks);
end;

procedure TSQLiteRegistrosMovimentados.LerDadosProdutos;
var
  Tasks: TArray<ITask>;
begin
  SetLength(Tasks, 2);

  Tasks[0] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarReferencias := FReferencias.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo referências (' + FBuscarReferencias.Count.ToString +
        ') no SQLite');
    end);
  Tasks[1] := TAppControl.SafeTask(
    procedure
    begin
      FBuscarSaldos := FSaldos.Ler;
      TLogSubject.GetInstance.NotifyAll('Lendo saldos (' + FBuscarSaldos.Count.ToString +
        ') no SQLite');
    end);

  TTask.WaitForAll(Tasks);
end;

procedure TSQLiteRegistrosMovimentados.LimparMovimentos;
var
  Tasks: TArray<ITask>;
begin
  SetLength(Tasks, 10);
  Tasks[0] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TCategoria>(FBuscarCategorias, 'Categorias');
    end);
  Tasks[1] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TDepartamento>(FBuscarDepartamentos, 'Departamentos');
    end);
  Tasks[2] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TColecao>(FBuscarColecoes, 'Coleções');
    end);
  Tasks[3] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TGrupo>(FBuscarGrupos, 'Grupos');
    end);
  Tasks[4] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TMaterial>(FBuscarMateriais, 'Materiais');
    end);
  Tasks[5] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TReferencia>(FBuscarReferencias, 'Referências');
    end);
  Tasks[6] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TFilial>(FBuscarFiliais, 'Filiais');
    end);
  Tasks[7] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TSaldo>(FBuscarSaldos, 'Saldos');
    end);
  Tasks[8] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TCor>(FBuscarCores, 'Cores');
    end);
  Tasks[9] := TAppControl.SafeTask(
    procedure
    begin
      Limpar<TTamanho>(FBuscarTamanhos, 'Tamanhos');
    end);

  TTask.WaitForAll(Tasks);
end;

procedure TSQLiteRegistrosMovimentados.DestruirObjetos;
begin
  if Assigned(FBuscarReferencias) then
  begin
    FreeAndNil(FBuscarReferencias);
    FreeAndNil(FBuscarSaldos);
  end;

  if Assigned(FBuscarCategorias) then
  begin
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
    FreeAndNil(FBuscarVariacoes);
  end;
end;

procedure TSQLiteRegistrosMovimentados.Limpar<T>(AListObj: TObjectList<T>; ATabela: string);
var
  podeExcluir: Boolean;
  i: integer;
  LListaIDsExcluir: TDictionary<string, string>;
begin
  if TAppControl.AppFinalizando then
    Exit;

  if not Assigned(AListObj) then
    Exit;

  LListaIDsExcluir := TDictionary<string, string>.Create;
  try
    if AListObj.Count > 0 then
    begin
      podeExcluir := false;
      for i := 0 to Pred(AListObj.Count) do
      begin
        if ((AListObj[i].ID_Bling <> '') or (AListObj[i].ID_Bling = 'EXCLUIR')) then
        begin
          LListaIDsExcluir.Add(AListObj[i].ID_Movimento, ATabela);
          podeExcluir := true;
        end;
      end;
      if podeExcluir then
        TLogSubject.GetInstance.NotifyAll('Limpando movimentos de ' + ATabela.ToLower +
          ' no SQLite');

      Apagar(LListaIDsExcluir);
    end;
  finally
    LListaIDsExcluir.Free;
  end;
end;

procedure TSQLiteRegistrosMovimentados.Apagar(AListIDs: TDictionary<string, string>);
var
  LQuery: IQuery;
  ID: TPair<string, string>;
  i: integer;
  LTabela: string;
begin
  if AListIDs.Count = 0 then
    Exit;

  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
  try
    LQuery.Close;
    LQuery.SQL.Text := 'DELETE FROM MOVIMENTOS_MIGRAR_BLING WHERE ID = :PID ';
    LQuery.ArraySize := AListIDs.Count;

    i := 0;
    for ID in AListIDs do
    begin
      LTabela := ID.Value;
      LQuery.ParamByName('PID').AsStrings(i, ID.Key);
      Inc(i);
    end;

    if AListIDs.Count > 0 then
      LQuery.Execute(AListIDs.Count);
  except
    on E: Exception do
      TLogSubject.GetInstance.NotifyAll('Não foi possível excluir os dados em ' + LTabela +
        ' - SQLite' + #13#10 + E.Message);
  end;
end;

end.
