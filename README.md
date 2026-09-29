# LET'S DEALER — Interaction Wireframe v1.2

현재 메인 실행본은 `docs/wireframes/lets_dealer_interaction_wireframes_v1_2`를 그대로 화면 소스로 사용하는 인터랙션 프로토타입입니다. 화면을 다시 그리지 않고 와이어프레임 PNG를 직접 표시하며, 그 위에 Deal / Sweep Collect / Board / Payout / Side Pot / Career / VIP / Final 상태 전환과 마우스·터치 제스처를 연결합니다.

## 바로 실행

1. Godot **4.7.2 안정 버전, 일반판**을 실행합니다. .NET판과 추가 애드온은 필요하지 않습니다.
2. 프로젝트 관리자에서 **가져오기**를 누르고 이 폴더의 `project.godot`를 선택합니다.
3. 편집기가 열리면 **F5**로 실행합니다. 메인 씬은 `scenes/interaction_wireframe_v1_2.tscn`입니다.
4. 아래쪽 카드 한 장을 잡아 **금색 표시가 있는 손님의 카드 영역**에 놓습니다.
5. 지민 → 맥스 → 소연 순서로 두 바퀴, 총 6장을 배분합니다.

카드 영역은 인물 아래의 두 칸이 있는 박스입니다. 인물 자체를 놓기 대상으로 사용하지 않습니다.

## 확정된 훈련 규칙

- 첫 카드 집기부터 60초가 시작됩니다.
- 다른 손님에게 놓으면 실수 1회이며 카드가 돌아옵니다. 실수 3회 또는 시간 초과면 실패합니다.
- 빈 영역에 놓거나 터치가 취소되면 실수 없이 돌아옵니다.
- 일시정지와 앱 포커스 이탈은 시간을 멈추고 잡은 카드를 돌려놓습니다. **계속하기**로 재개합니다.
- **처음부터**와 결과 화면의 **다시 훈련하기**는 시간·카드·실수를 초기화합니다.
- PC는 왼쪽 마우스, 모바일 입력은 한 손가락으로 조작합니다. 두 번째 손가락은 진행 중인 카드를 조작하지 않습니다.

## 들어 있는 것

- `docs/game-design.md`, `docs/game-design.pdf`: 한 판 전체의 1페이지 기획서.
- `docs/scene-structure.md`: 현재 씬·스크립트 구조.
- `docs/asset-guide.md`: AI 이미지 제작과 에셋 교체 위치.
- `docs/implementation-plan.md`: 이번 구현 순서와 검증 기준.
- `docs/verification.md`: 실행한 검사와 현재 검증 범위.
- `scenes/`: 편집 가능한 Table, Card, NpcSeat, ResultPanel 씬.
- `scripts/`: 입력, 규칙, 좌석 표시, 테이블 화면.
- `tests/`: 규칙 및 실제 씬의 마우스·터치 입력 검사.

현재 메인 화면 그래픽은 v1.2 인터랙션 와이어프레임 PNG를 그대로 사용합니다. 기존 코드 기반 Table 씬과 세로 슬라이스는 저장소에 남아 있어 이후 실제 UI 컴포넌트로 교체할 때 참고할 수 있습니다.

## 자동 검사

PowerShell에서 실행합니다. `GodotPath`에는 압축을 푼 실제 Godot 실행 파일 경로를 넣습니다.

```powershell
./tools/run-tests.ps1 -GodotPath 'C:/경로/Godot_v4.7.2-stable_win64_console.exe'
```

각 검사의 종료 코드 0과 `0 failures`가 통과 기준입니다. 외부 테스트 프레임워크는 필요하지 않습니다.

GitHub의 `main`에 푸시하거나 PR을 만들면 `.github/workflows/godot-check.yml`이 프로젝트 가져오기, 카드 배분 규칙 검사, 마우스·터치 입력 검사, 메인 씬 실행을 수행합니다.

## 다음 개발 작업

이 프로젝트는 **카드 배분 훈련까지 구현**되어 있습니다. 공용 카드 공개, 족보와 승자 판정, 칩 지급, 팁·경험치, 저장은 다음 기능입니다. 한 판 전체가 이미 완성된 것으로 표시하지 않습니다.

Android APK/AAB와 iOS 빌드는 이번 작업에 포함하지 않습니다. 이후 Android SDK/JDK와 내보내기 템플릿을 설정하고 실제 기기에서 화면, 터치, 백그라운드 전환, 한국어 폰트를 확인해야 합니다.

Godot는 MIT 라이선스입니다. 배포판에는 Godot 및 사용하는 리소스의 필요한 라이선스 고지를 포함하세요: https://godotengine.org/license/
