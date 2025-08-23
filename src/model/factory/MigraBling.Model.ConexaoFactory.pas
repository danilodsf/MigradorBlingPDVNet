unit MigraBling.Model.ConexaoFactory;

interface

uses
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.ConexaoProvider,
  MigraBling.Model.Interfaces.ConexaoFactory;

type
  TConexaoFactory = class(TInterfacedObject, IConexaoFactory)
  public
    function GetConexao(AProvider: TDbProvider): IConexao;
    class function New: IConexaoFactory;
  end;

implementation

uses
  MigraBling.Model.ConexaoFiredac,
  MigraBling.Model.ConexaoADO;
{ TConexaoFactory }

function TConexaoFactory.GetConexao(AProvider: TDbProvider): IConexao;
begin
  case AProvider of
    dpFD: Result := TConexaoFireDAC.Create;
    dpADO: Result := TConexaoADO.Create;
  end;
end;

class function TConexaoFactory.New: IConexaoFactory;
begin
  Result := Self.Create;
end;

end.
