unit MigraBling.Model.Saldos;

interface

uses
  MigraBling.Model.BaseModel;

type
  TSaldo = class(TBaseModel)
  private
    FID: string;
    FProduto: string;
    FProduto_ID_Bling: string;
    FFilial: integer;
    FFilial_ID_Bling: string;
    FSaldo: Double;
    FTipoReg: string;
    FExcluido: Boolean;
    FDesconsiderarEstoque: Boolean;
  public
    property ID: string read FID write FID;
    property Produto: string read FProduto write FProduto;
    property Produto_ID_Bling: string read FProduto_ID_Bling write FProduto_ID_Bling;
    property Filial: integer read FFilial write FFilial;
    property Filial_ID_Bling: string read FFilial_ID_Bling write FFilial_ID_Bling;
    property Saldo: Double read FSaldo write FSaldo;
    property TipoReg: string read FTipoReg write FTipoReg;
    property Excluido: Boolean read FExcluido write FExcluido;
    property DesconsiderarEstoque: Boolean read FDesconsiderarEstoque write FDesconsiderarEstoque;
  end;

implementation

end.
