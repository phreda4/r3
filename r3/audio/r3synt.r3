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
:v.ATTACK 8 dcell+ ; 
:v.DECAY 9 dcell+ ; 
:v.SUSTAIN 10 dcell+ ; 
:v.RELEASE 11 dcell+ ; 
:v.pitch_bend 12 dcell+ ; 
:v.mod_wheel 13 dcell+ ; 

#voices * $1ff | 4 * 16 * 8 (voices)

:resetvoices
	'voices
	8 ( 1? 1- swap
		0 over v.state d!
		0.0 over v.phase1 d!
		0.0 over v.phase2 d!
		0.0 over v.sub_phase d!		
		100 over v.velocity d!
		0.0 over v.pitch_bend d!
		0.0 over v.mod_wheel d!
		0.0 over v.ATTACK d!
		0.0 over v.DECAY d!
		0.0 over v.SUSTAIN d!
		0.0 over v.RELEASE d!
		4 16 * +
		swap ) 2drop ;

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

#envlevel

#vstate

#attrate
#decrate
#relrate
#suslevel

:venvelope | --
	vstate
	1 =? ( drop | attack
		envlevel attrate +
		1.0 >=? (
			1.0 nip
			2 'vstate !
			)
		'envlevel !			
		; )
	2 =? ( drop | decay
		envlevel decrate -
		suslevel <=? (
			suslevel nip
			3 'vstate !
			)
		'envlevel !
		; )
	3 =? ( drop |sustain
		; )
	drop | release
	envlevel relrate -
	0 <=? ( 
		0 nip 
		0 'vstate !
		)
	'envlevel !
	;
	
#osc1 #osc2	
:process_voice | nvoice -- sample
	16 4 * * 'voices +
	dup v.state d@ 0? ( nip ; ) drop
	
	dup v.phase1 dup d@ 
	1 + 1.0 >? ( 1.0 - ) | $ffff and
	dup rot d!
	pulse_width current_wave ex 'osc1 !
	
	dup v.phase2 dup d@ 
	10 + 1.0 >? ( 1.0 - )
	dup rot d!
	pulse_width current_wave ex 'osc2 !
	
	drop
	osc1 osc2 +
	;
	
	
:genaudio
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
|        for (int v = 0; v < MAX_POLYPHONY; v++) {
|            float velocity_factor = voices[v].velocity / 127.0f;
			0 process_voice |(&voices[v], current_cutoff, current_pwm, lfo2_val, sh_mod_pitch, velocity_factor);
			+
|        }

        | 4. Delay
|        float delayed_sample = process_delay(mix);
|        float final_output = mix + delayed_sample * 0.4f;

        | 5. write

		soft_clip -32768 max 32767 min | Clamp to 16-bit range
		dup 16 << or       | Duplicate to both channels
		db!+
		) drop ;
	
:qaudio
	audevice SDL_GetQueuedAudioSize 8192 >=? ( drop ; ) drop | Buffer full
	genaudio
	audevice 'outbuffer 8192 SDL_QueueAudio ;
	;
	
:drawbuffer
	$ffffff sdlcolor
	'outbuffer >a 
	0 ( 1024 <? 1+
		da@+ 
		over over $ffff and 9 >> 300 + SDLPoint
		over swap 16 >> $ffff and 9 >> 440 + SDLPoint
		) drop ;
		
|--------------------------------
:main
	$0 SDLcls
	10 10 txat "R3Synth" txprint
	
	drawbuffer
	
	SDLredraw
	sdlkey
	>esc< =? ( exit )
	<f1> =? ( 1 'voices d! )
	<f2> =? ( 0 'voices d! )
	drop 
	qaudio ;
	
: |--------------------------------
	"R3 Polyphonic Synthesizer" 1024 600 SDLinit
	"media/ttf/Roboto-bold.ttf" 20 txloadwicon txfont
	iniaudio
	reset
	resetvoices
	'main SDLshow
	SDLquit ;