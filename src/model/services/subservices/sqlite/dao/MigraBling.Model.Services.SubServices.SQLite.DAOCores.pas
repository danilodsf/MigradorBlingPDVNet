unit MigraBling.Model.Services.SubServices.SQLite.DAOCores;

interface

uses
  MigraBling.Model.Interfaces.Dao,
  MigraBling.Model.Cores,
  System.Generics.Collections,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.QueryFactory,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Utils,
  System.SysUtils,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Services.SubServices.SQLite.Dao;

type
  TDAOCoresSQLite = class(TDaoSQLite, IDAOTabelasSQLite<TCor>)
  public
    function Ler: TObjectList<TCor>;
    procedure Persistir(AListObj: TObjectList<TCor>);
    procedure GravarIDsBling(AListObj: TObjectList<TCor>);
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOCoresSQLite }

constructor TDAOCoresSQLite.Create(AConexao: IConexao);
begin
  inherited Create(AConexao);
end;

procedure TDAOCoresSQLite.GravarIDsBling(AListObj: TObjectList<TCor>);
const
  SQL_TABELA = ' UPDATE CORES SET ID_BLING = :PID_BLING WHERE COR_CODIGO = :PCOR_CODIGO ';
  SQL_CAMPO_CUSTOMIZADO = 'UPDATE CAMPOS_CUSTOMIZADOS SET ID_BLING = :PID_BLING ' +
    'WHERE TABELA = ''CORES'' ';
begin
  AtualizarIDsBlingEntidade<TCor>(AListObj, SQL_TABELA, SQL_CAMPO_CUSTOMIZADO,
    procedure(ACor: TCor; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PCOR_CODIGO').AsIntegers(AIndex, ACor.ID);
      AQuery.ParamByName('PID_BLING').AsStrings(AIndex, ACor.ID_Bling);
    end,
    procedure(ACor: TCor; AQuery: IQuery)
    begin
      AQuery.ParamByName('PID_BLING').AsString := ACor.ID_CampoCustomizavel;
    end, 'Cores');
end;

function TDAOCoresSQLite.Ler: TObjectList<TCor>;
const
  SQL = 'SELECT C.COR_CODIGO, C.COR_DESCRICAO, C.COR_INATIVO2, MMB.TIPO, MMB.ID_REG, MMB.ID, ' +
    'C.ID_BLING, CC.ID_BLING AS ID_CAMPO_CUSTOMIZADO '+
    'FROM MOVIMENTOS_MIGRAR_BLING MMB LEFT JOIN CORES C ON (C.COR_CODIGO = MMB.ID_REG) ' +
    'LEFT JOIN CAMPOS_CUSTOMIZADOS CC ON CC.TABELA = ''CORES'' ' +
    'WHERE MMB.TABELA = ''CORES'' AND 0 = 1 '; //Deixei assim pra não migrar de proposito
begin
  Result := LerEntidade<TCor>(SQL,
    function(AQuery: IQuery): TCor
    var
      LCor: TCor;
    begin
      LCor := TCor.Create;
      LCor.ID := AQuery.FieldByName('ID_REG').AsInteger;
      LCor.ID_Movimento := AQuery.FieldByName('ID').AsString;
      LCor.Descricao := AQuery.FieldByName('COR_DESCRICAO').AsString;
      LCor.Inativo := AQuery.FieldByName('COR_INATIVO2').AsInteger = 1;
      LCor.TipoReg := AQuery.FieldByName('TIPO').AsString;
      LCor.ID_Bling := AQuery.FieldByName('ID_BLING').AsString;
      LCor.ID_CampoCustomizavel := AQuery.FieldByName('ID_CAMPO_CUSTOMIZADO').AsString;
      Result := LCor;
    end);
end;

procedure TDAOCoresSQLite.Persistir(AListObj: TObjectList<TCor>);
const
  SQL_INSERT = ' INSERT INTO CORES (COR_CODIGO, COR_DESCRICAO, COR_INATIVO2) ' +
    ' VALUES (:PCOR_CODIGO, :PCOR_DESCRICAO, :PCOR_INATIVO2) ' +
    ' ON CONFLICT(COR_CODIGO) DO UPDATE SET COR_DESCRICAO = excluded.COR_DESCRICAO, ' +
    ' COR_CODIGO = excluded.COR_CODIGO, COR_INATIVO2 = excluded.COR_INATIVO2 ';

  SQL_DELETE = ' UPDATE CORES SET EXCLUIDO = 1 ' + ' WHERE COR_CODIGO = :PCOR_CODIGO ';
begin
  PersistirEntidade<TCor>(AListObj, SQL_INSERT, SQL_DELETE,
    function(Obj: TCor): Boolean
    begin
      Result := ((Obj.TipoReg = 'I') or (Obj.TipoReg = 'U'));
    end,
    procedure(ACor: TCor; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PCOR_CODIGO').AsIntegers(AIndex, ACor.ID);
      AQuery.ParamByName('PCOR_DESCRICAO').AsStrings(AIndex, ACor.Descricao);
      AQuery.ParamByName('PCOR_INATIVO2').AsIntegers(AIndex, IfThen(ACor.Inativo, 1, 0));
    end,
    procedure(ACor: TCor; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PCOR_CODIGO').AsIntegers(AIndex, ACor.ID);
    end, 'Cores');
end;

end.
