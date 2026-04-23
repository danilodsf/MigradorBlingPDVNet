unit MigraBling.View.AlertaToken;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Winapi.MMSystem;

type
  TFrmAlertaToken = class(TForm)
    Label1: TLabel;
    Panel1: TPanel;
    Button1: TButton;
    tmrNotifica: TTimer;
    procedure tmrNotificaTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    procedure Play;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmAlertaToken: TFrmAlertaToken;

implementation

{$R *.dfm}

procedure TFrmAlertaToken.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  tmrNotifica.Enabled := False;
  PlaySound(nil, 0, 0);
end;

procedure TFrmAlertaToken.FormShow(Sender: TObject);
begin
  tmrNotifica.Enabled := True;
  Play;
end;

procedure TFrmAlertaToken.Play;
var
  Caminho: string;
begin
  Caminho := ExtractFilePath(ParamStr(0)) + 'sons\alerta_token.wav';

  if FileExists(Caminho) then
    PlaySound(PChar(Caminho), 0, SND_FILENAME or SND_ASYNC);
end;

procedure TFrmAlertaToken.tmrNotificaTimer(Sender: TObject);
begin
  Play;
end;

end.
