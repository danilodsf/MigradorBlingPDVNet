unit MigraBling.Model.Interfaces.QueryFactory;

interface

uses
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.Conexao;

type
  IQueryFactory = interface
    ['{85A0D8BF-AE0E-46B3-8247-D5B32A35335F}']
    function GetQuery(AConexao: IConexao): IQuery;
  end;

implementation

end.
