unit MigraBling.Model.Variacoes;

interface

uses
  MigraBling.Model.BaseModel;

type
  TVariacao = class(TBaseModel)
  private
    FID: string;
    FReferencia: string;
    FDescricao: string;
    FCor: integer;
    FCorStr: string;
    FCor_ID_Bling: string;
    FCor_Vinculo: string;
    FTamanho: integer;
    FTamanhoStr: string;
    FTamanho_ID_Bling: string;
    FTamanho_Vinculo: string;
    FPreco: Currency;
    FInativo: boolean;
    FTipoReg: string;
    FExcluido: Boolean;
    FExibir: boolean;
  public
    property ID: string read FID write FID;
    property Referencia: string read FReferencia write FReferencia;
    property Descricao: string read FDescricao write FDescricao;
    property Cor: integer read FCor write FCor;
    property CorStr: string read FCorStr write FCorStr;
    property Cor_ID_Bling: string read FCor_ID_Bling write FCor_ID_Bling;
    property Cor_Vinculo: string read FCor_Vinculo write FCor_Vinculo;
    property Tamanho: integer read FTamanho write FTamanho;
    property TamanhoStr: string read FTamanhoStr write FTamanhoStr;
    property Tamanho_ID_Bling: string read FTamanho_ID_Bling write FTamanho_ID_Bling;
    property Tamanho_Vinculo: string read FTamanho_Vinculo write FTamanho_Vinculo;
    property Preco: Currency read FPreco write FPreco;
    property Inativo: boolean read FInativo write FInativo;
    property TipoReg: string read FTipoReg write FTipoReg;
    property Excluido: Boolean read FExcluido write FExcluido;
    property Exibir: Boolean read FExibir write FExibir;
  end;

implementation

end.
