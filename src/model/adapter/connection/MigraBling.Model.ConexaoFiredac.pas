unit MigraBling.Model.ConexaoFiredac;

interface

{$I mb_build.inc}

uses
  Data.DB,
  System.Classes,
  MigraBling.Model.Interfaces.Conexao,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  {$IFDEF USE_FD_MSSQL}
  FireDAC.Phys.MSSQL,
  FireDAC.Phys.MSSQLDef,
  {$ENDIF}
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.Client,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat;

type
  TConexaoFireDAC = class(TInterfacedObject, IConexao)
  private
    FConnection: TFDConnection;
    FBaseConectada: string;
    function GetParams: TStrings;
    procedure SetParams(AValue: TStrings);
    function GetConnected: Boolean;
    procedure SetConnected(AValue: Boolean);
    function GetInstance: TCustomConnection;
    procedure SetDateTimeFormat(AValue: string);
    function GetBaseConectada: string;
    procedure SetBaseConectada(AValue: string);
  public
    constructor Create;
    destructor Destroy; override;
    property Params: TStrings read GetParams write SetParams;
    property Connected: Boolean read GetConnected write SetConnected;
    property Instance: TCustomConnection read GetInstance;
    property DateTimeFormat: string write SetDateTimeFormat;
    property BaseConectada: string read GetBaseConectada write SetBaseConectada;
    procedure Open;
    procedure StartTransaction;
    procedure Commit;
    procedure Rollback;
    procedure DoBackup(ACaminhoBackup: string);
    function Clone: IConexao;
  end;

implementation

uses
  System.SysUtils;

{ TConexaoFireDAC }

function TConexaoFireDAC.Clone: IConexao;
begin
  Result := TConexaoFireDAC.Create;
  Result.Params := Self.FConnection.Params;
  Result.BaseConectada := Self.FBaseConectada;

  if Self.FConnection.Params.Database <> '' then
    Result.Connected := true;
end;

procedure TConexaoFireDAC.Commit;
begin
  FConnection.Commit;
end;

constructor TConexaoFireDAC.Create;
begin
  FConnection := TFDConnection.Create(nil);
  FConnection.LoginPrompt := False;
end;

destructor TConexaoFireDAC.Destroy;
begin
  FConnection.Free;
  inherited;
end;

procedure TConexaoFireDAC.DoBackup(ACaminhoBackup: string);
var
  Backup: TFDSQLiteBackup;
  DriverLink: TFDPhysSQLiteDriverLink;
begin
  if FConnection.ActualDriverID = 'SQLite' then
  begin
    ForceDirectories(ExtractFilePath(ACaminhoBackup));

    if FileExists(ACaminhoBackup) then
      DeleteFile(ACaminhoBackup);

    if not FileExists(ACaminhoBackup) then
    begin
      DriverLink := TFDPhysSQLiteDriverLink.Create(nil);
      Backup := TFDSQLiteBackup.Create(nil);
      try
        Backup.Database := FConnection.Params.Values['Database'];
        Backup.DriverLink := DriverLink;
        Backup.DestDatabase := ACaminhoBackup;
        Backup.Backup;
      finally
        Backup.Free;
        DriverLink.Free;
      end;
    end;
  end;
end;

function TConexaoFireDAC.GetBaseConectada: string;
begin
  Result := FBaseConectada;
end;

function TConexaoFireDAC.GetConnected: Boolean;
begin
  Result := FConnection.Connected;
end;

procedure TConexaoFireDAC.SetDateTimeFormat(AValue: string);
begin
  FConnection.FormatOptions.FmtDisplayDateTime := 'yyyy-mm-dd hh:nn:ss';
end;

function TConexaoFireDAC.GetInstance: TCustomConnection;
begin
  Result := FConnection;
end;

function TConexaoFireDAC.GetParams: TStrings;
begin
  Result := FConnection.Params as TStrings;
end;

procedure TConexaoFireDAC.Open;
begin
  FConnection.Open;
end;

procedure TConexaoFireDAC.Rollback;
begin
  FConnection.Rollback;
end;

procedure TConexaoFireDAC.SetBaseConectada(AValue: string);
begin
  FBaseConectada := AValue;
end;

procedure TConexaoFireDAC.SetConnected(AValue: Boolean);
begin
  if FConnection.ActualDriverID = 'SQLite' then
  begin
    FConnection.FormatOptions.OwnMapRules := True;
    FConnection.FormatOptions.MapRules.Add(dtInt64, dtFmtBCD);
  end;
  FConnection.Connected := AValue;
end;

procedure TConexaoFireDAC.SetParams(AValue: TStrings);
begin
  FConnection.Params.Text := AValue.Text;
end;

procedure TConexaoFireDAC.StartTransaction;
begin
  FConnection.StartTransaction;
end;

end.
