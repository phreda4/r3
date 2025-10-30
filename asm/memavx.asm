; DLL for avx memory moves - OPTIMIZED
; PHREDA 2025
;
format PE64 DLL
entry DllMain
include 'include/win64a.inc'

;--------------------------------------------------------------------
section '.code' code readable executable
 
proc DllMain hinstDLL,fdwReason,lpvReserved
	mov rax, TRUE
	ret
endp

; -----------------------------------------------------------------------------
; memcpy_rgb3f - OPTIMIZADO
; Convierte N píxeles 0x00RRGGBB en 3 planos float32 normalizados (R,G,B)
; Requisitos:
;   - src y dst alineados a 32 bytes
;   - N múltiplo de 8
; Parámetros:
;   RCX = src (uint32_t*)
;   RDX = dst (float*)
;   R8  = N   (# píxeles)
; -----------------------------------------------------------------------------
memcpy_rgb3f:
    push    rbx
    push    rsi
    push    rdi
    
    mov     rsi, rcx                ; src
    mov     rdi, rdx                ; dst base
    mov     rbx, r8                 ; N
    
    ; Precalcular punteros a los 3 planos
    shl     rbx, 2                  ; N*4 (más rápido que lea)
    mov     rax, rdi                ; r_ptr
    lea     rdx, [rdi + rbx]        ; g_ptr
    lea     r11, [rdi + rbx*2]      ; b_ptr
    
    ; Cargar constantes UNA SOLA VEZ
    vbroadcastss ymm6, [norm_1_over_255_avx]
    vmovdqa      ymm7, [mask_ff_dwords_avx]
    
    ; N/8 bloques
    shr     r8, 3                   ; cnt = N / 8
    
.avx_loop:
    ; Usar vmovdqa (aligned) es más rápido que vmovdqu
    vmovdqa ymm0, [rsi]
    
    ; --- canal B (optimizado: menos dependencias) ---
    vpand   ymm1, ymm0, ymm7
    vcvtdq2ps ymm1, ymm1
    vmulps  ymm1, ymm1, ymm6
    vmovaps [r11], ymm1
    
    ; --- canal G ---
    vpsrld  ymm2, ymm0, 8
    vpand   ymm2, ymm2, ymm7
    vcvtdq2ps ymm2, ymm2
    vmulps  ymm2, ymm2, ymm6
    vmovaps [rdx], ymm2
    
    ; --- canal R ---
    vpsrld  ymm3, ymm0, 16
    vpand   ymm3, ymm3, ymm7
    vcvtdq2ps ymm3, ymm3
    vmulps  ymm3, ymm3, ymm6
    vmovaps [rax], ymm3
    
    ; Avanzar punteros (combinar incrementos reduce latencia)
    add     rsi, 32
    add     rax, 32
    add     rdx, 32
    add     r11, 32
    
    dec     r8
    jnz     .avx_loop
    
    vzeroupper
    pop     rdi
    pop     rsi
    pop     rbx
    ret

; -----------------------------------------------------------------------------
; memcpy_bgr3f - OPTIMIZADO
; -----------------------------------------------------------------------------
memcpy_bgr3f:
    push    rbx
    push    rsi
    push    rdi
    
    mov     rsi, rcx
    mov     rdi, rdx
    mov     rbx, r8
    
    shl     rbx, 2                  ; N*4
    mov     rax, rdi                ; b_ptr
    lea     rdx, [rdi + rbx]        ; g_ptr
    lea     r11, [rdi + rbx*2]      ; r_ptr
    
    vbroadcastss ymm6, [norm_1_over_255_avx]
    vmovdqa      ymm7, [mask_ff_dwords_avx]
    
    shr     r8, 3
    
.avx_loop:
    vmovdqa ymm0, [rsi]
    
    ; --- canal B ---
    vpand   ymm1, ymm0, ymm7
    vcvtdq2ps ymm1, ymm1
    vmulps  ymm1, ymm1, ymm6
    vmovaps [rax], ymm1
    
    ; --- canal G ---
    vpsrld  ymm2, ymm0, 8
    vpand   ymm2, ymm2, ymm7
    vcvtdq2ps ymm2, ymm2
    vmulps  ymm2, ymm2, ymm6
    vmovaps [rdx], ymm2
    
    ; --- canal R ---
    vpsrld  ymm3, ymm0, 16
    vpand   ymm3, ymm3, ymm7
    vcvtdq2ps ymm3, ymm3
    vmulps  ymm3, ymm3, ymm6
    vmovaps [r11], ymm3
    
    add     rsi, 32
    add     rax, 32
    add     rdx, 32
    add     r11, 32
    
    dec     r8
    jnz     .avx_loop
    
    vzeroupper
    pop     rdi
    pop     rsi
    pop     rbx
    ret

; -----------------------------------------------------------------------------
; memcpy_rgbf - MEJORADO con loop escalar funcional
; -----------------------------------------------------------------------------
memcpy_rgbf:
    push rbx
    push rsi
    push rdi
    
    mov rsi, rcx
    mov rdi, rdx
    mov r9, r8
    
    ; Cargar constante 1/255.0
    vbroadcastss xmm15, [norm_1_over_255_avx]
    
    ; Procesar de a 4 píxeles
    cmp r9, 4
    jb .scalar_loop
    
.vector_loop:
    cmp r9, 4
    jb .scalar_loop
    
    movdqu xmm0, [rsi]
    
    ; Píxel 0
    movd eax, xmm0
    movzx ecx, al                ; B
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15
    movss [rdi], xmm1
    
    movzx ecx, ah                ; G
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15
    movss [rdi+4], xmm1
    
    shr eax, 16
    movzx ecx, al                ; R
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15
    movss [rdi+8], xmm1
    
    ; Píxel 1
    psrldq xmm0, 4
    movd eax, xmm0
    movzx ecx, al
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15
    movss [rdi+12], xmm1
    
    movzx ecx, ah
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15
    movss [rdi+16], xmm1
    
    shr eax, 16
    movzx ecx, al
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15
    movss [rdi+20], xmm1
    
    ; Píxel 2
    psrldq xmm0, 4
    movd eax, xmm0
    movzx ecx, al
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15
    movss [rdi+24], xmm1
    
    movzx ecx, ah
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15
    movss [rdi+28], xmm1
    
    shr eax, 16
    movzx ecx, al
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15
    movss [rdi+32], xmm1
    
    ; Píxel 3
    psrldq xmm0, 4
    movd eax, xmm0
    movzx ecx, al
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15
    movss [rdi+36], xmm1
    
    movzx ecx, ah
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15
    movss [rdi+40], xmm1
    
    shr eax, 16
    movzx ecx, al
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15
    movss [rdi+44], xmm1
    
    add rsi, 16
    add rdi, 48
    sub r9, 4
    jmp .vector_loop

.scalar_loop:
    test r9, r9
    jz .done
    
    ; Procesar píxeles restantes uno a uno
    mov eax, [rsi]
    
    movzx ecx, al                ; B
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15
    movss [rdi], xmm1
    
    movzx ecx, ah                ; G
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15
    movss [rdi+4], xmm1
    
    shr eax, 16
    movzx ecx, al                ; R
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15
    movss [rdi+8], xmm1
    
    add rsi, 4
    add rdi, 12
    dec r9
    jnz .scalar_loop

.done:
    pop rdi
    pop rsi
    pop rbx
    ret

; -----------------------------------------------------------------------------
; memcpy_f32p16 - OPTIMIZADO (sin stack frame innecesario)
; -----------------------------------------------------------------------------
memcpy_f32p16:
    mov     rax, r8
    shr     rax, 3
    jz      .tail
    
    vbroadcastss ymm2, [scale_65536]
    
.loop:
    vmovups ymm0, [rcx]
    vmulps  ymm0, ymm0, ymm2
    vcvtps2dq ymm1, ymm0
    vmovdqu [rdx], ymm1
    
    add     rcx, 32
    add     rdx, 32
    dec     rax
    jnz     .loop
    
.tail:
    and     r8, 7
    jz      .done
    
    vbroadcastss xmm2, [scale_65536]
    
.tail_loop:
    vmovss  xmm0, [rcx]
    vmulss  xmm0, xmm0, xmm2
    cvtss2si eax, xmm0
    mov     [rdx], eax
    
    add     rcx, 4
    add     rdx, 4
    dec     r8
    jnz     .tail_loop
    
.done:
    vzeroupper
    ret

; -----------------------------------------------------------------------------
; memcpy_p16f32 - OPTIMIZADO (sin stack frame innecesario)
; -----------------------------------------------------------------------------
memcpy_p16f32:
    mov     rax, r8
    shr     rax, 3
    jz      .tail
    
    vbroadcastss ymm2, [inv_65536]
    
.loop:
    vmovdqu ymm0, [rcx]
    vcvtdq2ps ymm1, ymm0
    vmulps   ymm1, ymm1, ymm2
    vmovups  [rdx], ymm1
    
    add      rcx, 32
    add      rdx, 32
    dec      rax
    jnz      .loop
    
.tail:
    and     r8, 7
    jz      .done
    
    vbroadcastss xmm2, [inv_65536]
    
.tail_loop:
    mov     eax, [rcx]
    movd    xmm0, eax
    vcvtdq2ps xmm1, xmm0
    vmulss   xmm1, xmm1, xmm2
    vmovss   [rdx], xmm1
    
    add      rcx, 4
    add      rdx, 4
    dec      r8
    jnz      .tail_loop
    
.done:
    vzeroupper
    ret

; -----------------------------------------------------------------------------
; memcpy_avx - OPTIMIZADO con prefetch y unrolling
; -----------------------------------------------------------------------------
memcpy_avx:
    push rbx
    mov rax, rcx
    
    test r8, r8
    jz .done
    
    ; Si es muy pequeño, usar ruta escalar
    cmp r8, 32
    jb .small_copy
    
    ; Loop desenrollado para copias grandes (64 bytes por iteración)
    cmp r8, 64
    jb .medium_copy
    
.large_loop:
    ; Prefetch adelantado
    prefetchnta [rdx + 128]
    
    vmovdqu ymm0, [rdx]
    vmovdqu ymm1, [rdx + 32]
    vmovdqu [rcx], ymm0
    vmovdqu [rcx + 32], ymm1
    
    add rcx, 64
    add rdx, 64
    sub r8, 64
    cmp r8, 64
    jae .large_loop

.medium_copy:
    cmp r8, 32
    jb .small_copy
    
    vmovdqu ymm0, [rdx]
    vmovdqu [rcx], ymm0
    add rcx, 32
    add rdx, 32
    sub r8, 32
    jmp .medium_copy

.small_copy:
    test r8, r8
    jz .done
    
    cmp r8, 16
    jb .check_8
    movdqu xmm0, [rdx]
    movdqu [rcx], xmm0
    add rcx, 16
    add rdx, 16
    sub r8, 16

.check_8:
    cmp r8, 8
    jb .check_4
    mov rbx, [rdx]
    mov [rcx], rbx
    add rcx, 8
    add rdx, 8
    sub r8, 8

.check_4:
    cmp r8, 4
    jb .check_2
    mov ebx, [rdx]
    mov [rcx], ebx
    add rcx, 4
    add rdx, 4
    sub r8, 4

.check_2:
    cmp r8, 2
    jb .check_1
    mov bx, [rdx]
    mov [rcx], bx
    add rcx, 2
    add rdx, 2
    sub r8, 2

.check_1:
    test r8, r8
    jz .done
    mov bl, [rdx]
    mov [rcx], bl

.done:
    vzeroupper
    pop rbx
    ret

;--------------------------------------------------------------------
section '.rdata' data readable

align 32	
mask_ff_dwords_avx: dd 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
norm_1_over_255_avx dd 0.0039215686274509803
scale_65536   dd 65536.0
inv_65536     dd 0.0000152587890625

section '.edata' export data readable

	export 'memavx.dll',\
	memcpy_rgb3f,'memcpy_rgb3f',\
	memcpy_bgr3f,'memcpy_bgr3f',\
	memcpy_rgbf,'memcpy_rgbf',\
	memcpy_f32p16,'memcpy_f32p16',\
	memcpy_p16f32,'memcpy_p16f32',\
	memcpy_avx,'memcpy_avx'
	
section '.reloc' fixups data readable discardable
    if $=$$
        dd 0,8
    end if