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
  MigraBling.Model.Services.SubServices.SQLite.Dao,
  MigraBling.Model.Services.SubServices.Interfaces.SQLite,
  MigraBling.Model.Configuracao;

type
  TDAOSaldosSQLite = class(TDaoSQLite, IDAOTabelasSQLite<TSaldo>)
  private
    FConfigurador: IDAOConfiguracoesSQLite<TConfiguracao>;
  public
    function Ler: TObjectList<TSaldo>; overload;
    function Ler(AID: string): TSaldo; overload;
    procedure Persistir(AListObj: TObjectList<TSaldo>);
    procedure GravarIDsBling(AListObj: TObjectList<TSaldo>);
    constructor Create(AConexao: IConexao; AConfigurador: IDAOConfiguracoesSQLite<TConfiguracao>);
  end;

const
  FILIAL_BLING = 5;

implementation

{ TDAOSaldosSQLite }

constructor TDAOSaldosSQLite.Create(AConexao: IConexao;
  AConfigurador: IDAOConfiguracoesSQLite<TConfiguracao>);
begin
  inherited Create(AConexao);
  FConfigurador := AConfigurador;
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

function TDAOSaldosSQLite.Ler(AID: string): TSaldo;
begin
  Result := nil;
end;

function TDAOSaldosSQLite.Ler: TObjectList<TSaldo>;
const
  SQL = 'SELECT S.SAL_ID, S.SAL_PRODUTO, S.SAL_FILIAL, S.SAL_SALDO, S.ID_BLING, ' +
    'F.ID_BLING FILIAL_ID_BLING, M.ID_BLING PRODUTO_ID_BLING, MMB.TIPO, MMB.ID_REG, MMB.ID, ' +
    'F.DESCONSIDERAR_ESTOQUE ' +
    'FROM MOVIMENTOS_MIGRAR_BLING MMB LEFT JOIN SALDOS S ON (S.SAL_ID = MMB.ID_REG) ' +
    'LEFT JOIN FILIAL F ON (F.FIL_CODIGO = S.SAL_FILIAL) ' +
    'LEFT JOIN MATERIAIS M ON (M.MAT_CODIGO = S.SAL_PRODUTO) WHERE MMB.TABELA = ''SALDOS'' '+
    'AND F.FIL_CODIGO <> :FIL_CODIGO';

  SQL_CONSOLIDA =
    'SELECT SUM(S.SAL_SALDO) SAL_SALDO FROM SALDOS S JOIN FILIAL F ON (S.SAL_FILIAL = F.FIL_CODIGO) '
    + 'WHERE S.SAL_PRODUTO = :SAL_PRODUTO AND F.DESCONSIDERAR_ESTOQUE = 0 ';

  SQL_INSERT = 'INSERT INTO SALDOS (SAL_ID, SAL_PRODUTO, SAL_FILIAL, SAL_SALDO) VALUES ' +
    '(:SAL_ID, :SAL_PRODUTO, :SAL_FILIAL, :SAL_SALDO) ' +
    'ON CONFLICT(SAL_ID) DO UPDATE SET SAL_ID = excluded.SAL_ID, ' +
    'SAL_PRODUTO = excluded.SAL_PRODUTO, SAL_FILIAL = excluded.SAL_FILIAL, ' +
    'SAL_SALDO = excluded.SAL_SALDO ';
var
  LConfiguracoes: TConfiguracao;
begin
  LConfiguracoes := FConfigurador.Ler(0);
  try
    Result := LerEntidade<TSaldo>(SQL, SQL_INSERT, SQL_CONSOLIDA,
      procedure(AQuery: IQuery; ANaoRetornarSaldoBling: boolean)
      begin
        AQuery.ParamByName('FIL_CODIGO').AsInteger := -1; // Neste caso retorna tudo

        if ANaoRetornarSaldoBling then
          AQuery.ParamByName('FIL_CODIGO').AsInteger := FILIAL_BLING;
      end,
      procedure(AQuery, AQueryInserir, AQueryConsolida: IQuery)
      begin
        AQueryConsolida.ParamByName('SAL_PRODUTO').AsString :=
          AQuery.FieldByName('SAL_PRODUTO').AsString;
        AQueryConsolida.Open;

        AQueryInserir.ParamByName('SAL_ID').AsString :=
          '5.' + AQuery.FieldByName('SAL_PRODUTO').AsString;
        AQueryInserir.ParamByName('SAL_PRODUTO').AsString :=
          AQuery.FieldByName('SAL_PRODUTO').AsString;
        AQueryInserir.ParamByName('SAL_FILIAL').AsInteger := FILIAL_BLING;
        AQueryInserir.ParamByName('SAL_SALDO').AsFloat :=
          ifThen(AQueryConsolida.FieldByName('SAL_SALDO').AsFloat <= 0, 0,
          AQueryConsolida.FieldByName('SAL_SALDO').AsFloat - LConfiguracoes.QtdEstoqueSubtrair);
      end,
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
        LSaldo.Saldo := AQuery.FieldByName('SAL_SALDO').AsFloat;
        LSaldo.TipoReg := AQuery.FieldByName('TIPO').AsString;
        LSaldo.ID_Bling := AQuery.FieldByName('ID_BLING').AsString;

        if AQuery.FieldByName('SAL_FILIAL').AsInteger <> FILIAL_BLING then
          LSaldo.ID_Bling := 'EXCLUIR';

        Result := LSaldo;
      end);
  finally
    LConfiguracoes.Free;
  end;
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
    end, 'Saldos');
end;

end.
