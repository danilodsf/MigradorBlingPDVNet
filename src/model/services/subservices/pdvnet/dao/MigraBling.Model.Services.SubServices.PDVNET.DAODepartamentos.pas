unit MigraBling.Model.Services.SubServices.PDVNET.DAODepartamentos;

interface

uses
  MigraBling.Model.Departamentos,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.QueryFactory,
  System.Generics.Collections, System.SysUtils, MigraBling.Model.LogObserver,
  MigraBling.Model.AppControl;

type
  TDAODepartamentosPDVNET = class(TInterfacedObject, IDAOTabelasPDVNET<TDepartamento>)
  private
    FConexao: IConexao;
  public
    function Ler: TObjectList<TDepartamento>;
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAODepartamentosPDVNET }

constructor TDAODepartamentosPDVNET.Create(AConexao: IConexao);
begin
  FConexao := AConexao;
end;

function TDAODepartamentosPDVNET.Ler: TObjectList<TDepartamento>;
var
  LDepartamento: TDepartamento;
  LQuery: IQuery;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);

  Result := TObjectList<TDepartamento>.Create;
  LQuery.Close;
  LQuery.SQL.Text := 'SELECT G.GRUM_CODIGO, G.GRUM_DESCRICAO, G.GRUM_INATIVO2, MMB.TIPO,  ' +
    'MMB.ID_REG, MMB.ID FROM MOVIMENTOS_MIGRAR_BLING MMB LEFT JOIN GRUPOMATERIAIS G ' +
    'ON (G.GRUM_CODIGO = MMB.ID_REG) WHERE MMB.TABELA = ''GRUPOMATERIAIS'' ';
  LQuery.Open;
  while not LQuery.EOF do
  begin
    if TAppControl.AppFinalizando then
      break;

    LDepartamento := TDepartamento.Create;
    LDepartamento.ID := LQuery.FieldByName('ID_REG').AsInteger;
    LDepartamento.ID_Movimento := LQuery.FieldByName('ID').AsString;
    LDepartamento.Descricao := LQuery.FieldByName('GRUM_DESCRICAO').AsString;
    LDepartamento.Inativo := LQuery.FieldByName('GRUM_INATIVO2').AsBoolean;
    LDepartamento.TipoReg := LQuery.FieldByName('TIPO').AsString;
    Result.Add(LDepartamento);
    LQuery.Next;
  end;
end;

end.
