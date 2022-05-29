| console words linux
| PHREDA 2022

^r3/posix/posix.r3
^r3/lib/mem.r3
^r3/lib/parse.r3

#kb 0

:stdout-write 1 -rot write drop ;
:stdin-key 
	0 'kb !  
	0 'kb 1 read drop  ;
	
:posix-bye   0 sysexit drop ;

::key | -- key
	stdin 'kb 1 0 0 ReadFile drop kb 
	;
	
::key? | -- f 
	stdin 0 WaitForSingleObject ;
	
::type | str cnt --
	1 rot rot write drop ;


#irec 0 
#codekey 0 0 0

|--- format key =  $ccp0ss
|    scancode			    ss
|    char				cc0000
|    press(0) release(1)  p000
|   
| ej: $1B1001 = release esc
::getch | -- key
|	stdin 'irec 1 'kb ReadConsoleInput 
	codekey 32 >> $1000 or irec 20 >> xor ;

::waitesc
	( getch $1B1001 <>? drop ) drop ;
	
#crb ( 10 13 0 0 )
#esc[ ( $1b $5b 0 0 0 0 0 0 0 0 0 0 )

::cr 'crb 2 type ;
::sp " " 1 type ;
::nsp ( 1? 1 - sp ) drop ;

::emit | nro
	" " dup rot swap c! 1 type ;
	
::.[ 'esc[ 2 + swap
	( c@+ 1? rot c!+ swap ) 2drop
	'esc[ swap over - type ;

::.write count type ;
	
::.print sprint count type ;

::.println sprint count type cr ;

::.home	"H" .[ ; | home
::.cls "H" .[ "J" .[ ; | cls 
::.at "%d;%df" sprint .[ ; | x y -- 
::.eline "K" .[ ; | erase line from cursor

::.fc "38;5;%dm" sprint .[ ; | Set foreground color.
::.bc  "48;5;%dm" sprint .[ ; 

::.Black "30m" .[ ;
::.Red "31m" .[ ;
::.Green "32m" .[ ;
::.Yellow "33m" .[ ;
::.Blue "34m" .[ ;
::.Magenta "35m" .[ ;
::.Cyan "36m" .[ ;
::.White "37m" .[ ;
::.Blackl "30;1m" .[ ;
::.Redl "31;1m" .[ ;
::.Greenl "32;1m" .[ ;
::.Yellowl "33;1m" .[ ;
::.Bluel "34;1m" .[ ;
::.Magental "35;1m" .[ ;
::.Cyanl "36;1m" .[ ;
::.Whitel "37;1m" .[ ;
	
::.BBlack "40m" .[ ;
::.BRed "41m" .[ ;
::.BGreen "42m" .[ ;
::.BYellow "43m" .[ ;
::.BBlue "44m" .[ ;
::.BMagenta "45m" .[ ;
::.BCyan "46m" .[ ;
::.BWhite "47m" .[ ;
::.BBlackl "40;1m" .[ ;
::.BRedl "41;1m" .[ ;
::.BGreenl "42;1m" .[ ;
::.BYellowl "43;1m" .[ ;
::.BBluel "44;1m" .[ ;
::.BMagental "45;1m" .[ ;
::.BCyanl "46;1m" .[ ;
::.BWhitel "47;1m" .[ ;

::.Bold "1m" .[ ;
::.Under "4m" .[ ;
::.Rever "7m" .[ ;
::.Reset "0m" .[ ;

::.alsb	"?1049h" .[ ; | alternate screen buffer
::.masb "?1049l" .[ ; | main screen buffer

::.showc "?25h" .[ ;
::.hidec "?25l" .[ ;
::.ovec "0 q" .[ ;
::.insc "5 q" .[ ;

##consoleinfo 0 0 0
##rows 
##cols

##pad * 256

::.input | --
	'pad
	( key 13 <>? swap c!+ ) drop
	0 swap c! ;

::.inputn | -- nro
	.input 'pad str>nro nip ;

:emite | char --
	$5e =? ( drop 27 emit ; ) | ^=escape
	emit ;
	
::.printe | "" --
	sprint
	( c@+ 1? emite ) 2drop ;

:ms 1000 * libc-usleep drop ;

:ms-ticks 
|   0 >r 0 >r CLOCK_MONOTONIC_RAW r@ cell - clock_gettime throw
|	r> 1000000 / r> 1000 * + 
	;