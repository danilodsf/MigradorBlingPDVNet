unit MigraBling.Audio;

interface

uses
  System.SysUtils,
  System.Classes,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  System.UITypes,
  MigraBling.View.AlertaToken;

type
  TNotificador = class
  private
    class var FForm: TFrmAlertaToken;
    class procedure ExibirAlerta;
  public
    class procedure Notificar;
    class procedure Parar;
  end;

implementation

class procedure TNotificador.ExibirAlerta;
begin
  FForm := TFrmAlertaToken.Create(nil);
  try
    FForm.ShowModal;
  finally
    FreeAndNil(FForm);
  end;

  Parar;
end;

class procedure TNotificador.Notificar;
begin
  TThread.Queue(nil,
    procedure
    begin
      ExibirAlerta;
    end);
end;

class procedure TNotificador.Parar;
begin
  if Assigned(FForm) then
    FForm.ModalResult := mrOk;
end;

end.
