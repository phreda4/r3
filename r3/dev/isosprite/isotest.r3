| 3dworld - no opengl
| PHREDA 2024
|-----

^r3/lib/rand.r3
^r3/util/arr16.r3
^r3/util/varanim.r3
^r3/util/boxtext.r3
^r3/util/sdlgui.r3
^r3/util/bfont.r3

^./isosprs.r3

#listspr 0 0
#listobj 0 0

|---------------------------------
| x y z az ss
| 1 2 3 4  5 
:.x		1 ncell+ ;
:.y		2 ncell+ ;
:.z		3 ncell+ ;
:.az 	4 ncell+ ;
:.ss	5 ncell+ ;

:ispr | adr -- adr
	>a
	a> .x @ a> .y @ a> .z @ isopos
	a> .az @ dup $ffff and swap 16 >>
	a> .ss @ +isospr | x y a z 'ss --
	;
	
:+obj | isospr a z x y z --
	'ispr 'listobj p!+ >a
	rot a!+ swap a!+ a!+ | x y z
	swap $ffff and swap 16 << or  a!+ | az
	a!+
	;
	
#xr 0 #yr 0

:isocamrot
	[ SDLx 'xr ! SDLy 'yr ! ; ] 
	[	sdlx xr over - 0.001 * 'isang +! 'xr ! 
		sdly dup yr - 0.001 * 'isalt +! 'yr ! 
		isocam
		; ] 
	onDnMove 
	;	
	
|-------------------------------	
:juego
	gui 0 0 sw sh guiRect
	isocamrot
	$3a3a3a sdlcls
	
	$ffffff bcolor
	0 0 bat "Voxel world" bprint bcr
	
	40 isoscene | max 40 objs
	'listobj p.draw
	isodraw
	
	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop
	;	
	
:testuni
	0 ( 6 <?
		0 ( 6 <? 
			6 randmax
			rand 
			2.0 
			pick4 10.0 * 25.0 - 8.0 randmax 4.0 - +
			pick4 10.0 * 25.0 - 8.0 randmax 4.0 - +
			0 |4.0 randmax
			+obj
			1+ ) drop
		1+ ) drop
	;
	
:jugar 
	resetcam

	'listspr p.clear
	'listobj p.clear

	testuni

	'juego SDLShow 
	;
	
|--------------------------------------------
#listvox
( 32 32 ) "clon1"
( 32 32 ) "clon2"
( 32 32 ) "clon3"
( 32 32 ) "ovni31"
( 32 32 ) "ovni32"
( 32 32 ) "ovni33"
0

	
|-------------------------------------
:main
	"iso world" 1024 600 SDLinit
	bfont1
	"media/ss/%s.png" 'listvox gensatlas
	
	50 'listspr p.ini
	200 'listobj p.ini
	
	jugar
	SDLquit ;	
	
: main ;