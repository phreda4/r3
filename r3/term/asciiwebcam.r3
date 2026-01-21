^r3/lib/console.r3
^r3/lib/webcam.r3

#ascii64 " .,-~:;!+=*x#%$@"

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
:lumi2ascii | adr --
	c@ 4 >> $f and 
	'ascii64 + c@ .emit ;

#c #d #e
:getrgb | adr -- adr rgb
	dup d@ |y0 u y1 v
	dup $ff and 16 - 'c !
	dup 8 >> $ff and 128 - 'd !
	24 >> $ff and 128 -  'e !
	298 c * 309 e * + 128 + 8 >> $ff clamp0max 16 <<
	298 c * 100 d * - 208 e * - 128 + 8 >> $ff clamp0max 8 << or
	298 c * 516 d * + 128 + 8 >> $ff clamp0max or
	;
	
|24bits color
:rgb2ascii | v -- v
	getrgb
	dup 16 >> $ff and
	over 8 >> $ff and
	rot $ff and
	.fgrgb	| color
	lumi2ascii ;

:8>6 | precise
	6 $ff */ ;
:8>6 
	dup 2* + 2* 8 >> ;

|8bit color	
:cube2ascii
	getrgb
	dup 16 >> $ff and 8>6 36 *
	over 8 >> $ff and 8>6 6 * +
	swap $ff and 8>6 + 
	16 + .fc
	lumi2ascii ;
		
	
#conv 'cube2ascii
#stepx #stepy
	
:]data | y x -- y x adr
	over stepy *. camw * 
	over stepx *. + 2* camdata + 
	;
	
:drawcam
	.home .reset
	0 ( scrh <?
		0 ( scrw <?
			]data conv ex
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
		cam 'camdata webcam_capture 0? ( 
			drawcam 
			cam webcam_release_frame 
			) drop
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
	
#cap
#format_names "RGB24" "RGB32" "YUYV" "YUV420" "MJPEG"

:listcapa
	0 webcam_query_capabilities 'cap !
	
    "Resoluciones soportadas:" .println
	cap 12 +
	d@+ "Max W:%d" .println
	d@+ "Max H:%d" .println
	d@+ "Min W:%d" .println
	d@ "Min H:%d" .println
    cap 8 + d@
	dup "formatos: %d" .println
	cap @ >a
	0 ( over <?
		da@+ 'format_names swap n>>0 "%s " .print
		da@+ "w %d " .print
		da@+ "h %d " .print
		da@+ "fps:%d " .println
		1+ ) 2drop
		
	cap webcam_free_capabilities
	.flush
	;

:main
	listadowc
	listcapa
	
	640 480 idx
	WEBCAM_FMT_YUYV
	webcam_open 
	0? ( drop "NO camara" .println .flush waitkey ; ) 'cam !
	.flush
	cam webcam_get_actual_height 'camh !
	cam webcam_get_actual_width 'camw !
	camh camw "Resolucion: %dx%d" .println
	
	camw fix. scrw / 'stepx !
	camh fix. scrh / 'stepy !
	
	.flush

	.hidec .cls .reset
	2 27 .at "WebCam ASCII DEMO | F1-24bit F2-8bit F3-B&N | ESC-Exit" .write
	main-loop
	cam webcam_close
	.showc .reset
    ;

| Program entry point
:  main .free ;

