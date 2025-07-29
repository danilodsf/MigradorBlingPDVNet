unit MigraBling.Model.Services.SubServices.Bling.DAOReferencias;

interface

uses
  MigraBling.Model.Services.SubServices.Bling.API,
  RESTRequest4D,
  System.JSON,
  Rest.Types,
  Rest.JSON,
  System.SysUtils,
  MigraBling.Model.Referencias,
  MigraBling.Model.Interfaces.DAO,
  System.Generics.Collections,
  MigraBling.Model.Services.SubServices.Interfaces.Auth,
  MigraBling.Model.LogObserver,
  MigraBling.Model.Utils,
  MigraBling.Model.Services.SubServices.Bling.Response,
  System.Classes, MigraBling.Model.Variacoes, System.Threading,
  MigraBling.Model.AppControl, MigraBling.Model.BaseModel;

type
  TDAOReferenciasBling = class(TInterfacedObject, IDAOBling<TReferencia>,
    IDAOBlingReferencias<TReferencia>)
  private
    FAuth: IModelAuth;
    procedure Criar(AObj: TReferencia);
    procedure Apagar(AObj: TBaseModel; ACodProduto: string); overload;
    procedure Apagar(AID: string); overload;
    procedure Atualizar(AObj: TReferencia);
    function Ler(AID: string): TJSONObject; overload;
    function Ler: TJSONObject; overload;
    function ObterJSONProduto(AObj: TReferencia; AExibirIDs: Boolean = false): TJSONObject;
    procedure AdicionarCampoCustomizado(AIDBling, ACampo, AVinculo, ADescricao: string;
      AJsonArray: TJSONArray; AExibirIDs: Boolean);
  public
    procedure Persistir(AListObj: TObjectList<TReferencia>);
    procedure ApagarTudo;
    procedure CorrigirTudo(AListObj: TObjectList<TReferencia>);
    constructor Create(AAuth: IModelAuth);
  end;

implementation

uses
  MigraBling.Model.Services.SubServices.Bling.Auth;

{ TDAOReferenciasBling }

procedure TDAOReferenciasBling.CorrigirTudo(AListObj: TObjectList<TReferencia>);
var
  referencia: TReferencia;
  JSONArrayCampos: TJSONArray;
  JSONLeitura, JSONCampo: TJSONObject;
  I: Integer;
begin
  // só é usado para ajustar registros que gravaram errado
  exit;
  for referencia in AListObj do
  begin
    if TAppControl.AppFinalizando then
      break;
    JSONLeitura := Ler(referencia.ID_Bling);
    try
      JSONArrayCampos := JSONLeitura.GetValue<TJSONObject>('data')
        .GetValue<TJSONArray>('camposCustomizados');
      if Assigned(JSONArrayCampos) then
      begin
        for I := 0 to Pred(JSONArrayCampos.Count) do
        begin
          JSONCampo := JSONArrayCampos[I] as TJSONObject;
          if JSONCampo.GetValue<string>('idCampoCustomizado') = referencia.Categoria_Campo then
            referencia.Categoria_Vinculo := JSONCampo.GetValue<string>('idVinculo')
          else if JSONCampo.GetValue<string>('idCampoCustomizado') = referencia.Departamento_Campo
          then
            referencia.Departamento_Vinculo := JSONCampo.GetValue<string>('idVinculo')
          else if JSONCampo.GetValue<string>('idCampoCustomizado') = referencia.Material_Campo then
            referencia.Material_Vinculo := JSONCampo.GetValue<string>('idVinculo')
          else if JSONCampo.GetValue<string>('idCampoCustomizado') = referencia.Grupo_Campo then
            referencia.Grupo_Vinculo := JSONCampo.GetValue<string>('idVinculo')
          else if JSONCampo.GetValue<string>('idCampoCustomizado') = referencia.Colecao_Campo then
            referencia.Colecao_Vinculo := JSONCampo.GetValue<string>('idVinculo')
          else if JSONCampo.GetValue<string>('idCampoCustomizado') = referencia.Cor_Campo then
            referencia.Cor_Vinculo := JSONCampo.GetValue<string>('idVinculo')
          else if JSONCampo.GetValue<string>('idCampoCustomizado') = referencia.Tamanho_Campo then
            referencia.Tamanho_Vinculo := JSONCampo.GetValue<string>('idVinculo');
        end;
      end;
    finally
      JSONLeitura.Free;
    end;

    Sleep(500);
  end;
end;

constructor TDAOReferenciasBling.Create(AAuth: IModelAuth);
begin
  FAuth := AAuth;
end;

procedure TDAOReferenciasBling.AdicionarCampoCustomizado(AIDBling, ACampo, AVinculo,
  ADescricao: string; AJsonArray: TJSONArray; AExibirIDs: Boolean);
var
  ACampoCustomizado: TJSONObject;
begin
  if AIDBling <> '' then
  begin
    ACampoCustomizado := TJSONObject.Create;
    ACampoCustomizado.AddPair('idCampoCustomizado', ACampo);
    if ((AExibirIDs) and (AVinculo <> '')) then
      ACampoCustomizado.AddPair('idVinculo', AVinculo);
    ACampoCustomizado.AddPair('valor', AIDBling);
    ACampoCustomizado.AddPair('item', ADescricao);
    AJsonArray.AddElement(ACampoCustomizado);
  end;
end;

function TDAOReferenciasBling.ObterJSONProduto(AObj: TReferencia; AExibirIDs: Boolean): TJSONObject;
var
  JSONBodyVariacao: TJSONObject;
  JSONArrayCampos, JSONArrayCamposVariacoes, JSONArrayVariacoes: TJSONArray;
  variacao: TVariacao;
begin
  Result := TJSONObject.Create;
  JSONArrayCampos := TJSONArray.Create;

  Result.AddPair('nome', AObj.Nome);
  Result.AddPair('codigo', AObj.referencia);
  Result.AddPair('tipo', 'P');
  Result.AddPair('situacao', 'A');

  if AObj.TemAoMenosUmaVariacaoValida then
  begin
    Result.AddPair('formato', 'V'); { V - Produdo com variação }
    Result.AddPair('preco', AObj.Variacoes[0].Preco);
  end
  else
  begin
    Result.AddPair('formato', 'S'); { S - Simples "Variação do produto" }
    Result.AddPair('preco', 1000); // Preço não pode ficar em branco
  end;

  Result.AddPair('descricaoCurta', AObj.Descricao);
  Result.AddPair('descricaoComplementar', AObj.Descricao_Complementar);
  Result.AddPair('marca', 'Split Fashion'); { Criar configuração para não ficar fixo }
  Result.AddPair('unidade', AObj.Unidade);
  Result.AddPair('pesoLiquido', AObj.Peso);
  Result.AddPair('pesoBruto', AObj.Peso);
  Result.AddPair('tipoProducao', 'P'); { P - própria, T - terceiros }
  Result.AddPair('condicao', 1); { 0 - Não especificado, 1 - Novo, 2 - Usado, 3 - Recondicionado }
  //Result.AddPair('categoria', TJSONObject.Create.AddPair('id', AObj.Categoria_ID_Bling));
  Result.AddPair('tributacao', TJSONObject.Create.AddPair('origem', 0).AddPair('ncm', AObj.NCM));
  Result.AddPair('dimensoes', TJSONObject.Create.AddPair('largura', AObj.Largura).AddPair('altura',
    AObj.Altura).AddPair('profundidade', AObj.Profundidade).AddPair('unidadeMedida', 1));

   AdicionarCampoCustomizado(AObj.Departamento_ID_Bling, AObj.Departamento_Campo,
   AObj.Departamento_Vinculo, AObj.Departamento, JSONArrayCampos, false);

   AdicionarCampoCustomizado(AObj.Colecao_ID_Bling, AObj.Colecao_Campo, AObj.Colecao_Vinculo,
   AObj.Colecao, JSONArrayCampos, false);

   AdicionarCampoCustomizado(AObj.Grupo_ID_Bling, AObj.Grupo_Campo, AObj.Grupo_Vinculo, AObj.Grupo,
   JSONArrayCampos, false);

   AdicionarCampoCustomizado(AObj.Material_ID_Bling, AObj.Material_Campo, AObj.Material_Vinculo,
   AObj.Material, JSONArrayCampos, false);

   AdicionarCampoCustomizado(AObj.Categoria_ID_Bling, AObj.Categoria_Campo, AObj.Categoria_Vinculo,
   AObj.Categoria, JSONArrayCampos, false);

   AdicionarCampoCustomizado(AObj.Cor_ID_Bling, AObj.Cor_Campo, AObj.Cor_Vinculo, AObj.Cor,
   JSONArrayCampos, false);

   AdicionarCampoCustomizado(AObj.Tamanho_ID_Bling, AObj.Tamanho_Campo, AObj.Tamanho_Vinculo,
   AObj.Tamanho, JSONArrayCampos, false);

  Result.AddPair('camposCustomizados', JSONArrayCampos);

  // var
  // Txt: TStrings;
  //
  // Txt := TStringList.Create;
  // try
  // try
  // Txt.Text := Result.ToJSON;
  // Txt.SaveToFile('json.json');
  // except
  // on E: Exception do
  // raise Exception.Create(E.Message);
  // end;
  // finally
  // Txt.Free;
  // end;

  if AObj.Variacoes.Count > 0 then
  begin
    JSONArrayVariacoes := TJSONArray.Create;
    try
      for variacao in AObj.Variacoes do
      begin
        if ((not variacao.Exibir) and (variacao.ID_Bling <> '')) then
        begin
          if variacao.ID_Bling = 'EXCLUIR' then
            continue;

          TLogSubject.GetInstance.NotifyAll('Apagando variação: ' + variacao.ID);
          Apagar(variacao, variacao.ID);
          continue;
        end;

        if (not variacao.Exibir) then
        begin
          variacao.ID_Bling := 'EXCLUIR';
          continue;
        end;

        JSONBodyVariacao := TJSONObject.Create;
        if AExibirIDs then
          JSONBodyVariacao.AddPair('id', variacao.ID_Bling);
        JSONBodyVariacao.AddPair('nome', AObj.Nome + ' COR: ' + variacao.CorStr + '; TAMANHO: ' +
          variacao.TamanhoStr);
        JSONBodyVariacao.AddPair('codigo', variacao.ID);
        JSONBodyVariacao.AddPair('preco', variacao.Preco);
        JSONBodyVariacao.AddPair('tipo', 'P');
        JSONBodyVariacao.AddPair('condicao', 1);
        { 0 - Não especificado, 1 - Novo, 2 - Usado, 3 - Recondicionado }
        JSONBodyVariacao.AddPair('marca', 'Split Fashion');
        { Criar configuração para não ficar fixo }
        JSONBodyVariacao.AddPair('situacao', 'A');
        JSONBodyVariacao.AddPair('formato', 'S');
        JSONBodyVariacao.AddPair('descricaoCurta', AObj.Descricao);
        JSONBodyVariacao.AddPair('descricaoComplementar', AObj.Descricao_Complementar);
        JSONBodyVariacao.AddPair('unidade', AObj.Unidade);
        JSONBodyVariacao.AddPair('pesoLiquido', AObj.Peso);
        JSONBodyVariacao.AddPair('pesoBruto', AObj.Peso);
        JSONBodyVariacao.AddPair('tipoProducao', 'P'); { P - própria, T - terceiros }
        //JSONBodyVariacao.AddPair('categoria', TJSONObject.Create.AddPair('id',
        //  AObj.Categoria_ID_Bling));
        JSONBodyVariacao.AddPair('tributacao', TJSONObject.Create.AddPair('origem', 0)
          .AddPair('ncm', AObj.NCM));
        JSONBodyVariacao.AddPair('dimensoes', TJSONObject.Create.AddPair('largura', AObj.Largura)
          .AddPair('altura', AObj.Altura).AddPair('profundidade', AObj.Profundidade)
          .AddPair('unidadeMedida', 1));

        JSONArrayCamposVariacoes := TJSONArray.Create;

         AdicionarCampoCustomizado(AObj.Departamento_ID_Bling, AObj.Departamento_Campo,
         AObj.Departamento_Vinculo, AObj.Departamento, JSONArrayCamposVariacoes, false);

         AdicionarCampoCustomizado(AObj.Colecao_ID_Bling, AObj.Colecao_Campo, AObj.Colecao_Vinculo,
         AObj.Colecao, JSONArrayCamposVariacoes, false);

         AdicionarCampoCustomizado(AObj.Grupo_ID_Bling, AObj.Grupo_Campo, AObj.Grupo_Vinculo,
         AObj.Grupo, JSONArrayCamposVariacoes, false);

         AdicionarCampoCustomizado(AObj.Material_ID_Bling, AObj.Material_Campo,
         AObj.Material_Vinculo, AObj.Material, JSONArrayCamposVariacoes, false);

         AdicionarCampoCustomizado(AObj.Categoria_ID_Bling, AObj.Categoria_Campo,
         AObj.Categoria_Vinculo, AObj.Categoria, JSONArrayCamposVariacoes, false);

         AdicionarCampoCustomizado(variacao.Cor_ID_Bling, AObj.Cor_Campo, variacao.Cor_Vinculo,
         variacao.CorStr, JSONArrayCamposVariacoes, false);

         AdicionarCampoCustomizado(variacao.Tamanho_ID_Bling, AObj.Tamanho_Campo,
         variacao.Tamanho_Vinculo, variacao.TamanhoStr, JSONArrayCamposVariacoes, false);

        JSONBodyVariacao.AddPair('camposCustomizados', JSONArrayCamposVariacoes);

        JSONBodyVariacao.AddPair('variacao', TJSONObject.Create.AddPair('nome',
          variacao.Descricao));

        // Txt := TStringList.Create;
        // try
        // try
        // Txt.Text := JSONBodyVariacao.ToJSON;
        // Txt.SaveToFile('json.json');
        // except
        // on E: Exception do
        // raise Exception.Create(E.Message);
        // end;
        // finally
        // Txt.Free;
        // end;

        JSONArrayVariacoes.Add(JSONBodyVariacao);
      end;
    finally
      if AObj.TemAoMenosUmaVariacaoValida then
        Result.AddPair('variacoes', JSONArrayVariacoes)
      else
        JSONArrayVariacoes.Free;
    end;
  end;
end;

procedure TDAOReferenciasBling.Criar(AObj: TReferencia);
var
  Response: IResponse;
  JSONLeitura, JSON, JSONBodyVariacao, JSONVariacoes, JSONCampo: TJSONObject;
  JSONArrayCampos, JSONSaved: TJSONArray;
  errorResponse: TResponseError;
  variacao: TVariacao;
  I: Integer;
begin
  if AObj.Inativo or AObj.Nome.IsEmpty or (not AObj.Exibir) or (AObj.Nome = 'EXCLUIR') then
  begin
    AObj.ID_Bling := 'EXCLUIR';
    exit;
  end;

  errorResponse := nil;
  try
    try
      Response := TRequest.New.BaseURL(C_BASEURL + C_PRODUTOS).Accept(C_ACCEPT)
        .ContentType(CONTENTTYPE_APPLICATION_JSON).TokenBearer(FAuth.AccessToken)
        .AddBody(ObterJSONProduto(AObj)).OnAfterExecute(
        procedure(const Req: IRequest; const Res: IResponse)
        begin
          FAuth.AtualizarToken(Req, Res);
        end).Post;

      if Response.StatusCode = 201 then
      begin
        JSON := TJSONObject.ParseJSONValue(Response.Content) as TJSONObject;
        AObj.ID_Bling := JSON.GetValue<TJSONObject>('data').GetValue<string>('id');
        JSONLeitura := Ler(AObj.ID_Bling);
        try
          JSONVariacoes := JSON.GetValue<TJSONObject>('data').GetValue<TJSONObject>('variations');
          JSONSaved := JSONVariacoes.GetValue<TJSONArray>('saved');
          for I := 0 to Pred(JSONSaved.Count) do
          begin
            JSONBodyVariacao := JSONSaved[I] as TJSONObject;
            for variacao in AObj.Variacoes do
            begin
              if variacao.Descricao = JSONBodyVariacao.GetValue<string>('nomeVariacao') then
              begin
                variacao.ID_Bling := JSONBodyVariacao.GetValue<string>('id');
                break;
              end;
            end;
          end;

          JSONArrayCampos := JSONLeitura.GetValue<TJSONObject>('data')
            .GetValue<TJSONArray>('camposCustomizados');
          if Assigned(JSONArrayCampos) then
          begin
            for I := 0 to Pred(JSONArrayCampos.Count) do
            begin
              JSONCampo := JSONArrayCampos[I] as TJSONObject;
              if JSONCampo.GetValue<string>('idCampoCustomizado') = AObj.Categoria_Campo then
                AObj.Categoria_Vinculo := JSONCampo.GetValue<string>('idVinculo')
              else if JSONCampo.GetValue<string>('idCampoCustomizado') = AObj.Departamento_Campo
              then
                AObj.Departamento_Vinculo := JSONCampo.GetValue<string>('idVinculo')
              else if JSONCampo.GetValue<string>('idCampoCustomizado') = AObj.Material_Campo then
                AObj.Material_Vinculo := JSONCampo.GetValue<string>('idVinculo')
              else if JSONCampo.GetValue<string>('idCampoCustomizado') = AObj.Grupo_Campo then
                AObj.Grupo_Vinculo := JSONCampo.GetValue<string>('idVinculo')
              else if JSONCampo.GetValue<string>('idCampoCustomizado') = AObj.Colecao_Campo then
                AObj.Colecao_Vinculo := JSONCampo.GetValue<string>('idVinculo');
            end;
          end;
        finally
          JSON.Free;
          if Assigned(JSONLeitura) then
            JSONLeitura.Free;
        end;
        exit;
      end;

      errorResponse := TJSON.JsonToObject<TResponseError>(Response.Content);
      raise Exception.Create(errorResponse.error.Message + ' - ' + errorResponse.error.description +
        ' - ' + 'Referências' + '. ' + errorResponse.allErrors);
    except
      on E: Exception do
      begin
        TLogSubject.GetInstance.NotifyAll(E.Message);
      end;
    end;
  finally
    FreeAndNil(errorResponse);
  end;

  Sleep(1000);
end;

function TDAOReferenciasBling.Ler(AID: string): TJSONObject;
var
  Response: IResponse;
begin
  Response := TRequest.New.BaseURL(C_BASEURL + C_PRODUTOS).AddUrlSegment('idProduto', AID)
    .Accept(C_ACCEPT).ContentType(CONTENTTYPE_APPLICATION_JSON).TokenBearer(FAuth.AccessToken)
    .OnAfterExecute(
    procedure(const Req: IRequest; const Res: IResponse)
    begin
      FAuth.AtualizarToken(Req, Res);
    end).Get;

  Result := TJSONObject.ParseJSONValue(Response.Content) as TJSONObject;
end;

function TDAOReferenciasBling.Ler: TJSONObject;
var
  Response: IResponse;
begin
  Response := TRequest.New.BaseURL(C_BASEURL + C_PRODUTOS).Accept(C_ACCEPT)
    .ContentType(CONTENTTYPE_APPLICATION_JSON).AddParam('tipo', 'C').TokenBearer(FAuth.AccessToken)
    .OnAfterExecute(
    procedure(const Req: IRequest; const Res: IResponse)
    begin
      FAuth.AtualizarToken(Req, Res);
    end).Get;

  Result := TJSONObject.ParseJSONValue(Response.Content) as TJSONObject;
end;

procedure TDAOReferenciasBling.ApagarTudo;
begin
  TAppControl.SafeTask(
    procedure
    var
      I: Integer;
      JSON: TJSONObject;
      JSONArray: TJSONArray;
    begin
      while true do
      begin
        if TAppControl.AppFinalizando then
          break;
        JSON := Ler;
        try
          JSONArray := JSON.GetValue<TJSONArray>('data');
          if not Assigned(JSONArray) then
            break;

          for I := 0 to Pred(JSONArray.Count) do
            Apagar(JSONArray[I].GetValue<Int64>('id').ToString);
        finally
          JSON.Free
        end;
      end;
    end);
end;

procedure TDAOReferenciasBling.Atualizar(AObj: TReferencia);
var
  Response: IResponse;
  JSON, JSONBodyVariacao, JSONVariacoes: TJSONObject;
  JSONArrayUpdated, JSONArraySaved: TJSONArray;
  errorResponse: TResponseError;
  variacao: TVariacao;
  I: Integer;
begin
  if (not AObj.Exibir) then
  begin
    Apagar(AObj, AObj.referencia);
    AObj.ID_Bling := 'EXCLUIR';
    exit;
  end;

  if AObj.Inativo or AObj.Nome.IsEmpty or (AObj.Nome = 'EXCLUIR') then
  begin
    AObj.ID_Bling := 'EXCLUIR';
    exit;
  end;

  errorResponse := nil;
  try
    try
      Response := TRequest.New.BaseURL(C_BASEURL + C_PRODUTOS + AObj.ID_Bling).Accept(C_ACCEPT)
        .ContentType(CONTENTTYPE_APPLICATION_JSON).TokenBearer(FAuth.AccessToken)
        .AddBody(ObterJSONProduto(AObj, true)).OnAfterExecute(
        procedure(const Req: IRequest; const Res: IResponse)
        begin
          FAuth.AtualizarToken(Req, Res);
        end).Put;

      if Response.StatusCode = 200 then
      begin
        JSON := TJSONObject.ParseJSONValue(Response.Content) as TJSONObject;
        try
          AObj.ID_Bling := JSON.GetValue<TJSONObject>('data').GetValue<string>('id');
          JSONVariacoes := JSON.GetValue<TJSONObject>('data').GetValue<TJSONObject>('variations');
          JSONArraySaved := JSONVariacoes.GetValue<TJSONArray>('saved');

          for I := 0 to Pred(JSONArraySaved.Count) do
          begin
            JSONBodyVariacao := JSONArraySaved[I] as TJSONObject;
            for variacao in AObj.Variacoes do
            begin
              if variacao.Descricao = JSONBodyVariacao.GetValue<string>('nomeVariacao') then
              begin
                variacao.ID_Bling := JSONBodyVariacao.GetValue<string>('id');
                break;
              end;
            end;
          end;

          JSONArrayUpdated := JSONVariacoes.GetValue<TJSONArray>('updated');

          for I := 0 to Pred(JSONArrayUpdated.Count) do
          begin
            JSONBodyVariacao := JSONArrayUpdated[I] as TJSONObject;
            if JSONBodyVariacao.GetValue<string>('nomeVariacao') = '' then
              Apagar(JSONBodyVariacao.GetValue<string>('id'));
          end;

        finally
          JSON.Free;
        end;
        exit;
      end;

      errorResponse := TJSON.JsonToObject<TResponseError>(Response.Content);

      raise Exception.Create(errorResponse.error.Message + ' - ' + errorResponse.error.description +
        ' - ' + 'Referências' + '. ' + errorResponse.allErrors);
    except
      on E: Exception do
        TLogSubject.GetInstance.NotifyAll(E.Message);
    end;
  finally
    FreeAndNil(errorResponse);
  end;

  Sleep(1000);
end;

procedure TDAOReferenciasBling.Persistir(AListObj: TObjectList<TReferencia>);
var
  Tasks: TArray<ITask>;
begin
  CorrigirTudo(AListObj);
  SetLength(Tasks, 1);
  Tasks[0] := TAppControl.SafeTask(
    procedure
    var
      I: Integer;
    begin
      for I := 0 to Pred(AListObj.Count) do
      begin
        if TAppControl.AppFinalizando then
          break;
        if ((AListObj[I].TipoReg = 'I') or (AListObj[I].ID_Bling = '')) then
        begin
          TLogSubject.GetInstance.NotifyAll('Inserindo referência: ' + AListObj[I].referencia + ' '
            + IntToStr(I + 1) + ' de ' + AListObj.Count.ToString);
          Criar(AListObj[I]);
        end
        else if ((AListObj[I].TipoReg = 'U') and (AListObj[I].ID_Bling <> '')) then
        begin
          TLogSubject.GetInstance.NotifyAll('Atualizando referência: ' + AListObj[I].referencia +
            ' ' + IntToStr(I + 1) + ' de ' + AListObj.Count.ToString);
          Atualizar(AListObj[I]);
        end
        else if ((AListObj[I].TipoReg = 'D') and (AListObj[I].ID_Bling <> '')) then
        begin
          TLogSubject.GetInstance.NotifyAll('Excluindo referência: ' + AListObj[I].referencia + ' '
            + IntToStr(I + 1) + ' de ' + AListObj.Count.ToString);
          Apagar(AListObj[I], AListObj[I].referencia);
        end;
      end;
    end);

  TTask.WaitForAll(Tasks);
end;

procedure TDAOReferenciasBling.Apagar(AObj: TBaseModel; ACodProduto: string);
begin
  if AObj.ID_Bling = 'EXCLUIR' then
    exit;

  try
    TAppControl.SafeTask(
      procedure
      var
        Response: IResponse;
        errorResponse: TResponseError;
      begin
        if TAppControl.AppFinalizando then
          exit;

        errorResponse := nil;
        try
          try
            Response := TRequest.New.BaseURL(C_BASEURL + C_PRODUTOS + AObj.ID_Bling + '/situacoes')
              .Accept(C_ACCEPT).ContentType(CONTENTTYPE_APPLICATION_JSON)
              .AddBody(TJSONObject.Create.AddPair('situacao', 'E')).TokenBearer(FAuth.AccessToken)
              .OnAfterExecute(
              procedure(const Req: IRequest; const Res: IResponse)
              begin
                FAuth.AtualizarToken(Req, Res);
              end).Patch;

            Response := TRequest.New.BaseURL(C_BASEURL + C_PRODUTOS).Accept(C_ACCEPT)
              .AddUrlSegment('idProduto', AObj.ID_Bling).ContentType(CONTENTTYPE_APPLICATION_JSON)
              .TokenBearer(FAuth.AccessToken).OnAfterExecute(
              procedure(const Req: IRequest; const Res: IResponse)
              begin
                FAuth.AtualizarToken(Req, Res);
              end).Delete;

            if Response.StatusCode = 204 then
            begin
              TLogSubject.GetInstance.NotifyAll('Produto: ' + ACodProduto + ' apagado com sucesso');
              AObj.ID_Bling := 'EXCLUIR';
              exit;
            end;

            errorResponse := TJSON.JsonToObject<TResponseError>(Response.Content);

            if errorResponse.error.&type = 'RESOURCE_NOT_FOUND' then
            begin
              AObj.ID_Bling := 'EXCLUIR';
              exit;
            end;

            raise Exception.Create(Response.Content);
          except
            on E: Exception do
            begin
              TLogSubject.GetInstance.NotifyAll('Não foi possível excluir o produto' + #13#10 +
                E.Message);
            end;
          end;
        finally
          FreeAndNil(errorResponse);
        end;
      end);
  finally
    Sleep(1000);
  end;
end;

procedure TDAOReferenciasBling.Apagar(AID: string);
var
  errorResponse: TResponseError;
begin
  errorResponse := nil;
  try
    TAppControl.SafeTask(
      procedure
      var
        Response: IResponse;
      begin
        if TAppControl.AppFinalizando then
          exit;
        try
          Response := TRequest.New.BaseURL(C_BASEURL + C_PRODUTOS + AID + '/situacoes')
            .Accept(C_ACCEPT).ContentType(CONTENTTYPE_APPLICATION_JSON)
            .AddBody(TJSONObject.Create.AddPair('situacao', 'E')).TokenBearer(FAuth.AccessToken)
            .OnAfterExecute(
            procedure(const Req: IRequest; const Res: IResponse)
            begin
              FAuth.AtualizarToken(Req, Res);
            end).Patch;

          Response := TRequest.New.BaseURL(C_BASEURL + C_PRODUTOS).Accept(C_ACCEPT)
            .AddUrlSegment('idProduto', AID).ContentType(CONTENTTYPE_APPLICATION_JSON)
            .TokenBearer(FAuth.AccessToken).OnAfterExecute(
            procedure(const Req: IRequest; const Res: IResponse)
            begin
              FAuth.AtualizarToken(Req, Res);
            end).Delete;

          if Response.StatusCode = 204 then
          begin
            TLogSubject.GetInstance.NotifyAll('Referência: ' + AID + ' apagada com sucesso');
            exit;
          end;

          errorResponse := TJSON.JsonToObject<TResponseError>(Response.Content);

          if errorResponse.error.&type = 'RESOURCE_NOT_FOUND' then
          begin
            exit;
          end;

          raise Exception.Create(Response.Content);
        except
          on E: Exception do
          begin
            TLogSubject.GetInstance.NotifyAll('Não foi possível excluir o produto' + #13#10 +
              E.Message);
          end;
        end;
      end);
  finally
    FreeAndNil(errorResponse);
    Sleep(1000);
  end;
end;

end.
