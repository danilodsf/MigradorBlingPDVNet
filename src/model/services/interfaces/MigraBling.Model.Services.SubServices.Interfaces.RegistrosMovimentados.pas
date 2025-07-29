unit MigraBling.Model.Services.SubServices.Interfaces.RegistrosMovimentados;

interface

uses
  System.Generics.Collections,
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
  MigraBling.Model.Saldos;

type
  IRegistrosMovimentados = interface
    ['{5209649E-B05C-4A5B-A875-E91A474226C3}']
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

    procedure LerDadosCadastrais;
    procedure LerDadosProdutos;
    procedure LimparMovimentos;
    procedure DestruirObjetos;
  end;

implementation

end.
