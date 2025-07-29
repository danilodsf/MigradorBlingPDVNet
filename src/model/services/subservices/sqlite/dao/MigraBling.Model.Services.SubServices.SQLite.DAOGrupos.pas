unit MigraBling.Model.Services.SubServices.SQLite.DAOGrupos;

interface

uses
  MigraBling.Model.Interfaces.Dao,
  MigraBling.Model.Grupos,
  System.Generics.Collections,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.QueryFactory,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Utils,
  System.SysUtils,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Services.SubServices.SQLite.Dao;

type
  TDAOGruposSQLite = class(TDaoSQLite, IDAOTabelasSQLite<TGrupo>)
  public
    function Ler: TObjectList<TGrupo>;
    procedure Persistir(AListObj: TObjectList<TGrupo>);
    procedure GravarIDsBling(AListObj: TObjectList<TGrupo>);
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOGruposSQLite }

constructor TDAOGruposSQLite.Create(AConexao: IConexao);
begin
  inherited Create(AConexao);
end;

procedure TDAOGruposSQLite.GravarIDsBling(AListObj: TObjectList<TGrupo>);
const
  SQL_TABELA = ' UPDATE MATERIAPRIMA SET ID_BLING = :PID_BLING ' +
    ' WHERE MAP_CODIGO = :PMAP_CODIGO ';
  SQL_CAMPO_CUSTOMIZADO = 'UPDATE CAMPOS_CUSTOMIZADOS SET ID_BLING = :PID_BLING ' +
    'WHERE TABELA = ''MATERIAPRIMA'' ';
begin
  AtualizarIDsBlingEntidade<TGrupo>(AListObj, SQL_TABELA, SQL_CAMPO_CUSTOMIZADO,
    procedure(AGrupo: TGrupo; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PMAP_CODIGO').AsIntegers(AIndex, AGrupo.ID);
      AQuery.ParamByName('PID_BLING').AsStrings(AIndex, AGrupo.ID_Bling);
    end,
    procedure(AGrupo: TGrupo; AQuery: IQuery)
    begin
      AQuery.ParamByName('PID_BLING').AsString := AGrupo.ID_CampoCustomizavel;
    end, 'Grupos');
end;

function TDAOGruposSQLite.Ler: TObjectList<TGrupo>;
const
  SQL = 'SELECT M.MAP_CODIGO, M.MAP_DESCRICAO, M.MAP_INATIVO2, M.ID_BLING, ' +
    'CC.ID_BLING AS ID_CAMPO_CUSTOMIZADO, MMB.TIPO, MMB.ID_REG, MMB.ID ' +
    'FROM MOVIMENTOS_MIGRAR_BLING MMB LEFT JOIN MATERIAPRIMA M ON (M.MAP_CODIGO = MMB.ID_REG) ' +
    'LEFT JOIN CAMPOS_CUSTOMIZADOS CC ON CC.TABELA = ''MATERIAPRIMA'' ' +
    'WHERE MMB.TABELA = ''MATERIAPRIMA'' AND MAP_INATIVO2 = 0 ';
begin
  Result := LerEntidade<TGrupo>(SQL,
    function(AQuery: IQuery): TGrupo
    var
      LGrupo: TGrupo;
    begin
      LGrupo := TGrupo.Create;
      LGrupo.ID := AQuery.FieldByName('ID_REG').AsInteger;
      LGrupo.ID_Movimento := AQuery.FieldByName('ID').AsString;
      LGrupo.Descricao := AQuery.FieldByName('MAP_DESCRICAO').AsString;
      LGrupo.Inativo := AQuery.FieldByName('MAP_INATIVO2').AsInteger = 1;
      LGrupo.TipoReg := AQuery.FieldByName('TIPO').AsString;
      LGrupo.ID_Bling := AQuery.FieldByName('ID_BLING').AsString;
      LGrupo.ID_CampoCustomizavel := AQuery.FieldByName('ID_CAMPO_CUSTOMIZADO').AsString;
      Result := LGrupo;
    end);
end;

procedure TDAOGruposSQLite.Persistir(AListObj: TObjectList<TGrupo>);
const
  SQL_INSERT = ' INSERT INTO MATERIAPRIMA (MAP_CODIGO, MAP_DESCRICAO, MAP_INATIVO2) ' +
      ' VALUES (:PMAP_CODIGO, :PMAP_DESCRICAO, :PMAP_INATIVO2) ' +
      ' ON CONFLICT(MAP_CODIGO) DO UPDATE SET MAP_DESCRICAO = excluded.MAP_DESCRICAO, ' +
      ' MAP_CODIGO = excluded.MAP_CODIGO, MAP_INATIVO2 = excluded.MAP_INATIVO2 ';

  SQL_DELETE = ' UPDATE MATERIAPRIMA SET EXCLUIDO = 1 WHERE MAP_CODIGO = :PMAP_CODIGO ';
begin
  PersistirEntidade<TGrupo>(AListObj, SQL_INSERT, SQL_DELETE,
    function(Obj: TGrupo): Boolean
    begin
      Result := ((Obj.TipoReg = 'I') or (Obj.TipoReg = 'U'));
    end,
    procedure(AGrupo: TGrupo; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PMAP_CODIGO').AsIntegers(AIndex, AGrupo.ID);
      AQuery.ParamByName('PMAP_DESCRICAO').AsStrings(AIndex, AGrupo.Descricao);
      AQuery.ParamByName('PMAP_INATIVO2').AsIntegers(AIndex, IfThen(AGrupo.Inativo, 1, 0));
    end,
    procedure(AGrupo: TGrupo; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PMAP_CODIGO').AsIntegers(AIndex, AGrupo.ID);
    end,
    'Grupos');
end;

end.
