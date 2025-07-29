unit MigraBling.Model.Services.SubServices.PDVNET.DAOColecoes;

interface

uses
  MigraBling.Model.Colecoes,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.QueryFactory,
  System.Generics.Collections,
  System.SysUtils,
  MigraBling.Model.LogObserver, MigraBling.Model.AppControl;

type
  TDAOColecoesPDVNET = class(TInterfacedObject, IDAOTabelasPDVNET<TColecao>)
  private
    FConexao: IConexao;
  public
    function Ler: TObjectList<TColecao>;
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOColecoesPDVNET }

constructor TDAOColecoesPDVNET.Create(AConexao: IConexao);
begin
  FConexao := AConexao;
end;

function TDAOColecoesPDVNET.Ler: TObjectList<TColecao>;
var
  LColecao: TColecao;
  LQuery: IQuery;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);

  Result := TObjectList<TColecao>.Create;
  LQuery.Close;
  LQuery.SQL.Text := 'SELECT C.COL_CODIGO, C.COL_DESCRICAO, C.COL_INATIVO2, MMB.TIPO,  ' +
    'MMB.ID_REG, MMB.ID FROM MOVIMENTOS_MIGRAR_BLING MMB LEFT JOIN COLECOES C ' +
    'ON (C.COL_CODIGO = MMB.ID_REG) WHERE MMB.TABELA = ''COLECOES'' ';
  LQuery.Open;
  while not LQuery.EOF do
  begin
    if TAppControl.AppFinalizando then
      break;

    LColecao := TColecao.Create;
    LColecao.ID := LQuery.FieldByName('ID_REG').AsInteger;
    LColecao.ID_Movimento := LQuery.FieldByName('ID').AsString;
    LColecao.Descricao := LQuery.FieldByName('COL_DESCRICAO').AsString;
    LColecao.Inativo := LQuery.FieldByName('COL_INATIVO2').AsBoolean;
    LColecao.TipoReg := LQuery.FieldByName('TIPO').AsString;
    Result.Add(LColecao);
    LQuery.Next;
  end;
end;

end.
