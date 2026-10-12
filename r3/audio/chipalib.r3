| chipalib.r3 - instrumento con parametros + musica en mini-notacion Strudel (sin interfaz)
| PHREDA 2026
|
| Es el motor de chipa.r3 sin GUI: un instrumento con parametros (onda, envolvente, volumen,
| curva, detune) y una melodia en bucle que suena con precision de muestra, igual que las
| melodias de gamesfx (supermix: smtick + smplayhzat), sin depender de los cuadros por segundo.
| La sintaxis de los patrones esta en eval.r3.
|
| API
|   cpinit                 SDL audio + supermix + instrumento        (cpinit0: la app ya inicio SDL)
|   cpupdate               llamar una vez por cuadro
|   "patron" bpm cpplay    arranca la musica en bucle; si ya suena, el patron nuevo entra en el
|                          proximo ciclo y sigue el compas (live coding)
|   cpstop                 corta la musica
|   bpm cpbpm              cambia el tempo (pulsos por minuto; un ciclo = 4 pulsos)
|   cpapply                aplica los parametros de abajo: llamar despues de cambiarlos
|   midi cpnoteon  midi cpnoteoff     nota sostenida con el mismo instrumento (teclado)
|   cpplaying -- 0/1       cpcycle -- n
|
| PARAMETROS (variables: cambiar y llamar cpapply; valen desde la proxima nota)
|   cp_wave               onda 0..cpnwaves-1; nombres en cp_wnames (lista para uiCombo)
|   cp_a cp_d cp_s cp_r   envolvente: ataque y decaimiento (s), sostenido (0..1), release (s)
|   cp_vol cp_crv         volumen (1.0) y curva de la envolvente (0 lineal .. 3 cuartica)
|   cp_detune             detune de SuperSaw: fraccion de la frecuencia (0.01 = 1%)
|
| Dentro del instrumento hay tres tipos de voz de supermix: onda (iosc), supersaw real con
| 7 osciladores desafinados (isuper) y ruido (inoise); cp_wave elige cual suena.

^./gamesfx.r3

##cp_wave 0
##cp_a 0.002 ##cp_d 0.05 ##cp_s 0.8 ##cp_r 0.1
##cp_vol 1.0 ##cp_crv 0 ##cp_detune 0.01
##cpnwaves 20
##cp_wnames "Sqr" "Saw" "Sin" "Tri" "Pul25" "Pul10" "SawRev" "SinFold" "Trap" "HSin" "Sin2" "Sin3" "Parab" "FSaw" "SSaw2" "SSaw3" "SuperSaw" "White" "Pink" "Brown" 0

| tipo de voz (0 onda, 1 supersaw, 2 ruido) y funcion, uno por cada nombre
#cp_wtab
0 'oscSqr 0 'oscSaw 0 'oscSin 0 'oscTri 0 'oscPul2 0 'oscPul1 0 'oscSawRev 0 'oscSinF 0 'oscTrap 0 'oscHSin
0 'oscSin2 0 'oscSin3 0 'oscParab 0 'oscFakeSuperSaw 0 'oscSuperSaw2P 0 'oscSuperSaw3P
1 'oscSaw 2 'wnoise 2 'pnoise1 2 'bnoise

#cp_io #cp_is #cp_in		| instrumentos: onda | supersaw | ruido
##cp_ins 0				| el que suena ahora
#cp_id -1				| melodia en curso

:cpadsr | -- v1 v2
	cp_a cp_d cp_s cp_r packADSR ;

:cpset | n --			| envolvente al instrumento n
	cpadsr rot smASDR! ;

:cpwave | --			| instrumento y funcion segun cp_wave
	cp_wave 0 max cpnwaves 1- min 4 << 'cp_wtab +
	@+ swap @ swap		| fn tipo
	0 =? ( drop cp_io smOSC! cp_io 'cp_ins ! ; )
	1 =? ( drop cp_is smOSC! cp_detune cp_is smAUX! cp_is 'cp_ins ! ; )
	drop cp_in smOSC! cp_in 'cp_ins ! ;

::cpapply | --
	cp_io cpset  cp_is cpset  cp_in cpset
	cpwave
	cp_id cp_ins sfxtuneins
	cp_id cp_vol cp_crv sfxtunemix drop ;

::cpinit0 | --			| igual que cpinit sin SDL_Init
	sfxinit0
	cpadsr 'oscSin iosc 'cp_io !
	cpadsr 'oscSaw cp_detune isuper 'cp_is !
	cpadsr 'wnoise inoise 'cp_in !
	cpapply ;

::cpinit | --
	$10 SDL_Init cpinit0 ;

::cpupdate | --
	sfxupdate ;

::cpplaying | -- 0/1
	cp_id sfxtuneplaying ;

::cpcycle | -- n
	cp_id sfxtunecycle ;

::cpbpm | bpm --
	cp_id swap sfxtunebpm ;

::cpplay | "patron" bpm --
	cpplaying 1? ( drop
		cp_id swap sfxtunebpm
		cp_id swap sfxtunetext ; ) drop
	cp_ins 1 sfxtune dup 'cp_id !
	cp_vol cp_crv sfxtunemix drop ;

::cpstop | --
	cp_id sfxtunestop -1 'cp_id ! ;

|--- notas sostenidas (teclado): el id de la voz se guarda por nota
#cp_pn * 128

:cpnon | midi --
	'cp_pn + dup c@ 1? ( 2drop ; ) drop
	cp_ins smi!  cp_vol smvel!  cp_crv smcurve!
	dup 'cp_pn - smplay swap c! ;

::cpnoteon | midi --
	ab[ cpnon ]ba ;

:cpnoff | midi --
	'cp_pn + dup c@ 0? ( 2drop ; )
	smstop 0 swap c! ;

::cpnoteoff | midi --
	ab[ cpnoff ]ba ;
