@echo off
REM Android APK 빌드 스크립트

echo ========================================
echo Android APK 빌드
echo ========================================
echo.

REM Flutter 경로 확인
set FLUTTER_PATH=C:\src\flutter\bin\flutter.bat
if not exist "%FLUTTER_PATH%" (
    echo [오류] Flutter를 찾을 수 없습니다.
    echo Flutter 경로를 확인해주세요.
    pause
    exit /b 1
)

echo Flutter 발견: %FLUTTER_PATH%
echo.

REM Android SDK 확인
if "%ANDROID_HOME%"=="" (
    echo [경고] ANDROID_HOME 환경 변수가 설정되어 있지 않습니다.
    echo.
    echo Android SDK를 설치하려면:
    echo 1. Android Studio를 설치하거나
    echo 2. Android SDK Command-line Tools를 설치하세요
    echo.
    echo 자세한 내용은 BUILD_ANDROID_GUIDE.md를 참조하세요.
    echo.
    echo 계속하시겠습니까? (Y/N)
    set /p continue=
    if /i not "%continue%"=="Y" (
        exit /b 1
    )
)

echo.
echo APK 빌드 중...
"%FLUTTER_PATH%" build apk --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo APK 빌드 완료!
    echo ========================================
    echo.
    echo APK 파일 위치: build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo 이 파일을 안드로이드 폰에 전송하여 설치할 수 있습니다.
    echo.
) else (
    echo.
    echo [오류] APK 빌드 실패
    echo.
    echo 가능한 원인:
    echo - Android SDK가 설치되지 않음
    echo - ANDROID_HOME 환경 변수가 설정되지 않음
    echo - Java JDK가 설치되지 않음
    echo.
)

pause

