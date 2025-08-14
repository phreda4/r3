| ffmpeg.dll
| PHREDA 2024
| api >> ffm.dll
^r3/lib/math.r3
^r3/lib/sdl2.r3

#sys-IniVideo
#sys-LoadVideo
#sys-VideoBox
#sys-VideoPoly
#sys-VideoFlag
#sys-VideoTex
#sys-PlayVideo
#sys-StopVideo

::IniVideo sys-IniVideo sys1 drop ;
::LoadVideo sys-LoadVideo sys2 ;
::VideoBox sys-VideoBox sys2 drop ;
::VideoPoly sys-VideoPoly sys5 drop ;
::VideoFlag sys-VideoFlag sys1 ;
::VideoTex sys-VideoTex sys1 ;
::PlayVideo sys-PlayVideo sys1 drop ;
::StopVideo sys-StopVideo sys1 drop ;

##LOADING		$20
##VID_NO_AUDIO  $10
##VID_LOOP		$8
##VID_WAIT		$4

::VideoTime | video -- len
	videoFlag 32 >> 0 max ;
	
::VideoSize | video -- w h
	videoFlag 8 >> dup 12 >> $fff and swap $fff and ;
	
|----------------------	
#vert [ 0 0 0 0 0
		0 0 0 0 0
		0 0 0 0 0
		0 0 0 0 0 ]

#index [ 0 1 2 2 3 0 ]	

#ym #xm
#dx #dy
	
|-------------------	
:fillfull
	'vert >a 
	-1 0 $3f800000 |1.0 f2fp 
	8 a+ pick2 da!+ over da!+ over da!+
	8 a+ pick2 da!+ dup da!+ over da!+
	8 a+ pick2 da!+ dup da!+ dup da!+
	8 a+ pick2 da!+ over da!+ dup da!
	3drop ;

:fillvertxy | x y --
	'vert >a
	over xm - i2fp da!+ dup ym - i2fp da!+ 12 a+ 
	over xm + i2fp da!+ dup ym - i2fp da!+ 12 a+
	over xm + i2fp da!+ dup ym + i2fp da!+ 12 a+
	swap xm - i2fp da!+ ym + i2fp da!+
	;

:rotxya! | x y x1 y1 -- x y
	over dx * over dy * - | x y x1 y1 x'
	17 >> pick4 + i2fp da!+
	swap dy * swap dx * + | x y y'
	17 >> over + i2fp da!+ 
	;	

:fillvertr | x y ang --
	sincos 'dx ! 'dy !
	'vert >a
	xm neg ym neg rotxya! 12 a+
	xm ym neg rotxya! 12 a+
	xm ym rotxya! 12 a+
	xm neg ym rotxya!
	2drop ;

|-------------------------	
::vshow | x y img --
	dup >r VideoSize 2/ 'ym ! 2/ 'xm ! 
	ab[ fillfull fillvertxy ]ba 
	r> 'vert 4 'index 6 VideoPoly ;
	
::vshowZ | x y zoom img --
	dup >r VideoSize 
	pick2 swap 17 *>> 'ym ! 17 *>> 'xm !
	ab[ fillfull fillvertxy ]ba 
	r> 'vert 4 'index 6 VideoPoly ;

::vshowR | x y ang img --
	dup >r VideoSize 'ym ! 'xm !
	ab[ fillfull fillvertr ]ba 
	r> 'vert 4 'index 6 VideoPoly ;

::vshowRZ | x y ang zoom img --
	dup >r VideoSize
	pick2 swap xm 16 *>> 'xm ! ym 16 *>> 'ym ! 
	ab[ fillfull fillvertr ]ba 
	r> 'vert 4 'index 6 VideoPoly ;
	
|-------- version 1 
#actvideo
#filename * 1024
	
::FFM_open | file --
	actvideo StopVideo 
	'filename strcpy
	'filename
	dup c@ 0? ( drop ; ) drop
	|LOADING VID_NO_AUDIO or | audio
	0
	LoadVideo 'actvideo ! 
	;
	
::FFM_redraw | -- 0-fin
	actvideo dup 0 VideoBox
	VideoFlag 
	;
	
::FFM_close 
	actvideo StopVideo ;
	
|----- BOOT	
:
	".\\dll" SetDllDirectory
	"ffmpegdll.dll" loadlib
	dup "IniVideo" getproc 'sys-IniVideo !	
	dup "LoadVideo" getproc 'sys-LoadVideo !
	dup "VideoBox" getproc 'sys-VideoBox !
	dup "VideoPoly" getproc 'sys-VideoPoly !	
	dup "VideoFlag" getproc 'sys-VideoFlag ! 
	dup "VideoTex" getproc 'sys-VideoTex ! 
	dup "PlayVideo" getproc 'sys-PlayVideo !	
	dup "StopVideo" getproc 'sys-StopVideo !
	drop
	"" SetDllDirectory
	;


