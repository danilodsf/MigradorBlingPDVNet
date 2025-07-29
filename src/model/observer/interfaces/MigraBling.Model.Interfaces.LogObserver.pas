unit MigraBling.Model.Interfaces.LogObserver;

interface

type
  ILogObserver = interface
    ['{FBBC21E2-D379-483B-B223-919B4443BF3C}']
    procedure Notify(const AValue: string);
  end;

implementation

end.
