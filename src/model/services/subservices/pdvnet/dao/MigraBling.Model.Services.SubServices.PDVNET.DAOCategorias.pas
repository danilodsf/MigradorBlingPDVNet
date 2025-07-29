unit MigraBling.Model.Services.SubServices.PDVNET.DAOCategorias;

interface

uses
  MigraBling.Model.Categorias,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.QueryFactory,
  System.Generics.Collections,
  System.SysUtils,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Interfaces.LogSubject, MigraBling.Model.AppControl;

type
  TDAOCategoriasPDVNET = class(TInterfacedObject, IDAOTabelasPDVNET<TCategoria>)
  private
    FConexao: IConexao;
  public
    function Ler: TObjectList<TCategoria>;
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOCategoriasPDVNET }

constructor TDAOCategoriasPDVNET.Create(AConexao: IConexao);
begin
  FConexao := AConexao;
end;

function TDAOCategoriasPDVNET.Ler: TObjectList<TCategoria>;
var
  LCategoria: TCategoria;
  LQuery: IQuery;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);

  Result := TObjectList<TCategoria>.Create;
  LQuery.Close;
  LQuery.SQL.Text := 'SELECT M.MOD_CODIGO, M.MOD_DESCRICAO, M.MOD_INATIVO2, MMB.TIPO, MMB.ID_REG, '
    + 'MMB.ID FROM MOVIMENTOS_MIGRAR_BLING MMB ' +
    'LEFT JOIN MODELOS M ON (M.MOD_CODIGO = MMB.ID_REG) WHERE MMB.TABELA = ''MODELOS'' ';
  LQuery.Open;
  while not LQuery.EOF do
  begin
    if TAppControl.AppFinalizando then
      break;

    LCategoria := TCategoria.Create;
    LCategoria.ID := LQuery.FieldByName('ID_REG').AsInteger;
    LCategoria.ID_Movimento := LQuery.FieldByName('ID').AsString;
    LCategoria.Descricao := LQuery.FieldByName('MOD_DESCRICAO').AsString;
    LCategoria.Inativo := LQuery.FieldByName('MOD_INATIVO2').AsBoolean;
    LCategoria.TipoReg := LQuery.FieldByName('TIPO').AsString;
    Result.Add(LCategoria);
    LQuery.Next;
  end;
end;

end.
