| r3synth
| PHREDA 2025

^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3


|--------------------------------
:_softclip
	0.8 <? ( 
		dup dup 16 *>> over 16 *>> 
		0.185 16 *>> - ; )
	1.6 <? ( 0.8 -
		dup dup 16 *>> 0.05625 16 *>> neg
		swap 0.32599 16 *>> 0.70528 + + ; )
	2.4 <? ( 1.6 -
		dup dup 16 *>> 0.02281 16 *>> neg
		swap 0.08625 16 *>> 0.92167 + + ; )
	2.4 -
	0.02722 16 *>> 0.98367 +
	|1.0 <? ( ; ) 1.0 nip 
	;
	
:soft_clip
	-? ( neg _softclip neg ; ) _softclip ;
	
| phase width -- val	
:oscSaw		drop 2* 1.0 - ;
:oscSqr		>? ( 1.0 ; ) -1.0 ; 
:oscTri		drop 0.5 <? ( 2 << 1.0 - ; ) 3.0 swap 2 << - ;
:oscSin		drop 2* sin ;

|-----------------------------------------
| ENV_IDLE, ENV_ATTACK, ENV_DECAY, ENV_SUSTAIN, ENV_RELEASE 
| WAVE_SAW, WAVE_SQUARE, WAVE_TRIANGLE, WAVE_SINE } Waveform
| FILTER_LP, FILTER_HP, FILTER_BP } FilterMode

#cutoff
#resonance
#master_vol
#current_wave 'oscSin | <<
#detune
#pulse_width
#lfo_freq #lfo_amount #lfo_phase
#delay_write_index #delay_feedback #delay_time_sec 
#attack_time #decay_time #sustain_level #release_time
#filter_mode #filter_env_amount
#osc_mix #lfo2_freq #lfo2_amount #lfo2_phase
#portamento_time
#drive_amount
#pan
#unison_detune #unison_voices
#pitch_bend_range
#mod_wheel_value
| SUB-OSCILLATOR
#sub_osc_level #sub_osc_octave
| SAMPLE & HOLD
#sh_freq #sh_phase #sh_value #sh_amount #sh_target

#delay_buffer * $ffff

:reset
	0.4 'master_vol !
	0.5 'cutoff !
	2.0 'resonance !
	'oscSin 'current_wave !
	0.005 'detune !
	0.5 'pulse_width !
	2.0 'lfo_freq ! 0.0 'lfo_amount ! 0.0 'lfo_phase !
	0 'delay_write_index ! 0.4 'delay_feedback ! 0.3 'delay_time_sec !
	
	0.02 'attack_time ! 0.2 'decay_time ! 0.5 'sustain_level ! 0.4 'release_time !
	
	0 'filter_mode ! 0.5 'filter_env_amount !
	0.5 'osc_mix ! 0.5 'lfo2_freq ! 0.0 'lfo2_amount ! 0.0 'lfo2_phase !
	0.0 'portamento_time !
	0.0 'drive_amount !
	0.5 'pan !
	0.1 'unison_detune ! 1 'unison_voices !
	2.0 'pitch_bend_range !
	0.0 'mod_wheel_value !
| SUB-OSCILLATOR
	0.0 'sub_osc_level ! -1 'sub_osc_octave ! | Una octava abajo
| SAMPLE & HOLD	
	10.0 'sh_freq ! 0.0 'sh_phase ! 0.0 'sh_value ! 0.0 'sh_amount ! 0 'sh_target !

	'delay_buffer 0 $ffff cfill
	;


| VOICE
::dcell+ 2 << + ;

:v.state 0 dcell+ ; | active-state
:v.freq 1 dcell+ ;
:v.note_id 2 dcell+ ;
:v.velocity 3 dcell+ ;
:v.phase1 4 dcell+ ; 
:v.phase2 5 dcell+ ; 
:v.sub_phase 6 dcell+ ; 
:v.env_level 7 dcell+ ; 

#max_voices 16

#voice * $1ff | 4 * 8 * 16 (voices)
#voice> 'voice

:resetvoices
	'voice 'voice> ! ;
	
:newvoice | -- nv
	voice> 'voice> >=? ( drop 0 ; )
	32 'voice> +! ;
	
:delvoice | nv --
	dup 32 + dup voice> - 3 >> move   | dsc
	-32 'voice> +! ;

| Audio Configuration
#audevice |SDL_AudioDeviceID 
#auspec * 32
#aurate 44100
	
#outbuffer * 8192 | Final output buffer (16-bit samples)
	
:iniaudio
	aurate 'auspec 0 + d! |freq
	$8010 'auspec 4 + w! |format: 16-bit signed
	2 'auspec 6 + c! |channels: stereo
	2048 'auspec 8 + w! |samples: 2048 frame buffer
	0 'auspec 16 + ! |callback: null (push mode)

	0 0 'auspec 0 0 SDL_OpenAudioDevice 'audevice !
	audevice 0 SDL_PauseAudioDevice
	;	

| ENV_IDLE, ENV_ATTACK, ENV_DECAY, ENV_SUSTAIN, ENV_RELEASE 

#attrate
#decrate
#relrate

#dt

:cenvelope
|	1.0 attack_time aurate * /. 'attrate !
|	1.0 decay_time aurate * /. 'decrate !
|	1.0 release_time aurate * /. 'relrate !
	1.0 aurate / 'dt ! 
	dt attack_time /. 'attrate !
	dt decay_time /. 'decrate !
	dt release_time /. 'relrate !
	;
	
:venvelope | level state -- level
	1 =? ( drop | attack
		attrate +
		1.0 >=? (
			1.0 nip
			2 a> v.state d!
			)
		; )
	2 =? ( drop | decay
		decrate -
		sustain_level <=? (
			sustain_level nip
			3 a> v.state d!
			)
		; )
	3 =? ( drop ; ) |sustain
	drop | release
	relrate -
	0 >? ( ; )
	0.0 nip 
	0 a> v.state d!
	;
	
#osc1 #osc2	

:voicecalc | voice -- sample
	dup d@ 0? ( swap delvoice ; ) drop | v.state=0
	>a
	
	a> v.phase1 dup d@ 
	a> v.freq d@ dt *. 
	+ 1.0 >? ( 1.0 - ) | $ffff and
	dup rot d!
	pulse_width current_wave ex 'osc1 !
	
	a> v.phase2 dup d@ 
	a> v.freq d@ dt *. 0.3 *.
	+ 1.0 >? ( 1.0 - ) | $ffff and
	dup rot d!
	pulse_width current_wave ex 'osc2 !
	
	osc1 osc2 +
	
	a> v.state d@
	venvelope
	;
	
	
:genaudio
	cenvelope
	'outbuffer >b
	2048 ( 1? 1-
        | 1. Sample & Hold
|        float sh_mod_filter, sh_mod_pitch, sh_mod_pwm;
|        process_sample_hold(&sh_mod_filter, &sh_mod_pitch, &sh_mod_pwm);
        
        | 2. LFOs
|        float lfo_val, lfo2_val;
|        process_lfos(&lfo_val, &lfo2_val);
        
|        float current_cutoff = clamp(params.cutoff + lfo_val * params.lfo_amount * 0.3f + sh_mod_filter, 0.05f, 0.95f);
|        float current_pwm = clamp(params.pulse_width + sh_mod_pwm, 0.1f, 0.9f);

        | 3. voices
        
		0 |float mix = 0.0f;
		'voice ( voice> <?
			dup voicecalc rot +
			swap 32 + ) drop
			|(&voices[v], current_cutoff, current_pwm, lfo2_val, sh_mod_pitch, velocity_factor);

        | 4. Delay
|        float delayed_sample = process_delay(mix);
|        float final_output = mix + delayed_sample * 0.4f;

        | 5. write

		soft_clip 
		-32768 max 32767 min | Clamp to 16-bit range
		dup 16 << or       | Duplicate to both channels
		db!+
		) drop ;
	
:qaudio
	audevice SDL_GetQueuedAudioSize 8192 >=? ( drop ; ) drop | Buffer full
	genaudio
	audevice 'outbuffer 8192 SDL_QueueAudio ;
	;
	
|-----------------------------------------------------
#freq_table [
  16.35   17.32   18.35   19.45   20.60   21.83   23.12   24.50   25.96   27.50   29.14   30.87 |C0-B0
  32.70   34.65   36.71   38.89   41.20   43.65   46.25   49.00   51.91   55.00   58.27   61.74 |C1-B1
  65.41   69.30   73.42   77.78   82.41   87.31   92.50   98.00  103.83  110.00  116.54  123.47 |C2-B2
 130.81  138.59  146.83  155.56  164.81  174.61  185.00  196.00  207.65  220.00  233.08  246.94 |C3-B3
 261.63  277.18  293.66  311.13  329.63  349.23  369.99  392.00  415.30  440.00  466.16  493.88 |C4-B4
 523.25  554.37  587.33  622.25  659.26  698.46  739.99  783.99  830.61  880.00  932.33  987.77 |C5-B5
1046.50 1108.73 1174.66 1244.51 1318.51 1396.91 1479.98 1567.98 1661.22 1760.00 1864.66 1975.53 |C6-B6
2093.00 2217.46 2349.32 2489.02 2637.02 2793.83 2959.96 3135.96 3322.44 3520.00 3729.31 3951.07 |C7-B7
4186.01 4434.92 4698.64 4978.03 5274.00 5587.65 5919.91 6271.93 6644.88 7040.00 7458.62 7902.13 |8
]

:note>freq | note -- freq
	2 << 'freq_table + d@ ;


| Note Management
:note_on | note velocity --
	newvoice 0? ( 3drop ; ) | No free voices|
	>a | Save voice index
	1 a> v.state d! | Attack state
	a> v.velocity d!
	dup a> v.note_id d!
	note>freq a> v.freq d!
	0.0 a> v.phase1 d!
	0.0 a> v.phase2 d!
	0.0 a> v.sub_phase d!
	0.0 a> v.env_level d!
	;


:note_off | note --
	'voice ( voice> <? 	| Find voice playing this note
		dup v.note_id d@
		pick2 =? ( drop 
			4 over v.state d! | state=release
			2drop ;	)
		drop
		32 + ) 2drop ;

|--------------------------------	
:drawbuffer
	$ffffff sdlcolor
	'outbuffer >a 
	0 ( 1024 <? 1+
		da@+ 
		over over $ffff and 9 >> 300 + SDLPoint
		over swap 16 >> $ffff and 9 >> 440 + SDLPoint
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
	over 1 + over 96 +
	30 4 sdlFRect ;

:wkey | n --
	colork sdlcolor
	over 'keyw -
	5 << 0 + 120
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
	over 1 + over 46 +
	30 4 sdlFRect ;

:bkey | n --
	0? ( drop ; )
	colork sdlcolor
	over 'keyb - 
	5 << 16 + 120
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
:playdn | note --
	dup 'playn + c@ 1? ( 2drop ; ) drop |
	dup 40 + 100 note_on | note + middle C, velocity 100
	1 swap 'playn + c! ; | Mark as pressed

:playup | note --
	dup 'playn + c@ 0? ( 2drop ; ) drop 
	dup 40 + note_off  | note + middle C
	0 swap 'playn + c! ; | Mark as released

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
:main
	$0 SDLcls
	10 10 txat "R3Synth" txprint
	
	drawbuffer
	drawkeys

	10 500 txat
	'voice ( voice> <?
		dup d@ "%d " txprint
		32 + ) drop 
	
	SDLredraw
	keys
	qaudio 
	;
	
: |--------------------------------
	"R3 Polyphonic Synthesizer" 1024 600 SDLinit
	"media/ttf/Roboto-bold.ttf" 20 txloadwicon txfont
	iniaudio
	reset
	resetvoices
	'main SDLshow
	SDLquit ;