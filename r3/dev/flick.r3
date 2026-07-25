| flick.r3 - mini clon de flickgame
|
| grilla de cols x rows celdas, cada celda guarda un color 0-7.
| el color de una celda ES el numero de pagina a la que salta al clickearla
| (color 0 = sin link). hasta npages paginas.
|
| controles:
|   E : modo editar        P : modo jugar
|   1-4 : elegir color/pagina-destino a pintar
|   click izq : en editar pinta la celda; en jugar sigue el link

^r3/lib/sdl2gfx.r3
^r3/lib/gui.r3

#cols 8
#rows 5
#cell 80
#npages 4

#page 0                    | pagina visible actual
#curcolor 1                | color/pagina-destino seleccionado para pintar
#editmode 1                | 1=editar 0=jugar

#pal $202020 $ff3030 $30ff30 $3030ff $ffff30 $ff30ff $30ffff $ffffff

#grid * $1000               | npages*rows*cols celdas de 8 bytes, con margen

#tcy 0
#tcx 0

| direccion de celda: (pg*rows*cols + cy*cols + cx) * 8 + grid
:addrof | pg cx cy -- addr
    'tcy !                     | pg cx        (guarda cy)
    'tcx !                     | pg           (guarda cx)
    rows cols * *               | pg*rows*cols
    tcy cols * +                 | + cy*cols
    tcx +                        | + cx
    3 << 'grid + ;

:cellget | pg cx cy -- color
    addrof @ ;

:cellset | color pg cx cy --
    addrof ! ;

:colorof | n -- rgb
    3 << 'pal + @ ;

| --- dibujo ---
#dcy 0
#dcx 0

:draw-row
    0 'dcx !
    ( dcx cols <? drop
        page dcx dcy cellget colorof SDLColor
        dcx cell * dcy cell * cell cell SDLFRect
        1 'dcx +!
    ) drop ;

:draw-grid
    0 'dcy !
    ( dcy rows <? drop
        draw-row
        1 'dcy +!
    ) drop ;

#tv 0

:vline | ncol --
    cell * 'tv !                | tv = x
    tv 0 tv rows cell * SDLLine ;

:hline | nrow --
    cell * 'tv !                | tv = y
    0 tv cols cell * tv SDLLine ;

:draw-grid-lines
    $404040 SDLColor
    0 ( cols 1 + <? dup vline 1 + ) drop
    0 ( rows 1 + <? dup hline 1 + ) drop ;

:draw-hud
    curcolor colorof SDLColor
    5 5 20 20 SDLFRect
    editmode 1? ( $ffffff SDLColor 30 5 6 20 SDLFRect ) drop ;

:redraw
    $000000 SDLcls
    draw-grid
    draw-grid-lines
    draw-hud
    SDLredraw ;

| --- input: click en la grilla, estilo drumbox.r3 (mapxy + guiBox + onClick) ---
| mapxy guarda cx,cy en variables para no pelear con el orden del stack
#mcx 0
#mcy 0

:mapxy
    SDLy cell / 'mcy !
    SDLx cell / 'mcx ! ;

:click-edit
    mapxy
    curcolor page mcx mcy cellset ;

:click-play
    mapxy
    page mcx mcy cellget
    0? ( drop ; )
    'page ! ;

:on-grid-click
    editmode 1? ( drop click-edit ; ) drop
    click-play ;

:grid-input
    0 0 cols cell * rows cell * guiBox
    'on-grid-click onClick ;

:check-keys
    SDLkey
    >esc< =? ( exit )
    <E> =? ( 1 'editmode ! )
    <P> =? ( 0 'editmode ! )
    <1> =? ( 0 'curcolor ! )
    <2> =? ( 1 'curcolor ! )
    <3> =? ( 2 'curcolor ! )
    <4> =? ( 3 'curcolor ! )
    drop ;

:game-loop
    gui
    check-keys
    redraw
    grid-input ;

:main
    "mini flickgame" 640 400 SDLinit
    'game-loop SDLshow
    SDLquit ;

: main ;
