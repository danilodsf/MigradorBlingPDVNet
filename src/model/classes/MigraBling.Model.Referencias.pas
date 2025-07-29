unit MigraBling.Model.Referencias;

interface

uses
  System.Generics.Collections,
  MigraBling.Model.BaseModel,
  MigraBling.Model.Variacoes;

type
  TReferencia = class(TBaseModel)
  private
    FReferencia: string;
    FNome: string;
    FDescricao: string;
    FDescricao_Complementar: string;
    FPeso: Double;
    FAltura: Double;
    FLargura: Double;
    FProfundidade: Double;
    FSite: Boolean;
    FTemAoMenosUmaVariacaoValida: Boolean;

    FGrupo: string;
    FGrupo_ID_Bling: string;
    FGrupo_Campo: string;
    FGrupo_Vinculo: string;

    FDepartamento: string;
    FDepartamento_ID_Bling: string;
    FDepartamento_Campo: string;
    FDepartamento_Vinculo: string;

    FMaterial: string;
    FMaterial_ID_Bling: string;
    FMaterial_Campo: string;
    FMaterial_Vinculo: string;

    FColecao: string;
    FColecao_ID_Bling: string;
    FColecao_Campo: string;
    FColecao_Vinculo: string;

    FCategoria: string;
    FCategoria_ID_Bling: string;
    FCategoria_Campo: string;
    FCategoria_Vinculo: string;

    FCor: string;
    FCor_ID_Bling: string;
    FCor_Campo: string;
    FCor_Vinculo: string;

    FTamanho: string;
    FTamanho_ID_Bling: string;
    FTamanho_Campo: string;
    FTamanho_Vinculo: string;

    FVariacoes: TObjectList<TVariacao>;

    FNCM: string;
    FUnidade: string;
    FExibir: Boolean;
    FInativo: Boolean;
    FTipoReg: string;
    FExcluido: Boolean;
  public
    property Referencia: string read FReferencia write FReferencia;
    property Nome: string read FNome write FNome;
    property Descricao: string read FDescricao write FDescricao;
    property Descricao_Complementar: string read FDescricao_Complementar
      write FDescricao_Complementar;
    property Peso: Double read FPeso write FPeso;
    property Altura: Double read FAltura write FAltura;
    property Largura: Double read FLargura write FLargura;
    property Profundidade: Double read FProfundidade write FProfundidade;
    property Site: Boolean read FSite write FSite;
    property TemAoMenosUmaVariacaoValida: Boolean read FTemAoMenosUmaVariacaoValida
      write FTemAoMenosUmaVariacaoValida;

    property Grupo: string read FGrupo write FGrupo;
    property Grupo_ID_Bling: string read FGrupo_ID_Bling write FGrupo_ID_Bling;
    property Grupo_Campo: string read FGrupo_Campo write FGrupo_Campo;
    property Grupo_Vinculo: string read FGrupo_Vinculo write FGrupo_Vinculo;

    property Departamento: string read FDepartamento write FDepartamento;
    property Departamento_ID_Bling: string read FDepartamento_ID_Bling write FDepartamento_ID_Bling;
    property Departamento_Campo: string read FDepartamento_Campo write FDepartamento_Campo;
    property Departamento_Vinculo: string read FDepartamento_Vinculo write FDepartamento_Vinculo;

    property Material: string read FMaterial write FMaterial;
    property Material_ID_Bling: string read FMaterial_ID_Bling write FMaterial_ID_Bling;
    property Material_Campo: string read FMaterial_Campo write FMaterial_Campo;
    property Material_Vinculo: string read FMaterial_Vinculo write FMaterial_Vinculo;

    property Colecao: string read FColecao write FColecao;
    property Colecao_ID_Bling: string read FColecao_ID_Bling write FColecao_ID_Bling;
    property Colecao_Campo: string read FColecao_Campo write FColecao_Campo;
    property Colecao_Vinculo: string read FColecao_Vinculo write FColecao_Vinculo;

    property Categoria: string read FCategoria write FCategoria;
    property Categoria_ID_Bling: string read FCategoria_ID_Bling write FCategoria_ID_Bling;
    property Categoria_Campo: string read FCategoria_Campo write FCategoria_Campo;
    property Categoria_Vinculo: string read FCategoria_Vinculo write FCategoria_Vinculo;

    property Cor: string read FCor write FCor;
    property Cor_ID_Bling: string read FCor_ID_Bling write FCor_ID_Bling;
    property Cor_Campo: string read FCor_Campo write FCor_Campo;
    property Cor_Vinculo: string read FCor_Vinculo write FCor_Vinculo;

    property Tamanho: string read FTamanho write FTamanho;
    property Tamanho_ID_Bling: string read FTamanho_ID_Bling write FTamanho_ID_Bling;
    property Tamanho_Campo: string read FTamanho_Campo write FTamanho_Campo;
    property Tamanho_Vinculo: string read FTamanho_Vinculo write FTamanho_Vinculo;

    property Variacoes: TObjectList<TVariacao> read FVariacoes write FVariacoes;

    property NCM: string read FNCM write FNCM;
    property Unidade: string read FUnidade write FUnidade;
    property Exibir: Boolean read FExibir write FExibir;
    property Inativo: Boolean read FInativo write FInativo;
    property TipoReg: string read FTipoReg write FTipoReg;
    property Excluido: Boolean read FExcluido write FExcluido;

    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TReferencia }

constructor TReferencia.Create;
begin
  FVariacoes := TObjectList<TVariacao>.Create;
end;

destructor TReferencia.Destroy;
begin
  FVariacoes.Free;

  inherited;
end;

end.
