unit MigraBling.View.Main;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.UITypes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Menus,
  Vcl.ComCtrls,
  Vcl.Buttons,
  MigraBling.Controller.Interfaces.Sincronizador,
  MigraBling.Model.Utils, Vcl.Samples.Spin, System.Threading, Vcl.CheckLst,
  System.Generics.Collections, MigraBling.Model.Filiais,
  MigraBling.Model.AppControl, MigraBling.Model.LogObserver;

type
  TStatusControles = (scReading, scEditing);

type
  TFrmMain = class(TForm)
    pgc: TPageControl;
    tbSincronizacao: TTabSheet;
    tbConfiguracao: TTabSheet;
    pnlMain: TPanel;
    pnlBottom: TPanel;
    Panel1: TPanel;
    lblConfiguracaoServidor: TLabel;
    Label1: TLabel;
    lblProximaSinc: TLabel;
    Panel2: TPanel;
    lblServidorConfigurado: TLabel;
    lblStatusSincronizacao: TLabel;
    lblProximaSincronizacao: TLabel;
    GroupBox1: TGroupBox;
    Panel4: TPanel;
    btnSincronizar: TBitBtn;
    rgAtivarSincronizador: TRadioGroup;
    GroupBox2: TGroupBox;
    Panel3: TPanel;
    btnSalvar: TBitBtn;
    btnCancelar: TBitBtn;
    Panel6: TPanel;
    gbSQLServer: TGroupBox;
    Label6: TLabel;
    edtIPSQLServer: TEdit;
    Label7: TLabel;
    edtBancoSQLServer: TEdit;
    Label8: TLabel;
    edtUsuarioSQLServer: TEdit;
    Label9: TLabel;
    edtSenhaSQLServer: TEdit;
    mmoLog: TMemo;
    Panel5: TPanel;
    Panel7: TPanel;
    gbSQLBling: TGroupBox;
    Label10: TLabel;
    Label11: TLabel;
    edtClientIDBling: TEdit;
    edtClientSecretBling: TEdit;
    Panel8: TPanel;
    gbSincronizador: TGroupBox;
    Label3: TLabel;
    edtTempoSincronizacao: TEdit;
    btnAlterar: TBitBtn;
    Panel9: TPanel;
    gbEstrutura: TGroupBox;
    btnCriarEstrutura: TBitBtn;
    btnExcluirProdutos: TBitBtn;
    btnTestarConexaoSQLServer: TBitBtn;
    Label2: TLabel;
    spnSubirEstoqueAcimaQtd: TSpinEdit;
    Label4: TLabel;
    Label5: TLabel;
    chkListFiliais: TCheckListBox;
    rgPrecoTabela: TRadioGroup;
    TrayIcon1: TTrayIcon;
    PopupMenu1: TPopupMenu;
    Abrir1: TMenuItem;
    Sair1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure rgAtivarSincronizadorClick(Sender: TObject);
    procedure btnAlterarClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnSincronizarClick(Sender: TObject);
    procedure btnCriarEstruturaClick(Sender: TObject);
    procedure btnExcluirProdutosClick(Sender: TObject);
    procedure btnTestarConexaoSQLServerClick(Sender: TObject);
    procedure Abrir1Click(Sender: TObject);
    procedure Sair1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
  private
    FSincronizador: ISincronizadorController;
    FSistemaConfigurado: Boolean;
    procedure SistemaConfigurado(AValue: Boolean);
    procedure GravarLog(AValue: string);
    procedure AtualizarTimer(AValue: string);
    procedure CarregarDados;
    procedure SalvarDados(APersistir: Boolean = true);
    procedure ControlesConfiguracoes(AValue: TStatusControles);
    procedure SistemaSincronizando(AValue: Boolean);
  protected
    procedure WndProc(var Msg: TMessage); override;
  public
    CustomRestoreMsg: UINT;
  end;

var
  FrmMain: TFrmMain;

const
  BalloonHintMessage = 'Sincronizador inicializado';
  SysConfigNotConfigured = 'Não configurado';
  SysConfigConfigured = 'Configurado';
  SysSyncSyncingData = 'Sincronizando dados';
  SysSyncAwaitingCount = 'Aguardando contagem';

implementation

uses
  MigraBling.Controller.Sincronizador;

{$R *.dfm}

procedure TFrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := False;
  Hide;
  TrayIcon1.BalloonHint := 'O aplicativo continua em execução na bandeja';
  TrayIcon1.ShowBalloonHint;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  pgc.ActivePageIndex := 0;
  mmoLog.Lines.Clear;
  FSincronizador := TSincronizadorController.Create;
  FSincronizador.ProcStatusServidor := SistemaConfigurado;
  FSincronizador.ProcStatusSincronizador := SistemaSincronizando;
  FSincronizador.ProcGravaLog := GravarLog;
  FSincronizador.ProcAtualizaTimer := AtualizarTimer;

  CarregarDados;
  rgAtivarSincronizador.ItemIndex := ifThen(FSincronizador.AtivarSincronizador, 0, 1);
  FSincronizador.Inicializar;
  ControlesConfiguracoes(scReading);

  TrayIcon1.Visible := true;
  TrayIcon1.BalloonHint := BalloonHintMessage;
  TrayIcon1.ShowBalloonHint;
  Hide;
end;

procedure TFrmMain.FormResize(Sender: TObject);
begin
  if WindowState = wsMinimized then
  begin
    Hide;
    TrayIcon1.BalloonHint := 'O aplicativo continua em execução na bandeja';
    TrayIcon1.ShowBalloonHint;
  end;
end;

procedure TFrmMain.btnSincronizarClick(Sender: TObject);
begin
  try
    FSincronizador.SincronizarAgora;
  except
    on E: Exception do
      TLogSubject.GetInstance.NotifyAll(E.Message);
  end;
end;

procedure TFrmMain.btnTestarConexaoSQLServerClick(Sender: TObject);
var
  strBotao: string;
begin
  strBotao := btnTestarConexaoSQLServer.Caption;
  btnTestarConexaoSQLServer.Enabled := False;
  btnTestarConexaoSQLServer.Caption := 'aguarde...';

  TAppControl.SafeTask(
    procedure
    begin
      SalvarDados(true);
      if FSincronizador.TestarConexaoSQLServer then
      begin
        TThread.Synchronize(nil,
          procedure
          begin
            MessageDlg('Conectado com sucesso!', mtWarning, [mbOK], 0);
          end);
      end
      else
      begin
        TThread.Synchronize(nil,
          procedure
          begin
            MessageDlg('Não foi possível conectar ao PDVNET', mtWarning, [mbOK], 0);
          end);
      end;

      TThread.Synchronize(nil,
        procedure
        begin
          btnTestarConexaoSQLServer.Caption := strBotao;
          btnTestarConexaoSQLServer.Enabled := true;
        end);
    end);

end;

procedure TFrmMain.btnAlterarClick(Sender: TObject);
begin
  ControlesConfiguracoes(scEditing);
end;

procedure TFrmMain.btnCancelarClick(Sender: TObject);
begin
  ControlesConfiguracoes(scReading);
  CarregarDados;
end;

procedure TFrmMain.btnCriarEstruturaClick(Sender: TObject);
var
  LPodeCriar: Boolean;
begin
  LPodeCriar := true;
  if FSistemaConfigurado then
  begin
    if (MessageDlg
      ('O PDVNET já possui a estrutura de sincronização. Tem certeza que deseja recriar ?',
      mtWarning, [mbYes, mbNo], 0) <> mrYes) then
    begin
      LPodeCriar := False;
    end;
  end;

  if LPodeCriar then
    try
      FSincronizador.CriarEstruturaSincronizacao;
      MessageDlg('Estrutura de sincronização criada com sucesso', mtInformation, [mbOK], 0);
    except
      on E: Exception do
        MessageDlg(E.Message, mtError, [mbOK], 0);
    end;
end;

procedure TFrmMain.btnExcluirProdutosClick(Sender: TObject);
begin
  btnExcluirProdutos.Enabled := False;
  FSincronizador.ApagarTodosProdutos;
  btnExcluirProdutos.Enabled := true;
end;

procedure TFrmMain.btnSalvarClick(Sender: TObject);
begin
  ControlesConfiguracoes(scReading);
  SalvarDados;
  CarregarDados;
end;

procedure TFrmMain.CarregarDados;
var
  LASQLServerIP, LSQLServerBD, LSQLServerUser, LSQLServerPassword, LBlingClientID,
    LBlingClientSecret: string;
  LTempoSincronizacao, LQtdEstoqueSubir, LTabelaPadrao, I: integer;
  Filial: TPair<integer, TFilial>;
  Filiais: TDictionary<integer, TFilial>;
  TabelasDePreco: TOrderedDictionary<integer, string>;
  TabelaDePreco: TPair<integer, string>;
begin
  FSincronizador.LerConfiguracoes(LASQLServerIP, LSQLServerBD, LSQLServerUser, LSQLServerPassword,
    LBlingClientID, LBlingClientSecret, LTempoSincronizacao, LQtdEstoqueSubir, LTabelaPadrao);

  edtIPSQLServer.Text := LASQLServerIP;
  edtBancoSQLServer.Text := LSQLServerBD;
  edtUsuarioSQLServer.Text := LSQLServerUser;
  edtSenhaSQLServer.Text := LSQLServerPassword;
  edtClientIDBling.Text := LBlingClientID;
  edtClientSecretBling.Text := LBlingClientSecret;
  edtTempoSincronizacao.Text := LTempoSincronizacao.ToString;
  spnSubirEstoqueAcimaQtd.Value := LQtdEstoqueSubir;

  chkListFiliais.Items.Clear;
  Filiais := FSincronizador.BuscarFiliais;
  try
    for Filial in Filiais do
    begin
      chkListFiliais.Items.AddObject(Filial.Value.Descricao, TObject(Filial.Value.ID));
      chkListFiliais.Checked[Pred(chkListFiliais.Count)] := (not Filial.Value.DesconsiderarEstoque);
      Filial.Value.Free;
    end;
  finally
    Filiais.Free;
  end;

  rgPrecoTabela.Items.Clear;

  TabelasDePreco := FSincronizador.BuscarTabelasDePreco;
  if not Assigned(TabelasDePreco) then
    exit;

  try
    for TabelaDePreco in TabelasDePreco do
      rgPrecoTabela.Items.AddObject(TabelaDePreco.Value, TObject(TabelaDePreco.Key))
  finally
    TabelasDePreco.Free;
  end;

  for I := 0 to rgPrecoTabela.Items.Count - 1 do
  begin
    if integer(rgPrecoTabela.Items.Objects[I]) = LTabelaPadrao then
    begin
      rgPrecoTabela.ItemIndex := I;
      break;
    end;
  end;
end;

procedure TFrmMain.Sair1Click(Sender: TObject);
begin
  TAppControl.FinalizarTodasAsync;
  TrayIcon1.Visible := False;
  Application.Terminate;
end;

procedure TFrmMain.SalvarDados(APersistir: Boolean);
var
  ConfigFiliais: TDictionary<integer, Boolean>;
  I, idTabelaPreco: integer;
begin
  idTabelaPreco := integer(rgPrecoTabela.Items.Objects[rgPrecoTabela.ItemIndex]);

  FSincronizador.GravarConfiguracoes(edtIPSQLServer.Text, edtBancoSQLServer.Text,
    edtUsuarioSQLServer.Text, edtSenhaSQLServer.Text, edtClientIDBling.Text,
    edtClientSecretBling.Text, StrToIntDef(edtTempoSincronizacao.Text, 2),
    spnSubirEstoqueAcimaQtd.Value, idTabelaPreco, APersistir);

  ConfigFiliais := TDictionary<integer, Boolean>.Create;
  for I := 0 to Pred(chkListFiliais.Count) do
    ConfigFiliais.Add(integer(chkListFiliais.Items.Objects[I]), chkListFiliais.Checked[I]);

  FSincronizador.GravarConfigFiliaisEstoque(ConfigFiliais);
end;

procedure TFrmMain.SistemaConfigurado(AValue: Boolean);
begin
  FSistemaConfigurado := AValue;
  if AValue then
  begin
    lblServidorConfigurado.Caption := SysConfigConfigured;
    lblServidorConfigurado.Font.Color := clGreen;
    lblStatusSincronizacao.Caption := SysSyncAwaitingCount;
  end
  else
  begin
    lblServidorConfigurado.Caption := SysConfigNotConfigured;
    lblServidorConfigurado.Font.Color := clRed;
    lblStatusSincronizacao.Caption := 'Sincronização desligada';
    lblProximaSincronizacao.Caption := '00:00:00';
  end;
end;

procedure TFrmMain.SistemaSincronizando(AValue: Boolean);
begin
  btnSincronizar.Enabled := (not AValue);
  lblProximaSinc.Visible := (not AValue);
  lblProximaSincronizacao.Visible := (not AValue);

  if AValue then
    lblStatusSincronizacao.Caption := 'Sincronizando dados'
  else
    lblStatusSincronizacao.Caption := 'Aguardando contagem';
end;

procedure TFrmMain.WndProc(var Msg: TMessage);
begin
  if Msg.Msg = CustomRestoreMsg then
  begin
    Show;
    WindowState := wsNormal;
    Application.BringToFront;
  end;
  inherited WndProc(Msg);
end;

procedure TFrmMain.GravarLog(AValue: string);
begin
  mmoLog.Lines.Add(FormatDateTime('dd/mm/yyyy hh:nn:ss', now) + ' - ' + AValue);
end;

procedure TFrmMain.rgAtivarSincronizadorClick(Sender: TObject);
begin
  FSincronizador.AtivarSincronizador := (rgAtivarSincronizador.ItemIndex = 0);
end;

procedure TFrmMain.Abrir1Click(Sender: TObject);
begin
  Show;
  WindowState := wsNormal;
  Application.BringToFront;
end;

procedure TFrmMain.AtualizarTimer(AValue: string);
begin
  lblProximaSincronizacao.Caption := AValue;
end;

procedure TFrmMain.ControlesConfiguracoes(AValue: TStatusControles);
begin
  case AValue of
    scReading:
      begin
        gbSQLServer.Enabled := False;
        gbSQLBling.Enabled := False;
        gbSincronizador.Enabled := False;
        gbEstrutura.Enabled := False;
        btnSalvar.Visible := False;
        btnCancelar.Visible := False;
        btnAlterar.Visible := true;
        btnTestarConexaoSQLServer.Enabled := False;
      end;
    scEditing:
      begin
        gbSQLServer.Enabled := true;
        gbSQLBling.Enabled := true;
        gbSincronizador.Enabled := true;
        gbEstrutura.Enabled := true;
        btnSalvar.Visible := true;
        btnCancelar.Visible := true;
        btnAlterar.Visible := False;
        btnTestarConexaoSQLServer.Enabled := true;
      end;
  end;
end;

end.

