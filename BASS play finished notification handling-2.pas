//1. make a global variable to handle Sync:

syncHandle: DWORD;         // sync callback handle

//2. make a callback function (should be global function and not member!):

// sync callback func to trigger (at end of playing a song)
procedure syncAtEnd(handle: HSYNC; channel, data: DWORD; user: DWORD); stdcall;
begin

  // you can put here all the stuff that you want this callback func will do

end;

//3. in your "play" button, after loading a stream/music, apply the callback to your stream/music handle:

syncHandle := BASS_ChannelSetSync(chan, BASS_SYNC_END, 0, @syncAtEnd, 0);

//* Don't forget to Free the Previously applied synced handle before loading a new stream/music with:

BASS_ChannelRemoveSync(chan, syncHandle);
//* That should be fine :)