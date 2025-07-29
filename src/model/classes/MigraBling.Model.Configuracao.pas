unit MigraBling.Model.Configuracao;

interface

uses
  System.Generics.Collections;

type
  TConfiguracao = class
  private
    FAccessToken: string;
    FRefreshToken: string;
    FExpiresIn: TDateTime;
    FClientID: string;
    FClientSecret: string;
    FPDVNET_Server: string;
    FPDVNET_Database: string;
    FPDVNET_UserName: string;
    FPDVNET_Password: string;
    FTempoSincronizacao: integer;
    FQtdEstoqueSubtrair: integer;
    FAtivar: Boolean;
    FDataUltimaConsultaHookDeck: TDateTime;
    FTabelaPrecoPadrao: integer;
    FPastaBackup: string;
  public
    property AccessToken: string read FAccessToken write FAccessToken;
    property RefreshToken: string read FRefreshToken write FRefreshToken;
    property ExpiresIn: TDateTime read FExpiresIn write FExpiresIn;
    property ClientID: string read FClientID write FClientID;
    property ClientSecret: string read FClientSecret write FClientSecret;
    property PDVNET_Server: string read FPDVNET_Server write FPDVNET_Server;
    property PDVNET_Database: string read FPDVNET_Database write FPDVNET_Database;
    property PDVNET_UserName: string read FPDVNET_UserName write FPDVNET_UserName;
    property PDVNET_Password: string read FPDVNET_Password write FPDVNET_Password;
    property TempoSincronizacao: integer read FTempoSincronizacao write FTempoSincronizacao;
    property QtdEstoqueSubtrair: integer read FQtdEstoqueSubtrair write FQtdEstoqueSubtrair;
    property Ativar: Boolean read FAtivar write FAtivar;
    property DataUltimaConsultaHookDeck: TDateTime read FDataUltimaConsultaHookDeck
      write FDataUltimaConsultaHookDeck;
    property TabelaPrecoPadrao: integer read FTabelaPrecoPadrao write FTabelaPrecoPadrao;
    property PastaBackup: string read FPastaBackup write FPastaBackup;
  end;

implementation

end.
