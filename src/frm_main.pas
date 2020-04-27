unit FRM_Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Spin, Menus, frm_info, LCLType{$IFDEF Windows}, Windows, registry{$ENDIF};

type

  { TForm1 }

  TForm1 = class(TForm)
    btnStart: TButton;
    btnStop: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lblNfo: TLabel;
    MenuItem1: TMenuItem;
    MenuItemAddStartup: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItemShow: TMenuItem;
    MenuItemHide: TMenuItem;
    MenuItemStart: TMenuItem;
    MenuItemStop: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItemExit: TMenuItem;
    Panel1: TPanel;
    Panel2: TPanel;
    PopupMenu1: TPopupMenu;
    TrayIcon1: TTrayIcon;
    txtPingStr: TMemo;
    SpinEdit1: TSpinEdit;
    Timer1: TTimer;
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure Label3Click(Sender: TObject);
    procedure MenuItemAddStartupClick(Sender: TObject);
    procedure MenuItemExitClick(Sender: TObject);
    procedure MenuItemHideClick(Sender: TObject);
    procedure MenuItemShowClick(Sender: TObject);
    procedure MenuItemStartClick(Sender: TObject);
    procedure MenuItemStopClick(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure TrayIcon1Click(Sender: TObject);
  private

  public

  end;


var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

{$if defined (windows)}
procedure Win32_AddtoStartUp(AppName, AppPath: String);
const RegKey = '\SOFTWARE\Microsoft\Windows\CurrentVersion\Run';
var
  Reg: TRegistry;
begin
  if (AppName <> '') and (AppPath <> '') then
  begin
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_CURRENT_USER;
    if (Reg.OpenKey(RegKey, False)) then
    begin
      Reg.WriteString(AppName, AppPath);
      Form1.MenuItemAddStartup.Checked := True;
      Application.MessageBox(PChar('Instance ''' +Application.ExeName+
      ''' will run on Windows Startup'), 'Info', MB_OK+MB_ICONINFORMATION);
    end
    else
    Application.MessageBox(PChar('Failed to enable Run on Startup: ' +ExtractFileName(Application.ExeName)),
    'Error', MB_OK+MB_ICONERROR);
  Reg.CloseKey;
  Reg.Free;
  end;

end;
{$endif}

{$if defined (windows)}
procedure Win32_StartupKeyCheck (AppName: String);
const RegKey = '\SOFTWARE\Microsoft\Windows\CurrentVersion\Run';
begin
AppName := ExtractFileName(Application.ExeName);
  try
    begin
      with TRegistry.Create do
           try
             RootKey := HKEY_CURRENT_USER;
             OpenKey(RegKey, False);
             if ValueExists(AppName) then
             begin
             Form1.MenuItemAddStartup.Checked := True;
            { Application.MessageBox(PChar('Instance ''' +Application.ExeName+
             ''' is already enabled to run on Windows Startup'), 'Info',
                                                      MB_OK+MB_ICONINFORMATION); }
             end;
           finally
             CloseKey;
             Free;
           end;
    end;
finally
end;
end;
{$endif}

{$if defined (windows)}
procedure Win32_RemoveStartup(AppName: String);
const RegKey = '\SOFTWARE\Microsoft\Windows\CurrentVersion\Run';
begin
  AppName := ExtractFileName(Application.ExeName);
  try
    begin
      with TRegistry.Create do
           try
             RootKey := HKEY_CURRENT_USER;
             OpenKey(RegKey, False);
             DeleteValue(AppName);
             Form1.MenuItemAddStartup.Checked := False;
             Application.MessageBox(PChar('Instance ''' +Application.ExeName+
             ''' will no longer run on Startup'), 'Info', MB_OK+MB_ICONWARNING);
           finally
             CloseKey;
             Free;
           end;
    end;
finally
end;
end;
{$endif}

procedure StartPinging();
begin
  Application.Icon.LoadFromResourceName(Hinstance,'HDD_ACTIVE');
  Form1.TrayIcon1.Icon.LoadFromResourceName(Hinstance,'HDD_ACTIVE');
  Form1.Icon.LoadFromResourceName(Hinstance,'HDD_ACTIVE');;
  Form1.TrayIcon1.Hint := 'Instance is currently Active' +sLineBreak+ Application.ExeName;
  Form1.TrayIcon1.BalloonTitle := 'Pinging has Started!';
  Form1.TrayIcon1.BalloonHint := 'Time interval is ' + IntToStr(Form1.SpinEdit1.Value) + ' ms';
  Form1.TrayIcon1.ShowBalloonHint;
  Form1.Timer1.Enabled := True;
  Form1.btnStart.Enabled := False;
  Form1.btnStop.Enabled := True;
  Form1.MenuItemStart.Enabled := False;
  Form1.MenuItemStop.Enabled := True;
end;

procedure StopPinging();
begin
  Application.Icon.LoadFromResourceName(Hinstance,'HDD_INACTIVE');
  Form1.TrayIcon1.Icon.LoadFromResourceName(Hinstance,'HDD_INACTIVE');
  Form1.Icon.LoadFromResourceName(Hinstance,'HDD_INACTIVE');;
  Form1.TrayIcon1.Hint := 'Instance is currently Inactive' +sLineBreak+ Application.ExeName;
  Form1.TrayIcon1.BalloonTitle := 'Pinging has Stopped!';
  Form1.TrayIcon1.BalloonHint := 'Time interval is set to ' + IntToStr(Form1.SpinEdit1.Value) + ' ms';
  Form1.TrayIcon1.ShowBalloonHint;
  Form1.Timer1.Enabled := False;
  Form1.btnStart.Enabled := True;
  Form1.btnStop.Enabled := False;
  Form1.MenuItemStart.Enabled := True;
  Form1.MenuItemStop.Enabled := False;
end;

procedure TForm1.btnStartClick(Sender: TObject);
begin
  StartPinging();
end;

procedure TForm1.btnStopClick(Sender: TObject);
begin
  StopPinging();
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Form2.ShowModal;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: boolean);
begin
    CanClose := False;
    Form1.WindowState := wsNormal;
    Form1.ShowInTaskBar := stNever;
    Form1.Hide;
    Form1.TrayIcon1.BalloonTitle := 'Minimized to systray';
    Form1.TrayIcon1.BalloonHint := 'I''m still here!';
    Form1.TrayIcon1.ShowBalloonHint;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
   AppName: string;
begin
  // Hide those unless we're on Windows.
  // TODO: Startup option for linux/MacOS (?)
  MenuItem1.Visible := False; // Options MenuItem
  MenuItem6.Visible := False; // Seperator

  AppName := ExtractFileName(Application.ExeName);

  {$if defined (Windows)}
  Win32_StartupKeyCheck(AppName);

  // if on Windows, show them
  MenuItem1.Visible := True; // Options MenuItem
  MenuItem6.Visible := True; // Seperator
  {$Endif}

  Form1.TrayIcon1.Hint := 'Instance is currently Active' +sLineBreak+ Application.ExeName;
  btnStop.Enabled := False;
  MenuItemStop.Enabled := False;
end;

procedure TForm1.FormWindowStateChange(Sender: TObject);
begin
  if Form1.WindowState = wsMinimized then begin
    Form1.WindowState := wsNormal;
    Form1.ShowInTaskBar := stNever;
    Form1.Hide;
  end;
end;

procedure TForm1.Label3Click(Sender: TObject);
begin
  Application.MessageBox(PChar(Application.ExeName +sLineBreak+sLineBreak+ 'You may also get'+
  ' this info by hovering over the tray icon.'), 'Launch path for this instance', MB_OK+MB_ICONINFORMATION);
end;

procedure TForm1.MenuItemAddStartupClick(Sender: TObject);
var
  AppName, AppPath: String;
begin
  AppName := ExtractFileName(Application.ExeName);
  AppPath := Application.ExeName;

  {$if defined (windows)}
  if (Form1.MenuItemAddStartup.Checked = False) then
  begin
  Win32_AddtoStartUp(AppName, AppPath);
  end
  {$endif}

  {$if defined (windows)}
  // if already added to startup
  else if (Form1.MenuItemAddStartup.Checked = True) then
  begin
  Win32_RemoveStartUp(AppName);
  end;
  {$endif}

end;

procedure TForm1.MenuItemExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.MenuItemHideClick(Sender: TObject);
begin
    Form1.WindowState := wsNormal;
    Form1.ShowInTaskBar := stNever;
    Form1.Hide;

end;

procedure TForm1.MenuItemShowClick(Sender: TObject);
begin
  Form1.WindowState := wsNormal;
  Form1.ShowInTaskBar := stAlways;
  Form1.Show;
end;

procedure TForm1.MenuItemStartClick(Sender: TObject);
begin
  StartPinging();
end;

procedure TForm1.MenuItemStopClick(Sender: TObject);
begin
  StopPinging();
end;

procedure TForm1.SpinEdit1Change(Sender: TObject);
begin
  Timer1.Interval := SpinEdit1.Value;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  F: TextFile;
  GeneratedTxtPath: String;
  Err: Word;
begin
  GeneratedTxtPath :=  ExtractFileName(Application.ExeName) + '.txt';
  AssignFile(F, GeneratedTxtPath);
  {$I-} // Otherwise failing to ReWrite will raise a runtime error
  ReWrite(F);
  {$I+}
  Err := IOResult;
  if Err <> 0 then begin
    StopPinging();
    Application.MessageBox(PChar('Error opening file ' +QuotedStr(GeneratedTxtPath)+
    sLineBreak+ 'Do you have enough permissions for current directory?' +sLineBreak+
    Application.ExeName), 'Error', MB_OK+MB_ICONERROR);
  end else begin
  Write(F, txtPingStr.Text);
  CloseFile(F);
  txtPingStr.Text := 'This file was generated by PingHD application on ' +
                  DateTimeToStr(Now)+sLineBreak+sLineBreak+ 'Written from application instance: '+
                  Application.ExeName;
  end;
end;

procedure TForm1.TrayIcon1Click(Sender: TObject);
begin
  Form1.WindowState := wsNormal;
  Form1.ShowInTaskBar := stAlways;
  Form1.Show;
end;

end.

