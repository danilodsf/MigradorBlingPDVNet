unit MigraBling.Model.Services.SubServices.SQLite.DAOTamanhos;

interface

uses
  MigraBling.Model.Interfaces.Dao,
  MigraBling.Model.Tamanhos,
  System.Generics.Collections,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.QueryFactory,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Utils,
  System.SysUtils,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Services.SubServices.SQLite.Dao;

type
  TDAOTamanhosSQLite = class(TDaoSQLite, IDAOTabelasSQLite<TTamanho>)
  public
    function Ler: TObjectList<TTamanho>;
    procedure Persistir(AListObj: TObjectList<TTamanho>);
    procedure GravarIDsBling(AListObj: TObjectList<TTamanho>);
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOTamanhosSQLite }

constructor TDAOTamanhosSQLite.Create(AConexao: IConexao);
begin
  inherited Create(AConexao);
end;

procedure TDAOTamanhosSQLite.GravarIDsBling(AListObj: TObjectList<TTamanho>);
const
  SQL_TABELA = ' UPDATE TAMANHOS SET ID_BLING = :PID_BLING WHERE TAM_CODIGO = :PTAM_CODIGO ';
  SQL_CAMPO_CUSTOMIZADO = 'UPDATE CAMPOS_CUSTOMIZADOS SET ID_BLING = :PID_BLING ' +
    'WHERE TABELA = ''TAMANHOS'' ';
begin
  AtualizarIDsBlingEntidade<TTamanho>(AListObj, SQL_TABELA, SQL_CAMPO_CUSTOMIZADO,
    procedure(ATamanho: TTamanho; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PTAM_CODIGO').AsIntegers(AIndex, ATamanho.ID);
      AQuery.ParamByName('PID_BLING').AsStrings(AIndex, ATamanho.ID_Bling);
    end,
    procedure(ATamanho: TTamanho; AQuery: IQuery)
    begin
      AQuery.ParamByName('PID_BLING').AsString := ATamanho.ID_CampoCustomizavel;
    end, 'Tamanhos');
end;

function TDAOTamanhosSQLite.Ler: TObjectList<TTamanho>;
const
  SQL = 'SELECT T.TAM_CODIGO, T.TAM_TAMANHO, T.TAM_ORDEM, T.TAM_INATIVO, ' +
    'T.ID_BLING, CC.ID_BLING AS ID_CAMPO_CUSTOMIZADO, MMB.TIPO, MMB.ID_REG, MMB.ID ' +
    'FROM MOVIMENTOS_MIGRAR_BLING MMB LEFT JOIN TAMANHOS T ON (T.TAM_CODIGO = MMB.ID_REG) ' +
    'LEFT JOIN CAMPOS_CUSTOMIZADOS CC ON CC.TABELA = ''TAMANHOS'' ' +
    'WHERE MMB.TABELA = ''TAMANHOS'' AND TAM_INATIVO = 0';
begin
  Result := LerEntidade<TTamanho>(SQL,
    function(AQuery: IQuery): TTamanho
    var
      LTamanho: TTamanho;
    begin
      LTamanho := TTamanho.Create;
      LTamanho.ID := AQuery.FieldByName('ID_REG').AsInteger;
      LTamanho.ID_Movimento := AQuery.FieldByName('ID').AsString;
      LTamanho.Descricao := AQuery.FieldByName('TAM_TAMANHO').AsString;
      LTamanho.Ordem := AQuery.FieldByName('TAM_ORDEM').AsInteger;
      LTamanho.Inativo := AQuery.FieldByName('TAM_INATIVO').AsInteger = 1;
      LTamanho.TipoReg := AQuery.FieldByName('TIPO').AsString;
      LTamanho.ID_Bling := AQuery.FieldByName('ID_BLING').AsString;
      LTamanho.ID_CampoCustomizavel := AQuery.FieldByName('ID_CAMPO_CUSTOMIZADO').AsString;
      Result := LTamanho;
    end);
end;

procedure TDAOTamanhosSQLite.Persistir(AListObj: TObjectList<TTamanho>);
const
  SQL_INSERT = ' INSERT INTO TAMANHOS (TAM_CODIGO, TAM_TAMANHO, TAM_ORDEM, TAM_INATIVO) '
      + ' VALUES (:PTAM_CODIGO, :PTAM_TAMANHO, :PTAM_ORDEM, :PTAM_INATIVO) ' +
      ' ON CONFLICT(TAM_CODIGO) DO UPDATE SET TAM_TAMANHO = excluded.TAM_TAMANHO, ' +
      ' TAM_CODIGO = excluded.TAM_CODIGO, TAM_ORDEM = excluded.TAM_ORDEM, '+
      ' TAM_INATIVO = excluded.TAM_INATIVO ';

  SQL_DELETE = ' UPDATE TAMANHOS SET EXCLUIDO = 1 WHERE TAM_CODIGO = :PTAM_CODIGO ';
begin
  PersistirEntidade<TTamanho>(AListObj, SQL_INSERT, SQL_DELETE,
    function(Obj: TTamanho): Boolean
    begin
      Result := ((Obj.TipoReg = 'I') or (Obj.TipoReg = 'U'));
    end,
    procedure(ATamanho: TTamanho; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PTAM_CODIGO').AsIntegers(AIndex, ATamanho.ID);
      AQuery.ParamByName('PTAM_TAMANHO').AsStrings(AIndex, ATamanho.Descricao);
      AQuery.ParamByName('PTAM_ORDEM').AsIntegers(AIndex, ATamanho.Ordem);
      AQuery.ParamByName('PTAM_INATIVO').AsIntegers(AIndex, IfThen(ATamanho.Inativo, 1, 0));
    end,
    procedure(ATamanho: TTamanho; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PTAM_CODIGO').AsIntegers(AIndex, ATamanho.ID);
    end, 'Tamanhos');
end;

end.
