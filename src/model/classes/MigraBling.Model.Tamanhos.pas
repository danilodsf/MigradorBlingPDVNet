unit MigraBling.Model.Tamanhos;

interface

uses
  MigraBling.Model.BaseModel;

type
  TTamanho = class(TBaseModel)
  private
    FID: integer;
    FDescricao: string;
    FOrdem: integer;
    FInativo: Boolean;
    FTipoReg: string;
    FExcluido: Boolean;
  public
    property ID: integer read FID write FID;
    property Descricao: string read FDescricao write FDescricao;
    property Ordem: integer read FOrdem write FOrdem;
    property Inativo: Boolean read FInativo write FInativo;
    property TipoReg: string read FTipoReg write FTipoReg;
    property Excluido: Boolean read FExcluido write FExcluido;
  end;

implementation

end.
