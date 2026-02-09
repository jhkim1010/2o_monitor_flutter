# 빠른 시작 가이드

## Flutter PATH 설정 (선택사항)

매번 전체 경로를 입력하지 않으려면 Flutter를 PATH에 추가하세요:

1. Windows 검색에서 "환경 변수" 검색
2. "시스템 환경 변수 편집" 선택
3. "환경 변수" 버튼 클릭
4. "시스템 변수"에서 "Path" 선택 후 "편집"
5. "새로 만들기" 클릭하고 `C:\src\flutter\bin` 추가
6. 모든 창을 "확인"으로 닫기
7. **새 PowerShell 창 열기** (변경사항 적용)

이제 `flutter` 명령어를 직접 사용할 수 있습니다.

## 프로젝트 실행

### 방법 1: 전체 경로 사용 (PATH 설정 전)
```powershell
C:\src\flutter\bin\flutter.bat run -d windows
```

### 방법 2: PATH 설정 후
```powershell
flutter run -d windows
```

## 앱 사용 방법

1. 앱 실행 후 로그인 화면에서:
   - PostgreSQL IP 주소 입력 (예: `192.168.1.100`)
   - 터미널 번호 입력 (예: `1`)
   - "연결" 버튼 클릭

2. 연결 정보는 자동으로 저장되며, 다음 실행 시 수정 가능합니다.

3. 모니터링 화면:
   - 왼쪽: 전체 readings 목록
   - 오른쪽 상단: 최신 읽기 항목 (큰 글씨)
   - 오른쪽 하단: Importe Final (총합계)

4. 데이터는 0.1초마다 자동으로 업데이트됩니다.

