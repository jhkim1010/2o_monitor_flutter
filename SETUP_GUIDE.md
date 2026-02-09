# Flutter 설치 및 프로젝트 설정 가이드

## Flutter 설치 방법

### 1. Flutter 다운로드
1. [Flutter 공식 웹사이트](https://flutter.dev/docs/get-started/install/windows)에서 Flutter SDK를 다운로드합니다.
2. 또는 직접 다운로드: https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.x.x-stable.zip

### 2. Flutter 설치
1. 다운로드한 ZIP 파일을 원하는 위치에 압축 해제합니다 (예: `C:\src\flutter`)
2. **중요**: `C:\Program Files\` 같은 권한이 필요한 폴더에는 설치하지 마세요.

### 3. PATH 환경 변수 설정
1. Windows 검색에서 "환경 변수"를 검색합니다.
2. "시스템 환경 변수 편집"을 엽니다.
3. "환경 변수" 버튼을 클릭합니다.
4. "시스템 변수" 섹션에서 "Path"를 선택하고 "편집"을 클릭합니다.
5. "새로 만들기"를 클릭하고 Flutter의 `bin` 폴더 경로를 추가합니다 (예: `C:\src\flutter\bin`)
6. 모든 창을 "확인"으로 닫습니다.
7. **새 PowerShell 창을 열어야** 변경사항이 적용됩니다.

### 4. Flutter 설치 확인
새 PowerShell 창에서 다음 명령어를 실행합니다:
```powershell
flutter doctor
```

## 프로젝트 설정

Flutter가 설치되고 PATH에 추가된 후:

### 1. 프로젝트 구조 생성
현재 디렉토리에서 다음 명령어를 실행합니다:
```powershell
flutter create --platforms=windows,android,ios .
```

이 명령어는 기존 파일들을 덮어쓰지 않고 필요한 플랫폼별 파일들만 추가합니다.

### 2. 의존성 설치
```powershell
flutter pub get
```

### 3. 앱 실행
```powershell
# Windows에서 실행
flutter run -d windows

# 또는 Android 에뮬레이터/디바이스에서 실행
flutter run -d android
```

## 문제 해결

### Flutter 명령어를 찾을 수 없는 경우
- PowerShell을 완전히 종료하고 새로 열어보세요.
- 환경 변수 PATH에 Flutter bin 폴더가 올바르게 추가되었는지 확인하세요.
- `flutter doctor` 명령어로 설치 상태를 확인하세요.

### 프로젝트 생성 시 오류가 발생하는 경우
- 현재 디렉토리에 이미 `pubspec.yaml`이 있으므로, Flutter는 기존 파일을 유지합니다.
- `--platforms` 옵션으로 필요한 플랫폼만 추가할 수 있습니다.

## 대안: Flutter 없이 프로젝트 구조 확인

만약 Flutter 설치가 어렵다면, 이미 생성된 파일들(`lib/` 폴더의 Dart 파일들)은 올바르게 작성되어 있습니다. 
Flutter를 설치한 후 위의 명령어들을 실행하면 바로 사용할 수 있습니다.

