unit MigraBling.Model.Interfaces.Query;

interface

uses
  System.Classes,
  Data.DB,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.QueryParam;

type
  IQuery = interface
    ['{F88E2002-ECD5-4A4D-A4BB-1AA31CBD569A}']
    function GetSQL: TStrings;
    procedure SetSQL(AValue: TStrings);
    function GetIsEmpty: Boolean;
    function GetEOF: Boolean;
    function GetRecordCount: Integer;
    function GetConnection: IConexao;
    procedure SetArraySize(AValue: integer);

    procedure Close;
    procedure Open;
    procedure Next;
    procedure ExecSQL;
    procedure Execute(AValue: integer);

    property SQL: TStrings read GetSQL write SetSQL;
    property IsEmpty: Boolean read GetIsEmpty;
    property EOF: Boolean read GetEOF;
    property RecordCount: Integer read GetRecordCount;
    property ArraySize: Integer write SetArraySize;
    property Connection: IConexao read GetConnection;

    function FieldByName(AValue: string): TField;
    function ParamByName(AValue: string): IParam;
  end;

implementation

end.
