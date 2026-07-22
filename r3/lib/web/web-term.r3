| terminal words -- WASM/browser via xterm.js
| PUERTO de win-term.r3.
|
| console.r3 (SIN CAMBIOS) solo necesita de esta capa:
|   type  ( str cnt -- )   escribe bytes crudos -- ya es ANSI/VT armado
|                           por console.r3, xterm.js lo interpreta
|                           directo, no hay parseo del lado JS
|   inkey ( -- key )        0 si no hay tecla, NO bloqueante
|   rows/cols                dimensiones actuales
|
| Todo lo Windows-especifico (GetStdHandle, SetConsoleMode, WriteFile,
| ReadConsoleInput, AllocConsole..) desaparece -- se reemplaza por 3
| imports resueltos del lado JS contra una instancia de xterm.js.
|-------------------------------------------------------------
^r3/lib/mem.r3
^r3/lib/parse.r3

##stdin ##stdout ##stderr | nombres por compatibilidad, sin uso real

|------- Basic Output -------
:type | str cnt --
	js_write ;                 | import: env.js_write(ptr,len) -> term.write(bytes)

##rows ##cols
#prevrc 0

:getterminfo
	js_getcols js_getrows 'cols ! 'rows ! ;

:getrc rows 16 << cols or ;

#on-resize 0
::.onresize | 'callback -- 'on-resize ! ;

:sizeex
	getrc prevrc =? ( drop ; ) 'prevrc !
	on-resize 0? ( drop ; ) ex ;

|------- Keyboard Input -------
| js_inkey devuelve 0 (nada pendiente) o un codigo ya traducido al
| mismo formato que evtkey en win-term.r3 -- la traduccion de
| secuencias ANSI ([UP] [F1] etc, ver tabla en console.r3) la hace
| el shim JS a partir de term.onData(), no hace falta reparsear aca.
::inkey js_inkey ;

::inevt | -- type
	js_resized 1? ( getterminfo sizeex 0 ; )
	inkey 0? ( drop 0 ; ) drop 1 ;

::getevt inevt ; | ver nota abajo -- SIN loop de espera real, ver Asyncify/tick

|------- Cleanup / Init -------
::.free ;    | no aplica, no hay consola real que liberar
::.reterm ;  | no aplica, no hay modos de consola que setear

:
	js_getcols js_getrows 'cols ! 'rows !
	getrc 'prevrc !
	;

|===========================================================================
| NOTA CRITICA -- getch/.input/waitkey/waitesc en console.r3 hacen:
|     ( inkey 0? drop N ms ) drop
| Esto es un loop BLOQUEANTE dentro de una sola llamada a WASM. En el
| browser esto NO PUEDE FUNCIONAR aunque 'ms' no bloquee de verdad:
| mientras el WASM esta corriendo synchronous, el event loop de JS no
| corre -- y term.onData() (que llena la cola que lee js_inkey) se
| dispara justamente desde ese event loop. Un spin-loop asi jamas va
| a ver una tecla nueva, sin importar que haga 'ms'.
|
| Dos salidas reales:
| 1) ASYNCIFY (Binaryen) -- transforma el .wasm para que esta func
|    pueda ceder control al browser y reanudar despues, dejando
|    getch/.input TAL CUAL estan hoy. Costo: pasada extra de build,
|    algo de overhead en las funciones marcadas async.
| 2) Restructurar: no llamar getch/.input desde el flujo principal.
|    Se reemplaza el spin-loop por UNA sola llamada a inkey por cada
|    tick(dt) desde requestAnimationFrame del lado JS -- el "esperar"
|    ya lo da el propio loop de rAF, 'ms' deja de hacer falta.
