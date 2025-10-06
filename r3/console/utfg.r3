| Utg Graphics
| PHREDA 2025
^./console.r3

#f8x8 
$0 $100010003000200 $4100820 $4102EB81D740820 
$5D405DC0DD40080 $1014092814902808 $544246406400200 $1000080 
$60030003000090 $90000C000C00600 $11005D401900000 $4005D400C00000 
$240008000000000 $55400000000 $140028000000000 $400024000240000 
$550390C309C0AA0 $55400C004C00280 $15542550100C0AA0 $550200C10A40AA0 
$403AE809C00080 $550200C3AA02AA8 $550300C3AA00AA0 $100024000242AA8 
$550300C1AA40AA0 $550055C300C0AA0 $100000002000000 $900020001000000 
$10018000900000 $AA80AA80000 $100009001800000 $40004010240AA0 
$5503154326C0AA0 $1004355C300C0AA0 $1550300C3AA42AA0 $550300830040AA0 
$1540302430182A80 $155430003AA02AA8 $100030003AA02AA8 $550305C30040AA0 
$1004300C3AAC2008 $55400C000C00AA8 $550300C000C0008 $100430603A402020 
$1554300030002000 $1004300C369C2008 $1004306C360C2008 $550300C300C0AA0 
$10003550300C2AA0 $550318C300C0AA0 $10043570300C2AA0 $550200C1AA00AA0 
$10003000300AAA8 $550300C300C2008 $1401824300C2008 $410328C300C2008 
$1004096006902008 $100030018908008 $1554090000902AA8 $5400C000C000A8 
$10018018000000 $1500030003002A00 $100030027600200 $AAAA000000000000 
$15540C002E8402A0 $550257005600000 $5500C0C0EA00800 $1500C0009500000 
$55030300AB00020 $550354025600000 $1000300038000A0 $A901AB025700000 
$101030303A802000 $54003000A000200 $690003000200020 $4100D800E400800 
$50030003000200 $1110333036600000 $1010303035600000 $540303025600000 
$30003A9035600000 $381AB025700000 $4000C0009500000 $1540056025400000 
$50030007400200 $540303030300000 $1000CC030300000 $440333032300000 
$1010098018900000 $A901AB030300000 $1550090015D00000 $5400C00A4000A8 
$4000C000C00080 $1500030001A02A00 $4400220 $0 

#xc #yc

|--- 3bytes utf-8 align to 4
#tx " " ( 0 0 ) "▀" "▄" "█"	 | 3bytes utf-char
:bc 2 << 'tx + .write ;
	
:bigline | val -- val
	16 ( 1? 2 - 2dup >> $3 and bc ) drop ;
	
:bigemit | ascii --
	$7f and 32 - clamp0 
	3 << 'f8x8 + @
	0 ( 4 <?
		xc yc pick2 + .at
		swap bigline 16 >> swap
		1+ ) 2drop 
	7 'xc +! ;

:xcol
	$20 nand 63 >? ( 7 - ) $30 - $f and ;
:escape
	xcol .bc c@+ xcol .fc ;
:xchar | char
	$5b =? ( drop c@+ $5b <>? ( escape ; ) ) | [[
	bigemit ;
| [02r[31o
::xwrite | str --
	( c@+ 1? xchar ) 2drop ;
	
::xat
	'yc ! 'xc ! ;

::.box | x y w h --
	( 1? 1- >r
		pick2 pick2 .at
		dup ( 1? 1- " " .write ) drop
		swap 1+ swap
		r> ) 4drop ;
		
::.boxl | x y w h --
	2over .at
	"┌" .write over 2 - "─" .rep "┐" .write
	2swap 1+
	2swap 2 -
	( 1? 1- >r
		pick2 pick2 .at "│" .write 
		pick2 over + 1- .col "│" .write 
		swap 1+ swap r> ) drop 
	pick2 pick2 .at
	"└" .write 2 - "─" .rep "┘" .write
	2drop ;

::.boxd | x y w h --
	2over .at
	"╔" .write over 2 - "═" .rep "╗" .write
	2swap 1+
	2swap 2 -
	( 1? 1- >r
		pick2 pick2 .at "║" .write 
		pick2 over + 1- .col "║" .write 
		swap 1+ swap r> ) drop 
	pick2 pick2 .at
	"╚" .write 2 - "═" .rep "╝" .write		
	2drop ;
	
::.boxf
	( 1? 1- >r
		pick2 pick2 .at
		dup .nsp swap 1+ swap 
		r> ) 4drop ;
	
::.vline | x y h --
	( 1? 1- >r pick2 pick2 .at "│" .write 1+ r> ) 3drop ;
::.hline | x y w --
	-rot .at "─" .rep ;
	
|--------------------------------	
#wx #wy #ww ##wh #wm

::.inwin? | x y -- 0/-1
	wy <? ( 2drop 0 ; ) wy - wh >? ( 2drop 0 ; ) drop
	wx <? ( drop 0 ; ) wx - ww >? ( drop 0 ; ) drop
	-1 ;

::.win 'wh ! 'ww ! 'wy ! 'wx ! ;
::.wmargin 'wm ! ;

::.wfill wx wy ww wh .boxf ;
::.wborde wx wy ww wh .boxl ;
::.wborded wx wy ww wh .boxd ;

:x0 wx ;
:x1 wx 1+ ;
:x2 wx pick2 - ww + ;
:x3 wx pick2 - 1- ww + ;
:x4 wx ww pick3 - 2/ + ;
:x5 wx wm + ;
:x6 wx pick2 - wm - ww + ;
#xpl x0 x1 x2 x3 x4 x5 x6 x0
:y0 wy ;
:y1 wy 1+ ;
:y2 wy wh + 1- ;
:y3 wy 2 - wh + ;
:y4 wy wh 2/ + ;
:y5 wy wm + ;
:y6 wy wm - wh + 1- ;
#ypl y0 y1 y2 y3 y4 y5 y6 y0

|$44 center
:place | count place -- x y
	dup $7 and 3 << 'xpl + @ ex
	swap 4 >> $7 and 3 << 'ypl + @ ex
	rot drop ;
	
::.wtitle | place "" --
	utf8count | place "" count
	rot place .at .write ;
	
::.wlinef | y --
	wx swap wy + .at "├" .write ww 2 - "─" .rep "┤" .write ;
	
::.wline | y --
	wx 1+ swap wy + .at ww 2 - "─" .rep ;
	
#wsx #wsy	
::.wstart	
	wx wm + 'wsx ! 
	wy wm + 'wsy !
	;
	
::.wtext | "" --
	wsx wm + wsy .at
	.write
	1 'wsy +! ;
::.wat@ | -- x y 
	wsx wm + wsy ;
	
|::.wltext ;
|::.wtext ;