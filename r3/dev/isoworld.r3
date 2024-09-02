| 3dworld - no opengl
| PHREDA 2023
|-----
^r3/win/isospr.r3
^r3/util/arr16.r3
^r3/util/varanim.r3
^r3/util/boxtext.r3
^r3/util/sdlgui.r3
^r3/util/bfont.r3

#spcar
#spcar2
#sptree
#sptank

#listspr 0 0
#listobj 0 0

|------ sprites
:+spr
	
	;
:atlaspr
	;
	
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
	a> .x @ a> .y @ a> .z @ 2iso
	a> .az @ dup $ffff and swap 16 >>
	a> .ss @ isospr | x y a z 'ss --
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
	gui
	isocamrot
	
	0 sdlcls
	
	$ffffff bcolor
	0 0 bat "Voxel world" bprint bcr

	'listobj p.draw

	SDLredraw
	SDLkey
	>esc< =? ( exit )
	drop
	;	
	
:jugar 
	resetcam
	12 26 "media/stackspr/veh_mini1.png" loadss 'spcar !
	36 36 "media/stackspr/blue_tree.png" loadss 'sptree !
	16 16 "media/stackspr/car.png" loadss 'spcar2 !
	32 32 "media/stackspr/tank.png" loadss 'sptank !	
	
	'listspr p.clear
	'listobj p.clear

	spcar 0 4.0 -4.0 4.0 0  +obj | isospr a z x y z --
	spcar2 0 4.0 4.0 4.0 0  +obj | isospr a z x y z --
	sptree 0 4.0 -4.0 -4.0 0 +obj | isospr a z x y z --
	sptank 0 4.0 4.0 -4.0 0 +obj | isospr a z x y z --
	
	'juego SDLShow 
	;
	
|-------------------------------------
:main
	"iso world" 1024 600 SDLinit
	bfont1
	
	50 'listspr p.ini
	200 'listobj p.ini
	jugar
	SDLquit ;	
	
: main ;