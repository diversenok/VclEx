unit VclEx.Edit;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls,
  Winapi.Messages;

type
  TEditEx = class(TEdit)
  protected
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure KeyPress(var Key: Char); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
  end;

  TButtonedEditEx = class(TButtonedEdit)
  protected
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure KeyPress(var Key: Char); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
  end;

procedure Register;

implementation

uses
  Winapi.Windows;

procedure Register;
begin
  RegisterComponents('Extensions', [TEditEx, TButtonedEditEx]);
end;

var
  SuppressLeftMove: Boolean;

function EditWordBreakProc(
  TextStart: PWideChar;
  Index: Integer;
  TextLength: Integer;
  Code: Cardinal
): Integer; stdcall;
var
  LastChar, Cursor: PWideChar;
  FoundNonDelimiter: Boolean;
  function IsCursorDelimiter: Boolean;
  const
    DELIMITERS = [#9, ' ', '!', '"', '#', '$', '%', '&', '''', '(', ')', '*',
      '+', ',', '-', '.', '/', ':', ';', '<', '=', '>', '?', '@', '[', '\', ']',
      '^', '_', '`', '{', '|', '}', '~'];
  begin
    Result := (Cursor < TextStart) or (Cursor > LastChar) or CharInSet(Cursor^,
      DELIMITERS);
  end;
begin
  if Index < 0 then
    Index := 0
  else if Index > TextLength then
    Index := TextLength;

  Cursor := TextStart + Index;
  LastChar := TextStart + TextLength - 1;

  case Code of
    WB_ISDELIMITER:
    begin
      // Hack: Windows only calls this code for Ctrl+Right; use it to suppress
      // the effect of WB_LEFT (which can be invoked as part of WB_RIGHT and
      // cancel it out)
      SuppressLeftMove := True;
      Result := Integer(IsCursorDelimiter);
    end;

    WB_LEFT:
      if SuppressLeftMove then
      begin
        // Hack: Suppress most of WB_LEFT's effects when called from Ctrl+Right,
        // but keep a left shift by one (since WB_RIGHT will start on the next
        // character)
        SuppressLeftMove := False;

        if Index > 0 then
          Result := Index - 1
        else
          Result := 0;
      end
      else if Cursor <= TextStart then
        Result := 0
      else
      begin
        // If we are inside a word, find where is starts by skipping all
        // non-delimiters to the left. If we are next to a delimiter,
        // skip all delimiters plus one word to the left.
        FoundNonDelimiter := False;

        repeat
          Cursor := CharPrevW(TextStart, Cursor);

          if Cursor <= TextStart then
            Break
          else if IsCursorDelimiter then
          begin
            if FoundNonDelimiter then
              Break;
          end
          else
            FoundNonDelimiter := True;

        until False;

        Result := Cursor - TextStart;

        if (Result > 0) and (Result < TextLength) then
        begin
          Inc(Cursor);
          Inc(Result);
        end;
      end;

    WB_RIGHT:
    begin
      // Skip the word (when inside) and the delimiter after it.
      SuppressLeftMove := False;
      FoundNonDelimiter := not IsCursorDelimiter;

      repeat
        if Cursor > LastChar then
          Break;

        Cursor := CharNextW(Cursor);

        if Cursor > LastChar then
          Break;

        if IsCursorDelimiter then
          FoundNonDelimiter := False
        else if not FoundNonDelimiter then
          Break;

      until False;

      Result := Cursor - TextStart;
    end;
  else
    Result := 0;
  end;
end;

function HandleCtrlBackspace(
  Edit: TCustomEdit;
  var Message: TWMKeyDown
): Boolean;
var
  SelStart, SelEnd: Integer;
begin
  Result := False;

  // Handle Ctrl+Backspace to erase the word on the left
  if (GetKeyState(VK_CONTROL) < 0) and (Message.CharCode = VK_BACK) then
  begin
    SendMessageW(Edit.Handle, EM_GETSEL, WPARAM(@SelStart), LPARAM(@SelEnd));

    // Only if nothing is selected
    if SelStart = SelEnd then
    begin
      // Identify where the word starts
      SelStart := EditWordBreakProc(PWideChar(Edit.Text), SelStart, SelStart + 1,
        WB_LEFT);

      // Select and erase it
      SendMessageW(Edit.Handle, EM_SETSEL, WPARAM(SelStart), LPARAM(SelEnd));
      SendMessageW(Edit.Handle, EM_REPLACESEL, 1, LPARAM(nil));
      Result := True;
    end;
  end;
end;

{ TEditEx }

procedure TEditEx.CreateWindowHandle;
begin
  inherited;
  SendMessageW(Handle, EM_SETWORDBREAKPROC, 0, LPARAM(@EditWordBreakProc));
end;

procedure TEditEx.KeyPress;
begin
  // Avoid adding the DEL character on Crtl+Backspace
  if (GetKeyState(VK_CONTROL) < 0) and (Key = #$7F) then
    Key := #0;

  inherited;
end;

procedure TEditEx.WMKeyDown;
begin
  if not HandleCtrlBackspace(Self, Message) then
    inherited;
end;

{ TButtonedEditEx }

procedure TButtonedEditEx.CreateWindowHandle;
begin
  inherited;
  SendMessageW(Handle, EM_SETWORDBREAKPROC, 0, LPARAM(@EditWordBreakProc));
end;

procedure TButtonedEditEx.KeyPress;
begin
  // Avoid adding the DEL character on Crtl+Backspace
  if (GetKeyState(VK_CONTROL) < 0) and (Key = #$7F) then
    Key := #0;

  inherited;
end;

procedure TButtonedEditEx.WMKeyDown;
begin
  if not HandleCtrlBackspace(Self, Message) then
    inherited;
end;

end.
