unit MigraBling.Model.QueryFactory;

interface

uses
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.QueryFactory,
  MigraBling.Model.QueryFiredac,
  MigraBling.Model.Interfaces.Conexao;

type
  TQueryFactory = class(TInterfacedObject, IQueryFactory)
  public
    function GetQuery(AConexao: IConexao): IQuery;
    class function New: IQueryFactory;
  end;

implementation

{ TQueryFactory }

function TQueryFactory.GetQuery(AConexao: IConexao): IQuery;
begin
  Result := TQueryFireDAC.Create(AConexao);
end;

class function TQueryFactory.New: IQueryFactory;
begin
  Result := Self.Create;
end;

end.
