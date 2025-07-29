unit MigraBling.Model.Services.SubServices.Interfaces.SQLite;

interface

uses
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.Services.SubServices.SQLite.DAOConfiguracoes,
  MigraBling.Model.Configuracao,
  MigraBling.Model.Services.SubServices.Interfaces.RegistrosMovimentados,
  MigraBling.Model.Categorias,
  MigraBling.Model.MovimentoEstoque,
  System.Generics.Collections;

type
  ISQLiteService = interface
    ['{610F0D80-3DE5-4B50-A6AA-5D7E36425229}']
    function GetConfiguracoes: IDAOConfiguracoesSQLite<TConfiguracao>;
    function GetConfiguracao: TConfiguracao;
    function GetTempoSincronizacao: integer;
    function GetAtivado: Boolean;
    function GetBuscarMovimentosDeCadastros: IRegistrosMovimentados;
    function GetBuscarMovimentosDeProdutos: IRegistrosMovimentados;
    function BuscarFiliais: TDictionary<integer, boolean>;
    procedure SetConfiguracoes(AValue: IDAOConfiguracoesSQLite<TConfiguracao>);
    procedure SetConfiguracao(AValue: TConfiguracao);
    procedure SetAtivado(AValue: Boolean);
    procedure GravarMovimentos(AValue: IRegistrosMovimentados);
    procedure GravarIDsBling(AValue: IRegistrosMovimentados);
    procedure LimparMovimentos(AValue: IRegistrosMovimentados);
    procedure GravarConfigFiliaisEstoque(AValue: TDictionary<integer, Boolean>);
    procedure GravarVendasBling(AValue: TObjectList<TMovimentoEstoque>);
    procedure DestruirObjetos;
    property BuscarMovimentosDeCadastros: IRegistrosMovimentados read GetBuscarMovimentosDeCadastros;
    property BuscarMovimentosDeProdutos: IRegistrosMovimentados read GetBuscarMovimentosDeProdutos;

    property Configuracoes: IDAOConfiguracoesSQLite<TConfiguracao> read GetConfiguracoes write SetConfiguracoes;
    property Configuracao: TConfiguracao read GetConfiguracao write SetConfiguracao;

    property TempoSincronizacao: integer read GetTempoSincronizacao;
    property Ativado: Boolean read GetAtivado write SetAtivado;
  end;

implementation

end.
