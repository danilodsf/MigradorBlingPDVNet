unit MigraBling.Model.Services.Interfaces.Sincronizador;

interface

uses
  MigraBling.Model.Services.SubServices.Interfaces.PDVNET,
  MigraBling.Model.Services.SubServices.Interfaces.Bling,
  MigraBling.Model.Services.SubServices.Interfaces.SQLite;

type
  ISincronizador = interface
    ['{F670F750-F494-4615-AFD7-CEE92807DCB9}']

    function GetBling: IBlingService;
    function GetPDVNET: IPDVNETService;
    function GetSQLite: ISQLiteService;

    property Bling: IBlingService read GetBling;
    property PDVNET: IPDVNETService read GetPDVNET;
    property SQLite: ISQLiteService read GetSQLite;
  end;

implementation

end.
