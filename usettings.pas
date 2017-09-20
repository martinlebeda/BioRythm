Unit uSettings;

{$mode objfpc}

Interface

Uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs, ValEdit, StdCtrls, Buttons;

Type

  { TfrmSettings }

  TfrmSettings = Class(TForm)
    edtDndScript: TEdit;
    edtDnScript: TEdit;
    edtTimerWarning: TEdit;
    edtWorkInterval: TEdit;
    edtPauseInterval: TEdit;
    lblDndScript: TLabel;
    lblDnScript: TLabel;
    lblTimerWarning: TLabel;
    lblWorkInterval: TLabel;
    lblPauseInterval: TLabel;
    Ok: TButton;
    Cancel: TButton;
    edtStartInterval: TEdit;
    lblStartInterval: TLabel;
    Procedure CancelClick(Sender: TObject);
    Procedure FormActivate(Sender: TObject);
    Procedure FormShow(Sender: TObject);
    Procedure lblStartIntervalClick(Sender: TObject);
    Procedure OkClick(Sender: TObject);
  Private
    { private declarations }
  Public
    { public declarations }
  End;

Var
  frmSettings: TfrmSettings;

Implementation

uses uMain;

{ TfrmSettings }

Procedure TfrmSettings.lblStartIntervalClick(Sender: TObject);
Begin

end;

Procedure TfrmSettings.OkClick(Sender: TObject);
Begin
  frmMain.MainAppXMLPropStr.StoredValue[CFG_INTERVAL_START] := edtStartInterval.Text;
  frmMain.MainAppXMLPropStr.StoredValue[CFG_INTERVAL_WORK] := edtWorkInterval.Text;
  frmMain.MainAppXMLPropStr.StoredValue[CFG_INTERVAL_PAUSE] := edtPauseInterval.Text;
  frmMain.MainAppXMLPropStr.StoredValue[CFG_DISTURB_NOT] := edtDndScript.Text;
  frmMain.MainAppXMLPropStr.StoredValue[CFG_DISTURB_NORMAL] := edtDnScript.Text;
  frmMain.MainAppXMLPropStr.StoredValue[CFG_WARNING_TIME] := edtTimerWarning.Text;

  Self.close;
end;

Procedure TfrmSettings.CancelClick(Sender: TObject);
Begin
  Self.Close;
end;

Procedure TfrmSettings.FormActivate(Sender: TObject);
Begin

end;

Procedure TfrmSettings.FormShow(Sender: TObject);
Begin
  edtStartInterval.Text := frmMain.MainAppXMLPropStr.StoredValue[CFG_INTERVAL_START];
  edtWorkInterval.Text  := frmMain.MainAppXMLPropStr.StoredValue[CFG_INTERVAL_WORK];
  edtPauseInterval.Text := frmMain.MainAppXMLPropStr.StoredValue[CFG_INTERVAL_PAUSE];
  edtDndScript.Text := frmMain.MainAppXMLPropStr.StoredValue[CFG_DISTURB_NOT];
  edtDnScript.Text  := frmMain.MainAppXMLPropStr.StoredValue[CFG_DISTURB_NORMAL];
  edtTimerWarning.Text := frmMain.MainAppXMLPropStr.StoredValue[CFG_WARNING_TIME];
end;

Initialization
  {$I uSettings.lrs}

End.

