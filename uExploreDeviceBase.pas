unit uExploreDeviceBase;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, System.Bluetooth, System.Generics.Collections,
  FMX.StdCtrls, DateUtils, FMX.Types,
  //uTimerThread,
  uTimerMP,
  System.Threading;
const
    SERVICE_UUID = '{EBE0CCB0-7A0A-4B0C-8A1A-6FF2997DA3A6}';
    TIME_CHARACTERISTIC_UUID = '{EBE0CCB7-7A0A-4B0C-8A1A-6FF2997DA3A6}'; //# 5 or 4 bytes          READ WRITE
    UNITS_CHARACTERISTIC_UUID = '{EBE0CCBE-7A0A-4B0C-8A1A-6FF2997DA3A6}'; //# 0x00 - F, 0x01 - C    READ WRITE
    UUID_CHARACTERISTIC_HISTORY = '{EBE0CCBC-7A0A-4B0C-8A1A-6FF2997DA3A6}'; //# Last idx 152          READ NOTIFY
    UUID_DATA = '{EBE0CCC1-7A0A-4B0C-8A1A-6FF2997DA3A6}'; //# 3 bytes               READ NOTIFY
    UUID_BATTERY = '{EBE0CCC4-7A0A-4B0C-8A1A-6FF2997DA3A6}'; //# 1 byte                READ
    UUID_NUM_RECORDS = '{EBE0CCB9-7A0A-4B0C-8A1A-6FF2997DA3A6}'; //# 8 bytes               READ
    UUID_RECORD_IDX = '{EBE0CCBA-7A0A-4B0C-8A1A-6FF2997DA3A6}'; //# 4 bytes               READ WRITE
    NAMEDEV = 'LYWSD02';
    defvalBattery = '--%';
    defvalTemperature = '--.--';
    defvalHumanity = '--%';
    defvalTime = '--:--';
    defvalUnit = 'C';
    waitingTime = 30000;
    intervalTime = 5000;

type
  FArrByte8=Array[0..7] of BYTE;
  FArrByte7=Array[0..6] of BYTE;
  FArrByte6=Array[0..5] of BYTE;
  FArrByte5=Array[0..4] of BYTE;
  FArrByte4=Array[0..3] of BYTE;
  FArrByte3=Array[0..2] of BYTE;
  FArrByte2=Array[0..1] of BYTE;

  TUpdateInformationFunction = procedure (value: String);
  TUpdateStateFunction = procedure (value: boolean);

  TDeviceValueStatus = class
    private
      FDate: TDateTime;
      FTime: TDateTime;
      FTimeZone: Integer;
      FBattery: Integer;
      FHumanity: Integer;
      FTemperatureC: Double;
      FTemperatureF: Double;
      FUnits: Integer;

      function HexToInt(Value: String): Longint;
      function ByteToHexStr(B: Byte):String;
    public
      constructor Create;
      destructor Destroy;

      procedure SetUnits(const ACharacteristic: TBluetoothGattCharacteristic);
      procedure SetBattery(const ACharacteristic: TBluetoothGattCharacteristic);
      procedure SetHumanityAndTemerature(const ACharacteristic: TBluetoothGattCharacteristic);
      procedure SetTime(const ACharacteristic: TBluetoothGattCharacteristic);

      property Date: TDateTime read FDate;
      property Time: TDateTime read FTime;
      property TimeZone: Integer read FTimeZone;
      property Battery: Integer read FBattery;
      property Humanity: Integer read FHumanity;
      property TemperatureC: Double read FTemperatureC;
      property TemperatureF: Double read FTemperatureF;
      property Units: Integer read FUnits;
  end;

  TExploreDeviceBase = class
    private
      FBluetoothManagerLE: TBluetoothLEManager;
      FDevice: TBluetoothLEDevice;
      FService: TBluetoothGattService;
      FCharServiceDic: TDictionary<String, String>;
      FStatusText: String;
      FDeviceValueStatus: TDeviceValueStatus;

      FOnTimeChange: TUpdateInformationFunction;
      FOnBatteryChange: TUpdateInformationFunction;
      FOnHumanityChange: TUpdateInformationFunction;
      FOnTemperatureChange: TUpdateInformationFunction;
      FOnUnitChange: TUpdateInformationFunction;
      FOnConnectChange: TUpdateStateFunction;
      FOnWaitingState: TUpdateStateFunction;

      //FTimer: TTimerThread;
      FTimer: TTimerMP;
      //function SetupTimer: TTimerThread;
      function SetupTimer: TTimerMP;
      procedure setActivityTimer(value: Boolean = false);
      procedure OnTimerSecond(const Sender: TObject);

      function GetCharacteristicByName(nameCharacteristic: String): TBluetoothGattCharacteristic;

      procedure SetupDeviceValueStatusDef;
      procedure SetupDeviceValueStatus;
      procedure setDefaultExtra;
      procedure CleanDeviceInformation;

      procedure setDeviceNotConnected;
      procedure setDeviceConnected;
      procedure setDeviceTime;
      procedure readDeviceData;
      procedure refreshTimeBatteryUnists;
      procedure setSubscribeData;
      procedure getDeviceTime;

      procedure GetDevice(var ADevice: TBluetoothLEDevice); overload;
      function GetDevice: TBluetoothLEDevice; overload;
      procedure GetService(var AService: TBluetoothGattService); overload;
      function GetService: TBluetoothGattService; overload;
      procedure DevicesDiscoveryNAMEDEV(const Sender: TObject; const ADevices: TBluetoothLEDeviceList);
      procedure DidCharacteristicData(const Sender: TObject; const ACharacteristic: TBluetoothGattCharacteristic;
        AGattStatus: TBluetoothGattStatus);
      procedure RefreshCurrentCharacteristicTime(const ACharacteristic: TBluetoothGattCharacteristic);
      procedure RefreshCurrentCharacteristicBattery(const ACharacteristic: TBluetoothGattCharacteristic);
      procedure RefreshCurrentCharacteristicUNITS_CHARACTERISTIC(const ACharacteristic: TBluetoothGattCharacteristic);
      procedure RefreshCurrentCharacteristicData(const ACharacteristic: TBluetoothGattCharacteristic);

      procedure setExtraDeviceAniIndicator(val: Boolean = false);
      procedure setExtraDeviceBattery(isDefault: Boolean = false);
      procedure setExtraDeviceHumanity(isDefault: Boolean = false);
      procedure setExtraDeviceTemperature(isDefault: Boolean = false);
      procedure setExtraDeviceTime(isDefault: Boolean = false);
      procedure setExtraDeviceUnit(isDefault: Boolean = false);
      procedure setExtraDeviceConnect(val: Boolean = false);

      property DeviceValueStatus: TDeviceValueStatus read FDeviceValueStatus write FDeviceValueStatus;
      property Device: TBluetoothLEDevice read GetDevice write FDevice;
      property Service: TBluetoothGattService read GetService write FService;
    public
      constructor Create;
      destructor Destroy;
      function reConnect: boolean;
      property OnTimeChange: TUpdateInformationFunction read FOnTimeChange write FOnTimeChange;
      property OnBatteryChange: TUpdateInformationFunction read FOnBatteryChange write FOnBatteryChange;
      property OnHumanityChange: TUpdateInformationFunction read FOnHumanityChange write FOnHumanityChange;
      property OnTemperatureChange: TUpdateInformationFunction read FOnTemperatureChange write FOnTemperatureChange;
      property OnUnitChange: TUpdateInformationFunction read FOnUnitChange write FOnUnitChange;
      property OnConnectChange: TUpdateStateFunction read FOnConnectChange write FOnConnectChange;
      property OnWaitingState: TUpdateStateFunction read FOnWaitingState write FOnWaitingState;
      property StatusText: String read FStatusText;

  end;

implementation

{ TExploreDeviceBase }

constructor TExploreDeviceBase.Create;
begin
  inherited Create;
  FCharServiceDic:=TDictionary<String, String>.Create;
  SetupDeviceValueStatus;
  setDeviceNotConnected;
end;

destructor TExploreDeviceBase.Destroy;
begin
  FreeAndNil(FTimer);
  TBluetoothLEManager.Current.LastDiscoveredDevices.Remove(Device);
  TBluetoothLEManager.Current.AllDiscoveredDevices.Clear;
  setDevicenotconnected;
  FreeAndNil(DeviceValueStatus);
  FreeAndNil(FCharServiceDic);
  inherited Destroy;
end;

procedure TExploreDeviceBase.setDeviceConnected;
begin
  FStatusText:='Connected';
  setExtraDeviceConnect(true);
  setDefaultExtra;
  CleanDeviceInformation;
  if Device <> nil then
  begin

    try Device.DiscoverServices;
    except on E: Exception do
       FStatusText:=E.Message;
    end;

    try SetupDeviceValueStatus;
    except on E: Exception do
       FStatusText:=E.Message;
    end;

    try setDeviceTime;
    except on E: Exception do
       FStatusText:=E.Message;
    end;
    try readDeviceData;
    except on E: Exception do
       FStatusText:=E.Message;
    end;
    try setSubscribeData;
    except on E: Exception do
       FStatusText:=E.Message;
    end;
    try setActivityTimer(true);
    except on E: Exception do
       FStatusText:=E.Message;
    end;

  end
  else
    setDevicenotconnected;
end;

procedure TExploreDeviceBase.setDeviceNotConnected;
begin
  FStatusText:='Not connected';
  setExtraDeviceConnect(false);
  setDefaultExtra;
  CleanDeviceInformation;
end;

function TExploreDeviceBase.reConnect: boolean;
var
  ABLEAdvertisedDataFilter: TBluetoothLEScanFilter;
  ABLEAdvertisedDataFilterList: TBluetoothLEScanFilterList;
begin
  setExtraDeviceAniIndicator(true);
  try
    if Assigned(Device) then
      begin
        TBluetoothLEManager.Current.LastDiscoveredDevices.Remove(Device);
        TBluetoothLEManager.Current.AllDiscoveredDevices.Clear;
        CleanDeviceInformation;
        setDevicenotconnected;
      end else
      begin
        {
        ABLEAdvertisedDataFilter:= TBluetoothLEScanFilter.Create;
        ABLEAdvertisedDataFilterList:= TBluetoothLEScanFilterList.Create;
        ABLEAdvertisedDataFilter.ServiceUUID:= StringToGUID(SERVICE_UUID);
        ABLEAdvertisedDataFilterList.Add(ABLEAdvertisedDataFilter);
        }
        FBluetoothManagerLE := TBluetoothLEManager.Current;
        FBluetoothManagerLE.OnDiscoveryEnd := DevicesDiscoveryNAMEDEV;
        //FBluetoothManagerLE.StartDiscovery(waitingTime, ABLEAdvertisedDataFilterList);
        FBluetoothManagerLE.StartDiscovery(waitingTime);
      end;
  finally

  end;
end;

procedure TExploreDeviceBase.CleanDeviceInformation;
begin
  FDevice := nil;
  FService := nil;
  if not Assigned(DeviceValueStatus) then
    DeviceValueStatus := TDeviceValueStatus.Create;
  setActivityTimer(false);
end;

procedure TExploreDeviceBase.SetupDeviceValueStatusDef;
begin
  if not Assigned(FCharServiceDic) then exit;
  
  FCharServiceDic.AddOrSetValue((TIME_CHARACTERISTIC_UUID), SERVICE_UUID);
  FCharServiceDic.AddOrSetValue((UNITS_CHARACTERISTIC_UUID), SERVICE_UUID);
  FCharServiceDic.AddOrSetValue((UUID_DATA), SERVICE_UUID);
  FCharServiceDic.AddOrSetValue((UUID_BATTERY), SERVICE_UUID);
  FCharServiceDic.AddOrSetValue((UUID_NUM_RECORDS), SERVICE_UUID);
  FCharServiceDic.AddOrSetValue((UUID_RECORD_IDX), SERVICE_UUID);
end;

procedure TExploreDeviceBase.SetupDeviceValueStatus;
var i, j: integer;
    CharList: TBluetoothGattCharacteristicList;
    AChar: TBluetoothGattCharacteristic;
begin
  FCharServiceDic.Clear;
  if not Assigned(FCharServiceDic) then exit;
  if Device=nil then exit;
  Device.OnCharacteristicRead := DidCharacteristicData;
  for i := 0 to Device.Services.Count - 1 do
    begin
      if GUIDToString(Device.Services[i].UUID) = SERVICE_UUID then
      begin
        Service := Device.Services[i];
        CharList := Service.Characteristics;
        try
        for j := 0 to CharList.Count - 1 do
          begin
            AChar := nil;
            AChar := CharList.Items[j];
            if
              (GUIDToString(AChar.UUID) = UNITS_CHARACTERISTIC_UUID) OR
              (GUIDToString(AChar.UUID) = UUID_CHARACTERISTIC_HISTORY) OR
              (GUIDToString(AChar.UUID) = UUID_DATA) OR
              (GUIDToString(AChar.UUID) = UUID_NUM_RECORDS) OR
              (GUIDToString(AChar.UUID) = UUID_RECORD_IDX) then
              begin
                FCharServiceDic.AddOrSetValue(GUIDToString(AChar.UUID), AChar.GetService.UUID.ToString);
                if (TBluetoothProperty.Read in AChar.Properties) then
                  Device.ReadCharacteristic(AChar);
              end else
          if (GUIDToString(AChar.UUID) = TIME_CHARACTERISTIC_UUID) then
              begin
                FCharServiceDic.AddOrSetValue(GUIDToString(AChar.UUID), AChar.GetService.UUID.ToString);
                Device.ReadCharacteristic(AChar);
              end
            else
          if (GUIDToString(AChar.UUID) = UUID_BATTERY) then
              begin
                FCharServiceDic.AddOrSetValue(GUIDToString(AChar.UUID), AChar.GetService.UUID.ToString);
                Device.ReadCharacteristic(AChar);
              end
        end;
        finally
          CharList:=nil;
          AChar:=nil;
        end;
      end;
    end

end;

procedure TExploreDeviceBase.DevicesDiscoveryNAMEDEV(const Sender: TObject;
  const ADevices: TBluetoothLEDeviceList);
var
  i: Integer;
  ListDevices: TStringList;
begin
  ListDevices:=TStringList.Create;
  try
  for i := 0 to ADevices.Count - 1 do
    ListDevices.Add(ADevices[I].DeviceName);
  if ListDevices.IndexOf(NAMEDEV)=-1 then
    begin
      setDeviceNotConnected;
    end else
    begin
      setDeviceConnected;
    end;
  finally
    ListDevices.Free;
    setExtraDeviceAniIndicator(false);
  end;
end;

procedure TExploreDeviceBase.DidCharacteristicData(const Sender: TObject;
  const ACharacteristic: TBluetoothGattCharacteristic;
  AGattStatus: TBluetoothGattStatus);
begin
  if GUIDToString(ACharacteristic.UUID) = TIME_CHARACTERISTIC_UUID then
  begin
    RefreshCurrentCharacteristicTime(ACharacteristic);
  end;
  if GUIDToString(ACharacteristic.UUID) = UUID_BATTERY then
  begin
    RefreshCurrentCharacteristicBattery(ACharacteristic);
  end;
  if GUIDToString(ACharacteristic.UUID) = UUID_DATA then
  begin
    RefreshCurrentCharacteristicData(ACharacteristic);
  end;
  if GUIDToString(ACharacteristic.UUID) = UNITS_CHARACTERISTIC_UUID then
  begin
    RefreshCurrentCharacteristicUNITS_CHARACTERISTIC(ACharacteristic);
  end;
  //UUID_CHARACTERISTIC_HISTORY = '{EBE0CCBC-7A0A-4B0C-8A1A-6FF2997DA3A6}'; //# Last idx 152          READ NOTIFY
end;

function TExploreDeviceBase.GetDevice: TBluetoothLEDevice;
begin
  GetDevice(FDevice);
  Result:=FDevice;
end;

procedure TExploreDeviceBase.GetDevice(var ADevice: TBluetoothLEDevice);
var
  i: Integer;
begin
  if Assigned(FBluetoothManagerLE) then
  if ADevice=nil then
  begin
    for i:=0 to FBluetoothManagerLE.LastDiscoveredDevices.Count - 1 do
    begin
      if FBluetoothManagerLE.LastDiscoveredDevices[i].DeviceName = NAMEDEV then
        ADevice := FBluetoothManagerLE.LastDiscoveredDevices[i];
    end;
  end;
end;

function TExploreDeviceBase.GetService: TBluetoothGattService;
begin
  GetService(FService);
  Result:=FService;
end;

procedure TExploreDeviceBase.GetService(var AService: TBluetoothGattService);
var
  i: Integer;
begin
  if AService=nil then
  begin
    for i := 0 to Device.Services.Count -1 do
    begin
      if GUIDToString(Device.Services[i].UUID) = SERVICE_UUID then
      begin
        AService := Device.Services[i];
      end;
    end;
  end;
end;

function TExploreDeviceBase.GetCharacteristicByName(nameCharacteristic: String): TBluetoothGattCharacteristic;
var
    AChar: TBluetoothGattCharacteristic;
begin
  AChar := nil;
  try
    if ((Service <> nil) and (Device <> nil)) then
      AChar := Service.GetCharacteristic(StringToGUID(nameCharacteristic));
  finally
    Result:=AChar;
  end;
end;

procedure TExploreDeviceBase.setDeviceTime;
var AChar: TBluetoothGattCharacteristic;
begin
  try
    AChar := GetCharacteristicByName(TIME_CHARACTERISTIC_UUID);
    if AChar<>nil then
    if (TBluetoothProperty.Write in AChar.Properties) or (TBluetoothProperty.WriteNoResponse in AChar.Properties)
      or (TBluetoothProperty.SignedWrite in AChar.Properties) then
        begin
          AChar.SetValueAsUInt32(Uint32(DateTimeToUnix(now)), 0);
              Device.WriteCharacteristic(AChar);
        end;
  finally
    AChar:=nil;
  end;
end;

procedure TExploreDeviceBase.getDeviceTime;
var
    AChar: TBluetoothGattCharacteristic;
begin
  try
    AChar := GetCharacteristicByName(TIME_CHARACTERISTIC_UUID);
    if AChar <> nil then
      Device.ReadCharacteristic(AChar);
  finally
    AChar:=nil;
  end;
end;

procedure TExploreDeviceBase.setSubscribeData;
var
    AChar: TBluetoothGattCharacteristic;
begin
  try
    AChar := GetCharacteristicByName(UUID_DATA);
    if AChar <> nil then
      if (TBluetoothProperty.Notify in AChar.Properties) or
        (TBluetoothProperty.Indicate in AChar.Properties) then
          Device.SetCharacteristicNotification(AChar, True);
  finally
    AChar:=nil;
  end;
end;

procedure TExploreDeviceBase.refreshTimeBatteryUnists;
var
    ACharT: TBluetoothGattCharacteristic;
    ACharB: TBluetoothGattCharacteristic;
    ACharU: TBluetoothGattCharacteristic;
begin
  ACharT := nil;
  ACharT := GetCharacteristicByName(TIME_CHARACTERISTIC_UUID);
  try
  if ACharT<> nil then
      Device.ReadCharacteristic(ACharT);
  finally

  end;

  ACharB := nil;
  ACharB := GetCharacteristicByName(UUID_BATTERY);
  try
  if ACharB<> nil then
      Device.ReadCharacteristic(ACharB);
  finally

  end;

  ACharU := nil;
  ACharU := GetCharacteristicByName(UNITS_CHARACTERISTIC_UUID);
  try
    if ACharU<> nil then
        Device.ReadCharacteristic(ACharU);
  finally
  end;
end;

procedure TExploreDeviceBase.readDeviceData;
var
  AChar: TBluetoothGattCharacteristic;
  i: Integer;
  ACharString: String;
begin
  try
    for ACharString in FCharServiceDic.Keys do
      begin
        AChar := nil;
        AChar:=GetCharacteristicByName(ACharString);
        if AChar<>nil then
          if (TBluetoothProperty.Read in AChar.Properties) then Device.ReadCharacteristic(AChar);
      end;
  finally
    AChar := nil;
  end;

end;

//TTimerThread
{
function TExploreDeviceBase.SetupTimer:TTimerThread;
begin
  if FTimer=nil then
  begin
    FTimer:=TTimerThread.Create;
    FTimer.Interval:=intervalTime;
    FTimer.OnTimerEvent:=OnTimerSecond;
  end;
  Result:=FTimer;
end;
}
//TTimerMP
function TExploreDeviceBase.SetupTimer:TTimerMP;
begin
  if FTimer=nil then
  begin
    FTimer:=TTimerMP.Create;
    FTimer.Interval:=intervalTime;
    FTimer.OnTimer:=OnTimerSecond;
  end;
  Result:=FTimer;
end;

//TTimerMP
procedure TExploreDeviceBase.OnTimerSecond(const Sender: TObject);
begin
  refreshTimeBatteryUnists;
end;

//TTimerMP
procedure TExploreDeviceBase.setActivityTimer(value: Boolean);
begin
  if value then
    SetupTimer.Enabled:=value else
    if FTimer<>nil then
    SetupTimer.Enabled:=value;
end;

procedure TExploreDeviceBase.setDefaultExtra;
begin
  setExtraDeviceAniIndicator(false);
  setExtraDeviceTime(true);
  setExtraDeviceBattery(true);
  setExtraDeviceHumanity(true);
  setExtraDeviceTemperature(true);
  setExtraDeviceUnit(true);
end;

procedure TExploreDeviceBase.RefreshCurrentCharacteristicBattery(
  const ACharacteristic: TBluetoothGattCharacteristic);
begin
  DeviceValueStatus.SetBattery(ACharacteristic);
  setExtraDeviceBattery;
end;

procedure TExploreDeviceBase.RefreshCurrentCharacteristicData(
  const ACharacteristic: TBluetoothGattCharacteristic);
begin
  DeviceValueStatus.SetHumanityAndTemerature(ACharacteristic);
  setExtraDeviceTemperature;
  setExtraDeviceHumanity;
end;

procedure TExploreDeviceBase.RefreshCurrentCharacteristicTime(
  const ACharacteristic: TBluetoothGattCharacteristic);
begin
  DeviceValueStatus.SetTime(ACharacteristic);
  setExtraDeviceTime;
end;

procedure TExploreDeviceBase.RefreshCurrentCharacteristicUNITS_CHARACTERISTIC(
  const ACharacteristic: TBluetoothGattCharacteristic);
begin
  DeviceValueStatus.SetUnits(ACharacteristic);
  setExtraDeviceUnit;
end;

procedure TExploreDeviceBase.setExtraDeviceAniIndicator(val: Boolean);
begin
  if Assigned(OnWaitingState) then
    OnWaitingState(val);
end;

procedure TExploreDeviceBase.setExtraDeviceConnect(val: Boolean);
begin
  if Assigned(OnConnectChange) then
      TTask.Run(
    procedure
    begin
      TThread.Synchronize(nil,
        procedure
        begin
          OnConnectChange(val);
        end);
    end);
end;

procedure TExploreDeviceBase.setExtraDeviceBattery(isDefault: Boolean);
var sValue: String;
begin
  if not Assigned(DeviceValueStatus) or isDefault then sValue:=defvalBattery else
    try
      sValue:=IntToStr(DeviceValueStatus.Battery)+'%';
    except
      sValue:=defvalBattery;
    end;
  if Assigned(OnBatteryChange) then
  TTask.Run(
    procedure
    begin
      TThread.Synchronize(nil,
        procedure
        begin
          OnBatteryChange(sValue);
        end);
    end);
end;

procedure TExploreDeviceBase.setExtraDeviceHumanity(isDefault: Boolean);
var sValue: String;
begin
  if not Assigned(DeviceValueStatus) or isDefault then sValue:=defvalHumanity else
    try
      sValue:=IntToStr(DeviceValueStatus.Humanity)+'%';
    except
      sValue:=defvalHumanity;
    end;
  if Assigned(OnHumanityChange) then
    TTask.Run(
    procedure
    begin
      TThread.Synchronize(nil,
        procedure
        begin
          OnHumanityChange(sValue);
        end);
    end);
end;

procedure TExploreDeviceBase.setExtraDeviceTemperature(isDefault: Boolean);
var sValue: String;
begin
  if not Assigned(DeviceValueStatus) or isDefault then sValue:=defvalTemperature else
    try
      sValue:=FloatToStr(DeviceValueStatus.TemperatureC);
    except
      sValue:=defvalTemperature;
    end;
  if Assigned(OnTemperatureChange) then
    TTask.Run(
    procedure
    begin
      TThread.Synchronize(nil,
        procedure
        begin
          OnTemperatureChange(sValue);
        end);
    end);
end;

procedure TExploreDeviceBase.setExtraDeviceTime(isDefault: Boolean);
var sValue: String;
begin
  if not Assigned(DeviceValueStatus) or isDefault then sValue:=defvalTime else
    try
      sValue:=formatdatetime('hh:nn', DeviceValueStatus.Time);
    except
      sValue:=defvalTime;
    end;
  if Assigned(OnTimeChange) then
  TTask.Run(
    procedure
    begin
      TThread.Synchronize(nil,
        procedure
        begin
          OnTimeChange(sValue);
        end);
    end);
end;

procedure TExploreDeviceBase.setExtraDeviceUnit(isDefault: Boolean);
var sValue: String;
begin
  if not Assigned(DeviceValueStatus) or isDefault then sValue:=defvalUnit
  else
    if DeviceValueStatus.Units=0 then
      sValue:='F' else sValue:=defvalUnit;

  if Assigned(OnUnitChange) then
    TTask.Run(
    procedure
    begin
      TThread.Synchronize(nil,
        procedure
        begin
          OnUnitChange(sValue)
        end);
    end);
end;


{ TDeviceValueStatus }

function TDeviceValueStatus.ByteToHexStr(B: Byte):String;
  const HexChars: Array [0..$F] of Char = '0123456789ABCDEF';
begin
  ByteToHexStr := HexChars[B shr 4 ] + HexChars[B and $F];
end;

function TDeviceValueStatus.HexToInt(Value: String): Longint;
var
  L : Longint;
  B : Byte;
begin
  Result := 0;
  if Length(Value) <> 0 then
  begin
    L := 1;
    B := Length(Value) + 1;
    repeat
      dec(B);
      if Value[B] <= '9' then
        Result := Result + (Byte(Value[B]) - 48) * L
      else
        Result := Result + (Byte(Value[B]) - 55) * L;
      L := L * 16;
    until B = 1;
  end;
end;

constructor TDeviceValueStatus.Create;
begin
  inherited Create;
  FDate:=now();
  FTime:=0;
  FBattery:=0;
  FHumanity:=0;
  FTemperatureC:=0;
  FTemperatureF:=0;
  FUnits:=0;
end;

destructor TDeviceValueStatus.Destroy;
begin
  inherited Destroy;
end;


procedure TDeviceValueStatus.SetBattery(const ACharacteristic: TBluetoothGattCharacteristic);
var
  I: BYTE;
  ABattery1: Integer;
begin
  if ACharacteristic = nil then exit;
  try
    i:=ACharacteristic.GetValueAs<BYTE>;
  except
    i:=0;
  end;
  FBattery:=Integer(I);
end;

procedure TDeviceValueStatus.SetHumanityAndTemerature(const ACharacteristic: TBluetoothGattCharacteristic);
var
  I3: FArrByte3;
  S:String;
begin
  if ACharacteristic=nil then exit;
  try
    I3:= ACharacteristic.GetValueAs<FArrByte3>;
    S:=ByteToHexStr(I3[1])+ByteToHexStr(I3[0]);
    FTemperatureC:=HexToInt(S)/Double(100.0);
    FTemperatureF:=FTemperatureC * 9.0 / 5.0 + 32.0;
    FHumanity:=Integer(I3[2]);
  except
    FTemperatureC:=0;
    FTemperatureF:=0;
    FHumanity:=0;
  end;
end;

procedure TDeviceValueStatus.SetTime(const ACharacteristic: TBluetoothGattCharacteristic);
var
  i: UInt64;
  I5: FArrByte5;
  B: BYTE;
  S: String;
  ATime4: UInt64;
begin
  if ACharacteristic = nil then exit;
  try
    i := ACharacteristic.GetValueAsUInt64;
    {
    I5 := ACharacteristic.GetValueAs<FArrByte5>;
    S := ByteToHexStr(I5[4])+ByteToHexStr(I5[3])+ByteToHexStr(I5[2])+ByteToHexStr(I5[1]);
    B := I5[0];
    ATime4 := HexToInt(S);
    FTimeZone := Integer(B);
    FTime := UnixToDateTime(ATime4);
    if (FTimeZone < 128) then
        FTime := FTime + FTimeZone * 3600
    else
        FTime := FTime + (FTimeZone - 256) * 3600;
    }
    ATime4 := Integer(I);
    FTime := UnixToDateTime(ATime4);
  except
    FTime := 0;
    FTimeZone := 0;
  end;

end;

procedure TDeviceValueStatus.SetUnits(const ACharacteristic: TBluetoothGattCharacteristic);
var
  i: BYTE;
begin
  if ACharacteristic = nil then exit;
  try
    i:= ACharacteristic.GetValueAs<BYTE>;
  except
    i:=0;
  end;
  FUnits:=Integer(I);
end;

end.

