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
|   "notas" bpm ins loop sfxtune -- id        melodia (formato abajo); ins = instrumento de supermix
|                                            (iosc isweep isample...), fijo para toda la melodia
|   id vol crv sfxtunemix -- id   volumen (16.16) y curva de la melodia (por defecto 1.0 y 0)
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
| REGISTROS: el registro B apunta al registro actual (la melodia en proceso o la capa que
| se esta tocando); A es scratch de hojas (l.adsr) y lo usa smplayhz. Supermix solo usa A/B
| dentro de genAudio, que corre despues del hook, asi que no hay choque. La API publica
| (sfxupdate sfxplay sfxplayp sfxtune sfxtunemix) guarda y restaura A y B (ab[ ]ba).
| Capas y notas se disparan con smplayhzat (el retardo en muestras lo maneja la voz): no hay cola de eventos.

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
| registro de melodia (9 celdas = 72 bytes), 8 melodias simultaneas; B apunta al registro en proceso:
|   0 ptr (0 = inactiva) 8 inicio 16 proximo(muestra) 24 pulso(muestras) 32 instrumento
|   40 loop 48 octava 56 ultimo-reinicio 64 vol(dword) 68 crv(dword)
#sxtunes * 576
#sxsemis 9 11 0 2 4 5 7		| a b c d e f g

:sxtune@ | n -- adr		| registro de la melodia n
	72 * 'sxtunes + ;

:t.ini b> 8 + ;
:t.next b> 16 + ;
:t.beat b> 24 + ;
:t.ins b> 32 + ;
:t.loop b> 40 + ;
:t.oct b> 48 + ;
:t.last b> 56 + ;
:t.vol b> 64 + ;
:t.crv b> 68 + ;

:sxskipws | p -- p'
	( dup c@ $ff and 1? 33 <? drop 1+ ) drop ;

:sxpint | p -- p' n		| entero decimal
	0 swap
	( dup c@ $ff and 48 - 0 9 in?
		rot 10 * + swap 1+ ) drop swap ;


:sxpint | p -- p' n		| entero decimal
	0 swap
	( dup c@ $ff and 48 - 0 9 in?
		rot 10 * + swap 1+ ) drop swap ;

:sxnote>semi | char -- semitono/-1
	$20 or 97 - 0 6 in? ( 3 << 'sxsemis + @ ; ) drop -1 ;

:sxmidi>hz | midi -- hz
	69 - fix. 12 / pow2. 440.0 *. ;

:sxsuffix1 | p mult -- p' mult
	over c@ $ff and
	$2a =? ( drop swap 1+ sxpint rot * sxsuffix1 ; )		| *n
	$2f =? ( drop swap 1+ sxpint 1 max rot swap / sxsuffix1 ; )	| /n
	$2e =? ( drop swap 1+ swap 1.5 *. sxsuffix1 ; )		| .
	drop ;

:sxsuffix | p -- p' mult	| multiplicador de duracion (16.16)
	1.0 sxsuffix1 ;

:sxaccid | p -- p' acc		| # sostenido, b bemol
	dup c@ $ff and
	$23 =? ( drop 1+ 1 ; )
	$62 =? ( drop 1+ -1 ; )
	drop 0 ;

:sxoctv | p -- p'		| un digito fija la octava
	dup c@ $ff and 48 - 0 9 in? ( t.oct ! 1+ ; ) drop ;

:sxtnote | midi dur --		| toca la nota ahora (retardo en muestras dentro del bloque) y avanza
	swap sxmidi>hz					| dur hz
	t.ins @ smi!  t.vol d@ smvel!  t.crv d@ smcurve!
	over 16 << aurate / 0.9 *.			| dur hz seg
	t.next @ sxbstart - 0 max smplayhzat
	t.next +! ;

:sxtend | --			| fin del texto: repite o termina
	t.loop @ 0? ( drop 0 b! ; ) drop
	t.next @ t.last @ =? ( drop 0 b! ; ) drop	| una pasada sin avanzar el tiempo
	t.next @ t.last !
	t.ini @ b! ;

:sxtunestep | --			| interpreta un token
	b@ sxskipws dup c@ $ff and
	0? ( 2drop sxtend ; )
	$7c =? ( drop 1+ b! ; )
	$3e =? ( drop 1+ b! 1 t.oct +! ; )
	$3c =? ( drop 1+ b! -1 t.oct +! ; )
	$7e =? ( drop 1+ sxsuffix swap b! t.beat @ swap *. t.next +! ; )
	sxnote>semi -? ( drop 1+ b! ; )	| p semi
	swap 1+ sxaccid rot +			| p' semi+acc
	swap sxoctv sxsuffix			| semi p' mult
	swap b!				| semi mult
	t.beat @ swap *.				| semi dur
	swap t.oct @ 1+ 12 * + swap		| midi dur
	sxtnote ;

:sxtune1 | --			| programa las notas de la melodia B que caen en este bloque
	64 ( 1? 1-
		b@ 0? ( 2drop ; ) drop
		t.next @ sxbstart 2048 + >=? ( 2drop ; ) drop
		sxtunestep ) drop ;

:sxtunesched | --
	'sxtunes >b
	8 ( 1? 1- sxtune1 72 b+ ) drop ;

:sxtunesclear | --
	'sxtunes 0 576 cfill ;

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

:sxtunenew | "notas" bpm ins loop -- id
	sxtunefree -? ( >r 4drop r> ; )		| txt bpm ins loop id
	dup sxtune@ >b  >r
	t.loop !  t.ins !					| txt bpm
	aurate 60 * swap 1 max / t.beat !	| txt
	dup b!  t.ini !
	sxclock t.next !  4 t.oct !  -1 t.last !
	1.0 t.vol d!  0 t.crv d!
	r> ;

::sfxtune | "notas" bpm ins loop -- id
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
