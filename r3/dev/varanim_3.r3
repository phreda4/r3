| variable animator
| PHREDA 2022
|
| vaini | max --
| vareset | -- 
| ---start 1.0 seconds, go from 10 to 100 in 2.0 seconds with 1 penner function
| +vanim | 100 10 1 2.0 1.0 -- 
| ---exe in 3.0 seconds
| +vexe | 'exe 3.0 --
| ---update 
| vupdate | --
|
^r3/lib/console.r3

^r3/lib/sdl2gfx.r3
^r3/lib/rand.r3
^r3/util/bfont.r3
^r3/util/varanim.r3

|------------------
:debug1
	0 0 bat $ffffff bcolor
	timeline 
	( timeline< <?
		@+ "%h " bprint ) 
	"<" bprint
	( timeline> <?
		@+ "%h " bprint ) 
	drop
	0 32 bat $ffffff bcolor
	exevar >a
	32 ( 1? 1-
		a@+ a@+ a@+ a@+ "%h %h %h %h" bprint bcr
		) drop 
	;

#v
:main
	vupdate
	$0 SDLcls
	
	$ff00 bcolor
	400 0 bat "test varanim" bprint bcr
	
	debug1
	
	SDLredraw	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( [ ; ] 1.0 3.0 randmax + +vexe )
	<f2> =? ( 'v 10 200 3 0.8 1.0 3.0 randmax + +vanim )
	<f3> =? ( 'v 10 200 3 0.8 1.0 3.0 randmax + +vboxanim )
	<f4> =? ( 'v 10 200 3 0.8 1.0 3.0 randmax + +vxyanim )
	<f5> =? ( 'v [ ; ] 1.0 3.0 randmax + +vvexe )
	drop ;
	
:start
	$1f vaini
	'main SDLshow 
	;
	
: 
	"r3sdl" 1032 700 SDLinit
	bfont1
	start
	SDLquit
	;	