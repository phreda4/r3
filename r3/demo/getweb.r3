| Test WININET
| PHREDA 2021

^r3/win/inet.r3
^r3/win/console.r3

#cnt

: 
mark
"http://www.google.com" 0 here openurl
dup here - 'cnt !
0 swap c!

|here .println

cnt " largo:%d " .println

;
