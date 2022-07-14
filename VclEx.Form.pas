unit VclEx.Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, Vcl.Controls, Vcl.Forms;

type
  TFormEx = class abstract (TForm)
  private
    const idOnTop = 10001;
    procedure WMSysCommand(var Message: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WMInitMenuPopup(var Message: TWMInitMenuPopup); message WM_INITMENUPOPUP;
  protected
    procedure DoClose(var Action: TCloseAction); override;
    procedure DoCreate; override;
    procedure DoShow; override;
  public
    function ShowModal: Integer; override;
  end;

implementation

{ TFormEx }

procedure TFormEx.DoClose;
begin
  Action := caFree;
  inherited;
end;

procedure TFormEx.DoCreate;
begin
  inherited;
  InsertMenu(GetSystemMenu(Handle, False), 0, MF_STRING, idOnTop,
    'Stay On &Top');
end;

procedure TFormEx.DoShow;
begin
  // Inherit stay-on-top style to prevent children hiding behind a parent
  if Owner is TForm then
    if TForm(Owner).FormStyle = fsStayOnTop then
      FormStyle := fsStayOnTop;
end;

function TFormEx.ShowModal;
begin
  Result := inherited;

  if ModalResult in [mrAbort, mrCancel] then
    Abort;
end;

procedure TFormEx.WMInitMenuPopup;
begin
  if not Message.SystemMenu then
    Exit;

  // Update state of our stay-on-top menu item
  if FormStyle = fsStayOnTop then
    CheckMenuItem(Message.MenuPopup, idOnTop, MF_CHECKED)
  else
    CheckMenuItem(Message.MenuPopup, idOnTop, MF_UNCHECKED);
end;

procedure TFormEx.WMSysCommand;
var
  hSysMenu: HMENU;
begin
  if Message.CmdType = idOnTop then
  begin
    hSysMenu := GetSystemMenu(Handle, False);
    if FormStyle = fsNormal then
    begin
      FormStyle := fsStayOnTop;
      CheckMenuItem(hSysMenu, idOnTop, MF_CHECKED);
    end
    else
    begin
      FormStyle := fsNormal;
      CheckMenuItem(hSysMenu, idOnTop, MF_UNCHECKED);
    end;
  end
  else
    inherited;
end;

end.
