unit Lang.PtBr;

interface

procedure ApplyPortugueseStrings;

implementation

uses
  Vcl.Consts, Windows;

procedure OverrideResourceString(AResString: PResStringRec; ANewValue: PChar);
var
  POldProtect: DWORD;
begin
  VirtualProtect(AResString, SizeOf(AResString^), PAGE_EXECUTE_READWRITE, @POldProtect);
  AResString^.Identifier := Integer(ANewValue);
  VirtualProtect(AResString, SizeOf(AResString^), POldProtect, @POldProtect);
end;

procedure ApplyPortugueseStrings;
begin
  OverrideResourceString(@SMsgDlgWarning, 'Aviso');
  OverrideResourceString(@SMsgDlgError, 'Erro');
  OverrideResourceString(@SMsgDlgInformation, 'Informa��o');
  OverrideResourceString(@SMsgDlgConfirm, 'Confirma��o');
  OverrideResourceString(@SMsgDlgYes, 'Sim');
  OverrideResourceString(@SYesButton, 'Sim');
  OverrideResourceString(@SMsgDlgNo, 'N�o');
  OverrideResourceString(@SNoButton, 'N�o');
  OverrideResourceString(@SMsgDlgOK, 'OK');
  OverrideResourceString(@SOKButton, 'OK');
  OverrideResourceString(@SMsgDlgCancel, 'Cancelar');
  OverrideResourceString(@SCancelButton, 'Cancelar');
  OverrideResourceString(@SMsgDlgRetry, 'Tentar Novamente');
  OverrideResourceString(@SMsgDlgIgnore, 'Ignorar');
  OverrideResourceString(@SMsgDlgAbort, 'Abortar');
  OverrideResourceString(@SMsgDlgAll, 'Todos');
  OverrideResourceString(@SMsgDlgNoToAll, 'N�o para Todos');
  OverrideResourceString(@SMsgDlgYesToAll, 'Sim para Todos');
end;

end.

