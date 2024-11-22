unit uExploreDevice;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics,
  FMX.Dialogs, System.Bluetooth, System.Generics.Collections,
  FMX.Controls.Presentation, FMX.StdCtrls, DateUtils, uExploreDeviceBase;

type
  TFMainForm = class(TForm)
    PMain: TPanel;
    sbconnect: TSpeedButton;
    AniIndicator: TAniIndicator;
    tmMainRefresher: TTimer;
    SkLclock: TLabel;
    SkLBattery: TLabel;
    SkLTemp: TLabel;
    SkLGradus: TLabel;
    SkLHum: TLabel;
    procedure sbconnectClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    ExploreDeviceBase: TExploreDeviceBase;
  public
  end;

  procedure TimeChange(value: String);
  procedure BatteryChange(value: String);
  procedure HumanityChange(value: String);
  procedure TemperatureChange(value: String);
  procedure UnitChange(value: String);
  procedure ConnectChange(value: boolean);
  procedure WaitingState(value: boolean);

var
  FMainForm: TFMainForm;

implementation

{$R *.fmx}
{$R *.NmXhdpiPh.fmx ANDROID}

procedure BatteryChange(value: String);
begin
  if Assigned(FMainForm.SkLBattery) then
  begin
    FMainForm.SkLBattery.Text:=value;
  end;
end;

procedure ConnectChange(value: boolean);
begin
  if Assigned(FMainForm.sbconnect) then
  begin
    if value then FMainForm.sbconnect.Text:='Отсоединиться' else
      FMainForm.sbconnect.Text:='Соединиться';
  end;
end;

procedure HumanityChange(value: String);
begin
  if Assigned(FMainForm.SkLHum) then
  begin
    Application.ProcessMessages;
    FMainForm.SkLHum.Text:=value;
    Application.ProcessMessages;
  end;
end;

procedure TemperatureChange(value: String);
begin
  if Assigned(FMainForm.SkLTemp) then
  begin
    Application.ProcessMessages;
    FMainForm.SkLTemp.Text:=value;
    Application.ProcessMessages;
  end;
end;

procedure TimeChange(value: String);
begin
  if Assigned(FMainForm.SkLclock) then
  begin
    Application.ProcessMessages;
    FMainForm.SkLclock.Text:=value;
    Application.ProcessMessages;
  end;
end;

procedure UnitChange(value: String);
begin
  if Assigned(FMainForm.SkLGradus) then
  begin
    Application.ProcessMessages;
    FMainForm.SkLGradus.Text:=value;
    Application.ProcessMessages;
  end;
end;

procedure WaitingState(value: boolean);
begin
  if Assigned(FMainForm.AniIndicator) then
  begin
    if value then
    begin
      FMainForm.AniIndicator.Visible:=value;
      FMainForm.AniIndicator.Enabled:=value;
    end else
    begin
      FMainForm.AniIndicator.Enabled:=value;
      FMainForm.AniIndicator.Visible:=value;
    end;
  end;

end;

procedure TFMainForm.FormCreate(Sender: TObject);
begin
  AniIndicator.Enabled:=false;
  AniIndicator.Visible:=false;
end;

procedure TFMainForm.FormDestroy(Sender: TObject);
begin
  if Assigned(ExploreDeviceBase) then ExploreDeviceBase.Free;
end;


procedure TFMainForm.sbconnectClick(Sender: TObject);
begin
  if ExploreDeviceBase<>nil then
  begin
    ExploreDeviceBase.changeStatus;
    ExploreDeviceBase.Free;
  end else
  begin
    ExploreDeviceBase:=TExploreDeviceBase.Create;
    try
      ExploreDeviceBase.OnBatteryChange:=BatteryChange;
      ExploreDeviceBase.OnConnectChange:=ConnectChange;
      ExploreDeviceBase.OnHumanityChange:=HumanityChange;
      ExploreDeviceBase.OnTemperatureChange:=TemperatureChange;
      ExploreDeviceBase.OnTimeChange:=TimeChange;
      ExploreDeviceBase.OnUnitChange:=UnitChange;
      ExploreDeviceBase.OnWaitingState:=WaitingState;

      ExploreDeviceBase.changeStatus;
    finally

    end;
  end;
end;


end.
