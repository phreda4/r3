^r3/lib/sdl2gfx.r3
^r3/lib/console.r3
^r3/lib/memshare.r3

#vshare 0 0 4096 "/data.mem"

#mprev 0

:checkcom
	vshare c@ mprev =? ( drop ; ) 'mprev !
	">" .write vshare 1+ .println
	;
	
:main
	">> basic player <<" .println

	( inkey [ESC] <>? drop
		checkcom
		100 ms ) drop
	;
:
.cls
'vshare inisharev
main
'vshare endsharev
;
