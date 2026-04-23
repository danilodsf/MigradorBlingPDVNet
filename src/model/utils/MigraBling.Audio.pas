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
    class procedure ExibirAlerta(AMotivoNotificacao: string);
  public
    class procedure NotificarTokenExpirado;
    class procedure NotificarFalhaConexaoSQLServer;
    class procedure Parar;
  end;

implementation

class procedure TNotificador.ExibirAlerta(AMotivoNotificacao: string);
begin
  FForm := TFrmAlertaToken.Create(nil);
  try
    FForm.ShowModal;
  finally
    FreeAndNil(FForm);
  end;

  Parar;
end;

class procedure TNotificador.NotificarFalhaConexaoSQLServer;
begin
  TThread.Queue(nil,
    procedure
    begin
      ExibirAlerta('Não foi possível conectar ao PDVNET');
    end);
end;

class procedure TNotificador.NotificarTokenExpirado;
begin
  TThread.Queue(nil,
    procedure
    begin
      ExibirAlerta('O Token do Bling expirou'+sLineBreak+'É necessário refazer o login');
    end);
end;

class procedure TNotificador.Parar;
begin
  if Assigned(FForm) then
    FForm.ModalResult := mrOk;
end;

end.
