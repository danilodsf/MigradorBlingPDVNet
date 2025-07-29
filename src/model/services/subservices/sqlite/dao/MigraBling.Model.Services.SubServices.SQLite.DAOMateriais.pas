unit MigraBling.Model.Services.SubServices.SQLite.DAOMateriais;

interface

uses
  MigraBling.Model.Interfaces.Dao,
  MigraBling.Model.Materiais,
  System.Generics.Collections,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.QueryFactory,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Utils,
  System.SysUtils,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Services.SubServices.SQLite.Dao;

type
  TDAOMateriaisSQLite = class(TDaoSQLite, IDAOTabelasSQLite<TMaterial>)
  public
    function Ler: TObjectList<TMaterial>;
    procedure Persistir(AListObj: TObjectList<TMaterial>);
    procedure GravarIDsBling(AListObj: TObjectList<TMaterial>);
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOMateriaisSQLite }

constructor TDAOMateriaisSQLite.Create(AConexao: IConexao);
begin
  inherited Create(AConexao);
end;

procedure TDAOMateriaisSQLite.GravarIDsBling(AListObj: TObjectList<TMaterial>);
const
  SQL_TABELA = ' UPDATE LINHA SET ID_BLING = :PID_BLING WHERE LIN_CODIGO = :PLIN_CODIGO ';
  SQL_CAMPO_CUSTOMIZADO = 'UPDATE CAMPOS_CUSTOMIZADOS SET ID_BLING = :PID_BLING ' +
    'WHERE TABELA = ''LINHA'' ';
begin
  AtualizarIDsBlingEntidade<TMaterial>(AListObj, SQL_TABELA, SQL_CAMPO_CUSTOMIZADO,
    procedure(AMaterial: TMaterial; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PLIN_CODIGO').AsIntegers(AIndex, AMaterial.ID);
      AQuery.ParamByName('PID_BLING').AsStrings(AIndex, AMaterial.ID_Bling);
    end,
    procedure(AMaterial: TMaterial; AQuery: IQuery)
    begin
      AQuery.ParamByName('PID_BLING').AsString := AMaterial.ID_CampoCustomizavel;
    end, 'Materiais');
end;

function TDAOMateriaisSQLite.Ler: TObjectList<TMaterial>;
const
  SQL = 'SELECT L.LIN_CODIGO, L.LIN_DESCRICAO, L.LIN_INATIVO2, L.ID_BLING, ' +
    'CC.ID_BLING AS ID_CAMPO_CUSTOMIZADO, MMB.TIPO, MMB.ID_REG, MMB.ID ' +
    'FROM MOVIMENTOS_MIGRAR_BLING MMB LEFT JOIN LINHA L ON (L.LIN_CODIGO = MMB.ID_REG) ' +
    'LEFT JOIN CAMPOS_CUSTOMIZADOS CC ON CC.TABELA = ''LINHA'' ' +
    'WHERE MMB.TABELA = ''LINHA'' AND LIN_INATIVO2 = 0 ';
begin
  Result := LerEntidade<TMaterial>(SQL,
    function(AQuery: IQuery): TMaterial
    var
      LMaterial: TMaterial;
    begin
      LMaterial := TMaterial.Create;
      LMaterial.ID := AQuery.FieldByName('ID_REG').AsInteger;
      LMaterial.ID_Movimento := AQuery.FieldByName('ID').AsString;
      LMaterial.Descricao := AQuery.FieldByName('LIN_DESCRICAO').AsString;
      LMaterial.Inativo := AQuery.FieldByName('LIN_INATIVO2').AsInteger = 1;
      LMaterial.TipoReg := AQuery.FieldByName('TIPO').AsString;
      LMaterial.ID_Bling := AQuery.FieldByName('ID_BLING').AsString;
      LMaterial.ID_CampoCustomizavel := AQuery.FieldByName('ID_CAMPO_CUSTOMIZADO').AsString;
      Result := LMaterial;
    end);
end;

procedure TDAOMateriaisSQLite.Persistir(AListObj: TObjectList<TMaterial>);
const
  SQL_INSERT = ' INSERT INTO LINHA (LIN_CODIGO, LIN_DESCRICAO, LIN_INATIVO2) ' +
      ' VALUES (:PLIN_CODIGO, :PLIN_DESCRICAO, :PLIN_INATIVO2) ' +
      ' ON CONFLICT(LIN_CODIGO) DO UPDATE SET LIN_DESCRICAO = excluded.LIN_DESCRICAO, ' +
      ' LIN_CODIGO = excluded.LIN_CODIGO, LIN_INATIVO2 = excluded.LIN_INATIVO2 ';

  SQL_DELETE = ' UPDATE LINHA SET EXCLUIDO = 1 ' + ' WHERE LIN_CODIGO = :PLIN_CODIGO ';
begin
  PersistirEntidade<TMaterial>(AListObj, SQL_INSERT, SQL_DELETE,
    function(Obj: TMaterial): Boolean
    begin
      Result := ((Obj.TipoReg = 'I') or (Obj.TipoReg = 'U'));
    end,
    procedure(AMaterial: TMaterial; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PLIN_CODIGO').AsIntegers(AIndex, AMaterial.ID);
      AQuery.ParamByName('PLIN_DESCRICAO').AsStrings(AIndex, AMaterial.Descricao);
      AQuery.ParamByName('PLIN_INATIVO2').AsIntegers(AIndex, IfThen(AMaterial.Inativo, 1, 0));
    end,
    procedure(AMaterial: TMaterial; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PLIN_CODIGO').AsIntegers(AIndex, AMaterial.ID);
    end,
    'Materiais');
end;

end.
