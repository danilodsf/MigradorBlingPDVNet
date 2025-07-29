unit MigraBling.Model.Services.SubServices.Bling.DAOGrupos;

interface

uses
  MigraBling.Model.Services.SubServices.Bling.API,
  RESTRequest4D,
  System.JSON,
  Rest.Types,
  Rest.JSON,
  System.SysUtils,
  MigraBling.Model.Grupos,
  MigraBling.Model.Interfaces.DAO,
  System.Generics.Collections,
  MigraBling.Model.Services.SubServices.Interfaces.Auth,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Utils,
  MigraBling.Model.Services.SubServices.Bling.Response,
  System.Classes, MigraBling.Model.AppControl, System.Threading;

type
  TDAOGruposBling = class(TInterfacedObject, IDAOBling<TGrupo>)
  private
    FAuth: IModelAuth;
    procedure Criar(AListObj: TObjectList<TGrupo>);
    function ObterJSONGrupo(AListObj: TObjectList<TGrupo>; AExibirIDs: Boolean = false)
      : TJSONObject;
    procedure Atualizar(AListObj: TObjectList<TGrupo>);
  public
    procedure Persistir(AListObj: TObjectList<TGrupo>);
    constructor Create(AAuth: IModelAuth);
  end;

implementation

uses
  MigraBling.Model.Services.SubServices.Bling.Auth;

{ TDAOGruposBling }

constructor TDAOGruposBling.Create(AAuth: IModelAuth);
begin
  FAuth := AAuth;
end;

function TDAOGruposBling.ObterJSONGrupo(AListObj: TObjectList<TGrupo>; AExibirIDs: Boolean)
  : TJSONObject;
var
  JsonArr: TJSONArray;
  JObj: TJSONObject;
  grupo: TGrupo;
begin
  result := TJSONObject.Create;

  result.AddPair('nome', 'Grupo');
  result.AddPair('situacao', 1);
  result.AddPair('placeholder', 'Informe o grupo do produto');
  result.AddPair('obrigatorio', false);
  result.AddPair('modulo', TJSONObject.Create.AddPair('id', 98309));
  result.AddPair('tipoCampo', TJSONObject.Create.AddPair('id', 3));

  JsonArr := TJSONArray.Create;
  for grupo in AListObj do
  begin
    JObj := TJSONObject.Create;

    if AExibirIDs then
      JObj.AddPair('id', grupo.ID_Bling);

    JObj.AddPair('nome', grupo.Descricao);

    JsonArr.Add(JObj);
  end;

  result.AddPair('opcoes', JsonArr);
end;

procedure TDAOGruposBling.Criar(AListObj: TObjectList<TGrupo>);
var
  Response: IResponse;
  JSON: TJSONObject;
  errorResponse: TResponseError;
  I: integer;
begin
  if TAppControl.AppFinalizando then
    exit;
  errorResponse := nil;
  try
    try
      Response := TRequest.New.BaseURL(C_BASEURL + C_CAMPOS_CUSTOMIZADOS).Accept(C_ACCEPT)
        .ContentType(CONTENTTYPE_APPLICATION_JSON).TokenBearer(FAuth.AccessToken)
        .AddBody(ObterJSONGrupo(AListObj)).OnAfterExecute(
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

      raise Exception.Create(errorResponse.error.message + ' ' + 'Grupos' + '. ' +
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

procedure TDAOGruposBling.Atualizar(AListObj: TObjectList<TGrupo>);
var
  Response: IResponse;
  JSON: TJSONObject;
  errorResponse: TResponseError;
  I: integer;
begin
  if TAppControl.AppFinalizando then
    exit;
  errorResponse := nil;
  try
    try
      Response := TRequest.New.BaseURL(C_BASEURL + C_CAMPOS_CUSTOMIZADOS +
        AListObj[0].ID_CampoCustomizavel).Accept(C_ACCEPT).ContentType(CONTENTTYPE_APPLICATION_JSON)
        .TokenBearer(FAuth.AccessToken).AddBody(ObterJSONGrupo(AListObj, true)).OnAfterExecute(
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

      raise Exception.Create(errorResponse.error.message + ' ' + 'Grupos' + '. ' +
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

procedure TDAOGruposBling.Persistir(AListObj: TObjectList<TGrupo>);
var
  I: integer;
  hasID: Boolean;
  Task: ITask;
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
        TLogSubject.GetInstance.NotifyAll('Inserindo campo customizável: GRUPO');
        Criar(AListObj);
      end
      else
      begin
        TLogSubject.GetInstance.NotifyAll('Atualizando campo customizável: GRUPO');
        Atualizar(AListObj);
      end;
    end);

  Task.Wait;
end;

end.
