^./console.r3
^r3/lib/escapi.r3

#ascii64 " .\'`^"",:;Il!i~+_-?]{}1)(/tfjrxnuvczmwqpdbkhaoXYUJCLQ0OZ#MW&8%B@$"

#running 1

#device
#capture 0 [ 80 40 ]

:exit 0 'running ! ;
	
:handle-key | key --
	]esc[ =? ( exit ; )      | ESC
|WIN|	$1000 and? ( ; ) 16 >> |ascii
|	$20 =? ( next-page ; ) | SPACE
    ;

:drawcam
	.cls
	capture >a
	40 ( 1? 1-
		80 ( 1? 1-
			da@+ 10 >> $3f and $3f xor 'ascii64 + c@ .emit
			) drop
		.cr
		) drop
	.flush 

	device doCapture
	;
	
:main-loop | --
    ( running 1? drop
		device isCaptureDone 1? ( drawcam ) drop 
        inkey 1? ( handle-key ) drop
        10 ms
    ) drop ;

|------- Main Program -------
:main
	setupESCAPI 1 <? ( "Unable to init ESCAPI" .log ) drop |'maxdevice !
	0 'device !
	here 'capture !
	80 40 * 4 * 'here +!
	device 'capture initCapture drop |"%d" .println
|	getprop
|	printp	

	device doCapture	
	
    | Set resize callback
|    'on-resize-event .onresize
    .hidec
    main-loop
    .showc .cls .home .Reset
    "Color demo finished!" .println ;

| Program entry point
: main ;

