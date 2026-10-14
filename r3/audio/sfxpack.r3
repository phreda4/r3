| sfxpack.r3 - sonidos listos para usar con gamesfx.r3
| Un sonido es un solo bloque de datos, sin terminador (ver gamesfx.r3):
|   tono / ruido (kind 1), 10 valores:  $kwc f0 f1 dur vol delay A D S R    k=kind w=wave c=crv, en hexa
|   wave: 0 cuadrada 1 sierra 2 seno 3 triangulo 4 pulso25 5 pulso10 ... 9 10 11 ruido blanco rosa marron
|   fxsynth (kind 3), 32 valores: $300 ... vol delay ... y los 22 parametros p_wave..p_vol
|   (se disenan en fxdemo.r3 y se copian con el boton Copy)
|   Los efectos compuestos (arpegio, repeat, filtros, vibrato) son siempre kind 3.

|---------------------------------------------------------------
| PACK "FUTBOL": port de audio.c (tone/noise con decaimiento exponencial)
| tone(f0,f1,dur,wave,vol) -> $10<wave>3 f0 f1 dur vol 0.0 0.001 dur 0.0 0.005
| noise(dur,vol)          -> $190 440.0 440.0 dur vol 0.0 0.001 dur 0.0 0.005   (wave 9 = ruido blanco)
| (en C las llamadas se encolan una tras otra; aca los sonidos compuestos son una aproximacion
|  kind 3 de un solo bloque: ajustar a oido en fxdemo.r3)
|---------------------------------------------------------------
##sfx_kick [ $103 200.0 70.0 0.09 0.14 0.0 0.001 0.09 0.0 0.005 ]
##sfx_pass [ $103 320.0 140.0 0.06 0.09 0.0 0.001 0.06 0.0 0.005 ]
##sfx_tackle [ $190 440.0 440.0 0.09 0.18 0.0 0.001 0.09 0.0 0.005 ]
##sfx_save [			| chirp que sube: cuadrada 500->900 Hz, 0.08 s
	$300 0.0 0.0 0.0 0.12 0.0 0.0 0.0 0.0 0.0
	0 0.0 0.0939 0.3 0.1627  0.3751 0.0 0.2564 0.0  0.0 0.0  0.0 0.0  0.5 0.0  1.0 0.0 0.0  0.0 0.0  0.0 0.5
	]
##sfx_bounce [ $103 140.0 90.0 0.04 0.05 0.0 0.001 0.04 0.0 0.005 ]
##sfx_crazy [			| barrido que sube con vibrato: sierra 160->1200 Hz, 0.45 s
	$300 0.0 0.0 0.0 0.14 0.0 0.0 0.0 0.0 0.0
	1 0.0 0.3637 0.0 0.2572  0.2106 0.0 0.2205 0.0  0.3 0.3  0.0 0.0  0.5 0.0  1.0 0.0 0.0  0.1 0.0  0.0 0.5
	]
##sfx_goal [			| fanfarria: cuadrada, do5 -> sol5 (salto cada 0.13 s) repetido, 0.5 s
	$300 0.0 0.0 0.0 0.12 0.0 0.0 0.0 0.0 0.0
	0 0.0 0.3929 0.35 0.2738  0.3837 0.0 0.0 0.0  0.0 0.0  0.6082 0.4661  0.5 0.0  1.0 0.0 0.0  0.0 0.0  0.2439 0.5
	]
##sfx_whistle [			| tono agudo sostenido: cuadrada 2300 Hz, 0.3 s, con vibrato leve
	$300 0.0 0.0 0.0 0.1 0.0 0.0 0.0 0.0 0.0
	0 0.0 0.2202 0.0 0.2895  0.8068 0.0 0.0 0.0  0.06 0.13  0.0 0.0  0.5 0.0  1.0 0.0 0.0  0.0 0.0  0.0 0.5
	]
##sfx_knock [			| golpe grave que cae: sierra 90->40 Hz, 0.15 s
	$300 0.0 0.0 0.0 0.14 0.0 0.0 0.0 0.0 0.0
	1 0.0 0.105 0.45 0.2348  0.1566 0.0 -0.2206 0.0  0.0 0.0  0.0 0.0  0.5 0.0  1.0 0.0 0.0  0.0 0.0  0.0 0.5
	]

|---------------------------------------------------------------
| PACK "GENERICO": sonidos tipicos de plataformas / arcade
|---------------------------------------------------------------
##sfx_jump [ $101 260.0 620.0 0.18 0.30 0.0 0.001 0.18 0.0 0.02 ]
##sfx_coin [			| moneda: seno 988 Hz que salta a 1319 Hz a los 0.07 s, 0.27 s
	$300 0.0 0.0 0.0 0.25 0.0 0.0 0.0 0.0 0.0
	2 0.0 0.1757 0.3 0.297  0.5282 0.0 0.0 0.0  0.0 0.0  0.528 0.6092  0.5 0.0  1.0 0.0 0.0  0.0 0.0  0.0 0.5
	]
##sfx_laser [			| laser: sierra 1800->300 Hz, 0.22 s
	$300 0.0 0.0 0.0 0.22 0.0 0.0 0.0 0.0 0.0
	1 0.0 0.1485 0.0 0.2738  0.7136 0.2899 -0.2643 0.0  0.0 0.0  0.0 0.0  0.5 0.0  1.0 0.0 0.0  0.0 0.0  0.0 0.5
	]
##sfx_explosion [			| explosion: ruido marron con pasa-bajos, 0.6 s
	$300 0.0 0.0 0.0 0.6 0.0 0.0 0.0 0.0 0.0
	11 0.0 0.2485 0.5 0.4504  0.5 0.0 0.0 0.0  0.0 0.0  0.0 0.0  0.5 0.0  0.55 0.0 0.0  0.0 0.0  0.0 0.5
	]
##sfx_powerup [			| power up: cuadrada 330->784 Hz, 0.46 s
	$300 0.0 0.0 0.0 0.2 0.0 0.0 0.0 0.0 0.0
	0 0.0 0.297 0.0 0.3386  0.3042 0.0 0.1667 0.0  0.0 0.0  0.0 0.0  0.5 0.0  1.0 0.0 0.0  0.0 0.0  0.0 0.5
	]
##sfx_hit [			| golpe: ruido blanco corto con filtros, 0.1 s
	$300 0.0 0.0 0.0 0.4 0.0 0.0 0.0 0.0 0.0
	3 0.0 0.0501 0.5 0.21  0.5 0.0 0.0 0.0  0.0 0.0  0.0 0.0  0.5 0.0  0.5 0.0 0.0  0.05 0.0  0.0 0.5
	]
##sfx_blip [ $100 880.0 880.0 0.05 0.25 0.0 0.001 0.05 0.8 0.01 ]
##sfx_hurt [			| danio: sierra 440->110 Hz, 0.25 s
	$300 0.0 0.0 0.0 0.3 0.0 0.0 0.0 0.0 0.0
	1 0.0 0.1485 0.0 0.297  0.3517 0.0 -0.2205 0.0  0.0 0.0  0.0 0.0  0.5 0.0  1.0 0.0 0.0  0.0 0.0  0.0 0.5
	]
##sfx_lose [ $131 440.0 110.0 0.60 0.30 0.0 0.005 0.60 0.0 0.05 ]

|---------------------------------------------------------------
| PARCHES para melodias (un tono: usa wave vol A D S R crv)
|---------------------------------------------------------------
##patch_lead [ $110 0.0 0.0 0.0 0.22 0.0 0.005 0.12 0.55 0.06 ]
##patch_bell [ $122 0.0 0.0 0.0 0.30 0.0 0.002 0.40 0.0 0.20 ]
##patch_tri [ $130 0.0 0.0 0.0 0.32 0.0 0.01 0.10 0.65 0.08 ]
##patch_bass [ $100 0.0 0.0 0.0 0.20 0.0 0.005 0.10 0.60 0.05 ]

|---------------------------------------------------------------
| MELODIAS (texto): mini-notacion Strudel, ver gamesfx.r3 / eval.r3
| un ciclo = 4 pulsos a 'bpm'; las que tienen N pasos en un ciclo piden bpm = 4/N del tempo en pulsos:
|   jingle 10 pasos a 150 pulsos/min -> bpm 60 | gameover 9 pasos a 110 -> bpm 49 | bgm: 1 compas por ciclo, bpm 132
|---------------------------------------------------------------
##tune_jingle "c5 e5 g5 c6@2 ~ g5 c6@3"
##tune_gameover "c5 b4 a#4 a4@2 ~ g4@3"
##tune_bgm_lead "<[e4 g4 a4 b4] [b4 a4 g4 e4] [d4 f#4 a4 d5] [b4@2 a4@2] [e4 g4 a4 b4] [c5 b4 a4 g4] [f#4 a4 d5 f#5] e5>"
##tune_bgm_bass "<e2 b2 d3 [g2 b2] e2 a2 d3 e2>"

|---------------------------------------------------------------
| EJEMPLO kind 3: sonido de fxsynth (32 valores, ver gamesfx.r3)
| 10 de cabecera ($300 vol delay) + p_wave p_attack ... p_vol
|---------------------------------------------------------------
##sfx_fxzap [
	$300 0.0 0.0 0.0 1.0 0.0 0.0 0.0 0.0 0.0
	0 0.0 0.15 0.0 0.2  0.8 0.5 -0.25 0.0  0.0 0.0  0.0 0.0  0.5 0.0  1.0 0.0 0.0  0.1 0.0  0.0 0.5
	]
