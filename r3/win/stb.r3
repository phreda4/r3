| stb.dll
|

#sys-STB_CloseFont
#sys-STB_OpenFontRW
#sys-STB_OpenFont
#sys-STB_RenderText
#sys-STB_MeasureText

::STB_CloseFont sys-STB_CloseFont sys1 drop ;
::STB_OpenFontRW sys-STB_OpenFontRW sys3 ;
::STB_OpenFont sys-STB_OpenFont sys3 ;
::STB_RenderText sys-STB_RenderText sys5 drop ;
::STB_MeasureText sys-STB_MeasureText sys2 ;

|----- BOOT
:
	"stb.DLL" loadlib
	dup "STBTTF_CloseFont" getproc 'sys-STB_CloseFont !
	dup "STBTTF_OpenFontRW" getproc 'sys-STB_OpenFontRW !
	dup "STBTTF_OpenFont" getproc 'sys-STB_OpenFont !
	dup "STBTTF_RenderText" getproc 'sys-STB_RenderText !
	dup "STBTTF_MeasureText" getproc 'sys-STB_MeasureText !
	drop
	;
