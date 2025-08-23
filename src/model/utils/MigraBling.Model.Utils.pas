unit MigraBling.Model.Utils;

interface

uses
  VCL.Forms,
  System.SysUtils,
  DateUtils;

function getAppDir: string;
function IfThen(ACondition: Boolean; ATrueValue: Variant; AFalseValue: Variant): Variant;
function RemoverAcentos(const Texto: string): string;
function getDataSQLite(AValue: string): TDateTime;
function setDataSQLite(AValue: TDateTime): string;
function TextoParaHTML(const ATexto: string): string;
function GetEnv(const AName: string): string;

implementation

function getAppDir: string;
begin
  result := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName));
end;

function IfThen(ACondition: Boolean; ATrueValue: Variant; AFalseValue: Variant): Variant;
begin
  if ACondition then
    result := ATrueValue
  else
    result := AFalseValue;
end;

function RemoverAcentos(const Texto: string): string;
const
  Acentos: array [0 .. 20] of Char = ('á', 'Á', 'à', 'ã', 'Ã', 'â', 'Â', 'é', 'É', 'è', 'È', 'ê',
    'Ê', 'í', 'Í', 'ó', 'õ', 'Ó', 'Õ', 'ç', 'Ç');
  SemAcentos: array [0 .. 20] of Char = ('a', 'A', 'a', 'a', 'A', 'a', 'A', 'e', 'E', 'e', 'E', 'e',
    'E', 'i', 'I', 'o', 'o', 'O', 'O', 'c', 'C');
var
  I, J: Integer;
  Ch: Char;
begin
  result := Texto;
  for I := 1 to Length(result) do
  begin
    Ch := result[I];
    for J := 0 to High(Acentos) do
    begin
      if Ch = Acentos[J] then
      begin
        result[I] := SemAcentos[J];
        Break;
      end;
    end;
  end;
end;

function getDataSQLite(AValue: string): TDateTime;
var
  aa, mm, dd, hh, nn, ss: word;
begin
  if AValue = '' then
    Exit(0);

  aa := copy(AValue, 1, 4).ToInteger;
  mm := copy(AValue, 6, 2).ToInteger;
  dd := copy(AValue, 9, 2).ToInteger;
  hh := copy(AValue, 12, 2).ToInteger;
  nn := copy(AValue, 15, 2).ToInteger;
  ss := copy(AValue, 18, 2).ToInteger;

  result := EncodeDateTime(aa, mm, dd, hh, nn, ss, 0);
end;

function setDataSQLite(AValue: TDateTime): string;
begin
  result := FormatDateTime('yyyy-mm-dd hh:nn:ss', AValue);
end;

function TextoParaHTML(const ATexto: string): string;
begin
  result := StringReplace(ATexto, sLineBreak, '<br/>', [rfReplaceAll]);
  result := StringReplace(result, #10, '<br/>', [rfReplaceAll]);
end;

function GetEnv(const AName: string): string;
begin
  result := GetEnvironmentVariable(AName);
end;

end.
