^r3/lib/math.r3
^r3/lib/rand.r3
^r3/lib/sdl2gfx.r3

|--------- constantes
#NB 64					| cantidad de cuerpos
#GDT 8.0				| gravedad*dt (delta de velocidad por paso)
#DT 0.04

|--------- body: 0 x  8 y  16 vx  24 vy  32 r  40 invm  48 rest  56 pad
#bodies * 8192			| NB*64 bytes

:body | n -- addr
	64 * 'bodies + ;

|--------- offsets de campo
:bx  ;
:by  8 + ;
:bvx 16 + ;
:bvy 24 + ;
:br  32 + ;
:bim 40 + ;
:bre 48 + ;

|--------- scratch geometria de par
#B2DX #B2DY #B2DIST #PEN #NX #NY #RVN #IMSUM #IMP #CORR #CI #CJ #II #IJ

|--------- A = cuerpo i, B = cuerpo j.  NX,NY apunta de j hacia i.
:pgeom | --
	a> bx @ b> bx @ - 'B2DX !
	a> by @ b> by @ - 'B2DY !
	B2DX dup *. B2DY dup *. + sqrt. 0? ( 'PEN ! ; ) 'B2DIST !
	a> br @ b> br @ + B2DIST - 'PEN !
	B2DX B2DIST /. 'NX !
	B2DY B2DIST /. 'NY ! ;

:applyimpulse | --
	a> bvx @ b> bvx @ - NX *.
	a> bvy @ b> bvy @ - NY *. + 'RVN !
	RVN 0.0 >=? ( drop ; ) drop
	a> bim @ b> bim @ + 'IMSUM !
	IMSUM 0.0 <=? ( drop ; ) drop
	a> bre @ b> bre @ min 1.0 + RVN *. neg IMSUM /. 'IMP !
	a> bim @ IMP *. 'II !
	b> bim @ IMP *. 'IJ !
	| i se aleja de j (+N) ; j se aleja de i (-N)
	a> bvx @ II NX *. + a> bvx !
	a> bvy @ II NY *. + a> bvy !
	b> bvx @ IJ NX *. - b> bvx !
	b> bvy @ IJ NY *. - b> bvy !
	;

:posresolve | --
	a> bim @ b> bim @ + 'IMSUM !
	IMSUM 0.0 <=? ( drop ; ) drop
	PEN 0.8 *. IMSUM /. 'CORR !
	a> bim @ CORR *. 'CI !
	b> bim @ CORR *. 'CJ !
	a> bx @ CI NX *. + a> bx !
	a> by @ CI NY *. + a> by !
	b> bx @ CJ NX *. - b> bx !
	b> by @ CJ NY *. - b> by !
	;

:collide | --
	pgeom
	PEN 0.0 <=? ( drop ; ) drop
	applyimpulse
	posresolve ;

:steppairs
	0 ( NB <?
		dup 1+
		( NB <?
			over body >a dup body >b
			collide
			1+ ) drop
		1+ ) drop ;

|--------- integrar + paredes  (A = cuerpo actual)
#SCRW #SCRH

:integrate | --
	a> bvy @ GDT + a> bvy !
	a> by @ a> bvy @ DT *. + a> by !
	a> bx @ a> bvx @ DT *. + a> bx !
	;

:wallx | --
	a> bx @ a> br @ - 0.0 <? (
		a> br @ a> bx !
		a> bvx @ neg a> bre @ *. a> bvx ! )
	drop
	a> bx @ a> br @ + SCRW fix. >? (
		SCRW fix. a> br @ - a> bx !
		a> bvx @ neg a> bre @ *. a> bvx ! )
	drop ;

:wally | --
	a> by @ a> br @ - 0.0 <? (
		a> br @ a> by !
		a> bvy @ neg a> bre @ *. a> bvy ! )
	drop
	a> by @ a> br @ + SCRH fix. >? (
		SCRH fix. a> br @ - a> by !
		a> bvy @ neg a> bre @ *. a> bvy ! )
	drop ;

:stepbodies
	0 ( NB <?
		dup body >a
		integrate
		wallx
		wally
		1 + ) drop ;

|--------- init
:newbody | n --
	body >a
	10.0 sw fix. randminmax a!+
	10.0 sh 2/ fix. randminmax a!+
	0.0 a!+ 0.0 a!+					| vx vy
	5.0 20.0 randminmax a!+			| r
	1.0 a!+							| invm
	0.6 a!+							| rest
	0.0 a!+ 						| pad
	;

:initbodies
	0 ( NB <?
		dup newbody
		1 + ) drop ;

:drawbodies
	0 ( NB <?
		dup body >a
		a> br @ int. a> bx @ int. a> by @ int.
		fcircle
		1+ ) drop ;

:key&mouse
	SDLkey
	>esc< =? ( exit )
	drop ;

:box2dlite
	$102030 cls
|	10 10 bat "box2d-lite (sequential impulses)" bprint
	$00aefa color
	drawbodies
	stepbodies
	steppairs
	key&mouse
	SDLredraw ;

:
	"r3sdl" 800 600 SDLinit
	sw 'SCRW ! sh 'SCRH !
	initbodies
	'box2dlite SDLshow
	SDLquit ;
