^r3/win/sdl2.r3
^r3/win/sdl2gl.r3

^r3/opengl/glgui.r3

#cntfloors 6

#delevator 5
#pelevator 1
#velevator 0

#floor * 32 | 32 floor max

:reset	'floor 0 32 cfill ;
	
:pushup	'floor + dup c@ 1 xor swap c! ; | f --
	
:pushdn	'floor + dup c@ 2 xor swap c! ; | f --

:light | f mask -- f color
	over 'floor + c@ and 
	0? ( drop $ff040404 ; ) drop $ff007f00 ;
		
	
:main
	SDLGLcls 
	GLgui
	
	24.0 'glFontSize !
	
	$ffff0000 'guicolorbtn !
	sw 70 - 10 60 40 glwin
	'exit "Exit" gltbtn gldn
	
	$ff0000ff 'guicolorbtn !
	10 60 80 40 glwin
	cntfloors ( 1? 	
		100 glwidth
		dup "piso %d" sprint glLabel gl>>
		60 glwidth
		1 light 'guicolorbtn !
		[ dup pushup ; ] "up" sprint gltbtn 
		gl>>
		2 light 'guicolorbtn !
		[ dup pushdn ; ] "dn" sprint gltbtn 		
		gl<<dn
		1 - ) drop
		
	$ff007f00 'guicolorbtn !
	340 60 60 40 glwin
	cntfloors ( 1? 	
		[ dup 'felevator ! ; ]
		over "%d" sprint sprint gltbtn 		
		gl<<dn
		1 - ) drop		

	$ff0f0fff glColor
	500 60 
	cntfloors felevator - 44 * +
	80 44 frect
	
	44.0 'glFontSize !
	10 500 780 80 glWin
	felevator "- %d -" sprint glLabelC
	
	
	SDLGLupdate
	SDLkey
	>esc< =? ( exit ) 	
	drop ;	

|----------- BOOT
:
	"test glscr" 800 600 SDLinitGL
	
	GLFontIni
	"media/msdf/roboto-bold" glFontLoad

	'main SDLshow
	SDL_Quit 
	;	