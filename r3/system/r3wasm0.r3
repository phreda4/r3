| generate WASM (WAT text) code
| PUERTO de r3asm0.r3 -- mismo modelo mental que la version x64:
|   rax  -> global $rax   (TOS cacheado)
|   rbp  -> global $sp    (puntero a la pila de datos, en memoria lineal)
| Tabla #vmc al final: MISMAS posiciones que #r3base (r3base.r3),
| offset 16 en adelante = r3base directo, offset 0-15 = tipos de
| literal (nro/hex/str/call/var/adr-word/adr-var). 0 = no portado aun.
|-------------------------------------------------------------
^r3/system/r3base.r3
^r3/system/r3stack.r3

:,ln ,print ,cr ;

|=========== HELPERS DE 128 BITS (mul signado, div 128/64 signada, ======
|=========== shift aritmetico >> y << sobre el par hi:lo) ================
| Emitidos UNA vez por wasm-header. Usan la tecnica de compiler-rt:
| - mul128: bajo 64 bits = a*b truncado normal (i64.mul, ya es correcto
|   sea signado o no); alto 64 bits = multiplicacion sin signo por
|   limbos de 32 bits + correccion de signo (- b si a<0, - a si b<0).
| - div128/64: shift-and-subtract restaurando, 128 iteraciones, el
|   cociente se va armando en el propio registro bajo a medida que se
|   corre el par (hi:lo) -- mismo truco que usa __udivti3 de LLVM
|   cuando no hay division 128/64 nativa.
:wasm-128bit-helpers
"(func $mulhi_u64 (param $a i64) (param $b i64) (result i64)" ,ln
" (local $alo i64) (local $ahi i64) (local $blo i64) (local $bhi i64)" ,ln
" (local $t i64) (local $w0 i64) (local $w1 i64) (local $w2 i64) (local $k i64)" ,ln
" local.get $a i64.const 0xffffffff i64.and local.set $alo" ,ln
" local.get $a i64.const 32 i64.shr_u local.set $ahi" ,ln
" local.get $b i64.const 0xffffffff i64.and local.set $blo" ,ln
" local.get $b i64.const 32 i64.shr_u local.set $bhi" ,ln
" local.get $alo local.get $blo i64.mul local.set $t" ,ln
" local.get $t i64.const 0xffffffff i64.and local.set $w0" ,ln
" local.get $t i64.const 32 i64.shr_u local.set $k" ,ln
" local.get $ahi local.get $blo i64.mul local.get $k i64.add local.set $t" ,ln
" local.get $t i64.const 0xffffffff i64.and local.set $w1" ,ln
" local.get $t i64.const 32 i64.shr_u local.set $w2" ,ln
" local.get $alo local.get $bhi i64.mul local.get $w1 i64.add local.set $t" ,ln
" local.get $t i64.const 32 i64.shr_u local.set $k" ,ln
" local.get $ahi local.get $bhi i64.mul local.get $w2 i64.add local.get $k i64.add)" ,ln

"(func $mul128_s (param $a i64) (param $b i64) (result i64 i64)" ,ln
" (local $hi i64)" ,ln
" local.get $a local.get $b call $mulhi_u64 local.set $hi" ,ln
" local.get $a i64.const 0 i64.lt_s" ,ln
" (if (then local.get $hi local.get $b i64.sub local.set $hi))" ,ln
" local.get $b i64.const 0 i64.lt_s" ,ln
" (if (then local.get $hi local.get $a i64.sub local.set $hi))" ,ln
" local.get $hi local.get $a local.get $b i64.mul)" ,ln

"(func $udivmod128 (param $hi i64) (param $lo i64) (param $d i64) (result i64 i64)" ,ln
" (local $rem i64) (local $i i32) (local $carry i64)" ,ln
" i64.const 0 local.set $rem" ,ln
" i32.const 0 local.set $i" ,ln
" (block $done (loop $again" ,ln
"  local.get $i i32.const 128 i32.ge_u br_if $done" ,ln
"  local.get $hi i64.const 63 i64.shr_u local.set $carry" ,ln
"  local.get $hi i64.const 1 i64.shl local.get $lo i64.const 63 i64.shr_u i64.or local.set $hi" ,ln
"  local.get $lo i64.const 1 i64.shl local.set $lo" ,ln
"  local.get $rem i64.const 1 i64.shl local.get $carry i64.or local.set $rem" ,ln
"  local.get $rem local.get $d i64.ge_u" ,ln
"  (if (then" ,ln
"   local.get $rem local.get $d i64.sub local.set $rem" ,ln
"   local.get $lo i64.const 1 i64.or local.set $lo))" ,ln
"  local.get $i i32.const 1 i32.add local.set $i" ,ln
"  br $again))" ,ln
" local.get $lo local.get $rem)" ,ln

"(func $neg128 (param $hi i64) (param $lo i64) (result i64 i64)" ,ln
" i64.const 0 local.get $hi i64.sub" ,ln
" local.get $lo i64.const 0 i64.ne (if (result i64) (then i64.const 1) (else i64.const 0)) i64.sub" ,ln
" i64.const 0 local.get $lo i64.sub)" ,ln

"(func $sdiv128 (param $hi i64) (param $lo i64) (param $d i64) (result i64)" ,ln
" (local $neg i32) (local $ahi i64) (local $alo i64) (local $ad i64) (local $q i64)" ,ln
" local.get $hi i64.const 0 i64.lt_s local.get $d i64.const 0 i64.lt_s i32.xor local.set $neg" ,ln
" local.get $hi i64.const 0 i64.lt_s" ,ln
" (if (result i64 i64)" ,ln
"  (then local.get $hi local.get $lo call $neg128)" ,ln
"  (else local.get $hi local.get $lo))" ,ln
" local.set $alo local.set $ahi" ,ln
" local.get $d i64.const 0 i64.lt_s" ,ln
" (if (result i64) (then i64.const 0 local.get $d i64.sub) (else local.get $d))" ,ln
" local.set $ad" ,ln
" local.get $ahi local.get $alo local.get $ad call $udivmod128 drop local.set $q" ,ln
" local.get $neg" ,ln
" (if (result i64) (then i64.const 0 local.get $q i64.sub) (else local.get $q)))" ,ln

"(func $ashr128_to64 (param $hi i64) (param $lo i64) (param $shift i32) (result i64)" ,ln
" (local $sh64 i64)" ,ln
" local.get $shift i64.extend_i32_u local.set $sh64" ,ln
" local.get $shift i32.const 64 i32.ge_u" ,ln
" (if (result i64)" ,ln
"  (then local.get $hi local.get $sh64 i64.const 64 i64.sub i64.shr_s)" ,ln
"  (else" ,ln
"   local.get $shift i32.eqz" ,ln
"   (if (result i64)" ,ln
"    (then local.get $lo)" ,ln
"    (else" ,ln
"     local.get $lo local.get $sh64 i64.shr_u" ,ln
"     local.get $hi i64.const 64 local.get $sh64 i64.sub i64.shl i64.or)))))" ,ln

"(func $shl64_to128 (param $a i64) (param $shift i32) (result i64 i64)" ,ln
" (local $sext i64) (local $sh64 i64)" ,ln
" local.get $a i64.const 63 i64.shr_s local.set $sext" ,ln
" local.get $shift i64.extend_i32_u local.set $sh64" ,ln
" local.get $shift i32.const 64 i32.ge_u" ,ln
" (if (result i64 i64)" ,ln
"  (then" ,ln
"   local.get $a local.get $sh64 i64.const 64 i64.sub i64.shl" ,ln
"   i64.const 0)" ,ln
"  (else" ,ln
"   local.get $shift i32.eqz" ,ln
"   (if (result i64 i64)" ,ln
"    (then local.get $sext local.get $a)" ,ln
"    (else" ,ln
"     local.get $sext local.get $sh64 i64.shl" ,ln
"     local.get $a i64.const 64 local.get $sh64 i64.sub i64.shr_u i64.or" ,ln
"     local.get $a local.get $sh64 i64.shl)))))" ,ln
;

|=========== PREAMBULO DEL MODULO (emitir 1 sola vez, al inicio) ======
:wasm-header
	"(module" ,ln
	"(import \"env\" \"memory\" (memory 16))" ,ln
	"(global $sp (mut i32) (i32.const 0))" ,ln       | rbp
	"(global $rax (mut i64) (i64.const 0))" ,ln      | TOS cacheado
	"(global $tmp (mut i64) (i64.const 0))" ,ln      | rcx/temporal
	"(global $rp (mut i32) (i32.const 0))" ,ln       | puntero R-stack
	"(global $A (mut i64) (i64.const 0))" ,ln        | registro indice A
	"(global $B (mut i64) (i64.const 0))" ,ln        | registro indice B
	wasm-128bit-helpers
	;
:wasm-footer ")" ,ln ;

|=========== HELPERS ====================================================
:mem-nip | -- ( saca un slot de memoria sin tocar $rax, equivale a un nip )
	"global.get $sp" ,ln
	"i32.const 8" ,ln "i32.sub" ,ln
	"global.set $sp" ,ln ;

:dyad-pre | -- ( deja NOS,TOS en la pila de operandos WASM )
	"global.get $sp" ,ln
	"i64.load" ,ln
	"global.get $rax" ,ln ;

:dyad-post
	"global.set $rax" ,ln
	mem-nip ;

|=========== PRIMITIVAS DE PILA ========================================
:,DUP
	"global.get $sp" ,ln "i32.const 8" ,ln "i32.add" ,ln "global.set $sp" ,ln
	"global.get $sp" ,ln "global.get $rax" ,ln "i64.store" ,ln ;

:,DROP
	"global.get $sp" ,ln "i64.load" ,ln "global.set $rax" ,ln
	mem-nip ;

:,NIP mem-nip ;

:,2DROP
	"global.get $sp" ,ln "i32.const 8" ,ln "i32.sub" ,ln "i64.load" ,ln "global.set $rax" ,ln
	"global.get $sp" ,ln "i32.const 16" ,ln "i32.sub" ,ln "global.set $sp" ,ln ;

:,3DROP
	"global.get $sp" ,ln "i32.const 16" ,ln "i32.sub" ,ln "i64.load" ,ln "global.set $rax" ,ln
	"global.get $sp" ,ln "i32.const 24" ,ln "i32.sub" ,ln "global.set $sp" ,ln ;

:,4DROP
	"global.get $sp" ,ln "i32.const 24" ,ln "i32.sub" ,ln "i64.load" ,ln "global.set $rax" ,ln
	"global.get $sp" ,ln "i32.const 32" ,ln "i32.sub" ,ln "global.set $sp" ,ln ;

:,OVER
	,DUP
	"global.get $sp" ,ln "i32.const 8" ,ln "i32.sub" ,ln "i64.load" ,ln "global.set $rax" ,ln ;

:,PICK2
	,DUP
	"global.get $sp" ,ln "i32.const 16" ,ln "i32.sub" ,ln "i64.load" ,ln "global.set $rax" ,ln ;

:,PICK3
	,DUP
	"global.get $sp" ,ln "i32.const 24" ,ln "i32.sub" ,ln "i64.load" ,ln "global.set $rax" ,ln ;

:,PICK4
	,DUP
	"global.get $sp" ,ln "i32.const 32" ,ln "i32.sub" ,ln "i64.load" ,ln "global.set $rax" ,ln ;

:,SWAP
	"global.get $sp" ,ln "i64.load" ,ln "global.set $tmp" ,ln
	"global.get $sp" ,ln "global.get $rax" ,ln "i64.store" ,ln
	"global.get $tmp" ,ln "global.set $rax" ,ln ;

:,ROT | a b c -- b c a  (rax=c al entrar)
	"global.get $sp" ,ln "i64.load" ,ln "global.set $tmp" ,ln           | tmp=b
	"global.get $sp" ,ln "global.get $rax" ,ln "i64.store" ,ln          | [sp]=c
	"global.get $sp" ,ln "i32.const 8" ,ln "i32.sub" ,ln "i64.load" ,ln "global.set $rax" ,ln  | rax=a
	"global.get $sp" ,ln "i32.const 8" ,ln "i32.sub" ,ln "global.get $tmp" ,ln "i64.store" ,ln ; | [sp-8]=b

:,-ROT | a b c -- c a b
	"global.get $sp" ,ln "i32.const 8" ,ln "i32.sub" ,ln "i64.load" ,ln "global.set $tmp" ,ln    | tmp=a
	"global.get $sp" ,ln "i32.const 8" ,ln "i32.sub" ,ln "global.get $rax" ,ln "i64.store" ,ln   | [sp-8]=c
	"global.get $sp" ,ln "i64.load" ,ln "global.set $rax" ,ln                                     | rax=b
	"global.get $sp" ,ln "global.get $tmp" ,ln "i64.store" ,ln ;                                   | [sp]=a

:,2DUP
	"global.get $sp" ,ln "i64.load" ,ln "global.set $tmp" ,ln
	"global.get $sp" ,ln "i32.const 8" ,ln "i32.add" ,ln "global.get $rax" ,ln "i64.store" ,ln
	"global.get $sp" ,ln "i32.const 16" ,ln "i32.add" ,ln "global.get $tmp" ,ln "i64.store" ,ln
	"global.get $sp" ,ln "i32.const 16" ,ln "i32.add" ,ln "global.set $sp" ,ln ;

:,2SWAP
	"global.get $sp" ,ln "i64.load" ,ln "global.set $tmp" ,ln                                    | tmp=c
	"global.get $sp" ,ln "i32.const 8" ,ln "i32.sub" ,ln "i64.load" ,ln                            | b (queda en la pila de operandos)
	"global.get $sp" ,ln "global.get $rax" ,ln "i64.store" ,ln                                    | [sp]=d
	"global.set $rax" ,ln                                                                            | rax=b
	"global.get $sp" ,ln "i32.const 8" ,ln "i32.sub" ,ln "global.get $tmp" ,ln "i64.store" ,ln ;   | [sp-8]=c

:,2OVER
	"global.get $sp" ,ln "i32.const 8" ,ln "i32.add" ,ln "global.get $rax" ,ln "i64.store" ,ln    | [sp+8]=rax
	"global.get $sp" ,ln "i32.const 16" ,ln "i32.add" ,ln "global.set $sp" ,ln                     | sp+=16
	"global.get $sp" ,ln "i32.const 32" ,ln "i32.sub" ,ln "i64.load" ,ln "global.set $tmp" ,ln    | tmp=[sp-32]
	"global.get $sp" ,ln "global.get $tmp" ,ln "i64.store" ,ln                                     | [sp]=tmp
	"global.get $sp" ,ln "i32.const 24" ,ln "i32.sub" ,ln "i64.load" ,ln "global.set $rax" ,ln ;   | rax=[sp-24]

|=========== NUMEROS =====================================================
:gdec | value -- ( decimal; token 9,10 reusan esta misma via TODO peephole )
	,DUP
	"i64.const " ,s ,d ,cr
	"global.set $rax" ,ln ;

:ghex | value -- ( hex literal en el codigo, funciona identico a gdec )
	gdec ;

:gstr | tok -- ( direccion de un string constante -- requiere que otra
	           | pasada del compilador ya haya declarado un global i32
	           | inmutable $strN por cada string, apuntando al offset
	           | real dentro del data segment. Ver TODO de layout de
	           | datos estaticos. )
	,DUP
	"global.get $str" ,s getval ,h ,cr
	"i64.extend_i32_s" ,ln
	"global.set $rax" ,ln ;

:gwor | idx --
	dup d@ $ff and
	16 =? ( drop getval "return_call $w%h" ,print ,cr ; )
	drop
	getval "call $w%h" ,print ,cr ;

:gvar | offset -- valor
	,DUP
	"i32.const " ,s ,d ,cr
	"i64.load" ,ln
	"global.set $rax" ,ln ;

:gdwor | offset --
	,DUP "i64.const " ,s ,d ,cr "global.set $rax" ,ln ;
:gdvar | offset --
	gdwor ;

|=========== RETORNO / IF / WHILE / EX ==================================
:g; "return" ,ln ;

:g(
	getval getiw
	0? ( drop pushbl dup "block $o%h" ,print ,cr ; )
	drop pushbl
	dup "block $o%h" ,print ,cr
	dup "loop $i%h" ,print ,cr ;

:g)
	getval getiw
	popbl swap
	1? ( over "br $i%h" ,print ,cr dup "end" ,ln )
	drop
	dup "end" ,ln drop ;

:gEX
	"global.get $rax" ,ln
	,DROP
	"call_indirect (type $wsig)" ,ln ;

|=========== ?? -- resuelve a que bloque saltar (portado literal) ======
:?? | -- nblock
	getval getiw
	0? ( drop nblock ; ) drop
	stbl> 4 - d@ ;

|=========== TESTS -- PEEK, no consumen la pila (igual que el original) =
:g0?
	"global.get $rax" ,ln "i64.eqz" ,ln "i32.eqz" ,ln
	?? "br_if $o%h" ,print ,cr ;
:g1?
	"global.get $rax" ,ln "i64.eqz" ,ln
	?? "br_if $o%h" ,print ,cr ;
:g+?
	"global.get $rax" ,ln "i64.const 0" ,ln "i64.lt_s" ,ln
	?? "br_if $o%h" ,print ,cr ;
:g-?
	"global.get $rax" ,ln "i64.const 0" ,ln "i64.ge_s" ,ln
	?? "br_if $o%h" ,print ,cr ;

|=========== COMPARACIONES -- fusionadas con salto (consumen la pila) ==
:cmp-tail
	"i32.eqz" ,ln
	mem-nip
	?? "br_if $o%h" ,print ,cr ;

:g<?  dyad-pre "i64.lt_s" ,ln cmp-tail ;
:g>?  dyad-pre "i64.gt_s" ,ln cmp-tail ;
:g=?  dyad-pre "i64.eq"   ,ln cmp-tail ;
:g<>? dyad-pre "i64.ne"   ,ln cmp-tail ;
:g>=? dyad-pre "i64.ge_s" ,ln cmp-tail ;
:g<=? dyad-pre "i64.le_s" ,ln cmp-tail ;

:gAND? dyad-pre "i64.and" ,ln "i64.eqz" ,ln mem-nip ?? "br_if $o%h" ,print ,cr ;
:gNAND? dyad-pre "i64.and" ,ln "i64.eqz" ,ln "i32.eqz" ,ln mem-nip ?? "br_if $o%h" ,print ,cr ;
:gIN? "; TODO gIN? -- range check, ver g<? / g>? combinados" ,ln ;

|=========== ARITMETICA / LOGICA ========================================
:gAND dyad-pre "i64.and" ,ln dyad-post ;
:gOR  dyad-pre "i64.or"  ,ln dyad-post ;
:gXOR dyad-pre "i64.xor" ,ln dyad-post ;
:gNAND
	dyad-pre "i64.and" ,ln
	"i64.const -1" ,ln "i64.xor" ,ln
	dyad-post ;

:g+   dyad-pre "i64.add"    ,ln dyad-post ;
:g-   dyad-pre "i64.sub"    ,ln dyad-post ;
:g*   dyad-pre "i64.mul"    ,ln dyad-post ;
:g/   dyad-pre "i64.div_s"  ,ln dyad-post ;
:gMOD dyad-pre "i64.rem_s"  ,ln dyad-post ;

:g/MOD | a b -- q r
	dyad-pre "i64.div_s" ,ln "global.set $tmp" ,ln          | tmp = q
	dyad-pre "i64.rem_s" ,ln "global.set $rax" ,ln          | rax = r
	"global.get $sp" ,ln "global.get $tmp" ,ln "i64.store" ,ln ; | [sp] = q (NOS), rax = r (TOS)

:triad3rd-drop2 | -- ( despues de consumir a,b,c dejando solo el resultado
                | en rax: hay que bajar $sp en 16 -- a y b vivian en
                | memoria, c ya estaba cacheado en rax )
	"global.get $sp" ,ln "i32.const 16" ,ln "i32.sub" ,ln "global.set $sp" ,ln ;

:g*/ | a b c -- d   ( d = a*b/c, intermedio de 128 bits )
	"global.get $sp" ,ln "i32.const 8" ,ln "i32.sub" ,ln "i64.load" ,ln   | a
	"global.get $sp" ,ln "i64.load" ,ln                                    | b
	"call $mul128_s" ,ln                                                   | -- hi lo
	"global.get $rax" ,ln                                                  | -- hi lo c
	"call $sdiv128" ,ln                                                    | -- d
	"global.set $rax" ,ln
	triad3rd-drop2 ;

:g*>> | a b shift -- d   ( d = (a*b) >> shift, intermedio de 128 bits )
	"global.get $sp" ,ln "i32.const 8" ,ln "i32.sub" ,ln "i64.load" ,ln   | a
	"global.get $sp" ,ln "i64.load" ,ln                                    | b
	"call $mul128_s" ,ln                                                   | -- hi lo
	"global.get $rax" ,ln "i32.wrap_i64" ,ln                               | -- hi lo shift(i32)
	"call $ashr128_to64" ,ln                                               | -- d
	"global.set $rax" ,ln
	triad3rd-drop2 ;

:g<</ | a b shift -- d   ( d = (a << shift) / b, intermedio de 128 bits )
	"global.get $sp" ,ln "i32.const 8" ,ln "i32.sub" ,ln "i64.load" ,ln   | a
	"global.get $rax" ,ln "i32.wrap_i64" ,ln                               | shift(i32)
	"call $shl64_to128" ,ln                                                | -- hi lo
	"global.get $sp" ,ln "i64.load" ,ln                                    | -- hi lo b
	"call $sdiv128" ,ln                                                    | -- d
	"global.set $rax" ,ln
	triad3rd-drop2 ;

:g<<  dyad-pre "i64.shl"    ,ln dyad-post ;
:g>>  dyad-pre "i64.shr_s"  ,ln dyad-post ;
:g>>> dyad-pre "i64.shr_u"  ,ln dyad-post ;

:gNOT "global.get $rax" ,ln "i64.const -1" ,ln "i64.xor" ,ln "global.set $rax" ,ln ;
:gNEG "i64.const 0" ,ln "global.get $rax" ,ln "i64.sub" ,ln "global.set $rax" ,ln ;

:gABS
	"global.get $rax" ,ln "i64.const 0" ,ln "i64.lt_s" ,ln
	"if (result i64)" ,ln
	"i64.const 0" ,ln "global.get $rax" ,ln "i64.sub" ,ln
	"else" ,ln
	"global.get $rax" ,ln
	"end" ,ln
	"global.set $rax" ,ln ;

:gSQRT
	"global.get $rax" ,ln "f64.convert_i64_s" ,ln "f64.sqrt" ,ln "i64.trunc_f64_s" ,ln
	"global.set $rax" ,ln ;

:gCLZ | i64.clz(x) == bsr+xor63 para x!=0 -- misma formula
	"global.get $rax" ,ln "i64.clz" ,ln "global.set $rax" ,ln ;

|=========== ACCESO A MEMORIA ===========================================
:g@   "global.get $rax" ,ln "i32.wrap_i64" ,ln "i64.load"     ,ln "global.set $rax" ,ln ;
:gC@  "global.get $rax" ,ln "i32.wrap_i64" ,ln "i64.load8_u"  ,ln "global.set $rax" ,ln ;
:gW@  "global.get $rax" ,ln "i32.wrap_i64" ,ln "i64.load16_u" ,ln "global.set $rax" ,ln ;
:gD@  "global.get $rax" ,ln "i32.wrap_i64" ,ln "i64.load32_u" ,ln "global.set $rax" ,ln ;

:load+tail | -- ( comun a @+/C@+/W@+/D@+: empuja addr vieja, avanza sp )
	"global.get $sp" ,ln "i32.const 8" ,ln "i32.add" ,ln "global.set $sp" ,ln
	"global.get $sp" ,ln "global.get $rax" ,ln "i64.store" ,ln ; | guarda addr vieja debajo

:g@+  "global.get $rax" ,ln "i32.wrap_i64" ,ln "i64.load"     ,ln "global.set $tmp" ,ln load+tail "global.get $tmp" ,ln "global.set $rax" ,ln ;
:gC@+ "global.get $rax" ,ln "i32.wrap_i64" ,ln "i64.load8_u"  ,ln "global.set $tmp" ,ln load+tail "global.get $tmp" ,ln "global.set $rax" ,ln ;
:gW@+ "global.get $rax" ,ln "i32.wrap_i64" ,ln "i64.load16_u" ,ln "global.set $tmp" ,ln load+tail "global.get $tmp" ,ln "global.set $rax" ,ln ;
:gD@+ "global.get $rax" ,ln "i32.wrap_i64" ,ln "i64.load32_u" ,ln "global.set $tmp" ,ln load+tail "global.get $tmp" ,ln "global.set $rax" ,ln ;

| store: valor en [sp] (NOS), direccion en rax (TOS)
:g!  "global.get $rax" ,ln "i32.wrap_i64" ,ln "global.get $sp" ,ln "i64.load" ,ln "i64.store"   ,ln ,2DROP ;
:gC! "global.get $rax" ,ln "i32.wrap_i64" ,ln "global.get $sp" ,ln "i64.load" ,ln "i64.store8"  ,ln ,2DROP ;
:gW! "global.get $rax" ,ln "i32.wrap_i64" ,ln "global.get $sp" ,ln "i64.load" ,ln "i64.store16" ,ln ,2DROP ;
:gD! "global.get $rax" ,ln "i32.wrap_i64" ,ln "global.get $sp" ,ln "i64.load" ,ln "i64.store32" ,ln ,2DROP ;

:g!+  "global.get $rax" ,ln "i32.wrap_i64" ,ln "global.get $sp" ,ln "i64.load" ,ln "i64.store"   ,ln ,2DROP "global.get $rax" ,ln "i64.const 8" ,ln "i64.add" ,ln "global.set $rax" ,ln ;
:gC!+ "global.get $rax" ,ln "i32.wrap_i64" ,ln "global.get $sp" ,ln "i64.load" ,ln "i64.store8"  ,ln ,2DROP "global.get $rax" ,ln "i64.const 1" ,ln "i64.add" ,ln "global.set $rax" ,ln ;
:gW!+ "global.get $rax" ,ln "i32.wrap_i64" ,ln "global.get $sp" ,ln "i64.load" ,ln "i64.store16" ,ln ,2DROP "global.get $rax" ,ln "i64.const 2" ,ln "i64.add" ,ln "global.set $rax" ,ln ;
:gD!+ "global.get $rax" ,ln "i32.wrap_i64" ,ln "global.get $sp" ,ln "i64.load" ,ln "i64.store32" ,ln ,2DROP "global.get $rax" ,ln "i64.const 4" ,ln "i64.add" ,ln "global.set $rax" ,ln ;

:g+!
	"global.get $rax" ,ln "i32.wrap_i64" ,ln "global.get $rax" ,ln "i32.wrap_i64" ,ln "i64.load" ,ln
	"global.get $sp" ,ln "i64.load" ,ln "i64.add" ,ln
	"global.get $rax" ,ln "i32.wrap_i64" ,ln "i64.store" ,ln
	,2DROP ;
:gC+!
	"global.get $rax" ,ln "i32.wrap_i64" ,ln "global.get $rax" ,ln "i32.wrap_i64" ,ln "i64.load8_u" ,ln
	"global.get $sp" ,ln "i64.load" ,ln "i64.add" ,ln
	"global.get $rax" ,ln "i32.wrap_i64" ,ln "i64.store8" ,ln
	,2DROP ;
:gW+!
	"global.get $rax" ,ln "i32.wrap_i64" ,ln "global.get $rax" ,ln "i32.wrap_i64" ,ln "i64.load16_u" ,ln
	"global.get $sp" ,ln "i64.load" ,ln "i64.add" ,ln
	"global.get $rax" ,ln "i32.wrap_i64" ,ln "i64.store16" ,ln
	,2DROP ;
:gD+!
	"global.get $rax" ,ln "i32.wrap_i64" ,ln "global.get $rax" ,ln "i32.wrap_i64" ,ln "i64.load32_u" ,ln
	"global.get $sp" ,ln "i64.load" ,ln "i64.add" ,ln
	"global.get $rax" ,ln "i32.wrap_i64" ,ln "i64.store32" ,ln
	,2DROP ;

|=========== R-STACK -- region propia, no el call-stack real ===========
:g>R
	"global.get $rp" ,ln "i32.const 8" ,ln "i32.add" ,ln "global.set $rp" ,ln
	"global.get $rp" ,ln "global.get $rax" ,ln "i64.store offset=65536" ,ln
	,DROP ;
:gR>
	,DUP
	"global.get $rp" ,ln "i64.load offset=65536" ,ln "global.set $rax" ,ln
	"global.get $rp" ,ln "i32.const 8" ,ln "i32.sub" ,ln "global.set $rp" ,ln ;
:gR@
	,DUP
	"global.get $rp" ,ln "i64.load offset=65536" ,ln "global.set $rax" ,ln ;

|=========== BANCOS A/B, MOVE/FILL, MEM -- no portados aun =============
|=========== BANCOS A/B -- registros indice globales ====================
| >X  pop TOS -> X (consume)      X>  push X -> TOS (peek, no limpia X)
| X+  X += TOS (consume)          X@/X! qword sin avanzar
| X@+/X!+ qword y avanza X en 8   CX@.. byte (avanza 1)  DX@.. dword (avanza 4)

:g>A "global.get $rax" ,ln "global.set $A" ,ln ,DROP ;
:gA>  ,DUP "global.get $A" ,ln "global.set $rax" ,ln ;
:gA+ "global.get $A" ,ln "global.get $rax" ,ln "i64.add" ,ln "global.set $A" ,ln ,DROP ;

:gA@  ,DUP "global.get $A" ,ln "i32.wrap_i64" ,ln "i64.load" ,ln "global.set $rax" ,ln ;
:gA!  "global.get $A" ,ln "i32.wrap_i64" ,ln "global.get $rax" ,ln "i64.store" ,ln ,DROP ;
:gA@+
	,DUP "global.get $A" ,ln "i32.wrap_i64" ,ln "i64.load" ,ln "global.set $rax" ,ln
	"global.get $A" ,ln "i64.const 8" ,ln "i64.add" ,ln "global.set $A" ,ln ;
:gA!+
	"global.get $A" ,ln "i32.wrap_i64" ,ln "global.get $rax" ,ln "i64.store" ,ln
	"global.get $A" ,ln "i64.const 8" ,ln "i64.add" ,ln "global.set $A" ,ln ,DROP ;

:gCA@ ,DUP "global.get $A" ,ln "i32.wrap_i64" ,ln "i64.load8_u" ,ln "global.set $rax" ,ln ;
:gCA! "global.get $A" ,ln "i32.wrap_i64" ,ln "global.get $rax" ,ln "i64.store8" ,ln ,DROP ;
:gCA@+
	,DUP "global.get $A" ,ln "i32.wrap_i64" ,ln "i64.load8_u" ,ln "global.set $rax" ,ln
	"global.get $A" ,ln "i64.const 1" ,ln "i64.add" ,ln "global.set $A" ,ln ;
:gCA!+
	"global.get $A" ,ln "i32.wrap_i64" ,ln "global.get $rax" ,ln "i64.store8" ,ln
	"global.get $A" ,ln "i64.const 1" ,ln "i64.add" ,ln "global.set $A" ,ln ,DROP ;

:gDA@ ,DUP "global.get $A" ,ln "i32.wrap_i64" ,ln "i64.load32_u" ,ln "global.set $rax" ,ln ;
:gDA! "global.get $A" ,ln "i32.wrap_i64" ,ln "global.get $rax" ,ln "i64.store32" ,ln ,DROP ;
:gDA@+
	,DUP "global.get $A" ,ln "i32.wrap_i64" ,ln "i64.load32_u" ,ln "global.set $rax" ,ln
	"global.get $A" ,ln "i64.const 4" ,ln "i64.add" ,ln "global.set $A" ,ln ;
:gDA!+
	"global.get $A" ,ln "i32.wrap_i64" ,ln "global.get $rax" ,ln "i64.store32" ,ln
	"global.get $A" ,ln "i64.const 4" ,ln "i64.add" ,ln "global.set $A" ,ln ,DROP ;

|--- banco B: identico a A, usando $B --------------------------------
:g>B "global.get $rax" ,ln "global.set $B" ,ln ,DROP ;
:gB>  ,DUP "global.get $B" ,ln "global.set $rax" ,ln ;
:gB+ "global.get $B" ,ln "global.get $rax" ,ln "i64.add" ,ln "global.set $B" ,ln ,DROP ;

:gB@  ,DUP "global.get $B" ,ln "i32.wrap_i64" ,ln "i64.load" ,ln "global.set $rax" ,ln ;
:gB!  "global.get $B" ,ln "i32.wrap_i64" ,ln "global.get $rax" ,ln "i64.store" ,ln ,DROP ;
:gB@+
	,DUP "global.get $B" ,ln "i32.wrap_i64" ,ln "i64.load" ,ln "global.set $rax" ,ln
	"global.get $B" ,ln "i64.const 8" ,ln "i64.add" ,ln "global.set $B" ,ln ;
:gB!+
	"global.get $B" ,ln "i32.wrap_i64" ,ln "global.get $rax" ,ln "i64.store" ,ln
	"global.get $B" ,ln "i64.const 8" ,ln "i64.add" ,ln "global.set $B" ,ln ,DROP ;

:gCB@ ,DUP "global.get $B" ,ln "i32.wrap_i64" ,ln "i64.load8_u" ,ln "global.set $rax" ,ln ;
:gCB! "global.get $B" ,ln "i32.wrap_i64" ,ln "global.get $rax" ,ln "i64.store8" ,ln ,DROP ;
:gCB@+
	,DUP "global.get $B" ,ln "i32.wrap_i64" ,ln "i64.load8_u" ,ln "global.set $rax" ,ln
	"global.get $B" ,ln "i64.const 1" ,ln "i64.add" ,ln "global.set $B" ,ln ;
:gCB!+
	"global.get $B" ,ln "i32.wrap_i64" ,ln "global.get $rax" ,ln "i64.store8" ,ln
	"global.get $B" ,ln "i64.const 1" ,ln "i64.add" ,ln "global.set $B" ,ln ,DROP ;

:gDB@ ,DUP "global.get $B" ,ln "i32.wrap_i64" ,ln "i64.load32_u" ,ln "global.set $rax" ,ln ;
:gDB! "global.get $B" ,ln "i32.wrap_i64" ,ln "global.get $rax" ,ln "i64.store32" ,ln ,DROP ;
:gDB@+
	,DUP "global.get $B" ,ln "i32.wrap_i64" ,ln "i64.load32_u" ,ln "global.set $rax" ,ln
	"global.get $B" ,ln "i64.const 4" ,ln "i64.add" ,ln "global.set $B" ,ln ;
:gDB!+
	"global.get $B" ,ln "i32.wrap_i64" ,ln "global.get $rax" ,ln "i64.store32" ,ln
	"global.get $B" ,ln "i64.const 4" ,ln "i64.add" ,ln "global.set $B" ,ln ,DROP ;

:gab[ "; TODO gab[ -- swap de bancos A/B, mecanico" ,ln ;
:g]ba "; TODO g]ba" ,ln ;

|=========== [ ] ANONIMOS -- no se portan a proposito ==================
| decision del proyecto: los anonimos se resuelven con un optimizador
| antes de llegar a este backend, no van a aparecer en el codigo que
| efectivamente le llega a g[ /g] -- se dejan sin implementar.
:g[ "; [ ] no se portan -- resueltos por el optimizador antes del backend" ,ln ;
:g] "; ver g[" ,ln ;
:gMOVE "; TODO gMOVE -- loop con g@+/g!+, mecanico" ,ln ;
:gMOVE> "; TODO gMOVE>" ,ln ;
:gFILL "; TODO gFILL" ,ln ;
:gCMOVE "; TODO gCMOVE" ,ln ; :gCMOVE> "; TODO gCMOVE>" ,ln ; :gCFILL "; TODO gCFILL" ,ln ;
:gDMOVE "; TODO gDMOVE" ,ln ; :gDMOVE> "; TODO gDMOVE>" ,ln ; :gDFILL "; TODO gDFILL" ,ln ;
:gMEM "; TODO gMEM" ,ln ;

|=========== FFI -- SHIM (ver comentario extenso mas abajo) ============
| Cada gSYSn/gLOADLIB/gGETPROC se resuelve como IMPORT fijo en env,
| definido en wasm-header. LOADLIB+GETPROC no aplican en runtime -- se
| resuelven en compile-time decidiendo a que funcion de env corresponde
| cada par. Ver conversacion sobre el shim de dibujo/audio/consola.
:gLOADLIB "; TODO shim LOADLIB -> resuelto en compile-time, no en runtime" ,ln ;
:gGETPROC "; TODO shim GETPROC -> resuelto en compile-time, no en runtime" ,ln ;
:gSYS0  "; TODO shim SYS0 -> import env.jsSYS0"  ,ln ;
:gSYS1  "; TODO shim SYS1 -> import env.jsSYS1"  ,ln ;
:gSYS2  "; TODO shim SYS2 -> import env.jsSYS2"  ,ln ;
:gSYS3  "; TODO shim SYS3 -> import env.jsSYS3"  ,ln ;
:gSYS4  "; TODO shim SYS4 -> import env.jsSYS4"  ,ln ;
:gSYS5  "; TODO shim SYS5 -> import env.jsSYS5"  ,ln ;
:gSYS6  "; TODO shim SYS6 -> import env.jsSYS6"  ,ln ;
:gSYS7  "; TODO shim SYS7 -> import env.jsSYS7"  ,ln ;
:gSYS8  "; TODO shim SYS8 -> import env.jsSYS8"  ,ln ;
:gSYS9  "; TODO shim SYS9 -> import env.jsSYS9"  ,ln ;
:gSYS10 "; TODO shim SYS10 -> import env.jsSYS10" ,ln ;

|=========== TABLA DE DISPATCH -- MISMAS POSICIONES QUE #r3base ========
| offset 0-6: sin uso | 7-10: literales numericos | 11: string
| 12: call word | 13: var(deref) | 14: adr-word | 15: adr-var
| offset 16+: 1:1 con #r3base (";" en 16, etc)
#vmc
0 0 0 0 0 0 0
gdec ghex gdec gdec gstr gwor gvar gdwor gdvar
g; g( g) g[ g] gEX g0? g1? g+? g-?
g<? g>? g=? g>=? g<=? g<>? gAND? gNAND? gIN?
,DUP ,DROP ,OVER ,PICK2 ,PICK3 ,PICK4 ,SWAP ,NIP
,ROT ,-ROT ,2DUP ,2DROP ,3DROP ,4DROP ,2OVER ,2SWAP
g>R gR> gR@
gAND gOR gXOR gNAND g+ g- g* g/
g<< g>> g>>> gMOD g/MOD g*/ g*>> g<</
gNOT gNEG gABS gSQRT gCLZ
g@ gC@ gW@ gD@
g@+ gC@+ gW@+ gD@+
g! gC! gW! gD!
g!+ gC!+ gW!+ gD!+
g+! gC+! gW+! gD+!
g>A gA> gA+
gA@ gA! gA@+ gA!+
gCA@ gCA! gCA@+ gCA!+
gDA@ gDA! gDA@+ gDA!+
g>B gB> gB+
gB@ gB! gB@+ gB!+
gCB@ gCB! gCB@+ gCB!+
gDB@ gDB! gDB@+ gDB!+
gab[ g]ba
gMOVE gMOVE> gFILL
gCMOVE gCMOVE> gCFILL
gDMOVE gDMOVE> gDFILL
gMEM
gLOADLIB gGETPROC
gSYS0 gSYS1 gSYS2 gSYS3 gSYS4 gSYS5
gSYS6 gSYS7 gSYS8 gSYS9 gSYS10

:codestep | token --
	$ff and 3 << 'vmc + @ ex ;
