unit MigraBling.Model.Services.SubServices.PDVNET.DAOSaldos;

interface

uses
  System.Generics.Collections,
  System.SysUtils,
  MigraBling.Model.Saldos,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.QueryFactory,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Utils,
  MigraBling.Model.Configuracao,
  MigraBling.Model.Services.SubServices.Interfaces.SQLite,
  MigraBling.Model.AppControl;

type
  TDAOSaldosPDVNET = class(TInterfacedObject, IDAOTabelasPDVNET<TSaldo>,
    IDAOTabelasPDVNETDependencia<TSaldo>)
  private
    FConexao: IConexao;
  public
    function Ler: TObjectList<TSaldo>; overload;
    function Ler(AID: string): TObjectList<TSaldo>; overload;
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOSaldosPDVNET }

constructor TDAOSaldosPDVNET.Create(AConexao: IConexao);
begin
  FConexao := AConexao;
end;

function TDAOSaldosPDVNET.Ler: TObjectList<TSaldo>;
var
  LSaldo: TSaldo;
  LQuery: IQuery;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
  Result := TObjectList<TSaldo>.Create;

  LQuery.Close;
  LQuery.SQL.Text := 'SELECT S.SAL_PRODUTO, S.SAL_FILIAL, S.SAL_SALDO, MMB.TIPO,  ' +
    'MMB.ID_REG, MMB.ID FROM MOVIMENTOS_MIGRAR_BLING MMB LEFT JOIN SALDOS S ' +
    'ON (CAST(SAL_FILIAL AS VARCHAR) + ''.'' + CAST(SAL_PRODUTO AS VARCHAR) = MMB.ID_REG) ' +
    'WHERE MMB.TABELA = ''SALDOS'' ';

  LQuery.Open;
  while not LQuery.EOF do
  begin
    if TAppControl.AppFinalizando then
      break;

    LSaldo := TSaldo.Create;
    LSaldo.ID := Trim(LQuery.FieldByName('SAL_FILIAL').AsString + '.' +
      LQuery.FieldByName('SAL_PRODUTO').AsString);
    LSaldo.Produto := LQuery.FieldByName('SAL_PRODUTO').AsString.Trim;
    LSaldo.ID_Movimento := LQuery.FieldByName('ID').AsString;
    LSaldo.Filial := LQuery.FieldByName('SAL_FILIAL').AsInteger;
    LSaldo.Saldo := LQuery.FieldByName('SAL_SALDO').AsFloat;
    LSaldo.TipoReg := LQuery.FieldByName('TIPO').AsString;
    Result.Add(LSaldo);
    LQuery.Next;
  end;
end;

function TDAOSaldosPDVNET.Ler(AID: string): TObjectList<TSaldo>;
var
  LSaldo: TSaldo;
  LQuery: IQuery;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
  Result := TObjectList<TSaldo>.Create;

  LQuery.Close;
  LQuery.SQL.Text := 'SELECT S.SAL_PRODUTO, S.SAL_FILIAL, S.SAL_SALDO FROM SALDOS S ' +
    'WHERE S.SAL_PRODUTO = :SAL_PRODUTO ';

  LQuery.ParamByName('SAL_PRODUTO').AsString := AID;
  LQuery.Open;
  while not LQuery.EOF do
  begin
    if TAppControl.AppFinalizando then
      break;

    LSaldo := TSaldo.Create;
    LSaldo.ID := Trim(LQuery.FieldByName('SAL_FILIAL').AsString + '.' +
      LQuery.FieldByName('SAL_PRODUTO').AsString);
    LSaldo.Produto := LQuery.FieldByName('SAL_PRODUTO').AsString.Trim;
    LSaldo.Filial := LQuery.FieldByName('SAL_FILIAL').AsInteger;
    LSaldo.Saldo := LQuery.FieldByName('SAL_SALDO').AsFloat;
    LSaldo.TipoReg := 'U';
    Result.Add(LSaldo);
    LQuery.Next;
  end;
end;

end.
