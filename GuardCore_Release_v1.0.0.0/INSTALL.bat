@echo off
echo ================================================================================
echo    GuardCore Back-Office Engine v1.0.0.0 - Installation Wizard
echo    Build Date: February 14, 2026
echo ================================================================================
echo.

echo [1/3] Verifying installation files...
timeout /t 2 /nobreak >nul

if not exist "security_guard_app.exe" (
    echo [ERROR] security_guard_app.exe not found!
    echo Please ensure all files are in the same directory.
    pause
    exit /b 1
)

if not exist "flutter_windows.dll" (
    echo [ERROR] flutter_windows.dll not found!
    echo Please ensure all files are in the same directory.
    pause
    exit /b 1
)

if not exist "data" (
    echo [ERROR] data folder not found!
    echo Please ensure all files are in the same directory.
    pause
    exit /b 1
)

echo [OK] All essential files found!
echo.

echo [2/3] Creating desktop shortcut...
timeout /t 1 /nobreak >nul

set SCRIPT="%TEMP%\CreateShortcut.vbs"
echo Set oWS = WScript.CreateObject("WScript.Shell") > %SCRIPT%
echo sLinkFile = "%USERPROFILE%\Desktop\GuardCore.lnk" >> %SCRIPT%
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %SCRIPT%
echo oLink.TargetPath = "%CD%\security_guard_app.exe" >> %SCRIPT%
echo oLink.WorkingDirectory = "%CD%" >> %SCRIPT%
echo oLink.Description = "GuardCore Back-Office Engine v1.0.0.0" >> %SCRIPT%
echo oLink.Save >> %SCRIPT%

cscript /nologo %SCRIPT%
del %SCRIPT%

if exist "%USERPROFILE%\Desktop\GuardCore.lnk" (
    echo [OK] Desktop shortcut created successfully!
) else (
    echo [WARNING] Could not create desktop shortcut (manual launch required)
)
echo.

echo [3/3] Installation complete!
echo.
echo ================================================================================
echo   GuardCore is now ready to use!
echo ================================================================================
echo.
echo Quick Start Guide:
echo   1. Double-click "GuardCore" icon on desktop OR run security_guard_app.exe
echo   2. Login with default credentials:
echo      Email: admin@example.com
echo      Password: admin123
echo   3. Navigate to Reports Center to print attendance reports
echo.
echo For detailed instructions, please read README.txt
echo.
echo Press any key to launch GuardCore now...
pause >nul

start "" "%CD%\security_guard_app.exe"

echo.
echo GuardCore is starting...
echo You can close this window now.
timeout /t 3 /nobreak >nul
exit
