| gamesfx.r3 - sonidos de videojuego generados (sin .mp3) sobre supermix.r3
| PHREDA 2025
|
| Un SONIDO es un solo bloque de datos, escrito con la sintaxis de datos de 32 bits:
|   ##nombre [ ... ]    (cada valor ocupa un dword; no hay terminador ni capas)
| Es un tono (con barrido de frecuencia) o una rafaga de ruido: 10 valores. Los efectos
| compuestos (arpegios, repeticiones, filtros, vibrato) se hacen con kind 3.
|
|   $kwc  f0    f1    dur   vol   delay  A     D    S   R
|   $103  200.0 70.0  0.09  0.14  0.0    0.001 0.09 0.0 0.005   <- tono
|   $200  0.0   0.0   0.09  0.18  0.0    0.001 0.09 0.0 0.005   <- ruido (f1 = color)
|
|   $kwc  primer valor, tres nibbles en hexa:  k = kind   w = wave   c = crv
|         ej: kind=1 wave=10 crv=2 -> $1A2.  Un sonido con kind 0 no suena
|   kind  1 tono, 2 ruido, 3 sonido de fxsynth (ver KIND 3)
|   wave  forma de onda 0..15, ver sfxwavename (0 cuadrada 1 sierra 2 seno 3 triangulo ...)
|   crv   curva de la envolvente: 0 lineal, 1 cuadratica, 2 cubica, 3 cuartica (~exp(-6t))
|   f0    frecuencia inicial en Hz (16.16)
|   f1    frecuencia final en Hz: el tono barre f0->f1 (exponencial) durante 'dur'
|         en ruido: color 0.0 blanco, 1.0 rosa, 2.0 marron
|   dur   duracion de la nota en segundos; despues se agrega la cola R
|   vol   volumen 0..1 (16.16)
|   delay retardo en segundos desde que se dispara el sonido
|   A D S R  envolvente: ataque(s) decaimiento(s) nivel de sostenido(0..1) release(s)
|   (16.16 en 32 bits con signo: las frecuencias llegan a 32767 Hz)
|
| KIND 3: sonido de fxsynth.r3 (filtros, vibrato, arpegio, duty, punch...). El sonido mide 32 valores:
|   los 10 de siempre ($300; solo valen vol y delay, el resto se ignora) y despues los 22 parametros
|   de fxsynth en el orden p_wave p_attack ... p_vol (16.16; p_wave es un entero, como lo imprime fxdemo)
|   $300 0.0 0.0 0.0 1.0 0.0 0 0 0 0   0 0.0 0.15 0.0 0.2 0.8 0.5 -0.25 0.0 ...(22 valores)
|   Se renderiza una sola vez (la primera vez que suena, o antes con sfxprepare) y queda en un
|   cache de 32 sonidos / 2 MB; suena como un sample con vol, delay y transposicion (sfxplayp).
|   Usa los p_* de fxsynth como registro de trabajo.
|
| Todo arranca con precision de muestra (supermix: smtick + smplayhzat), asi que el delay
| y las notas de las melodias no dependen de los cuadros por segundo.
|
| API
|   sfxinit                  inicia supermix, instrumentos y secuenciador
|   sfxupdate                llamar una vez por cuadro (genera/encola el audio)
|   'sonido sfxplay          dispara un sonido
|   'sonido n sfxplayp       igual, transpuesto n semitonos (variacion)
|   'sonido sfxprepare       renderiza antes un sonido kind 3 (el primer disparo no se traba)
|   "patron" bpm ins loop sfxtune -- id       melodia (mini-notacion Strudel, abajo); ins = instrumento de
|                                            supermix (iosc isweep isample...), fijo para toda la melodia
|   id vol crv sfxtunemix -- id   volumen (16.16) y curva de la melodia (por defecto 1.0 y 0)
|   id sfxtunestop           corta una melodia
|   id "patron" sfxtunetext  cambia el patron de una melodia que suena (entra en el proximo ciclo, sigue el compas)
|   id bpm sfxtunebpm         cambia el tempo de una melodia que suena
|   id ins sfxtuneins         cambia el instrumento de una melodia que suena (vale desde la proxima nota)
|   id sfxtuneplaying -- 0/1  la melodia sigue sonando?          id sfxtunecycle -- n   ciclo actual
|   sfxstop                  corta todo
|   v sfxvol                 volumen general (1.0 normal, 2.0 por defecto)
|
| PISTAS: instrumento editable + melodia en bucle + notas sostenidas (teclado). 8 pistas, cada una con
|   sus parametros y su melodia; sirven para editores/sliders (ver chipa.r3).
|   n sfxtrk -- rec          registro de la pista n. Los campos son variables de 64 bits (16.16) para
|                            sliders y combos:  rec tkwave|tka|tkd|tks|tkr|tkvol|tkcrv|tkdet -- adr
|   tkwave  (puede ir directo a uiCombo) onda 0..19, nombres en sfxtnames: 0..15 osciladores (igual que la
|           columna wave de los sonidos), 16 supersaw de 7 osciladores, 17 18 19 ruido blanco rosa marron
|   tka tkd tks tkr   envolvente: ataque y decaimiento (s), sostenido (0..1), release (s)
|   tkvol tkcrv       volumen (1.0) y curva de la envolvente (0 lineal .. 3 cuartica)
|   tkdet             detune del supersaw: fraccion de la frecuencia (0.01 = 1%)
|   n sfxtrkapply                aplica los parametros: llamar despues de cambiarlos (valen desde la proxima nota)
|   n "patron" bpm sfxtrkplay    melodia en bucle; si ya suena, el patron nuevo entra en el proximo ciclo
|   n sfxtrkstop      n bpm sfxtrkbpm      n sfxtrkplaying -- 0/1      n sfxtrkcycle -- n
|   midi n sfxtrkon   midi n sfxtrkoff    nota sostenida con el instrumento de la pista
|
| MELODIAS: mini-notacion de Strudel (el parser es eval.r3, ahi esta la sintaxis completa)
|   c4 d4 e4 f4          notas: c4 = do central (midi 60); sin octava = octava 3; c#4 db4; un numero = midi
|   ~                    silencio            [c4 d4]  un paso con dos notas    <c4 d4>  una por ciclo
|   c4*2  c4/2           mas rapido / mas lento    c4!2  replica    c4@3  c4 _  pesos    c4?  al azar
|   [c4 e4, g4]  {c4 e4 g4}  (c4 d4)  c4(3,8)  c4:3  c4^0.5   capas, acordes, azar, euclidiano, variante, volumen
|   Un CICLO dura 4 pulsos a 'bpm' (240/bpm segundos): "c4 d4 e4 f4" son cuatro negras. Para melodias largas se
|   escribe un compas por ciclo con <...>:   <[c4 d4 e4 f4] [g4@2 e4@2]>   (loop 1 repite)
| REGISTROS: el registro B apunta al registro actual (la melodia en proceso o el sonido que
| se esta tocando); A es scratch de hojas (l.adsr) y lo usa smplayhz. Supermix solo usa A/B
| dentro de genAudio, que corre despues del hook, asi que no hay choque. La API publica
| (sfxupdate sfxplay sfxplayp sfxtune sfxtunemix) guarda y restaura A y B (ab[ ]ba).
| Capas y notas se disparan con smplayhzat (el retardo en muestras lo maneja la voz): no hay cola de eventos.

^r3/lib/math.r3
^r3/lib/rand.r3
^./supermix.r3
^./eval.r3
^./fxsynth.r3

|--------------------------------------------------------------- tablas
##sfxwaves 'oscSqr 'oscSaw 'oscSin 'oscTri 'oscPul2 'oscPul1 'oscSawRev 'oscSinF 'oscTrap 'oscHSin 'oscSin3 'oscSuperSaw2P
'oscSin2 'oscParab 'oscFakeSuperSaw 'oscSuperSaw3P
##sfxnwaves 16			| ondas de sonido (nibble wave: 0..15)

#sxwnames "square" "saw" "sine" "triangle" "pulse25" "pulse10" "saw-rev" "sine-fold" "trapezoid" "half-sine" "sine3" "supersaw" "sine2" "parabola" "fake-supersaw" "supersaw3"
#sxnnames "white" "pink" "brown"

::sfxwavename | n -- "str"
	0 max 15 min
	'sxwnames swap ( 1? 1- swap >>0 swap ) drop ;

::sfxnoisename | n -- "str"
	0 max 2 min
	'sxnnames swap ( 1? 1- swap >>0 swap ) drop ;

| ruidos normalizados (el marron sale mas bajo)
:sxnWhite wnoise ;
:sxnPink pnoise ;
:sxnBrown bnoise 3 * ;
#sxnoises 'sxnWhite 'sxnPink 'sxnBrown
#sxtknoises 'wnoise 'pnoise1 'bnoise	| ruidos de pista (17 18 19)

##sfxtnames "Sqr" "Saw" "Sin" "Tri" "Pul25" "Pul10" "SawRev" "SinFold" "Trap" "HSin" "Sin3" "SSaw2" "Sin2" "Parab" "FSaw" "SSaw3" "SuperSaw" "White" "Pink" "Brown" 0

|--------------------------------------------------------------- estado
#sxinsT #sxinsN		| instrumentos de efectos: tonos con barrido / ruido
#sxclock 0		| muestra (absoluta) donde empieza el proximo bloque a generar
#sxbstart 0		| inicio del bloque que se esta por generar
#sxvolume 2.0		| master: con 2.0 'vol 1.0' de un sonido = fondo de escala

|--------------------------------------------------------------- sonidos (tono / ruido)
:sxslideof | f0 f1 dur -- oct/s	| log2(f1/f0)/dur
	0? ( 3drop 0 ; )
	rot 0? ( 3drop 0 ; )					| f1 dur f0
	pick2 0? ( 4drop 0 ; ) =? ( 3drop 0 ; )	| f1 dur f0
	rot swap /. log2. swap /. ;

:l.k db@ 8 >> $f and ;			| B = sonido en curso
:l.w db@ 4 >> $f and ;
:l.c db@ $f and ;
:l.f0 b> 4 + d@ ;
:l.f1 b> 8 + d@ ;
:l.dur b> 12 + d@ ;
:l.vol b> 16 + d@ ;
:l.delay b> 20 + d@ ;
:l.adsr b> 24 + >a da@+ da@+ da@+ da@+ packADSR ;

:sxsetins | osc ins --		| onda y ADSR del sonido en el instrumento; lo selecciona
	dup >r smOSC!  l.adsr r@ smASDR!  r> smi! ;

:sxplaynote | hz --
	l.vol smvel!  l.c smcurve!
	l.dur l.delay aurate *. smplayhzat ;

|--------------------------------------------------------------- sonido kind 3: sonido de fxsynth
| ver KIND 3 en la cabecera. El render (176400 muestras) es costoso: se hace una sola vez por sonido
| y queda en un cache (clave = direccion del sonido).
#sxfxpool * $200000		| 2 MB: samples renderizados, frames estereo de 16 bits
#sxfxused 0			| bytes usados del pool
#sxfxc * 1024			| cache de 32 entradas x 32 bytes: 0 sonido  8 instrumento  16 frames
#sxfxn 0			| entradas usadas
#sxfxe 0			| entrada en construccion

:sxfxload | 'params --		| 22 dwords 16.16 -> p_wave .. p_vol (qwords contiguos)
	>a 'p_wave >b
	22 ( 1? 1- da@+ 32 << 32 >> b!+ ) drop ;

:sxfxtrim | len -- frames		| quita el silencio del final del render
	( 1? 1- dup 2 << 'fxbuf + w@ 48 << 48 >> abs 64 >=?
		( drop 1+ 256 + fxmaxsamples min ; ) drop )
	256 + ;

:sxfxfind | 'sonido -- ent/0
	0 ( sxfxn <?				| snd i
		dup 5 << 'sxfxc + dup @		| snd i ent key
		pick3 =? ( drop nip nip ; )
		2drop 1+ ) 2drop 0 ;

:sxfxnew | 'sonido -- ent/0
	sxfxn 32 >=? ( 2drop 0 ; ) drop
	dup 40 + sxfxload
	fxRender sxfxtrim			| snd frames
	sxfxused over 2 << + $200000 >? ( 3drop 0 ; ) drop
	sxfxn 5 << 'sxfxc + 'sxfxe !
	swap sxfxe !				| frames   (clave = sonido)
	dup sxfxe 16 + !			| frames   (largo)
	'sxfxpool sxfxused + 'fxbuf pick2 2 << cmove
	0.0 0.0 1.0 0.01 packADSR 'sxfxpool sxfxused + pick3 isamplemem sxfxe 8 + !
	2 << 'sxfxused +!
	1 'sxfxn +!
	sxfxe ;

:sxfxget | 'sonido -- ent/0
	dup sxfxfind 1? ( nip ; ) drop sxfxnew ;

:sxplayfx | ratio --			| sonido kind 3 (B = sonido): sample del cache
	b> ab[ sxfxget ]ba			| ratio ent/0
	0? ( 2drop ; )
	dup 8 + @ smi!
	l.vol smvel!  0 smcurve!
	16 + @ 16 << aurate /			| ratio seg
	swap 440.0 *. swap			| hz seg   (440 Hz = velocidad original)
	l.delay aurate *. smplayhzat ;

:sxplaysound | 'sonido ratio --		| B = sonido
	swap >b
	l.k 0? ( 2drop ; )
	1 =? ( drop
		l.w 0 max 15 min 3 << 'sfxwaves + @ sxinsT sxsetins
		l.f0 l.f1 l.dur sxslideof smslide!
		l.f0 *. sxplaynote ; )
	3 =? ( drop sxplayfx ; ) drop
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

|--------------------------------------------------------------- pistas: registro
| 8 pistas x 128 bytes, campos de 64 bits: 0 wave (3 celdas: uiCombo usa var+8 y var+16 como estado)
| 24 a 32 d 40 s 48 r 56 vol 64 crv 72 det (parametros, 16.16)  80 io 88 is 96 in (instrumentos
| onda/supersaw/ruido, -1 = sin crear)  104 ins (el que suena)  112 id (melodia en curso, -1 = ninguna).
| Los instrumentos se crean la primera vez que se usa la pista.
#sxtrks * 1024
#sxtkn * 1024		| notas sostenidas: 128 bytes por pista (id de voz por nota midi)
#sxtk 0			| pista en curso (registro)

::sfxtrk | n -- rec		| registro de la pista n (0..7)
	0 max 7 min 7 << 'sxtrks + ;
::tkwave 0 + ;
::tka 24 + ;
::tkd 32 + ;
::tks 40 + ;
::tkr 48 + ;
::tkvol 56 + ;
::tkcrv 64 + ;
::tkdet 72 + ;
:tkio 80 + ;
:tkis 88 + ;
:tkin 96 + ;
:tkins 104 + ;
:tkid 112 + ;

:sxtkreset | --
	0 ( 8 <? dup sfxtrk 'sxtk !
		0 sxtk tkwave !
		0.002 sxtk tka !  0.05 sxtk tkd !  0.8 sxtk tks !  0.1 sxtk tkr !
		1.0 sxtk tkvol !  0 sxtk tkcrv !  0.01 sxtk tkdet !
		-1 sxtk tkio !  -1 sxtk tkis !  -1 sxtk tkin !  0 sxtk tkins !  -1 sxtk tkid !
		1+ ) drop
	'sxtkn 0 1024 cfill ;

::sfxinit0 | --			| igual que sfxinit pero sin SDL_Init (la app ya inicio SDL / render offline)
	sminit
	0 'sxclock !
	sxtunesclear sxtkreset
	0 'sxfxn ! 0 'sxfxused !
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

::sfxplay | 'sonido --
	1.0 ab[ sxplaysound ]ba ;

::sfxplayp | 'sonido semitonos --
	fix. 12 / pow2. ab[ sxplaysound ]ba ;

::sfxprepare | 'sonido --		| renderiza antes un sonido kind 3 (el primer disparo no se traba)
	dup d@ 8 >> $f and 3 <>? ( 2drop ; ) drop
	ab[ sxfxget drop ]ba ;

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

|--- control en vivo de una melodia (id de sfxtune)
:sxtunetext | id "patron" --
	swap -? ( 2drop ; )
	dup sxtune@ >b
	t.tree @ 0? ( 3drop ; ) drop			| txt id
	14 << 'sxtoks + processat drop ;	| se parsea en el buffer de la melodia: el ciclo ya generado no cambia

::sfxtunetext | id "patron" --
	ab[ sxtunetext ]ba ;

:sxtunebpm | id bpm --
	swap -? ( 2drop ; )
	sxtune@ >b
	aurate 240 * swap 1 max / t.clen ! ;

::sfxtunebpm | id bpm --
	ab[ sxtunebpm ]ba ;

:sxtuneins | id ins --
	swap -? ( 2drop ; )
	sxtune@ >b
	t.ins ! ;

::sfxtuneins | id ins --
	ab[ sxtuneins ]ba ;

::sfxtuneplaying | id -- 0/1
	-? ( drop 0 ; ) sxtune@ @ 0? ( ; ) drop 1 ;

::sfxtunecycle | id -- n
	-? ( drop 0 ; ) sxtune@ 24 + @ ;

|--------------------------------------------------------------- pistas: API
:sxtkadsr | -- v1 v2
	sxtk tka @ sxtk tkd @ sxtk tks @ sxtk tkr @ packADSR ;

:sxtkset | n --			| envolvente al instrumento n
	sxtkadsr rot smASDR! ;

:sxtkwave | --			| funcion de onda segun tkwave (instrumento onda, supersaw o ruido)
	sxtk tkwave @ 0 max 19 min
	16 <? ( 3 << 'sfxwaves + @ sxtk tkio @ smOSC!  sxtk tkio @ sxtk tkins ! ; )
	16 =? ( drop 'oscSaw sxtk tkis @ smOSC!
		sxtk tkdet @ sxtk tkis @ smAUX!  sxtk tkis @ sxtk tkins ! ; )
	17 - 3 << 'sxtknoises + @ sxtk tkin @ smOSC!  sxtk tkin @ sxtk tkins ! ;

:sxtkopen | --			| crea los 3 instrumentos de la pista la primera vez
	sxtk tkio @ -? ( drop
		sxtkadsr 'oscSin iosc sxtk tkio !
		sxtkadsr 'oscSaw sxtk tkdet @ isuper sxtk tkis !
		sxtkadsr 'wnoise inoise sxtk tkin !
		sxtkwave ; ) drop ;

:sxtkapply | --
	sxtkopen
	sxtk tkio @ sxtkset  sxtk tkis @ sxtkset  sxtk tkin @ sxtkset
	sxtkwave
	sxtk tkid @ sxtk tkins @ sxtuneins
	sxtk tkid @ sxtk tkvol @ sxtk tkcrv @ sxtunemix drop ;

::sfxtrkapply | n --
	ab[ sfxtrk 'sxtk ! sxtkapply ]ba ;

:sxtkplay | "patron" bpm --
	sxtkopen
	sxtk tkid @ sfxtuneplaying 1? ( drop			| ya suena: tempo y patron nuevo en el proximo ciclo
		sxtk tkid @ swap sxtunebpm
		sxtk tkid @ swap sxtunetext ; ) drop
	sxtk tkins @ 1 sxtunenew dup sxtk tkid !
	sxtk tkvol @ sxtk tkcrv @ sxtunemix drop ;

::sfxtrkplay | n "patron" bpm --
	ab[ rot sfxtrk 'sxtk ! sxtkplay ]ba ;

::sfxtrkstop | n --
	sfxtrk tkid dup @ sfxtunestop -1 swap ! ;

::sfxtrkbpm | n bpm --
	swap sfxtrk tkid @ swap sfxtunebpm ;

::sfxtrkplaying | n -- 0/1
	sfxtrk tkid @ sfxtuneplaying ;

::sfxtrkcycle | n -- n
	sfxtrk tkid @ sfxtunecycle ;

|--- notas sostenidas (teclado): el id de la voz se guarda por nota
:sxtknote | midi -- adr
	0 max 127 min sxtk 'sxtrks - 'sxtkn + + ;

:sxtkon | midi --
	sxtkopen
	0 max 127 min dup sxtknote
	dup c@ 1? ( 3drop ; ) drop			| midi adr
	sxtk tkins @ smi!  sxtk tkvol @ smvel!  sxtk tkcrv @ smcurve!
	swap smplay swap c! ;

:sxtkoff | midi --
	sxtknote dup c@ 0? ( 2drop ; )
	smstop 0 swap c! ;

::sfxtrkon | midi n --
	ab[ sfxtrk 'sxtk ! sxtkon ]ba ;

::sfxtrkoff | midi n --
	ab[ sfxtrk 'sxtk ! sxtkoff ]ba ;

:sxtkhalt | --			| las melodias y voces ya no existen (sfxstop)
	0 ( 8 <? dup sfxtrk tkid -1 swap !  1+ ) drop
	'sxtkn 0 1024 cfill ;

::sfxstop | --
	smreset sxvolume smmaster!		| smreset deja el master en 1.0
	sxtunesclear sxtkhalt ;
