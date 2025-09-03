unit MigraBling.Model.Services.SubServices.SQLite.DAOReferencias;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  MigraBling.Model.Interfaces.Dao,
  MigraBling.Model.Referencias,
  MigraBling.Model.Interfaces.Conexao,
  MigraBling.Model.QueryFactory,
  MigraBling.Model.Configuracao,
  MigraBling.Model.Interfaces.Query,
  MigraBling.Model.Utils,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Variacoes,
  MigraBling.Model.Services.SubServices.SQLite.Dao;

type
  TDAOReferenciasSQLite = class(TDaoSQLite, IDAOTabelasSQLite<TReferencia>)
  private
    FConfigurador: IDAOConfiguracoesSQLite<TConfiguracao>;
    FVariacoes: IDAOTabelasSQLite<TVariacao>;
  public
    function Ler: TObjectList<TReferencia>; overload;
    function Ler(AID: string): TReferencia; overload;
    procedure Persistir(AListObj: TObjectList<TReferencia>);
    procedure GravarIDsBling(AListObj: TObjectList<TReferencia>);
    constructor Create(AConexao: IConexao; AConfigurador: IDAOConfiguracoesSQLite<TConfiguracao>);
  end;

implementation

uses
  MigraBling.Model.Services.SubServices.SQLite.DAOVariacoes;

{ TDAOReferenciasSQLite }

constructor TDAOReferenciasSQLite.Create(AConexao: IConexao;
  AConfigurador: IDAOConfiguracoesSQLite<TConfiguracao>);
begin
  FConfigurador := AConfigurador;
  FVariacoes := TDAOVariacoesSQLite.Create(AConexao, AConfigurador);
  inherited Create(AConexao);
end;

procedure TDAOReferenciasSQLite.GravarIDsBling(AListObj: TObjectList<TReferencia>);
const
  SQL = ' UPDATE REFERENCIAS SET ID_BLING = :PID_BLING, ' +
    'CATEGORIA_VINCULO_ID_BLING = :PCATEGORIA_VINCULO_ID_BLING, ' +
    'DEPARTAMENTO_VINCULO_ID_BLING = :PDEPARTAMENTO_VINCULO_ID_BLING, ' +
    'COLECAO_VINCULO_ID_BLING = :PCOLECAO_VINCULO_ID_BLING, ' +
    'GRUPO_VINCULO_ID_BLING = :PGRUPO_VINCULO_ID_BLING, ' +
    'MATERIAL_VINCULO_ID_BLING = :PMATERIAL_VINCULO_ID_BLING, ' +
    'COR_VINCULO_ID_BLING = :PCOR_VINCULO_ID_BLING, ' +
    'TAMANHO_VINCULO_ID_BLING = :PTAMANHO_VINCULO_ID_BLING ' +
    'WHERE REF_REFERENCIA = :PREF_REFERENCIA ';
  SQL_VARIACOES = ' UPDATE MATERIAIS SET ID_BLING = :PID_BLING, ' +
    'COR_VINCULO_ID_BLING = :PCOR_VINCULO_ID_BLING, ' +
    'TAMANHO_VINCULO_ID_BLING = :PTAMANHO_VINCULO_ID_BLING WHERE MAT_CODIGO = :PMAT_CODIGO ';

begin
  AtualizarIDsBlingEntidade<TReferencia>(AListObj, SQL,
    procedure(AReferencia: TReferencia; AIndex: Integer; AQuery: IQuery)
    var
      variacao: TVariacao;
      LQuery: IQuery;
      I: Integer;
    begin
      try
        AQuery.ParamByName('PREF_REFERENCIA').AsStrings(AIndex, AReferencia.Referencia);
        AQuery.ParamByName('PID_BLING').AsStrings(AIndex, AReferencia.ID_Bling);

        AQuery.ParamByName('PCATEGORIA_VINCULO_ID_BLING').AsStrings(AIndex,
          AReferencia.Categoria_Vinculo);
        AQuery.ParamByName('PDEPARTAMENTO_VINCULO_ID_BLING').AsStrings(AIndex,
          AReferencia.Departamento_Vinculo);
        AQuery.ParamByName('PCOLECAO_VINCULO_ID_BLING').AsStrings(AIndex,
          AReferencia.Colecao_Vinculo);
        AQuery.ParamByName('PGRUPO_VINCULO_ID_BLING').AsStrings(AIndex, AReferencia.Grupo_Vinculo);
        AQuery.ParamByName('PMATERIAL_VINCULO_ID_BLING').AsStrings(AIndex,
          AReferencia.Material_Vinculo);
        AQuery.ParamByName('PCOR_VINCULO_ID_BLING').AsStrings(AIndex, AReferencia.Cor_Vinculo);
        AQuery.ParamByName('PTAMANHO_VINCULO_ID_BLING').AsStrings(AIndex,
          AReferencia.Tamanho_Vinculo);

        if AReferencia.Variacoes.Count > 0 then
        begin
          LQuery := TQueryFactory.New.GetQuery(FConexao.Clone);
          LQuery.SQL.Text := SQL_VARIACOES;
          LQuery.ArraySize := AReferencia.Variacoes.Count;
          I := 0;
          for variacao in AReferencia.Variacoes do
          begin
            LQuery.ParamByName('PMAT_CODIGO').AsStrings(I, variacao.ID);
            LQuery.ParamByName('PID_BLING').AsStrings(I, variacao.ID_Bling);
            LQuery.ParamByName('PCOR_VINCULO_ID_BLING').AsStrings(I, variacao.Cor_ID_Bling);
            LQuery.ParamByName('PTAMANHO_VINCULO_ID_BLING').AsStrings(I, variacao.Tamanho_ID_Bling);
            Inc(I);
          end;
          LQuery.Execute(AReferencia.Variacoes.Count);
        end;
      except
        on E: Exception do
          TLogSubject.GetInstance.NotifyAll(E.Message);
      end;

    end, 'Referências');
end;

function TDAOReferenciasSQLite.Ler(AID: string): TReferencia;
begin
  Result := nil;
end;

function TDAOReferenciasSQLite.Ler: TObjectList<TReferencia>;
const
  SQL = 'SELECT COL.ID_BLING REF_COLECAO, COL_DESCRICAO, REF_REFERENCIA, ' +
    'REF_DESCRICAO, REF_DESCRICAO_CURTA, REF_DESCRICAO_LONGA, REF_PESO, REF_ALTURA, REF_LARGURA, ' +
    'REF_PROFUNDIDADE, MAP.ID_BLING REF_MATERIA, MAP_DESCRICAO, GRUM.ID_BLING REF_GRUPO, ' +
    'GRUM_DESCRICAO, LIN.ID_BLING REF_LINHA, LIN_DESCRICAO, MOD.ID_BLING REF_MODELO, ' +
    'MOD_DESCRICAO, REF_NCM, REF_UNIDADE, REF_EXIBIR, R.EXCLUIDO, R.ID_BLING, REF_INATIVO2, ' +
    'MMB.TIPO, MMB.ID_REG, MMB.ID, CATEGORIA_VINCULO_ID_BLING, DEPARTAMENTO_VINCULO_ID_BLING, ' +
    'COLECAO_VINCULO_ID_BLING, GRUPO_VINCULO_ID_BLING, MATERIAL_VINCULO_ID_BLING, ' +
    'COR_VINCULO_ID_BLING, TAMANHO_VINCULO_ID_BLING, ' +
    '(select id_bling from CAMPOS_CUSTOMIZADOS where descricao = ''Departamento'') as CAMPO_DEPARTAMENTO, '
    + '(select id_bling from CAMPOS_CUSTOMIZADOS where descricao = ''Coleção'') as CAMPO_COLECAO, '
    + '(select id_bling from CAMPOS_CUSTOMIZADOS where descricao = ''Grupo'') as CAMPO_GRUPO, ' +
    '(select id_bling from CAMPOS_CUSTOMIZADOS where descricao = ''Material'') as CAMPO_MATERIAL, '
    + '(select id_bling from CAMPOS_CUSTOMIZADOS where descricao = ''Categoria'') as CAMPO_CATEGORIA, '
    + '(select id_bling from CAMPOS_CUSTOMIZADOS where descricao = ''Cor'') as CAMPO_COR, ' +
    '(select id_bling from CAMPOS_CUSTOMIZADOS where descricao = ''Tamanho'') as CAMPO_TAMANHO, ' +
    '(select id_bling from CORES where cor_codigo = 1) as REF_COR, ' +
    '(select cor_descricao from CORES where cor_codigo = 1) as COR_DESCRICAO, ' +
    '(select id_bling from tamanhos where TAM_INATIVO = 0 and tam_tamanho = ''U'' limit 1) as REF_TAMANHO, ' +
    '(select tam_tamanho from tamanhos where TAM_INATIVO = 0 and tam_tamanho = ''U'' limit 1) as TAMANHO_DESCRICAO ' +
    'FROM MOVIMENTOS_MIGRAR_BLING MMB ' +
    'LEFT JOIN REFERENCIAS R ON (R.REF_REFERENCIA = MMB.ID_REG) ' +
    'LEFT JOIN MATERIAPRIMA MAP ON (MAP_CODIGO = REF_MATERIA) ' +
    'LEFT JOIN GRUPOMATERIAIS GRUM ON (GRUM_CODIGO = REF_GRUPO) ' +
    'LEFT JOIN LINHA LIN ON (LIN_CODIGO = REF_LINHA) ' +
    'LEFT JOIN COLECOES COL ON (COL_CODIGO = REF_COLECAO) ' +
    'LEFT JOIN MODELOS MOD ON (MOD_CODIGO = REF_MODELO) WHERE MMB.TABELA = ''REFERENCIAS'' ';

  SQL_VARIACOES =
    'select mat_codigo, C.COR_DESCRICAO, T.TAM_TAMANHO, PRE_PRECO1, M.ID_BLING, MAT_REFERENCIA, ' +
    'MAT_EXIBIR, COR_VINCULO_ID_BLING, TAMANHO_VINCULO_ID_BLING, C.ID_BLING COR_ID_BLING, ' +
    'T.ID_BLING TAM_ID_BLING from MATERIAIS M join CORES C on (C.COR_CODIGO = M.MAT_COR) ' +
    'join TAMANHOS T on (T.TAM_CODIGO = M.MAT_TAMANHO) ' +
    'join PRECO on (PRE_PRODUTO = MAT_CODIGO) where PRE_TABELA = :PCODTABELA ' +
    'order by mat_referencia, mat_codigo';
begin
  Result := LerEntidade<TReferencia, TVariacao>(SQL, SQL_VARIACOES,
    procedure(AQuery: IQuery)
    var
      LConfiguracao: TConfiguracao;
    begin
      LConfiguracao := FConfigurador.Ler(0);
      try
        AQuery.ParamByName('PCODTABELA').AsInteger := LConfiguracao.TabelaPrecoPadrao;
      finally
        LConfiguracao.Free;
      end;
    end,
    function(AQuery: IQuery): TDictionary < string, TObjectList < TVariacao >>
    var
      LVariacao: TVariacao;
      LOrdem: integer;
    begin
      Result := TDictionary < string, TObjectList < TVariacao >>.Create;
      LOrdem := 1;
      while not AQuery.EOF do
      begin
        if not Result.ContainsKey(AQuery.FieldByName('MAT_REFERENCIA').AsString) then
        begin
          Result.Add(AQuery.FieldByName('MAT_REFERENCIA').AsString, TObjectList<TVariacao>.Create);
          LOrdem := 1;
        end;

        LVariacao := TVariacao.Create;
        LVariacao.ID := AQuery.FieldByName('MAT_CODIGO').AsString;
        LVariacao.ID_Bling := AQuery.FieldByName('ID_BLING').AsString;
        LVariacao.Referencia := AQuery.FieldByName('MAT_REFERENCIA').AsString;

        LVariacao.CorStr := AQuery.FieldByName('COR_DESCRICAO').AsString;
        LVariacao.Cor_Vinculo := AQuery.FieldByName('COR_VINCULO_ID_BLING').AsString;
        LVariacao.Cor_ID_Bling := AQuery.FieldByName('COR_ID_BLING').AsString;

        LVariacao.TamanhoStr := AQuery.FieldByName('TAM_TAMANHO').AsString;
        LVariacao.Tamanho_Vinculo := AQuery.FieldByName('TAMANHO_VINCULO_ID_BLING').AsString;
        LVariacao.Tamanho_ID_Bling := AQuery.FieldByName('TAM_ID_BLING').AsString;

        LVariacao.Preco := AQuery.FieldByName('PRE_PRECO1').AsCurrency;
        LVariacao.Exibir := (AQuery.FieldByName('MAT_EXIBIR').AsInteger in [1, 3]);
        LVariacao.Descricao := 'COR: ' + LVariacao.CorStr + '; TAMANHO: ' + LVariacao.TamanhoStr;
        LVariacao.Ordem := LOrdem;

        Result[AQuery.FieldByName('MAT_REFERENCIA').AsString].Add(LVariacao);

        Inc(LOrdem);

        AQuery.Next;
      end;
    end,
    function(AQuery: IQuery; AListaVariacoes: TDictionary < string, TObjectList < TVariacao >> )
      : TReferencia
    var
      LReferencia: TReferencia;
      LVariacaoTmp, LVariacao: TVariacao;
    begin
      LReferencia := TReferencia.Create;
      LReferencia.Referencia := AQuery.FieldByName('ID_REG').AsString.Trim;
      LReferencia.Nome := AQuery.FieldByName('REF_DESCRICAO').AsString;
      LReferencia.Descricao := AQuery.FieldByName('REF_DESCRICAO_CURTA').AsString;
      LReferencia.Descricao_Complementar := AQuery.FieldByName('REF_DESCRICAO_LONGA').AsString;
      LReferencia.Peso := AQuery.FieldByName('REF_PESO').AsFloat;
      LReferencia.Altura := AQuery.FieldByName('REF_ALTURA').AsFloat;
      LReferencia.Largura := AQuery.FieldByName('REF_LARGURA').AsFloat;
      LReferencia.Profundidade := AQuery.FieldByName('REF_PROFUNDIDADE').AsFloat;

      LReferencia.Colecao := AQuery.FieldByName('COL_DESCRICAO').AsString;
      LReferencia.Colecao_ID_Bling := AQuery.FieldByName('REF_COLECAO').AsString;
      LReferencia.Colecao_Campo := AQuery.FieldByName('CAMPO_COLECAO').AsString;
      LReferencia.Colecao_Vinculo := AQuery.FieldByName('COLECAO_VINCULO_ID_BLING').AsString;

      LReferencia.Grupo := AQuery.FieldByName('MAP_DESCRICAO').AsString;
      LReferencia.Grupo_ID_Bling := AQuery.FieldByName('REF_MATERIA').AsString;
      LReferencia.Grupo_Campo := AQuery.FieldByName('CAMPO_GRUPO').AsString;
      LReferencia.Grupo_Vinculo := AQuery.FieldByName('GRUPO_VINCULO_ID_BLING').AsString;

      LReferencia.Departamento := AQuery.FieldByName('GRUM_DESCRICAO').AsString;
      LReferencia.Departamento_ID_Bling := AQuery.FieldByName('REF_GRUPO').AsString;
      LReferencia.Departamento_Campo := AQuery.FieldByName('CAMPO_DEPARTAMENTO').AsString;
      LReferencia.Departamento_Vinculo :=
        AQuery.FieldByName('DEPARTAMENTO_VINCULO_ID_BLING').AsString;

      LReferencia.Material := AQuery.FieldByName('LIN_DESCRICAO').AsString;
      LReferencia.Material_ID_BLING := AQuery.FieldByName('REF_LINHA').AsString;
      LReferencia.Material_Campo := AQuery.FieldByName('CAMPO_MATERIAL').AsString;
      LReferencia.Material_Vinculo := AQuery.FieldByName('MATERIAL_VINCULO_ID_BLING').AsString;

      LReferencia.Categoria := AQuery.FieldByName('MOD_DESCRICAO').AsString;
      LReferencia.Categoria_ID_Bling := AQuery.FieldByName('REF_MODELO').AsString;
      LReferencia.Categoria_Campo := AQuery.FieldByName('CAMPO_CATEGORIA').AsString;
      LReferencia.Categoria_Vinculo := AQuery.FieldByName('CATEGORIA_VINCULO_ID_BLING').AsString;

      LReferencia.Cor := AQuery.FieldByName('COR_DESCRICAO').AsString;
      LReferencia.Cor_ID_Bling := AQuery.FieldByName('REF_COR').AsString;
      LReferencia.Cor_Campo := AQuery.FieldByName('CAMPO_COR').AsString;
      LReferencia.Cor_Vinculo := AQuery.FieldByName('COR_VINCULO_ID_BLING').AsString;

      LReferencia.Tamanho := AQuery.FieldByName('TAMANHO_DESCRICAO').AsString;
      LReferencia.Tamanho_ID_Bling := AQuery.FieldByName('REF_TAMANHO').AsString;
      LReferencia.Tamanho_Campo := AQuery.FieldByName('CAMPO_TAMANHO').AsString;
      LReferencia.Tamanho_Vinculo := AQuery.FieldByName('TAMANHO_VINCULO_ID_BLING').AsString;

      LReferencia.NCM := AQuery.FieldByName('REF_NCM').AsString;
      LReferencia.Unidade := AQuery.FieldByName('REF_UNIDADE').AsString;
      LReferencia.Exibir := AQuery.FieldByName('REF_EXIBIR').AsInteger = 1;
      LReferencia.Inativo := AQuery.FieldByName('REF_INATIVO2').AsInteger = 1;
      LReferencia.TipoReg := AQuery.FieldByName('TIPO').AsString;
      LReferencia.ID_Bling := AQuery.FieldByName('ID_BLING').AsString;
      LReferencia.ID_Movimento := AQuery.FieldByName('ID').AsString;
      LReferencia.TemAoMenosUmaVariacaoValida := false;

      if AListaVariacoes.ContainsKey(LReferencia.Referencia) then
      begin
        for LVariacaoTmp in AListaVariacoes[LReferencia.Referencia] do
        begin
          if (LVariacaoTmp.Exibir) then
            LReferencia.TemAoMenosUmaVariacaoValida := true;

          LVariacao := TVariacao.Create;
          LVariacao.ID := LVariacaoTmp.ID;
          LVariacao.Referencia := LVariacaoTmp.Referencia;
          LVariacao.Descricao := LVariacaoTmp.Descricao;

          LVariacao.CorStr := LVariacaoTmp.CorStr;
          LVariacao.Cor_Vinculo := LVariacaoTmp.Cor_Vinculo;
          LVariacao.Cor_ID_Bling := LVariacaoTmp.Cor_ID_Bling;

          LVariacao.TamanhoStr := LVariacaoTmp.TamanhoStr;
          LVariacao.Tamanho_Vinculo := LVariacaoTmp.Tamanho_Vinculo;
          LVariacao.Tamanho_ID_Bling := LVariacaoTmp.Tamanho_ID_Bling;

          LVariacao.Preco := LVariacaoTmp.Preco;
          LVariacao.Inativo := LVariacaoTmp.Inativo;
          LVariacao.TipoReg := LVariacaoTmp.TipoReg;
          LVariacao.Excluido := LVariacaoTmp.Excluido;
          LVariacao.ID_Movimento := LVariacaoTmp.ID_Movimento;
          LVariacao.ID_Bling := LVariacaoTmp.ID_Bling;

          LVariacao.Exibir := LVariacaoTmp.Exibir;
          LVariacao.Ordem := LVariacaoTmp.Ordem;

          LReferencia.Variacoes.Add(LVariacao);
        end;
      end;

      Result := LReferencia;
    end);

end;

procedure TDAOReferenciasSQLite.Persistir(AListObj: TObjectList<TReferencia>);
const
  SQL_INSERT = ' INSERT INTO REFERENCIAS (REF_COLECAO,	REF_REFERENCIA,	REF_DESCRICAO, ' +
    'REF_DESCRICAO_CURTA, REF_DESCRICAO_LONGA, REF_PESO, REF_ALTURA, REF_LARGURA, ' +
    'REF_PROFUNDIDADE, REF_MATERIA, REF_GRUPO, REF_LINHA, REF_MODELO, REF_NCM, REF_UNIDADE, ' +
    'REF_EXIBIR, REF_INATIVO2) ' + ' VALUES (:PREF_COLECAO, :PREF_REFERENCIA, :PREF_DESCRICAO, ' +
    ':PREF_DESCRICAO_CURTA, :PREF_DESCRICAO_LONGA, :PREF_PESO, :PREF_ALTURA, :PREF_LARGURA, ' +
    ':PREF_PROFUNDIDADE, :PREF_MATERIA, :PREF_GRUPO, :PREF_LINHA, :PREF_MODELO, :PREF_NCM, ' +
    ':PREF_UNIDADE, :PREF_EXIBIR, :PREF_INATIVO2) ' +
    'ON CONFLICT(REF_REFERENCIA) DO UPDATE SET REF_COLECAO = excluded.REF_COLECAO, ' +
    'REF_REFERENCIA = excluded.REF_REFERENCIA, REF_DESCRICAO = excluded.REF_DESCRICAO, ' +
    'REF_DESCRICAO_CURTA = excluded.REF_DESCRICAO_CURTA, ' +
    'REF_DESCRICAO_LONGA = excluded.REF_DESCRICAO_LONGA, ' +
    'REF_PESO = excluded.REF_PESO, REF_ALTURA = excluded.REF_ALTURA, ' +
    'REF_LARGURA = excluded.REF_LARGURA, REF_PROFUNDIDADE = excluded.REF_PROFUNDIDADE, ' +
    'REF_MATERIA = excluded.REF_MATERIA, REF_GRUPO = excluded.REF_GRUPO, ' +
    'REF_LINHA = excluded.REF_LINHA, REF_MODELO = excluded.REF_MODELO, ' +
    'REF_NCM = excluded.REF_NCM, REF_UNIDADE = excluded.REF_UNIDADE, ' +
    'REF_EXIBIR = excluded.REF_EXIBIR, REF_INATIVO2 = excluded.REF_INATIVO2 ';

  SQL_DELETE = ' UPDATE REFERENCIAS SET EXCLUIDO = 1 WHERE REF_REFERENCIA = :PREF_REFERENCIA ';
begin
  PersistirEntidade<TReferencia>(AListObj, SQL_INSERT, SQL_DELETE,
    function(Obj: TReferencia): Boolean
    begin
      Result := ((Obj.TipoReg = 'I') or (Obj.TipoReg = 'U'));
    end,
    procedure(LReferencia: TReferencia; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PREF_COLECAO').AsStrings(AIndex, LReferencia.Colecao);
      AQuery.ParamByName('PREF_REFERENCIA').AsStrings(AIndex, LReferencia.Referencia);
      AQuery.ParamByName('PREF_DESCRICAO').AsStrings(AIndex, LReferencia.Nome);
      AQuery.ParamByName('PREF_DESCRICAO_CURTA').AsStrings(AIndex, LReferencia.Descricao);
      AQuery.ParamByName('PREF_DESCRICAO_LONGA').AsStrings(AIndex,
        LReferencia.Descricao_Complementar);
      AQuery.ParamByName('PREF_PESO').AsFloats(AIndex, LReferencia.Peso);
      AQuery.ParamByName('PREF_ALTURA').AsFloats(AIndex, LReferencia.Altura);
      AQuery.ParamByName('PREF_LARGURA').AsFloats(AIndex, LReferencia.Largura);
      AQuery.ParamByName('PREF_PROFUNDIDADE').AsFloats(AIndex, LReferencia.Profundidade);
      AQuery.ParamByName('PREF_MATERIA').AsStrings(AIndex, LReferencia.Grupo);
      AQuery.ParamByName('PREF_GRUPO').AsStrings(AIndex, LReferencia.Departamento);
      AQuery.ParamByName('PREF_LINHA').AsStrings(AIndex, LReferencia.Material);
      AQuery.ParamByName('PREF_MODELO').AsStrings(AIndex, LReferencia.Categoria);
      AQuery.ParamByName('PREF_NCM').AsStrings(AIndex, LReferencia.NCM);
      AQuery.ParamByName('PREF_UNIDADE').AsStrings(AIndex, LReferencia.Unidade);
      AQuery.ParamByName('PREF_EXIBIR').AsIntegers(AIndex, IfThen(LReferencia.Exibir, 1, 0));
      AQuery.ParamByName('PREF_INATIVO2').AsIntegers(AIndex, IfThen(LReferencia.Inativo, 1, 0));

      FVariacoes.Persistir(LReferencia.Variacoes);
    end,
    procedure(LReferencia: TReferencia; AIndex: Integer; AQuery: IQuery)
    begin
      AQuery.ParamByName('PREF_REFERENCIA').AsStrings(AIndex, LReferencia.Referencia);
    end, 'Referências');
end;

end.
