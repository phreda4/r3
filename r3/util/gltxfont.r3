| txfont for OpenGL: atlas from a TTF in a GL texture
| pseudo utf-8 (ascii 32..127)
| PHREDA 2026
|
| Same txload as txfont.r3, but the atlas is a texture for glgfx.
| The font is used with txfont and the tx words of glgfx (txwrite txText ftext...)
|
^r3/lib/sdl2gl.r3
^r3/lib/sdl2ttf.r3
^r3/util/glgfx.r3

#ttfont #tsx #tsy
#asurf #gsurf #gtex
#curx #cury
#cbuf 0
#drec 0 0
#gw #gh
#nfnt

| entries x | w<<16 | y<<32 | h<<48 while the atlas is made
#etab * 2048

:render | char -- surf ; surface of the glyph, its size in gw gh
	'cbuf c!
	ttfont 'cbuf $ffffff TTF_RenderUTF8_Blended
	dup 16 + d@+ swap d@ 'gh ! 'gw ! ;

:nextpos | -- ; new row if the glyph does not fit
	curx gw + tsx <? ( drop ; ) drop
	0 'curx ! gh 'cury +! ;

:blit | surf -- ; copy with the alpha of the glyph to the atlas and free it
	curx 'drec d! cury 'drec 4 + d!
	gw 'drec 8 + d! gh 'drec 12 + d!
	dup 0 SDL_SetSurfaceBlendMode
	dup 0 asurf 'drec SDL_BlitSurface
	SDL_FreeSurface ;

:entry! | c --
	3 << 'etab +
	curx gw 16 << or cury 32 << or gh 48 << or
	swap ! ;

:glyph | c --
	dup render
	nextpos
	blit
	entry!
	gw 'curx +! ;

:glyphs
	32 ( 128 <? dup glyph 1+ ) drop ;

:specials | -- ; 0 cr ln = space, tab = 4 spaces
	'etab 32 3 << + @ dup 'etab !
	dup 'etab 13 3 << + !
	dup 'etab 10 3 << + !
	dup $ffff0000 and 2 << swap $ffffffff0000ffff and or
	'etab 9 3 << + ! ;

:upload | surface -- tex ; GL texture, packed with the size like glLoadImg
	dup $16762004 0 SDL_ConvertSurfaceFormat 'gsurf !
	SDL_FreeSurface
	1 'gtex glGenTextures
	GL_TEXTURE_2D gtex glBindTexture
	GL_TEXTURE_2D 0 GL_RGBA tsx tsy 0 pick3 GL_UNSIGNED_BYTE gsurf 32 + @ glTexImage2D
	GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER GL_NEAREST glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER GL_NEAREST glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_WRAP_S GL_CLAMP_TO_EDGE glTexParameteri
	GL_TEXTURE_2D GL_TEXTURE_WRAP_T GL_CLAMP_TO_EDGE glTexParameteri
	gsurf SDL_FreeSurface
	tsy 16 << tsx or 32 << gtex or ;

:copytab | font -- font ; the entries to the record, ws = space width, hs = line height
	0 ( 256 <? 
		dup 3 << 'etab + @ over 3 << pick3 40 + + !
		1+ ) drop
	dup 40 + 32 3 << + @ 16 >> $ffff and over 8 + !
	gh over 16 + ! ;

::txload | "font" size -- nfont ; load a TTF as atlas texture for glgfx (0 if there is no room), use txfont to select it
	TTF_Init
	dup 3 << dup 'tsy ! 2* 'tsx !
	TTF_OpenFont 'ttfont !
	0 tsx tsy 32 $ff0000 $ff00 $ff $ff000000 SDL_CreateRGBSurface 'asurf !
	0 ( 256 <? 0 over 3 << 'etab + ! 1+ ) drop
	0 'curx ! 0 'cury !
	glyphs specials
	ttfont TTF_CloseFont
	asurf upload fnew
	0? ( ; )
	copytab ;
