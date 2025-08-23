unit MigraBling.Model.Interfaces.QueryParamArraySource;

interface

type
  IArrayParamSource = interface
    ['{E9BBDACC-4117-4721-ADAA-D6B2881769CA}']
    function Count: Integer;
    function ValueAt(AIndex: Integer): Variant;
    procedure Clear;
    procedure EnsureSize(ASize: Integer);
  end;

implementation

end.
