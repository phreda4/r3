| translate from hat code in BASIC
| from forth2020 facebook group
|
|------ original BASIC version for agon
|DIM rr(320)
|FOR i=0 TO 320
|  rr(i)=193
|NEXT i
|xp=144
|xr=4.171238905
|xf=xr/xp
|FOR zi=64 TO -64 STEP -2
|  zt=zi*2.25
|  zs=zt*zt
|  xl=INT(SQR(20736-zs)+0.5)
|  FOR xi=0-xl TO xl step .5
|    xt=SQR(xi*xi+zs)*xf
|    yy=(SIN(xt)+SIN(xt*3)*0.4)*56
|    x1=xi+zi+160
|    y1=90-yy+zi
|    IF x1<0 THEN GOTO 180
|    IF rr(x1)<=y1 THEN GOTO 180
|    rr(x1)=y1
|    PLOT 69,x1*4,850-y1*4+32
|  NEXT xi
|NEXT zi
|------
^r3/win/sdl2gfx.r3	

#RR * 2560 | 320 * 8
#ZS
#XL

:plot | x y --
	over 3 << 'rr + @  >? ( 2drop ; )
	2dup SDLPoint
	swap 3 << 'rr + ! ;

:FEDORA
	'rr 200 320 FILL
|	4.171238905 144.0 /. 'xf ! | = 0.0289
	64 ( -64 >?
		2.25 over * dup *. 'zs !
		20736.0 zs - sqrt. 0.5 + 'xl !
		xl neg ( xl <?
			dup dup *. zs + sqrt. 
			|0.0289 *. 6.2831853072 /. | convert to turn (XT)
			0.0047 *. | constant folding
			dup sin swap 3 * sin 0.4 *. + 56 *. |'yy ! |int
			90 swap - pick2 +			| y1
			pick2 pick2 int. + 160 + 	| x1
			swap						| x1 y1 
			plot
			0.5 + ) drop
		2 - ) drop ;
	
:demo
	0 sdlcls
	$ffffff sdlcolor	
	fedora
	SDLredraw
	sdlkey >esc< =? ( exit ) drop
	;
	
: 
	"hat" 320 200 SDLinit
	'demo SDLshow 
	SDLquit
	;