| console words 
| PHREDA 2021 - Updated 2025

|LIN| ^./lin-console.r3
|WIN| ^./win-console.r3

^r3/lib/mem.r3
^r3/lib/parse.r3

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
    outbuf> + 'outbuf> ! ;
	
::.emit | char --
	outbuf> 'outbuf> =? ( .flush 'outbuf nip ) c!+ 'outbuf> ! ;

::.cr 10 .emit 13 .emit ;
::.sp 32 .emit ;
::.nsp ( 1? 1- .sp ) drop ;
::.write count .type ;
::.print sprintc .type ;
::.println sprintlnc .type ;
::.[ $1b .emit $5b .emit .write ;

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
::.at "%d;%df" sprint .[ ; | x y --
::.eline "K" .[ ; | erase line from cursor
::.escreen "J" .[ ; | erase from cursor to end of screen
::.eline0 "1K" .[ ; | erase from start of line to cursor
::.escreenup "1J" .[ ; | erase from cursor to beginning

::.showc "?25h" .[ ;
::.hidec "?25l" .[ ;
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

:ink | char addr --
    $1000 and? ( drop ; ) | ignore key release
    16 >> $ff and swap c!+ ;

:.readln | --
    'pad ( inkey 1? ink ) swap c! ;

::.input | -- | read line to pad
    'pad 
    ( getch $D001C <>? | wait for ENTER key
        $1000 and? ( drop ; ) | ignore key release
        16 >> 0? ( drop ; )
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
	

