unit MigraBling.Controller.Interfaces.Sincronizador;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  MigraBling.Model.Filiais,
  MigraBling.Model.Referencias;

type
  ISincronizadorController = interface
    ['{1113D1E1-9215-4DB2-8DD1-D7E166187CF5}']

    function GetAtivarSincronizador: Boolean;
    function TestarConexaoSQLServer: Boolean;
    procedure SetProcStatusServidor(AValue: TProc<Boolean>);
    procedure SetProcStatusSincronizador(AValue: TProc<Boolean>);
    procedure SetProcGravaLog(AValue: TProc<String>);
    procedure SetProcAtualizaTimer(AValue: TProc<String>);
    procedure SetAtivarSincronizador(AValue: Boolean);
    procedure GravarConfiguracoes(ASQLServerIP, ASQLServerBD, ASQLServerUser, ASQLServerPassword,
      ABlingClientID, ABlingClientSecret: string; ATempoSincronizacao, AQtdEstoqueSubir,
      ATabelaPadrao: integer; APersistir: Boolean = true);
    procedure LerConfiguracoes(out ASQLServerIP, ASQLServerBD, ASQLServerUser, ASQLServerPassword,
      ABlingClientID, ABlingClientSecret: string; out ATempoSincronizacao, AQtdEstoqueSubir,
      ATabelaPadrao: integer);
    procedure SincronizarAgora;
    procedure CriarEstruturaSincronizacao;
    procedure Inicializar;
    procedure ApagarTodosProdutos;
    procedure GravarConfigFiliaisEstoque(AValue: TDictionary<integer, Boolean>);
    function BuscarFiliais: TDictionary<integer, TFilial>;
    function BuscarTabelasDePreco: TOrderedDictionary<integer, string>;
    function BuscarReferencias: TObjectList<TReferencia>;
    procedure SincronizarReferencias(AReferencias: TList<string>);
    property ProcStatusServidor: TProc<Boolean> write SetProcStatusServidor;
    property ProcStatusSincronizador: TProc<Boolean> write SetProcStatusSincronizador;
    property ProcGravaLog: TProc<String> write SetProcGravaLog;
    property ProcAtualizaTimer: TProc<String> write SetProcAtualizaTimer;
    property AtivarSincronizador: Boolean read GetAtivarSincronizador write SetAtivarSincronizador;

  end;

implementation

end.
