| clip polygon to box
| PHREDA 2025

^r3/lib/sdl2gfx.r3	
^r3/util/varanim.r3
^r3/util/txfont.r3
^r3/lib/rand.r3

#vertex * 1024
#vertex> 'vertex

#verfix * 1024
#verfix> 'verfix

:getxy | v -- x y
	dup 48 << 48 >> 200 +
	swap 32 << 48 >> 100 + ;

#xp #yp
	
:lip dup getxy xp yp sdlline 
:opp getxy 'yp ! 'xp ! ;	

:showpoli | end ini --
	over 8 - @ opp
	( over <?
		@+ lip
		) 2drop ;

	
:v!+	vertex> !+ 'vertex> ! ;
:f!+	verfix> !+ 'verfix> ! ;

|---------------
#dx #dy	#lado

:rotv!+ | x y x1 y1 -- x y
	over dx * over dy * - 17 >> pick4 + >r
	swap dy * swap dx * + 17 >> over + r> 
	$ffff and 16 << swap $ffff and or 
	v!+ ;	
	
:buildbox | x y w ang --
	'vertex 'vertex> ! 
	sincos 'dx ! 'dy ! 'lado !

	lado neg lado neg rotv!+
	lado lado neg rotv!+
	lado lado rotv!+
	lado neg lado rotv!+
	2drop
	;
	
|---------------
#p0 #p1 #val

:getxy | v -- x y
	dup 48 << 48 >> swap 32 << 48 >> ;
:setxy | x y -- v
	$ffff and 16 << swap $ffff and or ;

|r.x=val; r.y=y1+(y2-y1)*(val-x1)/(x2-x1);
:clipx | -- pr
	p1 getxy p0 getxy	| x2 y2 x1 y1
	rot over -			| x2 x1 y1 yy
	2swap				| y1 yy x2 x1
	val over -			| y1 yy x2 x1 xx
	-rot - */ +
	val swap setxy ;
	
|r.y=val; r.x=x1+(x2-x1)*(val-y1)/(y2-y1);	
:clipy | -- pr
	p0 getxy p1 getxy	| x1 y1 x2 y2
	swap pick3 -		| x1 y1 y2 xx
	val pick3 -			| x1 y1 y2 xx yy
	2swap swap - */ +
	val setxy ;
	
#xclip 'clipx 	

:clipxy | -- pr
	xclip ex ;
	
| p -- v
:inxi	48 << 48 >> val - not 63 >> 1 and ; |0 >=? ( drop 1 ; ) drop 0 ;
:inxa	48 << 48 >> val - 63 >> 1 and ; |<=? ( drop 1 ; ) drop 0 ;
:inyi	32 << 48 >> val - not 63 >> 1 and ; |0 >=? ( drop 1 ; ) drop 0 ;
:inya	32 << 48 >> val - 63 >> 1 and ; |$ff <=? ( drop 1 ; ) drop 0 ;

#check 'inxi

:ckin check ex ;
		
:clipab | v1 --
	%11 =? ( drop p1 f!+ ; ) 
	%01 =? ( drop clipxy f!+ p1 f!+ ; )
	%10 =? ( drop clipxy f!+ ; ) 
	drop ;
		
:clipp
	'verfix 'verfix> !
	vertex> 8 - @ 'p0 !
	'vertex ( vertex> <?
		@+ dup 'p1 ! 
		p0 ckin 2* p1 ckin or | v01
		clipab
		'p0 !
		) drop 
	'vertex 'verfix verfix> over - | copy fix to ver
	'vertex over + 'vertex> !
	3 >> move |dsc
	;

:clip
	'clipx 'xclip !
	0 'val ! 'inxi 'check ! clipp
	$ff 'val ! 'inxa 'check ! clipp
	'clipy 'xclip !
	0 'val ! 'inyi 'check ! clipp
	$ff 'val ! 'inya 'check ! clipp
	;
	
|---------------	
:main
	0 sdlcls
	
	$7a7a7a sdlcolor
	200 100 256 dup sdlrect
	
	$00ff00 sdlcolor vertex> 'vertex showpoli
	$ff00ff sdlcolor verfix> 'verfix showpoli	
	
	SDLRedraw 
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( 
		255 randmax 50 + | x
		255 randmax 50 + | y
		250 randmax 80 + | w
		1.0 randmax		| r
		buildbox )
	<f2> =? ( clip )
|	<f1> =? ( 255 randmax 255 randmax v!+ )
|	<f2> =? ( 255 randmax 255 randmax f!+ )
	drop ;	

|---------------	
:
	"clip" 1024 640 SDLinit |
	'main sdlshow
	SDLQuit
	;	
