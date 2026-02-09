@echo off
REM Flutter Monitor 설치 파일 생성 스크립트

echo ========================================
echo Flutter Monitor 설치 파일 생성
echo ========================================
echo.

REM Inno Setup이 설치되어 있는지 확인
set INNO_SETUP_PATH=
if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
    set INNO_SETUP_PATH=C:\Program Files (x86)\Inno Setup 6\ISCC.exe
) else if exist "C:\Program Files\Inno Setup 6\ISCC.exe" (
    set INNO_SETUP_PATH=C:\Program Files\Inno Setup 6\ISCC.exe
) else (
    echo [오류] Inno Setup을 찾을 수 없습니다.
    echo.
    echo Inno Setup을 설치해주세요:
    echo https://jrsoftware.org/isdl.php
    echo.
    echo 또는 수동으로 installer.iss 파일을 Inno Setup Compiler로 열어서 컴파일하세요.
    pause
    exit /b 1
)

echo Inno Setup 발견: %INNO_SETUP_PATH%
echo.

REM 릴리즈 빌드 확인
if not exist "build\windows\x64\runner\Release\flutter_monitor.exe" (
    echo [오류] 릴리즈 빌드를 찾을 수 없습니다.
    echo.
    echo 먼저 다음 명령어로 빌드하세요:
    echo flutter build windows --release
    pause
    exit /b 1
)

echo 릴리즈 빌드 확인 완료
echo.

REM installer 디렉토리 생성
if not exist "installer" mkdir installer

echo 설치 파일 생성 중...
"%INNO_SETUP_PATH%" installer.iss

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo 설치 파일 생성 완료!
    echo ========================================
    echo.
    echo 설치 파일 위치: installer\FlutterMonitor_Setup.exe
    echo.
) else (
    echo.
    echo [오류] 설치 파일 생성 실패
    echo.
)

pause

