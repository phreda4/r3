| Color
| PHREDA 2020
|-----------------------------------------
^r3/lib/math.r3

::swapcolor | color -- swapcolor ; swap the red and blue channels of a 32-bit color ($AARRGGBB to $AABBGGRR)
	dup 16 >> $ff and 
	over 16 << $ff0000 and or
	swap $ff00ff00 and or ;

::colavg | a b -- c ; per-byte average of two 32-bit colors, rounded up
	2dup or -rot xor $fefefefe and 1 >> - ;

::col50% | c1 c2 -- c ; 50% mix of two 24-bit colors
	$fefefe and swap $fefefe and + 1 >> ;

::col25% | c1 c2 -- c ; 25% of c1 plus 75% of c2 (24-bit colors); approximate: with large channel values bits bleed into the next channel
	$fefefe and swap $fefefe and over + 1 >> + 1 >> ;

::col33% | c1 c2 -- c ; roughly 67% of c1 plus 33% of c2 (24-bit colors), made with bit masks
	$555555 and swap $aaaaaa and or ;

::colmix | c1 c2 a -- c ; mix 24-bit colors: c1 + (c2-c1)*a/256, a = 0..255; the result is in the low 24 bits (upper bits have garbage)
	rot dup 24 << or $ff00ff00ff and
	rot dup 24 << or $ff00ff00ff and
	over - rot * 8 >> + $ff00ff00ff and
	dup 24 >> or ;
	
::colmul | c1 a -- c ; 24-bit color scaled by a/256, a = 0..255; the result is in the low 24 bits (upper bits have garbage)
	swap dup 24 << or $ff00ff00ff and
	* 8 >> $ff00ff00ff and
	dup 24 >> or ;

::colmix4 | c1 c2 a -- c ; like colmix for 12-bit colors $RGB: a = 0..255 (only its high 4 bits count); the result is in the low 12 bits
	rot dup 12 << or $f0f0f and
	rot dup 12 << or $f0f0f and
	over - rot 4 >> * 4 >> + $f0f0f and
	dup 12 >> or ;

::colmul4 | c1 a -- c ; like colmul for 12-bit colors $RGB: a = 0..15; the result is in the low 12 bits
	swap dup 12 << or $f0f0f and
	* 4 >> $f0f0f and
	dup 12 >> or ;

|--- diferencia de color
::diffrgb2 | a b -- v ; sum of the absolute differences of the red, green and blue channels of two 24-bit colors
	over 16 >> over 16 >> - abs | a b a1
	pick2 8 >> $ff and pick2 8 >> $ff and - abs + | a b a2
	rot $ff and rot $ff and - abs + ;

| yuv <-> rgb
|-----------------------------
::rgb2yuv | r g b -- y u v ; custom transform: y = (r+g+b)/4, u = 128+(r-b)/4, v = (g-r)/8 (not the inverse of yuv2rgb)
	over 1 << pick3 - pick2 - 3 >>  >r
	pick2 over - 2 >> 128 + >r
	+ + 2 >> r> r> ;

:bound | i -- i
	$ff clamp0max ;

::yuv2rgb | y u v -- r g b ; video YUV (y 16..235, u v around 128) to RGB 0..255 (BUG: the green term uses u twice, v is missing)
	pick2 16 - 76283 * pick2 128 - 132252 * + 16 >> bound >r
	pick2 16 - 76283 * pick2 128 - 25624 *  - pick2 128 - 53281 * - 16 >> bound >r
	nip 128 - 104595 * swap 16 - 76283 * + 16 >> bound r> r> ;

::yuv32 | y u v -- col ; like yuv2rgb but returns the packed color $RRGGBB (same green bug)
	pick2 16 - 76283 * pick2 128 - 132252 * + 16 >> bound >r
	pick2 16 - 76283 * pick2 128 - 25624 * - pick2 128 - 53281 * - 16 >> bound 8 << $ff00 and >r
	nip 128 - 104595 * swap 16 - 76283 * + 16 >> bound 16 << $ff0000 and r> or r> or ;

| hsv 1.0 1.0 1.0 --> rgb
| hsv 1.0 1.0 1.0 --> rgb

:h0 ;				|v, n, m
:h1 swap -rot ;		|n, v, m
:h2 -rot ;			|m, v, n
:h3 swap rot ;		|m, n, v
:h4 rot ;			|n, m, v
:h5 swap ;			|v, m, n
#acch h0 h1 h2 h3 h4 h5

::hsv2rgb | h s v -- rgb ; h s v in fixed point 0..1.0 (h: 1.0 is a full circle) to a packed color $RRGGBB
	1? ( 1- ) $ffff and swap
	0? ( drop nip 8 >> dup 8 << dup 8 << or or ; ) | hvs
	rot 1? ( 1- ) $ffff and
	dup 1 << + 1 <<	| 6*
	dup 16 >> 	| vshH
	1 nand? ( $ffff rot - swap ) | vsfH
	>r $ffff and	| vsf
	1.0 pick2 - pick3 16 *>> | vsfm
	>r
	16 *>> 1.0 swap - | v (1-s*f)
	over 16 *>> r> | vnm
	r> 3 << 'acch + @ ex | rgb
	8 >> swap
	$ff00 and or swap
	8 << $ff0000 and or ;


#vR #vG #vB
:getzone | x max -- x max h
	vr =? ( vg vb - pick2 /. ; )
	vg =? ( vb vr - pick2 /. 2.0 + ; )
	vr vg - pick2 /. 4.0 + ;

::rgb2hsv | argb -- h s v ; packed color to h 0..1.0, s 0..1.0 and v = largest channel << 8 (0..$ff00); alpha is ignored
	dup 8 >> $ff00 and 'vr !
	dup $ff00 and 'vg !
	$ff and 8 << 'vb !
	vr vg min vb min
	vr vg max vb max | min max
	over =? ( 2drop 0 0 vr ; )
	dup rot - swap | x max
	getzone | x val h
	6 / -? ( 1.0 + )
	rot pick2 /.	| val h s
	rot
	;

| YCoCg colorspace (very fast)
::rgb2ycocg | r g b -- y co cg ; reversible YCoCg-R transform of 0..255 values (co and cg can be negative)
	rot over - | r-b
	dup >r 1 >> + | g t  r:co
	dup >r - r> | cg t r:co
	over 1 >> + | cg Y r:co
	r> rot ; | Y co cg

::ycocg2rgb | y co cg -- r g b ; inverse of rgb2ycocg
	rot over 1 >> - | co cg t
	dup pick3 1 >> - >r | co cg t r:B
	+ swap r@ + swap r> | R G B
	;

::rgb2ycc | RGB -- y co cg ; like rgb2ycocg from a packed color $RRGGBB
	dup 16 >> $ff and swap
	dup 8 >> $ff and swap
	$ff and rgb2ycocg ;

|-- anoter yuv
|     Y=G+(B+R-2*G)/4
|     U=B-G
|     V=R-G

::rgb2yuv2 | g b r -- y u v ; y = g + (b+r-2g)/4, u = b-g, v = r-g (note the order of the arguments)
	2dup + pick3 1 << - 2 >> pick3 + | g b r Y
	rot pick3 - | g r Y U
	2swap swap - ; | Y U V

|     G=Y-(U+V)/4
|     R=V+G
|     B=U+G
::yuv2rgb2 | y u v -- g b r ; inverse of rgb2yuv2
	rot pick2 pick2 + 2 >> - | u v G
	rot over + | v G B
	rot pick2 + ; | G B R

|--- GCbCr
::RGB>Gbr | R G B -- G b r ; G, B-G and R-G (the differences wrap to 0..255)
	over - $ff and
	rot pick2 - $ff and ;

::Gbr>RGB | G b r -- R G B ; inverse of RGB>Gbr
	pick2 + $ff and swap
	pick2 + $ff and rot swap ;

|-- YCoCg24
:fwlift | x y -- dif avg
	over - $ff and
	dup 1 >> rot + $ff and  ;

::RGB2YCoCg24 | r g b -- Y co cg ; YCoCg lifting with values wrapped to 0..255 (experimental: the results differ from rgb2ycocg)
	rot fwlift	| g co t
	rot swap fwlift	| co cg Y
	-rot ;

:relift | dif avg  -- x y
	over 1 >> - $ff and
	swap over + $ff and ;

::YCoCg242RGB | Y co cg -- r g b ; BUG: same code as RGB2YCoCg24, so it is not its inverse (relift is not used)
	rot fwlift	| g co t
	rot swap fwlift	| co cg Y
	-rot ;

|--- darker lighter color

| 4bits shadow,light color
::shadow4 | color shadow -- color ; darken a 24-bit color by shadow/16 (shadow 0..15), using only the high nibble of each channel
	swap 4 >> $f0f0f and * $f0f0f0 and
	dup 4 >> or ;
::light4 | color light -- color ; lighten a 24-bit color adding light (0..15) to the high nibble of each channel, max 15
	dup 8 << or dup 8 << or
	swap 4 >> $f0f0f and +
	$f0 and? ( $f or ) $f000 and? ( $f00 or ) $f00000 and? ( $f0000 or )
	$f0f0f and dup 4 << or ;

| 8bits shadow,light color
::shadow8 | color shadow -- color ; 24-bit color scaled by shadow/256 per channel (shadow 0..255)
	over $ff00ff and over * 8 >> $ff00ff and
	rot $ff00 and rot * 8 >> $ff00 and
	or ;
::light8 | color light -- color ; add light to each channel of a 24-bit color, saturating at 255
	over $ff and over + $ff min >a
	over $ff00 and over 8 << + $ff00 min a+
	16 << swap $ff0000 and + $ff0000 min a> or ;

| blend c1 and c2 in 2 bits
::blend2 | c1 c2 i -- c ; per channel, high nibble only: (c1 >> i) + (c2 >> 1); i = 1 gives the 50% average
	rot $f0f0f0 and swap >> $7f7f7f and
	swap $f0f0f0 and 1 >> $7f7f7f and
	+ ;

|---- 3bytes color
::b2color | col -- color ; 12-bit color $RGB to 24-bit $RRGGBB (each nibble repeated)
	dup $f and dup 4 << or swap
	dup $f0 and 4 << dup 4 << or swap
	$f00 and 8 << dup 4 << or or or ;
	
::bgr2rgb | BGR -- RGB ; swap the red and blue channels of a 24-bit color (the alpha byte is dropped)
	dup $ff00 and 
	over $ff and 16 << or 
	swap 16 >> $ff and or ;	
	
|---- 4bytes color
::4bcol | col -- color ; 16-bit color $ARGB (4 bits per channel) to 32-bit $AARRGGBB (each nibble repeated)
	dup $f and dup 4 << or swap | ff col
	dup $f0 and 4 << dup 4 << or swap
	dup $f00 and 8 << dup 4 << or swap
	$f000 and 12 << dup 4 << or 
	or or or ;
	
::4bicol | col -- color ; like 4bcol but the three color nibbles are read in reverse order (red and blue swapped)
	dup $f and 16 << dup 4 << or swap | ff col
	dup $f0 and 4 << dup 4 << or swap
	dup $f00 and 8 >> dup 4 << or swap
	$f000 and 12 << dup 4 << or 
	or or or ;
	

