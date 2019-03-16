@echo OFF
set DIRNAME=%~dp0
REM pushd %DIRNAME%

REM logstalgiaDir - self explanatory
set logstalgiaDir=Z:\APPS\logstalgia-1.0.9.win64

REM PUTTYBIN - self explanatory; get it from https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html
set PUTTYBIN=S:\wintools\lan\putty\64\plink.exe

REM PUTTY_SESSION=saved putty session in registry - must be password free: use pAgent with loaded RSA key for that purpose
set PUTTY_SESSION=web-scav-01

REM setup your logs path accordingly; it's nginx by default + custom path
REM LOGS should respect NCSA extended/combined log format and TZ should be set in system/systemd
set LOGS=/var/log/nginx/access.log /data/www/html/*.com/logs/access.log
REM set LOGS=/data/www/html/*.com/logs/access.extended.log

REM it's possible to specify a different TZ from the server; use signed integers: -5, +12, etc
set TZ=0

REM load-config=path to logstalgia config file.ini: start logstalgia with --save-config CONFIG_FILE to generate one
REM the default viewport=1280x720
set load-config=%DIRNAME%profile-default.ini

REM default remote commands for either log replay or follow
set remoteCmdReplay=cat
set remoteCmdTailPlus=tail -fq
set remoteCmdTail=tail -fqn1

REM defaults: by default we propose to REPLAY but we must set default commands to FollowPlus for batch scripting reasons
set FROMDATE=1
set REPLAY=Y
set SPEED=10
set pitch-speed=0.1
set FOLLOW=-
set remoteCommand=%remoteCmdTailPlus%

:: -----------------------------------------
:MAIN
echo.
set /p REPLAY=Replay? [%REPLAY%/n] 
if /I "x%REPLAY%x" EQU "xYx" call :setReplay
call :setTime
call :settings
call :showHelp
goto :logstalgia
:: -----------------------------------------

:setTime
set CURRENT_DATE=%DATE:/=-%
set CURRENT_TIME=%TIME%
if "%CURRENT_TIME:~0,1%" == " " set CURRENT_TIME=0%CURRENT_TIME:~1%
set CURRENT_TIME=%CURRENT_TIME:~0,5%

:: use modulo 10 because cannot calculate with numbers starting with 0...
set /a "lastHour=10%CURRENT_TIME:~0,2% %% 100 - 1"
:: add leading 0 if hour < 10
if %lastHour% LSS 10 set lastHour=0%lastHour%
:: add minutes to lastHour
set lastHour=%lastHour%%CURRENT_TIME:~2,3%

set GOOD_DATE=%CURRENT_DATE:~0,10%
:: ISO
if "%CURRENT_DATE:~2,1%" EQU "-" set GOOD_DATE=%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%
:: US
if "%CURRENT_DATE:~3,1%" EQU " " set GOOD_DATE=%DATE:~10,4%-%DATE:~4,2%-%DATE:~7,2%
REM GOOD_DATE=2019-03-18

REM yesterday crappy calculation; doesn't work if shifting back last month
set /a yesterday=%DATE:~7,2% - 1
if %yesterday% LSS 10 set yesterday=0%yesterday%
set GOOD_DATE_YESTERDAY=%DATE:~10,4%-%DATE:~4,2%-%yesterday%
REM pause
goto :EOF

:settings
echo TODAY        = [ ] = %GOOD_DATE%
echo FROM yesterday=[y] = %GOOD_DATE_YESTERDAY% %CURRENT_TIME%
echo FROM midnight= [m] = %GOOD_DATE% 00:01
echo FROM 1 hour  = [1] = %GOOD_DATE% %lastHour%
if /I "x%REPLAY%x" NEQ "xYx" echo FROM now     = [0] = %GOOD_DATE% %CURRENT_TIME%
echo.
echo Please enter one of the options above OR a DATE^+TIME in the exact same format as above:
set /p FROMDATE=start from? [%FROMDATE%] 

REM SPEED is adjusted depending on FROMDATE
if /I "x%FROMDATE%x" EQU "xmx" set STARTFROM=%GOOD_DATE% 00:01
if /I "x%FROMDATE%x" EQU "xyx" set STARTFROM=%GOOD_DATE% %CURRENT_TIME%
if "x%FROMDATE%x" EQU "x1x" set STARTFROM=%GOOD_DATE% %lastHour%
if "x%FROMDATE%x" EQU "x1x" set SPEED=1
if "x%FROMDATE%x" EQU "x0x" set remoteCommand=%remoteCmdTail%
if "x%FROMDATE%x" EQU "x0x" set SPEED=1
REM SPEED is asked only if not following logs at current time:
if "x%FROMDATE%x" NEQ "x0x" set /p SPEED=SPEED? [%SPEED%] 

:: adapt pitch-speed to play speed
if %SPEED% LSS 5 set pitch-speed=0.5

REM last call, when the user enters direclty date+time:
if NOT DEFINED STARTFROM set STARTFROM=%FROMDATE%
if "%TZ%" NEQ "0" set STARTFROM=%STARTFROM% %TZ%
REM pause
goto :EOF

:setReplay
set remoteCommand=%remoteCmdReplay%
set FOLLOW=
goto :EOF

:showHelp
echo Interactive keyboard commands:
echo.
echo    (C)   Displays Logstalgia logo
echo    (N)   Jump forward in time to next log entry
echo    (+-)  Adjust simulation speed
echo    (^<^>)  Adjust pitch speed
echo    (F5)  Reload config
echo    (F6)  Load config (Windows only)
echo    (F11) Window frame toggle
echo    (F12) Screenshot
echo    (Alt+Enter) Fullscreen toggle
echo    (Ctrl+S) Save config
echo    (Home/End)          Adjust address summarizer maximum depth
echo    (Page Up/Down)      Adjust group summarizer maximum depth
echo    (Ctrl+Home/End)     Adjust address summarizer abbreviation depth
echo    (Ctrl+Page Up/Down) Adjust group summarizer abbreviation depth
echo    (ESC) Quit
goto :EOF

:logstalgia
REM STARTFROM is set only if FROMDATE == midight or lastHour
REM if following logs, FROMDATE must be == 0 and STARTFROM empty

if "x%STARTFROM%x" NEQ "xx" set STARTFROM=--from "%STARTFROM%"
echo.
if DEFINED STARTFROM echo STARTING--from=%STARTFROM%

pushd %logstalgiaDir%
:: parameters in this batch take precedence over the ones in the config file
%PUTTYBIN% -load "%PUTTY_SESSION%" %remoteCommand% %LOGS% | ^
logstalgia --full-hostnames ^
--simulation-speed %SPEED% ^
--pitch-speed %pitch-speed% ^
--glow-duration 1 ^
--glow-intensity 2 ^
--glow-multiplier 2 ^
--paddle-position 0.5 ^
--paddle-mode vhost ^
--display-fields timestamp,hostname,response_code,method,protocol,path,referrer,user_agent ^
--load-config %load-config% ^
--detect-changes %STARTFROM% %FOLLOW%


pause

:: ###########################################################################################################################
rem https://logstalgia.io/
rem https://github.com/acaudwell/Logstalgia
rem https://github.com/audioscavenger/utils/blob/master/traffic

rem pitch speed should be between 0.1 and 10.0
rem paddle-position is the right portion of the screen
rem -s 20 simulation speed 20 for replays
rem -p 0.1 slowest pitch for replays

REM ## Apache log_format: https://httpd.apache.org/docs/current/mod/mod_log_config.html
REM ## NCSA extended/combined log format:                   "%h    %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\""
REM ## NCSA extended/combined log format with Virtual Host: "%v %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\""
REM ## %v canonical ServerName = vhost
REM ## %h 193.227.171.131
REM ## %l Remote logname
REM ## %u Remote user
REM ## %t time [18/Sep/2011:19:18:28 -0400]
REM ## \"%r\" First line of request "GET / HTTP/1.1"
REM ## %>s final status
REM ## %b Size of response in byte
REM ## \"%{Referer}i\"     "193.227.171.131"
REM ## \"%{User-agent}i\"  "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:57.0) Gecko/20100101 Firefox/57.0"

REM ## http://nginx.org/en/docs/http/ngx_http_log_module.html
REM log_format NCSA-combined '$remote_addr - $remote_user [$time_local] '
REM '"$request" $status $body_bytes_sent '
REM '$bytes_sent "$http_referer" "$http_user_agent"';

REM log_format NCSA-extended '$host $http_x_forwarded_for - $remote_user [$time_local] '
REM '"$request" $status $body_bytes_sent '
REM '$bytes_sent "$http_referer" "$http_user_agent"';


