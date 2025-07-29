unit MigraBling.Model.Services.SubServices.PDVNET.DAOSaldos;

interface

uses
  MigraBling.Model.Saldos,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.QueryFactory,
  System.Generics.Collections,
  System.SysUtils,
  MigraBling.Model.LogObserver, MigraBling.Model.Utils,
  MigraBling.Model.Configuracao,
  MigraBling.Model.Services.SubServices.Interfaces.SQLite,
  MigraBling.Model.AppControl;

type
  TDAOSaldosPDVNET = class(TInterfacedObject, IDAOTabelasPDVNET<TSaldo>)
  private
    FConexao: IConexao;
    FConfigurador: ISQLiteService;
  public
    function Ler: TObjectList<TSaldo>;
    constructor Create(AConexao: IConexao; var AConfigurador: ISQLiteService);
  end;

implementation

{ TDAOSaldosPDVNET }

constructor TDAOSaldosPDVNET.Create(AConexao: IConexao; var AConfigurador: ISQLiteService);
begin
  FConexao := AConexao;
  FConfigurador := AConfigurador;
end;

function TDAOSaldosPDVNET.Ler: TObjectList<TSaldo>;
var
  LSaldo: TSaldo;
  LQuery: IQuery;
  LConfiguracoes: TConfiguracao;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
  LConfiguracoes := FConfigurador.Configuracoes.Ler(0);
  Result := TObjectList<TSaldo>.Create;
  try
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
      LSaldo.ID := LQuery.FieldByName('SAL_FILIAL').AsString + '.' +
        LQuery.FieldByName('SAL_PRODUTO').AsString;
      LSaldo.Produto := LQuery.FieldByName('SAL_PRODUTO').AsString;
      LSaldo.ID_Movimento := LQuery.FieldByName('ID').AsString;
      LSaldo.Filial := LQuery.FieldByName('SAL_FILIAL').AsInteger;
      LSaldo.Saldo := LQuery.FieldByName('SAL_SALDO').AsFloat;
      LSaldo.Saldo := ifThen(LSaldo.Saldo <= 0, 0,
        LSaldo.Saldo - LConfiguracoes.QtdEstoqueSubtrair);
      LSaldo.TipoReg := LQuery.FieldByName('TIPO').AsString;
      Result.Add(LSaldo);
      LQuery.Next;
    end;
  finally
    LConfiguracoes.Free;
  end;

end;

end.
