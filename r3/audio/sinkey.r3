| sound with buffer without callback
| PHREDA 2024
|
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2mixer.r3
^r3/util/sdlgui.r3
^r3/lib/rand.r3
^r3/util/varanim.r3
^r3/util/ttext.r3


#audio_device |SDL_AudioDeviceID 
#audio_spec * 32

:setaudio 
44100 'audio_spec 0 + d! |freq: Offset 0 bytes
$8010 'audio_spec 4 + w! |format: Offset 4 bytes
2 'audio_spec 6 + c! |channels: Offset 6 bytes
|'audio_spec 7 + c! |silence: Offset 7 bytes
2048 'audio_spec 8 + w! |samples: Offset 8 bytes
|'audio_spec 10 + w! |padding: Offset 10 bytes
|'audio_spec 12 + d! |size: Offset 12 bytes
0 'audio_spec 16 + ! |callback: Offset 16 bytes
|'audio_spec 24 + ! |userdata: Offset 24 bytes	
	;
	
#buffer * 8192

:iniaudio
 	setaudio 
	0 0 'audio_spec 0 0 SDL_OpenAudioDevice 'audio_device !
	audio_device 0 SDL_PauseAudioDevice
	;	

:drawbuffer
	$ffffff sdlcolor
	'buffer >a 
	0 ( 1024 <? 1+
		da@+ 
		over over $ffff and 9 >> 300 + SDLPoint
		over swap 16 >> $ffff and 9 >> 440 + SDLPoint
		) drop ;

#key
#phase	
#freq

:play
	audio_device 'buffer 8192 SDL_QueueAudio ;
	
:noise
	'buffer >a 
	2048 ( 1? 1-
		rand 
		da!+ ) drop
	play ;
	
:sine
	'buffer >a 
	phase
	2048 ( 1? 1- swap 
		freq +
		dup sin 1.0 + 1 >> | volumen
		$ffff and 1 >> dup 16 << or
		da!+ swap ) drop
	'phase !
	play ;
	
|------------------------------------------
#playn * 25

:playdn | n --
	dup 'playn + c@ 1? ( 2drop ; ) drop
	
	dup 0.0015 * 'freq !
	sine
|	dup 3 << 'notes + @ -1 swap 0 -1 Mix_PlayChannelTimed 
	1 
	1 << 1 or  swap 'playn + c! ;

:playup | n --
	dup 'playn + c@ 0? ( 2drop ; ) 
|	1 >> 100 Mix_FadeOutChannel | 100 ms for avoid clicks
	drop
	
	0 swap 'playn + c! ;

|---------------------------------------------------
#keyw ( 0 2 4 5 7 9 11 12 14 16 17 19 21 23 	-1 )
#keyb (  1 3 0 6 8 10 0  13 15 0  18 20 22 		-1 )
	
:colork
	dup 'playn + c@ 
	0? ( $404040 nip ; )
	$e4bed3 nip ;
	
:pressk | n x y --
	pick2 'playn + c@ 
	1? ( drop ; ) drop
	$0 sdlcolor
	over 1 + over 46 +
	30 4 sdlFRect ;

:bkey | n --
	0? ( drop ; )
	colork sdlcolor
	over 'keyb - 
	5 << 16 + 120
	2dup 30 50 sdlFRect
	pressk
	$0 sdlcolor
	30 50 sdlRect
	drop ;
	
:colork
	dup 'playn + c@ 
	0? ( $fefefe nip ; )
	$7cd9e9 nip ;
	
:pressk | n x y --
	pick2 'playn + c@ 
	1? ( drop ; ) drop
	$808080 sdlcolor
	over 1 + over 96 +
	30 4 sdlFRect ;
	
:wkey | n --
	colork sdlcolor
	over 'keyw -
	5 << 0 + 120
	2dup 32 100 sdlFRect
	pressk
	$0 sdlcolor
	32 100 sdlRect
	drop ;

:drawkeys
	'keyw ( c@+ +? wkey ) 2drop
	'keyb ( c@+ +? bkey ) 2drop
	;

|-------------------------------------------
:main
	vupdate
	$0 SDLcls
	2.0 tsize $6 tcol 
	10 10 tat "Synte" tprint tcr	
	1.0 tsize $3 tcol 
	audio_device SDL_GetQueuedAudioSize "%d" tprint
	
	drawkeys
	drawbuffer	
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	<q> =? ( 0 playdn ) <2> =? ( 1 playdn )
	<w> =? ( 2 playdn ) <3> =? ( 3 playdn )
	<e> =? ( 4 playdn ) 
	<r> =? ( 5 playdn ) <5> =? ( 6 playdn ) 
	<t> =? ( 7 playdn ) <6> =? ( 8 playdn )
	<y> =? ( 9 playdn ) <7> =? ( 10 playdn )
	<u> =? ( 11 playdn )
	
	<z> =? ( 12 playdn ) <s> =? ( 13 playdn )
	<x> =? ( 14 playdn ) <d> =? ( 15 playdn )
	<c> =? ( 16 playdn )
	<v> =? ( 17 playdn ) <g> =? ( 18 playdn )
	<b> =? ( 19 playdn ) <h> =? ( 20 playdn )
	<n> =? ( 21 playdn ) <j> =? ( 22 playdn )
	<m> =? ( 23 playdn )

	>q< =? ( 0 playup ) >2< =? ( 1 playup )
	>w< =? ( 2 playup ) >3< =? ( 3 playup )
	>e< =? ( 4 playup ) 
	>r< =? ( 5 playup ) >5< =? ( 6 playup ) 
	>t< =? ( 7 playup ) >6< =? ( 8 playup )
	>y< =? ( 9 playup ) >7< =? ( 10 playup )
	>u< =? ( 11 playup )
	
	>z< =? ( 12 playup ) >s< =? ( 13 playup )
	>x< =? ( 14 playup ) >d< =? ( 15 playup )
	>c< =? ( 16 playup )
	>v< =? ( 17 playup ) >g< =? ( 18 playup )
	>b< =? ( 19 playup ) >h< =? ( 20 playup )
	>n< =? ( 21 playup ) >j< =? ( 22 playup )
	>m< =? ( 23 playup )
	<f1> =? ( play )
	drop ;
	
	
: 
	"generate buffer" 1024 600 SDLinit
	tini
	
	iniaudio

	'main SDLshow
	SDLquit 	
;
