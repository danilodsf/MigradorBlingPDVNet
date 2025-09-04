unit MigraBling.Model.Services.SubServices.SQLite.DAO;

interface

uses
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.QueryFactory,
  MigraBling.Model.QueryFactory,
  MigraBling.Model.BaseModel,
  System.SysUtils,
  System.Generics.Collections,
  MigraBling.Model.LogObserver, MigraBling.Model.AppControl;

type
  TDaoSQLite = class(TInterfacedObject)
  protected
    FConexao: IConexao;
  public
    constructor Create(AConexao: IConexao);

    function LerEntidade<T: class, constructor>(const ASQL: string;
      const AMapeador: TFunc<IQuery, T>): TObjectList<T>; overload;

    function LerEntidade<T: class, constructor>(const ASQL, ASQL2, ASQL3: string;
      const AMapeadorPrincipal: TProc<IQuery, boolean>;
      const AInserirDados: TProc<IQuery, IQuery, IQuery>; const AMapeador: TFunc<IQuery, T>)
      : TObjectList<T>; overload;

    function LerEntidade<T: class, constructor; TComp: class, constructor>(const ASQL,
      ASQLComplementar, ASQLComplementar2: string;
      const AMapeador: TFunc<IQuery, IQuery, IQuery, T>): TObjectList<T>; overload;

    function LerEntidade<T: class, constructor>(const ASQL: string;
      const AParametros: TProc<IQuery>; const AMapeador: TFunc<IQuery, T>): TObjectList<T>;
      overload;

    procedure PersistirEntidade<T: class, constructor>(AListObj: TObjectList<T>;
      const ASQLInsertOrUpdate, ASQLExcluir: string; const AFiltrarParaAtualizar: TPredicate<T>;
      const APreencherAtualizar, APreencherExcluir: TProc<T, Integer, IQuery>;
      const AContexto: string);

    procedure AtualizarIDsBlingEntidade<T: class, constructor>(AListObj: TObjectList<T>;
      const ASQL: string; const APreencherParametros: TProc<T, Integer, IQuery>;
      const AContexto: string); overload;

    procedure AtualizarIDsBlingEntidade<T: class, constructor>(AListObj: TObjectList<T>;
      const ASQLInsertTabela, ASQLInsertCampoCustomizado: string;
      const APreencherParametrosTabela: TProc<T, Integer, IQuery>;
      const APreencherParametroCampoCustomizado: TProc<T, IQuery>;
      const AContexto: string); overload;
  end;

implementation

{ TDaoSQLite }

procedure TDaoSQLite.AtualizarIDsBlingEntidade<T>(AListObj: TObjectList<T>; const ASQL: string;
  const APreencherParametros: TProc<T, Integer, IQuery>; const AContexto: string);
var
  LQuery: IQuery;
  I: Integer;
begin
  if TAppControl.AppFinalizando then
    Exit;

  if not Assigned(AListObj) then
    Exit;

  if AListObj.Count = 0 then
    Exit;

  try
    LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
    LQuery.Close;
    LQuery.SQL.Text := ASQL;
    LQuery.ArraySize := AListObj.Count;

    for I := 0 to Pred(AListObj.Count) do
    begin
      if TAppControl.AppFinalizando then
        break;
      APreencherParametros(AListObj[I], I, LQuery);
    end;

    LQuery.Execute(AListObj.Count);
  except
    on E: Exception do
    begin
      TLogSubject.GetInstance.NotifyAll(Format('Erro ao atualizar IDs Bling em %s - SQLite - %s',
        [AContexto, E.Message]));
    end;
  end;
end;

procedure TDaoSQLite.AtualizarIDsBlingEntidade<T>(AListObj: TObjectList<T>;
  const ASQLInsertTabela, ASQLInsertCampoCustomizado: string;
  const APreencherParametrosTabela: TProc<T, Integer, IQuery>;
  const APreencherParametroCampoCustomizado: TProc<T, IQuery>; const AContexto: string);
var
  LQueryTabela, LQueryCampoCustomizado: IQuery;
  I: Integer;
begin
  if TAppControl.AppFinalizando then
    Exit;

  if not Assigned(AListObj) then
    Exit;

  if AListObj.Count = 0 then
    Exit;

  try
    LQueryTabela := TQueryFactory.New.GetQuery(FConexao.Clone);
    LQueryTabela.SQL.Text := ASQLInsertTabela;
    LQueryTabela.ArraySize := AListObj.Count;

    LQueryCampoCustomizado := TQueryFactory.New.GetQuery(FConexao.Clone);
    LQueryCampoCustomizado.SQL.Text := ASQLInsertCampoCustomizado;

    for I := 0 to Pred(AListObj.Count) do
    begin
      if TAppControl.AppFinalizando then
        break;
      APreencherParametrosTabela(AListObj[I], I, LQueryTabela);
    end;

    LQueryTabela.Execute(AListObj.Count);

    if AListObj.Count > 0 then
    begin
      APreencherParametroCampoCustomizado(AListObj[0], LQueryCampoCustomizado);
      LQueryCampoCustomizado.ExecSQL;
    end;
  except
    on E: Exception do
    begin
      TLogSubject.GetInstance.NotifyAll(Format('Erro ao atualizar IDs Bling em %s - SQLite - %s',
        [AContexto, E.Message]));
    end;
  end;
end;

constructor TDaoSQLite.Create(AConexao: IConexao);
begin
  FConexao := AConexao;
end;

function TDaoSQLite.LerEntidade<T>(const ASQL: string; const AMapeador: TFunc<IQuery, T>)
  : TObjectList<T>;
var
  LQuery: IQuery;
  LObj: T;
begin
  Result := nil;

  if TAppControl.AppFinalizando then
    Exit;

  Result := TObjectList<T>.Create(True);

  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
  LQuery.SQL.Text := ASQL;
  LQuery.Open;

  while not LQuery.EOF do
  begin
    if TAppControl.AppFinalizando then
      break;

    LObj := AMapeador(LQuery);
    Result.Add(LObj);
    LQuery.Next;
  end;
end;

function TDaoSQLite.LerEntidade<T>(const ASQL, ASQL2, ASQL3: string;
  const AMapeadorPrincipal: TProc<IQuery, boolean>;
  const AInserirDados: TProc<IQuery, IQuery, IQuery>; const AMapeador: TFunc<IQuery, T>)
  : TObjectList<T>;
var
  LQuery, LQueryInsert, LQueryConsolida: IQuery;
  LObj: T;
begin
  Result := nil;

  if TAppControl.AppFinalizando then
    Exit;

  Result := TObjectList<T>.Create(True);

  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
  LQuery.SQL.Text := ASQL;
  AMapeadorPrincipal(LQuery, True);
  LQuery.Open;

  LQueryInsert := TQueryFactory.New.GetQuery(FConexao.Clone);
  LQueryInsert.SQL.Text := ASQL2;

  LQueryConsolida := TQueryFactory.New.GetQuery(FConexao.Clone);
  LQueryConsolida.SQL.Text := ASQL3;

  while not LQuery.EOF do
  begin
    LQueryConsolida.Close;
    LQueryInsert.Close;
    AInserirDados(LQuery, LQueryInsert, LQueryConsolida);
    LQueryInsert.ExecSQL;
    LQuery.Next;
  end;

  LQuery.Close;
  AMapeadorPrincipal(LQuery, false);
  LQuery.Open;

  while not LQuery.EOF do
  begin
    if TAppControl.AppFinalizando then
      break;

    LObj := AMapeador(LQuery);

    Result.Add(LObj);
    LQuery.Next;
  end;
end;

function TDaoSQLite.LerEntidade<T>(const ASQL: string; const AParametros: TProc<IQuery>;
  const AMapeador: TFunc<IQuery, T>): TObjectList<T>;
var
  LQuery: IQuery;
  LObj: T;
begin
  Result := nil;

  if TAppControl.AppFinalizando then
    Exit;

  Result := TObjectList<T>.Create(True);

  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
  LQuery.SQL.Text := ASQL;
  LQuery.Open;

  AParametros(LQuery);

  while not LQuery.EOF do
  begin
    LObj := AMapeador(LQuery);
    Result.Add(LObj);
    LQuery.Next;
  end;
end;

function TDaoSQLite.LerEntidade<T, TComp>(const ASQL, ASQLComplementar, ASQLComplementar2: string;
  const AMapeador: TFunc<IQuery, IQuery, IQuery, T>): TObjectList<T>;
var
  LQuery, LQuery2, LQuery3: IQuery;
  LObj: T;
begin
  Result := nil;

  if TAppControl.AppFinalizando then
    Exit;

  Result := TObjectList<T>.Create(True);

  LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
  LQuery.SQL.Text := ASQL;
  LQuery.Open;

  LQuery2 := TQueryFactory.New.GetQuery(FConexao.Clone);
  LQuery2.SQL.Text := ASQLComplementar;

  LQuery3 := TQueryFactory.New.GetQuery(FConexao.Clone);
  LQuery3.SQL.Text := ASQLComplementar2;

  while not LQuery.EOF do
  begin
    if TAppControl.AppFinalizando then
      break;

    LObj := AMapeador(LQuery, LQuery2, LQuery3);
    Result.Add(LObj);
    LQuery.Next;
  end;
end;

procedure TDaoSQLite.PersistirEntidade<T>(AListObj: TObjectList<T>;
  const ASQLInsertOrUpdate, ASQLExcluir: string; const AFiltrarParaAtualizar: TPredicate<T>;
  const APreencherAtualizar, APreencherExcluir: TProc<T, Integer, IQuery>; const AContexto: string);
var
  LQueryInsertUpdate, LQueryDelete: IQuery;
  InsertUpdateList, DeleteList: TObjectList<T>;
  I: Integer;
begin
  if TAppControl.AppFinalizando then
    Exit;

  if not Assigned(AListObj) then
    Exit;

  if AListObj.Count = 0 then
    Exit;

  InsertUpdateList := TObjectList<T>.Create(false);
  DeleteList := TObjectList<T>.Create(false);

  try
    try
      for I := 0 to Pred(AListObj.Count) do
      begin
        if TAppControl.AppFinalizando then
          break;

        if AFiltrarParaAtualizar(AListObj[I]) then
          InsertUpdateList.Add(AListObj[I])
        else
          DeleteList.Add(AListObj[I]);
      end;

      if InsertUpdateList.Count > 0 then
      begin
        LQueryInsertUpdate := TQueryFactory.New.GetQuery(FConexao.Clone);
        LQueryInsertUpdate.SQL.Text := ASQLInsertOrUpdate;
        LQueryInsertUpdate.ArraySize := InsertUpdateList.Count;

        for I := 0 to Pred(InsertUpdateList.Count) do
        begin
          if TAppControl.AppFinalizando then
            break;
          APreencherAtualizar(InsertUpdateList[I], I, LQueryInsertUpdate);
        end;

        LQueryInsertUpdate.Execute(InsertUpdateList.Count);
      end;

      if DeleteList.Count > 0 then
      begin
        LQueryDelete := TQueryFactory.New.GetQuery(FConexao.Clone);
        LQueryDelete.SQL.Text := ASQLExcluir;
        LQueryDelete.ArraySize := DeleteList.Count;

        for I := 0 to Pred(DeleteList.Count) do
        begin
          if TAppControl.AppFinalizando then
            break;
          APreencherExcluir(DeleteList[I], I, LQueryDelete);
        end;

        LQueryDelete.Execute(DeleteList.Count);
      end;
    except
      on E: Exception do
      begin
        TLogSubject.GetInstance.NotifyAll(Format('Erro ao persistir dados em %s - SQLite - %s',
          [AContexto, E.Message]));
      end;
    end;
  finally
    InsertUpdateList.Free;
    DeleteList.Free;
  end;
end;

end.
