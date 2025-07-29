unit MigraBling.Model.Services.SubServices.Bling.DAOTamanhos;

interface

uses
  MigraBling.Model.Services.SubServices.Bling.API,
  RESTRequest4D,
  System.JSON,
  Rest.Types,
  Rest.JSON,
  System.SysUtils,
  MigraBling.Model.Tamanhos,
  MigraBling.Model.Interfaces.DAO,
  System.Generics.Collections,
  MigraBling.Model.Services.SubServices.Interfaces.Auth,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Utils,
  MigraBling.Model.Services.SubServices.Bling.Response,
  MigraBling.Model.AppControl, System.Threading;

type
  TDAOTamanhosBling = class(TInterfacedObject, IDAOBling<TTamanho>)
  private
    FAuth: IModelAuth;
    function ObterJSONTamanho(AListObj: TObjectList<TTamanho>; AExibirIDs: Boolean = false)
      : TJSONObject;
    procedure Criar(AListObj: TObjectList<TTamanho>);
    procedure Atualizar(AListObj: TObjectList<TTamanho>);
  public
    procedure Persistir(AListObj: TObjectList<TTamanho>);
    constructor Create(AAuth: IModelAuth);
  end;

implementation

uses
  MigraBling.Model.Services.SubServices.Bling.Auth;

{ TDAOTamanhosBling }

constructor TDAOTamanhosBling.Create(AAuth: IModelAuth);
begin
  FAuth := AAuth;
end;

function TDAOTamanhosBling.ObterJSONTamanho(AListObj: TObjectList<TTamanho>; AExibirIDs: Boolean)
  : TJSONObject;
var
  JsonArr: TJSONArray;
  JObj: TJSONObject;
  tamanho: TTamanho;
begin
  Result := TJSONObject.Create;

  Result.AddPair('nome', 'Tamanho');
  Result.AddPair('situacao', 1);
  Result.AddPair('placeholder', 'Informe o tamanho do produto');
  Result.AddPair('obrigatorio', false);
  Result.AddPair('modulo', TJSONObject.Create.AddPair('id', 98309));
  Result.AddPair('tipoCampo', TJSONObject.Create.AddPair('id', 3));

  JsonArr := TJSONArray.Create;
  for tamanho in AListObj do
  begin
    JObj := TJSONObject.Create;

    if AExibirIDs then
      JObj.AddPair('id', tamanho.ID_Bling);

    JObj.AddPair('nome', tamanho.Descricao);
    JsonArr.Add(JObj);
  end;

  Result.AddPair('opcoes', JsonArr);
end;

procedure TDAOTamanhosBling.Criar(AListObj: TObjectList<TTamanho>);
var
  Response: IResponse;
  JSON: TJSONObject;
  errorResponse: TResponseError;
  I: Integer;
begin
  if TAppControl.AppFinalizando then
    exit;

  errorResponse := nil;
  try
    try
      Response := TRequest.New.BaseURL(C_BASEURL + C_CAMPOS_CUSTOMIZADOS).Accept(C_ACCEPT)
        .ContentType(CONTENTTYPE_APPLICATION_JSON).TokenBearer(FAuth.AccessToken)
        .AddBody(ObterJSONTamanho(AListObj)).OnAfterExecute(
        procedure(const Req: IRequest; const Res: IResponse)
        begin
          FAuth.AtualizarToken(Req, Res);
        end).Post;

      if Response.StatusCode = 201 then
      begin
        JSON := TJSONObject.ParseJSONValue(Response.Content) as TJSONObject;
        try
          for I := 0 to Pred(JSON.GetValue<TJSONObject>('data')
            .GetValue<TJSONArray>('idsOpcoes').Count) do
          begin
            AListObj[I].ID_CampoCustomizavel := JSON.GetValue<TJSONObject>('data')
              .GetValue<string>('id');

            AListObj[I].ID_Bling := JSON.GetValue<TJSONObject>('data')
              .GetValue<TJSONArray>('idsOpcoes').Items[I].GetValue<string>;
          end;
          Sleep(500);
          exit;
        finally
          JSON.Free;
        end;
      end;

      errorResponse := TJSON.JsonToObject<TResponseError>(Response.Content);

      raise Exception.Create(errorResponse.error.message + ' ' + 'Tamanhos' + '. ' +
        errorResponse.allErrors);
    except
      on E: Exception do
      begin
        TLogSubject.GetInstance.NotifyAll(E.message);
      end;
    end;
  finally
    FreeAndNil(errorResponse);
  end;
end;

procedure TDAOTamanhosBling.Atualizar(AListObj: TObjectList<TTamanho>);
var
  Response: IResponse;
  JSON: TJSONObject;
  errorResponse: TResponseError;
  I: Integer;
begin
  if TAppControl.AppFinalizando then
    exit;

  errorResponse := nil;
  try
    try
      Response := TRequest.New.BaseURL(C_BASEURL + C_CAMPOS_CUSTOMIZADOS +
        AListObj[0].ID_CampoCustomizavel).Accept(C_ACCEPT).ContentType(CONTENTTYPE_APPLICATION_JSON)
        .TokenBearer(FAuth.AccessToken).AddBody(ObterJSONTamanho(AListObj, true)).OnAfterExecute(
        procedure(const Req: IRequest; const Res: IResponse)
        begin
          FAuth.AtualizarToken(Req, Res);
        end).Put;

      if Response.StatusCode = 200 then
      begin
        JSON := TJSONObject.ParseJSONValue(Response.Content) as TJSONObject;
        try
          for I := 0 to Pred(JSON.GetValue<TJSONObject>('data')
            .GetValue<TJSONArray>('idsOpcoes').Count) do
          begin
            AListObj[I].ID_CampoCustomizavel := JSON.GetValue<TJSONObject>('data')
              .GetValue<string>('id');

            AListObj[I].ID_Bling := JSON.GetValue<TJSONObject>('data')
              .GetValue<TJSONArray>('idsOpcoes').Items[I].GetValue<string>;
          end;
          Sleep(500);
          exit;
        finally
          JSON.Free;
        end;
      end;

      errorResponse := TJSON.JsonToObject<TResponseError>(Response.Content);

      raise Exception.Create(errorResponse.error.message + ' ' + 'Tamanhos' + '. ' +
        errorResponse.allErrors);
    except
      on E: Exception do
      begin
        TLogSubject.GetInstance.NotifyAll(E.message);
      end;
    end;
  finally
    FreeAndNil(errorResponse);
  end;
end;

procedure TDAOTamanhosBling.Persistir(AListObj: TObjectList<TTamanho>);
var
  Task: ITask;
  hasID: Boolean;
  I: Integer;
begin
  if AListObj.Count = 0 then
    exit;

  hasID := false;
  for I := 0 to Pred(AListObj.Count) do
  begin
    if TAppControl.AppFinalizando then
      break;

    if AListObj[I].ID_CampoCustomizavel <> '' then
    begin
      hasID := true;
      break;
    end;
  end;

  Task := TAppControl.SafeTask(
    procedure
    begin
      if TAppControl.AppFinalizando then
        exit;

      if (not hasID) then
      begin
        TLogSubject.GetInstance.NotifyAll('Inserindo campo customizável: TAMANHO');
        Criar(AListObj);
      end
      else
      begin
        TLogSubject.GetInstance.NotifyAll('Atualizando campo customizável: TAMANHO');
        Atualizar(AListObj);
      end;
    end);

  Task.Wait;
end;

end.
