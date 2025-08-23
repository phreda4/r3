| libespeak-ng.dll
| PHREDA 2025
^r3/lib/win/kernel32.r3

#espeak_Initialize_p		::espeak_Initialize espeak_Initialize_p sys4 ;
#espeak_SetVoiceByName_p	::espeak_SetVoiceByName espeak_SetVoiceByName_p sys1 ;
#espeak_TextToPhonemes_p	::espeak_TextToPhonemes espeak_TextToPhonemes_p sys3 ;
#espeak_Terminate_p			::espeak_Terminate espeak_Terminate_p sys0 ;

: 
	".\\dll" SetDllDirectory
	"libespeak-ng.dll" loadlib
	dup "espeak_Initialize" getproc 'espeak_Initialize_p !
	dup "espeak_SetVoiceByName" getproc 'espeak_SetVoiceByName_p !
	dup "espeak_TextToPhonemes" getproc 'espeak_TextToPhonemes_p !
	dup "espeak_Terminate" getproc 'espeak_Terminate_p !
	drop
	"" SetDllDirectory
	;