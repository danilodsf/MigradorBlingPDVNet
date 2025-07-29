unit MigraBling.Model.Services.SubServices.PDVNET.DAOTabelaPrecos;

interface

uses
  MigraBling.Model.TabelaPrecos,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.QueryFactory,
  System.Generics.Collections,
  System.SysUtils,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Interfaces.LogSubject, MigraBling.Model.AppControl;

type
  TDAOTabelaPrecosPDVNET = class(TInterfacedObject, IDAOTabelasPDVNET<TTabelaPreco>)
  private
    FConexao: IConexao;
  public
    function Ler: TObjectList<TTabelaPreco>;
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOTabelaPrecosPDVNET }

constructor TDAOTabelaPrecosPDVNET.Create(AConexao: IConexao);
begin
  FConexao := AConexao;
end;

function TDAOTabelaPrecosPDVNET.Ler: TObjectList<TTabelaPreco>;
var
  LTabelaPrecos: TTabelaPreco;
  LQuery: IQuery;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);

  Result := TObjectList<TTabelaPreco>.Create;
  LQuery.Close;
  LQuery.SQL.Text := 'SELECT T.TAB_CODIGO, T.TAB_DESCRICAO, T.TAB_INATIVO, MMB.TIPO, MMB.ID_REG, ' +
    'MMB.ID FROM MOVIMENTOS_MIGRAR_BLING MMB ' +
    'LEFT JOIN TABELAPRECO T ON (T.TAB_CODIGO = MMB.ID_REG) WHERE MMB.TABELA = ''TABELAPRECO'' ';
  LQuery.Open;
  while not LQuery.EOF do
  begin
    if TAppControl.AppFinalizando then
      break;

    LTabelaPrecos := TTabelaPreco.Create;
    LTabelaPrecos.ID := LQuery.FieldByName('ID_REG').AsInteger;
    LTabelaPrecos.ID_Movimento := LQuery.FieldByName('ID').AsString;
    LTabelaPrecos.Descricao := LQuery.FieldByName('TAB_DESCRICAO').AsString;
    LTabelaPrecos.Inativo := LQuery.FieldByName('TAB_INATIVO').AsBoolean;
    LTabelaPrecos.TipoReg := LQuery.FieldByName('TIPO').AsString;
    Result.Add(LTabelaPrecos);
    LQuery.Next;
  end;
end;

end.
