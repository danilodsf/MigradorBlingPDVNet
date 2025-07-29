unit MigraBling.Model.Services.SubServices.Bling.DAOCategorias;

interface

uses
  MigraBling.Model.Services.SubServices.Bling.API,
  RESTRequest4D,
  System.JSON,
  Rest.Types,
  Rest.JSON,
  System.SysUtils,
  MigraBling.Model.Categorias,
  MigraBling.Model.Interfaces.DAO,
  System.Generics.Collections,
  MigraBling.Model.Services.SubServices.Interfaces.Auth,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Utils,
  MigraBling.Model.Services.SubServices.Bling.Response,
  MigraBling.Model.AppControl, System.Threading;

type
  TDAOCategoriasBling = class(TInterfacedObject, IDAOBling<TCategoria>)
  private
    FAuth: IModelAuth;
    function ObterJSONCategoria(AListObj: TObjectList<TCategoria>; AExibirIDs: Boolean = false)
      : TJSONObject;
    procedure Criar(AListObj: TObjectList<TCategoria>); overload;
    procedure Atualizar(AListObj: TObjectList<TCategoria>);

  public
    procedure Persistir(AListObj: TObjectList<TCategoria>);
    constructor Create(AAuth: IModelAuth);
  end;

implementation

uses
  MigraBling.Model.Services.SubServices.Bling.Auth;

{ TDAOCategoriasBling }

constructor TDAOCategoriasBling.Create(AAuth: IModelAuth);
begin
  FAuth := AAuth;
end;

function TDAOCategoriasBling.ObterJSONCategoria(AListObj: TObjectList<TCategoria>;
  AExibirIDs: Boolean): TJSONObject;
var
  JsonArr: TJSONArray;
  JObj: TJSONObject;
  categoria: TCategoria;
begin
  result := TJSONObject.Create;

  result.AddPair('nome', 'Categoria');
  result.AddPair('situacao', 1);
  result.AddPair('placeholder', 'Informe a categoria do produto');
  result.AddPair('obrigatorio', false);
  result.AddPair('modulo', TJSONObject.Create.AddPair('id', 98309));
  result.AddPair('tipoCampo', TJSONObject.Create.AddPair('id', 3));

  JsonArr := TJSONArray.Create;
  for categoria in AListObj do
  begin
    JObj := TJSONObject.Create;

    if AExibirIDs then
      JObj.AddPair('id', categoria.ID_Bling);

    JObj.AddPair('nome', categoria.Descricao);
    JsonArr.Add(JObj);
  end;

  result.AddPair('opcoes', JsonArr);
end;

procedure TDAOCategoriasBling.Criar(AListObj: TObjectList<TCategoria>);
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
        .AddBody(ObterJSONCategoria(AListObj)).OnAfterExecute(
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

      raise Exception.Create(errorResponse.error.message + ' ' + 'Categorias' + '. ' +
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

procedure TDAOCategoriasBling.Atualizar(AListObj: TObjectList<TCategoria>);
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
        .TokenBearer(FAuth.AccessToken).AddBody(ObterJSONCategoria(AListObj, true)).OnAfterExecute(
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

      raise Exception.Create(errorResponse.error.message + ' ' + 'Categorias' + '. ' +
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

procedure TDAOCategoriasBling.Persistir(AListObj: TObjectList<TCategoria>);
var
  I: Integer;
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
        TLogSubject.GetInstance.NotifyAll('Inserindo campo customizável: CATEGORIA');
        Criar(AListObj);
      end
      else
      begin
        TLogSubject.GetInstance.NotifyAll('Atualizando campo customizável: CATEGORIA');
        Atualizar(AListObj);
      end;
    end);

  Task.Wait;
end;

end.
