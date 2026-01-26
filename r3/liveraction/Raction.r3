^r3/lib/sdl2gfx.r3
^r3/lib/console.r3
^r3/lib/memshare.r3

#mprev 0

:checkcom
	memshare c@ mprev =? ( drop ; ) 'mprev !
	">" .write	memshare 1+ .println
	;
	
:main
	.cls
	">> LiveRaction player <<" .println

	( inkey [ESC] <>? drop
		checkcom
		100 ms ) drop
	;
:
inishare
main
endshare
;
