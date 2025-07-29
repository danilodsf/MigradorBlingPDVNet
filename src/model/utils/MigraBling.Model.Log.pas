unit MigraBling.Model.Log;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, System.SyncObjs, System.IOUtils,
  Winapi.Windows, System.DateUtils, MigraBling.Model.AppControl;

type
  TLog = class
  strict private
  const
    nomeArquivo = 'Log_MigraBling.txt';
    class var FInstance: TLog;
    class var logQueue: TQueue<string>;
    class var queueCS: TCriticalSection;
    class var logEvent: TEvent;
    class var logThread: TThread;
    class procedure StartLoggerThread;
    class procedure LoggerExecute;
  private
    class procedure encerrarThread(Sender: TObject);
  public
    class function GetInstance: TLog;
    class procedure ReleaseInstance;
    class procedure LimpaLog;
    procedure GravaInformacoes(const AMsg: string);
    procedure criaCopiaLog;
  end;

implementation

{ TLog }

class function TLog.GetInstance: TLog;
begin
  if not Assigned(FInstance) then
  begin
    FInstance := TLog.Create;
    logQueue := TQueue<string>.Create;
    queueCS := TCriticalSection.Create;
    logEvent := TEvent.Create(nil, False, False, '');
    StartLoggerThread;
  end;
  Result := FInstance;
end;

procedure TLog.GravaInformacoes(const AMsg: string);
var
  DataHora, Msg: string;
begin
  Msg := '';
  DataHora := FormatDateTime('dd/mm/yyyy hh:nn:ss', Now);
  if AMsg <> '' then
    Msg := Format('Thread:[%d] %s : %s', [TThread.CurrentThread.ThreadID, DataHora, AMsg]);

  queueCS.Enter;
  try
    logQueue.Enqueue(Msg);
    logEvent.SetEvent;
  finally
    queueCS.Leave;
  end;
end;

class procedure TLog.StartLoggerThread;
begin
  logThread := TThread.CreateAnonymousThread(
    procedure
    begin
      TAppControl.RegisterThread(logThread);
      LoggerExecute;
    end);
  logThread.FreeOnTerminate := False;
  logThread.OnTerminate := encerrarThread;
  logThread.Start;
end;

class procedure TLog.encerrarThread(Sender: TObject);
begin
  TAppControl.UnregisterThread(logThread);
end;

class procedure TLog.LoggerExecute;
var
  LogFile: string;
  Msg: string;
begin
  LogFile := TPath.Combine(ExtractFilePath(ParamStr(0)), nomeArquivo);

  while True and not(TAppControl.AppFinalizando) do
  begin
    if logEvent.WaitFor(500) = wrTimeout then
      Continue;

    while True and not(TAppControl.AppFinalizando) do
    begin
      queueCS.Enter;
      try
        if logQueue.Count = 0 then
          Break;
        Msg := logQueue.Dequeue;
      finally
        queueCS.Leave;
      end;

      while True do
      begin
        try
          if Msg <> '' then
            TFile.AppendAllText(LogFile, Msg + sLineBreak, TEncoding.UTF8)
          else
            TFile.WriteAllText(LogFile, '', TEncoding.UTF8);

          Break;
        except
          Sleep(3000);
        end
      end
    end;
  end;
end;

procedure TLog.criaCopiaLog;
var
  Data: string;
  Caminho, Origem, Destino: string;
  fs: TFormatSettings;
begin
  fs := TFormatSettings.Create;
  DateTimeToString(Data, 'dd-mm-yyyy-hh-nn-ss', Now, fs);

  Caminho := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)) + 'Logs');
  if not DirectoryExists(Caminho) then
    ForceDirectories(Caminho);

  Origem := TPath.Combine(ExtractFilePath(ParamStr(0)), nomeArquivo);
  Destino := Caminho + Data + '_' + nomeArquivo;

  if FileExists(Origem) then
    CopyFile(PChar(Origem), PChar(Destino), False);
end;

class procedure TLog.LimpaLog;
begin
  TLog.GetInstance.GravaInformacoes('');
end;

class procedure TLog.ReleaseInstance;
begin
  if Assigned(FInstance) then
  begin
    logThread.Terminate;
    logEvent.SetEvent;
    logThread.WaitFor;

    logQueue.Free;
    queueCS.Free;
    logEvent.Free;
    logThread.Free;
    FInstance.Free;
  end;
end;

initialization

finalization

TLog.ReleaseInstance;

end.
