unit MigraBling.Model.Services.SubServices.SQLite.DAOVendas;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  MigraBling.Model.Utils,
  MigraBling.Model.MovimentoEstoque,
  MigraBling.Model.Interfaces.Dao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.Services.SubServices.SQLite.Dao,
  MigraBling.Model.Configuracao;

type
  TDAOVendasSQLite = class(TDaoSQLite, IDAOTabelasSQLite<TMovimentoEstoque>)
  private
    FConfigurador: IDAOConfiguracoesSQLite<TConfiguracao>;
  public
    function Ler: TObjectList<TMovimentoEstoque>; overload;
    function Ler(AID: string): TMovimentoEstoque; overload;
    procedure Persistir(AListObj: TObjectList<TMovimentoEstoque>);
    procedure GravarIDsBling(AListObj: TObjectList<TMovimentoEstoque>);
    constructor Create(AConexao: IConexao; AConfigurador: IDAOConfiguracoesSQLite<TConfiguracao>);
  end;

implementation

{ TDAOVendasSQLite }

constructor TDAOVendasSQLite.Create(AConexao: IConexao;
  AConfigurador: IDAOConfiguracoesSQLite<TConfiguracao>);
begin
  inherited Create(AConexao);
  FConfigurador := AConfigurador;
end;

procedure TDAOVendasSQLite.GravarIDsBling(AListObj: TObjectList<TMovimentoEstoque>);
begin
end;

function TDAOVendasSQLite.Ler(AID: string): TMovimentoEstoque;
begin
  Result := nil;
end;

function TDAOVendasSQLite.Ler: TObjectList<TMovimentoEstoque>;
const
  SQL = 'SELECT ID, ID_PRODUTO_BLING, ID_FILIAL, QUANTIDADE_VENDIDA, SALDO_ANTERIOR, ' +
    'DATA FROM MOVIMENTOS_ESTOQUE_BLING WHERE PROCESSADO = ''N'' AND DATA > :PDATA';
begin
  Result := LerEntidade<TMovimentoEstoque>(SQL,
    procedure(AQuery: IQuery)
    var
      FConfiguracao: TConfiguracao;
    begin
      FConfiguracao := FConfigurador.Ler(0);
      try
        AQuery.ParamByName('PDATA').AsString :=
          setDataSQLite(FConfiguracao.DataUltimaConsultaHookDeck);
      finally
        FConfiguracao.Free;
      end;
    end,
    function(AQuery: IQuery): TMovimentoEstoque
    var
      LVenda: TMovimentoEstoque;
    begin
      LVenda := TMovimentoEstoque.Create;
      LVenda.ID := AQuery.FieldByName('ID').AsLargeInt;
      LVenda.ID_Produto_Bling := AQuery.FieldByName('ID_PRODUTO_BLING').AsLargeInt;
      LVenda.ID_Filial_Bling := AQuery.FieldByName('ID_FILIAL').AsLargeInt;
      LVenda.Quantidade := AQuery.FieldByName('QUANTIDADE_VENDIDA').AsInteger;
      LVenda.SaldoAnterior := AQuery.FieldByName('SALDO_ANTERIOR').AsInteger;
      LVenda.Data := getDataSQLite(AQuery.FieldByName('DATA').AsString);
      Result := LVenda;
    end);
end;

procedure TDAOVendasSQLite.Persistir(AListObj: TObjectList<TMovimentoEstoque>);
const
  SQL_INSERT =
    'INSERT INTO MOVIMENTOS_ESTOQUE_BLING(ID_PRODUTO_BLING, ID_FILIAL, QUANTIDADE_VENDIDA, ' +
    'SALDO_ANTERIOR, DATA) VALUES (:PID_PRODUTO_BLING, :PID_FILIAL, :PQUANTIDADE_VENDIDA, ' +
    ':PSALDO_ANTERIOR, :PDATA) ON CONFLICT(ID) DO UPDATE SET ID = excluded.ID, ' +
    'ID_PRODUTO_BLING = excluded.ID_PRODUTO_BLING, ID_FILIAL = excluded.ID_FILIAL, ' +
    'QUANTIDADE_VENDIDA = excluded.QUANTIDADE_VENDIDA, SALDO_ANTERIOR = excluded.SALDO_ANTERIOR, ' +
    'DATA = excluded.DATA ';

  SQL_DELETE = ' UPDATE SALDO SET EXCLUIDO = 1 WHERE SAL_ID = :PSAL_ID';
begin
  // PersistirEntidade<TMovimentoEstoque>(AListObj, SQL_INSERT, SQL_DELETE,
  // function(Obj: TMovimentoEstoque): Boolean
  // begin
  // Result := ((Obj.TipoReg = 'I') or (Obj.TipoReg = 'U'));
  // end,
  // procedure(ASaldo: TMovimentoEstoque; AIndex: Integer; AQuery: IQuery)
  // begin
  // AQuery.ParamByName('PSAL_ID').AsStrings(AIndex, ASaldo.ID);
  // AQuery.ParamByName('PSAL_PRODUTO').AsStrings(AIndex, ASaldo.Produto);
  // AQuery.ParamByName('PSAL_FILIAL').AsIntegers(AIndex, ASaldo.Filial);
  // AQuery.ParamByName('PSAL_SALDO').AsFloats(AIndex, ASaldo.Saldo);
  // end,
  // procedure(ASaldo: TMovimentoEstoque; AIndex: Integer; AQuery: IQuery)
  // begin
  // AQuery.ParamByName('PSAL_ID').AsStrings(AIndex, ASaldo.ID);
  // end,
  // 'Saldos');
end;

end.
