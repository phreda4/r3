^r3/lib/sdl2gfx.r3
^r3/lib/console.r3
^r3/lib/memshare.r3	

#vshare 0 0 4096 "/data.mem"

:send
	1 vshare c+! 'pad vshare 1+ strcpy
	;
	
:main
	( ">" .write .input 'pad c@ 1? drop 
		send
		) drop ;
:
'vshare inisharev

">> basic start <<" .println
|WIN| "cmd /c r3 ""r3/liveraction/basicr.r3""" sprint sysnew 
	
"*** hola ***" 'pad strcpy send
main

'vshare endsharev
;