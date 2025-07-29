unit MigraBling.Model.AppControl;

interface

uses
  System.Classes, System.SyncObjs, System.Generics.Collections, System.Threading,
  System.SysUtils;

type
  TAppControl = class
  private
    class var FThreadList: TList<TThread>;
    class var FTaskList: TList<ITask>;
    class var FCriticalSection: TCriticalSection;
    class var FAppFinalizando: Boolean;
  public
    class constructor Create;
    class destructor Destroy;

    class procedure RegisterThread(AThread: TThread);
    class procedure UnregisterThread(AThread: TThread);

    class procedure RegisterTask(ATask: ITask);
    class procedure UnregisterTask(ATask: ITask);

    class procedure FinalizarTodasAsync(TimeoutMs: Integer = 5000);
    class function SafeTask(const Proc: TProc): ITask;

    class property AppFinalizando: Boolean read FAppFinalizando;
  end;

implementation

uses
  System.DateUtils;

class constructor TAppControl.Create;
begin
  FCriticalSection := TCriticalSection.Create;
  FThreadList := TList<TThread>.Create;
  FTaskList := TList<ITask>.Create;
end;

class destructor TAppControl.Destroy;
begin
  //FinalizarTodasAsync;
  FThreadList.Free;
  FTaskList.Free;
  FCriticalSection.Free;
end;

class procedure TAppControl.RegisterThread(AThread: TThread);
begin
  FCriticalSection.Acquire;
  try
    if not FThreadList.Contains(AThread) then
      FThreadList.Add(AThread);
  finally
    FCriticalSection.Release;
  end;
end;

class procedure TAppControl.UnregisterThread(AThread: TThread);
begin
  FCriticalSection.Acquire;
  try
    FThreadList.Remove(AThread);
  finally
    FCriticalSection.Release;
  end;
end;

class procedure TAppControl.RegisterTask(ATask: ITask);
begin
  FCriticalSection.Acquire;
  try
    if not FTaskList.Contains(ATask) then
      FTaskList.Add(ATask);
  finally
    FCriticalSection.Release;
  end;
end;

class procedure TAppControl.UnregisterTask(ATask: ITask);
begin
  FCriticalSection.Acquire;
  try
    FTaskList.Remove(ATask);
  finally
    FCriticalSection.Release;
  end;
end;

class procedure TAppControl.FinalizarTodasAsync(TimeoutMs: Integer);
var
  Thread: TThread;
  StartTime: TDateTime;
  i: Integer;
begin
  FAppFinalizando := True;

  FCriticalSection.Acquire;

  if (FTaskList.Count = 0) and (FThreadList.Count = 0) then
    Exit;

  try
    for Thread in FThreadList do
      if Assigned(Thread) then
        Thread.Terminate;
  finally
    FCriticalSection.Release;
  end;

  StartTime := Now;
  repeat
    FCriticalSection.Acquire;
    try
      i := FTaskList.Count - 1;
      while i >= 0 do
      begin
        if FTaskList[i].Status in [TTaskStatus.Completed, TTaskStatus.Canceled, TTaskStatus.Exception] then
          FTaskList.Delete(i);
        Dec(i);
      end;

      i := FThreadList.Count - 1;
      while i >= 0 do
      begin
        if FThreadList[i].Finished then
          FThreadList.Delete(i);
        Dec(i);
      end;

      if (FTaskList.Count = 0) and (FThreadList.Count = 0) then
        Break;
    finally
      FCriticalSection.Release;
    end;

    Sleep(100);
  until MilliSecondsBetween(Now, StartTime) > TimeoutMs;
end;

class function TAppControl.SafeTask(const Proc: TProc): ITask;
var
  T: ITask;
begin
  T := TTask.Run(
    procedure
    begin
      try
        if TAppControl.AppFinalizando then Exit;
        Proc();
      finally
        TAppControl.UnregisterTask(TTask.CurrentTask);
      end;
    end
  );
  TAppControl.RegisterTask(T);
  Result := T;
end;

end.
