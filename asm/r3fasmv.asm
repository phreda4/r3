; r3 container for compile
;
format PE64 GUI 5.0

entry start

;----- SETINGS -----
include 'set.asm'
;----- SETINGS -----

include 'include/win64w.inc'
include 'sdl2.inc'
include 'sdl2_mixer.inc'

section '' code readable executable

;===============================================
start:
  sub rsp,40
  invoke Mix_OpenAudio,44100,AUDIO_S16SYS,2,1024
  invoke Mix_Init,8 ; mp3
  invoke SDL_Init,SDL_INIT_AUDIO+SDL_INIT_VIDEO ;****
  invoke SDL_CreateWindow,_title,\
    SDL_WINDOWPOS_UNDEFINED,SDL_WINDOWPOS_UNDEFINED,\
    XRES,YRES,0
  mov [window],eax
  invoke SDL_ShowCursor,0

;  cinvoke SDL_SetWindowFullscreen,[window],SDL_WINDOW_FULLSCREEN
  invoke SDL_GetWindowSurface,[window]
  mov rbx,rax
  mov [screen],eax
  mov rdi,[rbx+SDL_Surface.pixels]
  mov [SYSFRAME],rdi
  invoke VirtualAlloc,0,MEMSIZE,MEM_COMMIT+MEM_RESERVE,PAGE_READWRITE
  mov [FREE_MEM],rax
  invoke SDL_StartTextInput
  mov rbp,DATASTK
  xor rax,rax
  call INICIO

SYSEND:
  invoke SDL_StopTextInput
  invoke SDL_DestroyWindow,[window]
  invoke Mix_CloseAudio
  invoke Mix_Quit
  invoke SDL_Quit
  add rsp,40
  ret

;----- CODE -----
include 'code.asm'
;----- CODE -----
  ret

; from LocoDelAssembly in fasm forum
macro cinvoke64 name, [args]{
common
   PUSH RSP             ;save current RSP position on the stack
   PUSH qword [RSP]     ;keep another copy of that on the stack
   ADD RSP,8
   AND SPL,0F0h         ;adjust RSP to align the stack if not already there
   cinvoke name, args
   POP RSP              ;restore RSP to its original value
}
;===============================================
align 16
SYSREDRAW:
  push rax rbp   ; c d r8 r9
  cinvoke64 SDL_UpdateWindowSurface,[window]
  pop rbp rax
  ret

;===============================================
align 16
SYSUPDATE:
  push rax rbp
  xor eax,eax
  mov [SYSKEY],eax
  mov [SYSCHAR],eax
  cinvoke64 SDL_Delay,10
  cinvoke64 SDL_PollEvent,evt
  test eax,eax
  jnz n1
loopev:
  pop rbp rax
  ret
n1:
  mov eax,[evt.type]
  cmp eax,SDL_KEYDOWN
  je upkeyd
  cmp eax,SDL_KEYUP
  je upkeyu
  cmp eax,SDL_MOUSEBUTTONDOWN
  je upmobd
  cmp eax,SDL_MOUSEBUTTONUP
  je upmobu
  cmp eax,SDL_MOUSEMOTION
  je upmomo
  cmp eax,SDL_TEXTINPUT
  je uptext
  cmp eax,SDL_QUIT
  je SYSEND
  jmp loopev
upkeyd: ;key=(evt.key.keysym.sym&0xffff)|evt.key.keysym.sym>>16;break;
  mov eax,[evt.key.keysym.sym]
  and eax,0xffff
  mov ebx,[evt.key.keysym.sym]
  shr ebx,16
  or eax,ebx
  mov [SYSKEY],eax
  jmp loopev
upkeyu: ;key=0x1000|(evt.key.keysym.sym&0xffff)|evt.key.keysym.sym>>16;break;
  mov eax,[evt.key.keysym.sym]
  and eax,0xffff
  mov ebx,[evt.key.keysym.sym]
  shr ebx,16
  or eax,0x1000
  or eax,ebx
  mov [SYSKEY],eax
  jmp loopev
upmobd: ;bm|=evt.button.button;break;
  movzx eax,byte[evt.button.button]
  or [SYSBM],eax
  jmp loopev
upmobu: ;bm&=~evt.button.button;break;
  movzx eax,[evt.button.button]
  not eax
  and [SYSBM],eax
  jmp loopev
upmomo: ;xm=evt.motion.x;ym=evt.motion.y;break;
  mov eax,[evt.motion.x]
  mov [SYSXM],eax
  mov eax,[evt.motion.y]
  mov [SYSYM],eax
  jmp loopev
uptext: ;keychar=*(int*)evt.text.text;break;
  movzx eax,byte[evt.text.text]
  mov [SYSCHAR],eax
  jmp loopev

;===============================================
SYSMSEC: ;  ( -- msec )
  add rbp,8
  mov [rbp],rax
  cinvoke64 GetTickCount
;  cinvoke64 SDL_GetTicks
  ret

;===============================================
SYSTIME: ;  ( -- hms )
  add rbp,8
  mov [rbp],rax
  invoke GetLocalTime,SysTime
  movzx eax,word [SysTime.wHour]
  shl eax,16
  movzx ebx,word [SysTime.wMinute]
  shl ebx,8
  or eax,ebx
  movzx ebx,word [SysTime.wSecond]
  or eax,ebx
  ret

;===============================================
SYSDATE: ;  ( -- ymd )
  add rbp,8
  mov [rbp],rax
  invoke GetLocalTime,SysTime
  movzx eax,word [SysTime.wYear]
  shl eax,16
  movzx ebx,word [SysTime.wMonth]
  shl ebx,8
  or eax,ebx
  movzx ebx,word [SysTime.wDay]
  or eax,ebx
  ret

;===============================================
SYSLOAD:
  invoke SDL_RWFromFile,rax,"rb"
  mov [afile],rax
  or rax,rax
  mov rax,[rbp]
  jz .fend
  mov rsi,rax
  invoke SDL_RWsize,[afile]
  mov rdi,rax
  invoke SDL_RWread,[afile],rsi,1,rdi
  add rsi,rax
  invoke SDL_RWclose,[afile]
  mov rax,rsi
.fend:
  sub rbp,8
  ret

;===============================================
SYSSAVE: ; ( 'from cnt "filename" -- )
  invoke SDL_RWFromFile,rax,"wb"
  mov [afile],rax
  or rax,rax
  jz .fend
  mov rbx,[rbp]
  mov rsi,[rbp-8]
  invoke SDL_RWwrite,[afile],rsi,rbx,1
  invoke SDL_RWclose,[afile]
.fend:
  mov rax,[rbp-8*2]
  sub rbp,8*3
  ret

;===============================================
SYSAPPEND: ; ( 'from cnt "filename" -- )
  invoke SDL_RWFromFile,rax,"ab"
  mov [afile],rax
  or rax,rax
  jz .fend
  mov rbx,[rbp]
  mov rsi,[rbp-8]
  invoke SDL_RWwrite,[afile],rsi,rbx ,1
  invoke SDL_RWclose,[afile]
.fend:
  mov rax,[rbp-8*2]
  sub rbp,8*3
  ret

;===============================================
SYSFFIRST: ; ( "path" -- fdd ) ;****** r4 32 bits
;	push ebx ecx edx edi esi
	mov rsi,_dir
.bcpy:
	mov bl,[rax]
	or bl,bl
	jz .ends
	mov byte[rsi],bl
	add rax,1
	add rsi,1
	jmp .bcpy
.ends:
	mov dword [rsi],$002A2f2f
	invoke FindFirstFile,_dir,fdd
	mov [hfind],rax
	cmp eax,INVALID_HANDLE_VALUE
	je .nin
	mov rax,fdd
	jmp .fin
.nin:
	xor rax,rax
.fin:
;	pop esi edi edx ecx ebx
	ret

;===============================================
SYSFNEXT: ; ( -- fdd/0) ;****** r4 32 bits
	add rbp,8
	mov [rbp], rax
;	push ebx ecx edx edi esi
	invoke FindNextFile,[hfind],fdd
	or rax,rax
	jz .nin
	mov rax,fdd
	jmp .fin
.nin:
	invoke FindClose,[hfind]
	xor rax,rax
.fin:
;	pop esi edi edx ecx ebx
	ret


;===============================================
SYSYSTEM:
	push rax
	push rdi
	push rcx
;	invoke ZeroMemory,StartupInfo,StartupInfo.size
	xor rax,rax
	mov edi,StartupInfo
	mov ecx,17
	rep stosd
	mov eax,17*4
	mov [StartupInfo.cb],eax
	pop rcx
	pop rdi
	pop rax
	invoke CreateProcess,0,eax,0,0,FALSE, 0x08000000,0,0,StartupInfo,ProcessInfo
	mov rax,[ProcessInfo.hProcess]
;	invoke WaitForSingleObject,[ProcessInfo.hProcess],INFINITE
	ret

;===============================================
;	TOS=(int64_t)Mix_LoadWAV((char *)TOS);
; #define Mix_LoadWAV(file)   Mix_LoadWAV_RW(SDL_RWFromFile(file, "rb"), 1)
SYSSLOAD:
	cinvoke64 SDL_RWFromFile,rax,"rb"
	cinvoke64 Mix_LoadWAV_RW,rax,1
	ret

;===============================================
;	TOS=(int64_t)Mix_LoadMUS((char *)TOS);
SYSMLOAD:
	cinvoke64 Mix_LoadMUS,rax
    ret

;===============================================
;        if (TOS!=0)
;			Mix_PlayChannel(-1,(Mix_Chunk *)TOS, 0);
;      else for(int i=0;i<8;i++)
;			/*if (i!=mix_movie_channel) */Mix_HaltChannel(i);
SYSSPLAY:
	or rax,rax
	jz .halt
	cinvoke64 Mix_PlayChannelTimed,-1,rax,0,-1
	jmp .end
.halt:
	mov rcx,8
.lc:
	sub rcx,1
	cinvoke64 Mix_HaltChannel,rcx
	or rcx,rcx
	jnz .lc
.end:
	mov rax,[rbp-8]
	sub rbp,8
	ret

;===============================================
;        if (TOS!=0)
;			Mix_PlayMusic((Mix_Music *)TOS, 0);
;        else
;			Mix_HaltMusic();
SYSMPLAY:
	or rax,rax
	jz .halt
	cinvoke64 Mix_PlayMusic,rax,0
	jmp .end
.halt:
	cinvoke64 Mix_HaltMusic
.end:
	mov rax,[rbp-8]
	sub rbp,8
	ret

;===============================================
;    	Mix_FreeChunk((Mix_Chunk *)TOS);
SYSSFREE:
	cinvoke64 Mix_FreeChunk,rax
	mov rax,[rbp-8]
	sub rbp,8
	ret

;===============================================
;    	Mix_FreeMusic((Mix_Music *)TOS);
SYSMFREE:
	cinvoke64 Mix_FreeMusic,rax
	mov rax,[rbp-8]
	sub rbp,8
	ret

;-----------------------------------------------
;-----------------------------------------------
section '.data' data readable writeable

  _title db "r3d",0
  _error db "err",0
  _dir rb 1024

  window dd ?
  screen dd ?

  SysTime SYSTEMTIME
  hfind	dq 0
  hdir dq 0
  afile dq 0
  cntr dq 0
  evt SDL_Event
  fdd WIN32_FIND_DATAA

  ProcessInfo PROCESS_INFORMATION
  StartupInfo STARTUPINFO

align 16
  SYSXM          dd ?
  SYSYM          dd ?
  SYSBM          dd ?
  SYSKEY         dd ?
  SYSCHAR        dd ?
align 16
  SYSFRAME       dq ? ;rd XRES*YRES
  FREE_MEM       dq ?
  DATASTK        rq 256


;----- CODE -----
align 16
  include 'data.asm'
;----- CODE -----

section '.idata' import readable

  library kernel32,'KERNEL32',\
          user32,'USER32',\
          sdl2,'SDL2',\	
		  sdl2mixer,'SDL2_mixer',\
 		  sdl2net,'SDL2_net'
  include 'include\api\kernel32.inc'
  include 'include\api\user32.inc'
  include 'sdl2_api.inc'
  include 'sdl2_mixer_api.inc'
  include 'sdl2_net_api.inc'
