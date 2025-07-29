unit MigraBling.Model.Services.SubServices.PDVNET.DAOPrecos;

interface

uses
  MigraBling.Model.Precos,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.QueryFactory,
  System.Generics.Collections,
  System.SysUtils,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Interfaces.LogSubject, MigraBling.Model.AppControl,
  MigraBling.Model.Services.SubServices.Interfaces.SQLite,
  MigraBling.Model.Configuracao;

type
  TDAOPrecosPDVNET = class(TInterfacedObject, IDAOTabelasPDVNET<TPreco>)
  private
    FConexao: IConexao;
    FConfigurador: ISQLiteService;
  public
    function Ler: TObjectList<TPreco>;
    constructor Create(AConexao: IConexao; AConfigurador: ISQLiteService);
  end;

implementation

{ TDAOPrecosPDVNET }

constructor TDAOPrecosPDVNET.Create(AConexao: IConexao; AConfigurador: ISQLiteService);
begin
  FConexao := AConexao;
  FConfigurador := AConfigurador;
end;

function TDAOPrecosPDVNET.Ler: TObjectList<TPreco>;
var
  LPreco: TPreco;
  LQuery: IQuery;
  LConfiguracao: TConfiguracao;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
  LConfiguracao := FConfigurador.Configuracoes.Ler(0);
  Result := TObjectList<TPreco>.Create;
  try
    LQuery.Close;
    LQuery.SQL.Text := 'SELECT P.PRE_PRODUTO, P.PRE_TABELA, P.PRE_PRECO1, P.PRE_PRECO2, MMB.TIPO, '
      + 'MMB.ID_REG, MMB.ID FROM MOVIMENTOS_MIGRAR_BLING MMB LEFT JOIN PRECO P ' +
      'ON (CAST(P.PRE_TABELA AS VARCHAR) + ''.'' + CAST([PRE_PRODUTO] AS VARCHAR) = MMB.ID_REG) ' +
      'JOIN TABELAPRECO on TAB_CODIGO = PRE_TABELA WHERE MMB.TABELA = ''PRECO'' ' +
      'AND TAB_INATIVO = 0 AND TAB_CODIGO = :PCODTABELA ';
    LQuery.ParamByName('PCODTABELA').AsInteger := LConfiguracao.TabelaPrecoPadrao;
    LQuery.Open;
    while not LQuery.EOF do
    begin
      if TAppControl.AppFinalizando then
        break;

      LPreco := TPreco.Create;
      LPreco.ID := LQuery.FieldByName('PRE_TABELA').AsInteger.ToString + '.' +
        LQuery.FieldByName('PRE_PRODUTO').AsString;
      LPreco.ID_Movimento := LQuery.FieldByName('ID').AsString;
      LPreco.Referencia := LQuery.FieldByName('PRE_PRODUTO').AsString;
      LPreco.IDTabela := LQuery.FieldByName('PRE_TABELA').AsInteger;
      LPreco.Preco1 := LQuery.FieldByName('PRE_PRECO1').asFloat;
      LPreco.Preco2 := LQuery.FieldByName('PRE_PRECO2').asFloat;
      LPreco.TipoReg := LQuery.FieldByName('TIPO').AsString;
      Result.Add(LPreco);
      LQuery.Next;
    end;
  finally
    LConfiguracao.Free;
  end;

end;

end.
