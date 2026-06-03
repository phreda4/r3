; r3f.inc
; Include unificado generado para r3fasm
; Consolida: MACRO/PROC64.INC + MACRO/IMPORT64.INC + API/KERNEL32.INC
;
; NOTA: llamar 'r3f_kernel32' dentro de la seccion '.idata'
;

;==============================================================
; MACRO/PROC64.INC  -  macros de procedimientos y llamadas x64
;==============================================================
; Macroinstructions for defining and calling procedures (x64 version)

macro invoke proc,[arg]
 { common fastcall [proc],arg }

macro fastcall proc,[arg]
 { common local stackspace,argscount,counter
    if argscount < 4
     stackspace = 4*8
    else if argscount and 1
     stackspace = (argscount+1)*8
    else
     stackspace = argscount*8
    end if
    counter = 0
    if stackspace
     if defined current@frame
      if current@frame<stackspace
       current@frame = stackspace
      end if
     else
      if stackspace
       sub rsp,stackspace
      end if
     end if
    end if
   forward
    counter = counter + 1
    define type@param
    define definition@param arg
    match =float value,definition@param
    \{ define definition@param value
       define type@param float \}
    match =addr value,definition@param
    \{ define definition@param value
       define type@param addr \}
    match any=,any,definition@param
    \{ \local ..string,..continue
       jmp ..continue
       align sizeof.TCHAR
       ..string TCHAR definition@param,0
       ..continue:
       define definition@param ..string
       define type@param addr \}
    match any,definition@param
    \{ match \`any,any
       \\{ \\local ..string,..continue
	   jmp ..continue
	   align sizeof.TCHAR
	   ..string TCHAR definition@param,0
	   ..continue:
	   define definition@param ..string
	   define type@param addr \\} \}
    match param,definition@param
    \{ local opcode,origin
       size@param = 0
       if param eqtype 0 | param eqtype 0f | type@param eq addr
	size@param = 8
       else if param eqtype byte 0 | param eqtype byte 0f
	match prefix value,definition@param
	 \\{ if prefix eq qword
	      size@param = 8
	     else if prefix eq dword
	      size@param = 4
	     else if prefix eq word
	      size@param = 2
	     else if prefix eq byte
	      size@param = 1
	     end if \\}
       else if ~ param in <xmm0,xmm1,xmm2,xmm3,xmm4,xmm5,xmm6,xmm7,xmm8,xmm9,xmm10,xmm11,xmm12,xmm13,xmm14,xmm15>
	virtual
	 origin = $
	 inc param
	 load opcode byte from origin
	 if opcode = 67h
	  load opcode byte from origin+1
	 end if
	 if opcode and 0F8h = 48h
	  size@param = 8
	 else if opcode = 66h
	  size@param = 2
	 else if opcode = 0FFh
	  size@param = 4
	 else
	  size@param = 1
	 end if
	end virtual
       end if
       if counter = 1
	if type@param eq float
	 if ~ param eq xmm0
	  if size@param = 4
	   if param eqtype byte 0 | param eqtype byte 0f
	    mov eax,param
	    movd xmm0,eax
	   else
	    movd xmm0,param
	   end if
	  else
	   if param eqtype 0 | param eqtype 0f | param eqtype byte 0 | param eqtype byte 0f
	    mov rax,param
	    movq xmm0,rax
	   else
	    movq xmm0,param
	   end if
	  end if
	 end if
	else if type@param eq addr
	 if ~ param eq rcx
	  lea rcx,[param]
	 end if
	else if size@param = 8
	 if ~ param eq rcx
	  mov rcx,param
	 end if
	else if size@param = 4
	 if ~ param eq ecx
	  mov ecx,param
	 end if
	else if size@param = 2
	 if ~ param eq cx
	  mov cx,param
	 end if
	else if size@param = 1
	 if ~ param eq cl
	  mov cl,param
	 end if
	end if
       else if counter = 2
	if type@param eq float
	 if ~ param eq xmm1
	  if size@param = 4
	   if param eqtype byte 0 | param eqtype byte 0f
	    mov eax,param
	    movd xmm1,eax
	   else
	    movd xmm1,param
	   end if
	  else
	   if param eqtype 0 | param eqtype 0f | param eqtype byte 0 | param eqtype byte 0f
	    mov rax,param
	    movq xmm1,rax
	   else
	    movq xmm1,param
	   end if
	  end if
	 end if
	else if type@param eq addr
	 if ~ param eq rdx
	  lea rdx,[param]
	 end if
	else if size@param = 8
	 if ~ param eq rdx
	  mov rdx,param
	 end if
	else if size@param = 4
	 if ~ param eq edx
	  mov edx,param
	 end if
	else if size@param = 2
	 if ~ param eq dx
	  mov dx,param
	 end if
	else if size@param = 1
	 if ~ param eq dl
	  mov dl,param
	 end if
	end if
       else if counter = 3
	if type@param eq float
	 if ~ param eq xmm2
	  if size@param = 4
	   if param eqtype byte 0 | param eqtype byte 0f
	    mov eax,param
	    movd xmm2,eax
	   else
	    movd xmm2,param
	   end if
	  else
	   if param eqtype 0 | param eqtype 0f | param eqtype byte 0 | param eqtype byte 0f
	    mov rax,param
	    movq xmm2,rax
	   else
	    movq xmm2,param
	   end if
	  end if
	 end if
	else if type@param eq addr
	 if ~ param eq r8
	  lea r8,[param]
	 end if
	else if size@param = 8
	 if ~ param eq r8
	  mov r8,param
	 end if
	else if size@param = 4
	 if ~ param eq r8d
	  mov r8d,param
	 end if
	else if size@param = 2
	 if ~ param eq r8w
	  mov r8w,param
	 end if
	else if size@param = 1
	 if ~ param eq r8b
	  mov r8b,param
	 end if
	end if
       else if counter = 4
	if type@param eq float
	 if ~ param eq xmm3
	  if size@param = 4
	   if param eqtype byte 0 | param eqtype byte 0f
	    mov eax,param
	    movd xmm3,eax
	   else
	    movd xmm3,param
	   end if
	  else
	   if param eqtype 0 | param eqtype 0f | param eqtype byte 0 | param eqtype byte 0f
	    mov rax,param
	    movq xmm3,rax
	   else
	    movq xmm3,param
	   end if
	  end if
	 end if
	else if type@param eq addr
	 if ~ param eq r9
	  lea r9,[param]
	 end if
	else if size@param = 8
	 if ~ param eq r9
	  mov r9,param
	 end if
	else if size@param = 4
	 if ~ param eq r9d
	  mov r9d,param
	 end if
	else if size@param = 2
	 if ~ param eq r9w
	  mov r9w,param
	 end if
	else if size@param = 1
	 if ~ param eq r9b
	  mov r9b,param
	 end if
	end if
       else
	 if type@param eq addr
	  lea rax,[param]
	  mov [rsp+(counter-1)*8],rax
	 else if param eqtype [0] | param eqtype byte [0]
	  if size@param = 8
	   mov rax,param
	   mov [rsp+(counter-1)*8],rax
	  else if size@param = 4
	   mov eax,param
	   mov [rsp+(counter-1)*8],eax
	  else if size@param = 2
	   mov ax,param
	   mov [rsp+(counter-1)*8],ax
	  else
	   mov al,param
	   mov [rsp+(counter-1)*8],al
	  end if
	 else if size@param = 8
	  virtual
	   origin = $
	   mov rax,param
	   load opcode byte from origin+1
	  end virtual
	  if opcode = 0B8h
	   mov rax,param
	   mov [rsp+(counter-1)*8],rax
	  else
	   mov qword [rsp+(counter-1)*8],param
	  end if
	 else if param in <xmm0,xmm1,xmm2,xmm3,xmm4,xmm5,xmm6,xmm7,xmm8,xmm9,xmm10,xmm11,xmm12,xmm13,xmm14,xmm15>
	  movq [rsp+(counter-1)*8],param
	 else
	  mov [rsp+(counter-1)*8],param
	 end if
       end if \}
   common
    argscount = counter
    call proc
    if stackspace & ~defined current@frame
     add rsp,stackspace
    end if }

macro proc [args]
 { common
    match name params, args>
    \{ define@proc name,<params \} }

prologue@proc equ prologuedef

macro prologuedef procname,flag,parmbytes,localbytes,reglist
 { local loc,fill,counter
   loc = (localbytes+15) and (not 15)
   parmbase@proc equ rbp+16
   localbase@proc equ rbp-loc
   push rbp
   mov rbp,rsp
   if loc+fill
    sub rsp,loc+fill
   end if
   counter = 0
   irps reg, reglist \{ push reg
			counter = counter+1 \}
   fill = 8*(counter and 1) }

epilogue@proc equ epiloguedef

macro epiloguedef procname,flag,parmbytes,localbytes,reglist
 { irps reg, reglist \{ reverse pop reg \}
   leave
   retn }

close@proc equ

macro define@proc name,statement
 { local params,flag,regs,parmbytes,localbytes,current
   if used name
   name:
   match =stdcall args, statement \{ params equ args
				     flag = 11b \}
   match =stdcall, statement \{ params equ
				flag = 11b \}
   match =c args, statement \{ params equ args
			       flag = 10001b \}
   match =c, statement \{ params equ
			  flag = 10001b \}
   match =params, params \{ params equ statement
			    flag = 10000b \}
   match =uses reglist=,args, params \{ regs equ reglist
					params equ args \}
   match =regs =uses reglist, regs params \{ regs equ reglist
					     params equ \}
   match =regs, regs \{ regs equ \}
   match prologue:reglist, prologue@proc:<regs> \{ prologue name,flag,parmbytes,localbytes,reglist \}
   virtual at parmbase@proc
   match =,args, params \{ defargs@proc args \}
   match =args@proc args, args@proc params \{ defargs@proc args \}
   parmbytes = $-(parmbase@proc)
   end virtual
   name # % = parmbytes/8
   all@vars equ
   current = 0
   macro locals
   \{ virtual at localbase@proc+current
      macro label def \\{ match . type,def> \\\{ deflocal@proc .,label,<type \\\} \\}
      struc db [val] \\{ \common deflocal@proc .,db,val \\}
      struc du [val] \\{ \common deflocal@proc .,du,val \\}
      struc dw [val] \\{ \common deflocal@proc .,dw,val \\}
      struc dp [val] \\{ \common deflocal@proc .,dp,val \\}
      struc dd [val] \\{ \common deflocal@proc .,dd,val \\}
      struc dt [val] \\{ \common deflocal@proc .,dt,val \\}
      struc dq [val] \\{ \common deflocal@proc .,dq,val \\}
      struc rb cnt \\{ deflocal@proc .,rb cnt, \\}
      struc rw cnt \\{ deflocal@proc .,rw cnt, \\}
      struc rp cnt \\{ deflocal@proc .,rp cnt, \\}
      struc rd cnt \\{ deflocal@proc .,rd cnt, \\}
      struc rt cnt \\{ deflocal@proc .,rt cnt, \\}
      struc rq cnt \\{ deflocal@proc .,rq cnt, \\} \}
   macro endl
   \{ purge label
      restruc db,du,dw,dp,dd,dt,dq
      restruc rb,rw,rp,rd,rt,rq
      current = $-(localbase@proc)
      end virtual \}
   macro ret operand
   \{ match any, operand \\{ retn operand \\}
      match , operand \\{ match epilogue:reglist, epilogue@proc:<regs> \\\{ epilogue name,flag,parmbytes,localbytes,reglist \\\} \\} \}
   macro finish@proc
   \{ localbytes = current
      match close:reglist, close@proc:<regs> \\{ close name,flag,parmbytes,localbytes,reglist \\}
      end if \} }

macro defargs@proc [arg]
 { common
    if ~ arg eq
   forward
     local ..arg,current@arg
     match argname:type, arg
      \{ current@arg equ argname
	 label ..arg type
	 argname equ ..arg
	 if qqword eq type
	   dq ?,?,?,?
	 else if dqword eq type
	   dq ?,?
	 else if tbyte eq type
	   dq ?,?
	 else
	   dq ?
	 end if \}
     match =current@arg,current@arg
      \{ current@arg equ arg
	 arg equ ..arg
	 ..arg dq ? \}
   common
     args@proc equ current@arg
   forward
     restore current@arg
   common
    end if }

macro deflocal@proc name,def,[val] { name def val }

macro deflocal@proc name,def,[val]
 { common
    match vars, all@vars \{ all@vars equ all@vars, \}
    all@vars equ all@vars name
   forward
    local ..var,..tmp
    ..var def val
    match =?, val \{ ..tmp equ \}
    match any =?, val \{ ..tmp equ \}
    match any (=?), val \{ ..tmp equ \}
    match =label, def \{ ..tmp equ \}
    match tmp : value, ..tmp : val
     \{ tmp: end virtual
	initlocal@proc ..var,def value
	virtual at tmp\}
   common
    match first rest, ..var, \{ name equ first \} }

struc label type { label . type }

macro initlocal@proc name,def
 { virtual at name
    def
    size@initlocal = $ - name
   end virtual
   position@initlocal = 0
   while size@initlocal > position@initlocal
    virtual at name
     def
     if size@initlocal - position@initlocal < 2
      current@initlocal = 1
      load byte@initlocal byte from name+position@initlocal
     else if size@initlocal - position@initlocal < 4
      current@initlocal = 2
      load word@initlocal word from name+position@initlocal
     else if size@initlocal - position@initlocal < 8
      current@initlocal = 4
      load dword@initlocal dword from name+position@initlocal
     else
      load qword@initlocal dword from name+position@initlocal
      if ( qword@initlocal > 0 & qword@initlocal < 80000000h ) | ( qword@initlocal < 0 & qword@initlocal >= -80000000h )
       current@initlocal = 8
      else
       current@initlocal = 4
       dword@initlocal = qword@initlocal and 0FFFFFFFFh
      end if
     end if
    end virtual
    if current@initlocal = 1
     mov byte [name+position@initlocal],byte@initlocal
    else if current@initlocal = 2
     mov word [name+position@initlocal],word@initlocal
    else if current@initlocal = 4
     mov dword [name+position@initlocal],dword@initlocal
    else
     mov qword [name+position@initlocal],qword@initlocal
    end if
    position@initlocal = position@initlocal + current@initlocal
   end while }

macro endp
 { purge ret,locals,endl
   finish@proc
   purge finish@proc
   restore regs@proc
   match all,args@proc \{ restore all \}
   restore args@proc
   match all,all@vars \{ restore all \} }

macro local [var]
 { common
    locals
   forward done@local equ
    match varname[count]:vartype, var
    \{ match =BYTE, vartype \\{ varname rb count
				restore done@local \\}
       match =WORD, vartype \\{ varname rw count
				restore done@local \\}
       match =DWORD, vartype \\{ varname rd count
				 restore done@local \\}
       match =PWORD, vartype \\{ varname rp count
				 restore done@local \\}
       match =QWORD, vartype \\{ varname rq count
				 restore done@local \\}
       match =TBYTE, vartype \\{ varname rt count
				 restore done@local \\}
       match =DQWORD, vartype \\{ label varname dqword
				  rq count*2
				  restore done@local \\}
       match =QQWORD, vartype \\{ label varname qqword
				  rq count*4
				  restore done@local \\}
       match =XWORD, vartype \\{ label varname xword
				 rq count*2
				 restore done@local \\}
       match =YWORD, vartype \\{ label varname yword
				 rq count*4
				 restore done@local \\}
       match , done@local \\{ virtual
			       varname vartype
			      end virtual
			      rb count*sizeof.\#vartype
			      restore done@local \\} \}
    match :varname:vartype, done@local:var
    \{ match =BYTE, vartype \\{ varname db ?
				restore done@local \\}
       match =WORD, vartype \\{ varname dw ?
				restore done@local \\}
       match =DWORD, vartype \\{ varname dd ?
				 restore done@local \\}
       match =PWORD, vartype \\{ varname dp ?
				 restore done@local \\}
       match =QWORD, vartype \\{ varname dq ?
				 restore done@local \\}
       match =TBYTE, vartype \\{ varname dt ?
				 restore done@local \\}
       match =DQWORD, vartype \\{ label varname dqword
				  dq ?,?
				  restore done@local \\}
       match =QQWORD, vartype \\{ label varname qqword
				  dq ?,?,?,?
				  restore done@local \\}
       match =XWORD, vartype \\{ label varname xword
				 dq ?,?
				 restore done@local \\}
       match =YWORD, vartype \\{ label varname yword
				 dq ?,?,?,?
				 restore done@local \\}
       match , done@local \\{ varname vartype
			      restore done@local \\} \}
    match ,done@local
    \{ var
       restore done@local \}
   common
    endl }

macro frame
 { local size,current
   if size
    sub rsp,size
   end if
   current = 0
   current@frame equ current
   size@frame equ size }

macro endf
 { size@frame = current@frame
   if size@frame
    add rsp,size@frame
   end if
   restore size@frame,current@frame }

macro static_rsp_prologue procname,flag,parmbytes,localbytes,reglist
 { local counter,loc,frame,current 
   counter = 0 
   irps reg, reglist \{ push reg 
			counter = counter+1 \} 
   loc = (localbytes+7) and (not 7) 
   if frame & (counter+loc shr 3+1) and 1 
    loc = loc + 8 
   end if 
   framebytes@proc equ frame+loc 
   if framebytes@proc 
    sub rsp,framebytes@proc 
   end if 
   localbase@proc equ rsp+frame 
   regsbase@proc equ rsp+frame+loc 
   parmbase@proc equ rsp+frame+loc+counter*8+8 
   current = 0 
   current@frame equ current 
   size@frame equ frame } 

macro static_rsp_epilogue procname,flag,parmbytes,localbytes,reglist 
 { if framebytes@proc 
    add rsp,framebytes@proc 
   end if 
   irps reg, reglist \{ reverse pop reg \} 
   retn } 

macro static_rsp_close procname,flag,parmbytes,localbytes,reglist 
 { size@frame = current@frame 
   restore size@frame,current@frame }

stdcall fix fastcall
ccall fix fastcall
cinvoke fix invoke

;==============================================================
; MACRO/IMPORT64.INC  -  macros de seccion de imports (64-bit)
;==============================================================
; Macroinstructions for making import section (64-bit)

macro library [name,string]
 { common
    import.data:
   forward
    local _label
    if defined name#.redundant
     if ~ name#.redundant
      dd RVA name#.lookup,0,0,RVA _label,RVA name#.address
     end if
    end if
    name#.referred = 1
   common
    dd 0,0,0,0,0
   forward
    if defined name#.redundant
     if ~ name#.redundant
      _label db string,0
	     rb RVA $ and 1
     end if
    end if }

macro import name,[label,string]
 { common
    rb (- rva $) and 7
    if defined name#.referred
     name#.lookup:
   forward
     if used label
      if string eqtype ''
       local _label
       dq RVA _label
      else
       dq 8000000000000000h + string
      end if
     end if
   common
     if $ > name#.lookup
      name#.redundant = 0
      dq 0
     else
      name#.redundant = 1
     end if
     name#.address:
   forward
     if used label
      if string eqtype ''
       label dq RVA _label
      else
       label dq 8000000000000000h + string
      end if
     end if
   common
     if ~ name#.redundant
      dq 0
     end if
   forward
     if used label & string eqtype ''
     _label dw 0
	    db string,0
	    rb RVA $ and 1
     end if
   common
    end if }

macro api [name] {}

;==============================================================
; API/KERNEL32.INC  -  imports de KERNEL32.DLL (envueltos en macro)
;==============================================================

; Llama a esta macro desde la seccion '.idata':
; library kernel32,'KERNEL32'
; r3f_kernel32

macro r3f_kernel32 {
  ; KERNEL32 API calls
  
  import kernel32,\
         AddAtomA,'AddAtomA',\
         AddAtomW,'AddAtomW',\
         AddConsoleAliasA,'AddConsoleAliasA',\
         AddConsoleAliasW,'AddConsoleAliasW',\
         AllocConsole,'AllocConsole',\
         AreFileApisANSI,'AreFileApisANSI',\
         AssignProcessToJobObject,'AssignProcessToJobObject',\
         BackupRead,'BackupRead',\
         BackupSeek,'BackupSeek',\
         BackupWrite,'BackupWrite',\
         BaseAttachCompleteThunk,'BaseAttachCompleteThunk',\
         Beep,'Beep',\
         BeginUpdateResourceA,'BeginUpdateResourceA',\
         BeginUpdateResourceW,'BeginUpdateResourceW',\
         BuildCommDCBA,'BuildCommDCBA',\
         BuildCommDCBW,'BuildCommDCBW',\
         BuildCommDCBAndTimeoutsA,'BuildCommDCBAndTimeoutsA',\
         BuildCommDCBAndTimeoutsW,'BuildCommDCBAndTimeoutsW',\
         CallNamedPipeA,'CallNamedPipeA',\
         CallNamedPipeW,'CallNamedPipeW',\
         CancelIo,'CancelIo',\
         CancelWaitableTimer,'CancelWaitableTimer',\
         ClearCommBreak,'ClearCommBreak',\
         ClearCommError,'ClearCommError',\
         CloseConsoleHandle,'CloseConsoleHandle',\
         CloseHandle,'CloseHandle',\
         CloseProfileUserMapping,'CloseProfileUserMapping',\
         CmdBatNotification,'CmdBatNotification',\
         CommConfigDialogA,'CommConfigDialogA',\
         CommConfigDialogW,'CommConfigDialogW',\
         CompareFileTime,'CompareFileTime',\
         CompareStringA,'CompareStringA',\
         CompareStringW,'CompareStringW',\
         ConnectNamedPipe,'ConnectNamedPipe',\
         ConsoleMenuControl,'ConsoleMenuControl',\
         ContinueDebugEvent,'ContinueDebugEvent',\
         ConvertDefaultLocale,'ConvertDefaultLocale',\
         ConvertThreadToFiber,'ConvertThreadToFiber',\
         CopyFileA,'CopyFileA',\
         CopyFileW,'CopyFileW',\
         CopyFileExA,'CopyFileExA',\
         CopyFileExW,'CopyFileExW',\
         CreateConsoleScreenBuffer,'CreateConsoleScreenBuffer',\
         CreateDirectoryA,'CreateDirectoryA',\
         CreateDirectoryW,'CreateDirectoryW',\
         CreateDirectoryExA,'CreateDirectoryExA',\
         CreateDirectoryExW,'CreateDirectoryExW',\
         CreateEventA,'CreateEventA',\
         CreateEventW,'CreateEventW',\
         CreateFiber,'CreateFiber',\
         CreateFileA,'CreateFileA',\
         CreateFileW,'CreateFileW',\
         CreateFileMappingA,'CreateFileMappingA',\
         CreateFileMappingW,'CreateFileMappingW',\
         CreateHardLinkA,'CreateHardLinkA',\
         CreateHardLinkW,'CreateHardLinkW',\
         CreateIoCompletionPort,'CreateIoCompletionPort',\
         CreateJobObjectA,'CreateJobObjectA',\
         CreateJobObjectW,'CreateJobObjectW',\
         CreateMailslotA,'CreateMailslotA',\
         CreateMailslotW,'CreateMailslotW',\
         CreateMutexA,'CreateMutexA',\
         CreateMutexW,'CreateMutexW',\
         CreateNamedPipeA,'CreateNamedPipeA',\
         CreateNamedPipeW,'CreateNamedPipeW',\
         CreatePipe,'CreatePipe',\
         CreateProcessA,'CreateProcessA',\
         CreateProcessW,'CreateProcessW',\
         CreateRemoteThread,'CreateRemoteThread',\
         CreateSemaphoreA,'CreateSemaphoreA',\
         CreateSemaphoreW,'CreateSemaphoreW',\
         CreateTapePartition,'CreateTapePartition',\
         CreateThread,'CreateThread',\
         CreateToolhelp32Snapshot,'CreateToolhelp32Snapshot',\
         CreateVirtualBuffer,'CreateVirtualBuffer',\
         CreateWaitableTimerA,'CreateWaitableTimerA',\
         CreateWaitableTimerW,'CreateWaitableTimerW',\
         DebugActiveProcess,'DebugActiveProcess',\
         DebugBreak,'DebugBreak',\
         DefineDosDeviceA,'DefineDosDeviceA',\
         DefineDosDeviceW,'DefineDosDeviceW',\
         DeleteAtom,'DeleteAtom',\
         DeleteCriticalSection,'DeleteCriticalSection',\
         DeleteFiber,'DeleteFiber',\
         DeleteFileA,'DeleteFileA',\
         DeleteFileW,'DeleteFileW',\
         DeviceIoControl,'DeviceIoControl',\
         DisableThreadLibraryCalls,'DisableThreadLibraryCalls',\
         DisconnectNamedPipe,'DisconnectNamedPipe',\
         DosDateTimeToFileTime,'DosDateTimeToFileTime',\
         DuplicateConsoleHandle,'DuplicateConsoleHandle',\
         DuplicateHandle,'DuplicateHandle',\
         EndUpdateResourceA,'EndUpdateResourceA',\
         EndUpdateResourceW,'EndUpdateResourceW',\
         EnterCriticalSection,'EnterCriticalSection',\
         EnumCalendarInfoA,'EnumCalendarInfoA',\
         EnumCalendarInfoW,'EnumCalendarInfoW',\
         EnumCalendarInfoExA,'EnumCalendarInfoExA',\
         EnumCalendarInfoExW,'EnumCalendarInfoExW',\
         EnumDateFormatsA,'EnumDateFormatsA',\
         EnumDateFormatsW,'EnumDateFormatsW',\
         EnumDateFormatsExA,'EnumDateFormatsExA',\
         EnumDateFormatsExW,'EnumDateFormatsExW',\
         EnumResourceLanguagesA,'EnumResourceLanguagesA',\
         EnumResourceLanguagesW,'EnumResourceLanguagesW',\
         EnumResourceNamesA,'EnumResourceNamesA',\
         EnumResourceNamesW,'EnumResourceNamesW',\
         EnumResourceTypesA,'EnumResourceTypesA',\
         EnumResourceTypesW,'EnumResourceTypesW',\
         EnumSystemCodePagesA,'EnumSystemCodePagesA',\
         EnumSystemCodePagesW,'EnumSystemCodePagesW',\
         EnumSystemLocalesA,'EnumSystemLocalesA',\
         EnumSystemLocalesW,'EnumSystemLocalesW',\
         EnumTimeFormatsA,'EnumTimeFormatsA',\
         EnumTimeFormatsW,'EnumTimeFormatsW',\
         EraseTape,'EraseTape',\
         EscapeCommFunction,'EscapeCommFunction',\
         ExitProcess,'ExitProcess',\
         ExitThread,'ExitThread',\
         ExitVDM,'ExitVDM',\
         ExpandEnvironmentStringsA,'ExpandEnvironmentStringsA',\
         ExpandEnvironmentStringsW,'ExpandEnvironmentStringsW',\
         ExpungeConsoleCommandHistoryA,'ExpungeConsoleCommandHistoryA',\
         ExpungeConsoleCommandHistoryW,'ExpungeConsoleCommandHistoryW',\
         ExtendVirtualBuffer,'ExtendVirtualBuffer',\
         FatalAppExitA,'FatalAppExitA',\
         FatalAppExitW,'FatalAppExitW',\
         FatalExit,'FatalExit',\
         FileTimeToDosDateTime,'FileTimeToDosDateTime',\
         FileTimeToLocalFileTime,'FileTimeToLocalFileTime',\
         FileTimeToSystemTime,'FileTimeToSystemTime',\
         FillConsoleOutputAttribute,'FillConsoleOutputAttribute',\
         FillConsoleOutputCharacterA,'FillConsoleOutputCharacterA',\
         FillConsoleOutputCharacterW,'FillConsoleOutputCharacterW',\
         FindAtomA,'FindAtomA',\
         FindAtomW,'FindAtomW',\
         FindClose,'FindClose',\
         FindCloseChangeNotification,'FindCloseChangeNotification',\
         FindFirstChangeNotificationA,'FindFirstChangeNotificationA',\
         FindFirstChangeNotificationW,'FindFirstChangeNotificationW',\
         FindFirstFileA,'FindFirstFileA',\
         FindFirstFileW,'FindFirstFileW',\
         FindFirstFileExA,'FindFirstFileExA',\
         FindFirstFileExW,'FindFirstFileExW',\
         FindNextChangeNotification,'FindNextChangeNotification',\
         FindNextFileA,'FindNextFileA',\
         FindNextFileW,'FindNextFileW',\
         FindResourceA,'FindResourceA',\
         FindResourceW,'FindResourceW',\
         FindResourceExA,'FindResourceExA',\
         FindResourceExW,'FindResourceExW',\
         FlushConsoleInputBuffer,'FlushConsoleInputBuffer',\
         FlushFileBuffers,'FlushFileBuffers',\
         FlushInstructionCache,'FlushInstructionCache',\
         FlushViewOfFile,'FlushViewOfFile',\
         FoldStringA,'FoldStringA',\
         FoldStringW,'FoldStringW',\
         FormatMessageA,'FormatMessageA',\
         FormatMessageW,'FormatMessageW',\
         FreeConsole,'FreeConsole',\
         FreeEnvironmentStringsA,'FreeEnvironmentStringsA',\
         FreeEnvironmentStringsW,'FreeEnvironmentStringsW',\
         FreeLibrary,'FreeLibrary',\
         FreeLibraryAndExitThread,'FreeLibraryAndExitThread',\
         FreeResource,'FreeResource',\
         FreeVirtualBuffer,'FreeVirtualBuffer',\
         GenerateConsoleCtrlEvent,'GenerateConsoleCtrlEvent',\
         GetACP,'GetACP',\
         GetAtomNameA,'GetAtomNameA',\
         GetAtomNameW,'GetAtomNameW',\
         GetBinaryTypeA,'GetBinaryTypeA',\
         GetBinaryTypeW,'GetBinaryTypeW',\
         GetCPInfo,'GetCPInfo',\
         GetCPInfoExA,'GetCPInfoExA',\
         GetCPInfoExW,'GetCPInfoExW',\
         GetCommConfig,'GetCommConfig',\
         GetCommMask,'GetCommMask',\
         GetCommModemStatus,'GetCommModemStatus',\
         GetCommProperties,'GetCommProperties',\
         GetCommState,'GetCommState',\
         GetCommTimeouts,'GetCommTimeouts',\
         GetCommandLineA,'GetCommandLineA',\
         GetCommandLineW,'GetCommandLineW',\
         GetCompressedFileSizeA,'GetCompressedFileSizeA',\
         GetCompressedFileSizeW,'GetCompressedFileSizeW',\
         GetComputerNameA,'GetComputerNameA',\
         GetComputerNameW,'GetComputerNameW',\
         GetConsoleAliasA,'GetConsoleAliasA',\
         GetConsoleAliasW,'GetConsoleAliasW',\
         GetConsoleAliasExesA,'GetConsoleAliasExesA',\
         GetConsoleAliasExesW,'GetConsoleAliasExesW',\
         GetConsoleAliasExesLengthA,'GetConsoleAliasExesLengthA',\
         GetConsoleAliasExesLengthW,'GetConsoleAliasExesLengthW',\
         GetConsoleAliasesA,'GetConsoleAliasesA',\
         GetConsoleAliasesW,'GetConsoleAliasesW',\
         GetConsoleAliasesLengthA,'GetConsoleAliasesLengthA',\
         GetConsoleAliasesLengthW,'GetConsoleAliasesLengthW',\
         GetConsoleCP,'GetConsoleCP',\
         GetConsoleCommandHistoryA,'GetConsoleCommandHistoryA',\
         GetConsoleCommandHistoryW,'GetConsoleCommandHistoryW',\
         GetConsoleCommandHistoryLengthA,'GetConsoleCommandHistoryLengthA',\
         GetConsoleCommandHistoryLengthW,'GetConsoleCommandHistoryLengthW',\
         GetConsoleCursorInfo,'GetConsoleCursorInfo',\
         GetConsoleDisplayMode,'GetConsoleDisplayMode',\
         GetConsoleFontInfo,'GetConsoleFontInfo',\
         GetConsoleFontSize,'GetConsoleFontSize',\
         GetConsoleHardwareState,'GetConsoleHardwareState',\
         GetConsoleInputExeNameA,'GetConsoleInputExeNameA',\
         GetConsoleInputExeNameW,'GetConsoleInputExeNameW',\
         GetConsoleInputWaitHandle,'GetConsoleInputWaitHandle',\
         GetConsoleKeyboardLayoutNameA,'GetConsoleKeyboardLayoutNameA',\
         GetConsoleKeyboardLayoutNameW,'GetConsoleKeyboardLayoutNameW',\
         GetConsoleMode,'GetConsoleMode',\
         GetConsoleOutputCP,'GetConsoleOutputCP',\
         GetConsoleScreenBufferInfo,'GetConsoleScreenBufferInfo',\
         GetConsoleTitleA,'GetConsoleTitleA',\
         GetConsoleTitleW,'GetConsoleTitleW',\
         GetConsoleWindow,'GetConsoleWindow',\
         GetCurrencyFormatA,'GetCurrencyFormatA',\
         GetCurrencyFormatW,'GetCurrencyFormatW',\
         GetCurrentConsoleFont,'GetCurrentConsoleFont',\
         GetCurrentDirectoryA,'GetCurrentDirectoryA',\
         GetCurrentDirectoryW,'GetCurrentDirectoryW',\
         GetCurrentProcess,'GetCurrentProcess',\
         GetCurrentProcessId,'GetCurrentProcessId',\
         GetCurrentThread,'GetCurrentThread',\
         GetCurrentThreadId,'GetCurrentThreadId',\
         GetDateFormatA,'GetDateFormatA',\
         GetDateFormatW,'GetDateFormatW',\
         GetDefaultCommConfigA,'GetDefaultCommConfigA',\
         GetDefaultCommConfigW,'GetDefaultCommConfigW',\
         GetDevicePowerState,'GetDevicePowerState',\
         GetDiskFreeSpaceA,'GetDiskFreeSpaceA',\
         GetDiskFreeSpaceW,'GetDiskFreeSpaceW',\
         GetDiskFreeSpaceExA,'GetDiskFreeSpaceExA',\
         GetDiskFreeSpaceExW,'GetDiskFreeSpaceExW',\
         GetDriveTypeA,'GetDriveTypeA',\
         GetDriveTypeW,'GetDriveTypeW',\
         GetEnvironmentStringsA,'GetEnvironmentStringsA',\
         GetEnvironmentStringsW,'GetEnvironmentStringsW',\
         GetEnvironmentVariableA,'GetEnvironmentVariableA',\
         GetEnvironmentVariableW,'GetEnvironmentVariableW',\
         GetExitCodeProcess,'GetExitCodeProcess',\
         GetExitCodeThread,'GetExitCodeThread',\
         GetFileAttributesA,'GetFileAttributesA',\
         GetFileAttributesW,'GetFileAttributesW',\
         GetFileAttributesExA,'GetFileAttributesExA',\
         GetFileAttributesExW,'GetFileAttributesExW',\
         GetFileInformationByHandle,'GetFileInformationByHandle',\
         GetFileSize,'GetFileSize',\
         GetFileTime,'GetFileTime',\
         GetFileType,'GetFileType',\
         GetFullPathNameA,'GetFullPathNameA',\
         GetFullPathNameW,'GetFullPathNameW',\
         GetHandleInformation,'GetHandleInformation',\
         GetLargestConsoleWindowSize,'GetLargestConsoleWindowSize',\
         GetLastError,'GetLastError',\
         GetLocalTime,'GetLocalTime',\
         GetLocaleInfoA,'GetLocaleInfoA',\
         GetLocaleInfoW,'GetLocaleInfoW',\
         GetLogicalDriveStringsA,'GetLogicalDriveStringsA',\
         GetLogicalDriveStringsW,'GetLogicalDriveStringsW',\
         GetLogicalDrives,'GetLogicalDrives',\
         GetLongPathNameA,'GetLongPathNameA',\
         GetLongPathNameW,'GetLongPathNameW',\
         GetMailslotInfo,'GetMailslotInfo',\
         GetModuleFileNameA,'GetModuleFileNameA',\
         GetModuleFileNameW,'GetModuleFileNameW',\
         GetModuleHandleA,'GetModuleHandleA',\
         GetModuleHandleW,'GetModuleHandleW',\
         GetNamedPipeHandleStateA,'GetNamedPipeHandleStateA',\
         GetNamedPipeHandleStateW,'GetNamedPipeHandleStateW',\
         GetNamedPipeInfo,'GetNamedPipeInfo',\
         GetNextVDMCommand,'GetNextVDMCommand',\
         GetNumberFormatA,'GetNumberFormatA',\
         GetNumberFormatW,'GetNumberFormatW',\
         GetNumberOfConsoleFonts,'GetNumberOfConsoleFonts',\
         GetNumberOfConsoleInputEvents,'GetNumberOfConsoleInputEvents',\
         GetNumberOfConsoleMouseButtons,'GetNumberOfConsoleMouseButtons',\
         GetOEMCP,'GetOEMCP',\
         GetOverlappedResult,'GetOverlappedResult',\
         GetPriorityClass,'GetPriorityClass',\
         GetPrivateProfileIntA,'GetPrivateProfileIntA',\
         GetPrivateProfileIntW,'GetPrivateProfileIntW',\
         GetPrivateProfileSectionA,'GetPrivateProfileSectionA',\
         GetPrivateProfileSectionW,'GetPrivateProfileSectionW',\
         GetPrivateProfileSectionNamesA,'GetPrivateProfileSectionNamesA',\
         GetPrivateProfileSectionNamesW,'GetPrivateProfileSectionNamesW',\
         GetPrivateProfileStringA,'GetPrivateProfileStringA',\
         GetPrivateProfileStringW,'GetPrivateProfileStringW',\
         GetPrivateProfileStructA,'GetPrivateProfileStructA',\
         GetPrivateProfileStructW,'GetPrivateProfileStructW',\
         GetProcAddress,'GetProcAddress',\
         GetProcessAffinityMask,'GetProcessAffinityMask',\
         GetProcessHeap,'GetProcessHeap',\
         GetProcessHeaps,'GetProcessHeaps',\
         GetProcessPriorityBoost,'GetProcessPriorityBoost',\
         GetProcessShutdownParameters,'GetProcessShutdownParameters',\
         GetProcessTimes,'GetProcessTimes',\
         GetProcessVersion,'GetProcessVersion',\
         GetProcessWorkingSetSize,'GetProcessWorkingSetSize',\
         GetProfileIntA,'GetProfileIntA',\
         GetProfileIntW,'GetProfileIntW',\
         GetProfileSectionA,'GetProfileSectionA',\
         GetProfileSectionW,'GetProfileSectionW',\
         GetProfileStringA,'GetProfileStringA',\
         GetProfileStringW,'GetProfileStringW',\
         GetQueuedCompletionStatus,'GetQueuedCompletionStatus',\
         GetShortPathNameA,'GetShortPathNameA',\
         GetShortPathNameW,'GetShortPathNameW',\
         GetStartupInfoA,'GetStartupInfoA',\
         GetStartupInfoW,'GetStartupInfoW',\
         GetStdHandle,'GetStdHandle',\
         GetStringTypeA,'GetStringTypeA',\
         GetStringTypeW,'GetStringTypeW',\
         GetStringTypeExA,'GetStringTypeExA',\
         GetStringTypeExW,'GetStringTypeExW',\
         GetSystemDefaultLCID,'GetSystemDefaultLCID',\
         GetSystemDefaultLangID,'GetSystemDefaultLangID',\
         GetSystemDirectoryA,'GetSystemDirectoryA',\
         GetSystemDirectoryW,'GetSystemDirectoryW',\
         GetSystemInfo,'GetSystemInfo',\
         GetSystemPowerStatus,'GetSystemPowerStatus',\
         GetSystemTime,'GetSystemTime',\
         GetSystemTimeAdjustment,'GetSystemTimeAdjustment',\
         GetSystemTimeAsFileTime,'GetSystemTimeAsFileTime',\
         GetTapeParameters,'GetTapeParameters',\
         GetTapePosition,'GetTapePosition',\
         GetTapeStatus,'GetTapeStatus',\
         GetTempFileNameA,'GetTempFileNameA',\
         GetTempFileNameW,'GetTempFileNameW',\
         GetTempPathA,'GetTempPathA',\
         GetTempPathW,'GetTempPathW',\
         GetThreadContext,'GetThreadContext',\
         GetThreadLocale,'GetThreadLocale',\
         GetThreadPriority,'GetThreadPriority',\
         GetThreadPriorityBoost,'GetThreadPriorityBoost',\
         GetThreadSelectorEntry,'GetThreadSelectorEntry',\
         GetThreadTimes,'GetThreadTimes',\
         GetTickCount,'GetTickCount',\
         GetTimeFormatA,'GetTimeFormatA',\
         GetTimeFormatW,'GetTimeFormatW',\
         GetTimeZoneInformation,'GetTimeZoneInformation',\
         GetUserDefaultLCID,'GetUserDefaultLCID',\
         GetUserDefaultLangID,'GetUserDefaultLangID',\
         GetVDMCurrentDirectories,'GetVDMCurrentDirectories',\
         GetVersion,'GetVersion',\
         GetVersionExA,'GetVersionExA',\
         GetVersionExW,'GetVersionExW',\
         GetVolumeInformationA,'GetVolumeInformationA',\
         GetVolumeInformationW,'GetVolumeInformationW',\
         GetWindowsDirectoryA,'GetWindowsDirectoryA',\
         GetWindowsDirectoryW,'GetWindowsDirectoryW',\
         GlobalAddAtomA,'GlobalAddAtomA',\
         GlobalAddAtomW,'GlobalAddAtomW',\
         GlobalAlloc,'GlobalAlloc',\
         GlobalCompact,'GlobalCompact',\
         GlobalDeleteAtom,'GlobalDeleteAtom',\
         GlobalFindAtomA,'GlobalFindAtomA',\
         GlobalFindAtomW,'GlobalFindAtomW',\
         GlobalFix,'GlobalFix',\
         GlobalFlags,'GlobalFlags',\
         GlobalFree,'GlobalFree',\
         GlobalGetAtomNameA,'GlobalGetAtomNameA',\
         GlobalGetAtomNameW,'GlobalGetAtomNameW',\
         GlobalHandle,'GlobalHandle',\
         GlobalLock,'GlobalLock',\
         GlobalMemoryStatus,'GlobalMemoryStatus',\
         GlobalMemoryStatusVlm,'GlobalMemoryStatusVlm',\
         GlobalReAlloc,'GlobalReAlloc',\
         GlobalSize,'GlobalSize',\
         GlobalUnWire,'GlobalUnWire',\
         GlobalUnfix,'GlobalUnfix',\
         GlobalUnlock,'GlobalUnlock',\
         GlobalWire,'GlobalWire',\
         Heap32First,'Heap32First',\
         Heap32ListFirst,'Heap32ListFirst',\
         Heap32ListNext,'Heap32ListNext',\
         Heap32Next,'Heap32Next',\
         HeapAlloc,'HeapAlloc',\
         HeapCompact,'HeapCompact',\
         HeapCreate,'HeapCreate',\
         HeapDestroy,'HeapDestroy',\
         HeapExtend,'HeapExtend',\
         HeapFree,'HeapFree',\
         HeapLock,'HeapLock',\
         HeapReAlloc,'HeapReAlloc',\
         HeapSize,'HeapSize',\
         HeapSummary,'HeapSummary',\
         HeapUnlock,'HeapUnlock',\
         HeapUsage,'HeapUsage',\
         HeapValidate,'HeapValidate',\
         HeapWalk,'HeapWalk',\
         InitAtomTable,'InitAtomTable',\
         InitializeCriticalSection,'InitializeCriticalSection',\
         InitializeCriticalSectionAndSpinCount,'InitializeCriticalSectionAndSpinCount',\
         InterlockedCompareExchange,'InterlockedCompareExchange',\
         InterlockedDecrement,'InterlockedDecrement',\
         InterlockedExchange,'InterlockedExchange',\
         InterlockedExchangeAdd,'InterlockedExchangeAdd',\
         InterlockedIncrement,'InterlockedIncrement',\
         InvalidateConsoleDIBits,'InvalidateConsoleDIBits',\
         IsBadCodePtr,'IsBadCodePtr',\
         IsBadHugeReadPtr,'IsBadHugeReadPtr',\
         IsBadHugeWritePtr,'IsBadHugeWritePtr',\
         IsBadReadPtr,'IsBadReadPtr',\
         IsBadStringPtrA,'IsBadStringPtrA',\
         IsBadStringPtrW,'IsBadStringPtrW',\
         IsBadWritePtr,'IsBadWritePtr',\
         IsDBCSLeadByte,'IsDBCSLeadByte',\
         IsDBCSLeadByteEx,'IsDBCSLeadByteEx',\
         IsDebuggerPresent,'IsDebuggerPresent',\
         IsProcessorFeaturePresent,'IsProcessorFeaturePresent',\
         IsValidCodePage,'IsValidCodePage',\
         IsValidLocale,'IsValidLocale',\
         LCMapStringA,'LCMapStringA',\
         LCMapStringW,'LCMapStringW',\
         LeaveCriticalSection,'LeaveCriticalSection',\
         LoadLibraryA,'LoadLibraryA',\
         LoadLibraryW,'LoadLibraryW',\
         LoadLibraryExA,'LoadLibraryExA',\
         LoadLibraryExW,'LoadLibraryExW',\
         LoadModule,'LoadModule',\
         LoadResource,'LoadResource',\
         LocalAlloc,'LocalAlloc',\
         LocalCompact,'LocalCompact',\
         LocalFileTimeToFileTime,'LocalFileTimeToFileTime',\
         LocalFlags,'LocalFlags',\
         LocalFree,'LocalFree',\
         LocalHandle,'LocalHandle',\
         LocalLock,'LocalLock',\
         LocalReAlloc,'LocalReAlloc',\
         LocalShrink,'LocalShrink',\
         LocalSize,'LocalSize',\
         LocalUnlock,'LocalUnlock',\
         LockFile,'LockFile',\
         LockFileEx,'LockFileEx',\
         LockResource,'LockResource',\
         MapViewOfFile,'MapViewOfFile',\
         MapViewOfFileEx,'MapViewOfFileEx',\
         MapViewOfFileVlm,'MapViewOfFileVlm',\
         Module32First,'Module32First',\
         Module32Next,'Module32Next',\
         MoveFileA,'MoveFileA',\
         MoveFileW,'MoveFileW',\
         MoveFileExA,'MoveFileExA',\
         MoveFileExW,'MoveFileExW',\
         MoveFileWithProgressA,'MoveFileWithProgressA',\
         MoveFileWithProgressW,'MoveFileWithProgressW',\
         MulDiv,'MulDiv',\
         MultiByteToWideChar,'MultiByteToWideChar',\
         OpenEventA,'OpenEventA',\
         OpenEventW,'OpenEventW',\
         OpenFile,'OpenFile',\
         OpenFileMappingA,'OpenFileMappingA',\
         OpenFileMappingW,'OpenFileMappingW',\
         OpenJobObjectA,'OpenJobObjectA',\
         OpenJobObjectW,'OpenJobObjectW',\
         OpenMutexA,'OpenMutexA',\
         OpenMutexW,'OpenMutexW',\
         OpenProcess,'OpenProcess',\
         OpenProfileUserMapping,'OpenProfileUserMapping',\
         OpenSemaphoreA,'OpenSemaphoreA',\
         OpenSemaphoreW,'OpenSemaphoreW',\
         OpenWaitableTimerA,'OpenWaitableTimerA',\
         OpenWaitableTimerW,'OpenWaitableTimerW',\
         OutputDebugStringA,'OutputDebugStringA',\
         OutputDebugStringW,'OutputDebugStringW',\
         PeekConsoleInputA,'PeekConsoleInputA',\
         PeekConsoleInputW,'PeekConsoleInputW',\
         PeekNamedPipe,'PeekNamedPipe',\
         PostQueuedCompletionStatus,'PostQueuedCompletionStatus',\
         PrepareTape,'PrepareTape',\
         Process32First,'Process32First',\
         Process32Next,'Process32Next',\
         PulseEvent,'PulseEvent',\
         PurgeComm,'PurgeComm',\
         QueryDosDeviceA,'QueryDosDeviceA',\
         QueryDosDeviceW,'QueryDosDeviceW',\
         QueryInformationJobObject,'QueryInformationJobObject',\
         QueryPerformanceCounter,'QueryPerformanceCounter',\
         QueryPerformanceFrequency,'QueryPerformanceFrequency',\
         QueryWin31IniFilesMappedToRegistry,'QueryWin31IniFilesMappedToRegistry',\
         QueueUserAPC,'QueueUserAPC',\
         RaiseException,'RaiseException',\
         ReadConsoleA,'ReadConsoleA',\
         ReadConsoleW,'ReadConsoleW',\
         ReadConsoleInputA,'ReadConsoleInputA',\
         ReadConsoleInputW,'ReadConsoleInputW',\
         ReadConsoleInputExA,'ReadConsoleInputExA',\
         ReadConsoleInputExW,'ReadConsoleInputExW',\
         ReadConsoleOutputA,'ReadConsoleOutputA',\
         ReadConsoleOutputW,'ReadConsoleOutputW',\
         ReadConsoleOutputAttribute,'ReadConsoleOutputAttribute',\
         ReadConsoleOutputCharacterA,'ReadConsoleOutputCharacterA',\
         ReadConsoleOutputCharacterW,'ReadConsoleOutputCharacterW',\
         ReadFile,'ReadFile',\
         ReadFileEx,'ReadFileEx',\
         ReadFileScatter,'ReadFileScatter',\
         ReadFileVlm,'ReadFileVlm',\
         ReadProcessMemory,'ReadProcessMemory',\
         ReadProcessMemoryVlm,'ReadProcessMemoryVlm',\
         RegisterConsoleVDM,'RegisterConsoleVDM',\
         RegisterWaitForInputIdle,'RegisterWaitForInputIdle',\
         RegisterWowBaseHandlers,'RegisterWowBaseHandlers',\
         RegisterWowExec,'RegisterWowExec',\
         ReleaseMutex,'ReleaseMutex',\
         ReleaseSemaphore,'ReleaseSemaphore',\
         RemoveDirectoryA,'RemoveDirectoryA',\
         RemoveDirectoryW,'RemoveDirectoryW',\
         RequestWakeupLatency,'RequestWakeupLatency',\
         ResetEvent,'ResetEvent',\
         ResumeThread,'ResumeThread',\
         RtlFillMemory,'RtlFillMemory',\
         RtlMoveMemory,'RtlMoveMemory',\
         RtlUnwind,'RtlUnwind',\
         RtlZeroMemory,'RtlZeroMemory',\
         ScrollConsoleScreenBufferA,'ScrollConsoleScreenBufferA',\
         ScrollConsoleScreenBufferW,'ScrollConsoleScreenBufferW',\
         SearchPathA,'SearchPathA',\
         SearchPathW,'SearchPathW',\
         SetCommBreak,'SetCommBreak',\
         SetCommConfig,'SetCommConfig',\
         SetCommMask,'SetCommMask',\
         SetCommState,'SetCommState',\
         SetCommTimeouts,'SetCommTimeouts',\
         SetComputerNameA,'SetComputerNameA',\
         SetComputerNameW,'SetComputerNameW',\
         SetConsoleActiveScreenBuffer,'SetConsoleActiveScreenBuffer',\
         SetConsoleCP,'SetConsoleCP',\
         SetConsoleCommandHistoryMode,'SetConsoleCommandHistoryMode',\
         SetConsoleCtrlHandler,'SetConsoleCtrlHandler',\
         SetConsoleCursor,'SetConsoleCursor',\
         SetConsoleCursorInfo,'SetConsoleCursorInfo',\
         SetConsoleCursorPosition,'SetConsoleCursorPosition',\
         SetConsoleDisplayMode,'SetConsoleDisplayMode',\
         SetConsoleFont,'SetConsoleFont',\
         SetConsoleHardwareState,'SetConsoleHardwareState',\
         SetConsoleIcon,'SetConsoleIcon',\
         SetConsoleInputExeNameA,'SetConsoleInputExeNameA',\
         SetConsoleInputExeNameW,'SetConsoleInputExeNameW',\
         SetConsoleKeyShortcuts,'SetConsoleKeyShortcuts',\
         SetConsoleMaximumWindowSize,'SetConsoleMaximumWindowSize',\
         SetConsoleMenuClose,'SetConsoleMenuClose',\
         SetConsoleMode,'SetConsoleMode',\
         SetConsoleNumberOfCommandsA,'SetConsoleNumberOfCommandsA',\
         SetConsoleNumberOfCommandsW,'SetConsoleNumberOfCommandsW',\
         SetConsoleOutputCP,'SetConsoleOutputCP',\
         SetConsolePalette,'SetConsolePalette',\
         SetConsoleScreenBufferSize,'SetConsoleScreenBufferSize',\
         SetConsoleTextAttribute,'SetConsoleTextAttribute',\
         SetConsoleTitleA,'SetConsoleTitleA',\
         SetConsoleTitleW,'SetConsoleTitleW',\
         SetConsoleWindowInfo,'SetConsoleWindowInfo',\
         SetCriticalSectionSpinCount,'SetCriticalSectionSpinCount',\
         SetCurrentDirectoryA,'SetCurrentDirectoryA',\
         SetCurrentDirectoryW,'SetCurrentDirectoryW',\
         SetDefaultCommConfigA,'SetDefaultCommConfigA',\
         SetDefaultCommConfigW,'SetDefaultCommConfigW',\
         SetEndOfFile,'SetEndOfFile',\
         SetEnvironmentVariableA,'SetEnvironmentVariableA',\
         SetEnvironmentVariableW,'SetEnvironmentVariableW',\
         SetErrorMode,'SetErrorMode',\
         SetEvent,'SetEvent',\
         SetFileApisToANSI,'SetFileApisToANSI',\
         SetFileApisToOEM,'SetFileApisToOEM',\
         SetFileAttributesA,'SetFileAttributesA',\
         SetFileAttributesW,'SetFileAttributesW',\
         SetFilePointer,'SetFilePointer',\
         SetFileTime,'SetFileTime',\
         SetHandleCount,'SetHandleCount',\
         SetHandleInformation,'SetHandleInformation',\
         SetInformationJobObject,'SetInformationJobObject',\
         SetLastConsoleEventActive,'SetLastConsoleEventActive',\
         SetLastError,'SetLastError',\
         SetLocalTime,'SetLocalTime',\
         SetLocaleInfoA,'SetLocaleInfoA',\
         SetLocaleInfoW,'SetLocaleInfoW',\
         SetMailslotInfo,'SetMailslotInfo',\
         SetNamedPipeHandleState,'SetNamedPipeHandleState',\
         SetPriorityClass,'SetPriorityClass',\
         SetProcessAffinityMask,'SetProcessAffinityMask',\
         SetProcessPriorityBoost,'SetProcessPriorityBoost',\
         SetProcessShutdownParameters,'SetProcessShutdownParameters',\
         SetProcessWorkingSetSize,'SetProcessWorkingSetSize',\
         SetStdHandle,'SetStdHandle',\
         SetSystemPowerState,'SetSystemPowerState',\
         SetSystemTime,'SetSystemTime',\
         SetSystemTimeAdjustment,'SetSystemTimeAdjustment',\
         SetTapeParameters,'SetTapeParameters',\
         SetTapePosition,'SetTapePosition',\
         SetThreadAffinityMask,'SetThreadAffinityMask',\
         SetThreadContext,'SetThreadContext',\
         SetThreadExecutionState,'SetThreadExecutionState',\
         SetThreadIdealProcessor,'SetThreadIdealProcessor',\
         SetThreadLocale,'SetThreadLocale',\
         SetThreadPriority,'SetThreadPriority',\
         SetThreadPriorityBoost,'SetThreadPriorityBoost',\
         SetTimeZoneInformation,'SetTimeZoneInformation',\
         SetUnhandledExceptionFilter,'SetUnhandledExceptionFilter',\
         SetVDMCurrentDirectories,'SetVDMCurrentDirectories',\
         SetVolumeLabelA,'SetVolumeLabelA',\
         SetVolumeLabelW,'SetVolumeLabelW',\
         SetWaitableTimer,'SetWaitableTimer',\
         SetupComm,'SetupComm',\
         ShowConsoleCursor,'ShowConsoleCursor',\
         SignalObjectAndWait,'SignalObjectAndWait',\
         SizeofResource,'SizeofResource',\
         Sleep,'Sleep',\
         SleepEx,'SleepEx',\
         SuspendThread,'SuspendThread',\
         SwitchToFiber,'SwitchToFiber',\
         SwitchToThread,'SwitchToThread',\
         SystemTimeToFileTime,'SystemTimeToFileTime',\
         SystemTimeToTzSpecificLocalTime,'SystemTimeToTzSpecificLocalTime',\
         TerminateJobObject,'TerminateJobObject',\
         TerminateProcess,'TerminateProcess',\
         TerminateThread,'TerminateThread',\
         Thread32First,'Thread32First',\
         Thread32Next,'Thread32Next',\
         TlsAlloc,'TlsAlloc',\
         TlsFree,'TlsFree',\
         TlsGetValue,'TlsGetValue',\
         TlsSetValue,'TlsSetValue',\
         Toolhelp32ReadProcessMemory,'Toolhelp32ReadProcessMemory',\
         TransactNamedPipe,'TransactNamedPipe',\
         TransmitCommChar,'TransmitCommChar',\
         TrimVirtualBuffer,'TrimVirtualBuffer',\
         TryEnterCriticalSection,'TryEnterCriticalSection',\
         UnhandledExceptionFilter,'UnhandledExceptionFilter',\
         UnlockFile,'UnlockFile',\
         UnlockFileEx,'UnlockFileEx',\
         UnmapViewOfFile,'UnmapViewOfFile',\
         UnmapViewOfFileVlm,'UnmapViewOfFileVlm',\
         UpdateResourceA,'UpdateResourceA',\
         UpdateResourceW,'UpdateResourceW',\
         VDMConsoleOperation,'VDMConsoleOperation',\
         VDMOperationStarted,'VDMOperationStarted',\
         VerLanguageNameA,'VerLanguageNameA',\
         VerLanguageNameW,'VerLanguageNameW',\
         VerifyConsoleIoHandle,'VerifyConsoleIoHandle',\
         VirtualAlloc,'VirtualAlloc',\
         VirtualAllocEx,'VirtualAllocEx',\
         VirtualAllocVlm,'VirtualAllocVlm',\
         VirtualBufferExceptionHandler,'VirtualBufferExceptionHandler',\
         VirtualFree,'VirtualFree',\
         VirtualFreeEx,'VirtualFreeEx',\
         VirtualFreeVlm,'VirtualFreeVlm',\
         VirtualLock,'VirtualLock',\
         VirtualProtect,'VirtualProtect',\
         VirtualProtectEx,'VirtualProtectEx',\
         VirtualProtectVlm,'VirtualProtectVlm',\
         VirtualQuery,'VirtualQuery',\
         VirtualQueryEx,'VirtualQueryEx',\
         VirtualQueryVlm,'VirtualQueryVlm',\
         VirtualUnlock,'VirtualUnlock',\
         WaitCommEvent,'WaitCommEvent',\
         WaitForDebugEvent,'WaitForDebugEvent',\
         WaitForMultipleObjects,'WaitForMultipleObjects',\
         WaitForMultipleObjectsEx,'WaitForMultipleObjectsEx',\
         WaitForSingleObject,'WaitForSingleObject',\
         WaitForSingleObjectEx,'WaitForSingleObjectEx',\
         WaitNamedPipeA,'WaitNamedPipeA',\
         WaitNamedPipeW,'WaitNamedPipeW',\
         WideCharToMultiByte,'WideCharToMultiByte',\
         WinExec,'WinExec',\
         WriteConsoleA,'WriteConsoleA',\
         WriteConsoleW,'WriteConsoleW',\
         WriteConsoleInputA,'WriteConsoleInputA',\
         WriteConsoleInputW,'WriteConsoleInputW',\
         WriteConsoleInputVDMA,'WriteConsoleInputVDMA',\
         WriteConsoleInputVDMW,'WriteConsoleInputVDMW',\
         WriteConsoleOutputA,'WriteConsoleOutputA',\
         WriteConsoleOutputW,'WriteConsoleOutputW',\
         WriteConsoleOutputAttribute,'WriteConsoleOutputAttribute',\
         WriteConsoleOutputCharacterA,'WriteConsoleOutputCharacterA',\
         WriteConsoleOutputCharacterW,'WriteConsoleOutputCharacterW',\
         WriteFile,'WriteFile',\
         WriteFileEx,'WriteFileEx',\
         WriteFileGather,'WriteFileGather',\
         WriteFileVlm,'WriteFileVlm',\
         WritePrivateProfileSectionA,'WritePrivateProfileSectionA',\
         WritePrivateProfileSectionW,'WritePrivateProfileSectionW',\
         WritePrivateProfileStringA,'WritePrivateProfileStringA',\
         WritePrivateProfileStringW,'WritePrivateProfileStringW',\
         WritePrivateProfileStructA,'WritePrivateProfileStructA',\
         WritePrivateProfileStructW,'WritePrivateProfileStructW',\
         WriteProcessMemory,'WriteProcessMemory',\
         WriteProcessMemoryVlm,'WriteProcessMemoryVlm',\
         WriteProfileSectionA,'WriteProfileSectionA',\
         WriteProfileSectionW,'WriteProfileSectionW',\
         WriteProfileStringA,'WriteProfileStringA',\
         WriteProfileStringW,'WriteProfileStringW',\
         WriteTapemark,'WriteTapemark',\
         _hread,'_hread',\
         _hwrite,'_hwrite',\
         _lclose,'_lclose',\
         _lcreat,'_lcreat',\
         _llseek,'_llseek',\
         _lopen,'_lopen',\
         _lread,'_lread',\
         _lwrite,'_lwrite',\
         lstrcatA,'lstrcatA',\
         lstrcatW,'lstrcatW',\
         lstrcmpA,'lstrcmpA',\
         lstrcmpW,'lstrcmpW',\
         lstrcmpiA,'lstrcmpiA',\
         lstrcmpiW,'lstrcmpiW',\
         lstrcpyA,'lstrcpyA',\
         lstrcpyW,'lstrcpyW',\
         lstrcpynA,'lstrcpynA',\
         lstrcpynW,'lstrcpynW',\
         lstrlenA,'lstrlenA',\
         lstrlenW,'lstrlenW'
}

; (bloque 'api' original - macro vacia, solo documentacion)
; api AddAtom,\
;     AddConsoleAlias,\
;     BeginUpdateResource,\
;     BuildCommDCB,\
;     BuildCommDCBAndTimeouts,\
;     CallNamedPipe,\
;     CommConfigDialog,\
;     CompareString,\
;     CopyFile,\
;     CopyFileEx,\
;     CreateDirectory,\
;     CreateDirectoryEx,\
;     CreateEvent,\
;     CreateFile,\
;     CreateFileMapping,\
;     CreateHardLink,\
;     CreateJobObject,\
;     CreateMailslot,\
;     CreateMutex,\
;     CreateNamedPipe,\
;     CreateProcess,\
;     CreateSemaphore,\
;     CreateWaitableTimer,\
;     DefineDosDevice,\
;     DeleteFile,\
;     EndUpdateResource,\
;     EnumCalendarInfo,\
;     EnumCalendarInfoEx,\
;     EnumDateFormats,\
;     EnumDateFormatsEx,\
;     EnumResourceLanguages,\
;     EnumResourceNames,\
;     EnumResourceTypes,\
;     EnumSystemCodePages,\
;     EnumSystemLocales,\
;     EnumTimeFormats,\
;     ExpandEnvironmentStrings,\
;     ExpungeConsoleCommandHistory,\
;     FatalAppExit,\
;     FillConsoleOutputCharacter,\
;     FindAtom,\
;     FindFirstChangeNotification,\
;     FindFirstFile,\
;     FindFirstFileEx,\
;     FindNextFile,\
;     FindResource,\
;     FindResourceEx,\
;     FoldString,\
;     FormatMessage,\
;     FreeEnvironmentStrings,\
;     GetAtomName,\
;     GetBinaryType,\
;     GetCPInfoEx,\
;     GetCommandLine,\
;     GetCompressedFileSize,\
;     GetComputerName,\
;     GetConsoleAlias,\
;     GetConsoleAliasExes,\
;     GetConsoleAliasExesLength,\
;     GetConsoleAliases,\
;     GetConsoleAliasesLength,\
;     GetConsoleCommandHistory,\
;     GetConsoleCommandHistoryLength,\
;     GetConsoleInputExeName,\
;     GetConsoleKeyboardLayoutName,\
;     GetConsoleTitle,\
;     GetCurrencyFormat,\
;     GetCurrentDirectory,\
;     GetDateFormat,\
;     GetDefaultCommConfig,\
;     GetDiskFreeSpace,\
;     GetDiskFreeSpaceEx,\
;     GetDriveType,\
;     GetEnvironmentStrings,\
;     GetEnvironmentVariable,\
;     GetFileAttributes,\
;     GetFileAttributesEx,\
;     GetFullPathName,\
;     GetLocaleInfo,\
;     GetLogicalDriveStrings,\
;     GetLongPathName,\
;     GetModuleFileName,\
;     GetModuleHandle,\
;     GetNamedPipeHandleState,\
;     GetNumberFormat,\
;     GetPrivateProfileInt,\
;     GetPrivateProfileSection,\
;     GetPrivateProfileSectionNames,\
;     GetPrivateProfileString,\
;     GetPrivateProfileStruct,\
;     GetProfileInt,\
;     GetProfileSection,\
;     GetProfileString,\
;     GetShortPathName,\
;     GetStartupInfo,\
;     GetStringType,\
;     GetStringTypeEx,\
;     GetSystemDirectory,\
;     GetTempFileName,\
;     GetTempPath,\
;     GetTimeFormat,\
;     GetVersionEx,\
;     GetVolumeInformation,\
;     GetWindowsDirectory,\
;     GlobalAddAtom,\
;     GlobalFindAtom,\
;     GlobalGetAtomName,\
;     IsBadStringPtr,\
;     LCMapString,\
;     LoadLibrary,\
;     LoadLibraryEx,\
;     MoveFile,\
;     MoveFileEx,\
;     MoveFileWithProgress,\
;     OpenEvent,\
;     OpenFileMapping,\
;     OpenJobObject,\
;     OpenMutex,\
;     OpenSemaphore,\
;     OpenWaitableTimer,\
;     OutputDebugString,\
;     PeekConsoleInput,\
;     QueryDosDevice,\
;     ReadConsole,\
;     ReadConsoleInput,\
;     ReadConsoleInputEx,\
;     ReadConsoleOutput,\
;     ReadConsoleOutputCharacter,\
;     RemoveDirectory,\
;     ScrollConsoleScreenBuffer,\
;     SearchPath,\
;     SetComputerName,\
;     SetConsoleInputExeName,\
;     SetConsoleNumberOfCommands,\
;     SetConsoleTitle,\
;     SetCurrentDirectory,\
;     SetDefaultCommConfig,\
;     SetEnvironmentVariable,\
;     SetFileAttributes,\
;     SetLocaleInfo,\
;     SetVolumeLabel,\
;     UpdateResource,\
;     VerLanguageName,\
;     WaitNamedPipe,\
;     WriteConsole,\
;     WriteConsoleInput,\
;     WriteConsoleInputVDM,\
;     WriteConsoleOutput,\
;     WriteConsoleOutputCharacter,\
;     WritePrivateProfileSection,\
;     WritePrivateProfileString,\
;     WritePrivateProfileStruct,\
;     WriteProfileSection,\
;     WriteProfileString,\
;     lstrcat,\
;     lstrcmp,\
;     lstrcmpi,\
;     lstrcpy,\
;     lstrcpyn,\
;     lstrlen
