unit MigraBling.Model.Interfaces.Conexao;

interface

uses
  Data.DB,
  System.Classes;

type
  IConexao = interface
    ['{9264F212-4DE0-41EC-8273-4C70FAEC2D35}']

  function GetParams: TStrings;
  procedure SetParams(AValue: TStrings);
  function GetConnected: Boolean;
  procedure SetConnected(AValue: Boolean);
  function GetInstance: TCustomConnection;
  function GetBaseConectada: string;
  procedure SetBaseConectada(AValue: string);

  property Params: TStrings read GetParams write SetParams;
  property Connected: Boolean read GetConnected write SetConnected;
  property Instance: TCustomConnection read GetInstance;
  property BaseConectada: string read GetBaseConectada write SetBaseConectada;

  procedure Open;
  procedure StartTransaction;
  procedure Commit;
  procedure Rollback;
  procedure DoBackup(ACaminhoBackup: string);

  function Clone: IConexao;

  end;

implementation

end.
