unit MigraBling.Model.QueryParamFireDAC;

interface

uses
  MigraBling.Model.Interfaces.QueryParam, FireDAC.Stan.Param;

type
  TFDParamWrapper = class(TInterfacedObject, IParam)
  private
    FParam: TFDParam;
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
  public
    constructor Create(AParam: TFDParam);
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

procedure TFDParamWrapper.AsDateTimes(Index: Integer; AValue: TDateTime);
begin
  FParam.AsDateTimes[Index] := AValue;
end;

procedure TFDParamWrapper.AsFloats(Index: Integer; AValue: Double);
begin
  FParam.AsFloats[Index] := AValue;
end;

procedure TFDParamWrapper.AsIntegers(Index, AValue: Integer);
begin
  FParam.AsIntegers[Index] := AValue;
end;

procedure TFDParamWrapper.AsLargeInts(Index: Integer; AValue: Int64);
begin
  FParam.AsLargeInts[Index] := AValue;
end;

procedure TFDParamWrapper.AsStrings(Index: Integer; AValue: string);
begin
  FParam.AsStrings[Index] := AValue;
end;

constructor TFDParamWrapper.Create(AParam: TFDParam);
begin
  FParam := AParam;
end;

function TFDParamWrapper.GetAsDateTime: TDateTime;
begin
  Result := FParam.AsDateTime;
end;

function TFDParamWrapper.GetAsFloat: Double;
begin
  Result := FParam.AsFloat;
end;

function TFDParamWrapper.GetAsInteger: Integer;
begin
  Result := FParam.AsInteger;
end;

function TFDParamWrapper.GetAsLargeInt: Int64;
begin
  Result := FParam.AsLargeInt;
end;

function TFDParamWrapper.GetAsString: string;
begin
  Result := FParam.AsString;
end;

procedure TFDParamWrapper.SetAsDateTime(AValue: TDateTime);
begin
  FParam.AsDateTime := AValue;
end;

procedure TFDParamWrapper.SetAsFloat(AValue: Double);
begin
  FParam.AsFloat := AValue;
end;

procedure TFDParamWrapper.SetAsInteger(AValue: Integer);
begin
  FParam.AsInteger := AValue;
end;

procedure TFDParamWrapper.SetAsLargeInt(AValue: Int64);
begin
  FParam.AsLargeInt := AValue;
end;

procedure TFDParamWrapper.SetAsString(AValue: string);
begin
  FParam.AsString := AValue;
end;

end.
