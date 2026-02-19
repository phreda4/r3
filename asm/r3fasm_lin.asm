; r3 container for compile
; Linux ELF64 version
;
format ELF64 

extrn dlopen
extrn dlsym

entry start

;----- SETINGS -----
include 'set.asm'
;----- SETINGS -----

; Macro para llamar funciones que requieren alineacion a 16 bytes (libc, SSE, etc.)
; Guarda rsp en r11, alinea, llama, restaura.
; NOTA: r11 es volatile en el ABI de Linux, no hace falta salvarlo.
macro acall target {
  mov  r11, rsp
  sub  rsp, 8
  and  rsp, -16
  mov  [rsp], r11
  call target
  mov  rsp, [rsp]
}

; Linux syscall numbers (x86_64)
SYS_EXIT    = 60
SYS_MMAP    = 9
SYS_READ    = 0
SYS_WRITE   = 1

; mmap flags/prot
PROT_READ   = 1h
PROT_WRITE  = 2h
MAP_PRIVATE = 02h
MAP_ANON    = 20h

segment readable executable

;===============================================
start:
  ; mmap(NULL, MEMSIZE, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0)
  xor  rdi, rdi                   ; addr = NULL
  mov  rsi, MEMSIZE               ; length
  mov  rdx, PROT_READ + PROT_WRITE
  mov  r10, MAP_PRIVATE + MAP_ANON
  mov  r8,  -1                    ; fd = -1
  xor  r9,  r9                    ; offset = 0
  mov  rax, SYS_MMAP
  syscall
  mov  [FREE_MEM], rax

  mov  rbp, DATASTK-8
  xor  rax, rax
  call INICIO

  ; exit(0)
  xor  rdi, rdi
  mov  rax, SYS_EXIT
  syscall
  ret

;----- CODE -----
include 'code.asm'
;----- CODE -----

;-----------------------------------------------
segment readable writeable

align 16
  FREE_MEM  rq 2
  DATASTK   rq 256

;----- DATA -----
align 16
  include 'data.asm'
;----- DATA -----
