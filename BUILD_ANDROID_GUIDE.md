# Android APK 빌드 가이드

이 가이드는 Flutter Monitor 앱을 Android APK 파일로 빌드하는 방법을 설명합니다.

## 필수 요구사항

1. **Flutter SDK** (이미 설치됨)
2. **Android SDK** (Android Studio 또는 Command-line Tools)
3. **Java JDK** (17 이상 권장)

## 방법 1: Android Studio 사용 (권장)

### 1. Android Studio 설치

1. [Android Studio 다운로드](https://developer.android.com/studio) 페이지에서 다운로드
2. 설치 프로그램 실행 및 설치
3. Android Studio 실행 후 SDK Manager에서 필요한 SDK 설치

### 2. 환경 변수 설정

#### Windows 환경 변수 설정:

1. Windows 검색에서 "환경 변수" 검색
2. "시스템 환경 변수 편집" 열기
3. "환경 변수" 버튼 클릭
4. "시스템 변수" 섹션에서 "새로 만들기" 클릭
5. 다음 변수 추가:
   - **변수 이름**: `ANDROID_HOME`
   - **변수 값**: `C:\Users\{YourUsername}\AppData\Local\Android\Sdk` (기본 경로)
6. "Path" 변수 편집하여 다음 경로 추가:
   - `%ANDROID_HOME%\platform-tools`
   - `%ANDROID_HOME%\tools`
   - `%ANDROID_HOME%\tools\bin`

7. **새 PowerShell 창을 열어야** 변경사항이 적용됩니다.

### 3. APK 빌드

#### 자동 빌드 (배치 파일 사용):
```powershell
.\build_android_apk.bat
```

#### 수동 빌드:
```powershell
C:\src\flutter\bin\flutter.bat build apk --release
```

## 방법 2: Android SDK Command-line Tools만 설치

Android Studio 없이 SDK만 설치하려면:

1. [Android SDK Command-line Tools](https://developer.android.com/studio#command-tools) 다운로드
2. 원하는 위치에 압축 해제 (예: `C:\Android\sdk`)
3. 환경 변수 설정 (방법 1의 2단계 참조)
4. SDK Manager로 필요한 패키지 설치:
   ```powershell
   sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"
   ```

## 빌드된 APK 파일

빌드가 성공하면 다음 위치에 APK 파일이 생성됩니다:

```
build\app\outputs\flutter-apk\app-release.apk
```

## APK 설치 방법

### 방법 1: USB 연결
1. 안드로이드 폰을 USB로 PC에 연결
2. 파일 탐색기에서 `app-release.apk` 파일을 폰으로 복사
3. 폰에서 파일 관리자로 APK 파일 실행
4. "알 수 없는 소스" 설치 허용 (필요한 경우)

### 방법 2: ADB 사용
```powershell
adb install build\app\outputs\flutter-apk\app-release.apk
```

### 방법 3: 이메일/클라우드 전송
1. APK 파일을 이메일로 전송하거나 클라우드에 업로드
2. 폰에서 다운로드 후 설치

## APK 서명 (선택사항)

Play Store에 배포하려면 서명된 APK가 필요합니다:

1. 키스토어 생성:
   ```powershell
   keytool -genkey -v -keystore flutter-monitor-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias flutter-monitor
   ```

2. `android/key.properties` 파일 생성:
   ```properties
   storePassword=your_password
   keyPassword=your_password
   keyAlias=flutter-monitor
   storeFile=../flutter-monitor-key.jks
   ```

3. `android/app/build.gradle.kts`에서 서명 설정 추가

## 문제 해결

### "No Android SDK found" 오류
- `ANDROID_HOME` 환경 변수가 올바르게 설정되었는지 확인
- Android SDK가 실제로 설치되어 있는지 확인
- PowerShell을 완전히 종료하고 새로 열기

### "Java not found" 오류
- Java JDK 17 이상 설치 필요
- `JAVA_HOME` 환경 변수 설정

### 빌드 실패
- `flutter doctor` 명령어로 환경 확인
- 필요한 Android 라이선스 동의: `flutter doctor --android-licenses`

## 추가 정보

- Flutter Android 빌드 문서: https://docs.flutter.dev/deployment/android
- Android 개발자 가이드: https://developer.android.com/studio/build

