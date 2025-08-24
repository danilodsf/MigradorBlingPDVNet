unit MigraBling.Model.Interfaces.ConexaoFactory;

interface

uses
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.ConexaoProvider;

type
  IConexaoFactory = interface
    ['{23C36203-1A70-4283-97D6-1E739E3A6FF6}']

    function GetConexao(AProvider: TDbProvider): IConexao;
  end;

implementation

end.
