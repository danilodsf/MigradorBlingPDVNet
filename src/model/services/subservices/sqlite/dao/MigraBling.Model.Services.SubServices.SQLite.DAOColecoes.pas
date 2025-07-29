unit MigraBling.Model.Services.SubServices.SQLite.DAOColecoes;

interface

uses
  MigraBling.Model.Interfaces.Dao,
  MigraBling.Model.Colecoes,
  System.Generics.Collections,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.QueryFactory,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Utils,
  System.SysUtils,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Services.SubServices.SQLite.Dao;

type
  TDAOColecoesSQLite = class(TDaoSQLite, IDAOTabelasSQLite<TColecao>)
  public
    function Ler: TObjectList<TColecao>;
    procedure Persistir(AListObj: TObjectList<TColecao>);
    procedure GravarIDsBling(AListObj: TObjectList<TColecao>);
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOColecoesSQLite }

constructor TDAOColecoesSQLite.Create(AConexao: IConexao);
begin
  inherited Create(AConexao);
end;

procedure TDAOColecoesSQLite.GravarIDsBling(AListObj: TObjectList<TColecao>);
const
  SQL_TABELA = ' UPDATE COLECOES SET ID_BLING = :PID_BLING WHERE COL_CODIGO = :PCOL_CODIGO ';
  SQL_CAMPO_CUSTOMIZADO = 'UPDATE CAMPOS_CUSTOMIZADOS SET ID_BLING = :PID_BLING ' +
    'WHERE TABELA = ''COLECOES'' ';
begin
  AtualizarIDsBlingEntidade<TColecao>(AListObj, SQL_TABELA, SQL_CAMPO_CUSTOMIZADO,
    procedure(AColecao: TColecao; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PCOL_CODIGO').AsIntegers(AIndex, AColecao.ID);
      AQuery.ParamByName('PID_BLING').AsStrings(AIndex, AColecao.ID_Bling);
    end,
    procedure(AColecao: TColecao; AQuery: IQuery)
    begin
      AQuery.ParamByName('PID_BLING').AsString := AColecao.ID_CampoCustomizavel;
    end, 'Coleções');
end;

function TDAOColecoesSQLite.Ler: TObjectList<TColecao>;
const
  SQL = 'SELECT C.COL_CODIGO, C.COL_DESCRICAO, C.COL_INATIVO2, C.ID_BLING, ' +
    'CC.ID_BLING AS ID_CAMPO_CUSTOMIZADO, MMB.TIPO, MMB.ID_REG, MMB.ID ' +
    'FROM MOVIMENTOS_MIGRAR_BLING MMB LEFT JOIN COLECOES C ON (C.COL_CODIGO = MMB.ID_REG) ' +
    'LEFT JOIN CAMPOS_CUSTOMIZADOS CC ON CC.TABELA = ''COLECOES'' ' +
    'WHERE MMB.TABELA = ''COLECOES'' AND COL_INATIVO2 = 0 ';
begin
  Result := LerEntidade<TColecao>(SQL,
    function(AQuery: IQuery): TColecao
    var
      LColecao: TColecao;
    begin
      LColecao := TColecao.Create;
      LColecao.ID := AQuery.FieldByName('ID_REG').AsInteger;
      LColecao.ID_Movimento := AQuery.FieldByName('ID').AsString;
      LColecao.Descricao := AQuery.FieldByName('COL_DESCRICAO').AsString;
      LColecao.Inativo := AQuery.FieldByName('COL_INATIVO2').AsInteger = 1;
      LColecao.TipoReg := AQuery.FieldByName('TIPO').AsString;
      LColecao.ID_Bling := AQuery.FieldByName('ID_BLING').AsString;
      LColecao.ID_CampoCustomizavel := AQuery.FieldByName('ID_CAMPO_CUSTOMIZADO').AsString;
      Result := LColecao;
    end);
end;

procedure TDAOColecoesSQLite.Persistir(AListObj: TObjectList<TColecao>);
const
  SQL_INSERT = ' INSERT INTO COLECOES (COL_CODIGO, COL_DESCRICAO, COL_INATIVO2) ' +
      ' VALUES (:PCOL_CODIGO, :PCOL_DESCRICAO, :PCOL_INATIVO2) ' +
      ' ON CONFLICT(COL_CODIGO) DO UPDATE SET COL_DESCRICAO = excluded.COL_DESCRICAO, ' +
      ' COL_CODIGO = excluded.COL_CODIGO, COL_INATIVO2 = excluded.COL_INATIVO2 ';

  SQL_DELETE = ' UPDATE COLECOES SET EXCLUIDO = 1 WHERE COL_CODIGO = :PCOL_CODIGO ';
begin
  PersistirEntidade<TColecao>(AListObj, SQL_INSERT, SQL_DELETE,
    function(Obj: TColecao): Boolean
    begin
      Result := ((Obj.TipoReg = 'I') or (Obj.TipoReg = 'U'));
    end,
    procedure(AColecao: TColecao; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PCOL_CODIGO').AsIntegers(AIndex, AColecao.ID);
      AQuery.ParamByName('PCOL_DESCRICAO').AsStrings(AIndex, AColecao.Descricao);
      AQuery.ParamByName('PCOL_INATIVO2').AsIntegers(AIndex, IfThen(AColecao.Inativo, 1, 0));
    end,
    procedure(AColecao: TColecao; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PGRUM_CODIGO').AsIntegers(AIndex, AColecao.ID);
    end, 'Coleções');

end;

end.
