unit MigraBling.Model.Services.SubServices.PDVNET.DAOMateriais;

interface

uses
  MigraBling.Model.Materiais,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.QueryFactory,
  System.Generics.Collections,
  System.SysUtils,
  MigraBling.Model.LogObserver, MigraBling.Model.AppControl;

type
  TDAOMateriaisPDVNET = class(TInterfacedObject, IDAOTabelasPDVNET<TMaterial>)
  private
    FConexao: IConexao;
  public
    function Ler: TObjectList<TMaterial>;
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOMateriaisPDVNET }

constructor TDAOMateriaisPDVNET.Create(AConexao: IConexao);
begin
  FConexao := AConexao;
end;

function TDAOMateriaisPDVNET.Ler: TObjectList<TMaterial>;
var
  LMaterial: TMaterial;
  LQuery: IQuery;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);

  Result := TObjectList<TMaterial>.Create;
  LQuery.Close;
  LQuery.SQL.Text := 'SELECT L.LIN_CODIGO, L.LIN_DESCRICAO, L.LIN_INATIVO2, MMB.TIPO,  ' +
    'MMB.ID_REG, MMB.ID FROM MOVIMENTOS_MIGRAR_BLING MMB LEFT JOIN LINHA L ' +
    'ON (L.LIN_CODIGO = MMB.ID_REG) WHERE MMB.TABELA = ''LINHA'' ';
  LQuery.Open;
  while not LQuery.EOF do
  begin
    if TAppControl.AppFinalizando then
      break;

    LMaterial := TMaterial.Create;
    LMaterial.ID := LQuery.FieldByName('ID_REG').AsInteger;
    LMaterial.ID_Movimento := LQuery.FieldByName('ID').AsString;
    LMaterial.Descricao := LQuery.FieldByName('LIN_DESCRICAO').AsString;
    LMaterial.Inativo := LQuery.FieldByName('LIN_INATIVO2').AsBoolean;
    LMaterial.TipoReg := LQuery.FieldByName('TIPO').AsString;
    Result.Add(LMaterial);
    LQuery.Next;
  end;
end;

end.
