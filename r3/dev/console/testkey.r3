^./console.r3

:testkey
    getch
    [esc] =? ( drop ; )
    "%h" .fprintln
    testkey
    ;

: .console testkey .free ;
