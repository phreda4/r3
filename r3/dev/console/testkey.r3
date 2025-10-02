^./console.r3
^./f8x8.r3

:testkey
    getch
    [esc] =? ( drop ; )
    "%h" .fprintln
    testkey
    ;

: .console 
.cls .blue
1 1 xat
"Key Codes" xwrite .cr
.white
testkey 
.free ;
