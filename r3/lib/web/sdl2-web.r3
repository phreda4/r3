| SDL2 -- WASM/browser, via Canvas2D
| PUERTO de sdl2.r3: SDLinit/SDLmini/SDLupdate/SDLredraw/SDLshow/changews
| NO CAMBIAN -- siguen llamando a estos mismos nombres de palabra.
| Lo unico que cambia es COMO se resuelven: antes via loadlib+getproc+sysN,
| ahora import directo (mismo patron que type/inkey en web-term.r3).
| Requiere el mismo fix pendiente en gwor (distinguir palabra-import de
| palabra interna) que quedo anotado para consola.
|-------------------------------------------------------------
^r3/lib/console.r3
^r3/lib/sdlkeys.r3

| ---- subset cubierto (nucleo de render 2D + eventos + timing) -------
::SDL_Init          js_SDL_Init ;
::SDL_Quit           js_SDL_Quit ;
::SDL_CreateWindow    js_SDL_CreateWindow ;      | titulo x y w h flags -- win
::SDL_DestroyWindow    js_SDL_DestroyWindow ;
::SDL_RaiseWindow       js_SDL_RaiseWindow ;      | no-op, ver comentario abajo
::SDL_SetWindowFullscreen js_SDL_SetWindowFullscreen ;
::SDL_GetWindowSize     js_SDL_GetWindowSize ;
::SDL_SetWindowSize     js_SDL_SetWindowSize ;
::SDL_ShowCursor         js_SDL_ShowCursor ;

::SDL_CreateRenderer     js_SDL_CreateRenderer ;   | win idx flags -- rend
::SDL_DestroyRenderer    js_SDL_DestroyRenderer ;
::SDL_SetRenderDrawColor js_SDL_SetRenderDrawColor ;
::SDL_RenderClear        js_SDL_RenderClear ;
::SDL_RenderPresent      js_SDL_RenderPresent ;
::SDL_RenderDrawPoint    js_SDL_RenderDrawPoint ;
::SDL_RenderDrawLine     js_SDL_RenderDrawLine ;
::SDL_RenderDrawRect     js_SDL_RenderDrawRect ;
::SDL_RenderFillRect     js_SDL_RenderFillRect ;
::SDL_RenderCopy         js_SDL_RenderCopy ;
::SDL_RenderCopyEx       js_SDL_RenderCopyEx ;

::SDL_CreateTexture      js_SDL_CreateTexture ;
::SDL_UpdateTexture      js_SDL_UpdateTexture ;
::SDL_DestroyTexture     js_SDL_DestroyTexture ;
::SDL_QueryTexture       js_SDL_QueryTexture ;

::SDL_PollEvent          js_SDL_PollEvent ;        | &evt -- ok  (evt ya viene
                                                     | con el layout real,
                                                     | ver shim JS)
::SDL_Delay              js_SDL_Delay ;             | ver nota de bloqueo abajo
::SDL_GetTicks           js_SDL_GetTicks ;
::SDL_GetError           js_SDL_GetError ;

| ---- todavia no portado (mismo patron, mecanico, pedimelo) ----------
| audio: SDL_OpenAudioDevice/QueueAudio/.. -> Web Audio API
| clipboard: SDL_*ClipboardText -> navigator.clipboard
| RWops: SDL_RWFromFile/RWclose -> VFS (ver conversacion sobre I/O virtual)
| GL: SDL_GL_* -> WebGL2 context -- ES UN LABURO APARTE, no es 1:1

| ---- SDLshow -- reescrito SIN while bloqueante interno ---------------
| Original en sdl2.r3: ::SDLshow | 'word --
|     0 '.exit ! ( .exit 0? drop SDLupdate dup ex ) 2drop SDLupdate 0 '.exit ! ;
| Ese WHILE corria SDL_Delay+SDL_PollEvent dentro de UNA llamada WASM --
| no puede funcionar en el browser (bloquea el hilo, y el propio
| listener que llena la cola de eventos depende de que el event loop
| de JS corra). Se separa en dos: SDLshow arranca el estado (una vez),
| SDLtick hace UNA iteracion -- requestAnimationFrame llama a SDLtick
| repetidamente (ver shim JS).
##SDLrenderword

::SDLshow | 'word --   ( arranca: guarda la palabra a renderizar )
	'SDLrenderword ! 0 '.exit ! ;

::SDLtick | --   ( UNA iteracion -- exportar y llamar desde rAF )
	.exit 0? ( drop ; )
	SDLupdate
	SDLrenderword ex ;

| ---- expone la direccion real de 'SDLevent para que el shim JS sepa
| ---- donde escribir (evita hardcodear el offset del lado JS).
| NOTA: no se el mecanismo real de r3 para marcar un word exportado del
| modulo WASM (pragma de compilador, no sintaxis de fuente) -- ajustar
| a como sea que tu backend ya lo resuelve para gwor exportado:
::get_sdlevent_addr 'SDLevent ;
