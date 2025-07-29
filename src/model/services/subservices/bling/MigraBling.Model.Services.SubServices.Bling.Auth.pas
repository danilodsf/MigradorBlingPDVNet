unit MigraBling.Model.Services.SubServices.Bling.Auth;

interface

uses
  MigraBling.Model.Configuracao,
  MigraBling.Model.Services.SubServices.Interfaces.SQLite,
  MigraBling.Model.Utils,
  System.SysUtils,
  ShellAPI,
  Winapi.Windows,
  System.JSON,
  Horse,
  DateUtils,
  RESTRequest4D,
  Rest.Types,
  MigraBling.Model.Services.SubServices.Bling.API,
  Vcl.ExtCtrls,
  System.SyncObjs,
  MigraBling.Model.Services.SubServices.Interfaces.Auth,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Services.SubServices.Bling.Response, Rest.JSON;

type
  TModelAuth = class(TInterfacedObject, IModelAuth)
  private
    FAuthorizationCode: string;
    FState: string;
    FConfigurador: ISQLiteService;
    FConfiguracoes: TConfiguracao;
    FTokenReadyEvent: TEvent;
    function getAccessToken: string;
    function updateAccessToken(ARefreshToken: string): string;
    procedure StartServer;
    procedure getToken(const ACode: string);
  public
    property AccessToken: string read getAccessToken;
    procedure AtualizarToken(const Req: IRequest; const Res: IResponse);
    constructor Create(AConfigurador: ISQLiteService);
    destructor Destroy; override;
  end;

implementation

{ TModelAuth }

function TModelAuth.getAccessToken: string;
var
  url: string;
  WaitResult: TWaitResult;
begin
  try
    try
      if (Now < FConfiguracoes.ExpiresIn) then
        Exit(FConfiguracoes.AccessToken);

      if (FConfiguracoes.RefreshToken <> '') then
      begin
        Exit(updateAccessToken(FConfiguracoes.RefreshToken));
      end;

      StartServer;

      FConfiguracoes.AccessToken := '';

      url := Format(C_BASEURL + C_OAUTH + C_AUTHORIZE + '?response_type=code&client_id=%s&state=%s',
        [FConfiguracoes.ClientID, FState]);
      ShellExecute(0, 'open', PChar(url), nil, nil, SW_SHOWNORMAL);

      WaitResult := FTokenReadyEvent.WaitFor(INFINITE);

      if WaitResult = wrSignaled then
        Result := FConfiguracoes.AccessToken
      else
        TLogSubject.GetInstance.NotifyAll('Tempo de autenticação expirado. Nenhum token recebido.');
    except
      raise;
    end;
  finally
    if THorse.IsRunning then
      THorse.StopListen;
  end;
end;

procedure TModelAuth.StartServer;
begin
  THorse.Get('/callback',
    procedure(Req: THorseRequest; Res: THorseResponse)
    begin
      FAuthorizationCode := Req.Query.Field('code').AsString;
      FState := Req.Query.Field('state').AsString;

      Res.Send('Pode fechar esta página');
      getToken(FAuthorizationCode);
    end);

  THorse.Listen(9000);
end;

procedure TModelAuth.getToken(const ACode: string);
var
  Response: IResponse;
  JSON: TJSONObject;
begin
  try
    Response := TRequest.New.BaseURL(C_BASEURL + C_OAUTH + C_TOKEN).Accept(C_ACCEPT)
      .ContentType(CONTENTTYPE_APPLICATION_X_WWW_FORM_URLENCODED)
      .BasicAuthentication(FConfiguracoes.ClientID, FConfiguracoes.ClientSecret)
      .ClearBody.AddBody('grant_type=authorization_code&code=' + ACode).Post;

    if Response.StatusCode = 200 then
    begin
      JSON := TJSONObject.ParseJSONValue(Response.Content) as TJSONObject;
      try
        FConfiguracoes.AccessToken := JSON.GetValue<string>('access_token');
        FConfiguracoes.RefreshToken := JSON.GetValue<string>('refresh_token');
        FConfiguracoes.ExpiresIn := IncSecond(Now, JSON.GetValue<integer>('expires_in'));
        FConfigurador.Configuracoes.Atualizar(FConfiguracoes);

        FTokenReadyEvent.SetEvent;
      finally
        JSON.Free;
      end;
    end;
  except
    on E: Exception do
    begin
      FTokenReadyEvent.SetEvent;
      TLogSubject.GetInstance.NotifyAll('Não foi possível gerar o Token de autenticação.' + #13#10 +
        E.Message);
    end;
  end;
end;

function TModelAuth.updateAccessToken(ARefreshToken: string): string;
var
  Response: IResponse;
  JSON: TJSONObject;
begin
  try
    Response := TRequest.New.BaseURL(C_BASEURL + C_OAUTH + C_TOKEN).Accept(C_ACCEPT)
      .ContentType(CONTENTTYPE_APPLICATION_X_WWW_FORM_URLENCODED)
      .BasicAuthentication(FConfiguracoes.ClientID, FConfiguracoes.ClientSecret)
      .ClearBody.AddBody('grant_type=refresh_token&refresh_token=' + ARefreshToken).Post;

    if Response.StatusCode = 200 then
    begin
      JSON := TJSONObject.ParseJSONValue(Response.Content) as TJSONObject;
      try
        FConfiguracoes.AccessToken := JSON.GetValue<string>('access_token');
        FConfiguracoes.RefreshToken := JSON.GetValue<string>('refresh_token');
        FConfiguracoes.ExpiresIn := IncSecond(Now, JSON.GetValue<integer>('expires_in'));

        FConfigurador.Configuracoes.Atualizar(FConfiguracoes);
        Exit(FConfiguracoes.AccessToken);
      finally
        JSON.Free;
      end;
    end
    else
    begin
      FConfiguracoes.RefreshToken := '';
      Exit(getAccessToken);
    end;

    raise Exception.Create(Response.Content);
  except
    on E: Exception do
    begin
      TLogSubject.GetInstance.NotifyAll('Não foi possível atualizar o Token de autenticação.' +
        #13#10 + E.Message);
    end;
  end;
end;

constructor TModelAuth.Create(AConfigurador: ISQLiteService);
begin
  FConfigurador := AConfigurador;
  FState := TGuid.NewGuid.ToString;
  FTokenReadyEvent := TEvent.Create(nil, True, False, '');

  FConfiguracoes := FConfigurador.Configuracoes.Ler(0);
end;

destructor TModelAuth.Destroy;
begin
  FTokenReadyEvent.Free;
  FConfiguracoes.Free;
  inherited;
end;

procedure TModelAuth.AtualizarToken(const Req: IRequest; const Res: IResponse);
var
  errorResponse: TResponseError;
begin
  if Res.StatusCode = 401 then
  begin
    errorResponse := TJSON.JsonToObject<TResponseError>(Res.Content);
    try
      if not Assigned(errorResponse) then
        Exit;

      if errorResponse.error.&type = 'invalid_token' then
      begin
        FConfiguracoes.ExpiresIn := IncMinute(Date, -1);
        FConfiguracoes.AccessToken := '';
        getAccessToken;
        while True do
        begin
          if FConfiguracoes.AccessToken = '' then
            Sleep(10)
          else
            Break;
        end;
      end;
    finally
      FreeAndNil(errorResponse);
    end;
  end;
end;

end.
