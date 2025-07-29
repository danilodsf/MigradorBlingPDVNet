unit MigraBling.Model.Services.SubServices.SQLite.DAOMovimentos;

interface

uses
  MigraBling.Model.Interfaces.Dao,
  MigraBling.Model.Movimentos,
  System.Generics.Collections,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.QueryFactory,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Utils,
  System.SysUtils,
  MigraBling.Model.LogObserver;

type
  TDAOMovimentosSQLite = class(TInterfacedObject, IDAOMovimentosSQLite<TMovimento>)
  private
    FConexao: IConexao;
  public
    procedure Criar(AListObj: TObjectList<TMovimento>); overload;
    constructor Create(AConexao: IConexao);
  end;

implementation

{ TDAOMovimentosSQLite }

constructor TDAOMovimentosSQLite.Create(AConexao: IConexao);
begin
  FConexao := AConexao;
end;

procedure TDAOMovimentosSQLite.Criar(AListObj: TObjectList<TMovimento>);
var
  LQuery: IQuery;
  Movimento: TMovimento;
  I: integer;
  totMovimentos: integer;
begin
  if AListObj.Count = 0 then
    exit;

  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);

  totMovimentos := AListObj.Count;
  for I := Pred(AListObj.Count) downto 0 do
  begin
    if (AListObj[I].Tabela = 'MATERIAIS') then
    begin
      AListObj.Delete(I);
      Dec(totMovimentos);
    end;
  end;

  try
    LQuery.Close;
    LQuery.SQL.Text := ' INSERT INTO MOVIMENTOS_MIGRAR_BLING(ID, ID_REG, TABELA, TIPO, DATA) ' +
      ' VALUES (:PID, :PID_REG, :PTABELA, :PTIPO, :PDATA) ' +
      ' ON CONFLICT(ID) DO UPDATE SET ID_REG = excluded.ID_REG, ' +
      ' ID = excluded.ID, TABELA = excluded.TABELA, ' +
      ' TIPO = excluded.TIPO, DATA = excluded.DATA ';

    LQuery.ArraySize := totMovimentos;

    for I := 0 to Pred(AListObj.Count) do
    begin
      Movimento := AListObj[I];
      LQuery.ParamByName('PID').AsIntegers(I, Movimento.ID);
      LQuery.ParamByName('PID_REG').AsStrings(I, Movimento.ID_Reg);
      LQuery.ParamByName('PTABELA').AsStrings(I, Movimento.Tabela);
      LQuery.ParamByName('PTIPO').AsStrings(I, Movimento.Tipo);
      LQuery.ParamByName('PDATA').AsStrings(I, DateTimeToStr(Movimento.Data));
    end;

    if AListObj.Count > 0 then
      LQuery.Execute(AListObj.Count);
  except
    on E: Exception do
      TLogSubject.GetInstance.NotifyAll('Não foi possível inserir os dados em Movimentos - SQLite' +
        #13#10 + E.Message);
  end;
end;

end.
