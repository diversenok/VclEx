program DemoProject;

uses
  Vcl.Forms,
  DemoForm in 'DemoForm.pas' {FormDemo},
  VclEx.ListView in '..\VclEx.ListView.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormDemo, FormDemo);
  Application.Run;
end.
