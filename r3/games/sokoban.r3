| sokoban
| PHREDA 2023
| MC 2020
| Sprites from: https://kenney.nl/assets/
| Levels  from: https://github.com/begoon/sokoban-maps

^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3
^r3/util/ttfont.r3
^r3/games/sokoban.levels.r3

#sprites		| sprites
#nlevel 0		| map level
#xp 1 #yp 1 	| position
#fp				| face
#strstate * 32
#xmap #ymap
#zmap #zspr

#undo. #undo>	| undo buffer

:loadlevel | n --
	mapdecomp 			| level decompress
	c@+ 'xp ! c@ 'yp !	| player pos
	undo. 'undo> !		| reset undo
	"" 'strstate strcpy
	sw 100 - mapw / 
	sh 100 - maph / 
	min  | size
	dup	'zmap !
	10 << $800 + 'zspr ! | adjust for space in sprites
	sw mapw zmap * - 1 >> zmap 1 >> + 'xmap !
	sh maph zmap * - 1 >> zmap 1 >> + 'ymap !
	;
	
#nrocell ( 89 98 6 9 102 )	| ground wall box boxgoal groundgoal
#nroplay ( 55 52 78 81 ) 	| up dn ri le

|------- MAP
:]map | x y -- adr
	mapw * + 'map + ;

:xymap | x y -- x y 
	swap zmap * xmap + 
	swap zmap * ymap + ;	
	
:drawc	| x y -- x y
	2dup ]map c@ 'nrocell + c@
	pick2 pick2 xymap 
	2dup zspr 89 sprites sspritez | always stone back
	rot zspr swap sprites sspritez ;
		
:drawmap
	0 ( mapw <? 0 ( maph <? drawc 1 + ) drop 1 + ) drop ;
		
:drawplay
	xp yp xymap zspr fp 'nroplay + c@ sprites sspritez ;	

:test@ | x y -- c
	yp + swap xp + swap ]map c@ ;

:test! | x y c -- 
	rot xp + rot yp + ]map c! ;

:test2@ | x y -- c
	1 << yp + swap 1 << xp + swap ]map c@ ;
	
:test2! | x y c --
	rot 1 << xp + rot 1 << yp + ]map c! ;

:win? | -- 1/0
	mapw maph * 
	'map >a
	( 1? 1 - ca@+
		4 =? ( 2drop 0 ; ) drop
		) drop 1 ;
		
|------- UNDO
#pmove ( 0 -1 ) ( 0 1 ) ( 1 0 ) ( -1 0 ) 

:face2move | face -- x y 
	1 << 'pmove + c@+ swap c@ ;
	
:>>stream | floor tipo --
	swap 3 << or 2 << fp or undo> c!+ 'undo> ! ;
	
:t0
	$3 and dup 'fp ! 1 xor face2move
	'yp +! 'xp +! ;
:t1
	dup $3 and dup dup 'fp ! 1 xor 
	face2move 'yp +! 'xp +! 
	face2move
	2dup 2 test!
	rot 5 >> $7 and test2!
	;
:t2
	dup $3 and dup dup 'fp ! 1 xor 
	face2move 'yp +! 'xp +! 
	face2move
	2dup 3 test!
	rot 5 >> $7 and test2!
	;
	
#tlist 't0 't1 't2
	
:<<undo
	undo> 1 - undo. <? ( drop ; ) 
	dup c@ dup 2 >> $7 and 3 << 'tlist + @ ex
	'undo> ! ;

|------- MOVE
| dx dy 
:pgr | ground 0/ groundgoal 4
	0 0 >>stream
	'yp +! 'xp +! ;
:gwa | wall 1
	2drop ;
:pbo | box 2
	2dup test2@ $3 and 1? ( 3drop ; ) drop 
	2dup test2@ 1 >>stream 
	2dup 2dup test2@ 2 >> 2 + test2!
	2dup 0 test!
	'yp +! 'xp +! ;
:pbg | boxingoal 3
	2dup test2@ $3 and 1? ( 3drop ; ) drop
	2dup test2@ 2 >>stream 
	2dup 2dup test2@ 2 >> 2 + test2!
	2dup 4 test!
	'yp +! 'xp +! ;

#psig 'pgr 'gwa 'pbo 'pbg 'pgr

:plmove | fa --
	dup 'fp ! 
	face2move
	2dup test@ 
	3 << 'psig + @ ex 
	win? 1? ( "- You Win !! press F3" 'strstate strcpy ) drop
	; | dx dy 
	
|------- MAIN
:nexl
	nlevel 1 + 62 min dup 'nlevel ! loadlevel ;
:prel
	nlevel 1 - 0 max dup 'nlevel ! loadlevel ;
	
:game
	0 SDLcls
	drawmap
	drawplay
	$ffffff ttcolor
	10 0 ttat
	'strstate
	undo> undo. -
	nlevel 
	"Sokoban - level:%d - step:%d %s" ttprint
	10 560 ttat
	"ESC Exit | F1 Reset | F2 -Level | F3 +Level | z UNDO" ttprint

	SDLredraw
	SDLkey
	<up> =? ( 0 plmove )
	<dn> =? ( 1 plmove )
	<ri> =? ( 2 plmove )
	<le> =? ( 3 plmove )
	<z> =? ( <<undo )
	<f1> =? ( nlevel loadlevel )
	<f2> =? ( prel )
	<f3> =? ( nexl )
	>esc< =? ( exit )
	drop ;

: |<<<<< BOOT >>>>>
	msec time rerand
	"Sokoban" 1024 600 SDLinit
	64 64 "media\img\sokoban_tilesheet.png" ssload 'sprites !
	ttf_init
	"media/ttf/Roboto-Medium.ttf" 32 TTF_OpenFont  ttfont
	here 'undo. !
	0 loadlevel
	'game SDLshow
	SDLquit 
	;