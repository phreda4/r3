
^r3/lib/console.r3


#cntbones 
#cntani

#bones * $ffff
#animas * $fff

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
|		over "%d " .print
		>>sp trim | skip nro
		parseline

		tx ty tz pack21			a!+
		sc rx ry rz packsrot	a!+
		
		>>cr trim
		swap 1+ ) drop 
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
		tx ty tz pack21			a!+
		sc rx ry rz packsrot	a!+
		$ffffff00 32 << pa $ffff and or	a!+
		0 a!+
		swap 1+ ) drop
		
	|a> 'bones - "bones %d bytes" .println

	"ANIMATIONS" findstr >>sp trim 
	getnro dup "animations:%d" .println 'cntani !
	
	here >a
	0 ( cntani <? swap 
		parseanim 
		swap 1+ ) drop
	drop
|-------------------------------------
	mark 
	"R3A" d@ , 
	cntbones , cntani ,
	
	0 ( cntani <?
		
		1+ ) drop
	
	'bones >a
	0 ( cntani <?
		0 ( cntbones <?
			a@+ ,q a@+ ,q
			1+ ) drop		
		1+ ) drop
	
	"test.r3a" savemem
	empty
	;

:main
	"media\bvh\pajaro.r3a" 
	|"media\bvh\lobo.r3a" 
	loadr3a
	
	waitkey
	;


: main ;