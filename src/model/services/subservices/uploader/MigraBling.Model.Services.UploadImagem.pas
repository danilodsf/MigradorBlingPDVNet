unit MigraBling.Model.Services.UploadImagem;

interface

uses
  System.Classes,
  RESTRequest4D,
  StrUtils,
  SysUtils,
  System.JSON;

type
  TUploadImagem = class
  private
  public
    class function Subir(AReferencia: string; AStream: TStream; ASeq: integer): string;
  end;

implementation

{ TUploadImagem }

class function TUploadImagem.Subir(AReferencia: string; AStream: TStream; ASeq: integer): string;
var
  Response: IResponse;
  JSON: TJSONObject;
  LURL, LToken: string;
begin
  result := '';

  LURL := GetEnvironmentVariable('UPLOAD_API_URL');
  if LURL.IsEmpty then
    Exit;

  LToken := GetEnvironmentVariable('UPLOAD_API_TOKEN');
  if LToken.IsEmpty then
    Exit;

  if ASeq > 1 then
    AReferencia := AReferencia + '_' + ASeq.ToString;

  Response := TRequest.New.BaseURL(LURL).AddHeader('X-API-TOKEN', LToken)
    .AddField('produto_id', AReferencia).AddFile('file', AStream).Post;

  if Response.StatusCode <> 200 then
    exit;

  JSON := TJSONObject.ParseJSONValue(Response.Content) as TJSONObject;
  if not Assigned(JSON) then
    Exit;
  try
    JSON.TryGetValue<string>('url', result);
  finally
    JSON.Free;
  end;
end;

end.
