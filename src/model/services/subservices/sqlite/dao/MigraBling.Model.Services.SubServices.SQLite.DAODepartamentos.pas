unit MigraBling.Model.Services.SubServices.SQLite.DAODepartamentos;

interface

uses
  MigraBling.Model.Interfaces.Dao,
  MigraBling.Model.Departamentos,
  System.Generics.Collections,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.QueryFactory,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Utils,
  System.SysUtils,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Services.SubServices.SQLite.Dao;

type
  TDAODepartamentosSQLite = class(TDaoSQLite, IDAOTabelasSQLite<TDepartamento>)
  public
    function Ler: TObjectList<TDepartamento>;
    procedure Persistir(AListObj: TObjectList<TDepartamento>);
    procedure GravarIDsBling(AListObj: TObjectList<TDepartamento>);
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAODepartamentosSQLite }

constructor TDAODepartamentosSQLite.Create(AConexao: IConexao);
begin
  inherited Create(AConexao);
end;

procedure TDAODepartamentosSQLite.GravarIDsBling(AListObj: TObjectList<TDepartamento>);
const
  SQL_TABELA = ' UPDATE GRUPOMATERIAIS SET ID_BLING = :PID_BLING ' +
    ' WHERE GRUM_CODIGO = :PGRUM_CODIGO ';
  SQL_CAMPO_CUSTOMIZADO = 'UPDATE CAMPOS_CUSTOMIZADOS SET ID_BLING = :PID_BLING ' +
    'WHERE TABELA = ''GRUPOMATERIAIS'' ';
begin
  AtualizarIDsBlingEntidade<TDepartamento>(AListObj, SQL_TABELA, SQL_CAMPO_CUSTOMIZADO,
    procedure(ADepartamento: TDepartamento; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PGRUM_CODIGO').AsIntegers(AIndex, ADepartamento.ID);
      AQuery.ParamByName('PID_BLING').AsStrings(AIndex, ADepartamento.ID_Bling);
    end,
    procedure(ADepartamento: TDepartamento; AQuery: IQuery)
    begin
      AQuery.ParamByName('PID_BLING').AsString := ADepartamento.ID_CampoCustomizavel;
    end, 'Departamentos');
end;

function TDAODepartamentosSQLite.Ler: TObjectList<TDepartamento>;
const
  SQL = 'SELECT G.GRUM_CODIGO, G.GRUM_DESCRICAO, G.GRUM_INATIVO2, G.ID_BLING, ' +
    'CC.ID_BLING AS ID_CAMPO_CUSTOMIZADO, MMB.TIPO, MMB.ID_REG, MMB.ID ' +
    'FROM MOVIMENTOS_MIGRAR_BLING MMB LEFT JOIN GRUPOMATERIAIS G ON (G.GRUM_CODIGO = MMB.ID_REG) ' +
    'LEFT JOIN CAMPOS_CUSTOMIZADOS CC ON CC.TABELA = ''GRUPOMATERIAIS'' ' +
    'WHERE MMB.TABELA = ''GRUPOMATERIAIS'' AND GRUM_INATIVO2 = 0 ';
begin
  Result := LerEntidade<TDepartamento>(SQL,
    function(AQuery: IQuery): TDepartamento
    var
      LDepartamento: TDepartamento;
    begin
      LDepartamento := TDepartamento.Create;
      LDepartamento.ID := AQuery.FieldByName('ID_REG').AsInteger;
      LDepartamento.ID_Movimento := AQuery.FieldByName('ID').AsString;
      LDepartamento.Descricao := AQuery.FieldByName('GRUM_DESCRICAO').AsString;
      LDepartamento.Inativo := AQuery.FieldByName('GRUM_INATIVO2').AsInteger = 1;
      LDepartamento.TipoReg := AQuery.FieldByName('TIPO').AsString;
      LDepartamento.ID_Bling := AQuery.FieldByName('ID_BLING').AsString;
      LDepartamento.ID_CampoCustomizavel := AQuery.FieldByName('ID_CAMPO_CUSTOMIZADO').AsString;
      Result := LDepartamento;
    end);
end;

procedure TDAODepartamentosSQLite.Persistir(AListObj: TObjectList<TDepartamento>);
const
  SQL_INSERT = ' INSERT INTO GRUPOMATERIAIS (GRUM_CODIGO, GRUM_DESCRICAO, GRUM_INATIVO2) ' +
    ' VALUES (:PGRUM_CODIGO, :PGRUM_DESCRICAO, :PGRUM_INATIVO2) ' +
    ' ON CONFLICT(GRUM_CODIGO) DO UPDATE SET GRUM_DESCRICAO = excluded.GRUM_DESCRICAO, ' +
    ' GRUM_CODIGO = excluded.GRUM_CODIGO, GRUM_INATIVO2 = excluded.GRUM_INATIVO2 ';

  SQL_DELETE = ' UPDATE GRUPOMATERIAIS SET EXCLUIDO = 1 WHERE GRUM_CODIGO = :PGRUM_CODIGO ';
begin
  PersistirEntidade<TDepartamento>(AListObj, SQL_INSERT, SQL_DELETE,
    function(Obj: TDepartamento): Boolean
    begin
      Result := ((Obj.TipoReg = 'I') or (Obj.TipoReg = 'U'));
    end,
    procedure(ADepartamento: TDepartamento; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PGRUM_CODIGO').AsIntegers(AIndex, ADepartamento.ID);
      AQuery.ParamByName('PGRUM_DESCRICAO').AsStrings(AIndex, ADepartamento.Descricao);
      AQuery.ParamByName('PGRUM_INATIVO2').AsIntegers(AIndex, IfThen(ADepartamento.Inativo, 1, 0));
    end,
    procedure(ADepartamento: TDepartamento; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PGRUM_CODIGO').AsIntegers(AIndex, ADepartamento.ID);
    end, 'Departamentos');

end;

end.
