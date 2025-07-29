unit MigraBling.Model.Services.Sincronizador;

interface

uses
  Rest.Types,
  System.NetEncoding,
  MigraBling.Model.Utils,
  MigraBling.Model.Services.SubServices.SQLite,
  MigraBling.Model.Services.SubServices.PDVNET,
  MigraBling.Model.Services.SubServices.Bling,
  MigraBling.Model.Services.SubServices.Interfaces.SQLite,
  MigraBling.Model.Services.SubServices.Interfaces.PDVNET,
  MigraBling.Model.Services.SubServices.Interfaces.Bling,
  MigraBling.Model.Services.Interfaces.Sincronizador;

type
  TSincronizador = class(TInterfacedObject, ISincronizador)
  private
    FSQLite: ISQLiteService;
    FBling: IBlingService;
    FPDVNET: IPDVNETService;
    function GetBling: IBlingService;
    function GetPDVNET: IPDVNETService;
    function GetSQLite: ISQLiteService;
  public
    property Bling: IBlingService read GetBling;
    property PDVNET: IPDVNETService read GetPDVNET;
    property SQLite: ISQLiteService read GetSQLite;

    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  MigraBling.Model.Services.SubServices.Bling.Auth,  System.SysUtils;

{ TSincronizador }

constructor TSincronizador.Create;
begin
  FSQLite := TSQLite.Create;
  FBling := TBlingService.Create(TModelAuth.Create(FSQLite));
  FPDVNET := TPDVNetService.Create(FSQLite);
end;

destructor TSincronizador.Destroy;
begin
  inherited;
end;

function TSincronizador.GetBling: IBlingService;
begin
  Result := FBling;
end;

function TSincronizador.GetSQLite: ISQLiteService;
begin
  Result := FSQLite;
end;

function TSincronizador.GetPDVNET: IPDVNETService;
begin
  Result := FPDVNET;
end;

end.
