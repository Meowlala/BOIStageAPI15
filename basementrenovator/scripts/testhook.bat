@echo off
setlocal enabledelayedexpansion

for %%I in ("%~dp0.") do set "current=%%~fI"

:FindBasementRenovator
if exist "!current!\basementrenovator" (
    set "basementrenovator=!current!\basementrenovator"
) else (
    set "parent="
    for %%J in ("!current!\..") do set "parent=%%~fJ"
    if defined parent (
        set "current=!parent!"
        goto :FindBasementRenovator
    ) else (
        echo Error: This script must be placed in the StageAPI 'basementrenovator' folder or a subfolder.
        exit /b 1
    )
)

echo "Basement renovator folder: %basementrenovator%"


set "out=%basementrenovator%\roomTest.xml"
set "xmlToLua=%basementrenovator%\Executables\XMLToLua.exe"

xcopy /i /y %1 "%out%*"
"%xmlToLua%" "%out%"

endlocal