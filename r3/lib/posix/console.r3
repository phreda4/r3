| console words linux
| PHREDA 2022

^r3/lib/mem.r3
^r3/lib/str.r3
^r3/lib/posix/conkey.r3

#kb 0

:stdin-key 
	0 'kb !  
	0 'kb 1 libc-read drop  ;
	
:posix-bye   0 libc-exit drop ;

::type | str cnt --
	 1 rot rot libc-write drop ;

#crb ( 10 13 0 0 )
#esc[ ( $1b $5b 0 0 0 0 0 0 0 0 0 0 )

::.cr 'crb 2 type ;
::.sp " " 1 type ;
::.nsp ( 1? 1 - .sp ) drop ;

::.emit | nro
	" " dup rot swap c! 1 type ;
	
::.[ 'esc[ 2 + swap
	( c@+ 1? rot c!+ swap ) 2drop
	'esc[ swap over - type ;

::.write count type ;
	
::.print sprint count type ; 

::.println sprint count type .cr ; 

::.home	"H" .[ ; | home
::.cls "H" .[ "J" .[ ; | cls 
::.at "%d;%df" sprint .[ ; | x y -- 
::.eline "K" .[ ; | erase line from cursor

|::.fc "38;5;%dm" sprint .[ ; | Set foreground color.
|::.bc  "48;5;%dm" sprint .[ ; 

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

:emite | char --
	$5e =? ( drop 27 .emit ; ) | ^=escape
	.emit ;
	
::.printe | "" --
	sprint
	( c@+ 1? emite ) 2drop ;

:ms 1000 * libc-usleep drop ;


|    tcgetattr(STDIN_FILENO, &oldt);newt = oldt; |   // Get the terminal settings for stdin
|    newt.c_lflag &= ~(ICANON | ECHO); | 12+ |    // Disable canonical mode and echo
|    tcsetattr(STDIN_FILENO, TCSANOW, &newt); |    // Set the new terminal settings
#sterm * 52 | NCC=32
#stermp

::set-terminal-mode
    0 'sterm libc-tcgetattr 
    'sterm 12 + dup w@ dup 'stermp !
    10 nand swap w! |~(ICANON | ECHO);
    0 0 'sterm libc-tcsetattr  ;

::reset-terminal-mode
    stermp 'sterm 12 + w!
    0 0 'sterm libc-tcsetattr  ;
    
|------------ input
##ch 0 0

::getch | -- char
    set-terminal-mode
    0 'ch ! 0 'ch 16 libc-read drop ch 
    reset-terminal-mode
    ;

::waitesc
	( getch $1B <>? drop ) drop ;

##pad * 256

::.input | --
	'pad 
	( getch $a <>? 
		.emit ) drop
	0 swap c! ;

#tv 0 0
#fds * 128

::kbhit
    'tv 0 2 fill 
    'fds 0 16 fill
    1 'fds !
    1 'fds 0 0 'tv libc-select ;

|int kbhit() {
|    struct timeval tv = { 0L, 0L };
|    fd_set fds;
|    FD_ZERO(&fds);FD_SET(0, &fds);
|    return select(1, &fds, NULL, NULL, &tv) > 0;}

::inkey
    set-terminal-mode
    kbhit 0? ( reset-terminal-mode ; ) drop
    0 'ch ! 0 'ch 16 libc-read drop ch
    reset-terminal-mode ;

#ci 0 
##rows 
##cols

::.getconsoleinfo 
    1 $5413 'ci libc-ioctl | TIOCGWINSZ
	ci dup 16 >> $ffff and 1- 'cols ! $ffff and 1- 'rows !
	;



