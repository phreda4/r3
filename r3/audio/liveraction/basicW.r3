^r3/lib/sdl2gfx.r3
^r3/lib/console.r3
^r3/lib/memshare.r3	

#vshare 0 0 4096 "/data.mem"

:send
	'pad vshare 1+ strcpy		| primero el texto...
	1 vshare c+!				| ...y despues el contador (el lector no ve texto a medias)
	;
	
:main
	( ">" .write .input 'pad c@ 1? drop 
		send
		) drop ;
:
'vshare inisharev

">> basic start <<" .println
|WIN| "cmd /c r3 ""r3/audio/liveraction/basicR.r3""" sprint sysnew 
	
"*** hola ***" 'pad strcpy send
main

'vshare endsharev
;