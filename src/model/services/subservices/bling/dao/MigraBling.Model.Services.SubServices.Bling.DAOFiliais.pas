unit MigraBling.Model.Services.SubServices.Bling.DAOFiliais;

interface

uses
  MigraBling.Model.Services.SubServices.Bling.API,
  RESTRequest4D,
  System.JSON,
  Rest.Types,
  Rest.JSON,
  System.SysUtils,
  MigraBling.Model.Filiais,
  MigraBling.Model.Interfaces.DAO,
  System.Generics.Collections,
  MigraBling.Model.Services.SubServices.Interfaces.Auth,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Utils,
  MigraBling.Model.Services.SubServices.Bling.Response,
  MigraBling.Model.AppControl;

type
  TDAOFiliaisBling = class(TInterfacedObject, IDAOBling<TFilial>)
  private
    FAuth: IModelAuth;
    procedure Atualizar(AObj: TFilial);
    procedure Criar(AObj: TFilial); overload;
    procedure Apagar(AObj: TFilial); overload;
  public
    procedure Persistir(AListObj: TObjectList<TFilial>);
    constructor Create(AAuth: IModelAuth);
  end;

implementation

uses
  MigraBling.Model.Services.SubServices.Bling.Auth;

{ TDAOFiliaisBling }

constructor TDAOFiliaisBling.Create(AAuth: IModelAuth);
begin
  FAuth := AAuth;
end;

procedure TDAOFiliaisBling.Criar(AObj: TFilial);
var
  Response: IResponse;
  JSON, JSONBody: TJSONObject;
  errorResponse: TResponseError;
begin
  errorResponse := nil;
  try
    try
      JSONBody := TJSONObject.Create;
      JSONBody.AddPair('descricao', AObj.Descricao);
      JSONBody.AddPair('situacao', 1);
      JSONBody.AddPair('padrao', false);
      JSONBody.AddPair('desconsiderarSaldo', false);

      Response := TRequest.New.BaseURL(C_BASEURL + C_FILIAIS).Accept(C_ACCEPT)
        .ContentType(CONTENTTYPE_APPLICATION_JSON).TokenBearer(FAuth.AccessToken).AddBody(JSONBody)
        .OnAfterExecute(
        procedure(const Req: IRequest; const Res: IResponse)
        begin
          FAuth.AtualizarToken(Req, Res);
        end).Post;

      if Response.StatusCode = 201 then
      begin
        JSON := TJSONObject.ParseJSONValue(Response.Content) as TJSONObject;
        try
          AObj.ID_Bling := JSON.GetValue<TJSONObject>('data').GetValue<string>('id');
          exit;
        finally
          JSON.Free;
        end;
      end;

      errorResponse := TJSON.JsonToObject<TResponseError>(Response.Content);

      raise Exception.Create(errorResponse.error.message + ' ' + AObj.Descricao + '. ' +
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

procedure TDAOFiliaisBling.Atualizar(AObj: TFilial);
var
  Response: IResponse;
  JSONBody: TJSONObject;
  errorResponse: TResponseError;
begin
  errorResponse := nil;
  try
    try
      JSONBody := TJSONObject.Create;
      JSONBody.AddPair('descricao', AObj.Descricao);
      JSONBody.AddPair('situacao', 1);
      JSONBody.AddPair('padrao', false);
      JSONBody.AddPair('desconsiderarSaldo', false);

      Response := TRequest.New.BaseURL(C_BASEURL + C_FILIAIS + AObj.ID_Bling).Accept(C_ACCEPT)
        .ContentType(CONTENTTYPE_APPLICATION_JSON).TokenBearer(FAuth.AccessToken).AddBody(JSONBody)
        .OnAfterExecute(
        procedure(const Req: IRequest; const Res: IResponse)
        begin
          FAuth.AtualizarToken(Req, Res);
        end).Put;

      if Response.StatusCode = 200 then
        exit;

      errorResponse := TJSON.JsonToObject<TResponseError>(Response.Content);

      raise Exception.Create(errorResponse.error.message + ' ' + AObj.Descricao + '. ' +
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

procedure TDAOFiliaisBling.Persistir(AListObj: TObjectList<TFilial>);
var
  I: Integer;
begin
  for I := 0 to Pred(AListObj.Count) do
  begin
    if TAppControl.AppFinalizando then
      break;

    if ((AListObj[I].TipoReg = 'I') or (AListObj[I].ID_Bling = '')) then
    begin
      TLogSubject.GetInstance.NotifyAll('Inserindo depósito: ' + AListObj[I].Descricao + ' ' +
        IntToStr(I + 1) + ' de ' + AListObj.Count.ToString);
      Criar(AListObj[I]);
    end
    else if ((AListObj[I].TipoReg = 'U') and (AListObj[I].ID_Bling <> '')) then
    begin
      TLogSubject.GetInstance.NotifyAll('Atualizando depósito: ' + AListObj[I].Descricao + ' ' +
        IntToStr(I + 1) + ' de ' + AListObj.Count.ToString);
      Atualizar(AListObj[I]);
    end
    else if ((AListObj[I].TipoReg = 'D') and (AListObj[I].ID_Bling <> '')) then
    begin
      TLogSubject.GetInstance.NotifyAll('Excluindo depósito: ' + AListObj[I].Descricao + ' ' +
        IntToStr(I + 1) + ' de ' + AListObj.Count.ToString);
      Apagar(AListObj[I]);
    end;

    Sleep(500);
  end;
end;

procedure TDAOFiliaisBling.Apagar(AObj: TFilial);
var
  Response: IResponse;
begin
  try
    Response := TRequest.New.BaseURL(C_BASEURL + C_FILIAIS + AObj.ID_Bling).Accept(C_ACCEPT)
      .ContentType(CONTENTTYPE_APPLICATION_JSON).TokenBearer(FAuth.AccessToken).OnAfterExecute(
      procedure(const Req: IRequest; const Res: IResponse)
      begin
        FAuth.AtualizarToken(Req, Res);
      end).Delete;

    if Response.StatusCode = 204 then
      exit;

    raise Exception.Create(Response.Content);
  except
    on E: Exception do
    begin
      TLogSubject.GetInstance.NotifyAll('Não foi possível excluir a filial' + #13#10 + E.message);
    end;
  end;
end;

end.
