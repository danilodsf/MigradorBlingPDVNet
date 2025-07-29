unit MigraBling.Model.Services.SubServices.Interfaces.PDVNET;

interface

uses
  MigraBling.Model.Services.SubServices.PDVNET.DAOCategorias,
  MigraBling.Model.Interfaces.DAO, MigraBling.Model.Categorias,
  MigraBling.Model.Services.SubServices.Interfaces.RegistrosMovimentados,
  System.Generics.Collections;

type
  IPDVNETService = interface
    ['{1EDADF6A-34EA-4BC3-ADF9-63A426E5CD99}']
    function GetBancoConfigurado: Boolean;
    function GetBuscarMovimentos: IRegistrosMovimentados;
    function TestarConexaoSQLServer: Boolean;
    property BancoConfigurado: Boolean read GetBancoConfigurado;
    procedure CriarEstruturaSincronizacao;
    property BuscarMovimentos: IRegistrosMovimentados read GetBuscarMovimentos;
    procedure LimparMovimentos(AValue: IRegistrosMovimentados);
    procedure DestruirObjetos;
    function BuscarFiliais: TDictionary<integer, string>;
    function BuscarTabelasDePreco: TOrderedDictionary<integer, string>;
  end;

implementation

end.
