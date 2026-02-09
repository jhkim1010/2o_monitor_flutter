# 설치 파일 생성 가이드

## 방법 1: Inno Setup 사용 (권장)

### 1. Inno Setup 설치
1. [Inno Setup 다운로드 페이지](https://jrsoftware.org/isdl.php)에서 최신 버전 다운로드
2. 설치 프로그램 실행 및 설치

### 2. 설치 파일 생성

#### 자동 생성 (배치 파일 사용)
```powershell
.\create_installer.bat
```

#### 수동 생성
1. Inno Setup Compiler 실행
2. `installer.iss` 파일 열기
3. Build > Compile 메뉴 선택 (또는 F9)

### 3. 생성된 설치 파일
- 위치: `installer\FlutterMonitor_Setup.exe`
- 이 파일을 배포하면 됩니다.

## 방법 2: 수동 배포

설치 파일 없이 직접 배포하려면:

1. `build\windows\x64\runner\Release` 폴더 전체를 복사
2. 사용자에게 이 폴더를 원하는 위치에 복사하도록 안내
3. `flutter_monitor.exe` 실행

## 설치 파일 특징

- **자동 설치**: 사용자가 쉽게 설치할 수 있음
- **바로가기 생성**: 시작 메뉴와 바탕화면에 바로가기 자동 생성
- **제거 프로그램**: Windows 제어판에서 제거 가능
- **관리자 권한**: 설치 시 관리자 권한 요구

## 빌드 전 확인사항

설치 파일을 만들기 전에:
1. 릴리즈 빌드가 완료되어 있어야 함:
   ```powershell
   flutter build windows --release
   ```
2. 빌드된 파일 위치: `build\windows\x64\runner\Release\`

## 문제 해결

### Inno Setup을 찾을 수 없음
- Inno Setup이 설치되어 있는지 확인
- 설치 경로가 기본 경로가 아닌 경우 `create_installer.bat` 파일의 경로 수정

### 빌드 파일이 없음
- `flutter build windows --release` 명령어 실행
- 빌드가 성공적으로 완료되었는지 확인

