| var animator with groups
| PHREDA 2026

^r3/lib/sdl2gfx.r3
^r3/lib/rand.r3
^r3/util/varanimg.r3
^r3/util/txfont.r3

#splayer

#spos0
#spos1
#spos2
#spos3

:anima1
	'spos0 
	100 300 0.2 6.0 xyrz64
	800 400 -0.2 4.0 xyrz64
	0 4.0 0.0 0 +vboxanimg
	'spos0 
	800 400 -0.2 4.0 xyrz64
	100 300 0.2 6.0 xyrz64
	0 4.0 4.0 0 +vboxanimg
	
	'spos1
	100 300 0.2 6.0 xyrz64
	800 400 -0.2 4.0 xyrz64
	0 4.0 0.4 1 +vboxanimg
	'spos1 
	800 400 -0.2 4.0 xyrz64
	100 300 0.2 6.0 xyrz64
	0 4.0 4.4 1 +vboxanimg

	'spos2
	100 300 0.2 6.0 xyrz64
	800 400 -0.2 4.0 xyrz64
	0 4.0 0.8 2 +vboxanimg
	'spos2 
	800 400 -0.2 4.0 xyrz64
	100 300 0.2 6.0 xyrz64
	0 4.0 4.8 2 +vboxanimg
	
	'spos3
	100 300 0.2 6.0 xyrz64
	800 400 -0.2 4.0 xyrz64
	0 4.0 1.2 3 +vboxanimg
	'spos3
	800 400 -0.2 4.0 xyrz64
	100 300 0.2 6.0 xyrz64
	0 4.0 5.2 3 +vboxanimg
	
	;
	
:anima2
	1 vkillgroup
	;
	
:main
	vupdate
	$0 SDLcls

	$ffffff txrgb
	8 8 txat "demo" txprint txcr
	
	8 28 txat 
	timeline 
	( timeline> <?
		@+ "%h " txprint 
		timeline< =? ( "< " txprint )
		txcr
		) drop

	
	spos0 64xyrz 0 splayer sspriteRZ
	spos1 64xyrz 2 splayer sspriteRZ
	spos2 64xyrz 6 splayer sspriteRZ
	spos3 64xyrz 12 splayer sspriteRZ

	SDLredraw	
	SDLkey
	>esc< =? ( exit )
	<f1> =? ( anima1 )
	<f2> =? ( anima2 )
	drop ;
	
	
: |-------------------------------------
	"varanim g" 1024 600 SDLinit	

	"media/ttf/VictorMono-Bold.ttf" 24 txload txfont
	16 16 "media/img/manual.png" ssload 'splayer !
	$ff vaini
	100 100 0.2 4.0 xyrz64 'spos0 !
	'main SDLShow
	SDLquit ;	
