| fire effect - efecto de fuego en terminal
| PHREDA 2025
^r3/lib/rand.r3
^r3/lib/console.r3

#buffer1    | buffer de intensidades actual
#buffer2    | buffer de intensidades siguiente
#bufsize    | tamaño del buffer

| Colores del fuego según intensidad
:firecolor | intensity -- color
	0? ( ; )
	80 <? ( drop 52 ; )    | rojo oscuro
	120 <? ( drop 88 ; )   | rojo
	160 <? ( drop 124 ; )  | rojo claro
	200 <? ( drop 226 ; )  | amarillo
	drop 231 ;                  | blanco

| Obtener valor del buffer con límites
:getval | x y -- val
	0 max rows min swap
	0 max cols min swap 
	cols * + buffer1 + c@ $ff and ;

| Promediar vecinos para propagación
:avgfire | x y -- avg
	1+ swap 3 randmax 1- + swap getval
	16 randmax 16 - + 0 max ;                     

| Actualizar toda la pantalla
:updatefire
	buffer2 >a
	0 ( rows <?
		0 ( cols <?
			2dup swap avgfire ca!+
			1+ ) drop
		1+ ) drop
	| intercambiar buffers
	buffer1 buffer2 'buffer1 ! 'buffer2 ! ;

| Dibujar fuego en pantalla
:drawfire
	.home
	buffer1 >a
	0 ( rows <?
|		1 over 1+ .at
		0 ( cols <?
			ca@+ $ff and
			dup firecolor 1? ( dup .fc ) drop
			5 >> $7 and " .*#@&$X" + c@ .emit
			1+ ) drop
		.cr
		1+ ) drop ;

| Generar fuego en la base
:makeheat
	buffer1 rows 1- cols * + >a
	cols ( 1? 1-
		100 randmax 155 + ca!+
	) drop ;

:main
	.home
	makeheat
	updatefire
	drawfire
	.flush
	inkey [esc] =? ( drop ; ) drop
	30 ms
	main ;

| Inicializar buffers
:reset
	empty mark
	.reset .cls
	cols rows * dup 'bufsize !
	here dup 'buffer1 !
	+ 'buffer2 !
	
	| limpiar buffers
	buffer1 0 bufsize cfill
	buffer2 0 bufsize cfill ;

:
.hidec
mark
reset
'reset .onresize
main
.reset .free ;
