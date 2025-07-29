unit MigraBling.Model.Services.SubServices.Bling.DAOMateriais;

interface

uses
  MigraBling.Model.Services.SubServices.Bling.API,
  RESTRequest4D,
  System.JSON,
  Rest.Types,
  Rest.JSON,
  System.SysUtils,
  MigraBling.Model.Materiais,
  MigraBling.Model.Interfaces.DAO,
  System.Generics.Collections,
  MigraBling.Model.Services.SubServices.Interfaces.Auth,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Utils,
  MigraBling.Model.Services.SubServices.Bling.Response,
  System.Classes, MigraBling.Model.AppControl, System.Threading;

type
  TDAOMateriaisBling = class(TInterfacedObject, IDAOBling<TMaterial>)
  private
    FAuth: IModelAuth;
    function ObterJSONMaterial(AListObj: TObjectList<TMaterial>; AExibirIDs: Boolean = false)
      : TJSONObject;
    procedure Criar(AListObj: TObjectList<TMaterial>);
    procedure Atualizar(AListObj: TObjectList<TMaterial>);
  public
    procedure Persistir(AListObj: TObjectList<TMaterial>);
    constructor Create(AAuth: IModelAuth);
  end;

implementation

uses
  MigraBling.Model.Services.SubServices.Bling.Auth;

{ TDAOMateriaisBling }

constructor TDAOMateriaisBling.Create(AAuth: IModelAuth);
begin
  FAuth := AAuth;
end;

function TDAOMateriaisBling.ObterJSONMaterial(AListObj: TObjectList<TMaterial>; AExibirIDs: Boolean)
  : TJSONObject;
var
  JsonArr: TJSONArray;
  JObj: TJSONObject;
  material: TMaterial;
begin
  result := TJSONObject.Create;

  result.AddPair('nome', 'Material');
  result.AddPair('situacao', 1);
  result.AddPair('placeholder', 'Informe o material do produto');
  result.AddPair('obrigatorio', false);
  result.AddPair('modulo', TJSONObject.Create.AddPair('id', 98309));
  result.AddPair('tipoCampo', TJSONObject.Create.AddPair('id', 3));

  JsonArr := TJSONArray.Create;
  for material in AListObj do
  begin
    JObj := TJSONObject.Create;

    if AExibirIDs then
      JObj.AddPair('id', material.ID_Bling);

    JObj.AddPair('nome', material.Descricao);
    JsonArr.Add(JObj);
  end;

  result.AddPair('opcoes', JsonArr);
end;

procedure TDAOMateriaisBling.Criar(AListObj: TObjectList<TMaterial>);
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
        .AddBody(ObterJSONMaterial(AListObj)).OnAfterExecute(
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

      raise Exception.Create(errorResponse.error.message + ' ' + 'Materiais' + '. ' +
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

procedure TDAOMateriaisBling.Atualizar(AListObj: TObjectList<TMaterial>);
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
        .TokenBearer(FAuth.AccessToken).AddBody(ObterJSONMaterial(AListObj, true)).OnAfterExecute(
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

      raise Exception.Create(errorResponse.error.message + ' ' + 'Materiais' + '. ' +
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

procedure TDAOMateriaisBling.Persistir(AListObj: TObjectList<TMaterial>);
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
        TLogSubject.GetInstance.NotifyAll('Inserindo campo customizável: MATERIAL');
        Criar(AListObj);
      end
      else
      begin
        TLogSubject.GetInstance.NotifyAll('Atualizando campo customizável: MATERIAL');
        Atualizar(AListObj);
      end;
    end);

  Task.Wait;
end;

end.
