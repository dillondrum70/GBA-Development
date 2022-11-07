@echo off 

if not exist \Emu\VisualBoyAdvance\VisualBoyAdvance.exe goto EmulatorFail

set BuildFile=%1
set BuildPath=%2
if exist \utils\SelectedBuildFile.bat call \utils\SelectedBuildFile.bat 
cd %BuildPath%
if not %BuildPath:~0,1%==%CD:~0,1% goto InvalidPath

\Utils\Vasm\vasmarm_std_win32.exe %BuildFile% -m7tdmi -noialign -chklabels -nocase -Dvasm=1 -L \BldGBA\Listing.txt -DBuildGBA=1 -Fbin -o "\BldGBA\program.gba"

rem  -gbz80 -Fbin -o "z:\BldMSX\boot.bin" -L Z:\RelGB\Listing.txt
if not "%errorlevel%"=="0" goto Abandon

\Emu\VisualBoyAdvance\VisualBoyAdvance.exe \BldGBA\program.gba

goto Abandon
:InvalidPath
echo Error: ASM file must be on same drive as devtools 
echo File: %BuildPath%\%BuildFile% 
echo Devtools Drive: %CD:~0,1% 
goto Abandon
:EmulatorFail
echo Error: Can't find \Emu\VisualBoyAdvance\VisualBoyAdvance.exe
:Abandon
if "%3"=="nopause" exit
pause