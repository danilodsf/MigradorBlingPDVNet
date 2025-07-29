unit MigraBling.Model.Services.SubServices.SQLite.DAOSaldos;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  MigraBling.Model.Utils,
  MigraBling.Model.Saldos,
  MigraBling.Model.Interfaces.Dao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Services.SubServices.SQLite.Dao;

type
  TDAOSaldosSQLite = class(TDaoSQLite, IDAOTabelasSQLite<TSaldo>)
  public
    function Ler: TObjectList<TSaldo>;
    procedure Persistir(AListObj: TObjectList<TSaldo>);
    procedure GravarIDsBling(AListObj: TObjectList<TSaldo>);
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOSaldosSQLite }

constructor TDAOSaldosSQLite.Create(AConexao: IConexao);
begin
  inherited Create(AConexao);
end;

procedure TDAOSaldosSQLite.GravarIDsBling(AListObj: TObjectList<TSaldo>);
const
  SQL = ' UPDATE SALDOS SET ID_BLING = :PID_BLING WHERE SAL_ID = :PSAL_ID ';
begin
  AtualizarIDsBlingEntidade<TSaldo>(AListObj, SQL,
    procedure(ASaldo: TSaldo; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PSAL_ID').AsStrings(AIndex, ASaldo.ID);
      AQuery.ParamByName('PID_BLING').AsStrings(AIndex, ASaldo.ID_Bling);
    end, 'Saldos');
end;

function TDAOSaldosSQLite.Ler: TObjectList<TSaldo>;
const
  SQL = 'SELECT S.SAL_ID, S.SAL_PRODUTO, S.SAL_FILIAL, S.SAL_SALDO, S.ID_BLING, ' +
    'F.ID_BLING FILIAL_ID_BLING, M.ID_BLING PRODUTO_ID_BLING, MMB.TIPO, MMB.ID_REG, MMB.ID, ' +
    'F.DESCONSIDERAR_ESTOQUE '+
    'FROM MOVIMENTOS_MIGRAR_BLING MMB LEFT JOIN SALDOS S ON (S.SAL_ID = MMB.ID_REG) ' +
    'LEFT JOIN FILIAL F ON (F.FIL_CODIGO = S.SAL_FILIAL) '+
    'LEFT JOIN MATERIAIS M ON (M.MAT_CODIGO = S.SAL_PRODUTO) '+
    'WHERE MMB.TABELA = ''SALDOS'' ';
begin
  Result := LerEntidade<TSaldo>(SQL,
    function(AQuery: IQuery): TSaldo
    var
      LSaldo: TSaldo;
    begin
      LSaldo := TSaldo.Create;
      LSaldo.ID := AQuery.FieldByName('ID_REG').AsString;
      LSaldo.ID_Movimento := AQuery.FieldByName('ID').AsString;
      LSaldo.Filial := AQuery.FieldByName('SAL_FILIAL').AsInteger;
      LSaldo.Filial_ID_Bling := AQuery.FieldByName('FILIAL_ID_BLING').AsString;
      LSaldo.Produto := AQuery.FieldByName('SAL_PRODUTO').AsString;
      LSaldo.Produto_ID_Bling := AQuery.FieldByName('PRODUTO_ID_BLING').AsString;
      LSaldo.Saldo :=  AQuery.FieldByName('SAL_SALDO').AsFloat;
      LSaldo.TipoReg := AQuery.FieldByName('TIPO').AsString;
      LSaldo.ID_Bling := AQuery.FieldByName('ID_BLING').AsString;
      LSaldo.DesconsiderarEstoque := (AQuery.FieldByName('DESCONSIDERAR_ESTOQUE').AsInteger = 1);
      Result := LSaldo;
    end);
end;

procedure TDAOSaldosSQLite.Persistir(AListObj: TObjectList<TSaldo>);
const
  SQL_INSERT = ' INSERT INTO SALDOS (SAL_ID, SAL_PRODUTO,	SAL_FILIAL,	SAL_SALDO) ' +
    'VALUES (:PSAL_ID, :PSAL_PRODUTO,	:PSAL_FILIAL,	:PSAL_SALDO) ' +
    'ON CONFLICT(SAL_ID) DO UPDATE SET SAL_ID = excluded.SAL_ID, ' +
    'SAL_PRODUTO = excluded.SAL_PRODUTO, SAL_FILIAL = excluded.SAL_FILIAL, ' +
    'SAL_SALDO = excluded.SAL_SALDO ';

  SQL_DELETE = ' UPDATE SALDO SET EXCLUIDO = 1 WHERE SAL_ID = :PSAL_ID';
begin
  PersistirEntidade<TSaldo>(AListObj, SQL_INSERT, SQL_DELETE,
    function(Obj: TSaldo): Boolean
    begin
      Result := ((Obj.TipoReg = 'I') or (Obj.TipoReg = 'U'));
    end,
    procedure(ASaldo: TSaldo; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PSAL_ID').AsStrings(AIndex, ASaldo.ID);
      AQuery.ParamByName('PSAL_PRODUTO').AsStrings(AIndex, ASaldo.Produto);
      AQuery.ParamByName('PSAL_FILIAL').AsIntegers(AIndex, ASaldo.Filial);
      AQuery.ParamByName('PSAL_SALDO').AsFloats(AIndex, ASaldo.Saldo);
    end,
    procedure(ASaldo: TSaldo; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PSAL_ID').AsStrings(AIndex, ASaldo.ID);
    end,
    'Saldos');
end;

end.
