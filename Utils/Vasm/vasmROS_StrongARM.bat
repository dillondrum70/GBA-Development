@echo off 
cd %2
\Utils\Vasm\vasmarm_std_win32.exe %1 -mstrongarm -opt-ldrpc -opt-adr -chklabels -nocase -Dvasm=1  -L \BldROS\Listing.txt -DBuildROS=1 -Fbin -o "\BldROS\prog,ff8"
if not "%errorlevel%"=="0" goto Abandon

copy "\BldROS\prog,ff8" "\Emu\RPCEmu\hostfs\prog,ff8"
cd \Emu\RPCEmu\
\Emu\RPCEmu\RPCEmu-Interpreter.exe 
exit
:Abandon
if "%3"=="nopause" exit
pause
