unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  ComCtrls, Menus, ColorBox;

type

  { TForm1 }

  TForm1 = class(TForm)
    ColorBox1: TColorBox;
    Edit1: TEdit;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItemAbout: TMenuItem;
    MenuItemClear: TMenuItem;
    MenuItemExit: TMenuItem;
    MenuItemHelp: TMenuItem;
    MenuItemN1: TMenuItem;
    MenuItemOpen: TMenuItem;
    MenuItemSave: TMenuItem;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    SaveDialog1: TSaveDialog;
    UpDown1: TUpDown;
    procedure ColorBox1Change(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuItemAboutClick(Sender: TObject);
    procedure MenuItemClearClick(Sender: TObject);
    procedure MenuItemExitClick(Sender: TObject);
    procedure MenuItemHelpClick(Sender: TObject);
    procedure MenuItemOpenClick(Sender: TObject);
    procedure MenuItemSaveClick(Sender: TObject);
    procedure UpDown1Changing(Sender: TObject; var AllowChange: Boolean);
    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
  private
    Drawing: Boolean;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
begin
  Drawing := False;

  // Очистка поля рисования
  Image1.Canvas.Brush.Color := clWhite;
  Image1.Canvas.Brush.Style := bsSolid;
  Image1.Canvas.FillRect(0, 0, Image1.Width, Image1.Height);

  // Настройка пера
  Image1.Canvas.Pen.Color := clBlack;
  Image1.Canvas.Pen.Width := 1;

  // Настройка ColorBox
  ColorBox1.Style := [cbStandardColors];
  ColorBox1.DefaultColorColor := clBlack;
  ColorBox1.Selected := clBlack;

  // Настройка Edit1 и UpDown1 для толщины линии
  Edit1.Text := '1';
  Edit1.Alignment := taCenter;

  UpDown1.Associate := Edit1;
  UpDown1.Min := 1;
  UpDown1.Max := 20;
  UpDown1.Position := 1;

  // Настройка диалогов
  OpenDialog1.Filter := 'Изображения (*.bmp;*.jpg;*.png)|*.bmp;*.jpg;*.jpeg;*.png|Все файлы (*.*)|*.*';
  SaveDialog1.Filter := 'BMP изображения (*.bmp)|*.bmp|PNG изображения (*.png)|*.png';
  SaveDialog1.DefaultExt := 'bmp';
end;

procedure TForm1.ColorBox1Change(Sender: TObject);
begin
  Image1.Canvas.Pen.Color := ColorBox1.Selected;
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
  try
    Image1.Canvas.Pen.Width := StrToInt(Edit1.Text);
  except
    Image1.Canvas.Pen.Width := 1;
  end;
end;

procedure TForm1.UpDown1Changing(Sender: TObject; var AllowChange: Boolean);
begin
  Image1.Canvas.Pen.Width := UpDown1.Position;
end;

procedure TForm1.UpDown1Click(Sender: TObject; Button: TUDBtnType);
begin

end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  with Image1.Canvas do
  begin
    case Button of
      mbLeft:
        begin
          Drawing := True;
          MoveTo(X, Y);
        end;
      mbRight:
        begin
          Brush.Color := Pen.Color;
          FloodFill(X, Y, Pixels[X, Y], fsSurface);
        end;
    end;
  end;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if (ssLeft in Shift) and Drawing then
  begin
    Image1.Canvas.LineTo(X, Y);
  end;
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then
    Drawing := False;
end;

procedure TForm1.MenuItemClearClick(Sender: TObject);
begin
  Image1.Canvas.Brush.Color := clWhite;
  Image1.Canvas.Brush.Style := bsSolid;
  Image1.Canvas.FillRect(0, 0, Image1.Width, Image1.Height);
  Image1.Canvas.Pen.Color := ColorBox1.Selected;
  Image1.Canvas.Pen.Width := UpDown1.Position;
end;

procedure TForm1.MenuItemOpenClick(Sender: TObject);
var
  BMP: TBitmap;
  JPG: TJpegImage;
  Ext: string;
begin
  if OpenDialog1.Execute then
  begin
    Ext := LowerCase(ExtractFileExt(OpenDialog1.FileName));
    try
      if (Ext = '.bmp') then
      begin
        BMP := TBitmap.Create;
        try
          BMP.LoadFromFile(OpenDialog1.FileName);
          Image1.Picture.Assign(BMP);
        finally
          BMP.Free;
        end;
      end
      else if (Ext = '.jpg') or (Ext = '.jpeg') then
      begin
        JPG := TJpegImage.Create;
        try
          JPG.LoadFromFile(OpenDialog1.FileName);
          Image1.Picture.Assign(JPG);
        finally
          JPG.Free;
        end;
      end
      else if (Ext = '.png') then
      begin
        Image1.Picture.LoadFromFile(OpenDialog1.FileName);
      end;

      Image1.Canvas.Pen.Color := ColorBox1.Selected;
      Image1.Canvas.Pen.Width := UpDown1.Position;
    except
      ShowMessage('Ошибка при открытии файла!');
    end;
  end;
end;

procedure TForm1.MenuItemSaveClick(Sender: TObject);
begin
  if SaveDialog1.Execute then
  begin
    try
      if LowerCase(ExtractFileExt(SaveDialog1.FileName)) = '.png' then
        Image1.Picture.SaveToFile(SaveDialog1.FileName)
      else
        Image1.Picture.Bitmap.SaveToFile(SaveDialog1.FileName);
    except
      ShowMessage('Ошибка при сохранении файла!');
    end;
  end;
end;

procedure TForm1.MenuItemExitClick(Sender: TObject);
begin
  Close;
end;

procedure TForm1.MenuItemHelpClick(Sender: TObject);
begin
  ShowMessage('Графический редактор' + #13#10 +
              #13#10 +
              'УПРАВЛЕНИЕ:' + #13#10 +
              '• Левая кнопка мыши - рисование' + #13#10 +
              '• Правая кнопка мыши - заливка' + #13#10 +
              '• Выберите цвет в списке' + #13#10 +
              '• Выберите толщину линии (1-20)');
end;

procedure TForm1.MenuItemAboutClick(Sender: TObject);
begin
  if MessageDlg('Об авторе',
    'Графический редактор' + #13#10 +
    'Версия 1.0' + #13#10 +
    #13#10 +
    'Разработчик: Артём Ховрин (zaqrax1)' + #13#10 +
    'Группа: 1ИСиП-25-2с' + #13#10 +
    #13#10 +
    'Открыть мой GitHub?',
    mtInformation, [mbYes, mbNo], 0) = mrYes then
  begin
    OpenURL('https://github.com/zaqrax1');
  end;
end;

end.
