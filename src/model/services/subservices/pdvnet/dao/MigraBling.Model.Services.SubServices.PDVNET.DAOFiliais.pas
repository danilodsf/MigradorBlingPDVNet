unit MigraBling.Model.Services.SubServices.PDVNET.DAOFiliais;

interface

uses
  MigraBling.Model.Filiais,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.QueryFactory,
  System.Generics.Collections,
  System.SysUtils,
  MigraBling.Model.LogObserver, MigraBling.Model.AppControl;

type
  TDAOFiliaisPDVNET = class(TInterfacedObject, IDAOTabelasPDVNET<TFilial>)
  private
    FConexao: IConexao;
  public
    function Ler: TObjectList<TFilial>;
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOFiliaisPDVNET }

constructor TDAOFiliaisPDVNET.Create(AConexao: IConexao);
begin
  FConexao := AConexao;
end;

function TDAOFiliaisPDVNET.Ler: TObjectList<TFilial>;
var
  LFilial: TFilial;
  LQuery: IQuery;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);

  Result := TObjectList<TFilial>.Create;
  LQuery.Close;
  LQuery.SQL.Text := 'SELECT F.FIL_CODIGO, F.FIL_RAZAO_SOCIAL, F.FIL_INATIVA, MMB.TIPO,  ' +
    'MMB.ID_REG, MMB.ID FROM MOVIMENTOS_MIGRAR_BLING MMB LEFT JOIN FILIAL F ' +
    'ON (F.FIL_CODIGO = MMB.ID_REG) WHERE MMB.TABELA = ''FILIAL'' ';
  LQuery.Open;
  while not LQuery.EOF do
  begin
    if TAppControl.AppFinalizando then
      break;

    LFilial := TFilial.Create;
    LFilial.ID := LQuery.FieldByName('ID_REG').AsInteger;
    LFilial.ID_Movimento := LQuery.FieldByName('ID').AsString;
    LFilial.Descricao := LQuery.FieldByName('FIL_RAZAO_SOCIAL').AsString;
    LFilial.Inativo := LQuery.FieldByName('FIL_INATIVA').AsBoolean;
    LFilial.TipoReg := LQuery.FieldByName('TIPO').AsString;
    Result.Add(LFilial);
    LQuery.Next;
  end;
end;

end.
