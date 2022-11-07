@echo --------------------------------------------------------------------------
@echo 	Keith's Z80 Dev Toolkit - Please see the Readme for instructions!
@echo --------------------------------------------------------------------------
@echo 				Z Drive Mount tool V1.0
@echo. 			
@echo 		This tool mounts the Z80 tools to virtual drive Z
@echo 	If the Z drive is in use, X or Y will be used as an alternative
@echo. 
@echo --------------------------------------------------------------------------
@echo off

set driveletter=M
if exist %driveletter%:\Zdrive.bat goto showmsg
if not exist %driveletter%:\nul goto start

set driveletter=N
if exist %driveletter%:\Zdrive.bat goto showmsg
if not exist %driveletter%:\nul goto start

set driveletter=O
if exist %driveletter%:\Zdrive.bat goto showmsg
if not exist %driveletter%:\nul goto start

Echo Drives M, N and O are in use already - could not map drive
pause
goto end

:start
subst %driveletter%: .
:showmsg

echo Development tools have been mounted as virtual drive %driveletter%:
pause
start %driveletter%:\
:end