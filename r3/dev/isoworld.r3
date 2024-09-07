| 3dworld - no opengl
| PHREDA 2023
|-----


^r3/util/arr16.r3
^r3/util/varanim.r3
^r3/util/boxtext.r3
^r3/util/sdlgui.r3
^r3/util/bfont.r3

|^r3/win/isospr.r3
^r3/dev/isosprs.r3

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

	'listspr p.clear
	'listobj p.clear

	0 ( 4 <?
		0 ( 4 <? 
			2dup 2 << + 
			0 4.0 
			pick4 10.0 * 15.0  -
			pick4 10.0 * 15.0 -
			0 +obj
			1+ ) drop
		1+ ) drop
		

	'juego SDLShow 
	;
	
|--------------------------------------------
#list1 
( 8 8 ) "obj_tree1"
( 8 8 ) "obj_tree1a"
( 8 8 ) "obj_tree1b"
( 8 8 ) "obj_tree1c"
( 10 10 ) "obj_tree2"
( 10 10 ) "obj_tree2a"
( 10 10 ) "obj_tree2b"
( 10 10 ) "obj_tree2c"
( 10 10 ) "obj_tree3"
( 6 6 ) "obj_tree4"
( 12 26 ) "veh_mini1" 
( 14 37 ) "van" 
( 36 36 ) "blue_tree"
( 16 16 ) "car"
( 32 32 ) "tank"
( 26 9 ) "deer0" | 27
( 26 9 ) "deer1" | 27
( 26 9 ) "deer2" | 27
( 26 9 ) "deer3" | 27
0

#list3
( 64 64 ) "obj_house1" 
( 64 64 ) "obj_house3" 
( 64 64 ) "obj_house4" 
( 64 64 ) "obj_house5" 
( 64 64 ) "obj_house8" 
( 64 64 ) "obj_house8c" 
0
	
|-------------------------------------
:main
	"iso world" 1024 600 SDLinit
	bfont1
	'list1 genatlas
	50 'listspr p.ini
	200 'listobj p.ini
	jugar
	SDLquit ;	
	
: main ;