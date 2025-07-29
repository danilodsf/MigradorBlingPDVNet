unit MigraBling.Model.Interfaces.DAO;

interface

uses
  System.Generics.Collections;

type
  IDAOTabelasPDVNET<T: class> = interface
    ['{DC255E91-0281-4E37-B738-80F1CA9B7D52}']
    function Ler: TObjectList<T>;
  end;

  IDAOMovimentosPDVNET<T: class> = interface
    ['{2A88EFEB-CFAA-42E1-801E-8144B3F55E01}']
    function Ler: TObjectList<T>;
  end;

  IDAOBling<T: class> = interface
    ['{787C90A8-3A2B-4BC5-B75F-EC6B4AC99F3F}']
    procedure Persistir(AListObj: TObjectList<T>);
  end;

  IDAOBlingReferencias<T: class> = interface
    ['{6DF0F053-06D6-41F6-8709-4365EA1D9B72}']
    procedure ApagarTudo;
  end;

  IDAOTabelasSQLite<T: class> = interface
    ['{0923F88A-CA2B-4973-A94A-E9826998E1AF}']
    function Ler: TObjectList<T>;
    procedure Persistir(AListObj: TObjectList<T>);
    procedure GravarIDsBling(AListObj: TObjectList<T>);
  end;

  IDAOConfiguracoesSQLite<T: class> = interface
    ['{C00EA538-3BC1-460F-9DF6-467DA90DE7AF}']
    procedure Criar(AObj: T);
    procedure Atualizar(AObj: T);
    function Ler(AID: integer): T;
  end;

  IDAOMovimentosSQLite<T: class> = interface
    ['{86A89BA0-1805-40F9-8963-195DD7C610A5}']
    procedure Criar(AListObj: TObjectList<T>);
  end;

implementation

end.
