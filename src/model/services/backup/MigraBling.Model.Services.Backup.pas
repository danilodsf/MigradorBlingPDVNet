unit MigraBling.Model.Services.Backup;

interface

uses
  System.Classes, System.SysUtils, Winapi.Windows, FireDAC.Comp.Client,
  FireDAC.Stan.Intf, System.DateUtils, FireDAC.Phys.SQLite,
  MigraBling.Model.Services.SubServices.SQLite,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Services.SubServices.Connection,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.Configuracao,
  MigraBling.Model.Utils;

type
  TBackupThread = class(TThread)
  private
    FConfiguracoes: IDAOConfiguracoesSQLite<TConfiguracao>;
    function CaminhoBackup: string;
    function BackupJaFeitoHoje: Boolean;
    procedure FazerBackup;
  protected
    procedure Execute; override;
  public
    constructor Create(AConfiguracoes: IDAOConfiguracoesSQLite<TConfiguracao>);
  end;

implementation

constructor TBackupThread.Create(AConfiguracoes: IDAOConfiguracoesSQLite<TConfiguracao>);
begin
  inherited Create(False);
  FreeOnTerminate := False;
  FConfiguracoes := AConfiguracoes;
end;

function TBackupThread.CaminhoBackup: string;
var
  LConfiguracao: TConfiguracao;
begin
  result := '';
  LConfiguracao := FConfiguracoes.Ler(0);
  try
    if (LConfiguracao.PastaBackup = '') then
      exit;

    result := IncludeTrailingPathDelimiter(LConfiguracao.PastaBackup) +
      FormatDateTime('yyyymmdd', Date) + '.db';

{$IFDEF DEBUG}
    result := getAppDir + 'db\' + ExtractFileName(result);
{$ENDIF}
  finally
    LConfiguracao.Free;
  end;
end;

function TBackupThread.BackupJaFeitoHoje: Boolean;
begin
  result := FileExists(CaminhoBackup);
end;

procedure TBackupThread.FazerBackup;
var
  FConn: IConexao;
  Caminho: string;
begin
  Caminho := CaminhoBackup;

  if (Caminho = '') then
  begin
    Terminate;
    exit;
  end;

  TLogSubject.GetInstance.NotifyAll('Iniciando backup do banco de dados');
  FConn := TConnection.getSQLiteConnection;
  try
    FConn.DoBackup(CaminhoBackup);
    TLogSubject.GetInstance.NotifyAll('Backup concluído com sucesso');
  except
    on E: Exception do
      TLogSubject.GetInstance.NotifyAll('Erro ao fazer o backup do banco de dados - ' + E.Message);
  end;
end;

procedure TBackupThread.Execute;
begin
  while not Terminated do
  begin
    if not BackupJaFeitoHoje then
      FazerBackup;

    Sleep(1000);
  end;
end;

end.
