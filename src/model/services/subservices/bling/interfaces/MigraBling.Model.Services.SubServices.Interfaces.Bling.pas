unit MigraBling.Model.Services.SubServices.Interfaces.Bling;

interface

uses
  MigraBling.Model.Services.SubServices.Interfaces.RegistrosMovimentados;

type
  IBlingService = interface
    ['{7F0D774D-E954-4F92-B068-78F3A727513A}']
    procedure GravarMovimentosDeCadastros(AValue: IRegistrosMovimentados);
    procedure GravarMovimentosDeProdutos(AValue: IRegistrosMovimentados);
    procedure LimparProdutos;
  end;

implementation

end.
