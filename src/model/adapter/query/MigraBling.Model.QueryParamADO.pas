unit MigraBling.Model.QueryParamADO;

interface

uses
  MigraBling.Model.Interfaces.QueryParam,
  MigraBling.Model.Interfaces.QueryParamArraySource,
  Data.Win.ADODB, System.Generics.Collections, System.Variants;

type
  TADOParamWrapper = class(TInterfacedObject, IParam, IArrayParamSource)
  private
    FParam: TParameter;
    FArrayValues: TList<Variant>;
    function GetAsString: string;
    procedure SetAsString(AValue: string);
    function GetAsDateTime: TDateTime;
    procedure SetAsDateTime(AValue: TDateTime);
    function GetAsFloat: Double;
    procedure SetAsFloat(AValue: Double);
    function GetAsInteger: Integer;
    procedure SetAsInteger(AValue: Integer);
    function GetAsLargeInt: Int64;
    procedure SetAsLargeInt(AValue: Int64);
    function Count: Integer;
    function ValueAt(AIndex: Integer): Variant;
    procedure Clear;
  public
    constructor Create(AParam: TParameter);
    destructor Destroy; override;
    procedure EnsureSize(ASize: Integer);
    property AsString: string read GetAsString write SetAsString;
    property AsDateTime: TDateTime read GetAsDateTime write SetAsDateTime;
    property AsFloat: Double read GetAsFloat write SetAsFloat;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsLargeInt: Int64 read GetAsLargeInt write SetAsLargeInt;

    procedure AsStrings(Index: Integer; AValue: string);
    procedure AsDateTimes(Index: Integer; AValue: TDateTime);
    procedure AsFloats(Index: Integer; AValue: Double);
    procedure AsIntegers(Index: Integer; AValue: Integer);
    procedure AsLargeInts(Index: Integer; AValue: Int64);
  end;

implementation

{ TFDParam }

procedure TADOParamWrapper.AsDateTimes(Index: Integer; AValue: TDateTime);
begin
  EnsureSize(Index);
  FArrayValues[Index] := AValue;
end;

procedure TADOParamWrapper.AsFloats(Index: Integer; AValue: Double);
begin
  EnsureSize(Index);
  FArrayValues[Index] := AValue;
end;

procedure TADOParamWrapper.AsIntegers(Index, AValue: Integer);
begin
  EnsureSize(Index);
  FArrayValues[Index] := AValue;
end;

procedure TADOParamWrapper.AsLargeInts(Index: Integer; AValue: Int64);
begin
  EnsureSize(Index);
  FArrayValues[Index] := AValue;
end;

procedure TADOParamWrapper.AsStrings(Index: Integer; AValue: string);
begin
  EnsureSize(Index);
  FArrayValues[Index] := AValue;
end;

procedure TADOParamWrapper.Clear;
begin
  FArrayValues.Clear;
end;

function TADOParamWrapper.Count: Integer;
begin
  Result := FArrayValues.Count;
end;

constructor TADOParamWrapper.Create(AParam: TParameter);
begin
  inherited Create;
  FParam := AParam;
  FArrayValues := TList<Variant>.Create;
end;

destructor TADOParamWrapper.Destroy;
begin
  FArrayValues.Free;
  inherited;
end;

procedure TADOParamWrapper.EnsureSize(ASize: Integer);
begin
  if ASize <= 0 then Exit;
  while FArrayValues.Count < ASize do
    FArrayValues.Add(Null);
end;

function TADOParamWrapper.GetAsDateTime: TDateTime;
begin
  Result := VarToDateTime(FParam.Value);
end;

function TADOParamWrapper.GetAsFloat: Double;
begin
  Result := VarAsType(FParam.Value, varDouble);
end;

function TADOParamWrapper.GetAsInteger: Integer;
begin
  Result := VarAsType(FParam.Value, varInteger);
end;

function TADOParamWrapper.GetAsLargeInt: Int64;
begin
  Result := VarAsType(FParam.Value, varInt64);
end;

function TADOParamWrapper.GetAsString: string;
begin
  Result := VarToStr(FParam.Value);
end;

procedure TADOParamWrapper.SetAsDateTime(AValue: TDateTime);
begin
  FParam.Value := AValue;
end;

procedure TADOParamWrapper.SetAsFloat(AValue: Double);
begin
  FParam.Value := AValue;
end;

procedure TADOParamWrapper.SetAsInteger(AValue: Integer);
begin
  FParam.Value := AValue;
end;

procedure TADOParamWrapper.SetAsLargeInt(AValue: Int64);
begin
  FParam.Value := AValue;
end;

procedure TADOParamWrapper.SetAsString(AValue: string);
begin
  FParam.Value := AValue;
end;

function TADOParamWrapper.ValueAt(AIndex: Integer): Variant;
begin
  if (AIndex >= 0) and (AIndex < FArrayValues.Count) then
    Result := FArrayValues[AIndex]
  else
    Result := Null;
end;

end.
