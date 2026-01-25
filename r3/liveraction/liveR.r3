^r3/lib/sdl2gfx.r3
^r3/lib/console.r3
^./memshare.r3	


:send
	1 memshare c+!
	'pad memshare 1+ strcpy
	;
	
:main
	( ">" .write .input 'pad c@ 1? drop 
	
		send
|		">>" .write 'pad .println
		
		) drop ;
:
inishare

">> LiveRaction start <<" .println
"cmd /c r3 ""r3/liveraction/raction.r3""" sprint
sysnew 
	
main

endshare
;