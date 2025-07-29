unit MigraBling.Model.Services.SubServices.Bling;

interface

uses
  MigraBling.Model.Interfaces.DAO,
  MigraBling.Model.Services.SubServices.Interfaces.Bling,
  MigraBling.Model.Services.SubServices.Interfaces.Auth,
  MigraBling.Model.Services.SubServices.Interfaces.RegistrosMovimentados,
  MigraBling.Model.Services.SubServices.Bling.DAOCores,
  MigraBling.Model.Services.SubServices.Bling.DAOTamanhos,
  MigraBling.Model.Services.SubServices.Bling.DAOCategorias,
  MigraBling.Model.Services.SubServices.Bling.DAODepartamentos,
  MigraBling.Model.Services.SubServices.Bling.DAOColecoes,
  MigraBling.Model.Services.SubServices.Bling.DAOGrupos,
  MigraBling.Model.Services.SubServices.Bling.DAOMateriais,
  MigraBling.Model.Services.SubServices.Bling.DAOFiliais,
  MigraBling.Model.Services.SubServices.Bling.DAOReferencias,
  MigraBling.Model.Services.SubServices.Bling.DAOSaldos,
  MigraBling.Model.Cores,
  MigraBling.Model.Tamanhos,
  MigraBling.Model.Categorias,
  MigraBling.Model.Departamentos,
  MigraBling.Model.Colecoes,
  MigraBling.Model.Grupos,
  MigraBling.Model.Materiais,
  MigraBling.Model.Filiais,
  MigraBling.Model.Referencias,
  MigraBling.Model.Saldos;

type
  TBlingService = class(TInterfacedObject, IBlingService)
  private
    FCores: IDAOBling<TCor>;
    FTamanhos: IDAOBling<TTamanho>;
    FCategorias: IDAOBling<TCategoria>;
    FDepartamentos: IDAOBling<TDepartamento>;
    FColecoes: IDAOBling<TColecao>;
    FGrupos: IDAOBling<TGrupo>;
    FMateriais: IDAOBling<TMaterial>;
    FFiliais: IDAOBling<TFilial>;
    FReferencias: IDAOBling<TReferencia>;
    FReferenciasExtras: IDAOBlingReferencias<TReferencia>;
    FSaldos: IDAOBling<TSaldo>;
  public
    procedure GravarMovimentosDeCadastros(AValue: IRegistrosMovimentados);
    procedure GravarMovimentosDeProdutos(AValue: IRegistrosMovimentados);
    procedure LimparProdutos;
    constructor Create(AAuth: IModelAuth);
  end;

implementation

{ TBlingService }

constructor TBlingService.Create(AAuth: IModelAuth);
begin
  FCategorias := TDAOCategoriasBling.Create(AAuth);
  FDepartamentos := TDAODepartamentosBling.Create(AAuth);
  FColecoes := TDAOColecoesBling.Create(AAuth);
  FGrupos := TDAOGruposBling.Create(AAuth);
  FMateriais := TDAOMateriaisBling.Create(AAuth);
  FFiliais := TDAOFiliaisBling.Create(AAuth);
  FReferencias := TDAOReferenciasBling.Create(AAuth);
  FReferenciasExtras := TDAOReferenciasBling.Create(AAuth);
  FSaldos := TDAOSaldosBling.Create(AAuth);
  FCores := TDAOCoresBling.Create(AAuth);
  FTamanhos := TDAOTamanhosBling.Create(AAuth);
end;

procedure TBlingService.GravarMovimentosDeCadastros(AValue: IRegistrosMovimentados);
begin
  FCategorias.Persistir(AValue.BuscarCategorias);
  FDepartamentos.Persistir(AValue.BuscarDepartamentos);
  FColecoes.Persistir(AValue.BuscarColecoes);
  FGrupos.Persistir(AValue.BuscarGrupos);
  FMateriais.Persistir(AValue.BuscarMateriais);
  FFiliais.Persistir(AValue.BuscarFiliais);
  FCores.Persistir(AValue.BuscarCores);
  FTamanhos.Persistir(AValue.BuscarTamanhos);
end;

procedure TBlingService.GravarMovimentosDeProdutos(AValue: IRegistrosMovimentados);
begin
  FReferencias.Persistir(AValue.BuscarReferencias);
  FSaldos.Persistir(AValue.BuscarSaldos);
end;

procedure TBlingService.LimparProdutos;
begin
  FReferenciasExtras.ApagarTudo;
end;

end.

