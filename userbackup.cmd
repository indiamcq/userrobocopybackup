@ECHO off

:variables
set action=robocopy
set type=/BU/FF
set outdrive=
set bakdir=backup-%username%
set robocopy=C:\Windows\SysWOW64\robocopy.exe
call:checkdrives


:menu1
set menuname=menu1
ECHO.
call:feedback
ECHO.
echo     Select main option or set other options below.
ECHO.
ECHO            B. Start backup %username% files		&set soption=mainloop 
ECHO.
ECHO            E. Exit 				&set eoption=exit
ECHO.
:: The menuoptions variable reflects what is in the letter choices above.
set menuoptions=b e
goto menuchoice

:menuchoice
 
:: SET /P prompts for input and sets the variable to whatever the user types
SET Choice=
SET /P Choice=Type the letter and press Enter: 
:: The syntax in the next line extracts the substring
:: starting at 0 (the beginning) and 1 character long
IF NOT '%Choice%'=='' SET Choice=%Choice:~0,1%

ECHO.
:: Loop to evaluate the input and start the correct process.
:: the following line processes the choice
FOR /D %%c IN (%menuoptions%) DO call:menueval %%c 
goto %menuname%


:menueval
:: run through the choices to find a match then calls the selected option
set let=%~1
::echo %option%
set option=%let%option
:: /I makes the IF comparison case-insensitive
IF /I '%Choice%'=='q' goto %%%option%%%
IF /I '%Choice%'=='%let%' call:%%%option%%%
::echo off
goto:eof

:mainloop
call:checkdrives
set backupgroup=username
FOR /D %%c IN (%backupgroup%) DO call:%%c
goto end

:username
set input=C:\users\%username%
set output=%outdrive%:\%bakdir%\%username%
call :%action%
goto:eof

:robocopy
echo off
call:splitpath
echo Starting to backup %input%
::pause 
SET prefix=robocopy_backup

REM This is the file that we're going to backup from our local drive
SET source_dir="%input%"

REM This is the location where the files will be copied to
REM on the external drive.
SET dest_dir="%output%"

REM Set the log file name based on the current date.  This
REM will record the results from the robocopy command.
REM The typical format for the date command is:
REM Mon 11/09/2000
REM So, we are parsing the date by moving 4 characters back and 
REM copy 4 characters to get the 4-digit year, then we get the 
REM 2-digit month by moving 10 characters back and copying 2 
REM characters.  Finally, we get the day by moving 7 characters
REM back and copying 2 characters.
SET log_fname=logs/%prefix%%date:~-4,4%%date:~-7,2%%date:~-10,2%.log

REM See the robocopy documentation for what each command does.
REM /COPY:DAT :: COPY file data, attributes, and timestamps
REM /COPYALL :: COPY ALL file info
REM /B :: copy files in Backup mode.
REM /MIR :: MIRror a directory tree
REM /L :: Just list the info, don't actually do it
SET what_to_copy=/COPY:DAT /MIR

REM Exclude some files and directories that include transient data
REM that doesn't need to be copied.
SET exclude_dirs=/XD "Temporary Internet Files" "Cache" "Recent" "Cookies" "iPod Photo Cache" "MachineKeys"
SET exclude_files=/XF *.bak *.tmp index.dat usrclass.dat* ntuser.dat* *.lock *.swp

REM Refer to the robocopy documentation for more details.
REM /R:n :: number of Retries
REM /W:n :: Wait time between retries
REM /LOG :: Output log file
REM /NFL :: No file logging
REM /NDL :: No dir logging
SET options=/R:0 /W:0 /LOG+:%log_fname% /NFL 
:: /NDL removed from options

REM Execute the command based on all of our parameters
echo Starting Robocopy . . .
%robocopy% %source_dir% %dest_dir% %what_to_copy% %options% %exclude_dirs% %exclude_files%
goto:eof

:checkdrives
echo Start check possible drives
for %%d in (d e f g h i k l j m n o p q r s t u v w x y z) do call:testdrive %%d
if "%outdrive%"=="" goto:error

goto:eof

:feedback
echo Backup program: %action%
rem echo Program backup type set to: %type%
goto:eof

:testdrive
set test=%~1

if "%outdrive%" neq ""  goto:eof
echo 	... testing %test%: drive
if exist %test%:\%bakdir% (
  set outdrive=%test%
  echo.
  echo outdrive set to %test% 
)  
goto:eof

:error
echo 	No drive with correct folder was found to backup to.
echo.
echo 	Is the correct backup drive attached?
echo 	Attach it and start again.
goto :eof

