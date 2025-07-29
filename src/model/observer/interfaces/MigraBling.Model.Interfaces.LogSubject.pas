unit MigraBling.Model.Interfaces.LogSubject;

interface

uses
  MigraBling.Model.Interfaces.LogObserver;

type
  ILogSubject = interface
    ['{7B89873E-DCA3-420F-A7B2-97D1D6F5C1E6}']
    procedure RegisterObserver(AObserver: ILogObserver);
    procedure UnregisterObserver(AObserver: ILogObserver);
    procedure NotifyAll(const AValue: string);
  end;

implementation

end.
