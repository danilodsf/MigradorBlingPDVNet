unit MigraBling.Model.MapaEntidades;

interface

type
  TMapaEntidade = class
  private
    FTabela: string;
    FDescricao: string;
  public
    property Tabela: string read FTabela write FTabela;
    property Descricao: string read FDescricao write FDescricao;
  end;

implementation

end.
