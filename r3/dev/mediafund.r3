| 
^r3/lib/sdl2gfx.r3
^r3/util/ui.r3


#MFStartup_p ::MFStartup MFStartup_p sys2 ;
#MFShutdown_p ::MFShutdown MFShutdown_p sys1 drop ;
#MFCreateMediaType_p ::MFCreateMediaType MFCreateMediaType_p sys1 ;
#MFEnumDeviceSources_p ::MFEnumDeviceSources MFEnumDeviceSources_p sys3 ; 
#MFCreateAttributes_p ::MFCreateAttributes MFCreateAttributes_p sys2 ;

#MFCreateSourceReaderFromURL_p ::MFCreateSourceReaderFromURL MFCreateSourceReaderFromURL_p sys3 ;
#MFCreateSourceReaderFromMediaSource_p ::MFCreateSourceReaderFromMediaSource MFCreateSourceReaderFromMediaSource_p sys3 ;

#CoInitializeEx_p ::CoInitializeEx CoInitializeEx_p sys2 ;
#CoUninitialize_p ::CoUninitialize CoUninitialize_p sys0 drop ;
#CoTaskMemFree_p ::CoTaskMemFree CoTaskMemFree_p sys1 drop ; 

:inilib
    "mfplat.dll" loadlib
	dup "MFStartup" getproc 'mfstartup_p !
	dup "MFShutdown" getproc 'MFShutdown_p !
	dup "MFCreateMediaType" getproc 'MFCreateMediaType_p !
	dup "MFCreateAttributes" getproc 'MFCreateAttributes_p !
	dup "MFEnumDeviceSources" getproc 'MFEnumDeviceSources_p !
	drop
    "mfreadwrite.dll" loadlib
	dup "MFCreateSourceReaderFromURL" getproc 'MFCreateSourceReaderFromURL_p !
	dup "MFCreateSourceReaderFromMediaSource" getproc 'MFCreateSourceReaderFromMediaSource_p !
	drop
	"ole32.dll" loadlib
	dup "CoInitializeEx" getproc 'CoInitializeEx_p !
	dup "CoUninitialize" getproc 'CoUninitialize_p !
	dup "CoTaskMemFree" getproc 'CoTaskMemFree_p !
	drop
	;
	

#pReader
#ptype

#setguid_p
#release_p
:release release_p sys1 drop ;

#readSample_p
:readSample readSample_p sys7 ;

#pSample
		
#wchar * 256
:towchar | str -- str
	'wchar swap ( c@+ 1? rot w!+ swap ) nip swap w! 'wchar ;

#MF_VERSION $700070 |$20070

|#MF_MT_MAJOR_TYPE $4687F8C948EBA18E $8F6AF9C9740A11BF
|#MF_MT_SUBTYPE $471442E8F7E34C9A $8C2435D729CB4BB7
|#MFMediaType_Video $0010000073646976 $719B3800AA000080

|#IID_IMFSourceReader	( $48 $be $9b $7b $71 $a9 $e5 $48 $89 $9b $29 $00 $72 $70 $96 $6c )
|#CLSID_MFSourceReader	( $92 $b3 $46 $17 $00 $71 $b2 $47 $b3 $58 $15 $49 $48 $77 $ba $7a )
|#MFVideoFormat_RGB32	( $16 $00 $00 $00 $00 $00 $10 $00 $80 $00 $00 $aa $00 $38 $9b $71 )

#MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE [ $c60ac5fe  $478f252a ] ( $a0 $ef $bc $8f $a5 $f7 $ca $d3 ) 
#MF_DEVSOURCE_ATTRIBUTE_SOURCE_TYPE_VIDCAP_GUID [ $8c9c6f8c $4b6f0d1b ] ( $9f $0b $6a $3b $6a $3b $1e $3b )
|// Nota: Existen variantes en distintos SDKs; si esta GUID no funciona en tu sistema 
|// reemplázala por  {$E7EDC9?} — si falla  te doy la variante alternativa. Sin embargo
|// más abajo usaré MF_DEVSOURCE_ATTRIBUTE_FRIENDLY_NAME para leer nombres.
#MF_DEVSOURCE_ATTRIBUTE_FRIENDLY_NAME [ $60d0e559  $4fa252f8 ] ( $bb $ce $ac $db $34 $a8 $ec $01 )
#MF_MT_FRAME_SIZE [ $1652c33d  $4012d6b2 ] ( $b8 $34 $72 $03 $08 $49 $a3 $7d )
#MF_MT_MAJOR_TYPE [ $48eba18e  $4687f8c9 ] ( $bf $11 $0a $74 $c9 $f9 $6a $8f )
#MF_MT_SUBTYPE [ $f7e34c9a $471442e8 ] ( $b7 $4a $20 $39 $5b $1e $16 $0e )
#MFMediaType_Video [ $73646976 $00100000 ] ( $80 $00 $00 $aa $00 $38 $9b $71 )
#MFVideoFormat_RGB32 [ $00000016 $00100000 ] ( $80 $00 $00 $aa $00 $38 $9b $71 )
	
#setCurrentMediaType_p

#MF_SOURCE_READER_ANY_STREAM          -1
#MF_SOURCE_READER_FIRST_VIDEO_STREAM  -2

#pAtributes
#ppDevices 


:mfstart

	0 0 CoInitializeEx 1? ( dup "error 1 %d" .println  ) drop | COINIT_MULTITHREADED 
	MF_VERSION 0 MFStartup 1? ( dup "error 2 %d" .println ) drop
	
	'pAtributes 1 MFCreateAttributes 1? ( dup "error 3 %d" .println ) drop

	
	|"capture://video"
	|"device://video"
	"test.mp4" 
	towchar 0 'pReader MFCreateSourceReaderFromURL 1? ( "error" .println ) drop
	
|	0 0 'preader MFCreateSourceReaderFromMediaSource 1? ( "error" .println ) drop
	
	'ptype MFCreateMediaType 1? ( "error" .println ) drop
	
	pType @ 24 3 << + @ 'setguid_p ! | geminis=14..gpt=24
  
	pType 'MF_MT_MAJOR_TYPE 'MFMediaType_Video setguid_p sys3 1? ( "error1" .println ) drop
	pType 'MF_MT_SUBTYPE 'MFVideoFormat_RGB32 setguid_p sys3 1? ( "error2" .println ) drop
	
	pReader @ 6 3 << + @ 'setCurrentMediaType_p !
	pReader @ 11 3 << + @ 'readSample_p !

	pType @ 2 3 << + @ 'release_p !
	
	pReader MF_SOURCE_READER_FIRST_VIDEO_STREAM 0 pType setCurrentMediaType_p sys4 1? ( "error3" .println ) drop
	|ptype release 
	;

:mfend
	MFShutdown 
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
	pReader MF_SOURCE_READER_FIRST_VIDEO_STREAM 'streamIdx 'flags 'ts 'pSample readSample 1? ( "error" .println ) drop
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
	
	mfstart
	'main SDLshow
	SDLquit
	mfend	
	waitesc
	;

