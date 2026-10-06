| COLORSCENE - demo de colores de terminal estilo demoscene
| escenas: spectrum, plasma, tunel, rotozoomer, fuego, starfield, copper bars
|
^r3/lib/console.r3
^r3/lib/math.r3
^r3/lib/rand.r3
^r3/lib/color.r3

|---------------- tamano y buffers
#CW 80 #CH 24		| celdas del area de dibujo
#PW 80 #PH 48		| pixeles (PH = CH*2)

#pxb * 256000		| pixeles 320x200 (dword $RRGGBB)
#pal * 1024			| paleta de 256 colores
#heat * 66000		| fuego
#tang * 64000		| tunel: angulo
#tdep * 256000		| tunel: profundidad
#tfog * 64000		| tunel: niebla
#stx * 2048 #sty * 2048 #stz * 2048	| estrellas

#running 1 #auto 1
#scn 0 #t0 0 #tt 0 #fade 0 #fps 30 #dt 33 #tlast 0

:tnow msec t0 - ;

|---------------- color
:rgb | r g b -- c
	swap 8 << or swap 16 << or ;

:unpack | c -- r g b
	dup 16 >> $ff and over 8 >> $ff and rot $ff and ;

|---------------- paletas
:cosc | turns -- 0..255	; cos() se pasa de +-65536 en los extremos: se acota
	cos 65536 + 9 >> 255 clamp0max ;

:pch | f d i -- v		; un canal de la paleta coseno
	rot * 8 >> + cosc ;

:mkpal | f dr dg db --		; paleta coseno (Inigo Quilez): f = ciclos, dr dg db = fase
	0 ( 256 <?						| f dr dg db i
		pick4 pick4 pick2 pch 16 << >r
		pick4 pick3 pick2 pch 8 << r> or >r
		pick4 pick2 pick2 pch r> or
		over 2 << 'pal + d!
		1+ ) 4drop drop ;

:firepal | negro - rojo - naranja - amarillo - blanco
	0 ( 256 <?
		dup 3 * 255 min
		over 70 - 3 * 0 max 255 min
		pick2 150 - 3 * 0 max 255 min
		rgb
		over 2 << 'pal + d!
		1+ ) drop ;

:palc | i -- c
	$ff and 2 << 'pal + d@ ;

|---------------- salida: el frame se arma en memoria (here) y se escribe de una vez
:onum3 | r g b --
	rot ,d 59 ,c swap ,d 59 ,c ,d ;

:ofg | c -- 
	$1b ,c "[38;2;" ,s unpack onum3 109 ,c ;
:obg | c --
	$1b ,c "[48;2;" ,s unpack onum3 109 ,c ;

#lfg #lbg
:setfg | c --
	lfg =? ( drop ; ) dup 'lfg ! ofg ;
:setbg | c --
	lbg =? ( drop ; ) dup 'lbg ! obg ;

|---------------- texto superpuesto (overlay)
:forxy | 'w --			; w ( x y -- ) para cada pixel
	0 ( PH <?
		0 ( PW <?
			dup pick2 pick4 ex
			1+ ) drop
		1+ ) 2drop ;

:forpx | 'px --			; llena pxb con px ( x y -- color )
	'pxb >a
	0 ( PH <?
		0 ( PW <?
			dup pick2 pick4 ex da!+
			1+ ) drop
		1+ ) 2drop ;

|---------------- escena 0: SPECTRUM
:spec-init
	1.0 0 0.333 0.667 mkpal ;

:ramp | x -- 0..255		; a lo ancho
	255 * PW 1- 1 max / ;

:spec-px | x y -- color
	dup 6 * PH mod 6 <? ( 3drop 0 ; ) drop
	dup 6 * PH /
	0? ( 2drop ramp 16 << ; )
	1 =? ( 2drop ramp 8 << ; )
	2 =? ( 2drop ramp ; )
	3 =? ( 2drop ramp $010101 * ; )
	4 =? ( 2drop 256 * PW / tt 5 >> + palc ; )
	drop over 256 * PW / tt 4 >> + palc
	255 pick2 6 * PH mod 255 * PH / - colmul nip nip ;

:spec-frame
	'spec-px forpx ;

:spec-name "SPECTRUM  -  TRUECOLOR 24 BITS" ;

|---------------- escena 1: PLASMA
#pcx #pcy

:plasma-px | x y -- color
	over PW 16 <</ 3 * tt 8 * + sin
	over PH 16 <</ 2 * tt 5 * + sin +
	pick2 PW 16 <</ pick2 PH 16 <</ + 2 * tt 11 * + sin +
	pick2 pcx - dup * pick2 pcy - dup * + sqrt 16 << PH / 3 * tt 6 * + sin +
	10 >> tt 24 / + palc nip nip ;

:plasma-init
	1.0 0.0 0.15 0.4 mkpal ;

:plasma-frame
	tt 3 * sin PW 3 / *. PW 1 >> + 'pcx !
	tt 4 * cos PH 3 / *. PH 1 >> + 'pcy !
	'plasma-px forpx ;

:plasma-name "PLASMA" ;

|---------------- escena 2: TUNEL
:tunnel-px | x y --		; precalcula angulo, profundidad y niebla del pixel
	2dup PW * + >r
	swap PW 1 >> - swap PH 1 >> -			| dx dy
	2dup atan2 6 >> $ff and r@ 'tang + c!
	dup * swap dup * + sqrt				| d
	dup 510 * PH / 255 min r@ 'tfog + c!
	1+ PH 6 << swap / r> 2 << 'tdep + d! ;

:tunnel-init
	2.0 0.0 0.1 0.25 mkpal
	'tunnel-px forxy ;

:tunnel-frame
	'pxb >a
	0 ( PW PH * <?					| ti
		dup 'tang + c@ $ff and tt 3 >> +		| ti ang
		over 2 << 'tdep + d@				| ti ang td
		dup 3 >> rot +				| ti td v
		swap tt 2 >> + xor palc			| ti c
		over 'tfog + c@ $ff and colmul
		da!+
		1+ ) drop ;

:tunnel-name "TUNEL" ;

|---------------- escena 3: ROTOZOOMER
#dux #dvx #uu #vv

:shade | c -- c			; cuadros alternados mas oscuros
	uu 17 >> vv 17 >> xor 1 and 0? ( drop ; ) drop 170 colmul ;

:roto-init
	1.0 0.55 0.7 0.85 mkpal ;

:roto-frame
	tt 12 *
	dup cos tt 5 * sin 2/ 0.9 + *. 'dux !
	sin tt 5 * sin 2/ 0.9 + *. 'dvx !
	'pxb >a
	0 ( PH <?						| y
		PW 1 >> neg dux * over PH 1 >> - dvx * - tt 700 * + 'uu !
		PW 1 >> neg dvx * over PH 1 >> - dux * + tt 400 * + 'vv !
		0 ( PW <?
			uu 18 >> vv 18 >> xor 3 << tt 5 >> + palc
			shade da!+
			dux 'uu +! dvx 'vv +!
			1+ ) drop
		1+ ) drop ;

:roto-name "ROTOZOOMER" ;

|---------------- escena 4: FUEGO
:stride | -- n
	PW 2 + ;

:fseed | x -- v
	dup 3000 * tt 3 * + sin swap 1100 * tt 2 * - sin +
	1 >> 65536 + 9 >> 0 max
	rnd $7f and 128 + * 8 >> 255 min ;

:fire-init
	firepal
	'heat 0 PW 2 + PH 2 + * cfill ;

:fire-px | x y -- v		; promedio de 4 vecinos de la fila de abajo, menos enfriamiento
	1+ stride * + 'heat +				| a
	dup c@ $ff and over 1+ c@ $ff and + over 2 + c@ $ff and +
	swap stride 1+ + c@ $ff and +
	2 >>
	rnd $ff and 80000 PH / + 8 >> -
	0 max ;

:fire-cell | x y --
	2dup fire-px -rot stride * + 1+ 'heat + c! ;

:fire-col | x y -- color
	stride * + 1+ 'heat + c@ palc ;

:fire-seed | x --		; siembra las 2 filas de abajo
	dup fseed over PH stride * + 1+ 'heat + c!
	dup fseed swap PH 1+ stride * + 1+ 'heat + c! ;

:fire-frame
	0 ( PW <? dup fire-seed 1+ ) drop
	'fire-cell forxy
	'fire-col forpx ;

:fire-name "FUEGO" ;

|---------------- escena 5: STARFIELD
:NST 360 ;
#sx #sy #tx #ty #ln #sdz #strail

:star-new | i --
	2 << 
	4096 rndmax over 'stx + d!
	4096 rndmax over 'sty + d!
	255 rndmax 20 + swap 'stz + d! ;

:pset | c x y --
	PH >=? ( 3drop ; ) -? ( 3drop ; )
	swap PW >=? ( 3drop ; ) -? ( 3drop ; ) swap
	PW * + 2 << 'pxb + d! ;

:proj | v z half -- p		; perspectiva
	>r 4 << swap PH * swap / r> + ;

:star-draw | col bright --	; estela de (sx,sy) a (tx,ty), mas tenue hacia la cola
	tx sx - abs ty sy - abs max 1 max 40 min 'ln !
	0 ( ln <=?						| col bright li
		pick2 pick2 255 pick3 230 * ln / - * 8 >> colmul	| col bright li c
		tx sx - pick2 * ln / sx +
		ty sy - pick3 * ln / sy +
		pset
		1+ ) 3drop ;

:star-step | i --
	dup 2 << 'stz + d@ sdz -				| i sz
	2 <? ( drop star-new ; )
	over 2 << 'stx + d@ 2048 -				| i sz xv
	pick2 2 << 'sty + d@ 2048 -				| i sz xv yv
	over pick3 PW 1 >> proj 'sx !
	dup pick3 PH 1 >> proj 'sy !
	over pick3 strail + PW 1 >> proj 'tx !
	dup pick3 strail + PH 1 >> proj 'ty !
	2drop						| i sz
	dup pick2 2 << 'stz + d!
	over 29 * palc $ffffff 110 colmix			| i sz col
	255 pick2 3 * 2 >> - 1 max				| i sz col bright
	2dup star-draw drop					| i sz col
	over 80 <? ( over sx 1+ sy pset ) drop		| extra pixel cuando esta cerca
	3drop ;

:stars-init
	1.0 0.0 0.33 0.67 mkpal
	'pxb 0 PW PH * dfill
	0 ( NST <? dup star-new 1+ ) drop ;

:stars-frame
	'pxb 0 PW PH * dfill
	dt tt 4 * sin 65536 + 13 >> 6 + * 6 >> 'sdz !
	sdz 4 * 3 + 'strail !
	0 ( NST <? dup star-step 1+ ) drop ;

:stars-name "STARFIELD" ;

|---------------- escena 6: COPPER BARS
:bt | -- n			; medio alto de una barra
	PH 13 / 5 max ;

:cop-init
	1.0 0 0.333 0.667 mkpal ;

:bgrow | y --
	dup 255 * PH / >r
	$06061a $281050 r> colmix
	swap PW * 2 << 'pxb + swap PW dfill ;

:bar-fill | yc base dy --	; una linea de la barra (dy = -bt..bt alrededor del centro yc)
	pick2 over +						| yc base dy y
	0 PH 1- in? (
		swap 16384 * bt / cos 8 >>			| yc base y v
		dup dup * 8 >> dup * 8 >>			| yc base y v b
		>r pick2 swap colmul $ffffff r> 1 >> colmix		| yc base y c
		swap PW * 2 << 'pxb + swap PW dfill
		2drop ; )
	4drop ;

:bar | i want --		; want: 1 = barras de atras, 0 = de adelante
	over 9362 * tt 6 * +					| i want ph
	dup cos 63 >>> pick2 <>? ( 4drop ; ) drop
	dup sin PH 3 * 3 >> *. PH 1 >> +			| i want ph yc
	pick3 36 * tt 4 >> + palc				| i want ph yc base
	>r >r 3drop r> r>					| yc base
	bt neg ( bt <=?
		pick2 pick2 pick2 bar-fill
		1+ ) 3drop ;

:bars
	0 ( 7 <? dup 1 bar 1+ ) drop
	0 ( 7 <? dup 0 bar 1+ ) drop ;

:cop-frame
	0 ( PH <? dup bgrow 1+ ) drop
	bars ;

:cop-name "COPPER BARS" ;

|---------------- tablas de escenas
#snames spec-name plasma-name tunnel-name roto-name fire-name stars-name cop-name
#sinit spec-init plasma-init tunnel-init roto-init fire-init stars-init cop-init
#sframe spec-frame plasma-frame tunnel-frame roto-frame fire-frame stars-frame cop-frame

|---------------- presentacion
:fadec | c -- c'		; fundido de entrada de la escena
	fade 256 <? ( colmul ; ) drop ;

:cell | x y --			; una celda = 2 pixeles (medio bloque)
	1 << PW * + 2 << 'pxb + dup d@ swap PW 2 << + d@	| ct cb
	fadec swap fadec swap
	swap setfg setbg
	$e2 ,c $96 ,c $80 ,c ;

:scname | -- "name"
	scn 3 << 'snames + @ ex ;

:padn | n --
	( 1 >? 32 ,c 1- ) drop ;

:status
	$1b ,c 91 ,c CH 1+ ,d ";1H" ,s
	$1b ,c "[0;48;2;30;30;46;38;2;200;200;220m" ,s
	CH CW fps 7 scn 1+ scname "%s  %d/%d   %d fps   %dx%d " sprint count	| info len
	CW over -							| info len pd
	" SPC/arrows scene   A auto   ESC exit" count pick2 swap -	| info len pd help free
	1 >? ( swap ,s padn pick2 ,s 3drop ; )
	2drop padn drop ,s ;

:,at | x y --		; como .at pero escribe en el buffer del cuadro
	$1b ,c 91 ,c ,d 59 ,c ,d 72 ,c ;

:txt | "s" x y --		; texto en la columna x, fila y (desde 1), fondo oscuro
	,at $ffffff ofg $14141e obg ,print ;

:spec-labels
	"RED      0..255" 3 CH 12 / 1+ txt
	"GREEN    0..255" 3 CH 3 * 12 / 1+ txt
	"BLUE     0..255" 3 CH 5 * 12 / 1+ txt
	"GRAY     0..255" 3 CH 7 * 12 / 1+ txt
	"RAIWBOW  (hue)" 3 CH 9 * 12 / 1+ txt
	"HUE x VALOR  -  16.777.216 cols" 3 CH 11 * 12 / 1+ txt ;

:labels
	scn 0? ( spec-labels ) drop
	tt 2500 <? ( scname dup count nip CW swap - 1 >> 1+ 2 txt ) drop
	$1b ,c "[0m" ,s ;

:present
	mark here					| fs
	-1 'lfg ! -1 'lbg !
	0 ( CH <?					| fs y
		$1b ,c 91 ,c dup 1+ ,d ";1H" ,s
		0 ( PW <?				| fs y x
			dup pick2 cell
			1+ ) drop
		1+ ) drop
	$1b ,c "[0m" ,s
	status labels
	here over - type empty ;

|---------------- control
:wrapsc | n -- n
	-? ( drop 6 ; )
	7 >=? ( drop 0 ; )
	;

:initscene
	scn 3 << 'sinit + @ ex ;

:setscene | n --
	wrapsc 'scn ! msec 't0 ! 0 'fade ! initscene ;

:resize 
|LIN|	.getterminfo
	cols 320 min 20 max 'CW !
	rows 1- 100 min 8 max 'CH !
	CW 'PW ! CH 1 << 'PH !
	.Reset .cls
	scn setscene ;

:keys
	inkey 0? ( drop ; )
	[esc] =? ( drop 0 'running ! ; )
	$20 =? ( drop scn 1+ setscene ; )
	[RI] =? ( drop scn 1+ setscene ; )
	[LE] =? ( drop scn 1- setscene ; )
	$61 =? ( drop auto 1 xor 'auto ! ; )
	$41 =? ( drop auto 1 xor 'auto ! ; )
	$31 $37 in? ( $31 - setscene ; )
	drop ;

:frame
	msec dup tlast - 1 max 200 min 'dt ! 'tlast !
	fps 3 * 1000 dt / + 2 >> 'fps !
	fade dt 3 * 2 >> + 256 min 'fade !
	tnow 'tt !
	scn 3 << 'sframe + @ ex
	present
	auto 0? ( drop ; ) drop
	tt 12000 >? ( scn 1+ setscene ) drop
	;

:main
	( running 1? drop
		frame
		keys
		1 ms
		) drop ;

: 
	.alsb .hidec
	'resize .onresize
	resize
	main
	.Reset .showc .masb .free ;
