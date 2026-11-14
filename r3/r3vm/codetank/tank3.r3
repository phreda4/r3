| tank3 - arremetedor
| busca al enemigo y va derecho hacia el
| disparando cuando esta cerca

#radar 0.0	| direccion del radar
#blanco 0.0	| distancia al enemigo

: 1 ( 1?
	radar scan 'blanco !
	blanco 0? ( 0.03 radar + $ffff and 'radar ! 0.6 go )
	1? ( radar turn 1.0 go blanco 140.0 <? ( blanco fire ) drop )
	drop
	) drop ;
