| r3synth
| PHREDA 2025

^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3
^r3/util/immi.r3

#font1

| Osciladores
#osc_waveforms1 0 0
#osc_ranges1 
#osc_waveforms2 0 0
#osc_ranges2 
#osc_waveforms3 0 0
#osc_ranges3
#osc_detune
| Mixer
#osc_mix1 #osc_mix2 #osc_mix3
#noise_mix
| Filtro Moog
#cutoff
#resonance
#contour_amount
#keyboard_tracking
| Envelopes
#amp_attack #amp_decay #amp_sustain #amp_release
#fil_attack #fil_decay #fil_sustain #fil_release
| LFO
#lfo_rate
#lfo_phase
| Modulación
#mod_wheel
#mod_mix
| Master
#master_volume
#a440_tune


| VOICE
| id as es x | xx | vel 
| ph1 ph2 ph3 xx
| ae fe [freq] 
| b1 b2 
| b3 b4 
:b.id	; | byte
:b.amp_state 1 + ; |byte
:b.fil_state 2 + ; |byte 
:d.vel 4 + ; | dword
:w.phase1 8 + ; |word
:w.phase2 10 + ; |word
:w.phase3 12 + ; |word
:w.amp_env 16 + ; |word
:w.fil_env 18 + ; |word
:d.freq 20 + ; |dword
:d.f_buff0 24 + ; |word*4
:d.f_buff1 28 + ; |word*4
:d.f_buff2 32 + ; |word*4
:d.f_buff3 36 + ; |word*4
	

#voice * $fff
#voice> 'voice

:resetvoices
	'voice 'voice> ! ;
	
:newvoice | -- nv
	voice> 'voice> >=? ( drop 0 ; )
	40 'voice> +! ;
	
:delvoice | nv --
	-40 'voice> +! voice> 5 move ;

|--------------------------------
:resetsynte
	2 'osc_waveforms1 !
	2 'osc_waveforms2 !
	1 'osc_waveforms3 !
	0 'osc_ranges1 !
	0 'osc_ranges2 !
	-1.0 'osc_ranges3 !
	0 'osc_detune !
| Mixer
	1.0 'osc_mix1 !
	0.8 'osc_mix2 !
	0.3 'osc_mix3 !
	0.0 'noise_mix !
| Filtro
	0.6 'cutoff !
	2.0 'resonance !
	0.5 'contour_amount !
	0.33 'keyboard_tracking !
| Envelopes
	0.005 'amp_attack !
	0.1 'amp_decay !
	0.7 'amp_sustain !
	0.3 'amp_release !
	0.02 'fil_attack !
	0.5 'fil_decay !
	0.4 'fil_sustain !
	0.5 'fil_release !
| LFO
	5.0 'lfo_rate !
	0.0 'lfo_phase !
| Modulación
	0.0 'mod_wheel !
	0.5 'mod_mix !
| Master
	0.4 'master_volume !
	1.0 'a440_tune !
	;

| phase -- val	
:oscSaw		2* 1.0 - ;
:oscSqr		0.5 >? ( 1.0 nip ; ) -1.0 nip ; 
:oscTri		0.5 <? ( 2 << 1.0 - ; ) 3.0 swap 2 << - ;
:oscSin		2* sin ;

#vecwave 'oscSaw 'oscSqr 'oscTri 'oscSin

:get_osc_sample | phase type -- val
	$3 and 3 << 'vecwave + @ ex ;


:clamp | v min max - vv
	pick2 <? ( nip nip ; ) drop 
	over >? ( nip ; ) drop ;
	
:moog_ladder_filter | input curoff -- val
	a> d.f_buff3 d@ 2 << resonance *. | input cut feed
	rot swap - fastanh.			| cut val
	a> d.f_buff0 d@ - over *. a> d.f_buff0 d+! 
	a> d.f_buff0 d@ a> d.f_buff1 d@ - over *. a> d.f_buff1 d+!
	a> d.f_buff1 d@ a> d.f_buff2 d@ - over *. a> d.f_buff2 d+!
	a> d.f_buff2 d@ a> d.f_buff3 d@ - *. a> d.f_buff3 d+!
	a> d.f_buff3 d@
	;

#aattrt
#adecrt
#arelrt
#fattrt
#fdecrt
#frelrt

#dt

#listwave "Saw" "Square" "Triangle" "Sin" 0
#vwave 0 0 

:calcvar
	dt amp_attack /. 'aattrt !
	dt amp_decay /. 'adecrt !
	dt amp_release /. 'arelrt !
	dt fil_attack /. 'fattrt !
	dt fil_decay /. 'fdecrt !
	dt fil_release /. 'frelrt !
	;

:aenvelope | -- 
	a> b.amp_state c@
	1 =? ( drop | attack
		aattrt +
		1.0 <? ( ; ) 1.0 nip
		2 a> b.amp_state c!
		; )
	2 =? ( drop | decay
		adecrt -
		amp_sustain >? ( ; ) amp_sustain nip
		3 a> b.amp_state c!
		; )
	3 =? ( drop ; ) |sustain
	drop | release
	arelrt -
	0 >? ( ; ) 0.0 nip 
	0 a> b.amp_state c! ;
	

:fenvelope | level -- level
	a> b.fil_state c@
	1 =? ( drop | attack
		fattrt +
		1.0 <? ( ; ) 1.0 nip
		2 a> b.fil_state c!
		; )
	2 =? ( drop | decay
		fdecrt -
		fil_sustain >? ( ; ) fil_sustain nip
		3 a> b.fil_state c!
		; )
	3 =? ( drop ; ) |sustain
	drop | release
	frelrt -
	0 >? ( ; ) 0.0 nip 
	0 a> b.fil_state c! ;
	

|#lfo_val
#mod_signal 
	
:mixVoice | voice -- sample
	dup b.amp_state c@ 0? ( swap delvoice ; ) drop | v.state=0
	>a
	0
	a> d.freq d@ 2.0 osc_ranges1 pow. *.
	mod_signal 0.05 *. 1.0 + *.
	dt *.
	a> w.phase1 w+!
	a> w.phase1 w@ osc_waveforms1 get_osc_sample
	osc_mix1 *. +

	a> d.freq d@ 2.0 osc_ranges2 pow. *.
	osc_detune 1.0 + *.
	mod_signal 0.05 *. 1.0 + *.
	dt *.
	a> w.phase2 w+!
	a> w.phase2 w@ osc_waveforms2 get_osc_sample
	osc_mix2 *. +

	a> d.freq d@ 2.0 osc_ranges3 pow. *.
	osc_detune 2/ neg 1.0 + *.
	mod_signal 0.05 *. 1.0 + *.
	dt *.
	a> w.phase3 w+!
	a> w.phase3 w@ osc_waveforms3 get_osc_sample
	osc_mix3 *. +
	
	|$ffff randmax noise_mix *. +
	
	0.33 *.
	a> w.amp_env w@ aenvelope a> w.amp_env w!
	a> w.fil_env w@ fenvelope a> w.fil_env w!
	
	cutoff
	a> w.fil_env w@ contour_amount *. 2/ +
	mod_signal 2* +
	0 0.99 clamp
	|| input reso cutoff -- val
	moog_ladder_filter
	
	a> w.amp_env w@  *.
	a> d.vel d@ *.
	
	;

#outbuffer * 8192 | Final output buffer (16-bit samples)
	
:genaudio
	calcvar
	'outbuffer >b
	2048 ( 1? 1-
	
		lfo_phase lfo_rate dt *. +
		$ffff and 
		dup 'lfo_phase !
		|'lfo_val !
		mod_wheel *. mod_mix *. 'mod_signal !
				
		0 | mix voice
		'voice ( voice> <?
			dup MixVoice rot + | mix+
			swap 40 + ) drop


		master_volume *.
		fastanh. | -1.0..1.00 
		2/ -32768 max 32767 min | Clamp to 16-bit range

		$ffff and
		dup 16 << or       | Duplicate to both channels
		db!+
		) drop ;
	

|----------------------

:midi_to_freq | note -- freq
	2.0 swap fix. 12 / pow.
	440.0 *.
	a440_tune *.
	dup "%f" .println
	;

:note_on | noteid note velocity --
	newvoice 0? ( 4drop ; ) | No free voices|
	>a | Save voice index

	a> d.vel d!
	midi_to_freq a> d.freq d!
	a> b.id c!

	1 a> b.amp_state c!
	1 a> b.fil_state c!
	0 a> w.amp_env w!
	0 a> w.fil_env w!
	;

:note_off | noteid --
	'voice ( voice> <? 	| Find voice playing this note
		dup b.id c@
		pick2 =? ( drop 
			4 over b.amp_state c!
			4 over b.fil_state c!
			2drop ;	)
		drop
		40 + ) 2drop ;

|--------------------------------	
:drawbuffer
	$ffffff sdlcolor
	'outbuffer >a 
	0 ( cw <? 1+
		da@+ 
		over cx +
		over $7fff + 10 >> $3f and cy + SDLPoint
		over cx +
		swap 16 >> $7fff + 10 >> $3f and cy + ch 2/ + SDLPoint
		) drop ;
		
|-----------------------------------------
| Keyboard Interface
#keyw ( 0 2 4 5 7 9 11 12 14 16 17 19 21 23 	-1 )
#keyb (  1 3 0 6 8 10 0  13 15 0  18 20 22 		-1 )
#playn * 100 | Key press state for visual feedback

:colork
	dup 'playn + c@ 
	0? ( $fefefe nip ; )
	$7cd9e9 nip ;
	
:pressk | n x y --
	pick2 'playn + c@ 
	1? ( drop ; ) drop
	$808080 sdlcolor
	over 1+ over 96 +
	30 4 sdlFRect ;

:wkey | n --
	colork sdlcolor
	over 'keyw -
	5 << cx + cy
	2dup 32 100 sdlFRect
	pressk
	$0 sdlcolor
	32 100 sdlRect
	drop ;

:colork
	dup 'playn + c@ 
	0? ( $404040 nip ; )
	$e4bed3 nip ;
	
:pressk | n x y --
	pick2 'playn + c@ 
	1? ( drop ; ) drop
	$0 sdlcolor
	over 1+ over 46 +
	30 4 sdlFRect ;

:bkey | n --
	0? ( drop ; )
	colork sdlcolor
	over 'keyb - 
	5 << 16 + cx + cy 
	2dup 30 50 sdlFRect
	pressk
	$0 sdlcolor
	30 50 sdlRect
	drop ;

:drawkeys
	'keyw ( c@+ +? wkey ) 2drop
	'keyb ( c@+ +? bkey ) 2drop
	;
		
|-----------------------------------------
#nnote 1

:playdn | note --
	dup 'playn + c@ 1? ( 2drop ; ) drop 
	nnote 1+ $ff and 0? ( 1+ ) dup 'nnote !
	over 1.0 note_on
	nnote swap 'playn + c! ;

:playup | note --
	dup 'playn + c@ 0? ( 2drop ; )
	note_off  
	0 swap 'playn + c! ;

:upkeys
	>esc< =? ( exit )
	>q< =? ( 0 playup ) >2< =? ( 1 playup )
	>w< =? ( 2 playup ) >3< =? ( 3 playup )
	>e< =? ( 4 playup ) 
	>r< =? ( 5 playup ) >5< =? ( 6 playup ) 
	>t< =? ( 7 playup ) >6< =? ( 8 playup )
	>y< =? ( 9 playup ) >7< =? ( 10 playup )
	>u< =? ( 11 playup )
	
	>z< =? ( 12 playup ) >s< =? ( 13 playup )
	>x< =? ( 14 playup ) >d< =? ( 15 playup )
	>c< =? ( 16 playup )
	>v< =? ( 17 playup ) >g< =? ( 18 playup )
	>b< =? ( 19 playup ) >h< =? ( 20 playup )
	>n< =? ( 21 playup ) >j< =? ( 22 playup )
	>m< =? ( 23 playup )
	drop ;
	
:keys
	SDLkey 0? ( drop ; )
	$1000 and? ( upkeys ; ) | Key release
|	<f1> =? ( 0 set_wave_type ) <f2> =? ( 1 set_wave_type )
|	<f3> =? ( 2 set_wave_type ) <f4> =? ( 3 set_wave_type )
|	<f5> =? ( 4 set_wave_type )
|	<le> =? ( prev_wave_type ) <ri> =? ( next_wave_type )
	<q> =? ( 0 playdn ) <2> =? ( 1 playdn )
	<w> =? ( 2 playdn ) <3> =? ( 3 playdn )
	<e> =? ( 4 playdn ) 
	<r> =? ( 5 playdn ) <5> =? ( 6 playdn ) 
	<t> =? ( 7 playdn ) <6> =? ( 8 playdn )
	<y> =? ( 9 playdn ) <7> =? ( 10 playdn )
	<u> =? ( 11 playdn )
	
	<z> =? ( 12 playdn ) <s> =? ( 13 playdn )
	<x> =? ( 14 playdn ) <d> =? ( 15 playdn )
	<c> =? ( 16 playdn )
	<v> =? ( 17 playdn ) <g> =? ( 18 playdn )
	<b> =? ( 19 playdn ) <h> =? ( 20 playdn )
	<n> =? ( 21 playdn ) <j> =? ( 22 playdn )
	<m> =? ( 23 playdn )
	drop ;

|--------------------------------
| Audio Configuration
#audevice |SDL_AudioDeviceID 
#auspec * 32
#aurate 44100
	

	
:iniaudio
	aurate 'auspec 0 + d! |freq
	$8010 'auspec 4 + w! |format: 16-bit signed
	2 'auspec 6 + c! |channels: stereo
	2048 'auspec 8 + w! |samples: 2048 frame buffer
	0 'auspec 16 + ! |callback: null (push mode)

	0 0 'auspec 0 0 SDL_OpenAudioDevice 'audevice !
	audevice 0 SDL_PauseAudioDevice
	
	1.0 aurate / 'dt ! 
	;	

:qaudio
	audevice SDL_GetQueuedAudioSize 8192 >=? ( drop ; ) drop | Buffer full
	genaudio
	audevice 'outbuffer 8192 SDL_QueueAudio 
	;

		
|--------------------------------
:main
	$0 SDLcls
	font1 txfont
	uiStart
	4 8 uiPading
	$ffffff sdlcolor
	
	0.05 %h uiN "R3Synth " $11 uiText
	
	0.2 %h uiS
	
	uiPush
	0.6 %w uiO |4 uiWRRect
	drawkeys
	
	uiRest |4 uiWRRect
	drawbuffer
	uiPop
	
	0.3 %w uiO |4 uiWRRect
	uiPush
	3 1 uiGrid 
	"OSC 1" uiLabel
	"Range" uiLabel	
	"Mix" uiLabel
	"OSC 2" uiLabel
	"Range" uiLabel	
	"Mix" uiLabel
	"OSC 3" uiLabel
	"Range" uiLabel	
	"Mix" uiLabel
	"detune" uiLabel
	"noise" uiLabel
	1 0 uiAt 2 1 uiTo
	
| Osciladores
	'osc_waveforms1 'listwave uiCombo
	0.0 1.0 'osc_ranges1 uiSliderf
	0.0 1.0 'osc_mix1 uiSliderf	
	'osc_waveforms2 'listwave uiCombo
	0.0 1.0 'osc_ranges2 uiSliderf
	0.0 1.0 'osc_mix2 uiSliderf
	'osc_waveforms3 'listwave uiCombo
	0.0 1.0 'osc_ranges3 uiSliderf
	0.0 1.0 'osc_mix3 uiSliderf
	0.0 1.0 'osc_detune uiSliderf
	0.0 1.0 'noise_mix uiSliderf
	uiPop
	

	0.3 %w uiO |4 uiWRRect
	uiPush
	3 1 uiGrid 
	"Cutoff" uiLabel
	"resonance" uiLabel
	"Contour" uiLabel
	"key" uiLabel
	
	"Attack" uiLabel
	"Decay" uiLabel
	"Sustain" uiLabel
	"Release" uiLabel
	
	"Attack" uiLabel
	"Decay" uiLabel
	"Sustain" uiLabel
	"Release" uiLabel
	
	1 0 uiAt 2 1 uiTo

| Filtro Moog
	0.0 1.0 'cutoff uiSliderf
	0.0 4.0 'resonance uiSliderf
	0.0 1.0 'contour_amount uiSliderf
	0.0 1.0 'keyboard_tracking uiSliderf
| Envelopes
	0.001 2.0 'amp_attack uiSliderf
	0.0 1.0 'amp_decay uiSliderf
	0.0 1.0 'amp_sustain uiSliderf
	0.01 5.0 'amp_release uiSliderf

	0.001 2.0 'fil_attack uiSliderf
	0.0 1.0 'fil_decay uiSliderf
	0.0 1.0 'fil_sustain uiSliderf
	0.01 5.0 'fil_release uiSliderf

	uiPop
	
	0.3 %w uiO |4 uiWRRect
	uiPush
	3 1 uiGrid 

	"Rate" uiLabel
	|"Phase" uiLabel
	"Wheel" uiLabel
	"Mix" uiLabel
	"Master" uiLabel
	"Tune" uiLabel
	1 0 uiAt 2 1 uiTo
| LFO
	0.1 20.0 'lfo_rate uiSliderf
|	0.0 1.0 'lfo_phase uiSliderf
| Modulación
	0.0 1.0 'mod_wheel uiSliderf
	0.0 1.0 'mod_mix uiSliderf
| Master
	0.0 1.0 'master_volume uiSliderf
	-1.0 1.0 'a440_tune uiSliderf

	uiPop

	
	|10 500 txat 'voice ( voice> <? dup d@ "%d " txprint 32 + ) drop 
	
	uiEnd
	SDLredraw
	keys
	qaudio 
	;
	
: |--------------------------------
	"R3Moog" 1024 600 SDLinit
	"media/ttf/Roboto-bold.ttf" 16 txloadwicon 'font1 !
	iniaudio
	resetsynte
	resetvoices
	'main SDLshow
	SDLquit ;