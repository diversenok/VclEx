unit DemoForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, VclEx.ListView, System.ImageList, Vcl.ImgList, Vcl.Menus;

type
  TFormDemo = class(TForm)
    ListViewEx: TListViewEx;
    ComboBoxColumn: TComboBox;
    SearchBox: TButtonedEdit;
    SearchButtons: TImageList;
    PopupMenu: TPopupMenu;
    SomeActionMenu: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure SearchBoxRightButtonClick(Sender: TObject);
    procedure SearchBoxKeyPress(Sender: TObject; var Key: Char);
    procedure SearchBoxChange(Sender: TObject);
  private
    procedure InitColumnList;
  public
    { Public declarations }
  end;

var
  FormDemo: TFormDemo;

implementation

{$R *.dfm}

procedure TFormDemo.FormCreate(Sender: TObject);
var
  Item: TListItemEx;
begin
  InitColumnList;

  Item := ListViewEx.Items.Add;
  Item.Cell[0] := '42';
  Item.Cell[1] := 'Accessing data with Item.Cell[i]';
  Item.Cell[2] := 'where 0 is Caption while 1..n are SubItems';

  Item := ListViewEx.Items.Add;
  Item.Cell[0] := '304';
  Item.Cell[1] := 'Ctrl + C works automatically';
  Item.Cell[2] := 'It copies content of the main column';

  Item := ListViewEx.Items.Add;
  Item.Cell[0] := '315';
  Item.Cell[1] := 'Even when multiple items are selected';
  Item.Cell[2] := 'The main column is set via ClipboardSourceColumn';

  Item := ListViewEx.Items.Add;
  Item.Cell[0] := '316';
  Item.Cell[1] := 'Ctrl+Shift+C copies all columns';
  Item.Cell[2] := 'Again, even in multi-select mode';

  Item := ListViewEx.Items.Add;
  Item.Cell[0] := '383';
  Item.Cell[1] := 'Ctrl + A selects all items';
  Item.Cell[2] := 'And Space checks them simultaneously';

  Item := ListViewEx.Items.Add;
  Item.Cell[0] := '97';
  Item.Cell[1] := 'Rows can have hints. This one does.';
  Item.Cell[2] := 'Hover the mouse over it.';
  Item.Hint := 'This it an example hint message';

  Item := ListViewEx.Items.Add;
  Item.Cell[0] := '113';
  Item.Cell[1] := 'Rows can also have background color';
  Item.Color := clSilver;

  Item := ListViewEx.Items.Add;
  Item.Cell[1] := 'You can configure PopupMenu to appear';
  Item.Cell[2] := 'only on items with PopupOnItemsOnly';
  Item.Hint := 'Which means you can''t invoke it without selecting anything';

  Item := ListViewEx.Items.Add;
  Item.Cell[2] := 'You do not need to preallocate SubItems';

  Item := ListViewEx.Items.Add;
  Item.Cell[2] := 'Just access them with Cell[i]';
end;

procedure TFormDemo.InitColumnList;
var
  i: Integer;
begin
  // Just add all column captions to the ComboBox
  ComboBoxColumn.Items.BeginUpdate;

  for i := 0 to ListViewEx.Columns.Count - 1 do
    ComboBoxColumn.Items.Add(ListViewEx.Columns[i].Caption);

  ComboBoxColumn.Items.EndUpdate;
end;

procedure TFormDemo.SearchBoxChange(Sender: TObject);
const
  GROUP_SEARCH_IND = 0;
var
  i: Integer;
begin
  // Some cool trick to implement search if you don't use item groups.
  // We have a group that shows search result while we move everything else
  // to the -1 group to hide.

  // Each item has a Match method which is useful for searching text.

  ListViewEx.GroupView := (SearchBox.Text <> '');

  if SearchBox.Text = '' then
    Exit;

  // The value of (ComboBoxColumn.ItemIndex - 1) is -1 in case of searching
  // in all columns, and is the column index if one is selected

  for i := 0 to ListViewEx.Items.Count - 1 do
    if ListViewEx.Items[i].Matches(SearchBox.Text,
      ComboBoxColumn.ItemIndex - 1) then
      ListViewEx.Items[i].GroupID := GROUP_SEARCH_IND
    else
      ListViewEx.Items[i].GroupID := -1;
end;

procedure TFormDemo.SearchBoxKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then
     SearchBox.Text := ''; // Escape pressed
end;

procedure TFormDemo.SearchBoxRightButtonClick(Sender: TObject);
begin
  SearchBox.Text := '';
end;

end.
