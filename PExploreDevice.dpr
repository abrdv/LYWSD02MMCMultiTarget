// JCL_DEBUG_EXPERT_INSERTJDBG OFF
// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
program PExploreDevice;

uses
  System.StartUpCopy,
  FMX.Forms,
  uExploreDevice in 'uExploreDevice.pas' {FMainForm},
  uExploreDeviceBase in 'uExploreDeviceBase.pas',
  uTimerMP in 'uTimerMP.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFMainForm, FMainForm);
  Application.Run;
end.
