| OpenGL example
| PHREDA 2023
|MEM 64
^r3/lib/sdl2gl.r3
^./glfixfont.r3
^./gllib.r3

#marx 4 #mary 4
#padx 4 #pady 4

:gZoneAll
	wix wiy wiw wih ;

:gZoneEle
	wix marx + wiy mary + wiw marx 2* - wih mary 2* - ;
	
:gZonePad
	wix marx + padx + wiy mary + pady + wiw marx 2* - padx 2* - wih mary 2* - pady 2* - ;
	
::tlwrite | "text" --
	fsize nip | w h
	wix marx + padx +
	wiy wih 2/ + rot 2/ -
	fat ftext ;
	
:tcwrite | "text" --
	fsize | w h
	wix wiw 2/ + rot 2/ -
	wiy wih 2/ + rot 2/ -
	fat
	ftext ;
	
:trwrite | "text" --
	fsize | w h
	wix wiw + mary 2* pady 2* + - rot -
	wiy wih 2/ + rot 2/ -
	fat
	ftext ;


#colors [ $ffff0000 $ff00ffff $ffffff00 $ffff00ff $ff0000ff $ff00ff00 $ffff00 ] 	

::immBtn | "" --
	gZoneEle immBox immZone
	uistate $7 and 2 << 'colors + d@ 'fcolor !
	gZoneEle 5 frectb
	$ffffffff 'fcolor !
	|gZoneEle 5 rectb
	tcwrite	 ;
	