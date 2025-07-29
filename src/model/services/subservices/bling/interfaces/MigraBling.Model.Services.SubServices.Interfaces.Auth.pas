unit MigraBling.Model.Services.SubServices.Interfaces.Auth;

interface

uses
  RESTRequest4D.Request.Contract, RESTRequest4D;

type
  IModelAuth = interface
    ['{C56B1ACC-F44F-4CF7-8AE5-9D8A68647046}']
    function GetAccessToken: string;
    property AccessToken: string read GetAccessToken;
    procedure AtualizarToken(const Req: IRequest; const Res: IResponse);
  end;

implementation

end.
