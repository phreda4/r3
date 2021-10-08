| Programa 1
| consola
^r3/win/console.r3

|---- Dato
#nro

|---- Codigo
:repeticion | *** Repeticion
	0 ( nro <?
		dup "%d " .print 
		1 + ) drop
	cr
	;

:condicion | *** Condicion
	nro
	50 >? ( "Es mayor a 50 " .print cr )
	50 <? ( "Es menor a 50 " .print cr )
	drop
	;
	
: |*** Inicio
	.cls
	"Cual es tu nombre ? " .print 
	.input cr						| la entrada se encunetra en 'pad
	'pad " Hola %s!" .print cr
	
	"Cuantos numeros ? " .print
	.inputn 'nro ! cr				| el numero se encuentra en la pila

	repeticion
	condicion
	
	.input cr						| espera
;