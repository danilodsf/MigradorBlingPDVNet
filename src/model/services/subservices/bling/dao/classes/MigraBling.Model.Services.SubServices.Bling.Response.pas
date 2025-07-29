unit MigraBling.Model.Services.SubServices.Bling.Response;

interface

uses
  REST.Json.Types, System.SysUtils;

type
  TErrorDetails = class;
  TErrorFields = class;

  TResponseError = class
  private
    [JSONOwned]
    Ferror: TErrorDetails;
    function GetAllErrors: string;
  public
    property error: TErrorDetails read Ferror;
    property allErrors: string read GetAllErrors;
    destructor Destroy; override;
  end;

  TErrorDetails = class
  private
    Ffields: TArray<TErrorFields>;
    Fmessage: string;
    Fdescription: string;
    Ftype: string;
  public
    [JSONName('type')]
    property &type: string read Ftype write Ftype;
    [JSONName('message')]
    property &message: string read Fmessage write Fmessage;
    property description: string read Fdescription write Fdescription;
    property fields: TArray<TErrorFields> read Ffields write Ffields;
    constructor Create;
    destructor Destroy; override;
  end;

  TErrorFields = class
  private
    Fcode: string;
    Fmsg: string;
    Fnamespace: string;
    Felement: string;
  public
    property code: string read Fcode write Fcode;
    property msg: string read Fmsg write Fmsg;
    property element: string read Felement write Felement;
    property namespace: string read Fnamespace write Fnamespace;
  end;

implementation

{ TResponseError }

destructor TResponseError.Destroy;
begin
  Ferror.Free;
  inherited;
end;

function TResponseError.GetAllErrors: string;
var
  errorField: TErrorFields;
begin
  result := '';
  if Assigned(Ferror) then
    for errorField in error.Ffields do
      result := result + errorField.Fmsg + sLineBreak;

  result := result.Trim;
end;

{ TErrorDetails }

constructor TErrorDetails.Create;
begin
  Ffields := [];
end;

destructor TErrorDetails.Destroy;
var
  errorField: TErrorFields;
begin
  for errorField in Ffields do
    FreeAndNil(errorField);

  inherited;
end;

end.
