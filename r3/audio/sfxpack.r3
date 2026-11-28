| sfxpack.r3 - sonidos listos para usar con gamesfx.r3
| Un sonido es un solo bloque de datos, sin terminador (ver gamesfx.r3):
|   tono / ruido (kind 1), 10 valores:  $kwc f0 f1 dur vol delay A D S R    k=kind w=wave c=crv, en hexa
|   wave: 0 cuadrada 1 sierra 2 seno 3 triangulo 4 pulso25 5 pulso10 ... 9 10 11 ruido blanco rosa marron
|   Un bloque es un solo tono con barrido: los efectos compuestos (arpegio, repeat) se hacen con sfxtune.

|---------------------------------------------------------------
| PACK "FUTBOL": port de audio.c (tone/noise con decaimiento exponencial)
| tone(f0,f1,dur,wave,vol) -> $10<wave>3 f0 f1 dur vol 0.0 0.001 dur 0.0 0.005
| noise(dur,vol)          -> $190 440.0 440.0 dur vol 0.0 0.001 dur 0.0 0.005   (wave 9 = ruido blanco)
| (en C las llamadas se encolan una tras otra; aca los sonidos compuestos son una aproximacion
|  de un solo tono con barrido: ajustar a oido en sfxdemo.r3)
|---------------------------------------------------------------
##sfx_kick [ $103 200.0 70.0 0.09 0.14 0.0 0.001 0.09 0.0 0.005 ]
##sfx_pass [ $103 320.0 140.0 0.06 0.09 0.0 0.001 0.06 0.0 0.005 ]
##sfx_tackle [ $190 440.0 440.0 0.09 0.18 0.0 0.001 0.09 0.0 0.005 ]
##sfx_save [ $103 500.0 900.0 0.08 0.12 0.0 0.001 0.08 0.0 0.005 ]	| chirp que sube: cuadrada 500->900 Hz, 0.08 s
##sfx_bounce [ $103 140.0 90.0 0.04 0.05 0.0 0.001 0.04 0.0 0.005 ]
##sfx_crazy [ $113 160.0 1200.0 0.45 0.14 0.0 0.001 0.45 0.0 0.01 ]	| barrido que sube: sierra 160->1200 Hz, 0.45 s
##sfx_goal [ $101 523.25 783.99 0.5 0.12 0.0 0.002 0.5 0.0 0.01 ]	| sube: cuadrada, do5 -> sol5, 0.5 s
##sfx_whistle [ $100 2300.0 2300.0 0.3 0.1 0.0 0.02 0.05 0.7 0.05 ]	| tono agudo sostenido: cuadrada 2300 Hz, 0.3 s
##sfx_knock [ $113 90.0 40.0 0.15 0.14 0.0 0.001 0.15 0.0 0.005 ]	| golpe grave que cae: sierra 90->40 Hz, 0.15 s

|---------------------------------------------------------------
| PACK "GENERICO": sonidos tipicos de plataformas / arcade
|---------------------------------------------------------------
##sfx_jump [ $101 260.0 620.0 0.18 0.30 0.0 0.001 0.18 0.0 0.02 ]
##sfx_coin [ $123 988.0 1319.0 0.15 0.25 0.0 0.001 0.15 0.0 0.1 ]	| moneda: seno 988->1319 Hz, 0.15 s
##sfx_laser [ $113 1800.0 300.0 0.22 0.22 0.0 0.001 0.22 0.0 0.005 ]	| laser: sierra 1800->300 Hz, 0.22 s
##sfx_explosion [ $1b3 440.0 440.0 0.6 0.5 0.0 0.002 0.6 0.0 0.05 ]	| explosion: ruido marron, 0.6 s
##sfx_powerup [ $101 330.0 784.0 0.46 0.2 0.0 0.002 0.46 0.0 0.01 ]	| power up: cuadrada 330->784 Hz, 0.46 s
##sfx_hit [ $193 440.0 440.0 0.1 0.3 0.0 0.001 0.1 0.0 0.005 ]	| golpe: ruido blanco corto, 0.1 s
##sfx_blip [ $100 880.0 880.0 0.05 0.25 0.0 0.001 0.05 0.8 0.01 ]
##sfx_hurt [ $113 440.0 110.0 0.25 0.3 0.0 0.001 0.25 0.0 0.01 ]	| danio: sierra 440->110 Hz, 0.25 s
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
