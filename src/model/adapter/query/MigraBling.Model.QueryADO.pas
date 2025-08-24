unit MigraBling.Model.QueryADO;

interface

uses
  Data.DB,
  Data.Win.ADODB,
  System.Classes,
  System.Generics.Collections,
  MigraBling.Model.Interfaces.QueryParam,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.QueryParamFireDAC,
  MigraBling.Model.QueryParamADO,
  MigraBling.Model.Interfaces.QueryParamArraySource,
  System.SysUtils,
  System.Variants;

type
  TQueryADO = class(TInterfacedObject, IQuery)
  private
    FConexao: IConexao;
    FQuery: TADOQuery;
    FParams: TDictionary<string, IParam>;
    function GetSQL: TStrings;
    procedure SetSQL(AValue: TStrings);
    function GetIsEmpty: Boolean;
    function GetEOF: Boolean;
    function GetRecordCount: Integer;
    function GetConnection: IConexao;
    procedure SetArraySize(AValue: Integer);
    function MaxArrayCount: Integer;
  public
    constructor Create(AConnection: IConexao);
    destructor Destroy; override;

    procedure Close;
    procedure Open;
    procedure Next;
    procedure ExecSQL;
    procedure Execute(AValue: Integer);

    property IsEmpty: Boolean read GetIsEmpty;
    property EOF: Boolean read GetEOF;
    property RecordCount: Integer read GetRecordCount;
    property ArraySize: Integer write SetArraySize;
    property Connection: IConexao read GetConnection;
    function FieldByName(AValue: string): TField;
    function ParamByName(AValue: string): IParam;
  end;

implementation

{ TQueryADO }

procedure TQueryADO.Close;
begin
  FQuery.Close;
end;

constructor TQueryADO.Create(AConnection: IConexao);
begin
  FConexao := AConnection;
  FQuery := TADOQuery.Create(nil);
  FQuery.Connection := AConnection.Instance as TADOConnection;
  FParams := TDictionary<string, IParam>.Create;
end;

destructor TQueryADO.Destroy;
begin
  FParams.Free;
  FQuery.Free;
  inherited;
end;

procedure TQueryADO.ExecSQL;
begin
  FQuery.ExecSQL;
end;

function TQueryADO.MaxArrayCount: Integer;
var
  Pair: TPair<string, IParam>;
  Arr: IArrayParamSource;
begin
  Result := 0;
  for Pair in FParams do
    if Supports(Pair.Value, IArrayParamSource, Arr) then
      if Arr.Count > Result then
        Result := Arr.Count;
end;

procedure TQueryADO.Execute(AValue: Integer);
var
  Cmd: TADOCommand;
  i, j, BatchCount: Integer;
  P: TParameter;
  W: IArrayParamSource;
  Pair: TPair<string, IParam>;
  BaseValues: TDictionary<string, Variant>;
  V: Variant;
begin
  // 0) Determinar o tamanho do lote
  BatchCount := MaxArrayCount;
  if (BatchCount = 0) and (AValue > 0) then
    BatchCount := AValue;
  if BatchCount = 0 then
  begin
    // Não há lote: execute como ExecSQL normal
    FQuery.Prepared := True;
    FQuery.ExecSQL;
    Exit;
  end;

  // 1) Capturar valores escalares “de base” (param que não é array mantém o valor atual)
  BaseValues := TDictionary<string, Variant>.Create;
  try
    for j := 0 to FQuery.Parameters.Count - 1 do
    begin
      P := FQuery.Parameters[j];
      BaseValues.Add(P.Name, P.Value);
    end;

    // 2) Preparar o comando DML
    Cmd := TADOCommand.Create(nil);
    try
      Cmd.Connection := FQuery.Connection;
      Cmd.CommandType := cmdText;
      Cmd.CommandText := FQuery.SQL.Text;
      Cmd.Prepared := True;

      // Replica a coleção de parâmetros (estrutura e tipos)
      Cmd.Parameters.Assign(FQuery.Parameters);

      // 3) Transação + loop
      // Ajuste os nomes conforme sua IConexao (StartTransaction/Commit/Rollback)
      FConexao.StartTransaction;
      try
        for i := 0 to BatchCount - 1 do
        begin
          // Para cada parâmetro da query...
          for j := 0 to Cmd.Parameters.Count - 1 do
          begin
            P := Cmd.Parameters[j];

            // Tem wrapper registrado?
            if FParams.TryGetValue(P.Name, Pair.Value) and Supports(Pair.Value, IArrayParamSource,
              W) and (W.Count > 0) then
            begin
              // Pega o valor do índice i; se estourar, usa Null
              if i < W.Count then
                V := W.ValueAt(i)
              else
                V := Null;
            end
            else
            begin
              // Parâmetro escalar: reaproveita valor capturado
              if BaseValues.TryGetValue(P.Name, V) then
                { V já setado }
              else
                V := Null;
            end;

            P.Value := V;
          end;

          // Executa a volta
          Cmd.Execute;
        end;

        // Se tudo deu certo
        FConexao.Commit;
      except
        on E: Exception do
        begin
          FConexao.Rollback;
          raise;
        end;
      end;

      // 4) Limpa buffers dos wrappers (opcional)
      for Pair in FParams do
        if Supports(Pair.Value, IArrayParamSource, W) then
          W.Clear;

    finally
      Cmd.Free;
    end;

  finally
    BaseValues.Free;
  end;
end;

function TQueryADO.FieldByName(AValue: string): TField;
begin
  Result := FQuery.FieldByName(AValue);
end;

function TQueryADO.GetConnection: IConexao;
begin
  Result := FConexao;
end;

function TQueryADO.GetEOF: Boolean;
begin
  Result := FQuery.EOF;
end;

function TQueryADO.GetIsEmpty: Boolean;
begin
  Result := FQuery.IsEmpty;
end;

function TQueryADO.GetRecordCount: Integer;
begin
  Result := FQuery.RecordCount;
end;

function TQueryADO.GetSQL: TStrings;
begin
  Result := FQuery.SQL;
end;

procedure TQueryADO.Next;
begin
  FQuery.Next;
end;

procedure TQueryADO.Open;
begin
  FQuery.Open;
end;

function TQueryADO.ParamByName(AValue: string): IParam;
begin
  if not FParams.TryGetValue(AValue, Result) then
  begin
    Result := TADOParamWrapper.Create(FQuery.Parameters.ParamByName(AValue));
    FParams.Add(AValue, Result);
  end;
end;

procedure TQueryADO.SetArraySize(AValue: Integer);
var
  Pair: TPair<string, IParam>;
  Arr: IArrayParamSource;
begin
  // Em ADO não há ArraySize real; somente padronizamos o tamanho dos buffers
  for Pair in FParams do
    if Supports(Pair.Value, IArrayParamSource, Arr) then
      Arr.EnsureSize(AValue);
end;

procedure TQueryADO.SetSQL(AValue: TStrings);
begin
  FQuery.SQL := AValue;
end;

end.
