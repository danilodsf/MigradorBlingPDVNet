unit MigraBling.Controller.Sincronizador;

interface

uses
  System.SysUtils,
  Vcl.ExtCtrls,
  System.Classes,
  System.Threading,
  System.Generics.Collections,
  MigraBling.Model.Configuracao,
  MigraBling.Model.Services.Interfaces.Sincronizador,
  MigraBling.Model.Services.Sincronizador,
  MigraBling.Controller.Interfaces.Sincronizador,
  MigraBling.Model.Interfaces.LogObserver,
  MigraBling.Model.Services.SubServices.Interfaces.RegistrosMovimentados,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Filiais,
  MigraBling.Model.Interfaces.LogSubject,
  MigraBling.Model.Services.Backup,
  MigraBling.Model.MovimentoEstoque,
  MigraBling.Model.Referencias,
  MigraBling.Model.Log,
  MigraBling.Model.AppControl;

type
  TSincronizadorController = class(TInterfacedObject, ISincronizadorController, ILogObserver)
  private
    FSincronizador: ISincronizador;
    FProcStatusServidor: TProc<Boolean>;
    FProcStatusSincronizador: TProc<Boolean>;
    FProcGravaLog: TProc<String>;
    FProcAtualizaTimer: TProc<String>;
    FTimer: TTimer;
    FSegundosRestantes: integer;
    FContagem: string;
    FInicializou: Boolean;
    FThreadBackup: TBackupThread;
    procedure SetProcStatusServidor(AValue: TProc<Boolean>);
    procedure SetProcStatusSincronizador(AValue: TProc<Boolean>);
    procedure SetProcGravaLog(AValue: TProc<String>);
    procedure SetProcAtualizaTimer(AValue: TProc<String>);
    procedure AtualizarContador;
    function GetContagem: string;
    procedure ContagemOnTimer(Sender: TObject);
    function GetAtivarSincronizador: Boolean;
    procedure SetAtivarSincronizador(AValue: Boolean);
    procedure AtivacaoSincronizacao;
    procedure Sincronizar;
    procedure BuscarMovimentosDoPDVNetEGravarNoSQLite;
    procedure BuscarCadastrosDoSQLiteEGravarNoBling;
    procedure BuscarProdutosDoSQLiteEGravarNoBling;
    procedure IniciarSincronizacao;
    procedure ConcluirSincronizacao;
  public
    property ProcStatusServidor: TProc<Boolean> write SetProcStatusServidor;
    property ProcStatusSincronizador: TProc<Boolean> write SetProcStatusSincronizador;
    property ProcGravaLog: TProc<String> write SetProcGravaLog;
    property ProcAtualizaTimer: TProc<String> write SetProcAtualizaTimer;
    property Contagem: string read GetContagem;
    property AtivarSincronizador: Boolean read GetAtivarSincronizador write SetAtivarSincronizador;
    procedure GravarConfiguracoes(ASQLServerIP, ASQLServerBD, ASQLServerUser, ASQLServerPassword,
      ABlingClientID, ABlingClientSecret: string; ATempoSincronizacao, AQtdEstoqueSubtrair,
      ATabelaPadrao: integer; APersistir: Boolean = true);
    procedure LerConfiguracoes(out ASQLServerIP, ASQLServerBD, ASQLServerUser, ASQLServerPassword,
      ABlingClientID, ABlingClientSecret: string; out ATempoSincronizacao, AQtdEstoqueSubtrair,
      ATabelaPadrao: integer);
    procedure SincronizarAgora;
    constructor Create;
    destructor Destroy; override;
    procedure CriarEstruturaSincronizacao;
    procedure GravarConfigFiliaisEstoque(AValue: TDictionary<integer, Boolean>);
    procedure Inicializar;
    procedure ApagarTodosProdutos;
    function TestarConexaoSQLServer: Boolean;
    function BuscarFiliais: TDictionary<integer, TFilial>;
    function BuscarTabelasDePreco: TOrderedDictionary<integer, string>;
    function BuscarReferencias: TObjectList<TReferencia>;
    procedure SincronizarReferencias(AReferencias: TList<string>);
    procedure Notify(const AValue: string);
  end;

implementation

{ TSincronizadorController }

constructor TSincronizadorController.Create;
begin
  TLogSubject.GetInstance.RegisterObserver(Self);
  FInicializou := false;
  FSincronizador := TSincronizador.Create;
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := false;
  FTimer.Interval := 1000;
  FTimer.OnTimer := ContagemOnTimer;
  FThreadBackup := TBackupThread.Create(FSincronizador.SQLite.Configuracoes);
end;

procedure TSincronizadorController.CriarEstruturaSincronizacao;
begin
  Notify('Criando estrutura de sincronizações no PDVNET');
  FSincronizador.PDVNET.CriarEstruturaSincronizacao;
  Notify('Estrutura de sincronização criada com sucesso');
end;

destructor TSincronizadorController.Destroy;
begin
  FTimer.Free;
  FThreadBackup.Terminate;
  FThreadBackup.WaitFor;
  FThreadBackup.Free;
  inherited;
end;

function TSincronizadorController.GetAtivarSincronizador: Boolean;
begin
  Result := FSincronizador.SQLite.Ativado;
end;

procedure TSincronizadorController.SetAtivarSincronizador(AValue: Boolean);
begin
  if FInicializou then
  begin
    FSincronizador.SQLite.Ativado := AValue;
    AtivacaoSincronizacao;
  end;
end;

function TSincronizadorController.GetContagem: string;
begin
  Result := FContagem;
end;

procedure TSincronizadorController.SetProcAtualizaTimer(AValue: TProc<String>);
begin
  FProcAtualizaTimer := AValue;
end;

procedure TSincronizadorController.SetProcGravaLog(AValue: TProc<String>);
begin
  FProcGravaLog := AValue;
end;

procedure TSincronizadorController.SetProcStatusServidor(AValue: TProc<Boolean>);
begin
  FProcStatusServidor := AValue;
end;

procedure TSincronizadorController.SetProcStatusSincronizador(AValue: TProc<Boolean>);
begin
  FProcStatusSincronizador := AValue;
end;

procedure TSincronizadorController.SincronizarAgora;
begin
  Notify('Sincronização manual');
  Sincronizar;
end;

procedure TSincronizadorController.SincronizarReferencias(AReferencias: TList<string>);
begin
  if not FSincronizador.PDVNET.TestarConexaoSQLServer then
    Exit;

  FSincronizador.PDVNET.SincronizarReferencias(AReferencias);
end;

function TSincronizadorController.TestarConexaoSQLServer: Boolean;
begin
  Result := FSincronizador.PDVNET.TestarConexaoSQLServer;
end;

procedure TSincronizadorController.Inicializar;
begin
  if not FSincronizador.PDVNET.BancoConfigurado then
  begin
    FProcStatusServidor(false);
    Exit;
  end;
  AtivacaoSincronizacao;
  FInicializou := true;
end;

procedure TSincronizadorController.ApagarTodosProdutos;
begin
  FTimer.Enabled := false;
  try
    FSincronizador.Bling.LimparProdutos;
  finally
    // FTimer.Enabled := true;
  end;
end;

procedure TSincronizadorController.AtivacaoSincronizacao;
begin
  if FSincronizador.SQLite.Ativado then
  begin
    FSegundosRestantes := FSincronizador.SQLite.TempoSincronizacao * 60;
    FProcStatusServidor(true);
    Notify('Aguardando contagem');
    FTimer.Enabled := true;
  end
  else
  begin
    FProcStatusServidor(false);
    Notify('Sincronizador desligado');
    FTimer.Enabled := false;
  end;
end;

procedure TSincronizadorController.AtualizarContador;
var
  Hr, Min, Sec: integer;
begin
  Hr := FSegundosRestantes div 3600;
  Min := FSegundosRestantes div 60;
  Sec := FSegundosRestantes mod 60;

  if Hr > 0 then
    FProcAtualizaTimer(Format('%d:%.2d:%.2d', [Hr, Min, Sec]))
  else if Min > 0 then
    FProcAtualizaTimer(Format('%d:%.2d', [Min, Sec]))
  else
    FProcAtualizaTimer(Format('%.2d', [Sec]));
end;

procedure TSincronizadorController.ContagemOnTimer(Sender: TObject);
begin
  Dec(FSegundosRestantes);
  AtualizarContador;

  if FSegundosRestantes <= 0 then
    Sincronizar
  else
    FProcStatusSincronizador(false);
end;

procedure TSincronizadorController.Sincronizar;
begin
  TAppControl.SafeTask(
    procedure
    begin
      IniciarSincronizacao;
      BuscarMovimentosDoPDVNetEGravarNoSQLite;
      BuscarCadastrosDoSQLiteEGravarNoBling;
      BuscarProdutosDoSQLiteEGravarNoBling;
      ConcluirSincronizacao;
    end);
end;

procedure TSincronizadorController.GravarConfiguracoes(ASQLServerIP, ASQLServerBD, ASQLServerUser,
  ASQLServerPassword, ABlingClientID, ABlingClientSecret: string;
ATempoSincronizacao, AQtdEstoqueSubtrair, ATabelaPadrao: integer; APersistir: Boolean);
begin
  FSincronizador.SQLite.Configuracao.PDVNET_Server := ASQLServerIP;
  FSincronizador.SQLite.Configuracao.PDVNET_Database := ASQLServerBD;
  FSincronizador.SQLite.Configuracao.PDVNET_UserName := ASQLServerUser;
  FSincronizador.SQLite.Configuracao.PDVNET_Password := ASQLServerPassword;
  FSincronizador.SQLite.Configuracao.ClientID := ABlingClientID;
  FSincronizador.SQLite.Configuracao.ClientSecret := ABlingClientSecret;
  FSincronizador.SQLite.Configuracao.TempoSincronizacao := ATempoSincronizacao;
  FSincronizador.SQLite.Configuracao.QtdEstoqueSubtrair := AQtdEstoqueSubtrair;
  FSincronizador.SQLite.Configuracao.TabelaPrecoPadrao := ATabelaPadrao;
  if APersistir then
    FSincronizador.SQLite.Configuracoes.Atualizar(FSincronizador.SQLite.Configuracao);
end;

procedure TSincronizadorController.LerConfiguracoes(out ASQLServerIP, ASQLServerBD, ASQLServerUser,
  ASQLServerPassword, ABlingClientID, ABlingClientSecret: string;
out ATempoSincronizacao, AQtdEstoqueSubtrair, ATabelaPadrao: integer);
begin
  ASQLServerIP := FSincronizador.SQLite.Configuracao.PDVNET_Server;
  ASQLServerBD := FSincronizador.SQLite.Configuracao.PDVNET_Database;
  ASQLServerUser := FSincronizador.SQLite.Configuracao.PDVNET_UserName;
  ASQLServerPassword := FSincronizador.SQLite.Configuracao.PDVNET_Password;
  ABlingClientID := FSincronizador.SQLite.Configuracao.ClientID;
  ABlingClientSecret := FSincronizador.SQLite.Configuracao.ClientSecret;
  ATempoSincronizacao := FSincronizador.SQLite.Configuracao.TempoSincronizacao;
  AQtdEstoqueSubtrair := FSincronizador.SQLite.Configuracao.QtdEstoqueSubtrair;
  ATabelaPadrao := FSincronizador.SQLite.Configuracao.TabelaPrecoPadrao;
end;

procedure TSincronizadorController.Notify(const AValue: string);
begin
  FProcGravaLog(AValue);
  TLog.GetInstance.GravaInformacoes(AValue);
end;

procedure TSincronizadorController.ConcluirSincronizacao;
begin
  TThread.Synchronize(nil,
    procedure
    begin
      FProcStatusSincronizador(false);
      Notify('Sincronização completa!');
      FSegundosRestantes := FSincronizador.SQLite.TempoSincronizacao * 60;
      FTimer.Enabled := true;
    end);
end;

procedure TSincronizadorController.IniciarSincronizacao;
begin
  TThread.Synchronize(nil,
    procedure
    begin
      FTimer.Enabled := false;
      FProcStatusSincronizador(true);
      Notify('Iniciando sincronizador');
    end);
end;

function TSincronizadorController.BuscarFiliais: TDictionary<integer, TFilial>;
var
  FiliaisPDVNET: TDictionary<integer, string>;
  FiliaisSQLite: TDictionary<integer, Boolean>;
  FilialPDVNET: TPair<integer, string>;
  Filial: TFilial;
begin
  Result := TDictionary<integer, TFilial>.Create;

  if not FSincronizador.PDVNET.TestarConexaoSQLServer then
    Exit;

  FiliaisPDVNET := FSincronizador.PDVNET.BuscarFiliais;
  FiliaisSQLite := FSincronizador.SQLite.BuscarFiliais;
  try
    for FilialPDVNET in FiliaisPDVNET do
    begin
      Filial := TFilial.Create;
      Filial.ID := FilialPDVNET.Key;
      Filial.Descricao := FilialPDVNET.Value;
      Filial.DesconsiderarEstoque := false;
      if FiliaisSQLite.ContainsKey(FilialPDVNET.Key) then
        Filial.DesconsiderarEstoque := FiliaisSQLite.Items[FilialPDVNET.Key];

      Result.Add(FilialPDVNET.Key, Filial);
    end;
  finally
    FiliaisPDVNET.Free;
    FiliaisSQLite.Free
  end;
end;

function TSincronizadorController.BuscarTabelasDePreco: TOrderedDictionary<integer, string>;
begin
  Result := nil;

  if not FSincronizador.PDVNET.TestarConexaoSQLServer then
    Exit;

  Result := FSincronizador.PDVNET.BuscarTabelasDePreco;
end;

procedure TSincronizadorController.GravarConfigFiliaisEstoque
  (AValue: TDictionary<integer, Boolean>);
begin
  FSincronizador.SQLite.GravarConfigFiliaisEstoque(AValue);
end;

procedure TSincronizadorController.BuscarMovimentosDoPDVNetEGravarNoSQLite;
var
  LPDVRegistros: IRegistrosMovimentados;
begin
  LPDVRegistros := FSincronizador.PDVNET.BuscarMovimentos;
  try
    FSincronizador.SQLite.GravarMovimentos(LPDVRegistros);
    FSincronizador.PDVNET.LimparMovimentos(LPDVRegistros);
  finally
    FSincronizador.PDVNET.DestruirObjetos;
  end;
end;

procedure TSincronizadorController.BuscarCadastrosDoSQLiteEGravarNoBling;
var
  LPDVRegistros: IRegistrosMovimentados;
begin
  LPDVRegistros := FSincronizador.SQLite.BuscarMovimentosDeCadastros;
  try
    FSincronizador.Bling.GravarMovimentosDeCadastros(LPDVRegistros);
    FSincronizador.SQLite.GravarIDsBling(LPDVRegistros);
    FSincronizador.SQLite.LimparMovimentos(LPDVRegistros);
  finally
    FSincronizador.SQLite.DestruirObjetos;
  end;
end;

procedure TSincronizadorController.BuscarProdutosDoSQLiteEGravarNoBling;
var
  LPDVRegistros: IRegistrosMovimentados;
begin
  LPDVRegistros := FSincronizador.SQLite.BuscarMovimentosDeProdutos;
  try
    FSincronizador.Bling.GravarMovimentosDeProdutos(LPDVRegistros);
    FSincronizador.SQLite.GravarIDsBling(LPDVRegistros);
    FSincronizador.SQLite.LimparMovimentos(LPDVRegistros);
  finally
    FSincronizador.SQLite.DestruirObjetos;
  end;
end;

function TSincronizadorController.BuscarReferencias: TObjectList<TReferencia>;
begin
  Result := nil;

  if not FSincronizador.PDVNET.TestarConexaoSQLServer then
    Exit;

  Result := FSincronizador.PDVNET.BuscarReferencias;
end;

end.
