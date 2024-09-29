^r3/lib/console.r3

:testkey
    getch
    [esc] =? ( drop ; )
    "%h" .println
    testkey
    ;

:
testkey 
;
