| Simple Piano
| PHREDA 2024
|
^r3/lib/sdl2gfx.r3
^r3/lib/sdl2mixer.r3
^r3/util/sdlgui.r3
^r3/lib/rand.r3

#chunk

#frec
  16.35   17.32   18.35   19.45   20.60   21.83   23.12   24.50   25.96   27.50   29.14   30.87 |0
  32.70   34.65   36.71   38.89   41.20   43.65   46.25   49.00   51.91   55.00   58.27   61.74 |1
  65.41   69.30   73.42   77.78   82.41   87.31   92.50   98.00  103.83  110.00  116.54  123.47 |2
 130.81  138.59  146.83  155.56  164.81  174.61  185.00  196.00  207.65  220.00  233.08  246.94 |3
 261.63  277.18  293.66  311.13  329.63  349.23  369.99  392.00  415.30  440.00  466.16  493.88 |4
 523.25  554.37  587.33  622.25  659.26  698.46  739.99  783.99  830.61  880.00  932.33  987.77 |5
1046.50 1108.73 1174.66 1244.51 1318.51 1396.91 1479.98 1567.98 1661.22 1760.00 1864.66 1975.53 |6
2093.00 2217.46 2349.32 2489.02 2637.02 2793.83 2959.96 3135.96 3322.44 3520.00 3729.31 3951.07 |7
4186.01 4434.92 4698.64 4978.03 5274.00 5587.65 5919.91 6271.93 6644.88 7040.00 7458.62 7902.13 |8

#fracname "C" "C#" "D" "D#" "E" "F" "F#" "G" "G#" "A0" "A#" "Bb" "B"

#off

:viewave | adr --
	8 + @ off +
	0 ( 1000 <? swap
		w@+ neg 8 >> 300 + pick2 swap
		sdlpoint
		swap 1 + ) 2drop ;

|typedef struct Mix_Chunk {
|    int allocated;
|    Uint8 *abuf;
|    Uint32 alen;
|    Uint8 volume;       /* Per-sample volume, 0-128 */
|} Mix_Chunk;

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
:interpolate | posscr possam -- possrc value
	w@+ swap w@ 
	pick2 $ffff and 	| v1 v0 p
	rot pick2 - *. + ;
	
:changepitch | lendes adrdes lensrc adrsrc -- adrdesend
	>b 16 << pick2 /	| lendes adrdes adv ; b:scr
	rot pick2 + 		| adrdes adv endadrdes
	rot 0 swap			| adv endadrdes 0 adrdes
	( pick2 <? swap		| adv enda nowa pos 
		dup 16 >> 1 << b> + 
		interpolate		| adv enda nowa pos v
		rot w!+			| adv enda pos nowa'
		swap pick3 +	| adv enda nowa' pos' 
		swap ) 2drop nip ;

:changelen | lendes adrdes adrsrc -- adrend
	>b b@+ swap !+		| copy header; len adrsr
	dup 16 + swap !+	| INI BUFFER
	over swap d!+		| LEN WAV
	128 swap c!+ 3 +	| lendes adrdes
	b@+ db@ swap		| lendes adrdes lensrc adrscr 
	changepitch ;

|------------------------------------------
#notes 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

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

|------------------------------------------
#playn * 25

:playdn | n --
	dup 'playn + c@ 1? ( 2drop ; ) drop
	dup 3 << 'notes + @ -1 swap 0 -1 Mix_PlayChannelTimed 1 << 1 or 
	swap 'playn + c! ;

:playup | n --
	dup 'playn + c@ 0? ( 2drop ; ) 
	1 >> 100 Mix_FadeOutChannel | 100 ms for avoid clicks
	0 swap 'playn + c! ;

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
	5 << 116 + 100
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
	5 << 100 + 100
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
	immgui 	
	$0 SDLcls
	
	180 20 immbox
	0 0 immat
	"Simple PIANO" immlabelc immdn
|	chunk infowav
|	$ff00 sdlcolor chunk viewave
	
	drawkeys
	
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
	drop ;
	
:init
	"media/ttf/Roboto-Medium.ttf" 16 TTF_OpenFont immSDL
	44100 $8010 1 1024 Mix_OpenAudio | minimal buffer for low latency
	"media/snd/piano-c.mp3" 
	"media/snd/DX7-Bass-c2.mp3" 
	mix_loadWAV 'chunk !
	makenotes
	;

: 
	"Resample wav" 1024 600 SDLinit
	init
	'main SDLshow
	SDLquit 	
;
