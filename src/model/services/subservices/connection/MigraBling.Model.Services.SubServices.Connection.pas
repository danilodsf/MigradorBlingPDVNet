unit MigraBling.Model.Services.SubServices.Connection;

interface

uses
  MigraBling.Model.ConexaoFactory,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Utils,
  MigraBling.Model.Configuracao,
  MigraBling.Model.Services.SubServices.SQLite.CriadorBD,
  System.SysUtils;

type
  TConnection = class
  public
    class function getSQLiteConnection: IConexao;
    class function getSQLServerConnection(AConfigurcao: TConfiguracao): IConexao;
  end;

implementation

{ TConnection }

class function TConnection.getSQLiteConnection: IConexao;
var
  dbDir: string;
begin
  dbDir := getAppDir + 'db\';
  result := TConexaoFactory.New.GetConexao;
  result.BaseConectada := 'SQLite';
  result.Params.Add('Database=' + dbDir+ 'db.db');
  result.Params.Add('LockingMode=Normal');
  result.Params.Add('DriverID=SQLite');
  result.Params.Add('Synchronous=Normal');
  result.Params.Add('JournalMode=WAL');
  result.Params.Add('CacheSize=10000');
  result.Params.Add('BusyTimeout=30000');
  result.Params.Add('TempStore=Memory');

  if not FileExists(dbDir+'db.db') then
  begin
    ForceDirectories(dbDir);
    TCriadorBD.CriarBancoDeDados(result);
  end
  else
    TCriadorBD.AtualizarBancoDeDados(result);
end;

class function TConnection.getSQLServerConnection(AConfigurcao: TConfiguracao): IConexao;
begin
  result := TConexaoFactory.New.GetConexao;
  result.BaseConectada := 'PDVNET';
  result.Params.Add('Server=' + AConfigurcao.PDVNET_Server);
  result.Params.Add('OSAuthent=No');
  result.Params.Add('Database=' + AConfigurcao.PDVNET_Database);
  result.Params.Add('User_Name=' + AConfigurcao.PDVNET_UserName);
  result.Params.Add('Password=' + AConfigurcao.PDVNET_Password);
  result.Params.Add('LoginTimeout=2');
  result.Params.Add('DriverID=MSSQL');
  result.Params.Add('MARS=Yes');
end;

end.
