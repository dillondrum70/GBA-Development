@echo off 

if not exist \Emu\RPCEmu\RPCEmu-Interpreter.exe goto EmulatorFail
if not exist \Emu\RPCEmu\roms\*.rom goto RomFail

set BuildFile=%1
set BuildPath=%2
if exist \utils\SelectedBuildFile.bat call \utils\SelectedBuildFile.bat 
cd %BuildPath%
if not %BuildPath:~0,1%==%CD:~0,1% goto InvalidPath

\Utils\Vasm\vasmarm_std_win32.exe %BuildFile% -a2 -opt-ldrpc -opt-adr -chklabels -nocase -DCpuArm2=1 -Dvasm=1  -L \BldROS\Listing.txt -DBuildROS=1 -Fbin -o "\BldROS\prog,ff8"
if not "%errorlevel%"=="0" goto Abandon

copy "\BldROS\prog,ff8" "\Emu\RPCEmu\hostfs\prog,ff8"
cd \Emu\RPCEmu\
\Emu\RPCEmu\RPCEmu-Interpreter.exe 

goto Abandon
:InvalidPath
echo Error: ASM file must be on same drive as devtools 
echo File: %BuildPath%\%BuildFile% 
echo Devtools Drive: %CD:~0,1% 
goto Abandon
:EmulatorFail
echo Error: Can't find \Emu\RPCEmu\RPCEmu-Interpreter.exe
goto Abandon
:RomFail
echo.
echo ******************************************************************
echo *** For licensing reasons I cannot provide you with a rom file ***
echo ******************************************************************
echo.
echo Please put a usable rom in \Emu\RPCEmu\roms
echo. 
echo Tested with riscos-3.71.rom (4,194,304 bytes) (look for riscos3_71.zip)
goto Abandon
:Abandon
if "%3"=="nopause" exit
pause
