| tank2 - francotirador
| no se mueve: barre con el radar y
| dispara cuando el enemigo esta en la mira

#radar 0.0	| direccion del radar
#blanco 0.0	| distancia al enemigo

:alineado | -- 1/0
	dir radar - $ffff and
	0.5 >? ( 1.0 swap - )
	0.015 <? ( drop 1 ; ) drop 0 ;

: 1 ( 1?
	radar scan 'blanco !
	blanco 0? ( 0.02 radar + $ffff and 'radar ! )
	1? ( radar turn alineado 1? ( blanco fire ) drop )
	drop
	) drop ;
