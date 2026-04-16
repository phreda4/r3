
^r3/lib/console.r3


|------ pack 1 scale (8.8) + 3 rotation (0.16)
::packsrot | sx rx ry rz -- rp
	$ffff and swap 
	$ffff and 16 << or swap 
	$ffff and 32 << or swap
	8 >> $ffff and 48 << or 
	;

::+srot | ra rb -- rr
	+ $100010001 nand ;

|------ pack 3 vel in 63bits (21x3) (13.8) 
::pack21 | vx vy vz -- vp
	8 >> $1fffff and swap
	8 >> $1fffff and 21 << or swap
	8 >> $1fffff and 42 << or ;
	
::+p21 | va vb -- vr
	+ $40000200001 nand ;
	
::unpack21 | x -- px py pz
	dup 1 << 43 >> 8 << swap
	dup 22 << 43 >> 8 << swap
	43 << 43 >> 8 << ;


#cntbones 
#bones * $fff
#mats * $ffff | dwords!!

#cntani

#filer3a
#tx #ty #tz #rx #ry #rz #sc #pa
:parseline | adr -- adr'
	trim
	str>fnro 'tx ! str>fnro 'ty ! str>fnro 'tz !
	str>fnro 'rx ! str>fnro 'ry ! str>fnro 'rz !
	str>fnro 'sc ! ;
	
#cntstep

:parsepose
	0 ( cntbones <? swap
		over "%d " .print
		>>cr trim
		swap 1+ ) drop .cr
	;
	
:parseanim | adr -- adr
	"ANIM" findstr >>sp trim
	dup "%l" .println
	1+ >>str trim
	getnro dup "steps:%d" .println  'cntstep !
	0 ( cntstep <? swap
		"STEP"  findstr >>sp trim
		>>cr trim
		parsepose
		swap 1+ ) drop
	"END_ANIM" findstr >>sp
	;
	
:loadr3a | "" --
	here dup 'filer3a !
	swap load 0 swap c!+ 'here !

	filer3a 
	"SKELETON" findstr 
	>>sp trim
	getnro 'cntbones ! |"cnt:%d" .println
	'bones >a
	0 ( cntbones <?
		|dup "%d." .print
		swap
		"JOINT" findstr 5 +
		trim getnro drop |"%d," .print
		trim 1+ >>str trim
		getnro 'pa ! | parent
		parseline
		tx ty tz pack21 a!+
		sc rx ry rz packsrot a!+
		$ff0000 32 << pa $ffff and or a!+
		0 a!+
		swap 1+ ) drop
	a> 'bones - "bones %d bytes" .println

	"ANIMATIONS" findstr >>sp trim 
	getnro dup "animations:%d" .println 'cntani !
	0 ( cntani <? swap 
		parseanim 
		swap 1+ ) drop
	drop
	;

:main
	"media\bvh\pajaro.r3a" 
	|"media\bvh\lobo.r3a" 
	loadr3a
	
	waitkey
	;


: main ;