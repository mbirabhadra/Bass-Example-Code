uses
bass,..

type
  TForm1 = class(TForm)
    ...
  private
    { Private declarations }
    //=============================
    procedure Error(msg: string);
  public
    { Public declarations }
    channel:HSTREAM;
  end;
  
procedure TForm1.btnBrowseClick(Sender: TObject);
var
i:Integer;
begin
  if FileOpenDialog1.Execute() then
  begin
    BASS_ChannelStop(channel);
    edtFilePath.Clear;
    edtFilePath.Text := FileOpenDialog1.FileName;
  end;
 {for I := 0 to FileOpenDialog1.Files.Count-1 do
 begin
  ListBox1.Items.Add(FileOpenDialog1.Files[i]);
 end;}
end;

procedure TForm1.btnPauseClick(Sender: TObject);
begin
   BASS_ChannelPause(channel);
end;

procedure TForm1.btnPlayClick(Sender: TObject);
begin
  //Pause Resume handling first
  If BASS_ChannelIsActive(channel) = BASS_ACTIVE_PAUSED then
  begin
  BASS_ChannelPlay(channel, False);
  exit;
  end;


  //Fresh play
  if channel>0 then begin
    BASS_StreamFree(channel);  //destroy any previous channel if exists
    channel:=0;
  end;
  channel := BASS_StreamCreateFile(FALSE, PChar(edtFilePath.Text), 0, 0,BASS_UNICODE);
  //create the stream
  BASS_ChannelPlay(channel,false); // play the stream

end;

procedure TForm1.btnStopClick(Sender: TObject);
begin
 BASS_ChannelStop(channel);    //doesn't release the file resource - 
end;                           //for before explorer delete use below 

procedure TForm1.stopSoundExplorerly;
begin
  BASS_ChannelStop(channel);

  if channel>0 then begin
    BASS_StreamFree(channel);  //destroy any previous channel if exists
    channel:=0;
  end;
end;

procedure TForm1.Error(msg: string);
var
 s: string;
begin
 s := msg + #13#10 + '(Error code: ' + IntToStr(BASS_ErrorGetCode) + ')';
 MessageBox(Handle, PChar(s), nil, 0);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 // Close BASS
 BASS_Free();
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
    // check the correct BASS was loaded
   if (HIWORD(BASS_GetVersion) <> BASSVERSION) then
   begin
    MessageBox(0,'An incorrect version of BASS.DLL was loaded',nil,MB_ICONERROR);
    Halt;
   end;

   // Initialize audio - default device, 44100hz, stereo, 16 bits
   if not BASS_Init(-1, 44100, 0, Handle, nil) then
    Error('Error initializing audio!');
end;

