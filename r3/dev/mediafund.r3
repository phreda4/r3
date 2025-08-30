^r3/lib/sdl2gfx.r3
^r3/util/ui.r3


#MFStartup_p ::MFStartup MFStartup_p sys2 ;
#MFShutdown_p ::MFShutdown MFShutdown_p sys1 ;
#MFCreateMediaType_p ::MFCreateMediaType MFCreateMediaType_p sys1 ;

#MFCreateSourceReaderFromURL_p ::MFCreateSourceReaderFromURL MFCreateSourceReaderFromURL_p sys3 ;

:inilib
    "mfplat.dll" loadlib
	dup "MFStartup" getproc 'mfstartup_p !
	dup "MFShutdown" getproc 'MFShutdown_p !
	dup "MFCreateMediaType" getproc 'MFCreateMediaType_p !
	drop
    "mf.dll" loadlib
	drop
    "mfreadwrite.dll" loadlib
	dup "MFCreateSourceReaderFromURL" getproc 'MFCreateSourceReaderFromURL_p !
	drop
	;
	

#pReader
#ptype

#setgui_p
#release_p
:release release_p sys1 drop ;

#readSample_p
:readSample readSample_p sys7 ;

#pSample
		
#wchar * 256
:towchar | str -- str
	'wchar swap ( c@+ 1? rot w!+ swap ) nip swap w! 'wchar ;

#MF_VERSION $20070
#MF_MT_MAJOR_TYPE $4687F8C948EBA18E $8F6AF9C9740A11BF
#MF_MT_SUBTYPE $471442E8F7E34C9A $8C2435D729CB4BB7
#MFMediaType_Video $0010000073646976 $719B3800AA000080
#MFVideoFormat_RGB32 $0010000000000016 $719B3800AA000080

#setCurrentMediaType_p

#MF_SOURCE_READER_FIRST_VIDEO_STREAM      $FFFFFFFC


:ini
	MF_VERSION 0 MFStartup 1? ( "error" .println ) drop
	"capture://video"
	|"device://video"
	|"test.mp4" 
	towchar 0 'pReader MFCreateSourceReaderFromURL 1? ( "error" .println ) drop
	
	'ptype MFCreateMediaType 1? ( "error" .println ) drop
	
	pType @ 13 3 << + @ 'setgui_p !
  
	pType 'MF_MT_MAJOR_TYPE 'MFMediaType_Video setgui_p sys3 1? ( "error1" .println ) drop
	pType 'MF_MT_SUBTYPE 'MFVideoFormat_RGB32 setgui_p sys3 1? ( "error2" .println ) drop
	
	pReader @ 8 3 << + @ 'setCurrentMediaType_p !
	pReader @ 9 3 << + @ 'readSample_p !

	pType @ 2 3 << + @ 'release_p !
	
	|pReader MF_SOURCE_READER_FIRST_VIDEO_STREAM 0 pType setCurrentMediaType_p sys4 1? ( "error3" .println ) drop
	|ptype release 
	;

#streamIdx
#flags
#ts
#pBuffer

#convert_p	
#lock_p
#unlock_p

#texcam
#data
#maxlen
#curlen

:getframe
	pReader MF_SOURCE_READER_FIRST_VIDEO_STREAM 0 'streamIdx 'flags 'ts 'pSample readSample 1? ( "error" .println ) drop
	pSample 10 3 << + 'convert_p !
	
	pSample 'pBuffer convert_p sys2 1? ( "error" .println ) drop
	
	pBuffer 4 3 << + 'lock_p !
	pBuffer 4 3 << + 'unlock_p !
	
	pBuffer 'data 'maxlen 'curlen lock_p sys4 1? ( "error" .println ) drop
	
	texcam 0 data 640 4 * SDL_UpdateTexture
	
	pBuffer unlock_p sys1 1? ( "error" .println ) drop
	
	pBuffer release
	pSample release
	;

|-----------------------------
#font

:main
	|getframe
	
	0 SDLcls
	8 8 txat "Cam" txprint
	512 310 texcam sprite
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	drop
	;
	
|-----------------------------
|-----------------------------	
:	
	inilib

	"R3d4" 1280 720 SDLinit
	"media/ttf/Roboto-bold.ttf" 24 txload dup 
	txfont 'font !
	
	SDLrenderer $16362004 2 640 480 SDL_CreateTexture 'texcam !
	ini
	'main SDLshow
	SDLquit 
	waitesc
	;
