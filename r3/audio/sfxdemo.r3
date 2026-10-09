| sfxdemo.r3 - demo de terminal: generador de sonidos de videojuego (supermix + gamesfx)
| PHREDA 2025
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
| capas de 10 dwords (40 bytes): $kwc f0 f1 dur vol delay A D S R  (ver gamesfx.r3)
| la tabla muestra 12 columnas logicas; kind/wave/crv viven empaquetados en el 1er dword
#edit * 512		| hasta 8 capas + terminador
#newlayer [ $101 440.0 440.0 0.1 0.25 0.0 0.001 0.1 0.0 0.02 ]
#cur 0			| sonido en edicion
#row 0 #col 0		| celda seleccionada
#vol 2.0
#bgm1 -1 #bgm2 -1
#vu 0

#sidx 0 1 2 3 0 4 5 6 7 8 9 0	| columna logica -> dword de la capa

:lay | r -- adr
	40 * 'edit + ;

:gv | r c -- v			| valor de la celda (kind/wave/crv ya desempaquetados)
	swap lay swap
	0 =? ( drop d@ 8 >> $f and ; )
	4 =? ( drop d@ 4 >> $f and ; )
	11 =? ( drop d@ $f and ; )
	3 << 'sidx + @ 2 << + d@ ;

:sv | v r c --			| escribe la celda
	swap lay swap
	0 =? ( drop dup d@ $0ff and rot 8 << or swap d! ; )
	4 =? ( drop dup d@ $f0f and rot 4 << or swap d! ; )
	11 =? ( drop dup d@ $ff0 and rot or swap d! ; )
	3 << 'sidx + @ 2 << + d! ;

:cur@ | -- v
	row col gv ;
:cur! | v --
	row col sv ;
:kind@ | -- kind de la fila actual
	row 0 gv ;

:nlay | -- n
	0 'edit ( dup d@ 1? drop 40 + swap 1+ swap ) 2drop ;

:loadedit | n --
	'cur !
	'edit 0 512 cfill
	0 ( 8 <?
		dup 40 * cur saddr + d@ 0? ( 2drop ; ) drop
		dup 40 * 'edit + over 40 * cur saddr + 40 cmove
		1+ ) drop ;

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

:kindfix | --			| tras cambiar el tipo: f0/f1 con sentido (tono: Hz ; ruido: color blanco)
	kind@ 1 =? ( drop row 1 gv 20.0 <? ( 440.0 row 1 sv 440.0 row 2 sv ) drop ; )
	drop 0.0 row 2 sv ;

:adjust | --
	col 0 =? ( drop 3 kind@ - cur! kindfix ; ) drop
	cur@ col
	1 =? ( drop kind@ 2 =? ( 2drop ; ) drop ahz cur! ; )
	2 =? ( drop kind@ 2 =? ( drop acol cur! ; ) drop ahz cur! ; )
	3 =? ( drop adur cur! ; )
	4 =? ( drop awave cur! ; )
	5 =? ( drop avol cur! ; )
	6 =? ( drop adelay cur! ; )
	7 =? ( drop aA cur! ; )
	8 =? ( drop aD cur! ; )
	9 =? ( drop aS cur! ; )
	10 =? ( drop aR cur! ; )
	drop acrv cur! ;

:chg | dir coarse --
	'adjc ! 'adjd ! adjust ;

:addlayer | --
	nlay 8 >=? ( drop ; )
	40 * 'edit + dup 'newlayer 40 cmove
	40 + 0 swap d!
	nlay 1- 'row ! ;

:dellayer | --
	nlay 1 <=? ( drop ; ) drop
	row 40 * 'edit + dup 40 +
	nlay row - 40 * cmove
	clampcell ;

:mulcell | off lo hi --		| dword[off] *= azar(lo..hi)
	randminmax a> rot + dup d@ rot *. swap d! ;

:mutate | --
	0 ( nlay <? dup 40 * 'edit + >a
		a> d@ 8 >> $f and 1 =? ( 4 0.85 1.2 mulcell 8 0.85 1.2 mulcell ) drop
		12 0.85 1.15 mulcell
		16 0.9 1.1 mulcell
		a> 16 + dup d@ 1.0 min swap d!
		1+ ) drop ;

|--------------------------------------------------------------- musica
#iLead #iTri #iBass
:mkins | --
	0.005 0.12 0.55 0.06 packADSR 'oscSaw iosc 'iLead !
	0.01 0.10 0.65 0.08 packADSR 'oscTri iosc 'iTri !
	0.005 0.10 0.60 0.05 packADSR 'oscSqr iosc 'iBass ! ;

:bgm | --
	bgm1 0 >=? ( drop bgm1 sfxtunestop bgm2 sfxtunestop -1 'bgm1 ! -1 'bgm2 ! ; ) drop
	'tune_bgm_lead 132 iTri 1 sfxtune 0.32 0 sfxtunemix 'bgm1 !
	'tune_bgm_bass 132 iBass 1 sfxtune 0.20 0 sfxtunemix 'bgm2 ! ;

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
	$6d =? ( drop 'tune_jingle 150 iLead 0 sfxtune 0.22 0 sfxtunemix drop ; )
	$67 =? ( drop 'tune_gameover 110 iTri 0 sfxtune 0.32 0 sfxtunemix drop ; )
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
	pr 0 gv 'pk !
	1 pr 8 + .at .eline
	0 ( 12 <? dup 'pc !
		pr pc gv 'pv !
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
	"##mysound [   | editado desde: " .write cur sname .write .cr
	0 ( nlay <? dup 40 * 'edit + >a
		a> 36 + d@ a> 32 + d@ a> 28 + d@ a> 24 + d@ a> 20 + d@ a> 16 + d@ a> 12 + d@ a> 8 + d@ a> 4 + d@
		a> d@ $f and  a> d@ 4 >> $f and  a> d@ 8 >> $f and
		"  $%h%h%h %f %f %f %f %f %f %f %f %f" .println
		1+ ) drop
	"  0 ]" .println ;

:main
	sfxinit mkins
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
