| RIMM icons: drawn with lines and triangles over the draw color, no font
| glyphs and no image: the same icons in any backend and any size.
| (A spritesheet of icons can replace them: only uiIcon changes.)
|
|   uiIcon | n x y s -- ; icon n (ICxxx) in the square x y of side s, draw color
|

#ix #iy #is

:px | f -- x ; position in sixteenths of the icon
	is * 4 >> ix + ;
:py | f -- y
	is * 4 >> iy + ;
:sc
	is * 4 >> ;
:dChk
	3 px 8 py 6 px 12 py line
	3 px 9 py 6 px 13 py line
	6 px 12 py 13 px 4 py line
	6 px 13 py 13 px 5 py line ;
:dX
	4 px 4 py 12 px 12 py line
	4 px 5 py 12 px 13 py line
	4 px 12 py 12 px 4 py line
	4 px 13 py 12 px 5 py line ;
:dRight 5 px 3 py 5 px 13 py 12 px 8 py triangle ;
:dDown 3 px 5 py 13 px 5 py 8 px 12 py triangle ;
:dLeft 11 px 3 py 11 px 13 py 4 px 8 py triangle ;
:dUp 3 px 11 py 13 px 11 py 8 px 4 py triangle ;
:dPlus
	8 px 3 py 2 sc 12 sc rect
:dMinus
	3 px 8 py 12 sc 2 sc rect ;

| new, edit, delete, cut, copy, paste, paint, erase, view
#icons 'dChk 'dX 'dRight 'dDown 'dLeft 'dUp 'dPlus 'dMinus

::ICCHK 0 ; ::ICX 1 ; ::ICRIGHT 2 ; ::ICDOWN 3 ; 
::ICLEFT 4 ; ::ICUP 5 ; ::ICPLUS 6 ; ::ICMINUS 7 ;

::uiIcon | n x y s -- ; draw the icon n in the square x y of side s with the draw color
	'is ! 'iy ! 'ix !
	$7 and 3 << 'icons + @ ex ;
