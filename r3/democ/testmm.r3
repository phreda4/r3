^r3/lib/console.r3

::.mouse "?1000;1006;1015h" .[ ; | mouse
::-.mouse "?1000;1006;1015l" .[ ; | main screen buffer

::.mouse "?1003h" .[ "?1015h" .[ "1006h" .[ ; | mouse
::-.mouse "?1000l" .[ ; | main screen buffer

#upwm $38343b34363c5b1b
#dnwm $35323b35363c5b1b

:show
    upwm =? ( "wheel up" .println drop ; ) 
    dnwm =? ( "wheel dn" .println drop ; ) 
    'ch 8 + @ "%h " .print
    "%h " .print
    0 'ch 16 + c!
    'ch 2 + .print
    .cr
    ;

:testmouse
    getch [ESC] =? ( drop ; )
|    0? ( drop testmouse ; )
    show
    testmouse    
    ;

:testkey
    getch
    [esc] =? ( drop ; )
    "%h" .println
    testkey
    ;

:
|testkey 

.mouse
testmouse
-.mouse
;
