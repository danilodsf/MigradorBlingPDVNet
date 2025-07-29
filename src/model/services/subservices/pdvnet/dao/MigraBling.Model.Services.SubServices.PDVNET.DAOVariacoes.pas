unit MigraBling.Model.Services.SubServices.PDVNET.DAOVariacoes;

interface

uses
  MigraBling.Model.Variacoes,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.QueryFactory,
  System.Generics.Collections,
  System.SysUtils,
  MigraBling.Model.LogObserver, MigraBling.Model.AppControl;

type
  TDAOVariacoesPDVNET = class(TInterfacedObject, IDAOTabelasPDVNET<TVariacao>)
  private
    FConexao: IConexao;
  public
    function Ler: TObjectList<TVariacao>;
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOVariacoesPDVNET }

constructor TDAOVariacoesPDVNET.Create(AConexao: IConexao);
begin
  FConexao := AConexao;
end;

function TDAOVariacoesPDVNET.Ler: TObjectList<TVariacao>;
var
  LVariacao: TVariacao;
  LQuery: IQuery;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);

  Result := TObjectList<TVariacao>.Create;
  LQuery.Close;
  LQuery.SQL.Text := 'SELECT MAT_CODIGO, MAT_REFERENCIA, MAT_COR, MAT_TAMANHO, ' +
    'MAT_INATIVO, MMB.TIPO, MMB.ID_REG, MMB.ID, MAT_SITE '+
    'FROM MOVIMENTOS_MIGRAR_BLING MMB ' +
    'LEFT JOIN MATERIAIS ON (MAT_CODIGO = MMB.ID_REG) '+
    'LEFT JOIN REFERENCIAS R ON (REF_REFERENCIA = MAT_REFERENCIA) ' +
    'LEFT JOIN REFERENCIASITE on ((RES_COLECAO = REF_COLECAO) and (RES_REFERENCIA = REF_REFERENCIA)) '+
    'WHERE MMB.TABELA = ''MATERIAIS'' ';
  LQuery.Open;
  while not LQuery.EOF do
  begin
    if TAppControl.AppFinalizando then
      break;

    LVariacao := TVariacao.Create;
    LVariacao.ID := LQuery.FieldByName('ID_REG').AsString.Trim;
    LVariacao.ID_Movimento := LQuery.FieldByName('ID').AsString;
    LVariacao.Referencia := LQuery.FieldByName('MAT_REFERENCIA').AsString;
    LVariacao.Cor := LQuery.FieldByName('MAT_COR').AsInteger;
    LVariacao.Tamanho := LQuery.FieldByName('MAT_TAMANHO').AsInteger;
    LVariacao.Inativo := LQuery.FieldByName('MAT_INATIVO').AsBoolean;
    LVariacao.TipoReg := LQuery.FieldByName('TIPO').AsString;
    LVariacao.Exibir := (LQuery.FieldByName('MAT_SITE').AsInteger in [1,3]);
    Result.Add(LVariacao);
    LQuery.Next;
  end;
end;

end.
