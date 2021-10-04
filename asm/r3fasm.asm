; r3 container for compile
;
format PE64 GUI 5.0

entry start

;----- SETINGS -----
include 'set.asm'
;----- SETINGS -----

include 'include/win64w.inc'

; from LocoDelAssembly in fasm forum
macro cinvoke64 name, [args]{
common
   PUSH RSP             ;save current RSP position on the stack
   PUSH qword [RSP]     ;keep another copy of that on the stack
   ADD RSP,8
   AND SPL,$F0         ;adjust RSP to align the stack if not already there
   cinvoke name, args
   POP RSP              ;restore RSP to its original value
}

section '' code readable executable

;===============================================
start:
  invoke VirtualAlloc,0,MEMSIZE,MEM_COMMIT+MEM_RESERVE,PAGE_READWRITE
  mov [FREE_MEM],rax
  mov rbp,DATASTK
  xor rax,rax
  jmp INICIO

;----- CODE -----
include 'code.asm'
;----- CODE -----
  ret

;-----------------------------------------------
;-----------------------------------------------
section '.data' data readable writeable

  _title db "r3d",0
  _error db "err",0

align 16
  FREE_MEM	rq 2
  DATASTK	rq 256

;----- CODE -----
align 16
  include 'data.asm'
;----- CODE -----

section '.idata' import readable

  library kernel32,'KERNEL32',\
          user32,'USER32'

  include 'include\api\kernel32.inc'
  include 'include\api\user32.inc'

