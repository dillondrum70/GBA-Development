@echo off

if exist \utils\SelectedBuildFile.bat goto Deletefile
echo ************************************************************************************************************
echo *** Selected Path: %2 
echo *** Selected file: %1 
echo ************************************************************************************************************
echo.

echo set BuildFile=%1>\utils\SelectedBuildFile.bat 
echo set BuildPath=%2>>\utils\SelectedBuildFile.bat 
echo echo ************************************************************************************************************>>\utils\SelectedBuildFile.bat 
echo echo *** Selected Path: %%BuildPath%%>>\utils\SelectedBuildFile.bat 
echo echo *** Selected file: %%BuildFile%%>>\utils\SelectedBuildFile.bat 
echo echo ************************************************************************************************************>>\utils\SelectedBuildFile.bat 

exit


:Deletefile
del \utils\SelectedBuildFile.bat 
echo File selection is now removed, current file will be built
exit