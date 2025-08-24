unit MigraBling.Model.ConexaoADO;

interface

uses
  MigraBling.Model.Interfaces.Conexao,
  Data.Win.ADODB,
  Data.DB,
  System.Classes,
  Winapi.ActiveX,
  System.Win.ComObj, Vcl.Dialogs;

type
  TConexaoADO = class(TInterfacedObject, IConexao)
  private
    FConnection: TADOConnection;
    FBaseConectada: string;
    FParams: TStringList;
    FCoInitialized: Boolean;
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

{ TConexaoADO }

function TConexaoADO.Clone: IConexao;
begin
  Result := TConexaoADO.Create;
  Result.Params.Text := Self.Params.Text;
  Result.BaseConectada := Self.FBaseConectada;

  try
    Result.Connected := true;
  except

  end;
end;

procedure TConexaoADO.Commit;
begin
  FConnection.CommitTrans;
end;

constructor TConexaoADO.Create;
var
  hr: HResult;
begin
  hr := CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
  FCoInitialized := hr = S_OK;

  FConnection := TADOConnection.Create(nil);
  FConnection.LoginPrompt := False;
  FParams := TStringList.Create;
end;

destructor TConexaoADO.Destroy;
begin
  FParams.Free;
  FConnection.Free;

  if FCoInitialized then
    CoUninitialize;

  inherited;
end;

procedure TConexaoADO.DoBackup(ACaminhoBackup: string);
begin

end;

function TConexaoADO.GetBaseConectada: string;
begin
  Result := FBaseConectada;
end;

function TConexaoADO.GetConnected: Boolean;
begin
  Result := FConnection.Connected;
end;

function TConexaoADO.GetInstance: TCustomConnection;
begin
  Result := FConnection;
end;

function TConexaoADO.GetParams: TStrings;
begin
  Result := FParams;
end;

procedure TConexaoADO.Open;
begin
  Connected := true;
end;

procedure TConexaoADO.Rollback;
begin
  FConnection.RollbackTrans;
end;

procedure TConexaoADO.SetBaseConectada(AValue: string);
begin
  FBaseConectada := AValue;
end;

procedure TConexaoADO.SetConnected(AValue: Boolean);
var
  LConnStr, LServer, LDataBase, LUserName, LPassword: string;
begin
  LServer := FParams.Values['Server'];
  LDataBase := FParams.Values['Database'];
  LUserName := FParams.Values['User_Name'];
  LPassword := FParams.Values['Password'];

  LConnStr := 'Provider=MSOLEDBSQL19;PWD=' + LPassword +
    ';UID=' + LUserName + ';Database=BDMATRIZSPLIT;Server=' + LServer +
    ';Use Encryption for Data=Optional;MultipleActiveResultSets=True;';

  FConnection.ConnectionString := LConnStr;
  try
    FConnection.Connected := AValue;
  except
    on e: Exception do
      raise Exception.Create(E.message + sLineBreak + FConnection.ConnectionString);
  end;
end;

procedure TConexaoADO.SetDateTimeFormat(AValue: string);
begin
  //
end;

procedure TConexaoADO.SetParams(AValue: TStrings);
begin
  FParams.Text := AValue.Text;
end;

procedure TConexaoADO.StartTransaction;
begin
  FConnection.BeginTrans;
end;

end.
