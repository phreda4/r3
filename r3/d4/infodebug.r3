^r3/lib/console.r3

#tokenstr
";" "LIT1" "ADR" "CALL" "VAR"
"EX" 
"0?" "1?" "+?" "-?"
"<?" ">?" "=?" ">=?" "<=?" "<>?" "AND?" "NAND?" "IN?"
"DUP" "DROP" "OVER" "PICK2" "PICK3" "PICK4" "SWAP" "NIP" 
"ROT" "-ROT" "2DUP" "2DROP" "3DROP" "4DROP" "2OVER" "2SWAP" 
">R" "R>" "R@" 
"AND" "OR" "XOR" "NAND" 
"+" "-" "*" "/" 
"<<" ">>" ">>>" 
"MOD" "/MOD" "*/" "*>>" "<</" 
"NOT" "NEG" "ABS" "SQRT" "CLZ" 
"@" "C@" "W@" "D@" 
"@+" "C@+" "W@+" "D@+" 
"!" "C!" "W!" "D!" 
"!+" "C!+" "W!+" "D!+" 
"+!" "C+!" "W+!" "D+!" 
">A" "A>" "A+" 
"A@" "A!" "A@+" "A!+" 
"CA@" "CA!" "CA@+" "CA!+" 
"DA@" "DA!" "DA@+" "DA!+" 
">B" "B>" "B+" 
"B@" "B!" "B@+" "B!+" 
"CB@" "CB!" "CB@+" "CB!+" 
"DB@" "DB!" "DB@+" "DB!+" 
"AB[" "]BA" 
"MOVE" "MOVE>" "FILL" 
"CMOVE" "CMOVE>" "CFILL" 
"DMOVE" "DMOVE>" "DFILL" 
"MEM" 
"LOADLIB" "GETPROC" 
"SYS0" "SYS1" "SYS2" "SYS3" "SYS4" "SYS5" 
"SYS6" "SYS7" "SYS8" "SYS9" "SYS10"
"JMP" "JMPR" "LIT2" "LIT3" "LITF" 
"AND_L" "OR_L" "XOR_L" "NAND_L" 
"+_L" "-_L" "*_L" "/_L" 
"<<_L" ">>_L" ">>>_L" 
"MOD_L" "/MOD_L" "* /_L" 
"*>>_L" "<</_L" 
"*>>16_L" "<<16/_L" 
"*>>16" "<<16/" 
"<?_L" ">?_L" "=?_L" ">=?_L" "<=?_L" "<>?_L" "AN?_L" "NA?_L" 
"<<>>_" ">>AND_" 
"+@_" "+C@_" "+W@_" "+D@_" 
"+!_" "+!C_" "+!W_" "+!D_" 
"1<<+@" "2<<+@" "3<<+@" 
"1<<+@C" "2<<+@C" "3<<+@C" 
"1<<+@W" "2<<+@W" "3<<+@W" 
"1<<+@D" "2<<+@D" "3<<+@D" 
"1<<+!" "2<<+!" "3<<+!" 
"1<<+!C" "2<<+!C" "3<<+!C" 
"1<<+!W" "2<<+!W" "3<<+!W" 
"1<<+!D" "2<<+!D" "3<<+!D" 
"AA1" "BA1" 
"av@" "avC@" "avW@" "avD@" 
"av@+" "avC@+" "avW@+" "avD@+" 
"av!" "avC!" "avW!" "avD!" 
"av!+" "avC!+" "avW!+" "avD!+" 
"av+!" "avC+!" "avW+!" "avD+!" 
"v@" "vC@" "vW@" "vD@" 
"v@+" "vC@+" "vW@+" "vD@+" 
"v!" "vC!" "vW!" "vD!" 
"v!+" "vC!+" "vW!+" "vD!+" 
"v+!" "vC+!" "vW+!" "vD+!" 


#tokencnt (
0 0 0 0 0
0
0 0 0 0 |"0?" "1?" "+?" "-?"
0 0 0 0 0 0 0 0 0 |"<?" ">?" "=?" ">=?" "<=?" "<>?" "AND?" "NAND?" "IN?"
0 0 0 0 0 0 0 0
0 0 0 0 0 0 0 0
0 0 0
0 0 0 0
0 0 0 0
0 0 0
0 0 0 0 0
0 0 0 0 0
0 0 0 0
0 0 0 0
0 0 0 0
0 0 0 0
0 0 0 0
0 0 0
0 0 0 0
0 0 0 0
0 0 0 0
0 0 0
0 0 0 0
0 0 0 0
0 0 0 0
0 0 
0 0 0
0 0 0
0 0 0
0
0 0 
1 1 1 1 1 1 |"SYS0" "SYS1" "SYS2" "SYS3" "SYS4" "SYS5" 
1 1 1 1 1 |"SYS6" "SYS7" "SYS8" "SYS9" "SYS10"
1 -1 -1 -1 1 |"JMP" "JMPR" "LIT2" "LIT3" "LITF" 
1 1 1 1 |"AND_L" "OR_L" "XOR_L" "NAND_L" 
1 1 1 1 |"+_L" "-_L" "*_L" "/_L" 
1 1 1 |"<<_L" ">>_L" ">>>_L" 
1 1 1 |"MOD_L" "/MOD_L" "*/_L" 
1 1 |"*>>_L" "<</_L" 
2 2 |"*>>16_L" "<<16/_L" 
1 1 |"*>>16" "<<16/" 
1 1 1 1 1 1 1 1 |"<?_L" ">?_L" "=?_L" ">=?_L" "<=?_L" "<>?_L" "AN?_L" "NA?_L" 
3 3 |"<<>>_" ">>AND_" 
2 2 2 2 |"+@_" "+C@_" "+W@_" "+D@_" 
2 2 2 2 |"+!_" "+!C_" "+!W_" "+!D_" 
3 3 3 |"1<<+@" "2<<+@" "3<<+@" 
3 3 3 |"1<<+@C" "2<<+@C" "3<<+@C" 
3 3 3 |"1<<+@W" "2<<+@W" "3<<+@W" 
3 3 3 |"1<<+@D" "2<<+@D" "3<<+@D" 
3 3 3 |"1<<+!" "2<<+!" "3<<+!" 
3 3 3 |"1<<+!C" "2<<+!C" "3<<+!C" 
3 3 3 |"1<<+!W" "2<<+!W" "3<<+!W" 
3 3 3 |"1<<+!D" "2<<+!D" "3<<+!D" 
1 1 |"AA1" "BA1" 
1 1 1 1 |"av@" "avC@" "avW@" "avD@" 
1 1 1 1 |"av@+" "avC@+" "avW@+" "avD@+" 
1 1 1 1 |"av!" "avC!" "avW!" "avD!" 
1 1 1 1 |"av!+" "avC!+" "avW!+" "avD!+" 
1 1 1 1 |"av+!" "avC+!" "avW+!" "avD+!" 
1 1 1 1 |"av@" "avC@" "avW@" "avD@" 
1 1 1 1 |"av@+" "avC@+" "avW@+" "avD@+" 
1 1 1 1 |"av!" "avC!" "avW!" "avD!" 
1 1 1 1 |"av!+" "avC!+" "avW!+" "avD!+" 
1 1 1 1 |"av+!" "avC+!" "avW+!" "avD+!" 

::.token | value -- str
	'tokenstr swap $ff and n>>0 ;
	
::token>cnt | value -- cnt
	$ff and 'tokencnt + c@ ;