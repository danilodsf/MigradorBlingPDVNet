unit MigraBling.Model.Services.SubServices.Bling.DAOSaldos;

interface

uses
  MigraBling.Model.Services.SubServices.Bling.API,
  RESTRequest4D,
  System.JSON,
  Rest.Types,
  Rest.JSON,
  System.SysUtils,
  MigraBling.Model.Saldos,
  MigraBling.Model.Interfaces.DAO,
  System.Generics.Collections,
  MigraBling.Model.Services.SubServices.Interfaces.Auth,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Utils,
  MigraBling.Model.Services.SubServices.Bling.Response,
  System.Classes, System.Threading, MigraBling.Model.AppControl;

type
  TDAOSaldosBling = class(TInterfacedObject, IDAOBling<TSaldo>)
  private
    FAuth: IModelAuth;
    procedure Criar(AObj: TSaldo);
    function ObterJSONEstoque(AObj: TSaldo; AExibirIDs: Boolean = false): TJSONObject;
  public
    procedure Persistir(AListObj: TObjectList<TSaldo>);
    constructor Create(AAuth: IModelAuth);
  end;

implementation

uses
  MigraBling.Model.Services.SubServices.Bling.Auth;

{ TDAOSaldosBling }

constructor TDAOSaldosBling.Create(AAuth: IModelAuth);
begin
  FAuth := AAuth;
end;

function TDAOSaldosBling.ObterJSONEstoque(AObj: TSaldo; AExibirIDs: Boolean): TJSONObject;
begin
  Result := TJSONObject.Create;
  Result.AddPair('produto', TJSONObject.Create.AddPair('id', AObj.Produto_ID_Bling)
    .AddPair('codigo', AObj.Produto));
  Result.AddPair('deposito', TJSONObject.Create.AddPair('id', AObj.Filial_ID_Bling));
  Result.AddPair('operacao', 'B');
  Result.AddPair('quantidade', AObj.Saldo);
end;

procedure TDAOSaldosBling.Criar(AObj: TSaldo);
begin
  if (AObj.DesconsiderarEstoque) or (AObj.Produto_ID_Bling = '') then
  begin
    AObj.ID_Bling := 'EXCLUIR';
    exit;
  end;

  TAppControl.SafeTask(
    procedure
    var
      Response: IResponse;
      errorResponse: TResponseError;
      JSON: TJSONObject;
    begin
      if TAppControl.AppFinalizando then
        exit;
      errorResponse := nil;
      try
        try
          Response := TRequest.New.BaseURL(C_BASEURL + C_ESTOQUES).Accept(C_ACCEPT)
            .ContentType(CONTENTTYPE_APPLICATION_JSON).TokenBearer(FAuth.AccessToken)
            .AddBody(ObterJSONEstoque(AObj)).OnAfterExecute(
            procedure(const Req: IRequest; const Res: IResponse)
            begin
              FAuth.AtualizarToken(Req, Res);
            end).Post;

          if Response.StatusCode = 201 then
          begin
            JSON := TJSONObject.ParseJSONValue(Response.Content) as TJSONObject;
            AObj.ID_Bling := JSON.GetValue<TJSONObject>('data').GetValue<string>('id');
            exit;
          end;

          errorResponse := TJSON.JsonToObject<TResponseError>(Response.Content);
          raise Exception.Create(errorResponse.error.message + ' - ' +
            errorResponse.error.description + ' - ' + 'Estoques' + '. ' + errorResponse.allErrors);
        except
          on E: Exception do
          begin
            TLogSubject.GetInstance.NotifyAll(E.message);
          end;
        end;
      finally
        FreeAndNil(errorResponse);
      end;
    end);
  Sleep(500);
end;

procedure TDAOSaldosBling.Persistir(AListObj: TObjectList<TSaldo>);
var
  I: Integer;
begin
  for I := 0 to Pred(AListObj.Count) do
  begin
    if TAppControl.AppFinalizando then
      break;
    TLogSubject.GetInstance.NotifyAll('Atualizando estoque: ' + AListObj[I].Produto + ' ' +
      IntToStr(I + 1) + ' de ' + AListObj.Count.ToString);
    Criar(AListObj[I]);
  end;
end;

end.
