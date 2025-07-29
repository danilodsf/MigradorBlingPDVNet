unit MigraBling.Model.Movimentos;

interface

type
  TMovimento = class
  private
    FID: integer;
    FID_Reg: string;
    FTabela: string;
    FTipo: string;
    FData: TDateTime;
  public
    property ID: integer read FID write FID;
    property ID_Reg: string read FID_Reg write FID_Reg;
    property Tabela: string read FTabela write FTabela;
    property Tipo: string read FTipo write FTipo;
    property Data: TDateTime read FData write FData;
  end;

implementation

end.
