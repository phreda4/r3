| testvm
| PHREDA 2025
|-------------------------
^./rcodevm2.r3

|------------	
#testcode "
#v1 2
:cua dup * ;

: v1 cua ;
"
|------------	

|------------	
#cpu
#state | 0 - view | 1 - edit | 2 - run | 3 - error
	
|----- code
#cdtok * 1024
#cdtok> 'cdtok
#cdnow>

#cdspeed 0.2

:stepvm
	cdnow> 0? ( drop ; ) 
	|vmstepck 
	vmstep
|	1? ( dup vm2src 'fuente> ! )
	'cdnow> !
	;
	
:stepvmas
	cdnow> 0? ( drop ; ) 
	vmstepck 
	|vmstep
	terror 1 >? ( 2drop 
		3 'state ! 
		; ) drop
	cdtok> >=? ( drop 0 ) | fuera de codigo
	0? ( 'cdnow> ! 1 'state ! ; ) | fin
|	dup vm2src 'fuente> ! 
	'cdnow> !
	;
	
:compila | str -- code/0
	mark
	vmtokenizer 'code !
	terror 1 >? ( drop 
		3 'state !
		; ) drop
	2 'state !
	
	8 'code vmcpu 'cpu ! | 8 variables
	;


:compilar | str --
	vmtokreset
	'cdtok vmtokenizer 'cdtok> ! 
	0 cdtok> !
	
	vmdicc | ** DEBUG
|	|cdcnt 'cdtok vmcheckjmp

	terror 1 >? ( drop 
		3 'state !
|		serror 'fuente> ! 
		; ) drop
	2 'state ! 
	;
	
	
:play
	state 2 =? ( drop ; ) drop
	compilar
	state 2 <>? ( drop ; ) drop
	
	vmboot 
|	dup vm2src 'fuente> ! 
	'cdnow> !
	vmreset
|	resetplayer
|	'stepvma cdspeed +vexe
	
	;
	
	
:step
	state 2 =? ( drop stepvmas ; ) drop | stop?
	|resetplayer 
	compilar
	vmboot 
|	dup vm2src 'fuente> ! 
	'cdnow> !
	vmreset
|	resetplayer
	 ;
	
:help
	;
:vmcompila
	;
	
|------------ STACK
:drawstack
	vmdeep 0? ( drop ; ) 
	stack 8 +
	( swap 1- 1? swap
		@+ vmcell .write
		) 2drop 
	TOS vmcell .write ;
	
#code1 #code2
#cpu1 #cpu2 #cpu3 
	
|-------------------
: |<<< BOOT <<<
	"test vm" .println .cr
|	'cdtok 8 vmcpu 'cpu ! | 8 variables
|	'testcode vmcompila 'code1 !
|	code1 vmcpu 'cpu1 !
	
|	'code1 vmdicc
	.cr
|	cpu1 vmboot
|	cpu1 vmstep
	|vmdicc
	.input
	;
