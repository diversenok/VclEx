unit VclEx.Form;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, Vcl.Controls, Vcl.Forms;

type
  TFormEx = class abstract (TForm)
  private
    const idOnTop = 10001;
    procedure WMSysCommand(var Message: TWMSysCommand); message WM_SYSCOMMAND;
  protected
    procedure DoClose(var Action: TCloseAction); override;
    procedure DoCreate; override;
  public
    function ShowModal: Integer; override;
  end;

implementation

{ TFormEx }

procedure TFormEx.DoClose(var Action: TCloseAction);
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

function TFormEx.ShowModal: Integer;
begin
  Result := inherited;

  if ModalResult = mrAbort then
    Abort;
end;

procedure TFormEx.WMSysCommand(var Message: TWMSysCommand);
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
