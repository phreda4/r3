| SDL2_ttf.dll
|

#sys-TTF_Init
#sys-TTF_OpenFont
#sys-TTF_SetFontSize 
#sys-TTF_SetFontSDF
#sys-TTF_SetFontStyle
#sys-TTF_SetFontOutline
#sys-TTF_SizeText
#sys-TTF_SizeUTF8
#sys-TTF_RenderText_Solid
#sys-TTF_RenderUTF8_Solid
#sys-TTF_RenderText_Shaded
#sys-TTF_RenderUTF8_Shaded
#sys-TTF_RenderText_Blended
#sys-TTF_RenderUTF8_Blended
#sys-TTF_CloseFont
#sys-TTF_Quit

::TTF_Init sys-TTF_Init sys0 drop ;
::TTF_OpenFont sys-TTF_OpenFont sys2 ; |TTF_Font * TTF_OpenFont( char *file, int ptsize);
::TTF_SetFontStyle sys-TTF_SetFontStyle sys2 drop ; |void  TTF_SetFontStyle(TTF_Font *font, int style);
::TTF_SetFontOutline sys-TTF_SetFontOutline sys2 drop ; |void  TTF_SetFontOutline(TTF_Font *font, int outline);
::TTF_SetFontSize sys-TTF_SetFontSize sys2 ; |  int  TTF_SetFontSize(TTF_Font *font, int ptsize);
::TTF_SetFontSDF sys-TTF_SetFontSDF sys2 ; | int TTF_SetFontSDF(TTF_Font *font, SDL_bool on_off);
::TTF_SizeText sys-TTF_SizeText sys4 ; |int  TTF_SizeText(TTF_Font *font,  char *text, int *w, int *h);
::TTF_SizeUTF8 sys-TTF_SizeUTF8 sys4 ; |int  TTF_SizeUTF8(TTF_Font *font,  char *text, int *w, int *h);
::TTF_RenderText_Solid sys-TTF_RenderText_Solid sys3 ; |surface TTF_RenderText_Solid(TTF_Font *font, char *text, SDL_Color fg);
::TTF_RenderUTF8_Solid sys-TTF_RenderUTF8_Solid sys3 ; |surface TTF_RenderUTF8_Solid(TTF_Font *font, char *text, SDL_Color fg);
::TTF_RenderText_Shaded sys-TTF_RenderText_Shaded sys4 ; |surface TTF_RenderText_Shaded(TTF_Font *font, char *text, SDL_Color fg, SDL_Color bg);
::TTF_RenderUTF8_Shaded sys-TTF_RenderUTF8_Shaded sys4 ; |surface TTF_RenderUTF8_Shaded(TTF_Font *font, char *text, SDL_Color fg, SDL_Color bg);
::TTF_RenderText_Blended sys-TTF_RenderText_Blended sys3 ; |surface TTF_RenderText_Blended(TTF_Font *font, char *text, SDL_Color fg);
::TTF_RenderUTF8_Blended sys-TTF_RenderUTF8_Blended sys3 ; |surface TTF_RenderUTF8_Blended(TTF_Font *font, char *text, SDL_Color fg);
::TTF_CloseFont sys-TTF_CloseFont sys1 drop ; |void TTF_CloseFont(TTF_Font *font);
::TTF_Quit sys-TTF_Quit sys0 drop ; |void TTF_Quit(void);
 
|----- BOOT 
:
	"SDL2_ttf.DLL" loadlib
	dup "TTF_Init" getproc 'sys-TTF_Init !
	dup "TTF_OpenFont" getproc 'sys-TTF_OpenFont !
	dup "TTF_SetFontStyle" getproc 'sys-TTF_SetFontStyle !
	dup "TTF_SetFontOutline" getproc 'sys-TTF_SetFontOutline !
	dup "TTF_SetFontSize" getproc 'sys-TTF_SetFontSize !
	dup "TTF_SetFontSDF" getproc 'sys-TTF_SetFontSDF !
	dup "TTF_SizeText" getproc 'sys-TTF_SizeText !
	dup "TTF_SizeUTF8" getproc 'sys-TTF_SizeUTF8 !
	dup "TTF_RenderText_Solid" getproc 'sys-TTF_RenderText_Solid !
	dup "TTF_RenderUTF8_Solid" getproc 'sys-TTF_RenderUTF8_Solid !
	dup "TTF_RenderText_Shaded" getproc 'sys-TTF_RenderText_Shaded !
	dup "TTF_RenderUTF8_Shaded" getproc 'sys-TTF_RenderUTF8_Shaded !
	dup "TTF_RenderText_Blended" getproc 'sys-TTF_RenderText_Blended !
	dup "TTF_RenderUTF8_Blended" getproc 'sys-TTF_RenderUTF8_Blended !
	dup "TTF_CloseFont" getproc 'sys-TTF_CloseFont !
	dup "TTF_Quit" getproc 'sys-TTF_Quit !
	drop
	
	ttf_init
	;

