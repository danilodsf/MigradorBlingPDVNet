unit MigraBling.Model.QueryFiredac;

interface

uses
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  Data.DB,
  System.Classes,
  System.Generics.Collections,
  MigraBling.Model.Interfaces.QueryParam,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.QueryParamFireDAC;
type
  TQueryFireDAC = class(TInterfacedObject, IQuery)
  private
    FConexao: IConexao;
    FQuery: TFDQuery;
    FParams: TDictionary<string, IParam>;
    function GetSQL: TStrings;
    procedure SetSQL(AValue: TStrings);
    function GetIsEmpty: Boolean;
    function GetEOF: Boolean;
    function GetRecordCount: Integer;
    function GetConnection: IConexao;
    procedure SetArraySize(AValue: Integer);
  public
    constructor Create(AConnection: IConexao);
    destructor Destroy; override;

    procedure Close;
    procedure Open;
    procedure Next;
    procedure ExecSQL;
    procedure Execute(AValue: integer);

    property IsEmpty: Boolean read GetIsEmpty;
    property EOF: Boolean read GetEOF;
    property RecordCount: Integer read GetRecordCount;
    property ArraySize: Integer write SetArraySize;
    property Connection: IConexao read GetConnection;
    function FieldByName(AValue: string): TField;
    function ParamByName(AValue: string): IParam;
  end;

implementation

{ TQueryFireDAC }

procedure TQueryFireDAC.Close;
begin
  FQuery.Close;
end;

constructor TQueryFireDAC.Create(AConnection: IConexao);
begin
  FConexao := AConnection;
  FQuery := TFDQuery.Create(nil);
  FQuery.FetchOptions.Mode := fmAll;
  FQuery.Connection := AConnection.Instance as TFDConnection;
  FParams := TDictionary<string, IParam>.Create;
end;

destructor TQueryFireDAC.Destroy;
begin
  FParams.Free;
  FQuery.Free;
  inherited;
end;

procedure TQueryFireDAC.ExecSQL;
begin
  FQuery.ExecSQL;
end;

procedure TQueryFireDAC.Execute(AValue: integer);
begin
  FQuery.Execute(AValue);
end;

function TQueryFireDAC.FieldByName(AValue: string): TField;
begin
  Result := FQuery.FieldByName(AValue);
end;

function TQueryFireDAC.GetConnection: IConexao;
begin
  Result := FConexao;
end;

function TQueryFireDAC.GetEOF: Boolean;
begin
  Result := FQuery.Eof;
end;

function TQueryFireDAC.GetIsEmpty: Boolean;
begin
  Result := FQuery.IsEmpty;
end;

function TQueryFireDAC.GetRecordCount: Integer;
begin
  Result := FQuery.RecordCount;
end;

function TQueryFireDAC.GetSQL: TStrings;
begin
  Result := FQuery.SQL;
end;

procedure TQueryFireDAC.Next;
begin
  FQuery.Next;
end;

procedure TQueryFireDAC.Open;
begin
  FQuery.Open;
end;

function TQueryFireDAC.ParamByName(AValue: string): IParam;
begin
  if not FParams.TryGetValue(AValue, Result) then
  begin
    Result := TFDParamWrapper.Create(FQuery.ParamByName(AValue));
    FParams.Add(AValue, Result);
  end;
end;

procedure TQueryFireDAC.SetArraySize(AValue: Integer);
begin
  FQuery.Params.ArraySize := AValue;
end;

procedure TQueryFireDAC.SetSQL(AValue: TStrings);
begin
  FQuery.SQL := AValue;
end;

end.
