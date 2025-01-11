
|---------------------------------------LOG
::,2d	10 <? ( "0" ,s ) ,d ;
::,time	time dup 16 >> $ff and ,d ":" ,s dup 8 >> $ff and ,2d ":" ,s $ff and ,2d ;
::,date	date dup $ff and ,d "/" ,s dup 8 >> $ff and ,d "/" ,s 16 >> $ffff and ,d ; 
	
#term * 4096

:plog | "" --
	count 1+ | s c
	'term dup pick2 + swap rot 4096 swap - cmove>
	'term strcpy 
	;
	
::slog | adr --
	mark ,date 32 ,c ,time 32 ,c ,print 13 ,c 10 ,c 
	0 ,c empty here 
	plog 
	;
		
::log | adr --
	dup "%l" sprint slog ;

::showterm
	$0 bcolor
	ab[
	'term >a 30 ( 4 >? 4 over gotoxy a> dup bemits >>0 >a 1- ) drop
	]ba
	;