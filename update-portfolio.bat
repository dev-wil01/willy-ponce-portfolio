@echo off
setlocal EnableExtensions
title Update Willy Ponce Portfolio

REM ===== Portfolio settings =====
set "REPO_URL=https://github.com/dev-wil01/willy-ponce-portfolio.git"
set "BRANCH=main"
REM ==============================

cd /d "%~dp0"

echo.
echo ============================================
echo       WILLY PONCE PORTFOLIO UPDATER
echo ============================================
echo.
echo Folder: %CD%
echo.

where git >nul 2>&1
if errorlevel 1 (
    echo ERROR: Git was not found.
    echo Install Git for Windows from https://git-scm.com/download/win
    echo Then close and reopen this script.
    pause
    exit /b 1
)

if not exist ".git" (
    echo This folder is not yet a Git repository.
    echo.
    echo SAFEST FIRST-TIME SETUP:
    echo 1. Rename this folder temporarily, for example D:\MyPortfolio-files
    echo 2. Open Command Prompt and run:
    echo    git clone %REPO_URL% D:\MyPortfolio
    echo 3. Copy your website files into D:\MyPortfolio, replacing the old files.
    echo 4. Run this script again from D:\MyPortfolio.
    echo.
    echo This script will not initialize a new repository automatically,
    echo to avoid accidentally overwriting or disconnecting your existing GitHub repo.
    pause
    exit /b 1
)

for /f "delims=" %%R in ('git remote get-url origin 2^>nul') do set "CURRENT_REMOTE=%%R"
if not defined CURRENT_REMOTE (
    echo ERROR: No Git remote named origin is configured.
    echo Configure origin to: %REPO_URL%
    pause
    exit /b 1
)

echo Remote repository: %CURRENT_REMOTE%
echo.

git status --short
echo.
set /p "CONFIRM=Stage and publish changes in this folder to GitHub? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo Cancelled. No changes were published.
    pause
    exit /b 0
)

git add -A
if errorlevel 1 (
    echo ERROR: Could not stage files.
    pause
    exit /b 1
)

git diff --cached --quiet
if not errorlevel 1 (
    echo.
    echo No new changes to commit. Checking whether the branch is up to date...
    git pull --rebase origin %BRANCH%
    if errorlevel 1 (
        echo ERROR: Git could not synchronize with GitHub.
        echo Resolve the Git issue before running this script again.
        pause
        exit /b 1
    )
    echo.
    echo No new changes to publish.
    pause
    exit /b 0
)

echo.
set /p "COMMIT_MSG=Enter a commit message (press Enter for 'Update portfolio website'): "
if not defined COMMIT_MSG set "COMMIT_MSG=Update portfolio website"

git commit -m "%COMMIT_MSG%"
if errorlevel 1 (
    echo ERROR: Commit failed. Check Git's message above.
    pause
    exit /b 1
)

echo.
echo Synchronizing with GitHub before publishing...
git pull --rebase origin %BRANCH%
if errorlevel 1 (
    echo.
    echo ERROR: Could not rebase onto GitHub.
    echo Your commit is still local; it has not been pushed.
    echo Resolve the conflict, then run this script again.
    pause
    exit /b 1
)

echo.
echo Publishing to GitHub...
git push origin %BRANCH%
if errorlevel 1 (
    echo.
    echo ERROR: Push failed. Check your GitHub authentication or Git error.
    pause
    exit /b 1
)

echo.
echo SUCCESS: Your changes were pushed to GitHub.
echo GitHub Pages may take a few minutes to publish the update.
echo Website: https://dev-wil01.github.io/willy-ponce-portfolio/
echo.
pause
endlocal
