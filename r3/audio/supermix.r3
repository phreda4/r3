| superMix
| PHREDA 2025
|-------------------

^r3/lib/sdl2gfx.r3
^r3/lib/sdl2mixer.r3
^./noise.r3

|^r3/lib/trace.r3

#master_volume 1.0
#dt			| 2^32/aurate
#dte			| 2^47/aurate (envelope)

|------------------- VOICES
| unidad de sonido 
##voice * 65536		| 1024 voces x 64 bytes exactos ('voice> queda justo al final)
##voice> 'voice

:resetvoices
	'voice 'voice> ! ;

:c.state	a> ;		| state
:c.id		a> 1 + ;	| id
:c.crv		a> 2 + ;	| curva de envolvente: env^(n+1): 0 lineal, 1 cuadratica, 2 cubica, 3 cuartica (~exponencial)
:d.freq		a> 4 + ;	| inc freq

:q.AD		a> 8 + ;	| ADSR = 2 celdas (v1 v2 de packADSR), incrementos por muestra en 0.31 (1.0=$7fffffff)
:d.Adt		a> 8 + ;	| Attack
:d.Ddt		a> 12 + ;	| Decay

:d.lensam	a> 16 + ;	| 
:d.fresam	a> 20 + ;

:d.time		a> 24 + ;	| time+dt (negativo = retardo antes de sonar)
:d.dtime	a> 28 + ;

:q.func		a> 32 + ;
:q.vec		a> 40 + ;
:d.vel		a> 48 + ;	| ganancia de la voz (16.16)
:d.env		a> 52 + ;	| envelope actual (0.31, 1.0=$7fffffff)
:q.SR		a> 56 + ;
:d.Sus		a> 56 + ;	| Sustain (nivel 0.31)
:d.Rdt		a> 60 + ;	| Release

:newvoice | -- nv
	voice> 'voice> >=? ( drop 0 ; )
	64 'voice> +! ;
	
:delvoice | nv --
	-64 'voice> +! voice> 8 move ;

:delvoicea | --
	-64 'voice> +! a> voice> 8 move -64 a+ ;

|---- OSC
| time -- val
::oscSaw	2* 1.0 - ;
::oscSqr	0.5 >? ( -1.0 nip ; ) 1.0 nip ; 
::oscPul1	0.1 >? ( -1.0 nip ; ) 1.0 nip ; 
::oscPul2	0.25 >? ( -1.0 nip ; ) 1.0 nip ; 
::oscTri	$8000 and? ( $ffff xor ) 2 << 1.0 - ; 
::oscSin	sin ;
::oscHSin	sin abs ;
::oscSin2	sin dup *. ;
::oscSin3	sin dup dup *. *. ;
::oscSinF	2* 1.0 - dup *. 2* 1.0 - ;
::oscSawRev	1.0 swap - 2* 1.0 - ;
::oscTrap	0.25 <? ( 2 << ) 0.75 >? ( 2 << 4.0 - ) 2* 1.0 - ;
::oscParab	dup *. 2* 1.0 - ;

::oscFakeSuperSaw | phase -- v
	dup 2* 1.0 - swap dup *. 2* 1.0 - + 2/ ;
	
::oscSuperSaw2P | phase -- v
	2* 1.0 - dup 1.01 *. 2* 1.0 - + 2/ ;

::oscSuperSaw3P | phase -- v
	dup 2* 1.0 -
	swap dup 0.99 *. 2* 1.0 - +
	swap 1.01 *. 2* 1.0 - +
	0.333 *. ;


	
:envelADSR | -- env		| env 16.16 (0..$ffff); negativo = voz terminada
	1 d.time d+!
	c.state c@
	3 =? ( drop d.env d@ 15 >> ; )		| sustain
	1 =? ( drop							| attack
		d.env d@ d.Adt d@ +
		$7fffffff <? ( dup d.env d! 15 >> ; )
		$7fffffff nip dup d.env d! 2 c.state c! 15 >> ; )
	2 =? ( drop							| decay
		d.env d@ d.Ddt d@ -
		d.Sus d@ >? ( dup d.env d! 15 >> ; )
		drop d.Sus d@ dup d.env d! 3 c.state c! 15 >> ; )
	drop									| release (negativo = voz terminada, la borra playosc/playnoise/playsam)
	d.env d@ d.Rdt d@ -
	-? ( ; )
	dup d.env d! 15 >> ;

:delaying | -- 0/1		| retardo previo (sample-accurate): silencio mientras time < 0
	d.time d@ -? ( 1+ d.time d! 1 ; ) drop 0 ;

:shape | env -- env'
	c.crv c@ 0? ( drop ; )
	1 =? ( drop dup *. ; )
	2 =? ( drop dup dup *. *. ; )
	drop dup *. dup *. ;

:out | env osc -- v		| senial * envelope(curva) * ganancia de la voz
	swap shape swap *. d.vel d@ *. ;

:playosc	| -- v
	delaying 1? ( drop 0 ; ) drop
	envelADSR -? ( 0 nip delvoicea ; ) 
	
	d.time d@ d.dtime d@ >? ( 4 c.state c! )
	d.freq d@ *. $ffff and
	q.func @ ex |oscSin | ciclo
	
	out ;

|--- supersaw: 7 osciladores desafinados (detune simetrico), fase = time*freq_i + offset_i
|    d.lensam = detune (16.16, fraccion de freq del oscilador extremo), d.fresam = freq*detune (0.32)
#sstab				| detune_i (16.16, -1..1) | fase inicial_i (16 bits, secuencia aurea)
-65536 0  -43691 40503  -21845 15471  0 55974  21845 30942  43691 5909  65536 46413

:osc1 | time i -- v
	4 << 'sstab +					| time adr
	@+ d.fresam d@ *. d.freq d@ +	| time adr' freq_i
	pick2 *.						| time adr' fase
	swap @ + $ffff and nip		| fase
	q.func @ ex ;

:supersum | time -- sum
	0 7 ( 1? 1-					| time acc i
		pick2 over osc1			| time acc i v
		rot + swap )				| time acc' i
	drop nip ;

:playsuper	| -- v
	delaying 1? ( drop 0 ; ) drop
	envelADSR -? ( 0 nip delvoicea ; )
	d.time d@ d.dtime d@ >? ( 4 c.state c! )
	supersum 26214 *.				| 0.4: ~1/raiz(7), parejo en volumen con un osc simple
	out ;

|--- oscilador con pitch slide: fase acumulada (d.fresam) e incremento (d.freq) que
|    cambia cada muestra en forma exponencial; d.lensam = delta (0.32) por muestra
:playsweep	| -- v
	delaying 1? ( drop 0 ; ) drop
	envelADSR -? ( 0 nip delvoicea ; ) 
	d.time d@ d.dtime d@ >? ( 4 c.state c! ) drop
	d.freq d@ dup d.lensam d@ * 32 >> + 0 max
	dup d.freq d!
	d.fresam d@ + dup d.fresam d!
	16 >> $ffff and
	q.func @ ex out ;

:playnoise
	delaying 1? ( drop 0 ; ) drop
	envelADSR -? ( 0 nip delvoicea ; ) 
	
	d.time d@ d.dtime d@ >? ( 4 c.state c! )
	drop
	q.func @ ex | noise sin ciclo |	fbrown 
	out ;

:interpolate | scr sample -- value
	w@+ swap 2 + w@	| src v0 v1 | 2 + stereo!
	rot $ffff and 	| v1 v0 p
	rot pick2 - *. + ;

:playsam
	delaying 1? ( drop 0 ; ) drop
	envelADSR -? ( 0 nip delvoicea ; )
	
	d.time d@ d.dtime d@ >? ( 4 c.state c! )
	d.fresam d@ *
	d.lensam d@ 1- 16 << >=? ( 2drop 0 delvoicea ; )	| 1-: interpolate lee el frame siguiente
	
| sin interpolacion
|	16 >> 2 << q.func @ + w@ 

| interpolacion 
	dup 16 >> 2 << q.func @ + interpolate
	
	2* out ; |2.0 *. | w->0--1.0

|------------------- RUN
##aurate 44100 |48000 |
#audevice 
#auspec * 32

::sminit | -- ..
	aurate $8010 2 1024 Mix_OpenAudio | minimal buffer for low latency

	aurate	'auspec 0 + d! |freq
	$8010	'auspec 4 + w! |format: 16-bit signed
	2		'auspec 6 + c! |channels: stereo
	2048	'auspec 8 + w! |samples: 2048 frame buffer
	0		'auspec 16 + ! |callback: null (push mode)

	0 0 'auspec 0 0 SDL_OpenAudioDevice 'audevice !
	audevice 0 SDL_PauseAudioDevice
	
	1.0 16 << aurate / 'dt ! 
	1 47 << aurate / 'dte !
	
::smreset
	1.0 'master_volume !
	resetvoices
	;

##outbuffer * 8192 | Final output buffer (16-bit samples)

:genAudio | genera audio
	'outbuffer >b
	2048 ( 1? 1-

		0	| mix
		'voice ( voice> <? >a
			q.vec @ ex |playosc 
			| d.vel d@ *.	| VOLUME por voice
			+ a> 64 + ) drop

		2/ | shift 
		master_volume *.
		fastanh. 2/ clamps16 $ffff and	| fastanh. puede pasar de 1.0 con muchas voces
		
		dup 16 << or       | to stereo
		db!+
		) drop 
	;	


##smtick 0				| hook: 'palabra 'smtick ! ; se ejecuta antes de generar cada bloque de 2048 muestras
:runtick smtick 1? ( ex ; ) drop ;

::smmaster! | v --		| volumen general 0..1.0
	'master_volume ! ;

::smupdate | Queue audio
	audevice SDL_GetQueuedAudioSize 8192 >=? ( drop ; ) drop | Buffer full
	runtick
	genAudio
	audevice 'outbuffer 8192 SDL_QueueAudio 
	;
	

|------------------- INSTRUMENTS

#instr * $2000		| 128 instrumentos x 64 bytes
#instr> 'instr

#ins_vector playosc
#ins_wave oscSin |oscTri |'oscSin
#ins_ADSR 0 
#ins_ADSR2 0
#ins_aux
#ins_vel 1.0
#ins_crv 0

| ADSR en 2 celdas (v1 v2); iosc/inoise/isweep/isample/smASDR! las consumen tal cual
|  v1 = Attack | Decay<<32     v2 = Sustain | Release<<32      (campos de 32 bits, incremento por muestra 0.31)
| A,D,R: segundos, 1 muestra .. horas, sin escalon | S: 0..1.0
:tinc | seg -- inc
	0? ( 1+ ) dte swap / 0? ( 1+ ) $7fffffff min ;

::packADSR | A D S R -- v1 v2
	tinc 32 << swap 15 << $7fffffff min or	| A D v2
	swap tinc 32 << rot tinc or				| v2 v1
	swap ;

|--- MAKE INSTRUMENT

:ninstr
	instr> 'instr - 6 >> 1- ;	| slot: vec wave ADSR1 ADSR2 aux (64 bytes)
	
:ireset
	'instr 'instr> ! ;

#nochunk 0 0 0	| chunk vacio (abuf=0,alen=0): si falla la carga la voz termina al instante

:iadsr | v1 v2 --			| ADSR (2 celdas) al instrumento
	swap a!+ a!+ ;

:iend | aux -- n			| aux y salta al proximo slot
	a!+ 24 a+ a> 'instr> ! ninstr ;

::iosc | v1 v2 osc -- n
	instr> >a
	'playosc a!+
	a!+ iadsr 0 iend ;

::inoise | v1 v2 noise -- n
	instr> >a
	'playnoise a!+
	a!+ iadsr 0 iend ;

::isweep | v1 v2 osc -- n		| oscilador con pitch slide (ver smslide!)
	instr> >a
	'playsweep a!+
	a!+ iadsr 0 iend ;

::isuper | v1 v2 osc detune -- n	| supersaw: detune = fraccion de freq (0.01 = 1%) del osc extremo
	instr> >a
	'playsuper a!+
	swap a!+ >r iadsr r> iend ;

::isample | v1 v2 "" -- n
	instr> >a
	'playsam a!+
	mix_loadWAV 0? ( drop 'nochunk )
	dup 8 + @ a!+ 		| sample
	-rot iadsr
	16 + d@ 2 >> iend ;	| len sample

|---- SET INSTRUMENT
::smi! | n --
	6 << 'instr +
	@+ 'ins_vector !
	@+ 'ins_wave !
	@+ 'ins_ADSR !
	@+ 'ins_ADSR2 !
	@ 'ins_aux !
	1.0 'ins_vel ! 0 'ins_crv !	| se ajustan despues de smi! (smslide! smvel! smcurve!)
	;

::smslide! | oct/s --		| slide (octavas por segundo, +sube -baja) para el proximo smplayd; despues de smi!
	dt 45426 *. *. 'ins_aux ! ;

::smvel! | v --			| ganancia (16.16) de las proximas voces; despues de smi!
	'ins_vel ! ;

::smcurve! | n --		| curva de envolvente 0 lineal .. 3 cuartica (~exp); despues de smi!
	'ins_crv ! ;

::smdetune! | v --		| detune (16.16) de las proximas voces supersaw; despues de smi!
	'ins_aux ! ;

::smOSC! | osc n --
	6 << 'instr + 8 + ! ;
	
::smASDR! | v1 v2 n --
	6 << 'instr + 16 + rot over ! 8 + ! ;
	
::fx
::control
	
|---- PLAY INSTRUMENT
|inc_sample=(fr_deseada<<32)/fr_base
|inc_osc=(fr_desada<<32>/aurate

:midi_to_freq | note -- freq
	69 - fix. 12 / pow2. 440.0 *. ;

|inc_sample=(fr_deseada<<32)/fr_base
|inc_osc=(fr_desada<<32>/aurate

::smplayhz | hz time --		| frecuencia en Hz (16.16), duracion en segundos (16.16)
	newvoice 0? ( 3drop ; ) | No free voices|
	>a | Save voice index

	aurate *. 32 << d.time !
	
	16 <<
	dup 440.0 / d.fresam d! | para sample base 440
	aurate / d.freq d!	| para oscilador

	ins_vector q.vec !
	ins_wave q.func !
	ins_ADSR q.AD !
	ins_ADSR2 q.SR !
	ins_aux d.lensam d!
	ins_vel d.vel d!
	ins_crv c.crv c!
	ins_vector 'playsweep =? ( 0 d.fresam d! )
	'playsuper =? ( d.freq d@ d.lensam d@ *. d.fresam d! ) drop
	
	1 c.state w!					| state=1, id=0 (voz sin id: smplay lo asigna despues)
	0 d.env d!
	;

::smplayd | note time --
	swap midi_to_freq swap smplayhz ;

#sdelay
::smplayhzat | hz time delay --	| como smplayhz pero empieza 'delay' muestras despues
	'sdelay !
	voice> >r
	smplayhz
	voice> r> =? ( drop ; ) drop
	sdelay neg voice> 64 - 24 + d! ;

::smplayat | note time delay --	| como smplayd pero empieza 'delay' muestras despues
	>r swap midi_to_freq swap r> smplayhzat ;

#nnote 1

:idused? | id -- 0/1		| algun voz (incluso en release) tiene este id?
	'voice ( voice> <?
		dup 1+ c@ $ff and
		pick2 =? ( 3drop 1 ; )
		drop 64 + ) 2drop 0 ;

:nextid | -- id/0			| proximo id 1..255 libre (0 = todos en uso)
	255 ( 1? 1-
		nnote 1+ $ff and 0? ( 1+ ) dup 'nnote !
		idused? 0? ( 2drop nnote ; ) drop
		) drop 0 ;

::smplay | nota -- id		| id=0 si no hay voces libres o ids agotados
	nextid 0? ( nip ; )
	swap voice> >r
	$7fffffff smplayd
	voice> r> =? ( 2drop 0 ; ) drop
	dup c.id c! ;				| c! (antes ! escribia 8 bytes y pisaba freq/vol/ADSR)
	
::smstop | id --
	$ff and 0? ( drop ; )		| 0 = voz sin id
	'voice ( voice> <? 	| Find voice playing this note
		dup 1+ c@ $ff and	| id de la voz (antes se comparaba la DIRECCION)
		pick2 =? ( drop 
			4 over w!		| release + libera el id (state=4, id=0)
			2drop ; )
		drop
		64 + ) 2drop ;
