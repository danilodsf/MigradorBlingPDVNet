unit MigraBling.Model.Services.SubServices.SQLite.DAOVariacoes;

interface

uses
  System.Generics.Collections,
  System.SysUtils,
  MigraBling.Model.Interfaces.Dao,
  MigraBling.Model.Variacoes,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.QueryFactory,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Utils,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Saldos,
  MigraBling.Model.Services.SubServices.SQLite.Dao,
  MigraBling.Model.Configuracao;

type
  TDAOVariacoesSQLite = class(TDaoSQLite, IDAOTabelasSQLite<TVariacao>)
  private
    FSaldos: IDAOTabelasSQLite<TSaldo>;
  public
    function Ler: TObjectList<TVariacao>; overload;
    procedure Persistir(AListObj: TObjectList<TVariacao>);
    procedure GravarIDsBling(AListObj: TObjectList<TVariacao>);
    constructor Create(AConexao: IConexao; AConfigurador: IDAOConfiguracoesSQLite<TConfiguracao>);
  end;

implementation

uses
  MigraBling.Model.Services.SubServices.SQLite.DAOSaldos;

{ TDAOVariacoesSQLite }

constructor TDAOVariacoesSQLite.Create(AConexao: IConexao;
  AConfigurador: IDAOConfiguracoesSQLite<TConfiguracao>);
begin
  inherited Create(AConexao);
  FSaldos := TDAOSaldosSQLite.Create(AConexao, AConfigurador);
end;

procedure TDAOVariacoesSQLite.GravarIDsBling(AListObj: TObjectList<TVariacao>);
begin
  exit;
end;

function TDAOVariacoesSQLite.Ler: TObjectList<TVariacao>;
const
  SQL = 'SELECT MAT_CODIGO, MAT_REFERENCIA, MAT_COR, MAT_TAMANHO, MAT_INATIVO, ' +
    'MMB.TIPO, MMB.ID_REG, MMB.ID, MAT_EXIBIR, COR_VINCULO_ID_BLING,  TAMANHO_VINCULO_ID_BLING ' +
    'FROM MOVIMENTOS_MIGRAR_BLING MMB LEFT JOIN MATERIAIS T ON (MAT_CODIGO = MMB.ID_REG) ' +
    'WHERE MMB.TABELA = ''MATERIAIS'' ';
begin
  Result := LerEntidade<TVariacao>(SQL,
    function(AQuery: IQuery): TVariacao
    var
      LVariacao: TVariacao;
    begin
      LVariacao := TVariacao.Create;
      LVariacao.ID := AQuery.FieldByName('ID_REG').AsString;
      LVariacao.ID_Movimento := AQuery.FieldByName('ID').AsString;
      LVariacao.Referencia := AQuery.FieldByName('MAT_REFERENCIA').AsString;
      LVariacao.Cor := AQuery.FieldByName('MAT_COR').AsInteger;
      LVariacao.Tamanho := AQuery.FieldByName('MAT_TAMANHO').AsInteger;
      LVariacao.Inativo := AQuery.FieldByName('MAT_INATIVO').AsInteger = 1;
      LVariacao.TipoReg := AQuery.FieldByName('TIPO').AsString;
      LVariacao.Exibir := AQuery.FieldByName('MAT_EXIBIR').AsInteger = 1;
      LVariacao.Cor_ID_Bling := AQuery.FieldByName('COR_VINCULO_ID_BLING').AsString;
      LVariacao.Tamanho_ID_Bling := AQuery.FieldByName('TAMANHO_VINCULO_ID_BLING').AsString;
      Result := LVariacao;
    end);
end;

procedure TDAOVariacoesSQLite.Persistir(AListObj: TObjectList<TVariacao>);
const
  SQL_INSERT = ' INSERT INTO MATERIAIS (MAT_CODIGO,	MAT_REFERENCIA,	MAT_COR, ' +
    'MAT_TAMANHO, MAT_INATIVO, ID_BLING, MAT_EXIBIR) ' +
    'VALUES (:PMAT_CODIGO,	:PMAT_REFERENCIA,	:PMAT_COR, :PMAT_TAMANHO, :PMAT_INATIVO, ' +
    ':PID_BLING, :PMAT_EXIBIR) ' +
    'ON CONFLICT(MAT_CODIGO) DO UPDATE SET MAT_CODIGO = excluded.MAT_CODIGO, ' +
    'MAT_REFERENCIA = excluded.MAT_REFERENCIA, MAT_COR = excluded.MAT_COR, ' +
    'MAT_TAMANHO = excluded.MAT_TAMANHO, MAT_INATIVO = excluded.MAT_INATIVO, ' +
    'MAT_EXIBIR = excluded.MAT_EXIBIR ';

  SQL_DELETE = ' UPDATE MATERIAIS SET EXCLUIDO = 1 WHERE MAT_CODIGO = :PMAT_CODIGO ';
begin
  PersistirEntidade<TVariacao>(AListObj, SQL_INSERT, SQL_DELETE,
    function(Obj: TVariacao): Boolean
    begin
      Result := ((Obj.TipoReg = 'I') or (Obj.TipoReg = 'U'));
    end,
    procedure(AVariacao: TVariacao; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PMAT_CODIGO').AsStrings(AIndex, AVariacao.ID);
      AQuery.ParamByName('PMAT_REFERENCIA').AsStrings(AIndex, AVariacao.Referencia);
      AQuery.ParamByName('PMAT_COR').AsIntegers(AIndex, AVariacao.Cor);
      AQuery.ParamByName('PMAT_TAMANHO').AsIntegers(AIndex, AVariacao.Tamanho);
      AQuery.ParamByName('PMAT_INATIVO').AsIntegers(AIndex, IfThen(AVariacao.Inativo, 1, 0));
      AQuery.ParamByName('PMAT_EXIBIR').AsIntegers(AIndex, IfThen(AVariacao.Exibir, 1, 0));
      AQuery.ParamByName('PID_BLING').AsStrings(AIndex, AVariacao.ID_Bling);

      FSaldos.Persistir(AVariacao.Saldos);
    end,
    procedure(AVariacao: TVariacao; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PMAT_CODIGO').AsStrings(AIndex, AVariacao.ID);
    end, 'Variações');
end;

end.
