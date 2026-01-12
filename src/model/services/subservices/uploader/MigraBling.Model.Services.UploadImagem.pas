unit MigraBling.Model.Services.UploadImagem;

interface

uses
  System.Classes,
  RESTRequest4D,
  System.JSON;

type
  TUploadImagem = class
  private
  public
    class function Subir(AReferencia: string; AStream: TStream): string;
  end;

const
  C_BASEURL_IMAGENS = 'https://samiraadm.com.br/uploads_api/api.php';

implementation

{ TUploadImagem }

class function TUploadImagem.Subir(AReferencia: string; AStream: TStream): string;
var
  Response: IResponse;
  Json: TJSONObject;
begin
  result := '';

  Response := TRequest.New.BaseURL(C_BASEURL_IMAGENS)
    .AddHeader('X-API-TOKEN', 'SINCRONIZADOR_9fA7Kx2QmP8LwR6C')
    .AddField('produto_id',AReferencia)
    .AddFile('file',AStream)
    .Post;

  if Response.StatusCode <> 200 then
    exit;

  Json := TJSONObject.ParseJSONValue(Response.Content) as TJSONObject;
  try
    Json.TryGetValue<string>('url', Result);
  finally
    Json.Free;
  end;
end;

end.
