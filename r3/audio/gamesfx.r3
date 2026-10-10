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
|   "patron" bpm ins loop sfxtune -- id       melodia (mini-notacion Strudel, abajo); ins = instrumento de
|                                            supermix (iosc isweep isample...), fijo para toda la melodia
|   id vol crv sfxtunemix -- id   volumen (16.16) y curva de la melodia (por defecto 1.0 y 0)
|   id sfxtunestop           corta una melodia
|   sfxstop                  corta todo
|   v sfxvol                 volumen general (1.0 normal, 2.0 por defecto)
|
| MELODIAS: mini-notacion de Strudel (el parser es eval.r3, ahi esta la sintaxis completa)
|   c4 d4 e4 f4          notas: c4 = do central (midi 60); sin octava = octava 3; c#4 db4; un numero = midi
|   ~                    silencio            [c4 d4]  un paso con dos notas    <c4 d4>  una por ciclo
|   c4*2  c4/2           mas rapido / mas lento    c4!2  replica    c4@3  c4 _  pesos    c4?  al azar
|   [c4 e4, g4]  {c4 e4 g4}  (c4 d4)  c4(3,8)  c4:3  c4^0.5   capas, acordes, azar, euclidiano, variante, volumen
|   Un CICLO dura 4 pulsos a 'bpm' (240/bpm segundos): "c4 d4 e4 f4" son cuatro negras. Para melodias largas se
|   escribe un compas por ciclo con <...>:   <[c4 d4 e4 f4] [g4@2 e4@2]>   (loop 1 repite)
| REGISTROS: el registro B apunta al registro actual (la melodia en proceso o la capa que
| se esta tocando); A es scratch de hojas (l.adsr) y lo usa smplayhz. Supermix solo usa A/B
| dentro de genAudio, que corre despues del hook, asi que no hay choque. La API publica
| (sfxupdate sfxplay sfxplayp sfxtune sfxtunemix) guarda y restaura A y B (ab[ ]ba).
| Capas y notas se disparan con smplayhzat (el retardo en muestras lo maneja la voz): no hay cola de eventos.

^r3/lib/math.r3
^r3/lib/rand.r3
^./supermix.r3
^./eval.r3

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
#sxinsT #sxinsN		| instrumentos de efectos: tonos con barrido / ruido
#sxclock 0		| muestra (absoluta) donde empieza el proximo bloque a generar
#sxbstart 0		| inicio del bloque que se esta por generar
#sxvolume 2.0		| master: con 2.0 'vol 1.0' de una capa = fondo de escala

|--------------------------------------------------------------- capas
:sxslideof | f0 f1 dur -- oct/s	| log2(f1/f0)/dur
	0? ( 3drop 0 ; )
	rot 0? ( 3drop 0 ; )					| f1 dur f0
	pick2 0? ( 4drop 0 ; ) =? ( 3drop 0 ; )	| f1 dur f0
	rot swap /. log2. swap /. ;

:l.k db@ 8 >> $f and ;			| B = capa en curso
:l.w db@ 4 >> $f and ;
:l.c db@ $f and ;
:l.f0 b> 4 + d@ ;
:l.f1 b> 8 + d@ ;
:l.dur b> 12 + d@ ;
:l.vol b> 16 + d@ ;
:l.delay b> 20 + d@ ;
:l.adsr b> 24 + >a da@+ da@+ da@+ da@+ packADSR ;

:sxsetins | osc ins --		| onda y ADSR de la capa en el instrumento; lo selecciona
	dup >r smOSC!  l.adsr r@ smASDR!  r> smi! ;

:sxplaynote | hz --
	l.vol smvel!  l.c smcurve!
	l.dur l.delay aurate *. smplayhzat ;

:sxplaylayer | 'layer ratio --
	swap >b
	l.k 1 =? ( drop
		l.w 0 max 11 min 3 << 'sfxwaves + @ sxinsT sxsetins
		l.f0 l.f1 l.dur sxslideof smslide!
		l.f0 *. sxplaynote ; ) drop
	l.f1 16 >> 0 max 2 min 3 << 'sxnoises + @ sxinsN sxsetins
	drop 440.0 sxplaynote ;

|--------------------------------------------------------------- melodias
| mini-notacion Strudel (eval.r3): cada ciclo se evalua una vez, los eventos se guardan y se
| programan por bloque con smplayhzat (precision de muestra).
| registro de melodia (64 bytes), 8 simultaneas; B apunta al registro en proceso:
|   0 arbol (buffer de eval.r3, 0 = inactiva)  8 largo del ciclo (muestras)  16 inicio del ciclo actual (muestra)
|   24 nro de ciclo  32 instrumento  40 loop  48 vol(dword)  52 crv(dword)  56 eventos del ciclo (-1 = sin generar)
#sxtunes * 512
#sxtoks * $20000		| arbol de cada melodia: 16 KB (512 nodos)
#sxevs * $4000		| eventos del ciclo actual de cada melodia: 2 KB (256 eventos)

:sxtune@ | n -- adr		| registro de la melodia n
	6 << 'sxtunes + ;

:t.tree b> ;
:t.clen b> 8 + ;
:t.cstart b> 16 + ;
:t.cyc b> 24 + ;
:t.ins b> 32 + ;
:t.loop b> 40 + ;
:t.vol b> 48 + ;
:t.crv b> 52 + ;
:t.nev b> 56 + ;

:t.evs | -- adr		| buffer de eventos de la melodia B
	b> 'sxtunes - 6 >> 11 << 'sxevs + ;

:sxmidi>hz | midi -- hz
	69 - fix. 12 / pow2. 440.0 *. ;

:sxgen | --			| evalua el ciclo actual de la melodia B y guarda sus eventos
	'stack 'stack> !
	t.tree @ t.cyc @ evalat
	stack> 'stack - 3 >> dup t.nev !
	t.evs 'stack rot move ;

:sxevvel | ev -- vel	| volumen del evento (0 = normal) por el de la melodia
	48 >> $ff and 1? ( 16 << 255 / t.vol d@ *. ; ) drop t.vol d@ ;

:sxev | ev --			| programa el evento si cae dentro de este bloque
	dup 16 >> $ffff and t.clen @ * 16 >> t.cstart @ + sxbstart -	| ev delay
	0 <? ( 2drop ; ) 2048 >=? ( 2drop ; )
	swap										| delay ev
	t.ins @ smi!
	dup sxevvel smvel!  t.crv d@ smcurve!
	dup 32 >> $ff and sxmidi>hz					| delay ev hz
	swap $ffff and t.clen @ * 16 >> 16 << aurate / 0.9 *.	| delay hz seg
	rot smplayhzat ;

:sxevs1 | --			| eventos del ciclo de la melodia B que caen en este bloque
	t.evs t.nev @ ( 1? 1- >r @+ sxev r> ) 2drop ;

:sxadvance | -- 0/1		| pasa al ciclo siguiente (0 = la melodia termino)
	t.loop @ 0? ( drop 0 t.tree ! 0 ; ) drop
	1 t.cyc +!  t.clen @ t.cstart +!  sxgen 1 ;

:sxtune1 | --			| programa la melodia B en este bloque
	t.tree @ 0? ( drop ; ) drop
	t.nev @ -? ( sxgen ) drop
	64 ( 1? 1-
		sxevs1
		t.cstart @ t.clen @ + sxbstart 2048 + >=? ( 2drop ; ) drop
		sxadvance 0? ( 2drop ; ) drop ) drop ;

:sxtunesched | --
	'sxtunes >b
	8 ( 1? 1- sxtune1 64 b+ ) drop ;

:sxtunesclear | --
	'sxtunes 0 512 cfill ;

|--------------------------------------------------------------- API
:sxtick | --				| hook de supermix: antes de generar cada bloque
	sxclock 'sxbstart !
	sxtunesched
	2048 'sxclock +! ;

::sfxinit0 | --			| igual que sfxinit pero sin SDL_Init (la app ya inicio SDL / render offline)
	sminit
	0 'sxclock !
	sxtunesclear
	0.001 0.05 0.8 0.1 packADSR 'oscSqr isweep 'sxinsT !
	0.001 0.05 0.0 0.05 packADSR 'sxnWhite inoise 'sxinsN !
	sxvolume smmaster!
	'sxtick 'smtick ! ;

::sfxinit | --			| SDL audio + supermix + secuenciador
	$10 SDL_Init			| SDL_INIT_AUDIO
	sfxinit0 ;

::sfxupdate | --
	ab[ smupdate ]ba ;

::sfxclock | -- muestras		| muestras generadas hasta ahora (reloj del secuenciador)
	sxclock ;

::sfxvol | v --
	dup 'sxvolume ! smmaster! ;

:sxplaylayers | 'sonido ratio --
	ab[ swap ( dup d@ 1? drop			| ratio snd
		2dup swap sxplaylayer
		sfxLAYER + ) 3drop ]ba ;

::sfxplay | 'sonido --
	1.0 sxplaylayers ;

::sfxplayp | 'sonido semitonos --
	fix. 12 / pow2. sxplaylayers ;

:sxtunefree | -- id/-1
	0 ( 8 <?
		dup sxtune@ @ 0? ( drop ; ) drop
		1+ ) drop -1 ;

:sxtunenew | "patron" bpm ins loop -- id
	sxtunefree -? ( >r 4drop r> ; )		| txt bpm ins loop id
	dup sxtune@ >b  >r
	t.loop !  t.ins !					| txt bpm
	aurate 240 * swap 1 max / t.clen !	| txt: un ciclo = 4 pulsos
	r@ 14 << 'sxtoks + dup t.tree !		| txt buf
	processat drop
	sxclock t.cstart !  0 t.cyc !  -1 t.nev !
	1.0 t.vol d!  0 t.crv d!
	r> ;

::sfxtune | "patron" bpm ins loop -- id
	ab[ sxtunenew ]ba ;

:sxtunemix | id vol crv -- id
	rot -? ( 3drop -1 ; )				| vol crv id
	dup sxtune@ >b
	>r t.crv d! t.vol d! r> ;

::sfxtunemix | id vol crv -- id
	ab[ sxtunemix ]ba ;

::sfxtunestop | id --
	-? ( drop ; ) 0 swap sxtune@ ! ;

::sfxstop | --
	smreset sxvolume smmaster!		| smreset deja el master en 1.0
	sxtunesclear ;
