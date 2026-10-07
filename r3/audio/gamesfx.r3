| gamesfx.r3 - sonidos de videojuego generados (sin .mp3) sobre supermix.r3
| PHREDA 2025
|
| Un SONIDO es una lista de CAPAS terminada en 0, escrita con la sintaxis de datos de
| 32 bits:   ##nombre [ ... ]    (cada valor ocupa un dword)
| Una capa es un tono (con barrido de frecuencia) o una rafaga de ruido: 10 valores
|
|   $kwc  f0    f1    dur   vol   delay  A     D    S   R
|   $103  200.0 70.0  0.09  0.14  0.0    0.001 0.09 0.0 0.005   <- tono
|   $200  0.0   0.0   0.09  0.18  0.0    0.001 0.09 0.0 0.005   <- ruido (f1 = color)
|
|   $kwc  primer valor, tres nibbles en hexa:  k = kind   w = wave   c = crv
|         ej: kind=1 wave=10 crv=2 -> $1A2.  Como kind va primero, el valor 0 sigue
|         siendo FIN DE LISTA (kind 0)
|   kind  1 tono, 2 ruido
|   wave  forma de onda 0..11, ver sfxwavename (0 cuadrada 1 sierra 2 seno 3 triangulo ...)
|   crv   curva de la envolvente: 0 lineal, 1 cuadratica, 2 cubica, 3 cuartica (~exp(-6t))
|   f0    frecuencia inicial en Hz (16.16)
|   f1    frecuencia final en Hz: el tono barre f0->f1 (exponencial) durante 'dur'
|         en ruido: color 0.0 blanco, 1.0 rosa, 2.0 marron
|   dur   duracion de la nota en segundos; despues se agrega la cola R
|   vol   volumen 0..1 (16.16)
|   delay retardo en segundos desde que se dispara el sonido (capas en serie o simultaneas)
|   A D S R  envolvente: ataque(s) decaimiento(s) nivel de sostenido(0..1) release(s)
|   (16.16 en 32 bits con signo: las frecuencias llegan a 32767 Hz)
|
| Todo arranca con precision de muestra (supermix: smtick + smplayhzat), asi que las
| capas con delay y las notas de las melodias no dependen de los cuadros por segundo.
|
| API
|   sfxinit                  inicia supermix, instrumentos y secuenciador
|   sfxupdate                llamar una vez por cuadro (genera/encola el audio)
|   'sonido sfxplay          dispara un sonido
|   'sonido n sfxplayp       igual, transpuesto n semitonos (variacion)
|   "notas" bpm 'parche loop sfxtune -- id      melodia (formato abajo)
|   id sfxtunestop           corta una melodia
|   sfxstop                  corta todo
|   v sfxvol                 volumen general (1.0 normal, 2.0 por defecto)
|
| MELODIAS: texto con notas separadas por espacios
|   c4 d4 e4 f4 g4 a4 b4     nota + octava (c4 = do central, midi 60)
|   c#4 db4 f#3              sostenido (#) bemol (b)
|   c e g                    sin octava usa la ultima nombrada (empieza en 4)
|   c4*2  c4/2  c4.          duracion en pulsos: *n multiplica, /n divide, . puntillo
|   ~  ~*2                   silencio
|   > <                      sube / baja la octava actual (afecta a las notas sin numero);
|   |                        separador de compas (se ignora)
|   el numero de octava fija la octava en forma absoluta: 'c4' siempre es el do central
| El 'parche' es una capa de tono (misma estructura): usa wave vol A D S R crv.

^r3/lib/math.r3
^r3/lib/rand.r3
^./supermix.r3

|--------------------------------------------------------------- tablas
##sfxwaves 'oscSqr 'oscSaw 'oscSin 'oscTri 'oscPul2 'oscPul1 'oscSawRev 'oscSinF 'oscTrap 'oscHSin 'oscSin3 'oscSuperSaw2P
##sfxnwaves 12
##sfxLAYER 40			| bytes por capa: 10 valores de 32 bits

#sxwnames "square" "saw" "sine" "triangle" "pulse25" "pulse10" "saw-rev" "sine-fold" "trapezoid" "half-sine" "sine3" "supersaw"
#sxnnames "white" "pink" "brown"

::sfxwavename | n -- "str"
	0 max 11 min
	'sxwnames swap ( 1? 1- swap >>0 swap ) drop ;

::sfxnoisename | n -- "str"
	0 max 2 min
	'sxnnames swap ( 1? 1- swap >>0 swap ) drop ;

| ruidos normalizados (el marron sale mas bajo)
:sxnWhite wnoise ;
:sxnPink pnoise ;
:sxnBrown bnoise 3 * ;
#sxnoises 'sxnWhite 'sxnPink 'sxnBrown

|--------------------------------------------------------------- estado
#sxinsT #sxinsN		| instrumentos: tonos con barrido / ruido
#sxclock 0		| muestra (absoluta) donde empieza el proximo bloque a generar
#sxbstart 0		| inicio del bloque que se esta por generar
#sxvolume 2.0		| master: con 2.0 'vol 1.0' de una capa = fondo de escala
#sxratio 1.0		| transposicion del sonido que se esta programando

|--- eventos pendientes (10 celdas = 80 bytes): kind start hz dur slide wave adsr vol crv
##sxev * 20480

#sxEkind #sxEstart #sxEhz #sxEdur #sxEslide #sxEwave #sxEadsr #sxEvol #sxEcrv

:sxevalloc | -- adr/0
	'sxev ( 'sxev 20480 + <?
		dup @ 0? ( drop ; ) drop
		80 + ) drop 0 ;

:sxevadd | --			| agrega un evento con las variables sxE*
	sxevalloc 0? ( drop ; ) >a
	sxEkind a!+  sxEstart a!+  sxEhz a!+  sxEdur a!+
	sxEslide a!+  sxEwave a!+  sxEadsr a!+  sxEvol a!+  sxEcrv a!+ ;

|--------------------------------------------------------------- capas -> eventos
#sxLk #sxLf0 #sxLf1 #sxLdur #sxLwave #sxLvol #sxLdelay #sxLA #sxLD #sxLS #sxLR #sxLcrv
#sxsf0 #sxsf1 #sxsd

:sxslideof | f0 f1 dur -- oct/s	| log2(f1/f0)/dur
	'sxsd ! 'sxsf1 ! 'sxsf0 !
	sxsd 0? ( ; ) drop
	sxsf0 0? ( ; ) drop
	sxsf1 0? ( drop 0 ; ) drop
	sxsf1 sxsf0 =? ( drop 0 ; ) drop
	sxsf1 sxsf0 /. log2. sxsd /. ;

:sxschedlayer | 'layer --
	>a
	da@+ dup 8 >> $f and 'sxLk !  dup 4 >> $f and 'sxLwave !  $f and 'sxLcrv !	| $kwc
	da@+ 'sxLf0 !  da@+ 'sxLf1 !  da@+ 'sxLdur !  da@+ 'sxLvol !
	da@+ 'sxLdelay !  da@+ 'sxLA !  da@+ 'sxLD !  da@+ 'sxLS !  da@+ 'sxLR !
	sxLk 'sxEkind !
	sxclock sxLdelay aurate *. + 'sxEstart !
	sxLdur 'sxEdur !  sxLvol 'sxEvol !  sxLcrv 'sxEcrv !
	sxLA sxLD sxLS sxLR packADSR 'sxEadsr !
	sxLk 1 =? (
		sxLf0 sxratio *. 'sxEhz !
		sxLf0 sxLf1 sxLdur sxslideof 'sxEslide !
		sxLwave 0 max 11 min 3 << 'sfxwaves + @ 'sxEwave !
		sxevadd drop ; )
	drop
	440.0 'sxEhz !  0 'sxEslide !
	sxLf1 16 >> 0 max 2 min 3 << 'sxnoises + @ 'sxEwave !
	sxevadd ;

|--------------------------------------------------------------- lanzar eventos
#sxins

:sxplayev | adr --
	>a
	a@+ 'sxEkind !  a@+ 'sxEstart !  a@+ 'sxEhz !  a@+ 'sxEdur !
	a@+ 'sxEslide !  a@+ 'sxEwave !  a@+ 'sxEadsr !  a@+ 'sxEvol !  a@+ 'sxEcrv !
	sxinsN 'sxins !
	sxEkind 1 =? ( sxinsT 'sxins ! ) drop
	sxEwave sxins smOSC!
	sxEadsr sxins smASDR!
	sxins smi!
	sxEkind 1 =? ( sxEslide smslide! ) drop
	sxEvol smvel!
	sxEcrv smcurve!
	sxEhz sxEdur
	sxEstart sxbstart - 0 max
	smplayhzat ;

#sxq
:sxlaunch | --			| lanza los eventos que empiezan dentro del bloque
	'sxev ( 'sxev 20480 + <?
		dup 'sxq !
		sxq @ 1? (
			sxq 8 + @ sxbstart 2048 + <? ( sxq sxplayev 0 sxq ! ) drop
			) drop
		80 + ) drop ;

|--------------------------------------------------------------- melodias
| registro de melodia (10 celdas = 80 bytes), 8 melodias simultaneas:
|   0 activa 1 ptr 2 inicio 3 proximo(muestra) 4 pulso(muestras) 5 'parche 6 loop 7 octava 8 ultimo-reinicio
#sxtunes * 640
#sxtn 0
#sxTmult 1.0 #sxTsemi 0 #sxTacc 0 #sxlp 0
#sxsemis 9 11 0 2 4 5 7		| a b c d e f g

:t.on sxtn ;
:t.ptr sxtn 8 + ;
:t.ini sxtn 16 + ;
:t.next sxtn 24 + ;
:t.beat sxtn 32 + ;
:t.patch sxtn 40 + ;
:t.loop sxtn 48 + ;
:t.oct sxtn 56 + ;
:t.last sxtn 64 + ;

:sxskipws | p -- p'
	( dup c@ $ff and 1? 33 <? drop 1+ ) drop ;

:sxpint | p -- p' n		| entero decimal
	0 swap
	( dup c@ $ff and 48 - 0 9 in?
		rot 10 * + swap 1+ ) drop swap ;

:sxnote>semi | char -- semitono/-1
	$20 or 97 - 0 6 in? ( 3 << 'sxsemis + @ ; ) drop -1 ;

:sxmidi>hz | midi -- hz
	69 - fix. 12 / pow2. 440.0 *. ;

:sxsuffix1 | p -- p'
	dup c@ $ff and
	$2a =? ( drop 1+ sxpint sxTmult swap * 'sxTmult ! sxsuffix1 ; )
	$2f =? ( drop 1+ sxpint 1 max sxTmult swap / 'sxTmult ! sxsuffix1 ; )
	$2e =? ( drop 1+ sxTmult 1.5 *. 'sxTmult ! sxsuffix1 ; )
	drop ;

:sxsuffix | p -- p'		| *n  /n  .   -> sxTmult
	1.0 'sxTmult ! sxsuffix1 ;

:sxaccid | p -- p'		| # sostenido, b bemol
	0 'sxTacc !
	dup c@ $ff and
	$23 =? ( drop 1 'sxTacc ! 1+ ; )
	$62 =? ( drop -1 'sxTacc ! 1+ ; )
	drop ;

:sxoctv | p -- p'		| un digito fija la octava
	dup c@ $ff and 48 - 0 9 in? ( t.oct ! 1+ ; ) drop ;

:sxtdur | -- muestras
	t.beat @ sxTmult *. ;

:sxtplay | midi --		| programa una nota con el parche de la melodia
	sxmidi>hz 'sxEhz !
	1 'sxEkind !
	t.next @ 'sxEstart !
	sxtdur 16 << aurate / 0.9 *. 'sxEdur !
	0 'sxEslide !
	t.patch @ 'sxlp !
	sxlp d@ 4 >> $f and 0 max 11 min 3 << 'sfxwaves + @ 'sxEwave !
	sxlp 16 + d@ 'sxEvol !
	sxlp 24 + d@ sxlp 28 + d@ sxlp 32 + d@ sxlp 36 + d@ packADSR 'sxEadsr !
	sxlp d@ $f and 'sxEcrv !
	sxevadd ;

:sxtend | --			| fin del texto: repite o termina
	t.loop @ 0? ( drop 0 t.on ! ; ) drop
	t.next @ t.last @ =? ( drop 0 t.on ! ; ) drop	| una pasada sin avanzar el tiempo
	t.next @ t.last !
	t.ini @ t.ptr ! ;

:sxtunestep | --			| interpreta un token
	t.ptr @ sxskipws dup c@ $ff and
	0? ( 2drop sxtend ; )
	$7c =? ( drop 1+ t.ptr ! ; )
	$3e =? ( drop 1+ t.ptr ! 1 t.oct +! ; )
	$3c =? ( drop 1+ t.ptr ! -1 t.oct +! ; )
	$7e =? ( drop 1+ sxsuffix t.ptr ! sxtdur t.next +! ; )
	sxnote>semi -? ( drop 1+ t.ptr ! ; )
	'sxTsemi ! 1+ sxaccid sxoctv sxsuffix t.ptr !
	t.oct @ 1+ 12 * sxTsemi + sxTacc + sxtplay
	sxtdur t.next +! ;

:sxtune1 | --			| programa las notas de la melodia sxtn que caen en este bloque
	64 ( 1? 1-
		t.on @ 0? ( 2drop ; ) drop
		t.next @ sxbstart 2048 + >=? ( 2drop ; ) drop
		sxtunestep ) drop ;

:sxtunesched | --
	'sxtunes ( 'sxtunes 640 + <?
		dup 'sxtn ! sxtune1
		80 + ) drop ;

|--------------------------------------------------------------- API
:sxtick | --				| hook de supermix: antes de generar cada bloque
	sxclock 'sxbstart !
	sxtunesched
	sxlaunch
	2048 'sxclock +! ;

::sfxinit0 | --			| igual que sfxinit pero sin SDL_Init (la app ya inicio SDL / render offline)
	sminit
	0 'sxclock !
	'sxev 0 20480 cfill
	'sxtunes 0 640 cfill
	0.001 0.05 0.8 0.1 packADSR 'oscSqr isweep 'sxinsT !
	0.001 0.05 0.0 0.05 packADSR 'sxnWhite inoise 'sxinsN !
	sxvolume smmaster!
	'sxtick 'smtick ! ;

::sfxinit | --			| SDL audio + supermix + secuenciador
	$10 SDL_Init			| SDL_INIT_AUDIO
	sfxinit0 ;

::sfxupdate | --
	smupdate ;

::sfxclock | -- muestras		| muestras generadas hasta ahora (reloj del secuenciador)
	sxclock ;

::sfxvol | v --
	dup 'sxvolume ! smmaster! ;

:sxplaylayers | 'sonido --
	( dup d@ 1? drop dup sxschedlayer sfxLAYER + ) 2drop ;

::sfxplay | 'sonido --
	1.0 'sxratio ! sxplaylayers ;

::sfxplayp | 'sonido semitonos --
	fix. 12 / pow2. 'sxratio ! sxplaylayers 1.0 'sxratio ! ;

#sxTt #sxTb #sxTp #sxTl
::sfxtune | "notas" bpm 'parche loop -- id
	'sxTl ! 'sxTp ! 'sxTb ! 'sxTt !
	0 ( 8 <?
		dup 80 * 'sxtunes + 'sxtn !
		t.on @ 0? ( drop
			1 t.on !  sxTt t.ptr !  sxTt t.ini !  sxclock t.next !
			aurate 60 * sxTb 1 max / t.beat !
			sxTp t.patch !  sxTl t.loop !  4 t.oct !  -1 t.last !
			; ) drop
		1+ ) drop -1 ;

::sfxtunestop | id --
	0 swap 80 * 'sxtunes + ! ;

::sfxstop | --
	smreset sxvolume smmaster!		| smreset deja el master en 1.0
	'sxev 0 20480 cfill
	'sxtunes 0 640 cfill ;
