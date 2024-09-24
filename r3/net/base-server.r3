| SERVER
| PHREDA 2024
^r3/lib/win/console.r3
^r3/lib/sdl2.r3
^r3/lib/sdl2net.r3

|---------------------
:.port | nro -- port
	dup 8 << $ff00 and swap 8 >> $ff and or ;
	
#people * 1024 | n <<5
#lpeople 0

#MAX_CLIENTS 4
#ip
#ip2
#server 
#socketSet
#data * 1024
#datalen

:]people | n -- adr
	5 << 'people + ;
	
|-----------------	
:.iplocal
	"cmd /c C:\\Windows\\System32\\ipconfig | findstr /i ""ipv4"" > mem\\local.ip" sys
	here "mem\\local.ip" load 0 swap c!
	here .println ;

:slot | n -- n
	dup ]people @ 
	0? ( drop server SDLNet_TCP_Accept over ]people ! ; )
	dup 'data 1024 SDLNet_TCP_Recv
	-? ( 2drop 0 over ]people ! ; ) drop
	over "%d] " .print
	0 'data 64 + c!
	'data .println
	
	"ok" 'data strcpy
	'data count SDLNet_TCP_Send drop
	;
	

:runserver
	"Starting server..." .println
	
	'ip 0 1234 SDLNet_ResolveHost
	-1 =? ( drop
		SDLNet_GetError "SDLNet_ResolveHost: %s" .println
		; ) drop
	
	'ip 4 + w@ .port "   Network Port. . . . . . . . . . . : %d" .println
	.iplocal
	
	'ip SDLNet_TCP_Open 
	0? ( drop 
		SDLNet_GetError "SDLNet_TCP_Open: %s" .println
		; )
	'server !
	MAX_CLIENTS "server: %d players" .println
	MAX_CLIENTS 1+ SDLNet_AllocSocketSet 'socketSet !
	socketSet server SDLNet_AddSocket
	
	( inkey $1B1001 <>? drop 
		0 ( MAX_CLIENTS <?
			slot
			1+ ) drop
		10 sdl_delay
		) drop
		
	socketSet SDLNet_FreeSocketSet		
	server SDLNet_TCP_Close
	;
|-----------------	
: 
	$ffff SDL_Init
	SDLNet_Init

	runserver
	
	SDLNet_Quit
	SDL_Quit
	"server: bye" .println
;

