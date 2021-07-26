| Color
| PHREDA 2020
|-----------------------------------------
::colavg | a b -- c
	2dup xor $fefefefe and 1 >> >r or r> - ;

::col50% | c1 c2 -- c
	$fefefe and swap $fefefe and + 1 >> ;

::col25% | c1 c2 -- c
	$fefefe and swap $fefefe and over + 1 >> + 1 >> ;

::col33%  | c1 c2 -- c
	$555555 and swap $aaaaaa and or ;

::colmix | c1 c2 m -- c
	pick2 $ff00ff and
	pick2 $ff00ff and
	over - pick2 * 8 >> +
	$ff00ff and >r
	rot $ff00 and
	rot $ff00 and
	over - rot * 8 >> +
	$ff00 and r> or ;

|--- diferencia de color
::diffrgb2 | a b -- v
	over 16 >> over 16 >> - abs | a b a1
	pick2 8 >> $ff and pick2 8 >> $ff and - abs + | a b a2
	rot $ff and rot $ff and - abs + ;

| yuv <-> rgb
|-----------------------------
::rgb2yuv | rgb -- yuv
	over 1 << pick3 - pick2 - 3 >>  >r
	pick2 over - 2 >> 128 + >r
	+ + 2 >> r> r> ;

:bound | i -- i
	$ff clamp0max ;

::yuv2rgb | yuv -- rgb
	pick2 16 - 76283 * pick2 128 - 132252 * + 16 >> bound >r
	pick2 16 - 76283 * pick2 128 - 25624 *  - pick2 128 - 53281 * - 16 >> bound >r
	nip 128 - 104595 * swap 16 - 76283 * + 16 >> bound r> r> ;

::yuv32 | yuv -- col
	pick2 16 - 76283 * pick2 128 - 132252 * + 16 >> bound >r
	pick2 16 - 76283 * pick2 128 - 25624 *  - pick2 128 - 53281 * - 16 >> bound 8 << $ff00 and >r
	nip 128 - 104595 * swap 16 - 76283 * + 16 >> bound 16 << $ff0000 and r> or r> or ;

| hsv 1.0 1.0 1.0 --> rgb
| hsv 1.0 1.0 1.0 --> rgb

:h0 ;				|v, n, m
:h1 >r swap r> ;	|n, v, m
:h2 rot rot ;		|m, v, n
:h3 swap rot ;		|m, n, v
:h4 rot ;			|n, m, v
:h5 swap ;			|v, m, n
#acch h0 h1 h2 h3 h4 h5

::hsv2rgb | h s v -- rgb32
	1? ( 1 - ) $ffff and swap
	0? ( drop nip 8 >> dup 8 << dup 8 << or or ; ) | hvs
	rot 1? ( 1 - ) $ffff and
	dup 1 << + 1 <<	| 6*
	dup 16 >> 	| vshH
	1 nand? ( $ffff rot - swap ) | vsfH
	>r $ffff and	| vsf
	1.0 pick2 - pick3 16 *>> | vsfm
	>r
	16 *>> 1.0 swap - | v (1-s*f)
	over 16 *>> r> | vnm
	r> 2 << 'acch + @ ex | rgb
	8 >> swap
	$ff00 and or swap
	8 << $ff0000 and or ;


#vR #vG #vB
:getzone | x max -- x max h
	vr =? ( vg vb - pick2 /. ; )
	vg =? ( vb vr - pick2 /. 2.0 + ; )
	vr vg - pick2 /. 4.0 + ;

::rgb2hsv | argb -- h s v
	dup 16 >> $ff and 1.0 255 */ 'vr !
	dup 8 >> $ff and 1.0 255 */ 'vg !
	$ff and 1.0 255 */ 'vb !
	vr vg min vb min
	vr vg max vb max | min max
	over =? ( 2drop 0 0 vr ; )
	dup rot - swap | x max
	getzone | x val h
	6/ -? ( 1.0 + )
	rot pick2 /.	| val h s
	rot
	;

| YCoCg colorspace (very fast)
::rgb2ycocg | r g b -- y co cg
	rot over - | r-b
	dup >r 1 >> + | g t  r:co
	dup >r - r> | cg t r:co
	over 1 >> + | cg Y r:co
	r> rot ; | Y co cg

::ycocg2rgb | y co cg -- r g b
	rot over 1 >> - | co cg t
	dup pick3 1 >> - >r | co cg t r:B
	+ swap r@ + swap r> | R G B
	;

::rgb2ycc | RGB -- y co cg
	dup 16 >> $ff and swap
	dup 8 >> $ff and swap
	$ff and rgb2ycocg ;

|-- anoter yuv
|     Y=G+(B+R-2*G)/4
|     U=B-G
|     V=R-G

::rgb2yuv2 | g b r -- y u v
	2dup + pick3 1 << - 2 >> pick3 + | g b r Y
	rot pick3 - | g r Y U
	2swap swap - ; | Y U V

|     G=Y-(U+V)/4
|     R=V+G
|     B=U+G
::yuv2rgb2 | y u v -- g b r
	rot pick2 pick2 + 2 >> - | u v G
	rot over + | v G B
	rot pick2 + ; | G B R

|--- GCbCr
::RGB>Gbr | R G B -- G b r
	over - $ff and
	rot pick2 - $ff and ;

::Gbr>RGB | G b r -- R G B
	pick2 + $ff and swap
	pick2 + $ff and rot swap ;

|-- YCoCg24
:fwlift | x y -- avg dif
	over - $ff and
	dup 1 >> rot + $ff and  ;

::RGB2YCoCg24 | r g b -- Y co cg
	rot fwlift | G avg dif
	>r fwlift	| Y cg
	r> ;

:relift | dif avg  -- y x
	over 1 >> - $ff and
	swap over + $ff and ;

::YCoCg242RGB | Y co cg -- r g b
	rot relift
	>r relift
	r> ;

|--- darker lighter color

| 4bits shadow,light color
::shadow4 | color shadow -- color
	swap 4 >> $f0f0f and * $f0f0f0 and
	dup 4 >> or ;
::light4 | color ligth -- color
	dup 8 << or dup 8 << or
	swap 4 >> $f0f0f and +
	$f0 and? ( $f or ) $f000 and? ( $f00 or ) $f00000 and? ( $f0000 or )
	$f0f0f and dup 4 << or ;

| 8bits shadow,light color
::shadow8 | color shadow -- color
	over $ff00ff and over * 8 >> $ff00ff and
	rot $ff00 and rot * 8 >> $ff00 and
	or ;
::light8 | color ligth -- color
	over $ff and over + $ff min >a
	over $ff00 and over 8 << + $ff00 min a+
	16 << swap $ff0000 and + $ff0000 min a> or ;

| blend c1 and c2 in 2 bits
::blend2 | c1 c2 i -- c
	rot $f0f0f0 and swap >> $7f7f7f and
	swap $f0f0f0 and 1 >> $7f7f7f and
	+ ;

|---- 3bytes color
::b2color | col -- color
	dup $f and dup 4 << or swap
	dup $f0 and 4 << dup 4 << or swap
	$f00 and 8 << dup 4 << or or or ;