unit MigraBling.Model.Services.SubServices.SQLite.DAOCategorias;

interface

uses
  MigraBling.Model.Interfaces.Dao,
  MigraBling.Model.Categorias,
  System.Generics.Collections,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.QueryFactory,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Utils,
  System.SysUtils,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Services.SubServices.SQLite.Dao;

type
  TDAOCategoriasSQLite = class(TDaoSQLite, IDAOTabelasSQLite<TCategoria>)
  public
    function Ler: TObjectList<TCategoria>; overload;
    function Ler(AID: string): TCategoria; overload;
    procedure Persistir(AListObj: TObjectList<TCategoria>); overload;
    procedure GravarIDsBling(AListObj: TObjectList<TCategoria>);
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOCategoriasSQLite }

constructor TDAOCategoriasSQLite.Create(AConexao: IConexao);
begin
  inherited Create(AConexao);
end;

procedure TDAOCategoriasSQLite.GravarIDsBling(AListObj: TObjectList<TCategoria>);
const
  SQL_TABELA = ' UPDATE MODELOS SET ID_BLING = :PID_BLING WHERE MOD_CODIGO = :PMOD_CODIGO ';
  SQL_CAMPO_CUSTOMIZADO = 'UPDATE CAMPOS_CUSTOMIZADOS SET ID_BLING = :PID_BLING ' +
    'WHERE TABELA = ''MODELOS'' ';
begin
  AtualizarIDsBlingEntidade<TCategoria>(AListObj, SQL_TABELA, SQL_CAMPO_CUSTOMIZADO,
    procedure(ACategoria: TCategoria; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PMOD_CODIGO').AsIntegers(AIndex, ACategoria.ID);
      AQuery.ParamByName('PID_BLING').AsStrings(AIndex, ACategoria.ID_Bling);
    end,
    procedure(ACategoria: TCategoria; AQuery: IQuery)
    begin
      AQuery.ParamByName('PID_BLING').AsString := ACategoria.ID_CampoCustomizavel;
    end, 'Categorias');
end;

function TDAOCategoriasSQLite.Ler(AID: string): TCategoria;
begin
  Result := nil;
end;

procedure TDAOCategoriasSQLite.Persistir(AListObj: TObjectList<TCategoria>);
const
  SQL_INSERT = ' INSERT INTO modelos (MOD_CODIGO, MOD_DESCRICAO, MOD_INATIVO2) ' +
    ' VALUES (:PMOD_CODIGO, :PMOD_DESCRICAO, :PMOD_INATIVO2) ' +
    ' ON CONFLICT(MOD_CODIGO) DO UPDATE SET MOD_DESCRICAO = excluded.MOD_DESCRICAO, ' +
    ' MOD_CODIGO = excluded.MOD_CODIGO, MOD_INATIVO2 = excluded.MOD_INATIVO2 ';

  SQL_DELETE = ' UPDATE MODELOS SET EXCLUIDO = 1 WHERE MOD_CODIGO = :PMOD_CODIGO ';
begin
  PersistirEntidade<TCategoria>(AListObj, SQL_INSERT, SQL_DELETE,
    function(Obj: TCategoria): Boolean
    begin
      Result := ((Obj.TipoReg = 'I') or (Obj.TipoReg = 'U'));
    end,
    procedure(ACategoria: TCategoria; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PMOD_CODIGO').AsIntegers(AIndex, ACategoria.ID);
      AQuery.ParamByName('PMOD_DESCRICAO').AsStrings(AIndex, ACategoria.Descricao);
      AQuery.ParamByName('PMOD_INATIVO2').AsIntegers(AIndex, IfThen(ACategoria.Inativo, 1, 0));
    end,
    procedure(ACategoria: TCategoria; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PMOD_CODIGO').AsIntegers(AIndex, ACategoria.ID);
    end, 'Categorias');

end;

function TDAOCategoriasSQLite.Ler: TObjectList<TCategoria>;
const
  SQL = 'SELECT M.MOD_CODIGO, M.MOD_DESCRICAO, M.MOD_INATIVO2, M.ID_BLING, ' +
    'CC.ID_BLING AS ID_CAMPO_CUSTOMIZADO, MMB.TIPO, MMB.ID_REG, MMB.ID ' +
    'FROM MOVIMENTOS_MIGRAR_BLING MMB LEFT JOIN MODELOS M ON (M.MOD_CODIGO = MMB.ID_REG) ' +
    'LEFT JOIN CAMPOS_CUSTOMIZADOS CC ON CC.TABELA = ''MODELOS'' ' +
    'WHERE MMB.TABELA = ''MODELOS'' AND MOD_INATIVO2 = 0 ';
begin
  Result := LerEntidade<TCategoria>(SQL,
    function(AQuery: IQuery): TCategoria
    var
      LCategoria: TCategoria;
    begin
      LCategoria := TCategoria.Create;
      LCategoria.ID := AQuery.FieldByName('ID_REG').AsInteger;
      LCategoria.ID_Movimento := AQuery.FieldByName('ID').AsString;
      LCategoria.Descricao := AQuery.FieldByName('MOD_DESCRICAO').AsString;
      LCategoria.Inativo := AQuery.FieldByName('MOD_INATIVO2').AsInteger = 1;
      LCategoria.TipoReg := AQuery.FieldByName('TIPO').AsString;
      LCategoria.ID_Bling := AQuery.FieldByName('ID_BLING').AsString;
      LCategoria.ID_CampoCustomizavel := AQuery.FieldByName('ID_CAMPO_CUSTOMIZADO').AsString;
      Result := LCategoria;
    end);
end;

end.
