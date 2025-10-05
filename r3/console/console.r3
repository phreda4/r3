| console words 
| PHREDA 2021 - Updated 2025

|LIN| ^./lin-console.r3
|WIN| ^./win-console.r3
^r3/lib/mem.r3
^r3/lib/parse.r3

| KEYCODES 

##[ESC] $1b ##[ENTER] $a ##[TAB] $9 ##[BACK] $7f 
##[DEL]	$7E335B1B ##[INS] $7E325B1B
##[UP] $415b1b ##[DN] $425b1b ##[RI] $435B1B ##[LE] $445B1B
##[PGUP] $7e355b1b ##[PGDN] $7e365b1b ##[HOME] $485b1b ##[END] $465b1b
	
##[F1]	$504f1b ##[F2]	$514f1b ##[F3]	$524f1b ##[F4]	$534f1b
##[F5]	$7E34315B1B ##[F6]	$7E37315B1B ##[F7]	$7E38315B1B ##[F8]	$7E39315B1B
##[F9]	$7E30325B1B

| [CTRL]+A : 01 ..
| [ALT]+A  : 1b A

|------- Output Buffer System -------
#outbuf * $ffff  | 64KB output buffer
#outbuf> 'outbuf | Current position in buffer

::.flush | -- | Write buffer to stdout
    outbuf> 'outbuf - 0? ( drop ; )
	'outbuf swap type
    'outbuf 'outbuf> ! ;

::.type | str cnt -- | Add to buffer
    'outbuf> outbuf> - >? ( .flush )
	outbuf> rot pick2 cmove
    'outbuf> +! ;
::.emit | char --
	outbuf> 'outbuf> =? ( .flush 'outbuf nip ) c!+ 'outbuf> ! ;

::.cr 10 .emit 13 .emit ;
::.sp 32 .emit ;
::.nsp | n -- ;..
	32 swap 
::.nch | char n -- ; WARNIG not multibyte
	'outbuf> outbuf> - >? ( .flush )
	outbuf> rot pick2 cfill | dvc
	'outbuf> +! ;

::.write count .type ;
::.print sprintc .type ;
::.println sprintlnc .type ;
::.[ $1b .emit $5b .emit .write ;

::.rep | cnt  "car" -- 
	count rot ( 1? 1- pick2 pick2 .type ) 3drop ;

::.fwrite .write .flush ;
::.fprint .print .flush ;
::.fprintln .println .flush ;

|------- Special Character Printing -------
:emite | char --
    $5e =? ( drop 27 .emit ; ) | ^=escape
    .emit ;

::.printe | "str" -- | print with ^=ESC
    sprint ( c@+ 1? emite ) 2drop ;

|------- Cursor Control -------
::.home "H" .[ ;
::.cls "H" .[ "J" .[ ;
::.at "%d;%dH" sprint .[ ; | x y -- | f
::.col "%dG" sprint .[ ; | x -- columna
::.eline "0K" .[ ; | erase line from cursor
|::.eline0 "1K" .[ ; | erase from start of line to cursor
::.ealine "2K" .[ ; | borrar linea actual
::.escreen "J" .[ ; | erase from cursor to end of screen
::.escreenup "1J" .[ ; | erase from cursor to beginning

::.showc "?25h" .[ ;
::.hidec "?25l" .[ ;
::.blc "?12h" .[ ;
::.unblc "?12l" .[ ;
::.savec "s" .[ ; | save cursor position
::.restorec "u" .[ ; | restore cursor position

|------- Cursor Shapes -------
::.ovec "0 q" .[ ; | default cursor
::.insc "5 q" .[ ; | blinking bar
::.blockc "2 q" .[ ; | steady block
::.underc "4 q" .[ ; | steady underscore

|------- Screen Buffer Control -------
::.alsb "?1049h" .[ ; | alternate screen buffer
::.masb "?1049l" .[ ; | main screen buffer

|------- Foreground Colors -------
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

::.fc "38;5;%dm" sprint .[ ; | 256 color foreground

|------- Background Colors -------
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

::.bc "48;5;%dm" sprint .[ ; | 256 color background

|------- RGB Colors (true color) | r g b --
::.fgrgb swap rot "38;2;%d;%d;%dm" sprint .[ ;
::.bgrgb swap rot "48;2;%d;%d;%dm" sprint .[ ;

|------- Text Attributes -------
::.Bold "1m" .[ ;
::.Dim "2m" .[ ;
::.Italic "3m" .[ ;
::.Under "4m" .[ ;
::.Blink "5m" .[ ;
::.Rever "7m" .[ ;
::.Hidden "8m" .[ ;
::.Strike "9m" .[ ;
::.Reset "0m" .[ ;
	
|------- Line Input -------
##pad * 256

:.readln | --
    'pad ( inkey 1? swap c!+ ) swap c! ;

::.input | -- | read line to pad
    'pad 
    ( getch $D <>? | wait for ENTER key
        0? ( drop ; )
        8 =? ( swap 
            1 - 'pad <? ( 2drop 'pad ; )
            swap .emit "1P" .[ ; )
        dup .emit
        swap c!+ ) drop
    0 swap c! ;

::.inputn | -- n | read number
    .input 'pad str>nro nip ;

::waitesc | -- | wait for ESC key
    ( getch [esc] <>? drop ) drop ;
	

