; r3 container for compile
;
format PE64 GUI 5.0

entry start

;----- SETINGS -----
include 'set.asm'
;----- SETINGS -----

include 'include/MACRO/proc64.inc'
include 'include/MACRO/import64.inc'

macro cinvoke64 name, [args]{
common
	mov rdx, rsp
	sub rsp, 8
	and rsp, -16
	mov [rsp], rdx
	cinvoke name, args
	mov rsp, [rsp]
}

section '.text' code readable executable

MEM_COMMIT		= 001000h
MEM_RESERVE		= 002000h
PAGE_READWRITE	= 004h

;===============================================
start:
  sub rsp,40
  invoke VirtualAlloc,0,MEMSIZE,MEM_COMMIT+MEM_RESERVE,PAGE_READWRITE
  mov [FREE_MEM],rax
  mov rbp,DATASTK-8
  xor rax,rax
  call INICIO
  add rsp,40
  invoke ExitProcess,0
  ret
;----- CODE -----
include 'code.asm'
;----- CODE -----

;-----------------------------------------------
;-----------------------------------------------
section '.data' data readable writeable

align 16
  FREE_MEM	rq 2
  DATASTK	rq 256

;----- CODE -----
align 16
  include 'data.asm'
;----- CODE -----

section '.idata' import readable

library kernel32,'KERNEL32'

include 'include\api\kernel32.inc'

