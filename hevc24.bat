REM https://github.com/EposVox/WindowsMods/blob/master/crf24_hevc.bat

REM This script uses transcodes media in a source folder (including subfolders) to HEVC using NVENC. The script can be placed in the directory with the source media, or it can process a list of directories in "paths.txt" file residing beside this script. Transcoded files will appear beside the source media with extra text in the name. When complete, the command prompt window will remain open until keypress.

pushd "%2"

REM Path per line should be within quotes: "E:\Captures".
REM Can select folders (15 max at a time) and shift+right-click and click "copy as paths".
SET paths=paths.txt

REM CQP value. 24 - a good balance between quality and size reduction of AVC.
SET /A ffmpeg_qv=24

REM Test if the paths file exists and iterate through it:
if EXIST %paths% (
    for /f "tokens=*" %%a in (%paths%) do (
        echo Changing to directory %%a
        pushd "%%a"
        CALL :ffmpeg
    )
) else (
    REM It doesn't exist. Continue for media in the same directory.
    CALL :ffmpeg
)
pause
EXIT /B %ERRORLEVEL%
REM Don't run the function when they're first defined because that's a thing Batch does for some reason???
:ffmpeg
    for /R %%A in (*.mp4, *.avi, *.mov, *.wmv, *.ts, *.m2ts, *.mkv, *.mts, *.m4v) do (
        echo Processing "%%A"
        REM "-pix_fmt p010le", before "-map 0:v", sets to 10-bit instead of using default 420 8-bit.
		REM  "-map_metadata 0" copies all metadata from source file.
		REM  "-movflags +faststart" helps with audio streaming.
        ffmpeg -hwaccel auto -i "%%A" -pix_fmt p010le -map 0:v -map 0:a -map_metadata 0 -c:v hevc_nvenc -rc constqp -qp %ffmpeg_qv% -b:v 0K -c:a aac -b:a 384k -movflags +faststart -movflags use_metadata_tags "%%~dnpA_cqp%ffmpeg_qv%.mp4"
        echo Processed %%A
    )
GOTO :EOF

REM "%%A": A placeholder variable typically used at the start of a 'for' loop in batch scripting. The double percentage signs (%%) are used to denote a loop variable.
REM "~": Modifier manipulates the value of the variable that precedes it, in this case being "%%".
REM "d": Modifier removes any drive letter and colon from the variable.
REM "n": Modifier removes any file extension from the variable.
REM "p": Modifier extracts the path (directory) portion from the variable.
REM "A": This is the placeholder variable referenced, which is being modified by "~dnp".