| TORUS.R3 - Toro 3D giratorio, pantalla completa y color (256 colores)
| Algoritmo "donut.c" de Andy Sloane, adaptado a r3forth
| ESC = salir
|
^r3/lib/console.r3
^r3/lib/math.r3

| ---- buffers (maximo 400 x 120 celdas) ----
#zbuf * 192000	| 1/z por celda (dword, 16.16)
#cbuf * 48000	| caracter por celda
#kbuf * 48000	| color 256 por celda

| ---- pantalla ----
#SW 0 #SH 0		| celdas usadas
#K1 0			| escala de proyeccion (16.16)
#nth 0 #nph 0	| muestras por vuelta: tubo / anillo
#tw 0 #th 0

| ---- geometria (16.16) ----
#fp1 0.8		| radio del tubo
#fp2 2.2		| radio del anillo
#K2  7.0		| distancia ojo - centro

| ---- animacion ----
#angA 0 #angB 0
#cosA #sinA #cosB #sinB
#hf 0			| fase del arcoiris
#hue 0			| fila de paleta de la muestra
#ph 0

| ---- temporales por muestra ----
#ct #st #cp #sp #cxr
#px #py #pz #rx #ry #rz
#nx #ny #nz #rnx #rny #rnz
#ooz #sc #xp #yp #idx #lum

| ---- rampa de luminancia (12 niveles) ----
#lc ".,-~:;=!*#$@"

| ---- paleta: 24 tonos x 12 brillos -> color 256 ----
#pal * 288
#tt #cr #cg #cb #bv #bw

:c01 0 max 1.0 min ;

:q6 | v -- 0..5
	bw + c01 5 * $8000 + 16 >> ;

:mkcol | brillo -- color256
	dup 45875 * 11 / 19661 + 'bv !
	9 - 0 max 3200 * 'bw !
	cr bv *. q6 36 *
	cg bv *. q6 6 * +
	cb bv *. q6 + 16 + ;

:mkpal | --
	0 ( 24 <?
		dup 16 << 24 / 'tt !
		tt 6 * 3.0 - abs 1.0 - c01 'cr !
		tt 6 * 2.0 - abs 2.0 swap - c01 'cg !
		tt 6 * 4.0 - abs 2.0 swap - c01 'cb !
		0 ( 12 <?
			dup mkcol
			pick2 12 * pick2 + 'pal + c!
			1+ ) drop
		1+ ) drop ;

| ---- tamano ----
:setsize | --
	| K1 = min(ancho, 2*alto) : celdas ~1:2
	SW SH 1 << min 16 << 'K1 !
	K1 16 >> 5 * 4 / 500 min 40 max 'nth !
	nth 2 << 'nph !
	|mktheta
	.Reset .cls ;

:termsize | -- w h
|LIN|	.getterminfo cols 1+ rows 1+ ;
|WIN|	cols rows ;

:checksize | --
	termsize 120 min 10 max 'th ! 400 min 20 max 'tw !
	tw SW <>? ( drop ; ) drop
	th SH <>? ( drop ; ) drop ;

:resize? | --
	termsize 120 min 10 max 'th ! 400 min 20 max 'tw !
	tw SW =? ( drop th SH =? ( drop ; ) )
	drop
	tw 'SW ! th 'SH !
	setsize ;

| ---- helpers ----
:clrbufs | --
	'zbuf 0 SW SH * 2 << cfill
	'cbuf 32 SW SH * cfill
	'kbuf 0 SW SH * cfill ;

:cachetrig | --
	angA cos 'cosA !   angA sin 'sinA !
	angB cos 'cosB !   angB sin 'sinB ! ;

| ===== una muestra del toro =====
:dotsample | i --
	16 << nth / sincos 'ct ! 'st !
	
	ct fp1 *. fp2 + 'cxr !

	cxr cp *. 'px !
	cxr sp *. 'py !
	st fp1 *.  'pz !

	ct cp *. 'nx !
	ct sp *. 'ny !
	st       'nz !

	| rotacion A (eje Y)
	px cosA *. pz sinA *. + 'rx !
	pz cosA *. px sinA *. - 'rz !
	py 'ry !
	nx cosA *. nz sinA *. + 'rnx !
	nz cosA *. nx sinA *. - 'rnz !
	ny 'rny !

	| rotacion B (eje X)
	ry cosB *. rz sinB *. -
	rz cosB *. ry sinB *. +
	'rz ! 'ry !
	rny cosB *. rnz sinB *. -
	rnz cosB *. rny sinB *. +
	'rnz ! 'rny !

	| proyeccion
	1.0 K2 rz + /. 'ooz !
	ooz K1 *. 'sc !
	rx sc *. 16 >> SW 2/ + 'xp !
	SH 2/ ry sc *. 17 >> - 'yp !
	xp 0 <? ( drop ; ) SW >=? ( drop ; )
	yp 0 <? ( 2drop ; ) SH >=? ( 2drop ; )
	SW * + 'idx !

	| z-buffer: gana el mas cercano (mayor 1/z)
	idx 2 << 'zbuf + d@ ooz >=? ( drop ; ) drop
	ooz idx 2 << 'zbuf + d!

	| luz desde arriba-frente: L = (0, .707, -.707)
	rny rnz - 46341 *. 0 max 11 * 16 >> 11 min 'lum !
	lum 'lc + c@ idx 'cbuf + c!
	hue lum + 'pal + c@ idx 'kbuf + c! ;

:renderframe | --
	clrbufs cachetrig
	0 ( nph <?
		dup 16 << nph / 'ph !
		ph cos 'cp ! ph sin 'sp !
		ph 24 * 16 >> hf 3 >> + 24 mod 12 * 'hue !
		0 ( nth <? dup dotsample 1+ ) drop
		1+ ) drop ;

| ===== buffer -> terminal =====
#lk -1
#tf 0

:setcol | k --
	lk =? ( drop ; )
	dup 'lk ! .fc ;

:putcell | idx --
	dup 'cbuf + c@ 32 =? ( .emit drop ; )
	over 'kbuf + c@ $ff and setcol .emit drop ;

:flushscreen | --
	.home -1 'lk !
	0 ( SH <?
		0 ( SW <?
			over SW * over + putcell
			1+ ) drop
		SH 1- <? ( .cr )
		1+ ) drop
	.flush ;

:spin | --
	0.006 'angA +! 0.009 'angB +! 1 'hf +! ;

:main
	mkpal
	.alsb .hidec
	0 'SW ! 0 'SH !
	( inkey [esc] <>? drop
		msec 'tf !
		resize?
		renderframe
		flushscreen
		spin
		tf 33 + msec - 1 max ms
		) drop
	.Reset .cls .masb .showc .flush ;

: main ;
