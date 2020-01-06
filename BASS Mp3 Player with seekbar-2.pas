unit Mp3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, bass, StdCtrls, ExtCtrls, Buttons;

type
  TMp3form = class(TForm)
    Opendlgsong: TOpenDialog;
    tmTrackBar: TTimer;
    PnlDisplay: TPanel;
    btnplay: TSpeedButton;
    Btnopen: TSpeedButton;
    btnstop: TSpeedButton;
    btnpause: TSpeedButton;
    btnprev: TSpeedButton;
    btnnext: TSpeedButton;
    Bevel1: TBevel;
    sbctrackbar: TScrollBar;
    sbcvolume: TScrollBar;
    LBPlaylist: TListBox;
    btnadd: TSpeedButton;
    btnremove: TSpeedButton;
    cborder: TComboBox;
    btnplopen: TSpeedButton;
    btnplsave: TSpeedButton;
    sbcfreq: TScrollBar;
    LBFiles: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnopenClick(Sender: TObject);
    procedure BtnPlayClick(Sender: TObject);
    procedure PauseClick(Sender: TObject);
    procedure StopClick(Sender: TObject);
    procedure sbctrackbarScroll(Sender: TObject; ScrollCode: TScrollCode;
      var ScrollPos: Integer);
    procedure tmTrackBarTimer(Sender: TObject);
    procedure btnaddClick(Sender: TObject);
    procedure btnremoveClick(Sender: TObject);
    procedure LBPlaylistDblClick(Sender: TObject);
    procedure LBPlaylistKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnprevClick(Sender: TObject);
    procedure btnnextClick(Sender: TObject);
    procedure cborderChange(Sender: TObject);
  private
    { Private declarations }
    procedure Addfile(Filename: string);
    procedure PlayItem(Item: integer);
    Procedure RemoveSelected;
  public
    { Public declarations }
  end;

var
  Mp3form: TMp3form;
  stream: HSTREAM;
  tracking: boolean;
implementation

{$R *.dfm}

procedure TMp3form.cborderChange(Sender: TObject);
begin

   {if cborder.ItemIndex = 0
   then
   repeat PlayItem(lbplaylist.ItemIndex);
   until cborder.ItemIndex <> 1;}


end;

//--------------------------------------------------------------------------//
// Custom procedures
//--------------------------------------------------------------------------//
procedure TMp3form.Addfile(Filename: string);
begin
    lbfiles.items.add(FileName);
    lbplaylist.Items.Add(ExtractFileName(FileName));

    If lbplaylist.ItemIndex = -1 then
    lbPlaylist.ItemIndex := lbPlaylist.Items.Count -1;

end;

procedure TMp3form.PlayItem(Item: integer);
begin

        if Item < 0 then exit;
        if stream <> 0 then
        BASS_StreamFree(Stream);

  stream := BASS_StreamCreateFile(False, PChar(LBFiles.Items.Strings[Item]), 0, 0, 0);
  if stream = 0 then
  ShowMessage('You really should pick a song to play before trying to play a song. EPIC FAIL!')

  else begin
  pnlDisplay.Caption := lbPlaylist.Items.Strings[Item];

  sbcTrackbar.Min := 0;
  sbcTrackbar.Max := Bass_ChannelGetLength(stream, BASS_POS_BYTE)-1;
  sbcTrackbar.Position := 0;
  BASS_ChannelPlay(Stream, False);
   end;
end;


 procedure TMp3form.RemoveSelected;
var
  OldIndex : Integer;
  begin
  OldIndex := lbPlaylist.ItemIndex;
  LbPlaylist.Items.Delete(OldIndex);
  LbFiles.Items.Delete(OldIndex);

  If OldIndex > lbplaylist.Items.Count - 1 then
    OldIndex := lbplaylist.Items.Count - 1;

  LbPlaylist.ItemIndex := OldIndex;

end;



//--------------------------------------------------------------------------//
// Form Events
//--------------------------------------------------------------------------//

procedure TMp3form.btnopenClick(Sender: TObject);
begin
    if OpenDlgSong.Execute = False then exit;

  AddFile(OpenDlgSong.FileName);
  lbplaylist.itemindex := lbplaylist.items.count - 1;
  PlayItem(lbplaylist.ItemIndex);
end;

procedure TMp3form.FormCreate(Sender: TObject);
begin
  if BASS_Init(-1, 44100, 0, Handle, nil) = false then
    showmessage('EPIC FAIL of audio initilization.')
end;

procedure TMp3form.FormDestroy(Sender: TObject);
begin
  BASS_Free();
end;

procedure TMp3form.BtnPlayClick(Sender: TObject);
begin
 If BASS_ChannelIsActive(stream) = BASS_ACTIVE_PAUSED then
  BASS_ChannelPlay(stream, False)
  else
  PlayItem(lbplaylist.ItemIndex);
end;

procedure TMp3form.PauseClick(Sender: TObject);
begin
  BASS_ChannelPause(stream);
end;

procedure TMp3form.StopClick(Sender: TObject);
begin
  BASS_ChannelStop(stream);
  BASS_ChannelSetPosition(stream, 0, 0);
end;

procedure TMp3form.sbctrackbarScroll(Sender: TObject; ScrollCode: TScrollCode;
  var ScrollPos: Integer);
begin
  If ScrollCode = scEndScroll then begin
    Bass_ChannelSetPosition(stream, sbcTrackbar.Position, BASS_POS_BYTE);
    Tracking := False;
  end else
    Tracking := True
end;

procedure TMp3form.tmTrackBarTimer(Sender: TObject);
begin
  if Tracking = False then
  sbcTrackbar.Position := BASS_ChannelGetPosition(stream, BASS_POS_BYTE);

end;



procedure TMp3form.btnaddClick(Sender: TObject);
begin
  if OpenDlgSong.Execute = False then exit;

  AddFile(OpenDlgSong.FileName);
end;





procedure TMp3form.btnremoveClick(Sender: TObject);
begin
      RemoveSelected;
end;

procedure TMp3form.LBPlaylistDblClick(Sender: TObject);
begin
 PlayItem(lbplaylist.ItemIndex);
end;

procedure TMp3form.LBPlaylistKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  If Key = Vk_Delete then
  RemoveSelected;
end;

procedure TMp3form.btnprevClick(Sender: TObject);
Begin
  If lbplaylist.itemindex = 0 then
   lbplaylist.itemindex := lbplaylist.Items.Count - 1 
else
   lbplaylist.itemindex := lbplaylist.itemindex - 1;
   PlayItem(lbplaylist.ItemIndex);
end;

// Below is halt on selection 1 in the playlist :P above is rollover code :D
{    lbplaylist.itemindex := lbplaylist.itemindex - 1;
    If lbplaylist.itemindex = -1 then
  lbplaylist.itemindex := lbplaylist.itemindex +1;
    PlayItem(lbplaylist.ItemIndex);
end;}

procedure TMp3form.btnnextClick(Sender: TObject);
Begin
  If lbplaylist.itemindex = lbplaylist.Items.Count - 1 then
   lbplaylist.itemindex := 0
else
   lbplaylist.itemindex := lbplaylist.itemindex + 1;
   PlayItem(lbplaylist.ItemIndex);
end;


