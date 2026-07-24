# Mapa de memoria del debugger r3d4

*Fuentes: `r3debug.r3`, `infodebug.r3`, `memshare.r3` (lado debugger) +
`r3d.cpp` (intérprete/VM del lado depurado, confirmado directamente).*

Dos procesos separados (debugger TUI + programa depurado `r3lind`) comunicados
por **4 bloques de memoria compartida** (POSIX `shm_open`+`mmap` en Linux,
`CreateFileMapping`+`MapViewOfFile` en Windows). Definidos en `infodebug.r3`:

```
#vshare 0 0 4096 "/debug.mem"   | estado de la VM (registros, control)
#bshare 0 0 64   "/bp.mem"      | lista de breakpoints
#dshare 0 0 0    "/data.mem"    | espejo del data segment del programa
#cshare 0 0 0    "/code.mem"    | espejo del code segment (bytecode)
```

Cada `#xshare` reserva 4 words (32 bytes) con este layout fijo
(`memshare.r3`, comentario `mapfile size filename` en offsets 0/8/16/24):

| offset | campo      | contenido                                    |
|--------|------------|-----------------------------------------------|
| +0     | `mapfile`  | handle del mapping (fd en Linux, HANDLE en Win) |
| +8     | `mem`      | puntero a la memoria mapeada (esto es lo que se usa como base) |
| +16    | `size`     | tamaño en bytes del bloque                    |
| +24    | `filename` | nombre del objeto compartido (string estático)|

`inisharev` hace `shm_open`+`mmap` (o crea si no existe) y guarda el puntero
resultante en offset +8. Todo acceso real usa `vshare @` (que en realidad,
por cómo Forth resuelve la variable, apunta ya al puntero de +8 vía la
definición de la palabra — ver detalle abajo).

---

## 1. `vshare` — estado de la VM (4096 bytes)

Word (8 bytes) por slot, offset = `slot * 8`:

| slot | word         | acceso                          | contenido |
|------|--------------|----------------------------------|-----------|
| 0    | `vmSTATE`    | `vshare @`                       | comando/estado: `0`=stop `1`=play `2`=step `3`=stepover `4`=(loop interno de stepover) `5`=stepout `0xfe`=end |
| 1    | `vmINFO`     | `vshare 1 3 << + @`              | (reservado / info extra) |
| 2    | `vmIP`       | `vshare 2 3 << + @`              | instruction pointer actual (índice en el bytecode) |
| 3    | `vmTOS`      | `vshare 3 3 << + @`              | top of data stack |
| 4    | `vmNOS`      | `vshare 4 3 << + @`              | cantidad de elementos por debajo del TOS (offset del stack, no "next on stack") |
| 5    | `vmRTOS`     | `vshare 5 3 << + @`              | cantidad de elementos en el return stack |
| 6    | `vmREGA`     | `vshare 6 3 << + @`              | registro A de la VM |
| 7    | `vmREGB`     | `vshare 7 3 << + @`              | registro B de la VM |
| 8..511   | `vmDS`   | `vshare 8 3 << + ` (base)        | **data stack** del programa depurado (504 words) |
| 512..1023| `vmRS`   | `vshare 512 3 << + ` (base)      | **return stack** del programa depurado |

Comandos que el debugger escribe en slot 0 para controlar la ejecución
(`*>play`, `*>step`, `*>stepo`, `*>stepu`, `*>stop`, `*>end`):

```
*>stop   ->  0     detener / esperar
*>play   ->  1     correr libre (hasta breakpoint/error/tecla)
*>step   ->  2     step into
*>stepo  ->  3     step over (4 es el estado interno mientras loopea)
*>stepu  ->  5     step out / until return
*>end    ->  0xfe  terminar el programa depurado
```

El debugger hace **polling** de `vmSTATE`: mientras valga `1` sigue en play;
si vuelve a `0` es que el programa paró (breakpoint o fin de step);
si supera `0xff` (`$ff >?`) es `runtimerror` (ver `errorst`).

### Errores runtime (`.strerr`)

`vmSTATE` guarda el error tal como lo produce `r3d.cpp` (`playr3`/`checkr3`/
`error_filter`/`error_handler`); `stoponerror` (infodebug.r3) hace
`vmState 8 >>` para extraer el código y lo escribe en `errorst`.

| origen                        | código crudo (`vmstate`) | llega a `errorst` como |
|--------------------------------|---------------------------|------------------------|
| `checkr3()` underflow           | `0x10000`                 | `$100` ✓ |
| `checkr3()` overflow            | `0x20000`                 | `$200` ✓ |
| SIGILL (Linux)                  | `4<<8`                    | `$4` |
| SIGABRT (Linux)                 | `6<<8`                    | `$6` |
| SIGBUS (Linux)                  | `7<<8`                    | `$7` |
| SIGFPE (Linux, incl. div/0)     | `8<<8`                    | `$8` |
| SIGSEGV (Linux, memoria inválida)| `11<<8` (`0xb`)          | `$b` |
| SIGPIPE (Linux)                 | `13<<8` (`0xd`)           | `$d` |
| excepción Windows (NTSTATUS)    | `code<<8` (32 bits, no se trunca) | `$c0000005` (access violation), etc. |

⚠️ **`.strerr` en `r3debug.r3` está desactualizado**: hoy compara contra
`$5` (memoria) y `$94` (div/0), que **no corresponden a ningún código real**
que emita `r3d.cpp` — esos dos casos nunca muestran mensaje (caen al `drop`
final, texto vacío). Solo `$100`/`$200` matchean correctamente. Ver detalle
y corrección propuesta en la sección "Bugs conocidos" más abajo.

---

## 2. `bshare` — breakpoints (64 bytes)

Lista lineal de **doubles (8 bytes)**, cada entrada es un `token` (índice de
posición en `codesrc`, no una dirección de bytecode real):

```
clearbp   ->  bshare 0 over d! 'bplist> !      | reset: primer slot = 0 (terminador)
addbp bp  ->  bplist> d!+ 0 over d! 'bplist> ! | agrega bp, mantiene terminador 0 al final
inbp? bp  ->  recorre y compara                | ¿existe ya este bp?
delbp adr ->  compacta el arreglo               | borra shifteando el resto
```

Formato de cada entrada (`token`, ver `ftoken>token`/`token>ftoken`):
```
token = (posición_en_codesrc - codesrc) / 8 + 1
```
Es un índice a una entrada del arreglo `codesrc` (ver sección 4), **no** un
IP de bytecode directo — el mapeo a IP real lo hace `ftokenIP`/`showbreakpoint`
comparando contra `codesrc[vmIP-1]`.

⚠️ Actualmente `bshare` solo guarda la posición del breakpoint — **no hay
campo para condición** (tipo "romper si TOS = N"). Ver sección "Extensiones".

---

## 3. `dshare` — espejo del data segment (tamaño dinámico = `memdsize`)

Memoria de datos del programa depurado, mapeada 1:1. Offset de traducción:

```
dataoff = dshare - memdata      (calculado en 'precalc')
```

Para leer una variable del programa target conociendo su dirección real
(`memdata`-relativa, la que reporta el diccionario), hay que sumar `dataoff`.
Actualmente **no se usa para watch de variables** — solo se mapea y queda
disponible.

---

## 4. `cshare` — espejo del code segment / bytecode (tamaño dinámico = `memcsize`)

Contiene el bytecode compilado del programa, confirmado contra el intérprete
real (`r3d.cpp`): `memcode` es un arreglo de `__int64`, cada instrucción
ocupa **1 word de 8 bytes** (`register __int64 op = memcode[ip++]`), con el
opcode en los 8 bits bajos (`op & 0xff`, ver `case CALL/JMP/...`) y el
operando empaquetado en los bits altos (`op >> 8`). `ip` avanza de a 1 por
instrucción simple (no de a 8 bytes) — es un índice a word, no un offset en
bytes. Se desensambla con la tabla `tokenstr`/`tokencnt` de `infodebug.r3`.

```
memtokn = cshare + (vmIP << 3) @   | token crudo en la posición del IP actual
                                     | (offset en BYTES: vmIP es índice de
                                     | word de 8 bytes, por eso <<3)
memtok  = memtokn -> .token         | convierte a mnemónico string
```

⚠️ El código actual de `infodebug.r3` usa `2 << cshare + d@` (shift de 2,
lectura de dword de 4 bytes) para `memtokn` — no coincide con el layout
real de 8 bytes por instrucción confirmado en `r3d.cpp`. Si el desensamblado
en pantalla se ve corrido/incorrecto, este es un buen primer lugar para
revisar (posible bug adicional, no confirmado en ejecución real).

`.token`: busca en `tokenstra` (tabla de offsets de 2 bytes) para resolver
rápido el string del mnemónico sin recorrer `tokenstr` completo.

`token>cnt`: cuántos words de operando le siguen al token (0, 1, 2 o 3),
según tabla `tokencnt` — necesario para desensamblar avanzando el puntero
correctamente instrucción por instrucción.

---

## 5. Diccionario (`realdicc` / `localdicc` / `cntdicc`)

Cargado una sola vez al iniciar (`run&loadinfo`, desde `mem/r3dicc.mem` +
`mem/r3code.mem` que escribe el propio programa target al arrancar).

Cada entrada de diccionario es **1 word (8 bytes)** con este empaquetado
(comentario en `infodebug.r3`):

```
v = (inc<<56) | (pos<<40) | (dicc[i].mem<<8) | dicc[i].info
```

| campo | bits    | significado |
|-------|---------|-------------|
| inc   | 56..63  | número de include donde está definida la palabra |
| pos   | 40..55  | posición dentro del include (offset en el string de nombres) |
| mem   | 8..39   | dirección de memoria (código o dato) de la palabra |
| info  | 0..7    | flags (bit `$8` = tiene boot-chain, según `defwor`) |

### Acceso

```
ndicc@ n        -> ( n 3 << realdicc + @ )     | entrada cruda de la palabra n (0..cntdicc-1)
dicc>name nd    -> ( nd 40 >> $ffff and realdicc cntdicc 3 << + + )
                                                | puntero al string de nombre
                                                | (los nombres viven pegados
                                                | después del arreglo de
                                                | entradas, offset = pos)
```

`cntdicc` = cantidad total de palabras. `localdicc` = índice desde donde
empiezan las palabras "locales" (definidas en el propio archivo, no en libs
incluidas) — usado por `makelistwords` para listar solo esas en el panel
watch (`scrDicc`, hoy deshabilitado).

`xwriten.word` es la función usada por el widget de lista (`tuListn`) para
imprimir cada entrada: `#n → nombre` con color según tipo (`wcolor`: `:`=código
naranja, `#`=variable azul, chequeando bit `$10` de `info`... revisar exacto
en runtime).

---

## 6. Mapa fuente ↔ token (`codesrc` / `codedicc`) — reconstruido en el debugger

Este mapa **no viene del programa target**: el propio `r3debug.r3` vuelve a
tokenizar el código fuente (`makemapdebug` → `translatecode`/`wrd2token`)
para poder correlacionar `IP` con posición exacta en el archivo `.r3`.

Arreglo `codesrc` — 1 entrada (8 bytes) por **token de código fuente**
(cada palabra, número, string, etc. que compone el programa), en el mismo
orden en que el compilador los emitió, por lo tanto **el índice coincide
1:1 con el IP de la VM**:

```
ftoken = (inc<<48) | (cnt<<40) | (pos<<24) | (xc<<12) | yc
```

| campo | bits    | significado |
|-------|---------|-------------|
| inc   | 48..55  | include (archivo fuente) donde vive el token |
| cnt   | 40..47  | cantidad de caracteres que ocupa el token en el fuente |
| pos   | 24..39  | posición (offset) del token dentro del string fuente |
| xc    | 12..23  | columna en pantalla |
| yc    | 0..11   | fila en pantalla |

### Acceso

```
ftokenIP        -> codesrc + (vmIP-1)*8 @        | ftoken del token en el IP actual
findtoken pos   -> recorre codesrc buscando el   | dado un offset de texto,
                    entry cuyo rango contiene pos |   encuentra su índice/token
token>ftoken tk -> codesrc + (tk-1)*8             | dirección del ftoken dado el índice
ftoken>token adr-> (adr - codesrc)/8 + 1          | índice dado la dirección
```

`codedicc` es análogo pero para las **definiciones** (`:palabra` / `#var`)
en vez de cada token — usado para saber en qué línea empieza cada palabra
definida en el archivo (`finddicc`).

---

## 7. Resumen de flujo de arranque

```
main (r3debug.r3)
  └─ run&loadinfo                    (infodebug.r3)
       ├─ buildtokenstr              construye tabla rápida de mnemónicos
       ├─ lanza "./r3lind <archivo>" como subproceso (sysnew)
       ├─ espera a que aparezca mem/r3dicc.mem (polling, 200ms)
       ├─ carga mem/r3code.mem       -> cntdicc, localdicc, boot, memc, memd,
       │                                memdsize, memcsize, memcode, memdata,
       │                                mdatastack, mretstack, cntinc, strinc
       ├─ carga mem/r3dicc.mem       -> realdicc (diccionario completo)
       ├─ dshare/cshare: setean tamaño real (memdsize/memcsize)
       └─ inisharev x4               mapea vshare, bshare, dshare, cshare
  └─ makemapdebug                    (infodebug.r3)
       └─ reconstruye codesrc/codedicc tokenizando el/los .r3 en el debugger
  └─ clearbp
  └─ maindb (loop TUI, onTuia)
       ├─ lee vmSTATE/vmIP -> dibuja código+stacks
       ├─ uiKey -> F3 breakpoint, F5 play, F7/F8/F9 step
       └─ checkerror
  └─ debugend
       └─ *>end + endsharev x4
```

---

## 8. Bugs conocidos

### a) Error en un include no se muestra en el lugar correcto (F5 / `playmode`)

Cuando el programa está corriendo con F5 y el error ocurre en un archivo
`^incluido` distinto del que el debugger tenía abierto al arrancar el play,
la pantalla se queda mostrando el archivo/posición viejos.

Causas combinadas:

1. **`playshow` ignora redibujados fuera del include inicial.** Filtra con
   `dup 48 >> $ff and codenow <>? ( 2drop ; )` — mientras el IP corre dentro
   de un include distinto a `codenow` (fijado una sola vez al entrar a
   `playmode`), el debugger nunca actualiza pantalla.
2. **`runtimerror` no resincroniza el include.** Solo escribe el mensaje de
   error en el statusline; nunca llama `showcode` con el include real donde
   ocurrió el error, ni reposiciona el cursor (`tuipos!`).
3. **El "land in src" de `playmode` corre incluso en estado de error**,
   mandando `*>stepo` cuando debería mostrar el error tal cual está.

`stoponerror` (infodebug.r3) sí calcula bien el include/posición real
(`vmIP -= 1` antes de reportar) — el dato disponible es correcto, el
problema es enteramente de UI en `r3debug.r3` al no usarlo.

**Fix**: en `playmode`, antes del bloque "land in src", detectar error y
llamar `showcode`+`tuipos!` con el include/posición reales sacados de
`ftokenIP`, evitando el `*>stepo` posterior en ese caso.

### b) `.strerr` no reconoce los códigos de error reales

`.strerr` compara `errorst` contra `$5` y `$94` para "Invalid memory" y
"divide by 0" — códigos que **no corresponden a lo que emite `r3d.cpp`**.
El intérprete señaliza vía `signal()` (Linux) o `SetUnhandledExceptionFilter`
(Windows), y el código que llega a `errorst` es la señal POSIX cruda
(`SIGSEGV=$b`, `SIGFPE=$8`, `SIGBUS=$7`, etc.) o el NTSTATUS de 32 bits en
Windows — nunca `$5`/`$94`. Solo `$100`/`$200` (under/overflow, que vienen
de `checkr3()` con otro formato) matchean correctamente hoy.

**Efecto**: ante un crash real (segfault, div/0), el debugger muestra
"* RUNTIME ERROR: $b *" sin descripción, en vez del mensaje esperado.

**Fix**: actualizar `.strerr` para comparar contra los códigos de señal
reales (ver tabla de la sección 1), idealmente condicionado por plataforma
(`|WIN|`/`|LIN|`) ya que Windows usa NTSTATUS y Linux usa señales POSIX.

---

## 9. Qué le falta al debugger (para las extensiones pedidas)

### a) Watch de variables
Hoy `#vwatch`/`lwatch` existen como variables declaradas (`vwatch`, `lwatch`,
igual que `vincs`/`lincs` y `vwords`/`lwords`) pero **no tienen contraparte
de dibujo activa** — `scrDicc` solo llena el panel de `vwords` (lista de
palabras), y está comentado en `maindb`/`playshow` (no se llama).

Para watch real hace falta:
1. Lista de direcciones de variables a observar (nueva región, ej.
   `#watchlist> ` similar a `bplist>` en `bshare`, o un nuevo `#wshare`).
2. Resolver dirección real de la variable elegida: `ndicc@` da el campo
   `mem` (offset 8..39) → sumarle `dataoff` (`dshare - memdata`, ya
   calculado en `precalc`) para leer del `dshare` mapeado.
3. UI para elegir palabra desde `vwords`/`scrDicc` y agregarla al watch.
4. Redibujar valor en cada frame del loop de `maindb`/`playshow`
   (leyendo `dshare + addr`).

### b) Breakpoint condicional (ej. "romper si TOS = N")
Hoy `bshare` solo guarda el token de posición (8 bytes/entrada, ver §2).
Falta:
1. Extender la entrada a 2 words: `(token, condición_empaquetada)` o usar
   un bloque paralelo (`#bpcond` del mismo tamaño que `bshare`).
2. Formato de condición simple: `(tipo<<32)|valor` donde tipo = comparar
   contra `vmTOS`, `vmNOS`, o una variable por dirección.
3. En el loop de `playmode`, cuando el programa pare en un bp
   (`vmSTATE` vuelve a 0 estando en la posición del bp), evaluar la
   condición contra `vmTOS`/`vmNOS` actuales; si no matchea, hacer
   `*>play` de nuevo automáticamente en vez de quedarse detenido.
   (Requiere que el lado del programa target soporte parar ahí sin
   reportar como "breakpoint real" o que el debugger lo maneje
   transparente re-lanzando play).

### c) Call stack (pila de llamadas)
El return stack (`vmRS`, slots 512..1023 de `vshare`, `vmRTOS` = cantidad
de entradas) ya contiene las **direcciones de retorno** (IPs) apiladas.
`.retstack` (r3debug.r3) hoy solo las imprime como hex crudo.

Para un call stack legible:
1. Por cada entrada del return stack (recorrer con `rstackoff`, igual que
   `.retstack`), tratarla como un `IP` de retorno.
2. Convertir ese IP a `ftoken` (mismo mecanismo que `ftokenIP` pero
   indexando `codesrc` con ese IP en vez de `vmIP`).
3. De ahí sacar `inc`/`pos` → nombre de archivo + línea/columna.
4. Opcionalmente resolver a qué palabra del diccionario pertenece ese
   rango de código (recorrer `realdicc` buscando la entrada cuyo `mem`
   es el mayor `<=` a esa dirección de código — análogo a `finddicc`
   pero contra `codedicc`, ya que ahí se guardan las posiciones de
   inicio de cada `:palabra`).
5. Mostrar como panel tipo "backtrace": `palabra @ archivo:línea`, más
   reciente arriba.

### d) Otras faltantes notadas en el código
- `viewmemhere` (tecla F4): definida pero **vacía** (`;` sin cuerpo) —
  stub para un futuro visor de memoria/hex dump.
- `scrDicc`/`scrTokens` (paneles de diccionario/includes en split de
  pantalla): implementados pero **comentados** en `maindb`/`playshow` —
  no se están dibujando actualmente pese a existir el código base.

---

## Referencias cruzadas rápidas

| Quiero...                          | Uso |
|-------------------------------------|-----|
| Estado actual de la VM               | `vmSTATE` |
| IP actual                            | `vmIP` |
| Valor en tope de pila                | `vmTOS` |
| Token/mnemónico en el IP actual      | `memtok` |
| Nombre + archivo + línea del IP      | `ftokenIP` → decodificar `ftoken` |
| Convertir click en fuente → token    | `findtoken` |
| Poner/sacar breakpoint en cursor     | `breakpoint` (usa `addBP`/`delBP`) |
| Nombre de una palabra del dicc.      | `ndicc@` + `dicc>name` |
| Leer variable del programa target    | `dshare + (dir_dicc + dataoff)` *(no implementado aún como "watch")* |
| Desensamblar instrucción             | `.token` + `token>cnt` para avanzar |
