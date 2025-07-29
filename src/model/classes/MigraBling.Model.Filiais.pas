unit MigraBling.Model.Filiais;

interface

uses
  MigraBling.Model.BaseModel;

type
  TFilial = class(TBaseModel)
  private
    FID: integer;
    FDescricao: string;
    FInativo: Boolean;
    FTipoReg: string;
    FExcluido: Boolean;
    FDesconsiderarEstoque: Boolean;
  public
    property ID: integer read FID write FID;
    property Descricao: string read FDescricao write FDescricao;
    property Inativo: Boolean read FInativo write FInativo;
    property TipoReg: string read FTipoReg write FTipoReg;
    property Excluido: Boolean read FExcluido write FExcluido;
    property DesconsiderarEstoque: Boolean read FDesconsiderarEstoque write FDesconsiderarEstoque;
  end;

implementation

end.
