unit MigraBling.Model.Cores;

interface

uses
  MigraBling.Model.BaseModel;

type
  TCor = class(TBaseModel)
  private
    FID: integer;
    FDescricao: string;
    FInativo: Boolean;
    FTipoReg: string;
    FExcluido: Boolean;
  public
    property ID: integer read FID write FID;
    property Descricao: string read FDescricao write FDescricao;
    property Inativo: Boolean read FInativo write FInativo;
    property TipoReg: string read FTipoReg write FTipoReg;
    property Excluido: Boolean read FExcluido write FExcluido;
  end;

implementation

end.
