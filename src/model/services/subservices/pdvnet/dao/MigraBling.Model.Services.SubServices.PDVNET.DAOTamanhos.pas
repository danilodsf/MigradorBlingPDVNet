unit MigraBling.Model.Services.SubServices.PDVNET.DAOTamanhos;

interface

uses
  MigraBling.Model.Tamanhos,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.QueryFactory,
  System.Generics.Collections,
  System.SysUtils,
  MigraBling.Model.LogObserver, MigraBling.Model.AppControl;

type
  TDAOTamanhosPDVNET = class(TInterfacedObject, IDAOTabelasPDVNET<TTamanho>)
  private
    FConexao: IConexao;
  public
    function Ler: TObjectList<TTamanho>; overload;
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOTamanhosPDVNET }

constructor TDAOTamanhosPDVNET.Create(AConexao: IConexao);
begin
  FConexao := AConexao;
end;

function TDAOTamanhosPDVNET.Ler: TObjectList<TTamanho>;
var
  LTamanho: TTamanho;
  LQuery: IQuery;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);

  Result := TObjectList<TTamanho>.Create;
  LQuery.Close;
  LQuery.SQL.Text := 'SELECT T.TAM_CODIGO, T.TAM_TAMANHO, T.TAM_INATIVO, T.TAM_ORDEM, MMB.TIPO,  ' +
    'MMB.ID_REG, MMB.ID FROM MOVIMENTOS_MIGRAR_BLING MMB LEFT JOIN TAMANHOS T ' +
    'ON (T.TAM_CODIGO = MMB.ID_REG) WHERE MMB.TABELA = ''TAMANHOS'' ';
  LQuery.Open;
  while not LQuery.EOF do
  begin
    if TAppControl.AppFinalizando then
      break;

    LTamanho := TTamanho.Create;
    LTamanho.ID := LQuery.FieldByName('ID_REG').AsInteger;
    LTamanho.ID_Movimento := LQuery.FieldByName('ID').AsString;
    LTamanho.Descricao := LQuery.FieldByName('TAM_TAMANHO').AsString;
    LTamanho.Ordem := LQuery.FieldByName('TAM_ORDEM').AsInteger;
    LTamanho.Inativo := LQuery.FieldByName('TAM_INATIVO').AsBoolean;
    LTamanho.TipoReg := LQuery.FieldByName('TIPO').AsString;
    Result.Add(LTamanho);
    LQuery.Next;
  end;
end;

end.
