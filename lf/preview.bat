@echo off
setlocal enabledelayedexpansion

set "file=%~1"
set "ext=%~x1"
set "filename=%~nx1"

:: Check if it's a directory
if exist "%file%\*" (
    echo [38;2;97;175;239m[38;2;126;199;162m Directory: %filename%[0m
    echo [38;2;84;88;98m────────────────────────────────────────[0m
    dir /b "%file%" 2>nul | findstr /n "^" | findstr /b "^[1-4][0-9]:" >nul
    if !errorlevel! equ 0 (
        for /f "tokens=*" %%i in ('dir /b "%file%" 2^>nul ^| findstr /n "^" ^| findstr /b "^[1-5][0-9]:\|^[1-9]:"') do (
            for /f "tokens=1,* delims=:" %%a in ("%%i") do echo [38;2;171;178;191m%%b[0m
        )
        echo [38;2;84;88;98m... (showing first 50 items)[0m
    ) else (
        for /f "tokens=*" %%i in ('dir /b "%file%" 2^>nul') do echo [38;2;171;178;191m%%i[0m
    )
    exit /b
)

:: Handle archive files (basic info since 7z not available)
for %%a in (.zip .7z .tar .gz .rar .bz2 .xz .tgz .tbz2) do (
    if /i "%ext%"=="%%a" (
        echo [38;2;202;170;106m[38;2;126;199;162m Archive: %filename%[0m
        echo [38;2;84;88;98m────────────────────────────────────────[0m
        for %%F in ("%file%") do (
            echo [38;2;171;178;191mSize: %%~zF bytes[0m
            echo [38;2;171;178;191mType: %ext% archive[0m
        )
        echo.
        echo [38;2;84;88;98m(Archive preview requires 7z)[0m
        exit /b
    )
)

:: Handle image files (show info header)
for %%i in (.jpg .jpeg .png .gif .bmp .webp .ico .svg .tif .tiff .psd) do (
    if /i "%ext%"=="%%i" (
        echo [38;2;198;120;221m[38;2;126;199;162m Image: %filename%[0m
        echo [38;2;84;88;98m────────────────────────────────────────[0m
        for %%F in ("%file%") do (
            echo [38;2;171;178;191mSize: %%~zF bytes[0m
            echo [38;2;171;178;191mType: %ext% image[0m
        )
        exit /b
    )
)

:: Handle video files
for %%v in (.mp4 .mkv .avi .mov .wmv .flv .webm .m4v .mpg .mpeg) do (
    if /i "%ext%"=="%%v" (
        echo [38;2;198;120;221m[38;2;126;199;162m Video: %filename%[0m
        echo [38;2;84;88;98m────────────────────────────────────────[0m
        for %%F in ("%file%") do (
            echo [38;2;171;178;191mSize: %%~zF bytes[0m
            echo [38;2;171;178;191mType: %ext% video[0m
        )
        exit /b
    )
)

:: Handle audio files
for %%a in (.mp3 .flac .wav .ogg .m4a .aac .wma .opus) do (
    if /i "%ext%"=="%%a" (
        echo [38;2;86;182;194m[38;2;126;199;162m Audio: %filename%[0m
        echo [38;2;84;88;98m────────────────────────────────────────[0m
        for %%F in ("%file%") do (
            echo [38;2;171;178;191mSize: %%~zF bytes[0m
            echo [38;2;171;178;191mType: %ext% audio[0m
        )
        exit /b
    )
)

:: Handle PDF files
if /i "%ext%"==".pdf" (
    echo [38;2;224;108;117m[38;2;126;199;162m PDF: %filename%[0m
    echo [38;2;84;88;98m────────────────────────────────────────[0m
    for %%F in ("%file%") do (
        echo [38;2;171;178;191mSize: %%~zF bytes[0m
    )
    exit /b
)

:: Handle binary/executable files
for %%b in (.exe .dll .msi .sys .com) do (
    if /i "%ext%"=="%%b" (
        echo [38;2;126;199;162m[38;2;126;199;162m Binary: %filename%[0m
        echo [38;2;84;88;98m────────────────────────────────────────[0m
        for %%F in ("%file%") do (
            echo [38;2;171;178;191mSize: %%~zF bytes[0m
            echo [38;2;171;178;191mType: %ext% executable[0m
        )
        exit /b
    )
)

:: For text/code files - use bat with syntax highlighting
where bat >nul 2>&1
if %errorlevel% equ 0 (
    bat --color=always --style=numbers --theme="OneHalfDark" --paging=never --line-range=:200 "%file%" 2>nul
    if %errorlevel% equ 0 exit /b
)

:: Fallback to type for text files
type "%file%" 2>nul
