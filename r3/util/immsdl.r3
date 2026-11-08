| immi backend: SDL2 render
| PHREDA 2026
|
| The words the immi core and widgets need from the drawing side:
|  color frect rect fround round lineH lineV imageb
|  txfont txfont@ txrgb txat txw txh txwrite txText txalign txcur txcuri
|  txicon icChkOn icChkOff icRadOn icRadOff icTreeC icTreeO icCombo
|  gclip gclip0
|
^r3/lib/sdl2gfx.r3
^r3/util/txfont.r3

::txicon | char -- ; draw a one char icon vertically centered in the text line, the cursor moves
	txh over txch - 2/	| char ny
	0 over tx+at
	swap txemit
	0 swap neg tx+at ;

::icChkOn 139 ;
::icChkOff 138 ;
::icRadOn 137 ;
::icRadOff 136 ;
::icTreeC 129 ;
::icTreeO 130 ;
::icCombo 130 ;

#clipbox [ 0 0 0 0 ]

::gclip | x y w h -- ; clip the drawing to the rectangle
	'clipbox 12 + d! 'clipbox 8 + d! 'clipbox 4 + d! 'clipbox d!
	SDLrenderer 'clipbox SDL_RenderSetClipRect ;

::gclip0 | -- ; remove the clip
	SDLrenderer 0 SDL_RenderSetClipRect ;
