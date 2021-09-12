loc_403245:             ; jumptable 0000000000402846 case 117
mov     rcx, r11
call    cs:LoadLibraryA
mov     r11, rax
jmp     loc_402859      ; jumptable 0000000000402846 case 130

loc_403256:             ; jumptable 0000000000402846 case 118
mov     rdx, r11
mov     rcx, [r13+0]    ; hModule
sub     r13, 8
call    cs:GetProcAddress
mov     r11, rax
jmp     loc_402859      ; jumptable 0000000000402846 case 130

loc_40326F:             ; jumptable 0000000000402846 case 119
call    r11
mov     r11, rax
jmp     loc_402859      ; jumptable 0000000000402846 case 130

loc_40327A:             ; jumptable 0000000000402846 case 120
mov     rcx, [r13+0]
sub     r13, 8
call    r11
mov     r11, rax
jmp     loc_402859      ; jumptable 0000000000402846 case 130

loc_40328D:             ; jumptable 0000000000402846 case 121
mov     rcx, [r13-8]
mov     rdx, [r13+0]
sub     r13, 10h
call    r11
mov     r11, rax
jmp     loc_402859      ; jumptable 0000000000402846 case 130

loc_4032A4:             ; jumptable 0000000000402846 case 122
mov     rdx, [r13-8]
mov     rcx, [r13-10h]
sub     r13, 18h
mov     r8, [r13+18h]
call    r11
mov     r11, rax
jmp     loc_402859      ; jumptable 0000000000402846 case 130

loc_4032BF:             ; jumptable 0000000000402846 case 123
mov     rdx, [r13-10h]
mov     rcx, [r13-18h]
sub     r13, 20h ; ' '
mov     r9, [r13+20h]
mov     r8, [r13+18h]
call    r11
mov     r11, rax
jmp     loc_402859      ; jumptable 0000000000402846 case 130

var_B8= qword ptr -0B8h
var_B0= qword ptr -0B0h
var_A8= qword ptr -0A8h
var_A0= qword ptr -0A0h
var_98= qword ptr -98h
var_90= qword ptr -90h
var_88= qword ptr -88h
var_80= qword ptr -80h
var_78= xmmword ptr -78h
var_68= qword ptr -68h
var_60= qword ptr -60h
var_58= qword ptr -58h
var_50= qword ptr -50h

loc_4032DE:             ; jumptable 0000000000402846 case 124
mov     rax, [r13+0]
mov     rdx, [r13-18h]
sub     r13, 28h ; '('
mov     rcx, [r13+8]
mov     r9, [r13+20h]
mov     r8, [r13+18h]
mov     [rsp+0D8h-0B8h], rax
call    r11
mov     r11, rax
jmp     loc_402859      ; jumptable 0000000000402846 case 130

loc_403306:             ; jumptable 0000000000402846 case 125
mov     rax, [r13+0]
mov     rdx, [r13-20h]
sub     r13, 30h ; '0'
mov     rcx, [r13+8]
mov     r9, [r13+20h]
mov     r8, [r13+18h]
mov     [rsp+0D8h+var_B0], rax
mov     rax, [r13+28h]
mov     [rsp+0D8h+var_B8], rax
call    r11
mov     r11, rax
jmp     loc_402859      ; jumptable 0000000000402846 case 130

loc_403337:             ; jumptable 0000000000402846 case 126
mov     rax, [r13+0]
mov     rdx, [r13-28h]
sub     r13, 38h ; '8'
mov     rcx, [r13+8]
mov     r9, [r13+20h]
mov     r8, [r13+18h]
mov     [rsp+0D8h+var_A8], rax
mov     rax, [r13+30h]
mov     [rsp+0D8h+var_B0], rax
mov     rax, [r13+28h]
mov     [rsp+0D8h+var_B8], rax
call    r11
mov     r11, rax
jmp     loc_402859      ; jumptable 0000000000402846 case 130

loc_403371:             ; jumptable 0000000000402846 case 127
mov     rax, [r13+0]
mov     rdx, [r13-30h]
sub     r13, 40h ; '@'
mov     rcx, [r13+8]
mov     r9, [r13+20h]
mov     r8, [r13+18h]
mov     [rsp+0D8h+var_A0], rax
mov     rax, [r13+38h]
mov     [rsp+0D8h+var_A8], rax
mov     rax, [r13+30h]
mov     [rsp+0D8h+var_B0], rax
mov     rax, [r13+28h]
mov     [rsp+0D8h+var_B8], rax
call    r11
mov     r11, rax
jmp     loc_402859      ; jumptable 0000000000402846 case 130

loc_4033B4:             ; jumptable 0000000000402846 case 128
mov     rax, [r13+0]
mov     rdx, [r13-38h]
sub     r13, 48h ; 'H'
mov     rcx, [r13+8]
mov     r9, [r13+20h]
mov     r8, [r13+18h]
mov     [rsp+0D8h+var_98], rax
mov     rax, [r13+40h]
mov     [rsp+0D8h+var_A0], rax
mov     rax, [r13+38h]
mov     [rsp+0D8h+var_A8], rax
mov     rax, [r13+30h]
mov     [rsp+0D8h+var_B0], rax
mov     rax, [r13+28h]
mov     [rsp+0D8h+var_B8], rax
call    r11
mov     r11, rax
jmp     loc_402859      ; jumptable 0000000000402846 case 130

loc_403400:             ; jumptable 0000000000402846 case 129
mov     rax, [r13+0]
mov     rdx, [r13-40h]
sub     r13, 50h ; 'P'
mov     rcx, [r13+8]
mov     r9, [r13+20h]
mov     r8, [r13+18h]
mov     [rsp+0D8h+var_90], rax
mov     rax, [r13+48h]
mov     [rsp+0D8h+var_98], rax
mov     rax, [r13+40h]
mov     [rsp+0D8h+var_A0], rax
mov     rax, [r13+38h]
mov     [rsp+0D8h+var_A8], rax
mov     rax, [r13+30h]
mov     [rsp+0D8h+var_B0], rax
mov     rax, [r13+28h]
mov     [rsp+0D8h+var_B8], rax
call    r11
mov     r11, rax
jmp     loc_402859      ; jumptable 0000000000402846 case 130
