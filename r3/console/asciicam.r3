^./console.r3
^r3/lib/escapi.r3

#ascii64 "$@B%8&WM#*oahkbdpqwmZO0QLCJUYXzcvunxrjft/\|()1{}[]?-_+~<>i!lI;:,^`'."

#running 1

#device
#capture 0 [ 80 25 ] | SIZE

:exit 0 'running ! ;
	
| luma->char
:lumi2ascii | v --
	dup 16 >> $ff and 2* 
	over 8 >> $ff and dup 2 << + +
	swap $ff and + 3 >> | luma (2r+5g+b)/8
	2 >> $3f and 'ascii64 + c@ .emit ;

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

:drawcam
	.home .reset
	capture >a
	25 ( 1? 1-		| SIZE
		80 ( 1? 1-
			da@+ conv ex
			) drop
		.cr
		) drop
	.flush 
	device doCapture ;

:handle-key | key --
	[esc] =? ( exit ; )      | ESC
	[f1] =? ( 'rgb2ascii 'conv ! )
	[f2] =? ( 'cube2ascii 'conv ! )
	[f3] =? ( 'lumi2ascii 'conv ! )
    ;
	
:main-loop | --
    ( running 1? drop
		device isCaptureDone 1? ( drawcam ) drop 
        inkey 1? ( handle-key ) drop
        10 ms
    ) drop ;

|------- Main Program -------
:main
	setupESCAPI 1 <? ( "Unable to init ESCAPI" .fprint ) drop |'maxdevice !
	0 'device !
	here 'capture !
	80 25 * 4 * 'here +!	| SIZE
	device 'capture initCapture drop
	device doCapture	
    .hidec .cls .reset
	2 27 .at "WebCam ASCII DEMO | F1-24bit F2-8bit F3-B&N | ESC-Exit" .write
    main-loop
	.showc .reset
    ;

| Program entry point
:  .console main .free ;

