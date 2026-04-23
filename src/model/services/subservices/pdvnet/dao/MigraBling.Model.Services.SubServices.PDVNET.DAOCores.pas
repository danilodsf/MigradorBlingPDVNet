unit MigraBling.Model.Services.SubServices.PDVNET.DAOCores;

interface

uses
  MigraBling.Model.Cores,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.QueryFactory,
  System.Generics.Collections,
  System.SysUtils,
  MigraBling.Model.LogObserver, MigraBling.Model.AppControl;

type
  TDAOCoresPDVNET = class(TInterfacedObject, IDAOTabelasPDVNET<TCor>)
  private
    FConexao: IConexao;
  public
    function Ler: TObjectList<TCor>; overload;
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOCoresPDVNET }

constructor TDAOCoresPDVNET.Create(AConexao: IConexao);
begin
  FConexao := AConexao;
end;

function TDAOCoresPDVNET.Ler: TObjectList<TCor>;
var
  LCor: TCor;
  LQuery: IQuery;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);

  Result := TObjectList<TCor>.Create;
  LQuery.Close;
  LQuery.SQL.Text := 'SELECT C.COR_CODIGO, C.COR_DESCRICAO, C.COR_INATIVO2, MMB.TIPO,  ' +
    'MMB.ID_REG, MMB.ID FROM MOVIMENTOS_MIGRAR_BLING MMB LEFT JOIN CORES C ' +
    'ON (C.COR_CODIGO = MMB.ID_REG) WHERE MMB.TABELA = ''CORES'' ';
  LQuery.Open;
  while not LQuery.EOF do
  begin
    if TAppControl.AppFinalizando then
      break;

    LCor := TCor.Create;
    LCor.ID := LQuery.FieldByName('ID_REG').AsInteger;
    LCor.ID_Movimento := LQuery.FieldByName('ID').AsString;
    LCor.Descricao := LQuery.FieldByName('COR_DESCRICAO').AsString;
    LCor.Inativo := LQuery.FieldByName('COR_INATIVO2').AsBoolean;
    LCor.TipoReg := LQuery.FieldByName('TIPO').AsString;
    Result.Add(LCor);
    LQuery.Next;
  end;
end;

end.
