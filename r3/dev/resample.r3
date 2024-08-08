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

:infowav | adr
	d@+ "allocate %d" immLabel immdn
	4 + | align
	@+ "buffer %h" immLabel immdn	
	d@+ "len %h" immLabel immdn	
	c@+ $ff and "vol %d" immLabel immdn immdn
	drop
	;
	
:wavlen | chunk -- len
	16 + d@ ;
	
|---------- copy and change length music chunk
:interp | posscr possam -- possrc value
	w@+ swap w@ 
	pick2 $ffff and | v1 v0 p
	rot pick2 - *. +
	;
	
:changelen | lendes adrdes adrsrc -- adrend
	>b b@+ swap !+	| copy header; len adrsr
	dup 16 + swap !+ | INI BUFFER
	over swap d!+	| LEN WAV
	128 swap c!+ 3 + | lendes adrdes
	b@+				| lendes adrdes adrscr
	db@				| lendes adrdes adrscr lensrc
	swap >b			| lendes adrdes lensrc; b:scr
	16 << pick2 /	| lendes adrdes adv
	rot pick2 + 	| adrdes adv endadrdes
	rot 0 swap		| adv endadrdes 0 adrdes
	( pick2 <? swap	| adv enda nowa pos 
		dup 16 >> 1 << b> + 
		interp		| adv enda nowa pos v
		rot w!+		| adv enda pos nowa'
		swap pick3 + | adv enda nowa' pos' 
		swap ) 2drop nip ;

|------------------------------------------		
#notes 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

:playnot | n --
	3 << 'notes + @ sndplay ;
	
:makenotes
	chunk wavlen 
	12 3 * 3 << 'frec + @  | len fa ; c2 first note
	'notes >a				| len fa note
	chunk a!+
	1 ( 24 <?				| len fa n
		dup "generate %d note" .println
		12 3 * over + 3 << 'frec + @ | len fa n fra
		2over rot */ | len fa n largo | len fa frac */ -->largo
		here a!+ 
		here chunk changelen 'here !
		1 + ) 3drop ;

:main
	immgui 	
	$0 SDLcls
	
	180 20 immbox
	0 0 immat
	"resample wav" immlabelc immdn
	chunk infowav

	$ff00 sdlcolor
	|chunk viewave
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )

	<up> =? ( 64 'off +! ) <dn> =? ( -64 'off +! )
	<q> =? ( 0 playnot ) <2> =? ( 1 playnot )
	<w> =? ( 2 playnot ) <3> =? ( 3 playnot )
	<e> =? ( 4 playnot ) 
	<r> =? ( 5 playnot ) <5> =? ( 6 playnot ) 
	<t> =? ( 7 playnot ) <6> =? ( 8 playnot )
	<y> =? ( 9 playnot ) <7> =? ( 10 playnot )
	<u> =? ( 11 playnot )
	
	<z> =? ( 12 playnot ) <s> =? ( 13 playnot )
	<x> =? ( 14 playnot ) <d> =? ( 15 playnot )
	<c> =? ( 16 playnot )
	<v> =? ( 17 playnot ) <g> =? ( 18 playnot )
	<b> =? ( 19 playnot ) <h> =? ( 20 playnot )
	<n> =? ( 21 playnot ) <j> =? ( 22 playnot )
	<m> =? ( 23 playnot )
	drop ;
	
:init
	"media/ttf/Roboto-Medium.ttf" 16 TTF_OpenFont immSDL
	44100 $8010 1 1024 Mix_OpenAudio | minimal buffer for low latency
	"media/snd/piano-c.mp3" mix_loadWAV 'chunk !
	makenotes
	;

: 
	"Resample wav" 1024 600 SDLinit
	init
	'main SDLshow
	SDLquit 	
;
