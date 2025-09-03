| SDL2_ttf.dll
| PHREDA 2024

|WIN|^r3/lib/win/core.r3
|LIN|^r3/lib/posix/core.r3

#sys-TTF_Init
#sys-TTF_OpenFont
#sys-TTF_SetFontSize 
#sys-TTF_SetFontSDF
#sys-TTF_SetFontStyle
#sys-TTF_SetFontOutline
#sys-TTF_SetFontLineSkip
#sys-TTF_SetFontWrappedAlign
#sys-TTF_SizeText
#sys-TTF_SizeUTF8
#sys-TTF_MeasureUTF8
#sys-TTF_RenderText_Solid
#sys-TTF_RenderUTF8_Solid
#sys-TTF_RenderText_Shaded
#sys-TTF_RenderUTF8_Shaded
#sys-TTF_RenderText_Blended
#sys-TTF_RenderUTF8_Blended
#sys-TTF_RenderUTF8_Blended_Wrapped
#sys-TTF_RenderUNICODE_Blended
#sys-TTF_CloseFont
#sys-TTF_Quit

::TTF_Init sys-TTF_Init sys0 drop ;
::TTF_OpenFont sys-TTF_OpenFont sys2 ; |TTF_Font * ( char *file, int ptsize);
::TTF_SetFontStyle sys-TTF_SetFontStyle sys2 drop ; |void ( *font, int style);
::TTF_SetFontOutline sys-TTF_SetFontOutline sys2 drop ; |void ( *font, int outline);
::TTF_SetFontLineSkip sys-TTF_SetFontLineSkip sys2 drop ; |(TTF_Font *font, int lineskip);
::TTF_SetFontWrappedAlign sys-TTF_SetFontWrappedAlign sys2 drop ; |(TTF_Font *font, int align);
::TTF_SetFontSize sys-TTF_SetFontSize sys2 drop ; |  int ( *font, int ptsize);
::TTF_SetFontSDF sys-TTF_SetFontSDF sys2 ; | int ( *font, SDL_bool on_off);
::TTF_SizeText sys-TTF_SizeText sys4 ; |int  ( *font,  char *, int *w, int *h);
::TTF_SizeUTF8 sys-TTF_SizeUTF8 sys4 ; |int  ( *font,  char *, int *w, int *h);
::TTF_MeasureUTF8 sys-TTF_MeasureUTF8 sys5 drop ; |int (*font, char *,measure_width,*extent,*count);
::TTF_RenderText_Solid sys-TTF_RenderText_Solid sys3 ; |surface ( *font, char *, SDL_Color fg);
::TTF_RenderUTF8_Solid sys-TTF_RenderUTF8_Solid sys3 ; |surface ( *font, char *, SDL_Color fg);
::TTF_RenderText_Shaded sys-TTF_RenderText_Shaded sys4 ; |surface (*font,char *, SDL_Color fg, SDL_Color bg)
::TTF_RenderUTF8_Shaded sys-TTF_RenderUTF8_Shaded sys4 ; |surface (*font,char *, SDL_Color fg, SDL_Color bg)
::TTF_RenderText_Blended sys-TTF_RenderText_Blended sys3 ; |surface ( *font, char *, SDL_Color fg);
::TTF_RenderUTF8_Blended sys-TTF_RenderUTF8_Blended sys3 ; |surface ( *font, char *, SDL_Color fg);
::TTF_RenderUTF8_Blended_Wrapped sys-TTF_RenderUTF8_Blended_Wrapped sys4 ; | font str color width -- surface
::TTF_RenderUNICODE_Blended sys-TTF_RenderUNICODE_Blended sys3 ;
::TTF_CloseFont sys-TTF_CloseFont sys1 drop ; |void ( *font);
::TTF_Quit sys-TTF_Quit sys0 drop ; |void (void);
 
|----- BOOT 
:
|WIN|	"dll/SDL2_ttf.DLL" loadlib
|LIN|	"libSDL2_ttf-2.0.so.0" loadlib	
	dup "TTF_Init" getproc 'sys-TTF_Init !
	dup "TTF_OpenFont" getproc 'sys-TTF_OpenFont !
	dup "TTF_SetFontStyle" getproc 'sys-TTF_SetFontStyle !
	dup "TTF_SetFontOutline" getproc 'sys-TTF_SetFontOutline !
	dup "TTF_SetFontLineSkip" getproc 'sys-TTF_SetFontLineSkip !
	dup "TTF_SetFontWrappedAlign" getproc 'sys-TTF_SetFontWrappedAlign !
	dup "TTF_SetFontSize" getproc 'sys-TTF_SetFontSize !
	dup "TTF_SetFontSDF" getproc 'sys-TTF_SetFontSDF !
	dup "TTF_SizeText" getproc 'sys-TTF_SizeText !
	dup "TTF_SizeUTF8" getproc 'sys-TTF_SizeUTF8 !
	dup "TTF_MeasureUTF8" getproc 'sys-TTF_MeasureUTF8 !
	dup "TTF_RenderText_Solid" getproc 'sys-TTF_RenderText_Solid !
	dup "TTF_RenderUTF8_Solid" getproc 'sys-TTF_RenderUTF8_Solid !
	dup "TTF_RenderText_Shaded" getproc 'sys-TTF_RenderText_Shaded !
	dup "TTF_RenderUTF8_Shaded" getproc 'sys-TTF_RenderUTF8_Shaded !
	dup "TTF_RenderText_Blended" getproc 'sys-TTF_RenderText_Blended !
	dup "TTF_RenderUTF8_Blended" getproc 'sys-TTF_RenderUTF8_Blended !
	dup "TTF_RenderUTF8_Blended_Wrapped" getproc 'sys-TTF_RenderUTF8_Blended_Wrapped !
	dup "TTF_RenderUNICODE_Blended" getproc 'sys-TTF_RenderUNICODE_Blended !
	dup "TTF_CloseFont" getproc 'sys-TTF_CloseFont !
	dup "TTF_Quit" getproc 'sys-TTF_Quit !
	drop
	ttf_init
	;

