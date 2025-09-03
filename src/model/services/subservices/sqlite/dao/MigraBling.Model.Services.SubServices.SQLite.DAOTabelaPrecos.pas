unit MigraBling.Model.Services.SubServices.SQLite.DAOTabelaPrecos;

interface

uses
  MigraBling.Model.Interfaces.Dao,
  MigraBling.Model.TabelaPrecos,
  System.Generics.Collections,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Utils,
  System.SysUtils,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Services.SubServices.SQLite.Dao;

type
  TDAOTabelaPrecosSQLite = class(TDaoSQLite, IDAOTabelasSQLite<TTabelaPreco>)
  public
    function Ler: TObjectList<TTabelaPreco>; overload;
    function Ler(AID: string): TTabelaPreco; overload;
    procedure Persistir(AListObj: TObjectList<TTabelaPreco>);
    procedure GravarIDsBling(AListObj: TObjectList<TTabelaPreco>);
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOTabelaPrecosSQLite }

constructor TDAOTabelaPrecosSQLite.Create(AConexao: IConexao);
begin
  inherited Create(AConexao);
end;

procedure TDAOTabelaPrecosSQLite.GravarIDsBling(AListObj: TObjectList<TTabelaPreco>);
begin
  exit;
end;

function TDAOTabelaPrecosSQLite.Ler(AID: string): TTabelaPreco;
begin
  Result := nil;
end;

function TDAOTabelaPrecosSQLite.Ler: TObjectList<TTabelaPreco>;
const
  SQL = 'SELECT T.TAB_CODIGO, T.TAB_DESCRICAO, T.TAB_INATIVO, ' + 'MMB.TIPO, MMB.ID_REG, MMB.ID ' +
    'FROM MOVIMENTOS_MIGRAR_BLING MMB LEFT JOIN TABELAPRECO T ON (T.TAB_CODIGO = MMB.ID_REG) ' +
    'WHERE MMB.TABELA = ''TABELAPRECO'' ';
begin
  Result := LerEntidade<TTabelaPreco>(SQL,
    function(AQuery: IQuery): TTabelaPreco
    var
      LTabelaPreco: TTabelaPreco;
    begin
      LTabelaPreco := TTabelaPreco.Create;
      LTabelaPreco.ID := AQuery.FieldByName('ID_REG').AsInteger;
      LTabelaPreco.ID_Movimento := AQuery.FieldByName('ID').AsString;
      LTabelaPreco.Descricao := AQuery.FieldByName('TAB_DESCRICAO').AsString;
      LTabelaPreco.Inativo := AQuery.FieldByName('TAB_INATIVO').AsInteger = 1;
      LTabelaPreco.TipoReg := AQuery.FieldByName('TIPO').AsString;
      Result := LTabelaPreco;
    end);
end;

procedure TDAOTabelaPrecosSQLite.Persistir(AListObj: TObjectList<TTabelaPreco>);
const
  SQL_INSERT = ' INSERT INTO TABELAPRECO (TAB_CODIGO, TAB_DESCRICAO, TAB_INATIVO) ' +
    ' VALUES (:PTAB_CODIGO, :PTAB_DESCRICAO, :PTAB_INATIVO) ' +
    ' ON CONFLICT(TAB_CODIGO) DO UPDATE SET TAB_DESCRICAO = excluded.TAB_DESCRICAO, ' +
    ' TAB_CODIGO = excluded.TAB_CODIGO, TAB_INATIVO = excluded.TAB_INATIVO ';

  SQL_DELETE = ' UPDATE TABELAPRECO SET EXCLUIDO = 1 WHERE TAB_CODIGO = :PTAB_CODIGO ';
begin
  PersistirEntidade<TTabelaPreco>(AListObj, SQL_INSERT, SQL_DELETE,
    function(Obj: TTabelaPreco): Boolean
    begin
      Result := ((Obj.TipoReg = 'I') or (Obj.TipoReg = 'U'));
    end,
    procedure(ATabelaPreco: TTabelaPreco; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PTAB_CODIGO').AsIntegers(AIndex, ATabelaPreco.ID);
      AQuery.ParamByName('PTAB_DESCRICAO').AsStrings(AIndex, ATabelaPreco.Descricao);
      AQuery.ParamByName('PTAB_INATIVO').AsIntegers(AIndex, IfThen(ATabelaPreco.Inativo, 1, 0));
    end,
    procedure(ATabelaPreco: TTabelaPreco; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PTAB_CODIGO').AsIntegers(AIndex, ATabelaPreco.ID);
    end, 'Tabela de Preços');
end;

end.
