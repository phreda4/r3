| sfxdemo.r3 - demo de terminal: generador de sonidos de videojuego (supermix + gamesfx)
|
|  1-9 q-o  dispara un sonido (pack futbol = port de audio.c, y pack generico)
|  Tab      elegir el sonido a editar          Espacio  reproducir lo editado
|  flechas  mover celda (arriba/abajo capa, izq/der parametro)
|  + -      cambia el valor    * /  cambio grueso      0  recargar el original
|  a d      agregar / borrar capa     f  variar (mutacion al azar)
|  [ ]      volumen general
|  m g      jingle / game over        b  musica de fondo (2 voces en loop)    x  corta todo
|  Esc      salir (imprime el sonido editado como datos listos para pegar)

^r3/lib/console.r3
^r3/lib/rand.r3
^./gamesfx.r3
^./sfxpack.r3

|--------------------------------------------------------------- sonidos
#keys "123456789qwertyuio"
#snames "kick" "pass" "tackle" "save" "bounce" "crazy" "goal" "whistle" "knock" "jump" "coin" "laser" "explosion" "powerup" "hit" "blip" "hurt" "lose"
#sounds 'sfx_kick 'sfx_pass 'sfx_tackle 'sfx_save 'sfx_bounce 'sfx_crazy 'sfx_goal 'sfx_whistle 'sfx_knock 'sfx_jump 'sfx_coin 'sfx_laser 'sfx_explosion 'sfx_powerup 'sfx_hit 'sfx_blip 'sfx_hurt 'sfx_lose
#NSND 18

:sname | n -- "str"
	'snames swap ( 1? 1- swap >>0 swap ) drop ;

:saddr | n -- 'sound
	3 << 'sounds + @ ;

|--------------------------------------------------------------- buffer de edicion
#edit * 1024		| hasta 8 capas de 96 bytes + terminador
#newlayer 1 440.0 440.0 0.1 0 0.25 0.0 0.001 0.1 0.0 0.02 1
#cur 0			| sonido en edicion
#row 0 #col 0		| celda seleccionada
#vol 2.0
#bgm1 -1 #bgm2 -1
#vu 0

:nlay | -- n
	0 'edit ( dup @ 1? drop 96 + swap 1+ swap ) 2drop ;

:loadedit | n --
	'cur !
	cur saddr >b
	'edit >a
	8 ( 1? 1- b@ 0? ( 2drop 0 a! ; ) drop
		12 ( 1? 1- b@+ a!+ ) drop
		) drop
	0 a! ;

:cell | -- adr
	row 96 * col 3 << + 'edit + ;

:kind@ | -- kind de la fila actual
	row 96 * 'edit + @ ;

:clampcell | --
	row nlay 1 max 1- min 0 max 'row !
	col 0 max 11 min 'col ! ;

|--------------------------------------------------------------- cambio de valores
#adjd #adjc		| direccion (+1/-1) y multiplicador (1 fino / 10 grueso)

:ahz | v -- v'		| semitonos (grueso: octavas x 1)
	adjd adjc * fix. 12 / pow2. *. 20.0 max 20000.0 min ;
:acol | v -- v'
	adjd 1.0 * + 0.0 max 2.0 min ;
:adur | v -- v'
	0.01 adjc * adjd * + 0.005 max 4.0 min ;
:awave | v -- v'
	adjd + 12 + 12 mod ;
:avol | v -- v'
	0.01 adjc * adjd * + 0.0 max 1.0 min ;
:adelay | v -- v'
	0.01 adjc * adjd * + 0.0 max 4.0 min ;
:aA | v -- v'
	0.001 adjc * adjd * + 0.001 max 1.0 min ;
:aD | v -- v'
	0.01 adjc * adjd * + 0.0 max 4.0 min ;
:aS | v -- v'
	0.05 adjc * adjd * + 0.0 max 1.0 min ;
:aR | v -- v'
	0.01 adjc * adjd * + 0.001 max 4.0 min ;
:acrv | v -- v'
	adjd + 0 max 3 min ;

:adjust | --
	cell @ col
	0 =? ( 2drop 3 cell @ - cell ! ; )
	1 =? ( drop kind@ 2 =? ( 2drop ; ) drop ahz cell ! ; )
	2 =? ( drop kind@ 2 =? ( drop acol cell ! ; ) drop ahz cell ! ; )
	3 =? ( drop adur cell ! ; )
	4 =? ( drop awave cell ! ; )
	5 =? ( drop avol cell ! ; )
	6 =? ( drop adelay cell ! ; )
	7 =? ( drop aA cell ! ; )
	8 =? ( drop aD cell ! ; )
	9 =? ( drop aS cell ! ; )
	10 =? ( drop aR cell ! ; )
	drop acrv cell ! ;

:chg | dir coarse --
	'adjc ! 'adjd ! adjust ;

:addlayer | --
	nlay 8 >=? ( drop ; )
	96 * 'edit + dup 'newlayer 96 cmove
	96 + 0 swap !
	nlay 1- 'row ! ;

:dellayer | --
	nlay 1 <=? ( drop ; ) drop
	row 96 * 'edit + dup 96 +
	nlay row - 96 * cmove
	clampcell ;

:mulcell | off lo hi --		| a[off] *= azar(lo..hi)
	randminmax a> rot + dup @ rot *. swap ! ;

:mutate | --
	0 ( nlay <? dup 96 * 'edit + >a
		a@ 1 =? ( 8 0.85 1.2 mulcell 16 0.85 1.2 mulcell ) drop
		24 0.85 1.15 mulcell
		40 0.9 1.1 mulcell
		a> 40 + dup @ 1.0 min swap !
		1+ ) drop ;

|--------------------------------------------------------------- musica
:bgm | --
	bgm1 0 >=? ( drop bgm1 sfxtunestop bgm2 sfxtunestop -1 'bgm1 ! -1 'bgm2 ! ; ) drop
	'tune_bgm_lead 132 'patch_tri 1 sfxtune 'bgm1 !
	'tune_bgm_bass 132 'patch_bass 1 sfxtune 'bgm2 ! ;

:stopall | --
	sfxstop -1 'bgm1 ! -1 'bgm2 ! ;

:volume | delta --
	vol + 0.25 max 4.0 min dup 'vol ! sfxvol ;

|--------------------------------------------------------------- teclas
#fk -1
:findkey | key -- idx/-1
	-1 'fk !
	0 ( 18 <?
		dup 'keys + c@ $ff and pick2 =? ( over 'fk ! ) drop
		1+ ) 2drop fk ;

:handle | key --
	0? ( drop ; )
	[TAB] =? ( drop cur 1+ NSND mod loadedit 0 'row ! ; )
	[UP] =? ( drop -1 'row +! clampcell ; )
	[DN] =? ( drop 1 'row +! clampcell ; )
	[LE] =? ( drop -1 'col +! clampcell ; )
	[RI] =? ( drop 1 'col +! clampcell ; )
	$2b =? ( drop 1 1 chg ; )
	$3d =? ( drop 1 1 chg ; )
	$2d =? ( drop -1 1 chg ; )
	$2a =? ( drop 1 10 chg ; )
	$2f =? ( drop -1 10 chg ; )
	32 =? ( drop 'edit sfxplay ; )
	$30 =? ( drop cur loadedit ; )
	$61 =? ( drop addlayer ; )
	$64 =? ( drop dellayer ; )
	$66 =? ( drop mutate 'edit sfxplay ; )
	$5b =? ( drop -0.25 volume ; )
	$5d =? ( drop 0.25 volume ; )
	$6d =? ( drop 'tune_jingle 150 'patch_lead 0 sfxtune drop ; )
	$67 =? ( drop 'tune_gameover 110 'patch_tri 0 sfxtune drop ; )
	$62 =? ( drop bgm ; )
	$78 =? ( drop stopall ; )
	findkey -? ( drop ; )
	dup loadedit 0 'row ! saddr sfxplay ;

|--------------------------------------------------------------- pantalla
#colx 3 9 15 21 26 37 42 47 52 57 62 67
#pr #pc #pv #pk

:ms16 | v -- ms        | segundos 16.16 -> milisegundos redondeados
	1000 * $8000 + 16 >> ;
:pc16 | v -- %
	100 * $8000 + 16 >> ;


:vu! | --
	0 'vu !
	'outbuffer >a
	2048 ( 1? 1- da@+ 48 << 48 >> abs vu max 'vu ! ) drop ;

:drawvu | --
	1 1 .at 14 .fc " GAMESFX " .write
	8 .fc "vu " .write
	vu 20 * 15 >> 20 min
	10 .fc dup ( 1? 1- 35 .emit ) drop
	8 .fc 20 swap - ( 1? 1- 46 .emit ) drop
	.Reset ;

:drawinfo | --
	1 2 .at .eline
	7 .fc "editando: " .write 15 .fc cur sname .write
	7 .fc "   volumen " .write vol pc16 "%d" .print
	"%   musica: " .write
	bgm1 0 >=? ( 10 .fc "on " .write ) drop
	bgm1 0 <? ( 8 .fc "off" .write ) drop
	.Reset ;

:drawsnd | --
	0 ( NSND <?
		dup 6 mod 13 * 2 + over 6 / 4 + .at
		.Reset
		dup cur =? ( 15 .fc 24 .bc ) drop
		dup 'keys + c@ $ff and .emit 32 .emit dup sname .write 32 .emit
		.Reset
		1+ ) drop ;

:ptxt | --
	pc
	0 =? ( drop pk 1 =? ( drop "tone " .write ; ) drop "noise" .write ; )
	1 =? ( drop pk 1 =? ( drop pv 16 >> "%d" .print ; ) drop "-" .write ; )
	2 =? ( drop pk 1 =? ( drop pv 16 >> "%d" .print ; ) drop pv 16 >> sfxnoisename .write ; )
	3 =? ( drop pv ms16 "%d" .print ; )
	4 =? ( drop pk 1 =? ( drop pv sfxwavename .write ; ) drop "-" .write ; )
	5 =? ( drop pv pc16 "%d" .print ; )
	6 =? ( drop pv ms16 "%d" .print ; )
	7 =? ( drop pv 10000 * $8000 + 16 >> dup 10 / "%d" .print "." .write 10 mod "%d" .print ; )
	8 =? ( drop pv ms16 "%d" .print ; )
	9 =? ( drop pv pc16 "%d" .print ; )
	10 =? ( drop pv ms16 "%d" .print ; )
	drop pv "%d" .print ;

:prow | r --
	'pr !
	pr 96 * 'edit + @ 'pk !
	1 pr 8 + .at .eline
	0 ( 12 <? dup 'pc !
		pr 96 * pc 3 << + 'edit + @ 'pv !
		pc 3 << 'colx + @ pr 8 + .at
		.Reset 7 .fc
		pr row =? ( pc col =? ( 15 .fc 24 .bc ) drop ) drop
		ptxt
		.Reset
		1+ ) drop ;

:drawtable | --
	.Reset 8 .fc
	1 7 .at .eline
	3 7 .at "kind" .write  9 7 .at "f0Hz" .write  15 7 .at "f1Hz" .write  21 7 .at "dur" .write
	26 7 .at "wave" .write  37 7 .at "vol%" .write  42 7 .at "dly" .write  47 7 .at "A" .write
	52 7 .at "D" .write  57 7 .at "S%" .write  62 7 .at "R" .write  67 7 .at "crv" .write
	.Reset
	0 ( 8 <?
		dup nlay <? ( dup prow ) drop
		dup nlay >=? ( 1 over 8 + .at .eline ) drop
		1+ ) drop ;

:drawhelp | --
	8 .fc
	1 18 .at "Tab sonido  flechas celda  + - valor  * / grueso  Espacio oir  0 recargar" .write
	1 19 .at "a/d capa  f variar  m jingle  g gameover  b musica  x stop  [ ] volumen  Esc salir" .write
	1 20 .at "dur dly D R en ms, A en ms con decimal" .write
	.Reset ;

:draw | --
	drawvu drawinfo drawsnd drawtable drawhelp ;

|--------------------------------------------------------------- salida
:dump | --			| el sonido editado como datos para pegar en un .r3
	"##mysound   | editado desde: " .write cur sname .write .cr
	0 ( nlay <? dup 96 * 'edit + >a
		a> 88 + @ a> 80 + @ a> 72 + @ a> 64 + @ a> 56 + @ a> 48 + @ a> 40 + @ a> 32 + @ a> 24 + @ a> 16 + @ a> 8 + @ a@
		"  %d %f %f %f %d %f %f %f %f %f %f %d" .println
		1+ ) drop
	"  0" .println ;

:main
	sfxinit
	msec $1234567 rerand
	0 loadedit
	.alsb .hidec .cls
	( inkey [ESC] <>?
		handle
		sfxupdate
		vu!
		draw
		.flush
		16 ms
		) drop
	.Reset .cls .masb .showc .flush
	dump
	.flush .free ;

: main ;
