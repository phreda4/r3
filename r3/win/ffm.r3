| ffm.dll
|

#sys-FFM_init
#sys-FFM_open
#sys-FFM_redraw
#sys-FFM_resize
#sys-FFM_close

::FFM_init sys-FFM_init sys0 drop ;
::FFM_open sys-FFM_open sys3 drop ;	
::FFM_redraw sys-FFM_redraw sys1 ;
::FFM_resize sys-FFM_resize sys2 ;
::FFM_close sys-FFM_close sys0 drop ;

::ffm
	"ffdll.DLL" loadlib
	dup "FFM_init" getproc 'sys-FFM_init !
	dup "FFM_open" getproc 'sys-FFM_open ! 
	dup "FFM_redraw" getproc 'sys-FFM_redraw !
	dup "FFM_resize" getproc 'sys-FFM_resize !
	dup "FFM_close" getproc 'sys-FFM_close !
	drop
	;

	
|DLLIMPORT extern int mix_movie_channel;

