| osc.r3 - osciladores y ruidos: fase 0..1.0 (16 bits) -> valor -1.0..1.0, todos sin continua (media 0)
| Los ruidos tienen la misma firma que los osciladores: descartan la fase y solo generan.
| Solo hay formas que suenan distinto: la sierra invertida, la parabola, las "supersierras" de
| un oscilador y el seno al cuadrado sonaban igual que la sierra (o el seno una octava arriba), y el
| trapecio quedaba a menos de 4 dB de la triangular / seno3.
| Para una supersierra de verdad usar el instrumento isuper (supermix.r3).

^r3/lib/math.r3
^r3/lib/rand.r3

|---- OSC
| time -- val
::oscSaw	2* 1.0 - ;
::oscSqr	0.5 >? ( -1.0 nip ; ) 1.0 nip ;
::oscPul1	0.1 >? ( -0.2 nip ; ) 1.8 nip ;		| 10%: sin continua (alto 1.8, bajo -0.2)
::oscPul2	0.25 >? ( -0.5 nip ; ) 1.5 nip ;	| 25%: sin continua (alto 1.5, bajo -0.5)
::oscTri	$8000 and? ( $ffff xor ) 2 << 1.0 - ;
::oscSin	sin ;
::oscHSin	sin abs 0.6366 - ;				| seno rectificado sin continua (2/pi)
::oscSin3	sin dup dup *. *. ;				| seno + 3er armonico
::oscSinF	2* 1.0 - dup *. 2* 1.0 - 0.3333 + ;	| seno parabolico sin continua

|---- ruidos (phase -- v)
::oscWhite	drop -1.0 1.0 randminmax ;

#pinkc
#pink * 16
::oscPink							| rosa: Voss-McCartney
	drop pinkc ctz $7 and 1 << 'pink + rand swap w!
	1 'pinkc +!
	0 8 ( 1? 1- dup 1 << 'pink + w@ $ffff and rot + swap ) drop
	3 >> $8000 - 2* ;

#browna
::oscBrown							| marron, normalizado (el paseo aleatorio sale en +-0.27)
	drop browna 0.99 * 16 >>
	-0.02 0.02 randminmax +
	clamps16
	dup 'browna !
	3 * ;
