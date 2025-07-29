unit MigraBling.Model.ConexaoFactory;

interface

uses
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.ConexaoFactory;

type
  TConexaoFactory = class(TInterfacedObject, IConexaoFactory)
  public
    function GetConexao: IConexao;
    class function New: IConexaoFactory;
  end;

implementation

uses
  MigraBling.Model.ConexaoFiredac;

{ TConexaoFactory }

function TConexaoFactory.GetConexao: IConexao;
begin
  Result := TConexaoFireDAC.Create;
end;

class function TConexaoFactory.New: IConexaoFactory;
begin
  Result := Self.Create;
end;

end.
