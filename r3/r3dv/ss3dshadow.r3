| ss3dshadow - shadows for ss3d
|
|   ... rl_init ... ss3dload ...
|   2048 ss3dshadowini           | res
|   1 ss3dshadowauto             | area y bias auto 
|   0.5 0.8 0.3  1.0 0.95 0.85 1.3 ss3dsun     | dir , col , int
|   1 ss3dshadow!                              | 1 = activate
|
| manual:  x y z r ss3dshadowarea   (esfera que debe quedar dentro del mapa)
|          normal depth ss3dshadowbias  (normal offset en mundo, bias de profundidad 0..1)
|          ss3dshadowfit             (ajusta area y bias una vez a las instancias actuales)
| PHREDA 2026
^./renderlib.r3
^./ss3d.r3

#sh_fbo 0
#sh_tex 0
#sh_res 2048
#sh_on 0
#sh_autoarea 0
#sh_autobias 0
#sh_nbias 0.12		| normal offset en unidades de mundo
#sh_dbias 0.002		| bias de profundidad (0..1 del mapa)
#sh_r 8.0
#sh_one 0
#sh_c * 24			| centro pedido
#sh_cs * 24			| centro ajustado a la grilla de texels de la luz
#sh_sun * 24
#sh_eye * 24
#sh_up * 24
#sh_s * 24
#sh_u * 24
#sh_lproj * 128
#sh_ubo * 96
#sh_sunbuf * 32

:sdx 'sh_sun @ ;
:sdy 'sh_sun 8 + @ ;
:sdz 'sh_sun 16 + @ ;

:shup | --	; up = Y salvo que el sol este casi vertical
	0 'sh_up ! 1.0 'sh_up 8 + ! 0 'sh_up 16 + !
	sdy abs 0.98 >? ( 0 'sh_up 8 + ! 1.0 'sh_up 16 + ! ) drop ;

:shtexel | -- tx	; tamano de un texel de la luz
	sh_r 2* sh_res / ;

:shshift | 'ax tx --	; corre sh_cs sobre el eje 'ax hasta la grilla de texels
	0? ( 2drop ; )
	over 'sh_c v3ddot swap		| 'ax d tx
	2dup /. 0.5 + 16 >> *		| 'ax d m
	swap - 'sh_cs -rot v3+* ;

:shupdate | --	; matriz de la luz + UBO ShadowU
	mpush										| guarda la matriz actual
	shup
	| base (derecha, arriba) de la luz: solo depende de la direccion
	'sh_eye 'sh_c v3=  'sh_eye 'sh_sun sh_r v3+*
	'sh_eye 'sh_c 'sh_up mlookat
	mat> @ 'sh_s !  mat> 32 + @ 'sh_s 8 + !  mat> 64 + @ 'sh_s 16 + !
	mat> 8 + @ 'sh_u !  mat> 40 + @ 'sh_u 8 + !  mat> 72 + @ 'sh_u 16 + !
	| centro corrido al texel mas cercano (evita el centelleo de los bordes)
	'sh_cs 'sh_c v3=
	'sh_s shtexel shshift
	'sh_u shtexel shshift
	'sh_eye 'sh_cs v3=  'sh_eye 'sh_sun sh_r v3+*
	sh_r sh_r neg sh_r sh_r neg sh_r 2* 0 mortho01	| r l t b f n
	'sh_lproj mcpy
	'sh_eye 'sh_cs 'sh_up mlookat
	'sh_lproj mm*
	'sh_ubo mat> cpymatif
	mpop mpop									| restaura la matriz actual
	ab[ 'sh_ubo 64 + >a
	sdx neg f2fp da!+ sdy neg f2fp da!+ sdz neg f2fp da!+ 0 da!+
	sh_on 16 << f2fp da!+ sh_nbias f2fp da!+ sh_dbias f2fp da!+ 0 da!+
	]ba
	rl_ubo_shadow 0? ( drop ; ) drop
	GL_UNIFORM_BUFFER rl_ubo_shadow glBindBuffer
	GL_UNIFORM_BUFFER 0 96 'sh_ubo glBufferSubData
	GL_UNIFORM_BUFFER 0 glBindBuffer ;

:sharea! | x y z r --
	'sh_r ! 'sh_c 16 + ! 'sh_c 8 + ! 'sh_c ! ;

| area (esfera de las instancias, radio redondeado a 0.25)
:shfitarea | cx cy cz r --
	sh_autoarea 0? ( drop 4drop ; ) drop
	0.25 + 16383 + 14 >> 14 << sharea! ;

| bias (en celdas de la grilla gruesa)
:shfitbias | ms --
	sh_autobias 0? ( 2drop ; ) drop
	0.01 *. ss3dshS <<			| celda gruesa en mundo
	dup 1.5 *. 'sh_nbias !
	0.25 *. sh_r 2* /. 'sh_dbias ! ;

:shfit | --
	SS3Dbounds >r shfitarea r> shfitbias ;

:shpass | --	; hook de rl_frame_end
	sh_on 0? ( drop ; ) drop
	sh_autoarea sh_autobias or 1? ( shfit shupdate ) drop
	GL_FRAMEBUFFER sh_fbo glBindFramebuffer
	0 0 sh_res sh_res glViewport
	GL_TRUE glDepthMask
	GL_DEPTH_TEST glEnable
	$1801 0 'sh_one glClearBufferfv
	SS3Dshadowdraw ;

:shtp | par v --
	GL_TEXTURE_2D -rot glTexParameteri ;

:shmaketex | --
	1 'sh_tex glGenTextures
	GL_TEXTURE_2D sh_tex glBindTexture
	GL_TEXTURE_2D 0 GL_DEPTH_COMPONENT32F sh_res sh_res 0 GL_DEPTH_COMPONENT GL_FLOAT 0 glTexImage2D
	GL_TEXTURE_MIN_FILTER GL_LINEAR shtp
	GL_TEXTURE_MAG_FILTER GL_LINEAR shtp
	GL_TEXTURE_WRAP_S GL_CLAMP_TO_EDGE shtp
	GL_TEXTURE_WRAP_T GL_CLAMP_TO_EDGE shtp
	GL_TEXTURE_COMPARE_MODE GL_COMPARE_REF_TO_TEXTURE shtp
	GL_TEXTURE_COMPARE_FUNC GL_LEQUAL shtp
	GL_TEXTURE_2D 0 glBindTexture
	1 'sh_fbo glGenFramebuffers
	GL_FRAMEBUFFER sh_fbo glBindFramebuffer
	GL_FRAMEBUFFER GL_DEPTH_ATTACHMENT GL_TEXTURE_2D sh_tex 0 glFramebufferTexture2D
	GL_NONE glDrawBuffer
	GL_NONE glReadBuffer
	GL_FRAMEBUFFER 0 glBindFramebuffer ;

::ss3dshadowini | res --	; despues de rl_init y ss3dload
	'sh_res !
	SS3Dshadowbuild
	$3f800000 'sh_one !
	shmaketex
	sh_tex 'rl_shadow_tex !
	'shpass 'rl_shadow_hook !
	0 'sh_sun ! 1.0 'sh_sun 8 + ! 0 'sh_sun 16 + !
	shupdate ;

::ss3dshadowend | --
	0 'rl_shadow_hook !
	0 'rl_shadow_tex !
	1 'sh_fbo glDeleteFramebuffers		| glDelete* ignora el nombre 0
	1 'sh_tex glDeleteTextures
	0 'sh_fbo ! 0 'sh_tex ! ;

::ss3dshadow! | 0/1 --	; activa / desactiva las sombras
	'sh_on ! shupdate ;

::ss3dshadow@ | -- 0/1
	sh_on ;

::ss3dshadowarea | x y z r --	; esfera (centro y radio) que cubre el mapa de sombras (desactiva el area automatica)
	0 'sh_autoarea !
	sharea! shupdate ;

::ss3dshadowbias | normal depth --	; normal offset (mundo) y bias de profundidad (0..1) (desactiva el bias automatico)
	0 'sh_autobias !
	'sh_dbias ! 'sh_nbias ! shupdate ;

::ss3dshadowauto | 0/1 --	; area y bias automaticos: se recalculan cada frame segun las instancias
	dup 'sh_autoarea ! dup 'sh_autobias !
	1? ( shfit ) drop
	shupdate ;

::ss3dshadowfit | --	; ajusta area y bias una vez a las instancias actuales
	sh_autoarea sh_autobias
	1 'sh_autoarea ! 1 'sh_autobias !
	shfit
	'sh_autobias ! 'sh_autoarea !
	shupdate ;

::ss3dsun | dx dy dz cr cg cb i --	; direccion HACIA el sol (cualquier largo), color e intensidad
	f2fp 'sh_sunbuf 28 + d!			| i
	f2fp 'sh_sunbuf 24 + d!			| cb
	f2fp 'sh_sunbuf 20 + d!			| cg
	f2fp 'sh_sunbuf 16 + d!			| cr
	'sh_sun 16 + ! 'sh_sun 8 + ! 'sh_sun !
	'sh_sun v3nor
	ab[ 'sh_sunbuf >a
	sdx f2fp da!+ sdy f2fp da!+ sdz f2fp da!+ 0 da!+
	]ba
	'sh_sunbuf rl_set_sun
	shupdate ;
