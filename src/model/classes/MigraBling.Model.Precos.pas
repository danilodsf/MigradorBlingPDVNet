unit MigraBling.Model.Precos;

interface

uses
  MigraBling.Model.BaseModel;

type
  TPreco = class(TBaseModel)
  private
    FID: string;
    FReferencia: string;
    FIDTabela: integer;
    FPreco1: Double;
    FPreco2: Double;
    FTipoReg: string;
    FExcluido: Boolean;
  public
    property ID: string read FID write FID;
    property Referencia: string read FReferencia write FReferencia;
    property IDTabela: integer read FIDTabela write FIDTabela;
    property Preco1: Double read FPreco1 write FPreco1;
    property Preco2: Double read FPreco2 write FPreco2;
    property TipoReg: string read FTipoReg write FTipoReg;
    property Excluido: Boolean read FExcluido write FExcluido;
  end;

implementation

end.
