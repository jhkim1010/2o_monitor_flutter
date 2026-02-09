# 윈도우 설치 파일 생성 가이드

## 빠른 시작

### 1단계: 릴리즈 빌드 생성
```powershell
C:\src\flutter\bin\flutter.bat build windows --release
```

### 2단계: 설치 파일 생성

#### 옵션 A: 자동 생성 (배치 파일)
```powershell
.\create_installer.bat
```

#### 옵션 B: 수동 생성 (Inno Setup Compiler)
1. Inno Setup Compiler 실행
2. `installer.iss` 파일 열기
3. Build > Compile (F9)

## Inno Setup 설치

설치 파일을 만들려면 Inno Setup이 필요합니다:

1. [Inno Setup 다운로드](https://jrsoftware.org/isdl.php)
2. 설치 (기본 경로: `C:\Program Files (x86)\Inno Setup 6\`)
3. 설치 완료 후 `create_installer.bat` 실행

## 생성된 파일

- **설치 파일**: `installer\FlutterMonitor_Setup.exe`
- 이 파일을 배포하면 사용자가 쉽게 설치할 수 있습니다.

## 설치 파일 특징

- ✅ 자동 설치 마법사
- ✅ 시작 메뉴 바로가기
- ✅ 바탕화면 바로가기 (선택)
- ✅ Windows 제어판에서 제거 가능
- ✅ 관리자 권한으로 설치

## 수동 배포 (설치 파일 없이)

설치 파일 없이 배포하려면:

1. `build\windows\x64\runner\Release` 폴더 전체를 ZIP으로 압축
2. 사용자에게 압축 해제 후 `flutter_monitor.exe` 실행 안내

## 문제 해결

### 빌드 오류
```powershell
# Flutter 의존성 확인
C:\src\flutter\bin\flutter.bat doctor

# 클린 빌드
C:\src\flutter\bin\flutter.bat clean
C:\src\flutter\bin\flutter.bat build windows --release
```

### Inno Setup 오류
- Inno Setup이 설치되어 있는지 확인
- `create_installer.bat`에서 경로 확인
- 수동으로 Inno Setup Compiler에서 `installer.iss` 열기

