; DLL for avx memmory moves
; PHREDA 2025
;
format PE64 DLL
entry DllMain
include 'include/win64a.inc'

;--------------------------------------------------------------------
section '.code' code readable writeable executable
 
proc DllMain hinstDLL,fdwReason,lpvReserved
	mov rax, TRUE
	ret
endp

; -----------------------------------------------------------------------------
; memcpy_rgb3f
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
    ; Prologue
    push    rbx
    push    rsi
    push    rdi
    mov     rsi, rcx                ; src
    mov     rdi, rdx                ; dst base
    mov     rbx, r8                 ; N
    ; calcular punteros a los 3 planos
    lea     r9,  [rbx*4]            ; N*4 bytes
    mov     rax, rdi                ; r_ptr
    lea     rdx, [rdi + r9]         ; g_ptr
    lea     r11, [rdi + r9*2]       ; b_ptr
    ; cargar constantes
    vbroadcastss ymm6, [norm_1_over_255_avx] ; 1/255
    vmovdqa      ymm7, [mask_ff_dwords_avx] ; 0xFF por dword
    ; N/8 bloques
    mov     rcx, rbx
    shr     rcx, 3                  ; cnt = N / 8 (bloques de 8 píxeles)
.avx_loop:
    vmovdqa ymm0, [rsi]             ; cargar 8 píxeles (32 bytes alineados)
    ; --- canal B ---
    vpand   ymm1, ymm0, ymm7
    vcvtdq2ps ymm1, ymm1
    vmulps  ymm1, ymm1, ymm6
    vmovaps [r11], ymm1             ; guardar 8 floats
    add     r11, 32
    ; --- canal G ---
    vpsrld  ymm2, ymm0, 8
    vpand   ymm2, ymm2, ymm7
    vcvtdq2ps ymm2, ymm2
    vmulps  ymm2, ymm2, ymm6
    vmovaps [rdx], ymm2
    add     rdx, 32
    ; --- canal R ---
    vpsrld  ymm3, ymm0, 16
    vpand   ymm3, ymm3, ymm7
    vcvtdq2ps ymm3, ymm3
    vmulps  ymm3, ymm3, ymm6
    vmovaps [rax], ymm3
    add     rax, 32
    ; avanzar origen
    add     rsi, 32
    dec     rcx
    jnz     .avx_loop
    ; epílogo
    vzeroupper
    pop     rdi
    pop     rsi
    pop     rbx
    ret

; -----------------------------------------------------------------------------
memcpy_bgr3f:
    push    rbx
    push    rsi
    push    rdi
    mov     rsi, rcx                ; src
    mov     rdi, rdx                ; dst base
    mov     rbx, r8                 ; N
    ; calcular punteros a los 3 planos  
    lea     r9,  [rbx*4]            ; N*4 bytes
    mov     rax, rdi                ; b_ptr (BGR -> B primero)
    lea     rdx, [rdi + r9]         ; g_ptr
    lea     r11, [rdi + r9*2]       ; r_ptr (R último en BGR)
    ; cargar constantes
    vbroadcastss ymm6, [norm_1_over_255_avx]
    vmovdqa      ymm7, [mask_ff_dwords_avx]
    ; N/8 bloques
    mov     rcx, rbx
    shr     rcx, 3
.avx_loop:
    vmovdqa ymm0, [rsi]             ; cargar 8 píxeles
    ; --- canal B (bits 0-7) ---
    vpand   ymm1, ymm0, ymm7        ; Extraer B correctamente
    vcvtdq2ps ymm1, ymm1
    vmulps  ymm1, ymm1, ymm6
    vmovaps [rax], ymm1             ; B va al primer plano
    add     rax, 32
    ; --- canal G (bits 8-15) ---
    vpsrld  ymm2, ymm0, 8
    vpand   ymm2, ymm2, ymm7
    vcvtdq2ps ymm2, ymm2
    vmulps  ymm2, ymm2, ymm6
    vmovaps [rdx], ymm2
    add     rdx, 32
    ; --- canal R (bits 16-23) ---
    vpsrld  ymm3, ymm0, 16          ; Corregido: inicializar ymm3
    vpand   ymm3, ymm3, ymm7        ; Corregido: usar ymm3
    vcvtdq2ps ymm3, ymm3
    vmulps  ymm3, ymm3, ymm6
    vmovaps [r11], ymm3             ; R va al último plano
    add     r11, 32
    ; avanzar origen
    add     rsi, 32
    dec     rcx
    jnz     .avx_loop
    vzeroupper
    pop     rdi
    pop     rsi
    pop     rbx
    ret

; -----------------------------------------------------------------------------
memcpy_rgbf:
    push rbx
    push rsi
    push rdi
    mov rsi, rcx            ; src
    mov rdi, rdx            ; dst
    mov r9, r8              ; count
    ; Cargar constante 1/255.0 en XMM15
    mov eax, 0x3B808081
    movd xmm15, eax
    shufps xmm15, xmm15, 0  ; broadcast
    ; Procesar de a 4 píxeles usando XMM (más simple que YMM para intercalado)
    cmp r9, 4
    jb .scalar_loop
.vector_loop:
    cmp r9, 4
    jb .scalar_loop
    ; Cargar 4 píxeles (16 bytes)
    movdqu xmm0, [rsi]      ; xmm0 = [P3|P2|P1|P0]
    ; Procesar píxel por píxel dentro del registro
    ; Píxel 0
    movd eax, xmm0
    mov ecx, eax
    and ecx, 0xFF           ; B
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15
    movss [rdi], xmm1
    mov ecx, eax
    shr ecx, 8
    and ecx, 0xFF           ; G  
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15
    movss [rdi+4], xmm1
    shr eax, 16
    and eax, 0xFF           ; R
    cvtsi2ss xmm1, eax
    mulss xmm1, xmm15
    movss [rdi+8], xmm1
    ; Píxel 1
    psrldq xmm0, 4          ; shift right 4 bytes
    movd eax, xmm0
    mov ecx, eax
    and ecx, 0xFF           ; B
    cvtsi2ss xmm1, ecx  
    mulss xmm1, xmm15
    movss [rdi+12], xmm1
    mov ecx, eax
    shr ecx, 8
    and ecx, 0xFF           ; G
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15  
    movss [rdi+16], xmm1
    shr eax, 16
    and eax, 0xFF           ; R
    cvtsi2ss xmm1, eax
    mulss xmm1, xmm15
    movss [rdi+20], xmm1
    ; Píxel 2  
    psrldq xmm0, 4
    movd eax, xmm0
    mov ecx, eax
    and ecx, 0xFF           ; B
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15
    movss [rdi+24], xmm1
    mov ecx, eax  
    shr ecx, 8
    and ecx, 0xFF           ; G
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15
    movss [rdi+28], xmm1
    shr eax, 16
    and eax, 0xFF           ; R
    cvtsi2ss xmm1, eax
    mulss xmm1, xmm15
    movss [rdi+32], xmm1
    ; Píxel 3
    psrldq xmm0, 4
    movd eax, xmm0
    mov ecx, eax
    and ecx, 0xFF           ; B
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15  
    movss [rdi+36], xmm1
    
    mov ecx, eax
    shr ecx, 8
    and ecx, 0xFF           ; G
    cvtsi2ss xmm1, ecx
    mulss xmm1, xmm15
    movss [rdi+40], xmm1
    
    shr eax, 16  
    and eax, 0xFF           ; R
    cvtsi2ss xmm1, eax
    mulss xmm1, xmm15
    movss [rdi+44], xmm1
    
    add rsi, 16             ; 4 píxeles
    add rdi, 48             ; 4 * 12 bytes
    sub r9, 4
    jmp .vector_loop

.scalar_loop:

.done:
    pop rdi
    pop rsi
    pop rbx  
    ret
	
;|-----------	
memcpy_rgbf_BASE:
    push    rbx
    push    rsi
    push    rdi
    mov     rsi, rcx             ; src
    mov     rdi, rdx             ; dst
    ;mov     r9,  r8              ; count
    ; xmm15 = 1/255
    mov     eax,0x3B808081       ; 0.0039215689f
    movd    xmm15,eax
    shufps  xmm15,xmm15,0
.loop:
    test    r8,r8
    jz      .done
    ; Leer 4 bytes RGBA
    mov     eax,[rsi]            ; EAX = 0xXXBBGGRR
    ; Extraer R,G,B
    mov     ecx,eax
    and     ecx,0xFF             ; R
    shr     eax,8
    mov     edx,eax
    and     edx,0xFF             ; G
    shr     eax,8
    and     eax,0xFF             ; B
    ; Convertir y normalizar
    cvtsi2ss xmm0,ecx
    mulss   xmm0,xmm15
    movss   [rdi],xmm0           ; R
    cvtsi2ss xmm0,edx
    mulss   xmm0,xmm15
    movss   [rdi+4],xmm0         ; G
    cvtsi2ss xmm0,eax
    mulss   xmm0,xmm15
    movss   [rdi+8],xmm0         ; B
    ; avanzar
    add     rsi,4                ; 4 bytes RGBA
    add     rdi,12               ; 3 floats
    dec     r8
    jmp     .loop
.done:
    pop     rdi
    pop     rsi
    pop     rbx
    ret

; -----------------------------------------------------------------------------
; void memcpy_f32p16(const float* src, int32_t* dst, size_t count)
; RCX = src, RDX = dst, R8 = count
; Convierte float32 -> Q16.16 (int32).
; -----------------------------------------------------------------------------
memcpy_f32p16:
	;sub     rsp, 40
	mov     rax, r8
	shr     rax, 3
	jz      .tail
	vbroadcastss ymm2, [scale_65536]  ; escala = 65536.0f
.loop:
	vmovups ymm0, [rcx]      ; cargar 8 floats (no alineado)
	vmulps  ymm0, ymm0, ymm2
	vcvtps2dq ymm1, ymm0
	vmovdqu [rdx], ymm1      ; guardar 8 int32 (no alineado)
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
	;add     rsp, 40
	ret

; -----------------------------------------------------------------------------
; void q16_16_to_f32(const int32_t* src, float* dst, size_t count)
; RCX = src, RDX = dst, R8 = count
; Convierte Q16.16 -> float32.
; -----------------------------------------------------------------------------
memcpy_p16f32:
	sub     rsp, 40
	mov     rax, r8
	shr     rax, 3
	jz      .tail2
	vbroadcastss ymm2, [inv_65536]    ; 1/65536.0f
.loop2:
	vmovdqu ymm0, [rcx]      ; cargar 8 int32 (no alineado)
	vcvtdq2ps ymm1, ymm0
	vmulps   ymm1, ymm1, ymm2
	vmovups  [rdx], ymm1     ; guardar 8 floats (no alineado)
	add      rcx, 32
	add      rdx, 32
	dec      rax
	jnz      .loop2
.tail2:
	and     r8, 7
	jz      .done2
	vbroadcastss xmm2, [inv_65536]
.tail_loop2:
	mov     eax, [rcx]
	movd    xmm0, eax
	vcvtdq2ps xmm1, xmm0
	vmulss   xmm1, xmm1, xmm2
	vmovss   [rdx], xmm1
	add      rcx, 4
	add      rdx, 4
	dec      r8
	jnz      .tail_loop2
.done2:
	vzeroupper
	add     rsp, 40
	ret

; memcpy_avx
; RCX = dest (puntero al destino)
; RDX = src (puntero a la fuente)
; R8  = n (número de bytes a copiar)
memcpy_avx:
	push rbx
	mov rax, rcx        ; Guardar el puntero de destino para retornarlo
    ; Si n == 0, salir
	test r8, r8
	jz .done
    ; Comprobar si podemos usar AVX (copias de 32 bytes)
	cmp r8, 32
	jb .small_ini
    ; Bucle principal para copias grandes usando YMM (32 bytes por iteración)
.large_copy:
	vmovdqu ymm0, [rdx]     ; Cargar 32 bytes desde src
	vmovdqu [rcx], ymm0     ; Escribir 32 bytes en dest
	add rcx, 32
	add rdx, 32
	sub r8, 32
	cmp r8, 32
	jae .large_copy
    ; Manejar los bytes restantes (< 32 bytes)
.small_copy:
    cmp r8, 0
    je .done
.small_ini:
    ; Comprobar si hay al menos 16 bytes
    cmp r8, 16
    jb .check_8
    movdqu xmm0, [rdx]      ; Cargar 16 bytes desde src
    movdqu [rcx], xmm0      ; Escribir 16 bytes en dest
    add rcx, 16
    add rdx, 16
    sub r8, 16
.check_8:
    cmp r8, 8
    jb .check_4
    mov rax, [rdx]          ; Cargar 8 bytes desde src
    mov [rcx], rax          ; Escribir 8 bytes en dest
    add rcx, 8
    add rdx, 8
    sub r8, 8
.check_4:
    cmp r8, 4
    jb .check_2
    mov eax, [rdx]          ; Cargar 4 bytes desde src
    mov [rcx], eax          ; Escribir 4 bytes en dest
    add rcx, 4
    add rdx, 4
    sub r8, 4
.check_2:
    cmp r8, 2
    jb .check_1
    mov ax, [rdx]           ; Cargar 2 bytes desde src
    mov [rcx], ax           ; Escribir 2 bytes en dest
    add rcx, 2
    add rdx, 2
    sub r8, 2
.check_1:
    cmp r8, 1
    jb .done
    mov al, [rdx]           ; Cargar 1 byte desde src
    mov [rcx], al           ; Escribir 1 byte en dest.done:
.done:
	vzeroupper          ; Limpiar estado de registros YMM para evitar penalizaciones
	pop rbx
	ret

;--------------------------------------------------------------------
section '.rdata' data readable

align 32	
mask_ff_dwords_avx: dd 0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh,0FFh
norm_1_over_255_avx dd 0.0039215686274509803
scale_65536   dd 65536.0
inv_65536     dd 0.0000152587890625    ; 1/65536

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