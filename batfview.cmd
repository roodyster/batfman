@echo off & setlocal DisableDelayedExpansion

if "%~1"=="" (goto :eof) else set "file=%~1"

set /a lines=43, cols=120

mode %cols%,%lines% & cls
color 1B

set /a lines-=1, start=1, end=start+lines-1, from=0, len=cols-1

for /f %%a in ('"prompt $H&for %%b in (1) do rem"') do set "BS=%%a"
for /f %%a in ('copy /Z "%~f0" nul') do set "CR=%%a"

del "%tmp%\%file%.tmp"
set "Slice=call :slice %file% !start! !end! "%tmp%\%file%.tmp" !from! %len%"
set "Clear=set /p "=%BS%                                                       !CR!" <nul"

setlocal EnableDelayedExpansion

%Slice%

:loop_move

  set /p "=[ Lines: %start% to %end% ]!CR!" <nul

  %temp%\console.exe > %temp%\console.tmp
  set /p key=<%temp%\console.tmp

  if "%key%" == "UpArrow"    ( if !start! gtr 1 ( set /a end-=1, start-=1 & cls & %Slice% ) )
  if "%key%" == "DownArrow"  ( %Clear% & set /a end+=1, start+=1 & call :slice %file% !end! !end! "%tmp%\%file%.tmp" !from! %len%)
  if "%key%" == "LeftArrow"  ( set /a from+=1 & cls& %Slice% )
  if "%key%" == "RightArrow" ( if !from! gtr 0 ( set /a from-=1 & cls & %Slice% ) )
  if "%key%" == "Escape"     ( goto :eof )

goto :loop_move

goto :eof



rem serve il BACKSPACE
for /f %%a in ('"prompt $H&for %%b in (1) do rem"') do set "BS=%%a"


:loop_getkey

    call :getkey
    if "%key%"==" " (set /p "=_%BS% " < nul) else set /p "=%key%" < nul

goto :loop_getkey


goto :eof

:getkey
  for /F "eol=1delims=" %%x in ('xcopy /WQL "%~f0" NUL:\*') do (set "key=%%x" &  set "key=!key:~-1!")
  if not defined key echo NO INPUT!
goto :eof


:slice
@Echo Off
:: Usage: slice.cmd filename [<int>start] [<int>end] [file_tmp] [from] [len]
:: Note: if end is 0 then prints until the end of file
:: Add trick for bigger files

Setlocal EnableExtensions DisableDelayedExpansion
Set /A b=%~2+0,e=%~3+0,#=0 2>Nul
If %b% Leq 0 Set "b=1"
If %e% Leq 0 Set "e=2147483647"

if not "%~4"=="" (set "tmp_file=%~4") else set "tmp_file=%tmp%\slice_%random%_%random%.dat"

if "%~4"=="" (
  Findstr /n "^" "%~dpf1">"%tmp_file%"
  rem Find /n /v "" "%~dpf1">"%tmp_file%" &:: più lento di findstr  
) else if not exist "%~4" Findstr /n "^" "%~dpf1">"%tmp_file%"


rem con il 'type %tmp_file%' ci mette troppo. Lo stesso come findstr.
rem For /f "delims=" %%$ In ('Findstr /n "^" "%~dpf1"') Do (

set "skip="
if %b% gtr 1 set /A "skip=%b%-1"
if defined skip (
  set /a #+=%skip%
  set "skip=skip=%skip%"
) 

For /f "%skip% delims=" %%$ In (%tmp_file%) Do (
  Set /A #+=1 & Set "$=%%$"
  Setlocal EnableDelayedExpansion
    rem Set "$=!$:*:=!"
    If !#! Geq %b% Echo(!$:~%5,%6!
    If !#! Geq %e% (Endlocal & Goto End)
    rem if !random! geq 32700 title !#!
  Endlocal
)

:End
Endlocal & Goto:Eof