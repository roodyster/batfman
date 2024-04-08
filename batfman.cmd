/* %0 >nul 2> nul & @goto :init

:: ===================================================================================================
:: BAT Simple File Manager 0.1 by Mihai Grigorescu, written in CMD script, compatible with x64 systems
:: ===================================================================================================

:main

   setlocal enableDelayedExpansion

   call :screen 120 43 1B
   call :panels 0 0 58 39
   call :menu

   set left_dir=%cd%
   set right_dir=%cd%

   call :getdir 
   call :refresh

   call :cursor show
   call :prompt

   :event

      %cin% > %keybuf%
      set /p key=<%keybuf%

      :: Navigation events

      if "%key%" == "UpArrow"   ( call :cursor up     & call :refresh & call :cursor show & call :prompt & goto event )
      if "%key%" == "DownArrow" ( call :cursor down   & call :refresh & call :cursor show & call :prompt & goto event )
      if "%key%" == "Home"      ( call :cursor top    & call :refresh & call :cursor show & call :prompt & goto event )
      if "%key%" == "End"       ( call :cursor bottom & call :refresh & call :cursor show & call :prompt & goto event )
      if "%key%" == "Tab"       ( call :cursor tab    & call :refresh & call :cursor show & call :prompt & goto event )

      :: Function key events
 
      if "%key%" == "F3"        ( if "%cursor_panel%" == "left"  call :exec    "%~p0batfview.cmd" "!left[%cursor_left%]!"    & set buf=& goto event
                                  if "%cursor_panel%" == "right" call :exec    "%~p0batfview.cmd" "!right[%cursor_right%]!"  & set buf=& goto event )
      if "%key%" == "F4"        ( if "%cursor_panel%" == "left"  call :exec    "Edit" "!left[%cursor_left%]!"                & set buf=& goto event
                                  if "%cursor_panel%" == "right" call :exec    "Edit" "!right[%cursor_right%]!"              & set buf=& goto event )
      if "%key%" == "F5"        ( if "%cursor_panel%" == "left"  call :filedlg "Copy" "!left[%cursor_left%]!" "%right_dir%"  & set buf=& goto event
                                  if "%cursor_panel%" == "right" call :filedlg "Copy" "!right[%cursor_right%]!" "%left_dir%" & set buf=& goto event )
      if "%key%" == "F6"        ( if "%cursor_panel%" == "left"  call :filedlg "Move" "!left[%cursor_left%]!" "%right_dir%"  & set buf=& goto event
                                  if "%cursor_panel%" == "right" call :filedlg "Move" "!right[%cursor_right%]!" "%left_dir%" & set buf=& goto event )

      if "%key%" == "F7"        ( call :dirdlg  "!%cursor_panel%_dir!" & goto event )

      if "%key%" == "F8"        ( echo F8 & goto event )
      if "%key%" == "F10"       ( cls & color 0B & exit )

      :: Execution events

      if "%key%" == "Enter"     ( if "%cursor_panel%" == "left"  call :exec "!left[%cursor_left%]!"   & set buf=& goto event
                                  if "%cursor_panel%" == "right" call :exec "!right[%cursor_right%]!" & set buf=& goto event )

      :: Typing events

      if "%key%" == "Escape"    ( set "buf="       & call :prompt & goto event )
      if "%key%" == "Spacebar"  ( set "buf=%buf% " & call :prompt & goto event )
      if "%key%" == "Backspace" ( set "buf=%buf%" & call :prompt & goto event )

      set buf=%buf%%key%
      call :prompt

   if not "%key%" == "F10" goto event

goto :eof

:: Panel Functions

:cursor

   if "%1"=="up"      if not "!cursor_%cursor_panel%!" == "0" set /a cursor_%cursor_panel%=cursor_%cursor_panel%-1
   if "%1"=="down"    if not "!cursor_%cursor_panel%!" == "!%cursor_panel%[count]!" set /a cursor_%cursor_panel%=cursor_%cursor_panel%+1
   if "%1"=="top"     set /a cursor_%cursor_panel%=0
   if "%1"=="bottom"  set cursor_%cursor_panel%=!%cursor_panel%[count]!

   if "%1"=="tab" (
      if "%cursor_panel%" == "left" set cursor_panel=right
      if "%cursor_panel%" == "right" set cursor_panel=left
   )

   if "%1"=="show" (
      call :gotoxy !offset_%cursor_panel%! !cursor_%cursor_panel%!+1
      if "%cursor_panel%" == "left" call :showbar "!left[%cursor_left%]!"
      if "%cursor_panel%" == "right" call :showbar "!right[%cursor_right%]!"
   )    

exit %ret%

:prompt
   call :gotoxy 0 41
   cd !%cursor_panel%_dir!
   %cout%=!%cursor_panel%_dir!^>%buf%%clr%
exit %ret%

:getdir 

   for /l %%N in (1 1 39) do (    
      call set "left[%%N]=ÿ"
      call set "right[%%N]=ÿ"
   )

   call :getfiles left %left_dir%
   call :getfiles right %right_dir%

   for /l %%N in (1 1 38) do (    
      call :linebuffer %%N "!left[%%N]!" "!right[%%N]!"
   )

exit %ret%

:getfiles 

   cd %2
   set panel=%1   

   :: Load the file path in array
   set "%1[0]=.."
   for /f "tokens=1* delims=:" %%A in ('dir /b /o:gn^|findstr /n "^"') do (
     set "%1[%%A]=%%B"
     set "%1[count]=%%A"
   )

exit %ret%

:refresh

   %gotoxy% 1 1
   echo .. %tab%%tab%%next%..								       
   for /l %%N in (1 1 38) do echo !line[%%N]!

exit %ret%

:panels

   set line=
   set space=

   set next=					  
   set next=%next% ºº

   set cursor_left=0
   set cursor_right=0
   set cursor_panel=left

   set /a offset_left=1
   set /a offset_right=%3+3

   for /l %%x in (1,1,%3) do (
      call set "line=%%line%%Í"
      call set "space=%%space%% "
   )

   call :gotoxy %1 %2 

   %cout%=É%line%»É%line%»

   for /l %%y in (1,1,%4) do (
      %cout%=º%space%ºº%space%º
   )

   %cout%=È%line%¼È%line%¼

   call :gotoxy %1+1 %2+1

exit %ret%

:showbar

   set bar=
   set str=%~1
   call :strlen str len
   set /a fill=53-%len%
   set bar=!tabs[%fill%]!
   %cin% color DarkCyan Black "%~1 %bar% ÿ ÿ"

exit %ret%

:linebuffer

   set str1=%~2
   call :strlen str1 len1
   set /a fill1=58-%len1%
   set tab1=!tabs[%fill1%]!

   set str2=%~3
   call :strlen str2 len2
   set /a fill2=58-%len2%
   set tab2=!tabs[%fill2%]!

   set line[%1]=º%~2%tab1%ºº%~3%tab2%

exit %ret%

:menu
   call :gotoxy 0 42
   set items=1
   for %%i in ("ÿÿÿÿÿÿ" "ÿÿÿÿÿÿ" "Viewÿÿ" "Editÿÿ" "Copyÿÿ" "Moveÿÿ" "Mkdirÿ" "Delete" "ÿÿÿÿÿÿ" "Quitÿÿÿ") do (
      call :menuitem %%i 
   )
exit %ret%

:menuitem
 %cin% color Black Gray "ÿ%items%"
::   %cout%=ÿ%items%
   %cin% color DarkCyan Black "%1ÿ"
   set /a items+=1
exit %ret%

:: Execution Functions

:exec
   if "%buf%" == "" (       
      cd %1 > nul 2> nul && call :exec_cd && exit %ret%
      set buf=%1
   )
   if not "%buf%" == "" (
      cls & color 0F
      call :prompt
      echo.
      if "%buf%" == "F10" exit
      call %buf% %2 %3 %4
      pause
      set buf=
      call "set buf="
      cls & color 1B
      call :panels 0 0 58 39
      call :menu
      call :refresh
      call :cursor show
      call :prompt
   )
exit %ret%

:exec_cd

   set key=

   if "%cursor_panel%" == "left"  set left_dir=%cd%& set cursor_left=0
   if "%cursor_panel%" == "right" set right_dir=%cd%& set cursor_right=0

   call :getdir 
   call :gotoxy 0 1 
   call :refresh
   call :cursor show
   call :prompt
   goto event

exit %ret%

:: Dialog Windows

:windlg [title, prompt, dir]

   set spacer=      
   set dlgspace=
   set dlgsingle=
   set dlgdouble=

   set "title= %~1 "

   for /l %%x in (1,1,31) do (
      call set "dlgspace=%%dlgspace%% "
      call set "dlgsingle=%%dlgsingle%%Ä"
      call set "dlgdouble=%%dlgdouble%%Í"
   )

   call :gotoxy 23 14 & %cin% color Gray Black "ÿÿÿ%dlgspace%%spacer%%dlgspace%ÿÿÿ" 
   call :gotoxy 23 15 & %cin% color Gray Black "ÿÿÉ%dlgdouble%%title%%dlgdouble%»ÿÿ"
   call :gotoxy 23 16 & %cin% color Gray Black "ÿÿº%dlgspace%%spacer%%dlgspace%ºÿÿ" 
   call :gotoxy 23 17 & %cin% color Gray Black "ÿÿº%dlgspace%%spacer%%dlgspace%ºÿÿ" 
   call :gotoxy 23 18 & %cin% color Gray Black "ÿÿÇ%dlgsingle%ÄÄÄÄÄÄ%dlgsingle%¶ÿÿ"
   call :gotoxy 23 19 & %cin% color Gray Black "ÿÿºÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ[ %~1 ]    "
   set _dlgbutcancel= & %cin% color Gray Black "ÿÿ[ Cancel ]ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿºÿÿ"
   call :gotoxy 23 20 & %cin% color Gray Black "ÿÿÈ%dlgdouble%ÍÍÍÍÍÍ%dlgdouble%¼ÿÿ"
   call :gotoxy 23 21 & %cin% color Gray Black "ÿÿÿ%dlgspace%%spacer%%dlgspace%ÿÿÿ" 
   call :gotoxy 27 17 & %cin% color DarkCyan Black "%dlgspace%ÿÿÿÿ%dlgspace%"

   call :gotoxy 27 16 & %cin% color Gray Black "%~2"
   call :gotoxy 27 17 & %cin% color DarkCyan Black "%~3"

exit %ret%

:filedlg
   call :windlg "%1" "%1 '%2' to :" "%3"

   set dlg_cmd=%~1
   set dlg_file=%2
   set dlg_dir=%3

   :readkey
      set key=
      %cin% > %keybuf%
      set /p key=<%keybuf%
      if "%key%" == "Enter" %dlg_cmd% %dlg_file% %dlg_dir% > nul & goto closedlg
      if "%key%" == "Escape" goto closedlg
   goto readkey

   :closedlg
      call :getdir
      call :refresh
      call :cursor show
      call :prompt

exit %ret%

:dirdlg
   call :windlg "MDir" "Create the directory :" "ÿ"
   set dirname=
   SET /P dirname=
   if not "%dirname%" == "" md %dirname%
   call :getdir
   call :refresh
   call :cursor show
   call :prompt
exit %ret%

:: Display Functions

:screen 

   for /l %%i in (1,1,58) do (
      call set "tabs=%%tabs%% "
      call set "tabs[%%i]=%%tabs%%"
   )
   for /l %%i in (1,1,15) do call set "clr=%%clr%%ÿ"
   for /l %%i in (1,1,15) do call set "clr=%%clr%%"
   %cin% %1 %2 %3
   mode con: cp select=437 > nul
   set /a cols=%1, lines=%2
   mode con: cols=%cols% lines=%lines% 
   set gotoxy=%cin%
   set bgcolor=%3
   set tab=	
   cls & color %bgcolor%

exit %ret%

:gotoxy
  set /a "posx=%1"
  set /a "posy=%2"
  %gotoxy% %posx% %posy%
exit %ret%

:strlen
  setlocal EnableDelayedExpansion
  set "s=#!%~1!"
  set "len=0"
  for %%N in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
    if "!s:~%%N,1!" neq "" (
      set /a "len+=%%N"
      set "s=!s:~%%N!"
    )
  )
  endlocal&set %~2=%len%
exit %ret%

:: System Functions

:init

   @echo off 
   set "csc="
   set "ret=/b"
   set "cin=%temp%\console.exe"
   set "cout=<NUL set /p"
   set "keybuf=%temp%\console.tmp"

   pushd "%SystemRoot%\Microsoft.NET\Framework"
   for /f "tokens=* delims=" %%i in ('dir /b /o:n "v*"') do (
      dir /a-d /b "%%~fi\csc.exe" >nul 2>&1 && set "csc="%%~fi\csc.exe""
   )
   popd

   if not defined csc (
      echo This application requires Microsoft .NET Framework
      goto :eof
   )

   echo CMD Manager 0.1 (beta) - loading, please wait ...
   %csc% /nologo /optimize /warnaserror /nowin32manifest /debug- /target:exe /out:"%cin%" "%~f0"

goto :main

/* DotNET Function, ANSI.SYS replacement compatible with x64 systems */

using System;
using System.Runtime.InteropServices;

class ConsoleWindow {
   public static void Main (string[] args) { 
      ConsoleKeyInfo cki;
      if (args.Length == 0) { cki = Console.ReadKey (true); Console.WriteLine (cki.Key.ToString ()); } else
      if (args.Length == 2) { Console.SetCursorPosition (Int32.Parse(args[0]), Int32.Parse(args[1])); } else
      if (args.Length == 3) { Console.SetWindowSize (Int32.Parse(args[0]), Int32.Parse(args[1])); }
      if (args.Length == 4) { Console.BackgroundColor = (ConsoleColor) Enum.Parse(typeof(ConsoleColor),args[1]); 
                              Console.ForegroundColor = (ConsoleColor) Enum.Parse(typeof(ConsoleColor),args[2]); 
                              Console.Write (args[3]); Console.ResetColor(); }
   }
}
