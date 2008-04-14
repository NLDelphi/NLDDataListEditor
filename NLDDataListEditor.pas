
//*******************************************************
//
//  NLDDataListEditor
//  Versie 0.5
//
//  Copyright (c) 2002 Aikema.nl
//
//  NLDDataListEditor is een DB-aware variant van
//  TValueListEditor.
//
//  Installatie
//  -----------
//  Installeer component via Delphi IDE, Menu Component ->
//	 Install Component
//
//  Gebruik
//  -------
//  Verbind property Datasource met een Datasource
//
//  Commentaar
//  ----------
//	 Op- of aanmerkingen graag via jos@aikema.nl
//*******************************************************

unit NLDDataListEditor;

interface

uses
  SysUtils, Classes, Controls, Grids, ValEdit, DB, Graphics;

type
  TNLDDataListEditor = class;

  TNLDDataEditorDatalink = class (TDataLink)
  private
    FEditor: TNLDDataListEditor;
  protected
    procedure ActiveChanged; override;
    procedure DatasetChanged; override;
    procedure RecordChanged(Field: TField); override;
    procedure DataSetScrolled(Distance: Integer); override;
  public
    constructor Create(AEditor : TNLDDataListEditor);
    destructor Destroy; override;
  end;

  TNLDDataListEditor = class(TValueListEditor)
  private
    FCanChange : Boolean;
    FDatalink : TNLDDataEditorDatalink;
    procedure DataChanged;
    procedure FillFieldList;
    function GetDatasource: TDataSource;
    procedure SetDatasource(AValue: TDataSource);
  protected
    procedure DoChange(Sender : TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Notification(AComponent : TComponent;
			Operation : TOperation); override;
  published
    property Datasource: TDataSource read GetDatasource write SetDatasource;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Standard', [TNLDDataListEditor]);
end;

{ TNLDDataListEditor }

constructor TNLDDataListEditor.Create(AOwner: TComponent);
begin
	inherited Create(AOwner);
	TitleCaptions.Add('Field');
	TitleCaptions.Add('Value');
   FDatalink:=TNLDDataEditorDatalink.Create(self);
   Width:=240;
	Height:=291;
   ColWidths[0]:=119;
	ColWidths[1]:=119;
   Color:=clBtnFace;
   OnStringsChange := DoChange;
   FCanChange:=false;
end;

procedure TNLDDataListEditor.DataChanged;
begin
	FCanChange:=false;
	FillFieldList;
   FCanChange:=true;
end;

destructor TNLDDataListEditor.Destroy;
begin
   if FDatalink <> nil then
   begin
		FDatalink.Free;
		FDatalink:=nil;
   end;
	inherited Destroy;
end;

procedure TNLDDataListEditor.DoChange(Sender: TObject);
begin
	if not (csDesigning in ComponentState) and FCanChange then
	begin
   	FDatalink.Edit;
      //case FDatalink.DataSet.Fields[Row].DataType of
      //  ftString :
      FDatalink.Dataset.FieldByName(Cells[0,Row]).AsString:=Cells[1,Row];
      //  ftInteger : FDatalink.Dataset.FieldByName(Cells[0,Row]).AsInteger:=StrToInt(Cells[1,Row]);
      //end;
  end;
end;

procedure TNLDDataListEditor.FillFieldList;
var
  i: Integer;
begin
   Strings.Clear;
   if FDatalink <> nil then
	begin
   	if FDatalink.Active then
      begin
      	for i:=0 to FDatalink.DataSet.FieldCount-1 do
         	begin
            	Refresh;
               InsertRow(FDatalink.Dataset.FieldList.Fields[i].FieldName,FDatalink.Dataset.FieldList.Fields[i].AsString,true);
         	end;
   	end
	end;
end;

function TNLDDataListEditor.GetDatasource: TDataSource;
begin
   Result := FDataLink.DataSource;
end;

procedure TNLDDataListEditor.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  	if (FDataLink <> nil) then
      if (AComponent = DataSource)  then
        DataSource := nil
end;

procedure TNLDDataListEditor.SetDatasource(AValue: TDataSource);
begin
	if not (csDesigning in ComponentState) then
  begin
     FDatalink.DataSource := AValue;
     Invalidate;
   end
   else
    if not (csLoading in ComponentState) then
       begin
           FDatalink.DataSource := AValue;
           Invalidate;
        end;
end;

procedure TNLDDataEditorDatalink.ActiveChanged;
begin
	inherited ActiveChanged;
	FEditor.DataChanged;
end;

constructor TNLDDataEditorDatalink.Create(AEditor: TNLDDataListEditor);
begin
	inherited Create;
	FEditor := AEditor;
end;

destructor TNLDDataEditorDatalink.Destroy;
begin
	inherited Destroy;
end;

procedure TNLDDataEditorDatalink.DatasetChanged;
begin
	inherited DatasetChanged;
	FEditor.DataChanged;
end;

procedure TNLDDataEditorDatalink.DataSetScrolled(Distance: Integer);
begin
	inherited DataSetScrolled(Distance);
	FEditor.DataChanged;
end;


procedure TNLDDataEditorDatalink.RecordChanged(Field: TField);
begin
	inherited RecordChanged(Field);
	FEditor.DataChanged;
end;

end.
