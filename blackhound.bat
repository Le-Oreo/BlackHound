@echo off
rem ==========================================================================
rem  BLACKHOUND - OSINT hunting rig.  Single-file launcher.
rem  Author: Oreo
rem  Theme: set THEME below to  crimson | amber | cyan
rem  Catalogue of 2711 open-source OSINT tools. R <n> clones the repo into
rem  tools\<id>, installs its deps once (per-tool venv), and runs it here.
rem  It runs third-party code from GitHub - only run tools you trust.
rem  Tool list is embedded at the very bottom (lines starting with :::).
rem ==========================================================================
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
set "PYTHONUTF8=1"
set "PYTHONIOENCODING=utf-8"
title BLACKHOUND
set "SELF=%~f0"
set "HERE=%~dp0"
rem ---- settings: defaults, then load saved values from blackhound.cfg ----
set "THEME=crimson"
set "AUTODEL=1"
set "AUTOHELP=1"
set "WARN=1"
call :loadcfg

for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "R=%ESC%[0m"
set "P=%ESC%[38;5;252m"
set "M=%ESC%[38;5;244m"
set "T=%ESC%[38;5;242m"
set "F=%ESC%[38;5;237m"
set "OK=%ESC%[38;5;78m"
set "NO=%ESC%[38;5;203m"
call :applytheme

rem ---- non-interactive hooks for testing ----
if /I "%~1"=="--draw" ( call :draw & exit /b 0 )
if /I "%~1"=="--find" ( call :dofind "%~2" & exit /b 0 )
if /I "%~1"=="--card" ( call :docard "%~2" & exit /b 0 )
if /I "%~1"=="--lane" ( call :lane %~2 & exit /b 0 )
if /I "%~1"=="--run" ( call :getcard "%~2" FOUND & set "NOPROMPT=1" & set "TARGS=%~3" & if defined FOUND call :engine & exit /b 0 )

rem ================= boot splash =================
cls
echo(%F%╭─ %A%●%P% BLACKHOUND %F%────────────────────────────────────────────────────────%M% v1.0 %F%─╮%R%
echo(                %A%                   ⢠⡟⡄    ⢠⢻⡄%R%
echo(                %A%                   ⣿⣧⣿⡄  ⢠⣿⢸⣿⡄%R%
echo(                %A%                  ⢸⣿⡇⣿⣿⣿⣼⣿⣿⢸⣿⡇%R%
echo(                %A%                  ⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧%R%
echo(                %A%                  ⠘⣿⣿⢻⣧⢻⣿⢠⡟⢻⣿⠃%R%
echo(                %A%          ⣤⣼⡄      ⠛⣿⣿⡄⣿⣿⢣⣼⣿⡟       ⣧⣤%R%
echo(                %A%      ⢠⣼⣿⣿⣿⣿⢠⣤⣧⣧   ⢸⢸⣿⣿⣿⣿⣼⣿⡟⣤   ⣼⣧⣤⡄⣿⣿⣿⣧⣧⡄%R%
echo(                %A%    ⣤⣿⣿⣿⣿⣿⡟⠛⣿⣿⣿⣿⣿⡄⢠⣿⣧⢻⣿⣿⣿⣿⣿⢣⣿⡇ ⣼⣿⣿⣿⣿⠛⣿⣿⣿⣿⣿⣿⣤%R%
echo(                %A%   ⢸⣤⠛⣼⣿⣿⣿⠛⠛⣿⣿⣿⣿⣿⢣⣿⣿⣿⡇⣿⣿⣿⣿⢣⣿⣿⣿⡜⣿⣿⣿⣿⣿⠛⠛⣿⣿⣿⣿⠛⡄⡇%R%
echo(                %A%   ⣼⣤⣿⣿⣿⣿⣿⣿⡇⣿⣿⣿⣿⣧⢸⣿⣿⣿⣿⣼⣿⣿⣧⣼⣿⣿⣿⡇⣼⣿⣿⣿⣿⢸⣿⣿⣿⣿⣿⣧⣤⣧%R%
echo(                %A% ⢠⣿⣿⣿⣿⣿⣿⣿⣿⠛⢸⣿⣿⣿⣿⣿⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢸⣿⣿⣿⣿⣧⢻⣿⣿⣿⣿⣿⣿⣿⣿⡄%R%
echo(                %A%⣤⣿⣿⠛⢻⣧⣿⣿⡟⢻⣿⣼⣿⣿⣿⣿⣿⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿ ⣿⣿⣿⣿⣿⣿⣼⣿⣿⣿⣿⣼⡟⠛⣿⣿⣤%R%
echo(                %A%⠛⠛⣤⡟⠛       ⠛⣿⣿⣿⣿⣿⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⣼⣿⣿⣿⣿⡟⠃    ⠘⠘⠛⢻⣤⢻⠛%R%
echo(                %A%             ⣿⣿⣿⣿⣿⣧⢻⣿⣿⣿⣿⣿⣿⣿⣿⠛⣼⣿⣿⣿⣿⣿⡇%R%
echo(                %A%              ⢻⣿⣿⣿⣿⣧⡜⣿⣿⣿⣿⣿⣿⠛⣼⣿⣿⣿⣿⡟%R%
echo(                %A%                ⠛⢻⣿⣿⣿⡜⢻⣿⣿⣿⢣⣿⣿⣿⡟⠛%R%
echo(                %A%                    ⠛⠛⢣⠛⠛⣼⠛⠛⠃%R%
echo(
echo(                    %A%██████%AD%╗ %A%██%AD%╗      %A%█████%AD%╗  %A%██████%AD%╗%A%██%AD%╗  %A%██%AD%╗  %R%
echo(                    %A%██%AD%╔══%A%██%AD%╗%A%██%AD%║     %A%██%AD%╔══%A%██%AD%╗%A%██%AD%╔════╝%A%██%AD%║ %A%██%AD%╔╝  %R%
echo(                    %A%██████%AD%╔╝%A%██%AD%║     %A%███████%AD%║%A%██%AD%║     %A%█████%AD%╔╝   %R%
echo(                    %A%██%AD%╔══%A%██%AD%╗%A%██%AD%║     %A%██%AD%╔══%A%██%AD%║%A%██%AD%║     %A%██%AD%╔═%A%██%AD%╗   %R%
echo(                    %A%██████%AD%╔╝%A%███████%AD%╗%A%██%AD%║  %A%██%AD%║╚%A%██████%AD%╗%A%██%AD%║  %A%██%AD%╗  %R%
echo(                    %AD%╚═════╝ %AD%╚══════╝╚═╝  %AD%╚═╝ %AD%╚═════╝╚═╝  %AD%╚═╝  %R%
echo(                  %A%██%AD%╗  %A%██%AD%╗ %A%██████%AD%╗ %A%██%AD%╗   %A%██%AD%╗%A%███%AD%╗   %A%██%AD%╗%A%██████%AD%╗ %R%
echo(                  %A%██%AD%║  %A%██%AD%║%A%██%AD%╔═══%A%██%AD%╗%A%██%AD%║   %A%██%AD%║%A%████%AD%╗  %A%██%AD%║%A%██%AD%╔══%A%██%AD%╗%R%
echo(                  %A%███████%AD%║%A%██%AD%║   %A%██%AD%║%A%██%AD%║   %A%██%AD%║%A%██%AD%╔%A%██%AD%╗ %A%██%AD%║%A%██%AD%║  %A%██%AD%║%R%
echo(                  %A%██%AD%╔══%A%██%AD%║%A%██%AD%║   %A%██%AD%║%A%██%AD%║   %A%██%AD%║%A%██%AD%║╚%A%██%AD%╗%A%██%AD%║%A%██%AD%║  %A%██%AD%║%R%
echo(                  %A%██%AD%║  %A%██%AD%║╚%A%██████%AD%╔╝╚%A%██████%AD%╔╝%A%██%AD%║ %AD%╚%A%████%AD%║%A%██████%AD%╔╝%R%
echo(                  %AD%╚═╝  %AD%╚═╝ %AD%╚═════╝  %AD%╚═════╝ %AD%╚═╝  %AD%╚═══╝╚═════╝ %R%
echo(%T%                       O S I N T   H U N T I N G   R I G%R%
echo(%F%                                  ‹ by OREO ›%R%
echo(
call :sleep 350
call :bootline "acquiring catalogue"
call :bootline "2711 tools indexed"
call :bootline "24 vectors online"
call :sleep 350

:menu
cls
call :draw
echo(
set "CMD="
set /p "CMD=  %A%blackhound%M%>%R% "
if not defined CMD goto menu
for /f "tokens=1*" %%a in ("!CMD!") do ( set "V=%%a" & set "ARG=%%b" )
if /I "!V!"=="q" goto end
if /I "!V!"=="quit" goto end
if /I "!V!"=="d" goto doctor
if /I "!V!"=="c" goto settings
if /I "!V!"=="settings" goto settings
if /I "!V!"=="s" goto search
if /I "!V!"=="search" goto search
if /I "!V!"=="r" goto runtool
if /I "!V!"=="run" goto runtool
if /I "!V!"=="i" goto info
if /I "!V!"=="info" goto info
if /I "!V!"=="h" goto helpscreen
if /I "!V!"=="?" goto helpscreen
echo !V!| findstr /r "^[0-9][0-9]*$" >nul && goto pick
echo   %NO%unknown command "!CMD!"%R%   %M%type H for help%R%
call :sleep 900
goto menu

:draw
echo(%F%╭─ %A%●%P% BLACKHOUND %F%────────────────────────────────────────────────────────%M% v1.0 %F%─╮%R%
echo(  %A%            ⣸⢃  ⢠⣧                %A%██████%AD%╗ %A%██%AD%╗      %A%█████%AD%╗  %A%██████%AD%╗%A%██%AD%╗  %A%██%AD%╗  %R%
echo(  %A%            ⣿⢻⣤⣠⣿⣿⡇               %A%██%AD%╔══%A%██%AD%╗%A%██%AD%║     %A%██%AD%╔══%A%██%AD%╗%A%██%AD%╔════╝%A%██%AD%║ %A%██%AD%╔╝  %R%
echo(  %A%            ⣿⣿⢿⡿⢿⣿⡇               %A%██████%AD%╔╝%A%██%AD%║     %A%███████%AD%║%A%██%AD%║     %A%█████%AD%╔╝   %R%
echo(  %A%      ⢀⣆    ⢿⣿⢱⡷⣱⣿    ⢰⣀          %A%██%AD%╔══%A%██%AD%╗%A%██%AD%║     %A%██%AD%╔══%A%██%AD%║%A%██%AD%║     %A%██%AD%╔═%A%██%AD%╗   %R%
echo(  %A%   ⢀⣶⣿⣿⣇⣾⣶⣀ ⣀⢿⣿⣷⣿⢱⡀⢀⣾⣶⣾⣿⣿⣷⣀       %A%██████%AD%╔╝%A%███████%AD%╗%A%██%AD%║  %A%██%AD%║╚%A%██████%AD%╗%A%██%AD%║  %A%██%AD%╗  %R%
echo(  %A%  ⢨⡝⣿⣿⡗⢺⣿⣿⣿⣴⣿⡏⣿⣿⣯⣿⣧⢺⣿⣿⡗⠚⣿⣿⡟⢱      %AD%╚═════╝ %AD%╚══════╝╚═╝  %AD%╚═╝ %AD%╚═════╝╚═╝  %AD%╚═╝  %R%
echo(  %A% ⢠⣶⣾⣿⣿⣿⣼⣿⣿⣷⣿⣿⣿⣿⣿⣾⣿⣿⣼⣿⣿⣧⢻⣿⣿⣷⣾⡄   %A%██%AD%╗  %A%██%AD%╗ %A%██████%AD%╗ %A%██%AD%╗   %A%██%AD%╗%A%███%AD%╗   %A%██%AD%╗%A%██████%AD%╗ %R%
echo(  %A%⣤⣿⠛⣯⣿⡟⣷⣿⣿⣿⣿⢻⣿⣿⣿⣿⣿⣿⡏⢹⣿⣿⣿⣿⣿⣿⣿⠛⣿⣦  %A%██%AD%║  %A%██%AD%║%A%██%AD%╔═══%A%██%AD%╗%A%██%AD%║   %A%██%AD%║%A%████%AD%╗  %A%██%AD%║%A%██%AD%╔══%A%██%AD%╗%R%
echo(  %A%⠉⠑⠋⠁   ⠈⣿⣿⣿⣯⢿⣿⣿⣿⣿⡿⣳⣿⣿⣿⡏   ⠉⠉⠊⠋  %A%███████%AD%║%A%██%AD%║   %A%██%AD%║%A%██%AD%║   %A%██%AD%║%A%██%AD%╔%A%██%AD%╗ %A%██%AD%║%A%██%AD%║  %A%██%AD%║%R%
echo(  %A%        ⠙⠿⣿⣿⣮⣻⣿⣿⡿⣣⣿⣿⠿⠋⠁         %A%██%AD%╔══%A%██%AD%║%A%██%AD%║   %A%██%AD%║%A%██%AD%║   %A%██%AD%║%A%██%AD%║╚%A%██%AD%╗%A%██%AD%║%A%██%AD%║  %A%██%AD%║%R%
echo(  %A%          ⠉⠛⠻⠯⡻⢟⡷⠿⠛⠉            %A%██%AD%║  %A%██%AD%║╚%A%██████%AD%╔╝╚%A%██████%AD%╔╝%A%██%AD%║ %AD%╚%A%████%AD%║%A%██████%AD%╔╝%R%
echo(  %A%                                %AD%╚═╝  %AD%╚═╝ %AD%╚═════╝  %AD%╚═════╝ %AD%╚═╝  %AD%╚═══╝╚═════╝ %R%
echo(%T%                       O S I N T   H U N T I N G   R I G%R%
echo(%F%                                  ‹ by OREO ›%R%
echo(
echo(                  %OK%●%M% 2717 tools    %OK%●%M% 24 lanes    %A%●%M% engine idle%R%
echo(
echo(%F%── %M%LANES%F% ───────────────────────────────────────────────────────────────────────%R%
echo(
echo(   %A%01 %P%General OSINT              %M% 357     %A%13 %P%Geo / Maps                 %M%  94%R%
echo(   %A%02 %P%Domain / DNS               %M% 303     %A%14 %P%Web Scan                   %M%  84%R%
echo(   %A%03 %P%Recon                      %M% 232     %A%15 %P%Dorking                    %M%  55%R%
echo(   %A%04 %P%Username                   %M% 223     %A%16 %P%Secrets                    %M%  55%R%
echo(   %A%05 %P%Network                    %M% 208     %A%17 %P%Link Graph                 %M%  52%R%
echo(   %A%06 %P%IP / Geo                   %M% 183     %A%18 %P%Forensics                  %M%  36%R%
echo(   %A%07 %P%Social Media               %M% 139     %A%19 %P%Dark Web                   %M%  34%R%
echo(   %A%08 %P%Metadata                   %M% 136     %A%20 %P%Wireless                   %M%  23%R%
echo(   %A%09 %P%Email                      %M% 121     %A%21 %P%Breach                     %M%  22%R%
echo(   %A%10 %P%Phone                      %M% 119     %A%22 %P%People ID                  %M%  12%R%
echo(   %A%11 %P%Threat Intel               %M% 116     %A%23 %P%Crypto                     %M%   8%R%
echo(   %A%12 %P%Web Extract                %M% 100     %A%24 %P%Corporate                  %M%   5%R%
echo(
echo(%F%── %M%CONSOLE%F% ─────────────────────────────────────────────────────────────────────%R%
echo(
echo(   %A%1-24%M% lane    %A%S%M% search    %A%R%M% run    %A%I%M% info    %A%D%M% doctor    %A%C%M% settings    %A%Q%M% quit%R%
echo(
echo(%F%╰──────────────────────────────────────────────────────────────────────────────╯%R%
exit /b 0

:pick
if !V! GEQ 1 if !V! LEQ 24 (
  cls
  call :lane !V!
  echo(
  echo   %M%R ^<n^> run    I ^<n^> info    Enter menu%R%
  set "SUB=" & set /p "SUB=  %A%blackhound%M%>%R% "
  if defined SUB ( for /f "tokens=1*" %%a in ("!SUB!") do ( set "V=%%a" & set "ARG=%%b" ) )
  if /I "!V!"=="r" goto runtool
  if /I "!V!"=="i" goto info
  goto menu
)
goto menu

:lane
rem  %1 = category number; list its tools from embedded DB, one row per line
call :catname %1
call :brand
echo   %P%!CATNAME!%R%   %M%!CATCOUNT! tools    %A%R ^<n^>%M% run    %A%I ^<n^>%M% info%R%
echo   %F%────────────────────────────────────────────────────────────────────────────%R%
echo(
for /f "usebackq tokens=1,3,4,8 delims=	" %%a in (`findstr /b ":::" "%SELF%"`) do (
  if "%%b"=="!CATNAME_FULL!" (
    set "NN=%%a" & set "NN=!NN:~3!" & set "NN=    !NN!" & set "NN=!NN:~-4!"
    echo     %A%!NN!%R%  %P%%%c%R%
    echo          %M%%%d%R%
  )
)
exit /b 0

:search
if not defined ARG set /p "ARG=  %M%search:%R% "
if not defined ARG goto menu
cls
call :brand
call :dofind "!ARG!"
echo(
pause
goto menu

:dofind
echo   %F%╭─ %P%SEARCH%M%  %~1%R%
echo(
set "HIT=0"
for /f "usebackq tokens=1,4,8 delims=	" %%a in (`findstr /b ":::" "%SELF%" ^| findstr /i /c:"%~1"`) do (
  set "NN=%%a" & set "NN=!NN:~3!"
  if !HIT! LSS 40 ( echo   %A%!NN!%R%  %P%%%b%R% & echo        %M%%%c%R% )
  set /a HIT+=1
)
echo(
if !HIT!==0 ( echo   %NO%no matches%R% ) else ( echo   %M%!HIT! hits - run one with %A%R ^<n^>%R% )
exit /b 0

:info
if not defined ARG set /p "ARG=  %M%tool number:%R% "
if not defined ARG goto menu
cls
call :brand
call :docard "!ARG!"
echo(
pause
goto menu

:runtool
if not defined ARG set /p "ARG=  %M%tool number:%R% "
if not defined ARG goto menu
call :getcard "!ARG!" FOUND
if not defined FOUND ( echo   %NO%no tool number !ARG!%R% & call :sleep 900 & goto menu )
call :engine
goto menu

:getcard
set "CARD_REPO=" & set "CARD_ID=" & set "CARD_NAME=" & set "CARD_LANG=" & set "CARD_DESC=" & set "FOUNDIT="
if not "%~2"=="" set "%~2="
for /f "usebackq tokens=1-8 delims=	" %%a in (`findstr /b /c:":::%~1	" "%SELF%"`) do (
  set "FOUNDIT=1" & set "CARD_REPO=%%g" & set "CARD_ID=%%b" & set "CARD_NAME=%%d" & set "CARD_LANG=%%f" & set "CARD_DESC=%%h"
)
if defined FOUNDIT if not "%~2"=="" set "%~2=1"
exit /b 0

rem ===================== run engine =====================
rem  Clones the repo into tools\<id>, installs deps once, runs it here.
:engine
set "TID=!CARD_ID!"
set "SRC=%HERE%tools\!TID!"
set "VENV=!SRC!\.venv"
call :trace "engine: start TID=!TID! SRC=!SRC!"
set "AUTH=!CARD_REPO!"
set "AUTH=!AUTH:https://github.com/=!"
set "AUTH=!AUTH:http://github.com/=!"
for /f "tokens=1 delims=/" %%a in ("!AUTH!") do set "AUTH=%%a"
cls
call :brand
echo(
echo   %F%╭─ %A%▶ LAUNCH   %P%!CARD_NAME!%R%
echo   %F%│%R%   %M%author  %R% %P%!AUTH!%R%
echo   %F%│%R%   %M%repo    %R% !CARD_REPO!
echo   %F%│%R%   %M%language%R% !CARD_LANG!
echo   %F%│%R%   %M%about   %R% !CARD_DESC!
echo   %F%├──────────────────────────────────────────────────────────────────────────%R%
if /I "!CARD_LANG!"=="web" (
  echo   %A%   [*]%M% opening !CARD_NAME! in your browser ...%R%
  echo   %M%       !CARD_REPO!%R%
  start "" "!CARD_REPO!"
  echo   %OK%   [+]%M% opened - upload the photo on the site to run the search%R%
  echo   %F%   ╰──────────────────────────────────────────────────────────────────────────%R%
  echo(
  echo   %M%   press any key to go back to the menu%R%
  pause >nul
  exit /b 0
)
call :needgit
if errorlevel 1 ( echo   %F%   ╰──%R% & exit /b 1 )
if not exist "!SRC!\.git" (
  if "!WARN!"=="1" if not defined WARNED ( echo   %NO%   [x] runs third-party code from GitHub - only run tools you trust%R% & set "WARNED=1" )
  echo   %A%   [*]%M% downloading !CARD_NAME! ...%R%
  git clone --depth 1 --quiet "!CARD_REPO!" "!SRC!" 2>nul
  if errorlevel 1 ( echo   %NO%   [x] download failed%R% & exit /b 1 )
  echo   %OK%   [+]%M% downloaded%R%
) else ( echo   %OK%   [+]%M% already downloaded%R% )
call :trace "engine: clone/skip done"
if not exist "!SRC!\.bh_state" (
  echo   %A%   [*]%M% installing dependencies ...%R%
  call :install
  if errorlevel 1 ( echo   %NO%   [x] some dependencies failed to build - the tool may not fully work%R% ) else ( echo   %OK%   [+]%M% ready%R% )
) else ( echo   %OK%   [+]%M% ready%R% )
call :trace "engine: install done, pre-launch"
echo   %F%╰──────────────────────────────────────────────────────────────────────────%R%
if defined NOPROMPT ( call :launch !TARGS! & call :finishtool & exit /b 0 )
echo   %M%   what   !CARD_DESC!%R%
echo(
if "!AUTOHELP!"=="1" (
  echo   %F%── COMMANDS ─ how to use this tool ────────────────────────────────────────%R%
  call :showcommands
)
echo(
echo   %M%   now type arguments to run it,  or   %A%?%M% help again    %A%r%M% readme    %A%q%M% finish%R%
echo   %M%   some tools have no flags and just start when you press Enter.%R%
:askargs
echo(
set "TARGS="
set /p "TARGS=  %A%!CARD_NAME!%M% args >%R% "
if /I "!TARGS!"=="q" ( call :finishtool & exit /b 0 )
if /I "!TARGS!"=="quit" ( call :finishtool & exit /b 0 )
if /I "!TARGS!"=="r" ( call :showreadme & goto askargs )
if /I "!TARGS!"=="readme" ( call :showreadme & goto askargs )
if "!TARGS!"=="?" ( call :showcommands & goto askargs )
if /I "!TARGS!"=="help" ( call :showcommands & goto askargs )
call :launch !TARGS!
echo(
echo   %M%   run again with new args,   %A%?%M% help    %A%r%M% readme    %A%q%M% finish + delete%R%
goto askargs

:install
pushd "!SRC!"
call :trace "install: pushed cwd=!CD!"
set "IFAIL=" & set "ISPY="
if exist requirements.txt set "ISPY=1"
if not defined ISPY if exist pyproject.toml set "ISPY=1"
if not defined ISPY if exist setup.py set "ISPY=1"
if not defined ISPY if exist *.py set "ISPY=1"
call :trace "install: ISPY=!ISPY!"
if defined ISPY (
  call :pyvenv
  call :trace "install: pyvenv returned rc=!errorlevel! VENV=!VENV!"
  if errorlevel 1 ( popd & exit /b 1 )
  set "PIPFAIL="
  if exist requirements.txt (
    "!VENV!\Scripts\python.exe" -m pip install -q -r requirements.txt --disable-pip-version-check
    if errorlevel 1 set "PIPFAIL=1"
  ) else if exist pyproject.toml (
    "!VENV!\Scripts\python.exe" -m pip install -q . --disable-pip-version-check
    if errorlevel 1 set "PIPFAIL=1"
  ) else if exist setup.py (
    "!VENV!\Scripts\python.exe" -m pip install -q . --disable-pip-version-check
    if errorlevel 1 set "PIPFAIL=1"
  )
  "!VENV!\Scripts\python.exe" -m pip install -q pipreqs --disable-pip-version-check >nul 2>&1
  "!VENV!\Scripts\pipreqs.exe" --force --savepath ".bh_reqs.txt" "!SRC!" >nul 2>&1
  if exist ".bh_reqs.txt" "!VENV!\Scripts\python.exe" -m pip install -q --only-binary=:all: -r ".bh_reqs.txt" --disable-pip-version-check >nul 2>&1
  call :trace "install: bh_reqs installed"
  rem tools that route through Tor/SOCKS need pysocks for requests
  findstr /s /i /m /c:"socks5" /c:"SOCKSProxyManager" /c:"import socks" /c:"9050" "!SRC!\*.py" >nul 2>&1 && "!VENV!\Scripts\python.exe" -m pip install -q pysocks --disable-pip-version-check >nul 2>&1
  if defined PIPFAIL set "IFAIL=1"
) else if exist package.json (
  where npm >nul 2>&1 && ( call npm install --no-audit --no-fund --loglevel=error ) || set "IFAIL=1"
) else if exist go.mod (
  where go >nul 2>&1 && ( go build -o ".bh_run.exe" ./... ) || set "IFAIL=1"
) else if exist Cargo.toml (
  where cargo >nul 2>&1 && ( cargo build --release ) || set "IFAIL=1"
)
popd
if defined IFAIL exit /b 1
echo ok>"!SRC!\.bh_state"
exit /b 0

:pyvenv
if not exist "!VENV!\Scripts\python.exe" (
  call :findpy
  if errorlevel 1 exit /b 1
  !PY! -m venv "!VENV!" >nul 2>&1
  if not exist "!VENV!\Scripts\python.exe" ( echo   %NO%could not create venv%R% & exit /b 1 )
)
"!VENV!\Scripts\python.exe" -m pip install -q --upgrade pip setuptools wheel >nul 2>&1
exit /b 0

:launch
call :trace "launch: start args=%*"
set "PYTHONWARNINGS=ignore"
set "VPY=!VENV!\Scripts\python.exe"
set "EXE="
if exist "!VENV!\Scripts\!TID!.exe" set "EXE=!VENV!\Scripts\!TID!.exe"
if not defined EXE if exist "!VENV!\Scripts\!CARD_NAME!.exe" set "EXE=!VENV!\Scripts\!CARD_NAME!.exe"
pushd "!SRC!"
call :trace "launch: pushed to !SRC! EXE=!EXE!"
echo(
echo   %M%   ── output ──────────────────────────────────────────────────────────%R%
echo(
rem 1 - python console script from the venv (pip install)
if defined EXE ( "!EXE!" %* & goto launch_done )
rem 2 - native binary (go / rust build)
if exist ".bh_run.exe" ( ".bh_run.exe" %* & goto launch_done )
if exist "target\release\!TID!.exe" ( "target\release\!TID!.exe" %* & goto launch_done )
rem 3 - node / javascript
if exist "package.json" (
  if exist "node_modules\.bin\!TID!.cmd" ( call "node_modules\.bin\!TID!.cmd" %* & goto launch_done )
  set "NJS="
  for %%F in (index.js main.js cli.js app.js server.js bin\cli.js bin\index.js src\index.js src\cli.js) do if not defined NJS if exist "%%F" set "NJS=%%F"
  if defined NJS ( where node >nul 2>&1 && ( node "!NJS!" %* & goto launch_done ) )
  where node >nul 2>&1 && ( node . %* & goto launch_done )
)
rem 3b - streamlit web app? run with streamlit, not python
if exist "!VENV!\Scripts\streamlit.exe" (
  set "SLAPP="
  for %%F in (ui.py app.py streamlit_app.py Home.py main.py) do if not defined SLAPP if exist "%%F" ( findstr /m /i /c:"streamlit" "%%F" >nul 2>&1 && set "SLAPP=%%F" )
  if not defined SLAPP for %%F in (*.py) do if not defined SLAPP ( findstr /m /i /c:"import streamlit" "%%F" >nul 2>&1 && set "SLAPP=%%~nxF" )
  if defined SLAPP ( echo   %M%   starting the web UI - it opens in your browser ...%R% & "!VENV!\Scripts\streamlit.exe" run "!SLAPP!" & goto launch_done )
)
rem 4 - python script in the repo
set "ENTRY="
for %%F in ("!TID!.py" "!CARD_NAME!.py" main.py __main__.py cli.py run.py app.py start.py) do if not defined ENTRY if exist %%F set "ENTRY=%%~F"
rem   only one .py in the root? just run it
if not defined ENTRY (
  set "PYCOUNT=0"
  for %%F in (*.py) do ( set /a PYCOUNT+=1 & set "ONEPY=%%~nxF" )
  if "!PYCOUNT!"=="1" set "ENTRY=!ONEPY!"
)
rem   still nothing? pick the .py that has a __main__ block (the runnable one)
if not defined ENTRY (
  for %%F in (*.py) do if not defined ENTRY ( findstr /m /c:"__main__" "%%F" >nul 2>&1 && set "ENTRY=%%~nxF" )
)
if defined ENTRY (
  if exist "!VPY!" ( "!VPY!" "!ENTRY!" %* ) else ( python "!ENTRY!" %* )
  goto launch_done
)
if exist "!TID!\__main__.py" (
  if exist "!VPY!" ( "!VPY!" -m "!TID!" %* ) else ( python -m "!TID!" %* )
  goto launch_done
)
rem 5 - could not tell: let the user pick a file to run
call :pickrun %*
:launch_done
call :trace "launch: tool finished, at launch_done"
echo(
echo   %M%   ────────────────────────────────────────────────────────────────────%R%
popd
call :trace "launch: popped, returning"
exit /b 0

:pickrun
echo   %NO%   could not auto-detect how to run this one.%R%
echo   %M%   pick a file to run  (path is relative to the repo):%R%
set "GOTF="
for %%F in (*.py *.js *.sh *.exe) do ( echo       %P%%%~nxF%R% & set "GOTF=1" )
for /d %%D in (*) do for %%F in ("%%D\*.py" "%%D\*.js") do ( echo       %P%%%D\%%~nxF%R% & set "GOTF=1" )
if not defined GOTF echo       %M%nothing runnable found - browse: !SRC!%R%
echo(
set "PICK="
set /p "PICK=  %A%type a filename to run%M% - blank to skip >%R% "
if not defined PICK exit /b 0
if /I "!PICK:~-3!"==".py" ( if exist "!VPY!" ( "!VPY!" "!PICK!" %* ) else ( python "!PICK!" %* ) & exit /b 0 )
if /I "!PICK:~-3!"==".js" ( node "!PICK!" %* & exit /b 0 )
if /I "!PICK:~-3!"==".sh" ( where bash >nul 2>&1 && bash "!PICK!" %* & exit /b 0 )
if /I "!PICK:~-4!"==".exe" ( "!PICK!" %* & exit /b 0 )
if exist "!VPY!" ( "!VPY!" "!PICK!" %* ) else ( python "!PICK!" %* )
exit /b 0

:needgit
where git >nul 2>&1 && exit /b 0
echo   %NO%git not found - install Git for Windows: https://git-scm.com/download/win%R%
exit /b 1

:findpy
set "PY="
rem 1) a wheel-friendly system Python via the py launcher
for %%v in (3.12 3.11 3.10) do if not defined PY ( py -%%v -V >nul 2>&1 && set "PY=py -%%v" )
if defined PY exit /b 0
rem 2) a portable Python BLACKHOUND downloaded before
if exist "%HERE%runtime\python\python.exe" ( set PY="%HERE%runtime\python\python.exe" & exit /b 0 )
rem 3) no good Python - fetch a portable 3.12 so tools build cleanly
call :bootpy
if exist "%HERE%runtime\python\python.exe" ( set PY="%HERE%runtime\python\python.exe" & exit /b 0 )
rem 4) last resort: whatever Python exists (may be too new for some tools)
for %%v in (3.13 3.14 3.9 3.8) do if not defined PY ( py -%%v -V >nul 2>&1 && set "PY=py -%%v" )
if not defined PY where py >nul 2>&1 && set "PY=py -3"
if not defined PY where python >nul 2>&1 && set "PY=python"
if not defined PY ( echo   %NO%Python not found - get it from https://www.python.org/downloads/ and tick Add to PATH%R% & exit /b 1 )
exit /b 0

:bootpy
rem  Download a portable, wheel-friendly Python 3.12 into runtime\python (one time).
if exist "%HERE%runtime\python\python.exe" exit /b 0
echo(
echo   %A%[*]%M% no wheel-friendly Python found - fetching a portable Python 3.12%R%
echo   %M%       one-time, about 30 MB, so tools install without build errors ...%R%
if not exist "%HERE%runtime" mkdir "%HERE%runtime"
where curl >nul 2>&1 || ( echo   %NO%[x] curl not found - update Windows, or install Python 3.12 yourself%R% & exit /b 1 )
curl -L -# -o "%HERE%runtime\py.tgz" "https://github.com/astral-sh/python-build-standalone/releases/download/20260901/cpython-3.12.14+20260901-x86_64-pc-windows-msvc-install_only.tar.gz"
if not exist "%HERE%runtime\py.tgz" ( echo   %NO%[x] download failed - check your connection%R% & exit /b 1 )
echo   %M%       extracting ...%R%
tar -xf "%HERE%runtime\py.tgz" -C "%HERE%runtime"
del "%HERE%runtime\py.tgz" >nul 2>&1
if exist "%HERE%runtime\python\python.exe" ( echo   %OK%[+]%M% portable Python 3.12 ready%R% ) else ( echo   %NO%[x] could not set up portable Python%R% )
exit /b 0

:showcommands
rem  Only tools that use argparse/click understand --help safely.
rem  Others (which read sys.argv directly) would treat --help as INPUT, so show the README instead.
findstr /s /i /c:"argparse" /c:"import click" /c:"click.option" /c:"docopt" "!SRC!\*.py" >nul 2>&1
if not errorlevel 1 (
  call :launch --help
) else (
  echo   %M%   this tool has no --help flags - showing its README so you can see how to run it%R%
  echo(
  call :showreadme
)
exit /b 0

:showreadme
set "RM="
for %%F in (README.md README.MD readme.md README.rst README.txt README) do if not defined RM if exist "!SRC!\%%F" set "RM=%%F"
if not defined RM ( echo   %NO%   no readme in this repo%R% & exit /b 0 )
echo(
echo   %M%   ── !RM! ──  %A%space%M% next page   %A%q%M% quit%R%
more "!SRC!\!RM!"
exit /b 0

:brand
echo   %A%⣶%R% %P%BLACKHOUND%R%%M%  · osint hunting rig · by Oreo%R%
echo   %F%────────────────────────────────────────────────────────────────────────────────%R%
exit /b 0

:cleanup
call :trace "cleanup: start SRC=!SRC!"
echo(
echo   %M%   removing !CARD_NAME! from disk ...%R%
cd /d "%HERE%." 2>nul
call :trace "cleanup: cd done, rmdir"
rmdir /s /q "!SRC!" 2>nul
call :trace "cleanup: rmdir done"
exit /b 0

:trace
rem debug trace disabled - set BHDEBUG=1 to log steps to bh_debug.log
if defined BHDEBUG >> "%HERE%bh_debug.log" echo [%date% %time%] %~1
exit /b 0

:docard
set "CARD_REPO=" & set "CARD_HTML=" & if not "%~2"=="" set "%~2="
set "FOUNDIT="
for /f "usebackq tokens=1-8 delims=	" %%a in (`findstr /b /c:":::%~1	" "%SELF%"`) do (
  set "FOUNDIT=1"
  set "NN=%%a" & set "NN=!NN:~3!"
  echo   %F%╭────────────────────────────────────────────────────────────────────╮%R%
  echo   %P%%%d%R%   %M%#!NN!  %%e stars  %%f%R%
  echo   %F%├────────────────────────────────────────────────────────────────────┤%R%
  echo   %M%lane %R% %%c
  echo   %M%repo %R% %P%%%g%R%
  echo   %M%what %R% %M%%%h%R%
  echo   %F%╰────────────────────────────────────────────────────────────────────╯%R%
  set "CARD_REPO=%%g" & set "CARD_HTML=%%g" & set "CARD_ID=%%b" & set "CARD_NAME=%%d" & set "CARD_LANG=%%f"
  if not "%~2"=="" set "%~2=1"
)
if not defined FOUNDIT echo   %NO%no tool number %~1%R%
if defined CARD_HTML set "CARD_HTML=!CARD_HTML:.git=!"
exit /b 0

:doctor
cls
call :brand
echo   %F%╭─ %P%DOCTOR%M%  what BLACKHOUND can drive on this PC%R%
echo(
call :chk git    "clone tools"
call :chk python "run Python tools"
call :chk node   "run JavaScript tools"
call :chk go     "build Go tools"
call :chk cargo  "build Rust tools"
echo(
set "PYV="
for /f "tokens=2" %%v in ('python -V 2^>^&1') do set "PYV=%%v"
if defined PYV echo     %M%python version:%R% !PYV!
set "PYNEW="
echo !PYV!^| findstr /c:"3.13" /c:"3.14" /c:"3.15" /c:"3.16" >nul 2>&1 && set "PYNEW=1"
if defined PYNEW echo     %NO%[x] Python !PYV! is very new - many tools have no wheels for it.%R%
if exist "%HERE%runtime\python\python.exe" (
  echo     %OK%[ok] BLACKHOUND has its own portable Python 3.12 - tools use that instead.%R%
) else if defined PYNEW (
  echo     %M%    no worries: BLACKHOUND downloads its own Python 3.12 the first time a tool needs it.%R%
)
echo(
pause
goto menu

:chk
where %1 >nul 2>&1
if !errorlevel!==0 ( echo     %OK%[ok]%R%  %P%%~1%R%   %M%%~2%R% ) else ( echo     %NO%[--]%R%  %P%%~1%R%   %M%%~2 - missing%R% )
exit /b 0

:helpscreen
cls
call :brand
echo   %F%╭─ %P%HELP%R%
echo(
echo     %A%1-24%R%   %M%open a lane and list its tools%R%
echo     %A%S%R% x    %M%search every tool name and description%R%
echo     %A%I%R% n    %M%info card for tool number n%R%
echo     %A%R%R% n    %M%how to fetch and run tool number n%R%
echo     %A%D%R%      %M%doctor - what is installed here%R%
echo     %A%Q%R%      %M%quit%R%
echo(
pause
goto menu

:catname
rem map number -> short + full category name
set "CATNAME=" & set "CATNAME_FULL=" & set "CATCOUNT="
if "%1"=="1" ( set "CATNAME=General OSINT" & set "CATNAME_FULL=General OSINT" & set "CATCOUNT=357" )
if "%1"=="2" ( set "CATNAME=Domain / DNS" & set "CATNAME_FULL=Domain / DNS" & set "CATCOUNT=303" )
if "%1"=="3" ( set "CATNAME=Recon" & set "CATNAME_FULL=Recon / Footprint" & set "CATCOUNT=232" )
if "%1"=="4" ( set "CATNAME=Username" & set "CATNAME_FULL=Username" & set "CATCOUNT=223" )
if "%1"=="5" ( set "CATNAME=Network" & set "CATNAME_FULL=Network" & set "CATCOUNT=208" )
if "%1"=="6" ( set "CATNAME=IP / Geo" & set "CATNAME_FULL=IP / Geo" & set "CATCOUNT=183" )
if "%1"=="7" ( set "CATNAME=Social Media" & set "CATNAME_FULL=Social Media" & set "CATCOUNT=139" )
if "%1"=="8" ( set "CATNAME=Metadata" & set "CATNAME_FULL=Media / Metadata" & set "CATCOUNT=136" )
if "%1"=="9" ( set "CATNAME=Email" & set "CATNAME_FULL=Email" & set "CATCOUNT=121" )
if "%1"=="10" ( set "CATNAME=Phone" & set "CATNAME_FULL=Phone" & set "CATCOUNT=119" )
if "%1"=="11" ( set "CATNAME=Threat Intel" & set "CATNAME_FULL=Threat Intel" & set "CATCOUNT=116" )
if "%1"=="12" ( set "CATNAME=Web Extract" & set "CATNAME_FULL=Web Extract / Scrape" & set "CATCOUNT=100" )
if "%1"=="13" ( set "CATNAME=Geo / Maps" & set "CATNAME_FULL=Geo / Maps" & set "CATCOUNT=94" )
if "%1"=="14" ( set "CATNAME=Web Scan" & set "CATNAME_FULL=Web Scan" & set "CATCOUNT=84" )
if "%1"=="15" ( set "CATNAME=Dorking" & set "CATNAME_FULL=Dorking / Search" & set "CATCOUNT=55" )
if "%1"=="16" ( set "CATNAME=Secrets" & set "CATNAME_FULL=Code / Secrets" & set "CATCOUNT=55" )
if "%1"=="17" ( set "CATNAME=Link Graph" & set "CATNAME_FULL=Graph / Link Analysis" & set "CATCOUNT=52" )
if "%1"=="18" ( set "CATNAME=Forensics" & set "CATNAME_FULL=Forensics" & set "CATCOUNT=36" )
if "%1"=="19" ( set "CATNAME=Dark Web" & set "CATNAME_FULL=Dark Web" & set "CATCOUNT=34" )
if "%1"=="20" ( set "CATNAME=Wireless" & set "CATNAME_FULL=Wireless" & set "CATCOUNT=23" )
if "%1"=="21" ( set "CATNAME=Breach" & set "CATNAME_FULL=Breach / Leaks" & set "CATCOUNT=22" )
if "%1"=="22" ( set "CATNAME=People ID" & set "CATNAME_FULL=People / Identity" & set "CATCOUNT=12" )
if "%1"=="23" ( set "CATNAME=Crypto" & set "CATNAME_FULL=Crypto / Finance" & set "CATCOUNT=8" )
if "%1"=="24" ( set "CATNAME=Corporate" & set "CATNAME_FULL=Corporate / Business" & set "CATCOUNT=5" )
exit /b 0

:sleep
ping -n 1 -w %1 192.0.2.1 >nul 2>&1
exit /b 0

rem ===================== settings (saved to blackhound.cfg) =====================
:applytheme
if /I "%THEME%"=="amber" ( set "A=%ESC%[38;5;214m" & set "AD=%ESC%[38;5;94m" ) else if /I "%THEME%"=="cyan" ( set "A=%ESC%[38;5;45m" & set "AD=%ESC%[38;5;30m" ) else ( set "A=%ESC%[38;5;196m" & set "AD=%ESC%[38;5;88m" )
exit /b 0

:loadcfg
if not exist "%HERE%blackhound.cfg" exit /b 0
for /f "usebackq tokens=1,2 delims==" %%a in ("%HERE%blackhound.cfg") do (
  if /I "%%a"=="THEME" set "THEME=%%b"
  if /I "%%a"=="AUTODEL" set "AUTODEL=%%b"
  if /I "%%a"=="AUTOHELP" set "AUTOHELP=%%b"
  if /I "%%a"=="WARN" set "WARN=%%b"
)
exit /b 0

:savecfg
> "%HERE%blackhound.cfg" echo THEME=!THEME!
>> "%HERE%blackhound.cfg" echo AUTODEL=!AUTODEL!
>> "%HERE%blackhound.cfg" echo AUTOHELP=!AUTOHELP!
>> "%HERE%blackhound.cfg" echo WARN=!WARN!
exit /b 0

:toggle
if "!%~1!"=="1" ( set "%~1=0" ) else ( set "%~1=1" )
exit /b 0

:cycletheme
if /I "!THEME!"=="crimson" ( set "THEME=amber" ) else if /I "!THEME!"=="amber" ( set "THEME=cyan" ) else ( set "THEME=crimson" )
call :applytheme
exit /b 0

:finishtool
if "!AUTODEL!"=="1" ( call :cleanup ) else ( echo( & echo   %M%   kept at tools\!TID! - next run needs no re-download%R% )
exit /b 0

:settings
set "T2=off" & if "!AUTODEL!"=="1" set "T2=on"
set "T3=off" & if "!AUTOHELP!"=="1" set "T3=on"
set "T4=off" & if "!WARN!"=="1" set "T4=on"
cls
call :brand
echo   %F%╭─ %P%SETTINGS%M%   saved automatically to blackhound.cfg%R%
echo   %F%├──────────────────────────────────────────────────────────────────────────%R%
echo(
echo     %A%1%R%  theme                    %P%!THEME!%R%   %M%crimson / amber / cyan%R%
echo     %A%2%R%  delete tool after run    %P%!T2!%R%    %M%off = keep it cached for instant re-runs%R%
echo     %A%3%R%  auto-show tool commands  %P%!T3!%R%
echo     %A%4%R%  trust warning            %P%!T4!%R%    %M%the "runs third-party code" notice%R%
echo(
echo   %F%├──────────────────────────────────────────────────────────────────────────%R%
echo     %M%pick a number to change it,   Enter to go back%R%
set "S=" & set /p "S=  %A%settings%M%>%R% "
if not defined S goto menu
if "!S!"=="1" ( call :cycletheme & call :savecfg & goto settings )
if "!S!"=="2" ( call :toggle AUTODEL & call :savecfg & goto settings )
if "!S!"=="3" ( call :toggle AUTOHELP & call :savecfg & goto settings )
if "!S!"=="4" ( call :toggle WARN & call :savecfg & goto settings )
goto settings

:bootline
echo     %OK%●%R% %M%%~1%R%
call :sleep 250
exit /b 0

:end
cls
echo   %A%hound sleeps.%R%
endlocal
exit /b 0

rem ============================ TOOL DATABASE ============================
rem  Format:  :::<n>\t<id>\t<category>\t<name>\t<stars>\t<lang>\t<repo>\t<desc>
:::1	worldmonitor	General OSINT	worldmonitor	87090	TypeScript	https://github.com/koala73/worldmonitor.git	Real-time global intelligence dashboard. AI-powered news aggregation, geopolitical monitoring, and infrastruct
:::2	web-check	General OSINT	web-check	34880	TypeScript	https://github.com/lissy93/web-check.git	All-in-one OSINT tool for analysing any website
:::3	singlefile	General OSINT	SingleFile	22439	JavaScript	https://github.com/gildas-lormeau/SingleFile.git	Web Extension for saving a faithful copy of a complete web page in a single HTML file
:::4	ghunt	General OSINT	GHunt	19581	Python	https://github.com/mxrch/GHunt.git	Offensive Google framework
:::5	crucix	General OSINT	Crucix	11774	JavaScript	https://github.com/calesthio/Crucix.git	Your personal intelligence agent. Watches the world from multiple data sources and pings you when something ch
:::6	sublist3r	General OSINT	Sublist3r	11044	Python	https://github.com/aboul3la/Sublist3r.git	Fast subdomains enumeration tool for penetration testers
:::7	httpx	General OSINT	httpx	10414	Go	https://github.com/projectdiscovery/httpx.git	httpx is a fast and multi-purpose HTTP toolkit that allows running multiple probes using the retryablehttp lib
:::8	paramspider	General OSINT	ParamSpider	3174	Python	https://github.com/devanshbatham/ParamSpider.git	Mining URLs from dark corners of Web Archives for bug hunting/fuzzing/further probing
:::9	redamon	General OSINT	redamon	2493	Python	https://github.com/samugit83/redamon.git	An AI-powered agentic red team framework that automates offensive security operations, from reconnaissance to 
:::10	ipdrone	General OSINT	ipdrone	2163	Python	https://github.com/noob-hackers/ipdrone.git	Track Location With Live Address And Accuracy In Termux
:::11	fsociety	General OSINT	fsociety	1832	Python	https://github.com/fsociety-team/fsociety.git	A Modular Penetration Testing Framework
:::12	darkdump	General OSINT	darkdump	1781	Python	https://github.com/josh0xA/darkdump.git	Open Source Intelligence Interface for Deep Web Scraping
:::13	secrets-patterns-db	General OSINT	secrets-patterns-db	1618	Python	https://github.com/mazen160/secrets-patterns-db.git	Secrets Patterns DB: The largest open-source Database for detecting secrets, API keys, passwords, tokens, and 
:::14	whatsapp-osint	General OSINT	whatsapp-osint	1537	Python	https://github.com/jasperan/whatsapp-osint.git	WhatsApp spy - logs online/offline events from ANYONE in the world
:::15	socid-extractor	General OSINT	socid-extractor	1091	Python	https://github.com/soxoj/socid-extractor.git	The extraction engine behind Maigret: turn any profile URL into a structured OSINT record across 150+ sites
:::16	xeuledoc	General OSINT	xeuledoc	1027	Python	https://github.com/Malfrats/xeuledoc.git	Fetch information about a public Google document
:::17	dedsec	General OSINT	DedSec	1021	Python	https://github.com/dedsec1121fk/DedSec.git	Official repository of the DedSec Project
:::18	gitfive	General OSINT	GitFive	1019	Python	https://github.com/mxrch/GitFive.git	Track down GitHub users
:::19	powerful-plugins	General OSINT	Powerful-Plugins	907	-	https://github.com/Hack-with-Github/Powerful-Plugins.git	Powerful plugins and add-ons for hackers
:::20	ghost-osint-crm	General OSINT	GHOST-osint-crm	889	JavaScript	https://github.com/elm1nst3r/GHOST-osint-crm.git	GHOST - Global Human Operations Surveillance Tracking: Open-source investigation management platform for track
:::21	udork	General OSINT	uDork	866	Shell	https://github.com/m3n0sd0n4ld/uDork.git	uDork is a script written in Bash Scripting that uses advanced Google search techniques to obtain sensitive in
:::22	scavenger	General OSINT	Scavenger	834	Python	https://github.com/rndinfosecguy/Scavenger.git	Crawler Bot searching for credential leaks on paste sites
:::23	tlosint-live	General OSINT	tlosint-live	833	HTML	https://github.com/tracelabs/tlosint-live.git	Trace Labs OSINT Linux Distribution based on Kali
:::24	obsidian-osint-templates	General OSINT	obsidian-osint-templates	810	-	https://github.com/WebBreacher/obsidian-osint-templates.git	These templates are suggestions of how the Obsidian notetaking tool can be used during an OSINT investigation.
:::25	onedrive_user_enum	General OSINT	onedrive_user_enum	769	Python	https://github.com/nyxgeek/onedrive_user_enum.git	onedrive user enumeration - pentest tool to enumerate valid o365 users
:::26	fofamap	General OSINT	FofaMap	729	Python	https://github.com/asaotomo/FofaMap.git	FOFA AI CLI / MCP / Skill / REST API Nuclei
:::27	infinite-monitor	General OSINT	infinite-monitor	726	TypeScript	https://github.com/homanp/infinite-monitor.git	Monitor anything in real time
:::28	osint-mapping-tool	General OSINT	OSINT-Mapping-Tool	656	JavaScript	https://github.com/anonymousRAID/OSINT-Mapping-Tool.git	An OSINT Mapping tool for research
:::29	cloudrip	General OSINT	CloudRip	644	Python	https://github.com/moscovium-mc/CloudRip.git	A tool that helps you find the real IP addresses hiding behind Cloudflare
:::30	cardpwn	General OSINT	CardPwn	634	Python	https://github.com/itsmehacker/CardPwn.git	OSINT Tool to find Breached Credit Cards Information
:::31	waybackpy	General OSINT	waybackpy	605	Python	https://github.com/akamhy/waybackpy.git	Wayback Machine API interface a command-line tool
:::32	singlefile-mv3	General OSINT	SingleFile-MV3	600	JavaScript	https://github.com/gildas-lormeau/SingleFile-MV3.git	SingleFile version compatible with Manifest V3
:::33	bchacktool	General OSINT	BCHackTool	543	Shell	https://github.com/ByCh4n/BCHackTool.git	All-in-one launcher and installer for popular penetration-testing and OSINT tools on Kali Linux and Termux
:::34	osintgpt	General OSINT	osintgpt	528	Python	https://github.com/estebanpdl/osintgpt.git	An open-source intelligence OSINT analysis tool leveraging GPT-powered embeddings and vector search engines 
:::35	vortex	General OSINT	vortex	450	Python	https://github.com/klezVirus/vortex.git	VPN Overall Reconnaissance, Testing, Enumeration and eXploitation Toolkit
:::36	git-vuln-finder	General OSINT	git-vuln-finder	428	Python	https://github.com/cve-search/git-vuln-finder.git	Finding potential software vulnerabilities from git commit messages
:::37	osint-browser-extensions	General OSINT	OSINT-Browser-Extensions	427	-	https://github.com/The-Osint-Toolbox/OSINT-Browser-Extensions.git	Browser Chrome extensions, to help with OSINT, OPSEC, Privacy Obfuscation
:::38	sputnik	General OSINT	sputnik	417	JavaScript	https://github.com/mitchmoser/sputnik.git	Open Source Intelligence Browser Extension
:::39	h-i-v-e	General OSINT	H.I.V.E	409	Python	https://github.com/Shad0w-ops/H.I.V.E.git	H.I.V.E is an automated OSINT Open Source Intelligence multi-tool that enables efficient data gathering from
:::40	claude-skills-journalism	General OSINT	claude-skills-journalism	397	Python	https://github.com/jamditis/claude-skills-journalism.git	Claude Code skills for journalism, media, and academia - verification, FOIA, data journalism, academic writing
:::41	tryhackme	General OSINT	TryHackMe	394	Shell	https://github.com/migueltc13/TryHackMe.git	Master cybersecurity skills with this free-only TryHackMe learning path, complete with a progress-tracking tem
:::42	counter-osint-guide-en	General OSINT	counter-osint-guide-en	367	-	https://github.com/soxoj/counter-osint-guide-en.git	Comprehensive Counter OSINT and privacy guide initially for CIS countries
:::43	google-dorks-simplified	General OSINT	Google-Dorks-Simplified	358	-	https://github.com/osintverse/Google-Dorks-Simplified.git	Best Resource for learning Google Dorks
:::44	mesh-networking	General OSINT	mesh-networking	358	JavaScript	https://github.com/pirate/mesh-networking.git	:globe_with_meridians: LEGO blocks for networking, a Python library to help create and test flexible network t
:::45	araa-search	General OSINT	araa-search	333	Python	https://github.com/Extravi/araa-search.git	A privacy-respecting, ad-free, self-hosted Google metasearch engine with strong security that offers full API 
:::46	dorkagent	General OSINT	DorkAgent	324	Python	https://github.com/yee-yore/DorkAgent.git	LLM-powered agent for automated Google Dorking in bug hunting pentesting
:::47	llm_osint	General OSINT	llm_osint	319	Python	https://github.com/sshh12/llm_osint.git	LLM OSINT is a proof-of-concept method of using LLMs to gather information from the internet and then perform 
:::48	ghostrecon	General OSINT	GhostRecon	307	Shell	https://github.com/KawaCoder/GhostRecon.git	Popular OSINT framework for online investigations
:::49	iptables-tracer	General OSINT	iptables-tracer	297	Go	https://github.com/x-way/iptables-tracer.git	Insert trace-points into the running configuration to observe the path of packets through the iptables chains
:::50	assayo	General OSINT	assayo	296	HTML	https://github.com/bakhirev/assayo.git	Creates an HTML-report with analysis of commit statistics
:::51	pockint	General OSINT	pockint	285	Python	https://github.com/edoardogerosa/pockint.git	A portable OSINT Swiss Army Knife for DFIR/OSINT professionals
:::52	tweet-machine	General OSINT	tweet-machine	273	Shell	https://github.com/0xcyberpj/tweet-machine.git	This tool can retrieve : 1.Deleted tweets and replies ,Even if The account is suspended 2 .Old bios and Timest
:::53	unimocap	General OSINT	UniMoCap	203	Python	https://github.com/LinghaoChan/UniMoCap.git	[Open-source Project] UniMoCap: community implementation to unify the text-motion datasets HumanML3D, KIT-ML,
:::54	cyberpunkos	General OSINT	CyberPunkOS	201	Python	https://github.com/cyberpunkOS/CyberPunkOS.git	CyberPunkOS is a virtual machine that incorporates several tools for Open Source Intelligence OSINT to disma
:::55	urx	General OSINT	urx	191	Rust	https://github.com/hahwul/urx.git	Extracts URLs from OSINT Archives for Security Insights
:::56	prot1ntelligence	General OSINT	Prot1ntelligence	189	Python	https://github.com/C3n7ral051nt4g3ncy/Prot1ntelligence.git	Protintelligence is a Python script for the OSINT and Cyber Community. This tool helps you to find intelligenc
:::57	gitxray	General OSINT	gitxray	184	Python	https://github.com/kulkansecurity/gitxray.git	A multifaceted security tool which leverages Public GitHub REST APIs for OSINT, Forensics, Pentesting and more
:::58	netscout	General OSINT	netscout	183	Go	https://github.com/caio-ishikawa/netscout.git	OSINT tool that finds domains, subdomains, directories, endpoints and files for a given seed URL
:::59	osint-search-tools	General OSINT	OSINT-Search-Tools	180	HTML	https://github.com/HOPain/OSINT-Search-Tools.git	Complex OSINT Search Tools
:::60	orion	General OSINT	OriON	176	Shell	https://github.com/Cl4r4-5/OriON.git	OriON is a virtual machine in Spanish that incorporates several tools for Open Source Intelligence OSINT on 
:::61	webcheck-osint	General OSINT	WebCheck-OSINT	172	TypeScript	https://github.com/mwakidenis/WebCheck-OSINT.git	All-in-one OSINT reconnaissance tool for dissecting any website
:::62	memcachedump	General OSINT	memcachedump	141	Python	https://github.com/JLospinoso/memcachedump.git	Python/Shodan tool for dumping exposed memcached server contents into local text files
:::63	sociallinks-api	General OSINT	sociallinks-api	132	Python	https://github.com/SocialLinks-IO/sociallinks-api.git	Social Links API: description, examples, trial access
:::64	python-wayback-machine-downloader	General OSINT	python-wayback-machine-downloader	127	Python	https://github.com/bitdruid/python-wayback-machine-downloader.git	Query and download archive.org as simple as possible
:::65	osintbox	General OSINT	osintBOX	123	HTML	https://github.com/Dimaslg/osintBOX.git	Script to modify a Parrot OS distro with the most popular OSINT tools
:::66	cyber-intelligence-gpt	General OSINT	Cyber-Intelligence-GPT	119	-	https://github.com/osintshifu/Cyber-Intelligence-GPT.git	Advanced AI assistant for OSINT, cyber intelligence, digital forensics, threat analysis, ethical hacking, and 
:::67	devilseye	General OSINT	DevilsEye	116	C#	https://github.com/Fergs32/DevilsEye.git	C# - Opensource OSINT program, using google dorking methods, free api's and much more
:::68	physical-pentesting-tools	General OSINT	Physical-Pentesting-Tools	109	-	https://github.com/yogsec/Physical-Pentesting-Tools.git	Physical penetration testing is a critical aspect of security assessment that involves simulating real-world a
:::69	opsec-osint-tools	General OSINT	OPSEC-OSINT-Tools	109	Shell	https://github.com/airborne-commando/OPSEC-OSINT-Tools.git	A list and guide of OSINT/OPSEC and some tools that I've made and or use
:::70	inteltrace	General OSINT	IntelTrace	108	Python	https://github.com/Gowtham-Darkseid/IntelTrace.git	OSINT Intelligence Tool
:::71	wayback-machine-downloader	General OSINT	wayback-machine-downloader	102	JavaScript	https://github.com/birbwatcher/wayback-machine-downloader.git	Wayback Machine Downloader for webmasters, OSINT researchers, and SEO specialists
:::72	vichiti	General OSINT	vichiti	101	JavaScript	https://github.com/umair9747/vichiti.git	An OSINT focused tool made with Nodejs
:::73	osint-ia	General OSINT	OSINT-IA	101	-	https://github.com/CScorza/OSINT-IA.git	L'I.A. a supporto dell'OSINT
:::74	stalkphish-oss	General OSINT	StalkPhish-OSS	98	Python	https://github.com/t4d/StalkPhish-OSS.git	StalkPhish-OSS - The Phishing kits stalker, harvesting phishing kits for investigations
:::75	draculaos	General OSINT	DraculaOS	96	-	https://github.com/emrekybs/DraculaOS.git	Dracula OS is a Linux operating system meticulously designed for OSINT Open Source Intelligence and Cyber In
:::76	tsukuyomi	General OSINT	TSUKUYOMI	95	-	https://github.com/savannah-i-g/TSUKUYOMI.git	##Note: this is really old now, and the janky pseudo methods are probably only working out of sheer coincidenc
:::77	osint-war-room	General OSINT	OSINT-War-Room	87	JavaScript	https://github.com/Hue-Jhan/OSINT-War-Room.git	War Tactical dashboard designed for tracking global conflicts, military movements, and geopolitical events in 
:::78	osint-cli-tool-skeleton	General OSINT	osint-cli-tool-skeleton	83	Python	https://github.com/soxoj/osint-cli-tool-skeleton.git	Template for new OSINT command-line tools
:::79	urldna	General OSINT	urldna	80	Python	https://github.com/urldna/urldna.git	The DNA test for websites
:::80	estensionichromeosint	General OSINT	EstensioniChromeOSINT	79	-	https://github.com/CScorza/EstensioniChromeOSINT.git	Estensioni Utili per l'OSINT
:::81	osinttools	General OSINT	OSINTtools	77	-	https://github.com/LinaYorda/OSINTtools.git	A set of social media OSINT tools that I use when participating in Trace Labs Search Party CTF
:::82	spyscraper	General OSINT	SpyScraper	77	Python	https://github.com/N0rz3/SpyScraper.git	Osint tool to scraper websites
:::83	otwartezrodla	General OSINT	otwartezrodla	73	HTML	https://github.com/P3run/otwartezrodla.git	Polskie rozszerzenie OSINT framework - Polish extension of OSINT framework
:::84	scrape	General OSINT	scrape	71	Go	https://github.com/averagesecurityguy/scrape.git	Extensible paste site scraper written in Golang
:::85	akerouanton-iptables-tracer	General OSINT	iptables-tracer	71	Go	https://github.com/akerouanton/iptables-tracer.git	Trace packets as they go through iptables chains
:::86	webdragon63-mr-holmes	General OSINT	Mr.Holmes	70	Python	https://github.com/webdragon63/Mr.Holmes.git	A Complete OSINT Tool
:::87	amasss_cbct	General OSINT	AMASSS_CBCT	68	Python	https://github.com/Maxlo24/AMASSS_CBCT.git	Automatic segmentation of CBCT scans with a 3D Unet
:::88	dnsrecon-gui	General OSINT	DNSrecon-gui	62	JavaScript	https://github.com/micro-joan/DNSrecon-gui.git	DNSrecon tool with GUI for Kali Linux
:::89	amass-annotation-unifier	General OSINT	AMASS-Annotation-Unifier	60	Python	https://github.com/Mathux/AMASS-Annotation-Unifier.git	Unify text-motion datasets like BABEL, HumanML3D, KIT-ML into a common motion-text representation
:::90	googlefu	General OSINT	GoogleFU	56	Python	https://github.com/champmq/GoogleFU.git	A tool that sorts out the information found on Google
:::91	osint-toolkit	General OSINT	OSINT-Toolkit	53	HTML	https://github.com/Cybersight-Security/OSINT-Toolkit.git	This repository serves as a comprehensive catalog for tools and websites useful in Open Source Intelligence O
:::92	cqfd	General OSINT	cqfd	49	Python	https://github.com/megadose/cqfd.git	cqfd is a tool and a python libraries to search skype account from a name
:::93	gokhancode-osint-tools	General OSINT	OSINT-Tools	49	-	https://github.com/gokhancode/OSINT-Tools.git	Open Source Intelligence Tools List in English/Turkish
:::94	yahye_abdirahman	General OSINT	Yahye_Abdirahman	44	Shell	https://github.com/fikrado/Yahye_Abdirahman.git	this is termux scrip that dowloads all social media hacking tools , ip tracers , phishing and shells
:::95	osint-investigation	General OSINT	osint-investigation	43	-	https://github.com/coldvisionz/osint-investigation.git	Useful OSINT tools
:::96	azure-devops-gitleaks	General OSINT	azure-devops-gitleaks	43	TypeScript	https://github.com/JoostVoskuil/azure-devops-gitleaks.git	This is an extension for Azure DevOps that is a wrapper arround gitleaks created by Zachary Rice for easy exec
:::97	ghunt-panel	General OSINT	ghunt-panel	41	JavaScript	https://github.com/Drotfix/ghunt-panel.git	A local, self-hosted web UI for GHunt mxrch's OSINT framework for investigating Google accounts. ghunt-panel w
:::98	va-pt	General OSINT	va-pt	40	Python	https://github.com/sec0ps/va-pt.git	The VAPT Toolkit provides a streamlined way to install, configure, and maintain a complete penetration testing
:::99	g1-retarget	General OSINT	G1-retarget	40	Python	https://github.com/HomerIsAFool/G1-retarget.git	Use PHC framework to retarget motion from AMASS dataset into unitree G1 style
:::100	caulking	General OSINT	caulking	35	Shell	https://github.com/cloud-gov/caulking.git	Caulking installs global Git hooks that run gitleaks so you dont accidentally commit or push secrets
:::101	fl0wj0b	General OSINT	Fl0wj0b	33	Python	https://github.com/megadose/Fl0wj0b.git	Fl0wj0b est un script qui permet d'extraire des informations d'annuaires et de les exporter .csv
:::102	maigret-adapter	General OSINT	maigret-adapter	32	Python	https://github.com/soxoj/maigret-adapter.git	Connect Maigret with other tools
:::103	holehe-web	General OSINT	holehe-web	31	JavaScript	https://github.com/sds-osint/holehe-web.git	A basic web implementation of Holehe
:::104	osint-tools-emirates	General OSINT	OSINT-Tools-Emirates	31	-	https://github.com/paulpogoda/OSINT-Tools-Emirates.git	Tools for OSINT in Emirates
:::105	osint-stividor	General OSINT	osint-stividor	30	JavaScript	https://github.com/okpulse/osint-stividor.git	OSINT Stividor
:::106	amass_g1_retargeting	General OSINT	amass_g1_retargeting	30	-	https://github.com/edpsw/amass_g1_retargeting.git	This repository provides tools to retarget motion data from the AMASS dataset to G1 humanoid motions
:::107	gitleaksverifier	General OSINT	GitleaksVerifier	30	Python	https://github.com/aydinnyunus/GitleaksVerifier.git	GitleaksVerifier is a Python-based verification tool designed to enhance the functionality of Gitleaks by rigo
:::108	osint-explorer	General OSINT	OSINT-Explorer	25	JavaScript	https://github.com/gowthamaraj/OSINT-Explorer.git	New-Generation OSINT Framework
:::109	abirhasan2005-userrecon	General OSINT	UserRecon	24	Shell	https://github.com/AbirHasan2005/UserRecon.git	Modified version of userrecon. Mod
:::110	cti-house	General OSINT	CTI-House	23	-	https://github.com/CyberIntelligenceLab/CTI-House.git	Open Source Intelligence OSINT Tool List for Cyber Threat Intelligence Researchers
:::111	elastichunt	General OSINT	Elastichunt	23	Python	https://github.com/ef1500/Elastichunt.git	Locate, search and download open Elasticsearch databases
:::112	gmailosint	General OSINT	GmailOSINT	23	Python	https://github.com/Shakedash-dev/GmailOSINT.git	Use Google services to gather details on an owner of a google acount
:::113	osint-vm	General OSINT	osint-vm	21	-	https://github.com/Inforensics/osint-vm.git	VM for OSINT investigators that is a test-bed for using AI tools and agents to improve investigations. No out-
:::114	sleuth	General OSINT	sleuth	20	Python	https://github.com/povvo/sleuth.git	6 phase, 56 task agent workflow, consisting of; Operational Direction, Intelligence Collection, Collation Enti
:::115	stalker	General OSINT	Stalker	20	Python	https://github.com/SORRYSPLASH/Stalker.git	Stalker represents a sophisticated tool utilized in the realm of Open Source Intelligence OSINT. Its primary
:::116	0u44-spiderfoot	General OSINT	SpiderFoot	20	Shell	https://github.com/0u44/SpiderFoot.git	launch spiderfoot easily from any terminal
:::117	rigidbody-network-prediction-and-reconci	General OSINT	Rigidbody-Network-Prediction-and-Reconci	18	C#	https://github.com/Apollo99-Games/Rigidbody-Network-Prediction-and-Reconciliation-for-Unity-NGO.git	An implementation of Rigidbody Network Prediction and Reconciliation for Unity's Netcode for Gameobjects
:::118	homebrew-amass	General OSINT	homebrew-amass	18	Ruby	https://github.com/owasp-amass/homebrew-amass.git	The OWASP Amass Homebrew Formula
:::119	intelbox	General OSINT	IntelBox	17	Python	https://github.com/malwaredojo/IntelBox.git	Install an arsenal of OSINT tools by running IntelBox on your Debian VM or OS
:::120	nik-checker	General OSINT	NIK-checker	17	Go	https://github.com/Mr-Pstar7/NIK-checker.git	Tools for checking NIK
:::121	lab-rats	General OSINT	Lab-RATS	16	Java	https://github.com/K4N3CO/Lab-RATS.git	Lab-RATS is a powerful and lightweight Android Remote Administration Tool full of features that enables remote
:::122	open-source-intelligence	General OSINT	Open-Source-INTelligence	15	-	https://github.com/txuswashere/Open-Source-INTelligence.git	Open-source intelligence OSINT
:::123	reconstruction-ngsim-trajectory-with-dmd	General OSINT	Reconstruction-NGSIM-Trajectory-with-DMD	15	Python	https://github.com/TeRyZh/Reconstruction-NGSIM-Trajectory-with-DMD-and-Res_UNet_plus.git	This contains the model and data for reconstructing NGSIM dataset
:::124	human-posture-visualization	General OSINT	human-posture-visualization	15	Python	https://github.com/TullyMonster/human-posture-visualization.git	Web 3D SMPL/SMPLX
:::125	webdiver	General OSINT	WebDiver	14	Python	https://github.com/AnonCatalyst/WebDiver.git	WebDiver is a versatile Python script for crawling websites, extracting internal and external links, titles, a
:::126	osint-indonesia-v4	General OSINT	osint-indonesia-v4	14	Python	https://github.com/spyschools/osint-indonesia-v4.git	Tools OSINT Indonesia, untuk cek NIK No HP. Script ini tidak akan ambil data dari database ilegal, tapi hanya 
:::127	ai-osint-security-analyzer	General OSINT	AI-OSINT-Security-Analyzer	14	Python	https://github.com/Armaan29-09-2005/AI-OSINT-Security-Analyzer.git	AI OSINT Security Analyzer is an intelligent platform that leverages AI to perform autonomous investigations a
:::128	webhound	General OSINT	WebHound	14	Python	https://github.com/AnonCatalyst/WebHound.git	WebHound is your Python-powered command-line assistant for sharp and efficient web searches It sniffs out data
:::129	sportracker	General OSINT	sporTracker	13	Python	https://github.com/mrofcodyx/sporTracker.git	SporTracker is an OSINT tool designed to collect and organize publicly available information from multiple onl
:::130	janddda-spiderfoot	General OSINT	spiderfoot	13	Python	https://github.com/Janddda/spiderfoot.git	SpiderFoot, the open source footprinting and intelligence-gathering tool
:::131	www-project-amass	General OSINT	www-project-amass	13	HTML	https://github.com/OWASP/www-project-amass.git	OWASP Foundation Web Respository
:::132	amass-to-csv	General OSINT	amass-to-csv	13	Python	https://github.com/amroot/amass-to-csv.git	A simple script that generates an Excel friendly CSV file from an Amass JSON file
:::133	osint-web-application	General OSINT	osint-web-application	13	TypeScript	https://github.com/albonidrizi/osint-web-application.git	A high-performance OSINT Orchestration Platform built with Kotlin Spring Boot and React. Features asynchrono
:::134	rtsp-to-webcam	General OSINT	RTSP.to-webcam	12	-	https://github.com/apple-fritter/RTSP.to-webcam.git	Output RTSP stream to a virtual webcam device using FFmpeg. A guide
:::135	rohit_phoneinfoga	General OSINT	Rohit_PhoneInfoga	12	-	https://github.com/avengerrohit/Rohit_PhoneInfoga.git	You can easily install PhoneInfoga with the help of this repository
:::136	amass-roundtable	General OSINT	amass-roundtable	12	Shell	https://github.com/huxiang1126/amass-roundtable.git	Claude Code Skill HRCOO
:::137	amass-motion-retargeting	General OSINT	AMASS-Motion-Retargeting	12	Python	https://github.com/XinLang2019/AMASS-Motion-Retargeting.git	this code can retarget AMASS dataset to the G1,H1 robot, which can be used to train policy
:::138	cleanmetadata	General OSINT	CleanMetadata	12	Python	https://github.com/benedictus79/CleanMetadata.git	Este script Python remove todos os metadados de arquivos utilizando ExifTool, incluindo datas de criao e modif
:::139	digital-war-room	General OSINT	digital-war-room	11	Python	https://github.com/lina767/digital-war-room.git	Multi-agent platform using OSINT tools to create geopolitical analysis
:::140	osint-browser-extentions	General OSINT	OSINT-browser-extentions	11	-	https://github.com/LinaYorda/OSINT-browser-extentions.git	Browser extension that I use daily to detect fake news; search images and collect data
:::141	webamon-cli	General OSINT	webamon-cli	11	Python	https://github.com/webamon-org/webamon-cli.git	Democratizing Threat Intelligence
:::142	snapscoretracker	General OSINT	snapscoretracker	11	Python	https://github.com/ibnaleem/snapscoretracker.git	A Snapscore tracker that reports various metrics such as time differences, score increases, snaps sent and rec
:::143	phoneinfog	General OSINT	phoneinfog	11	-	https://github.com/sagheer46/phoneinfog.git	git@github.com:sundowndev/PhoneInfoga.git
:::144	ipgeo	General OSINT	ipgeo	11	Rust	https://github.com/grantshandy/ipgeo.git	A pure-rust CLI tool that finds the location of IP addresses
:::145	spiderfoot-local-data-module	General OSINT	Spiderfoot-local-data-module	11	Python	https://github.com/her0marodeur/Spiderfoot-local-data-module.git	This module allows Spiderfoot to search local databases. This might be useful, when you want to include databa
:::146	autoinfogather	General OSINT	AutoInfoGather	10	Python	https://github.com/sys1ph0s/AutoInfoGather.git	A tool to automate OSINT tasks related to emails by combining industry favorite tools
:::147	gmr	General OSINT	GMR	10	Python	https://github.com/engineai-robotics/GMR.git	GMR for EngineAI Robots. Retarget human motions BVH, SMPL-X, AMASS to EngineAI PM01 and T800 humanoid robots
:::148	ip	General OSINT	ip	9	PHP	https://github.com/fikrado/ip.git	php ip tracer scrip for linux, termux or any shell based terminal
:::149	connectors_amass-3dshapes	General OSINT	Connectors_Amass.3dshapes	9	-	https://github.com/realthunder/Connectors_Amass.3dshapes.git	3D models of AMASS connectors for use in KiCad and FreeCAD
:::150	waybackurls-pl	General OSINT	waybackurls.pl	9	Perl	https://github.com/LvMalware/waybackurls.pl.git	Search for urls of subdomains using the web archive database
:::151	amass-setup	General OSINT	amass-setup	8	Shell	https://github.com/mikedesu/amass-setup.git	My personal amass setup
:::152	puming-amass	General OSINT	Amass	8	Java	https://github.com/puming/Amass.git	Jetpack+Okhttp+Retrofit+Dagger2+Rxjava2+ARouterApp
:::153	eagle-library-amass	General OSINT	Eagle-Library-AMASS	8	-	https://github.com/suzakulab/Eagle-Library-AMASS.git	This AMASS connector Eagle library is an unofficial. If you notice a mistake, please contact the suzaku lab. i
:::154	andromedatrader	General OSINT	AndromedaTrader	8	C#	https://github.com/BalintFarkas/AndromedaTrader.git	Andromeda Trader is a C#-based programming competition game. Players write AIs that control spaceships, which 
:::155	huginn	General OSINT	Huginn	8	Go	https://github.com/satty-br/Huginn.git	A gitleaks secrets validator
:::156	dexpose	General OSINT	dexpose	8	Go	https://github.com/zuhayrb/dexpose.git	Pure-Go CLI that scans APK files for leaked secrets. Zero dependencies, gitleaks-compatible rules, CI-friendly
:::157	devsecops-kit	General OSINT	devsecops-kit	8	Go	https://github.com/EdgarPsda/devsecops-kit.git	Opinionated CLI to bootstrap a DevSecOps pipeline in minutes, SAST, secrets scanning, SCA, SBOM, IaC, and AI f
:::158	ghost-osint	General OSINT	Ghost-OSINT	7	-	https://github.com/Aabyss-Team/Ghost-OSINT.git	Ghost OSINT SpiderFootOSINT
:::159	ipgeolocation	General OSINT	IPGeolocation	6	Python	https://github.com/JohnLuca12/IPGeolocation.git	IP Tracer For Termux and Linux
:::160	spiderfoot-mcp	General OSINT	spiderfoot-mcp	6	Python	https://github.com/marlinkcyber/spiderfoot-mcp.git	A Model Context Protocol MCP server that provides SpiderFoot OSINT automation capabilities to AI assistants 
:::161	amassa_api	General OSINT	Amassa_API	6	JavaScript	https://github.com/matgermano/Amassa_API.git	Projeto Nodejs - Criao de API com modelagem de dados voltadas um restaurante
:::162	binaryscary-subdomainrecon	General OSINT	SubDomainRecon	6	Shell	https://github.com/BinaryScary/SubDomainRecon.git	Amass + all.txt + commonspeak + AltDNS + SubJack
:::163	owasp-amass-diagrams	General OSINT	owasp-amass-diagrams	6	-	https://github.com/enseitankado/owasp-amass-diagrams.git	Visual representation of amass subcommands
:::164	soma2amass	General OSINT	soma2amass	6	Python	https://github.com/WhitKey/soma2amass.git	SEED / SOMA MHR BVH mocap to AMASS-format SMPL-X .npz. Retargets through the SOMA-X rig and a topology bridg
:::165	carouselldestroyer	General OSINT	CarousellDestroyer	6	Java	https://github.com/syahrul12345/CarousellDestroyer.git	A bot that can auto sell, detect if your listing is on the first page and amass likes
:::166	swiftdiff	General OSINT	SwiftDiff	6	Python	https://github.com/sibotian96/SwiftDiff.git	[IEEE T-ASE] Official repo for 'Real-Time 3D Motion Prediction for Human-Robot Collaboration via Bayesian-Opti
:::167	astronomy_visualization_metadata_exiftoo	General OSINT	astronomy_visualization_metadata_exiftoo	6	-	https://github.com/clr/astronomy_visualization_metadata_exiftool_profile.git	This profile allows you to use ExifTool to edit XMP tags for the AVM standard defined by the VAMP team
:::168	dnsrecon_elite	General OSINT	DNSRecon_Elite	6	Python	https://github.com/BotGJ16/DNSRecon_Elite.git	DNSRecon Elite
:::169	archive	General OSINT	archive	6	Shell	https://github.com/Imran407704/archive.git	This is a Simple Bash Script for Automating Some repetative task this Script simple take urls from many passiv
:::170	sift	General OSINT	sift	6	Python	https://github.com/AmadeusITGroup/sift.git	SIFT Smart Intelligent Finding Triaging is an innovative AI-powered tool to automatically analyze GitLeaks s
:::171	userreconplus	General OSINT	UserReconPlus	5	Shell	https://github.com/esteban11121/UserReconPlus.git	Versin mejorada y mantenida por @esteban11121 Este script es tu herramienta definitiva para buscar perfiles de
:::172	ip-traceroute-explorer	General OSINT	IP-traceroute-explorer	5	Python	https://github.com/NZRS/IP-traceroute-explorer.git	RIPE Atlas hackathon project to explore the differences in performance from same origin to same destination us
:::173	vscode-hacker-theme	General OSINT	vscode-hacker-theme	5	-	https://github.com/aidabeorn/vscode-hacker-theme.git	The perfect theme for writing IP tracers in Visual Basic and reverse-proxying a UNIX-system firewall
:::174	opfor-intel	General OSINT	opfor-intel	5	Python	https://github.com/GlobalReconReport/opfor-intel.git	Terminal-based geopolitical threat intelligence toolkit RSS collection, Shodan/ipinfo enrichment, SpiderFoot O
:::175	brecon	General OSINT	brecon	5	Shell	https://github.com/bronxi47/brecon.git	brecon is a bash script that chains together assetfinder, amass, gobuster, httpx, and Censys for both active a
:::176	aquamacs	General OSINT	Aquamacs	5	JavaScript	https://github.com/mdesjardins/Aquamacs.git	This is my current Aquamacs emacs config. Most of the stuff I've amassed through years of emacs use is in Pref
:::177	sfn	General OSINT	sfn	5	C	https://github.com/zricethezav/sfn.git	Secrets Fast Now - a shitty _and_ faster gitleaks port in C
:::178	burpsuite-gitleaks-extension	General OSINT	BurpSuite-Gitleaks-Extension	5	Java	https://github.com/TheArqsz/BurpSuite-Gitleaks-Extension.git	Unofficial Gitleaks integration/extension for Burp Suite
:::179	find-and-report-secrets-in-code	General OSINT	find-and-report-secrets-in-code	5	Python	https://github.com/abdullahkhawer/find-and-report-secrets-in-code.git	Security solution to find secrets in a git repository and report about them. It uses Gitleaks and some custom 
:::180	gitleaks-wrapper	General OSINT	gitleaks-wrapper	5	Python	https://github.com/cedowens/gitleaks-wrapper.git	Simple wrapper around gitleaks to enumerate publicly facing repos belonging to an org and then run gitleaks ag
:::181	shodan-runner	General OSINT	Shodan-Runner	5	Shell	https://github.com/jfer-bah/Shodan-Runner.git	Shodan Runner is a bash script designed to expedite shodan search queries using the shodan python cli
:::182	shodan-skill	General OSINT	shodan-skill	5	Python	https://github.com/liuweitao/shodan-skill.git	An unofficial, safety-focused Shodan CLI and universal Agent Skill covering the documented REST, Streaming, Tr
:::183	leandrejd2239-userrecon	General OSINT	userrecon	4	Shell	https://github.com/leandrejd2239/userrecon.git	userrecon de @linux_choice mais j ai ajouter pornhub a la recherche de site mdr
:::184	phonenumberscanner	General OSINT	PhoneNumberScanner	4	Python	https://github.com/onursengul01/PhoneNumberScanner.git	Automation of PhoneInfoga
:::185	honkerhack-phoneinfoga	General OSINT	PhoneInfoga	4	-	https://github.com/HonkerHack/PhoneInfoga.git	PhoneInfoga Una de las herramientas ms avanzadas para escanear nmeros de telfono utilizando solo recursos grat
:::186	cyber-mino-ip-tracer	General OSINT	IP.Tracer	4	-	https://github.com/CyBeR-Mino/IP.Tracer.git	https://github.com/rajkumardusad
:::187	emmateva18-amass	General OSINT	AMASS	4	HTML	https://github.com/emmateva18/AMASS.git	This is our C++ based applications for the MusalaSoft Sprint
:::188	amass-skeleton-to-smpl	General OSINT	AMASS-skeleton-to-SMPL	4	Python	https://github.com/Ceveloper/AMASS-skeleton-to-SMPL.git	Convert AMASS-format 3D joint sequences to SMPL meshes. via optimization. For Human Motion Prediction
:::189	amass-to-3dhpe	General OSINT	AMASS-to-3DHPE	4	Python	https://github.com/goldbricklemon/AMASS-to-3DHPE.git	Conversion utility to transform the AMASS dataset to a Human3.6M-compatible 3D human pose estimation dataset. 
:::190	blackpinkdsproject	General OSINT	BlackpinkDSProject	4	Python	https://github.com/rachelombok/BlackpinkDSProject.git	A data science project analyzing why/how BLACKPINK has amassed global popularity in the kpop scope
:::191	subdomainscan	General OSINT	SubdomainScan	4	Python	https://github.com/smilexxfire/SubdomainScan.git	SubdomainScansubfinderamass
:::192	betterleaks-action	General OSINT	betterleaks-action	4	TypeScript	https://github.com/dortort/betterleaks-action.git	GitHub Action for Betterleaks secrets detection - scan for exposed credentials in your CI/CD pipeline
:::193	cyberkallan-userrecon	General OSINT	userrecon	3	Shell	https://github.com/cyberkallan/userrecon.git	by Arjun arz
:::194	geo-ip-traceroute	General OSINT	Geo-IP-Traceroute	3	Python	https://github.com/pr0xy-8L4d3/Geo-IP-Traceroute.git	Traceroute the hostname or IP and locate the IPs
:::195	jullien-madera	General OSINT	Jullien-Madera	3	Python	https://github.com/m4ndrake/Jullien-Madera.git	Modulo Ping para SpiderFoot
:::196	docker-spiderfoot	General OSINT	docker-spiderfoot	3	-	https://github.com/treemo/docker-spiderfoot.git	SpiderFoot, the open source footprinting and intelligence-gathering tool. http://www.spiderfoot.net
:::197	spiderfoot-claude-code	General OSINT	spiderfoot-claude-code	3	Python	https://github.com/drbothen/spiderfoot-claude-code.git	SpiderFoot OSINT Lab with CLI for AI coding assistant integration
:::198	auntiehecker	General OSINT	AuntieHecker	3	PowerShell	https://github.com/Deppy04/AuntieHecker.git	Finding my hacker. Publishing redacted evidence and SpiderFoot results from a long-term digital compromise aff
:::199	domaintomailserver	General OSINT	DomainToMailServer	3	Python	https://github.com/r4p3c4/DomainToMailServer.git	DomainToMailServer es un mdulo creado para Spiderfoot, cuya funcin es obtener los servidores de correo corresp
:::200	lkpttn-amass	General OSINT	amass	3	JavaScript	https://github.com/lkpttn/amass.git	Amass personal analytics dashboard
:::201	subsubsui	General OSINT	subsubsui	3	Shell	https://github.com/zyairelai/subsubsui.git	AMASS + Assetfinder + Subfinder = subsubsui
:::202	plataforma_amassa	General OSINT	Plataforma_Amassa	3	JavaScript	https://github.com/matgermano/Plataforma_Amassa.git	Projeto React - Integrao de API Amassa_API para aplicao prtica de plataforma Web para um restaurante
:::203	public-amass-platform-starter	General OSINT	public-amass-platform-starter	3	Python	https://github.com/amass-technologies/public-amass-platform-starter.git	An interactive agent for querying scientific literature and clinical trials via the amass platform
:::204	pickslide	General OSINT	PickSlide	3	Python	https://github.com/rclough/PickSlide.git	Purely hypothetical scraper to amass Guitar Pro files for music research from a hypothetical popular guitar ta
:::205	the-arcane-odyssey	General OSINT	The-Arcane-Odyssey	3	Python	https://github.com/Yani-Jivkov/The-Arcane-Odyssey.git	Embark on an exhilarating journey in The Arcane Odyssey, where strategy and cunning dictate fate. Navigate the
:::206	freefall	General OSINT	FreeFall	3	Python	https://github.com/etmaifo/FreeFall.git	Freefall is a mobile game that will test your quick responses and keep you engaged in endless fun of dodging o
:::207	scrub-claude-sessions	General OSINT	scrub-claude-sessions	3	Python	https://github.com/slhck/scrub-claude-sessions.git	Scan and redact secrets from Claude Code session logs using gitleaks
:::208	lazygitleaks	General OSINT	lazyGitleaks	3	Python	https://github.com/bassammaged/lazyGitleaks.git	Do you interested in finding secrets? Are you depending on gitleaks tool? Do you usually perform large scan sc
:::209	shodna	General OSINT	ShoDNA	3	HTML	https://github.com/sc4rfurry/ShoDNA.git	Yet another Shodan with CLI + WebUI Tool with some Dorks related to SHodan
:::210	censeye-ng	General OSINT	censeye-ng	3	Go	https://github.com/Censys-Research/censeye-ng.git	An example API and CLI for working with the Censys Threathunting Module
:::211	phoneinf0	General OSINT	phoneinf0	2	Python	https://github.com/AverageMisesian/phoneinf0.git	https://phonenumberinfo.herokuapp.com/
:::212	ipv6-tracer	General OSINT	IPv6-Tracer	2	Python	https://github.com/JDowns412/IPv6-Tracer.git	CS 653 Semester Project
:::213	bull-attack	General OSINT	Bull-Attack	2	-	https://github.com/MarcoAGP/Bull-Attack.git	Website or Ip TRACER for Termux
:::214	hackerproid96-ipdrone	General OSINT	ipdrone	2	Python	https://github.com/HackerProID96/ipdrone.git	Tracking Someone's IP Using Termux
:::215	tools	General OSINT	tools	2	-	https://github.com/andixax/tools.git	Tools Gitu Lah
:::216	spiderfoot-build	General OSINT	spiderfoot-build	2	Shell	https://github.com/martinboller/spiderfoot-build.git	Installs Spiderfoot Community Edition on Debian 11
:::217	spiderfoot-modification-project	General OSINT	spiderfoot-modification-project	2	-	https://github.com/sh1katagana1/spiderfoot-modification-project.git	My custom modules for Spiderfoot
:::218	personal-soc-lab-t-pot-ce	General OSINT	Personal-SOC-Lab-T-Pot-CE	2	-	https://github.com/ShaneYeung-Cyber/Personal-SOC-Lab-T-Pot-CE-.git	Personal SOC lab using T-Pot CE on AWS to analyze real-world attack telemetry through Honeypots, Suricata, and
:::219	simplednsrecon	General OSINT	SimpleDNSRecon	2	Shell	https://github.com/w4spy/SimpleDNSRecon.git	a bash script for subdomains enum using different set of tools at once
:::220	python-guardians	General OSINT	python-guardians	2	Python	https://github.com/scthornton/python-guardians.git	Handy Red Teaming Scripts
:::221	azure-devops-gitleaks-extension	General OSINT	azure-devops-gitleaks-extension	2	TypeScript	https://github.com/davidpolaniaac/azure-devops-gitleaks-extension.git	Gitleaks is a SAST tool for detecting hardcoded secrets
:::222	ikuuhakui-gitleaks	General OSINT	gitleaks	2	JavaScript	https://github.com/IKuuhakuI/gitleaks.git	A lightweight CLI tool for scanning secrets in your repo
:::223	gitleaks-pipeline	General OSINT	gitleaks-pipeline	2	TypeScript	https://github.com/fluent-ci-templates/gitleaks-pipeline.git	A ready-to-use CI/CD Pipeline for detecting secrets in your code using Gitleaks
:::224	gitleaks-example	General OSINT	gitleaks-example	2	Python	https://github.com/pabpereza/gitleaks-example.git	Code repository example to detect and protect secrets on code with gitleaks and GitHub actions
:::225	nogoo9-gitleaks	General OSINT	gitleaks	2	Python	https://github.com/nogoo9/gitleaks.git	npm and pypi wrappers for gitleaks - a tool for detecting secrets like passwords, API keys, and tokens in git 
:::226	twt-repo	General OSINT	twt-repo	2	Shell	https://github.com/miravuong/twt-repo.git	Test fixture for Tripwire: planted fake secrets with ground-truth manifest for validating Gitleaks + TruffleHo
:::227	maskctl	General OSINT	maskctl	2	Go	https://github.com/muhittink/maskctl.git	Local anonymization gate for AI uploads blocks secrets gitleaks, pseudonymizes PII Presidio DE+EN, restore
:::228	vault-rag-pipeline	General OSINT	vault-rag-pipeline	2	Python	https://github.com/mdziegiel/vault-rag-pipeline.git	Self-hosted RAG pipeline for an AI homelab agent semantic search over an Obsidian vault with automated secrets
:::229	fullstack_devsec	General OSINT	FullStack_DevSec	2	JavaScript	https://github.com/wizzfi1/FullStack_DevSec.git	I built this end-to-end DevSecOps pipeline to demonstrate how Id run secure, observable, and automated softwar
:::230	shodan_cli	General OSINT	SHODAN_CLI	2	Python	https://github.com/ManuAP/SHODAN_CLI.git	Este cdigo realiza una bsqueda en el motor de bsqueda de Shodan utilizando la librera Shodan de Python
:::231	confusploit	General OSINT	confusploit	2	Python	https://github.com/p4b3l1t0/confusploit.git	This is a python script that can be used with Shodan CLI to mass hunting Confluence Servers vulnerable to CVE-
:::232	crow	General OSINT	Crow	2	Python	https://github.com/airborne-commando/Crow.git	A gui Edition of the OSINT tool blackbird
:::233	old-dov-osintbox	General OSINT	OSINTBox	1	Python	https://github.com/old-dov/OSINTBox.git	Orchestrateur d'outils OSINT Sherlock, Maigret, Holehe, theHarvester -- CLI + interface desktop PySide6
:::234	osint-console	General OSINT	osint-console	1	Python	https://github.com/davidleonstr/osint-console.git	Flask and React rebuild. Drives Blackbird, Holehe, Maigret and Sherlock against one target and merges what the
:::235	thatbynln-userrecon	General OSINT	userrecon	1	Shell	https://github.com/thatbynln/userrecon.git	Terminal Based Info- Gathering Tool
:::236	aliadiv-userrecon	General OSINT	userrecon	1	-	https://github.com/aliadiv/userrecon.git	apt-get install tor
:::237	mrzapero-userrecon	General OSINT	userrecon	1	Shell	https://github.com/Mrzapero/userrecon.git	tool untuk melacak akun sosial media seseorang
:::238	pericena-userrecon	General OSINT	UserRecon	1	Shell	https://github.com/Pericena/UserRecon.git	Alguna vez te has preguntado si alguien est usando tu nombre de usuario en otra red social que nunca usaste? E
:::239	fabrisoftware-userrecon	General OSINT	UserRecon	1	Python	https://github.com/FabriSoftware/UserRecon.git	an rcon client for minecraft java and bedrock servers written in python
:::240	cybersume-phoneinfoga	General OSINT	phoneinfoga	1	Python	https://github.com/cybersume/phoneinfoga.git	only for testing
:::241	jisu29-phoneinfoga	General OSINT	phoneinfoga	1	Go	https://github.com/jisu29/phoneinfoga.git	git clone https://github.com/jisu29/phoneingoa
:::242	leodevries13-phoneinfoga	General OSINT	phoneinfoga	1	Python	https://github.com/leodevries13/phoneinfoga.git	python version
:::243	h801486-phoneinfoga	General OSINT	phoneInfoga	1	-	https://github.com/H801486/phoneInfoga.git	Some text here
:::244	phoneinfoga_launcher	General OSINT	Phoneinfoga_launcher	1	-	https://github.com/ACTZWells/Phoneinfoga_launcher.git	when you search about a tool like phoneinfoga and you found that you need to write the path before writing the
:::245	trackout	General OSINT	trackout	1	Python	https://github.com/shamanthss/trackout.git	Simple IP Tracer
:::246	ipgeolocation-iptc	General OSINT	IPGeoLocation-iptc	1	C	https://github.com/moritzkreemke/IPGeoLocation-iptc.git	A small CLI Tool to determine the Country of an IP-Address
:::247	dradisce-build	General OSINT	dradisce-build	1	Shell	https://github.com/martinboller/dradisce-build.git	Installing SpiderFoot
:::248	romanr301-spiderfoot	General OSINT	spiderfoot	1	HTML	https://github.com/RomanR301/spiderfoot.git	https://romanr301.github.io/spiderfoot/spiderfoot/index.html
:::249	darkspacesoftwareandsecurity-spiderfoot	General OSINT	SPIDERFOOT	1	Python	https://github.com/DarkspaceSoftwareandSecurity/SPIDERFOOT.git	REMOTE COMMAND EXECUTION RCE
:::250	spiderweb	General OSINT	spiderweb	1	Python	https://github.com/Hakkadex/spiderweb.git	spiderfoot cli manager
:::251	sfe	General OSINT	sfe	1	Shell	https://github.com/SirCryptic/sfe.git	SpiderFoot Easylaunch Installer
:::252	spiderfoot-rust	General OSINT	spiderfoot-rust	1	Rust	https://github.com/hob1t/spiderfoot-rust.git	rust impl of spiderfoot
:::253	spiderfoot-snap	General OSINT	spiderfoot-snap	1	-	https://github.com/JitPatro/spiderfoot-snap.git	SpiderFoot is an open source intelligence OSINT automation tool
:::254	spiderfoot-snmp	General OSINT	spiderfoot-snmp	1	Python	https://github.com/ch3vy-1/spiderfoot-snmp.git	Small Spiderfoot module where you can get OS information from a server. Only if it is using public community
:::255	olgierdwspanialy-spiderfoot	General OSINT	SpiderFoot	1	-	https://github.com/olgierdwspanialy/SpiderFoot.git	i want to learn spiderfoot
:::256	spiderfoot-launcher	General OSINT	spiderfoot-launcher	1	Shell	https://github.com/Ahkuu/spiderfoot-launcher.git	Simple bash service manager for SpiderFoot OSINT tool
:::257	spiderfoot-js	General OSINT	spiderfoot-js	1	TypeScript	https://github.com/torch-ai/spiderfoot-js.git	Provides a generic service connection to an open source Spiderfoot instance and generic types
:::258	spiderfoot-2-6-1-src	General OSINT	spiderfoot-2.6.1-src	1	-	https://github.com/w3bt00lz/spiderfoot-2.6.1-src.git	https://sourceforge.net/projects/spiderfoot/files/spiderfoot-2.6.1-src.tar.gz/download
:::259	spf_new_module	General OSINT	spf_new_module	1	Python	https://github.com/justorodriguez87/spf_new_module.git	Spiderfoot Get Host By Name
:::260	findrootme	General OSINT	findRootMe	1	Python	https://github.com/Anferomol/findRootMe.git	Find if exist account in Root-me.org with this module for SpiderFoot
:::261	arm64v8-spiderfoot	General OSINT	arm64v8-spiderfoot	1	-	https://github.com/onty/arm64v8-spiderfoot.git	spiderfoot Docker build for arm machines
:::262	satyam	General OSINT	SATYAM	1	-	https://github.com/minecraftgamers074-jpg/SATYAM-.git	wget https://github.com/smicallef/spiderfoot/archive/v4.0.tar.gz tar zxvf v4.0.tar.gz cd spiderfoot-4.0 pip3 i
:::263	spiderfoostatuscode	General OSINT	spiderfooStatusCode	1	Python	https://github.com/Ur3anNXT/spiderfooStatusCode.git	Modulo de Spiderfoot con el cual podremos sabe el codigo de estado de una web introducidad
:::264	hacking-aziral	General OSINT	hacking-aziral	1	Python	https://github.com/shutovBro/hacking-aziral.git	Self-hosted OSINT/pentest platform Authentik SSO + ~15 tools SpiderFoot, Superset, Activepieces, Cronicle, et
:::265	xlsx-to-html-links	General OSINT	xlsx-to-html-links	1	Python	https://github.com/PaulSizemore/xlsx-to-html-links.git	Scripts to create HTML pages with links for all sheets with URL's - run from SpiderFoot output
:::266	reconng	General OSINT	ReconNG	1	-	https://github.com/ManticoreAI/ReconNG.git	[Is this the best OSINT tool out there? ]https://youtu.be/i99v8lIOvFc
:::267	ngp_lenticular_recon	General OSINT	NGP_lenticular_recon	1	Python	https://github.com/HrushikeshBudhale/NGP_lenticular_recon.git	Artistic lenticular effect using NGP
:::268	twittersentencegenerator	General OSINT	TwitterSentenceGenerator	1	Python	https://github.com/a-nady/TwitterSentenceGenerator.git	Create a random AI generated sentence based off a user's syntax and vocabulary using their tweets
:::269	dysaf-dnsrecon	General OSINT	dnsrecon	1	Python	https://github.com/dysaf/dnsrecon.git	dnslookup tool
:::270	anizum1-mr-holmes	General OSINT	Mr.-Holmes	1	Python	https://github.com/anizum1/Mr.-Holmes.git	Mr. Holmes is a powerful Open Source Intelligence OSINT investigation tool designed for legitimate research,
:::271	rainbowhatrkn-trape	General OSINT	trape	1	-	https://github.com/rainbowhatrkn/trape.git	People tracker on the Internet: OSINT analysis and research tool by Jose Pino
:::272	archive_urls	General OSINT	Archive_urls	1	Python	https://github.com/Agent44-eagle/Archive_urls.git	A Python tool to fetch live and unique URLS from domains or subdomains using OTX, Commoncrawl, waybackurls and
:::273	gitleaks-test	General OSINT	gitleaks-test	1	-	https://github.com/alperensoydan/gitleaks-test.git	Test Gitleaks for Secrets
:::274	step-security-gitleaks-action	General OSINT	gitleaks-action	1	TypeScript	https://github.com/step-security/gitleaks-action.git	Protect your secrets using Gitleaks-Action. Secure drop-in replacement for gitleaks/gitleaks-action
:::275	secrets-precommit	General OSINT	secrets-precommit	1	Python	https://github.com/moveeeax/secrets-precommit.git	Pre-commit bundle wiring gitleaks and trufflehog with sensible defaults
:::276	fledge-plugin-gitleaks	General OSINT	fledge-plugin-gitleaks	1	Rust	https://github.com/CorvidLabs/fledge-plugin-gitleaks.git	Scan your repo for committed secrets via gitleaks, with a one-command pre-commit hook installer
:::277	python-gitleaks	General OSINT	Python-Gitleaks	1	-	https://github.com/jonturista-prog/Python-Gitleaks.git	A project which uses Gitleaks Python to build a script that detects whether secrets or other sensitive informa
:::278	gitleaks-lite	General OSINT	gitleaks-lite	1	HTML	https://github.com/workflowsdiy/gitleaks-lite.git	A minimalist, containerized CLI tool to rapidly scan Git repositories for secrets, with an optional AI-powered
:::279	ctxguard	General OSINT	ctxguard	1	Go	https://github.com/zach-source/ctxguard.git	Claude Code hook that keeps secrets out of the model's context PreToolUse refusal + PostToolUse hash redaction
:::280	fathallatechops-gitleaks-action	General OSINT	gitleaks-action	1	Python	https://github.com/FathAllaTechOps/gitleaks-action.git	A GitHub action for Gitleaks, enabling easy integration of Gitleaks into your CI/CD pipelines to detect and pr
:::281	secure-cicd-pipeline	General OSINT	secure-cicd-pipeline	1	Python	https://github.com/nadiarahmadinaa/secure-cicd-pipeline.git	Secure CI/CD pipeline with automated security gates: SAST CodeQL, DAST OWASP ZAP, container scanning Triv
:::282	auto_smb	General OSINT	auto_smb	1	Python	https://github.com/cod-0xb0/auto_smb.git	a python script using shodan cli to search for authentication disabled SMB and using smbclient the script will
:::283	passiverecon-aggregator	General OSINT	PassiveRecon-Aggregator	1	Python	https://github.com/konswe/PassiveRecon-Aggregator.git	A passive asset discovery tool for mapping external IT perimeters. It aggregates data from public APIs Shodan
:::284	shodanmapper	General OSINT	ShodanMapper	1	Python	https://github.com/arieltoniatto/ShodanMapper.git	Shodan Mapper: Python tool to scan exposed services by country, city, org, or custom query. Generates CSV and 
:::285	threat-intel-auto-blocker	General OSINT	Threat-intel-auto-blocker	1	Python	https://github.com/exoshade-arch/Threat-intel-auto-blocker.git	Automated Python SOC tool: Enriches IP with AbuseIPDB, IPinfo Shodan. Blocks malicious IPs score 80 pct  via
:::286	bantay-eye	General OSINT	bantay-eye	1	Python	https://github.com/osintph/bantay-eye.git	Defensive internet exposure survey utility. Part of the OSINT-PH tool suite
:::287	censys_go	General OSINT	censys_go	1	Go	https://github.com/mar0ls/censys_go.git	Lightweight Go wrapper for Censys API enabling host search, asset discovery, and internet-wide scanning for OS
:::288	ctitool	General OSINT	ctitool	1	Python	https://github.com/SidhuK007/ctitool.git	CTI Triage CLI for SOC analysts. Enrich IPs, domains, and file hashes using multiple CTI sources RDAP, VirusT
:::289	asrar-x	General OSINT	ASRAR-X	1	HTML	https://github.com/ethicalasadd-cyber/ASRAR-X.git	Cyberpunk-style cybersecurity platform featuring OSINT, Blackbird intelligence, and penetration testing concep
:::290	home-eth0-maigret-bin-home-eth0-maigret-	General OSINT	home-eth0-maigret-bin-home-eth0-maigret-	0	-	https://github.com/eth0me/-home-eth0-maigret-bin-home-eth0-maigret-docs-home-eth0-maigret-maigret-home-eth0-maigret-pyinsta.git	Ferramenta para Osint
:::291	maigret-osint-portfolio	General OSINT	maigret-osint-portfolio	0	HTML	https://github.com/Hamza-Vigilante-Lefriqi/maigret-osint-portfolio.git	Advanced OSINT Threat Intelligence Portfolio - Maigret Framework Complete Technical Documentation
:::292	td4-osint	General OSINT	TD4-OSINT	0	-	https://github.com/jacquesimajeanraynold-jpg/TD4-OSINT.git	TD4 OSINT - Recherche par pseudo avec Sherlock, Maigret et Twint
:::293	mult-osint	General OSINT	mult-osint	0	Python	https://github.com/Ddff330/mult-osint.git	OSINT Sherlock, Maigret, Holehe, PhoneInfoga
:::294	osint-useful	General OSINT	osint-useful	0	Shell	https://github.com/Life-Is-Nothing/osint-useful.git	Ethical OSINT pack installer holehe, maigret, dnstwist, katana, gau not full 50GB arsenal
:::295	osint-harvester-web-maigret	General OSINT	OSINT-Harvester-Web-Maigret	0	HTML	https://github.com/luissiko/OSINT-Harvester-Web-Maigret.git	Maigret es una herramienta OSINT de lnea de comandos utilizada para buscar la presencia pblica de un nombre de
:::296	rapport_td4	General OSINT	Rapport_TD4	0	-	https://github.com/jacquesimajeanraynold-jpg/Rapport_TD4.git	TD4 OSINT - Recherche par pseudo avec Sherlock, Maigret et Twint
:::297	nunchi	General OSINT	nunchi	0	Python	https://github.com/Siwoo4985/nunchi.git	Nunchi OSINT Korean-focused fork of Maigret
:::298	osint-search	General OSINT	Osint-Search	0	Python	https://github.com/alexcaussades/Osint-Search.git	Recherche des e-mails/users sur diffrents sites internet
:::299	fanlandy	General OSINT	fanlandy	0	Python	https://github.com/kotoedoff/fanlandy.git	Advanced OSINT investigation platform with 11+ integrated tools Maigret, Sherlock, Holehe, GHunt, Blackbird, 
:::300	danizplayz-userrecon	General OSINT	userrecon	0	Shell	https://github.com/DanizPlayz/userrecon.git	userrecon tool
:::301	hello	General OSINT	hello	0	-	https://github.com/kingyaser/hello.git	Edit userrecon
:::302	findm3h-beta-1	General OSINT	FindM3H-Beta-1	0	-	https://github.com/Sckreptikus/FindM3H-Beta-1.git	Modified Version Of UserRecon
:::303	hacker213-userrecon	General OSINT	userrecon	0	Shell	https://github.com/hacker213/userrecon.git	This is a project by TheLinuxChoice. This repo was removed so I have uploaded it here
:::304	iampasindu-userrecon	General OSINT	userrecon	0	Shell	https://github.com/iampasindu/userrecon.git	CODING LAB SL
:::305	xianca596-userrecon	General OSINT	userrecon	0	-	https://github.com/Xianca596/userrecon.git	untuk mengetahui
:::306	zaba-235-userrecon	General OSINT	userrecon	0	-	https://github.com/zaba-235/userrecon.git	Bir projem var
:::307	userreconciliationtool	General OSINT	userreconciliationtool	0	HTML	https://github.com/MA2026-FEB/userreconciliationtool.git	URT - User Reconciliation Tool
:::308	pawankumarpandit-ghunt	General OSINT	GHunt	0	Python	https://github.com/PawanKumarPandit/GHunt.git	Offensive Google framework
:::309	tar-zxvf-phoneinfoga_linux_x86_64-tar-gz	General OSINT	tar--zxvf-PhoneInfoga_Linux_x86_64.tar.g	0	-	https://github.com/badbiyy/tar--zxvf-PhoneInfoga_Linux_x86_64.tar.gz.git	/phoneinfoga scan -n +905366608850
:::310	https-github-com-sundowndev-phoneinfoga-	General OSINT	https-github.com-sundowndev-phoneinfoga.	0	-	https://github.com/ary75/https-github.com-sundowndev-phoneinfoga.git.io.git	phoneinfoga.git.io
:::311	phoneinfoga-sa	General OSINT	phoneinfoga-sa	0	-	https://github.com/SteeloARMY/phoneinfoga-sa-.git	PhoneinfogaSA by Steelo
:::312	guru3943-ipdrone	General OSINT	ipdrone	0	-	https://github.com/Guru3943/ipdrone.git	apt-get update -y apt-get upgrade -y pkg install python -y pkg install python2 -y pkg install git -y pip insta
:::313	ipdrone-ip-tracker	General OSINT	Ipdrone-IP-tracker	0	-	https://github.com/Shaiksarfaraz00121/Ipdrone-IP-tracker.git	You can track someone by using termux
:::314	geolocate	General OSINT	geolocate	0	-	https://github.com/666xyzw/geolocate.git	A CLI client for ipgeolocation.io
:::315	theharvester-osint-lab	General OSINT	theharvester-osint-lab	0	-	https://github.com/saniyabutoolfatima-lgtm/theharvester-osint-lab.git	Performed OSINT reconnaissance using TheHarvester to collect emails, subdomains, and hosts
:::316	uchihashahin01-theharvester-automation-s	General OSINT	TheHarvester-Automation-Script	0	Python	https://github.com/uchihashahin01/TheHarvester-Automation-Script.git	TheHarvester Automation Script automates the use of TheHarvester, a tool for gathering emails, subdomains, IPs
:::317	osint-photon-lite	General OSINT	osint-photon-lite	0	Python	https://github.com/agent-obe/osint-photon-lite.git	Lightweight OSINT-style crawler inspired by Photon, with a safe demo
:::318	r4gn4r0ek-spiderfoot	General OSINT	Spiderfoot	0	-	https://github.com/r4gn4r0ek/Spiderfoot.git	Spiderfoot free
:::319	sfp_twitch	General OSINT	sfp_Twitch	0	-	https://github.com/Maelagon/sfp_Twitch.git	modulo spiderfoot
:::320	mdjavedhusain014-cmd-spiderfoot	General OSINT	spiderfoot	0	-	https://github.com/mdjavedhusain014-cmd/spiderfoot.git	Panel for free fire
:::321	gold1029-spiderfoot	General OSINT	Spiderfoot	0	Python	https://github.com/gold1029/Spiderfoot.git	SpiderFoot, the open source footprinting and intelligence-gathering tool
:::322	baisakkg-spiderfoot	General OSINT	spiderfoot	0	-	https://github.com/BaisakKG/spiderfoot.git	Passive analysis of digital assets
:::323	twitter_sentiment_analysis	General OSINT	Twitter_sentiment_analysis	0	Python	https://github.com/NorekAkrobata/Twitter_sentiment_analysis.git	Twint, nltk, textblob, vader
:::324	ricardperez-webextractor	General OSINT	WebExtractor	0	PHP	https://github.com/ricardperez/WebExtractor.git	A PHP library that will allow you to get data from websites like if they had a REST API
:::325	subdomainrecon	General OSINT	subdomainRecon	0	Shell	https://github.com/medicenr4z0r/subdomainRecon.git	Este script automatiza la recoleccin de subdominios utilizando mltiples herramientas populares Findomain, Sub
:::326	sonamkhadka-sublist3r	General OSINT	Sublist3r	0	Python	https://github.com/Sonamkhadka/Sublist3r.git	Enumerate subdomains of websites using OSINT
:::327	r3k1ng-sublist3r	General OSINT	Sublist3r	0	Python	https://github.com/R3K1NG/Sublist3r.git	Fast subdomains enumeration tool for penetration testers
:::328	lukifox-sublist3r	General OSINT	Sublist3r	0	Python	https://github.com/lukifox/Sublist3r.git	Fast subdomains enumeration tool for penetration testers
:::329	checksubdomains	General OSINT	checksubdomains	0	Go	https://github.com/spudtrooper/checksubdomains.git	Finds HTTP-reachabe subdomains of a given host using sublist3r
:::330	cybersphinix-subenum	General OSINT	subenum	0	-	https://github.com/cybersphinix/subenum.git	This script is combined tools like Sublist3r, amass, assetfinder,subfinder to find the subdomains and sort uni
:::331	subgather	General OSINT	subgather	0	Shell	https://github.com/brunosergi/subgather.git	Automation script that searches subdomains with Amass, Assetfinder, Crts.sh, Findomain, Subfinder, Sublist3r, 
:::332	hakmgr-dnsrecon	General OSINT	dnsrecon	0	-	https://github.com/hakmgr/dnsrecon.git	Security tool installation guide and Docker setup for dnsrecon
:::333	dnsreconhecimento	General OSINT	DnsReconhecimento	0	Shell	https://github.com/ricardoazev/DnsReconhecimento.git	Ferramenta Pentest em Bash
:::334	dnsrecon-macos	General OSINT	DNSrecon-MacOS	0	-	https://github.com/jacixrc/DNSrecon-MacOS.git	How do I add dnsrecon to my mac os when terminal tells me that they are unable to locate a java runtime that s
:::335	quickdnsreconscript	General OSINT	QuickDNSReconScript	0	Python	https://github.com/lestrella1991/QuickDNSReconScript.git	Python script for getting endpoints names in a cidr
:::336	harvester-dnsrecon-consolidator	General OSINT	Harvester-dnsRecon-Consolidator	0	Python	https://github.com/Business1sg00d/Harvester-dnsRecon-Consolidator.git	Take json files in Harvester output directory and dnsrecon directory; combine into an HTML file displaying dom
:::337	simple-zone-transfer-script-1	General OSINT	Simple-Zone-Transfer-Script-1	0	Shell	https://github.com/FuzzyLogick/Simple-Zone-Transfer-Script-1.git	Me practicing Bash. Might be useful to someone, but dnsrecon can do more
:::338	cyb34punk-sn0int	General OSINT	Sn0int	0	Rust	https://github.com/cyb34punk/Sn0int.git	Semi-automatic OSINT framework and package manager
:::339	mrholmes	General OSINT	MrHolmes	0	Python	https://github.com/anknpolley123/MrHolmes.git	Mr.Holmes a powerful osint tool developed by Lucksi but fixed errors by Ankon Polley
:::340	pavan-123-tech-trape	General OSINT	Trape	0	Python	https://github.com/Pavan-123-tech/Trape.git	People tracker on the Internet: Learn to track the world, to avoid being traced
:::341	trapex-app	General OSINT	trapex-app	0	JavaScript	https://github.com/shareefahbalogun-ctrl/trapex-app.git	A simple expense tracker app to track daily spending and budgets
:::342	archseek	General OSINT	Archseek	0	Go	https://github.com/Jevil36239/Archseek.git	**Automated archival scraping** for researchers, bughunters, and digital historians
:::343	shodancli	General OSINT	ShodanCli	0	Python	https://github.com/sputnicyes/ShodanCli.git	Ferramenta de Busca que utiliza o Shodan.io como seu motor de busca, foi criada em Python para facilitar seu u
:::344	shodan	General OSINT	shodan	0	Go	https://github.com/R0X4R/shodan.git	A Go alternative for the Shodan Python CLI
:::345	shodan-python-cli	General OSINT	shodan-python-cli	0	-	https://github.com/aiHgithub/shodan-python-cli.git	shodan-python-cli-updated
:::346	shodan-python-cli-with-menu	General OSINT	shodan-python-cli-with-menu	0	Python	https://github.com/smartersec/shodan-python-cli-with-menu.git	A Shodan script written in Python with a menu for easy searching
:::347	shodan-http-client	General OSINT	shodan-http-client	0	Python	https://github.com/jim3/shodan-http-client.git	A lightweight Python command-line interface for interacting with the Shodan API
:::348	vulnerabilitygrabber	General OSINT	vulnerabilitygrabber	0	Python	https://github.com/sapphiregraphics/vulnerabilitygrabber.git	Python CLI with Shodan API to list vulnerable devices from danish ISPs
:::349	argusscan	General OSINT	argusscan	0	Python	https://github.com/digenaldo/argusscan.git	Ethical Pentest Automation using Shodan API for cybersecurity professionals
:::350	soc-alert-triage-engine	General OSINT	soc-alert-triage-engine	0	Python	https://github.com/alisterrodrigues/soc-alert-triage-engine.git	Python CLI that ingests alerts from CSV, Splunk, or Elasticsearch; enriches source IPs via VirusTotal and Shod
:::351	censys-cli	General OSINT	censys-cli	0	Go	https://github.com/oucema001/censys-cli.git	Command Line Client for censys written in GO
:::352	censyssearchcli_v02	General OSINT	CensysSearchCLI_v02	0	Python	https://github.com/rikyeah/CensysSearchCLI_v02.git	CLI for querying Censys Search v2 using official APIs, with a browser-based fallback to bypass Cloudflare Turn
:::353	censys-kv-test-client	General OSINT	censys-kv-test-client	0	Go	https://github.com/augustoapg/censys-kv-test-client.git	Service that tests kv-store for Censys take home exercise
:::354	iconhash-skills	General OSINT	iconhash-skills	0	Go	https://github.com/cyberspacesec/iconhash-skills.git	Favicon hash calculator for cyber-space mapping supports SKILLS, CLI, Go SDK, MCP/API integration. Calculate M
:::355	blackhisoka-blackbird	General OSINT	Blackbird	0	-	https://github.com/BlackHisoka/Blackbird.git	Blackbird OSINT
:::356	name2username	General OSINT	name2username	0	Python	https://github.com/kalinathalie/name2username.git	Modified version of linkedin2username by me
:::357	linkscrap	General OSINT	LINKSCRAP	0	Python	https://github.com/LINKSCRAP/LINKSCRAP.git	A modernized fork of linkedin2username with significant improvements. Key improvements: - Playwright instead o
:::358	theharvester	Domain / DNS	theHarvester	17565	Python	https://github.com/laramies/theHarvester.git	E-mails, subdomains and names Harvester - OSINT
:::359	amass	Domain / DNS	amass	15194	Go	https://github.com/owasp-amass/amass.git	In-depth attack surface mapping and asset discovery
:::360	subfinder	Domain / DNS	subfinder	14467	Go	https://github.com/projectdiscovery/subfinder.git	Fast passive subdomain enumeration tool
:::361	bbot	Domain / DNS	bbot	10603	Python	https://github.com/blacklanternsecurity/bbot.git	The recursive internet scanner for hackers
:::362	networkmanager	Domain / DNS	NETworkManager	8775	C#	https://github.com/BornToBeRoot/NETworkManager.git	A powerful open-source tool for managing networks and troubleshooting network problems
:::363	reconftw	Domain / DNS	reconftw	8126	Shell	https://github.com/six2dez/reconftw.git	reconFTW is a tool designed to perform automated recon on a target domain by running the best set of tools to 
:::364	dnstwist	Domain / DNS	dnstwist	5740	Python	https://github.com/elceef/dnstwist.git	Domain name permutation engine for detecting homograph phishing attacks, typo squatting, and brand impersonati
:::365	knockpy	Domain / DNS	knockpy	4199	Python	https://github.com/guelfoweb/knockpy.git	Knock Subdomain Scan
:::366	ivre	Domain / DNS	ivre	4151	Python	https://github.com/ivre/ivre.git	Network recon framework. Build your own, self-hosted and fully-controlled alternatives to Shodan / ZoomEye / C
:::367	findomain	Domain / DNS	Findomain	3794	Rust	https://github.com/Findomain/Findomain.git	The fastest and complete solution for domain recognition. Supports screenshoting, port scan, HTTP check, data 
:::368	red_hawk	Domain / DNS	RED_HAWK	3759	PHP	https://github.com/Tuhinshubhra/RED_HAWK.git	All in one tool for Information Gathering, Vulnerability Scanning and Crawling. A must have tool for all penet
:::369	massdns	Domain / DNS	massdns	3645	C	https://github.com/blechschmidt/massdns.git	A high-performance DNS stub resolver for bulk lookups and reconnaissance subdomain enumeration
:::370	dnsrecon	Domain / DNS	dnsrecon	3070	Python	https://github.com/darkoperator/dnsrecon.git	DNS Enumeration Script
:::371	finalrecon	Domain / DNS	FinalRecon	2986	Python	https://github.com/thewhiteh4t/FinalRecon.git	All In One Web Recon
:::372	cloudfail	Domain / DNS	CloudFail	2687	Python	https://github.com/m0rtem/CloudFail.git	Utilize misconfigured DNS and old database records to find hidden IP's behind the CloudFlare network
:::373	sudomy	Domain / DNS	Sudomy	2434	Shell	https://github.com/screetsec/Sudomy.git	Sudomy is a subdomain enumeration tool to collect subdomains and analyzing domains performing automated reconn
:::374	cloakquest3r	Domain / DNS	CloakQuest3r	2269	Python	https://github.com/spyboy-productions/CloakQuest3r.git	Open-source security research tool for identifying origin IP exposure of websites protected by Cloudflare and 
:::375	puredns	Domain / DNS	puredns	2244	Go	https://github.com/d3mondev/puredns.git	Puredns is a fast domain resolver and subdomain bruteforcing tool that can accurately filter out wildcard subd
:::376	adalanche	Domain / DNS	Adalanche	2201	Go	https://github.com/lkarlslund/Adalanche.git	Attack Graph Visualizer and Explorer Active Directory ...Who's *really* Domain Admin?
:::377	ctfr	Domain / DNS	ctfr	2119	Python	https://github.com/UnaPibaGeek/ctfr.git	Abusing Certificate Transparency logs for getting HTTPS websites subdomains
:::378	recondog	Domain / DNS	ReconDog	2112	Python	https://github.com/s0md3v/ReconDog.git	Reconnaissance Swiss Army Knife
:::379	subdomainizer	Domain / DNS	SubDomainizer	1895	Python	https://github.com/nsonaniya2010/SubDomainizer.git	A tool to find subdomains and interesting things hidden inside, external Javascript files of page, folder, and
:::380	fierce	Domain / DNS	fierce	1814	Python	https://github.com/mschwager/fierce.git	A DNS reconnaissance tool for locating non-contiguous IP space
:::381	shuffledns	Domain / DNS	shuffledns	1671	Go	https://github.com/projectdiscovery/shuffledns.git	MassDNS wrapper written in go to enumerate valid subdomains using active bruteforce as well as resolve subdoma
:::382	scopesentry	Domain / DNS	ScopeSentry	1623	Go	https://github.com/Autumn-27/ScopeSentry.git	ScopeSentry-Cyberspace mapping, subdomain enumeration, port scanning, sensitive information discovery, vulnera
:::383	goofuzz	Domain / DNS	GooFuzz	1588	Shell	https://github.com/m3n0sd0n4ld/GooFuzz.git	GooFuzz is a tool to perform fuzzing with an OSINT approach, managing to enumerate directories, files, subdoma
:::384	anubis	Domain / DNS	anubis	1376	Python	https://github.com/jonluca/anubis.git	Subdomain enumeration tool
:::385	domain-digger	Domain / DNS	domain-digger	1349	TypeScript	https://github.com/wotschofsky/domain-digger.git	Full Toolkit for Next-Level Domain Analysis
:::386	recon-skills	Domain / DNS	recon-skills	1278	Python	https://github.com/uphiago/recon-skills.git	Recon pentest skill pack. CORS, XSS, SQLi, SSRF, RCE, WordPress, MCP, cloud, subdomain takeover, and more. Fie
:::387	scilla	Domain / DNS	scilla	1272	Go	https://github.com/edoardottt/scilla.git	Information Gathering tool - DNS / Subdomains / Ports / Directories enumeration
:::388	dnsgen	Domain / DNS	dnsgen	1080	Python	https://github.com/AlephNullSK/dnsgen.git	DNSGen is a powerful and flexible DNS name permutation tool designed for security researchers and penetration 
:::389	magicrecon	Domain / DNS	magicRecon	1057	Shell	https://github.com/robotshell/magicRecon.git	MagicRecon is a powerful shell script to maximize the recon and data collection process of an objective and fi
:::390	sublert	Domain / DNS	sublert	1033	Python	https://github.com/yassineaboukir/sublert.git	Sublert is a security and reconnaissance tool which leverages certificate transparency to automatically monito
:::391	opensquat	Domain / DNS	opensquat	985	Python	https://github.com/atenreiro/opensquat.git	openSquat is an open-source tool that detects look-alike domains impersonating your brand, by scanning newly r
:::392	subscraper	Domain / DNS	subscraper	976	Python	https://github.com/m8sec/subscraper.git	Subdomain and target enumeration tool built for offensive security testing
:::393	skanuvaty	Domain / DNS	skanuvaty	930	Rust	https://github.com/Esc4iCEscEsc/skanuvaty.git	Dangerously fast DNS/network/port scanner
:::394	censys-subdomain-finder	Domain / DNS	censys-subdomain-finder	846	Python	https://github.com/christophetd/censys-subdomain-finder.git	Perform subdomain enumeration using the certificate transparency logs from Censys
:::395	garud	Domain / DNS	Garud	810	Shell	https://github.com/R0X4R/Garud.git	An automation tool that scans sub-domains, sub-domain takeover, then filters out XSS, SSTI, SSRF, and more inj
:::396	subdominator	Domain / DNS	Subdominator	809	Python	https://github.com/RevoltSecurities/Subdominator.git	SubDominator helps you discover subdomains associated with a target domain efficiently and with minimal impact
:::397	goohak	Domain / DNS	Goohak	743	Shell	https://github.com/1N3/Goohak.git	Automatically Launch Google Hacking Queries Against A Target Domain
:::398	xurlfind3r	Domain / DNS	xurlfind3r	722	Go	https://github.com/hueristiq/xurlfind3r.git	A command-line utility designed to discover URLs for a given domain in a simple, efficient way. It works by ga
:::399	e4gl30s1nt	Domain / DNS	E4GL30S1NT	699	Python	https://github.com/C0MPL3XDEV/E4GL30S1NT.git	E4GL30S1NT - Simple Information Gathering Tool
:::400	urlcrazy	Domain / DNS	urlcrazy	693	Ruby	https://github.com/urbanadventurer/urlcrazy.git	Generate and test domain typos and variations to detect and perform typo squatting, URL hijacking, phishing, a
:::401	cero	Domain / DNS	cero	693	Go	https://github.com/glebarez/cero.git	Scrape domain names from SSL certificates of arbitrary hosts
:::402	aiodnsbrute	Domain / DNS	aiodnsbrute	674	Python	https://github.com/blark/aiodnsbrute.git	Python 3.5+ DNS asynchronous brute force utility
:::403	xingrin	Domain / DNS	xingrin	658	TypeScript	https://github.com/yyhuni/xingrin.git	Open-source attack surface management and authorized security automation platform for asset discovery, service
:::404	ghost_eye	Domain / DNS	ghost_eye	654	Python	https://github.com/BullsEye0/ghost_eye.git	Ghost Eye Informationgathering Footprinting Scanner and Recon Tool Release. Ghost Eye is an Information Gather
:::405	sonarsearch	Domain / DNS	SonarSearch	653	Go	https://github.com/Cgboal/SonarSearch.git	A rapid API for the Project Sonar dataset
:::406	bugcrowd-levelup-subdomain-enumeration	Domain / DNS	bugcrowd-levelup-subdomain-enumeration	631	Python	https://github.com/appsecco/bugcrowd-levelup-subdomain-enumeration.git	This repository contains all the material from the talk Esoteric sub-domain enumeration techniques given at Bu
:::407	globalping	Domain / DNS	globalping	603	TypeScript	https://github.com/jsdelivr/globalping.git	A global network of probes to run network tests like ping, traceroute and DNS resolve
:::408	gpt_vuln-analyzer	Domain / DNS	GPT_Vuln-analyzer	599	Python	https://github.com/morpheuslord/GPT_Vuln-analyzer.git	Uses ChatGPT API, Bard API, and Llama2, Python-Nmap, DNS Recon, PCAP and JWT recon modules and uses the GPT3 m
:::409	nullinux	Domain / DNS	nullinux	579	Python	https://github.com/m8sec/nullinux.git	Internal penetration testing tool for Linux that can be used to enumerate OS information, domain information, 
:::410	sif	Domain / DNS	sif	577	Go	https://github.com/vmfunc/sif.git	the blazing-fast pentesting suite
:::411	dome	Domain / DNS	Dome	545	Python	https://github.com/v4d1/Dome.git	Dome - Subdomain Enumeration Tool. Fast and reliable python script that makes active and/or passive scan to ob
:::412	gotator	Domain / DNS	gotator	534	Go	https://github.com/Josue87/gotator.git	Gotator is a tool to generate DNS wordlists through permutations
:::413	webosint	Domain / DNS	WebOSINT	512	Python	https://github.com/C3n7ral051nt4g3ncy/WebOSINT.git	W3b0s1nt WebOSINT is a Python tool/script for passive Domain Intelligence gathering
:::414	silenthound	Domain / DNS	SilentHound	502	Python	https://github.com/layer8secure/SilentHound.git	Quietly enumerate an Active Directory Domain via LDAP parsing users, admins, groups, etc
:::415	ache	Domain / DNS	ache	487	Java	https://github.com/VIDA-NYU/ache.git	ACHE is a web crawler for domain-specific search
:::416	scancannon	Domain / DNS	ScanCannon	482	Shell	https://github.com/johnnyxmas/ScanCannon.git	A script for credentials-based attack surface enumeration and general reconnaissance of massive external netwo
:::417	urlextractor	Domain / DNS	URLextractor	453	Shell	https://github.com/eschultze/URLextractor.git	Information gathering website reconnaissance https://phishstats.info/
:::418	haylxon	Domain / DNS	haylxon	442	Rust	https://github.com/pwnwriter/haylxon.git	Blazing-fast tool to grab screenshots of your domain list right from terminal
:::419	arl-next	Domain / DNS	ARL-Next	438	Python	https://github.com/owl234/ARL-Next.git	ARL-Next ARL MCP
:::420	portauthority	Domain / DNS	PortAuthority	424	Java	https://github.com/aaronjwood/PortAuthority.git	A handy systems and security-focused tool, Port Authority is a very fast Android port scanner. Port Authority 
:::421	second-order	Domain / DNS	second-order	408	Go	https://github.com/mhmdiaa/second-order.git	Second-order subdomain takeover scanner
:::422	threatpinchlookup	Domain / DNS	ThreatPinchLookup	387	HTML	https://github.com/cloudtracer/ThreatPinchLookup.git	Documentation and Sharing Repository for ThreatPinch Lookup Chrome Firefox Extension
:::423	misp-modules	Domain / DNS	misp-modules	377	Python	https://github.com/MISP/misp-modules.git	Modules for expansion services, enrichment, import and export in MISP and other tools
:::424	crt-sh	Domain / DNS	crt.sh	364	Go	https://github.com/az7rb/crt.sh.git	A fast, parallel subdomain enumeration tool that queries 4 Certificate Transparency log sources simultaneously
:::425	destroyscammers	Domain / DNS	DestroyScammers	361	JavaScript	https://github.com/phishdestroy/DestroyScammers.git	Scam intelligence, phishing attribution, drainer mapping. Legal OSINT only. Public data. Real cases. For resea
:::426	recon-my-way	Domain / DNS	recon-my-way	351	C	https://github.com/ehsahil/recon-my-way.git	This repository created for personal use and added tools from my latest blog post
:::427	xrcross	Domain / DNS	XRCross	349	Shell	https://github.com/pikpikcu/XRCross.git	XRCross is a Reconstruction, Scanner, and a tool for penetration / BugBounty testing. This tool was built to t
:::428	pdlist	Domain / DNS	pdlist	335	Python	https://github.com/gnebbia/pdlist.git	A passive subdomain finder
:::429	hawk	Domain / DNS	hawk	332	Python	https://github.com/medpaf/hawk.git	Network, recon and offensive-security tool for Linux
:::430	python3-nmap	Domain / DNS	python3-nmap	318	Python	https://github.com/nmmapper/python3-nmap.git	A python 3 library which helps in using nmap port scanner. This is done by converting each nmap command into a
:::431	subdomz	Domain / DNS	SubDomz	296	Shell	https://github.com/0xPugal/SubDomz.git	An Automated Subdomain Enumeration Tool
:::432	domainstack-io	Domain / DNS	domainstack.io	291	TypeScript	https://github.com/jakejarvis/domainstack.io.git	All-in-one domain name intelligence as a service
:::433	rock-on	Domain / DNS	Rock-ON	290	Shell	https://github.com/SilverPoision/Rock-ON.git	Rock-On is a all in one Recon tool that will just get a single entry of the Domain name and do all of the work
:::434	monitorizer	Domain / DNS	Monitorizer	287	Python	https://github.com/BitTheByte/Monitorizer.git	Monitoring framework to detect and report newly found subdomains on a specific target using various scanning t
:::435	mksub	Domain / DNS	mksub	276	Go	https://github.com/trickest/mksub.git	Generate tens of thousands of subdomain combinations in a matter of seconds
:::436	garudrecon	Domain / DNS	GarudRecon	271	Shell	https://github.com/rix4uni/GarudRecon.git	GarudRecon automates domain recon with top open-source tools to discover assets, enumerate subdomains, and det
:::437	dnsmorph	Domain / DNS	dnsmorph	268	Go	https://github.com/edoardogerosa/dnsmorph.git	Domain name permutation engine written in Go
:::438	certstream-server-go	Domain / DNS	certstream-server-go	233	Go	https://github.com/d-Rickyy-b/certstream-server-go.git	This project aims to be a drop-in replacement for the certstream server by Calidog. This tool aggregates, pars
:::439	graphinder	Domain / DNS	graphinder	229	Python	https://github.com/Escape-Technologies/graphinder.git	Blazing fast GraphQL endpoints finder using subdomain enumeration, scripts analysis and bruteforce
:::440	tugarecon	Domain / DNS	tugarecon	223	Python	https://github.com/skynet0x01/tugarecon.git	TugaRecon is an advanced subdomain reconnaissance and intelligence framework built for security researchers, p
:::441	goaltdns	Domain / DNS	goaltdns	213	Go	https://github.com/subfinder/goaltdns.git	A permutation generation tool written in golang
:::442	edge	Domain / DNS	edge	188	Go	https://github.com/iknowjason/edge.git	Whois for the Cloud: Recon tool for cloud provider attribution. Supports AWS, Azure, Google, Cloudflare, and D
:::443	wi-fi_info	Domain / DNS	Wi-Fi_Info	188	Java	https://github.com/TrueMLGPro/Wi-Fi_Info.git	Powerful network toolset packed into an Android app. Gathers and displays the information about the Wi-Fi netw
:::444	udon	Domain / DNS	udon	180	Go	https://github.com/dhn/udon.git	A simple tool that helps to find assets/domains based on the Google Analytics ID
:::445	courlan	Domain / DNS	courlan	177	Python	https://github.com/adbar/courlan.git	Clean, filter and sample URLs to optimize data collection Python command-line Deduplication, spam, content and
:::446	netshark	Domain / DNS	NetShark	177	Python	https://github.com/kalachbeg/NetShark.git	All-in-one CLI security scanner: port scanning, web security, subdomain enumeration, network monitoring. Multi
:::447	subby	Domain / DNS	subby	172	Go	https://github.com/n0mi1k/subby.git	An uber fast and simple subdomain enumeration tool using DNS and web requests with support for detecting wildc
:::448	mcp-shodan	Domain / DNS	mcp-shodan	172	TypeScript	https://github.com/w0h1v/mcp-shodan.git	MCP server for Shodan search internet-connected devices, IP reconnaissance, DNS lookups, and CVE/CPE vulnerabi
:::449	sub-monitor	Domain / DNS	sub.Monitor	172	Python	https://github.com/e1abrador/sub.Monitor.git	Self-hosted passive subdomain continous monitoring tool
:::450	url-shorteners	Domain / DNS	url-shorteners	170	Shell	https://github.com/PeterDaveHello/url-shorteners.git	A comprehensive, high-quality URL shorteners domain list for whitelist/allowlist or blacklist/blocklist purpos
:::451	merklemap-cli	Domain / DNS	merklemap-cli	168	Rust	https://github.com/Merklemap/merklemap-cli.git	Discover and enumerate all subdomains associated with a website, including those not publicly advertised. Use 
:::452	dpulse	Domain / DNS	dpulse	167	Python	https://github.com/OSINT-TECHNOLOGIES/dpulse.git	DPULSE - Tool for complex approach to domain OSINT
:::453	infohound	Domain / DNS	InfoHound	163	Python	https://github.com/Fundacio-i2CAT/InfoHound.git	InfoHound is an OSINT to extract a large amount of data given a web domain name
:::454	sqlmutant	Domain / DNS	SQLMutant	163	Shell	https://github.com/blackhatethicalhacking/SQLMutant.git	SQLMutant is a powerful SQL injection testing tool that includes both passive and active reconnaissance proces
:::455	webstor	Domain / DNS	webstor	157	Python	https://github.com/RossGeerlings/webstor.git	WebStor efficiently enumerates all websites across your organizations networks and those in your DNS records -
:::456	subzuf	Domain / DNS	subzuf	156	Python	https://github.com/elceef/subzuf.git	a smart DNS response-guided subdomain fuzzer
:::457	eagleosint	Domain / DNS	EagleOsint	154	Python	https://github.com/retr0-g04t/EagleOsint.git	EagleOsint - Simple Information Gathering Tool
:::458	scriptkiddi3	Domain / DNS	scriptkiddi3	152	Shell	https://github.com/thecyberneh/scriptkiddi3.git	Streamline your recon and vulnerability detection process with SCRIPTKIDDI3, A recon and initial vulnerability
:::459	namesilo-evidence	Domain / DNS	namesilo-evidence	152	HTML	https://github.com/phishdestroy/namesilo-evidence.git	NameSilo IANA #1479 registrar abuse investigation 5,281,151 domains scanned, 204,460 classified IOC 122,119
:::460	eternalview	Domain / DNS	EternalView	151	Shell	https://github.com/rpranshu/EternalView.git	EternalView is an all in one basic information gathering and vulnerability assessment tool
:::461	pentesting-framework	Domain / DNS	pentesting-framework	149	Shell	https://github.com/ankushbhagats/pentesting-framework.git	Pentesting Framework is a bundle of penetration testing tools, Includes - security, pentesting, hacking and ma
:::462	bass	Domain / DNS	bass	148	Python	https://github.com/Abss0x7tbh/bass.git	Bass grabs you those extra resolvers you are missing out on when performing Active DNS enumeration. Add anywhe
:::463	certstreammonitor	Domain / DNS	CertStreamMonitor	148	Python	https://github.com/AssuranceMaladieSec/CertStreamMonitor.git	Monitor certificates generated for specific domain strings and associated, store data into sqlite3 database, a
:::464	scoptix	Domain / DNS	scoptix	147	TypeScript	https://github.com/Omnitarium/scoptix.git	Open-source passive reconnaissance and exposure discovery tool that leverages VirusTotal and the Wayback Machi
:::465	bevigil-osint-cli	Domain / DNS	BeVigil-OSINT-CLI	144	Python	https://github.com/Bevigil/BeVigil-OSINT-CLI.git	bevigil-cli provides a unified command line interface and python library for using BeVigil OSINT API
:::466	qbitseclabs-osint	Domain / DNS	osint	140	Shell	https://github.com/qbitseclabs/osint.git	Docker image for osint
:::467	horn3t	Domain / DNS	Horn3t	137	Python	https://github.com/JannisKirschner/Horn3t.git	Powerful Visual Subdomain Enumeration at the Click of a Mouse
:::468	chomtesh	Domain / DNS	chomtesh	136	Shell	https://github.com/mr-rizwan-syed/chomtesh.git	CHOMTE.SH is a powerful shell script designed to automate reconnaissance tasks during penetration testing. It 
:::469	certeagle	Domain / DNS	CertEagle	135	Python	https://github.com/devanshbatham/CertEagle.git	Weaponizing Live CT logs for automated monitoring ofassets
:::470	dnsanity	Domain / DNS	dnsanity	134	Go	https://github.com/nil0x42/dnsanity.git	High-performance DNS validator using template-based verification
:::471	shortdot-evidence	Domain / DNS	shortdot-evidence	131	Python	https://github.com/phishdestroy/shortdot-evidence.git	ShortDot SA zone abuse evidence 6,242,647 domains across .icu, .bond, .cyou, .sbs, .cfd, .buzz, .qpon. 237,894
:::472	s3dns	Domain / DNS	s3dns	129	Python	https://github.com/olizimmermann/s3dns.git	Find S3 AWS/GCP/Azure buckets while surfing. S3DNS acts as DNS server, follows CNAMEs and matches any bucket p
:::473	sd-goo	Domain / DNS	sd-goo	127	Shell	https://github.com/darklotuskdb/sd-goo.git	Enumerate Subdomains Through Google Dorks Bypassed Page Filter
:::474	dnsbruter	Domain / DNS	Dnsbruter	127	Python	https://github.com/RevoltSecurities/Dnsbruter.git	Dnsbruter is a powerful tool designed to perform active subdomain enumeration and discovery. It uses DNS resol
:::475	ok-vps	Domain / DNS	OK-VPS	123	Shell	https://github.com/mrco24/OK-VPS.git	Bug Bounty Vps Setup Tools
:::476	rdwatool	Domain / DNS	RDWAtool	122	Python	https://github.com/p0dalirius/RDWAtool.git	A python script to extract information from a Microsoft Remote Desktop Web Access RDWA application
:::477	yotter	Domain / DNS	yotter	121	Shell	https://github.com/b3rito/yotter.git	yotter - bash script that performs recon and then uses dirb to discover directories that might lead to informa
:::478	xsubfind3r	Domain / DNS	xsubfind3r	119	Go	https://github.com/hueristiq/xsubfind3r.git	A command-line utility designed to discover subdomains for a given domain in a simple, efficient way. It works
:::479	sub-drill	Domain / DNS	Sub-Drill	117	Shell	https://github.com/Fadavvi/Sub-Drill.git	A very very FAST and simple subdomain finder based on online free services. Without any configuration requir
:::480	vita	Domain / DNS	vita	112	Rust	https://github.com/junnlikestea/vita.git	A tool to find subdomains or domains from passive sources
:::481	subevil	Domain / DNS	SubEvil	111	Python	https://github.com/Evil-Twins-X/SubEvil.git	SubEvil is an advanced open source intelligence framework OSINT for grouping subdomains
:::482	subdover	Domain / DNS	subdover	111	Python	https://github.com/PushpenderIndia/subdover.git	Subdover is a MultiThreaded Subdomain Takeover Vulnerability Scanner Written In Python3
:::483	zenbuster	Domain / DNS	zenbuster	107	Python	https://github.com/0xTas/zenbuster.git	Multi-threaded URL enumeration/content-discovery tool in Python
:::484	offensive-pentesting-scripts	Domain / DNS	Offensive-Pentesting-Scripts	106	Python	https://github.com/InfoSecWarrior/Offensive-Pentesting-Scripts.git	Scripts that are intended to help you in your pen-testing and bug-hunting efforts by automating various manual
:::485	crtsh	Domain / DNS	crtsh	97	Python	https://github.com/YashGoti/crtsh.git	A Python Script to Get Subdomain using https://crt.sh
:::486	bugscanx	Domain / DNS	BugScanX	81	Python	https://github.com/FreeNetLabs/BugScanX.git	bughost scanner
:::487	subdomains-sh	Domain / DNS	subdomains.sh	80	Shell	https://github.com/enenumxela/subdomains.sh.git	A wrapper around tools used for subdomain enumeration, to automate the workflow, on a given domain, written in
:::488	subcert	Domain / DNS	Subcert	79	Python	https://github.com/A3h1nt/Subcert.git	Subcert is a subdomain enumeration tool, that finds all the subdomains from certificate transparency logs
:::489	goblyn	Domain / DNS	Goblyn	74	Python	https://github.com/loseys/Goblyn.git	Goblyn is a Python tool focused to enumeration and capture of website files metadata
:::490	subdomainsenumerator	Domain / DNS	subdomainsEnumerator	71	Shell	https://github.com/Anon-Exploiter/subdomainsEnumerator.git	A docker image which will enumerate, sort, unique and resolve the results of various subdomains enumeration to
:::491	subdomain-scanner	Domain / DNS	subdomain-scanner	70	Go	https://github.com/fengdingbo/subdomain-scanner.git	subdomain-scanner is a subdomain discovery tool that discovers valid subdomains for websites
:::492	subdog	Domain / DNS	subdog	69	Go	https://github.com/rix4uni/subdog.git	A powerful subdomain enumeration tool that aggregates data from multiple sources to create comprehensive lists
:::493	dark_web-py	Domain / DNS	dark_web.py	69	Python	https://github.com/akashblackhat/dark_web.py.git	Dark Web Informationgathering Footprinting Scanner and Recon Tool Release. Dark Web is an Information Gatherin
:::494	substr3am	Domain / DNS	Substr3am	68	Python	https://github.com/nexxai/Substr3am.git	Passive reconnaissance/enumeration of interesting targets by watching for SSL certificates being issued
:::495	lazygrandma	Domain / DNS	lazyGrandma	67	Shell	https://github.com/AhmedConstant/lazyGrandma.git	a shell script aim to automatically launch 50+ online web scanning tools in the Browsaer against a target doma
:::496	domainthreat	Domain / DNS	domainthreat	67	Python	https://github.com/PAST2212/domainthreat.git	Newly registered Domain Monitoring to detect phishing and brand impersonation with subdomain enumeration and s
:::497	wildcheck	Domain / DNS	wildcheck	64	Go	https://github.com/theblackturtle/wildcheck.git	A simple tool to detect wildcards domain based on Amass's wildcards detector
:::498	huntthebug	Domain / DNS	HuntTheBug	60	Shell	https://github.com/vikrantbatra05/HuntTheBug.git	Advanced reconnaissance framework for bug bounty hunters - Automate subdomain enumeration, vulnerability scann
:::499	0x0p1n3r	Domain / DNS	0x0p1n3r	57	Python	https://github.com/z3dc0ps/0x0p1n3r.git	0x0p1n3r is set of combination of other tools and one line scripts to find subdomains easily and to check subd
:::500	subscan	Domain / DNS	subscan	54	Rust	https://github.com/eredotpkfr/subscan.git	A subdomain enumeration tool leveraging diverse techniques, designed for advanced pentesting operations
:::501	certina	Domain / DNS	certina	53	Python	https://github.com/n0mi1k/certina.git	Certina is an OSINT tool for red teamers and bug hunters to discover subdomains from web certificate data
:::502	bug-bounty-script	Domain / DNS	Bug-Bounty-Script	43	Shell	https://github.com/shubham-rooter/Bug-Bounty-Script.git	Bug-hunting Automation
:::503	saas_enum	Domain / DNS	saas_enum	42	Python	https://github.com/HackingLZ/saas_enum.git	Command-line tool for discovering SaaS platforms a company uses via DNS enumeration
:::504	lar	Domain / DNS	LAR	40	Python	https://github.com/west-wind/LAR.git	Light Armoured Recon is a python script designed to automate passive recon. It automates execution of TheHarve
:::505	whour	Domain / DNS	whoUR	34	Python	https://github.com/jopcode/whoUR.git	Tool for information gathering, IPReverse, AdminFInder, DNS, WHOIS, SQLi Scanner with google
:::506	netool-toolkit-downloader-installer	Domain / DNS	netool-toolkit-downloader-installer	31	Shell	https://github.com/mr-wassim/netool-toolkit-downloader-installer.git	Operative Systems Suported are: Linux-ubuntu, kali-linux, backtack-linux un-continued, freeBSD, Mac osx un-
:::507	adamsrecon	Domain / DNS	AdamsRecon	27	Python	https://github.com/hehacksdark/AdamsRecon.git	AdamsScan is an automated subdomain enumeration script that utilizes multiple popular tools and APIs like Subl
:::508	subdomainx	Domain / DNS	subdomainx	27	Go	https://github.com/itszeeshan/subdomainx.git	Subdomain enumeration reconnaissance framework for bug bounty and pentesting 20+ tools APIs, HTTP fingerprinti
:::509	webanalyzer	Domain / DNS	WebAnalyzer	24	Python	https://github.com/frkndncr/WebAnalyzer.git	WebAnalyzer is a versatile tool for comprehensive domain analysis. It provides insights into WHOIS data, DNS r
:::510	subscan4	Domain / DNS	Subscan4	24	Shell	https://github.com/drak3hft7/Subscan4.git	Script that performs a scan of a specific domain, using the following tools: Subfinder, assetfinder, amass and
:::511	subtron	Domain / DNS	subtron	24	Shell	https://github.com/cyb3ratul/subtron.git	Subtron is a professional grade subdomain enumeration toolkit designed for security researchers, penetration t
:::512	ghosthunter	Domain / DNS	GhostHunter	22	Go	https://github.com/Mysteriza/GhostHunter.git	GhostHunter is a powerful and user-friendly tool designed to uncover hidden treasures from the Wayback Machine
:::513	dsat-dnssecurityanalysistool	Domain / DNS	DSAT-DNSSecurityAnalysisTool	20	Python	https://github.com/shamimrezasohag/DSAT-DNSSecurityAnalysisTool.git	The DNS Security Analysis Tool is a Python-based utility designed to conduct an in-depth security analysis of 
:::514	detecti-cli	Domain / DNS	DetecTI-CLI	20	Python	https://github.com/detectisec/DetecTI-CLI.git	DetecTI-CLI is a high-performance Python 3.11+ CLI tool designed for External Attack Surface Management EASM
:::515	subr3con	Domain / DNS	SubR3con	18	Python	https://github.com/rohitcoder/SubR3con.git	SubR3con is a script written in python. It uses Sublist3r to enumerate all subdomains of a specific target and
:::516	namescraper	Domain / DNS	NameScraper	18	Python	https://github.com/Macmod/NameScraper.git	A Selenium scraper for public domain search tools
:::517	pentest	Domain / DNS	Pentest	17	Python	https://github.com/strmrider/Pentest.git	Cybersecurity ethical hacking library and app
:::518	sparshkulshrestha-lazyrecon	Domain / DNS	LazyRecon	16	Python	https://github.com/sparshkulshrestha/LazyRecon.git	Subdomain discovery using Sublist3r, certspotter, crt.sh , censys and amass . Subdomain bruteforcing using Gob
:::519	submonitor	Domain / DNS	submonitor	14	Go	https://github.com/xpl0ited1/submonitor.git	Subdomain monitor with reporting capabilities to Slack, Discord and Telegram
:::520	pentest-1-introduction-to-pentesting-and	Domain / DNS	pentest-1-Introduction-to-Pentesting-and	12	-	https://github.com/Vanessapan001/pentest-1-Introduction-to-Pentesting-and-OSINT.git	this topic includes Reconnaissance and planning, Google Dorking, certificate transparency, shodan recon-ng
:::521	subzero	Domain / DNS	subzero	12	Python	https://github.com/t0thkr1s/subzero.git	Passive subdomain enumeration tool for bug-bounty hunters penetration testers
:::522	subfind3r	Domain / DNS	Subfind3r	12	Python	https://github.com/ASafarzadeh/Subfind3r.git	An improved version of Sublist3r, a python based Fast subdomains enumeration tool for penetration testers
:::523	shield-eye-core	Domain / DNS	Shield-Eye-Core	11	Python	https://github.com/exiv703/Shield-Eye-Core.git	Network security scanner. Nmap-powered port scanning, CMS detection with live CVE lookup CIRCL, security hea
:::524	huntsman	Domain / DNS	Huntsman	11	Python	https://github.com/Import3r/Huntsman.git	a python script that automates recon flow for a given target domain
:::525	recon-ng_reddit	Domain / DNS	Recon-ng_Reddit	10	Python	https://github.com/t94j0/Recon-ng_Reddit.git	Reddit domain search module for Recon-ng
:::526	rexc0n	Domain / DNS	rexC0n	10	Shell	https://github.com/Wahid-najim/rexC0n.git	Powerful Bash-based subdomain enumeration tool for recon, bug bounty, and red teaming integrates Subfinder, Am
:::527	bash	Domain / DNS	bash	10	Shell	https://github.com/hc-liang/bash.git	bash for find subdomainsubdinder+amass+onefoall
:::528	dns_port	Domain / DNS	DNS_PORT	9	Python	https://github.com/Leoid/DNS_PORT.git	Subdomain Brute Forcing and Port Scanning for each live host [recon-ng module][beta]
:::529	claritysec-amass	Domain / DNS	amass	9	Go	https://github.com/claritysec/amass.git	Subdomain and Host Enumeration
:::530	subfinder-gui	Domain / DNS	subfinder-GUI	9	JavaScript	https://github.com/aaravshah1311/subfinder-GUI.git	Subfinder-GUI is a graphical user interface GUI version of the popular subfinder tool, designed to find subd
:::531	untimsubs	Domain / DNS	untimSubs	8	Python	https://github.com/thenurhabib/untimSubs.git	It makes easy to use all subdomain enumeration with all popular tools
:::532	advanced_port_os_scanner	Domain / DNS	Advanced_Port_OS_Scanner	7	Python	https://github.com/chromeheartbeat/Advanced_Port_OS_Scanner.git	An advanced Python-based port scanner that supports: TCP Connect scan 065535 SYN scan stealth, Nmap-style -
:::533	r3con-x	Domain / DNS	R3CON-X	7	Python	https://github.com/saurabhsingh-26/R3CON-X.git	R3CON-X is a Python-based automated recon tool for bug bounty hunters and security researchers. It performs su
:::534	dns-recon-dns-redteaming	Domain / DNS	dns-recon-dns-redTeaming	7	Python	https://github.com/hack-with-ethics/dns-recon-dns-redTeaming.git	This is a Python script that provides the ability to perform: Check all NS Records for Zone Transfers. Enumera
:::535	webpys	Domain / DNS	Webpys	6	Python	https://github.com/pugazhexploit/Webpys.git	WebPyX is a powerful passive recon and vulnerability scanner built in Python. Performs SSL analysis, header au
:::536	autonetix	Domain / DNS	Autonetix	6	Shell	https://github.com/G4sul1n/Autonetix.git	Automatic script for subdomain enumeration and vulnerability scanning using Acunetix API
:::537	recon_framework	Domain / DNS	recon_framework	6	HTML	https://github.com/adlbrhm/recon_framework.git	A professional, real-time reconnaissance dashboard for automated subdomain enumeration, DNS validation, and li
:::538	advanced-web-scrapping-tool	Domain / DNS	Advanced-Web-Scrapping-Tool	6	Python	https://github.com/ANONYMOUSx46/Advanced-Web-Scrapping-Tool.git	A web-scrapping-tool I built to automate the process of web recon with advanced techniques, ready to use in yo
:::539	tumblrblognetworkenumeration	Domain / DNS	TumblrBlogNetworkEnumeration	5	-	https://github.com/hackerlawyer/TumblrBlogNetworkEnumeration.git	Due to it taking 2 1/2 days to perform subdomain enumeration on the Tumblr Blog Network I have decided to post
:::540	dnspeek	Domain / DNS	dnspeek	5	Go	https://github.com/Neved4/dnspeek.git	Fast DNS recon in Go
:::541	faciltech-dnsrecon	Domain / DNS	dnsrecon	4	Shell	https://github.com/faciltech/dnsrecon.git	Um programa para verificar endereos DNS de um domnio, tentar a transferncia e coletar algumas informaes, como 
:::542	scanct	Domain / DNS	scanct	4	Go	https://github.com/rgwohlbold/scanct.git	Use Certificate Transparency Logs to find Jenkins and GitLab instances containing secrets
:::543	python3-libraccoon	Domain / DNS	python3-libraccoon	3	Python	https://github.com/nmmapper/python3-libraccoon.git	libraccon a library for high performance offensive security tool for reconnaissance based on raccoon scanner. 
:::544	subdomain-enumeration-script	Domain / DNS	Subdomain-Enumeration-Script	3	Shell	https://github.com/LavSarkari/Subdomain-Enumeration-Script.git	SubEnum v2.0 - A fast and powerful subdomain enumeration script that combines multiple tools Sublist3r, Amass
:::545	bucketeer	Domain / DNS	bucketeer	3	Python	https://github.com/abhaybhargav/bucketeer.git	Bucketeer is a small script that builds off the useful Sublist3r tool. The Tool tries to identify S3 Buckets a
:::546	slackmass	Domain / DNS	SlackMass	3	Shell	https://github.com/Prune2000/SlackMass.git	Scripting subdomain enumeration with Amass with slack alerts
:::547	as-recon-subdomain-tool	Domain / DNS	as-recon-subdomain-tool	3	Python	https://github.com/hakspare/as-recon-subdomain-tool.git	High-Speed Subdomain Enumeration Automated Recon Tool for Bug Bounty Hunters. Amass Alternative
:::548	snwfdhmp-dnsrecon	Domain / DNS	dnsrecon	3	Shell	https://github.com/snwfdhmp/dnsrecon.git	Easy to use DNS recon tool that uses prefix dictionary
:::549	dnsrecord	Domain / DNS	dnsrecord	3	Python	https://github.com/zerbaliy3v/dnsrecord.git	Fuzz dns records and scan accord record type
:::550	full-fledged-network	Domain / DNS	Full-Fledged-Network	2	-	https://github.com/NasimBahadur/Full-Fledged-Network.git	In this project, A full-fledged network is designed for an organization with multiple subnets using CISCO pack
:::551	enterprise-network-infrastructure-cisco-	Domain / DNS	Enterprise-Network-Infrastructure-Cisco-	2	-	https://github.com/Thanhizme/Enterprise-Network-Infrastructure-Cisco-VLSM-OSPF-ACL.git	Designed a scalable enterprise network in Cisco Packet Tracer using OSPF and VLANs. Optimized IP allocation wi
:::552	risheyab	Domain / DNS	risheyab	2	Python	https://github.com/lordsmh/risheyab.git	subdomain scanner
:::553	0-1arafasuber	Domain / DNS	0.1ArafaSuber	2	Shell	https://github.com/0Arafa/0.1ArafaSuber.git	Simple Bash script that automate Subdomain Enumeration using best tools: subfinder,sublist3r,amass. And save a
:::554	custom_scripts	Domain / DNS	custom_scripts	2	Shell	https://github.com/User-404-NotFound/custom_scripts.git	A Bash automation script to perform comprehensive subdomain enumeration, live host detection and vulnerability
:::555	igorcmelo-dnsrecon	Domain / DNS	dnsrecon	2	Shell	https://github.com/igorcmelo/dnsrecon.git	Ferramenta escrita em Bash Script para reconhecimento de DNS atravs de uma lista de possveis subdomnios
:::556	uniqdnsrecon	Domain / DNS	uniqDNSrecon	2	Python	https://github.com/NayMyatMin/uniqDNSrecon.git	DNS Buffer Over Run using multiple Recon Engines and finding out the unique ones
:::557	dnsg	Domain / DNS	dnsg	2	Shell	https://github.com/sakibulalikhan/dnsg.git	Automate DNS Enumerations With DNS G
:::558	drast	Domain / DNS	DRAST	2	Python	https://github.com/ZhL0b1X/DRAST.git	DNS Record Analysis and Storage Tool
:::559	smart-domain-detector	Domain / DNS	Smart-Domain-Detector	2	TypeScript	https://github.com/smartboy223/Smart-Domain-Detector.git	Comprehensive domain reconnaissance and exposure analysis platform for SOC teams, combining passive enumeratio
:::560	shadowmap	Domain / DNS	ShadowMap	2	Python	https://github.com/D0m0x61/ShadowMap.git	From a domain or IP: subdomains, open ports, CVE scores, reputation, leaks all passive
:::561	spiderfoot-domain-to-ip	Domain / DNS	Spiderfoot-Domain-to-IP	1	Python	https://github.com/hanlec52/Spiderfoot-Domain-to-IP.git	Module to obtain IP from Domain name
:::562	active-passive-recon-lab	Domain / DNS	active-passive-recon-lab	1	-	https://github.com/VibhavChennamadhava/active-passive-recon-lab.git	Active passive reconnaissance lab using Amass, Sn1per, theHarvester, Recon-ng, Maltego, SpiderFoot, SET, and N
:::563	project-5-information-gathering-automati	Domain / DNS	Project-5---Information-Gathering-Automa	1	-	https://github.com/Jolwin-J0E/Project-5---Information-Gathering-Automation-in-Cyber-Reconnaissance-Using-Recon-ng-.git	Automated cybersecurity reconnaissance using Recon-ng by streamlining domain enumeration, DNS analysis, and WH
:::564	thelastbyte-subdomain-scanner	Domain / DNS	subdomain-scanner	1	Shell	https://github.com/thelastbyte/subdomain-scanner.git	# security-subdomain-scanner Subdomain scanner built using Kali 2.0 tools  fierce, theharvester, and recon-ng
:::565	go-recon	Domain / DNS	go-recon	1	Go	https://github.com/Yousef-G0/go-recon.git	A small Go-based command-line tool that performs basic recon on a target domain or IP. Think of it like a mini
:::566	pkcert-project2-footprinting-recon	Domain / DNS	pkcert-project2-footprinting-recon	1	-	https://github.com/DaniShahzadKhan/pkcert-project2-footprinting-recon.git	PKCERT Project 2: Footprinting Reconnaissance using Kali Linux and OSINT tools. This repository contains pract
:::567	subgram	Domain / DNS	subgram	1	Shell	https://github.com/TheFellowHacker/subgram.git	Automated tool for subdomain scanning and Telegram updates using sublist3r, subfinder, and assetfinder
:::568	ffuflist3r	Domain / DNS	ffuflist3r	1	Python	https://github.com/joshuasoftdev/ffuflist3r.git	This script will execute Sublist3r to enumerate subdomains and then use FFuF to perform fuzzing on each subdom
:::569	dnsauditor	Domain / DNS	DNSauditor	1	Python	https://github.com/gahretto/DNSauditor.git	Python leveraging BadDNS and sublist3r to audit subdomain takeover vulnerabilities on enterprise sized organiz
:::570	subdomain-discovery-with-python	Domain / DNS	Subdomain-Discovery-With-Python	1	Python	https://github.com/tb-29/Subdomain-Discovery-With-Python.git	A Python script to discover subdomains for domains listed in a text file using Sublist3r. Supports multi-threa
:::571	set	Domain / DNS	SET	1	Python	https://github.com/0xb4c/SET.git	SET helps enumerate quickly subdomains of a domain by combining the power of DNSdumpster and Sublist3r
:::572	sc0pe	Domain / DNS	sc0pe	1	JavaScript	https://github.com/zbo14/sc0pe.git	Find in-scope subdomains for bug bounty programs
:::573	sub-domain-finder	Domain / DNS	Sub-Domain-finder	1	Go	https://github.com/MihadCM/Sub-Domain-finder.git	React and Go Fiber based web tool for fast and clean subdomain enumeration using Subfinder and Sublist3r
:::574	takeme	Domain / DNS	TakeMe	1	Python	https://github.com/khireddine10/TakeMe.git	TakeMe tool is used to check if the target domain have subdomains that can be vulnerable to subdomain takeover
:::575	subsarecool	Domain / DNS	subsarecool	1	PowerShell	https://github.com/ROBSAUCE/subsarecool.git	Take subdomains from other tools like sublist3r and resolve thier dns records and output to csv for easy viewi
:::576	sidlister	Domain / DNS	Sidlister	1	Python	https://github.com/Siddharth0kumar/Sidlister.git	Sidlister: A Python-based subdomain enumeration tool leveraging Sublist3r. It provides a user-friendly CLI wit
:::577	enumax	Domain / DNS	enumax	1	Shell	https://github.com/DrW3b/enumax.git	Enumax is a simple Bash script that automates subdomain enumeration using popular tools such as sublist3r, sub
:::578	autosubrecon	Domain / DNS	AutoSubRecon	1	Shell	https://github.com/soroush44d/AutoSubRecon.git	Automated tool for subdomain enumeration combining passive and active techniques for web application penetrati
:::579	g-findit-py	Domain / DNS	G-Findit.py	1	Python	https://github.com/FulcanelliR/G-Findit.py.git	A tool to help locate files for a specific domain similar to PowerMeta or Metagoofil using a Google Custom S
:::580	mbudge-dnsrecon	Domain / DNS	dnsrecon	1	Go	https://github.com/mbudge/dnsrecon.git	RESTful API built with Go to collect sets of DNS records
:::581	lennymouzehine-dnsrecon	Domain / DNS	DNSRecon	1	Shell	https://github.com/lennymouzehine/DNSRecon.git	Domain Name System DNS Recon With DIG
:::582	neiltyagi-dnsrecon	Domain / DNS	DNSRECON	1	Python	https://github.com/neiltyagi/DNSRECON.git	Passive dns reconnaissance tool for automating forward and reverse lookup queries and generating a database
:::583	dnsreconciler	Domain / DNS	DNSReconciler	1	Go	https://github.com/Grace-Solutions/DNSReconciler.git	A single-binary, cross-platform DNS reconciliation agent. Each node detects its own reachable address and publ
:::584	network-footprinting-assessment	Domain / DNS	network-footprinting-assessment	1	-	https://github.com/PrudenceMatrix/network-footprinting-assessment.git	Authorized cybersecurity reconnaissance and footprinting assessment of Networkwalks using WHOIS, WhatWeb, Nslo
:::585	w2-pm1-footprinting-reconnaissance	Domain / DNS	W2-PM1-Footprinting-Reconnaissance	1	-	https://github.com/priyankabehera2323-debug/W2-PM1-Footprinting-Reconnaissance.git	A practical cybersecurity reconnaissance project completed using Kali Linux. Demonstrates domain footprinting,
:::586	waybackurlsscript	Domain / DNS	WaybackURLsScript	1	Python	https://github.com/vivekbhatt3011/WaybackURLsScript.git	WaybackURLs-Python is a script that retrieves archived URLs of a given domain using the Wayback Machine API. I
:::587	infeagle-recon	Domain / DNS	Infeagle-Recon	1	Shell	https://github.com/InferiorAK/Infeagle-Recon.git	Passive Recon Suite Harvest URLs, discover subdomains, filter live endpoints and extract parameters from publi
:::588	genrex-bot-reconx	Domain / DNS	Reconx	1	Python	https://github.com/genrex-bot/Reconx.git	Automated Passive + Active Reconnaissance CLI Tool subdomains, OSINT, Shodan, tech fingerprinting
:::589	osintrecon	Domain / DNS	osintrecon	1	Python	https://github.com/bastian-red/osintrecon.git	Modular Python CLI for domain OSINT reconnaissance: subdomain enumeration, DNS, WHOIS, certificate transparenc
:::590	osint-recon	Domain / DNS	osint-recon	0	Python	https://github.com/tmartin004/osint-recon.git	Combined domain OSINT recon: subdomains + emails + DNS + WHOIS. Chains: subfinder, amass, theHarvester, crt.sh
:::591	ikechukwu-ogbechie-s-network-scanning-we	Domain / DNS	IKECHUKWU-OGBECHIE-S-NETWORK-SCANNING-WE	0	-	https://github.com/Apexike/IKECHUKWU-OGBECHIE-S-NETWORK-SCANNING-WEEK-2-PROJECT-MODULE-4-BATCH-B083.git	theHarvester Kali is a passive OSINT tool that gathers public infoemails, subdomains, hostnames, IPsvia sear
:::592	01_information_gathering	Domain / DNS	01_Information_Gathering	0	-	https://github.com/Fisseha2424/01_Information_Gathering.git	Tools like whois, nslookup, theHarvester, Shodan, Recon-ng. Passive/active recon
:::593	subdomain-finder	Domain / DNS	SubDomain-Finder	0	Shell	https://github.com/D1rkPanther/SubDomain-Finder.git	Find Subdomain Using Amass , Sublist3r , AssetsFinder
:::594	subdomain-enum-script	Domain / DNS	subdomain-enum-script	0	Shell	https://github.com/helmutye0/subdomain-enum-script.git	Subdomain Enumeration Script glorified sublist3r wrapper
:::595	subdomain-enum2	Domain / DNS	SUBDOMAIN-ENUM2	0	Python	https://github.com/lordricckybruce/SUBDOMAIN-ENUM2.git	a subdomain enumeration tool built like sublist3r and dns request
:::596	subdomain-compiler	Domain / DNS	subdomain-compiler	0	Python	https://github.com/krisFernz26/subdomain-compiler.git	A python script that automates domain enumeration using sublist3r and assetfinder
:::597	ayoubatmani-cloud-sublist3r	Domain / DNS	Sublist3r	0	Python	https://github.com/ayoubatmani-cloud/Sublist3r.git	Subdomain Finder Version 3
:::598	sub-ce	Domain / DNS	Sub-Ce	0	Shell	https://github.com/olajidejames/Sub-Ce.git	Subdomain enumeration script using Subfinder and Sublist3r
:::599	subsearch	Domain / DNS	subsearch	0	Shell	https://github.com/kusonooyasumi/subsearch.git	very simple subdomain search, includes assetfinder subfinder sublist3r and crtsh
:::600	subdomain-enumeration	Domain / DNS	Subdomain-Enumeration	0	-	https://github.com/Manojgolla0516/Subdomain-Enumeration.git	Subdomain enumeration using Sublist3r, Gobuster, DNSRecon and Amass DNS reconnaissance and attack surface mapp
:::601	sublist3r-enumeration	Domain / DNS	Sublist3r-Enumeration	0	-	https://github.com/Adii-cyber458/-Sublist3r-Enumeration.git	Subdomain enumeration using Sublist3r tool for OSINT purposes
:::602	xvanshx-sublist3r	Domain / DNS	sublist3r	0	Python	https://github.com/xVanshx/sublist3r.git	A Basic Subdomain FInder Tool made in python
:::603	subdomain-enumartion	Domain / DNS	Subdomain-enumartion	0	Shell	https://github.com/shuvoalamin500a/Subdomain-enumartion.git	ei script diye subdomains enumartion korte hoy,subfinder,assetfinder,amass,sublist3r etc toll diye bash script
:::604	subdomain-enumeration-pipeline	Domain / DNS	subdomain-enumeration-pipeline	0	Python	https://github.com/soham23/subdomain-enumeration-pipeline.git	Automated Bash pipeline for passive and active subdomain enumeration using Sublist3r, Subfinder, PureDNS, AltD
:::605	information-gathering-subdomain-enum	Domain / DNS	information-gathering-subdomain-enum	0	-	https://github.com/mehedi-hasan-sami98/information-gathering-subdomain-enum.git	Subdomain enumeration reconnaissance documentation using Sublist3r, crt.sh, and Subfinder for ethical penetrat
:::606	sublist3r2	Domain / DNS	Sublist3r2	0	Rust	https://github.com/WhatAScriptKiddieDoes/Sublist3r2.git	Porting of the Sublist3r subdomain enumeration tool in Rust
:::607	subdomain_recon	Domain / DNS	Subdomain_Recon	0	Shell	https://github.com/Kishore18M/Subdomain_Recon.git	I have Developed an automated Bash-based subdomain enumeration tool that integrates Subfinder, Sublist3r, Amas
:::608	sublist3r-macos	Domain / DNS	Sublist3r-macOS	0	Python	https://github.com/reapersapprentice/Sublist3r-macOS.git	Fast subdomain enumeration on macOS Apple Silicon Intel native
:::609	sublist3r-recon-lab	Domain / DNS	sublist3r-recon-lab	0	-	https://github.com/mehedi-hasan-sami98/sublist3r-recon-lab.git	Subdomain enumeration lab writeup using Sublist3r OSINT-based reconnaissance tool for penetration testing
:::610	subdomain-checker	Domain / DNS	subdomain-checker	0	Python	https://github.com/SazumiVicky/subdomain-checker.git	This script is used to check the status of subdomains of a root domain. It uses sublist3r to find subdomains a
:::611	vtotalenum	Domain / DNS	vtotalenum	0	Go	https://github.com/B4l3rI0n/vtotalenum.git	subdomain enumeration using virustotal
:::612	python-subdomain-generator	Domain / DNS	python-subdomain-generator	0	-	https://github.com/Nichrides/python-subdomain-generator.git	Subdomain Enumerator is a Python script that uses Sublist3r to enumerate subdomains for a given domain name, u
:::613	web_killer	Domain / DNS	Web_Killer	0	-	https://github.com/0x7n6/Web_Killer.git	This tool can find subdomain using sublist3r and after that it will look for valid subdomains. Working only in
:::614	subenum	Domain / DNS	SubEnum	0	Shell	https://github.com/ricktor0/SubEnum.git	SubEnum A Bash automation tool for subdomain enumeration and HTTP status checking using Assetfinder, Subfinder
:::615	mx8pro-subdomain-enumeration-script	Domain / DNS	Subdomain-Enumeration-Script	0	Shell	https://github.com/MX8Pro/Subdomain-Enumeration-Script.git	This is a bash script that uses three tools: assetfinder, subfinder,sublist3r, to extract and explore subdomai
:::616	subdomain-enumeration-and-brute-forcing-	Domain / DNS	Subdomain-Enumeration-and-Brute-Forcing-	0	Python	https://github.com/AbdullahMaqbool22/Subdomain-Enumeration-and-Brute-Forcing-Tool.git	This powerful and efficient Python script is designed for cybersecurity professionals and enthusiasts to enhan
:::617	enum_screenshot	Domain / DNS	enum_screenshot	0	Shell	https://github.com/TylersTech2020/enum_screenshot.git	This will run Sublist3r to enumerate the subdomains of example.com, and then use Eyewitness to take screenshot
:::618	sqli-enumeration	Domain / DNS	SQLi-Enumeration	0	-	https://github.com/Yusuf-d-hackguy/SQLi-Enumeration.git	Week 5: Hands-on web security labs SQLi enumeration, subdomain discovery Sublist3r/ffuf and CTF practice la
:::619	subhunt	Domain / DNS	SubHunt	0	Shell	https://github.com/M4HMUD404/SubHunt.git	SubHunt is a subdomain enumeration tool that allows you to quickly discover subdomains for a given domain. It 
:::620	fr3131	Domain / DNS	FR3131	0	Go	https://github.com/Amirhossein-3131/FR3131.git	A Go-based wrapper for running multiple subdomain enumeration tools like Sublist3r, Subfinder, Assetfinder, an
:::621	avdsidlister	Domain / DNS	AvdSidlister	0	Python	https://github.com/Siddharth0kumar/AvdSidlister.git	AvdSidlister is a powerful Python-based subdomain enumeration tool by siddharth0kumar. Discover subdomains wit
:::622	subenum-wrapper	Domain / DNS	SubEnum-Wrapper	0	Shell	https://github.com/shirkirtia-art/SubEnum-Wrapper.git	A fast and efficient bash wrapper that automates subdomain enumeration by combining Subfinder, Assetfinder, Su
:::623	domain-recon-suite	Domain / DNS	domain-recon-suite	0	Shell	https://github.com/shyam-achuthan/domain-recon-suite.git	All-in-one Dockerized recon toolkit for security researchers combines Subfinder, Sublist3r, MassDNS, dnsx, Ass
:::624	ultrarecon	Domain / DNS	ultrarecon	0	Python	https://github.com/xtawb/ultrarecon.git	Parallel subdomain enumeration and live-host triage for authorized security recon orchestrates theHarvester, a
:::625	bug-bounty-toolkit	Domain / DNS	bug-bounty-toolkit	0	-	https://github.com/Vijaymore04/bug-bounty-toolkit.git	Features Automates recon tasks: subdomain enumeration, port scanning, and screenshotting. Integrates tools lik
:::626	reconrom	Domain / DNS	reconrom	0	Shell	https://github.com/romesh0/reconrom.git	recon for bug hunting. This is written in bash script. Includes tools amass,sublist3r,subfinder for subdomain 
:::627	sdenum	Domain / DNS	sdenum	0	Python	https://github.com/Cipherx7/sdenum.git	SDenum - Subdomain Enumeration Tool for ethical hacking. It uses Amass, Sublist3r, and FFUF to find subdomains
:::628	vuln_scanner	Domain / DNS	vuln_Scanner	0	Python	https://github.com/OmarMohamedg/vuln_Scanner.git	Built an intelligent web vulnerability scanning platform using AI orchestration to detect XSS, SQL Injection, 
:::629	subsolve	Domain / DNS	subsolve	0	-	https://github.com/sthomas28/subsolve.git	This Bash script can be used to find every subdomain under a given domain, uses four separate tools Sublist3r
:::630	information-gathering-lab	Domain / DNS	information-gathering-lab	0	-	https://github.com/wonlyanu2004/information-gathering-lab.git	The project involved collecting domain and WHOIS information, subdomain enumeration, DNS record analysis, tech
:::631	sublis3t-subfinder-use	Domain / DNS	Sublis3t-Subfinder-Use	0	-	https://github.com/NonitBajaj/Sublis3t-Subfinder-Use.git	A personal repository for learning and experimenting with subdomain enumeration tools like Subfinder and Subli
:::632	recvanucleix	Domain / DNS	RecVANucleiX	0	Shell	https://github.com/chandra215/RecVANucleiX.git	An automated reconnaissance script for penetration testing and bug bounty hunting. It integrates tools like Su
:::633	web-reconnaissance-and-enumeration-for-s	Domain / DNS	Web-Reconnaissance-and-Enumeration-for-S	0	-	https://github.com/Ajaychristo007/Web-Reconnaissance-and-Enumeration-for-Security-Assessment.git	Skilled in reconnaissance, subdomain enumeration, and penetration testing using tools like AMASS, assetfinder,
:::634	cybersecurity-enumeration-and-vulnerabil	Domain / DNS	Cybersecurity-Enumeration-and-Vulnerabil	0	-	https://github.com/sanjy9025530/Cybersecurity-Enumeration-and-Vulnerability-Assessment-Tools.git	Skilled in reconnaissance, subdomain enumeration, and penetration testing using tools like AMASS, assetfinder,
:::635	dnslocate	Domain / DNS	dnslocate	0	Shell	https://github.com/Hackingariseofficial/dnslocate.git	dns locater useing dnsrecon
:::636	cognis-digital-dnsrecon	Domain / DNS	dnsrecon	0	Python	https://github.com/cognis-digital/dnsrecon.git	Aggregate DNS recon records, zone hints, takeover candidates
:::637	its-harsh-8-dnsrecon	Domain / DNS	DNSRecon	0	Shell	https://github.com/its-harsh-8/DNSRecon.git	A bash script to gather basic DNS information about a domain using built in linux commands
:::638	0x10f8-dnsrecon	Domain / DNS	DNSRecon	0	Shell	https://github.com/0x10F8/DNSRecon.git	DNS recon tools in bash
:::639	abdulrahmanmaktabi-dnsrecon	Domain / DNS	DNSRecon	0	Shell	https://github.com/AbdulrahmanMaktabi/DNSRecon.git	DNSRecon is a python script used for DNS information gathering
:::640	africanaz-dnsrecon	Domain / DNS	dnsrecon	0	Shell	https://github.com/africanaz/dnsrecon.git	Multiple DNS recon tools
:::641	ox1df-dnsrecon	Domain / DNS	DNSrecon	0	Python	https://github.com/ox1df/DNSrecon.git	The DNS Recon Tool is a comprehensive script for gathering DNS information and subdomain enumeration using var
:::642	lw-homeless-dnsrecon	Domain / DNS	DNSRecon	0	Python	https://github.com/LW-Homeless/DNSRecon.git	DNSRecon herramienta para la obtencin de registros DNS tales como, registros IPv4 A, registros Mail Exchange
:::643	noursallam-dnsrecon	Domain / DNS	Dnsrecon	0	-	https://github.com/noursallam/Dnsrecon.git	makr dns recon about your taarget website
:::644	willkj-dnsrecon	Domain / DNS	dnsrecon	0	Shell	https://github.com/willkj/dnsrecon.git	Bruteforce de reconhecimento de DNS
:::645	ibrahim71reza-dnsrecon	Domain / DNS	dnsRecon	0	Python	https://github.com/Ibrahim71Reza/dnsRecon.git	dnsRecon is a fast, terminal-first DNS intelligence tool for authorized security testing. It analyzes DNS reco
:::646	dnsrecon-rs	Domain / DNS	dnsrecon-rs	0	Rust	https://github.com/DaZuo0122/dnsrecon-rs.git	Rust Rewrite of DNSRecon, the DNS Enumeration Script
:::647	bulk-dnsrecon	Domain / DNS	bulk-dnsRecon	0	Python	https://github.com/glastyy/bulk-dnsRecon.git	The Bulk DNSrecon Script is a Python script designed to facilitate DNS reconnaissance on multiple domains usin
:::648	python3-dnsrecon	Domain / DNS	python3-dnsrecon	0	Python	https://github.com/nmmapper/python3-dnsrecon.git	DNS reconnaissance to investigate dns details offers DNS Enumeration
:::649	dnsrecontool	Domain / DNS	DnsReconTool	0	Python	https://github.com/RareTalent9/DnsReconTool.git	This tool is used to resolve all the resource records of a domain
:::650	dreco	Domain / DNS	dreco	0	Python	https://github.com/wodeh/dreco.git	domain recon written in python using several tools like nmap, dnsenum, dnsrecon etc
:::651	footprinting-reconnaissance	Domain / DNS	Footprinting-Reconnaissance	0	-	https://github.com/VrundaDomadiya/Footprinting-Reconnaissance.git	Footprinting and Reconnaissance using Kali Linux tools including WHOIS, WhatWeb, NSLookup, CURL, WAFW00F, and 
:::652	networkwalks-b083-week-2-pm1-cybersecuri	Domain / DNS	NETWORKWALKS-B083-WEEK-2-PM1-CYBERSECURI	0	-	https://github.com/Praise20032108/NETWORKWALKS-B083-WEEK-2-PM1-CYBERSECURITY-FOOTPRINTING-WITH-MULTIPLE-TOOLS.git	Footprinting using six built-in Kali Linux tools: whois, whatweb, nslookup, curl, wafw00f and dnsrecon
:::653	footprinting-network-scanning	Domain / DNS	Footprinting-Network-Scanning	0	-	https://github.com/Waleunique/Footprinting-Network-Scanning.git	Cybersecurity lab documenting footprinting, OSINT, and network scanning using WHOIS, WhatWeb, theHarvester, dn
:::654	networkwalks-balami-b083-wk2-footprintin	Domain / DNS	NETWORKWALKS-BALAMI-B083-WK2-FOOTPRINTIN	0	-	https://github.com/ESBalami/NETWORKWALKS-BALAMI-B083-WK2-FOOTPRINTING-SCANNING.git	Week 2 Cybersecurity Lab covering Footprinting, OSINT, DNS Enumeration, and Network Scanning using Kali Linux 
:::655	vishal8736-waybackurls	Domain / DNS	waybackurls	0	Shell	https://github.com/Vishal8736/waybackurls.git	waybackurls fast, lightweight subdomain URL extractor. Pulls archived URLs from Wayback/Common Crawl, dedupes 
:::656	shodan-recon-agent	Domain / DNS	shodan-recon-agent	0	Python	https://github.com/rksharma-owg/shodan-recon-agent.git	Production-ready Python CLI for authorized Internet reconnaissance with the Shodan APIhost lookup, search, DNS
:::657	omega-cli	Domain / DNS	omega-cli	0	Python	https://github.com/Ekoelogan/omega-cli.git	108-command OSINT Passive Recon Toolkit DNS, WHOIS, SSL, breach, shodan, social, crypto, AI-analyst and more
:::658	ai-recon	Domain / DNS	ai-recon	0	Python	https://github.com/toluowo/ai-recon.git	AI-assisted, offline-first recon CLI. WHOIS, Shodan, AI summary/pretext, live risk score, Markdown reports. AI
:::659	0xcatmeat-osint-recon	Domain / DNS	osint-recon	0	Python	https://github.com/0xCatmeat/osint-recon.git	Command-line OSINT toolkit that queries many providers, normalizes the evidence, and builds a per-target repor
:::660	censys-go-script	Domain / DNS	censys-go-script	0	Go	https://github.com/serhanwbahar/censys-go-script.git	This CLI takes a domain name and returns a JSON with several intelligence data fetched from Censys
:::661	spiderfoot	Recon / Footprint	spiderfoot	22429	Python	https://github.com/smicallef/spiderfoot.git	SpiderFoot automates OSINT for threat intelligence and mapping your attack surface
:::662	manisso-fsociety	Recon / Footprint	fsociety	12316	Python	https://github.com/Manisso/fsociety.git	fsociety Hacking Tools Pack A Penetration Testing Framework
:::663	osint-framework	Recon / Footprint	OSINT-Framework	12170	JavaScript	https://github.com/lockfale/OSINT-Framework.git	OSINT Framework
:::664	sn1per	Recon / Footprint	Sn1per	11258	Shell	https://github.com/1N3/Sn1per.git	Automated penetration testing attack surface management platform. Recon, scan, exploit, report 600+ exploits, 
:::665	trape	Recon / Footprint	trape	9015	Python	https://github.com/jofpin/trape.git	People tracker on the Internet: OSINT analysis and research tool by Jose Pino
:::666	allaboutbugbounty	Recon / Footprint	AllAboutBugBounty	6898	-	https://github.com/daffainfo/AllAboutBugBounty.git	All about bug bounty bypasses, payloads, and etc
:::667	osmedeus	Recon / Footprint	osmedeus	6573	Go	https://github.com/j3ssie/osmedeus.git	A Modern Orchestration Engine for Security
:::668	arjun	Recon / Footprint	Arjun	6398	Python	https://github.com/s0md3v/Arjun.git	HTTP parameter discovery suite
:::669	recon-ng	Recon / Footprint	recon-ng	5926	Python	https://github.com/lanmaster53/recon-ng.git	Open Source Intelligence gathering tool aimed at reducing the time spent harvesting information from open sour
:::670	hakrawler	Recon / Footprint	hakrawler	5133	Go	https://github.com/hakluke/hakrawler.git	Simple, fast web crawler designed for easy, quick discovery of endpoints and assets within a web application
:::671	gowitness	Recon / Footprint	gowitness	4517	Go	https://github.com/sensepost/gowitness.git	gowitness - a golang, web screenshot utility using Chrome Headless
:::672	aliens_eye	Recon / Footprint	Aliens_eye	4083	Python	https://github.com/arxhr007/Aliens_eye.git	Hunt down 840+ social media accounts using AI
:::673	winpwn	Recon / Footprint	WinPwn	3696	PowerShell	https://github.com/S3cur3Th1sSh1t/WinPwn.git	Automation for internal Windows Penetrationtest / AD-Security
:::674	uncover	Recon / Footprint	uncover	3060	Go	https://github.com/projectdiscovery/uncover.git	Quickly discover exposed hosts on the internet using multiple search engines
:::675	tookie-osint	Recon / Footprint	tookie-osint	2969	Python	https://github.com/Alfredredbird/tookie-osint.git	Tookie is a advanced OSINT information gathering tool that finds social media accounts based on inputs
:::676	fbi-tools	Recon / Footprint	FBI-tools	2667	-	https://github.com/danieldurnea/FBI-tools.git	OSINT Tools for gathering information and actions forensics
:::677	conferences	Recon / Footprint	Conferences	2448	-	https://github.com/onhexgroup/Conferences.git	Conference presentation slides
:::678	gogo	Recon / Footprint	gogo	2138	Go	https://github.com/chainreactors/gogo.git	A highly controllable and extensionable automated scanning engine for red teams
:::679	x8	Recon / Footprint	x8	2097	Rust	https://github.com/Sh1Yo/x8.git	Hidden parameters discovery suite
:::680	tidos-framework	Recon / Footprint	TIDoS-Framework	1869	Python	https://github.com/0xInfection/TIDoS-Framework.git	The Offensive Manual Web Application Penetration Testing Framework
:::681	wordlists	Recon / Footprint	wordlists	1797	-	https://github.com/trickest/wordlists.git	Real-world infosec wordlists, updated regularly
:::682	urlhunter	Recon / Footprint	urlhunter	1701	Go	https://github.com/utkusen/urlhunter.git	a recon tool that allows searching on URLs that are exposed via shortener services
:::683	openosint	Recon / Footprint	OpenOSINT	1613	Python	https://github.com/OpenOSINT/OpenOSINT.git	AI-powered OSINT agent with interactive REPL, MCP server, and CLI. 20 tools. Works with Claude, GPT-4, or loca
:::684	inventory	Recon / Footprint	inventory	1612	Shell	https://github.com/trickest/inventory.git	Asset inventory of over 800 public bug bounty programs
:::685	bigbountyrecon	Recon / Footprint	BigBountyRecon	1571	C#	https://github.com/Viralmaniar/BigBountyRecon.git	BigBountyRecon tool utilises 58 different techniques using various Google dorks and open source tools to exped
:::686	gasmask	Recon / Footprint	gasmask	1476	Python	https://github.com/twelvesec/gasmask.git	Information gathering tool - OSINT
:::687	secator	Recon / Footprint	secator	1310	Python	https://github.com/freelabz/secator.git	secator - the pentester's swiss knife
:::688	favfreak	Recon / Footprint	FavFreak	1309	Python	https://github.com/devanshbatham/FavFreak.git	Making Favicon.ico based Recon Great again
:::689	offensive-osint-tools	Recon / Footprint	Offensive-OSINT-Tools	1280	-	https://github.com/wddadk/Offensive-OSINT-Tools.git	OffSec OSINT Pentest/RedTeam Tools
:::690	taranis-ai	Recon / Footprint	taranis-ai	1218	Python	https://github.com/taranis-ai/taranis-ai.git	Taranis AI is an advanced Open-Source Intelligence OSINT tool, leveraging Artificial Intelligence to revolut
:::691	hosthunter	Recon / Footprint	HostHunter	1172	Python	https://github.com/SpiderLabs/HostHunter.git	HostHunter a recon tool for discovering hostnames using OSINT techniques
:::692	pywerview	Recon / Footprint	pywerview	1134	Python	https://github.com/the-useless-one/pywerview.git	A partial Python rewriting of PowerSploit's PowerView
:::693	jsfscan-sh	Recon / Footprint	JSFScan.sh	1110	Shell	https://github.com/KathanP19/JSFScan.sh.git	Automation for javascript recon in bug bounty
:::694	infoooze	Recon / Footprint	infoooze	1085	JavaScript	https://github.com/devxprite/infoooze.git	A OSINT tool which helps you to quickly find information effectively. All you need is to input and it will tak
:::695	mantis	Recon / Footprint	mantis	1039	Python	https://github.com/PhonePe/mantis.git	Mantis is a security framework that automates the workflow of discovery, reconnaissance, and vulnerability sca
:::696	hack-camera	Recon / Footprint	HACK-CAMERA	1033	HTML	https://github.com/hackerxphantom/HACK-CAMERA.git	Hack Victim android Camera Using Link with Termux/Kali-linux
:::697	karma_v2	Recon / Footprint	karma_v2	1029	Shell	https://github.com/Dheerajmadhukar/karma_v2.git	is a Passive Open Source Intelligence OSINT Automated Reconnaissance framework
:::698	wpprobe	Recon / Footprint	wpprobe	948	Go	https://github.com/Chocapikk/wpprobe.git	A fast WordPress plugin enumeration tool
:::699	xajkep-wordlists	Recon / Footprint	wordlists	947	Python	https://github.com/xajkep/wordlists.git	Infosec Wordlists and more
:::700	urlfinder	Recon / Footprint	urlfinder	913	Go	https://github.com/projectdiscovery/urlfinder.git	A high-speed tool for passively gathering URLs, optimized for efficient and comprehensive web asset discovery 
:::701	reconaizer	Recon / Footprint	ReconAIzer	911	Python	https://github.com/hisxo/ReconAIzer.git	A Burp Suite extension to add OpenAI GPT on Burp and help you with your Bug Bounty recon to discover endpoin
:::702	graphw00f	Recon / Footprint	graphw00f	902	Python	https://github.com/dolevf/graphw00f.git	graphw00f is GraphQL Server Engine Fingerprinting utility for software security professionals looking to learn
:::703	tactical-exploitation	Recon / Footprint	tactical-exploitation	868	Python	https://github.com/0xdea/tactical-exploitation.git	Modern tactical exploitation toolkit
:::704	sicat	Recon / Footprint	sicat	829	Python	https://github.com/justakazh/sicat.git	The useful exploit finder
:::705	shadowclone	Recon / Footprint	ShadowClone	822	Python	https://github.com/fyoorer/ShadowClone.git	Unleash the power of cloud
:::706	web_hacking	Recon / Footprint	Web_Hacking	816	-	https://github.com/Mehdi0x90/Web_Hacking.git	Bug Bounty Tricks and useful payloads and bypasses for Web Application Security
:::707	witnessme	Recon / Footprint	WitnessMe	759	Python	https://github.com/byt3bl33d3r/WitnessMe.git	Web Inventory tool, takes screenshots of webpages using Pyppeteer headless Chrome/Chromium and provides some
:::708	webkiller	Recon / Footprint	webkiller	749	Python	https://github.com/ultrasecurity/webkiller.git	Tool Information Gathering Write By Python
:::709	o365recon	Recon / Footprint	o365recon	745	PowerShell	https://github.com/nyxgeek/o365recon.git	retrieve information via O365 and AzureAD with a valid cred
:::710	slash	Recon / Footprint	slash	742	Python	https://github.com/theahmadov/slash.git	The Slash OSINT Tool
:::711	siem	Recon / Footprint	SIEM	728	PowerShell	https://github.com/TonyPhipps/SIEM.git	SIEM Tactics, Techiques, and Procedures
:::712	reconpi	Recon / Footprint	ReconPi	725	Shell	https://github.com/x1mdev/ReconPi.git	ReconPi - A lightweight recon tool that performs extensive scanning with the latest tools
:::713	sarenka	Recon / Footprint	sarenka	674	Python	https://github.com/KTZgraph/sarenka.git	OSINT tool - gets data from services like shodan, censys etc. in one app
:::714	thundersearch	Recon / Footprint	ThunderSearch	667	Python	https://github.com/xzajyjs/ThunderSearch.git	macOSFofaShodanHunterZoomeyeQuakeGUIMac/Windowshwhvv
:::715	shotlooter	Recon / Footprint	shotlooter	649	Python	https://github.com/utkusen/shotlooter.git	a recon tool that finds sensitive data inside the screenshots uploaded to prnt.sc
:::716	blitzstrike	Recon / Footprint	blitzstrike	639	TypeScript	https://github.com/shinthink/blitzstrike.git	Blitz Strike a universal MCP penetration-testing toolbelt. Structured methodology: reconnaissance attack-surfa
:::717	osint_team_links	Recon / Footprint	OSINT_Team_Links	626	-	https://github.com/IVMachiavelli/OSINT_Team_Links.git	Links for the OSINT Team
:::718	zen	Recon / Footprint	Zen	603	Python	https://github.com/s0md3v/Zen.git	Find emails of Github users
:::719	cti-expert	Recon / Footprint	cti-expert	599	Python	https://github.com/7onez/cti-expert.git	CTI Expert Cyber Threat Intelligence OSINT analysis skill for Claude Code / Codex. 120+ commands, 57 technique
:::720	komo	Recon / Footprint	Komo	567	Python	https://github.com/komomon/Komo.git	Komo, a comprehensive asset collection and vulnerability scanning tool. Komo 20ipipwebxraywebPOC
:::721	rombuster	Recon / Footprint	RomBuster	563	Python	https://github.com/EntySec/RomBuster.git	RomBuster is a router exploitation tool that allows to disclosure network router admin password
:::722	rustbuster	Recon / Footprint	rustbuster	559	Rust	https://github.com/phra/rustbuster.git	A Comprehensive Web Fuzzer and Content Discovery Tool
:::723	skytrack	Recon / Footprint	skytrack	540	Python	https://github.com/ANG13T/skytrack.git	skytrack is a planespotting and aircraft OSINT tool made using Python
:::724	jshunter	Recon / Footprint	JShunter	537	Go	https://github.com/cc1a2b/JShunter.git	jshunter is a command-line tool designed for analyzing JavaScript files and extracting endpoints. This tool sp
:::725	csprecon	Recon / Footprint	csprecon	529	Go	https://github.com/edoardottt/csprecon.git	Discover new target domains using Content Security Policy
:::726	otseca	Recon / Footprint	otseca	522	Shell	https://github.com/trimstray/otseca.git	Open source security auditing tool to search and dump system configuration. It allows you to generate reports 
:::727	ntlmrecon	Recon / Footprint	NTLMRecon	510	Python	https://github.com/pwnfoo/NTLMRecon.git	Enumerate information from NTLM authentication enabled web endpoints
:::728	porch-pirate	Recon / Footprint	porch-pirate	478	Python	https://github.com/WatchDogSecurity/porch-pirate.git	Porch Pirate is the most comprehensive Postman recon / OSINT client and framework that facilitates the automat
:::729	hawkscan	Recon / Footprint	HawkScan	463	Python	https://github.com/c0dejump/HawkScan.git	Security Tool for Reconnaissance and Information Gathering on a website. python 3.x
:::730	lazyrecon	Recon / Footprint	LazyRecon	453	Shell	https://github.com/capt-meelo/LazyRecon.git	An automated approach to performing recon for bug bounty hunting and penetration testing
:::731	mqtt-pwn	Recon / Footprint	mqtt-pwn	452	Python	https://github.com/akamai-threat-research/mqtt-pwn.git	MQTT-PWN intends to be a one-stop-shop for IoT Broker penetration-testing and security assessment operations
:::732	1in9e-gosint	Recon / Footprint	gosint	428	JavaScript	https://github.com/1in9e/gosint.git	Gosint is a distributed asset information collection and vulnerability scanning platform
:::733	fp-tools	Recon / Footprint	fp-tools	423	Python	https://github.com/oncologylab/fp-tools.git	Command-first ATAC-seq footprinting, motif analysis, and reproducible interactive reports
:::734	bugbounty-lab101	Recon / Footprint	bugbounty-lab101	377	Shell	https://github.com/DevCop95/bugbounty-lab101.git	A complete bug bounty workspace for HackerOne researchers. Includes scope enforcement, automated recon/vuln pi
:::735	url-tracker	Recon / Footprint	url-tracker	363	JavaScript	https://github.com/al-sultani/url-tracker.git	Change monitoring app that checks the content of web pages in different periods
:::736	slicer	Recon / Footprint	slicer	343	Python	https://github.com/mzfr/slicer.git	A tool to automate the boring process of APK recon
:::737	easyeasm	Recon / Footprint	EasyEASM	332	Go	https://github.com/g0ldencybersec/EasyEASM.git	Zero-dollar attack surface management tool
:::738	bug_bounty_tools_and_methodology	Recon / Footprint	Bug_Bounty_Tools_and_Methodology	328	-	https://github.com/blackhatethicalhacking/Bug_Bounty_Tools_and_Methodology.git	Bug Bounty Tools used on Twitch - Recon
:::739	reconness	Recon / Footprint	reconness	328	C#	https://github.com/reconness/reconness.git	ReconNess is a platform to allow continuous recon CR where you can set up a pipeline of #recon tools Agents
:::740	secretz	Recon / Footprint	secretz	326	Go	https://github.com/lc/secretz.git	secretz, minimizing the large attack surface of Travis CI
:::741	kanha	Recon / Footprint	kanha	325	Rust	https://github.com/pwnwriter/kanha.git	A web-app pentesting suite written in rust
:::742	hamburglar	Recon / Footprint	Hamburglar	319	Python	https://github.com/needmorecowbell/Hamburglar.git	Hamburglar -- collect useful information from urls, directories, and files
:::743	ai4eh	Recon / Footprint	ai4eh	297	Python	https://github.com/ethiack/ai4eh.git	AI for Ethical Hacking - Workshop
:::744	sagemode	Recon / Footprint	sagemode	282	Python	https://github.com/senran101604/sagemode.git	Sagemode: Track and Unveil Online identities across social media platforms
:::745	s3enum	Recon / Footprint	s3enum	281	Go	https://github.com/koenrh/s3enum.git	Fast and stealthy Amazon S3 bucket enumeration tool for pentesters
:::746	dirsearch	Recon / Footprint	dirsearch	279	Go	https://github.com/evilsocket/dirsearch.git	A Go implementation of dirsearch
:::747	robofinder	Recon / Footprint	robofinder	273	Python	https://github.com/Spix0r/robofinder.git	Robofinder fetches historical robots.txt files from Archive.org to uncover old directories, hidden paths, and 
:::748	recon-ng-marketplace	Recon / Footprint	recon-ng-marketplace	272	Python	https://github.com/lanmaster53/recon-ng-marketplace.git	Official module repository for the Recon-ng Framework
:::749	traxosint	Recon / Footprint	TraxOsint	257	Python	https://github.com/N0rz3/TraxOsint.git	Osint tool for track ip adress
:::750	tobias	Recon / Footprint	TOBIAS	256	Python	https://github.com/loosolab/TOBIAS.git	Transcription factor Occupancy prediction By Investigation of ATAC-seq Signal
:::751	intrec-pack	Recon / Footprint	IntRec-Pack	254	Shell	https://github.com/NullArray/IntRec-Pack.git	Intelligence and Reconnaissance Package/Bundle installer
:::752	bughunter	Recon / Footprint	bughunter	253	Python	https://github.com/thehackingsage/bughunter.git	Tools for BugHunting
:::753	secretopt1c	Recon / Footprint	SecretOpt1c	250	Shell	https://github.com/blackhatethicalhacking/SecretOpt1c.git	SecretOpt1c is a Red Team tool that helps uncover sensitive information in websites using ACTIVE and PASSIVE T
:::754	pip-intel	Recon / Footprint	Pip-Intel	241	Shell	https://github.com/emrekybs/Pip-Intel.git	PIP-INTEL is an OSINT Open Source Intelligence tool designed using various open-source tools and pip package
:::755	osint-tools-mcp-server	Recon / Footprint	osint-tools-mcp-server	241	Python	https://github.com/frishtik/osint-tools-mcp-server.git	MCP server exposing multiple OSINT tools for AI assistants like Claude
:::756	yar	Recon / Footprint	yar	239	Go	https://github.com/nielsing/yar.git	Yar is a tool for plunderin' organizations, users and/or repositories
:::757	intelspy	Recon / Footprint	intelspy	237	Python	https://github.com/maldevel/intelspy.git	Perform automated network reconnaissance scans
:::758	chronos	Recon / Footprint	chronos	236	Go	https://github.com/mhmdiaa/chronos.git	Wayback Machine OSINT Framework
:::759	lucille	Recon / Footprint	Lucille	234	Python	https://github.com/jasonxtn/Lucille.git	Information Gatherer Webapps Exploiter
:::760	bbrecon	Recon / Footprint	bbrecon	229	Python	https://github.com/serain/bbrecon.git	Python library and CLI for the Bug Bounty Recon API
:::761	quidam	Recon / Footprint	Quidam	227	Python	https://github.com/megadose/Quidam.git	Quidam allows you to retrieve information thanks to the forgotten password function of some sites
:::762	x8-burp	Recon / Footprint	x8-Burp	225	Python	https://github.com/Impact-I/x8-Burp.git	Hidden parameters discovery suite
:::763	gitem	Recon / Footprint	gitem	219	Python	https://github.com/mschwager/gitem.git	A Github organization reconnaissance tool
:::764	linx	Recon / Footprint	linx	214	Go	https://github.com/riza/linx.git	Reveals invisible links within JavaScript files
:::765	osmedeus-base	Recon / Footprint	osmedeus-base	208	-	https://github.com/osmedeus/osmedeus-base.git	Build your own reconnaissance system with Osmedeus Next Generation
:::766	teamsenum	Recon / Footprint	TeamsEnum	199	Python	https://github.com/lucidra-security/TeamsEnum.git	User Enumeration of Microsoft Teams users via API
:::767	bash_scripting	Recon / Footprint	bash_scripting	195	Shell	https://github.com/bing0o/bash_scripting.git	bash scripting thing
:::768	gotanda	Recon / Footprint	Gotanda	194	JavaScript	https://github.com/HASH1da1/Gotanda.git	Gotanda is browser Web Extension for OSINT
:::769	warf	Recon / Footprint	warf	194	Python	https://github.com/iamnihal/warf.git	WARF is a Web Application Reconnaissance Framework that helps to gather information about the target
:::770	open-asm	Recon / Footprint	open-asm	193	TypeScript	https://github.com/oasm-platform/open-asm.git	AI-powered open-source platform for Attack Surface Management OASM
:::771	jsrecon-buddy	Recon / Footprint	JSRecon-Buddy	189	JavaScript	https://github.com/TheArqsz/JSRecon-Buddy.git	A simple browser extension to quickly find interesting security-related information on a webpage
:::772	autosetup	Recon / Footprint	autosetup	181	Shell	https://github.com/shubhampathak/autosetup.git	Auto setup is a bash script compatible with Debian based distributions to install and setup necessary programs
:::773	teamsuserenum	Recon / Footprint	TeamsUserEnum	176	Go	https://github.com/immunIT/TeamsUserEnum.git	User enumeration with Microsoft Teams API
:::774	rekon	Recon / Footprint	Rekon	175	Shell	https://github.com/shiblisec/Rekon.git	The project contains multiple shell scripts for automating the tasks during recon
:::775	stardox	Recon / Footprint	Stardox	175	Python	https://github.com/0xPrateek/Stardox.git	Github stargazers information gathering tool
:::776	mkpath	Recon / Footprint	mkpath	174	Go	https://github.com/trickest/mkpath.git	Make URL path combinations using a wordlist
:::777	gitmonitor	Recon / Footprint	GitMonitor	172	Python	https://github.com/Talkaboutcybersecurity/GitMonitor.git	One way to continuously monitor sensitive information that could be exposed on Github
:::778	recon-ng-api-key-creation	Recon / Footprint	Recon-NG-API-Key-Creation	170	-	https://github.com/Raikia/Recon-NG-API-Key-Creation.git	One of the biggest annoyances of using Recon-ng is getting everything set up to use it. So here Ill outline th
:::779	bitcrook	Recon / Footprint	bitcrook	164	Go	https://github.com/ax-i-om/bitcrook.git	Open-Source Intelligence Apparatus
:::780	smartrecon	Recon / Footprint	smartrecon	159	Shell	https://github.com/kh4sh3i/smartrecon.git	smartrecon is a powerful shell script to automate the recon and finding common vulnerabilities for bug hunter
:::781	sourcewolf	Recon / Footprint	SourceWolf	157	Python	https://github.com/ksharinarayanan/SourceWolf.git	Amazingly fast response crawler to find juicy stuff in the source code
:::782	spaces-finder	Recon / Footprint	spaces-finder	156	Python	https://github.com/appsecco/spaces-finder.git	A tool to hunt for publicly accessible DigitalOcean Spaces
:::783	s3recon	Recon / Footprint	s3recon	155	Python	https://github.com/clarketm/s3recon.git	Amazon S3 bucket finder and crawler
:::784	wordlist	Recon / Footprint	WordList	154	Go	https://github.com/rix4uni/WordList.git	Custom wordlist, updated regularly
:::785	webdork	Recon / Footprint	webdork	154	Python	https://github.com/HACKE-RC/webdork.git	A Python tool to automate some dorking stuff to find information disclosures
:::786	insiders	Recon / Footprint	insiders	154	-	https://github.com/trickest/insiders.git	Archive of Potential Insider Threats
:::787	google-hacking-assistant	Recon / Footprint	google-hacking-assistant	153	TypeScript	https://github.com/Pa55w0rd/google-hacking-assistant.git	ChromeGoogle//BingDorkingURL Chrome extension for security research and penetration testing. One-click advance
:::788	ntlm_challenger	Recon / Footprint	ntlm_challenger	152	Python	https://github.com/nopfor/ntlm_challenger.git	Parse NTLM challenge messages over HTTP and SMB
:::789	kitsec-core	Recon / Footprint	kitsec-core	149	Python	https://github.com/kitsec-labs/kitsec-core.git	Pentesting, made easy
:::790	uddup	Recon / Footprint	uddup	145	Python	https://github.com/rotemreiss/uddup.git	Urls de-duplication tool for better recon
:::791	jsfinder	Recon / Footprint	jsfinder	139	Go	https://github.com/kacakb/jsfinder.git	Fetches JavaScript files quickly and comprehensively
:::792	binaryobjectscanner	Recon / Footprint	BinaryObjectScanner	127	C#	https://github.com/SabreTools/BinaryObjectScanner.git	C# protection, packer, and archive scanning library
:::793	github-recon	Recon / Footprint	GitHub-Recon	126	-	https://github.com/TheBinitGhimire/GitHub-Recon.git	GitHub Recon and what you can achieve with it
:::794	x-marshal	Recon / Footprint	X-Marshal	126	-	https://github.com/XTeam-Wing/X-Marshal.git	Marshal-EASM
:::795	deksterecon	Recon / Footprint	deksterecon	125	Shell	https://github.com/0xdekster/deksterecon.git	Web Application recon automation
:::796	secbuild	Recon / Footprint	Secbuild	123	Shell	https://github.com/DonatoReis/Secbuild.git	An automation tool to install the most popular tools for bug bounty or pentesting
:::797	corptrace	Recon / Footprint	corptrace	118	Shell	https://github.com/r1cksec/corptrace.git	Automate Scoping, OSINT and Recon assessments
:::798	praetorian-inc-ntlmrecon	Recon / Footprint	NTLMRecon	117	Go	https://github.com/praetorian-inc/NTLMRecon.git	A tool for performing light brute-forcing of HTTP servers to identify commonly accessible NTLM authentication 
:::799	ad-privileged-audit	Recon / Footprint	ad-privileged-audit	114	PowerShell	https://github.com/ziesemer/ad-privileged-audit.git	Provides various Windows Server Active Directory AD security-focused reports
:::800	wpintel	Recon / Footprint	WPintel	113	JavaScript	https://github.com/Tuhinshubhra/WPintel.git	Chrome extension designed for WordPress Vulnerability Scanning and information gathering
:::801	reg-gen	Recon / Footprint	reg-gen	113	Python	https://github.com/CostaLab/reg-gen.git	Regulatory Genomics Toolbox: Python library and set of tools for the integrative analysis of high throughput r
:::802	netnoob	Recon / Footprint	NETNOOB	109	Shell	https://github.com/NARCOTIC/NETNOOB.git	A simple program written in bash that contains basic Linux network tools, information gathering tools and scan
:::803	recon-ng-modules	Recon / Footprint	Recon-ng-modules	107	Python	https://github.com/scumsec/Recon-ng-modules.git	Additional modules for recon-ng
:::804	53r3n17y	Recon / Footprint	53R3N17Y	105	Python	https://github.com/abaykan/53R3N17Y.git	Python based script for Information Gathering
:::805	scope	Recon / Footprint	scope	99	Shell	https://github.com/rix4uni/scope.git	An automated GitHub Actions-based crawler that fetches and updates public scopes from popular bug bounty platf
:::806	signex	Recon / Footprint	Signex	98	Python	https://github.com/zhiyuzi/Signex.git	Personal intelligence agent powered by Claude Code. Describe what to watch, it collects, analyzes, and learns 
:::807	hydrarecon	Recon / Footprint	HydraRecon	94	Python	https://github.com/aufzayed/HydraRecon.git	All In One, Fast, Easy Recon Tool
:::808	loki	Recon / Footprint	loki	93	Python	https://github.com/malwaredojo/loki.git	Command Line Sock Puppet Creator for Investigators
:::809	x-snifer	Recon / Footprint	X-snifer	93	Python	https://github.com/Whomrx666/X-snifer.git	X-snifer is a versatile tool designed for scanning and gathering information from a website and simplifying va
:::810	sovereign_watch	Recon / Footprint	Sovereign_Watch	92	TypeScript	https://github.com/d3mocide/Sovereign_Watch.git	Distributed Multi-INT Fusion Center designed for decentralized situational awareness
:::811	htkit	Recon / Footprint	htkit	87	Python	https://github.com/Keyj33k/htkit.git	Information Gathering Simplified
:::812	duolingosint	Recon / Footprint	duolingOSINT	86	Python	https://github.com/ajuelosemmanuel/duolingOSINT.git	Gather information about a Duolingo user
:::813	ghosttrace	Recon / Footprint	ghosttrace	85	Python	https://github.com/alialsartawi7-sketch/ghosttrace.git	Modular OSINT and attack surface analysis platform for authorized security research, with risk scoring, attack
:::814	stargather	Recon / Footprint	stargather	71	Go	https://github.com/dwisiswant0/stargather.git	A fast GitHub stargazers information gathering tool
:::815	amass-docker-compose	Recon / Footprint	amass-docker-compose	55	-	https://github.com/owasp-amass/amass-docker-compose.git	OWASP Amass Docker Compose for setting up a full instance of the infrastructure
:::816	orb	Recon / Footprint	orb	53	Python	https://github.com/epsylon/orb.git	Orb is a massive footprinting tool
:::817	osint-dev-team-osint-framework	Recon / Footprint	osint-framework	46	Python	https://github.com/osint-dev-team/osint-framework.git	:fork_and_knife: All-in-one OSINT-RECON Swiss Knife
:::818	sublist3rv2	Recon / Footprint	sublist3rV2	46	Python	https://github.com/hxlxmj/sublist3rV2.git	Fast subdomains enumeration tool for penetration testers and bug bounty hunters
:::819	osint-terminal	Recon / Footprint	osint-terminal	39	Python	https://github.com/RojanSapkota/osint-terminal.git	Self-hosted OSINT dashboard: 400+ keyless recon tools, a live 3D threat globe, and batch/case investigation wo
:::820	censys-recon-ng	Recon / Footprint	censys-recon-ng	39	Python	https://github.com/censys/censys-recon-ng.git	recon-ng modules for Censys
:::821	methos2016-recon-ng	Recon / Footprint	recon-ng	39	Python	https://github.com/methos2016/recon-ng.git	Recon-ng is a full-featured Web Reconnaissance framework written in Python
:::822	fugitive	Recon / Footprint	Fugitive	37	Python	https://github.com/RetroPackets/Fugitive.git	[Fugitive was made to offer resourcfulness to 'Osint Investigations' Fugitive will allow you to collect detail
:::823	verylazytech-github-io	Recon / Footprint	verylazytech.github.io	25	HTML	https://github.com/verylazytech/verylazytech.github.io.git	Google Dorks for Bug Bounty
:::824	atactk	Recon / Footprint	atactk	24	Python	https://github.com/ParkerLab/atactk.git	A toolkit for working with ATAC-seq data
:::825	phantomcollect	Recon / Footprint	phantomcollect	20	Python	https://github.com/xsser01/phantomcollect.git	Advanced stealth web data collection framework for security
:::826	reconhound	Recon / Footprint	ReconHound	19	Shell	https://github.com/indiancybertroops/ReconHound.git	ReconHound is Best OSINT Tool For Enumeration We've Given 10 Different Type Of Enumeration Sub Tools Its Recon
:::827	recon-ng_modules	Recon / Footprint	recon-ng_modules	19	Python	https://github.com/403labs/recon-ng_modules.git	Recon-ng modules that won't get accepted into the main distribution because of 3rd party dependencies
:::828	moonwitch-osint-bot	Recon / Footprint	moonwitch-osint-bot	18	Python	https://github.com/whosouvikkk/moonwitch-osint-bot.git	MoonWitch is a terminal-based OSINT Open Source Intelligence framework designed for efficient and rapid data
:::829	raven	Recon / Footprint	raven	18	JavaScript	https://github.com/Yugabdh/raven.git	Raven is a Web application penetration testing tool
:::830	roshanburnwal-th3inspector	Recon / Footprint	Th3inspector	18	Perl	https://github.com/roshanburnwal/Th3inspector.git	All in one tool for Information Gathering
:::831	ga-recon	Recon / Footprint	ga-recon	17	-	https://github.com/fguisso/ga-recon.git	ReconAmass, Naabu, Nuclei workflow with Github Actions
:::832	claude-osint-deploy	Recon / Footprint	claude-osint-deploy	16	Python	https://github.com/soxoj/claude-osint-deploy.git	Install, run and verify OSINT tools from GitHub automatically, on any OS
:::833	recon-ng-web	Recon / Footprint	recon-ng-web	14	PHP	https://github.com/interference-security/recon-ng-web.git	Web interface for recon-ng
:::834	simplerecondorking	Recon / Footprint	SimpleReconDorking	13	Python	https://github.com/osintbrazuca/SimpleReconDorking.git	Ferramenta de dorking em mltiplos motores de busca para coleta de URLs em operaes de OSINT e reconhecimento
:::835	maldevel-osint	Recon / Footprint	osint	13	-	https://github.com/maldevel/osint.git	Tools, scripts and tips useful during OSINT investigations and reconnaissance
:::836	waybackurlsx	Recon / Footprint	waybackurlsx	13	Go	https://github.com/rix4uni/waybackurlsx.git	A powerful and efficient Go-based tool for extracting archived URLs from the Wayback Machine with advanced fil
:::837	indeed-recon-ng-script	Recon / Footprint	indeed-recon-ng-script	12	Python	https://github.com/ZonkSec/indeed-recon-ng-script.git	A recon-ng module for crawling Indeed.com for contacts and resumes
:::838	dec0ne-recon-ng-modules	Recon / Footprint	Recon-ng-Modules	11	Python	https://github.com/Dec0ne/Recon-ng-Modules.git	Recon-ng modules for basic OSINT
:::839	samglish-recon-ng	Recon / Footprint	Recon-ng	11	-	https://github.com/samglish/Recon-ng.git	Recognition tool
:::840	reconx	Recon / Footprint	ReconX	11	Shell	https://github.com/whitehatboy005/ReconX.git	This is a powerful Bash script designed for automating the reconnaissance of websites. It helps security resea
:::841	amass-action	Recon / Footprint	amass-action	10	JavaScript	https://github.com/fguisso/amass-action.git	In-depth Attack Surface Mapping and Asset Discovery for Github Actions
:::842	recon-enum	Recon / Footprint	recon-enum	9	Python	https://github.com/securelyinsecure/recon-enum.git	python script to automate the usage of recon-ng. Based on the enum.sh script by @jhaddix
:::843	necrospider	Recon / Footprint	NecroSpider	7	Python	https://github.com/ch0udharyji/NecroSpider.git	NecroSpider a automates OSINT for threat intelligence and mapping your attack surface and an enhanced version 
:::844	recon-ng-bt_lookup	Recon / Footprint	recon-ng-bt_lookup	7	Python	https://github.com/sam-b/recon-ng-bt_lookup.git	A BT lookup module for recon-ng
:::845	nextkool-spiderfoot	Recon / Footprint	Spiderfoot	6	Python	https://github.com/NextKool/Spiderfoot.git	SpiderFoot automates OSINT for threat intelligence and mapping your attack surface
:::846	vulp1n3-recon-ng-modules	Recon / Footprint	recon-ng-modules	6	Python	https://github.com/vulp1n3/recon-ng-modules.git	modules for the Recon-NG framework
:::847	recon-scripts	Recon / Footprint	recon-scripts	5	Python	https://github.com/rogueclown/recon-scripts.git	a set of scripts to make recon using recon-ng even easier
:::848	blackbird-venv	Recon / Footprint	Blackbird-venv	5	Shell	https://github.com/commander-Z3R0/Blackbird-venv.git	Running Blackbird an OSINT tool in virtual environment
:::849	vkontakte-contacts-recon-ng	Recon / Footprint	vkontakte-contacts-recon-ng	4	Python	https://github.com/lctrcl/vkontakte-contacts-recon-ng.git	Vkontakte contacts module for recon-ng
:::850	recon-ng_modules_dorks	Recon / Footprint	recon-ng_modules_dorks	4	Python	https://github.com/blacknon/recon-ng_modules_dorks.git	Recon-ng modules that retrieve results from various search engines
:::851	th3inspector-python	Recon / Footprint	Th3inspector-python	4	-	https://github.com/chasexcole86/Th3inspector-python.git	Th3Inspector :male_detective: Best Tool For Information Gathering on Python :mag_right:
:::852	trashrecon	Recon / Footprint	TrashRecon	4	Python	https://github.com/Somchandra17/TrashRecon.git	Ultimate Automation using tools like puredns, httpx, dnsx, smap, aquatone, waybackurls, gf, massdns, subzy, wa
:::853	reconmaster	Recon / Footprint	ReconMaster	4	Python	https://github.com/shlokkokk/ReconMaster.git	A professional, automated reconnaissance framework for bug bounty hunters and penetration testers. Integrates 
:::854	django-maps-scripting	Recon / Footprint	django-maps-scripting	3	HTML	https://github.com/ConnorXploit/django-maps-scripting.git	Django, MapBox, Info gathering, Recon-ng, Metasploit, Empire
:::855	recon-ng-baidu_site-module-rewrite	Recon / Footprint	recon-ng-baidu_site-module-rewrite	3	Python	https://github.com/F4l13n5n0w/recon-ng-baidu_site-module-rewrite.git	recon-ng baidu_site module rewrite
:::856	anonhackerx-recon-ng	Recon / Footprint	Recon-ng	3	-	https://github.com/AnonHackerx/Recon-ng.git	git clone https://github.com/lanmaster53/recon-ng.git
:::857	datahawk	Recon / Footprint	DataHawk	2	Shell	https://github.com/damnkrishna/DataHawk-.git	A modular OSINT suite to automate recon using Sherlock, Maigret, Holehe,PhoneInfoga and theHarvester no API ke
:::858	docker-recon_ng	Recon / Footprint	docker-recon_ng	2	Shell	https://github.com/threatnoodle/docker-recon_ng.git	LaNMaSteR53's recon-ng in a docker container
:::859	recon-ng-plugins	Recon / Footprint	recon-ng-plugins	2	Python	https://github.com/BastienFaure/recon-ng-plugins.git	A repo aiming to host custom recon-ng plugins
:::860	mirage	Recon / Footprint	Mirage	1	-	https://github.com/gmh5225/Mirage.git	Mirage is aim to a be a complete rewrite and refactor of Spiderfoot in RUST to help automates OSINT for threat
:::861	fork42541-recon-ng	Recon / Footprint	recon-ng	1	Python	https://github.com/fork42541/recon-ng.git	git clone https://LaNMaSteR53@bitbucket.org/LaNMaSteR53/recon-ng.git
:::862	hgprofiler	Recon / Footprint	hgprofiler	1	Python	https://github.com/jasonrhaas/hgprofiler.git	HG Profiler based off of the profiler module from recon-ng
:::863	recon-ripe	Recon / Footprint	recon-ripe	1	Python	https://github.com/hljupkij/recon-ripe.git	Recon-ng modules for RIPE-DB queries
:::864	automated-recon-ng	Recon / Footprint	automated-recon-ng	1	Shell	https://github.com/SamShanks1/automated-recon-ng.git	Recon-ng automation script
:::865	recon-ngx	Recon / Footprint	recon-ngx	1	Python	https://github.com/xvzfopt/recon-ngx.git	recon-ng Extended - A new iteration of recon-ng with added features and Quality of Life improvements
:::866	azrecon-ng	Recon / Footprint	AzRecon-ng	1	PowerShell	https://github.com/Ramikan/AzRecon-ng.git	Automated Tool for Azure Recon
:::867	recon-ng_googler_setup	Recon / Footprint	Recon-ng_Googler_Setup	1	-	https://github.com/JessicaIveyAllen/Recon-ng_Googler_Setup.git	This repository provides installation, configuration, and usage instructions for Recon-ng and Googler on Ubunt
:::868	b-i-quiz-nh-gi-ki-n-th-c-n-n-t-ng-red-te	Recon / Footprint	B-i-quiz-nh-gi-ki-n-th-c-n-n-t-ng-red-te	1	HTML	https://github.com/pifaas/B-i-quiz-nh-gi-ki-n-th-c-n-n-t-ng-red-team-m-ng-recon-v-khai-th-c-c-b-n.-Observer-Phase-v2.6.git	Bi nh gi nn tng dnh cho red team, tp trung vo kin thc mng, trinh st v khai thc c bn
:::869	togg53192-cmd-recon	Recon / Footprint	recon	1	Python	https://github.com/togg53192-cmd/recon.git	OSINT aggregator using publicly available tools and external tools  optional  like blackbird, sherlock to gi
:::870	social-media-footprint-analysis	Recon / Footprint	Social-Media-Footprint-Analysis	0	-	https://github.com/ESTHER552/Social-Media-Footprint-Analysis.git	An OSINT Open-Source Intelligence assessment of the publicly available social media footprint of an authoriz
:::871	alaminsarkar0-userrecon	Recon / Footprint	userrecon	0	-	https://github.com/alaminsarkar0/userrecon.git	OSINT Framework User Recon
:::872	nezzzumi-userrecon	Recon / Footprint	userrecon	0	Python	https://github.com/nezzzumi/userrecon.git	Script para buscar um nome de usurio em vrios sites
:::873	pranav2510-ipdrone	Recon / Footprint	IPDRONE	0	Python	https://github.com/pranav2510/IPDRONE.git	A automated tool for ip recon and information gathering
:::874	gokulakannan468-theharvester	Recon / Footprint	theHarvester	0	-	https://github.com/gokulakannan468/theHarvester.git	Used theHarvester tool to gather OSINT information such as emails, subdomains, IP addresses, and hostnames fro
:::875	badfish5150-recon-ng	Recon / Footprint	recon-ng	0	Python	https://github.com/badfish5150/recon-ng.git	The glorious recon-ng project, which is super cool
:::876	jaisanas-hgprofiler	Recon / Footprint	hgprofiler	0	JavaScript	https://github.com/jaisanas/hgprofiler.git	HG Profiler based on the profiler module from recon-ng
:::877	lu-chi-recon-ng	Recon / Footprint	recon-ng	0	Shell	https://github.com/lu-chi/recon-ng.git	Dockerized recon-ng
:::878	carlosmarq-recon	Recon / Footprint	recon	0	Shell	https://github.com/carlosmarq/recon.git	Recon-ng scripts
:::879	kefkahacks-recon-ng	Recon / Footprint	recon-ng	0	Python	https://github.com/kefkahacks/recon-ng.git	another recon-ng mirror
:::880	pawankumar9-recon-ng-modules	Recon / Footprint	recon-ng-modules	0	Python	https://github.com/Pawankumar9/recon-ng-modules.git	Modules for recon-ng
:::881	information-gathering-with-recon-ng-2026	Recon / Footprint	information-gathering-with-recon-ng-2026	0	Python	https://github.com/AiHd1/information-gathering-with-recon-ng-20260711-1246.git	Information Gathering with Recon-ng
:::882	itamae-recon-ng	Recon / Footprint	itamae-recon-ng	0	-	https://github.com/ninoseki/itamae-recon-ng.git	Itamae scripts for Recon-ng
:::883	snooplet	Recon / Footprint	snooplet	0	-	https://github.com/T145/snooplet.git	Wandering spirit inspired by Recon-NG
:::884	attack-surface-mapping-recon-ng	Recon / Footprint	Attack-Surface-Mapping-Recon-ng	0	-	https://github.com/yahyayousaf078/Attack-Surface-Mapping-Recon-ng.git	Passive OSINT reconnaissance using Recon-ng
:::885	network-recon-airodump-ng	Recon / Footprint	network-recon-airodump-ng	0	-	https://github.com/AiHd1/network-recon-airodump-ng.git	Educational project: Network Recon with Airodump-ng
:::886	auto-recon	Recon / Footprint	auto-recon	0	Python	https://github.com/KingSeth982/auto-recon.git	Script for running tasks in recon-ng
:::887	birp	Recon / Footprint	birp	0	Python	https://github.com/snakesec/birp.git	Big Iron Recon Pwnage for ANDRAX-NG
:::888	pawankumarpandit-th3inspector	Recon / Footprint	Th3inspector	0	Perl	https://github.com/PawanKumarPandit/Th3inspector.git	Th3Inspector Best Tool For Information Gathering
:::889	itsami-th3inspector	Recon / Footprint	Th3inspector	0	-	https://github.com/iTsami/Th3inspector.git	Th3Inspector male_detective Best Tool For Information Gathering male_detective
:::890	recon-tool	Recon / Footprint	recon-tool	0	Shell	https://github.com/Ameen2255/recon-tool.git	Beginner-friendly recon tool using Sublist3r, assetfinder, and httpx to find subdomains and check live hosts w
:::891	sensitive-java-script-files-founder	Recon / Footprint	sensitive-java-script-files-founder	0	Shell	https://github.com/burhanuddin-down/sensitive-java-script-files-founder.git	Enhanced Bash bug-bounty script automates recon and JS-focused scanning. It enumerates subdomains amass, subf
:::892	blackbird-osint	Recon / Footprint	BlackBird-OSINT	0	Python	https://github.com/Nikosane/BlackBird-OSINT.git	BlackBird-OSINT is an open-source intelligence OSINT tool designed to gather and analyze publicly available 
:::893	sherlock	Username	sherlock	92282	Python	https://github.com/sherlock-project/sherlock.git	Hunt down social media accounts by username across social networks
:::894	maigret	Username	maigret	37854	Python	https://github.com/soxoj/maigret.git	Collect a dossier on a person by username from 6K websites
:::895	social-analyzer	Username	social-analyzer	24073	JavaScript	https://github.com/qeeqbox/social-analyzer.git	API, CLI, and Web App for analyzing and finding a person's profile in 1000 social media \ websites
:::896	osintgram	Username	Osintgram	14475	Python	https://github.com/Datalux/Osintgram.git	Osintgram is a OSINT tool on Instagram. It offers an interactive shell to perform analysis on Instagram accoun
:::897	blackbird	Username	blackbird	8487	Python	https://github.com/antoniaci/blackbird.git	An OSINT tool to search for accounts by username and email in social networks
:::898	user-scanner	Username	user-scanner	4939	Python	https://github.com/kaifcodec/user-scanner.git	2-in-1 Email Username OSINT suite featuring native MCP support for deep data extraction just from a single E
:::899	mr-holmes	Username	Mr.Holmes	4212	Python	https://github.com/Lucksi/Mr.Holmes.git	A Complete Osint Tool :mag:
:::900	snoop	Username	snoop	4032	Python	https://github.com/snooppr/snoop.git	Snoop OSINT world
:::901	gosearch	Username	gosearch	3664	Go	https://github.com/ibnaleem/gosearch.git	Search anyone's digital footprint across 300+ websites
:::902	whatsmyname	Username	WhatsMyName	2882	Python	https://github.com/WebBreacher/WhatsMyName.git	Community-maintained dataset of 700+ websites for finding accounts by username powers OSINT and digital footpr
:::903	nexfil	Username	nexfil	2620	Python	https://github.com/thewhiteh4t/nexfil.git	OSINT tool for finding profiles by username
:::904	linkedin2username	Username	linkedin2username	1856	Python	https://github.com/initstring/linkedin2username.git	OSINT Tool: Generate username lists for companies on LinkedIn
:::905	socialscan	Username	socialscan	1843	Python	https://github.com/iojw/socialscan.git	Python library for accurately querying username and email usage on online platforms
:::906	detectdee	Username	DetectDee	1817	Go	https://github.com/Yvesssn/DetectDee.git	DetectDee: Hunt down social media accounts by username, email or phone across social networks
:::907	crosslinked	Username	CrossLinked	1593	Python	https://github.com/m8sec/CrossLinked.git	LinkedIn enumeration tool to extract valid employee names from an organization through search engine scraping
:::908	username-anarchy	Username	username-anarchy	1469	Ruby	https://github.com/urbanadventurer/username-anarchy.git	Username tools for penetration testing
:::909	buildware-tools	Username	Buildware-Tools	1380	Python	https://github.com/v4lkyr0/Buildware-Tools.git	Buildware-Tools is an all-in-one multitool for security research and automation
:::910	userfinder	Username	UserFinder	1359	Shell	https://github.com/mishakorzik/UserFinder.git	OSINT tool for finding profiles by username
:::911	osint-tools	Username	osint-tools	1346	-	https://github.com/HowToFind-bot/osint-tools.git	OSINT open-source tools catalog
:::912	linkook	Username	linkook	1016	Python	https://github.com/JackJuly/linkook.git	An OSINT tool for discovering linked social accounts and associated emails across multiple platforms using a s
:::913	mailcat	Username	mailcat	941	Python	https://github.com/sharsil/mailcat.git	Find existing email addresses by nickname using API/SMTP checking methods without user notification. Please, d
:::914	enola	Username	enola	876	Go	https://github.com/TheYahya/enola.git	This is Sherlock's sister, Modern shiny CLI tool written with Golang to help you: Hunt down social media accou
:::915	thebigbrother	Username	TheBigBrother	763	Python	https://github.com/chadi0x/TheBigBrother.git	The Big Brother V6.0 is a weaponized OSINT platform featuring username enumeration 473+ platforms, quad-vect
:::916	emora-project	Username	Emora-Project	718	C#	https://github.com/idefasoft/Emora-Project.git	Emora is an OSINT tool like sherlock but with a GUI, which search for accounts by username across social netwo
:::917	ominis-osint	Username	Ominis-OSINT	620	Python	https://github.com/AnonCatalyst/Ominis-OSINT.git	This Python application is an OSINT Open Source Intelligence tool called Ominis OSINT - Web Hunter. It perfo
:::918	tools-termux	Username	Tools-termux	591	-	https://github.com/Taoviqinvicible/Tools-termux.git	1.[Script Termux] -Cmatrix *apt-get update *apt-get upgrade *apt-get install nmap *apt-get install python *apt
:::919	mailfinder	Username	MailFinder	590	Python	https://github.com/mishakorzik/MailFinder.git	OSINT tool for finding email by first and last name
:::920	the_spy_job	Username	The_spy_job	489	Python	https://github.com/XDeadHackerX/The_spy_job.git	The spy's job es una Herramienta enfocada al OSINT la cual cuenta con los mejores mtodos para recolectar Infor
:::921	telegramscraper	Username	telegramscraper	409	Python	https://github.com/DenizShabani/telegramscraper.git	Scraper and adder for Telegram supporting multiple accounts at the same time. Adds via Telegram API and only b
:::922	findme	Username	findme	358	HTML	https://github.com/0xSaikat/findme.git	FindME is a CLI tool for searching social media and online profiles linked to a username. Its ideal for reconn
:::923	vesper	Username	vesper	331	Rust	https://github.com/krishpranav/vesper.git	A simple username osint tool built in rust
:::924	marple	Username	marple	326	Python	https://github.com/soxoj/marple.git	Collect links to profiles by username through search engines and analyze with various plugins
:::925	insta-osint	Username	INSTA-OSINT	325	Python	https://github.com/HunxByts/INSTA-OSINT.git	is a tool to find as much information as possible on Instagram accounts, such as username, full username, post
:::926	ch3r0	Username	ch3r0	325	-	https://github.com/tnt-wolve/ch3r0.git	Hackingtool Menu AnonSurf Information Gathering Password Attack Wireless Attack SQL Injection Tools Phishing A
:::927	gitrecon	Username	gitrecon	324	Python	https://github.com/GONZOsint/gitrecon.git	OSINT tool to get information from a Github and Gitlab profile and find user's email addresses leaked on commi
:::928	querytool	Username	querytool	321	HTML	https://github.com/osintshifu/querytool.git	A local-first, standalone OSINT query tool for filtering sources and opening targeted searches
:::929	investigo	Username	Investigo	283	Go	https://github.com/tdh8316/Investigo.git	Find usernames and download their data across social media
:::930	mcp-maigret	Username	mcp-maigret	263	JavaScript	https://github.com/w0h1v/mcp-maigret.git	MCP server for maigret, a powerful OSINT tool that collects user account information from various public sourc
:::931	gitsint	Username	GitSint	259	Python	https://github.com/N0rz3/GitSint.git	OSINT Tool github tracker
:::932	hippie-osint-toolkit	Username	Hippie-OSINT-Toolkit	242	TypeScript	https://github.com/hippiiee/Hippie-OSINT-Toolkit.git	A web based OSINT ressource and tool
:::933	threat-actor-usernames-scrape	Username	Threat-Actor-Usernames-Scrape	238	-	https://github.com/spmedia/Threat-Actor-Usernames-Scrape.git	A collection lists of intel and usernames scraped from various cybercrime sources forums. DarkForums, HackForu
:::934	prism-platform	Username	Prism-platform	232	Python	https://github.com/NovaCode37/Prism-platform.git	Self-hosted OSINT platform. Point it at a domain, IP, email, phone or username and 26 modules run in parallel:
:::935	the-black-tiger	Username	The-Black-Tiger	209	Python	https://github.com/VirusZzHkP/The-Black-Tiger.git	The Black Tiger is all in one OSINT Tool, which has the best methods to collect Information about something or
:::936	uosint	Username	uosint	191	Python	https://github.com/uosint-project/uosint.git	This tool will help you to find the information of USERNAME. Before there are many tools that just show that t
:::937	username-generation-guide	Username	username-generation-guide	180	Python	https://github.com/soxoj/username-generation-guide.git	A definitive guide to generating usernames for OSINT purposes
:::938	cupidcr4wl	Username	cupidcr4wl	175	Python	https://github.com/OSINTI4L/cupidcr4wl.git	cupidcr4wl is an Open-Source Intelligence username and phone number search tool that crawls adult content plat
:::939	ghostintel	Username	GhostIntel	163	HTML	https://github.com/ruyynn/GhostIntel.git	GhostIntel is a Python-based OSINT framework for digital investigation using public data such as username, ema
:::940	unve1ler	Username	unve1ler	161	Python	https://github.com/spyboy-productions/unve1ler.git	A social engineering tool designed to seamlessly locate profiles using usernames while offering convenient rev
:::941	hack-sql	Username	Hack-SQL	147	-	https://github.com/Don-No7/Hack-SQL.git	File generated with SQLiteStudio v3.2.1 on Sun Feb 7 14:58:28 2021 -- -- Text encoding used: System -- PRAGMA 
:::942	handlehawk	Username	HandleHawk	144	HTML	https://github.com/C3n7ral051nt4g3ncy/HandleHawk.git	Cross-platform username reconnaissance tool built for OSINT investigators, cyber threat analysts, red teamers,
:::943	guns-lol-username-checker	Username	guns.lol-username-checker	144	Python	https://github.com/efekrbas/guns.lol-username-checker.git	Find unclaimed guns.lol usernames
:::944	whatsmyname-python	Username	WhatsMyName-Python	144	HTML	https://github.com/C3n7ral051nt4g3ncy/WhatsMyName-Python.git	As a regular contributor to Project WhatsMyName, this is a script I made for myself to check sites are working
:::945	mgz-staze-tools-termux	Username	tools-Termux	144	-	https://github.com/MGz-Staze/tools-Termux.git	Cara Update dan Upgrade Termux pkg update pkg upgrade Tools Pendukung untuk Termux Tools pendukung yang di per
:::946	bridgekeeper	Username	BridgeKeeper	131	Python	https://github.com/0xZDH/BridgeKeeper.git	Scrape, Hunt, and Transform names and usernames
:::947	spy	Username	SPY	125	Python	https://github.com/CYB3R-G0D/SPY.git	An OSINT python tool to scan social media accounts by username across social networks
:::948	tracer	Username	tracer	119	Python	https://github.com/chr3st5an/tracer.git	Tracer is an OSINT tool that can be used to detect on which websites a username is currently in use
:::949	github	Username	github	99	-	https://github.com/sherlock-bot-osint/.github.git	Sherlock Bot OSINT Telegram 2026. , @username, ID. Sherlock Report Sonar 22.5 . : 100 30 . . . 2
:::950	odinova	Username	Odinova	94	Python	https://github.com/AnonCatalyst/Odinova.git	Odinova Digital Tiger is an advanced application designed for Open-Source Intelligence OSINT, equipped with 
:::951	whocord	Username	WhoCord	94	Python	https://github.com/Siv-nick/WhoCord.git	Scans Discord links across mutual guilds to extract profiles, crossreferences 700+ sites, searches usernames w
:::952	maigret-maltego	Username	maigret-maltego	93	Python	https://github.com/soxoj/maigret-maltego.git	Maltego transformation for searching of accounts by username
:::953	socialrecon	Username	SocialRecon	89	Python	https://github.com/0xRamInf0sec/SocialRecon.git	This is an Open source intelligence tool and used to gather information about social media and it is also used
:::954	hashtray	Username	hashtray	83	Python	https://github.com/balestek/hashtray.git	hashtray is an OSINT Open Source Intelligence tool designed to find a Gravatar account associated with an em
:::955	telespotter	Username	Telespotter	79	Rust	https://github.com/thumpersecure/Telespotter.git	A version of Telespot in RUST - a tool that searches telephone numbers across Google, Bing, DuckDuckGo, and De
:::956	mesuutt-sherlock	Username	sherlock	79	Go	https://github.com/mesuutt/sherlock.git	:mag_right: Find usernames across social networks
:::957	mailfoguess	Username	Mailfoguess	77	Python	https://github.com/WildSiphon/Mailfoguess.git	OSINT tool to guess and verify the email address of a person from information such as firstname, middlename, l
:::958	xtrack	Username	Xtrack	71	Python	https://github.com/Whomrx666/Xtrack.git	Xtrack is a tracking tool that can be used to track IP addresses, telephone numbers and usernames
:::959	digi-netra	Username	DIGI-NETRA	69	Python	https://github.com/pwnxotus/DIGI-NETRA.git	DIGI-NETRA is a Python OSINT toolkit for digital investigations. Trace phone numbers , usernames , IPs , and e
:::960	sherlock-rs	Username	sherlock-rs	64	Rust	https://github.com/jonaylor89/sherlock-rs.git	Hunt down social media accounts by username across social networks
:::961	abhijithvijayan-sherlock	Username	sherlock	62	HTML	https://github.com/abhijithvijayan/sherlock.git	Find usernames across social networks
:::962	userrecon	Username	UserReCon	61	Python	https://github.com/vijaysahuofficial/UserReCon.git	This is a simple username recognition tool. It can search a username from over 200 different social media plat
:::963	anthophilee-spiderfoot	Username	SpiderFoot	44	-	https://github.com/anthophilee/SpiderFoot-.git	USES SpiderFoot can be used offensively e.g. in a red team exercise or penetration test for reconnaissance o
:::964	osintlab	Username	OSINTLAB	43	Shell	https://github.com/Purpl3-Dev/OSINTLAB.git	This script automates the installation of 50 OSINT tools for reconnaissance and information gathering
:::965	wiwok	Username	Wiwok	42	Python	https://github.com/Kirozaku/Wiwok.git	OSINT tool for username, email, and phone investigation. No API key required
:::966	userrecon-py	Username	userrecon-py	37	Python	https://github.com/stjordanis/userrecon-py.git	Find username in social networks. demo:
:::967	social-finder	Username	Social-Finder	35	Python	https://github.com/MattiaPasti/Social-Finder.git	Social Finder is an OSINT web app to search usernames across hundreds of platforms. Built with Flask and power
:::968	go-sherlock	Username	go-sherlock	34	Go	https://github.com/Longwater1234/go-sherlock.git	Minified version of Project Sherlock written in GO. Lookup given username from 1000 social networks
:::969	osint-beginner-field-guide	Username	OSINT-Beginner-Field-Guide	34	-	https://github.com/fawadqureshi007/OSINT-Beginner-Field-Guide.git	A practical beginner-friendly OSINT field guide covering username enumeration, social media, search engines, r
:::970	gxsuid	Username	gxsuid	33	Python	https://github.com/mrofcodyx/gxsuid.git	gxsuid is a powerful tool for interacting with Instagram profiles. It offers comprehensive functionalities suc
:::971	userreconog	Username	userreconOG	32	Shell	https://github.com/Graey/userreconOG.git	A script to find usernames across over 75 social networks
:::972	philint	Username	philINT	28	Python	https://github.com/ajuelosemmanuel/philINT.git	OSINT tool that allows to gather information from an email address, an username, and more
:::973	cupp-rs	Username	cupp-rs	28	Rust	https://github.com/ElNiak/cupp-rs.git	Common User Passwords Profiler CUPP in Rust
:::974	mbahd3m4n6	Username	mbahd3m4n6	28	-	https://github.com/60-n3z/mbahd3m4n6.git	# /data/data/com.termux/files/usr/bin/bash # Auto Install Tools v.2.1 # coded By Mr.60-n3z # dark line asosias
:::975	gopher-find	Username	Gopher-Find	27	Go	https://github.com/caetano-dev/Gopher-Find.git	Gopher Find is a blazingly fast alternative to Sherlock written in Golang. It is an OSINT tool that looks for 
:::976	mohamad-mortada-osintgram	Username	Osintgram	25	Python	https://github.com/Mohamad-Mortada/Osintgram.git	Osintgram is a OSINT tool on Instagram. It offers an interactive shell to perform analysis on Instagram accoun
:::977	osint-ui	Username	osint-ui	25	-	https://github.com/afsh4ck/osint-ui.git	Professional Open Source Intelligence Platform
:::978	osint-exposure-toolkit	Username	osint-exposure-toolkit	25	HTML	https://github.com/SagarBiswas-MultiHAT/osint-exposure-toolkit.git	OSINT Exposure Toolkit: A modular, passive reconnaissance CLI that inspects emails, domains, and usernames for
:::979	yan	Username	yan	24	-	https://github.com/mamahsayang/yan.git	# /data/data/com.termux/files/usr/bin/bash # DIAN HERMAWAN # coded By MASTER HACKER # copyright 2019 # WELCOME
:::980	web-sherlock	Username	web-sherlock	23	Python	https://github.com/azurejoga/web-sherlock.git	A Web GUI Interface built with Flask to search for usernames across social networks using the Sherlock project
:::981	ghosts-tracer	Username	ghosts-tracer	21	Python	https://github.com/cyberghosts02/ghosts-tracer.git	Ghost - Tracer is a terminal-based OSINT tool for ethical hackers and investigators. It offers features like I
:::982	user-recon	Username	User-Recon	18	-	https://github.com/anthophilee/User-Recon.git	User Recon Find usernames across over 75 social networks This is useful if you are running an investigation to
:::983	al-alamysploit-userrecon	Username	UserRecon	17	Shell	https://github.com/AL-AlamySploit/UserRecon.git	Find usernames across over 75 social networks This is useful if you are running an investigation to determine 
:::984	worldofcyberskills-blackbird	Username	Blackbird	16	Python	https://github.com/worldofcyberskills/Blackbird.git	Blackbird:- An OSINT tool to search fast for accounts by username across 131 sites
:::985	twitterusernamefromuserid	Username	twitterUsernamefromUserID	16	Python	https://github.com/rishi-raj-jain/twitterUsernamefromUserID.git	twitterUsernameviaUserID is an advanced Twitter scraping tool written in Python and Selenium that allows for s
:::986	whomrx666-userfinder	Username	UserFinder	15	Shell	https://github.com/Whomrx666/UserFinder.git	This is an OSINT tool for searching targets using the target's username
:::987	reccon	Username	Reccon	13	TypeScript	https://github.com/sammwyy/Reccon.git	Web-based OSINT application designed to detect and gather usernames across platforms, based on Sherlock Projec
:::988	dark-sherlock	Username	dark-sherlock	13	Python	https://github.com/banaxou/dark-sherlock.git	csint tool username dark sherlock
:::989	email_to_github_account	Username	Email_to_Github_account	12	Python	https://github.com/FuzzingMyGF/Email_to_Github_account.git	An OSINT tool that permit to obtain the username of an Github account by simply specifying a mail adress, even
:::990	bhikandeshmukh-userrecon	Username	userrecon	12	Shell	https://github.com/bhikandeshmukh/userrecon.git	This is useful if you are running an investigation to determine the usage of the same username on different so
:::991	osint-ai-agent	Username	OSINT-AI-Agent	11	Python	https://github.com/sumba101/OSINT-AI-Agent.git	A claude agent with skills for OSINT capabilities. Leverages Holehe, Sherlock and a personal fork of Ghunt to 
:::992	grabber	Username	GRABBER	11	Python	https://github.com/MrEchoFi/GRABBER.git	An IP Tracer , Username Tracer based tool
:::993	noimosiny-checker	Username	noimosiny-checker	10	Python	https://github.com/soxoj/noimosiny-checker.git	Reverse account search by phone number, email address, username
:::994	sherlock2-0	Username	sherlock2.0	10	Python	https://github.com/baum1810/sherlock2.0.git	a project wich can be used to find infomations about a username educational purposes only
:::995	fox-userfinder	Username	Fox-UserFinder	9	Python	https://github.com/BlackFoxTM/Fox-UserFinder.git	Fox User Finder OSINT Good For finding Username for hacking
:::996	n1xyosint	Username	n1xYosint	7	Python	https://github.com/n11xY/n1xYosint.git	Async, plugin-based OSINT recon for usernames, emails names 90+ sources, confidence-scored, built for Kali Lin
:::997	nwokike-sherlock	Username	Sherlock	7	Python	https://github.com/Nwokike/Sherlock.git	Sherlock: Hunt down social media accounts by username across 3000+ networks. Built with Python and Flet
:::998	osint-profiler	Username	OSINT-Profiler	7	Python	https://github.com/jeraldbenny/OSINT-Profiler.git	OSINT Profiler is a powerful open intelligence investigation tool investigate emails, phones usernames with GU
:::999	sherlock-termux	Username	Sherlock-Termux	7	-	https://github.com/Achik-Ahmed/Sherlock-Termux.git	Sherlock is a popular tool that is used to find someone's all social media platforms accounts just by their us
:::1000	sherlock-mcp	Username	sherlock-mcp	7	Python	https://github.com/Burnsedia/sherlock-mcp.git	Sherlock MCP Server: Find truth and counter propaganda through ethical OSINT. FastMCP integration for social m
:::1001	jarvis	Username	jarvis	7	Python	https://github.com/yokarakas/jarvis.git	MARK LS is a real-time cross-platform voice AI built on Gemini Live API. Featuring OSINT username lookup acros
:::1002	user-finder	Username	user-finder	7	Python	https://github.com/prc-github-prc/user-finder.git	Python script to automatically test usernames with different websites
:::1003	pinkycourse-ghostintel	Username	GhostIntel	6	HTML	https://github.com/pinkycourse/GhostIntel.git	Analyze phone numbers, usernames, emails, and IP information with GhostIntel, an open-source OSINT framework b
:::1004	dorkscout	Username	DorkScout	6	Python	https://github.com/TnYtCoder/DorkScout.git	DorkScout Ultimate OSINT Investigation Tool. Direct checks, Google search, Tor proxy, advanced dorking, and br
:::1005	bhikandeshmukh-sherlock	Username	sherlock	6	Python	https://github.com/bhikandeshmukh/sherlock.git	social media username mapper
:::1006	oli97430-sherlock-rs	Username	sherlock-rs	6	HTML	https://github.com/Oli97430/sherlock-rs.git	Hunt down social media accounts by username - Rust rewrite with modern web UI
:::1007	notslater-sherlock2-0	Username	Sherlock2.0	5	Python	https://github.com/NotSlater/Sherlock2.0.git	Sherlock is a username searching program that scans many websites to see if that username is taken. This is a 
:::1008	profile-finder	Username	profile-finder	5	Python	https://github.com/dika-maulidal/profile-finder.git	Scan Social Media Accounts based on Usernames Accurately
:::1009	tsun	Username	Tsun	5	-	https://github.com/injectionmethod/Tsun.git	Web Crawler For Usernames, Idea Based Off Of Sherlock But Made In C#
:::1010	instagram-username-finder	Username	instagram-username-finder	5	Python	https://github.com/FadeHack/instagram-username-finder.git	A responsible, open-source Instagram username availability scanner. Async CLI with bounded concurrency, rate-l
:::1011	mr-homes-by-hanan-asif	Username	Mr.Homes-by-Hanan-Asif	5	Python	https://github.com/thehananasif/Mr.Homes-by-Hanan-Asif.git	Mr.Holmes is an open-source OSINT tool for gathering information on domains, usernames, and phone numbers usin
:::1012	nurodev-sherlock	Username	sherlock	4	TypeScript	https://github.com/NuroDev/sherlock.git	Check social media accounts usernames
:::1013	sherlock-java	Username	sherlock-java	4	Java	https://github.com/Longwater1234/sherlock-java.git	Minified Java version of sherlock project sherlock-project/sherlock, Looks up username in 1000 social sites
:::1014	sherlock-telegram-bot	Username	sherlock-telegram-bot	4	Python	https://github.com/hadi-hoho/sherlock-telegram-bot.git	Hunt down social media accounts by username across social networks intelegram
:::1015	sherlock-the-social-media-hunter	Username	Sherlock-the-social-media-hunter	4	Python	https://github.com/chanakayaa/Sherlock-the-social-media-hunter.git	It is a Kali linux CLI tool use to search a username across various social media
:::1016	adler	Username	adler	4	Rust	https://github.com/commit3296/adler.git	OSINT username search across ~3,000 sites, in Rust. Honest verdicts and built to reach the hard ones Cloudflar
:::1017	osint-hub	Username	OSINT-Hub	4	Python	https://github.com/x1n-Q/OSINT-Hub.git	All-in-One OSINT Framework with modern GUI and powerful CLI. Username search across 300+ sites, email/domain/I
:::1018	shaunlwm-sherlock	Username	sherlock	3	JavaScript	https://github.com/ShaunLWM/sherlock.git	Find usernames across social networks
:::1019	shakenetwork-sherlock	Username	sherlock	3	Python	https://github.com/shakenetwork/sherlock.git	Find usernames across social networks
:::1020	sherlock-osint-manual-2025	Username	Sherlock-OSINT-Manual-2025	3	-	https://github.com/ContactAlexey/Sherlock-OSINT-Manual-2025.git	2025 updated manual for Sherlock, a tool to search usernames online, with installation via pipx, usage instruc
:::1021	daiosint	Username	DaiOSINT	3	-	https://github.com/selfcentered/DaiOSINT.git	DaiOSINT collect a dossier on a person by username only, checking for accounts on a huge number of sites and g
:::1022	alvinbaby-userrecon	Username	UserRecon	3	Shell	https://github.com/alvinbaby/UserRecon.git	UserRecon v1.0 Find usernames across over 75 social networks This is useful if you are running an investigatio
:::1023	9glenda-enola	Username	enola	2	Go	https://github.com/9glenda/enola.git	This is Sherlock's sister, Modern shiny CLI tool written with Golang to help you: Hunt down social media accou
:::1024	post04-sherlock	Username	sherlock	2	Go	https://github.com/post04/sherlock.git	searches social media sites for usernames
:::1025	haolamnm-sherlock	Username	sherlock	2	Python	https://github.com/haolamnm/sherlock.git	Simple checking username availability tool written in Python
:::1026	sherlock-project	Username	sherlock-project	2	Python	https://github.com/Esmeraldin999/sherlock-project.git	High quality account searcher by username, on over 400+ networks
:::1027	shenwin	Username	shenwin	2	Python	https://github.com/LattesGit/shenwin.git	Python OSINT tool for username enumeration across 500+ platforms with variation engine sherlock + winget
:::1028	sherlock-report-at-github	Username	github	2	-	https://github.com/sherlock-report-at/.github.git	Sherlock Report AT 2026. , , @username . Sonar 22.5  Telegram 100 30 . Sherlock Report . . 2
:::1029	zqrya-osint	Username	Zqrya-OSINT	2	Python	https://github.com/iyudhistira484-maker/Zqrya-OSINT.git	Zqrya v3.0 API-free OSINT framework. Investigate usernames, emails, phones, domains, IPs, and NIK/KTP from pub
:::1030	kiki-hub	Username	Kiki-Hub	2	HTML	https://github.com/kiki-koteyka/Kiki-Hub.git	OSINT tool for digital footprint discovery search by username or emai across VK, Telegram, 500+ sites, HaveIBe
:::1031	cyberflakeconnect-userrecon	Username	UserRecon	2	Shell	https://github.com/cyberflakeconnect/UserRecon.git	Find usernames across over 75 social networks This is useful if you are running an investigation to determine 
:::1032	user-finder-osint-tool	Username	user-finder-OSINT-tool	2	Python	https://github.com/72sevenzy2/user-finder-OSINT-tool.git	hello, this is a an simple osint tool ive made with python that searches a specific username that your searchi
:::1033	shadowtrace	Username	ShadowTrace	2	Python	https://github.com/sylhetyhackvenger/ShadowTrace.git	Shadow Tracer is a cyber intelligence OSINT framework for researchers investigators. It combines IP intelligen
:::1034	osintgram-gui	Username	osintgram-gui	2	Python	https://github.com/azerxafro/osintgram-gui.git	Osintgram-gui is a OSINT tool on Instagram with GUI. It offers an interactive shell to perform analysis on Ins
:::1035	sherlockv2	Username	sherlockV2	1	Python	https://github.com/hanyxd/sherlockV2.git	Next-Gen Username OSINT Tool - Async username enumeration across 90+ sites with profile extraction, monitoring
:::1036	dhruv00098-sherlock	Username	sherlock	1	-	https://github.com/Dhruv00098/sherlock.git	Find social media accounts by username across 400+ networks
:::1037	2fxxd-sherlock	Username	sherlock	1	Python	https://github.com/2FXXD/sherlock.git	Hunt down social media accounts by username across social networks
:::1038	pawankumarpandit-sherlock	Username	Sherlock	1	Python	https://github.com/PawanKumarPandit/Sherlock.git	Hunt down social media accounts by username across social networks
:::1039	mitchikoy0305-sherlock	Username	Sherlock	1	-	https://github.com/Mitchikoy0305/Sherlock.git	Learning how to hack an account only using username with Sherlock tool
:::1040	cyber-academy-labs-sherlock	Username	sherlock	1	Python	https://github.com/cyber-academy-labs/sherlock.git	:mag_right: Hunt down social media accounts by username across social networks
:::1041	sherlock-v1	Username	Sherlock-V1	1	Python	https://github.com/FDegs/Sherlock-V1.git	A tool for searching accounts by username
:::1042	sherlock-net	Username	sherlock.net	1	C#	https://github.com/hershyz/sherlock.net.git	NET extendable clone of Sherlock - find usernames across social networks
:::1043	sherlock-eye	Username	SHERLOCK-EYE	1	Python	https://github.com/RoyaleSoftware/SHERLOCK-EYE.git	A tool for finding information by username and OSINT intelligence
:::1044	sherlock-cs	Username	Sherlock-cs	1	C#	https://github.com/weiajr/Sherlock-cs.git	Sherlock-cs is a reimagining of the popular username scraper, Sherlock, built with speed in mind
:::1045	avanced-sherlock	Username	avanced-sherlock	1	Python	https://github.com/a5007156/avanced-sherlock.git	A sherlock-like osint tool but it now checks variations of the username
:::1046	sherlock-osint	Username	sherlock-osint	1	Python	https://github.com/jvanleur2234-glitch/sherlock-osint.git	Sherlock OSINT Suite Find anyone by username, phone, or IP across 500+ social platforms
:::1047	bangkahdev-sherlock-java	Username	sherlock-java	1	Java	https://github.com/Bangkahdev/sherlock-java.git	Aplikasi ini digunakan untuk mencari keberadaan sebuah username di ratusan situs sosial media secara otomatis 
:::1048	hydrogen2-sherlock-rs	Username	sherlock-rs	1	Rust	https://github.com/hydrogen2/sherlock-rs.git	Hunt down social media accounts by username across ~480 sites a fast, single-binary Rust port of sherlock
:::1049	mikuru	Username	mikuru	1	TypeScript	https://github.com/p1atdev/mikuru.git	A modern Sherlock alternative built with Bun to find accounts by username
:::1050	moriarty	Username	moriarty	1	Ruby	https://github.com/decentralizuj/moriarty.git	Moriarty - Tool to check social networks for available username
:::1051	nebraska	Username	Nebraska	1	Python	https://github.com/Belchite/Nebraska.git	OSINT username reconnaissance tool
:::1052	tracelock	Username	TraceLock	1	Python	https://github.com/codewithzaqar/TraceLock.git	A simple Sherlock-style Python tool to check if a username exists across multiple platforms
:::1053	poirot	Username	poirot	1	Python	https://github.com/DylanMcBean/poirot.git	An osint tool for searching peoples usernames, based of the already famous tool called sherlock
:::1054	moderation-scanner	Username	moderation-scanner	1	Python	https://github.com/Ven0m0/moderation-scanner.git	Multi-source account intelligence: Reddit toxicity analysis + Sherlock username search across multiple platfor
:::1055	trace-board	Username	trace-board	1	HTML	https://github.com/mechmukul/trace-board.git	Visual OSINT board: investigate a username across ~38 platforms with clickable profile links; import Sherlock 
:::1056	open-source-intelligence-platform	Username	OPEN-SOURCE-INTELLIGENCE-PLATFORM	1	Python	https://github.com/techie-aman2007/OPEN-SOURCE-INTELLIGENCE-PLATFORM.git	An OSINT platform built with Django that integrates AI-powered website search, deep research using Gemini, and
:::1057	osint-name-checker	Username	OSINT-Name-Checker	1	Python	https://github.com/quelquun667/OSINT-Name-Checker.git	Multithreaded CLI tool to check username availability across 40+ social/dev platforms Instagram, GitHub, Redd
:::1058	gregoirener-horus	Username	HORUS	1	-	https://github.com/gregoirener/HORUS.git	Eye of Horus is an ethical OSINT username checker combining Maigret Sherlock databases. Quickly scans hundreds
:::1059	lachydotmcg-argus	Username	argus	1	Python	https://github.com/lachydotmcg/argus.git	See yourself the way the internet sees you. Self-OSINT footprint scanner: username enumeration across 30+ plat
:::1060	omniscan	Username	omniscan	1	Python	https://github.com/HubDamian95/omniscan.git	Username and email availability scanner with full-spectrum coverage. Combines accurate registration-API checks
:::1061	telegram-osint-bot	Username	Telegram-Osint-bot	1	Python	https://github.com/cyberguy256/Telegram-Osint-bot.git	Telegram OSINT bot that searches usernames/emails across 700+ sites Blackbird and scans links VirusTotal, 
:::1062	gretonline	Username	gretonline	1	Python	https://github.com/Anzo52/gretonline.git	Maigret with a web interface. IN DEVELOPMENT
:::1063	maigret-llm	Username	maigret-llm	1	Python	https://github.com/MATHEUSFELIX/maigret-llm.git	Maigret + LLM: OSINT inteligente com sntese narrativa, expanso de usernames e agente autnomo
:::1064	sajawal-hacker-userrecon	Username	userrecon	1	Shell	https://github.com/Sajawal-hacker/userrecon.git	Find usernames across over 75 social networks This is useful if you are running an investigation to determine 
:::1065	userrecon-2-0	Username	Userrecon-2.0	1	Shell	https://github.com/Ranjithkumar567/Userrecon-2.0.git	Find usernames across over 75 social networks This is useful if you are running an investigation to determine 
:::1066	osint-username-finder	Username	osint-username-finder	1	Python	https://github.com/amokahal/osint-username-finder.git	Python tool to search usernames across multiple platforms
:::1067	zeroxploit-code-sherlock	Username	sherlock	0	Shell	https://github.com/zeroXploit-code/sherlock.git	Osint username
:::1068	janelhuang28-sherlock	Username	Sherlock	0	-	https://github.com/janelhuang28/Sherlock.git	Tool to find username
:::1069	mato002-sherlock	Username	sherlock	0	-	https://github.com/mato002/sherlock.git	hunting down usernames using sherlock
:::1070	sherlock-web	Username	sherlock-web	0	HTML	https://github.com/amelia999-whimsy/sherlock-web.git	Sherlock Web Interface - Username Finder
:::1071	igorrozani-sherlock	Username	sherlock	0	Go	https://github.com/IgorRozani/sherlock.git	Find usernames across social networks
:::1072	sherlock4win	Username	sherlock4win	0	Python	https://github.com/sk1tzwzd/sherlock4win.git	Sherlock username search GUI for Windows and Linux
:::1073	sherlock-username-enumeration-lab	Username	Sherlock-Username-Enumeration-Lab	0	-	https://github.com/andrewknowyou/Sherlock-Username-Enumeration-Lab.git	OSINT lab demonstrating username enumeration, digital footprint analysis, and public profile discovery using S
:::1074	priestd09-sherlock	Username	sherlock	0	Go	https://github.com/priestd09/sherlock.git	:mag_right: Find usernames across multiple social networks
:::1075	maryams24-sherlock	Username	Sherlock	0	Python	https://github.com/maryams24/Sherlock.git	Username Detection and Data Analysis with Python This project leverages the open-source tool Sherlock to detec
:::1076	sable-hops-sherlock	Username	sherlock	0	-	https://github.com/sable-hops/sherlock.git	Hunt down social media accounts by username across social networks
:::1077	unwanted666dkjf-sherlock	Username	sherlock	0	Python	https://github.com/unwanted666dkjf/sherlock.git	Hunt down social media accounts by username across social networks
:::1078	kirojava-sherlock	Username	sherlock	0	-	https://github.com/Kirojava/sherlock.git	Hunt down social media accounts by username across social networks
:::1079	jako-art-sherlock	Username	sherlock	0	Python	https://github.com/jako-art/sherlock.git	Hunt down social media accounts by username across social networks
:::1080	marketbypass333-ui-sherlock	Username	sherlock	0	-	https://github.com/marketbypass333-ui/sherlock.git	Hunt down social media accounts by username across social networks
:::1081	deco31416-sherlock	Username	sherlock	0	Python	https://github.com/deco31416/sherlock.git	Hunt down social media accounts by username across social networks
:::1082	sherlock-js	Username	sherlock-js	0	JavaScript	https://github.com/brion25/sherlock-js.git	Find username across social networks JS implementation
:::1083	vladutz1000-sherlock	Username	sherlock	0	-	https://github.com/vladutz1000/sherlock.git	Hunt down social media accounts by username across social networks
:::1084	lolaboonz-sherlock	Username	sherlock	0	-	https://github.com/lolaboonz/sherlock.git	Hunt down social media accounts by username across social networks
:::1085	dubois	Username	dubois	0	Python	https://github.com/maintenancetunnels/dubois.git	DuBois: downstream Sherlock fork. Hunt usernames across social networks
:::1086	blackbird-username-email	Username	Blackbird---Username-email	0	-	https://github.com/Outils-Osint/Blackbird---Username-email.git	An OSINT tool to search for accounts by username and email in social networks
:::1087	blackbird-osint-toolkit	Username	BlackBird-OSINT-Toolkit	0	Python	https://github.com/ritikkalmeghe9-cpu/BlackBird-OSINT-Toolkit.git	A lightweight, terminal-based Offensive OSINT Toolkit for Kali Linux. Features IP geolocation, phone number OS
:::1088	dove	Username	Dove	0	Python	https://github.com/drew-codes-things/Dove.git	Unified OSINT lookup - username, email, phone and name checks across sherlock, maigret, blackbird, holehe and 
:::1089	blackbird-gui	Username	Blackbird-GUI	0	Python	https://github.com/SAS-Group-org/Blackbird-GUI.git	Blackbird is a powerful OSINT tool that combines fast username and email searches across more than 600 platfor
:::1090	une-sys-nexusint	Username	Nexusint	0	Python	https://github.com/Une-Sys/Nexusint.git	A professional, multi-module OSINT toolkit that unifies username, email, phone and social investigation into a
:::1091	maigret-report	Username	maigret-report	0	HTML	https://github.com/outhsics/maigret-report.git	Maigret OSINT username search report
:::1092	osintusersunifyxxl	Username	osintusersunifyXXL	0	Python	https://github.com/XXL-MAN/osintusersunifyXXL.git	Bsqueda OSINT de usernames Sherlock, Maigret, Socialscan con verificacin HTTP y exportacin unificada a Excel
:::1093	osint-tool	Username	osint-tool	0	Python	https://github.com/1ymenn/osint-tool.git	Unified OSINT tool username search 3000+ platforms via Maigret + phone number lookup. Linux bash CLI
:::1094	maigret-rust	Username	maigret-rust	0	HTML	https://github.com/Skullmc1/maigret-rust.git	High-performance Rust implementation of Maigret username OSINT lookup tool
:::1095	maigret-web	Username	maigret-web	0	Python	https://github.com/ohg68/maigret-web.git	Maigret OSINT username search deployed as a web service on Railway
:::1096	maigret-to-json-examples	Username	maigret-to-json-examples	0	-	https://github.com/bondvit/maigret-to-json-examples.git	Runnable Python JS examples for the Maigret Username OSINT on Apify
:::1097	txltedxgod-osint-hub	Username	osint-hub	0	Python	https://github.com/txltedxgod/osint-hub.git	A FastAPI web app for username search across hundreds of sites with Sherlock Maigret. Educational purposes onl
:::1098	jovemsigilosodobembr-maigret	Username	Maigret	0	Python	https://github.com/jovemsigilosodobembr/Maigret.git	Deixe Sua doao
:::1099	x402-osint	Username	x402-osint	0	Python	https://github.com/x402-osint/x402-osint.git	Pay-per-call OSINT for AI agents: username + email recon in USDC on Base via x402. Free MCP discovery tools + 
:::1100	osint_dashboard	Username	osint_dashboard	0	Python	https://github.com/reory/osint_dashboard.git	A powerful, full-stack Open Source Intelligence OSINT workstation that automates username footprinting acros
:::1101	erzambayu-userrecon	Username	userrecon	0	Shell	https://github.com/Erzambayu/userrecon.git	Find usernames across over 30 modern social networks 2025 This is useful if you are running an investigation
:::1102	osint-userrecon	Username	osint-userrecon	0	-	https://github.com/alreemnawaf/osint-userrecon.git	OSINT investigation using UserRecon on Kali Linux to identify usernames across online platforms
:::1103	spikebigmoneylol-droid-osint-username-fi	Username	osint-username-finder	0	-	https://github.com/spikebigmoneylol-droid/osint-username-finder.git	OSINT Instagram, TikTok, Telegram, Discord
:::1104	divyanshigupta31-osint-username-finder	Username	osint-username-finder	0	Python	https://github.com/divyanshigupta31/osint-username-finder.git	A small python based tool to detect username presence across multiple platforms that utilises HTTP request han
:::1105	prateek0379-osint-username-finder	Username	osint-username-finder	0	-	https://github.com/Prateek0379/osint-username-finder.git	OSINT tool to find usernames across 300+ platforms + full Instagram bypass investigation
:::1106	osint_username_finder	Username	osint_username_finder	0	Python	https://github.com/zamin-codes/osint_username_finder.git	This Project is used to discover the live account of username provided by the user or similiar username presen
:::1107	python-osint-username-finder	Username	Python-OSINT-Username-Finder	0	Python	https://github.com/GodwinJoeDionisus/Python-OSINT-Username-Finder.git	Python-based OSINT tool that searches multiple websites to find where a username exists across social media pl
:::1108	sherhole	Username	Sherhole	0	Python	https://github.com/justarandomNN1337/Sherhole.git	Sherlock + Holehe OSINT wrapper for organized username and email reconnaissance
:::1109	footprint-lab	Username	footprint-lab	0	Python	https://github.com/jkasaudhan/footprint-lab.git	Check your own username and email exposure. Built using Maigret, Holehe, theHarvester , Have I Been Pwned
:::1110	osint-suite	Username	OSINT-Suite	0	HTML	https://github.com/YonasTewabe/OSINT-Suite.git	Web UI for email username OSINT powered by Holehe and User Scanner. Built with Flask, deployable via Docker
:::1111	osintsweep	Username	OSINTsweep	0	Python	https://github.com/Spoofkapoof/OSINTsweep.git	OSINTsweep async OSINT recon across 130+ sources. Email registration discovery holehe-style, username enumer
:::1112	danielhertz1999-bit-osintgram2	Username	Osintgram2	0	-	https://github.com/danielhertz1999-bit/Osintgram2.git	Osintgram is a OSINT tool on Instagram. It offers an interactive shell to perform analysis on Instagram accoun
:::1113	basseybernard321-code-osintgram	Username	Osintgram	0	Python	https://github.com/basseybernard321-code/Osintgram.git	Osintgram is a OSINT tool on Instagram. It offers an interactive shell to perform analysis on Instagram accoun
:::1114	python-osint-blackbird	Username	Python.Osint.Blackbird	0	Python	https://github.com/venantvr-security/Python.Osint.Blackbird.git	Recherche de noms d'utilisateur sur 500+ plateformes Blackbird, requtes async aiohttp
:::1115	blackbird-auto	Username	Blackbird-auto	0	Shell	https://github.com/Okroshbob/Blackbird-auto.git	A small bash script that makes running the Blackbird OSINT utility easier. Instead of navigating through direc
:::1116	bettercap	Network	bettercap	20008	Go	https://github.com/bettercap/bettercap.git	The Swiss Army knife for 802.11, BLE, HID, CAN-bus, IPv4 and IPv6 networks reconnaissance and MITM attacks
:::1117	brook	Network	brook	15183	Go	https://github.com/txthinking/brook.git	A cross-platform programmable network tool
:::1118	nmap	Network	nmap	13642	C	https://github.com/nmap/nmap.git	Nmap - the Network Mapper. Github mirror of official SVN repository
:::1119	mastg	Network	mastg	13190	Python	https://github.com/OWASP/mastg.git	The OWASP Mobile Application Security Testing Guide MASTG is a comprehensive manual for mobile app security 
:::1120	scapy	Network	scapy	12559	Python	https://github.com/secdev/scapy.git	Scapy: the Python-based interactive packet manipulation program library
:::1121	kubeshark	Network	kubeshark	12083	Go	https://github.com/kubeshark/kubeshark.git	eBPF-powered network observability for Kubernetes. Indexes L4/L7 traffic with full K8s context, decrypts TLS w
:::1122	pattern	Network	pattern	8861	Python	https://github.com/clips/pattern.git	Web mining module for Python, with tools for scraping, natural language processing, machine learning, network 
:::1123	zmap	Network	zmap	6382	C	https://github.com/zmap/zmap.git	ZMap is a fast single packet network scanner designed for Internet-wide network surveys
:::1124	scan4all	Network	scan4all	6177	Go	https://github.com/GhostTroops/scan4all.git	Official repository vuls Scan: 15000+PoCs; 23 kinds of application password crack; 7000+Web fingerprints; 146 
:::1125	scanopy	Network	scanopy	5775	Rust	https://github.com/scanopy/scanopy.git	Network diagrams that update themselves
:::1126	pcapdroid	Network	PCAPdroid	4782	Java	https://github.com/emanuele-f/PCAPdroid.git	No-root network monitor, firewall and PCAP dumper for Android
:::1127	opentrace	Network	opentrace	4445	C#	https://github.com/Archeb/opentrace.git	Open Source Visualized Route Tracing Tool for macOS, Windows, and Linux
:::1128	anakin	Network	anakin	4404	Go	https://github.com/Anakin-Inc/anakin.git	Open-source web scraping API. Turn any website into clean markdown or structured JSON. Anti-detect browser, pr
:::1129	discover	Network	discover	3939	Shell	https://github.com/leebaird/discover.git	Custom Bash and Python scripts used to automate various penetration testing tasks including recon, scanning, e
:::1130	anything-analyzer	Network	anything-analyzer	3676	TypeScript	https://github.com/Mouseww/anything-analyzer.git	+ MITM + + AI + MCP Server AI Agent/IDE All-in-one protocol analysis toolkit built-in browser capture, MITM pr
:::1131	bruteshark	Network	BruteShark	3397	C#	https://github.com/odedshimon/BruteShark.git	Network Analysis Tool
:::1132	smap	Network	Smap	3300	Go	https://github.com/s0md3v/Smap.git	a drop-in replacement for Nmap powered by shodan.io
:::1133	easy_hack	Network	EasY_HaCk	2483	Python	https://github.com/sabri-zaki/EasY_HaCk.git	Hack the World using Termux
:::1134	ja4	Network	ja4	2094	Rust	https://github.com/FoxIO-LLC/ja4.git	JA4+ is a suite of network fingerprinting standards
:::1135	jshookmcp	Network	jshookmcp	2008	TypeScript	https://github.com/vmoranv/jshookmcp.git	js hook toolkit that all you need
:::1136	sandmap	Network	sandmap	1865	Shell	https://github.com/trimstray/sandmap.git	Nmap on steroids. Simple CLI with the ability to run pure Nmap engine, 31 modules with 459 scan profiles
:::1137	netscanner	Network	netscanner	1855	Rust	https://github.com/Chleba/netscanner.git	Terminal Network scanner diagnostic tool with modern TUI
:::1138	tcpflow	Network	tcpflow	1777	C++	https://github.com/simsong/tcpflow.git	TCP/IP packet demultiplexer. Download from:
:::1139	sx	Network	sx	1555	Go	https://github.com/v-byte-cpu/sx.git	:vulcan_salute: Fast, modern, easy-to-use network scanner
:::1140	pgrouting	Network	pgrouting	1435	C++	https://github.com/pgRouting/pgrouting.git	Repository contains pgRouting library. Development branch is develop , stable branch is master
:::1141	bmon	Network	bmon	1390	C	https://github.com/Jafaral/bmon.git	bandwidth monitor and rate estimator
:::1142	dracnmap	Network	Dracnmap	1385	Shell	https://github.com/screetsec/Dracnmap.git	Dracnmap is an open source program which is using to exploit the network and gathering information with nmap h
:::1143	ptcpdump	Network	ptcpdump	1277	C	https://github.com/mozillazg/ptcpdump.git	Process-aware, eBPF-based tcpdump
:::1144	nfstream	Network	nfstream	1223	Python	https://github.com/nfstream/nfstream.git	NFStream: a Flexible Network Data Analysis Framework
:::1145	open-source-security-guide	Network	Open-Source-Security-Guide	1108	Go	https://github.com/mikeroyal/Open-Source-Security-Guide.git	Open Source Security Guide. Learn all about Security Standards FIPS, CIS, FedRAMP, FISMA, etc., Frameworks, 
:::1146	autopwn-suite	Network	AutoPWN-Suite	1100	Python	https://github.com/GamehunterKaan/AutoPWN-Suite.git	AutoPWN Suite is a project for scanning vulnerabilities and exploiting systems automatically
:::1147	ullaakut-nmap	Network	nmap	1052	Go	https://github.com/Ullaakut/nmap.git	Idiomatic nmap library for go developers
:::1148	opendoor	Network	OpenDoor	1007	Python	https://github.com/stanislav-web/OpenDoor.git	OWASP Web Recon Directory Discovery Platform
:::1149	picosnitch	Network	picosnitch	1000	C	https://github.com/elesiuta/picosnitch.git	Monitor network traffic per executable
:::1150	habu	Network	habu	986	Python	https://github.com/fportantier/habu.git	Hacking Toolkit
:::1151	cidranger	Network	cidranger	970	Go	https://github.com/yl2chen/cidranger.git	Fast IP to CIDR lookup in Golang
:::1152	netgraph	Network	netgraph	956	Go	https://github.com/ga0/netgraph.git	A cross platform http sniffer with a web UI
:::1153	l0p4map	Network	L0p4Map	916	Python	https://github.com/HaxL0p4/L0p4Map.git	Professional network monitoring visualization tool. L0P4Map combines high-speed ARP discovery with full nmap i
:::1154	suzieq	Network	suzieq	904	Python	https://github.com/netenglabs/suzieq.git	Using network observability to operate and design healthier networks
:::1155	stratospherelinuxips	Network	StratosphereLinuxIPS	890	Python	https://github.com/stratosphereips/StratosphereLinuxIPS.git	Slips, a free software behavioral Python intrusion prevention system IDS/IPS that uses machine learning to d
:::1156	nmap-formatter	Network	nmap-formatter	738	Go	https://github.com/vdjagilev/nmap-formatter.git	A tool that allows you to convert NMAP results to html, csv, json, markdown, graphviz dot, sqlite, excel and
:::1157	frontendwingman	Network	FrontendWingman	669	-	https://github.com/dendoink/FrontendWingman.git	Frontend Wingman, Learn frontend faster
:::1158	natlas	Network	natlas	661	Python	https://github.com/natlas/natlas.git	Attack Surface Management since before Attack Surface Management was a thing
:::1159	caronte	Network	caronte	651	JavaScript	https://github.com/eciavatta/caronte.git	A tool to analyze the network flow during attack/defence Capture the Flag competitions
:::1160	wiremcp	Network	WireMCP	585	JavaScript	https://github.com/0xKoda/WireMCP.git	An MCP for WireShark tshark. Empower LLM's with realtime network traffic analysis capability
:::1161	hellraiser	Network	HellRaiser	584	Ruby	https://github.com/m0nad/HellRaiser.git	Vulnerability scanner using Nmap for scanning and correlating found CPEs with CVEs
:::1162	obsidiantools	Network	obsidiantools	572	Python	https://github.com/mfarragher/obsidiantools.git	Obsidian tools - a Python package for analysing an Obsidian.md vault
:::1163	packetnet	Network	packetnet	558	C#	https://github.com/dotpcap/packetnet.git	Official repository - High performance .NET package for dissecting and constructing network packets such as Et
:::1164	jekyll	Network	jekyll	550	HTML	https://github.com/programminghistorian/jekyll.git	Jekyll-based static site for The Programming Historian
:::1165	fritap	Network	friTap	543	Python	https://github.com/fkie-cad/friTap.git	Simplifying encrypted traffic analysis for researchers by making protocol decryption effortless
:::1166	qnsm	Network	qnsm	531	C	https://github.com/iqiyi/qnsm.git	QNSM is network security monitoring framework based on DPDK
:::1167	nmapgui	Network	NMapGUI	505	Java	https://github.com/daniel-cues/NMapGUI.git	Advanced Graphical User Interface for NMap
:::1168	tulip	Network	tulip	489	Python	https://github.com/OpenAttackDefenseTools/tulip.git	Network analysis tool for Attack Defence CTF
:::1169	network-management-client	Network	network-management-client	481	TypeScript	https://github.com/meshtastic/network-management-client.git	A Meshtastic desktop client, allowing simple, offline deployment and administration of an ad-hoc mesh communic
:::1170	pig	Network	pig	478	C	https://github.com/rafael-santiago/pig.git	A Linux packet crafting tool
:::1171	iot-inspector-client	Network	iot-inspector-client	476	Python	https://github.com/nyu-mlab/iot-inspector-client.git	IoT Inspector: capturing and analyzing your smart home network traffic
:::1172	flare	Network	flare	458	Python	https://github.com/austin-taylor/flare.git	An analytical framework for network traffic and behavioral analytics
:::1173	badkarma	Network	badKarma	436	Python	https://github.com/r3vn/badKarma.git	network reconnaissance toolkit
:::1174	poseidon	Network	poseidon	433	Python	https://github.com/faucetsdn/poseidon.git	Poseidon is a python-based application that leverages software defined networks SDN to acquire and then feed
:::1175	cdlib	Network	cdlib	429	Python	https://github.com/GiulioRossetti/cdlib.git	Community Discovery Library
:::1176	nload	Network	nload	420	C++	https://github.com/rolandriegel/nload.git	Real-time network traffic monitor
:::1177	threader3000	Network	threader3000	397	Python	https://github.com/dievus/threader3000.git	Multi-threaded Python Port Scanner with Nmap Integration
:::1178	lightweight-segmentation	Network	Lightweight-Segmentation	369	Python	https://github.com/Tramac/Lightweight-Segmentation.git	Lightweight models for real-time semantic segmentationinclude mobilenetv1-v3, shufflenetv1-v2, igcv3, efficie
:::1179	gephi-lite	Network	gephi-lite	352	TypeScript	https://github.com/gephi/gephi-lite.git	A web-based, lighter version of Gephi
:::1180	noxim	Network	noxim	336	C++	https://github.com/davidepatti/noxim.git	Network on Chip Simulator
:::1181	packemon	Network	packemon	307	Go	https://github.com/ddddddO/packemon.git	Packet monster -=  '-' TUI tool for sending packets of arbitrary input and monitoring packets on any netwo
:::1182	textnets	Network	textnets	293	Python	https://github.com/jboynyc/textnets.git	Text analysis with networks
:::1183	ctstraffic	Network	ctsTraffic	289	C++	https://github.com/microsoft/ctsTraffic.git	ctsTraffic is a highly scalable client/server networking tool giving detailed performance and reliability anal
:::1184	ayaflow	Network	ayaFlow	286	Rust	https://github.com/DavidHavoc/ayaFlow.git	A high-performance, eBPF-based network traffic analyzer written in Rust
:::1185	nfsen-ng	Network	nfsen-ng	282	PHP	https://github.com/mbolli/nfsen-ng.git	Responsive NetFlow visualizer built on top of nfdump tools
:::1186	bwm-ng	Network	bwm-ng	275	C	https://github.com/vgropp/bwm-ng.git	Bandwidth Monitor NG is a small and simple console-based live network and disk io bandwidth monitor for Linux,
:::1187	kali-linux	Network	Kali-Linux	263	-	https://github.com/aw-junaid/Kali-Linux.git	A guide to using Kali Linux tools for web penetration testing, ethical hacking, forensics, and bug bounty. Cov
:::1188	pycurity	Network	pycurity	239	Python	https://github.com/ninijay/pycurity.git	Python Security Scripts
:::1189	udpx	Network	udpx	237	Go	https://github.com/nullt3r/udpx.git	Fast and lightweight, UDPX is a single-packet UDP scanner written in Go that supports the discovery of over 45
:::1190	autoenum	Network	autoenum	231	Shell	https://github.com/Gr1mmie/autoenum.git	Automatic Service Enumeration Script
:::1191	network_scanner	Network	network_scanner	211	Python	https://github.com/parvez/network_scanner.git	This Home Assistant integration provides a network scanner that identifies all devices on your local network. 
:::1192	grawler	Network	Grawler	210	PHP	https://github.com/A3h1nt/Grawler.git	Grawler is a tool written in PHP which comes with a web interface that automates the task of using google dork
:::1193	netbox-scanner	Network	netbox-scanner	207	Python	https://github.com/lopes/netbox-scanner.git	A scanner util for NetBox
:::1194	costco-scraper	Network	costco-scraper	206	-	https://github.com/ScrapingBee/costco-scraper.git	Costco Scraper API for extracting product data, pricing, and category listings from Costco.com using a scalabl
:::1195	reconky-automated_bash_script	Network	Reconky-Automated_Bash_Script	204	Shell	https://github.com/ShivamRai2003/Reconky-Automated_Bash_Script.git	Reconky is an great Content Discovery bash script for bug bounty hunters which automate lot of task and organi
:::1196	nibble	Network	nibble	193	Go	https://github.com/backendsystems/nibble.git	easy to use network scanner, with a clickable tui interface
:::1197	minino	Network	Minino	176	C++	https://github.com/ElectronicCats/Minino.git	Minino is an original multiprotocol and multiband board made for sniffing, communicating, and attacking IoT de
:::1198	pbscan	Network	pbscan	171	C	https://github.com/gvb84/pbscan.git	Faster and more efficient stateless SYN scanner and banner grabber due to userland TCP/IP stack usage
:::1199	domainrecon	Network	DomainRecon	158	Python	https://github.com/devsecboy/DomainRecon.git	Based on URL and Organization Name, collect the IP Ranges, subdomains using various tools like Amass, subfinde
:::1200	msploitego	Network	msploitego	148	Python	https://github.com/shizzz477/msploitego.git	Pentesting suite for Maltego based on data in a Metasploit database
:::1201	astsu	Network	astsu	141	Python	https://github.com/ReddyyZ/astsu.git	A network scanner tool, developed in Python 3 using scapy
:::1202	pimeyes-scraper	Network	Pimeyes-scraper	130	Python	https://github.com/Nix4444/Pimeyes-scraper.git	Automated Selenium-based scraper for PimEyes, enabling reverse face search for Open-Source Intelligence OSINT
:::1203	scanme	Network	scanme	118	Go	https://github.com/CyberRoute/scanme.git	A Golang package for scanning private and public IPs for open TCP ports
:::1204	networksherlock	Network	NetworkSherlock	115	Python	https://github.com/HalilDeniz/NetworkSherlock.git	NetworkSherlock: powerful and flexible port scanning tool With Shodan
:::1205	python3-nmapscanner	Network	Python3-NmapScanner	113	Python	https://github.com/AlexisAhmed/Python3-NmapScanner.git	Python3 Nmap Scanner
:::1206	cosyredactgateway	Network	CosyRedactGateway	91	JavaScript	https://github.com/CassiopeiaCode/CosyRedactGateway.git	Lightweight, stateless privacy gateway for LLM APIs redact secrets before OpenAI/Anthropic upstreams and resto
:::1207	packet-tracer-network-project	Network	packet-tracer-network-project	67	-	https://github.com/div6079-code/packet-tracer-network-project.git	Basic network configuration using Cisco Packet Tracer including router and switch setup, IP addressing, and co
:::1208	cisco-packet-tracer-networking-projects	Network	Cisco-Packet-Tracer-Networking-Projects	62	-	https://github.com/bala2007-05/Cisco-Packet-Tracer-Networking-Projects.git	A Cisco Packet Tracer project demonstrating the design and configuration of a large-scale network with routers
:::1209	network-project-packet-tracer	Network	Network-project-packet-tracer	51	-	https://github.com/gayathripc2006-cpu/Network-project-packet-tracer-.git	Simulation of a basic network in Cisco Packet Tracer with router and switch configuration, IP addressing, and 
:::1210	wpaudit	Network	wpaudit	41	Python	https://github.com/ihuzaifashoukat/wpaudit.git	WPAUDIT: Advanced WordPress security auditing suite vulnerability scanner. Automates pentesting with Nmap, WPS
:::1211	cyber-octopus	Network	Cyber-Octopus	31	Python	https://github.com/Bharadwaja1557/Cyber-Octopus.git	Toolkit of Python scripts for web security, network recon, login brute-forcing, and ARP spoofing experiments. 
:::1212	pynmap	Network	pynmap	28	Python	https://github.com/the-c0d3r/pynmap.git	A serious attempt to implement multi-threading to nmap module, which would result in faster scanning speed. I 
:::1213	egoalpha	Network	EGOAlpha	27	Python	https://github.com/PolitoInc/EGOAlpha.git	EGO is a vulnerability scanner developed by chickenpwny at PolitoInc. It was created to provide a platform for
:::1214	depthsearch	Network	DepthSearch	25	Python	https://github.com/AnonCatalyst/DepthSearch.git	DepthSearch is a deep web OSINT tool that enables powerful, anonymous searches across deep web search engines.
:::1215	scans2any	Network	scans2any	25	Python	https://github.com/softScheck/scans2any.git	Convert infrastructure scans into various output formats such as Markdown tables, YAML, HTML, CSV, and more. C
:::1216	network-scanner	Network	Network-Scanner	21	Python	https://github.com/frangelbarrera/Network-Scanner.git	AI-assisted network reconnaissance and security assessment toolkit nmap + Python + Flask + React. CLI, Web UI,
:::1217	nmap-scanner-django	Network	nmap-scanner-django	18	Python	https://github.com/Neo1277/nmap-scanner-django.git	This Django application uses nmap3 python library to scan the network with the option -A and -sV, this web app
:::1218	nmappalyzer	Network	nmappalyzer	18	Python	https://github.com/blacklanternsecurity/nmappalyzer.git	A lightweight Python 3 Nmap wrapper that doesn't try too hard. Gracefully handles any Nmap command, providing 
:::1219	cyber-guard	Network	Cyber-Guard	17	Python	https://github.com/Akazayh/Cyber-Guard.git	Security Toolkit,Network Security,Network Scanner,Nmap, IDS, Firewall,IPS,python
:::1220	hacksha	Network	Hacksha	17	Python	https://github.com/hackyshadab/Hacksha.git	Tools for Pentesting that all hacker need
:::1221	penum	Network	penum	16	Python	https://github.com/drtychai/penum.git	Parallelized enumeration tool for red team engagements and bug bounty programs
:::1222	agilegrabber	Network	AgileGrabber	15	Python	https://github.com/sudo0x18/AgileGrabber.git	AgileGrabber is a multi cored and multi threaded port scanner made with python and nmap to make scanning faste
:::1223	honey-hornet	Network	honey-hornet	15	Python	https://github.com/ajackal/honey-hornet.git	port scanner login credential tester
:::1224	jimbo-v2ray	Network	jimbo-v2ray	15	Python	https://github.com/mahdizynali/jimbo-v2ray.git	Scrapping fresh V2ray configs through the web and testing to find alive configs on your network
:::1225	web-enumeration-script	Network	Web-Enumeration-Script	15	Shell	https://github.com/quitehacker/Web-Enumeration-Script.git	This Script contains tools like assetfinder, amass, httprobe, subjack, nmap, waybackurls and gowitness
:::1226	vulnscanner-simple	Network	vulnscanner-simple	14	Python	https://github.com/Leetcore/vulnscanner-simple.git	Automatisierung von Amass + Nmap + Nikto
:::1227	nmap_dnsrecon_result	Network	nmap_dnsrecon_result	13	Python	https://github.com/ngalongc/nmap_dnsrecon_result.git	A wrap up script to auto perform nmap scan from the result of dnsrecon, then output result with filename as ho
:::1228	nmap-commands-every-ethical-hacker-must-	Network	Nmap-Commands-Every-Ethical-Hacker-Must-	12	-	https://github.com/AdityaBhatt3010/Nmap-Commands-Every-Ethical-Hacker-Must-Master.git	An energetic deep dive into Nmap unleashing its modular power, scan profiles, and automation tricks to superch
:::1229	fstscan	Network	fstscan	12	Python	https://github.com/thenurhabib/fstscan.git	Massive Vulnerability scanner
:::1230	vulnerability-scanner	Network	Vulnerability-Scanner	12	Python	https://github.com/Ganatra-Ruchir/Vulnerability-Scanner.git	A beginner-friendly Python tool by Ranchiro for scanning vulnerabilities and gathering system information usin
:::1231	scan-shark	Network	Scan-Shark	11	Python	https://github.com/Shivangx01b/Scan-Shark.git	A Simple Network scanner which uses nmap and it's version scanning capability to get the version name and sear
:::1232	nmap-scan	Network	nmap-scan	10	Python	https://github.com/f-froehlich/nmap-scan.git	Nmap wrapper for python with full Nmap DTD support, parallel scans and threaded callback methods support for f
:::1233	shifter-tool	Network	Shifter-tool	10	Python	https://github.com/SabriAmir/Shifter-tool.git	Educational toolkit with 14 security-related utilities system info, hash tools, FTP cracker, SQLMap launcher,
:::1234	ascan	Network	Ascan	9	Python	https://github.com/nallamuthu/Ascan.git	Python script to perform nmap, header, ssl, cipher, certificate scan
:::1235	vulnhawk	Network	VulnHawk	9	Python	https://github.com/tanujkumar2405/VulnHawk.git	A modular and beginner-friendly Python vulnerability scanner with port scanning, real-time CVE detection, CVSS
:::1236	scanner	Network	scanner	8	Python	https://github.com/shakarr/scanner.git	Scan tool with python + nmap
:::1237	nmap-python-scanner	Network	nmap-python-scanner	8	Python	https://github.com/himadriganguly/nmap-python-scanner.git	Demo Application To Use Nmap Scanner In Python
:::1238	r3conautomator	Network	r3conAutomator	8	Shell	https://github.com/KoelhoSec/r3conAutomator.git	Script to Automate your Recon running with Assetfinder Amass Subjack Nmap EyeWitness
:::1239	network-scanner-flask	Network	Network-Scanner-Flask	7	Python	https://github.com/DeepKariaX/Network-Scanner-Flask.git	A Web Based Network Port Scanner built with python flask and a manual is provided to use this tool
:::1240	psst_hb_final_project	Network	psst_hb_final_project	7	JavaScript	https://github.com/blythest/psst_hb_final_project.git	A port scanner and visualization web app. Written in Python, Flask, D3.js, and the NMAP library
:::1241	scan-x	Network	SCAN-X	7	Python	https://github.com/Anonymous40443/SCAN-X.git	SCAN-X v3.0 The Ultimate Blood-Tiger Recon Engine. Automate 15+ Nmap scans, bypass firewalls find CVEs. Featur
:::1242	nmapscan	Network	nmapscan	6	Python	https://github.com/norksec/nmapscan.git	Simple python nmap scanner
:::1243	porthunt	Network	PortHunt	6	Python	https://github.com/ctxzero/PortHunt.git	High-speed port service scanner with CVE enrichment and exportable reports
:::1244	kharon	Network	Kharon	6	Python	https://github.com/dawnl3ss/Kharon.git	Kharon is an automated web-server ctf scanner which perform basic tasks of webserver pentesting. Written in Py
:::1245	comprehensive-network-design-and-configu	Network	Comprehensive-Network-Design-and-Configu	5	-	https://github.com/abdar7eem/Comprehensive-Network-Design-and-Configuration-using-Cisco-Packet-Tracer.git	This project involves designing a network using Cisco Packet Tracer. Students perform IP subnetting, configure
:::1246	campuslink	Network	CampusLink	5	-	https://github.com/Basitx72/CampusLink.git	Network infrastructure project designed using Packet Tracer for testing and simulation, providing secure and r
:::1247	nmap-port-scanner	Network	Nmap-Port-Scanner	5	Python	https://github.com/0MeMo07/Nmap-Port-Scanner.git	a port scanner using nmap with python
:::1248	port-scanner	Network	Port-Scanner	5	Python	https://github.com/aroh3006/Port-Scanner.git	GUI-based port scanning tool built using Python, Tkinter, and Nmap for network reconnaissance and security tes
:::1249	autorecon-ai	Network	autorecon-ai	5	Python	https://github.com/ANKIT48274/autorecon-ai.git	AI-Powered Reconnaissance Analysis Engine Multi-threaded scanner with Claude/OpenAI/Grok integration for autom
:::1250	aegisscan-opencore	Network	AegisScan-OpenCore	5	Python	https://github.com/Imposter-zx/AegisScan-OpenCore.git	Mission-Aware Adversarial Simulation Framework for Defensive Security Research
:::1251	oceanscrape	Network	oceanscrape	5	-	https://github.com/ShippingTrading1/oceanscrape.git	Scraper for marine traffic data - amass AIS data fast for free without being detected; ready for AI pipeline i
:::1252	cybersift	Network	CyberSift	5	Python	https://github.com/Cyber-XS/CyberSift.git	CyberSift is a all in one Tool for Information Gathering which use many tool like nmap, subfinder, amass, dirb
:::1253	firewall-acl-configuration-on-router-pac	Network	Firewall-ACL-Configuration-on-Router-Pac	4	-	https://github.com/Cyberguy786/Firewall-ACL-Configuration-on-Router-Packet-Tracer-.git	This project demonstrates how to configure Access Control Lists ACLs on a router in Cisco Packet Tracer to c
:::1254	nmap-scanner-python	Network	Nmap-scanner-python	4	Python	https://github.com/tanod-cyber/Nmap-scanner-python.git	This is beginner friendly code with python
:::1255	martinyung-port-scanner	Network	port-scanner	4	JavaScript	https://github.com/martinyung/port-scanner.git	nmap scanner on python flask
:::1256	aryansecops-nmap-port-scanner	Network	nmap-port-scanner	4	Python	https://github.com/AryanSecOps/nmap-port-scanner.git	Beginner-friendly interactive Python wrapper for authorized Nmap port and service scans
:::1257	mcmap	Network	mcmap	4	Python	https://github.com/n0nexist/mcmap.git	nmap minecraft scanner written in python
:::1258	pnutmap	Network	pnutmap	4	Python	https://github.com/realpnut/pnutmap.git	python wrapper for nmap
:::1259	djangonetscanner	Network	DjangoNetScanner	4	Python	https://github.com/Muhammad-Azmeer-Ahmad/DjangoNetScanner.git	Web-based network scanner built with Django and Nmap. Enter a target IP or hostname to detect open ports and r
:::1260	advancednetscanner-with-autoexploitcheck	Network	AdvancedNetScanner-With-AutoExploitCheck	4	Python	https://github.com/muhammetalgan/AdvancedNetScanner-With-AutoExploitCheck-CVE-ExploitDB.git	This repository contains a Python script that performs advanced network scanning, vulnerability detection, and
:::1261	recon_nmap-py	Network	recon_nmap.py	4	Python	https://github.com/guigavicentin/recon_nmap.py.git	Reconhecimento com Amass + Nmap com algumas opes
:::1262	theschaefer-oceanscrape	Network	OceanScrape	4	Python	https://github.com/theSchaefer/OceanScrape.git	Scraper for marine traffic data - amass AIS data fast for free without being detected; ready for AI pipeline i
:::1263	approach	Network	approach	4	Shell	https://github.com/prakhar0x01/approach.git	This repository provides a beginner-friendly approach for testing subdomains with a focus on automation. It in
:::1264	pentest-osint-mcp-server	Network	pentest-osint-mcp-server	3	Python	https://github.com/Hackerobi/pentest-osint-mcp-server.git	A comprehensive MCP server integrating 25+ OSINT tools for penetration testing. Connects Claude Desktop to She
:::1265	voip_cisco_packet_tracer	Network	VoIP_Cisco_Packet_Tracer	3	-	https://github.com/PavitraGautam17/VoIP_Cisco_Packet_Tracer.git	It is a demonstration of VOIP in a small company which made on Cisco Packet Tracer for understanding the telep
:::1266	ciscopackettracer	Network	CiscoPacketTracer	3	-	https://github.com/akkamismeryem/CiscoPacketTracer.git	Network simulation labs built with Cisco Packet Tracer covering static IP, DHCP, VLAN, routing protocols, and 
:::1267	basic-office-network	Network	basic-office-network	3	-	https://github.com/ShradhaSwain/basic-office-network.git	Designed a basic office network using Cisco Packet Tracer, implementing IP addressing, device configuration, a
:::1268	enterprise-campus-network	Network	Enterprise-Campus-Network	3	-	https://github.com/MUdevelops/Enterprise-Campus-Network.git	Cisco Packet Tracer simulation, architectural design, and IP addressing schema for an Enterprise Campus Networ
:::1269	mayurkadampro-nmap-port-scanner	Network	NMAP-Port-Scanner	3	Python	https://github.com/mayurkadampro/NMAP-Port-Scanner.git	NMAP-Port Scanner Python Script
:::1270	python-automated-nmap-scanner	Network	Python-Automated-Nmap-Scanner	3	Python	https://github.com/yassinSahli/Python-Automated-Nmap-Scanner-.git	This Nmap Scanner is a network discovery tool that uses raw IP packets in novel ways to determine what hosts a
:::1271	nmap_port_scanner	Network	NMAP_Port_Scanner	3	Python	https://github.com/WhatTheMahad/NMAP_Port_Scanner.git	A basic level NMAP port scanner having TCP SYN-ACKand UDP connections scans
:::1272	servers-scanner	Network	servers-scanner	3	Python	https://github.com/suiramdev/servers-scanner.git	A script that searches for open servers e.g. Minecraft around the world
:::1273	devmytho-port-scanner	Network	port-scanner	3	Python	https://github.com/DevMytho/port-scanner.git	Port Scanner created using python, tkinter and nmap
:::1274	mightyscanner	Network	MightyScanner	3	Python	https://github.com/amfinethankyou/MightyScanner.git	MightyScanner is a powerful network and vulnerability scanner designed to help users identify and mitigate sec
:::1275	poccrster	Network	POCCRSTER	3	Python	https://github.com/Hotmansifu/POCCRSTER.git	Simple Port-Scanning tool
:::1276	kagescan	Network	KageScan	3	Python	https://github.com/0xnotkyo/KageScan.git	A fast network scanner
:::1277	net_scan	Network	net_scan	3	Python	https://github.com/lordofsraam/net_scan.git	Network scanner and monitor with curses display option. Written in Python and uses nmap
:::1278	iot-vuln-scanner	Network	iot-vuln-scanner	3	PHP	https://github.com/izzuddinafif/iot-vuln-scanner.git	IoT Vulnerability Scanner that uses Laravel as the web frontend, Go for the backend HTTP server to handle scan
:::1279	v-finder	Network	v-finder	3	Python	https://github.com/solitary8/v-finder.git	This is a vulnerability scanner mainly coded in python using nmap with an interactive GUI,this scanner is for 
:::1280	porty	Network	Porty	3	Python	https://github.com/MrM3ARS/Porty.git	Bu uygulama aslnda bir Ak Port Tarama ve Altnda alan Servisleri tespit etmeye yarayan bir yazlmdr
:::1281	network_scanner_tool_1-0-6	Network	Network_Scanner_Tool_1.0.6	3	Python	https://github.com/cobraa9/Network_Scanner_Tool_1.0.6.git	A Python-based tool for port scanning, network scanning, stealth scanning, detecting open ports, services, and
:::1282	wraith-scanner	Network	Wraith-Scanner	3	Python	https://github.com/Destawell/Wraith-Scanner.git	A surgical network scanner that actually works on Android without the annoying ERROR drama
:::1283	mappy	Network	mappy	3	Python	https://github.com/fawkes-picks/mappy.git	A Python tool used to scan a network, leveraging Nmap. There is also a Nikto vulnerability scanner, recently a
:::1284	pradip676-vulnx	Network	VulnX	3	Python	https://github.com/pradip676/VulnX.git	VulnX is a lightweight Python-based vulnerability scanner using Nmap and Vulners API. It detects open ports, f
:::1285	jok3r	Network	Jok3r	3	Python	https://github.com/heshamm1/Jok3r.git	Jok3r by Hesham Sh1vv is a Python script for network reconnaissance and port scanning. It streamlines host d
:::1286	sentinelforge	Network	SentinelForge	3	Python	https://github.com/Sa1tama228/SentinelForge.git	This is local defensive security toolkit with scanner, recon, honeypots, vulnerability correlation, evidence g
:::1287	vulnscan	Network	VULNSCAN	3	Python	https://github.com/MukeshCB5036/VULNSCAN.git	VulnScan is a Python-based vulnerability scanner that scans IPs for open ports within a user-defined range. It
:::1288	cve-2025-66398	Network	cve-2025-66398	3	Go	https://github.com/joshuavanderpoll/cve-2025-66398.git	CVE-2025-66398 Signal K Server 2.18.0 RCE PoC
:::1289	configuring-static-routes	Network	Configuring-Static-Routes	2	-	https://github.com/ro-drick/Configuring-Static-Routes.git	A Cisco Packet Tracer lab demonstrating static route configuration across multiple routers. The lab focuses on
:::1290	network-simulation-doc	Network	network-simulation-doc	2	-	https://github.com/sameerkhuhro/network-simulation-doc.git	Documentation of a Cisco Packet Tracer project connecting two departments with static IP and wireless setup
:::1291	enterprise-network-vlan-routing	Network	enterprise-network-vlan-routing	2	-	https://github.com/odarkpxlo/enterprise-network-vlan-routing.git	Enterprise network configuration lab using Cisco Packet Tracer, including VLANs, trunking, IP addressing, and 
:::1292	configure-a-wireless-router-and-client	Network	Configure-a-Wireless-Router-and-Client	2	-	https://github.com/DamoJayy/Configure-a-Wireless-Router-and-Client-.git	Configured a wireless network in Cisco Packet Tracer and learned the basics of DHCP, IP addressing, router con
:::1293	multi-department-network-design	Network	Multi-Department-Network-Design	2	-	https://github.com/immaryammahmood/Multi-Department-Network-Design.git	Multi-Department-Network-Design networking project demonstrating a professional enterprise network architectur
:::1294	network-design-and-implementation-projec	Network	Network-Design-and-Implementation-Projec	2	-	https://github.com/hariharande/Network-Design-and-Implementation-Project.git	Designed and implemented a virtual enterprise network across six locations using Cisco Packet Tracer. Implemen
:::1295	5-cities-networking-project	Network	5-Cities-Networking-Project	2	-	https://github.com/zahi1/5-Cities-Networking-Project.git	This project presents a detailed network configuration for schools in 5 different cities, designed, modelled a
:::1296	laboratorio-v	Network	Laboratorio-V	2	-	https://github.com/lucascastronuovo/Laboratorio-V.git	El repositorio contiene archivos de Cisco Packet Tracer con ejercicios prcticos de Laboratorio V, abordando di
:::1297	switch-configuration	Network	Switch-Configuration	2	-	https://github.com/jeddy-coco/Switch-Configuration.git	This repo contains beginner-friendly Packet Tracer activities for configuring new Cisco switches. Includes top
:::1298	small-enterprise-network	Network	Small-enterprise-network	2	-	https://github.com/collins-wanjala/Small-enterprise-network.git	This is a Medium enterprise network system designed developed in Cisco Packet tracer. It contains several depa
:::1299	3-star-hotel-network-design	Network	3-star-hotel-network-design	2	-	https://github.com/arpit127/3-star-hotel-network-design.git	A proposed network architecture for an airport demonstrated using cisco packet tracer. An airport which has th
:::1300	python-nmap-scanner	Network	python-nmap-scanner	2	Python	https://github.com/corgima/python-nmap-scanner.git	Learning python - automating nmap with python-nmap
:::1301	nmap-llm	Network	nmap-llm	2	Python	https://github.com/MohnishShende/nmap-llm.git	AI-assisted Nmap scanner using Ollama and Python
:::1302	sankarlmao-vulnerability-scanner	Network	vulnerability-scanner	2	HTML	https://github.com/sankarlmao/vulnerability-scanner.git	Python vulnerability scanner using Nmap and Socket
:::1303	pymacscanner	Network	pymacscanner	2	Python	https://github.com/yunhasnawa/pymacscanner.git	Python MAC address scanner using NMAP
:::1304	836541-port-scanner	Network	port-scanner	2	Python	https://github.com/836541/port-scanner.git	Portscanner Scapy/Socket-Based to simulate NMAP
:::1305	networks-scanner-vulnerability-reporter	Network	networks-scanner-vulnerability-reporter	2	Python	https://github.com/saudnadaf09/networks-scanner-vulnerability-reporter.git	Python-based Network Scanner Vulnerability Reporter using Nmap
:::1306	hostscanner	Network	HostScanner	2	Python	https://github.com/marcelogdeandrade/HostScanner.git	A port scanner on a host using Nmap with Python
:::1307	smooth-port-scanner	Network	smooth-port-scanner	2	Python	https://github.com/vaisx05/smooth-port-scanner.git	Simple Python script for performing port scanning on an IPv4 address using python-nmap
:::1308	network-vulnerability-scanner	Network	Network-Vulnerability-Scanner	2	HTML	https://github.com/ItsPiyushVishwakarma/Network-Vulnerability-Scanner.git	Professional network vulnerability scanner using Nmap and Python with CVE lookup
:::1309	automaticnmap	Network	AutomaticNMAP	2	Python	https://github.com/Business1sg00d/AutomaticNMAP.git	Working on a bash and python script that runs nmap, stores open ports in memory, then runs subsequent scans in
:::1310	realtime-network-vulnerability-scanner	Network	realtime-network-vulnerability-scanner	2	Python	https://github.com/0xShyam-Sec/realtime-network-vulnerability-scanner.git	Real-time network vulnerability scanner built with Python and Nmap on Kali Linux
:::1311	doorbreaker-portscanner	Network	DoorBreaker-PortScanner	2	Python	https://github.com/joaocarnevalli/DoorBreaker-PortScanner.git	Checkpoint 5 of coding for security - PortScanner - DoorBreaker
:::1312	webpentest	Network	WebPentest	1	Shell	https://github.com/AswinMathew2004/WebPentest.git	Automated web penetration testing tool for Kali Linuix,Nmap port scan, SSL audit, Gobuster dir brute-force, Ni
:::1313	boniyeamincse-osint-tools	Network	OSINT-Tools	1	-	https://github.com/boniyeamincse/OSINT-Tools.git	Sadman Tajwar Sadman Tajwar1st BTech IT Engineering - Cybersecurity and Artificial Intelligence. 1h Top 10 sou
:::1314	webguardian	Network	webguardian	1	Python	https://github.com/HumerousFi/webguardian.git	CLI recon/vuln-scan orchestrator wrapping nmap, nikto, theHarvester, dnsrecon, wafw00f and more behind one int
:::1315	revathig04-recon	Network	Recon	1	Shell	https://github.com/revathig04/Recon.git	Bash automation scripts for reconnaissance and vulnerability assessment
:::1316	om	Network	Om	1	Shell	https://github.com/adiz777/Om.git	Om is a minimalist reconnaissance script for Kali Linux that automates information gathering using tools like 
:::1317	ghunt-masscan	Network	GHUNT-Masscan	0	Python	https://github.com/krl5/GHUNT-Masscan.git	GHUNT-Masscan batch GHunt wrapper for running OSINT across multiple Google accounts and inferring their locati
:::1318	submap_tool	Network	SubMap_Tool	0	Python	https://github.com/Srodzz/SubMap_Tool.git	Tool that blend sublist3r with nmap and automatically scans subdomains
:::1319	url-and-ip-scanner	Network	URL-and-IP-Scanner	0	Shell	https://github.com/sourabh24396/URL-and-IP-Scanner.git	bash script to automate nmap, dirbuster and dnsrecon
:::1320	domain_scanner_project	Network	domain_scanner_project	0	-	https://github.com/wodeh/domain_scanner_project.git	scanning domains using nmap, sublister, dnsrecon, dnsenum and several tools
:::1321	screcon	Network	screcon	0	Python	https://github.com/sanjaybx1/screcon.git	Unified Reconnaissance Framework Nmap, WPScan, Sublist3r, Recon-ng, DNSenum, DNSrecon, theHarvester
:::1322	webvulnebilityscanner	Network	webvulnebilityscanner	0	Python	https://github.com/PranshuCyb3r/webvulnebilityscanner.git	Python-based Web Vulnerability Scanner using Nmap, Nikto, Wafw00f, DNSRecon, Wapiti and other security tools
:::1323	bash-recon-framework	Network	Bash-Recon-Framework	0	Shell	https://github.com/varun75405/Bash-Recon-Framework.git	Automated Bash-based reconnaissance and vulnerability scanning framework integrating Nmap, Nikto, Dirb, DNSRec
:::1324	sniffnet	IP / Geo	sniffnet	41171	Rust	https://github.com/GyulyVGC/sniffnet.git	Comfortably monitor your network traffic
:::1325	ntrace-core	IP / Geo	NTrace-core	8169	Go	https://github.com/nxtrace/NTrace-core.git	NextTrace, an open source visual route tracking CLI tool
:::1326	ip-tracer	IP / Geo	IP-Tracer	3012	PHP	https://github.com/rajkumardusad/IP-Tracer.git	Track any ip address with IP-Tracer. IP-Tracer is developed for Linux and Termux. you can retrieve any ip addr
:::1327	reconspider	IP / Geo	reconspider	2813	Python	https://github.com/bhavsec/reconspider.git	Most Advanced Open Source Intelligence OSINT Framework for scanning IP Address, Emails, Websites, Organizati
:::1328	ip-location-db	IP / Geo	ip-location-db	2194	JavaScript	https://github.com/sapics/ip-location-db.git	ip to location database by ASN, GeoFeed, Whois, iptoasn.com, db-ip lite, GeoLite2
:::1329	vulnx	IP / Geo	vulnx	2149	Python	https://github.com/anouarbensaad/vulnx.git	vulnx an intelligent Bot, Shell can achieve automatic injection, and help researchers detect security vulnerab
:::1330	cli	IP / Geo	cli	2067	Go	https://github.com/ipinfo/cli.git	Official Command Line Interface for the IPinfo API IP geolocation and other types of IP data
:::1331	asn	IP / Geo	asn	1936	Shell	https://github.com/nitefood/asn.git	ASN / RPKI validity / BGP stats / IPv4v6 / Prefix / URL / ASPath / Organization / IP reputation / IP geolocati
:::1332	metabigor	IP / Geo	metabigor	1837	Go	https://github.com/j3ssie/metabigor.git	OSINT power without API key hassle
:::1333	ip-info-api	IP / Geo	ip-info-api	1542	-	https://github.com/ihmily/ip-info-api.git	Free Open IP Information API IP API GET
:::1334	geowifi	IP / Geo	geowifi	1510	Python	https://github.com/GONZOsint/geowifi.git	Search WiFi geolocation data by BSSID and SSID on different public databases
:::1335	creepy	IP / Geo	creepy	1482	Python	https://github.com/ilektrojohn/creepy.git	A geolocation OSINT tool. Offers geolocation information gathering through social networking platforms
:::1336	quien	IP / Geo	quien	1268	Go	https://github.com/retlehs/quien.git	A better whois and domain intelligence toolkit
:::1337	i-see-you	IP / Geo	I-See-You	1201	Shell	https://github.com/Viralmaniar/I-See-You.git	ISeeYou is a Bash and Javascript tool to find the exact location of the users during social engineering or phi
:::1338	fav-up	IP / Geo	fav-up	1200	Python	https://github.com/pielco11/fav-up.git	IP lookup by favicon using Shodan
:::1339	geointel	IP / Geo	GeoIntel	1137	HTML	https://github.com/atiilla/GeoIntel.git	GeoIntel using Google's Gemini API to uncover the location where photos were taken through AI-powered geo-loca
:::1340	asnmap	IP / Geo	asnmap	1130	Go	https://github.com/projectdiscovery/asnmap.git	Go CLI and Library for quickly mapping organization network ranges using ASN information
:::1341	one-ip	IP / Geo	one-ip	757	TypeScript	https://github.com/zhihui-hu/one-ip.git	IP IP ASNDNS/CDN WebRTC AI
:::1342	osint-san	IP / Geo	OSINT-SAN	622	-	https://github.com/Bafomet666/OSINT-SAN.git	OSINT-SAN Framework
:::1343	connmap	IP / Geo	connmap	583	C	https://github.com/cantrepro/connmap.git	connmap is an X11 desktop widget that shows location of your current network peers on a world map in real-time
:::1344	python	IP / Geo	python	569	Python	https://github.com/ipinfo/python.git	Official Python Library for IPinfo API IP geolocation and other types of IP data
:::1345	ip2location-go	IP / Geo	ip2location-go	560	Go	https://github.com/ip2location/ip2location-go.git	The IP2Location Go Package retrieves comprehensive geolocation data from any IP address or hostname. It accura
:::1346	as-ip-blocks	IP / Geo	as-ip-blocks	523	-	https://github.com/ipverse/as-ip-blocks.git	Download IP block lists by ASN - network provider addresses, updated daily
:::1347	crips	IP / Geo	Crips	500	Python	https://github.com/Manisso/Crips.git	IP Tools To quickly get information about IP Address's, Web Pages and DNS records
:::1348	exiflooter	IP / Geo	exifLooter	498	Go	https://github.com/aydinnyunus/exifLooter.git	ExifLooter finds geolocation on all image urls and directories also integrates with OpenStreetMap
:::1349	cyberscan	IP / Geo	CyberScan	469	Python	https://github.com/medbenali/CyberScan.git	CyberScan: Network's Forensics ToolKit
:::1350	ashok	IP / Geo	Ashok	445	Python	https://github.com/powerexploit/Ashok.git	Ashok is a OSINT Recon Tool , a.k.a :heart_eyes: Swiss Army knife
:::1351	geo-recon	IP / Geo	geo-recon	414	Python	https://github.com/radioactivetobi/geo-recon.git	An OSINT CLI tool desgined to fast track IP Reputation and Geo-locaton look up for Security Analysts
:::1352	full-bug-bounty-hunting-methodology-2026	IP / Geo	Full-Bug-Bounty-Hunting-Methodology-2026	412	-	https://github.com/Cyber-note/Full-Bug-Bounty-Hunting-Methodology-2026.git	How To approach recon on real targets from passive enumeration to origin IP discovery. Covers tools, automatio
:::1353	ipdatabase	IP / Geo	ipdatabase	343	Java	https://github.com/wzhe06/ipdatabase.git	IP geolocation binary tree search
:::1354	ip_rover	IP / Geo	IP_Rover	302	Python	https://github.com/Cyber-Dioxide/IP_Rover.git	An Excellent OSINT tool to get information of any ip address. All details are explained in below screenshot
:::1355	php	IP / Geo	php	290	PHP	https://github.com/ipinfo/php.git	Official PHP library for IPinfo IP geolocation and other types of IP data
:::1356	gvision	IP / Geo	gvision	275	Python	https://github.com/GONZOsint/gvision.git	GVision is a reverse image search app that use Google Cloud Vision API to detect landmarks and web entities fr
:::1357	ip2location-iata-icao	IP / Geo	ip2location-iata-icao	268	-	https://github.com/ip2location/ip2location-iata-icao.git	This list contains the airport codes of IATA airport code and ICAO airport code together with country code and
:::1358	dumbwhois	IP / Geo	DumbWhoIs	235	JavaScript	https://github.com/DumbWareio/DumbWhoIs.git	A Dumb WhoIs
:::1359	refloow-geo-forensics	IP / Geo	Refloow-Geo-Forensics	222	JavaScript	https://github.com/Refloow/Refloow-Geo-Forensics.git	Free batch image video geolocation digital forensics tool. Automatically extract EXIF data, visualize GPS coor
:::1360	asnip	IP / Geo	asnip	221	Go	https://github.com/harleo/asnip.git	ASN target organization IP range attack surface mapping for reconnaissance, fast and lightweight
:::1361	kasroudra-ip-tracker	IP / Geo	IP-Tracker	218	Shell	https://github.com/KasRoudra/IP-Tracker.git	Track anyone's IP just opening a link
:::1362	ip2location-php-module	IP / Geo	IP2Location-PHP-Module	216	PHP	https://github.com/ip2location/IP2Location-PHP-Module.git	This module is a PHP module that enables the user to find the country, region, city, coordinates, zip code, IS
:::1363	mmdb-server	IP / Geo	mmdb-server	206	Python	https://github.com/adulau/mmdb-server.git	mmdb-server is an open source fast API server to lookup IP addresses for their geographic location
:::1364	laravel	IP / Geo	laravel	202	PHP	https://github.com/ipinfo/laravel.git	Official Laravel client library for IPinfo API IP geolocation and other types of IP data
:::1365	geo-sleuth	IP / Geo	geo-sleuth	195	Python	https://github.com/Oldcircle/geo-sleuth.git	An agent skill that finds where a photo was taken OpenStreetMap geometry, elevation skylines, satellite imager
:::1366	claude-ip-guard	IP / Geo	claude-ip-guard	190	Shell	https://github.com/cso1z/claude-ip-guard.git	A Claude Code hook plugin for IP-based access control Claude Claude IP IP Claude
:::1367	node	IP / Geo	node	189	TypeScript	https://github.com/ipinfo/node.git	Official Node client library for IPinfo API IP geolocation and other types of IP data
:::1368	geospatial-intelligence-library	IP / Geo	geospatial-intelligence-library	189	HTML	https://github.com/neonpangolin/geospatial-intelligence-library.git	Your geospatial intelligence tool belt for digital investigations
:::1369	l0p4-toolkit	IP / Geo	L0p4-Toolkit	183	Python	https://github.com/HaxL0p4/L0p4-Toolkit.git	L0p4 Toolkit is a powerful hacking toolset designed for hacker's. It includes advanced tools for web hacking 
:::1370	bigbro	IP / Geo	Bigbro	157	-	https://github.com/Bafomet666/Bigbro.git	OSINT, / 1-30 . kali linux and termux. premium
:::1371	ip-tracker	IP / Geo	IP-Tracker	150	Python	https://github.com/anonymousproo/IP-Tracker.git	Track any ip address with IP-Tracker. IP-Tracker is developed for Linux and Termux. you can retrieve any ip ad
:::1372	go	IP / Geo	go	150	Go	https://github.com/ipinfo/go.git	Go library for IPinfo API IP geolocation and other types of IP data
:::1373	interceptor	IP / Geo	Interceptor	144	Shell	https://github.com/Lucksi/Interceptor.git	An Ip-Grabber Tool With a Custom Redirect Link
:::1374	bing-ip2hosts	IP / Geo	bing-ip2hosts	141	Shell	https://github.com/urbanadventurer/bing-ip2hosts.git	bingip2hosts is a Bing.com web scraper that discovers websites by IP address
:::1375	ip-address-databases	IP / Geo	ip-address-databases	138	-	https://github.com/iplocate/ip-address-databases.git	Free, daily-updated IP to Country ASN databases and samples from www.iplocate.io
:::1376	java	IP / Geo	java	136	Java	https://github.com/ipinfo/java.git	Official Java library for IPinfo API IP geolocation and other types of IP data
:::1377	geo-nft	IP / Geo	geo-nft	126	Shell	https://github.com/wirefalls/geo-nft.git	Bash script to create nftables sets of country specific IP address ranges for use with firewall rulesets. The 
:::1378	nft-geo-filter	IP / Geo	nft-geo-filter	118	Python	https://github.com/rpthms/nft-geo-filter.git	Allow/deny traffic in nftables using country specific IP blocks
:::1379	media-search-engine	IP / Geo	media-search-engine	115	Python	https://github.com/conflict-investigations/media-search-engine.git	Search geolocations for social media posts in databases like Bellingcat, Cen4InfoRes etc
:::1380	twlocation	IP / Geo	TwLocation	108	Python	https://github.com/MazenElzanaty/TwLocation.git	Python script that gets Twitter users' tweets location
:::1381	ip2location-nodejs	IP / Geo	ip2location-nodejs	108	JavaScript	https://github.com/ip2location/ip2location-nodejs.git	IP2Location Node.js Module - Knowing where your visitors from
:::1382	cidr-ip-ranges-by-country	IP / Geo	cidr-ip-ranges-by-country	106	-	https://github.com/ebrasha/cidr-ip-ranges-by-country.git	CIDR IP ranges by country for geolocation, firewall rules, network filtering, and cybersecurity updated hourly
:::1383	merged-ip-data	IP / Geo	Merged-IP-Data	105	Go	https://github.com/NetworkCats/Merged-IP-Data.git	merge multiple IP geolocation databases into a single MMDB file
:::1384	eyes-sh	IP / Geo	eyes.sh	103	Shell	https://github.com/naltun/eyes.sh.git	Let's you perform domain/IP information gathering... in BASH Wasn't it esr who said With enough eyeballs, all 
:::1385	cloudcheck	IP / Geo	cloudcheck	93	Python	https://github.com/blacklanternsecurity/cloudcheck.git	Check whether an IP address or hostname belongs to popular cloud providers
:::1386	ip2location-c-library	IP / Geo	IP2Location-C-Library	93	Shell	https://github.com/ip2location/IP2Location-C-Library.git	IP2Location C library enables the user to find the country, region, city, coordinates, zip code, time zone, IS
:::1387	lingolens	IP / Geo	lingolens	86	HTML	https://github.com/OSINT-mindset/lingolens.git	Search in Google Lens in lingo Multi language search of image with export in HTML report
:::1388	ip2location-laravel	IP / Geo	ip2location-laravel	79	PHP	https://github.com/ip2location/ip2location-laravel.git	The IP2Location Laravel extension allows users to retrieve geolocation data from an IP address using the IP2Lo
:::1389	spyrod-v2	IP / Geo	Spyrod-v2	76	Python	https://github.com/Euronymou5/Spyrod-v2.git	Una simple herramienta para rastrear IP programada en Python
:::1390	ip2location-nginx	IP / Geo	ip2location-nginx	73	C	https://github.com/ip2location/ip2location-nginx.git	This is IP2Location Nginx module that enables the user to find the country, region state, city, latitude, lo
:::1391	ipapi-python	IP / Geo	ipapi-python	69	Python	https://github.com/ipapi-co/ipapi-python.git	Python bindings for https://ipapi.co IP Address Location - Use with python / django / flask for IP address l
:::1392	rust	IP / Geo	rust	68	Rust	https://github.com/ipinfo/rust.git	IPinfo Rust library for IPinfo API IP geolocation and other types of IP data
:::1393	ipanalyzer	IP / Geo	IPAnalyzer	67	Shell	https://github.com/s-r-e-e-r-a-j/IPAnalyzer.git	IPAnalyzer is an IP Address Tracker OSINT ethical hacking tool built for Linux distributions, designed to gath
:::1394	ip2location-java	IP / Geo	ip2location-java	66	Java	https://github.com/ip2location/ip2location-java.git	IP2Location IP Geolocation Java Component enables applications to retrieve IP geolocation data, including the 
:::1395	rgeolocate	IP / Geo	rgeolocate	66	C	https://github.com/Ironholds/rgeolocate.git	Generalised IP geolocation through R
:::1396	django	IP / Geo	django	59	Python	https://github.com/ipinfo/django.git	Official Django Library for IPinfo API IP geolocation and other types of IP data
:::1397	osint-mcp-server	IP / Geo	osint-mcp-server	55	TypeScript	https://github.com/badchars/osint-mcp-server.git	OSINT intelligence MCP server for AI agents 37 tools, 12 sources. Shodan, VirusTotal, Censys, SecurityTrails, 
:::1398	ruby	IP / Geo	ruby	52	Ruby	https://github.com/ipinfo/ruby.git	Official Ruby client library for IPinfo API IP geolocation and other types of IP data
:::1399	ip2country	IP / Geo	IP2Country	52	C#	https://github.com/RobThree/IP2Country.git	Ip to country mapping
:::1400	n-trace	IP / Geo	N-TRACE	51	Python	https://github.com/Nabil-Official/N-TRACE.git	IP -TRACKER IP-PHISH RANDOM-IP-GENARATOR
:::1401	ipapi-nodejs	IP / Geo	ipapi-nodejs	46	JavaScript	https://github.com/ipapi-co/ipapi-nodejs.git	Node.js - for https://ipapi.co IP address geolocation API. Lookup IP address info with Javascript / NodeJS
:::1402	geolocate-ip-browser-extension	IP / Geo	Geolocate-IP-Browser-Extension	45	JavaScript	https://github.com/AykutCevik/Geolocate-IP-Browser-Extension.git	A browser extension, which shows you the origin of your IP address
:::1403	ip2trace-python	IP / Geo	ip2trace-python	42	Python	https://github.com/ip2location/ip2trace-python.git	Python tool to traceroute with IP geolocation information, such as country, region, city, isp and many more
:::1404	ip-geolocation-api-php	IP / Geo	ip-geolocation-api-php	42	PHP	https://github.com/IPGeolocation/ip-geolocation-api-php.git	Official PHP SDK for the IPGeolocation.io IP Location API with single and bulk lookup, typed responses, and ra
:::1405	ip-nose	IP / Geo	ip-nose	39	C++	https://github.com/Karim93160/ip-nose.git	ip-nose is a Matrix-themed IP geolocation CLI tool built with C++. It offers IP detection, search history, a v
:::1406	hmg-ipmap	IP / Geo	hmg-ipmap	38	Java	https://github.com/hyundaimotorgroup/hmg-ipmap.git	Open-source IP geolocation platform that resolves IPv4 addresses to city, country, and continent
:::1407	jackind424-ip-tracer	IP / Geo	IP-Tracer	37	PHP	https://github.com/jackind424/IP-Tracer.git	Track any ip address with IP-Tracer. IP-Tracer is developed for linux and android terminal like Termux and GNU
:::1408	ip2location-csv-converter	IP / Geo	ip2location-csv-converter	36	PHP	https://github.com/ip2location/ip2location-csv-converter.git	This PHP script converts IP2Location CSV database into IP range or CIDR format
:::1409	ip2location-piwik	IP / Geo	ip2location-piwik	35	PHP	https://github.com/ip2location/ip2location-piwik.git	IP2Location geolocation service to lookup a visitor's location in Matomo Piwik 4.x, 5.x. This service allows
:::1410	geoip-asn	IP / Geo	geoip-asn	34	Python	https://github.com/O-X-L/geoip-asn.git	Open Free IP to ASN/Internet Provider Database
:::1411	locus	IP / Geo	locus	33	Python	https://github.com/alpkeskin/locus.git	Turn street photos into GPS coordinates using AI
:::1412	safeip	IP / Geo	SafeIP	32	JavaScript	https://github.com/AhmadJeddi/SafeIP.git	A lightweight network security tool that verifies IP location, validates network safety, and prevents access t
:::1413	what-you-reveal	IP / Geo	what-you-reveal	32	JavaScript	https://github.com/saatvik333/what-you-reveal.git	a privacy analysis tool designed to show exactly what information your browser exposes to websites
:::1414	sypexgeors	IP / Geo	SypexGeoRS	30	Rust	https://github.com/GLOBUS-studio/SypexGeoRS.git	Fast zero-dependency pure-Rust reader for SypexGeo binary IP geolocation databases - country, city and region 
:::1415	wordpress-ip-geo-block	IP / Geo	WordPress-IP-Geo-Block	28	PHP	https://github.com/tokkonopapa/WordPress-IP-Geo-Block.git	A WordPress plugin that will blocks any comment, pingback and trackback spams posted from outside your nation.
:::1416	rustyip	IP / Geo	rustyip	28	Rust	https://github.com/NetworkCats/rustyip.git	Lightweight IP lookup service with geolocation, ASN, and proxy/VPN detection
:::1417	ip2location-io-rust	IP / Geo	ip2location-io-rust	28	Rust	https://github.com/ip2location/ip2location-io-rust.git	IP2Location.io Rust SDK allows user to query for an enriched data set based on IP address and provides WHOIS l
:::1418	steamreveal	IP / Geo	SteamReveal	27	TypeScript	https://github.com/Berchez/SteamReveal.git	Discover a Steam player's likely location and closest friends through social graph analysis plus AI-based chea
:::1419	ip2location-ruby	IP / Geo	ip2location-ruby	27	Ruby	https://github.com/ip2location/ip2location-ruby.git	The IP2Location Ruby library enables users to retrieve geolocation information from an IP address or hostname,
:::1420	ip2location-traceroute	IP / Geo	ip2location-traceroute	27	C	https://github.com/ip2location/ip2location-traceroute.git	A traceroute tools that displaying geolocation information using IP2Location database
:::1421	infofinder	IP / Geo	infofinder	27	Shell	https://github.com/AnonymousAt3/infofinder.git	Automated Ip Tracking Tool
:::1422	codeigniter-ip2location	IP / Geo	codeigniter-ip2location	26	PHP	https://github.com/ip2location/codeigniter-ip2location.git	IP2Location library for CodeIgniter. Use IP2Location geolocation database to lookup the country, region, city,
:::1423	footprinted	IP / Geo	footprinted	25	Ruby	https://github.com/rameerez/footprinted.git	Simple event tracking for Rails apps: automatically track IP geolocated user activity
:::1424	csharp-old	IP / Geo	csharp-old	25	C#	https://github.com/ipinfo/csharp-old.git	Old C# Library for IPinfo API IP geolocation and other types of IP data
:::1425	achik-ahmed-ip-tracer	IP / Geo	Ip-Tracer	25	Shell	https://github.com/Achik-Ahmed/Ip-Tracer.git	A basic Termux IP address tracer tool that can fetch all publicly available information about an IP address
:::1426	iptracker	IP / Geo	ipTracker	23	Shell	https://github.com/m4lal0/ipTracker.git	Herramienta hecha en Bash para rastrear una IP Pblica
:::1427	ip2location-lookup-py	IP / Geo	ip2location-lookup-py	23	Python	https://github.com/ip2location/ip2location-lookup-py.git	A free standalone software that enables end-users to detect country, region, city, latitude, longitude, ZIP co
:::1428	ip2location-io-php	IP / Geo	ip2location-io-php	23	PHP	https://github.com/ip2location/ip2location-io-php.git	IP2Location.IO PHP SDK allows user to query for an enriched data set based on IP address and provides WHOIS lo
:::1429	ip2location-io-python	IP / Geo	ip2location-io-python	23	Python	https://github.com/ip2location/ip2location-io-python.git	IP2Location.IO Python SDK allows user to query for an enriched data set based on IP address and provides WHOIS
:::1430	ip2location-io-cli	IP / Geo	ip2location-io-cli	23	Go	https://github.com/ip2location/ip2location-io-cli.git	IP2Location.io command line to query IP geolocation data from IP2Location.io API
:::1431	rails	IP / Geo	rails	23	Ruby	https://github.com/ipinfo/rails.git	Official Rails Library for IPinfo API IP geolocation and other types of IP data
:::1432	spring	IP / Geo	spring	22	Java	https://github.com/ipinfo/spring.git	Official Spring Client Library for IPinfo API IP geolocation and other types of IP data
:::1433	know-your-ip	IP / Geo	know-your-ip	22	Python	https://github.com/themains/know-your-ip.git	Know Your IP: Get location, blacklist status, shodan and censys results, and more
:::1434	ip-geolocation-api-java-sdk	IP / Geo	ip-geolocation-api-java-sdk	22	Java	https://github.com/IPGeolocation/ip-geolocation-api-java-sdk.git	Official Java SDK for the IPGeolocation API. Get IP geolocation, ASN, company, timezone, hostname, and user-ag
:::1435	ip-geolocation-api-javascript-sdk	IP / Geo	ip-geolocation-api-javascript-sdk	22	TypeScript	https://github.com/IPGeolocation/ip-geolocation-api-javascript-sdk.git	Official JavaScript SDK for the IPGeolocation.io IP Location API with single and bulk lookup, typed JSON, and 
:::1436	reconwolf	IP / Geo	ReconWolf	21	Perl	https://github.com/XyberWolf/ReconWolf.git	Web Footprinting Tool
:::1437	ip-location-api	IP / Geo	ip-location-api	21	Go	https://github.com/paul-norman/ip-location-api.git	A basic API for IP location lookups
:::1438	ip2location-cakephp	IP / Geo	ip2location-cakephp	21	PHP	https://github.com/ip2location/ip2location-cakephp.git	IP2Location CakePHP plugin enables the user to find the country, region, city, coordinates, zip code, time zon
:::1439	java-appium-ip-geolocation	IP / Geo	java-appium-ip-geolocation	21	Java	https://github.com/himanshuseth004/java-appium-ip-geolocation.git	Change IP geographic location in Java with Appium on LambdaTest cloud
:::1440	geolocate-ips	IP / Geo	geolocate-ips	21	Python	https://github.com/christophetd/geolocate-ips.git	Batch IP geolocation script
:::1441	web-scanner	IP / Geo	Web-Scanner	19	Python	https://github.com/Akshay7591/Web-Scanner.git	Web Scanner written in Python which after scanning the given URL returns it's domain name, ip address, nmap sc
:::1442	bloodfinder	IP / Geo	BloodFinder	19	Java	https://github.com/rasheedsulayman/BloodFinder.git	Iblood is an application that connects blood seekers with nearby blood donors and blood banks
:::1443	astralosint	IP / Geo	AstralOSINT	16	JavaScript	https://github.com/hackops-academy/AstralOSINT.git	AstraOSINT is a professional-grade, web-based Geospatial Intelligence GEOINT tool designed for researchers, 
:::1444	gunadizz-ip-tracer	IP / Geo	IP-tracer	11	Python	https://github.com/gunadizz/IP-tracer.git	Track IP Location
:::1445	ipgeolocation-cli	IP / Geo	cli	10	Go	https://github.com/IPGeolocation/cli.git	IPGeolocation.io Command Line Tool CLI for fast IP lookups with threat intelligence, timezone, user-agent, a
:::1446	tracepoint	IP / Geo	TracePoint	9	JavaScript	https://github.com/kluter/TracePoint.git	Locate the origin point of photographs using geometric ray intersection
:::1447	stark-404-ip-tracker	IP / Geo	Ip-tracker	9	Python	https://github.com/STARK-404/Ip-tracker.git	It's a Simple Code To Track Geolocation
:::1448	white-iptracer	IP / Geo	white-IpTracer	8	Python	https://github.com/whxitte/white-IpTracer.git	Just a simple light weight tool for simple ip information gathering
:::1449	th3-c0der-ip-tracer	IP / Geo	IP-Tracer	8	PHP	https://github.com/Th3-C0der/IP-Tracer.git	Track any ip address with IP-Tracer. IP-Tracer is developed for Linux and Termux. you can retrieve any ip addr
:::1450	ip-tracer-tracker-using-kali-linux	IP / Geo	IP-Tracer-Tracker-using-Kali-Linux	8	PHP	https://github.com/RaghavDabra/IP-Tracer-Tracker-using-Kali-Linux-.git	How to check someone's IP Address using Kali Linux
:::1451	hackersm9-ip-tracker	IP / Geo	ip-tracker	8	Python	https://github.com/HackerSM9/ip-tracker.git	Track IP in Termux with best VERSION 98.7
:::1452	ipscope	IP / Geo	ipscope	8	Go	https://github.com/cyclone-github/ipscope.git	A powerful, yet easy to use CLI tool written in Go for subdomain discovery and IP lookup
:::1453	ohsint-completed-task	IP / Geo	ohsint-completed-task	7	-	https://github.com/NovaCode37/ohsint-completed-task.git	Completed the OhSINT room on TryHackMe an OSINT challenge involving image metadata analysis, social media inte
:::1454	sevenminutesontheseine-osint	IP / Geo	SevenMinutesOnTheSeine-osint	7	-	https://github.com/NovaCode37/SevenMinutesOnTheSeine-osint.git	Solved TryHackMe The Case: Seven Minutes on the Seine multi-layered OSINT investigation of a fictional Louvre 
:::1455	ip-tracer-v3-0-2	IP / Geo	IP-Tracer-v3.0.2	7	PHP	https://github.com/reblox01/IP-Tracer-v3.0.2.git	Track any ip address with IP-Tracer. IP-Tracer v3.0.2 is developed for Linux and Termux. you can retrieve any 
:::1456	cylentsec-dnsrecon	IP / Geo	dnsrecon	7	Go	https://github.com/cylentsec/dnsrecon.git	This tool enriches domain lists by resolving each domain to its IP address and identifying the organization th
:::1457	iptracer	IP / Geo	iptracer	6	-	https://github.com/titancomputinglegend/iptracer.git	Fixed version of Rajkumardusad's IP-Tracer @ https://github.com/titancomputinglegend/iptracer.git
:::1458	spyrod-v1	IP / Geo	Spyrod-v1	6	Python	https://github.com/Euronymou5/Spyrod-v1.git	Una simple herramienta para rastrear IP programada en Python
:::1459	abhi6722-ipdrone	IP / Geo	ipdrone	6	Python	https://github.com/Abhi6722/ipdrone.git	get your victim's location by his/her ip address in Termux from ipdrone https://hackershub.abhi6722.in
:::1460	spiderfootreverseipmodule	IP / Geo	SpiderFootReverseIPModule	5	Python	https://github.com/hardsoftsecurity/SpiderFootReverseIPModule.git	Module created for the reverse identification of websites hosted on the same IP address
:::1461	arturo254-ip-tracer	IP / Geo	IP-TRACER	4	-	https://github.com/Arturo254/IP-TRACER.git	Para saber informacin necesaria de una direccin IP OJO NO DOXEA
:::1462	dhcp-server-configuration-in-cisco-packe	IP / Geo	DHCP-server-configuration-in-Cisco-Packe	4	-	https://github.com/Ironfist69/DHCP-server-configuration-in-Cisco-Packet-Tracer.git	This project involves configuring DHCP and DNS servers in Cisco Packet Tracer. The DHCP server automates IP ad
:::1463	krishpranav-ip-tracer	IP / Geo	ip-tracer	3	Python	https://github.com/krishpranav/ip-tracer.git	This Tool will trace someone's ip address
:::1464	codingwithdevil-ip-tracer	IP / Geo	IP-Tracer	3	Python	https://github.com/codingwithdevil/IP-Tracer.git	Trace IP Address , Fetch IP Info
:::1465	shamanthss-iptracker	IP / Geo	iptracker	3	PHP	https://github.com/shamanthss/iptracker.git	IP-Tracker is use to track ip address. IP-Tracker is developed for linux and android terminal like Termux and 
:::1466	ipa4	IP / Geo	IPa4	3	Python	https://github.com/Prvvv/IPa4.git	Quick and Accurate IP Address Geo-Location and Security lookup program
:::1467	xcryp-ip-tracer	IP / Geo	XCRYP-IP-TRACER	2	Python	https://github.com/pyvrax/XCRYP-IP-TRACER.git	IP Tracer Tool
:::1468	ip-tracer-plus	IP / Geo	IP-Tracer-Plus	2	PHP	https://github.com/JaniduXxX/IP-Tracer-Plus.git	IP-Tracer is used to track an ip address. IP-Tracer is developed for Termux and Linux based systems. you can e
:::1469	ahrabbi1998-ip-tracer	IP / Geo	IP-Tracer	2	-	https://github.com/ahrabbi1998/IP-Tracer.git	What is IP-Tracer ? IP-Tracer is used to track an ip address. IP-Tracer is developed for linux and android ter
:::1470	steven-ai-cmyk-ip-tracer	IP / Geo	ip-Tracer	2	-	https://github.com/Steven-ai-cmyk/ip-Tracer-.git	apt update apt upgrade -y pkg install git -y pkg install w3m -y pkg install wget -y git clone https://github.c
:::1471	ip-tracer-pro	IP / Geo	IP-Tracer-Pro	2	PHP	https://github.com/poisk-ls/IP-Tracer-Pro.git	Track any ip address and retrieve information
:::1472	ip-address-track	IP / Geo	IP-address-track	2	-	https://github.com/Whitedevile420/IP-address-track-.git	apt update apt install git -y git clone https://github.com/rajkumardusad/IP-Tracer.git cd IP-Tracer chmod +x i
:::1473	bank-network-design	IP / Geo	BANK-NETWORK-DESIGN	2	-	https://github.com/SahithiPoladi/BANK-NETWORK-DESIGN.git	Designed a network of BANK using Cisco Packet Tracer and configured IP address for Systems, Switches and Firew
:::1474	nano-tracer	IP / Geo	nano-tracer	2	PHP	https://github.com/ExploitXpertt/nano-tracer.git	Nano Tracer A lightweight IP information lookup tool for Termux, Linux, and other Unix-like systems. Retrieve 
:::1475	mmdbio	IP / Geo	mmdbio	2	Go	https://github.com/IPGeolocation/mmdbio.git	mmdbio is ipgeolocation.io's MMDB file management CLI, supporting inspection, lookups, validation, diffs, and 
:::1476	workly-ai-powered-platform-for-hyper-loc	IP / Geo	Workly-AI-Powered-Platform-for-Hyper-Loc	2	TypeScript	https://github.com/hanifjamadar77/Workly-AI-Powered-Platform-for-Hyper-Local-Micro-Job-Finding-.git	In the current gig economy, individuals seeking short-term, flexible jobssuch as students, unemployed youth, a
:::1477	neighbour	IP / Geo	neighbOUR	2	JavaScript	https://github.com/NaveenKumar-AK/neighbOUR.git	Finding reliable local services plumbing, tutoring, cleaning is difficult. LocalServe is a web platform conn
:::1478	ip-tracer-wch	IP / Geo	IP-Tracer-WCH	1	-	https://github.com/Wiich-Crack-Hack/IP-Tracer-WCH.git	What is IP-Tracer ? IP-Tracer is used to track an ip address. IP-Tracer is developed for Termux and Linux base
:::1479	bnl987-ip-tracer	IP / Geo	IP-Tracer	1	PHP	https://github.com/Bnl987/IP-Tracer.git	Track any ip address with IP-Tracer. IP-Tracer is developed for Linux and Termux. you can retrieve any ip addr
:::1480	batch-ip-tracer	IP / Geo	Batch-IP-Tracer	1	Shell	https://github.com/SammyHerring/Batch-IP-Tracer.git	Batch based IP Tracer
:::1481	ipgrab	IP / Geo	IpGrab	1	Python	https://github.com/Aruack/IpGrab.git	Ipdrone is a simply python script, which can be used to Ip lookup and to get information of perticualr target 
:::1482	localtime-cli	IP / Geo	localtime-cli	1	Python	https://github.com/thaikolja/localtime-cli.git	GitLab-mirrored repository of localtime-cli, a Command-Line Interface CLI tool for retrieving the local time
:::1483	ipyou-cli	IP / Geo	ipyou-cli	1	Shell	https://github.com/ipyou-net/ipyou-cli.git	ipyou.net IP :ASN/, API KeyFree IP lookup with geolocation, ASN, residential/datacenter detection risk score. 
:::1484	eagleeye	IP / Geo	EagleEye	1	Python	https://github.com/NyxarisSec/EagleEye.git	Eagle Eye is a focused infrastructure intelligence tool that identifies cloud service endpoints, CDN and edge 
:::1485	dj-seeker	IP / Geo	DJ-Seeker	1	PHP	https://github.com/rootuserdj/DJ-Seeker.git	Geolocation framework for ethical security research. Accurately pinpoints device location and captures detaile
:::1486	domfetcher	IP / Geo	DomFetcher	1	Python	https://github.com/MrAdi46/DomFetcher.git	DomFetcher is an asynchronous OSINT tool for domain intelligence and security scanning. It collects data from 
:::1487	get-into-hacking-ipdrone	IP / Geo	ipdrone	0	Python	https://github.com/Get-Into-Hacking/ipdrone.git	Ipdrone is a simply python script, which can be used to Ip lookup and to get information of perticualr target 
:::1488	netora	IP / Geo	netora	0	Python	https://github.com/nativevoid/netora.git	Quickly uncover details and geolocation for any IP address
:::1489	entry-level-reconnaissance-project-infor	IP / Geo	Entry-Level-Reconnaissance-Project-Infor	0	-	https://github.com/William-cybersec/Entry-Level-Reconnaissance-Project-Information-Gathering-Target-Profiling.git	Entry-level cybersecurity project demonstrating passive reconnaissance using OSINT tools like theHarvester, WH
:::1490	advanced-domain-lookup	IP / Geo	Advanced-Domain-Lookup	0	Python	https://github.com/Dan-Duran/Advanced-Domain-Lookup.git	This Python terminal utility performs domain lookups, retrieving DNS records, WHOIS information, IP geolocatio
:::1491	ifinder	IP / Geo	ifinder	0	Python	https://github.com/virtuvil/ifinder.git	ifinderis simple python tool for finding IP address for bunch of live subdomains.Generally subdomain enumerati
:::1492	jarit	IP / Geo	JarIt	0	Java	https://github.com/owwlo/JarIt.git	Geolocation based treasure seeking app prototype
:::1493	seekergeolocation	IP / Geo	seekergeolocation	0	-	https://github.com/trigona/seekergeolocation.git	geolocation using seeker
:::1494	find_out_user_geolocation	IP / Geo	find_out_user_geolocation	0	HTML	https://github.com/LizardRoot/find_out_user_geolocation.git	Find out the location of users on the Internet
:::1495	master-seeker	IP / Geo	Master-Seeker	0	Python	https://github.com/anonymouscreationss/Master-Seeker.git	Master Seeker A Flask-powered OSINT reconnaissance framework for device geolocation, people discovery, and soc
:::1496	treasure-dumps	IP / Geo	Treasure-dumps	0	-	https://github.com/Mattsmovers/Treasure-dumps.git	X and y axis geolocation of mall dumpsters with treasures. Money for contributors and prize for seekers
:::1497	homecooks	IP / Geo	HomeCooks	0	TypeScript	https://github.com/arbitroy/HomeCooks.git	HomeCooks is a mobile marketplace that connects passionate home cooks with local customers seeking authentic, 
:::1498	cultural-experience-finder	IP / Geo	Cultural-Experience-Finder	0	JavaScript	https://github.com/yugmehendiratta/Cultural-Experience-Finder.git	The Cultural Experience Finder is an innovative project designed to connect users with enriching cultural expe
:::1499	gram-sakhi	IP / Geo	GRAM-SAKHI	0	HTML	https://github.com/GramSakhi-org/GRAM-SAKHI.git	Gram Sakhi is a web app that connects skilled rural workers with urban seekers using geolocation. It provides 
:::1500	solana-pulse-mobile	IP / Geo	solana-pulse-mobile	0	HTML	https://github.com/kosmokhm/solana-pulse-mobile.git	$SKR Super-App for Solana Mobile Pulse Mobile is an advanced Android-native Super-App built specifically for 
:::1501	cti-dashboard	IP / Geo	CTI-Dashboard	0	Python	https://github.com/heraldava-unmsm/CTI-Dashboard-.git	The project seeks to develop a centralized cyberattack intelligence system for real-time surveillance, incorpo
:::1502	the-ook-project	IP / Geo	The-Ook-project	0	-	https://github.com/AndrewvyumvuhoreOok/The-Ook-project-.git	This project seeks to create a new advanced technology learning tool/ device that uses AI and real world appli
:::1503	native-spotin-frontend	IP / Geo	Native-SpotIn-Frontend	0	TypeScript	https://github.com/YOKH-DEV/Native-SpotIn-Frontend.git	Spotin is an attendance app that validates in real time whether a person is at the assigned location, date, an
:::1504	trip-companion	IP / Geo	Trip-Companion	0	JavaScript	https://github.com/Pranjali6/Trip-Companion.git	This application is designed for tourists seeking the best dining experiences. It leverages Google Maps and va
:::1505	hackzurick19	IP / Geo	hackzurick19	0	TypeScript	https://github.com/vpcom/hackzurick19.git	#3 EVENT SEEKING FOR MERE MORTALS SWISSCOM CASE POWERED BY LOCALCITIES.CH Planning your social life online r
:::1506	scansearch-python	IP / Geo	scansearch-python	0	Python	https://github.com/ScanSearch/scansearch-python.git	Official Python SDK and CLI for ScanSearch live internet scanning exposure-research platform. Alternative to S
:::1507	instaloader	Social Media	instaloader	13411	Python	https://github.com/instaloader/instaloader.git	Download pictures or videos along with their captions and other metadata from Instagram
:::1508	instagrapi	Social Media	instagrapi	6824	Python	https://github.com/subzeroid/instagrapi.git	The fastest and powerful Python library for Instagram Private API 2026 with HikerAPI SaaS
:::1509	gitgraber	Social Media	gitGraber	2430	Python	https://github.com/hisxo/gitGraber.git	gitGraber: monitor GitHub to search and find sensitive data in real time for different online services such as
:::1510	yark	Social Media	yark	2189	Python	https://github.com/Owez/yark.git	OSINT for YouTube made simple
:::1511	tinfoleak	Social Media	tinfoleak	1984	Python	https://github.com/vaguileradiaz/tinfoleak.git	The most complete open-source tool for Twitter intelligence analysis
:::1512	twitter-advanced-search	Social Media	twitter-advanced-search	1610	-	https://github.com/igorbrigadir/twitter-advanced-search.git	Advanced Search for Twitter
:::1513	osi-ig	Social Media	osi.ig	1567	Python	https://github.com/th3unkn0n/osi.ig.git	Information Gathering Instagram
:::1514	instagram_monitor	Social Media	instagram_monitor	1508	Python	https://github.com/misiektoja/instagram_monitor.git	Track Instagram users' activities, profile changes and capture content with beautiful dashboards and instant n
:::1515	attacksurfacemapper	Social Media	AttackSurfaceMapper	1409	Python	https://github.com/superhedgy/AttackSurfaceMapper.git	AttackSurfaceMapper is a tool that aims to automate the reconnaissance process
:::1516	xteam	Social Media	Xteam	1293	Python	https://github.com/xploitstech/Xteam.git	Xteam All in one Instagram,Android,phishing osint and wifi hacking tool available
:::1517	ipranges	Social Media	ipranges	1179	Shell	https://github.com/lord-alfred/ipranges.git	List all IP ranges from: Google Cloud GoogleBot, Bing Bingbot, Amazon AWS, Microsoft, Oracle Cloud, Gi
:::1518	avillaforensics	Social Media	AvillaForensics	1128	C#	https://github.com/AvillaDaniel/AvillaForensics.git	Avilla Forensics FREE
:::1519	scrapfly-scrapers	Social Media	scrapfly-scrapers	1082	Python	https://github.com/scrapfly/scrapfly-scrapers.git	Scalable Python web scraping scripts for +40 popular domains
:::1520	matkap	Social Media	matkap	1030	JavaScript	https://github.com/0x6rss/matkap.git	Matkap - hunt down malicious Telegram bots
:::1521	urs	Social Media	URS	1027	Python	https://github.com/JosephLai241/URS.git	Universal Reddit Scraper - A comprehensive Reddit scraping/archival command-line tool
:::1522	social-media-osint	Social Media	Social-Media-OSINT	1019	-	https://github.com/The-Osint-Toolbox/Social-Media-OSINT.git	Social Media OSINT collection containing - tools, techniques tradecraft
:::1523	instagramprivsniffer	Social Media	InstagramPrivSniffer	1018	Python	https://github.com/obitouka/InstagramPrivSniffer.git	First ever tool to view Instagram private posts anonymously
:::1524	x-tweet-fetcher	Social Media	x-tweet-fetcher	965	Python	https://github.com/ythx-101/x-tweet-fetcher.git	Fetch X/Twitter tweets, replies, timelines, and articles without login or API keys field tool for AI agents
:::1525	tweetfeed	Social Media	TweetFeed	683	-	https://github.com/0xDanielLopez/TweetFeed.git	TweetFeed collects Indicators of Compromise IOCs shared by the infosec community at Twitter. Here you will f
:::1526	gosint	Social Media	gOSINT	676	Go	https://github.com/Nhoya/gOSINT.git	OSINT Swiss Army Knife
:::1527	ironsight	Social Media	IRONSIGHT	648	TypeScript	https://github.com/NoblerWorks-HQ/IRONSIGHT.git	Real-time OSINT command center for the Iran/Israel and Russia/Ukraine theaters 50+ live open-source intelligen
:::1528	stweet	Social Media	stweet	621	Python	https://github.com/markowanga/stweet.git	Advanced python library to scrap Twitter tweets, users from unofficial API
:::1529	linkedindumper	Social Media	LinkedInDumper	613	Python	https://github.com/l4rm4nd/LinkedInDumper.git	Python 3 script to dump/scrape/extract company employees from LinkedIn API
:::1530	maltego-telegram	Social Media	maltego-telegram	567	Python	https://github.com/vognik/maltego-telegram.git	OSINT Maltego Transforms for investigating Telegram channels, groups, and users, including deanonymization via
:::1531	netsoc_osint	Social Media	NetSoc_OSINT	518	Shell	https://github.com/XDeadHackerX/NetSoc_OSINT.git	Tool focused on extracting information from an account in different Social Networks / Herramienta enfocada a e
:::1532	youtube-metadata	Social Media	youtube-metadata	509	JavaScript	https://github.com/mattwright324/youtube-metadata.git	A quick way to gather all the metadata about a video, playlist, or channel from the YouTube API
:::1533	terra	Social Media	terra	467	Python	https://github.com/xadhrit/terra.git	OSINT Tool on Twitter and Instagram
:::1534	scamintellogs	Social Media	ScamIntelLogs	444	HTML	https://github.com/phishdestroy/ScamIntelLogs.git	Open-source intelligence archive of crypto scam operations internal chats, admin panels, victim records, and i
:::1535	soig	Social Media	SoIG	424	Python	https://github.com/yezz123/SoIG.git	OSINT Tool gets a range of information from an Instagram account
:::1536	birdwatcher	Social Media	birdwatcher	421	Ruby	https://github.com/michenriksen/birdwatcher.git	Data analysis and OSINT framework for Twitter
:::1537	instagram-private-graph	Social Media	instagram-private-graph	407	Python	https://github.com/0x6rss/instagram-private-graph.git	Analyze the followers and following accounts that a private hidden Instagram account interacts with
:::1538	telegram-bot-dumper	Social Media	telegram-bot-dumper	383	Python	https://github.com/soxoj/telegram-bot-dumper.git	Dumper ripper for Telegram bots by token. Forensic CLI tool with web interface
:::1539	telegram-tracker	Social Media	telegram-tracker	383	Python	https://github.com/estebanpdl/telegram-tracker.git	The package connects to Telegram's API to generate JSON files containing data for channels, including informat
:::1540	the-endorser	Social Media	the-endorser	357	Python	https://github.com/eth0izzle/the-endorser.git	An OSINT tool that allows you to draw out relationships between people on LinkedIn via endorsements/skills
:::1541	deanonymizer	Social Media	deanonymizer	345	TypeScript	https://github.com/ni5arga/deanonymizer.git	Deanonymize anyone based on their public commenting or posting history pattern
:::1542	nqntnqnqmb	Social Media	nqntnqnqmb	333	Python	https://github.com/megadose/nqntnqnqmb.git	Allows you to retrieve information on linkedin profiles, companies on linkedin and search on linkedin companie
:::1543	youtube-comment-suite	Social Media	youtube-comment-suite	323	Java	https://github.com/mattwright324/youtube-comment-suite.git	Download YouTube comments from numerous videos, playlists, and channels for archiving, general search, and sho
:::1544	telegram-osint-lib	Social Media	telegram-osint-lib	319	PHP	https://github.com/Postuf/telegram-osint-lib.git	Telegram scenario-based API aimed at OSINT
:::1545	c-hacks	Social Media	C-hacks	305	Python	https://github.com/DRACULA-HACK/C-hacks.git	All social Media hacking with information gathering
:::1546	twitwork	Social Media	TwitWork	277	JavaScript	https://github.com/atmoner/TwitWork.git	Monitor twitter stream from nodejs electron
:::1547	masto	Social Media	Masto	272	Python	https://github.com/C3n7ral051nt4g3ncy/Masto.git	Masto is an OSINT tool written in python to gather intelligence on Mastodon users and instances
:::1548	tigmint	Social Media	TIGMINT	267	JavaScript	https://github.com/TIGMINT/TIGMINT.git	TIGMINT: OSINT Open Source Intelligence GUI software framework
:::1549	rpi-security	Social Media	rpi-security	223	Python	https://github.com/FutureSharks/rpi-security.git	A security system written in python to run on a Raspberry Pi with motion detection and mobile notifications
:::1550	telegramdb	Social Media	TelegramDB	219	-	https://github.com/TelegramDB/TelegramDB.git	TelegramDB is a service that allows you to search for channels, groups and their members
:::1551	rosint	Social Media	Rosint	199	JavaScript	https://github.com/zuxu4n/Rosint.git	Reddit open-source user intelligence tool
:::1552	telegram-similar-channels	Social Media	telegram-similar-channels	199	Python	https://github.com/SocialLinks-IO/telegram-similar-channels.git	Telegram similar channels search tool CLI + Maltego
:::1553	twayback	Social Media	twayback	195	Python	https://github.com/humandecoded/twayback.git	Automate downloading archived deleted Tweets
:::1554	all-in-one-bot	Social Media	all-in-one-bot	182	Go	https://github.com/uerax/all-in-one-bot.git	A Telegram-based DeFi tool for real-time on-chain data analysis, smart money tracking, and automated trade mon
:::1555	stocklook	Social Media	stocklook	174	Python	https://github.com/zbarge/stocklook.git	crypto currency library for trading market making bots, account management, and data analysis
:::1556	tw1tter0s1nt	Social Media	tw1tter0s1nt	174	Python	https://github.com/falkensmz/tw1tter0s1nt.git	Python tool that automates the process of Twitter OSiNT investigation using twint
:::1557	ig-osi	Social Media	ig.osi	171	Python	https://github.com/SulimanHacker1/ig.osi.git	Information Gathering Instagram Tool
:::1558	youtube-geofind	Social Media	youtube-geofind	160	JavaScript	https://github.com/mattwright324/youtube-geofind.git	Web-tool to search YouTube for geographically tagged videos by channel, topic, and location. Videos are viewab
:::1559	maigret-tg-bot	Social Media	maigret-tg-bot	160	Python	https://github.com/soxoj/maigret-tg-bot.git	Maigret Telegram bot
:::1560	ig-detective	Social Media	IG-Detective	157	Python	https://github.com/shredzwho/IG-Detective.git	OSINT tool researched and designed to hunt down IG handles
:::1561	hostagram	Social Media	hostagram	144	Python	https://github.com/banaxou/hostagram.git	hostagram osint tool Instagram hostagram
:::1562	tiktok-osint	Social Media	TikTok-OSINT	134	Python	https://github.com/akrambak/TikTok-OSINT.git	TikTok Social Media Open Source Intellegence Tool
:::1563	ig-followersbotzz	Social Media	ig-followersbotzz	122	Shell	https://github.com/DRACULA-HACK/ig-followersbotzz.git	insta-follow-botz . Instagram hacks bot with instagram report ,followers , information gathering , instagram h
:::1564	socmintelligence	Social Media	SOCMIntelligence	116	-	https://github.com/CScorza/SOCMIntelligence.git	Identificazione profili, relazioni, organizzazioni e tracciare reti
:::1565	insto	Social Media	insto	116	Python	https://github.com/subzeroid/insto.git	Interactive Instagram OSINT CLI with pluggable HikerAPI and aiograpi backends
:::1566	unseen	Social Media	Unseen	111	Python	https://github.com/amanverasia/Unseen.git	To perform OSINT on an instagram profile
:::1567	telegram-osint-for-cyber-threat-intellig	Social Media	Telegram-OSINT-for-Cyber-Threat-Intellig	108	Python	https://github.com/kienmarkdo/Telegram-OSINT-for-Cyber-Threat-Intelligence-Analysis.git	An OSINT tool tailored for comprehensive collection, analysis, and interpretation of cyber threat intelligence
:::1568	instatracker	Social Media	instatracker	105	Python	https://github.com/ibnaleem/instatracker.git	an Instagram tracking script that logs any changes to an Instagram account followers, following, posts, and b
:::1569	tik-spyder	Social Media	tik-spyder	102	Python	https://github.com/estebanpdl/tik-spyder.git	A Python command-line tool designed to collect TikTok data using SerpAPI for Google search results and Apify f
:::1570	v1ew-s0urce	Social Media	v1ew-s0urce	91	Python	https://github.com/CRO-THEHACKER/v1ew-s0urce.git	v1ew-s0urce a recon tool built by the 5/9Dark team
:::1571	igsearch-osint	Social Media	igsearch-osint	78	Python	https://github.com/malek10xdev/igsearch-osint.git	isearch is an OSINT tool on Instagram. Offers a face recognition reverse image search on Instagram profile fee
:::1572	whomrx666-osintgram	Social Media	osintgram	73	Python	https://github.com/Whomrx666/osintgram.git	This is a tool for searching or osint on Instagram to find target information
:::1573	instahunter	Social Media	instahunter	72	Python	https://github.com/shashwatah/instahunter.git	CLI OSINT app that can fetch data from Instagram's Web API without authentication
:::1574	ig-osint	Social Media	IG-OSINT	72	Python	https://github.com/t0mxplo1t/IG-OSINT.git	Simple OSINT Tool for Instagram
:::1575	jdvrif	Social Media	jdvrif	72	C++	https://github.com/CleasbyCode/jdvrif.git	Steganography Tool for JPG Images
:::1576	osinttube	Social Media	OsintTube	71	Python	https://github.com/SamueleAmato/OsintTube.git	An Easy-to-Use YouTube OSINT Tool
:::1577	linkdtime	Social Media	LinkdTime	70	Python	https://github.com/Lucksi/LinkdTime.git	A Linkedin Activity date Finder
:::1578	twintelligence	Social Media	Twintelligence	50	HTML	https://github.com/jipegit/Twintelligence.git	Twintelligence is a free Twitter OSINT tool
:::1579	tweetfeed_code	Social Media	TweetFeed_code	49	Python	https://github.com/0xDanielLopez/TweetFeed_code.git	Source code used at TweetFeed.live
:::1580	osint-tool-for-tg	Social Media	OSINT-Tool-For-TG	33	JavaScript	https://github.com/Flintgliboom/OSINT-Tool-For-TG.git	OSINT Telegram
:::1581	nextkool-osintgram	Social Media	Osintgram	33	Python	https://github.com/NextKool/Osintgram.git	Osintgram is a OSINT tool on Instagram
:::1582	osintgram2	Social Media	Osintgram2	29	Python	https://github.com/EchterAlsFake/Osintgram2.git	A tool to get OSINT information from an Instagram Account
:::1583	astra-bot	Social Media	Astra-Bot	29	Python	https://github.com/hac01/Astra-Bot.git	Python based Discord bot Which allows you to run tools like nmap and amass from discord
:::1584	instarecon	Social Media	InstaRecon	25	Python	https://github.com/Faizee-Asad/InstaRecon.git	Professional Instagram OSINT tool for penetration testing and security research. Gather public information eth
:::1585	create_word_cloud	Social Media	create_word_cloud	25	Python	https://github.com/rsharifnasab/create_word_cloud.git	create word clouds with wrodcloud-fa for twitter and telegram chat
:::1586	social-media-checker	Social Media	Social-Media-Checker	22	-	https://github.com/OSINT-Trace/Social-Media-Checker.git	Enterprise multi-platform OSINT API to verify identifier existence extract rich profile intelligence across Go
:::1587	verifytweet	Social Media	verifytweet	20	Python	https://github.com/preetham/verifytweet.git	Verify Tweet from Image
:::1588	osintgramcxx	Social Media	OsintgramCXX	16	C++	https://github.com/BC100Dev/OsintgramCXX.git	A reimplementation of Osintgram, but in C++
:::1589	twitter-media-downloader	Social Media	twitter-media-downloader	16	Python	https://github.com/11philip22/twitter-media-downloader.git	downloads photos and videos from twitter
:::1590	twitark	Social Media	Twitark	13	JavaScript	https://github.com/pantchox/Twitark.git	Archive the Twitter sample firehose and daily trends
:::1591	inscrape	Social Media	InScrape	13	Python	https://github.com/rohmadhidayah/InScrape.git	Instagram information gathering
:::1592	twint_server	Social Media	twint_server	12	Python	https://github.com/Nedja995/twint_server.git	TWINT Flask-Celery Server. Optimized tweets scraping
:::1593	osintworkstation	Social Media	OSINTWorkstation	11	Shell	https://github.com/CScorza/OSINTWorkstation.git	Configurazione di una postazione per OSINT
:::1594	yashhaxinc-osintgram	Social Media	Osintgram	10	Python	https://github.com/yashhaxinc/Osintgram.git	Instagram OSINT Open Source Information  Gathering Tool
:::1595	easytwitterapi	Social Media	EasyTwitterAPI	9	Python	https://github.com/psanch21/EasyTwitterAPI.git	A wrapper for the Twitter API that also integrates twint for some queries. Results can be stored in local usin
:::1596	hey	Social Media	Hey	8	-	https://github.com/BanHammer66/Hey.git	GHunt es una herramienta de OSINT para extraer informacin de cualquier cuenta de Google mediante un correo ele
:::1597	twintel	Social Media	twintel	7	Python	https://github.com/mikkokotila/twintel.git	Twitter data for signals intelligence
:::1598	scrape-twitter-json-to-html-table	Social Media	scrape-twitter-json-to-html-table	7	Python	https://github.com/androiddevnotesyoutube/scrape-twitter-json-to-html-table.git	This script shows how to scrape your tweets by date or year using the opensource project Twint and turn it int
:::1599	linkedin_spider	Social Media	Linkedin_spider	6	Python	https://github.com/MikeLarch/Linkedin_spider.git	Module for recon-ng used to harvest contacts unauthenticated on linkedin
:::1600	twintrest	Social Media	twintrest	5	Python	https://github.com/moorescloud/twintrest.git	Simple Twitter sentiment analysis and visualization for Holiday by MooresCloud
:::1601	twitter_scraping_tool	Social Media	twitter_scraping_tool	5	Python	https://github.com/akshayuppal3/twitter_scraping_tool.git	A scraping tool based on tweepy module
:::1602	instagram-archive-metadata	Social Media	instagram-archive-metadata	5	Python	https://github.com/tomshafer/instagram-archive-metadata.git	Attach Exif metadata to an Instagram downloadable archive for import into a photo manager
:::1603	twint-server	Social Media	twint-server	4	Python	https://github.com/fx-ha/twint-server.git	Unofficial Twitter API
:::1604	argh	Social Media	argh	4	Python	https://github.com/i-infra/argh.git	Augmented Reality Gaming Helper. Be brave, be bold, say ARGH
:::1605	python-flask-twitter-scraper	Social Media	Python-Flask-Twitter-Scraper	4	Python	https://github.com/Charlie-Hill/Python-Flask-Twitter-Scraper.git	A very basic Flask HTTP API that uses the Twint library to fetch tweets from a specific query and returns resu
:::1606	aashay-shah-spiderfoot	Social Media	Spiderfoot	3	Python	https://github.com/aashay-shah/Spiderfoot.git	Open Source Intelligent Tool which scraps all the openly available information of GitHub, Instagram and Reddit
:::1607	twitter-scraper	Social Media	Twitter-Scraper	3	Python	https://github.com/yusufarist/Twitter-Scraper.git	Some Modules for scraping on Twitter either use the API or not
:::1608	twitterscraper-labhd	Social Media	twitterscraper-LABHD	2	Python	https://github.com/ericbrasiln/twitterscraper-LABHD.git	Cdigo para raspagem de dados do Twitter usando a biblioteca twint
:::1609	twitter-scrapper-twint	Social Media	twitter-scrapper-twint	2	-	https://github.com/bushmusi/twitter-scrapper-twint.git	Twint is unofficial twitter scrapper
:::1610	twinter	Social Media	twinter	2	-	https://github.com/JawarLab/twinter.git	Clon de twitter
:::1611	pytwintel	Social Media	pyTwintel	2	Python	https://github.com/doctorparadox/pyTwintel.git	Basic Twitter research tools
:::1612	twint_api	Social Media	Twint_API	2	Go	https://github.com/PG-Insights/Twint_API.git	Python app for obtaining twitter information using the Twint-Zero program
:::1613	twtoo	Social Media	twtoo	2	Python	https://github.com/153/twtoo.git	twitter -- mastodon
:::1614	twitter_news_data	Social Media	twitter_news_data	2	Python	https://github.com/HegdeChaitra/twitter_news_data.git	Scraping tweets and articles from news twitter handles. Can be used for teaser generation and news headline ge
:::1615	notredame	Social Media	notredame	2	JavaScript	https://github.com/natashaannn/notredame.git	Todays fire at Notre Dame Cathedral incited a culture war on social media with some users mourning an irreplac
:::1616	fbdupesfindr	Social Media	fbDupesFindr	1	Shell	https://github.com/paucabral/fbDupesFindr.git	This is a derivative of @linux_choice's userrecon. This script will list up to 10000 duplicate accounts based 
:::1617	runeeex-osintgram	Social Media	Osintgram	1	-	https://github.com/runeeex/Osintgram.git	Instagram About
:::1618	readloud-osintgram	Social Media	Osintgram	1	Python	https://github.com/readloud/Osintgram.git	**OSINT** tool on Instagram to collect, analyze, and run reconnaissance
:::1619	cat00789-osintgram	Social Media	Osintgram	1	Python	https://github.com/Cat00789/Osintgram.git	Osintgram is a OSINT tool on Instagram to collect, analyze, and run reconnaissance
:::1620	satyampathania-osintgram	Social Media	OSINTgram	1	Python	https://github.com/Satyampathania/OSINTgram.git	A Python-based Instagram OSINT tool for gathering publicly available data from Instagram profiles. Fetch profi
:::1621	eyosiyas8-twitter-scraper	Social Media	twitter-scraper	1	Python	https://github.com/Eyosiyas8/twitter-scraper.git	The twint api
:::1622	nestscraper	Social Media	NestScraper	1	Shell	https://github.com/dariojw98/NestScraper.git	Twint Tool for scraping twitter
:::1623	beautifultwint	Social Media	beautifultwint	1	Python	https://github.com/vivekteega/beautifultwint.git	Visualization for Twitter data scraped with Twint
:::1624	chatgp-sentiment-twitter	Social Media	chatgp-sentiment-twitter	1	-	https://github.com/zhikri/chatgp-sentiment-twitter.git	Sentimen analisis ChatGPT dengan menggunakan twint tool sebagai crawler
:::1625	saurabhsri108-twinter	Social Media	twinter	1	TypeScript	https://github.com/saurabhsri108/twinter.git	MVP for product idea where twitter followers get NFT
:::1626	twint-zero-research	Social Media	twint-zero-research	1	Go	https://github.com/mirekjames/twint-zero-research.git	Clone of twint-zero, edited for academic research purposes by Mirek Stolee
:::1627	botdetection	Social Media	BotDetection	1	Python	https://github.com/fabiands97/BotDetection.git	Give percentage to some Twitter Bots using Twint Library
:::1628	whege-twinter	Social Media	Twinter	1	Python	https://github.com/whege/Twinter.git	Create a model to tweet in the style of any valid/public Twitter account
:::1629	lhernandez0-twitter-scraper	Social Media	Twitter-Scraper	1	Python	https://github.com/lhernandez0/Twitter-Scraper.git	A twitter scraper utilizing Twint and the Twitter API for lead generation and data collection
:::1630	twitter_grabber	Social Media	twitter_grabber	1	Python	https://github.com/jonwchapman/twitter_grabber.git	Using Twint module to grab twitter data, then processing it for storage in MariaDB. Spawns multiple threads to
:::1631	stats-twitter-geotribu	Social Media	stats-twitter-geotribu	1	Python	https://github.com/geotribu/stats-twitter-geotribu.git	Scripts de scrap de donnes Twitter sur GeoTribu, ainsi que de visualisations de ces donnes, via Twint, Pandas 
:::1632	twitter-opinion-mining	Social Media	Twitter-Opinion-Mining	1	JavaScript	https://github.com/azizurrehman0432/Twitter-Opinion-Mining.git	real time keyword based opinion mining of tweets using Twint, BERT, backend is build on Django, a GUI html, c
:::1633	twitter-sentiment-analysis-odl	Social Media	Twitter-Sentiment-Analysis-ODL	1	-	https://github.com/haikalfitri/Twitter-Sentiment-Analysis-ODL.git	This repository contains the code and data for a Twitter sentiment analysis project on issues related to open 
:::1634	bdhsc-2021_poster-presentation	Social Media	BDHSC-2021_Poster-Presentation	1	-	https://github.com/AVINEET-Singh/BDHSC-2021_Poster-Presentation.git	Poster Presentation on the topic Exploring Substance Use Disorder SUD Patterns on Twitter Before and During 
:::1635	tweenspector	Social Media	tweenspector	1	Python	https://github.com/DamianBisewski/tweenspector.git	TweeNspector is a Twitter analyzer written in Python. It enables searching for most frequently used words, int
:::1636	mert999-security-osintgram	Social Media	Osintgram	0	-	https://github.com/mert999-security/Osintgram.git	Instagram osint
:::1637	osintgram-1	Social Media	osintgram-1	0	-	https://github.com/akbarazimifar/osintgram-1.git	Open Source Intelligent Instagram tools
:::1638	osintgram-lite-osintgram-educational-osi	Social Media	osintgram-lite-osintgram-educational-osi	0	-	https://github.com/amiramoli/osintgram-lite-osintgram-educational-osintgram-persian-edition.git	A simplified educational fork of Osintgram for learning OSINT techniques on Instagram using Python
:::1639	deadkennedyx-osintgram	Social Media	osintgram	0	Python	https://github.com/DeadKennedyx/osintgram.git	Tool to search for basic instagram queries for user and locations
:::1640	malaidev-osintgram	Social Media	Osintgram	0	Python	https://github.com/malaidev/Osintgram.git	Osintgram is a OSINT tool on Instagram to collect, analyze, and run reconnaissance
:::1641	osintgram_like_v2-py	Social Media	osintgram_like_v2.py	0	-	https://github.com/Nitindbg/osintgram_like_v2.py.git	Usage Instagram  @ : info: posts: bio_parse: / email_guess: + phone_search: Google sherlock: exit:
:::1642	instaosint	Social Media	instaosint	0	Python	https://github.com/MustafaRajihAli/instaosint.git	Interactive OSINT shell for public Instagram profiles - instaloader-based rebuild of the Osintgram idea, with 
:::1643	twitter-scrapeing-with-twint	Social Media	Twitter-scrapeing-with-TWINT	0	Python	https://github.com/rylanristia/Twitter-scrapeing-with-TWINT.git	Twint twitter scapring
:::1644	backend-twitter-scraping	Social Media	backend-twitter-scraping	0	Python	https://github.com/moransk8/backend-twitter-scraping.git	Twitter Scraping using Twint
:::1645	data-acquisition-project-using-twitter-a	Social Media	Data-Acquisition-Project--Using-Twitter-	0	-	https://github.com/cadancai/Data-Acquisition-Project--Using-Twitter-APIs-to-Collect-Tweets.git	In this project our team collected tweets about earthquake from twitter using search api and married the tweet
:::1646	google-images	Media / Metadata	Google-Images	899996	web	https://images.google.com/	Reverse image search - huge web coverage, limited face matching visually similar.
:::1647	tineye	Media / Metadata	TinEye	899995	web	https://tineye.com/	Original reverse image search - trace where an exact photo first appeared.
:::1648	omniparse	Media / Metadata	omniparse	7931	Python	https://github.com/adithya-s-k/omniparse.git	Ingest, parse, and optimize any data format from documents to multimedia for enhanced compatibility with GenAI
:::1649	remove-ai-watermarks	Media / Metadata	remove-ai-watermarks	5610	Python	https://github.com/wiltodelta/remove-ai-watermarks.git	Remove visible and invisible AI watermarks and provenance metadata from images and video. Python library and C
:::1650	exiftool	Media / Metadata	exiftool	5072	Perl	https://github.com/exiftool/exiftool.git	ExifTool meta information reader/writer
:::1651	geemap	Media / Metadata	geemap	4030	Python	https://github.com/gee-community/geemap.git	A Python package for interactive geospatial analysis and visualization with Google Earth Engine
:::1652	metadata-extractor	Media / Metadata	metadata-extractor	2832	Java	https://github.com/drewnoakes/metadata-extractor.git	Extracts Exif, IPTC, XMP, ICC and other metadata from image, video and audio files
:::1653	exifcleaner	Media / Metadata	exifcleaner	2695	TypeScript	https://github.com/szTheory/exifcleaner.git	Cross-platform desktop GUI app to clean image metadata
:::1654	photogrammetry-guide	Media / Metadata	Photogrammetry-Guide	1524	Python	https://github.com/mikeroyal/Photogrammetry-Guide.git	Photogrammetry Guide. Photogrammetry is widely used for Aerial surveying, Agriculture, Architecture, 3D Games,
:::1655	laramies-metagoofil	Media / Metadata	metagoofil	1320	Python	https://github.com/laramies/metagoofil.git	Metadata harvester
:::1656	exifr	Media / Metadata	exifr	1249	JavaScript	https://github.com/MikeKovarik/exifr.git	The fastest and most versatile JS EXIF reading library
:::1657	grass	Media / Metadata	grass	1165	C	https://github.com/OSGeo/grass.git	GRASS - free and open-source geospatial processing engine
:::1658	google-photos-exif	Media / Metadata	google-photos-exif	1095	TypeScript	https://github.com/mattwilson1024/google-photos-exif.git	A tool to populate missing DateTimeOriginal EXIF metadata in Google Photos takeout, using Google's JSON metada
:::1659	metadata-extractor-dotnet	Media / Metadata	metadata-extractor-dotnet	1071	C#	https://github.com/drewnoakes/metadata-extractor-dotnet.git	Extracts Exif, IPTC, XMP, ICC and other metadata from image, video and audio files
:::1660	exif-py	Media / Metadata	exif-py	969	Python	https://github.com/ianare/exif-py.git	Easy to use Python module to extract Exif metadata from digital image files
:::1661	bugbountyscanner	Media / Metadata	BugBountyScanner	924	Shell	https://github.com/chvancooten/BugBountyScanner.git	A Bash script and Docker image for Bug Bounty reconnaissance. Intended for headless use
:::1662	stegoforge	Media / Metadata	StegoForge	592	Python	https://github.com/Nour833/StegoForge.git	The ultimate steganography and digital forensics toolkit. Hide and extract data across images, audio, video, d
:::1663	gopro-dashboard-overlay	Media / Metadata	gopro-dashboard-overlay	588	Python	https://github.com/time4tea/gopro-dashboard-overlay.git	Programs to process GoPro MP4 Generic GPX/FIT files and create video dashboards maps
:::1664	exiftool-vendored-js	Media / Metadata	exiftool-vendored.js	557	TypeScript	https://github.com/photostructure/exiftool-vendored.js.git	Fast, cross-platform Node.js access to ExifTool
:::1665	seqbox	Media / Metadata	SeqBox	555	Python	https://github.com/MarcoPon/SeqBox.git	A single file container/archive that can be reconstructed even after total loss of file system structures
:::1666	adtimeline	Media / Metadata	ADTimeline	535	PowerShell	https://github.com/ANSSI-FR/ADTimeline.git	Timeline of Active Directory changes with replication metadata
:::1667	arkhammirror	Media / Metadata	ArkhamMirror	490	Python	https://github.com/mantisfury/ArkhamMirror.git	Local-first AI-powered document intelligence platform for investigative journalism
:::1668	imageindexer	Media / Metadata	ImageIndexer	395	Python	https://github.com/jabberjabberjabber/ImageIndexer.git	Creates an index of images, queries a local LLM and adds tags to the image metadata
:::1669	libexif	Media / Metadata	libexif	376	C	https://github.com/libexif/libexif.git	A library for parsing, editing, and saving EXIF data
:::1670	whatsosint	Media / Metadata	WhatsOSINT	353	Python	https://github.com/HackUnderway/WhatsOSINT.git	View data of a WhatsApp number, including its status, photo, etc
:::1671	goca	Media / Metadata	goca	330	Go	https://github.com/gocaio/goca.git	Goca Scanner
:::1672	ossim	Media / Metadata	ossim	329	C++	https://github.com/ossimlabs/ossim.git	Core OSSIM Open Source Software Image Map package including C++ code for OSSIM library, command-line applica
:::1673	cat-net	Media / Metadata	CAT-Net	316	Python	https://github.com/mjkwon2021/CAT-Net.git	Official code for CAT-Net: Compression Artifact Tracing Network. Image manipulation detection and localization
:::1674	nightingale	Media / Metadata	Nightingale	313	Shell	https://github.com/RAJANAGORI/Nightingale.git	Nightingale Docker for Pentesters is a comprehensive Dockerized environment tailored for penetration testing a
:::1675	exifer	Media / Metadata	exifer	312	JavaScript	https://github.com/terkelg/exifer.git	A lightweight Exif meta-data decipher
:::1676	spotifyscraper	Media / Metadata	SpotifyScraper	305	Python	https://github.com/AliAkhtari78/SpotifyScraper.git	Extract public Spotify data tracks, albums, artists, playlists, podcasts lyrics without the official API. Sync
:::1677	exifglass	Media / Metadata	ExifGlass	303	C#	https://github.com/d2phap/ExifGlass.git	Cross-platform EXIF metadata viewing tool
:::1678	extractnet	Media / Metadata	extractnet	300	HTML	https://github.com/currentslab/extractnet.git	A fork of Dragnet that also extract author, headline, date, keywords from context, as well as built in metadat
:::1679	go-exiftool	Media / Metadata	go-exiftool	299	Go	https://github.com/barasher/go-exiftool.git	Golang wrapper for Exiftool : extract as much metadata as possible EXIF, ... from files pictures, pdf, offi
:::1680	jhead	Media / Metadata	jhead	261	C	https://github.com/Matthias-Wandel/jhead.git	Command line program to display and manipupate Exif headers of jpeg files, written in C
:::1681	pyexiv2	Media / Metadata	pyexiv2	247	Python	https://github.com/LeoHsiao1/pyexiv2.git	A Python library for reading and writing image metadata, including EXIF, IPTC, XMP, ICC Profile
:::1682	phishingkithunter	Media / Metadata	PhishingKitHunter	243	Python	https://github.com/t4d/PhishingKitHunter.git	Find phishing kits which use your brand/organization's files and image
:::1683	sharelint	Media / Metadata	sharelint	239	Python	https://github.com/jasonzhang06-source/sharelint.git	Local privacy preflight for files, folders, and archivescatch secrets, PII, metadata, and hidden document cont
:::1684	paperscraper	Media / Metadata	PaperScraper	232	Python	https://github.com/NLPatVCU/PaperScraper.git	A web scraping tool to systematically extract the text of scientific papers and corresponding metadata from un
:::1685	imagemeta	Media / Metadata	imagemeta	177	Go	https://github.com/evanoberholster/imagemeta.git	Image Metadata Exif and XMP extraction for JPEG, HEIC, AVIF, TIFF and Camera Raw in golang. Focus is on prov
:::1686	googletakeoutfixer	Media / Metadata	GoogleTakeoutFixer	175	Go	https://github.com/feloex/GoogleTakeoutFixer.git	A tool to easily clean and organize Google Photos Takeout exports
:::1687	photo-metadata-editor	Media / Metadata	photo-metadata-editor	164	Python	https://github.com/NextWeb4/photo-metadata-editor.git	Windows desktop EXIF/XMP/IPTC photo metadata editor powered by ExifTool
:::1688	metadata-remover	Media / Metadata	Metadata-Remover	129	Python	https://github.com/Anish-M-code/Metadata-Remover.git	A simple Metadata Removal Tool for images and videos using exiftool and ffmpeg in C and Python3
:::1689	nom-exif	Media / Metadata	nom-exif	123	Rust	https://github.com/mindeng/nom-exif.git	Exif/metadata parsing library written in pure Rust, both image JPEG, PNG, WebP, HEIC/HEIF, AVIF, TIFF, Phase 
:::1690	capncook	Media / Metadata	capNcook	123	HTML	https://github.com/zuzke/capNcook.git	capNcook - a dark web exploration tool
:::1691	intelhub	Media / Metadata	IntelHub	121	JavaScript	https://github.com/tomsec8/IntelHub.git	A modern and intuitive Chrome extension that brings your favorite OSINT tools, metadata analyzers, and Google 
:::1692	exif-frame	Media / Metadata	exif-frame	120	TypeScript	https://github.com/jeonghyeon-net/exif-frame.git	with EXIF metadata
:::1693	picarta-api	Media / Metadata	Picarta-API	93	-	https://github.com/PicartaAI/Picarta-API.git	Picarta AI Image Geolocalization API
:::1694	provenance	Media / Metadata	Provenance	91	TypeScript	https://github.com/011-sam-110/Provenance.git	Governments, space agencies, seismologists and UN clusters publish an enormous amount of live data for free, i
:::1695	6over3-exiftool	Media / Metadata	exiftool	90	TypeScript	https://github.com/6over3/exiftool.git	ExifTool powered by WebAssembly to extract metadata from files in browsers and Node.js environments using zero
:::1696	rexiv2	Media / Metadata	rexiv2	88	Rust	https://github.com/felixc/rexiv2.git	Rust library for read/write access to media-file metadata Exif, XMP, and IPTC
:::1697	nathanpeck-exiftool	Media / Metadata	exiftool	83	JavaScript	https://github.com/nathanpeck/exiftool.git	A Node.js wrapper around exiftool, providing metadata extraction from numerous audio, video, document, and bin
:::1698	exiftool-commands	Media / Metadata	Exiftool-Commands	79	-	https://github.com/jonkeren/Exiftool-Commands.git	Several Exiftool commands I have used to edit/sort my pictures and improve metadata
:::1699	go-xmp	Media / Metadata	go-xmp	69	Go	https://github.com/trimmer-io/go-xmp.git	A native Go SDK for the Extensible Metadata Platform XMP
:::1700	photosint	Media / Metadata	photosint	62	JavaScript	https://github.com/Haris87/photosint.git	PhotOSINT is an OSINT chrome extension for images and photos. It scans each webpage for images with EXIF data,
:::1701	exif	Media / Metadata	Exif	61	HTML	https://github.com/AryanVBW/Exif.git	ExifTool is a powerful command-line tool that can be used to extract and edit metadata in a wide range of medi
:::1702	plugin-maui-exif	Media / Metadata	Plugin.Maui.Exif	56	C#	https://github.com/jfversluis/Plugin.Maui.Exif.git	Plugin.Maui.Exif provides the ability to read EXIF metadata from image files in your .NET MAUI application
:::1703	iptcinfo3	Media / Metadata	iptcinfo3	56	Python	https://github.com/james-see/iptcinfo3.git	iptcinfo working for python 3 finally do pip3 install iptcinfo3
:::1704	exif-viewer	Media / Metadata	exif-viewer	54	JavaScript	https://github.com/ternera/exif-viewer.git	A browser extension to display EXIF data of images directly on web pages
:::1705	xxd-strip-ai-meta	Media / Metadata	xxd-strip-ai-meta	45	Python	https://github.com/nevertoday/xxd-strip-ai-meta.git	Batch-remove AI provenance and image metadata with ExifTool. CLI + Agent Skill, preserving pixel data
:::1706	amass-annotate-image	Media / Metadata	amass-annotate-image	35	JavaScript	https://github.com/ssaket/amass-annotate-image.git	A tool to quickly Search and Annotate images online from multiple sources. Built with using React
:::1707	multi_exiftool	Media / Metadata	multi_exiftool	32	Ruby	https://github.com/janfri/multi_exiftool.git	This library is my new approach of a wrapper for the Exiftool command-line application https://exiftool.org 
:::1708	exiftool_php_stayopen	Media / Metadata	ExifTool_PHP_Stayopen	31	PHP	https://github.com/tsmgeek/ExifTool_PHP_Stayopen.git	PHP ultra-fast library to allow accessing the excellent ExifTool http://www.sno.phy.queensu.ca/~phil/exiftool
:::1709	rmetashell	Media / Metadata	rMETAshell	31	Shell	https://github.com/git5loxosec/rMETAshell.git	rMETAshell takes a shell command and an image, video or text file as input. It then injects the command into t
:::1710	google-photos-takeout-sh	Media / Metadata	google-photos-takeout.sh	28	Shell	https://github.com/Zaczero/google-photos-takeout.sh.git	Fixes Google Photos Takeout metadata
:::1711	geotag2kml	Media / Metadata	geotag2kml	28	Python	https://github.com/forensenellanebbia/geotag2kml.git	Creates a Google Earth .KML file from geotagged photos/videos
:::1712	open-vbrowser	Media / Metadata	open-vbrowser	25	TypeScript	https://github.com/fish-not-phish/open-vbrowser.git	vBrowser is a secure, containerized browser platform designed for covert web investigations. Originally create
:::1713	exiftool-rs	Media / Metadata	exiftool-rs	25	Rust	https://github.com/Le-Syl21/exiftool-rs.git	Pure Rust reimplementation of ExifTool 13.59 with 100 pct tag parity: read, write and edit EXIF, XMP, IPTC and
:::1714	autofile	Media / Metadata	autofile	25	Python	https://github.com/RhetTbull/autofile.git	Mac command line app to automatically move or copy files based on metadata associated with the files. For exam
:::1715	soypat-exif	Media / Metadata	exif	23	Go	https://github.com/soypat/exif.git	Dead simple exchangeable image file format tools for Go optimized for large image files using lazy loading
:::1716	pdf-meta-editor	Media / Metadata	pdf-meta-editor	22	JavaScript	https://github.com/Scriptim/pdf-meta-editor.git	Interactive cli for changing metadata of pdf files
:::1717	metadata_reference	Media / Metadata	Metadata_Reference	17	-	https://github.com/StarGeekSpaceNerd/Metadata_Reference.git	Metadata reference of various programs/websites for use with exiftool
:::1718	phototags-synchronizer	Media / Metadata	PhotoTags-Synchronizer	16	C#	https://github.com/Nordlien/PhotoTags-Synchronizer.git	PhotoTags Synchronizer keeps your metadata tags where it belongs
:::1719	metadatazero	Media / Metadata	metadatazero	16	TypeScript	https://github.com/metadatazero/metadatazero.git	Remove metadata from your photos and documents
:::1720	dji_gpx_extractor	Media / Metadata	DJI_GPX_Extractor	15	Python	https://github.com/djexit/DJI_GPX_Extractor.git	Windows GUI tool for extracting DJI MP4/MOV telemetry metadata to GPX using ExifTool
:::1721	x-metadata	Media / Metadata	X-metadata	15	Python	https://github.com/Whomrx666/X-metadata.git	X-metadata is a tool for viewing complete metadata from an image or photo
:::1722	ai_provenance_scanner	Media / Metadata	AI_Provenance_Scanner	14	Python	https://github.com/abrignoni/AI_Provenance_Scanner.git	Script that uses exiftool and c2pa to identify metadata tags that indicate AI generation
:::1723	aaa_metadata_system	Media / Metadata	AAA_Metadata_System	14	Python	https://github.com/EricRollei/AAA_Metadata_System.git	Comprehensive metadata management for ComfyUI - multi-format support, smart merging, database storage, and wor
:::1724	metadata-editor	Media / Metadata	metadata-editor	13	Perl	https://github.com/lunu-bounir/metadata-editor.git	a browser extension to show medata of files based on ExifTool
:::1725	go-out	Media / Metadata	go-out	13	Go	https://github.com/xob0t/go-out.git	Merge Google Photos json metadata into media files
:::1726	metadata	Media / Metadata	metadata	12	JavaScript	https://github.com/anasshakil/metadata.git	An advanced Node.js plug-and-play interface to the Exiftool CLI
:::1727	java-exif-remover	Media / Metadata	java-exif-remover	12	Java	https://github.com/FlorianDe/java-exif-remover.git	A small java based program to delete EXIF metadata from images
:::1728	flickr-meta-export	Media / Metadata	flickr-meta-export	11	Python	https://github.com/nickivanov/flickr-meta-export.git	A tool to convert Flickr JSON metadata to CSV for use with ExifTool
:::1729	gopro-metadata	Media / Metadata	gopro-metadata	11	-	https://github.com/trek-view/gopro-metadata.git	GoPro 360 image and video metadata useful for understanding GoPro Photo EXIF and GoPro Video GPMF
:::1730	mattduffy-exiftool	Media / Metadata	exiftool	10	JavaScript	https://github.com/mattduffy/exiftool.git	A Node.js package wrapping the incredible exiftool created by Phil Harvey
:::1731	geoint-completed-task	Media / Metadata	geoint-completed-task	8	-	https://github.com/NovaCode37/geoint-completed-task.git	Solved OSINT Exercise #005 geolocated polar bears from a zoo live cam to exact GPS coordinates using reverse i
:::1732	oxidex	Media / Metadata	oxidex	8	Rust	https://github.com/swack-tools/oxidex.git	Replicates exiftool but in rust, with some additional features
:::1733	exiftoolgui	Media / Metadata	exiftoolgui	8	Python	https://github.com/psyb0t/exiftoolgui.git	The badass desktop wizard for digital anarchists and cybernauts who want to manipulate EXIF data like a boss. 
:::1734	sharpexiftool	Media / Metadata	SharpExifTool	8	C#	https://github.com/junian/SharpExifTool.git	ExifTool CLI Wrapper in C#. Tested on Windows and macOS
:::1735	fotopreprocessor	Media / Metadata	FotoPreProcessor	8	Python	https://github.com/FrankAbelbeck/FotoPreProcessor.git	FotoPreProcessor FPP is a PyQt4-based frontend for exiftool and allows to graphically edit the EXIF metada
:::1736	metascout	Media / Metadata	MetaScout	8	Python	https://github.com/gorkemguler/MetaScout.git	Open-source, cross-platform document discovery metadata reconnaissance tool a modern, Windows-free alternative
:::1737	fckexif	Media / Metadata	fckExif	8	JavaScript	https://github.com/datwalkerv/fckExif.git	Extract remove exif data from images
:::1738	media-curator	Media / Metadata	media-curator	8	TypeScript	https://github.com/SylphxAI/media-curator.git	Intelligently organizes and deduplicates large digital photo and video collections using metadata and content 
:::1739	metashell	Media / Metadata	METAshell	8	-	https://github.com/git5loxosec/METAshell.git	rMETAshell takes a shell command and an image, video or text file as input. It then injects the command into t
:::1740	burpexiftoolscanner	Media / Metadata	BurpExifToolScanner	7	Java	https://github.com/LogicalTrust/BurpExifToolScanner.git	Burp extension, reads metadata using ExifTool
:::1741	rusty-exif	Media / Metadata	rusty-exif	7	Rust	https://github.com/i5-650/rusty-exif.git	A simple sketchy rust program to export exif into json file
:::1742	exif-api	Media / Metadata	exif-api	6	Ruby	https://github.com/ggouzi/exif-api.git	REST API that provides tools to extract/edit EXIF metadata
:::1743	photo-metadata	Media / Metadata	photo-metadata	6	Python	https://github.com/kingyo1205/photo-metadata.git	Python library to extract, read, modify, and write photo and video metadata EXIF, IPTC, XMP using ExifTool. 
:::1744	exif-extraction	Media / Metadata	exif-extraction	6	-	https://github.com/crypto-cypher/exif-extraction.git	Techniques for extracting metadata from files sorting it into a spreadsheet using exiftool
:::1745	photosec	Media / Metadata	PhotoSec	6	Python	https://github.com/jeremylaratro/PhotoSec.git	A security-oriented Python script with bulk image analysis and security features such as metadata scrubbing, i
:::1746	aigc-tag-tool	Media / Metadata	aigc-tag-tool	6	Python	https://github.com/AIPlayerDayu/aigc-tag-tool.git	AIGC macOS / AI AIGCGB 45438-2025
:::1747	snapchat-memories-organizer	Media / Metadata	snapchat-memories-organizer	6	Python	https://github.com/annsopirate/snapchat-memories-organizer.git	A complete toolkit to organize downloaded Snapchat Memories. Includes scripts to fix metadata Exif, sort fil
:::1748	snap-memories-processor	Media / Metadata	snap-memories-processor	6	Go	https://github.com/EliasLd/snap-memories-processor.git	Easily Process all your exported snapchat memories. Conserving overlays, timestamps and locations
:::1749	screenscrub	Media / Metadata	screenscrub	6	Go	https://github.com/Adversis/screenscrub.git	Find credentials in screenshots, save them to your secret manager, and irreversibly redact them from the image
:::1750	image-metadata-viewer	Media / Metadata	image-metadata-viewer	5	HTML	https://github.com/JoseTomasTocino/image-metadata-viewer.git	Simple image metadata viewer based on ExifTool
:::1751	p-exiftool	Media / Metadata	p-exiftool	5	JavaScript	https://github.com/transitive-bullshit/p-exiftool.git	Wrapper around exiftool for reading metadata from many different file types
:::1752	3dsmaxmetadata	Media / Metadata	3dsMaxMetadata	5	PowerShell	https://github.com/akarcode/3dsMaxMetadata.git	This script utilizes ExifTool to read the Metadata from 3ds Max files
:::1753	fast-video-metadata	Media / Metadata	fast-video-metadata	5	TypeScript	https://github.com/titarenko/fast-video-metadata.git	Fast metadata extraction without dependencies e. g. usage of spawned ffmpeg, exiftool, etc
:::1754	aigcforge	Media / Metadata	AIGCForge	5	HTML	https://github.com/Daniel-wambua/AIGCForge.git	An OSINT metadata analysis framework that extracts and reports file metadata using ExifTool, with an added AI 
:::1755	leosetter	Media / Metadata	LeoSetter	5	Perl	https://github.com/AHJ32/LeoSetter.git	A lightweight, cross-platform metadata editor for images. Features batch applying, easy templating, and essent
:::1756	armv7-spiderfoot	Media / Metadata	armv7-spiderfoot	4	-	https://github.com/onty/armv7-spiderfoot.git	Spiderfoot docker image
:::1757	metadata_mapping_exif_data-475-2151_roja	Media / Metadata	Metadata_mapping_exif_data-475-2151_Roja	4	Python	https://github.com/ForensicTools/Metadata_mapping_exif_data-475-2151_Rojas_Schoenfeld.git	Mostly all pictures, videos, documents taken with a smartphone, or created with a computer will have metadata 
:::1758	exif_keywords_generator	Media / Metadata	exif_keywords_generator	4	Perl	https://github.com/dmitrypisanko/exif_keywords_generator.git	Generate keywords using Computer Vison API from Clarifai.com. Use exiftool for update metadata
:::1759	pigallery2-metadata-editor	Media / Metadata	pigallery2-metadata-editor	4	JavaScript	https://github.com/kagahd/pigallery2-metadata-editor.git	Web-based metadata editor for PiGallery2 to read/write XMP tags e.g. Favorite, Rating, Tags using ExifTool. 
:::1760	exifdb	Media / Metadata	exifdb	4	Python	https://github.com/karlicoss/exifdb.git	Keep EXIF and other metadata in a database and keep track of changes
:::1761	takeoutfix	Media / Metadata	takeoutfix	4	Go	https://github.com/vchilikov/takeoutfix.git	CLI tool to fix Google Photos Takeout exports: restore photo/video metadata and normalize filenames for easy m
:::1762	gphotos-takeout-organizer	Media / Metadata	gphotos-takeout-organizer	4	C#	https://github.com/itielbru/gphotos-takeout-organizer.git	Merge Google Photos Takeout metadata back into your photos correct dates, timezones, duplicates, and albums. W
:::1763	img-meta	Media / Metadata	img-meta	4	Python	https://github.com/themostjomo/img-meta.git	img-meta is a command-line tool that lets you view, edit, and strip metadata from image files EXIF data for J
:::1764	exiftools	Media / Metadata	exiftools	3	Go	https://github.com/evanoberholster/exiftools.git	Image Exif, MakerNote and XMP metadata tools in Golang
:::1765	victorhqc-fuji	Media / Metadata	fuji	3	Rust	https://github.com/victorhqc/fuji.git	Read Fujifilm Recipe Settings from EXIF using exiftool
:::1766	exiftool-mcp-server	Media / Metadata	exiftool-mcp-server	3	JavaScript	https://github.com/vgribok/exiftool-mcp-server.git	An MCP-compatible AI agent for retrieving EXIF metadata from photos and videos on the local file system
:::1767	integrating-aws-lambda-with-exiftool	Media / Metadata	Integrating-AWS-Lambda-With-EXIFTOOL	3	Python	https://github.com/voidrlm/Integrating-AWS-Lambda-With-EXIFTOOL.git	This repository provides a comprehensive guide and code examples for seamlessly integrating AWS Lambda with EX
:::1768	ansible-role-exiftool	Media / Metadata	ansible-role-exiftool	3	-	https://github.com/wtanaka/ansible-role-exiftool.git	Ansible role to install Exiftool
:::1769	amazon-adding-metadata-tag	Media / Metadata	amazon-adding-metadata-tag	3	JavaScript	https://github.com/khooyc/amazon-adding-metadata-tag.git	Local Windows/macOS app for safer Amazon image and video XMP tagging with face/body-assisted review
:::1770	picture_tool	Media / Metadata	picture_tool	3	PowerShell	https://github.com/flolilo/picture_tool.git	Batch-Convert pictures to JPEG and/or transfer/delete/add metadata using ImageMagick exiftool
:::1771	exif_banner	Media / Metadata	exif_banner	3	Shell	https://github.com/aprinjha/exif_banner.git	Generate clean EXIF Metadata overlays on your Professional Photographs
:::1772	exif_heist	Media / Metadata	EXIF_HEIST	3	Python	https://github.com/sharanthehunter/EXIF_HEIST.git	EXIF_HEIST runs exiftool to extract all metadata about an uploaded or internet-located object
:::1773	genealogy-filename-generator	Media / Metadata	genealogy-filename-generator	3	HTML	https://github.com/emaynard/genealogy-filename-generator.git	A specialized tool for genealogists to generate standardized filenames and metadata commands for genealogy doc
:::1774	metabridge	Media / Metadata	Metabridge	2	Shell	https://github.com/Disc0Ding0/Metabridge.git	A script that bridges the gap between metagoofil and exif tool to be used when searching the web for document 
:::1775	klepto	Media / Metadata	klepto	2	Shell	https://github.com/telekom-security/klepto.git	Klepto is a docker-image search tool, extraction and secrets searcher within found docker images
:::1776	container-guard	Media / Metadata	container-guard	2	Python	https://github.com/Aritpal15/container-guard.git	A lightweight FastAPI service providing container health and runtime metadata, built with non-root Docker secu
:::1777	instant-ngp-based-3d-reconstruction-usin	Media / Metadata	instant-ngp-based-3d-reconstruction-usin	1	Python	https://github.com/srijanpal07/instant-ngp-based-3d-reconstruction-using-autonomous-drone.git	Autonomous drone-based 3D reconstruction using object detection, COLMAP, and Instant-NGP for efficient high-fi
:::1778	manouchehri-metagoofil	Media / Metadata	metagoofil	1	Python	https://github.com/Manouchehri/metagoofil.git	Information gathering tool designed for extracting metadata of public documents
:::1779	r3po	Media / Metadata	r3po	1	Python	https://github.com/Arielpoghon/r3po.git	Scans a GitHub/GitLab repo for CVEs, leaked secrets, and SAST issues via Trivy, Gitleaks, and Semgrep. CLI + w
:::1780	docker-sublist3r	Media / Metadata	docker-sublist3r	0	Python	https://github.com/hypn/docker-sublist3r.git	A Docker image of Sublist3r , for enumerating subdomains
:::1781	ngosangnso-metadetective	Media / Metadata	MetaDetective	0	JavaScript	https://github.com/ngosangnso/MetaDetective.git	Unleash Metadata Intelligence with MetaDetective. Your Assistant Beyond Metagoofil
:::1782	holehe	Email	holehe	14958	Python	https://github.com/megadose/holehe.git	holehe allows you to check if the mail is used on different sites like twitter, instagram and will retrieve in
:::1783	mosint	Email	mosint	6034	Go	https://github.com/alpkeskin/mosint.git	An automated e-mail OSINT tool
:::1784	google-maps-scraper	Email	google-maps-scraper	5952	Go	https://github.com/gosom/google-maps-scraper.git	scrape data from Google Maps. Extracts data such as the name, address, phone number, website URL, rating, revi
:::1785	h8mail	Email	h8mail	5310	Python	https://github.com/khast3x/h8mail.git	Email OSINT Password breach hunting tool, locally or using premium services. Supports chasing down related ema
:::1786	argus	Email	Argus	4220	Python	https://github.com/jasonxtn/Argus.git	The Ultimate Information Gathering Toolkit
:::1787	yesitsme	Email	yesitsme	3065	Python	https://github.com/0x0be/yesitsme.git	Simple OSINT script to find Instagram profiles by name and e-mail/phone
:::1788	email2phonenumber	Email	email2phonenumber	2764	Python	https://github.com/martinvigo/email2phonenumber.git	A OSINT tool to obtain a target's phone number just by having his email address
:::1789	x-osint	Email	X-osint	2682	Python	https://github.com/TermuxHackz/X-osint.git	This is an Open source intelligent framework ie an osint tool which gathers valid information about a phone nu
:::1790	th3inspector	Email	Th3inspector	2668	Perl	https://github.com/Moham3dRiahi/Th3inspector.git	Th3Inspector Best Tool For Information Gathering
:::1791	pwnedornot	Email	pwnedOrNot	2647	Python	https://github.com/thewhiteh4t/pwnedOrNot.git	OSINT Tool for Finding Passwords of Compromised Email Addresses
:::1792	striker	Email	Striker	2345	Python	https://github.com/s0md3v/Striker.git	Striker is an offensive information and vulnerability scanner
:::1793	clatscope	Email	ClatScope	1578	Python	https://github.com/Clats97/ClatScope.git	ClatScope Info Tool The best and most versatile OSINT utility for retrieving geolocation, DNS, WHOIS, phone, e
:::1794	mailaccess	Email	MailAccess	1420	Python	https://github.com/KatrielMoses/MailAccess.git	Free email OSINT tool, 2500+ platforms, identity clustering, breach detection. No API keys required. pip insta
:::1795	buster	Email	buster	1415	Python	https://github.com/sham00n/buster.git	An advanced tool for email reconnaissance
:::1796	thephish	Email	ThePhish	1371	Python	https://github.com/emalderson/ThePhish.git	ThePhish: an automated phishing email analysis tool
:::1797	zehef	Email	Zehef	1073	Python	https://github.com/N0rz3/Zehef.git	Zehef is an osint tool to track emails
:::1798	zero-attacker	Email	Zero-attacker	1036	Python	https://github.com/AsjadOooO/Zero-attacker.git	Zero-attacker is an multipurpose hacking tool with over 15+ multifunction tools
:::1799	honeypots	Email	honeypots	989	Python	https://github.com/qeeqbox/honeypots.git	30 different honeypots in one package dhcp, dns, elastic, ftp, http proxy, https proxy, http, https, imap, ip
:::1800	iky	Email	iKy	982	Python	https://github.com/kennbroorg/iKy.git	OSINT Project. Collect information from a mail. Gather. Profile. Timeline
:::1801	simplyemail	Email	SimplyEmail	955	Python	https://github.com/SimplySecurity/SimplyEmail.git	Email recon made fast and easy, with a framework to build on
:::1802	datasurgeon	Email	DataSurgeon	903	Rust	https://github.com/Drew-Alleman/DataSurgeon.git	Quickly Extracts IP's, Email Addresses, Hashes, Files, Credit Cards, Social Security Numbers and a lot More Fr
:::1803	seekr	Email	seekr	875	Go	https://github.com/seekr-osint/seekr.git	A multi-purpose OSINT toolkit with a neat web-interface
:::1804	h4x-tools	Email	H4X-Tools	829	Python	https://github.com/vil/H4X-Tools.git	A modular, terminal-based toolkit for OSINT, reconnaissance, and scraping - built in Python, runs on Linux and
:::1805	emailall	Email	EmailAll	750	Python	https://github.com/Taonn/EmailAll.git	EmailAll is a powerful Email Collect tool
:::1806	redtiger-tools	Email	RedTiger-Tools	726	Python	https://github.com/loxy0devlp/RedTiger-Tools.git	RedTiger-Tools is a multifunction automation tool dedicated to pentesting and OSINT. The project is open sourc
:::1807	chiasmodon	Email	chiasmodon	699	Python	https://github.com/chiasmod0n/chiasmodon.git	Chiasmodon is an OSINT tool designed to assist in the process of gathering information about a target domain. 
:::1808	odin	Email	ODIN	669	Python	https://github.com/chrismaddalena/ODIN.git	Automated network asset, email, and social media profile discovery and cataloguing
:::1809	pyhtools	Email	pyhtools	656	Python	https://github.com/dmdhrumilmistry/pyhtools.git	A Python Hacking Library consisting of network scanner, arp spoofer and detector, dns spoofer, code injector, 
:::1810	poastal	Email	poastal	603	Python	https://github.com/jakecreps/poastal.git	Poastal - the Email OSINT tool
:::1811	metadetective	Email	MetaDetective	507	Python	https://github.com/franckferman/MetaDetective.git	Unleash Metadata Intelligence with MetaDetective. Your Assistant Beyond Metagoofil
:::1812	gmailc2	Email	gmailc2	489	Python	https://github.com/machine1337/gmailc2.git	A Fully Undetectable C2 Server That Communicates Via Google SMTP to evade Antivirus Protections and Network Tr
:::1813	dark-fantasy-hack-tool	Email	dark-fantasy-hack-tool	480	Python	https://github.com/ritvikb99/dark-fantasy-hack-tool.git	DDOS Tool: To take down small websites with HTTP FLOOD. Port scanner: To know the open ports of a site. FTP Pa
:::1814	osintanonymous	Email	OSINTAnonymous	476	-	https://github.com/CScorza/OSINTAnonymous.git	Creazione d'identit Fake - Impostazione Privacy Profili Social - Creazione Ambiente di Lavoro
:::1815	fotosploit	Email	FOTOSPLOIT	426	-	https://github.com/Juanhacker051/FOTOSPLOIT-.git	*FotoSploit* $ git clone https://github.com/Cesar-Hack-Gray/FotoSploit $ cd FotoSploit $ chmod +x * $ bash ins
:::1816	master-osint-toolkit	Email	Master-OSINT-Toolkit	422	-	https://github.com/techenthusiast167/Master-OSINT-Toolkit-.git	A user-friendly Python toolkit for open source intelligence, providing key features such as image geolocation,
:::1817	better-auth-harmony	Email	better-auth-harmony	382	TypeScript	https://github.com/GeKorm/better-auth-harmony.git	Normalize emails/phone numbers and block throwaway domains with Better Auth
:::1818	dnsdumpster	Email	dnsdumpster	379	Python	https://github.com/nmmapper/dnsdumpster.git	A tool to perform DNS reconnaissance on target networks. Among the DNS information got from include subdomains
:::1819	omnisci3nt	Email	omnisci3nt	371	Python	https://github.com/spyboy-productions/omnisci3nt.git	Omnisci3nt is an open-source web reconnaissance and intelligence tool for extracting deep technical insights f
:::1820	ip-biter	Email	IP-Biter	327	PHP	https://github.com/damianofalcioni/IP-Biter.git	IP-Biter: The Hacker-friendly E-Mail but not only Tracking Framework
:::1821	emailanalyzer	Email	EmailAnalyzer	307	Python	https://github.com/keraattin/EmailAnalyzer.git	With EmailAnalyzer you can analyze your suspicious emails. You can extract headers, links, and hashes from the
:::1822	webextractor	Email	WebExtractor	239	Python	https://github.com/s-r-e-e-r-a-j/WebExtractor.git	WebExtractor is a powerful OSINT and ethical hacking tool developed in Python. It is used to extract email add
:::1823	knock-knock	Email	knock-knock	208	Python	https://github.com/djkurlander/knock-knock.git	Knock-Knock: A Live, Multi-Protocol Honeypot Dashboard of Internet Break-in Attempts - 13 Protocols, an Extens
:::1824	mailmeta	Email	mailMeta	176	Python	https://github.com/gr33nm0nk2802/mailMeta.git	An forensics tool to help aid in the investigation of spoofed emails based off the email headers
:::1825	archivefuzz	Email	ArchiveFuzz	164	Python	https://github.com/devanshbatham/ArchiveFuzz.git	Hunt down the secrets from the WebArchives for Fun and Profit
:::1826	hermes-secure-email-gateway	Email	Hermes-Secure-Email-Gateway	139	JavaScript	https://github.com/deeztek/Hermes-Secure-Email-Gateway.git	Hermes Secure Email Gateway is a Free Open Source Secure Email Gateway and Email Server
:::1827	email-osint	Email	Email-Osint	136	Python	https://github.com/KanekiWeb/Email-Osint.git	EMAIL OSINT is an OSINT Tool for emails. It helps you gather information about the target email
:::1828	osint	Email	OSINT	134	Python	https://github.com/JambaAcademy/OSINT.git	Companion repo for A Complete Guide to Mastering OSINT 2025. Includes free templates $5,000 value, latest 
:::1829	amitrajputfff-profil3r	Email	Profil3r	134	Python	https://github.com/amitrajputfff/Profil3r.git	Profil3r is an OSINT tool that allows you to find potential profiles of a person on social networks, as well a
:::1830	black	Email	Black	110	Python	https://github.com/fawadqureshi007/Black.git	BlackTrace is a Python OSINT toolkit for reconnaissance, offering image geolocation, email breach checks, doma
:::1831	daprofiler	Email	DaProfiler	109	JavaScript	https://github.com/dalunacrobate/DaProfiler.git	DaProfiler allows you to create a profile on your target based in France only. The particularity of this progr
:::1832	socialosint	Email	socialosint	97	Rust	https://github.com/krishpranav/socialosint.git	A rust osint tool for getting emails, from a target, published in social networks like Instagram, Linkedin and
:::1833	map-email-scraper	Email	map-email-scraper	93	JavaScript	https://github.com/MickeyUK/map-email-scraper.git	A open source tool for collating publically available contact information for businesses
:::1834	csv2vcf	Email	csv2vcf	75	Python	https://github.com/Moduland/csv2vcf.git	Simple script in python to convert CSV files to VCF
:::1835	infofinder_pro	Email	INFOFINDER_PRO	73	-	https://github.com/techenthusiast167/INFOFINDER_PRO.git	A comprehensive Python-based OSINT Open Source Intelligence tool for email and phone number verification wit
:::1836	opsdisk-theharvester	Email	theHarvester	62	Python	https://github.com/opsdisk/theHarvester.git	A multithreaded rewrite of the classic theHarvester email address collection script
:::1837	glit	Email	glit	58	Rust	https://github.com/shadawck/glit.git	Retrieve all mails of users related to a git repository, a git user or a git organization
:::1838	breachcheck	Email	BreachCheck	50	Python	https://github.com/v4resk/BreachCheck.git	BreachCheck is a tool designed to help users search for their passwords in known data breaches and leaks
:::1839	aarya	Email	aarya	44	Python	https://github.com/forshaur/aarya.git	E-mail to digital footprint Validate the existence of email address on various online platforms Extract rich m
:::1840	leakcheck-api	Email	leakcheck-api	42	Python	https://github.com/LeakCheck/leakcheck-api.git	LeakCheck API
:::1841	one	Email	one	37	Python	https://github.com/charliebrassington/one.git	One, an osint tool with multiple scrapers including cyberbackgroundchecks
:::1842	emailosint	Email	emailosint	26	Python	https://github.com/krishpranav/emailosint.git	emailosint is a tool for gathering email accounts informations ip,hostname,country, etc...
:::1843	instamailchecker	Email	InstaMailChecker	23	C#	https://github.com/joaostack/InstaMailChecker.git	A OSINT tool that checks if the specified email is registered on Instagram
:::1844	osintxphone	Email	osintxphone	21	Python	https://github.com/e-m3din4/osintxphone.git	OSINT tool to verify phone numbers in Mexico
:::1845	drooling-email-osint	Email	email-osint	21	Python	https://github.com/drooling/email-osint.git	A email OSINT tool written in python3
:::1846	offensive-recon	Email	Offensive-Recon	21	PHP	https://github.com/InfoSecWarrior/Offensive-Recon.git	Passive Reconnaissance Techniques Approach helps for penetration testing and bug bounty hunting by gathering i
:::1847	cartuxeira	Email	cartuxeira	18	Python	https://github.com/eliasgranderubio/cartuxeira.git	Phishing attack identification tool - Performs email risk evaluations relying on different black lists, machin
:::1848	skip-trace	Email	skip-trace	16	Python	https://github.com/WebOlivia/skip-trace.git	people search and tracing API
:::1849	cyberleaks	Email	CyberLeaks	14	Python	https://github.com/HackUnderway/CyberLeaks.git	An OSINT tool to check if your emails have been compromised in data breaches using dual engines Apify RapidAP
:::1850	seo	Email	SEO	10	Python	https://github.com/Euronymou5/SEO.git	SEO es una herramienta de osint para un correo electronico
:::1851	t-tools-advanced-cyber-security	Email	T-Tools-advanced--cyber-security	10	Python	https://github.com/Hirukshacoder/T-Tools-advanced--cyber-security.git	A tool that can used for hacking :- reverse-shells, email-attacks, ip tracker and tracer
:::1852	recon-smtp	Email	recon-smtp	9	Python	https://github.com/pentestit/recon-smtp.git	smtp-user-enum.pl ported into a recon-ng module
:::1853	gitsniff	Email	GitSniff	8	Python	https://github.com/Reginald-Gillespie/GitSniff.git	GitSniff is an OSINT tool designed to extract emails from metadata on GitHub accounts and repos
:::1854	email_check	Email	email_check	8	Python	https://github.com/HackUnderway/email_check.git	Email Check: using Holehe in Flask to perform OSINT on email addresses
:::1855	mail-osint-tools	Email	mail-osint-tools	8	-	https://github.com/olegakanom/mail-osint-tools.git	OSINT- email: , , , , , , . OSINT 2025
:::1856	infoga-email-osint	Email	Infoga---Email-OSINT	6	-	https://github.com/anthophilee/Infoga---Email-OSINT.git	Infoga - Email OSINT Infoga is a tool gathering email accounts informations ip,hostname,country,... from dif
:::1857	email-validator	Email	email-validator	4	Python	https://github.com/Renatoelho/email-validator.git	Este projeto visa obter bom nvel de confiana de um determinado endereo de e-mail, considerando diversos fatore
:::1858	cisco-packet-tracer	Email	cisco-packet-tracer	3	-	https://github.com/IbrahimHashhash/cisco-packet-tracer.git	This Cisco Packet Tracer project for ENCS3320 involves designing and simulating a complete network, focusing o
:::1859	infoga	Email	Infoga	2	-	https://github.com/cybersechub/Infoga.git	Infoga - Email OSINT
:::1860	build-a-network-for-both-uhd-goyzha-and-	Email	Build-a-network-for-Both-UHD-Goyzha-and-	2	-	https://github.com/DanaFaiq/-Build-a-network-for-Both-UHD-Goyzha-and-Qaradax-Camps-Interconnect-through-OSPF-Routing-protocol-.git	Design LANS with Hierarchical Network Model, select technology and assign IP address. We consider for each cam
:::1861	interconnecting-2-corporate-company-by-w	Email	Interconnecting-2-corporate-Company-by-W	2	-	https://github.com/DanaFaiq/-Interconnecting-2-corporate-Company-by-WAN-technology-and-implement-VPN-IPSec-PPP-NAT-PAT-and.git	Interconnecting 2 corporate Company, assigned different IP addresses and Autonomous System AS for each one, 
:::1862	profiler-main	Email	Profiler-main	2	Python	https://github.com/DavidZerox8/Profiler-main.git	Profil3r is an OSINT tool that allows you to find potential profiles of a person on social networks, as well a
:::1863	etshx-osint	Email	etshx-osint	2	Shell	https://github.com/etshx01/etshx-osint.git	etshx-osint is a modular OSINT Open Source Intelligence deep reconnaissance framework written in Bash. It au
:::1864	holeheplayground	Email	HoleHePlayGround	1	Python	https://github.com/jkerai1/HoleHePlayGround.git	Playground of projects messing around with Holehe
:::1865	opensource-search_holehe-fastapi	Email	opensource-search_holehe-fastapi	1	Python	https://github.com/aaron-ty/opensource-search_holehe-fastapi.git	High-performance OSINT service for email and phone intelligence. Automates multi-platform reconnaissance with 
:::1866	osint-service	Email	OSINT-Service	1	-	https://github.com/aeglon97/OSINT-Service.git	Uses the holehe tool to efficiently find information associated with email accounts
:::1867	email-checker	Email	email-checker	1	Python	https://github.com/mahi-cyberaware/email-checker.git	OSINT email investigation tool that checks where an email is registered across 120+ websites and detects possi
:::1868	emailaccountfinder	Email	EmailAccountFinder	1	TypeScript	https://github.com/aakashsakhalkar/EmailAccountFinder.git	EmailAccountFinder is an OSINT web platform checking email registrations across 120+ platforms via password re
:::1869	aatman1571-emailosint	Email	emailosint	1	Python	https://github.com/Aatman1571/emailosint.git	Email Header Analyzer and OSINT Toolkit A web-based tool to analyze email headers, detect spoofing, calculate 
:::1870	harvester-utils	Email	harvester-utils	1	Shell	https://github.com/bjellesma/harvester-utils.git	Short script to assist with the command line theharvester email harvesting script
:::1871	theharvestermarketingtool	Email	TheHarvesterMarketingTool	1	-	https://github.com/maxt-800/TheHarvesterMarketingTool.git	The Harvester Marketing Tool is a powerful marketing tool designed to streamline and enhance outreach efforts 
:::1872	domain-name-analysis-of-an-organisation-	Email	DOMAIN-NAME-ANALYSIS-OF-AN-ORGANISATION-	1	-	https://github.com/16sumanshiroy/DOMAIN-NAME-ANALYSIS-OF-AN-ORGANISATION-AND-AN-EMAIL-ADDRESS-USING-INFORMATION-GATHERING-OSINT-TOOLS.git	Conducted domain and email analysis using Spiderfoot and Netlas in Kali Linux, verifying 20+ domains, identify
:::1873	licked-pwnedornot	Email	licked-pwnedOrNot	1	Python	https://github.com/pepelawycliffe/licked-pwnedOrNot.git	tests the given email address using
:::1874	victormac1-pwnedornot	Email	pwnedOrNot	1	Python	https://github.com/victormac1/pwnedOrNot.git	OSINT Tool for Finding Passwords of Compromised Email Addresses
:::1875	pieterunperceived553-holehe	Email	holehe	0	-	https://github.com/pieterunperceived553/holehe.git	Holehe checks if an email is linked to accounts on over 120 platforms without alerting the target, using the f
:::1876	holehe-email	Email	Holehe---Email	0	-	https://github.com/Outils-Osint/Holehe---Email.git	holehe allows you to check if the mail is used on different sites like twitter, instagram and will retrieve in
:::1877	holehe-osint	Email	Holehe-OSINT	0	-	https://github.com/bunchac/Holehe-OSINT.git	Email to Registered Accounts
:::1878	v662-coder-holehe-osint	Email	Holehe-OSINT	0	Python	https://github.com/v662-coder/Holehe-OSINT.git	Email to Registered Accounts
:::1879	holehe-email-osint	Email	holehe-email-osint	0	-	https://github.com/VastHornet/holehe-email-osint.git	Apify actor: holehe-email-osint
:::1880	anshumanatrey-holehe-email-osint	Email	holehe-email-osint	0	Python	https://github.com/AnshumanAtrey/holehe-email-osint.git	Email OSINT find accounts registered to an email across 100+ sites. Apify actor
:::1881	noxis-holehe	Email	noxis-holehe	0	Python	https://github.com/esttebanink/noxis-holehe.git	Holehe Email Intelligence engine for NOXIS OSINT Intelligence Platform
:::1882	holehe_v2	Email	holehe_v2	0	Python	https://github.com/anubhavanonymous/holehe_v2.git	Your target has an email. holehe_v2 finds everywhere it's been used
:::1883	holehe-installation-guide	Email	holehe-installation-guide	0	-	https://github.com/abu76/holehe-installation-guide.git	Holehe is an OSINT tool that checks whether an email address is associated with accounts on various services
:::1884	email-osint-enricher	Email	email-osint-enricher	0	Python	https://github.com/bon3spike/email-osint-enricher.git	Local OSINT email enrichment tool using GHunt and Holehe email footprint scoring, identity confidence, batch p
:::1885	waver	Email	Waver	0	Python	https://github.com/0x94sd/Waver.git	Outil OSINT async Dtection de pseudos, scan email Holehe, gnration de variantes wildcard, rotation proxy/UA 
:::1886	zcheck	Email	Zcheck	0	Python	https://github.com/Zeyneell/Zcheck.git	Async emailaccounts OSINT holehe-style but data-driven 690+ sites, with canary false-positive suppression an
:::1887	osint-investigator	Email	osint-investigator	0	Python	https://github.com/J4y35/osint-investigator.git	A modern, modular OSINT command-line tool for private-investigation work. Holehe email checks, Playwright peop
:::1888	localsimulation	Email	LocalSimulation	0	-	https://github.com/ecgun3/LocalSimulation.git	A comprehensive email reconnaissance tool integrating MX, BuiltWith, Holehe, and Genesys Search. Collects doma
:::1889	techcheckmailer	Email	TechCheckMailer	0	-	https://github.com/ecgun3/TechCheckMailer.git	A web-based tool that leverages the BuiltWith API to identify technologies used by a given domain, integrates 
:::1890	mutai08-infoga	Email	infoga	0	-	https://github.com/mutai08/infoga.git	Infoga - Email OSINT SaaS - https://infoga.io
:::1891	agraf93-ghunt	Email	Ghunt	0	-	https://github.com/agraf93/Ghunt.git	Google email exploitation
:::1892	theharvester-osint	Email	theharvester-osint	0	Python	https://github.com/AnshumanAtrey/theharvester-osint.git	theHarvester OSINT emails, subdomains, hosts from public sources. Apify actor
:::1893	theharvester-automation	Email	theHarvester-Automation	0	Python	https://github.com/higgsborn/theHarvester-Automation.git	Automation script for email extraction using theHarvester
:::1894	theharvester-macos	Email	theHarvester-macOS	0	Python	https://github.com/reapersapprentice/theHarvester-macOS.git	Map a domain's public footprint emails, names subdomains on your Mac
:::1895	brv-intelligence	Email	brv-intelligence	0	Python	https://github.com/bigrun3303/brv-intelligence.git	BRV Intelligence Engine Docker-deployable OSINT pipeline for B2B contact discovery theHarvester, MX check, em
:::1896	reconstudio	Email	ReconStudio	0	Python	https://github.com/tinkerlev/ReconStudio.git	Modular web reconnaissance toolkit for ethical hackers. Includes subdomain enumeration, WHOIS lookup, and pass
:::1897	networkwalks-b082-w2-pm4-footprinting-an	Email	NETWORKWALKS-B082-W2-PM4-Footprinting-an	0	-	https://github.com/Snowy-lab-dotcom/NETWORKWALKS-B082-W2-PM4-Footprinting-and-Reconnaissance-with-theHarvester.git	Practical cybersecurity lab demonstrating passive reconnaissance and information gathering using theHarvester 
:::1898	osint-exposure-assessment	Email	OSINT-Exposure-Assessment	0	-	https://github.com/rakshitham1030/OSINT-Exposure-Assessment.git	A professional Open Source Intelligence OSINT exposure assessment covering public domain metadata, email exp
:::1899	osint-exposure-assessmentt	Email	OSINT-Exposure-Assessmentt	0	-	https://github.com/rakshitham1030/OSINT-Exposure-Assessmentt.git	A professional Open Source Intelligence OSINT exposure assessment covering public domain metadata, email exp
:::1900	networkwalks-b082-week2-pradheepa	Email	networkwalks-B082-week2-Pradheepa	0	-	https://github.com/pradheepa73/networkwalks-B082-week2-Pradheepa.git	Week 2 - Networkwalks Cybersecurity Internship Batch B082. Complete submission for Footprinting, Reconnaissa
:::1901	pentest-lab-information-gathering	Email	PenTest-Lab-Information-Gathering	0	-	https://github.com/uliyach45/PenTest-Lab-Information-Gathering.git	Lab Task 3 for Penetration Testing Full information gathering phase covering passive OSINT Netcraft, Whois, 
:::1902	toutatis-gui	Email	Toutatis-GUI	0	Python	https://github.com/gigachad80/Toutatis-GUI.git	GUI version of Toutatis with bug fixes and updates Instagram Tool . Toutatis is a tool that allows you to ex
:::1903	phoneinfoga	Phone	phoneinfoga	17924	Go	https://github.com/sundowndev/phoneinfoga.git	Information gathering framework for phone numbers
:::1904	ghosttrack	Phone	GhostTrack	15102	Python	https://github.com/HunxByts/GhostTrack.git	Useful tool to track location or mobile number
:::1905	intl-tel-input	Phone	intl-tel-input	8261	TypeScript	https://github.com/jackocnr/intl-tel-input.git	For entering, formatting, and validating international telephone numbers. Available in vanilla JavaScript, or 
:::1906	device-activity-tracker	Phone	device-activity-tracker	5140	TypeScript	https://github.com/gommzystudio/device-activity-tracker.git	A phone number can reveal whether a device is active, in standby or offline and more. This PoC demonstrates 
:::1907	libphonenumber-for-php	Phone	libphonenumber-for-php	5056	PHP	https://github.com/giggsey/libphonenumber-for-php.git	PHP version of Google's phone number handling library
:::1908	chinamobilephonenumberregex	Phone	ChinaMobilePhoneNumberRegex	4769	-	https://github.com/VincentSit/ChinaMobilePhoneNumberRegex.git	Regular expressions that match the mobile phone number in mainland China. /
:::1909	toutatis	Phone	toutatis	4297	Python	https://github.com/megadose/toutatis.git	Toutatis is a tool that allows you to extract information from instagrams accounts such as e-mails, phone numb
:::1910	gokboru_intel	Phone	Gokboru_Intel	2093	Python	https://github.com/AzizKpln/Gokboru_Intel.git	This tool gives information about the phone number that you entered
:::1911	ignorant	Phone	ignorant	2070	Python	https://github.com/megadose/ignorant.git	ignorant allows you to check if a phone number is used on different sites like snapchat, instagram
:::1912	searchphone	Phone	SearchPhone	1987	Python	https://github.com/HackUnderway/SearchPhone.git	Phone number OSINT toolkit with multi-API search Google, GitHub, Numverify, Reddit, DuckDuckGo, Hudson Rock 
:::1913	telegram-phone-number-checker	Phone	telegram-phone-number-checker	1788	Python	https://github.com/bellingcat/telegram-phone-number-checker.git	Check if phone numbers are connected to Telegram accounts
:::1914	alhacking	Phone	ALHacking	1633	Shell	https://github.com/4lbH4cker/ALHacking.git	Albanian Hacking Tool Tools to help you with ethical hacking, Social media hack, phone info, Gmail attack, pho
:::1915	r4ven	Phone	r4ven	1519	HTML	https://github.com/spyboy-productions/r4ven.git	Track the GPS location of the user's smartphone or PC and capture a picture of the target, along with IP and d
:::1916	phunter	Phone	Phunter	1203	Python	https://github.com/N0rz3/Phunter.git	Phunter is an osint tool allowing you to find various information via a phone number
:::1917	phonelib	Phone	phonelib	1165	Ruby	https://github.com/daddyz/phonelib.git	Ruby gem for phone validation and formatting using google libphonenumber library data
:::1918	tel-agent	Phone	Tel-Agent	968	Python	https://github.com/Dpro-at/Tel-Agent.git	AI phone assistant open-source
:::1919	shadcn-phone-input	Phone	shadcn-phone-input	968	TypeScript	https://github.com/omeralpi/shadcn-phone-input.git	Customizable phone input component with proper validation for any country. Built on top of shadcn
:::1920	phone	Phone	phone	924	TypeScript	https://github.com/AfterShip/phone.git	With a given country and phone number, validate and reformat the mobile phone number to the E.164 standard. Th
:::1921	libphonenumber-csharp	Phone	libphonenumber-csharp	921	C#	https://github.com/twcclegg/libphonenumber-csharp.git	Offical C# port of https://github.com/googlei18n/libphonenumber
:::1922	truecallerjs	Phone	truecallerjs	873	TypeScript	https://github.com/sumithemmadi/truecallerjs.git	TruecallerJS: This is a library for retrieving phone number details using the Truecaller API
:::1923	laravel-sms	Phone	laravel-sms	835	PHP	https://github.com/toplan/laravel-sms.git	:iphone::heavy_check_mark:A phone number validation solution based on laravel
:::1924	operative-framework	Phone	operative-framework	750	Rust	https://github.com/graniet/operative-framework.git	operative framework is a rust investigation OSINT framework, you can interact with multiple targets, execute m
:::1925	telephone-osint	Phone	Telephone-OSINT	663	-	https://github.com/The-Osint-Toolbox/Telephone-OSINT.git	Phone lookup tools
:::1926	oprecon	Phone	OPRecon	628	Python	https://github.com/AbirHasan2005/OPRecon.git	Using this you can find informations via PhoneInFogaIn-Built, Find location via IP Address website link via 
:::1927	la-deep-web-phoneinfoga	Phone	Phoneinfoga	619	Python	https://github.com/la-deep-web/Phoneinfoga.git	script to search for data about phone numbers
:::1928	phomber	Phone	phomber	601	Python	https://github.com/s41r4j/phomber.git	[PH0MBER]: An open source infomation grathering reconnaissance framework
:::1929	websift	Phone	WebSift	584	Shell	https://github.com/s-r-e-e-r-a-j/WebSift.git	WebSift is an OSINT ethical hacking tool designed to scrape and extract emails, phone numbers, and social medi
:::1930	edittext-mask	Phone	edittext-mask	479	Java	https://github.com/egslava/edittext-mask.git	The custom mask for EditText. The solution for masked edit text input phone numbers, SSN, and so on for Androi
:::1931	react-international-phone	Phone	react-international-phone	450	TypeScript	https://github.com/ybrusentsov/react-international-phone.git	International phone input component for React
:::1932	dial2verify-twilio	Phone	dial2verify-twilio	442	PHP	https://github.com/natsu90/dial2verify-twilio.git	Phone verification at no cost Deprecated
:::1933	django-formset	Phone	django-formset	435	Python	https://github.com/jrief/django-formset.git	The missing widgets and form manipulation library for Django
:::1934	phonenumber	Phone	phonenumber	428	PHP	https://github.com/brick/phonenumber.git	A phone number library for PHP
:::1935	react-native-phone-number-input	Phone	react-native-phone-number-input	387	JavaScript	https://github.com/garganurag893/react-native-phone-number-input.git	React Native component for phone number
:::1936	react-native-international-phone-number	Phone	react-native-international-phone-number	378	JavaScript	https://github.com/AstrOOnauta/react-native-international-phone-number.git	React Native phone number input component
:::1937	thescrapper	Phone	TheScrapper	372	Python	https://github.com/champmq/TheScrapper.git	Scrape emails, phone numbers and social media accounts from a website
:::1938	faker	Phone	faker	356	Go	https://github.com/dmgk/faker.git	A library for generating fake data such as names, addresses, and phone numbers
:::1939	pydantic-extra-types	Phone	pydantic-extra-types	336	Python	https://github.com/pydantic/pydantic-extra-types.git	Extra Pydantic types
:::1940	countrycodepicker	Phone	CountryCodePicker	321	Java	https://github.com/joielechong/CountryCodePicker.git	Country Code Picker CCP is an android library which provides an easy way to search and select country phone 
:::1941	pandora	Phone	pandora	311	Python	https://github.com/MrSanZz/pandora.git	= Has features =- =============== -DDoS -Web Scanning -Phone Hunter -CCTV Hunter -Deface -Mass Deface -Deface 
:::1942	phoneintel	Phone	phoneintel	306	Python	https://github.com/phoneintel/phoneintel.git	PhoneIntel is an OSINT tool for retrieving detailed information about phone numbers
:::1943	deep-hlr	Phone	deep-hlr	294	Python	https://github.com/e-m3din4/deep-hlr.git	Obtain a Phone Number full profile including HLR, Reputation, Carrier, Social Media Accounts, Geolocation, Val
:::1944	owltrack	Phone	OwlTrack	265	Python	https://github.com/IccTeam/OwlTrack.git	OwlTrack OSINT Tools This tracking tool can provide information about the phone number you enter. Not only tha
:::1945	inspector	Phone	Inspector	234	Python	https://github.com/N0rz3/Inspector.git	Osint tool phone-number tracker
:::1946	sms-number-verifier	Phone	sms-number-verifier	230	JavaScript	https://github.com/transitive-bullshit/sms-number-verifier.git	Allows you to spoof SMS number verification
:::1947	ids-inf	Phone	ids-inf	229	Shell	https://github.com/DRACULA-HACK/ids-inf.git	ids-inf is a information gathering tool and with extra use full options like number unban and ban and it has p
:::1948	ngx-intl-tel-input	Phone	ngx-intl-tel-input	224	TypeScript	https://github.com/webcat12345/ngx-intl-tel-input.git	Phone number input field to support international numbers, Angular
:::1949	mui-tel-input	Phone	mui-tel-input	208	TypeScript	https://github.com/viclafouch/mui-tel-input.git	A phone number input designed for MUI Material ui built with libphonenumber-js
:::1950	rust-phonenumber	Phone	rust-phonenumber	203	Rust	https://github.com/whisperfish/rust-phonenumber.git	Library for parsing, formatting and validating international phone numbers
:::1951	reborn	Phone	Reborn	202	Python	https://github.com/4nat/Reborn.git	ReborN SMS BOMBER SpeedX 4NAT
:::1952	sms-sender	Phone	sms-sender	200	Python	https://github.com/mfr-fr/sms-sender.git	This script in python allows to send messages anonymously
:::1953	social-media-detector-api	Phone	social-media-detector-api	190	Python	https://github.com/yazeed44/social-media-detector-api.git	This api would allow you to check if a phone number has a certain social media app
:::1954	python-phonenumber-tracker-app	Phone	Python-phonenumber-tracker-App	178	Python	https://github.com/Kalebu/Python-phonenumber-tracker-App.git	Tracks location of a phone number with python
:::1955	mini_phone	Phone	mini_phone	158	C++	https://github.com/ianks/mini_phone.git	A fast phone number parser, validator and formatter for Ruby. This gem binds to Google's C++ libphonenumber fo
:::1956	react-native-unified-contacts	Phone	react-native-unified-contacts	157	Java	https://github.com/joshuapinter/react-native-unified-contacts.git	Your best friend when working with the latest and greatest Contacts Framework in iOS 9+ in React Native
:::1957	telespot	Phone	Telespot	139	Python	https://github.com/thumpersecure/Telespot.git	TeleSpot OSINT lookup from Telephone number using DDGR + BING + GOOGLE + DEHASHED and uses pattern recognition
:::1958	svelte-tel-input	Phone	svelte-tel-input	127	TypeScript	https://github.com/gyurielf/svelte-tel-input.git	Svelte Tel Input
:::1959	owl-sint	Phone	Owl-sint	117	Python	https://github.com/IccTeam/Owl-sint.git	The OwlSint tool is a tool for searching phone number information and for tracking phone numbers,perhaps only 
:::1960	premium-call	Phone	Premium-Call	113	Python	https://github.com/Dra-Ganzz/Premium-Call.git	Work Script Call Unlimited Premium Multi Target - Kebanyak Nomor Dan 24 jam Nonstop And No Timer/Delay And Spa
:::1961	bat-security-toolkit	Phone	bat-security-toolkit	111	Python	https://github.com/Kcisti/bat-security-toolkit.git	Automated Network Reconnaissance and OSINT framework. Streamlines IP tracking, geolocation, and digital footpr
:::1962	osint-x	Phone	osint-X	108	Python	https://github.com/Whomrx666/osint-X.git	osint-X is a tool for searching phone number information and for tracking phone numbers,perhaps only a few cou
:::1963	ghostgd	Phone	gHoStGD	108	Python	https://github.com/Gheris-579/gHoStGD.git	Useful tool to track location or mobile number
:::1964	iranian-phonenumber-validation	Phone	iranian-phonenumber-validation	106	HTML	https://github.com/AmirMahdyJebreily/iranian-phonenumber-validation.git	Regex collection for validating Iranian phone numbers + examples of writing in multiple languages such as Pyth
:::1965	countries-phone-masks	Phone	countries-phone-masks	105	JavaScript	https://github.com/ChristoPy/countries-phone-masks.git	Phone masks, ISO codes and flags
:::1966	rlibphonenumber	Phone	rlibphonenumber	98	Rust	https://github.com/vloldik/rlibphonenumber.git	A high-performance Rust port of Google's libphonenumber for parsing, formatting, and validating international 
:::1967	libphonenumber-for-php-lite	Phone	libphonenumber-for-php-lite	97	PHP	https://github.com/giggsey/libphonenumber-for-php-lite.git	PHP version of Google's phone number handling library
:::1968	antd-phone-input	Phone	antd-phone-input	92	TypeScript	https://github.com/typesnippet/antd-phone-input.git	Advanced, highly customizable phone input component for Ant Design
:::1969	standalone-call-recorder	Phone	standalone-call-recorder	88	Shell	https://github.com/alwye/standalone-call-recorder.git	Another phone call recorder + a pinch of privacy. Record your iPhone, Android or landline calls
:::1970	xtelenumsint	Phone	xTELENUMSINT	82	JavaScript	https://github.com/thumpersecure/xTELENUMSINT.git	xTELENUMSINT - A powerful new Chrome extension for Telephone OSINT NUMSINT that automates searches in Google
:::1971	racksee-bullet-phoneinfoga	Phone	PhoneInfoga	77	Python	https://github.com/RACKSEE-BULLET/PhoneInfoga.git	location hacking and phone number hacking
:::1972	react-phonenr-input	Phone	React-PhoneNr-Input	74	TypeScript	https://github.com/KaiHotz/React-PhoneNr-Input.git	An intuitive phone number input with country selector for international and national phone numbers
:::1973	pnwgen	Phone	pnwgen	73	Python	https://github.com/toxydose/pnwgen.git	A very flexible phone number wordlist generator
:::1974	nova-phone-number	Phone	nova-phone-number	70	PHP	https://github.com/dniccum/nova-phone-number.git	A Laravel Nova field to format and validate phone numbers
:::1975	anthophilee-phoneinfoga	Phone	phoneinfoga	69	-	https://github.com/anthophilee/phoneinfoga.git	Install phne infoga in termux to fetching data from phone number $ apt update apt upgrade $ pkg install python
:::1976	phone-number-information	Phone	Phone-Number-Information	67	Python	https://github.com/rodyherrera/Phone-Number-Information.git	Look up an international phone numbers estimated location lat/long + place, carrier info, and export the res
:::1977	myanmar-phonenumber	Phone	myanmar-phonenumber	66	JavaScript	https://github.com/kaungmyatlwin/myanmar-phonenumber.git	Javascript module port for browsers and node of https://github.com/Melomap/mm_phonenumber to check valid m
:::1978	x-trojan	Phone	X-trojan	63	Python	https://github.com/Whomrx666/X-trojan.git	This is a tool for sending a Trojan virus to the victim's cellphone using the victim's telephone number on the
:::1979	antd-country-phone-input	Phone	antd-country-phone-input	62	TypeScript	https://github.com/boyuai/antd-country-phone-input.git	Country phone input component as standard Ant.Design form item
:::1980	free-otp-api	Phone	free-otp-api	56	TypeScript	https://github.com/Shelex/free-otp-api.git	web service and api with free phone numbers from various providers in one place
:::1981	keycloak-phone-number	Phone	keycloak-phone-number	54	Java	https://github.com/vymalo/keycloak-phone-number.git	Keycloak plugin for logins using phone number
:::1982	no-infoga-py	Phone	no-infoga.py	53	Python	https://github.com/akashblackhat/no-infoga.py.git	This tool gives information about the phone number that you entered
:::1983	magento2-sign-in-with-phone-number	Phone	magento2-sign-in-with-phone-number	53	PHP	https://github.com/williankeller/magento2-sign-in-with-phone-number.git	This extension allow your customers to login to your Magento store using their phone number
:::1984	wasonar	Phone	WaSonar	53	JavaScript	https://github.com/AjayAntoIsDev/WaSonar.git	WhatsApp Intelligence Resource Exhaustion Tool. Features real-time device tracking, silent RTT probing, and pr
:::1985	phonumspy	Phone	PhoNumSpy	49	Python	https://github.com/CyberNDR/PhoNumSpy.git	PhoNumSpy is an intelligence OSINT information gathering tool used to get the main informations about a phon
:::1986	naija-phone-number	Phone	naija-phone-number	47	JavaScript	https://github.com/dokasto/naija-phone-number.git	A fast minimal module to validate Nigerian mobile phone numbers using Regular Expressions
:::1987	dadata	Phone	dadata	46	PHP	https://github.com/kstkn/dadata.git	A PHP library for the DaData.ru REST API
:::1988	phosint	Phone	phosint	40	Python	https://github.com/drooling/phosint.git	Phone number OSINT tool made in python3
:::1989	info-instagram	Phone	info-instagram	33	-	https://github.com/9k6y/info-instagram.git	Toutatis is a tool that allows you to extract information from instagrams accounts such as e-mails, phone numb
:::1990	wire	Phone	Wire	32	Python	https://github.com/therealOri/Wire.git	Simple OSINT phone number lookup
:::1991	pyphoneinfoga	Phone	pyPhoneInfoga	29	Python	https://github.com/Dont-Copy-That-Floppy/pyPhoneInfoga.git	A branch of the original PhoneInfoga to keep using python
:::1992	devsebastian44-ip-tracker	Phone	IP-Tracker	24	Python	https://github.com/devsebastian44/IP-Tracker.git	Proyectos en Python para aprendizaje y prctica
:::1993	near	Phone	Near	23	Python	https://github.com/SamueleAmato/Near.git	All-in-one OSINT toolkit
:::1994	jonaylor89-ignorant	Phone	ignorant	15	Rust	https://github.com/jonaylor89/ignorant.git	ignorant allows you to check if a phone number is used on different sites like snapchat, instagram
:::1995	bucin-sh	Phone	bucin.sh	13	-	https://github.com/Dzxmzstrt/bucin.sh.git	# cd /data/data/com.termux/files/usr/bin/bash clear cd data clear echo Ngapain Ke Sini? siap Siap Ngebucin Ya 
:::1996	techgujarati-phoneinfoga	Phone	PhoneInfoga	8	Go	https://github.com/TechGujarati/PhoneInfoga.git	Hacker's Tool For collecting Information about Phone number
:::1997	phone-number-tracker	Phone	Phone-Number-Tracker	8	Python	https://github.com/Jonaskouame/Phone-Number-Tracker.git	Track, validate, and analyze phone numbers with detailed carrier, location, roaming, and subscriber insights u
:::1998	andro-location-tracker	Phone	andro-location-tracker	8	Python	https://github.com/anub12345/andro-location-tracker.git	a very powerfull location tracker tool for andorid phone. this tool can get geolocation of a android . copyrig
:::1999	technofuge-phoneinfoga	Phone	PhoneInfoga	7	Python	https://github.com/TechnoFuge/PhoneInfoga.git	Information Gathering Tool From Phone Number
:::2000	bikkurs-phoneinfoga	Phone	phoneinfoga	6	Python	https://github.com/bikkurs/phoneinfoga.git	Osint phone number information gathering tool
:::2001	phoneinfoga-linux-portabel	Phone	phoneinfoga-linux-portabel	6	-	https://github.com/spyschools/phoneinfoga-linux-portabel.git	Information gathering framework for phone numbers
:::2002	pulu-html	Phone	pulu.html	6	-	https://github.com/xienan917/pulu.html.git	blue='\e[0;34' cyan='\e[0;36m' green='\e[0;34m' okegreen='\033[92m' lightgreen='\e[1;32m' white='\e[1;37m' red
:::2003	phoneinfoga-phone-osint	Phone	phoneinfoga-phone-osint	5	Python	https://github.com/AnshumanAtrey/phoneinfoga-phone-osint.git	Phone OSINT scan international phone numbers, validate country, generate footprint URLs across social/reputati
:::2004	ignorantpro	Phone	IgnorantPro	5	Python	https://github.com/Yescrypt/IgnorantPro.git	Phone number OSINT CLI tool that checks presence across multiple platforms and generates an automatic report
:::2005	jonaylor89-toutatis	Phone	toutatis	5	Rust	https://github.com/jonaylor89/toutatis.git	Toutatis is a tool that allows you to extract information from instagrams accounts such as e-mails, phone numb
:::2006	phoneinfoga_toolkit	Phone	PhoneInfoga_toolkit	3	Python	https://github.com/whoami136/PhoneInfoga_toolkit.git	An advanced, modular OSINT investigation toolkit designed for terminal-based reconnaissance. Featuring a high-
:::2007	numburglar	Phone	numburglar	3	-	https://github.com/p4wnsolo/numburglar.git	OSINT tool to scrape public phone-directory websites. Like Phoneinfoga
:::2008	scammerbuster	Phone	ScammerBuster	3	Python	https://github.com/w1s3m4n/ScammerBuster.git	ScammerBuster is a simple script used to gather sensitive basic information via command line. It is intended t
:::2009	tvphack-phoneinfoga	Phone	PhoneInfoga	2	Python	https://github.com/tvphack/PhoneInfoga.git	this is a tool for collect information of a phone number
:::2010	phoneinfoga_v1_11	Phone	phoneinfoga_v1_11	2	Python	https://github.com/gaborga/phoneinfoga_v1_11.git	V1.11 of phone infoga
:::2011	advanced-real-time-web-reconnaissance	Phone	Advanced-Real-Time-Web-Reconnaissance	2	HTML	https://github.com/Threadlinee/Advanced-Real-Time-Web-Reconnaissance.git	OSINT about Phone numbers, people , ip addresses , websites
:::2012	mrholmes-phone-demo	Phone	mrholmes-phone-demo	2	Shell	https://github.com/ashwithbangera/mrholmes-phone-demo.git	Phone-number information lookup using the Mr.Holmes OSINT tool ethical cybersecurity demo
:::2013	lutkinxp-phoneinfoga	Phone	phoneinfoga	1	Python	https://github.com/Lutkinxp/phoneinfoga.git	The phoneinfoga.py script is designed to gather and display information about a phone number, including its va
:::2014	sherrybrownagent-bit-phoneinfoga	Phone	phoneinfoga	1	-	https://github.com/sherrybrownagent-bit/phoneinfoga.git	This tool gives information about the phone number that you entered
:::2015	maari-krish-phoneinfoga	Phone	Phoneinfoga	1	Python	https://github.com/maari-krish/Phoneinfoga.git	Extract information From Phone Numbers.It has designed with the of a Python
:::2016	frans2456-phoneinfoga	Phone	PhoneInfoga	1	Go	https://github.com/Frans2456/PhoneInfoga.git	Advanced information gathering OSINT framework for phone numbers
:::2017	phoneinfoga-cli-osint	Phone	Phoneinfoga-CLI-OSINT	1	-	https://github.com/Checo132/Phoneinfoga-CLI-OSINT.git	CLI-only build of PhoneInfoga for fast OSINT phone number footprinting and investigation without the web UI
:::2018	darkworm796-email2phonenumber	Phone	email2phonenumber	1	-	https://github.com/darkworm796/email2phonenumber.git	this powfulltool will allow you to pull phone from emails just needs python to be installed
:::2019	phoneinfoga1	Phone	Phoneinfoga1	0	Python	https://github.com/Frans2456/Phoneinfoga1.git	search for data about phone numbers
:::2020	ignorant-phone	Phone	Ignorant---Phone	0	-	https://github.com/Outils-Osint/Ignorant---Phone.git	ignorant allows you to check if a phone number is used on different sites like snapchat, instagram
:::2021	kingsley	Phone	kingsley	0	-	https://github.com/Ulom/kingsley.git	Dear Beneficiary, It's my pleasure to write to everyone that is reading this mail,how are you hope you are goo
:::2022	anthropic-cybersecurity-skills	Threat Intel	Anthropic-Cybersecurity-Skills	33036	Python	https://github.com/mukul975/Anthropic-Cybersecurity-Skills.git	817 structured cybersecurity skills for AI agents Mapped to 6 frameworks: MITRE ATT CK, NIST CSF 2.0, MITRE AT
:::2023	radare2	Threat Intel	radare2	24837	C	https://github.com/radareorg/radare2.git	UNIX-like reverse engineering framework and command-line toolset
:::2024	wifiphisher	Threat Intel	wifiphisher	14852	Python	https://github.com/wifiphisher/wifiphisher.git	The Rogue Access Point Framework
:::2025	opencti	Threat Intel	opencti	10023	TypeScript	https://github.com/OpenCTI-Platform/opencti.git	Open Cyber Threat Intelligence Platform
:::2026	databend	Threat Intel	databend	9446	Rust	https://github.com/databendlabs/databend.git	Data Agent Ready Warehouse : One for Analytics, Search, AI, Python Sandbox. rebuilt from scratch. Unified arch
:::2027	misp	Threat Intel	MISP	6544	PHP	https://github.com/MISP/MISP.git	MISP core software - Open Source Threat Intelligence and Sharing Platform
:::2028	capa	Threat Intel	capa	6192	Python	https://github.com/mandiant/capa.git	The FLARE team's open-source tool to identify capabilities in executable files
:::2029	intelowl	Threat Intel	IntelOwl	4725	Python	https://github.com/intelowlproject/IntelOwl.git	IntelOwl: manage your Threat Intelligence at scale
:::2030	volatility3	Threat Intel	volatility3	4410	Python	https://github.com/volatilityfoundation/volatility3.git	Volatility 3.0 development
:::2031	osint-brazuca	Threat Intel	osint-brazuca	2730	Python	https://github.com/osintbrazuca/osint-brazuca.git	Repositrio criado com intuito de reunir informaes, fonteswebsites/portais e tricks de OSINT dentro do contex
:::2032	aisoc	Threat Intel	AiSOC	2359	Python	https://github.com/beenuar/AiSOC.git	Open-source AI-powered Security Operations Center alert fusion, purple-team drills, agent-assisted triage, MIT
:::2033	mitaka	Threat Intel	mitaka	1863	TypeScript	https://github.com/ninoseki/mitaka.git	A browser extension for OSINT search
:::2034	phishing_catcher	Threat Intel	phishing_catcher	1823	Python	https://github.com/x0rz/phishing_catcher.git	Phishing catcher using Certstream
:::2035	investigations	Threat Intel	investigations	1701	Python	https://github.com/AmnestyTech/investigations.git	Indicators of Compromise from Amnesty International's cyber investigations
:::2036	sysmontools	Threat Intel	SysmonTools	1664	TypeScript	https://github.com/nshalabi/SysmonTools.git	Utilities for Sysmon
:::2037	cve-mcp-server	Threat Intel	cve-mcp-server	1579	Python	https://github.com/mukul975/cve-mcp-server.git	Production-grade MCP server giving Claude 27 security intelligence tools across 21 APIs CVE lookup, EPSS scori
:::2038	flare-learning-hub	Threat Intel	flare-learning-hub	1469	JavaScript	https://github.com/mandiant/flare-learning-hub.git	Free educational content on reverse engineering and malware analysis from the FLARE team
:::2039	ransomware-tool-matrix	Threat Intel	Ransomware-Tool-Matrix	1447	-	https://github.com/BushidoUK/Ransomware-Tool-Matrix.git	A resource containing all the tools each ransomware gangs uses
:::2040	pocindex	Threat Intel	pocindex	1409	Python	https://github.com/0xMarcio/pocindex.git	Search 82,000+ public CVE proof-of-concept exploits from GitHub, Nuclei, ExploitDB, Metasploit and Vulhub
:::2041	watcher	Threat Intel	Watcher	1383	JavaScript	https://github.com/thalesgroup-cert/Watcher.git	Watcher - Open Source AI-powered Cyber Threat Intelligence Hunting Platform. Developed with Django React JS
:::2042	usbvalve	Threat Intel	USBvalve	1346	C	https://github.com/cecio/USBvalve.git	Expose USB activity on the fly
:::2043	harpoon	Threat Intel	harpoon	1292	Python	https://github.com/Te-k/harpoon.git	CLI tool for open source and threat intelligence
:::2044	attackgen	Threat Intel	attackgen	1243	Python	https://github.com/mrwadams/attackgen.git	AttackGen is a cybersecurity incident response testing tool that leverages the power of large language models 
:::2045	malcom	Threat Intel	malcom	1173	Python	https://github.com/tomchop/malcom.git	Malcom - Malware Communications Analyzer
:::2046	ceh-in-bullet-points	Threat Intel	CEH-in-bullet-points	1171	-	https://github.com/undergroundwires/CEH-in-bullet-points.git	Certified ethical hacker summary in bullet points
:::2047	airecon	Threat Intel	airecon	1062	Python	https://github.com/pikpikcu/airecon.git	AIRecon is an autonomous cybersecurity agent that combines a self-hosted Large Language Model Ollama with a 
:::2048	osint-brazuca-regex	Threat Intel	osint-brazuca-regex	1012	Python	https://github.com/osintbrazuca/osint-brazuca-regex.git	Repositrio criado com intuito de reunir expresses regulares dentro do contexto Brasil
:::2049	open-source-threat-intel-feeds	Threat Intel	Open-Source-Threat-Intel-Feeds	948	Python	https://github.com/Bert-JanP/Open-Source-Threat-Intel-Feeds.git	This repository contains Open Source freely usable Threat Intel feeds that can be used without additional requ
:::2050	osint_toolkit	Threat Intel	osint_toolkit	945	JavaScript	https://github.com/dev-lu/osint_toolkit.git	Open source platform for cyber security analysts with many features for threat intelligence and detection engi
:::2051	mihari	Threat Intel	mihari	944	Ruby	https://github.com/ninoseki/mihari.git	A query aggregator for OSINT based threat hunting
:::2052	osint-bible	Threat Intel	OSINT-BIBLE	927	-	https://github.com/frangelbarrera/OSINT-BIBLE.git	Comprehensive 2026 OSINT guide 450+ tools, AI intelligence, methodologies ethics across 35 sections for invest
:::2053	open-source-tools-for-cti	Threat Intel	Open-source-tools-for-CTI	832	-	https://github.com/BushidoUK/Open-source-tools-for-CTI.git	Public Repository of Open Source Tools for Cyber Threat Intelligence Analysts and Researchers
:::2054	klara	Threat Intel	klara	728	PHP	https://github.com/KasperskyLab/klara.git	Kaspersky's GReAT KLara
:::2055	cyberbro	Threat Intel	cyberbro	687	Python	https://github.com/stanfrbd/cyberbro.git	A simple application that extracts your IoCs from garbage input and checks their reputation using multiple CTI
:::2056	ransomlook	Threat Intel	RansomLook	669	Python	https://github.com/RansomLook/RansomLook.git	Yet another Ransomware gang tracker
:::2057	ebpf-guide	Threat Intel	eBPF-Guide	660	Go	https://github.com/mikeroyal/eBPF-Guide.git	eBPF extended Berkeley Packet Filter Guide. Learn all about the eBPF Tools and Libraries for Security, Monit
:::2058	misp-warninglists	Threat Intel	misp-warninglists	650	Python	https://github.com/MISP/misp-warninglists.git	Warning lists to inform users of MISP about potential false-positives or other information in indicators
:::2059	rita	Threat Intel	rita	641	Go	https://github.com/activecm/rita.git	Real Intelligence Threat Analytics RITA is a framework for detecting command and control communication throu
:::2060	patrowlmanager	Threat Intel	PatrowlManager	639	HTML	https://github.com/Patrowl/PatrowlManager.git	PatrOwl - Open Source, Smart and Scalable Security Operations Orchestration Platform
:::2061	misp-galaxy	Threat Intel	misp-galaxy	639	Python	https://github.com/MISP/misp-galaxy.git	Clusters and elements to attach to MISP events or attributes like threat actors
:::2062	nebula	Threat Intel	Nebula	635	Python	https://github.com/gl4ssesbo1/Nebula.git	Nebula is a cloud C2 Framework, which at the moment offers reconnaissance, enumeration, exploitation, post exp
:::2063	malware-sample-sources	Threat Intel	Malware-Sample-Sources	633	-	https://github.com/Virus-Samples/Malware-Sample-Sources.git	Malware Sample Sources
:::2064	iocextract	Threat Intel	iocextract	584	Python	https://github.com/pedramamini/iocextract.git	Defanged Indicator of Compromise IOC Extractor
:::2065	utmstack	Threat Intel	UTMStack	582	TypeScript	https://github.com/utmstack/UTMStack.git	Enterprise-ready SIEM, SOAR and Compliance powered by real-time correlation and threat intelligence
:::2066	connectors	Threat Intel	connectors	581	Python	https://github.com/OpenCTI-Platform/connectors.git	OpenCTI Connectors
:::2067	scrummage	Threat Intel	Scrummage	543	Python	https://github.com/matamorphosis/Scrummage.git	A Holistic OSINT and Threat Hunting Platform
:::2068	malconfscan	Threat Intel	MalConfScan	498	Python	https://github.com/JPCERTCC/MalConfScan.git	Volatility plugin for extracts configuration data of known malware
:::2069	whoyoucalling	Threat Intel	WhoYouCalling	479	C#	https://github.com/H4NM/WhoYouCalling.git	Records an executable's network activity into a Full Packet Capture file .pcap and much more
:::2070	ioc	Threat Intel	ioc	459	C	https://github.com/gendigitalinc/ioc.git	Threat Intel IoCs + bits and pieces of dark matter. Published by Gen Threat Labs
:::2071	baitroute	Threat Intel	baitroute	438	Go	https://github.com/utkusen/baitroute.git	A web honeypot library to create vulnerable-looking endpoints to detect and mislead attackers
:::2072	soc-multitool	Threat Intel	SOC-Multitool	422	JavaScript	https://github.com/zdhenard42/SOC-Multitool.git	A powerful and user-friendly browser extension that streamlines investigations for security professionals
:::2073	threatactors-ttps	Threat Intel	ThreatActors-TTPs	415	-	https://github.com/crocodyli/ThreatActors-TTPs.git	Repository created to share information about tactics, techniques and procedures used by threat actors. Initia
:::2074	ghost	Threat Intel	ghost	391	Rust	https://github.com/pandaadir05/ghost.git	Detects process injection and memory manipulation used by malware. Finds RWX regions, shellcode patterns, API 
:::2075	agentic-threat-hunting-framework	Threat Intel	agentic-threat-hunting-framework	375	Python	https://github.com/Nebulock-Inc/agentic-threat-hunting-framework.git	ATHF is a framework for agentic threat hunting - building systems that can remember, learn, and act with incre
:::2076	ransomware-live	Threat Intel	ransomware.live	364	Python	https://github.com/JMousqueton/ransomware.live.git	Another Ransomware gang tracker
:::2077	malware-feed	Threat Intel	Malware-Feed	363	Shell	https://github.com/MalwareSamples/Malware-Feed.git	Bringing you the best of the worst files on the Internet
:::2078	crowdsec-blocklist-import	Threat Intel	crowdsec-blocklist-import	362	Python	https://github.com/wolffcatskyy/crowdsec-blocklist-import.git	10-20x more blocks for your CrowdSec bouncers 120k+ IPs from 36 free threat feeds
:::2079	omnibus	Threat Intel	omnibus	357	Python	https://github.com/InQuest/omnibus.git	The OSINT Omnibus beta release
:::2080	hearth	Threat Intel	HEARTH	345	HTML	https://github.com/THORCollective/HEARTH.git	A community-driven repository for threat hunting ideas, methodologies, and research that serves as a central g
:::2081	cradle	Threat Intel	cradle	343	JavaScript	https://github.com/prodaft/cradle.git	CRADLE is a collaborative platform for Cyber Threat Intelligence analysts. It streamlines threat investigation
:::2082	kestrel-lang	Threat Intel	kestrel-lang	325	Python	https://github.com/opencybersecurityalliance/kestrel-lang.git	Kestrel threat hunting language: building reusable, composable, and shareable huntflows across different data 
:::2083	lyrie-ai	Threat Intel	lyrie-ai	324	TypeScript	https://github.com/OTT-Cybersecurity-LLC/lyrie-ai.git	Lyrie.ai The world's first autonomous AI cybersecurity agent. Built by OTT Cybersecurity LLC
:::2084	xrefer	Threat Intel	xrefer	322	Python	https://github.com/mandiant/xrefer.git	FLARE Team's Binary Navigator
:::2085	malware-ioc	Threat Intel	malware-ioc	320	Python	https://github.com/prodaft/malware-ioc.git	This repository contains indicators of compromise IOCs of our various investigations
:::2086	osweep	Threat Intel	OSweep	319	Python	https://github.com/ecstatic-nobel/OSweep.git	Don't Just Search OSINT. Sweep It
:::2087	elemental	Threat Intel	Elemental	318	HTML	https://github.com/Elemental-attack/Elemental.git	Elemental - An ATT CK Threat Library
:::2088	androidqf	Threat Intel	androidqf	310	Go	https://github.com/botherder/androidqf.git	androidqf Android Quick Forensics helps quickly gathering forensic evidence from Android devices, in order t
:::2089	mindmaps	Threat Intel	MindMaps	307	-	https://github.com/nasbench/MindMaps.git	#ThreatHunting #DFIR #Malware #Detection Mind Maps
:::2090	clawdstrike	Threat Intel	clawdstrike	288	TypeScript	https://github.com/backbay-labs/clawdstrike.git	Agentic AI EDR for developer workstations and autonomous agent swarms. Build Swarm Detection Response platform
:::2091	microsoft-sentinel-secops	Threat Intel	Microsoft-Sentinel-SecOps	268	PowerShell	https://github.com/eshlomo1/Microsoft-Sentinel-SecOps.git	Microsoft Sentinel SOC Operations
:::2092	stix-shifter	Threat Intel	stix-shifter	265	Python	https://github.com/opencybersecurityalliance/stix-shifter.git	This project consists of an open source library allowing software to connect to data repositories using STIX P
:::2093	threat-hunting	Threat Intel	Threat-Hunting	261	-	https://github.com/sapphirex00/Threat-Hunting.git	Personal compilation of APT malware from whitepaper releases, documents and own research
:::2094	favihunter	Threat Intel	favihunter	257	Python	https://github.com/eremit4/favihunter.git	Discover and monitor internet assets using favicon hashes across search engines
:::2095	scot	Threat Intel	scot	254	JavaScript	https://github.com/sandialabs/scot.git	Sandia Cyber Omni Tracker SCOT
:::2096	cloudintel	Threat Intel	CloudIntel	251	-	https://github.com/unknownhad/CloudIntel.git	This repo contains IOC, malware and malware analysis associated with Public cloud
:::2097	autonomousthreatsweeper	Threat Intel	AutonomousThreatSweeper	246	-	https://github.com/Securonix/AutonomousThreatSweeper.git	Threat Hunting queries for various attacks
:::2098	patrowlengines	Threat Intel	PatrowlEngines	244	Python	https://github.com/Patrowl/PatrowlEngines.git	PatrOwl - Open Source, Free and Scalable Security Operations Orchestration Platform
:::2099	kitphishr	Threat Intel	kitphishr	235	Go	https://github.com/cybercdh/kitphishr.git	A tool designed to hunt for Phishing Kit source code
:::2100	ida-skill	Threat Intel	IDA-Skill	232	Python	https://github.com/miunasu/IDA-Skill.git	skill AI Agent AI Agent skill for automated malware analysis using IDA Pro
:::2101	docker-misp	Threat Intel	docker-misp	228	Shell	https://github.com/coolacid/docker-misp.git	A nearly production ready Dockered MISP
:::2102	misp-dashboard	Threat Intel	misp-dashboard	218	JavaScript	https://github.com/MISP/misp-dashboard.git	A live dashboard for a real-time overview of threat intelligence from MISP instances
:::2103	secbert	Threat Intel	SecBERT	213	Python	https://github.com/jackaduma/SecBERT.git	pretrained BERT model for cyber security text, learned CyberSecurity Knowledge
:::2104	greedybear	Threat Intel	GreedyBear	203	Python	https://github.com/GreedyBear-Project/GreedyBear.git	Threat Intel Platform for T-POTs
:::2105	lenspect	Threat Intel	lenspect	202	Python	https://github.com/vmkspv/lenspect.git	A lightweight security threat scanner intended to make malware detection more accessible and efficient
:::2106	favicorn	Threat Intel	favicorn	197	Python	https://github.com/sharsil/favicorn.git	All-sources tool to search websites by favicons
:::2107	the-art-of-pivoting	Threat Intel	the-art-of-pivoting	190	HTML	https://github.com/adulau/the-art-of-pivoting.git	The Art of Pivoting - Techniques for Intelligence Analysts to Discover New Relationships in a Complex World
:::2108	misp-maltego	Threat Intel	MISP-maltego	186	Python	https://github.com/MISP/MISP-maltego.git	Set of Maltego transforms to inferface with a MISP Threat Sharing instance, and also to explore the whole MITR
:::2109	hunting-rules	Threat Intel	hunting-rules	183	-	https://github.com/travisbgreen/hunting-rules.git	Suricata rules for network anomaly detection
:::2110	pygreynoise	Threat Intel	pygreynoise	177	Python	https://github.com/GreyNoise-Intelligence/pygreynoise.git	Python3 library and command line for GreyNoise
:::2111	kc7	Threat Intel	kc7	176	Python	https://github.com/KC7-Foundation/kc7.git	A cybersecurity game in Azure Data Explorer
:::2112	sweetie-data	Threat Intel	sweetie-data	174	-	https://github.com/0xsha/sweetie-data.git	This repo contains logstash of various honeypots
:::2113	threatintel-reports	Threat Intel	ThreatIntel-Reports	172	Python	https://github.com/mthcht/ThreatIntel-Reports.git	Raw data from Threat Intelligence Reports with automatic reports collection and keyword search across thousand
:::2114	docintel	Threat Intel	DocIntel	171	JavaScript	https://github.com/docintelapp/DocIntel.git	Open Source Platform for storing, organizing, and searching documents related to cyber threats
:::2115	typedb-cti	Threat Intel	typedb-cti	170	Python	https://github.com/typedb-osi/typedb-cti.git	Open Source Threat Intelligence Platform
:::2116	mthc	Threat Intel	mthc	168	-	https://github.com/pe3zx/mthc.git	All-in-one bundle of MISP, TheHive and Cortex
:::2117	patrowlhears	Threat Intel	PatrowlHears	167	Python	https://github.com/Patrowl/PatrowlHears.git	PatrowlHears - Vulnerability Intelligence Center / Exploits
:::2118	threat-intel	Threat Intel	Threat-Intel	165	Python	https://github.com/davidonzo/Threat-Intel.git	Threat-Intel repository. API: https://github.com/davidonzo/apiosintDS
:::2119	pcap-hunter	Threat Intel	pcap-hunter	164	Python	https://github.com/ninedter/pcap-hunter.git	AI-assisted threat-hunting workbench for SOC and DFIR analysts turns raw PCAPs into actionable intel with a Ze
:::2120	ai_for_the_win	Threat Intel	ai_for_the_win	161	Python	https://github.com/depalmar/ai_for_the_win.git	Build AI-powered security tools. 50+ hands-on labs covering ML, LLMs, RAG, threat detection, DFIR, and red tea
:::2121	resource-threat-hunting	Threat Intel	resource-threat-hunting	160	-	https://github.com/SoulSec/resource-threat-hunting.git	Repository resource for threat hunter
:::2122	subcrawl	Threat Intel	subcrawl	150	Python	https://github.com/hpthreatresearch/subcrawl.git	SubCrawl is a modular framework for discovering open directories, identifying unique content through signature
:::2123	patrowldocs	Threat Intel	PatrowlDocs	149	HTML	https://github.com/Patrowl/PatrowlDocs.git	PatrOwl - Open Source, Free and Scalable Security Operations Orchestration Platform
:::2124	mcp-virustotal	Threat Intel	mcp-virustotal	149	TypeScript	https://github.com/w0h1v/mcp-virustotal.git	MCP server for VirusTotal API analyze URLs, files, IPs, and domains with comprehensive security reports, relat
:::2125	controlcompass-github-io	Threat Intel	ControlCompass.github.io	143	JavaScript	https://github.com/ControlCompass/ControlCompass.github.io.git	Pointing cybersecurity teams to thousands of detection rules and offensive security tests aligned with common 
:::2126	pyc2bytecode	Threat Intel	pyc2bytecode	143	Python	https://github.com/knight0x07/pyc2bytecode.git	A Python Bytecode Disassembler helping reverse engineers in dissecting Python binaries by disassembling and an
:::2127	deceptifeed	Threat Intel	deceptifeed	141	Go	https://github.com/r-smith/deceptifeed.git	Honeypot servers with an integrated threat feed
:::2128	cvemapping	Threat Intel	cvemapping	139	Python	https://github.com/rix4uni/cvemapping.git	This repo Gathers all available cve exploits from github. Be careful Malware
:::2129	public-intelligence-feeds	Threat Intel	Public-Intelligence-Feeds	133	-	https://github.com/CriticalPathSecurity/Public-Intelligence-Feeds.git	Standard-Format Threat Intelligence Feeds
:::2130	shonydanza	Threat Intel	ShonyDanza	121	Python	https://github.com/fierceoj/ShonyDanza.git	A customizable, easy-to-navigate tool for researching, pen testing, and defending with the power of Shodan
:::2131	sexettintool	Threat Intel	sexettintool	89	Python	https://github.com/sexettin78/sexettintool.git	erisinde 100'den fazla modl ve zellii barndran ok amal bir siber gvenlik arac
:::2132	ceh	Threat Intel	CEH	87	-	https://github.com/Brute-f0rce/CEH.git	Exam Prep for the Ec-council Certified Ethical Hacker 312-50
:::2133	osint-agent-skills	Threat Intel	osint-agent-skills	30	JavaScript	https://github.com/frangelbarrera/osint-agent-skills.git	OSINT knowledge base + MCP server for autonomous AI agents Claude Code, Cursor, Kimi K3, recon threat intel pl
:::2134	threatlens	Threat Intel	ThreatLens	24	Python	https://github.com/AbdaullahAG/ThreatLens.git	Python CLI tool for rapid IOC analysis IPs, Domains, CVEs using 6 free Threat Intel APIs. Outputs: Color-cod
:::2135	secubian	Threat Intel	secubian	6	Python	https://github.com/kidrek/secubian.git	SECUBIAN is a French Linux distribution focused on evidence processing during Incident Response
:::2136	miguna-exploit-toolkit	Threat Intel	Miguna-exploit-toolkit	5	Shell	https://github.com/Almsuni/Miguna-exploit-toolkit.git	Miguna exploit toolkit is amassive exploiting tool : Easy tool to generate backdoor and easy tool to post expl
:::2137	tiq	Threat Intel	tiq	5	Python	https://github.com/evgind/tiq.git	Command-line threat intel lookups. Query IPs, domains, URLs and hashes across VirusTotal, OTX, AbuseIPDB, MISP
:::2138	firecrawl	Web Extract / Scrape	firecrawl	182573	TypeScript	https://github.com/firecrawl/firecrawl.git	The web data API to search, scrape, and interact at scale
:::2139	scrapegraph-ai	Web Extract / Scrape	Scrapegraph-ai	31151	Python	https://github.com/ScrapeGraphAI/Scrapegraph-ai.git	Python scraper based on AI
:::2140	crawlee	Web Extract / Scrape	crawlee	25853	TypeScript	https://github.com/apify/crawlee.git	CrawleeA web scraping and browser automation library for Node.js to build reliable crawlers. In JavaScript and
:::2141	stagehand	Web Extract / Scrape	stagehand	24644	TypeScript	https://github.com/browserbase/stagehand.git	The SDK to extract data and interact with any site on the web. Get started with Claude Code, Codex, Eve, Mastr
:::2142	maxun	Web Extract / Scrape	maxun	17512	TypeScript	https://github.com/getmaxun/maxun.git	Turn any website into a structured API. Extract, automate, search and monitor the web
:::2143	photon	Web Extract / Scrape	Photon	13218	Python	https://github.com/s0md3v/Photon.git	Incredibly fast crawler designed for OSINT
:::2144	crawlab	Web Extract / Scrape	crawlab	12273	Go	https://github.com/crawlab-team/crawlab.git	Distributed web crawler admin platform for spiders management regardless of languages and frameworks
:::2145	crawlee-python	Web Extract / Scrape	crawlee-python	9540	Python	https://github.com/apify/crawlee-python.git	CrawleeA web scraping and browser automation library for Python to build reliable crawlers. Extract data for A
:::2146	firecrawl-mcp-server	Web Extract / Scrape	firecrawl-mcp-server	7491	JavaScript	https://github.com/firecrawl/firecrawl-mcp-server.git	Official Firecrawl MCP Server - Adds powerful web scraping and search to Cursor, Claude and any other LLM clie
:::2147	wigolo	Web Extract / Scrape	wigolo	5346	TypeScript	https://github.com/KnockOutEZ/wigolo.git	The go-to web for your AI coding agent local-first search, fetch, crawl research over MCP. No API keys, no clo
:::2148	torbot	Web Extract / Scrape	TorBot	4915	Python	https://github.com/DedSecInside/TorBot.git	Dark Web OSINT Tool
:::2149	design-extract	Web Extract / Scrape	design-extract	4122	HTML	https://github.com/Manavarya09/design-extract.git	Extract any website's complete design system with one command. DTCG tokens, semantic+primitive+composite, MCP 
:::2150	oletools	Web Extract / Scrape	oletools	3418	Python	https://github.com/decalage2/oletools.git	oletools - python tools to analyze MS OLE2 files Structured Storage, Compound File Binary Format and MS Offi
:::2151	amazon-scraper	Web Extract / Scrape	amazon-scraper	3395	Python	https://github.com/oxylabs/amazon-scraper.git	Free Trial Amazon Scraper API for extracting search, product, offer listing, reviews, question and answers, be
:::2152	nutch	Web Extract / Scrape	nutch	3292	Java	https://github.com/apache/nutch.git	Apache Nutch is an extensible and scalable web crawler
:::2153	how-to-scrape-amazon-product-data	Web Extract / Scrape	how-to-scrape-amazon-product-data	3256	-	https://github.com/oxylabs/how-to-scrape-amazon-product-data.git	The process of extracting product data from Amazon using Python, including titles, ratings, prices, images, an
:::2154	spider	Web Extract / Scrape	spider	2724	Rust	https://github.com/spider-rs/spider.git	Foundational low latency web data collecting in Rust
:::2155	webclaw	Web Extract / Scrape	webclaw	2353	Rust	https://github.com/0xMassi/webclaw.git	Fast, local-first web content extraction for LLMs. Scrape, crawl, extract structured data all from Rust. CLI, 
:::2156	abot	Web Extract / Scrape	abot	2309	C#	https://github.com/sjdirect/abot.git	Cross Platform C# web crawler framework built for speed and flexibility. Please star this project +1
:::2157	moli	Web Extract / Scrape	moli	2148	Rust	https://github.com/lexmount/moli.git	Best headless browser for AI agents. Lite, Fast, High-Compatibility. Built in Rust
:::2158	how-to-scrape-amazon-prices	Web Extract / Scrape	how-to-scrape-amazon-prices	2091	Python	https://github.com/oxylabs/how-to-scrape-amazon-prices.git	A code for extracting best-selling items, search results, and currently available deals from Amazon using Pyth
:::2159	browserless	Web Extract / Scrape	browserless	1836	JavaScript	https://github.com/microlinkhq/browserless.git	The headless Chrome/Chromium driver on top of Puppeteer. Take screenshots, generate PDFs, extract text and HTM
:::2160	pspider	Web Extract / Scrape	PSpider	1834	Python	https://github.com/xianhu/PSpider.git	PythonQQ597510560
:::2161	blackwidow	Web Extract / Scrape	BlackWidow	1823	Python	https://github.com/1N3/BlackWidow.git	A Python based web application scanner to gather OSINT and fuzz for OWASP vulnerabilities on a target website
:::2162	single-file-cli	Web Extract / Scrape	single-file-cli	1622	JavaScript	https://github.com/gildas-lormeau/single-file-cli.git	CLI tool for saving a faithful copy of a complete web page in a single HTML file based on SingleFile
:::2163	batfish	Web Extract / Scrape	batfish	1478	Java	https://github.com/batfish/batfish.git	Batfish is a network configuration analysis tool that can find bugs and guarantee the correctness of planned 
:::2164	agentql	Web Extract / Scrape	agentql	1463	Python	https://github.com/tinyfish-io/agentql.git	AgentQL is a suite of tools for connecting your AI to the web. Featuring a query language and Playwright integ
:::2165	how-to-scrape-google-finance	Web Extract / Scrape	how-to-scrape-google-finance	1403	Python	https://github.com/oxylabs/how-to-scrape-google-finance.git	Use Web Scraper API to extract data from Google Finance, including stock titles, pricing, and price changes in
:::2166	linkinator	Web Extract / Scrape	linkinator	1263	TypeScript	https://github.com/JustinBeckwith/linkinator.git	Broken link checker that crawls websites and validates links. Find broken links, dead links, and invalid URLs 
:::2167	browsertrix-crawler	Web Extract / Scrape	browsertrix-crawler	1143	TypeScript	https://github.com/webrecorder/browsertrix-crawler.git	Run a high-fidelity browser-based web archiving crawler in a single Docker container
:::2168	crw	Web Extract / Scrape	crw	1057	Rust	https://github.com/us/crw.git	Fast, lightweight Firecrawl/Tavily alternative in Rust. Web scraper, crawler search API with MCP server for AI
:::2169	stormcrawler	Web Extract / Scrape	stormcrawler	996	Java	https://github.com/apache/stormcrawler.git	A scalable, mature and versatile web crawler based on Apache Storm
:::2170	librecrawl	Web Extract / Scrape	LibreCrawl	969	Python	https://github.com/PhialsBasement/LibreCrawl.git	Free desktop SEO crawler - open source alternative to Screaming Frog and similar tools. Crawl websites, analyz
:::2171	threatingestor	Web Extract / Scrape	ThreatIngestor	930	Python	https://github.com/pedramamini/ThreatIngestor.git	Extract and aggregate threat intelligence
:::2172	nfdump	Web Extract / Scrape	nfdump	921	C	https://github.com/phaag/nfdump.git	Netflow processing tools
:::2173	satintel	Web Extract / Scrape	SatIntel	900	Go	https://github.com/ANG13T/SatIntel.git	SatIntel is an OSINT tool for Satellites . Extract satellite telemetry, receive orbital predictions, and parse
:::2174	getjs	Web Extract / Scrape	getJS	900	Go	https://github.com/003random/getJS.git	A tool to fastly get all javascript sources/files
:::2175	apk2url	Web Extract / Scrape	apk2url	883	Shell	https://github.com/n0mi1k/apk2url.git	An OSINT tool to quickly extract IP and URL endpoints from APKs by disassembling and decompiling
:::2176	above	Web Extract / Scrape	Above	871	Python	https://github.com/caster0x00/Above.git	Network Security Sniffer
:::2177	spidr	Web Extract / Scrape	spidr	836	Ruby	https://github.com/postmodern/spidr.git	A versatile Ruby web spidering library that can spider a site, multiple domains, certain links or infinitely. 
:::2178	uscrapper	Web Extract / Scrape	Uscrapper	798	Python	https://github.com/z0m31en7/Uscrapper.git	Uscrapper Vanta: Dive deeper into the web with this powerful open-source tool. Extract valuable insights with 
:::2179	killshot	Web Extract / Scrape	killshot	784	Ruby	https://github.com/bahaabdelwahed/killshot.git	A Penetration Testing Framework, Information gathering tool Website Vulnerability Scanner
:::2180	python-evtx	Web Extract / Scrape	python-evtx	781	Python	https://github.com/williballenthin/python-evtx.git	Pure Python parser for Windows Event Log files .evtx
:::2181	craw4llm	Web Extract / Scrape	Craw4LLM	665	Python	https://github.com/cxcscmu/Craw4LLM.git	Official repository for Craw4LLM: Efficient Web Crawling for LLM Pretraining
:::2182	lead-generation	Web Extract / Scrape	Lead-Generation	657	Python	https://github.com/Madi-S/Lead-Generation.git	Python script, which empowers people with no programming background to generate robust leads on a mass scale. 
:::2183	stealth-requests	Web Extract / Scrape	Stealth-Requests	564	Python	https://github.com/jpjacobpadilla/Stealth-Requests.git	Undetected web-scraping seamless HTML parsing in Python
:::2184	icp-checker	Web Extract / Scrape	ICP-Checker	563	Python	https://github.com/wongzeon/ICP-Checker.git	ICPICPExcel*VIP
:::2185	reader	Web Extract / Scrape	reader	562	TypeScript	https://github.com/vakra-dev/reader.git	Open source web infrastructure for AI. Scrape, crawl, and automate the web, clean markdown, browser sessions, 
:::2186	whatsapp-key-database-extractor	Web Extract / Scrape	WhatsApp-Key-Database-Extractor	560	Python	https://github.com/YuvrajRaghuvanshiS/WhatsApp-Key-Database-Extractor.git	The most advanced and complete solution for extracting WhatsApp key/DB from package directory /data/data/com.
:::2187	edgar-crawler	Web Extract / Scrape	edgar-crawler	545	Python	https://github.com/lefterisloukas/edgar-crawler.git	The only open-source toolkit that can download SEC EDGAR financial reports and extract textual data from speci
:::2188	torcrawl-py	Web Extract / Scrape	TorCrawl.py	539	Python	https://github.com/MikeMeliz/TorCrawl.py.git	Crawl and extract regular or onion webpages through TOR network
:::2189	scrapple	Web Extract / Scrape	scrapple	504	Python	https://github.com/AlexMathew/scrapple.git	A framework for creating semi-automatic web content extractors
:::2190	kochat	Web Extract / Scrape	kochat	462	Python	https://github.com/hyunwoongko/kochat.git	Opensource Korean chatbot framework
:::2191	scrapehero-code-amazon-scraper	Web Extract / Scrape	amazon-scraper	443	Python	https://github.com/scrapehero-code/amazon-scraper.git	A simple web scraper to extract Product Data and Pricing from Amazon
:::2192	zeno	Web Extract / Scrape	Zeno	425	Go	https://github.com/internetarchive/Zeno.git	State-of-the-art web crawler
:::2193	sparkler	Web Extract / Scrape	sparkler	419	Python	https://github.com/chrismattmann/sparkler.git	A crawl workstation: View, Control, and Crawl. Solr CrawlDB, Tika, Vue 3
:::2194	webpalm	Web Extract / Scrape	webpalm	382	Go	https://github.com/XORbit01/webpalm.git	Crawl in the web network
:::2195	supercrawler	Web Extract / Scrape	supercrawler	382	JavaScript	https://github.com/brendonboshell/supercrawler.git	A web crawler. Supercrawler automatically crawls websites. Define custom handlers to parse content. Obeys robo
:::2196	graphlit-mcp-server	Web Extract / Scrape	graphlit-mcp-server	381	TypeScript	https://github.com/graphlit/graphlit-mcp-server.git	Model Context Protocol MCP Server for Graphlit Platform
:::2197	google-news-scraper	Web Extract / Scrape	google-news-scraper	379	JavaScript	https://github.com/lewisdonovan/google-news-scraper.git	Lightweight scraper for Google News
:::2198	macos-unifiedlogs	Web Extract / Scrape	macos-UnifiedLogs	377	Rust	https://github.com/mandiant/macos-UnifiedLogs.git	A cross platform parser for Apple UnifiedLogs
:::2199	news-crawl	Web Extract / Scrape	news-crawl	376	Java	https://github.com/commoncrawl/news-crawl.git	News crawling with StormCrawler - stores content as WARC
:::2200	goscrapy	Web Extract / Scrape	goscrapy	372	Go	https://github.com/tech-engine/goscrapy.git	GoScrapy: High perfomance webscraping framework in Go, inspired by Python's Scrapy
:::2201	crawler	Web Extract / Scrape	crawler	371	PHP	https://github.com/crwlrsoft/crawler.git	Library for Rapid Web Crawler and Scraper Development
:::2202	spidy	Web Extract / Scrape	spidy	354	Python	https://github.com/rivermont/spidy.git	The simple, easy to use command line web crawler
:::2203	crawley	Web Extract / Scrape	crawley	340	Go	https://github.com/s0rg/crawley.git	The unix-way web crawler
:::2204	fatcat	Web Extract / Scrape	fatcat	326	C++	https://github.com/Gregwar/fatcat.git	FAT filesystems explore, extract, repair, and forensic tool
:::2205	analyzer	Web Extract / Scrape	analyzer	322	Python	https://github.com/qeeqbox/analyzer.git	Analyze, extract and visualize features, artifacts and IoCs of files and memory dumps Windows, Linux, Android
:::2206	burpsuite-xkeys	Web Extract / Scrape	BurpSuite-Xkeys	314	Python	https://github.com/vsec7/BurpSuite-Xkeys.git	A Burp Suite Extension to extract interesting strings key, secret, token, or etc. from a webpage
:::2207	infinilabs-crawler	Web Extract / Scrape	crawler	311	Go	https://github.com/infinilabs/crawler.git	An easy-to-use spider written in Golang. previous named GOPA.
:::2208	agent-fetch	Web Extract / Scrape	agent-fetch	309	TypeScript	https://github.com/teng-lin/agent-fetch.git	Full-content web fetcher for AI agents Chrome TLS fingerprinting, browser impersonation, multi-strategy articl
:::2209	invtero-net	Web Extract / Scrape	inVtero.net	296	C#	https://github.com/ShaneK2/inVtero.net.git	inVtero.net: A high speed Gbps Forensics, Memory integrity assurance. Includes offensive defensive memory ca
:::2210	mineru-html	Web Extract / Scrape	MinerU-HTML	290	Python	https://github.com/opendatalab/MinerU-HTML.git	MinerU-HTML: An SLM-powered HTML main content extractor that outputs clean HTML bodies. Perfect for Deep Resea
:::2211	ant	Web Extract / Scrape	ant	281	Go	https://github.com/yields/ant.git	A web crawler for Go
:::2212	strong-web-crawler	Web Extract / Scrape	Strong-Web-Crawler	276	C#	https://github.com/microfisher/Strong-Web-Crawler.git	C#.NET+PhantomJS+SelleniumJavascriptDom
:::2213	antch	Web Extract / Scrape	antch	265	Go	https://github.com/antchfx/antch.git	Antch, a fast, powerful and extensible web crawling scraping framework for Go
:::2214	searcharvester	Web Extract / Scrape	searcharvester	263	Python	https://github.com/vakovalskii/searcharvester.git	Self-hosted search + markdown harvester for AI agents. SearXNG 100+ engines + FastAPI + trafilatura. Tavily-
:::2215	lagoujob	Web Extract / Scrape	LagouJob	263	Python	https://github.com/lucasxlu/LagouJob.git	Data Analysis Mining for lagou.com
:::2216	crawler-commons	Web Extract / Scrape	crawler-commons	259	Java	https://github.com/crawler-commons/crawler-commons.git	A set of reusable Java components that implement functionality common to any web crawler
:::2217	infinitycrawler	Web Extract / Scrape	InfinityCrawler	252	C#	https://github.com/TurnerSoftware/InfinityCrawler.git	A simple but powerful web crawler library for .NET
:::2218	scrapemate	Web Extract / Scrape	scrapemate	210	Go	https://github.com/gosom/scrapemate.git	Golang Crawling and scraping framework
:::2219	norconex-crawler	Web Extract / Scrape	crawler	204	Java	https://github.com/Norconex/crawler.git	Norconex Crawlers or spiders are flexible web and filesystem crawlers for collecting, parsing, and manipulat
:::2220	ignareo-isml-auto-voter	Web Extract / Scrape	Ignareo-ISML-auto-voter	194	Python	https://github.com/Hecate2/Ignareo-ISML-auto-voter.git	Ignareo the Carillon, a web crawler/spider template of ultimate high concurrency built for leprechauns. Carill
:::2221	zhihu-crawler-people	Web Extract / Scrape	zhihu-crawler-people	192	Python	https://github.com/elliotxx/zhihu-crawler-people.git	A simple distributed crawler for zhihu data analysis
:::2222	ioc-finder	Web Extract / Scrape	ioc-finder	184	Python	https://github.com/fhightower/ioc-finder.git	Simple, effective, and modular package for parsing observables indicators of compromise IOCs, network data,
:::2223	evine	Web Extract / Scrape	evine	181	Go	https://github.com/saeeddhqan/evine.git	Interactive CLI Web Crawler
:::2224	crawlberg	Web Extract / Scrape	crawlberg	177	Rust	https://github.com/xberg-io/crawlberg.git	High-performance web crawling engine with bindings for 11 languages
:::2225	cewler	Web Extract / Scrape	cewler	164	Python	https://github.com/roys/cewler.git	CeWLeR - Custom Word List generator Redefined. CeWL alternative in Python, based on the Scrapy framework
:::2226	deepfaceui	Web Extract / Scrape	deepfaceui	151	Python	https://github.com/GONZOsint/deepfaceui.git	DeepFace UI is a web application for facial recognition and analysis built with DeepFace. It offers an intuiti
:::2227	gitcolombo	Web Extract / Scrape	gitcolombo	97	Python	https://github.com/soxoj/gitcolombo.git	Extract and analyze contributors info from git repos
:::2228	onion_check	Web Extract / Scrape	onion_check	26	Python	https://github.com/CyberSoldiers/onion_check.git	Handy Tool to check the availability of onion site and to extract the title of submitted onion links
:::2229	hell0	Web Extract / Scrape	Hell0	21	Python	https://github.com/snippray/Hell0.git	Hello Zero helps you extract information about all hardware and software installed on your system and automati
:::2230	snapchat-checker	Web Extract / Scrape	Snapchat-Checker	8	-	https://github.com/OSINT-Trace/Snapchat-Checker.git	Enterprise OSINT API to verify Snapchat account existence extract rich profile intelligence 3D Bitmojis, disp
:::2231	ruby-amass	Web Extract / Scrape	ruby-amass	8	Ruby	https://github.com/postmodern/ruby-amass.git	A Ruby interface to amass
:::2232	zrainerzz-port-scanner	Web Extract / Scrape	Port-Scanner	3	Python	https://github.com/zRainerzz/Port-Scanner.git	A simple Python-based port scanner using the nmap library. This tool scans specified target IP addresses withi
:::2233	k1r-scan-fantom	Web Extract / Scrape	K1R-Scan-fantom	3	Python	https://github.com/k1rpit/K1R-Scan-fantom.git	Network Stalker: Multi-port scanner with automated random IP target selection
:::2234	ghunt-fix	Web Extract / Scrape	ghunt-fix	0	Python	https://github.com/rodrigo47363/ghunt-fix.git	Hotfix and patch for GHunt's people.py parser resolving Google People API schema breaking changes and enterpri
:::2235	simple-firewall-log-parser	Web Extract / Scrape	Simple-Firewall-Log-Parser	0	Python	https://github.com/Kendryck-Garcia/Simple-Firewall-Log-Parser.git	A Python tool that parses firewall logs via Regex and enriches telemetry with IPGeolocation API data. It maps 
:::2236	shodan-ip-extractor	Web Extract / Scrape	Shodan-IP-Extractor	0	Python	https://github.com/XploitPoy-777/Shodan-IP-Extractor.git	A powerful Python-based CLI tool to extract IP addresses from Shodan search results using the official Shodan 
:::2237	iocsift	Web Extract / Scrape	iocsift	0	Python	https://github.com/BL3IP/iocsift.git	Zero-dependency Python CLI to extract enrich IOCs IPs, domains, hashes, CVEs from logs - refang, Shodan Inte
:::2238	gods-eye-view	Geo / Maps	gods-eye-view	39541	JavaScript	https://github.com/bilawalsidhu/gods-eye-view.git	A spy satellite simulator in your browser, except the data is real. Live open source spatial intelligence on a
:::2239	cesium	Geo / Maps	cesium	15758	JavaScript	https://github.com/CesiumGS/cesium.git	An open-source JavaScript library for world-class 3D globes and maps :earth_americas:
:::2240	kepler-gl	Geo / Maps	kepler.gl	12020	TypeScript	https://github.com/keplergl/kepler.gl.git	Kepler.gl is a powerful open source geospatial analysis tool for large-scale data sets
:::2241	turf	Geo / Maps	turf	10491	TypeScript	https://github.com/Turfjs/turf.git	A modular geospatial engine written in JavaScript and TypeScript
:::2242	tile38	Geo / Maps	tile38	9732	Go	https://github.com/tidwall/tile38.git	Real-time Geospatial and Geofencing
:::2243	blendergis	Geo / Maps	BlenderGIS	9400	Python	https://github.com/domlysz/BlenderGIS.git	Blender addons to make the bridge between Blender and geographic data
:::2244	geolibre	Geo / Maps	GeoLibre	7522	TypeScript	https://github.com/opengeos/GeoLibre.git	A lightweight, cloud-native GIS platform for visualizing, exploring, and analyzing geospatial data. It runs in
:::2245	graphhopper	Geo / Maps	graphhopper	6696	Java	https://github.com/graphhopper/graphhopper.git	Open source routing engine for OpenStreetMap. Use it as Java library or standalone web server
:::2246	h3	Geo / Maps	h3	6546	C	https://github.com/uber/h3.git	Hexagonal hierarchical geospatial indexing system
:::2247	redisearch	Geo / Maps	RediSearch	6241	Rust	https://github.com/RediSearch/RediSearch.git	A query and indexing engine for Redis, providing secondary indexing, full-text search, vector similarity searc
:::2248	openfreemap	Geo / Maps	openfreemap	6039	Python	https://github.com/hyperknot/openfreemap.git	Free and open-source map hosting solution with custom styles for websites and apps, using OpenStreetMap data
:::2249	osmnx	Geo / Maps	osmnx	5850	Python	https://github.com/gboeing/osmnx.git	Download, model, analyze, and visualize street networks and other geospatial features from OpenStreetMap
:::2250	geopandas	Geo / Maps	geopandas	5255	Python	https://github.com/geopandas/geopandas.git	Python tools for geographic data
:::2251	calcite	Geo / Maps	calcite	5186	Java	https://github.com/apache/calcite.git	Apache Calcite
:::2252	buntdb	Geo / Maps	buntdb	4870	Go	https://github.com/tidwall/buntdb.git	BuntDB is an embeddable, in-memory key/value database for Go with custom indexing and geospatial support
:::2253	torchgeo	Geo / Maps	torchgeo	4185	Python	https://github.com/torchgeo/torchgeo.git	TorchGeo: datasets, samplers, transforms, and pre-trained models for geospatial data
:::2254	segment-geospatial	Geo / Maps	segment-geospatial	4144	Python	https://github.com/opengeos/segment-geospatial.git	A Python package for segmenting geospatial data with the Segment Anything Model SAM
:::2255	l7	Geo / Maps	L7	4063	TypeScript	https://github.com/antvis/L7.git	Large-scale WebGL-powered Geospatial Data Visualization analysis engine
:::2256	leafmap	Geo / Maps	leafmap	3773	Python	https://github.com/opengeos/leafmap.git	A Python package for interactive mapping and geospatial analysis with minimal coding in a Jupyter environment
:::2257	php-crud-api	Geo / Maps	php-crud-api	3736	PHP	https://github.com/mevdschee/php-crud-api.git	Single file PHP script that adds a REST API to a SQL database
:::2258	geoai	Geo / Maps	geoai	3387	Python	https://github.com/opengeos/geoai.git	GeoAI: Artificial Intelligence for Geospatial Data
:::2259	react-simple-maps	Geo / Maps	react-simple-maps	3337	TypeScript	https://github.com/zcreativelabs/react-simple-maps.git	Composable SVG map charts for data visualization in React
:::2260	headway	Geo / Maps	headway	3000	Rust	https://github.com/headwaymaps/headway.git	Self-hostable maps stack, powered by OpenStreetMap
:::2261	maputnik	Geo / Maps	maputnik	2637	TypeScript	https://github.com/maplibre/maputnik.git	An open source visual editor for the 'MapLibre Style Specification'
:::2262	3dtilesrendererjs	Geo / Maps	3DTilesRendererJS	2470	JavaScript	https://github.com/NASA-AMMOS/3DTilesRendererJS.git	Renderer for 3D Tiles in Javascript using three.js, Babylon.js, and r3f
:::2263	sedona	Geo / Maps	sedona	2412	Java	https://github.com/apache/sedona.git	A cluster computing framework for processing large-scale geospatial data
:::2264	proj4js	Geo / Maps	proj4js	2242	JavaScript	https://github.com/proj4js/proj4js.git	JavaScript library to transform coordinates from one coordinate system to another, including datum transformat
:::2265	raster-vision	Geo / Maps	raster-vision	2242	Python	https://github.com/azavea/raster-vision.git	An open source library and framework for deep learning on satellite and aerial imagery
:::2266	geo	Geo / Maps	geo	1939	Rust	https://github.com/georust/geo.git	Rust geospatial primitives algorithms
:::2267	geotools	Geo / Maps	geotools	1929	Java	https://github.com/geotools/geotools.git	Official GeoTools repository
:::2268	city2graph	Geo / Maps	city2graph	1923	Python	https://github.com/c2g-dev/city2graph.git	Transform geospatial relations into graphs for Graph Neural Networks and spatial network analysis
:::2269	globalthreatmap	Geo / Maps	globalthreatmap	1833	TypeScript	https://github.com/unicodeveloper/globalthreatmap.git	Global threat map. Learn wars, conflicts, military bases and history of nations
:::2270	mapsui	Geo / Maps	Mapsui	1572	C#	https://github.com/Mapsui/Mapsui.git	Mapsui is a .NET Map component for: MAUI, Avalonia, Uno Platform, Blazor, WPF, WinUI, Windows Forms, Eto Forms
:::2271	placemark	Geo / Maps	placemark	1462	TypeScript	https://github.com/placemark/placemark.git	A flexible web-based editor, converter, visualization tool, for geospatial data
:::2272	cesium-unreal	Geo / Maps	cesium-unreal	1240	C++	https://github.com/CesiumGS/cesium-unreal.git	Bringing the 3D geospatial ecosystem to Unreal Engine
:::2273	pyproj	Geo / Maps	pyproj	1227	Python	https://github.com/pyproj4/pyproj.git	Python interface to PROJ cartographic projections and coordinate transformations library
:::2274	mapserver	Geo / Maps	MapServer	1221	C	https://github.com/MapServer/MapServer.git	Source code of the MapServer project. Please submit pull requests to the 'main' branch
:::2275	whitebox-tools	Geo / Maps	whitebox-tools	1205	Rust	https://github.com/jblindsay/whitebox-tools.git	An advanced geospatial data analysis platform
:::2276	paulmach-orb	Geo / Maps	orb	1132	Go	https://github.com/paulmach/orb.git	Types and utilities for working with 2d geometry in Golang
:::2277	ofbiz-framework	Geo / Maps	ofbiz-framework	1124	Java	https://github.com/apache/ofbiz-framework.git	Apache OFBiz is an open source product for the automation of enterprise processes. It includes framework compo
:::2278	geoparquet	Geo / Maps	geoparquet	1090	Python	https://github.com/opengeospatial/geoparquet.git	Specification for storing geospatial vector data point, line, polygon in Parquet
:::2279	h3-js	Geo / Maps	h3-js	1085	JavaScript	https://github.com/uber/h3-js.git	h3-js provides a JavaScript version of H3, a hexagon-based geospatial indexing system
:::2280	h3-py	Geo / Maps	h3-py	1038	Python	https://github.com/uber/h3-py.git	Python bindings for H3, a hierarchical hexagonal geospatial indexing system
:::2281	streamlit-geospatial	Geo / Maps	streamlit-geospatial	1029	Python	https://github.com/opengeos/streamlit-geospatial.git	A multi-page streamlit app for geospatial
:::2282	webworldwind	Geo / Maps	WebWorldWind	1002	JavaScript	https://github.com/NASAWorldWind/WebWorldWind.git	The NASA WorldWind Javascript SDK WebWW includes the library and examples for creating geo-browser web appli
:::2283	geospatial-wheels	Geo / Maps	geospatial-wheels	986	-	https://github.com/cgohlke/geospatial-wheels.git	Geospatial library wheels for Python on Windows
:::2284	gmt	Geo / Maps	gmt	981	C	https://github.com/GenericMappingTools/gmt.git	The Generic Mapping Tools
:::2285	go-geom	Geo / Maps	go-geom	976	Go	https://github.com/twpayne/go-geom.git	Package geom implements efficient geometry types for geospatial applications
:::2286	lonboard	Geo / Maps	lonboard	964	Python	https://github.com/developmentseed/lonboard.git	Fast, interactive geospatial data visualization in Jupyter
:::2287	agentmaps	Geo / Maps	AgentMaps	960	JavaScript	https://github.com/noncomputable/AgentMaps.git	Make social simulations on real maps Agent-based modeling for the web
:::2288	openglobus	Geo / Maps	openglobus	936	TypeScript	https://github.com/openglobus/openglobus.git	TypeScript/JavaScript 3D maps and geospatial data visualization engine library
:::2289	xeokit-sdk	Geo / Maps	xeokit-sdk	935	HTML	https://github.com/xeokit/xeokit-sdk.git	3D BIM IFC Viewer SDK for AEC engineering applications. Open Source JavaScript Toolkit based on pure WebGL for
:::2290	geopolars	Geo / Maps	geopolars	918	Python	https://github.com/pola-rs/geopolars.git	Geospatial extensions for Polars
:::2291	terratorch	Geo / Maps	terratorch	861	Python	https://github.com/torchgeo/terratorch.git	A Python toolkit for fine-tuning Geospatial Foundation Models GFMs
:::2292	worldwindjava	Geo / Maps	WorldWindJava	788	Java	https://github.com/NASAWorldWind/WorldWindJava.git	The NASA WorldWind Java SDK WWJ is for building cross-platform 3D geospatial desktop applications in Java
:::2293	koop	Geo / Maps	koop	713	JavaScript	https://github.com/koopjs/koop.git	Transform, query, and download geospatial data on the web
:::2294	third-eye	Geo / Maps	Third-Eye	700	TypeScript	https://github.com/eli-labz/Third-Eye.git	A production-grade OSINT platform that provides situational awareness across multiple intelligence domains
:::2295	leaflet-dvf	Geo / Maps	leaflet-dvf	687	JavaScript	https://github.com/humangeo/leaflet-dvf.git	Leaflet Data Visualization Framework
:::2296	kart	Geo / Maps	kart	680	Python	https://github.com/koordinates/kart.git	Distributed version-control for geospatial and tabular data
:::2297	verde	Geo / Maps	verde	670	Python	https://github.com/fatiando/verde.git	Processing and gridding spatial data, machine-learning style
:::2298	rtreego	Geo / Maps	rtreego	655	Go	https://github.com/dhconnelly/rtreego.git	an R-Tree library for Go
:::2299	gstools	Geo / Maps	GSTools	652	Python	https://github.com/GeoStat-Framework/GSTools.git	GSTools - A geostatistical toolbox: random fields, variogram estimation, covariance models, kriging and much m
:::2300	world-intel-mcp	Geo / Maps	world-intel-mcp	649	Python	https://github.com/marc-shade/world-intel-mcp.git	120-tool MCP server for real-time global intelligence: markets, SEC filings, conflict, military, cyber, climat
:::2301	rioxarray	Geo / Maps	rioxarray	625	Python	https://github.com/corteva/rioxarray.git	geospatial xarray extension powered by rasterio
:::2302	pygeoapi	Geo / Maps	pygeoapi	624	Python	https://github.com/geopython/pygeoapi.git	pygeoapi is a Python server implementation of the OGC API suite of standards. The project emerged as part of t
:::2303	rspatial-terra	Geo / Maps	terra	620	C++	https://github.com/rspatial/terra.git	R package for spatial data handling https://rspatial.github.io/terra/reference/terra-package.html
:::2304	osint-map	Geo / Maps	OSINT-Map	612	JavaScript	https://github.com/Malfrats/OSINT-Map.git	A map of OSINT tools
:::2305	wicket	Geo / Maps	Wicket	590	JavaScript	https://github.com/arthur-e/Wicket.git	A modest library for moving between Well-Known Text WKT and various framework geometries
:::2306	streamlit-folium	Geo / Maps	streamlit-folium	586	Python	https://github.com/randyzwitch/streamlit-folium.git	Streamlit Component for rendering Folium maps
:::2307	leaflet-freedraw	Geo / Maps	Leaflet.FreeDraw	576	JavaScript	https://github.com/Wildhoney/Leaflet.FreeDraw.git	:earth_asia: FreeDraw allows the free-hand drawing of shapes on your Leaflet.js map layer providing an intuiti
:::2308	infomap	Geo / Maps	infomap	492	C++	https://github.com/mapequation/infomap.git	Multi-level network clustering based on the Map Equation
:::2309	spaghetti	Geo / Maps	spaghetti	284	Python	https://github.com/pysal/spaghetti.git	SPAtial GrapHs: nETworks, Topology, Inference
:::2310	urbanaccess	Geo / Maps	urbanaccess	266	Python	https://github.com/UDST/urbanaccess.git	A tool for GTFS transit and OSM pedestrian network accessibility analysis by UrbanSim
:::2311	qeeqbox-raven	Geo / Maps	raven	234	JavaScript	https://github.com/qeeqbox/raven.git	Advanced Cyber Threat Map Simplified, customizable, responsive and optimized
:::2312	digital-footprint-osint-tool	Geo / Maps	Digital-Footprint-OSINT-Tool	189	Python	https://github.com/Hamed233/Digital-Footprint-OSINT-Tool.git	A powerful Open Source Intelligence OSINT tool for analyzing digital footprints across multiple platforms. T
:::2313	osint-cse	Geo / Maps	OSINT-CSE	159	-	https://github.com/paulpogoda/OSINT-CSE.git	Custom Search Engines for OSINT
:::2314	ospider	Geo / Maps	OSpider	152	Python	https://github.com/skytruine/OSpider.git	POI/AOI///
:::2315	velocity	Geo / Maps	velocity	93	Python	https://github.com/AndrewCTF/velocity.git	Self-hosted OSINT situation console: live aircraft, ships, satellites, quakes and conflict events fused on one
:::2316	ukraine2022data	Geo / Maps	Ukraine2022data	81	HTML	https://github.com/mapconcierge/Ukraine2022data.git	Geospatial data archive of what is happening in Ukraine #Ukraine2022GEOINT
:::2317	cipher387-github-io	Geo / Maps	cipher387.github.io	51	HTML	https://github.com/cipher387/cipher387.github.io.git	Repo for site with links to my projects
:::2318	geoint-standards	Geo / Maps	geoint-standards	33	HTML	https://github.com/ngageoint/geoint-standards.git	co-create and grow GEOINT standards transparenlty
:::2319	cscorza	Geo / Maps	CScorza	28	HTML	https://github.com/CScorza/CScorza.git	CScorza Web - Insieme di tutti gli strumenti OSINT e Digital Forensics
:::2320	flight-tracker	Geo / Maps	Flight-Tracker	23	Python	https://github.com/shallvhack/Flight-Tracker.git	Flight Tracker: Real-time flight updates and interactive map for seamless tracking and staying in the loop
:::2321	osinttheory	Geo / Maps	OSINTtheory	17	-	https://github.com/CScorza/OSINTtheory.git	Teoria Osint - Definizioni
:::2322	brahmastra_osint	Geo / Maps	Brahmastra_OSINT	16	TypeScript	https://github.com/connedigital/Brahmastra_OSINT.git	Brahmastra_OSINT is a powerful tool designed for gathering open-source intelligence from various online platfo
:::2323	vuln-map	Geo / Maps	Vuln-Map	13	Shell	https://github.com/immtsuki/Vuln-Map.git	Its a simple tool made for recon, I have included lots of future like spiderfoot which can dig password hashes
:::2324	osint-rehberi	Geo / Maps	osint-rehberi	12	-	https://github.com/1ojew/osint-rehberi.git	OSINT Mastery: A Scenario-Based Guide to Tools and Techniques
:::2325	naissance	Geo / Maps	Naissance	9	JavaScript	https://github.com/ConfoederatioVF/Naissance.git	The editor for map data over time. Simple, capable, and open-source
:::2326	gaia	Geo / Maps	gaia	9	Python	https://github.com/OSINT-TECHNOLOGIES/gaia.git	GAIA - Geospatial Aerial Images Analyser
:::2327	satellite-mcp	Geo / Maps	satellite-mcp	7	TypeScript	https://github.com/badchars/satellite-mcp.git	Full-Spectrum Geospatial Intelligence MCP Server 171 tools across 27 categories: satellite imagery, aircraft t
:::2328	osintgodseye	Geo / Maps	OsintGodseye	7	TypeScript	https://github.com/jollncoelho/OsintGodseye.git	Real-time tactical OSINT GEOINT dashboard. Live flight tracking ADS-B, maritime vessels, satellites, underse
:::2329	lintel	Geo / Maps	lintel	6	Go	https://github.com/MHChlagou/lintel.git	Lintel one Go binary that turns your Git hooks into a security checkpoint. Coordinates gitleaks, opengrep, osv
:::2330	track-ip	Geo / Maps	track-ip	2	Shell	https://github.com/unkownvenom/track-ip.git	Advanced Ip Tracer Tool Created By htr-tech.you can see Live Location Of An Ip adress From Google map using th
:::2331	reconnaissance-gathering-target-intellig	Geo / Maps	Reconnaissance-Gathering-target-intellig	0	-	https://github.com/okafor-henry/Reconnaissance-Gathering-target-intelligence-using-osint-tools.git	theHarvester to map an organization's digital footprint domains,emails,IP ranges
:::2332	rengine	Web Scan	rengine	8850	HTML	https://github.com/yogeshojha/rengine.git	reNgine is an automated reconnaissance framework for web applications with a focus on highly configurable stre
:::2333	whatweb	Web Scan	WhatWeb	6847	Ruby	https://github.com/urbanadventurer/WhatWeb.git	Next generation web scanner
:::2334	nettacker	Web Scan	Nettacker	5604	Python	https://github.com/OWASP/Nettacker.git	Automated Penetration Testing Framework - Open-Source Vulnerability Scanner - Vulnerability Management
:::2335	agentic-bug-hunter	Web Scan	Agentic-Bug-Hunter	5080	Python	https://github.com/awarexone/Agentic-Bug-Hunter.git	AI-powered bug bounty hunting toolkit that works with or without subscription
:::2336	raccoon	Web Scan	Raccoon	4028	Python	https://github.com/evyatarmeged/Raccoon.git	A high performance offensive security tool for reconnaissance and vulnerability scanning
:::2337	sn0int	Web Scan	sn0int	2540	Rust	https://github.com/kpcyrd/sn0int.git	Semi-automatic OSINT framework and package manager
:::2338	whosthere	Web Scan	whosthere	2449	Go	https://github.com/ramonvermeulen/whosthere.git	Local Area Network discovery tool with an interactive Terminal User Interface TUI written in Go. Discover, e
:::2339	gohacktools	Web Scan	goHackTools	2188	Go	https://github.com/dreddsa5dies/goHackTools.git	Hacker tools on Go Golang
:::2340	rapidscan	Web Scan	rapidscan	2135	Python	https://github.com/skavngr/rapidscan.git	:new: The Multi-Tool Web Vulnerability Scanner
:::2341	hackvault	Web Scan	HackVault	2037	JavaScript	https://github.com/0xSobky/HackVault.git	A container repository for my public web hacks
:::2342	nomore403	Web Scan	nomore403	1881	Go	https://github.com/devploit/nomore403.git	Advanced tool for security researchers to bypass 403/40X restrictions through smart techniques and adaptive re
:::2343	hackerpro	Web Scan	hackerpro	1863	Python	https://github.com/jaykali/hackerpro.git	All in One Hacking Tool for Linux Android Termux. Make your linux environment into a Hacking Machine. Hacker
:::2344	top25-parameter	Web Scan	top25-parameter	1848	-	https://github.com/lutfumertceylan/top25-parameter.git	For basic researches, top 25 vulnerability parameters that can be used in automation tools or manual recon
:::2345	gitgot	Web Scan	GitGot	1573	Python	https://github.com/BishopFox/GitGot.git	Semi-automated, feedback-driven tool to rapidly search through troves of public data on GitHub for sensitive s
:::2346	lunasec	Web Scan	lunasec	1469	TypeScript	https://github.com/lunasec-io/lunasec.git	LunaSec - Dependency Security Scanner that automatically notifies you about vulnerabilities like Log4Shell or 
:::2347	webcopilot	Web Scan	webcopilot	1295	Shell	https://github.com/h4r5h1t/webcopilot.git	An automation tool that enumerates subdomains then filters out xss, sqli, open redirect, lfi, ssrf and rce par
:::2348	xpoc	Web Scan	xpoc	1188	-	https://github.com/chaitin/xpoc.git	[] [] [] [xray2.0] A fast emergency response tool designed for supply chain vulnerability scanning
:::2349	corscanner	Web Scan	CORScanner	1161	Python	https://github.com/chenjj/CORScanner.git	Fast CORS misconfiguration vulnerabilities scanner
:::2350	xalgorix	Web Scan	xalgorix	1112	Go	https://github.com/xalgorix/xalgorix.git	Autonomous AI pentesting agents real-time reconnaissance, vulnerability detection, and exploitation orchestrat
:::2351	lonkero	Web Scan	lonkero	1098	Rust	https://github.com/bountyyfi/lonkero.git	Lonkero - Wraps around your attack surface. Professional-grade scanner for real penetration testing. Fast. Mod
:::2352	cybermes	Web Scan	Cybermes	861	Python	https://github.com/Zyrexnn/Cybermes.git	Autonomous Offensive Security, Bug Bounty Red Teaming Agent Framework powered by Hermes Agent, specialized rea
:::2353	rekono	Web Scan	rekono	609	Python	https://github.com/pablosnt/rekono.git	Offensive security platform that automates attack surface discovery and vulnerability management
:::2354	furious	Web Scan	furious	605	Go	https://github.com/liamg/furious.git	:angry: Go IP/port scanner with SYN stealth scanning and device manufacturer identification
:::2355	minimalistic-offensive-security-tools	Web Scan	Minimalistic-offensive-security-tools	599	PowerShell	https://github.com/InfosecMatter/Minimalistic-offensive-security-tools.git	A repository of tools for pentesting of restricted and isolated environments
:::2356	thetimemachine	Web Scan	TheTimeMachine	552	Python	https://github.com/anmolksachan/TheTimeMachine.git	Weaponizing WaybackUrls for Recon, BugBounties , OSINT, Sensitive Endpoints and what not
:::2357	vault	Web Scan	vault	551	Python	https://github.com/abhisharma404/vault.git	swiss army knife for hackers
:::2358	evilscan	Web Scan	evilscan	546	JavaScript	https://github.com/eviltik/evilscan.git	NodeJS Simple Network Scanner
:::2359	pybelt	Web Scan	Pybelt	520	Python	https://github.com/Ekultek/Pybelt.git	The hackers tool belt
:::2360	taipan	Web Scan	Taipan	462	-	https://github.com/enkomio/Taipan.git	Web application vulnerability scanner
:::2361	recon-pipeline	Web Scan	recon-pipeline	454	Python	https://github.com/epi052/recon-pipeline.git	An automated target reconnaissance pipeline
:::2362	reconator	Web Scan	Reconator	442	Python	https://github.com/gokulapap/Reconator.git	Automated Recon for Web Pentesting
:::2363	netz	Web Scan	netz	399	Go	https://github.com/SpectralOps/netz.git	Discover internet-wide misconfigurations while drinking coffee
:::2364	gsec	Web Scan	Gsec	387	Python	https://github.com/gotr00t0day/Gsec.git	Web Security Scanner
:::2365	z0scan	Web Scan	z0scan	365	Python	https://github.com/JiuZero/z0scan.git	A lightweight active and passive scanner that combines the advantages of local and distributed models, support
:::2366	nerva	Web Scan	nerva	358	Go	https://github.com/praetorian-inc/nerva.git	Fast service fingerprinting CLI for 170+ protocols TCP/UDP/SCTP - built by Praetorian
:::2367	havn	Web Scan	havn	318	Rust	https://github.com/mrjackwills/havn.git	A fast configurable port scanner with reasonable defaults
:::2368	armada	Web Scan	armada	317	Rust	https://github.com/resyncgg/armada.git	A high performance TCP SYN port scanner
:::2369	kimi	Web Scan	kimi	261	Python	https://github.com/alechilczenko/kimi.git	Attack Surface Discovery tool built on a microservice approach, utilizing multi-threading for fast, internet-s
:::2370	pphack	Web Scan	pphack	250	Go	https://github.com/edoardottt/pphack.git	Advanced Client-Side Prototype Pollution Scanner
:::2371	favirecon	Web Scan	favirecon	248	Go	https://github.com/edoardottt/favirecon.git	Use favicons to improve your target recon phase. Quickly detect technologies, WAF, exposed panels, known servi
:::2372	project-deep-focus	Web Scan	Project-Deep-Focus	247	Python	https://github.com/Y0oshi/Project-Deep-Focus.git	Your personal 'Mini Shodan'. A high-performance network reconnaissance engine designed for massive scale asset
:::2373	lazy-hunter	Web Scan	Lazy-Hunter	241	Python	https://github.com/iamunixtz/Lazy-Hunter.git	LazyHunter is an automated reconnaissance tool designed for bug hunters, leveraging Shodan's InternetDB and CV
:::2374	pwneye	Web Scan	pwneye	238	Python	https://github.com/Hackerest/pwneye.git	Your ONVIF and RTSP camera companion for discovering and hacking real-world security cameras
:::2375	julius	Web Scan	julius	236	Go	https://github.com/praetorian-inc/julius.git	Simple LLM service identification - translate IP:Port to Ollama, vLLM, LiteLLM, or 60+ other AI services in se
:::2376	nesca	Web Scan	nesca	231	C++	https://github.com/pantyusha/nesca.git	The legendary netstalking NEtwork SCAnner
:::2377	recon	Web Scan	Recon	222	Python	https://github.com/dirsoooo/Recon.git	Recon is a script to perform a full recon on a target with the main tools to search for vulnerabilities. Creat
:::2378	lzr	Web Scan	lzr	197	Go	https://github.com/stanford-esrg/lzr.git	LZR quickly detects and fingerprints unexpected services running on unexpected ports
:::2379	rengine-ng	Web Scan	rengine-ng	183	Python	https://github.com/Security-Tools-Alliance/rengine-ng.git	reNgine-ng is an automated reconnaissance framework for web applications with a focus on highly configurable s
:::2380	cbrutekrag	Web Scan	cbrutekrag	175	C	https://github.com/matricali/cbrutekrag.git	Penetration tests on SSH servers using brute force or dictionary attacks. Written in C
:::2381	x-recon	Web Scan	X-Recon	171	Python	https://github.com/joshkar/X-Recon.git	A utility for detecting webpage inputs and conducting XSS scans
:::2382	wordlist404	Web Scan	Wordlist404	165	-	https://github.com/tamimhasan404/Wordlist404.git	Small but effective wordlist for brute-forcing and discovering hidden things
:::2383	r3c0nizer	Web Scan	R3C0Nizer	151	Shell	https://github.com/Anon-Artist/R3C0Nizer.git	R3C0Nizer is the first ever CLI based menu-driven web application B-Tier recon framework
:::2384	portscanner	Web Scan	PortScanner	149	Python	https://github.com/vinitshahdeo/PortScanner.git	A go-to tool for scanning network. Scan all the open ports for a given host with just one click
:::2385	udpz	Web Scan	udpz	136	Go	https://github.com/FalconOpsLLC/udpz.git	Speedy probe-based UDP service scanner
:::2386	wildbox	Web Scan	wildbox	133	Python	https://github.com/fabriziosalmi/wildbox.git	An open-source security platform for the community. Unified SIEM, SOAR, WAF, and more in a single, self-hosted
:::2387	cloudgazer	Web Scan	cloudgazer	127	Python	https://github.com/Aidennnn33/cloudgazer.git	Find Real IPs hidden behind Cloudflare with Criminal IPcriminalip.io, security OSINT Tool
:::2388	htk-lite	Web Scan	htk-lite	126	Python	https://github.com/unkn0wnh4ckr/htk-lite.git	htk-lite is a lighter version of hackers-tool-kit but it still has the same hacking ability as hackers-tool-ki
:::2389	goblob	Web Scan	goblob	123	Go	https://github.com/Macmod/goblob.git	A fast enumeration tool for publicly exposed Azure Storage blobs
:::2390	reconner	Web Scan	Reconner	113	Go	https://github.com/rootdr-backup/Reconner.git	Self-hosted bug-bounty platform verification-first recon DAST, continuous monitoring. Your data stays on your 
:::2391	fazscan	Web Scan	FazScan	89	Perl	https://github.com/mfazrinizar/FazScan.git	FazScan is a Perl program to do some vulnerability scanning and pentesting
:::2392	google-dorks-for-cross-site-scripting-xs	Web Scan	Google-Dorks-for-Cross-site-Scripting-XS	74	-	https://github.com/MrPr0fessor/Google-Dorks-for-Cross-site-Scripting-XSS.git	Cross-Site Scripting XSS injects malicious scripts into trusted websites via user input. Attacker-sent scrip
:::2393	ircp	Web Scan	IRCP	55	Python	https://github.com/internet-relay-chat/IRCP.git	A robust information gathering tool for large scale reconnaissance on Internet Relay Chat servers
:::2394	wodxgod-gdorks	Web Scan	gDorks	48	Python	https://github.com/wodxgod/gDorks.git	Vulnerable website scraper
:::2395	github-action-gitleaks	Web Scan	github-action-gitleaks	22	Shell	https://github.com/DariuszPorowski/github-action-gitleaks.git	This GitHub Action allows you to run Gitleaks in your GitHub workflow
:::2396	clutch-vscode-extension	Web Scan	clutch-vscode-extension	17	JavaScript	https://github.com/clutchsecurity/clutch-vscode-extension.git	The Clutch VS code extension allows any user to scan for secrets in his/hers open workspace automatically with
:::2397	ipscanner	Web Scan	IPscanner	16	JavaScript	https://github.com/michalstankiewicz4-cell/IPscanner.git	Just simple IP scanner with OSINT, pentest and opsec tools
:::2398	veltcli	Web Scan	VeltCLI	15	Python	https://github.com/vkxd/VeltCLI.git	An all in 1 OSINT Tool thats a work in progress
:::2399	honeypot-auditor	Web Scan	honeypot-auditor	10	Python	https://github.com/mziqudhd92/honeypot-auditor.git	Does This Look Like An Honeypot? DTLLAH Multi-protocol CLI that fingerprints whether a target IP behaves lik
:::2400	waybackurls	Web Scan	waybackurls	9	JavaScript	https://github.com/chethanyadav456/waybackurls.git	Get historical URLs from the Wayback Machine using Node.js. Supports CLI and library usage
:::2401	draugr	Web Scan	draugr	7	Go	https://github.com/draugr-dev/draugr.git	Run Trivy, Semgrep, Gitleaks and more from one file. Consolidates SAST, SCA, secrets, IaC and container findin
:::2402	secretkeeper	Web Scan	secretKeeper	4	Python	https://github.com/sicpa-foundations/secretKeeper.git	SecretKeeper is a tool for detecting secrets and misconfigurations on your Git repositories Bitbucket and Git
:::2403	git-secrets-scanner	Web Scan	Git-Secrets-Scanner	3	Go	https://github.com/AkhilSharma90/Git-Secrets-Scanner.git	A GO project that uses TruffleHog and GitLeaks to scan for leaked secrets in code
:::2404	gitleaks-ai	Web Scan	gitleaks-ai	2	Python	https://github.com/rawqubit/gitleaks-ai.git	AI-enhanced secrets scanner with Shannon entropy analysis and LLM-powered false-positive elimination. Drop-in 
:::2405	gitleaks-scanner	Web Scan	gitleaks-scanner	2	JavaScript	https://github.com/Jaykatta17/gitleaks-scanner.git	Bulk Gitleaks Scanner is a Python tool that scans multiple Git repositories for secrets using Gitleaks. It sup
:::2406	claude-sentinel	Web Scan	claude-sentinel	2	-	https://github.com/TorpedoD/claude-sentinel.git	Security audit slash command for Claude Code. Runs SAST, secrets detection, SBOM, SCA, AI-skill safety, and pr
:::2407	aetherion	Web Scan	aetherion	2	Python	https://github.com/RDTUTORIAL/aetherion.git	All-in-one Android security toolkit scanning, exploitation, post-exploitation, persistence, and reporting via 
:::2408	xss-osint-swiftkit	Web Scan	XSS-OSINT-SWIFTKIT	1	Shell	https://github.com/Talyx66/XSS-OSINT-SWIFTKIT.git	XSStrike, Spiderfoot, Dalfox, well, what do you know? Please use responsibly and credit goes to orignal creato
:::2409	waybackurls-scanner	Web Scan	waybackurls-scanner	1	Python	https://github.com/RamadhanAlfatih/waybackurls-scanner.git	A Python tool to fetch archived URLs from the Wayback Machine for reconnaissance
:::2410	picket	Web Scan	picket	1	C#	https://github.com/willibrandon/picket.git	Native AOT .NET secrets scanner with Gitleaks compatibility, validation, source scanning, and CI integrations
:::2411	secrets-scanner	Web Scan	secrets-scanner	1	Python	https://github.com/hmcts/secrets-scanner.git	Composite GitHub Action to run Gitleaks and TruffleHog for secrets scanning. Built to simplify and standardise
:::2412	slack2scan	Web Scan	slack2scan	1	Python	https://github.com/govindasamyarun/slack2scan.git	The Slack2scan application scans the GitHub repository for hardcoded secrets using Gitleaks. It will make secu
:::2413	leakguard	Web Scan	leakguard	1	Python	https://github.com/Yashraj5122/leakguard.git	Find leaked secrets on the public surface your org scanner ignores personal repos, npm/PyPI packages, JS bundl
:::2414	shodan-scanner	Web Scan	shodan-scanner	1	-	https://github.com/javokhir-sec/shodan-scanner.git	Advanced Shodan Censys CLI hunt exposed services, IoT devices, vulnerable hosts
:::2415	mdsr-1-network-vulnerability-scanner	Web Scan	Network-Vulnerability-Scanner	0	-	https://github.com/mdsr-1/Network-Vulnerability-Scanner.git	Multi-threaded Python CLI tool for network recon, port scanning, and automated CVE correlation using the Shoda
:::2416	pagodo	Dorking / Search	pagodo	3397	Python	https://github.com/opsdisk/pagodo.git	pagodo Passive Google Dork - Automate Google Hacking Database scraping and searching
:::2417	github-dorks	Dorking / Search	github-dorks	3283	Python	https://github.com/techgaun/github-dorks.git	Find leaked secrets via github search
:::2418	how-to-scrape-google-trends	Dorking / Search	how-to-scrape-google-trends	2911	Python	https://github.com/oxylabs/how-to-scrape-google-trends.git	Learn step-by-step how to scrape Google Trends data and make a result comparison using Python and Oxylabs SERP
:::2419	marginaliasearch	Dorking / Search	MarginaliaSearch	2144	Java	https://github.com/MarginaliaSearch/MarginaliaSearch.git	Internet search engine for text-oriented websites. Indexing the small, old and weird web
:::2420	how-to-scrape-google-scholar	Dorking / Search	how-to-scrape-google-scholar	2099	Python	https://github.com/oxylabs/how-to-scrape-google-scholar.git	A guide for extracting titles, authors, and citations from Google Scholar using Python and Oxylabs SERP Scrape
:::2421	atscan	Dorking / Search	ATSCAN	1588	Perl	https://github.com/AlisamTechnology/ATSCAN.git	Advanced dork Search Mass Exploit Scanner
:::2422	go-dork	Dorking / Search	go-dork	1302	Go	https://github.com/dwisiswant0/go-dork.git	The fastest dork scanner written in Go
:::2423	open-semantic-search	Dorking / Search	open-semantic-search	1210	Shell	https://github.com/opensemanticsearch/open-semantic-search.git	Open Source research tool to search, browse, analyze and explore large document collections by Semantic Search
:::2424	sitedorks	Dorking / Search	sitedorks	1057	Python	https://github.com/Zarcolio/sitedorks.git	Search Google/Bing/Ecosia/DuckDuckGo/Yandex/Yahoo for a search term dork with a default set of websites, bug
:::2425	zeus-scanner	Dorking / Search	Zeus-Scanner	999	Python	https://github.com/Ekultek/Zeus-Scanner.git	Advanced reconnaissance utility
:::2426	gdorks	Dorking / Search	GDorks	708	-	https://github.com/Ishanoshada/GDorks.git	Google Dork List - Uncover the Hidden Gems of the Internet  There are at least 320+ categories  + Web App
:::2427	google-dorking	Dorking / Search	Google-Dorking	676	-	https://github.com/chr3st5an/Google-Dorking.git	Google Dorking Cheat Sheet
:::2428	metagoofil	Dorking / Search	metagoofil	590	Python	https://github.com/opsdisk/metagoofil.git	Search Google and download specific file types
:::2429	sightline	Dorking / Search	sightline	567	TypeScript	https://github.com/ni5arga/sightline.git	An OSINT search engine for mapping real-world infrastructure from OpenStreetMap data
:::2430	darksearch	Dorking / Search	Darksearch	542	Python	https://github.com/vlall/Darksearch.git	:mag::shipit: Search engine for hidden material. Scraping dark web onions, irc logs, deep web etc
:::2431	txtool	Dorking / Search	txtool	521	Python	https://github.com/kuburan/txtool.git	an easy pentesting tool
:::2432	dorknet	Dorking / Search	DorkNet	349	Python	https://github.com/NullArray/DorkNet.git	Selenium powered Python script to automate searching for vulnerable web apps
:::2433	dorks_hunter	Dorking / Search	dorks_hunter	344	Python	https://github.com/six2dez/dorks_hunter.git	Simple Google Dorks search tool
:::2434	googledorker	Dorking / Search	GoogleDorker	296	Python	https://github.com/RevoltSecurities/GoogleDorker.git	GoogleDorker - Unleash the power of Google dorking for ethical hackers with custom search precision
:::2435	dorkscanner	Dorking / Search	dorkScanner	284	Python	https://github.com/madhavmehndiratta/dorkScanner.git	A typical search engine dork scanner scrapes search engines with dorks that you provide in order to find vulne
:::2436	bug-hunting-arsenal	Dorking / Search	Bug-Hunting-Arsenal	265	Shell	https://github.com/thevillagehacker/Bug-Hunting-Arsenal.git	The Repository contains various payloads, tools, tips and tricks from various hackers around the world. Please
:::2437	google-sports-results-api	Dorking / Search	google-sports-results-api	257	-	https://github.com/ScrapingBee/google-sports-results-api.git	Extract live scores, match results, and league standings directly from Google Search. A flexible sports data A
:::2438	r4ygm-dorkscout	Dorking / Search	dorkscout	243	Go	https://github.com/R4yGM/dorkscout.git	DorkScout - Golang tool to automate google dork scan against the entiere internet or specific targets
:::2439	dorkify	Dorking / Search	Dorkify	213	Python	https://github.com/hhhrrrttt222111/Dorkify.git	Perform Google Dork search with Dorkify
:::2440	fastdork	Dorking / Search	FastDork	145	JavaScript	https://github.com/SKVNDR/FastDork.git	FastDork speeds up repetitive dorking: build reusable lists, open search tabs in batches, and import matching 
:::2441	darkweb-search-engine	Dorking / Search	Darkweb-search-engine	142	Python	https://github.com/NexvisionLab/Darkweb-search-engine.git	Dark web deep web search engine, crawler, and indexer open-source OSINT tooling for Tor-based darknet reconnai
:::2442	gh-dork	Dorking / Search	gh-dork	137	Python	https://github.com/molly/gh-dork.git	Github dorking tool
:::2443	google-dorks-full_list	Dorking / Search	Google-Dorks-Full_list	125	-	https://github.com/TUXCMD/Google-Dorks-Full_list.git	Approx 10.000 lines of Google dorks search queries - Use this for research purposes only
:::2444	dorkgen	Dorking / Search	dorkgen	109	Go	https://github.com/sundowndev/dorkgen.git	Type-safe dork queries for search engines such as Google, Yahoo, DuckDuckGo Bing
:::2445	pydork	Dorking / Search	pydork	88	Python	https://github.com/blacknon/pydork.git	Scraping and listing text and image searches on Google, Bing, DuckDuckGo, Baidu, Yahoo japan
:::2446	dorkhub	Dorking / Search	DorkHub	85	-	https://github.com/TrixSec/DorkHub.git	DorkHub is the security researcher's companion. Its a comprehensive repository of Google dorks collected in on
:::2447	google-dorks-toolkit	Dorking / Search	google-dorks-toolkit	75	Python	https://github.com/SalehLardhi/google-dorks-toolkit.git	GoogleDorks Toolkit is a powerful automated tool for google dorks, designed for pentration tester, ethical hac
:::2448	proviesec-github-dorks	Dorking / Search	github-dorks	72	-	https://github.com/Proviesec/github-dorks.git	Useful Github Dorks for BugBounty
:::2449	fravia	Dorking / Search	FRAVIA	65	-	https://github.com/soxoj/FRAVIA.git	FRAVIA: The Art of Searching
:::2450	osint-sync	Dorking / Search	Osint-Sync	61	JavaScript	https://github.com/mixaoc/Osint-Sync.git	Extension Osint Sync
:::2451	xgs	Dorking / Search	XGS	60	Python	https://github.com/sanfor2004/XGS.git	PYTHON CODE TO SEARCH BY DORK ON .onion WEBSITES , NORMAL WEBSITES AND LEARN HOW DORK WORK
:::2452	dolkings	Dorking / Search	Dolkings	55	Python	https://github.com/Yutix/Dolkings.git	Dorking google with python easy support Termux
:::2453	darkweb-crawling-indexing	Dorking / Search	DarkWeb-Crawling-Indexing	44	HTML	https://github.com/AshwinAmbal/DarkWeb-Crawling-Indexing.git	A DarkWeb Crawler based off the open-source TorSpider. Indexing with search engine created using Apache Solr
:::2454	sql-injection-google-dork-list	Dorking / Search	SQL-Injection-Google-Dork-List	40	-	https://github.com/ShivamRai2003/SQL-Injection-Google-Dork-List.git	Updated 6000 Sql Injection Google Dork 2021
:::2455	atdork	Dorking / Search	AtDork	39	Python	https://github.com/amnottdevv/AtDork.git	tools auto dorking with multi enggine search
:::2456	dorkfinder	Dorking / Search	DorkFinder	36	Python	https://github.com/TheHermione/DorkFinder.git	Automatic tool to find Google Dorks
:::2457	webcamexplorer	Dorking / Search	WebcamExplorer	34	-	https://github.com/TariqullslamHridoy/WebcamExplorer.git	A comprehensive guide to discovering unsecured webcams using Google and Shodan dorks, with ethical guidelines 
:::2458	chad	Dorking / Search	chad	33	Python	https://github.com/ivan-sincek/chad.git	Search Google Dorks like Chad. / Broken link hijacking tool
:::2459	dorker	Dorking / Search	dorker	32	Python	https://github.com/0xdln1/dorker.git	Better Google Dorking with Dorker
:::2460	admin-panel-dorks	Dorking / Search	Admin-Panel-Dorks	31	-	https://github.com/0Xnanoboy/Admin-Panel-Dorks.git	Find The Admin Panel SQL Injection Endpoints, Using Google Dorks
:::2461	elasticsearch-pentesting	Dorking / Search	ElasticSearch-Pentesting	31	-	https://github.com/kh4sh3i/ElasticSearch-Pentesting.git	ElasticSearch exploit and Pentesting guide for penetration tester
:::2462	googledorks	Dorking / Search	GoogleDorks	29	-	https://github.com/TheLeopardsH/GoogleDorks.git	Google dorks for OSINT
:::2463	aiotools	Dorking / Search	AIOTools	28	Python	https://github.com/NeloF4/AIOTools.git	All In One Tools Hacking
:::2464	godork	Dorking / Search	godork	27	Python	https://github.com/thd3r/godork.git	Advanced Fast Google Dorking Tool
:::2465	bountydork	Dorking / Search	BountyDork	26	Python	https://github.com/ElNiak/BountyDork.git	BountyDork is a comprehensive tool designed for penetration testers and cybersecurity researchers. It integrat
:::2466	g-dorks	Dorking / Search	G-dorks	25	HTML	https://github.com/Zierax/G-dorks.git	Just Harmless Google dorks for bug hunters
:::2467	dorkninja-google-dork-term-generator	Dorking / Search	DorkNinja-Google-Dork-Term-Generator	21	Python	https://github.com/SHUR1K-N/DorkNinja-Google-Dork-Term-Generator.git	A tool that assists in Google Dorks by simplifying your task enough to just adding keywords to be turned into 
:::2468	shodan-recon	Dorking / Search	shodan-recon	0	Python	https://github.com/strikergoutham/shodan-recon.git	shodan-recon is a cli python 3 based tool which helps to fetch useful information from shodan search engine. I
:::2469	censys-io-client	Dorking / Search	Censys.io-Client	0	Python	https://github.com/qwuedhiaujsodis/Censys.io-Client.git	Web client for using Censys.io Search Engine API . You will need to set UID and SECRET to run the program
:::2470	osint-blackbird	Dorking / Search	OSINT-bLACKBIRD	0	-	https://github.com/Eduselva/OSINT-bLACKBIRD.git	Search engine
:::2471	gitleaks	Code / Secrets	gitleaks	29403	Go	https://github.com/gitleaks/gitleaks.git	Find secrets with Gitleaks
:::2472	infisical	Code / Secrets	infisical	29340	TypeScript	https://github.com/Infisical/infisical.git	Infisical is the open-source platform for secrets, certificates, and privileged access management
:::2473	shhgit	Code / Secrets	shhgit	3983	JavaScript	https://github.com/eth0izzle/shhgit.git	Ah shhgit Find secrets in your code. Secrets detection for your GitHub, GitLab and Bitbucket repositories
:::2474	betterleaks	Code / Secrets	betterleaks	1984	Go	https://github.com/betterleaks/betterleaks.git	Find leaked secrets everywhere
:::2475	git-hound	Code / Secrets	git-hound	1461	Go	https://github.com/tillson/git-hound.git	Fast GitHub recon tool. Scans for leaked secrets across all of GitHub, not just known repos and orgs. Support 
:::2476	pasteguard	Code / Secrets	pasteguard	755	TypeScript	https://github.com/sgasser/pasteguard.git	AI gets the context. Not your private data. Local-first privacy proxy for browser chat, AI APIs, and coding ag
:::2477	keyfinder	Code / Secrets	keyFinder	716	JavaScript	https://github.com/momenbasel/keyFinder.git	Passive API key and secret discovery browser extension for Chrome and Firefox. 80+ detection patterns, zero co
:::2478	gitleaks-action	Code / Secrets	gitleaks-action	646	JavaScript	https://github.com/gitleaks/gitleaks-action.git	Protect your secrets using Gitleaks-Action
:::2479	force-push-scanner	Code / Secrets	force-push-scanner	492	Python	https://github.com/trufflesecurity/force-push-scanner.git	Scan for secrets in dangling commits on GitHub using GH Archive data
:::2480	chat-archive-guard	Code / Secrets	chat-archive-guard	460	Python	https://github.com/MaxHu-xuan/chat-archive-guard.git	Audit AI chat exports locally before sharing or migration. Find possible secrets, personal-data patterns, brok
:::2481	privacy-filter	Code / Secrets	privacy-filter	336	Go	https://github.com/packyme/privacy-filter.git	LLM privacy gateway in Go millisecond-latency PII and secret redaction. Used in production by PackyCode
:::2482	apkscan	Code / Secrets	apkscan	309	Python	https://github.com/LucasFaudman/apkscan.git	Scan for secrets, endpoints, and other sensitive data after decompiling and deobfuscating Android files. .apk
:::2483	gf-secrets	Code / Secrets	gf-secrets	247	Shell	https://github.com/dwisiswant0/gf-secrets.git	Secret and/or credential patterns used for gf
:::2484	littlebrother	Code / Secrets	LittleBrother	193	Python	https://github.com/AbirHasan2005/LittleBrother.git	LittleBrother is an information collection tool OSINT which aims to carry out research on a French, Swiss, L
:::2485	secret-scanning-custom-patterns	Code / Secrets	secret-scanning-custom-patterns	176	HTML	https://github.com/advanced-security/secret-scanning-custom-patterns.git	Examples of Custom Secret Scanning Patterns for use with GitHub Secret Protection/Advanced Security
:::2486	hackerwasi	Code / Secrets	Hackerwasi	150	Python	https://github.com/evildevill/Hackerwasi.git	Hackerwasii is an information collection tool OSINT which aims to carry out research on a French, Swiss, Lux
:::2487	keyhog	Code / Secrets	keyhog	104	Rust	https://github.com/santhreal/keyhog.git	GPU-accelerated secret scanner for code, Git history, containers, cloud, browser assets, and CI. 923 detectors
:::2488	trufflehog-burp-suite-extension	Code / Secrets	trufflehog-burp-suite-extension	102	Python	https://github.com/trufflesecurity/trufflehog-burp-suite-extension.git	Official TruffleHog Burp Suite Extension. Scan Burp Suite traffic for 800+ different types of secrets API key
:::2489	clawguard	Code / Secrets	ClawGuard	87	TypeScript	https://github.com/Gk0Wk/ClawGuard.git	The antivirus for OpenClaw approve dangerous actions, scan skills, block secret leaks, and keep humans in cont
:::2490	agent-sweep	Code / Secrets	agent-sweep	82	Python	https://github.com/Ishannaik/agent-sweep.git	Find and redact secrets in AI coding agent histories Claude Code, and more
:::2491	git-secret-scanner	Code / Secrets	git-secret-scanner	70	Go	https://github.com/padok-team/git-secret-scanner.git	Find secrets in git repositories with TruffleHog Gitleaks
:::2492	leaklens	Code / Secrets	leaklens	64	Go	https://github.com/dinosn/leaklens.git	Bug bounty focused JavaScript security analysis for crawling web assets, source maps, and secret discovery
:::2493	gssar	Code / Secrets	GSSAR	51	TypeScript	https://github.com/advanced-security/GSSAR.git	GitHub Secret Scanning Auto Remediator GSSAR
:::2494	secpat2gf	Code / Secrets	secpat2gf	39	Python	https://github.com/dwisiswant0/secpat2gf.git	convert secret patterns to gf compatible
:::2495	crenox	Code / Secrets	crenox	25	Go	https://github.com/crenoxhq/crenox.git	Statically compiled, zero-dependency Git pre-commit secret scanner and credentials detector written in Go. An 
:::2496	secretradar	Code / Secrets	SecretRadar	11	JavaScript	https://github.com/Bo0oM/SecretRadar.git	Gitleaks scours your repo. Trufflehog digs for secrets on your disk. Another secret scanner? Yep. Guilty as ch
:::2497	secretsynth	Code / Secrets	secretsynth	8	Python	https://github.com/austimkelly/secretsynth.git	A secret scanner wrapper to aggregate results across multiple secret scanning tools
:::2498	didileak	Code / Secrets	DidILeak	7	Python	https://github.com/frangelbarrera/DidILeak.git	Local-first LLM secret scanner scan ChatGPT, Claude, Cursor Kimi K3 chat history for leaked API keys, PII cred
:::2499	whatileaked	Code / Secrets	whatileaked	6	TypeScript	https://github.com/selan-ai/whatileaked.git	Find credentials your coding agent already sent. Scans local Claude Code and Codex transcripts against the git
:::2500	devsecops-project	Code / Secrets	devsecops-project	6	Python	https://github.com/Mehmettrkkan/devsecops-project.git	Automated DevSecOps pipeline with 4-layer security: secret scanning, SAST, container vulnerability analysis, a
:::2501	azure-pipelines	Code / Secrets	azure-pipelines	6	Shell	https://github.com/lpsm-dev/azure-pipelines.git	Azure DevOps Pipeline - Docker Build, Trivy Scan, Secret Detection, Sonar, Kubernetes Deploy and others Steps
:::2502	secret-guard	Code / Secrets	secret-guard	5	Python	https://github.com/taksh1507/secret-guard.git	Open-source Python secret scanner: detect leaked API keys, AWS keys, GitHub tokens, passwords and private keys
:::2503	gitleaks-for-enterprise	Code / Secrets	gitleaks-for-enterprise	5	Python	https://github.com/rewanthtammana/gitleaks-for-enterprise.git	Gitleaks customized to use across enterprises/multiple projects
:::2504	security-audit	Code / Secrets	security-audit	5	Python	https://github.com/YangKuoshih/security-audit.git	Universal security scanning skill for AI agents - finds hardcoded secrets, API keys, and vulnerabilities in an
:::2505	leakferret	Code / Secrets	leakferret	5	Rust	https://github.com/leakferrethq/leakferret.git	MCP-native secret scanner in one fast Rust binary: engine, CLI, and MCP server. Finds API keys and secrets, sk
:::2506	xche-ai-app-security-pack	Code / Secrets	xche-ai-app-security-pack	5	Shell	https://github.com/xChechi/xche-ai-app-security-pack.git	Free security guardrails for apps built with AI coding tools Claude Code, Cursor, Lovable, Bolt. Drop-in rul
:::2507	goleaks	Code / Secrets	goleaks	4	Go	https://github.com/TALLHAMADOU/goleaks.git	Goleaks - Ultra-fast Go alternative to Gitleaks , Smart secret scanning with--diff-only --dmart mode
:::2508	security-review	Code / Secrets	security-review	4	PowerShell	https://github.com/cdmx-in/security-review.git	Claude Code skill that runs real security scanners Semgrep, gitleaks, TruffleHog, Trivy, osv-scanner, ZAP th
:::2509	redactyl	Code / Secrets	redactyl	4	Go	https://github.com/varalys/redactyl.git	Deep artifact scanner for cloud-native environments. Find secrets hiding in container images, Helm charts, Kub
:::2510	devsecops-monorepo-shawcase	Code / Secrets	DevSecOps-Monorepo-Shawcase	4	TypeScript	https://github.com/O2sa/DevSecOps-Monorepo-Shawcase.git	Enterprise Polyglot DevSecOps Platform: End-to-End CI/CD, SAST Semgrep, DAST OWASP ZAP, SCA Trivy, Secre
:::2511	gitleaks-secret-scanner	Code / Secrets	gitleaks-secret-scanner	3	JavaScript	https://github.com/criisv7/gitleaks-secret-scanner.git	A zero-configuration npm wrapper for Gitleaks that automatically installs the binary and simplifies secret sca
:::2512	git-security-scanner-public	Code / Secrets	git-security-scanner-public	3	Python	https://github.com/cloudon-one/git-security-scanner-public.git	Git secrets, vulnurabilities scanner with rich reporting
:::2513	secret-scan	Code / Secrets	secret-scan	2	TypeScript	https://github.com/sanity-labs/secret-scan.git	Secret detection library based on gitleaks rules
:::2514	leaklane	Code / Secrets	leaklane	2	Python	https://github.com/stefanodenti/leaklane.git	Local secret triage for repository fleets with Gitleaks and LM Studio
:::2515	pai-secret-scanning	Code / Secrets	pai-secret-scanning	2	Shell	https://github.com/jcfischer/pai-secret-scanning.git	Automated secret detection for PAI operators. Gitleaks config + pre-commit hook + CI workflow
:::2516	aethelred-x	Code / Secrets	Aethelred-X	2	Python	https://github.com/Hafiz380/Aethelred-X.git	A high-speed, AI-enhanced security framework for secret discovery and exploitation intelligence. Powered by Gi
:::2517	synctx	Code / Secrets	Synctx	2	JavaScript	https://github.com/adsathye/Synctx.git	Never loose your sessions Sync your AI coding sessions across devices securely. A Copilot CLI plugin with Gitl
:::2518	api-security-ci-cd	Code / Secrets	api-security-ci-cd	2	Python	https://github.com/Indrajit2807/api-security-ci-cd.git	Built a vulnerable FastAPI application and implemented a DevSecOps CI/CD pipeline with SAST Semgrep, secret 
:::2519	aiscan	Code / Secrets	aiscan	2	JavaScript	https://github.com/hedongli1/aiscan.git	AI-assisted code security scanner - zero-dependency static analysis + entropy-based secret detection + SARIF o
:::2520	devsecops-aws-pipeline-githubactions	Code / Secrets	devsecops-aws-pipeline-githubactions	2	TypeScript	https://github.com/HimanM/devsecops-aws-pipeline-githubactions.git	DevSecOps CI/CD pipeline using GitHub Actions with secret scanning, IaC security, policy-as-code enforcement, 
:::2521	cpp-hooks-gitleaks	Code / Secrets	cpp-hooks-gitleaks	1	Go	https://github.com/hmcts/cpp-hooks-gitleaks.git	Repo for checks gitleaks like secret, keys, password
:::2522	gitleaks-secret-scanning	Code / Secrets	Gitleaks-Secret-Scanning	1	Python	https://github.com/crow50/Gitleaks-Secret-Scanning.git	Secrets Scanning in CI/CD Pipelines and Secrets Remediation including Gitleaks Pre-Commit Hooks
:::2523	secretscan-go	Code / Secrets	secretscan-go	1	Go	https://github.com/JSLEEKR/secretscan-go.git	Re-implementation of gitleaks in Go secret detection with parallel scanning, entropy analysis, SARIF output
:::2524	claude-code-gitleaks	Code / Secrets	claude-code-gitleaks	1	JavaScript	https://github.com/saravananravi08/claude-code-gitleaks.git	Claude Code plugin for secret detection on staged files before git commit/push. Zero dependencies, embedded gi
:::2525	censys-client	Code / Secrets	censys-client	0	-	https://github.com/dkstar111/censys-client.git	A censys.io client that allow to you to use multiple api key
:::2526	flowsint	Graph / Link Analysis	flowsint	8845	TypeScript	https://github.com/reconurge/flowsint.git	A modern platform for visual, flexible, and extensible graph-based investigations. For cybersecurity analysts 
:::2527	pygraphistry	Graph / Link Analysis	pygraphistry	2555	Python	https://github.com/graphistry/pygraphistry.git	PyGraphistry is a Python library to quickly load, shape, embed, and explore big graphs with the GPU-accelerate
:::2528	aleph	Graph / Link Analysis	aleph	2435	JavaScript	https://github.com/alephdata/aleph.git	Search and browse documents and data; find the people and companies you look for
:::2529	igraph	Graph / Link Analysis	igraph	2008	C	https://github.com/igraph/igraph.git	Library for the analysis of networks
:::2530	non-typical-osint-guide	Graph / Link Analysis	non-typical-OSINT-guide	1589	-	https://github.com/OffcierCia/non-typical-OSINT-guide.git	The most unusual OSINT guide you've ever seen. The repository is intended for bored professionals only. PRs ar
:::2531	python-igraph	Graph / Link Analysis	python-igraph	1462	Python	https://github.com/igraph/python-igraph.git	Python interface for igraph
:::2532	network-analysis-made-simple	Graph / Link Analysis	Network-Analysis-Made-Simple	1122	Python	https://github.com/ericmjl/Network-Analysis-Made-Simple.git	An introduction to network analysis and applied graph theory using Python and NetworkX
:::2533	networkit	Graph / Link Analysis	networkit	876	C++	https://github.com/networkit/networkit.git	NetworKit is a growing open-source toolkit for large-scale network analysis
:::2534	paulbrodersen-netgraph	Graph / Link Analysis	netgraph	745	Python	https://github.com/paulbrodersen/netgraph.git	Publication-quality network visualisations in python
:::2535	digitaldisarray-osint-tools	Graph / Link Analysis	OSINT-Tools	744	-	https://github.com/digitaldisarray/OSINT-Tools.git	:eyes: Some of my favorite OSINT tools
:::2536	datasets	Graph / Link Analysis	datasets	656	-	https://github.com/benedekrozemberczki/datasets.git	A repository of pretty cool datasets that I collected for network science and machine learning research
:::2537	easy-graph	Graph / Link Analysis	Easy-Graph	483	Python	https://github.com/easy-graph/Easy-Graph.git	EasyGraph is an open-source network analysis library designed to cover advanced network processing methods. It
:::2538	api	Graph / Link Analysis	api	375	Python	https://github.com/vulnersCom/api.git	Official Python SDK for the Vulners vulnerability-intelligence API search CVEs, exploits and advisories CVSS/
:::2539	deepgraph	Graph / Link Analysis	deepgraph	348	Python	https://github.com/deepgraph/deepgraph.git	Analyze Data with Pandas-based Networks. Documentation:
:::2540	ogi	Graph / Link Analysis	ogi	312	Python	https://github.com/khashashin/ogi.git	Open Source Link Analysis OSINT Framework
:::2541	holehe-maltego	Graph / Link Analysis	holehe-maltego	255	Python	https://github.com/megadose/holehe-maltego.git	Holehe transform for maltego
:::2542	inquisitor	Graph / Link Analysis	inquisitor	180	Python	https://github.com/penafieljlm/inquisitor.git	Opinionated organisation-centric OSINT footprinting inspired from recon-ng and Maltego
:::2543	argos	Graph / Link Analysis	Argos	170	Shell	https://github.com/SOsintOps/Argos.git	This script will automatically set up an OSINT workstation starting from a Ubuntu OS
:::2544	maltego	Graph / Link Analysis	Maltego	163	-	https://github.com/M0m0SMS-OSINT/Maltego.git	Maltego compilation of various assets, local transforms and helpful scripts
:::2545	canari3	Graph / Link Analysis	canari3	145	Python	https://github.com/malleum-inc/canari3.git	Canari v3 - next gen Maltego framework for rapid remote and local transform development
:::2546	phoneinfoga-maltego	Graph / Link Analysis	phoneinfoga-maltego	135	Python	https://github.com/megadose/phoneinfoga-maltego.git	Phoneinfoga Maltego Transform
:::2547	maltego-tools	Graph / Link Analysis	maltego-tools	89	Python	https://github.com/Reflets-info/maltego-tools.git	Maltego transforms for investigative journalism
:::2548	spiderfoot-neo4j	Graph / Link Analysis	spiderfoot-neo4j	86	Python	https://github.com/blacklanternsecurity/spiderfoot-neo4j.git	Import, visualize, and analyze SpiderFoot scans in Neo4j, a graph database
:::2549	kipi	Graph / Link Analysis	kipi	72	Python	https://github.com/assafkip/kipi.git	Open-source, self-hosted OSINT investigation platform: turn documents into a live, investigated entity graph. 
:::2550	maltego_transforms	Graph / Link Analysis	maltego_transforms	71	Python	https://github.com/hackertarget/maltego_transforms.git	Use the Hacker Target IP Tools API for Reconnaissance in Maltego
:::2551	maltego-haveibeenpwned	Graph / Link Analysis	Maltego-haveibeenpwned	64	-	https://github.com/cmlh/Maltego-haveibeenpwned.git	Maltego integration of https://haveibeenpwned.com
:::2552	toutatis-maltego	Graph / Link Analysis	toutatis-maltego	59	Python	https://github.com/megadose/toutatis-maltego.git	Toutatis transform for maltego
:::2553	hunter-maltego	Graph / Link Analysis	hunter-maltego	44	Python	https://github.com/megadose/hunter-maltego.git	Maltego transform for hunter.io
:::2554	quidam-maltego	Graph / Link Analysis	quidam-maltego	44	Python	https://github.com/megadose/quidam-maltego.git	Quidam maltego transform
:::2555	censys-maltego	Graph / Link Analysis	censys-maltego	41	Python	https://github.com/censys/censys-maltego.git	Censys Maltego transforms Take advantage of Censys transforms for Maltego to back your investigations with the
:::2556	recon-ng-maltego	Graph / Link Analysis	recon-ng-maltego	41	Python	https://github.com/bostonlink/recon-ng-maltego.git	recon-ng Maltego local transform pack
:::2557	maltego-clearbit	Graph / Link Analysis	Maltego-Clearbit	40	-	https://github.com/cmlh/Maltego-Clearbit.git	Maltego integration of https://clearbit.com
:::2558	opencti-maltego	Graph / Link Analysis	opencti-maltego	32	Python	https://github.com/maltegotransforms/opencti-maltego.git	Maltego local and server integration for OpenCTI
:::2559	web-penetration-testing-with-kali-linux-	Graph / Link Analysis	Web-Penetration-Testing-with-Kali-Linux-	31	HTML	https://github.com/PacktPublishing/Web-Penetration-Testing-with-Kali-Linux-Third-Edition.git	Web Penetration Testing with Kali Linux - Third Edition, published by Packt
:::2560	totem-maltego	Graph / Link Analysis	totem-maltego	29	Python	https://github.com/megadose/totem-maltego.git	Totem maltego transform
:::2561	osint-projects-for-beginners	Graph / Link Analysis	OSINT-Projects-for-Beginners	29	-	https://github.com/0xrajneesh/OSINT-Projects-for-Beginners.git	Get hands-on with OSINT tools such as Recon-ng, Maltego, Shodan and Sherlock
:::2562	osintbuddy-plugins	Graph / Link Analysis	osintbuddy-plugins	28	Python	https://github.com/jerlendds/osintbuddy-plugins.git	Create and extend OSINT plugins for transforming data in a modular manner: https://github.com/jerlendds/osintb
:::2563	maltego-fullcontact	Graph / Link Analysis	Maltego-FullContact	26	-	https://github.com/cmlh/Maltego-FullContact.git	Maltego Integration of https://www.fullcontact.com/ @FullContact
:::2564	avkashk-osint	Graph / Link Analysis	OSINT	25	-	https://github.com/avkashk/OSINT.git	Open Source Intelligence
:::2565	nqntnqnqmb-maltego	Graph / Link Analysis	nqntnqnqmb-maltego	24	Python	https://github.com/megadose/nqntnqnqmb-maltego.git	Nqntnqnqmb transform maltego
:::2566	maltego-stix2	Graph / Link Analysis	maltego-stix2	21	Python	https://github.com/maltegotransforms/maltego-stix2.git	Generation of STIX2 compliant entities for Maltego
:::2567	nexusint	Graph / Link Analysis	NEXUsint	19	Python	https://github.com/Kit4Some/NEXUsint.git	Multi-INT Fusion OSINT Platform Real-time intelligence collection, knowledge graph analysis, and 30+ live data
:::2568	abster-intelligence	Graph / Link Analysis	Abster-Intelligence	19	TypeScript	https://github.com/frangelbarrera/Abster-Intelligence.git	Sovereign OSINT platform for modern investigators. Local-first, open-source, and privacy-centric
:::2569	ghunt-maltego	Graph / Link Analysis	ghunt-maltego	18	Python	https://github.com/kodamaChameleon/ghunt-maltego.git	Maltego Transform Partner to Ghunt for OSINT Node Graph Analysis
:::2570	transnet	Graph / Link Analysis	TransNet	17	C#	https://github.com/secana/TransNet.git	Net library to create Maltego transformations
:::2571	maltego-abusix	Graph / Link Analysis	Maltego-Abusix	16	-	https://github.com/cmlh/Maltego-Abusix.git	Maltego integration of https://abusix.com
:::2572	maltego-transformation-template	Graph / Link Analysis	maltego-transformation-template	15	Python	https://github.com/soxoj/maltego-transformation-template.git	A template for standard Maltego transformation
:::2573	cqfd-maltego	Graph / Link Analysis	cqfd-maltego	14	Python	https://github.com/megadose/cqfd-maltego.git	Maltego Transforms with cqfd
:::2574	keskivonfer-maltego	Graph / Link Analysis	keskivonfer-maltego	14	Python	https://github.com/megadose/keskivonfer-maltego.git	Maltego transform with Keskivonfer
:::2575	steamtransforms	Graph / Link Analysis	SteamTransforms	13	Python	https://github.com/WlndyMiller/SteamTransforms.git	Maltego transforms for the Steam community
:::2576	omoika	Graph / Link Analysis	omoika	11	-	https://github.com/omoika-institute/omoika.git	Entity graphs, OSINT data mining, and plugins. Connect unstructured and public data for transformative insight
:::2577	docs	Graph / Link Analysis	docs	5	HTML	https://github.com/owasp-amass/docs.git	Official Documentation for the OWASP Amass Project
:::2578	imhex	Forensics	ImHex	54845	C++	https://github.com/WerWolv/ImHex.git	A Hex Editor for Reverse Engineers, Programmers and people who value their retinas when working at 3 AM
:::2579	prowler	Forensics	prowler	14841	Python	https://github.com/prowler-cloud/prowler.git	Prowler is the worlds most widely used open-source cloud security platform that automates security and complia
:::2580	mvt	Forensics	mvt	13281	Python	https://github.com/mvt-project/mvt.git	MVT Mobile Verification Toolkit helps with conducting forensics of mobile devices in order to find signs of 
:::2581	chainsaw	Forensics	chainsaw	3665	Rust	https://github.com/WithSecureOpenSource/chainsaw.git	Rapidly Search and Hunt through Windows Forensic Artefacts
:::2582	timesketch	Forensics	timesketch	3419	Python	https://github.com/google/timesketch.git	Collaborative forensic timeline analysis
:::2583	hayabusa	Forensics	hayabusa	3357	Rust	https://github.com/Yamato-Security/hayabusa.git	Hayabusa  is a sigma-based threat hunting and fast forensics timeline generator for Windows event logs
:::2584	digital-forensics-guide	Forensics	Digital-Forensics-Guide	3157	Python	https://github.com/mikeroyal/Digital-Forensics-Guide.git	Digital Forensics Guide. Learn all about Digital Forensics, Computer Forensics, Mobile device Forensics, Netwo
:::2585	plaso	Forensics	plaso	2159	Python	https://github.com/log2timeline/plaso.git	Super timeline all the things
:::2586	memlabs	Forensics	MemLabs	1903	Shell	https://github.com/stuxnet999/MemLabs.git	Educational, CTF-styled labs for individuals interested in Memory Forensics
:::2587	recoverpy	Forensics	RecoverPy	1790	Python	https://github.com/PabloLec/RecoverPy.git	Interactively find and recover deleted or :point_right: overwritten :point_left: files from your terminal
:::2588	hindsight	Forensics	hindsight	1513	Python	https://github.com/RyanDFIR/hindsight.git	Browser forensics tool for Google Chrome, other Chromium-based browsers, and Mozilla Firefox
:::2589	uac	Forensics	uac	1457	Shell	https://github.com/tclahr/uac.git	UAC is a powerful and extensible incident response tool designed for forensic investigators, security analysts
:::2590	mac_apt	Forensics	mac_apt	1085	Python	https://github.com/ydkhatri/mac_apt.git	macOS  ios Artifact Parsing Tool
:::2591	hackdroid	Forensics	hackdroid	1077	-	https://github.com/thehackingsage/hackdroid.git	Security Apps for Android
:::2592	zircolite	Forensics	Zircolite	854	Python	https://github.com/wagga40/Zircolite.git	A standalone SIGMA-based detection tool for EVTX, Auditd and Sysmon for Linux logs
:::2593	ctf-super-hub	Forensics	ctf-super-hub	816	JavaScript	https://github.com/asdfgh1445/ctf-super-hub.git	CTF / Skills
:::2594	turbinia	Forensics	turbinia	795	Python	https://github.com/google/turbinia.git	Automation and Scaling of Digital Forensics Tools
:::2595	forensia	Forensics	Forensia	788	C++	https://github.com/PaulNorman01/Forensia.git	Anti Forensics Tool For Red Teamers, Used For Erasing Footprints In The Post Exploitation Phase
:::2596	pwf	Forensics	PWF	785	PowerShell	https://github.com/bluecapesecurity/PWF.git	Practical Windows Forensics Training
:::2597	wela-deprecated	Forensics	WELA-deprecated	776	PowerShell	https://github.com/Yamato-Security/WELA-deprecated.git	WELA Windows Event Log Analyzer: The Swiss Army knife for Windows Event Logs
:::2598	linuxforensics	Forensics	LinuxForensics	728	Shell	https://github.com/ashemery/LinuxForensics.git	Everything related to Linux Forensics
:::2599	osint-forensics-mobile	Forensics	OSINT-FORENSICS-MOBILE	704	-	https://github.com/CScorza/OSINT-FORENSICS-MOBILE.git	Tools OSINT MOBILE
:::2600	live-forensicator	Forensics	Live-Forensicator	634	PowerShell	https://github.com/Johnng007/Live-Forensicator.git	Cross-platform incident response and live forensics toolkit with built-in detection, structured analysis, and 
:::2601	diffy	Forensics	diffy	630	Python	https://github.com/Netflix-Skunkworks/diffy.git	:no_entry: DEPRECATED Diffy is a triage tool used during cloud-centric security incidents, to help digital f
:::2602	recuperabit	Forensics	RecuperaBit	622	Python	https://github.com/Lazza/RecuperaBit.git	A tool for forensic file system reconstruction
:::2603	pano	Forensics	PANO	602	Python	https://github.com/ALW1EZ/PANO.git	PANO: Advanced OSINT investigation platform combining graph visualization, timeline analysis, and AI assistanc
:::2604	tailpipe	Forensics	tailpipe	580	Go	https://github.com/turbot/tailpipe.git	select * from logs; Tailpipe is an open source SIEM for instant log insights, powered by DuckDB. Analyze milli
:::2605	analyzemft	Forensics	analyzeMFT	533	Python	https://github.com/rowingdude/analyzeMFT.git	analyzeMFT.py is designed to fully parse the MFT file from an NTFS filesystem and present the results as accur
:::2606	iphone_backup_decrypt	Forensics	iphone_backup_decrypt	384	Python	https://github.com/jsharkey13/iphone_backup_decrypt.git	Decrypt an encrypted local iOS backup on Windows or MacOS
:::2607	sara	Forensics	Sara	343	Python	https://github.com/caster0x00/Sara.git	MikroTik RouterOS Security Inspector
:::2608	mftecmd	Forensics	MFTECmd	337	C#	https://github.com/EricZimmerman/MFTECmd.git	Parses $MFT from NTFS file systems
:::2609	rdpcachestitcher	Forensics	RdpCacheStitcher	334	C++	https://github.com/BSI-Bund/RdpCacheStitcher.git	RdpCacheStitcher is a tool that supports forensic analysts in reconstructing useful images out of RDP cache bi
:::2610	fuji	Forensics	Fuji	300	Python	https://github.com/Lazza/Fuji.git	macOS forensic acquisition made simple
:::2611	ctf-tools	Forensics	CTF-Tools	290	-	https://github.com/MrMugiwara/CTF-Tools.git	Useful CTF Tools
:::2612	coeus-osint-toolbox	Forensics	Coeus-OSINT-ToolBox	276	HTML	https://github.com/AnonCatalyst/Coeus-OSINT-ToolBox.git	Coeus is an OSINT ToolBox empowering users with tools for effective intelligence gathering from open sources. 
:::2613	upload-secure-artifact	Forensics	upload-secure-artifact	42	JavaScript	https://github.com/PaloAltoNetworks/upload-secure-artifact.git	This GitHub Action scans artifacts for secrets using gitleaks before uploading them
:::2614	robin	Dark Web	robin	7207	Python	https://github.com/apurvsinghgautam/robin.git	AI-Powered Dark Web OSINT Tool
:::2615	dark-web-osint-tools	Dark Web	dark-web-osint-tools	2601	-	https://github.com/apurvsinghgautam/dark-web-osint-tools.git	OSINT Tools for the Dark Web
:::2616	pcapxray	Dark Web	PcapXray	1880	Python	https://github.com/srixivas/PcapXray.git	:snowflake: PcapXray - A Network Forensics Tool - To visualize a Packet Capture offline as a Network Diagram i
:::2617	onionsearch	Dark Web	OnionSearch	1794	Python	https://github.com/megadose/OnionSearch.git	OnionSearch is a script that scrapes urls on different .onion search engines
:::2618	voidaccess	Dark Web	voidaccess	734	Python	https://github.com/KatrielMoses/voidaccess.git	Self-hosted dark web OSINT platform. Automated threat intelligence from query to graph in 13 steps. Free alter
:::2619	darkus	Dark Web	Darkus	695	Python	https://github.com/Lucksi/Darkus.git	A Onion websites searcher
:::2620	docker-onion-nmap	Dark Web	docker-onion-nmap	542	Shell	https://github.com/milesrichardson/docker-onion-nmap.git	Scan .onion hidden services with nmap using Tor, proxychains and dnsmasq in a minimal alpine Docker container
:::2621	darkscrape	Dark Web	DarkScrape	512	Python	https://github.com/itsmehacker/DarkScrape.git	OSINT Tool For Scraping Dark Websites
:::2622	conduit-manager	Dark Web	conduit-manager	371	Shell	https://github.com/SamNet-dev/conduit-manager.git	A powerful, one-click management tool for Psiphon Conduit nodes. Simplifies deployment, automation, and real-t
:::2623	thedevilseye	Dark Web	thedevilseye	267	-	https://github.com/rly0nheart/thedevilseye.git	An osint tool that uses Ahmia.fi to get hidden services and descriptions that match with the users query
:::2624	onionclaw	Dark Web	OnionClaw	237	Python	https://github.com/christinminor459/OnionClaw.git	Provide AI agents with full Tor network access and dark web data through a zero-config OpenClaw skill or stand
:::2625	anongt	Dark Web	AnonGT	237	Python	https://github.com/gt0day/AnonGT.git	Redirect All Traffic Through Tor Network For Kali Linux
:::2626	darc	Dark Web	darc	234	Python	https://github.com/JarryShaw/darc.git	Darkweb Crawler Project
:::2627	red-rabbit	Dark Web	Red-Rabbit	195	Go	https://github.com/TotallyNotAHaxxer/Red-Rabbit.git	The Red Rabbit project is just what a hacker needs for everyday automation. Red Rabbit unlike most frameworks 
:::2628	gotor	Dark Web	gotor	174	Go	https://github.com/DedSecInside/gotor.git	Concurrent Go web crawler with first-class Tor SOCKS5 support, a CLI, versioned JSON reports, and a job-contro
:::2629	turbo-scanner	Dark Web	turbo-scanner	167	Go	https://github.com/mytechnotalent/turbo-scanner.git	A port scanner and service detection tool that uses 1000 goroutines at once to scan any hosts IP or FQDN with 
:::2630	threatintel-platform	Dark Web	threatintel-platform	142	Python	https://github.com/osintph/threatintel-platform.git	A platform for threat intelligence brand monitoring, dark web intelligence, osint, and more
:::2631	osintinvestigation	Dark Web	OSINTInvestigation	119	-	https://github.com/CScorza/OSINTInvestigation.git	OSINTinvestigation - Tecniche OSINT - Strumenti - DeepWeb - Archivio
:::2632	initial-access-broker-landscape	Dark Web	Initial-Access-Broker-Landscape	116	-	https://github.com/curated-intel/Initial-Access-Broker-Landscape.git	A visualized overview of the Initial Access Broker IAB cybercrime landscape
:::2633	hostonion	Dark Web	HostOnion	98	Python	https://github.com/anubhavanonymous/HostOnion.git	Host A Hidden Service on TOR with an Onion Address
:::2634	onion-lookup	Dark Web	onion-lookup	66	Python	https://github.com/ail-project/onion-lookup.git	Tor onion address lookup
:::2635	tor-everything	Dark Web	TOR-Everything	62	-	https://github.com/mytechnotalent/TOR-Everything.git	Simple FREE guide to set up TOR stealth and persistence with complete anonymity
:::2636	beginner-bug-bounty-automation	Dark Web	Beginner-Bug-Bounty-Automation	62	Python	https://github.com/sam5epi0l/Beginner-Bug-Bounty-Automation.git	Many script that can be modified according to your needs for Information Gathering and Asset discovery in Bug 
:::2637	dark-web-links	Dark Web	Dark-Web-Links	59	-	https://github.com/Giddyspurz/Dark-Web-Links.git	Some Links to surf on the DarkWeb
:::2638	torserv	Dark Web	torserv	52	HTML	https://github.com/torserv/torserv.git	Hardened zero-config static web server that automatically launches as a Tor hidden service. Ideal for anonymou
:::2639	dedmap	Dark Web	DEDMAP	47	Python	https://github.com/7Ragnarok7/DEDMAP.git	A Network Automation framework focused on Cyber-Security
:::2640	anonsurf	Dark Web	anonsurf	44	Shell	https://github.com/machine1337/anonsurf.git	An Effiecent Tool To Change Tor IP's in Seconds,change mac address and clean all logs
:::2641	darkweb	Dark Web	DarkWeb	33	Python	https://github.com/akashblackhat/DarkWeb.git	A powerful tool to search the dark web using Tor. ShadowNet allows you to search .onion websites with the help
:::2642	element-protocol	Dark Web	element-protocol	26	C	https://github.com/element-protocol/element-protocol.git	The decentralized, completely anonymous, lightweight, peer-to-peer network communication protocol
:::2643	inspy	Dark Web	Inspy	24	Python	https://github.com/webdragon63/Inspy.git	An Advanced Darkweb OSINT Tool
:::2644	medor	Dark Web	medor	19	Python	https://github.com/balestek/medor.git	medor is an OSINT tool that enables you to discover a WordPress website IP behind a WAF or behind Onion Servic
:::2645	maltego-darknet-transforms	Dark Web	maltego-darknet-transforms	17	PHP	https://github.com/kawaiipantsu/maltego-darknet-transforms.git	Maltego DarkNET Transforms - These are all PHP local transforms that i am trying to maintain and deploy in a e
:::2646	simpleonionmap	Dark Web	simpleOnionMap	4	Python	https://github.com/hv0l/simpleOnionMap.git	Onion Scanner is a Python script that performs port scans using Nmap on Onion websites within the Tor network
:::2647	soc-darkwatch	Dark Web	SOC-DarkWatch	3	-	https://github.com/amitambekar510/SOC-DarkWatch.git	Open-source dark web monitoring for SOC teams phased build using SpiderFoot, TorBot, MISP, integrated with ELK
:::2648	shadowbroker	Wireless	Shadowbroker	11208	Python	https://github.com/BigBodyCobain/Shadowbroker.git	Open-source intelligence for the global theater. Track everything from the corporate/private jets of the wealt
:::2649	aircrack-ng	Wireless	aircrack-ng	7661	C	https://github.com/aircrack-ng/aircrack-ng.git	WiFi security auditing tools suite
:::2650	netalertx	Wireless	NetAlertX	7180	Python	https://github.com/netalertx/NetAlertX.git	Centralized network visibility and continuous asset discovery. Monitor devices, detect change, and stay aware 
:::2651	airgorah	Wireless	airgorah	3554	Rust	https://github.com/martin-olivier/airgorah.git	A WiFi security auditing software
:::2652	pi-alert	Wireless	Pi.Alert	2768	JavaScript	https://github.com/pucherot/Pi.Alert.git	WIFI / LAN intruder detector. Check the devices connected and alert you with unknown devices. It also warns of
:::2653	kithack	Wireless	KitHack	2091	Python	https://github.com/AdrMXR/KitHack.git	Hacking tools pack backdoors generator
:::2654	halehound-cyd	Wireless	HaleHound-CYD	1730	-	https://github.com/JesseCHale/HaleHound-CYD.git	ESP32-DIV HaleHound Edition for Cheap Yellow Display - Multi-protocol offensive security toolkit
:::2655	wifi-deauth	Wireless	wifi-deauth	910	Python	https://github.com/flashnuke/wifi-deauth.git	A deauth attack that disconnects all devices from the target wifi network 2.4Ghz 5Ghz, WPA3 also supported 
:::2656	super	Wireless	super	863	JavaScript	https://github.com/spr-networks/super.git	One wifi password per device. Ad Blocking Privacy Blocklists. Policy Based Network Access
:::2657	swap_digger	Wireless	swap_digger	536	Shell	https://github.com/sevagas/swap_digger.git	swap_digger is a tool used to automate Linux swap analysis during post-exploitation or forensics. It automates
:::2658	wifi-hacking-py	Wireless	wifi-hacking.py	530	Python	https://github.com/akashblackhat/wifi-hacking.py.git	Cyber Security Tool For Hacking Wireless Connections Using Built-In Kali Tools. Supports All Securities WEP, 
:::2659	flipper-zero-backpacks	Wireless	flipper-zero-backpacks	446	C++	https://github.com/Chrismettal/flipper-zero-backpacks.git	Backpack-style addon boards for the Flipper Zero
:::2660	netspionage	Wireless	netspionage	306	Python	https://github.com/ANG13T/netspionage.git	Network Forensics CLI utility that performs Network Scanning, OSINT, and Attack Detection
:::2661	probequest	Wireless	probequest	281	Python	https://github.com/SkypLabs/probequest.git	Toolkit for Playing with Wi-Fi Probe Requests
:::2662	whoishere-py	Wireless	whoishere.py	250	Python	https://github.com/hkm/whoishere.py.git	WIFI Client Detection - Identify people by assigning a name to a device performing a wireless probe request
:::2663	bombercat	Wireless	BomberCat	186	HTML	https://github.com/ElectronicCats/BomberCat.git	BomberCat is the latest security tool that combines the most common card technologies: NFC technology Near Fi
:::2664	generaldussduss-poseidon	Wireless	poseidon	186	C++	https://github.com/GeneralDussDuss/poseidon.git	80+ feature pentesting firmware for M5Stack Cardputer-Adv. WiFi, BLE, sub-GHz CC1101, 2.4GHz nRF24, LoRa 
:::2665	gapcast	Wireless	gapcast	176	Go	https://github.com/ANDRVV/gapcast.git	802.11 broadcast analyzer injector
:::2666	pifinger	Wireless	PiFinger	160	Python	https://github.com/WiPi-Hunter/PiFinger.git	Searches for wifi-pineapple traces and calculate wireless network security score
:::2667	wifi-deauther	Wireless	wifi-deauther	159	Python	https://github.com/ZKAW/wifi-deauther.git	802.11 deauthentication tool for Wi-Fi security testing and research
:::2668	netradar	Wireless	NetRadar	153	Shell	https://github.com/XDeadHackerX/NetRadar.git	NetRadar is a Networking tool focused on mapping local and WiFi networks. It provides detailed information abo
:::2669	autowifi	Wireless	AutoWIFI	61	Python	https://github.com/momenbasel/AutoWIFI.git	Wireless penetration testing framework. Automates WPA/WPA2/WEP/WPS attacks - recon to exploitation in one comm
:::2670	peanuts	Wireless	Peanuts	37	Python	https://github.com/NoobieDog/Peanuts.git	Peanuts is a free and open source wifi tracking tool. Based on the SensePosts Snoopy-NG project that is now cl
:::2671	whatbreach	Breach / Leaks	WhatBreach	1681	Python	https://github.com/Ekultek/WhatBreach.git	OSINT tool to find breached emails, databases, pastes, and relevant information
:::2672	ail-framework	Breach / Leaks	ail-framework	1016	Python	https://github.com/ail-project/ail-framework.git	AIL framework - Analysis Information Leak framework
:::2673	leaker	Breach / Leaks	leaker	594	Go	https://github.com/vflame6/leaker.git	Passive leak enumeration tool
:::2674	darknet-mcp-server	Breach / Leaks	darknet-mcp-server	455	TypeScript	https://github.com/badchars/darknet-mcp-server.git	66-tool MCP server for dark web intelligence breach data, ransomware tracking, Tor .onion access, malware anal
:::2675	leakscraper	Breach / Leaks	leakScraper	449	Python	https://github.com/Acceis/leakScraper.git	LeakScraper is an efficient set of tools to process and visualize huge text files containing credentials. Thes
:::2676	nox-framework	Breach / Leaks	nox-framework	328	Python	https://github.com/nox-project/nox-framework.git	High-performance OSINT/CTI framework for automated identity pivoting and risk analysis across 120+ sources
:::2677	osint-d2	Breach / Leaks	osint-d2	268	Python	https://github.com/Doble-2/osint-d2.git	Agentic OSINT toolkit. Autonomous identity triangulation, 6-dimension cognitive profiling, breach analysis. CL
:::2678	keyhunter	Breach / Leaks	keyhunter	183	Rust	https://github.com/fadidevv/keyhunter.git	Fast Rust scanner to find leaked API keys on GitHub - OpenAI, Anthropic, Claude, GPT, AWS, Stripe, HuggingFace
:::2679	conti-ransomware	Breach / Leaks	Conti-Ransomware	180	C++	https://github.com/gharty03/Conti-Ransomware.git	Full source of the Conti Ransomware Including the missing Locker files from the original leak. I have fixed so
:::2680	xposedornot	Breach / Leaks	XposedOrNot	149	Python	https://github.com/Viralmaniar/XposedOrNot.git	XposedOrNot XoN tool is to search an aggregated repository of xposed passwords comprising of ~850 million re
:::2681	evildork	Breach / Leaks	evildork	95	Python	https://github.com/Fricciolosa-Red-Team/evildork.git	Evildork targeting your fiancee
:::2682	tgsint-bot	Breach / Leaks	tgsint-bot	63	Python	https://github.com/bugourmet/tgsint-bot.git	Telegram OSINT Bot
:::2683	ddwpasterecon	Breach / Leaks	DDWPasteRecon	46	C#	https://github.com/Viralmaniar/DDWPasteRecon.git	DDWPasteRecon tool will help you identify code leak, sensitive files, plaintext passwords, password hashes. It
:::2684	skills	Breach / Leaks	Skills	38	Shell	https://github.com/UseOSINT/Skills.git	28 OSINT Agent Skills that turn Cursor, Claude AI coding agents into a full open-source intelligence platform 
:::2685	p1sty	Breach / Leaks	P1sty	28	Python	https://github.com/jonathan6661/P1sty.git	Fraud prevention tool
:::2686	agent-guard	Breach / Leaks	agent-guard	28	Shell	https://github.com/JeongJaeSoon/agent-guard.git	Real-time secret-leak guardrails for AI coding agents Claude Code, Codex, Git hooks, and CI
:::2687	leakrecon	Breach / Leaks	LeakRecon	11	Python	https://github.com/egnake/LeakRecon.git	An advanced, asynchronous OSINT and Dark Web reconnaissance framework engineered for automated threat intellig
:::2688	keywatch	Breach / Leaks	KeyWatch	5	Rust	https://github.com/pixincreate/KeyWatch.git	KeyWatch the vigilant guardian that sniffs out hidden keys and secrets in your code with a wink and a nod
:::2689	xsentry	Breach / Leaks	xSentry	2	Go	https://github.com/xSPRV/xSentry.git	Fast, lightweight secret scanner for Git repos and filesystems TruffleHog + Gitleaks alternative
:::2690	anthonyonazure-osint-hub	Breach / Leaks	osint-hub	1	JavaScript	https://github.com/anthonyonazure/osint-hub.git	Unified OSINT platform - SpiderFoot + IntelOwl + OpenCTI with identity, breach, secrets dark web tools
:::2691	forge-gitleaks-security-dashboard	Breach / Leaks	forge-gitleaks-security-dashboard	1	JavaScript	https://github.com/abhineetsagar/forge-gitleaks-security-dashboard.git	Real-time, organization-wide secret leak detection dashboard for Bitbucket Cloud, built on Atlassian Forge
:::2692	leak-triage-ml	Breach / Leaks	leak-triage-ml	1	Python	https://github.com/darshangvnptl/leak-triage-ml.git	Build a lightweight classifier that re-scores Gitleaks findings using contextual signals file path, variable 
:::2693	yandex-face-search	People / Identity	Yandex-Face-Search	900000	web	https://yandex.com/images/	FREE reverse face+image search, no account. Click the camera icon and upload a photo - best free face matcher.
:::2694	facecheck-id	People / Identity	FaceCheck-ID	899999	web	https://facecheck.id/	Facial recognition search across the web. Handles cropped/filtered faces. Free to search, pay to unlock source URLs.
:::2695	pimeyes	People / Identity	PimEyes	899998	web	https://pimeyes.com/	The most powerful face search - deep web crawl. Free results are blurred; subscription to see them.
:::2696	lenso-ai	People / Identity	Lenso-AI	899997	web	https://lenso.ai/en	AI reverse image and face search with a free tier.
:::2697	wholeaked	People / Identity	wholeaked	1101	Go	https://github.com/utkusen/wholeaked.git	a file-sharing tool that allows you to find the responsible person in case of a leakage
:::2698	profil3r	People / Identity	Profil3r	667	-	https://github.com/Greyjedix/Profil3r.git	OSINT tool that allows you to find a person's accounts and emails + breached emails
:::2699	eye_of_web	People / Identity	eye_of_web	322	Python	https://github.com/MehmetYukselSekeroglu/eye_of_web.git	State of the art OSINT tool. A powerful open-source alternative to other face search engines
:::2700	sylva	People / Identity	sylva	253	Python	https://github.com/ppfeister/sylva.git	Simplify the link between social and real identities
:::2701	helix	People / Identity	helix	25	Python	https://github.com/thalha-a9/helix.git	Helix by thalha-a9 An advanced asynchronous OSINT identity mapper and relation tool
:::2702	peoplescraper	People / Identity	PeopleScraper	8	Python	https://github.com/HelloByeLetsNot/PeopleScraper.git	PeopleScraper is a Python program that enables users to search multiple search engines for a given first name,
:::2703	poison	People / Identity	poison	6	Shell	https://github.com/resistec/poison.git	Poison is an aggregation and automation tool that relies on existing open source intelligence OSINT collecti
:::2704	e0xsecops-profil3r	People / Identity	Profil3r	2	Python	https://github.com/e0xsecops/Profil3r.git	OSINT tool that allows you to find a person's accounts and emails + breached emails
:::2705	on-chain-investigations-tools-list	Crypto / Finance	On-Chain-Investigations-Tools-List	1947	-	https://github.com/OffcierCia/On-Chain-Investigations-Tools-List.git	Here we discuss how one can investigate crypto hacks and security incidents, and collect all the possible tool
:::2706	web3	Crypto / Finance	web3	1928	HTML	https://github.com/life-itself/web3.git	Making sense of web3 crypto. Introduction to key concepts and ideas. Rigorous, constructive analysis of key cl
:::2707	horus	Crypto / Finance	horus	952	Python	https://github.com/6abd/horus.git	An OSINT / digital forensics tool built in Python
:::2708	orbit	Crypto / Finance	Orbit	619	Python	https://github.com/s0md3v/Orbit.git	Blockchain Transactions Investigation Tool
:::2709	time-series-machine-learning	Crypto / Finance	time-series-machine-learning	376	Python	https://github.com/maxim5/time-series-machine-learning.git	Machine learning models for time series analysis
:::2710	graphsense-maltego-transform	Crypto / Finance	GraphSense-Maltego-transform	43	Python	https://github.com/INTERPOL-Innovation-Centre/GraphSense-Maltego-transform.git	Query GraphSense clusters, details and attribution tag-packs directly in Maltego. By an initial idea of our Sw
:::2711	crypttrace	Crypto / Finance	crypttrace	20	Python	https://github.com/bobslayerX/crypttrace.git	OSINT crypto-investigation CLI trace stolen funds on-chain
:::2712	gitleaks-github-secret-scanner	Crypto / Finance	gitleaks-github-secret-scanner	2	Python	https://github.com/AnshumanAtrey/gitleaks-github-secret-scanner.git	Cloud-hosted gitleaks for GitHub - hunt leaked API keys, wallet private keys secrets across 40 services. PR re
:::2713	autopsy	Corporate / Business	autopsy	3344	Java	https://github.com/sleuthkit/autopsy.git	Autopsy is a digital forensics platform and graphical interface to The Sleuth Kit and other digital forensics 
:::2714	emploleaks	Corporate / Business	emploleaks	793	Python	https://github.com/infobyte/emploleaks.git	An OSINT tool that helps detect members of a company with leaked credentials
:::2715	osintbuddy	Corporate / Business	osintbuddy	179	-	https://github.com/osintbuddy/osintbuddy.git	Entity graphs, OSINT data mining, and plugins. Connect unstructured and public data for transformative insight
:::2716	bejaey-theharvester	Corporate / Business	theHarvester	0	-	https://github.com/Bejaey/theHarvester.git	theHarvester is a very simple to use, yet powerful and effective tool designed to be used in the early stages 
:::2717	theharvester-automation-script	Corporate / Business	theHarvester-Automation-Script	0	Shell	https://github.com/IshtiakNihal/theHarvester-Automation-Script.git	theHarvester is an OSINT tool or gathering emails, subdomains, hosts, employee names, and more from different 
