:: Build automation for Windows systems: KWADs
::
:: To get started, copy batconfig.example.bat as batconfig.bat and fill in the appropriate paths.
::
:: Requires:
:: * PowerShell v5.0 or higher (for compressing zip files from the command-line)
:: * KWAD Builder
::
:: This performs the following operations
:: * Build .anim files from .anim.d folders within anim\
:: * Build .kwad files from the anim\ and gui\ directories.
::

setlocal
@ECHO off

if not exist %~dp0\batconfig.bat (
  @ECHO ERROR: Could not find %~dp0\batconfig.bat
  @ECHO Copy batconfig.example.bat and set the paths to match your system
  PAUSE
  exit /b 1
)
call %~dp0\batconfig.bat


FOR /R "%~dp0\anims" /D %%I IN (*.anim.d) DO (
  :: Calculate the path names for the .anim and a temporary .zip, because Compress-Archive checks the file extension.
  :: Then compress to a .zip. Then, finally rename the .zip to the .anim.
  powershell -NoProfile "$animfile='%%~dI%%~pI%%~nI'; $zipfile=[System.IO.Path]::ChangeExtension($animfile, 'zip'); Compress-Archive -Path %%I\* -DestinationPath $zipfile; Move-Item -Force $zipfile $animfile"
  if ERRORLEVEL 1 PAUSE
  if ERRORLEVEL 1 exit /b 1
)

%kwadbuilderexe% -i "%~dp0\build.lua" -o "%~dp0\out"

PAUSE
:: if ERRORLEVEL 1 PAUSE
if ERRORLEVEL 1 exit /b 1
