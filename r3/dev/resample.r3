^r3/win/sdl2gfx.r3
^r3/win/sdl2mixer.r3
^r3/util/sdlgui.r3
^r3/lib/rand.r3

|typedef struct Mix_Chunk {
|    int allocated;
|    Uint8 *abuf;
|    Uint32 alen;
|    Uint8 volume;       /* Per-sample volume, 0-128 */
|} Mix_Chunk;

#chunk
#chunk2

#frec
16.35 17.32 18.35 19.45 20.60 21.83 23.12 24.50 25.96 27.50 29.14 30.87 |o0
32.70 34.65 36.71 38.89 41.20 43.65 46.25 49.00 51.91 55.00 58.27 61.74 |1
65.41 69.30 73.42 77.78 82.41 87.31 92.50 98.00 103.83 110.00 116.54 123.47 |2
130.81 138.59 146.83 155.56 164.81 174.61 185.00 196.00 207.65 220.00 233.08 246.94 |3
261.63 277.18 293.66 311.13 329.63 349.23 369.99 392.00 415.30 440.00 466.16 493.88 |4
523.25 554.37 587.33  622.25 659.26 698.46 739.99 783.99 830.61 880.00 932.33 987.77 |5
1046.50 1108.73 1174.66 1244.51 1318.51 1396.91 1479.98 1567.98 1661.22 1760.00 1864.66 1975.53 |6
2093.00 2217.46 2349.32 2489.02 2637.02 2793.83 2959.96 3135.96 3322.44 3520.00 3729.31 3951.07 |7
4186.01 4434.92 4698.64 4978.03

#fracname "C" "C#" "D" "D#" "E" "F" "F#" "G" "G#" "A0" "A#" "Bb" "B"

	
#off

:viewave | adr --
	8 + @ off +
	0 ( 1000 <? swap
		w@+ neg 8 >> 300 + pick2 swap
		sdlpoint
		swap 1 + ) 2drop ;

:changew | adr --
	8 + @+ swap d@ 1 >> | adr len
	( 1? 1 - swap
		dup w@ 1 >> swap w!+
		swap ) 2drop ;

:fillwa | adr --
	8 + @+ dup >a >b
	d@ 3 >> | adr len
	( 1? 1 - 
		da@+ | read2
		dup 16 >> $ffff and swap $ffff and + 1 >>
		da@+ | read2
		dup 16 >> $ffff and swap $ffff and + 1 >>
		16 << or
		db!+
		) drop ;
		

:infowav | adr
	d@+ "allocate %d" immLabel immdn
	4 + | align
	@+ "buffer %h" immLabel immdn	
	d@+ "len %h" immLabel immdn	
	c@+ $ff and "vol %d" immLabel immdn immdn
	drop
	;
		
:interp | posscr possam -- possrc value
	w@+ swap w@ 
	pick2 $ffff and | v1 v0 p
	rot pick2 - *. +
	;
	
:changelen | lendes adrsrc adrdes --
	>b >a b@+ a!+	| copy header
	b@+ a> 16 + a!+ | lendes adrsrc
	db@+ pick2 da!+ | lendes adrsrc lensrc
	128 ca! 8 a+
	swap >b | lendes lensrc ; a:adrdes b:adrsrc
	16 << over / | lendes adv
	0 rot		| adv 0 elndes 
	1 >> ( 1? 1 - | adv posscr lendes
		swap	| adv lendes posscr 
		dup 16 >> 1 << b> + | adv lendes posscr SRCSAMPLE
		interp |w@+ swap w@ + 1 >> | media
		a> w!+ >a 
		pick2 +  | adv lendes posscr 
		swap
		) 3drop ;

:main
	immgui 	
	$0 SDLcls
	
	180 20 immbox
	0 0 immat
	"resample wav" immlabelc immdn
	chunk infowav
	chunk2 infowav
	

	$ff00 sdlcolor
	chunk viewave
	
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( -1 chunk 0 -1 Mix_PlayChannelTimed )
	<f2> =? ( -1 chunk2 0 -1 Mix_PlayChannelTimed )
	
	<f3> =? ( chunk changew )
	<f4> =? ( chunk fillwa )
	<f5> =? ( $1bc00 chunk2 chunk changelen )
	<f6> =? ( $3bc00 chunk2 chunk changelen )
	<up> =? ( 40 'off +! )
	<dn> =? ( -40 'off +! )
	drop ;
	
:init
	"media/ttf/Roboto-Medium.ttf" 16 TTF_OpenFont immSDL
	44100 $8010 1 1024 Mix_OpenAudio | minimal buffer for low latency
	"media/snd/piano-c.mp3" mix_loadWAV 'chunk !
	here 'chunk2 !
	;

: 
"Resample wav" 1024 600 SDLinit
init
'main SDLshow
SDLquit 	
;
