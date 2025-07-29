unit MigraBling.Model.Services.SubServices.PDVNET.DAOMovimentos;

interface

uses
  MigraBling.Model.Movimentos,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.QueryFactory,
  System.Generics.Collections,
  System.SysUtils,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Utils, MigraBling.Model.AppControl;

type
  TDAOMovimentosPDVNET = class(TInterfacedObject, IDAOMovimentosPDVNET<TMovimento>)
  private
    FConexao: IConexao;
  public
    function Ler: TObjectList<TMovimento>; overload;
    constructor Create(AConexao: IConexao);
    destructor Destroy; override;
  end;

implementation

{ TDAOMovimentosPDVNET }

constructor TDAOMovimentosPDVNET.Create(AConexao: IConexao);
begin
  FConexao := AConexao;
end;

destructor TDAOMovimentosPDVNET.Destroy;
begin
  inherited;
end;

function TDAOMovimentosPDVNET.Ler: TObjectList<TMovimento>;
var
  LMovimento: TMovimento;
  LQuery: IQuery;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);

  Result := TObjectList<TMovimento>.Create;
  LQuery.Close;
  LQuery.SQL.Text := 'SELECT ID, ID_REG, TABELA, TIPO, DATA FROM MOVIMENTOS_MIGRAR_BLING ';
  LQuery.Open;
  while not LQuery.EOF do
  begin
    if TAppControl.AppFinalizando then
      break;

    LMovimento := TMovimento.Create;
    LMovimento.ID := LQuery.FieldByName('ID').AsInteger;
    LMovimento.ID_Reg := LQuery.FieldByName('ID_REG').AsString.Trim;
    LMovimento.Tabela := LQuery.FieldByName('TABELA').AsString;
    LMovimento.Tipo := LQuery.FieldByName('TIPO').AsString;
    LMovimento.Data := StrToDateTime(LQuery.FieldByName('DATA').AsString);
    Result.Add(LMovimento);
    LQuery.Next;
  end;
end;

end.
