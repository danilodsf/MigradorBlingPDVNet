unit MigraBling.Model.ReferenciasImagens;

interface

uses
  System.Classes;

type
  TReferenciaImagem = class
  private
    FSeq: integer;
    FImagem: TStream;
  public
    property Seq: integer read FSeq write FSeq;
    property Imagem: TStream read FImagem write FImagem;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TReferenciaImagem }

constructor TReferenciaImagem.Create;
begin
  FImagem := TMemoryStream.Create;
end;

destructor TReferenciaImagem.Destroy;
begin
  FImagem.Free;
  inherited;
end;

end.
