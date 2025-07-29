unit MigraBling.Model.Services.SubServices.SQLite.DAOPrecos;

interface

uses
  MigraBling.Model.Interfaces.Dao,
  MigraBling.Model.Precos,
  System.Generics.Collections,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.QueryFactory,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Utils,
  System.SysUtils,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Services.SubServices.SQLite.Dao;

type
  TDAOPrecosSQLite = class(TDaoSQLite, IDAOTabelasSQLite<TPreco>)
  public
    function Ler: TObjectList<TPreco>;
    procedure Persistir(AListObj: TObjectList<TPreco>);
    procedure GravarIDsBling(AListObj: TObjectList<TPreco>);
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOPrecosSQLite }

constructor TDAOPrecosSQLite.Create(AConexao: IConexao);
begin
  inherited Create(AConexao);
end;

procedure TDAOPrecosSQLite.GravarIDsBling(AListObj: TObjectList<TPreco>);
begin
  exit;
end;

function TDAOPrecosSQLite.Ler: TObjectList<TPreco>;
const
  SQL = 'SELECT P.PRE_PRODUTO, P.PRE_TABELA, P.PRE_PRECO1, P.PRE_PRECO2, ' +
    'MMB.TIPO, MMB.ID_REG, MMB.ID ' + 'FROM MOVIMENTOS_MIGRAR_BLING MMB ' +
    'LEFT JOIN PRECO P ON (P.PRE_ID = MMB.ID_REG) ' + 'WHERE MMB.TABELA = ''PRECO'' ';
begin
  Result := LerEntidade<TPreco>(SQL,
    function(AQuery: IQuery): TPreco
    var
      LPreco: TPreco;
    begin
      LPreco := TPreco.Create;
      LPreco.ID_Movimento := AQuery.FieldByName('ID').AsString;
      LPreco.Referencia := AQuery.FieldByName('PRE_PRODUTO').AsString;
      LPreco.IDTabela := AQuery.FieldByName('PRE_TABELA').AsInteger;
      LPreco.Preco1 := AQuery.FieldByName('PRE_PRECO1').AsFloat;
      LPreco.Preco2 := AQuery.FieldByName('PRE_PRECO2').AsFloat;
      LPreco.TipoReg := AQuery.FieldByName('TIPO').AsString;
      Result := LPreco;
    end);
end;

procedure TDAOPrecosSQLite.Persistir(AListObj: TObjectList<TPreco>);
const
  SQL_INSERT = ' INSERT INTO PRECO (PRE_ID, PRE_PRODUTO, PRE_TABELA, PRE_PRECO1, PRE_PRECO2) ' +
    ' VALUES (:PPRE_ID, :PPRE_PRODUTO, :PPRE_TABELA, :PPRE_PRECO1, :PPRE_PRECO2) ' +
    ' ON CONFLICT(PRE_ID) DO UPDATE SET PRE_TABELA = excluded.PRE_TABELA, ' +
    ' PRE_ID = excluded.PRE_ID, PRE_PRECO2 = excluded.PRE_PRECO2, ' +
    ' PRE_PRODUTO = excluded.PRE_PRODUTO, PRE_PRECO1 = excluded.PRE_PRECO1 ';

  SQL_DELETE = ' UPDATE PRECO SET EXCLUIDO = 1 WHERE PRE_ID = :PPRE_ID ';
begin
  PersistirEntidade<TPreco>(AListObj, SQL_INSERT, SQL_DELETE,
    function(Obj: TPreco): Boolean
    begin
      Result := ((Obj.TipoReg = 'I') or (Obj.TipoReg = 'U'));
    end,
    procedure(APreco: TPreco; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PPRE_ID').AsStrings(AIndex, APreco.ID);
      AQuery.ParamByName('PPRE_PRODUTO').AsStrings(AIndex, APreco.Referencia);
      AQuery.ParamByName('PPRE_TABELA').AsIntegers(AIndex, APreco.IDTabela);
      AQuery.ParamByName('PPRE_PRECO1').AsFloats(AIndex, APreco.Preco1);
      AQuery.ParamByName('PPRE_PRECO2').AsFloats(AIndex, APreco.Preco2);
    end,
    procedure(APreco: TPreco; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PPRE_ID').AsStrings(AIndex, APreco.ID);
    end, 'Preços');
end;

end.
