program MigraBling;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  Lang.PtBr in 'src\model\utils\Lang.PtBr.pas',
  Winapi.Windows,
  MigraBling.View.Main in 'src\view\MigraBling.View.Main.pas' {FrmMain},
  MigraBling.Controller.Interfaces.Sincronizador in 'src\controller\interfaces\MigraBling.Controller.Interfaces.Sincronizador.pas',
  MigraBling.Controller.Sincronizador in 'src\controller\MigraBling.Controller.Sincronizador.pas',
  MigraBling.Model.Services.Sincronizador in 'src\model\services\MigraBling.Model.Services.Sincronizador.pas',
  MigraBling.Model.Utils in 'src\model\utils\MigraBling.Model.Utils.pas',
  MigraBling.Model.Services.SubServices.Bling.Auth in 'src\model\services\subservices\bling\MigraBling.Model.Services.SubServices.Bling.Auth.pas',
  MigraBling.Model.Categorias in 'src\model\classes\MigraBling.Model.Categorias.pas',
  MigraBling.Model.Services.SubServices.Bling.API in 'src\model\services\subservices\bling\consts\MigraBling.Model.Services.SubServices.Bling.API.pas',
  MigraBling.Model.Services.SubServices.Bling.DAOCategorias in 'src\model\services\subservices\bling\dao\MigraBling.Model.Services.SubServices.Bling.DAOCategorias.pas',
  MigraBling.Model.Services.Interfaces.Sincronizador in 'src\model\services\interfaces\MigraBling.Model.Services.Interfaces.Sincronizador.pas',
  MigraBling.Model.Services.SubServices.Interfaces.PDVNET in 'src\model\services\subservices\pdvnet\interfaces\MigraBling.Model.Services.SubServices.Interfaces.PDVNET.pas',
  MigraBling.Model.Services.SubServices.Interfaces.Auth in 'src\model\services\subservices\bling\interfaces\MigraBling.Model.Services.SubServices.Interfaces.Auth.pas',
  MigraBling.Model.Interfaces.Conexao in 'src\model\factory\interfaces\MigraBling.Model.Interfaces.Conexao.pas',
  MigraBling.Model.Services.SubServices.SQLite in 'src\model\services\subservices\sqlite\MigraBling.Model.Services.SubServices.SQLite.pas',
  MigraBling.Model.Interfaces.ConexaoFactory in 'src\model\factory\interfaces\MigraBling.Model.Interfaces.ConexaoFactory.pas',
  MigraBling.Model.ConexaoFactory in 'src\model\factory\MigraBling.Model.ConexaoFactory.pas',
  MigraBling.Model.ConexaoFiredac in 'src\model\factory\MigraBling.Model.ConexaoFiredac.pas',
  MigraBling.Model.Interfaces.DAO in 'src\model\interfaces\MigraBling.Model.Interfaces.DAO.pas',
  MigraBling.Model.Configuracao in 'src\model\classes\MigraBling.Model.Configuracao.pas',
  MigraBling.Model.Services.SubServices.SQLite.DAOConfiguracoes in 'src\model\services\subservices\sqlite\dao\MigraBling.Model.Services.SubServices.SQLite.DAOConfiguracoes.pas',
  MigraBling.Model.Interfaces.QueryFactory in 'src\model\factory\interfaces\MigraBling.Model.Interfaces.QueryFactory.pas',
  MigraBling.Model.QueryFactory in 'src\model\factory\MigraBling.Model.QueryFactory.pas',
  MigraBling.Model.Interfaces.Query in 'src\model\factory\interfaces\MigraBling.Model.Interfaces.Query.pas',
  MigraBling.Model.QueryFiredac in 'src\model\factory\MigraBling.Model.QueryFiredac.pas',
  MigraBling.Model.Interfaces.QueryParam in 'src\model\factory\interfaces\MigraBling.Model.Interfaces.QueryParam.pas',
  MigraBling.Model.QueryParamFireDAC in 'src\model\factory\MigraBling.Model.QueryParamFireDAC.pas',
  MigraBling.Model.Services.SubServices.PDVNET.DAOCategorias in 'src\model\services\subservices\pdvnet\dao\MigraBling.Model.Services.SubServices.PDVNET.DAOCategorias.pas',
  MigraBling.Model.Services.SubServices.Interfaces.SQLite in 'src\model\services\subservices\sqlite\interfaces\MigraBling.Model.Services.SubServices.Interfaces.SQLite.pas',
  MigraBling.Model.Services.SubServices.PDVNET in 'src\model\services\subservices\pdvnet\MigraBling.Model.Services.SubServices.PDVNET.pas',
  MigraBling.Model.Services.SubServices.Interfaces.Bling in 'src\model\services\subservices\bling\interfaces\MigraBling.Model.Services.SubServices.Interfaces.Bling.pas',
  MigraBling.Model.Services.SubServices.Bling in 'src\model\services\subservices\bling\MigraBling.Model.Services.SubServices.Bling.pas',
  MigraBling.Model.Services.SubServices.Interfaces.RegistrosMovimentados in 'src\model\services\interfaces\MigraBling.Model.Services.SubServices.Interfaces.RegistrosMovimentados.pas',
  MigraBling.Model.Services.SubServices.PDVNET.RegistrosMovimentados in 'src\model\services\subservices\pdvnet\MigraBling.Model.Services.SubServices.PDVNET.RegistrosMovimentados.pas',
  MigraBling.Model.Services.SubServices.SQLite.DAOCategorias in 'src\model\services\subservices\sqlite\dao\MigraBling.Model.Services.SubServices.SQLite.DAOCategorias.pas',
  MigraBling.Model.Services.SubServices.PDVNET.DAOMovimentos in 'src\model\services\subservices\pdvnet\dao\MigraBling.Model.Services.SubServices.PDVNET.DAOMovimentos.pas',
  MigraBling.Model.Movimentos in 'src\model\classes\MigraBling.Model.Movimentos.pas',
  MigraBling.Model.Services.SubServices.SQLite.DAOMovimentos in 'src\model\services\subservices\sqlite\dao\MigraBling.Model.Services.SubServices.SQLite.DAOMovimentos.pas',
  MigraBling.Model.Services.SubServices.PDVNET.DAODepartamentos in 'src\model\services\subservices\pdvnet\dao\MigraBling.Model.Services.SubServices.PDVNET.DAODepartamentos.pas',
  MigraBling.Model.Departamentos in 'src\model\classes\MigraBling.Model.Departamentos.pas',
  MigraBling.Model.Services.SubServices.SQLite.DAODepartamentos in 'src\model\services\subservices\sqlite\dao\MigraBling.Model.Services.SubServices.SQLite.DAODepartamentos.pas',
  MigraBling.Model.Services.SubServices.SQLite.RegistrosMovimentados in 'src\model\services\subservices\sqlite\MigraBling.Model.Services.SubServices.SQLite.RegistrosMovimentados.pas',
  MigraBling.Model.Interfaces.LogObserver in 'src\model\observer\interfaces\MigraBling.Model.Interfaces.LogObserver.pas',
  MigraBling.Model.LogObserver in 'src\model\observer\MigraBling.Model.LogObserver.pas',
  MigraBling.Model.Services.SubServices.Bling.Response in 'src\model\services\subservices\bling\dao\classes\MigraBling.Model.Services.SubServices.Bling.Response.pas',
  MigraBling.Model.Interfaces.LogSubject in 'src\model\observer\interfaces\MigraBling.Model.Interfaces.LogSubject.pas',
  MigraBling.Model.Services.SubServices.Bling.DAODepartamentos in 'src\model\services\subservices\bling\dao\MigraBling.Model.Services.SubServices.Bling.DAODepartamentos.pas',
  MigraBling.Model.Colecoes in 'src\model\classes\MigraBling.Model.Colecoes.pas',
  MigraBling.Model.Services.SubServices.PDVNET.DAOColecoes in 'src\model\services\subservices\pdvnet\dao\MigraBling.Model.Services.SubServices.PDVNET.DAOColecoes.pas',
  MigraBling.Model.Services.SubServices.SQLite.DAOColecoes in 'src\model\services\subservices\sqlite\dao\MigraBling.Model.Services.SubServices.SQLite.DAOColecoes.pas',
  MigraBling.Model.Services.SubServices.Bling.DAOColecoes in 'src\model\services\subservices\bling\dao\MigraBling.Model.Services.SubServices.Bling.DAOColecoes.pas',
  MigraBling.Model.Grupos in 'src\model\classes\MigraBling.Model.Grupos.pas',
  MigraBling.Model.Services.SubServices.PDVNET.DAOGrupos in 'src\model\services\subservices\pdvnet\dao\MigraBling.Model.Services.SubServices.PDVNET.DAOGrupos.pas',
  MigraBling.Model.Services.SubServices.SQLite.DAOGrupos in 'src\model\services\subservices\sqlite\dao\MigraBling.Model.Services.SubServices.SQLite.DAOGrupos.pas',
  MigraBling.Model.Services.SubServices.Bling.DAOGrupos in 'src\model\services\subservices\bling\dao\MigraBling.Model.Services.SubServices.Bling.DAOGrupos.pas',
  MigraBling.Model.Materiais in 'src\model\classes\MigraBling.Model.Materiais.pas',
  MigraBling.Model.Services.SubServices.PDVNET.DAOMateriais in 'src\model\services\subservices\pdvnet\dao\MigraBling.Model.Services.SubServices.PDVNET.DAOMateriais.pas',
  MigraBling.Model.Services.SubServices.SQLite.DAOMateriais in 'src\model\services\subservices\sqlite\dao\MigraBling.Model.Services.SubServices.SQLite.DAOMateriais.pas',
  MigraBling.Model.Services.SubServices.Bling.DAOMateriais in 'src\model\services\subservices\bling\dao\MigraBling.Model.Services.SubServices.Bling.DAOMateriais.pas',
  MigraBling.Model.Referencias in 'src\model\classes\MigraBling.Model.Referencias.pas',
  MigraBling.Model.Services.SubServices.PDVNET.DAOReferencias in 'src\model\services\subservices\pdvnet\dao\MigraBling.Model.Services.SubServices.PDVNET.DAOReferencias.pas',
  MigraBling.Model.Services.SubServices.SQLite.DAOReferencias in 'src\model\services\subservices\sqlite\dao\MigraBling.Model.Services.SubServices.SQLite.DAOReferencias.pas',
  MigraBling.Model.Cores in 'src\model\classes\MigraBling.Model.Cores.pas',
  MigraBling.Model.Tamanhos in 'src\model\classes\MigraBling.Model.Tamanhos.pas',
  MigraBling.Model.Services.SubServices.PDVNET.DAOCores in 'src\model\services\subservices\pdvnet\dao\MigraBling.Model.Services.SubServices.PDVNET.DAOCores.pas',
  MigraBling.Model.Services.SubServices.SQLite.DAOCores in 'src\model\services\subservices\sqlite\dao\MigraBling.Model.Services.SubServices.SQLite.DAOCores.pas',
  MigraBling.Model.Services.SubServices.PDVNET.DAOTamanhos in 'src\model\services\subservices\pdvnet\dao\MigraBling.Model.Services.SubServices.PDVNET.DAOTamanhos.pas',
  MigraBling.Model.Services.SubServices.SQLite.DAOTamanhos in 'src\model\services\subservices\sqlite\dao\MigraBling.Model.Services.SubServices.SQLite.DAOTamanhos.pas',
  MigraBling.Model.Services.SubServices.Bling.DAOReferencias in 'src\model\services\subservices\bling\dao\MigraBling.Model.Services.SubServices.Bling.DAOReferencias.pas',
  MigraBling.Model.Filiais in 'src\model\classes\MigraBling.Model.Filiais.pas',
  MigraBling.Model.Services.SubServices.PDVNET.DAOFiliais in 'src\model\services\subservices\pdvnet\dao\MigraBling.Model.Services.SubServices.PDVNET.DAOFiliais.pas',
  MigraBling.Model.Services.SubServices.SQLite.DAOFiliais in 'src\model\services\subservices\sqlite\dao\MigraBling.Model.Services.SubServices.SQLite.DAOFiliais.pas',
  MigraBling.Model.Services.SubServices.Bling.DAOFiliais in 'src\model\services\subservices\bling\dao\MigraBling.Model.Services.SubServices.Bling.DAOFiliais.pas',
  MigraBling.Model.TabelaPrecos in 'src\model\classes\MigraBling.Model.TabelaPrecos.pas',
  MigraBling.Model.Services.SubServices.PDVNET.DAOTabelaPrecos in 'src\model\services\subservices\pdvnet\dao\MigraBling.Model.Services.SubServices.PDVNET.DAOTabelaPrecos.pas',
  MigraBling.Model.Services.SubServices.SQLite.DAOTabelaPrecos in 'src\model\services\subservices\sqlite\dao\MigraBling.Model.Services.SubServices.SQLite.DAOTabelaPrecos.pas',
  MigraBling.Model.Precos in 'src\model\classes\MigraBling.Model.Precos.pas',
  MigraBling.Model.Services.SubServices.PDVNET.DAOPrecos in 'src\model\services\subservices\pdvnet\dao\MigraBling.Model.Services.SubServices.PDVNET.DAOPrecos.pas',
  MigraBling.Model.Services.SubServices.SQLite.DAOPrecos in 'src\model\services\subservices\sqlite\dao\MigraBling.Model.Services.SubServices.SQLite.DAOPrecos.pas',
  MigraBling.Model.Variacoes in 'src\model\classes\MigraBling.Model.Variacoes.pas',
  MigraBling.Model.Services.SubServices.PDVNET.DAOVariacoes in 'src\model\services\subservices\pdvnet\dao\MigraBling.Model.Services.SubServices.PDVNET.DAOVariacoes.pas',
  MigraBling.Model.Services.SubServices.SQLite.DAOVariacoes in 'src\model\services\subservices\sqlite\dao\MigraBling.Model.Services.SubServices.SQLite.DAOVariacoes.pas',
  MigraBling.Model.Saldos in 'src\model\classes\MigraBling.Model.Saldos.pas',
  MigraBling.Model.Services.SubServices.PDVNET.DAOSaldos in 'src\model\services\subservices\pdvnet\dao\MigraBling.Model.Services.SubServices.PDVNET.DAOSaldos.pas',
  MigraBling.Model.TabelaDados in 'src\model\classes\MigraBling.Model.TabelaDados.pas',
  MigraBling.Model.Services.SubServices.SQLite.DAOSaldos in 'src\model\services\subservices\sqlite\dao\MigraBling.Model.Services.SubServices.SQLite.DAOSaldos.pas',
  MigraBling.Model.BaseModel in 'src\model\classes\MigraBling.Model.BaseModel.pas',
  MigraBling.Model.Services.SubServices.SQLite.DAO in 'src\model\services\subservices\sqlite\dao\MigraBling.Model.Services.SubServices.SQLite.DAO.pas',
  MigraBling.Model.MapaEntidades in 'src\model\classes\MigraBling.Model.MapaEntidades.pas',
  MigraBling.Model.Services.SubServices.Bling.DAOSaldos in 'src\model\services\subservices\bling\dao\MigraBling.Model.Services.SubServices.Bling.DAOSaldos.pas',
  MigraBling.Model.MovimentoEstoque in 'src\model\classes\MigraBling.Model.MovimentoEstoque.pas',
  MigraBling.Model.Services.SubServices.SQLite.DAOVendas in 'src\model\services\subservices\sqlite\dao\MigraBling.Model.Services.SubServices.SQLite.DAOVendas.pas',
  MigraBling.Model.Log in 'src\model\utils\MigraBling.Model.Log.pas',
  MigraBling.Model.AppControl in 'src\model\utils\MigraBling.Model.AppControl.pas',
  MigraBling.Model.Services.SubServices.Bling.DAOCores in 'src\model\services\subservices\bling\dao\MigraBling.Model.Services.SubServices.Bling.DAOCores.pas',
  MigraBling.Model.Services.SubServices.Bling.DAOTamanhos in 'src\model\services\subservices\bling\dao\MigraBling.Model.Services.SubServices.Bling.DAOTamanhos.pas',
  MigraBling.Model.Services.Backup in 'src\model\services\backup\MigraBling.Model.Services.Backup.pas',
  MigraBling.Model.Services.SubServices.Connection in 'src\model\services\subservices\connection\MigraBling.Model.Services.SubServices.Connection.pas',
  MigraBling.Model.Services.SubServices.SQLite.CriadorBD in 'src\model\services\subservices\sqlite\MigraBling.Model.Services.SubServices.SQLite.CriadorBD.pas';

{$R *.res}

var
  AppMutex: THandle;
  MsgID: UINT;
  MainWindow: HWND;

begin
  AppMutex := CreateMutex(nil, True, 'SincronizadorPDVNetBling');

  MsgID := RegisterWindowMessage('WM_RESTORE_SINCRONIZADOR');

  if (AppMutex = 0) or (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    MainWindow := FindWindow(nil, 'Migrador Bling');
    if MainWindow <> 0 then
      PostMessage(MainWindow, MsgID, 0, 0);

    ExitProcess(0);
  end;

  ReportMemoryLeaksOnShutdown := true;
  Application.ShowMainForm := False;
  Application.Initialize;
  ApplyPortugueseStrings;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  FrmMain.CustomRestoreMsg := MsgID;

  Application.Run;
end.
