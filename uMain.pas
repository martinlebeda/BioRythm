unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, process, XMLConf, sqlite3conn, Buttons, LazHelpHTML, Menus,
  ActnList, PopupNotifier, XMLPropStorage, uSettings;

type

  TTrayIconType = (TiBase, TiWork, TiPaused, TiOwer, TiEnding);

  { TfrmMain }
  TfrmMain = class(TForm)
    acStartWorkInterval: TAction;
    acStartPauseInterval: TAction;
    acNormalDisturb: TAction;
    acNotDisturb: TAction;
    acOptions: TAction;
    acExit: TAction;
    acStartInterval0: TAction;
    acStartInterval1: TAction;
    acStartInterval5: TAction;
    acStartInterval10: TAction;
    acStartInterval15: TAction;
    acStartInterval30: TAction;
    acPauseTimer: TAction;
    acShowMainForm: TAction;
    ActionList1: TActionList;
    btStartInterval1: TBitBtn;
    btStartInterval2: TButton;
    btStartInterval3: TButton;
    btStartInterval4: TButton;
    btStartInterval5: TButton;
    btStartInterval6: TButton;
    btnPause: TBitBtn;
    chAutomaticDnd: TCheckBox;
    ImageList1: TImageList;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    pauza1: TButton;
    PopupNotifier1: TPopupNotifier;
    Prace1: TButton;
    hideTimer: TTimer;
    TrayMenu: TPopupMenu;
    Prace: TButton;
    lblZobrazeni: TLabel;
    Process: TProcess;
    pauza: TButton;
    tik_tak: TTimer;
    TrayIcon: TTrayIcon;
    MainAppXMLPropStr: TXMLPropStorage;
    Procedure acBlockInput(Sender: TObject);
    Procedure acExitExecute(Sender: TObject);
    procedure acNotDisturbExecute(Sender: TObject);
    Procedure acOptionsExecute(Sender: TObject);
    Procedure acPauseTimerExecute(Sender: TObject);
    Procedure acStartInterval15Execute(Sender: TObject);
    Procedure acStartInterval1Execute(Sender: TObject);
    Procedure acStartInterval30Execute(Sender: TObject);
    Procedure acStartInterval5Execute(Sender: TObject);
    procedure acStartPauseIntervalExecute(Sender: TObject);
    procedure acStartWorkIntervalExecute(Sender: TObject);
    procedure acNormalDisturbExecute(Sender: TObject);
    Procedure acStartInterval0Execute(Sender: TObject);
    Procedure acStartInterval10Execute(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormHide(Sender: TObject);
    Procedure FormWindowStateChange(Sender: TObject);
    Procedure IdleTimer1Timer(Sender: TObject);
    procedure nerusitClick(Sender: TObject);
    procedure tik_takTimer(Sender: TObject);
    Procedure hideTimerTimer(Sender: TObject);
    procedure ti_owerClick(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
    procedure acShowMainFormExecute(Sender: TObject);
    procedure TrayIconClick(Sender: TObject);
  private
    { private declarations }
    toEnd: integer; // čas do konce v minutách
    isAction: boolean;
    FBlockInput: boolean;
    FAutoHide: boolean;
    procedure doNormalDisturb;
    procedure doStartWorkInterval;
    procedure doStartPauseInterval;
    procedure doNotDisturb;
    Procedure hideForm;
    Procedure AutoHideFormAfter(aAfterSec: Cardinal);
    procedure pause;
    procedure setNormalStatus;
    procedure setOwerStatus;
    Procedure setWorkIcon;
    procedure startInterval(aMinute: integer);
    procedure setLabel;
    procedure endInterval;
    procedure setTrayIcon(aIcon: TTrayIconType);
    procedure writeTimeToFile;
    procedure disturbOnStop;
  public
    { public declarations }
  end;

const
  CFG_INTERVAL_START  = 'StartInterval';
  CFG_INTERVAL_WORK   = 'WorkInterval';
  CFG_INTERVAL_PAUSE  = 'PauseInterval';
  CFG_DISTURB_NORMAL  = 'NormalDisturb';
  CFG_DISTURB_NOT     = 'NotDisturb';
  CFG_WARNING_TIME    = 'WarningTime';
  CFG_DISTURB_ON_STOP = 'DisturbOnStop';

var
  frmMain: TfrmMain;

implementation

const
  SEC_PER_MIN = 60; // sekund za minutu
  TMR_FILENAME = '/tmp/timer.txt';

{ TfrmMain }

Procedure TfrmMain.FormCreate(Sender: TObject);
begin
  MainAppXMLPropStr.Restore;
  startInterval(StrToInt(MainAppXMLPropStr.StoredValue[CFG_INTERVAL_START]));
  isAction := True;

  btStartInterval1.Caption := '';
  btnPause.Caption := '';
end;

Procedure TfrmMain.FormHide(Sender: TObject);
begin
  frmMain.ShowInTaskBar := stNever;
end;

Procedure TfrmMain.FormWindowStateChange(Sender: TObject);
Begin
  //if frmMain.WindowState = wsMinimized then
  //begin
  //  // frmMain.Hide;
  //End
  //else
  //begin
  //  // frmMain.ShowInTaskBar := stDefault;
  //End;

end;

Procedure TfrmMain.IdleTimer1Timer(Sender: TObject);
Begin
  Application.Minimize;
end;

Procedure TfrmMain.FormClose(Sender: TObject; Var CloseAction: TCloseAction);
begin
  if FBlockInput then
    CloseAction := caNone
  else if toEnd > 0 then
  begin
    CloseAction := caHide; // caMinimize;
    hideForm;
  End
  else
  begin
    // on realy close
    DeleteFile(TMR_FILENAME); {TODO -oLebeda -cNone: realy??}
    MainAppXMLPropStr.Save;
    disturbOnStop;
  End;
end;

Procedure TfrmMain.acStartWorkIntervalExecute(Sender: TObject);
begin
  doStartWorkInterval;
end;

Procedure TfrmMain.acNormalDisturbExecute(Sender: TObject);
begin
  doNormalDisturb;
end;

Procedure TfrmMain.acStartInterval0Execute(Sender: TObject);
Begin
  startInterval(0);
  disturbOnStop;
end;

Procedure TfrmMain.acStartInterval10Execute(Sender: TObject);
Begin
  startInterval(10);
end;

Procedure TfrmMain.acStartPauseIntervalExecute(Sender: TObject);
begin
  doStartPauseInterval;
end;

Procedure TfrmMain.acNotDisturbExecute(Sender: TObject);
begin
  doNotDisturb;
end;

Procedure TfrmMain.acExitExecute(Sender: TObject);
Begin
  startInterval(0);
  Self.Close;
end;

Procedure TfrmMain.acBlockInput(Sender: TObject);
Begin
  (Sender as TAction).Enabled := not FBlockInput;
end;

Procedure TfrmMain.acOptionsExecute(Sender: TObject);
Begin
  frmSettings.ShowModal;
end;

Procedure TfrmMain.acPauseTimerExecute(Sender: TObject);
Begin
  pause;
end;

Procedure TfrmMain.acStartInterval15Execute(Sender: TObject);
Begin
  startInterval(15);
end;

Procedure TfrmMain.acStartInterval1Execute(Sender: TObject);
Begin
  startInterval(1);
end;

Procedure TfrmMain.acStartInterval30Execute(Sender: TObject);
Begin
  startInterval(30);
end;

Procedure TfrmMain.acStartInterval5Execute(Sender: TObject);
Begin
  startInterval(5);
end;

Procedure TfrmMain.nerusitClick(Sender: TObject);
begin
  doNotDisturb;
end;

Procedure TfrmMain.tik_takTimer(Sender: TObject);
begin
  toEnd := toEnd - 1;
  setLabel;
  if (toEnd = 0) or ((toEnd < 0) and ((abs(toEnd) mod 60) = 0)) then
    endInterval;

  if toEnd > 0 then
    setWorkIcon;

  if ((abs(toEnd) mod 60) = 0) then
  begin
    writeTimeToFile;
  end;
end;

Procedure TfrmMain.hideTimerTimer(Sender: TObject);
Begin
  if FAutoHide then
  begin
    Application.Minimize;
    frmMain.WindowState := wsMinimized;
  End;

  hideTimer.Enabled := False;
  FBlockInput := False
end;

Procedure TfrmMain.ti_owerClick(Sender: TObject);
begin
  Application.Restore;
end;

Procedure TfrmMain.TrayIcon1Click(Sender: TObject);
begin
  // při kladném čísle zastavit, při záporném přidat 10 minut
  if (toEnd > 0) then
    pause
  else
  begin
    startInterval(0);
    startInterval(10); {TODO -oLebeda -cNone: zajímavá funkčnost, ale kam s ní }
  end;
end;

Procedure TfrmMain.acShowMainFormExecute(Sender: TObject);
begin
  frmMain.Show;
end;

Procedure TfrmMain.TrayIconClick(Sender: TObject);
begin
  if not frmMain.visible or (frmMain.WindowState = wsMinimized) then
    frmMain.Show
  else
    hideForm;
  // pause;
end;

Procedure TfrmMain.startInterval(aMinute: integer);
begin
  setNormalStatus;
  tik_tak.Enabled := False; // zastavení timeru
  if aMinute <> 0 then
  begin
    if toEnd < 0 then
      toEnd := 0;
    toEnd := toEnd + (aMinute * SEC_PER_MIN);
    tik_tak.Enabled := True; // nové spuštění timeru
    setWorkIcon;
  end
  else
  begin
    toEnd := aMinute;
    setLabel; // vynutí poslední překreslení
    //ti_work.Visible:= true;
    setTrayIcon(TiBase);
  end;

  writeTimeToFile;
end;

Procedure TfrmMain.doNotDisturb;
begin
  Process.CommandLine := MainAppXMLPropStr.StoredValue[CFG_DISTURB_NOT];
  if Process.CommandLine <> '' then
    Process.Execute;
end;

Procedure TfrmMain.hideForm;
Begin
  frmMain.Hide;
  frmMain.ShowInTaskBar := stNever;
End;

Procedure TfrmMain.AutoHideFormAfter(aAfterSec: Cardinal);
Begin
  FBlockInput := true;
  FAutoHide := (frmMain.WindowState = wsMinimized) Or Not frmMain.visible;
  hideTimer.Interval := aAfterSec * 1000;
  hideTimer.Enabled := True;
End;

Procedure TfrmMain.doStartWorkInterval;
begin
  startInterval(0);
  startInterval(StrToInt(MainAppXMLPropStr.StoredValue[CFG_INTERVAL_WORK]));
  if chAutomaticDnd.Checked then
    doNotDisturb;
end;

Procedure TfrmMain.doNormalDisturb;
begin
  Process.CommandLine := MainAppXMLPropStr.StoredValue[CFG_DISTURB_NORMAL];
  if Process.CommandLine <> '' then
    Process.Execute;
end;

Procedure TfrmMain.doStartPauseInterval;
begin
  startInterval(0);
  startInterval(StrToInt(MainAppXMLPropStr.StoredValue[CFG_INTERVAL_PAUSE]));
  if chAutomaticDnd.Checked then
    doNormalDisturb;
end;

Procedure TfrmMain.pause;
begin
  setNormalStatus;
  tik_tak.Enabled := not (tik_tak.Enabled);
  if (not tik_tak.Enabled) then
  begin
    setTrayIcon(TiPaused);
    TrayIcon.Hint := TrayIcon.Hint + ' - ZASTAVENO';
    acPauseTimer.ImageIndex := 6;
    ImageList1.GetBitmap(6, btnPause.Glyph);
  end
  else
  begin
    if toEnd < 0 then
      setOwerStatus;
    setWorkIcon;
    ImageList1.GetBitmap(5, btnPause.Glyph);
    acPauseTimer.ImageIndex := 5;
  end;
end;


Procedure TfrmMain.setNormalStatus;
begin
  Self.FormStyle := fsNormal;
  Self.Color := clDefault;
end;

Procedure TfrmMain.setOwerStatus;
begin
  Self.FormStyle := fsStayOnTop;
  Self.Position := poScreenCenter;
  Self.Color := clRed;
  AutoHideFormAfter(5);
  Self.Show;
  Self.Position := poDefaultPosOnly;
end;

Procedure TfrmMain.setWorkIcon;
Begin
  If toEnd <= (StrToInt(MainAppXMLPropStr.StoredValue[CFG_WARNING_TIME]) * 60) Then
  begin
    if ((abs(toEnd) mod 60) = 0) then
    begin
      Self.FormStyle := fsStayOnTop;
      Self.Position := poScreenCenter;
      Self.Color := clYellow;
      AutoHideFormAfter(2);
      Self.Show;
    End;
    setTrayIcon(TiEnding)
  End
  Else
  begin
    setTrayIcon(TiWork);
  End;
End;

Procedure TfrmMain.setLabel;
var
  min, sec: integer;
begin
  min := toEnd div SEC_PER_MIN;
  sec := toEnd mod SEC_PER_MIN;

  //if (sec = 0) and (min > 0) then
  //begin
  //isAction := false;
  //TrackBar1.Position:=min;
  //isAction := true;
  //end;

  lblZobrazeni.Caption := IntToStr(min) + ':' + IntToStr(sec);
  Application.Title := lblZobrazeni.Caption;
  frmMain.Caption := lblZobrazeni.Caption;
  TrayIcon.Hint := lblZobrazeni.Caption;
end;

Procedure TfrmMain.endInterval;
begin
  // tik_tak.Enabled:= false; // jen at počítá i přesčas
  //Process.CommandLine := 'notify-send Časovač "Vypršel časovač"';
  //Process.Execute;
  //PopupNotifier1.Text := 'Timer ended';
  //PopupNotifier1.Show;

  setOwerStatus;

  setTrayIcon(TiOwer);
  // TrayIcon.ShowBalloonHint;
end;

Procedure TfrmMain.setTrayIcon(aIcon: TTrayIconType);
var
  iconIndex: Integer;
  Bmp: TBitmap;
begin
  iconIndex := 4;
  case aIcon of
   TiBase  : iconIndex := 4;
   TiWork  : iconIndex := 3;
   TiOwer  : iconIndex := 0;
   TiPaused: iconIndex := 2;
   TiEnding: iconIndex := 1;
  end;

  Bmp := TBitmap.Create;
  try
    ImageList1.GetBitmap(iconIndex, Bmp);
    TrayIcon.Icon.Assign(Bmp);
    TrayIcon.Show;
  finally
    Bmp.Free;
  end;
end;

Procedure TfrmMain.writeTimeToFile;
begin
  with TStringList.Create do
    try
      Add(IntToStr(toEnd div 60));
      SaveToFile(TMR_FILENAME);
    finally
      Free;
    end;
end;

Procedure TfrmMain.disturbOnStop;
Begin
  if StrToBool(frmMain.MainAppXMLPropStr.StoredValue[CFG_DISTURB_ON_STOP]) then
    acNormalDisturb.Execute;
End;

initialization
  {$I uMain.lrs}

end.


