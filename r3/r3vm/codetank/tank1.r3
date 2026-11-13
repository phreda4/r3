| tank1 - tanque de ejemplo
| radar, persecucion y disparo.
| Los dos tanques corren este script.
|
| scan ( ang -- dist ) distancia al
|   enemigo en esa direccion, 0=nadie
| turn ( ang -- ) gira hacia ang
|   (0.0 arriba, 0.25 derecha)
| go ( v -- ) velocidad -1.0 .. 1.0
| fire ( dist -- ) bomba que explota
|   a esa distancia
| pos ( -- x y ) dir ( -- ang )
| batt ( -- n ) damage ( -- n )
| id ( -- n ) wait ( ticks -- )
| bear ( dx dy -- ang ) rumbo a un punto
| rand sin cos *. /. fix. int.

#radar 0.0	| direccion del radar
#blanco 0.0	| distancia al enemigo
#px #py

:alineado | -- 1/0
	dir radar - $ffff and
	0.5 >? ( 1.0 swap - )
	0.015 <? ( drop 1 ; ) drop 0 ;

:borde | -- 1/0 cerca de la pared?
	pos 'py ! 'px !
	px abs 190.0 >? ( drop 1 ; ) drop
	py abs 190.0 >? ( drop 1 ; ) drop
	0 ;

:centro | -- gira hacia el centro
	pos neg swap neg swap bear turn ;

:buscar | -- barre con el radar
	radar 0.02 + $ffff and 'radar !
	borde 1? ( centro ) drop
	0.5 go ;

:atacar | -- apunta, acerca y dispara
	radar turn
	blanco 110.0 >? ( 0.7 go ) 110.0 <=? ( 0 go ) drop
	alineado 1? ( blanco fire ) drop ;

: 1 ( 1?
	radar scan 'blanco !
	blanco 1? ( atacar ) 0? ( buscar ) drop
	) drop ;
