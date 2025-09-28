| R3 Polyphonic Synthesizer with ADSR Envelopes
| PHREDA 2024 - Enhanced by AI

^r3/lib/sdl2gfx.r3
^r3/lib/sdl2mixer.r3
^r3/lib/rand.r3
^r3/util/varanim.r3
^r3/util/txfont.r3

#ibuffer * $1fff | Visual buffer for waveform display
#wave1 * 8192    | Temporary wave buffer

|-----------------------------------------
| Audio Configuration
#audio_device |SDL_AudioDeviceID 
#audio_spec * 32
#sample_rate 44100

#rel_rate
#sus_level
#dec_rate
#att_rate

:IMS2TICKS 	441.0 /. ;
	
::ADSR! | A D S R -- | ms ms level ms
	1? ( IMS2TICKS ) 'rel_rate !
	'sus_level !
	1? ( IMS2TICKS ) 'dec_rate !
	1? ( IMS2TICKS ) 'att_rate !
	;
	

:debug1
	0.1 0.15 0.7 0.3 ADSR!	
	
	att_rate "att:%f" .println
	dec_rate "dec:%f" .println
	sus_level "sus:%f" .println
	rel_rate "rel:%f" .println
	
	;
	
| value | nota | time |estado	
#value	

::ADSRI
	0 'value ! ;

:att
	swap 1.0 >=? ( 2drop 1.0 1 ; )
	att_rate + swap ;
:dec
	swap sus_level <? ( 2drop sus_level 2 ; )
	dec_rate - swap ;
:sus
	;
:rel
	swap 0 >? ( rel_rate - swap ; )
	2drop 0 4 | delete
	;
	
| state 0-attck 1-decay 2-susta 3-rele
::adsrn | -- value
	value
	dup 32 >> swap $7 and
	0 =? ( att )
	1 =? ( dec )
	2 =? ( sus )
	3 =? ( rel )
	over 32 << or
	'value !
	;
	
:drawdebug
	$ffff00 sdlcolor
	ADSRI
	0 ( 1024 <? 1+
		10 ( 1? 1- ADSRn drop ) drop
		dup 300 ADSRn 255 *. - sdlpoint 
		) drop ;
		
:iniaudio
	sample_rate 'audio_spec 0 + d! |freq
	$8010 'audio_spec 4 + w! |format: 16-bit signed
	2 'audio_spec 6 + c! |channels: stereo
	2048 'audio_spec 8 + w! |samples: 2048 frame buffer
	0 'audio_spec 16 + ! |callback: null (push mode)

	0 0 'audio_spec 0 0 SDL_OpenAudioDevice 'audio_device !
	audio_device 0 SDL_PauseAudioDevice
	;	

|-----------------------------------------
| Frequency Table - Precise musical frequencies
#freq_table
  16.35   17.32   18.35   19.45   20.60   21.83   23.12   24.50   25.96   27.50   29.14   30.87 |C0-B0
  32.70   34.65   36.71   38.89   41.20   43.65   46.25   49.00   51.91   55.00   58.27   61.74 |C1-B1
  65.41   69.30   73.42   77.78   82.41   87.31   92.50   98.00  103.83  110.00  116.54  123.47 |C2-B2
 130.81  138.59  146.83  155.56  164.81  174.61  185.00  196.00  207.65  220.00  233.08  246.94 |C3-B3
 261.63  277.18  293.66  311.13  329.63  349.23  369.99  392.00  415.30  440.00  466.16  493.88 |C4-B4
 523.25  554.37  587.33  622.25  659.26  698.46  739.99  783.99  830.61  880.00  932.33  987.77 |C5-B5
1046.50 1108.73 1174.66 1244.51 1318.51 1396.91 1479.98 1567.98 1661.22 1760.00 1864.66 1975.53 |C6-B6
2093.00 2217.46 2349.32 2489.02 2637.02 2793.83 2959.96 3135.96 3322.44 3520.00 3729.31 3951.07 |C7-B7
4186.01 4434.92 4698.64 4978.03 5274.00 5587.65 5919.91 6271.93 6644.88 7040.00 7458.62 7902.13 |8

:note>freq | note -- freq
	3 << 'freq_table + @ ;

|-----------------------------------------
| Voice Structure (32 bytes per voice)
| Offset 0:  frequency (8 bytes - fixed point)
| Offset 8:  phase (8 bytes - fixed point) 
| Offset 16: envelope_time (8 bytes - fixed point)
| Offset 24: state (1 byte: 0=off, 1=attack, 2=decay, 3=sustain, 4=release)
| Offset 25: note (1 byte: MIDI note number)
| Offset 26: velocity (1 byte: 0-127)


#max_voices 16
#voice * 512  | 16 voices * 32 bytes each
#voice> 'voice

:resetvoice
	'voice 'voice> ! ;
	
:newvoice | -- nv
	voice> 'voice> >=? ( drop 0 ; )
	32 'voice> +! ;
	
:delvoice | nv --
	dup 32 + dup voice> - 3 >> move   | dsc
	-32 'voice> +! ;
	
| ADSR Parameters (fixed point 16.16)
#attack_time   0.1   | 100ms attack
#decay_time    0.15  | 150ms decay  
#sustain_level 0.7   | 70% sustain level
#release_time  0.3   | 300ms release

:.voice_freq ;
:.voice_phase		8 + ;
:.voice_env_time	16 + ;
:.voice_state		24 + ;
:.voice_note		25 + ;
:.voice_velocity	26 + ;

|-----------------------------------------
| ADSR Envelope Generator

:calc_attack | voice -- amplitude
	dup .voice_env_time @
	attack_time /. 
	1.0 min
	1.0 <? ( nip ; ) drop
	2 over .voice_state c! | Move to decay
	0.0 swap .voice_env_time !
	;

:calc_decay | voice_idx -- amplitude  
	dup .voice_env_time @
	decay_time /.
	1.0 min
	1.0 swap - sustain_level *. 
	1.0 swap -
	sustain_level >? ( nip ; ) 
	3 swap .voice_state c! | Move to sustain
	;

:calc_sustain | voice_idx -- amplitude
	drop sustain_level ;

:calc_release | voice_idx -- amplitude
	dup .voice_env_time @
	release_time /. 1.0 min
	1.0 swap -
	sustain_level *.
	0.01 >? ( nip ; ) drop
	0 over .voice_state c! | Turn off
	delvoice
	0.0 ;

:calc_envelope | voice -- amplitude(0.0-1.0)
	dup .voice_state c@
	1 =? ( drop calc_attack ; )
	2 =? ( drop calc_decay ; ) 
	3 =? ( drop calc_sustain ; )
	4 =? ( drop calc_release ; )
	2drop 0.0 ; | Default

|-----------------------------------------
| Wave Types
#wave_type 0  | 0=sine, 1=square, 2=triangle, 3=sawtooth, 4=noise

#wave_names "Sine   " "Square " "Triangl" "Sawtoot" "Noise  " 0

:get_wave_name | wave_type -- str_addr
	3 << 'wave_names + ;

|-----------------------------------------
| Wave Generation Functions
:generate_sine | voice_idx freq --
	2048 ( 1? 1-
		over sample_rate /. | freq_per_sample 
		a@+ over + dup a! | Update and store phase
		sin | Generate sine wave (-1 to 1)
		rot ) 2drop ;

:limsq
	0.5 >? ( 1.0 nip ; ) -1.0 nip ; 
	
:generate_square | voice_idx freq --
	2048 ( 1? 1-
		over sample_rate /. | freq_per_sample (0 to 1)
		a@+ over + 
		1.0 >=? ( 1.0 - ) | Wrap phase
		dup a! | Store updated phase
		limsq | Square wave: >0.5 = high, else low
		rot ) 2drop ;

:limtr
	0.5 <=? ( 4.0 *. 1.0 - ; ) | Rising edge: 0-0.5 -> -1 to 1
	1.0 swap - 4.0 *. 1.0 - | Falling edge: 0.5-1 -> 1 to -1
	;
	
:generate_triangle | voice_idx freq --
	2048 ( 1? 1-
		over sample_rate /. | freq_per_sample
		a@+ over + 
		1.0 >=? ( 1.0 - ) | Wrap phase
		dup a! | Store updated phase
		limtr | Convert phase (0-1) to triangle (-1 to 1)
		rot ) 2drop ;

:generate_sawtooth | voice_idx freq --
	2048 ( 1? 1-
		over sample_rate /. | freq_per_sample
		a@+ over + 
		1.0 >=? ( 1.0 - ) | Wrap phase
		dup a! | Store updated phase
		2.0 *. 1.0 - | Convert 0-1 to -1 to 1 (sawtooth)
		rot ) 2drop ;

:generate_noise | voice_idx freq phase_addr --
	drop 2drop | Noise doesn't need frequency or phase
	2048 ( 1? 1-
		2.0 randmax 1.0 - | Random value -1 to 1
		rot ) drop ;

| Wave generator dispatch table
#wave_generators 'generate_sine 'generate_square 'generate_triangle 'generate_sawtooth 'generate_noise

:generate_wave | voice --
	'wave1 >b | Output buffer
	dup .voice_freq @     | voice_idx freq
	over .voice_phase @    | voice_idx freq phase_addr
	
	'wave1 >a
	| Call appropriate generator
	wave_type 3 << 'wave_generators + @ ex | Call generator function
	
	| Convert samples to 16-bit and store
|	 
|	2048 ( 1? 1-
|		da@+ 1.0 + 0.5 *. | Convert -1,1 to 0,1
|		$ffff and     | Convert to 16-bit integer  
|		b> w!+ >b
|		) drop 
	;

|-----------------------------------------
| Polyphonic Audio Rendering
#mix_buffer * 8192  | Mixing buffer (32-bit samples)
#output_buffer * 8192 | Final output buffer (16-bit samples)

:clear_mix_buffer
	'mix_buffer 0 2048 dfill ;

:mix_voice | voice --
	dup .voice_state c@ 0? ( 2drop ; ) drop | Skip inactive voices

drop ;	
	dup calc_envelope | voice amplitude
	0.01 <? ( 2drop ; ) | Skip nearly silent voices
	
2drop ;
	
	
	generate_wave | Generate wave data to wave1 buffer

	| Mix into main buffer with amplitude
	'wave1 >b 
	'mix_buffer >a
	2048 ( 1? 1-
		db@+ |$ffff and | Get sample  
		|over *. 16 >>   | Apply amplitude
		da@ + da!+     | Mix with existing
		) 2drop
	;

:render_all_voices
	'voice voice> =? ( drop ; ) 
	clear_mix_buffer
	( voice> <?
		dup mix_voice
		32 + ) drop
	| Convert 32-bit mix buffer to 16-bit output
	'mix_buffer >a 'output_buffer >b
	2048 ( 1? 1-
		da@+ 
		-32768 max 32767 min | Clamp to 16-bit range
		dup 16 << or       | Duplicate to both channels
		db!+
		) drop
	| Send to audio device
	audio_device 'output_buffer 8192 SDL_QueueAudio ;

|-----------------------------------------
| Note Management
:note_on | note velocity --
	newvoice 0? ( 3drop ; ) | No free voices|
	>a | Save voice index
	a> .voice_velocity c!
	dup a> .voice_note c!
	| Set frequency from table
	note>freq a> .voice_freq !
	| Initialize envelope
	0.0 a> .voice_phase !
	0.0 a> .voice_env_time !
	1 a> .voice_state c! | Attack state
	;

:note_off | note --
	| Find voice playing this note
	'voice ( voice> <?
		dup .voice_note c@ 
		pick2 =? ( drop 
			0.0 over .voice_env_time !
			4 over .voice_state c!
			2drop ;	
			)
		drop
		32 + ) 2drop ;

|-----------------------------------------
| Update System
:update_voices
	'voice ( voice> <?
		dup .voice_state c@ 1? ( | Active voice
			| Update envelope time
			0.023  | ~1/44100 * buffer_size for timing
			pick2 .voice_env_time +!
			) drop
		32 + ) drop ;

:runsynthe	
	audio_device SDL_GetQueuedAudioSize 8192 >=? ( drop ; ) drop | Buffer full
	update_voices
	render_all_voices
	;

|-----------------------------------------
| Visual Components  

:drawbuffer
	$ffffff sdlcolor
	'output_buffer >a 
	0 ( 1024 <? 1+
		a@+ 
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
| Wave Type Selection
:next_wave_type
	wave_type 1+ 4 >? ( drop 0 ) 'wave_type ! ;

:prev_wave_type  
	wave_type 1- -? ( drop 4 ) 'wave_type ! ;

:set_wave_type | type --
	0 max 4 min 'wave_type ! ;

|-----------------------------------------
| Enhanced Keyboard Handling  
:playdn | note --
	dup 'playn + c@ 1? ( 2drop ; ) drop | Already pressed
	dup 60 + 100 note_on | note + middle C, velocity 100
	1 swap 'playn + c! ; | Mark as pressed

:playup | note --
	dup 'playn + c@ 0? ( 2drop ; ) drop | Not pressed
	dup 60 + note_off  | note + middle C
	0 swap 'playn + c! ; | Mark as released

:upkeys
	>esc< =? ( exit )
	>f1< =? ( 0 set_wave_type ) >f2< =? ( 1 set_wave_type )
	>f3< =? ( 2 set_wave_type ) >f4< =? ( 3 set_wave_type ) 
	>f5< =? ( 4 set_wave_type )
	>le< =? ( prev_wave_type ) >ri< =? ( next_wave_type )
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
	
:teclado
	SDLkey 0? ( drop ; )
	$1000 and? ( upkeys ; ) | Key release
	<f1> =? ( 0 set_wave_type ) <f2> =? ( 1 set_wave_type )
	<f3> =? ( 2 set_wave_type ) <f4> =? ( 3 set_wave_type )
	<f5> =? ( 4 set_wave_type )
	<le> =? ( prev_wave_type ) <ri> =? ( next_wave_type )
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

|-----------------------------------------
| Voice Status Display
:draw_wave_selector
	10 50 txat "Waveform: " txprint
	wave_type get_wave_name txprint
	" (F1-F5 or <>)" txprint ;

:draw_voice_status
	10 550 txat "Active Voices: " txprint
	
	| Count active voices
	voice> 'voice - 5 >> "%d/16" txprint
	
	| Show voice details
	200 550 txat "Voice States: " txprint
	'voice ( voice> <? 
		dup .voice_note c@ 
		over .voice_state c@
		"[%d:%d] " txprint
		32 + ) drop ;

|-----------------------------------------
| Main Loop
:main
	$0 SDLcls
	
	10 10 txat "R3 Polyphonic Synthesizer v2.1" txprint
	10 30 txat "QWERTY keyboard plays notes • F1-F5 change waveforms • ESC to exit" txprint
	
	draw_wave_selector
	drawkeys
|	drawbuffer

 drawdebug
	draw_voice_status
	
	runsynthe
	
	SDLredraw
	teclado ;

|-----------------------------------------
| Initialization and Entry Point
: 
	"R3 Polyphonic Synthesizer" 1024 600 SDLinit
	"media/ttf/Roboto-bold.ttf" 20 txloadwicon txfont


	
	debug1
	
	iniaudio
	resetvoice
	
	'main SDLshow
	SDLquit ;