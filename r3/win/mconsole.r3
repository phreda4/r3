| memory console words
| generate buffer for send to console
| PHREDA 2021
^r3/lib/mem.r3

::,sp 32 ,c ;
::,nsp ( 1? 1 - ,sp ) drop ;

::,esc $1b ,c $5b ,c ;
::,[ ,esc ,s ;
::,fcolor ,esc "38;5;%dm" ,print ;
::,bcolor ,esc "48;5;%dm" ,print ;
::,eline  ,esc "K" ,s ; | erase line from cursor	

::,home	"H" ,[ ; | home
::,cls "H" ,[ "J" ,[ ; | cls 
::,at "%d;%df" sprint ,[ ; | x y -- 
::,col "%dG" sprint ,[ ; | x -- 
::,eline "K" ,[ ; | erase line from cursor

::,fc "38;5;%dm" sprint ,[ ; | Set foreground color.
::,bc  "48;5;%dm" sprint ,[ ; 

::,Black "30m" ,[ ; ::,Red "31m" ,[ ;
::,Green "32m" ,[ ; ::,Yellow "33m" ,[ ;
::,Blue "34m" ,[ ;  ::,Magenta "35m" ,[ ;
::,Cyan "36m" ,[ ;  ::,White "37m" ,[ ;
::,Blackl "30;1m" ,[ ; ::,Redl "31;1m" ,[ ;
::,Greenl "32;1m" ,[ ; ::,Yellowl "33;1m" ,[ ;
::,Bluel "34;1m" ,[ ; ::,Magental "35;1m" ,[ ;
::,Cyanl "36;1m" ,[ ; ::,Whitel "37;1m" ,[ ;
	
::,BBlack "40m" ,[ ; ::,BRed "41m" ,[ ;
::,BGreen "42m" ,[ ; ::,BYellow "43m" ,[ ;
::,BBlue "44m" ,[ ; ::,BMagenta "45m" ,[ ;
::,BCyan "46m" ,[ ; ::,BWhite "47m" ,[ ;
::,BBlackl "100m" ,[ ; ::,BRedl "101m" ,[ ;
::,BGreenl "102m" ,[ ; ::,BYellowl "103m" ,[ ;
::,BBluel "104m" ,[ ; ::,BMagental "105m" ,[ ;
::,BCyanl "106m" ,[ ; ::,BWhitel "107m" ,[ ;

::,Bold "1m" ,[ ;
::,Under "4m" ,[ ;
::,Rever "7m" ,[ ;
::,Reset "0m" ,[ "40m" ,[ "37m" ,[ ;

::,alsb	"?1049h" ,[ ; | alternate screen buffer
::,masb "?1049l" ,[ ; | main screen buffer

::,showc "?25h" ,[ ;	| show cursor
::,hidec "?25l" ,[ ;	| hide cuersor
::,ovec "0 q" ,[ ;		| cursor over
::,insc "5 q" ,[ ;		| cursor insert
::,savec "s" ,[ ;		| save cursor
::,restc "u" ,[ ;		| restore cursor
::,print sprint ,s ;
::,println sprint ,s ,nl ;

:emite | char --
	$5e =? ( drop 27 ,c ; ) | ^=escape
	,c ;
	
::,printe | "" --
	sprint ( c@+ 1? emite ) 2drop ;
	
::,type | adr cnt --
	( 1? 1 - swap c@+ ,c swap ) 2drop ; 
