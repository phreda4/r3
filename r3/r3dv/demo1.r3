| demo_shapes.r3 - Demo todas las formas
| Cubo (geom) + Esfera, Capsula, Cilindro, Cono, Disco, Plano (impostors)
| PHREDA 2026
^./renderlib.r3
^./rlhud.r3
^./rlshapes.r3

| ============================================================
| CAMARA
| ============================================================

#cam_yaw  -0.6
#cam_pit   0.35
#cam_dist  9.0
#camEye   -10.0 2.0 0.0
#camTo      0.0 0.0 0.0
#camUp      0.0 1.0 0.0

| ============================================================
| LUZ
| ============================================================

#fsun [
-2.5 2.0 -1.5 0
 1.0 1.0  1.0 1.1 ]

| ============================================================
| ESCENA
| Disposicion: formas en circulo, cada una orbitando/girando
|
|  Posiciones fijas en circulo radio=3.5, paso=PI*2/6
|  0: cubo      (derecha)
|  1: esfera    (der-abajo)
|  2: capsula   (izq-abajo)
|  3: cilindro  (izquierda)
|  4: cono      (izq-arriba)
|  5: disco     (der-arriba)
|  Centro: plano inclinado
| ============================================================

:drawscene

    | --- PLANO INFINITO (fondo/suelo) ---
    matini
    0 -0.8 0 matpos
    0.0 $33441100 draw_plane   | 0 = infinito

    | --- CUBO - gira sobre si mismo, posicion fija ---
    matini
    3.5 0 0 matpos
    msec 2 << 0 msec 3 << matrot
    0.7 dup dup matscale
    $ff6644f0 draw_cube

    | --- ESFERA - pulsa y orbita lento ---
    matini
    msec 5 << cos 3.5 *. 0.2 msec 5 << sin 3.5 *. matpos
    |0.2 0 matpos
    msec 3 << sin 0.08 *. 0.55 + dup dup matscale
    0.55 $44ccfff2 draw_sphere

    | --- CAPSULA - parada, gira lento en Y ---
    matini
    -3.5 0 0 matpos
    0 msec 4 << 0 matrot
    
    0.3 1.1 $88ff44f0 draw_capsule

    | --- CILINDRO - tumbado, rueda ---
    matini
    0 0 3.5 matpos
    msec 3 << 0 msec 4 << matrot   | rueda sobre Z
    0.35 0.9 $ffcc22f0 draw_cylinder

    | --- CONO - orbita vertical, apunta arriba ---
    matini
    msec 4 << sin 3.0 *. 0 msec 4 << cos 3.0 *. matpos
    0.4 1.0 $ff44aaf8 draw_cone

    | --- DISCO - gira inclinado en el centro ---
    matini
    0 0.5 0 matpos
    msec 3 << 0 msec 4 << matrot   | inclinacion animada
    1.1 $ffffff88 draw_disc
    ;

| ============================================================
| CAMARA
| ============================================================

#xp #yp
:movecam
    sdlx dup xp - 0.002 * 'cam_yaw +! 'xp !
    sdly dup yp - neg 0.002 *
    cam_pit + 1.4 min -1.4 max 'cam_pit !
    'yp !
:calcam
    'camEye >a
    cam_yaw cos cam_pit cos *. cam_dist *. a!+
    cam_pit sin cam_dist *. a!+
    cam_yaw sin cam_pit cos *. cam_dist *. a!
    'camEye 'camTo 'camUp rl_camera ;
:wheelcam
    SDLw 0? ( drop ; ) neg
    0.3 * 'cam_dist +!
    cam_dist 2.0 max 'cam_dist !
    calcam ;

| ============================================================
| LUCES
| ============================================================

:set_lights
    'fsun rl_set_sun

    | luz roja orbita izquierda-abajo
    1.5 0.9 0.1 0.1
    msec 3 <<
    dup cos -4 *
    over sin -4 *
    rot sin 3.0 *.
    rl_point_light

    | luz azul orbita derecha-arriba
    1.5 0.1 0.3 0.9
    msec 3 <<
    dup cos 4 *
    over sin 4 *
    rot 0.5 + sin 3.0 *.
    rl_point_light

    | luz blanca cenital fija
    2.0 0.8 0.8 0.8
    0.0 0.0 0.0
    rl_point_light
    ;

| ============================================================
| RENDER / MAIN
| ============================================================

:render
    rl_frame_begin
    drawscene
    set_lights
    rl_frame_end ;

:main
    render

    fini
    2 'fscale !
    $7f000000 'fcolor !
    8 sh 48 - 500 40 frect
    $ffffffff 'fcolor !
    16 sh 40 - fat
    "r3forth - IMPOSTORS: esfera capsula cilindro cono disco plano" ftext
    fend

    GLUpdate

    immIni
    immMouse
    1 =? ( wheelcam )
    2 =? ( sdlx 'xp ! sdly 'yp ! )
    3 =? ( movecam )
    drop

    sdlkey
    >esc< =? ( exit )
    drop ;

:viewresize sh sw rl_resizewin fixFontResize ;

| ============================================================
| BOOT
| ============================================================

: | <<<<<< Boot
    "demo_shapes r3dv" 1024 768 GLini GLInfo
    rlhud
    rl_init
    IniShapes

    8 'fsun memfloat

    'viewresize SDLeventR
    calcam

    'main SDLshow

    rl_shutdown
    GLend
    endShapes
    ;
