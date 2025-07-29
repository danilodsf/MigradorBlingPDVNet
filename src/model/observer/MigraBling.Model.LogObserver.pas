unit MigraBling.Model.LogObserver;

interface

uses
  MigraBling.Model.Interfaces.LogObserver,
  MigraBling.Model.Interfaces.LogSubject,
  System.Generics.Collections, System.Classes;

type
  TLogSubject = class(TInterfacedObject, ILogSubject)
  private
    FObservers: TList<ILogObserver>;
    class var FInstance: ILogSubject;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterObserver(AObserver: ILogObserver);
    procedure UnregisterObserver(AObserver: ILogObserver);
    procedure NotifyAll(const AValue: string);
    class function GetInstance: ILogSubject;
  end;

implementation

{ TLogSubject }

constructor TLogSubject.Create;
begin
  FObservers := TList<ILogObserver>.Create;
end;

destructor TLogSubject.Destroy;
begin
  FObservers.Free;
  inherited;
end;

class function TLogSubject.GetInstance: ILogSubject;
begin
  if not Assigned(FInstance) then
    FInstance := TLogSubject.Create;

  Result := FInstance;
end;

procedure TLogSubject.NotifyAll(const AValue: string);
begin
  TThread.Queue(nil,
    procedure
    var
      Obs: ILogObserver;
    begin
      for Obs in FObservers do
        Obs.Notify(AValue);
    end);
end;

procedure TLogSubject.RegisterObserver(AObserver: ILogObserver);
begin
  if not FObservers.Contains(AObserver) then
    FObservers.Add(AObserver);
end;

procedure TLogSubject.UnregisterObserver(AObserver: ILogObserver);
begin
  FObservers.Remove(AObserver);
end;

end.
