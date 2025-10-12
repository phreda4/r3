| terminal words 
| PHREDA 2021 - Updated 2025

|LIN| ^r3/lib/posix/lin-term.r3
|WIN| ^r3/lib/win/win-term.r3
^r3/lib/mem.r3
^r3/lib/parse.r3

| KEYCODES 
::[ESC] $1b ; 
::[ENTER] 
|WIN| $d 
|LIN| $a
	; 
::[BACK] $7f ;
::[TAB] $9 ; ::[DEL] $7E335B1B ; ::[INS] $7E325B1B ;
::[UP] $415b1b ; ::[DN] $425b1b ; 
::[RI] $435B1B ; ::[LE] $445B1B ;
::[PGUP] $7e355b1b ; ::[PGDN] $7e365b1b ; 
::[HOME] $485b1b ; ::[END] $465b1b ;
::[SHIFT+TAB] $5a5b1b ;
::[SHIFT+DEL] $7e323b335b1B ;
::[SHIFT+INS] $7E323b325B1B ;
::[SHIFT+UP] $41323b315b1b ; ::[SHIFT+DN] $42323b315b1b ;
::[SHIFT+RI] $43323b315B1B ; ::[SHIFT+LE] $44323b315B1B ;
::[SHIFT+PGUP] $7e323b355b1b ; ::[SHIFT+PGDN] $7e323b365b1b ;
::[SHIFT+HOME] $48323b315b1b ; ::[SHIFT+END] $46323b315b1b ;
::[F1] $504f1b ; ::[F2] $514f1b ; ::[F3] $524f1b ; ::[F4] $534f1b ;
::[F5] $7E34315B1B ; ::[F6]	$7E37315B1B ; ::[F7] $7E38315B1B ; ::[F8] $7E39315B1B ;
::[F9] $7E30325B1B ; ::[F10] $7E31325B1B ; ::[F11] $7E33325B1B ; ::[F12] $7E34325B1B ;

| [CTRL]+A : 01 ..
| [ALT]+A  : 1b A

|------- Output Buffer System -------
#outbuf | output buffer
#outbuf> 'outbuf | Current position in buffer
#endbuf |  end of outbuf

::.cl outbuf 'outbuf> ! ;
	
::.flush | -- | Write buffer to stdout
    outbuf> outbuf - 0? ( drop ; )
	outbuf swap type
    outbuf 'outbuf> ! ;

::.type | str cnt -- | Add to buffer
    endbuf outbuf> - >? ( .flush ) 
	outbuf> rot pick2 cmove
    'outbuf> +! ;
::.emit | char --
	outbuf> endbuf =? ( .flush outbuf nip ) c!+ 'outbuf> ! ;

::.cr 10 .emit 13 .emit ;
::.sp 32 .emit ;
::.nsp | n -- ;..
	32 swap 
::.nch | char n -- ; WARNIG not multibyte
	endbuf outbuf> -  >? ( .flush )
	outbuf> rot pick2 cfill | dvc
	'outbuf> +! ;

::.write count .type ;
::.print sprintc .type ;
::.println sprintlnc .type ;

::.^[ $1b .emit $5b .emit ;
::.[w .^[ .write ;
::.[p .^[ .print ;

::.rep | cnt  "car" -- 
	count rot ( 1? 1- pick2 pick2 .type ) 3drop ;

|--- automatic flush version
::.fwrite .write .flush ;
::.fprint .print .flush ;
::.fprintln .println .flush ;

|------- Cursor Control -------
::.home "H" .[w ;
::.cls "H" .[w "J" .[w ;
::.at "%d;%dH" .[p ; | x y -- | f
::.col "%dG" .[p ; | x -- columna
::.eline "0K" .[w ; | erase line from cursor
|::.eline0 "1K" .[w ; | erase from start of line to cursor
::.ealine "2K" .[w ; | borrar linea actual
::.escreen "J" .[w ; | erase from cursor to end of screen
::.escreenup "1J" .[w ; | erase from cursor to beginning

::.showc "?25h" .[w ;
::.hidec "?25l" .[w ;
::.blc "?12h" .[w ;
::.unblc "?12l" .[w ;
::.savec "s" .[w ; | save cursor position
::.restorec "u" .[w ; | restore cursor position

|------- Cursor Shapes -------
::.ovec "0q" .[w ; | default cursor
::.insc "5q" .[w ; | blinking bar
::.blockc "2q" .[w ; | steady block
::.underc "4q" .[w ; | steady underscore

|------- Screen Buffer Control -------
::.alsb "?1049h" .[w ; | alternate screen buffer
::.masb "?1049l" .[w ; | main screen buffer

::.scrolloff | rows --
	"1;%dr" .[p ;
::.scrollon	"r" .[w ;
|------- Foreground Colors -------
::.Black "30m" .[w ;
::.Red "31m" .[w ;
::.Green "32m" .[w ;
::.Yellow "33m" .[w ;
::.Blue "34m" .[w ;
::.Magenta "35m" .[w ;
::.Cyan "36m" .[w ;
::.White "37m" .[w ;

::.Blackl "30;1m" .[w ;
::.Redl "31;1m" .[w ;
::.Greenl "32;1m" .[w ;
::.Yellowl "33;1m" .[w ;
::.Bluel "34;1m" .[w ;
::.Magental "35;1m" .[w ;
::.Cyanl "36;1m" .[w ;
::.Whitel "37;1m" .[w ;

::.fc "38;5;%dm" .[p ; | 256 color foreground

|------- Background Colors -------
::.BBlack "40m" .[w ;
::.BRed "41m" .[w ;
::.BGreen "42m" .[w ;
::.BYellow "43m" .[w ;
::.BBlue "44m" .[w ;
::.BMagenta "45m" .[w ;
::.BCyan "46m" .[w ;
::.BWhite "47m" .[w ;

::.BBlackl "40;1m" .[w ;
::.BRedl "41;1m" .[w ;
::.BGreenl "42;1m" .[w ;
::.BYellowl "43;1m" .[w ;
::.BBluel "44;1m" .[w ;
::.BMagental "45;1m" .[w ;
::.BCyanl "46;1m" .[w ;
::.BWhitel "47;1m" .[w ;

::.bc "48;5;%dm" .[p ; | 256 color background

|------- RGB Colors (true color) | r g b --
::.fgrgb swap rot "38;2;%d;%d;%dm" .[p ;
::.bgrgb swap rot "48;2;%d;%d;%dm" .[p ;

|------- Text Attributes -------
::.Bold "1m" .[w ;
::.Dim "2m" .[w ;
::.Italic "3m" .[w ;
::.Under "4m" .[w ;
::.Blink "5m" .[w ;
::.Rever "7m" .[w ;
::.Hidden "8m" .[w ;
::.Strike "9m" .[w ;
::.Reset "0m" .[w ;

::waitesc | -- | wait for ESC key
    ( getch [esc] <>? drop 10 ms ) drop ;

::waitkey | -- | wait any key
    ( getch 0? drop 10 ms ) drop ;
	
: |||||||||||||||||||||||||||||
	here 
	dup 'outbuf ! dup 'outbuf> !
	$ffff +	| 64kb flush buffer (big!!)
	dup 'endbuf ! 'here !
	;
