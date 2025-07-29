unit MigraBling.Model.MovimentoEstoque;

interface

type
  TMovimentoEstoque = class
  private
    FID: Int64;
    FID_Produto_Bling: Int64;
    FSaldoAnterior: Integer;
    FID_Filial: Int64;
    FOperacao: string;
    FQuantidade: integer;
    FData: TDateTime;
  public
    property ID: Int64 read FID write FID;
    property ID_Produto_Bling: Int64 read FID_Produto_Bling write FID_Produto_Bling;
    property SaldoAnterior: Integer read FSaldoAnterior write FSaldoAnterior;
    property ID_Filial_Bling: Int64 read FID_Filial write FID_Filial;
    property Operacao: string read FOperacao write FOperacao;
    property Quantidade: integer read FQuantidade write FQuantidade;
    property Data: TDateTime read FData write FData;
  end;

implementation

end.
