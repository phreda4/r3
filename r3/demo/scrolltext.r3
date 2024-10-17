| scroll text
| PHREDA 2023
|
^r3/util/varanim.r3
^r3/util/ttfont.r3

#texto 
"Creditos" 
""
"Prueba de scroll"
"Texto que va pasando"
"en una pantalla de scroll"
""
"segundo grupo"
"Linea de texto"
"con funcion de animacion de variables"

#clinea 9
#hlinea 7
#nlinea	
#ys 0
#yh 100

:linestr | nro -- ""
	-? ( drop "" ; )
	clinea >=? ( drop "" ; )
	'texto swap n>>0 ;

:printline | ynow nro str -- ynow nro

|... center 1024,yh
	ttsize | w h 
	yh swap - 1 >> pick4 + swap
	1024 swap - 1 >> swap ttat
	
	tt. ;
	
:animc
	vareset
	'ys yh neg 0 23 1.0 0 +vanim
	[ nlinea 1 + clinea >=? ( hlinea neg nip ) 'nlinea ! animc ; ] 1.0 +vexe
	0 'ys ! 
	;
	
:drawlines
	ys 0 ( hlinea <? 
		nlinea over + linestr printline
		1 + swap yh + swap ) 2drop ;
	
:title
	vupdate
	$0 SDLcls
	$ffffff ttcolor
	drawlines	
	
	SDLredraw	
	SDLkey
	>esc< =? ( exit )
	drop ;
	
|-------------------------------------
:main
	"title scroll" 1024 600 SDLinit	

	"media/ttf/Roboto-Medium.ttf" 48 TTF_OpenFont ttfont
	$7f vaini
	animc
	hlinea neg 'nlinea !
	'title SDLShow
	
	SDLquit ;	
	
: main ;	