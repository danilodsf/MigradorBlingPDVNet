unit MigraBling.Model.Services.SubServices.PDVNET.DAOGrupos;

interface

uses
  MigraBling.Model.Grupos,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.QueryFactory,
  System.Generics.Collections,
  System.SysUtils,
  MigraBling.Model.LogObserver, MigraBling.Model.AppControl;

type
  TDAOGruposPDVNET = class(TInterfacedObject, IDAOTabelasPDVNET<TGrupo>)
  private
    FConexao: IConexao;
  public
    function Ler: TObjectList<TGrupo>;
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOGruposPDVNET }

constructor TDAOGruposPDVNET.Create(AConexao: IConexao);
begin
  FConexao := AConexao;
end;

function TDAOGruposPDVNET.Ler: TObjectList<TGrupo>;
var
  LGrupo: TGrupo;
  LQuery: IQuery;
begin
  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);

  Result := TObjectList<TGrupo>.Create;
  LQuery.Close;
  LQuery.SQL.Text := 'SELECT M.MAP_CODIGO, M.MAP_DESCRICAO, M.MAP_INATIVO2, MMB.TIPO,  ' +
    'MMB.ID_REG, MMB.ID FROM MOVIMENTOS_MIGRAR_BLING MMB LEFT JOIN MATERIAPRIMA M ' +
    'ON (M.MAP_CODIGO = MMB.ID_REG) WHERE MMB.TABELA = ''MATERIAPRIMA'' ';
  LQuery.Open;
  while not LQuery.EOF do
  begin
    if TAppControl.AppFinalizando then
      break;

    LGrupo := TGrupo.Create;
    LGrupo.ID := LQuery.FieldByName('ID_REG').AsInteger;
    LGrupo.ID_Movimento := LQuery.FieldByName('ID').AsString;
    LGrupo.Descricao := LQuery.FieldByName('MAP_DESCRICAO').AsString;
    LGrupo.Inativo := LQuery.FieldByName('MAP_INATIVO2').AsBoolean;
    LGrupo.TipoReg := LQuery.FieldByName('TIPO').AsString;
    Result.Add(LGrupo);
    LQuery.Next;
  end;
end;

end.
