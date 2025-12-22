^r3/lib/term.r3
^r3/lib/webcam.r3

#ascii64 "`.-',:_~;""^!*]/)(<>?1r+cl=|7YvLsx[it}JjzTC{fyVnIou2S3Few%5AHXkZ"
#ns ".,-~:;!+*=#%$@"

#running 1

#cam
#camw #camh 

#camdata
0 | unsigned char *data;
0 | int width; int height;
0 | int size; WebcamPixelFormat format;
0 | unsigned long timestamp_ms; 
	
#scrw 80 #scrh 25

:exit 0 'running ! ;
	
| luma->char
:lumi2ascii | v --
	dup 16 >> $ff and 2* 
	over 8 >> $ff and dup 2 << + +
	swap $ff and + 3 >> | luma (2r+5g+b)/8
|	2 >> $3f and 		| 64
|	4 >> $f and 2 <<	| 16
	5 >> $f and 3 <<	| 8
	'ascii64 + c@ .emit ;

|24bits color
:rgb2ascii | v -- v
	dup 16 >> $ff and
	over 8 >> $ff and
	pick2 $ff and
	.fgrgb	| color
	lumi2ascii ;

:8>6 | precise
	6 $ff */ ;
:8>6 
	dup 2* + 2* 8 >> ;

|8bit color	
:cube2ascii
	dup 16 >> $ff and 8>6 36 *
	over 8 >> $ff and 8>6 6 * +
	over $ff and 8>6 + 
	16 + .fc
	lumi2ascii ;
		
#conv 'cube2ascii
#stepx #stepy
#invarea
#ar #ag #ab

:acccol | y x -- y x rgb
	0 'ar ! 0 'ag ! 0 'ab !
	0 ( stepy 16 >> <?
		pick2 stepy *. over + camw * pick2 stepx *. + 3 * 
		camdata + >a
		stepx 16 >> ( 1?
			ca@+ $ff and 'ar +!
			ca@+ $ff and 'ag +!
			ca@+ $ff and 'ab +!
			1- ) drop
		1+ ) drop
	ar invarea * 32 >> $ff and 16 <<
	ag invarea * 32 >> $ff and 8 << or
	ab invarea * 32 >> $ff and or
	;
	

:drawcam
	.home .reset
	camdata >a
	0 ( scrh <?
		0 ( scrw <?
			acccol conv ex
			1+ ) drop
		.cr
		1+ ) drop
	.flush ;

:handle-key | key --
	[esc] =? ( exit ; )      | ESC
	[f1] =? ( 'rgb2ascii 'conv ! )
	[f2] =? ( 'cube2ascii 'conv ! )
	[f3] =? ( 'lumi2ascii 'conv ! )
    ;
	
:main-loop | --
    ( running 1? drop
		cam 'camdata webcam_capture 0? ( drawcam ) drop
		inkey 1? ( handle-key ) drop
		10 ms
    ) drop ;

|------- Main Program -------
#cntwc
#listwc

#idx

:listadowc
	'cntwc webcam_list_devices 'listwc !
	cntwc "webcam:%d" .println 
	listwc 
	0 ( cntwc <? swap
		d@+ "%d " .print
		dup "%s " .println
		128 + |dup "%s " .println
		256 +
		swap 1+ ) 2drop 
		
	listwc d@ 'idx !
	listwc webcam_free_list
	.flush
	;
	
:main
	listadowc
	640 480 idx WEBCAM_FMT_RGB24 webcam_open 
	0? ( drop "NO camara" .flush waitkey ; ) 'cam !
	.flush
	cam webcam_get_actual_height 'camh !
	cam webcam_get_actual_width 'camw !
	camh camw "Resolucion: %dx%d" .println
	
	camw fix. scrw / 'stepx !
	camh fix. scrh / 'stepy !
	stepx stepy "%f %f" .cr .println .flush
	
	$100000000 stepx int. stepy int. * /. 'invarea !
	invarea 16 >> "%f" .println
	
	.flush
	here 
	dup 'camdata ! 
	camh camw * 3 *  +
	'here !
	
    .hidec .cls .reset
	2 27 .at "WebCam ASCII DEMO | F1-24bit F2-8bit F3-B&N | ESC-Exit" .write
    main-loop
	cam webcam_close
	.showc .reset
    ;

| Program entry point
:  main .free ;

