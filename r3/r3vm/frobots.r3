| frobots
| PHREDA 2021-2024 (r3)
|-------------------------

^r3/lib/rand.r3
^r3/util/arr16.r3
^r3/win/sdl2gfx.r3
^r3/util/sdlgui.r3
^r3/win/sdledit.r3

^r3/r3vm/r3ivm.r3
^r3/r3vm/r3itok.r3
^r3/r3vm/r3iprint.r3

#codepath "r3/r3vm/robotcode/"

#spad * 256

| robots
| code/name,color,type,
#nr>	| cursor
#nrp	| first
#nrc	| cnt per page

#tsprites 

#robots 0 0
#screen 0 0	| finarray iniarray

|-----------------------
#nowrobot

:v+ b@+ b> 28 - +! ;

#radioexp

:checkdamage
	;

:star
	;

:explo
	>b
|	mpush
	-1 b> +!
	b@+ 0? ( checkdamage ; ) drop
	b@+ b@+ 0 |mtransi
	0.1 b> +!
	|$ffffff 'ink !
	b@ star
|	mpop 
;


:+explo | x y exp --
	'explo 'screen p!+ >a
	a!+ swap a!+ a!+ 1 a! ;

|----------- Disparo
:disparo | adr --
	>b
	|mpush
	-1 b> +!
	b@+ 0? ( b@+ b@ 20 +explo ; ) drop
	b@+ b@+ b@+ |mtransi
|	b@+ mrotxi b@+ mrotyi b@+ mrotzi | no rota balas
	12 b+
	|v+ v+ v+
	|$ffffff 'ink !
	|drawshoot
	|mpop 
	;

:+disparo | vel ang x y --
	'disparo 'screen p!+ >a
	$3f a!+
	0 swap rot a!+ a!+ a!+	| position
	0 0 0 a!+ a!+ a!+	| rotation
	swap polar
	0 swap rot a!+ a!+ a!+	| vpos
	;

|----------------------------------

:motor	b> 24 + @ swap polar b> 8 + +! b> 4 + +! ;
:turn   b> 24 + +! ;

:IOrobot
	code 256 + 8 + @	| first var in code
	$1 and? ( 0.001 turn )
	$2 and? ( -0.001 turn )
	$4 and? ( 0.02 motor )
	$8 and? ( -0.02 motor )
	$10 and? ( 0.2 b> 24 + @ b> 4 + @+ swap @ +disparo )
	$f and code 256 + 8 +  !
	;

:coderobot | adr --
	>b
	b@+ dup vm@ ip code + vmstep code - 'ip ! vm!
	IOrobot
	|mpush
	b@+ |'ink !
	b@+ b@+ b@+ |mtransi
	|b@+ mrotxi b@+ mrotyi	| no rotate in x and y
	8 b+
	b@+ |mrotzi
	|drawtank

	|tankingui
|	$ffffff 'ink ! guizone
	[ dup nowrobot =? ( 0 nip ) 'nowrobot ! ; ] onClick

	|mpop 
	;

|----- add robot and code
:+robot | x y color "code" --
	'coderobot 'screen p!+ >a
	$fff vmcpu	| create CPU
	dup a!+		| vm
	swap vmload | load CODE
	a!+ swap a!+ a!+ 0 a!+	| position
	0 0 0 a!+ a!+ a!+	| rotation

	0 0 0 a!+ a!+ a!+ 	| velocity

	;


#anyerror

:screenrobot | adr -- adr
	dup 8 + >a
	a@+ a@+ a@+ a@ 2swap
	'codepath "%s%w.r3i" sprint
	|dup .print
	+robot
	dup 48 + >a
	error dup 'msgok =? ( 0 nip ) 'anyerror +!
	a!+
	lerror a!
	;

|----------------------------------
:error!
	drop ;

|-- crobots words
:xturn | degree --
	;

:xscan | resolution -- res
	;

:xcannon | range --
	;
:xdrive | speed --
	;
:xdamage | -- dam
	;
:xspeed | -- spe
	;
:xxyloc | -- x y
	;

|------
:xbye
	exit ;

|#wsys "BYE" "shoot" "turn" "adv" "stop"
#wsysdic $23EA6 $34A70C35 $D76CEF $22977 $D35C31 0

#xsys 'xbye |'xshoot 'xturn 'xadv 'xstop
0

|-------------------
:parserror
	;

:parse&run

|	'spad r3i2token
|	1? ( parserror ) 2drop

|	9 ,i
|	vmresetr
|	code> vmrun drop

	0 'spad !
	refreshfoco
	;

:printinfo | --
    nowrobot 0? ( drop ; )
|	$ffffff 'ink !
|	dup 'screen p.nnow 'robots p.nro @+ 'ink ! @ " %s " print cr
	8 + @+ vm@
	@+ 'bcolor !
	@+ "x:%f " bprint @+ "y:%f " bprint bcr
	@+ "%h " bprint @+ "%h " bprint bcr
	drop | @ "%h" print cr
	"> " bprint |'spad 64 binput
	sdlkey
	<ret> =? ( parse&run )
	drop
	;



:runscr
	0 sdlcls
	0 0 bat
	$ffff bcolor
	" FRobots" bprint bcr
	|printinfo

|	drawbackgroud
|	'screen p.draw

	sdlkey
	>esc< =? ( exit )
	drop ;


:modrun
	mark
	'wsysdic syswor!
	'xsys vecsys!
	100 'screen p.ini
	0 'anyerror !
	|'screenrobot 'robots p.mapv
	anyerror 1? ( drop empty ; ) drop
	|'runscr sdlshow
	empty
	;

|-------------------
:modediting
	0 SDLcls 
	edshow 
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	drop
	;
	
:editing
	edreset
	'modediting sdlShow
	;
	
:modedit
	nr> 'robots p.nro
	8 + @ 'codepath "%s%w.r3i" sprint
	edload
	editing		| edrun
	edsave
	;

|-------------------
| robots
| code/name,color,type,

:addrobot | x y color "" --
	'robots p!+ >a
	a!+ a!+ a!+
	0 a!+
	0 a!+
	0 a!+
	;

:delrobot
 	nr> 'robots p.nro 'robots p.del
	nr> 'robots  p.cnt 0? ( 2drop ; )
	1 - clamp0 min 'nr> !
	;

:drawinlist | n -- n
|	'robots p.cnt >=? ( ; )
|	dup "%d. " print
	dup 'robots p.nro
	@+ 'immcolorbtn ! |bcolor |'ink !
	@+ " %s " sprint [ over 'nr> ! ; ] swap immbtn 

|	@+ "(%f:" print
|	@+ "%f)" print

|	8 +
|	@ 1? ( dup $ff0000 bcolor " %s " bprint ) drop
	drop
	nr> =? ( imm>> "<" immLabel imm<< )
	immdn ;

:menu
	0 sdlcls 
	immgui
	
	$ff 'immcolorbtn !
	100 24 immbox
	4 4 immat
	"r3Bot" immlabelc imm>>
	
	'modrun "Run" immbtn imm>>
	'modedit "Edit" immbtn imm>>
|	'modrun "run" immbtn immdn	
|	turn "turn:%d" immlabelc immdn
	$ff0000 'immcolorbtn !
	'exit "Exit" immbtn 
	
	$ff00 'immcolorbtn !
	200 24 immbox
	4 32 immat

	'robots p.cnt 
	0 ( over <? 
		drawinlist
		1 + ) 2drop
|	"F4-Add " bprint
|	"F5-Del " bprint
	
	520 300 2.0 2.0 1 tsprites sspriterz
	
	SDLredraw 
	sdlkey
	<f1> =? ( modrun )
	<f2> =? ( modedit )
|	<f3> =? ( debug
	<f4> =? ( 0 0 $ffffff "" addrobot )
	<f5> =? ( delrobot )
	>esc< =? ( exit )
	drop
	;

:modmenu
	0 'nrp !
	10 'nrc !
	'menu sdlShow ;

: |<<< BOOT <<<
	"r3 robots" 1024 600 SDLinit
	"media/ttf/roboto-bold.TTF" 20 TTF_OpenFont immSDL
	
	16 16 "media/img/tank.png" ssload 'tsprites !

	
| 32 robots
	32 'robots p.ini
	-5.0 -5.0 "test1" $ff00 addrobot
	-5.0 5.0 "test2" $ff0000 addrobot
	5.0 -5.0 "test3" $ff addrobot
|	5.0 5.0 "test4" $ff00ff addrobot

| editor
	bfont1
	1 4 80 25 edwin
	edram
| menu
	modmenu
	SDLquit 
	;
