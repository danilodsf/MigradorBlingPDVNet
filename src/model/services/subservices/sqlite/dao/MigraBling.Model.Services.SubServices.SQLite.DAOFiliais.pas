unit MigraBling.Model.Services.SubServices.SQLite.DAOFiliais;

interface

uses
  MigraBling.Model.Interfaces.Dao,
  MigraBling.Model.Filiais,
  System.Generics.Collections,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.QueryFactory,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Utils,
  System.SysUtils,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Services.SubServices.SQLite.Dao;

type
  TDAOFiliaisSQLite = class(TDaoSQLite, IDAOTabelasSQLite<TFilial>)
  public
    function Ler: TObjectList<TFilial>;
    procedure Persistir(AListObj: TObjectList<TFilial>);
    procedure GravarIDsBling(AListObj: TObjectList<TFilial>);
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOFiliaisSQLite }

constructor TDAOFiliaisSQLite.Create(AConexao: IConexao);
begin
  inherited Create(AConexao);
end;

procedure TDAOFiliaisSQLite.GravarIDsBling(AListObj: TObjectList<TFilial>);
const
  SQL_TABELA = ' UPDATE FILIAL SET ID_BLING = :PID_BLING WHERE FIL_CODIGO = :PFIL_CODIGO ';
begin
  AtualizarIDsBlingEntidade<TFilial>(AListObj, SQL_TABELA,
    procedure(AFilial: TFilial; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PFIL_CODIGO').AsIntegers(AIndex, AFilial.ID);
      AQuery.ParamByName('PID_BLING').AsStrings(AIndex, AFilial.ID_Bling);
    end, 'Filiais');
end;

function TDAOFiliaisSQLite.Ler: TObjectList<TFilial>;
const
  SQL = 'SELECT F.FIL_CODIGO, F.FIL_RAZAO_SOCIAL, F.FIL_INATIVA, F.ID_BLING,' +
    'MMB.TIPO, MMB.ID_REG, MMB.ID ' +
    'FROM MOVIMENTOS_MIGRAR_BLING MMB LEFT JOIN FILIAL F ON (F.FIL_CODIGO = MMB.ID_REG) ' +
    'WHERE MMB.TABELA = ''FILIAL'' ';
begin
  Result := LerEntidade<TFilial>(SQL,
    function(AQuery: IQuery): TFilial
    var
      LFilial: TFilial;
    begin
      LFilial := TFilial.Create;
      LFilial.ID := AQuery.FieldByName('ID_REG').AsInteger;
      LFilial.ID_Bling := AQuery.FieldByName('ID_BLING').AsString;
      LFilial.ID_Movimento := AQuery.FieldByName('ID').AsString;
      LFilial.Descricao := AQuery.FieldByName('FIL_RAZAO_SOCIAL').AsString;
      LFilial.Inativo := AQuery.FieldByName('FIL_INATIVA').AsInteger = 1;
      LFilial.TipoReg := AQuery.FieldByName('TIPO').AsString;
      Result := LFilial;
    end);
end;

procedure TDAOFiliaisSQLite.Persistir(AListObj: TObjectList<TFilial>);
const
  SQL_INSERT = ' INSERT INTO FILIAL (FIL_CODIGO, FIL_RAZAO_SOCIAL, FIL_INATIVA) ' +
    ' VALUES (:PFIL_CODIGO, :PFIL_RAZAO_SOCIAL, :PFIL_INATIVA) ' +
    ' ON CONFLICT(FIL_CODIGO) DO UPDATE SET FIL_RAZAO_SOCIAL = excluded.FIL_RAZAO_SOCIAL, ' +
    ' FIL_CODIGO = excluded.FIL_CODIGO, FIL_INATIVA = excluded.FIL_INATIVA ';

  SQL_DELETE = ' UPDATE FILIAL SET EXCLUIDO = 1 WHERE FIL_CODIGO = :PFIL_CODIGO ';
begin
  PersistirEntidade<TFilial>(AListObj, SQL_INSERT, SQL_DELETE,
    function(Obj: TFilial): Boolean
    begin
      Result := ((Obj.TipoReg = 'I') or (Obj.TipoReg = 'U'));
    end,
    procedure(AFilial: TFilial; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PFIL_CODIGO').AsIntegers(AIndex, AFilial.ID);
      AQuery.ParamByName('PFIL_RAZAO_SOCIAL').AsStrings(AIndex, AFilial.Descricao);
      AQuery.ParamByName('PFIL_INATIVA').AsIntegers(AIndex, IfThen(AFilial.Inativo, 1, 0));
    end,
    procedure(AFilial: TFilial; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PFIL_CODIGO').AsIntegers(AIndex, AFilial.ID);
    end, 'Filiais');
end;

end.
