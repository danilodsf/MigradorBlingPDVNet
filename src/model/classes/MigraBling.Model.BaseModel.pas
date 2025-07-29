unit MigraBling.Model.BaseModel;

interface

type
  TBaseModel = class
  private
    FID_Movimento: string;
    FID_Bling: string;
    FID_CampoCustomizavel: string;
  public
    property ID_Movimento: string read FID_Movimento write FID_Movimento;
    property ID_Bling: string read FID_Bling write FID_Bling;
    property ID_CampoCustomizavel: string read FID_CampoCustomizavel write FID_CampoCustomizavel;
  end;

implementation

end.
