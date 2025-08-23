unit MigraBling.Model.Interfaces.QueryParam;

interface

type
  IParam = interface
    ['{4BE53A41-AA00-4676-93D2-BE947A31CACA}']
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

end.
