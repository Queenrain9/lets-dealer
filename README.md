# LET'S DEALER / 렛츠 딜러

Godot 4.x 기반 모바일 딜러 액션 게임 프로젝트입니다.

이 저장소의 목표는 화면 목업이 아니라, 실제 iOS App Store 출시까지 확장 가능한 게임 구조를 만드는 것입니다. 현재 단계는 **Core Gameplay Prototype 0.1**이며 최종 아트보다 입력, 상태, 인터랙션, 확장 구조를 우선합니다.

## 현재 플레이 가능한 범위

실행하면 `scenes/table_test.tscn`이 열립니다.

1. **START HAND**를 누릅니다.
2. 화면 하단의 카드 한 장을 노란색으로 강조된 좌석으로 드래그합니다.
3. 4개 좌석에 2장씩, 총 8장을 올바른 순서로 배분합니다.
4. 잘못된 좌석에 놓으면 Mistake가 올라가고 Combo가 초기화됩니다.
5. 올바른 배분은 Perfect와 Combo에 기록됩니다.
6. 홀카드 배분이 끝나면 최소 상태 머신이 Betting → Flop → Turn → River → Showdown → Payout → Complete로 진행됩니다.
7. Flop / Turn / River 카드는 실제 덱 상태에서 보드로 이동합니다.
8. Complete 후 다음 핸드를 시작할 수 있습니다.

> Betting, chip collection, pot calculation, showdown ranking, winner payout은 아직 **의도적으로 placeholder**입니다. 버튼으로 상태 훅만 통과합니다.

## 구조

```text
lets-dealer/
├─ project.godot
├─ scenes/
│  └─ table_test.tscn
├─ scripts/
│  ├─ config/
│  │  └─ table_config.gd
│  ├─ core/
│  │  ├─ dealer_game_state.gd
│  │  ├─ hand_state.gd
│  │  ├─ player_seat.gd
│  │  ├─ poker_table_state.gd
│  │  ├─ pot_state.gd
│  │  └─ session_result.gd
│  ├─ gameplay/
│  │  └─ table_test.gd
│  └─ ui/
│     ├─ draggable_card.gd
│     └─ seat_view.gd
└─ data/
   └─ table_configs/
      └─ prototype_table.tres
```

## 설계 원칙

### Core state와 Visual 분리

게임 규칙과 상태는 `scripts/core`에 있습니다. 씬과 UI는 상태를 표시하고 입력을 전달하는 역할만 합니다.

예를 들어 카드 배분 규칙은 `DealerGameState.try_deal_card_to_seat()`에 있고, 드래그 표현은 `DraggableCard`에 있습니다. 따라서 나중에 최종 카드 이미지, 손 애니메이션, 테이블 아트로 교체하더라도 카드 배분 규칙 자체를 다시 만들 필요가 없습니다.

### Touch / Pointer 공통 입력

`DraggableCard`는 다음을 모두 처리합니다.

- `InputEventScreenTouch`
- `InputEventScreenDrag`
- 마우스 press / motion / release

즉 PC Godot Editor에서는 마우스로 테스트하고, iPhone/Xogot에서는 손가락 입력으로 같은 상호작용을 사용하도록 설계되어 있습니다.

프로젝트 설정에도 touch ↔ mouse emulation을 켜 두어 초기 테스트 환경 차이를 줄입니다.

### 데이터 분리

테이블 설정은 코드에 하드코딩하지 않고 `TableConfig` Resource와 `.tres` 데이터로 분리했습니다.

현재는 좌석 수, 시작 스택, 블라인드, 카드 수만 있지만 이후 다음 데이터를 같은 방향으로 추가합니다.

- 테이블 난이도
- 손님 행동 패턴
- 업무 종류
- EXP 요구량
- Tip / Combo 보상
- 스테이지 해금 조건

### Prototype과 Production 구분

현재 씬의 색상, 카드 박스, 좌석 패널은 전부 placeholder입니다.

**Production 기반으로 보는 부분**
- DealerGameState
- PokerTableState
- HandState
- PlayerSeat
- PotState
- SessionResult
- TableConfig
- Touch / Pointer drag 입력 경계
- 화면 표현과 상태 로직의 분리

**Prototype 전용인 부분**
- 단순 패널 기반 테이블/좌석/카드
- ADVANCE PHASE 버튼
- 자동 보드 오픈
- 승자 미결정 Showdown
- 실제 칩이 없는 Betting / Payout

## 다음 개발 단계

다음 milestone은 **Chip & Pot Interaction 0.2**입니다.

우선순위:

1. 베팅 칩 데이터와 시각 오브젝트 생성
2. 칩 또는 칩 스택 드래그
3. 좌석 앞 베팅 칩을 중앙 Pot으로 모으기
4. PotState와 실제 금액 동기화
5. All-in contribution 추적
6. Main Pot / Side Pot 분리
7. 보드 오픈을 수동 dealer action으로 전환
8. 실제 Hand Evaluator 연결
9. 승자 및 split pot 계산
10. 플레이어가 직접 정확한 칩을 지급하고 판정
11. 정확도 / 속도 / 실수 / Combo를 Hand 결과로 확정

그 다음에야 Dealer EXP, Reputation, Tip, Career/Progression, 손님 성격, 멀티태스킹 이벤트를 붙입니다.

## 실행

Godot 4.x에서 저장소 루트를 프로젝트로 Import한 뒤 실행합니다.

기준 viewport는 **720 × 1280 portrait**이며 `canvas_items` stretch를 사용합니다.

현재 단계에서는 최종 캐릭터 일러스트나 시안 이미지를 프로젝트 내부 아트로 사용하지 않습니다. 첨부 시안은 장기적인 제품 방향과 플레이 감각의 참고 자료입니다.
