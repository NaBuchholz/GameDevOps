@echo off

echo ===============================
echo   Godot Setup
echo ===============================
echo.

:: Check if Git is installed
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Git is not installed or not in PATH.
    echo Please install Git from https://git-scm.com/download/win
    echo Make sure to include Git LFS during installation.
    pause
    exit /b 1
)
echo [OK] Git found.

:: Check if Git LFS is installed
where git-lfs >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Git LFS is not installed.
    echo Please install Git LFS from https://git-lfs.com
    pause
    exit /b 1
)
echo [OK] Git LFS found.

:: Initialize Git LFS for current user
echo.
echo Initializing Git LFS...
git lfs install
if %errorlevel% neq 0 (
    echo ERROR: Failed to initialize Git LFS.
    pause
    exit /b 1
)
echo [OK] Git LFS initialized.

:: Configure hooks path
echo.
echo Configuring hooks path...
git config core.hooksPath .githooks
if %errorlevel% neq 0 (
    echo ERROR: Failed to configure hooks path.
    pause
    exit /b 1
)
echo [OK] Hooks configured.

:: Pull LFS assets
echo.
echo Pulling LFS assets...
git lfs pull
if %errorlevel% neq 0 (
    echo ERROR: Failed to pull LFS assets. Check your network connection.
    pause
    exit /b 1
)
echo [OK] LFS assets updated.

echo.
echo ===============================
echo   Setup completed successfully
echo ===============================
pause