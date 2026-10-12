| sfxballs.r3 - ejemplo de terminal: pelotas que rebotan, cada una con su sonido, y musica de fondo
| PHREDA 2025
|
| COMO AGREGAR SONIDO Y MUSICA A UN PROGRAMA O JUEGO (gamesfx.r3 + sfxpack.r3):
|
|   1. ^./gamesfx.r3 y ^./sfxpack.r3        (los sonidos listos son ##sfx_..., se editan con sfxdemo.r3)
|   2. sfxinit                                una vez al inicio: audio + sintetizador + secuenciador
|   3. 'sfx_coin sfxplay                      en cada evento del juego (choque, salto, moneda...)
|      'sfx_coin 3 sfxplayp                   el mismo sonido 3 semitonos mas agudo (variacion)
|      "c4 e4 g4 c5" 120 inst 1 sfxtune       musica en bucle: patron Strudel, bpm, instrumento, loop 1
|   4. sfxupdate                              UNA VEZ POR CUADRO en el bucle principal
|
| Un instrumento para la musica se crea con supermix (ver mkins abajo):
|   attack decay sustain release packADSR 'onda iosc      (ondas: oscSqr oscSaw oscTri oscSin ...)
|
| Aca: 6 pelotas rebotan; al tocar el piso suena el sonido de cada una. Una musica suena de fondo.
|   [espacio] patea todas   [m] musica si/no   [+] [-] volumen   [esc] salir

^r3/lib/console.r3
^r3/lib/rand.r3
^./gamesfx.r3
^./sfxpack.r3

|--------------------------------------------------------------- pelotas
#NB 6
#balls * 1024				| 8 pelotas max, 128 bytes cada una
#bsnd 'sfx_bounce 'sfx_knock 'sfx_kick 'sfx_pass 'sfx_blip 'sfx_tackle
#bsem 0 4 -3 7 -5 2			| semitonos: cada pelota suena distinto aunque comparta sonido
#bnames "bounce" "knock" "kick" "pass" "blip" "tackle"
#bcol 196 46 51 226 201 208		| colores xterm-256

:bptr | n -- adr
	7 << 'balls + ;
:bname | n -- "str"
	'bnames swap ( 1? 1- swap >>0 swap ) drop ;

| campos (A apunta a la pelota): posicion y velocidad en 16.16 (celdas, celdas/seg)
:b.x a> ;
:b.y a> 8 + ;
:b.vx a> 16 + ;
:b.vy a> 24 + ;
:b.col a> 32 + ;
:b.snd a> 40 + ;
:b.semi a> 48 + ;
:b.flash a> 56 + ;			| cuadros que dura el destello del choque
:b.hits a> 64 + ;
:b.ox a> 72 + ;
:b.oy a> 80 + ;

|--------------------------------------------------------------- pantalla
:scw cols 20 max ;
:sch rows 12 max ;
#floory					| fila del piso (16.16)
#dt #tprev				| segundos del cuadro (16.16), ms del cuadro anterior

:gravity 32.0 ;				| celdas/seg2
:rest 0.86 ;				| rebote: velocidad que se conserva

|--------------------------------------------------------------- fisica
:rnd | min max -- r			| randminmax usa A; se protege porque A es la pelota
	ab[ randminmax ]ba ;

:binit | n --
	dup bptr >a
	scw 4 - randmax 2 + 16 << b.x !
	sch 10 - randmax 2 + 16 << b.y !
	-14.0 14.0 rnd b.vx !
	0 b.vy !
	dup 3 << 'bsnd + @ b.snd !
	dup 3 << 'bsem + @ b.semi !
	3 << 'bcol + @ b.col !
	0 b.flash !  0 b.hits !  0 b.ox !  0 b.oy ! ;

:choque | -- 				| toca el piso: sonido de esta pelota
	1 b.hits +!
	6 b.flash !
	b.snd @ b.semi @ sfxplayp ;

:piso | --
	floory b.y !
	b.vy @ dup rest *. neg b.vy !		| invierte y pierde energia
	4.0 >? ( choque ) drop				| solo suena si el golpe es fuerte
	b.vy @ neg 7.0 <? ( drop 24.0 34.0 rnd neg b.vy ! ; ) drop ;	| casi quieta: la patea

:bstep | -- 				| una pelota, un cuadro
	b.vy @ gravity dt *. + b.vy !
	b.y @ b.vy @ dt *. + b.y !
	b.x @ b.vx @ dt *. + b.x !
	b.x @ 0 <? ( drop 0 b.x ! b.vx @ abs b.vx ! ; ) drop
	b.x @ scw 1- 16 << >? ( drop scw 1- 16 << b.x ! b.vx @ abs neg b.vx ! ; ) drop
	b.y @ floory <? ( drop ; ) drop
	piso ;

:tick | --
	msec dup tprev - swap 'tprev !
	50 min 65536 * 1000 / 'dt !
	sch 3 - 16 << 'floory !
	0 ( NB <? dup bptr >a bstep 1+ ) drop ;

:kickall | --
	0 ( NB <? dup bptr >a
		-34.0 -20.0 rnd b.vy !
		-14.0 14.0 rnd b.vx !
		1+ ) drop ;

|--------------------------------------------------------------- dibujo
:berase | --				| (A se usa solo antes de la primera llamada a consola)
	b.ox @ b.oy @ .at " " .write ;

:fl-- | --
	b.flash @ 1? ( 1- b.flash ! ; ) drop ;

:bdraw | --				| se leen los campos de la pelota antes de imprimir: consola pisa A y B
	b.x @ 16 >> b.y @ 16 >> 2dup b.oy ! b.ox !
	b.col @ b.flash @ fl--			| x y color destello
	0? ( drop .fc .at "O" .write ; )
	drop drop .at .Whitel .Bold "@" .write ;

:marker | --				| marca en el piso mientras dura el destello
	b.flash @ 0? ( drop ; ) drop
	b.x @ 16 >> b.col @
	.fc floory 16 >> 1+ .at "*" .write ;

:hudball | n --
	dup bptr >a b.col @ b.hits @		| n color golpes
	pick2 15 * 1+ 2 .at
	swap .fc "O " .write
	over bname .write
	" %d" .print drop ;

:hud | --
	.Reset
	1 1 .at .Whitel "sfxballs - sonido de choque distinto por pelota + musica de fondo" .write
	0 ( NB <? dup hudball 1+ ) drop
	.Reset ;

:draw | --
	0 ( NB <? dup bptr >a berase 1+ ) drop
	.Reset 240 .fc
	0 floory 16 >> .at scw ( 1? 1- "=" .write ) drop
	0 floory 16 >> 1+ .at .eline
	0 ( NB <? dup bptr >a bdraw 1+ ) drop
	0 ( NB <? dup bptr >a marker 1+ ) drop
	hud
	.Reset 245 .fc 0 sch 1- .at "[space] kick  [m] music  [+][-] volume  [esc] exit" .write .Reset ;

|--------------------------------------------------------------- musica
#iTri #iBass #bgm1 -1 #bgm2 -1 #vol 2.0

:mkins | --
	0.01 0.10 0.65 0.08 packADSR 'oscTri iosc 'iTri !
	0.005 0.10 0.60 0.05 packADSR 'oscSqr iosc 'iBass ! ;

:bgm | --				| musica si/no: dos voces en bucle (melodia y bajo)
	bgm1 0 >=? ( drop bgm1 sfxtunestop bgm2 sfxtunestop -1 'bgm1 ! -1 'bgm2 ! ; ) drop
	'tune_bgm_lead 132 iTri 1 sfxtune 0.32 0 sfxtunemix 'bgm1 !
	'tune_bgm_bass 132 iBass 1 sfxtune 0.20 0 sfxtunemix 'bgm2 ! ;

:volume | delta --
	vol + 0.25 max 4.0 min dup 'vol ! sfxvol ;

|--------------------------------------------------------------- teclas y bucle
:handle | key --
	0? ( drop ; )
	32 =? ( drop kickall ; )
	$6d =? ( drop bgm ; )
	$2b =? ( drop 0.25 volume ; )
	$3d =? ( drop 0.25 volume ; )
	$2d =? ( drop -0.25 volume ; )
	drop ;

:main
	sfxinit mkins
	msec $1234567 rerand
	0 ( NB <? dup binit 1+ ) drop
	bgm
	msec 'tprev !
	.alsb .hidec .cls
	( inkey [ESC] <>?
		handle
		tick
		sfxupdate
		draw
		.flush
		16 ms
		) drop
	.Reset .cls .masb .showc .flush .free ;

: main ;
