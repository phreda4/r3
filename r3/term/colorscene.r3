| COLORSCENE - demo de colores de terminal estilo demoscene
| escenas: spectrum, plasma, tunel, rotozoomer, fuego, starfield, copper bars
|
^r3/lib/console.r3
^r3/lib/math.r3
^r3/lib/rand.r3

|---------------- tamano y buffers
#CW 80 #CH 24		| celdas del area de dibujo
#PW 80 #PH 48		| pixeles (PH = CH*2)

#pxb * 256000		| pixeles 320x200 (dword $RRGGBB)
#ovl * 32000		| texto superpuesto: caracter por celda
#ovc * 128000		| texto superpuesto: color por celda
#pal * 1024			| paleta de 256 colores
#heat * 66000		| fuego
#tang * 64000		| tunel: angulo
#tdep * 256000		| tunel: profundidad
#tfog * 64000		| tunel: niebla
#stx * 2048 #sty * 2048 #stz * 2048	| estrellas

#xx #yy
#running 1 #auto 1 #needinit 0
#scn 0 #t0 0 #tt 0 #fade 0 #fps 30 #dt 33 #tlast 0 #fstart 0

:tnow msec t0 - ;

|---------------- color
:rgb | r g b -- c
	swap 8 << or swap 16 << or ;

:unpack | c -- r g b
	dup 16 >> $ff and over 8 >> $ff and rot $ff and ;

:cmul | c v -- c' ; v 0..256
	>r dup 16 >> $ff and r@ * 8 >> 16 <<
	over 8 >> $ff and r@ * 8 >> 8 << or
	swap $ff and r> * 8 >> or ;

:cmix1 | s d a -- v
	>r over - r> * 8 >> + ;

#c1v #c2v #ma
:cmix | c1 c2 a -- c
	'ma ! 'c2v ! 'c1v !
	c1v 16 >> $ff and c2v 16 >> $ff and ma cmix1 16 <<
	c1v 8 >> $ff and c2v 8 >> $ff and ma cmix1 8 << or
	c1v $ff and c2v $ff and ma cmix1 or ;

:avg2 | a b -- c
	swap $fefefe and 1 >> swap $fefefe and 1 >> + ;

|---------------- paletas
#pr #pg #pb #pf #pt

:cosc | turns -- 0..255
	cos 65536 + 9 >> 255 min ;

:mkpal | f dr dg db --   ; paleta coseno (Inigo Quilez)
	'pb ! 'pg ! 'pr ! 'pf !
	0 ( 256 <?
		dup pf * 8 >> 'pt !
		pt pr + cosc
		pt pg + cosc
		pt pb + cosc
		rgb
		over 2 << 'pal + d!
		1+ ) drop ;

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
:onum | n -- ; 0..255
	10 <? ( 48 + ,c ; )
	100 <? ( 10 /mod swap 48 + ,c 48 + ,c ; )
	100 /mod swap 48 + ,c 10 /mod swap 48 + ,c 48 + ,c ;

:onum3 | r g b --
	rot onum 59 ,c swap onum 59 ,c onum ;

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
#otx #oty #otc

:ovok | -- 0/1
	otx 0 CW 1- in? ( 
		drop oty 0 CH 1- in? ( drop 1 ; ) drop 0 ; ) 
	drop 0 ;

:ovput | ch --
	ovok 0? ( 2drop 1 'otx +! ; ) drop
	oty CW * otx +
	swap over 'ovl + c!
	otc swap 2 << 'ovc + d!
	1 'otx +! ;

:ovchar | ch --
	32 >? ( ovput ; ) drop 1 'otx +! ;

:otext | "s" x y c --
	'otc ! 'oty ! 'otx !
	( c@+ 1? ovchar ) 2drop ;

:otextc | "s" y c --
	'otc ! 'oty ! 
	dup count nip CW swap - 1 >> 'otx !
	( c@+ 1? ovchar ) 2drop ;

|---------------- escena 0: SPECTRUM
:spec-init
	1.0 0 0.333 0.667 mkpal ;

#u #bd
:spec-px | -- color
	yy 6 * PH mod 6 <? ( drop 0 ; ) drop
	xx 255 * PW 1- 1 max / 'u !
	yy 6 * PH / 'bd !
	bd 0? ( drop u 16 << ; )
	1 =? ( drop u 8 << ; )
	2 =? ( drop u ; )
	3 =? ( drop u $010101 * ; )
	4 =? ( drop xx 256 * PW / tt 5 >> + palc ; )
	drop
	xx 256 * PW / tt 4 >> + palc
	255 yy 6 * PH mod 255 * PH / - cmul ;

:spec-frame
	'pxb >a
	0 ( PH <? dup 'yy !
		0 ( PW <? dup 'xx !
			spec-px da!+
			1+ ) drop
		1+ ) drop
	"RED      0..255" 2 CH 12 / $ffffff otext
	"GREEN    0..255" 2 CH 3 * 12 / $ffffff otext
	"BLUE     0..255" 2 CH 5 * 12 / $ffffff otext
	"GRAY     0..255" 2 CH 7 * 12 / $ffffff otext
	"RAIWBOW  (hue)" 2 CH 9 * 12 / $ffffff otext
	"HUE x VALOR  -  16.777.216 cols" 2 CH 11 * 12 / $ffffff otext ;

:spec-name "SPECTRUM  -  TRUECOLOR 24 BITS" ;

|---------------- escena 1: PLASMA
#ta #tb #tc #td #pcx #pcy
:plasma-px | -- color
	xx PW 16 <</ 3 * ta + sin
	yy PH 16 <</ 2 * tb + sin +
	xx PW 16 <</ yy PH 16 <</ + 2 * tc + sin +
	xx pcx - dup * yy pcy - dup * + sqrt 16 << PH / 3 * td + sin +
	10 >> tt 24 / + palc ;

:plasma-init
	1.0 0.0 0.15 0.4 mkpal ;

:plasma-frame
	tt 8 * 'ta ! tt 5 * 'tb ! tt 11 * 'tc ! tt 6 * 'td !
	tt 3 * sin PW 3 / *. PW 1 >> + 'pcx !
	tt 4 * cos PH 3 / *. PH 1 >> + 'pcy !
	'pxb >a
	0 ( PH <? dup 'yy !
		0 ( PW <? dup 'xx !
			plasma-px da!+
			1+ ) drop
		1+ ) drop ;

:plasma-name "PLASMA" ;

|---------------- escena 2: TUNEL
#ti #ts #tz
:tunnel-init
	2.0 0.0 0.1 0.25 mkpal
	0 ( PH <? dup 'yy !
		0 ( PW <? dup 'xx !
			yy PW * xx + 'ti !
			xx PW 1 >> - yy PH 1 >> -
			2dup atan2 6 >> $ff and ti 'tang + c!
			dup * swap dup * + sqrt 'td !
			PH 6 << td 1+ / ti 2 << 'tdep + d!
			td 510 * PH / 255 min ti 'tfog + c!
			1+ ) drop
		1+ ) drop ;

:tunnel-frame
	tt 3 >> 'ts ! tt 2 >> 'tz !
	'pxb >a
	0 ( PW PH * <? dup 'ti !
		ti 'tang + c@ $ff and ts +
		ti 2 << 'tdep + d@ 'td !
		td 3 >> +
		td tz + xor palc
		ti 'tfog + c@ $ff and cmul
		da!+
		1+ ) drop ;

:tunnel-name "TUNEL" ;

|---------------- escena 3: ROTOZOOMER
#dux #dvx #uu #vv
:shade | c -- c
	uu 17 >> vv 17 >> xor 1 and 0? ( drop ; ) drop 170 cmul ;

:roto-init
	1.0 0.55 0.7 0.85 mkpal ;

:roto-frame
	tt 12 * 'ta !
	ta cos tt 5 * sin 2/ 0.9 + *. 'dux !
	ta sin tt 5 * sin 2/ 0.9 + *. 'dvx !
	'pxb >a
	0 ( PH <? dup 'yy !
		PW 1 >> neg dux * yy PH 1 >> - dvx * - tt 700 * + 'uu !
		PW 1 >> neg dvx * yy PH 1 >> - dux * + tt 400 * + 'vv !
		0 ( PW <? 
			uu 18 >> vv 18 >> xor 3 << tt 5 >> + palc
			shade da!+
			dux 'uu +! dvx 'vv +!
			1+ ) drop
		1+ ) drop ;

:roto-name "ROTOZOOMER" ;

|---------------- escena 4: FUEGO
#fp #cool
:fseed | -- v
	xx 3000 * tt 3 * + sin xx 1100 * tt 2 * - sin + 
	1 >> 65536 + 9 >> 
	rnd $7f and 128 + * 8 >> 
	255 min ;

:fire-init
	firepal
	'heat 0 PW 2 + PH 2 + * cfill
	80000 PH / 'cool ! ;

:fire-px | -- v
	yy 1+ PW 2 + * xx + 'heat + 'fp !
	fp c@ $ff and fp 1+ c@ $ff and + fp 2 + c@ $ff and + fp PW 2 + + 1+ c@ $ff and +
	2 >>
	rnd $ff and cool + 8 >> -
	0 max ;

:fire-frame
	0 ( PW <? dup 'xx !
		fseed PH PW 2 + * xx + 1+ 'heat + c!
		fseed PH 1+ PW 2 + * xx + 1+ 'heat + c!
		1+ ) drop
	0 ( PH <? dup 'yy !
		0 ( PW <? dup 'xx !
			fire-px yy PW 2 + * xx + 1+ 'heat + c!
			1+ ) drop
		1+ ) drop
	'pxb >a
	0 ( PH <? dup 'yy !
		0 ( PW <? dup 'xx !
			yy PW 2 + * xx + 1+ 'heat + c@ palc da!+
			1+ ) drop
		1+ ) drop ;

:fire-name "FUEGO" ;

|---------------- escena 5: STARFIELD
:NST 360 ;
#si #sz #sdz #sxv #syv #sx #sy #sc

:star-new | i --
	2 << 
	4096 rndmax over 'stx + d!
	4096 rndmax over 'sty + d!
	255 rndmax 20 + swap 'stz + d! ;

:pset | c x y --
	PH >=? ( 3drop ; ) -? ( 3drop ; )
	swap PW >=? ( 3drop ; ) -? ( 3drop ; ) swap
	PW * + 2 << 'pxb + d! ;

#tx #ty #ln #li #sbd #strail
:star-draw
	si 29 * palc $ffffff 110 cmix 'sc !
	255 sz 3 * 2 >> - 1 max 'sbd !
	sxv PH * sz strail + 4 << / PW 1 >> + 'tx !
	syv PH * sz strail + 4 << / PH 1 >> + 'ty !
	tx sx - abs ty sy - abs max 1 max 40 min 'ln !
	0 ( ln <=? dup 'li !
		sc sbd 255 li 230 * ln / - * 8 >> cmul
		tx sx - li * ln / sx +
		ty sy - li * ln / sy +
		pset
		1+ ) drop
	sz 80 <? ( sc sx 1+ sy pset ) drop ;

:star-step | i --
	'si !
	si 2 << 'stz + d@ sdz - 'sz !
	sz 2 <? ( drop si star-new ; ) drop
	si 2 << 'stx + d@ 2048 - 'sxv !
	si 2 << 'sty + d@ 2048 - 'syv !
	sxv PH * sz 4 << / PW 1 >> + 'sx !
	syv PH * sz 4 << / PH 1 >> + 'sy !
	sz si 2 << 'stz + d!
	star-draw ;

:stars-init
	1.0 0.0 0.33 0.67 mkpal
	'pxb 0 PW PH * dfill
	0 ( NST <? dup star-new 1+ ) drop ;

:fadepx
	'pxb >a
	PW PH * ( 1? 1- 
		da@ dup $fcfcfc and 2 >> - da!+ ) drop ;

:stars-frame
	'pxb 0 PW PH * dfill
	dt tt 4 * sin 65536 + 13 >> 6 + * 6 >> 'sdz !
	sdz 4 * 3 + 'strail !
	0 ( NST <? dup star-step 1+ ) drop ;

:stars-name "STARFIELD" ;

|---------------- escena 6: COPPER BARS + SCROLLER
#scrtxt "   R3FORTH  -  COLORFORTH LIKE -  TRUECOLOR in terminal -  GREETINGS DEMOSCENE  -   "
#slen 0
#bi #bt #byc #bph #bbase #scrp

:cop-init
	1.0 0 0.333 0.667 mkpal
	'scrtxt count 'slen ! drop ;

:bgrow | y --
	dup 255 * PH / 'bt !
	$06061a $281050 bt cmix
	swap PW * 2 << 'pxb + swap PW dfill ;

:bar-fill | dy --
	dup byc +
	0 PH 1- in? (
		swap 16384 * bt / cos 8 >>
		dup dup * 8 >> dup * 8 >>
		>r bbase swap cmul $ffffff r> 1 >> cmix
		swap PW * 2 << 'pxb + swap PW dfill ; )
	2drop ;

:bar | i want --
	swap 'bi !
	tt 6 * bi 9362 * + 'bph !
	bph cos 63 >>> <>? ( drop ; ) drop
	bph sin PH 3 * 3 >> *. PH 1 >> + 'byc !
	bi 36 * tt 4 >> + palc 'bbase !
	PH 13 / 5 max 'bt !
	bt neg ( bt <=? dup bar-fill 1+ ) drop ;

:bars
	0 ( 7 <? dup 1 bar 1+ ) drop
	0 ( 7 <? dup 0 bar 1+ ) drop ;

:scroller
	tt 70 / 'scrp !
	0 ( CW <? dup 'otx !
		dup 1024 * tt 8 * + sin CH 12 / *. CH 5 * 6 / + 'oty !
		dup 8 * tt 6 >> + palc 'otc !
		scrp over + slen mod 'scrtxt + c@ ovchar
		1+ ) drop ;

:cop-frame
	0 ( PH <? dup bgrow 1+ ) drop
	bars scroller ;

:cop-name "COPPER BARS" ;

|---------------- tablas de escenas
#snames spec-name plasma-name tunnel-name roto-name fire-name stars-name cop-name
#sinit spec-init plasma-init tunnel-init roto-init fire-init stars-init cop-init
#sframe spec-frame plasma-frame tunnel-frame roto-frame fire-frame stars-frame cop-frame

|---------------- presentacion
#fs #cx #cy #tp #ct #cb

:celltext | ch --
	cy CW * cx + 2 << 'ovc + d@ setfg
	ct cb avg2 2 >> $3f3f3f and setbg
	,c ;

:cell
	cx 2 << tp + d@ 'ct !
	cx 2 << tp + PW 2 << + d@ 'cb !
	fade 256 <? ( ct fade cmul 'ct ! cb fade cmul 'cb ! ) drop
	cy CW * cx + 'ovl + c@
	1? ( celltext ; ) drop
	ct setfg cb setbg
	$e2 ,c $96 ,c $80 ,c ;

:scname | -- "name"
	scn 3 << 'snames + @ ex ;

#rl #rs #pd
:padn | n --
	( 1 >? 32 ,c 1- ) drop ;

:status
	$1b ,c 91 ,c CH 1+ ,d ";1H" ,s
	$1b ,c "[0;48;2;30;30;46;38;2;200;200;220m" ,s
	CH CW fps 7 scn 1+ scname "%s  %d/%d   %d fps   %dx%d " sprint
	count 'rl ! 'rs !
	CW rl - 'pd !
	" SPC/arrows scene   A auto   ESC exit" count
	pd swap - 1 >? ( swap ,s padn rs ,s ; )
	drop drop pd padn rs ,s ;

:present
	mark here 'fs !
	-1 'lfg ! -1 'lbg !
	0 ( CH <? dup 'cy !
		$1b ,c 91 ,c cy 1+ ,d ";1H" ,s
		cy 1 << PW * 2 << 'pxb + 'tp !
		0 ( PW <? dup 'cx !
			cell
			1+ ) drop
		1+ ) drop
	$1b ,c "[0m" ,s
	status
	.flush fs here fs - type empty ;

|---------------- control
:wrapsc | n -- n
	-? ( drop 6 ; )
	7 >=? ( drop 0 ; )
	;

:initscene
	scn 3 << 'sinit + @ ex ;

:setscene | n --
	wrapsc 'scn ! msec 't0 ! 0 'fade ! initscene ;

:setsize
|LIN|	.getterminfo
	cols 320 min 20 max 'CW !
	rows 1- 100 min 8 max 'CH !
	CW 'PW ! CH 1 << 'PH !
	.Reset .cls
	scn setscene ;

:resize 1 'needinit ! ;

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
	'ovl 0 CW CH * cfill
	scn 3 << 'sframe + @ ex
	tt 2500 <? ( scname 1 $ffffff otextc ) drop
	present ;

:main
	( running 1? drop
		msec 'fstart !
		needinit 1? ( 0 'needinit ! setsize ) drop
		frame
		auto 1? ( tt 12000 >? ( scn 1+ setscene ) drop ) drop
		keys
		33 msec fstart - - 1 max ms
		) drop ;

: 
	.alsb .hidec
	'resize .onresize
	setsize
	main
	.Reset .showc .masb .free ;
