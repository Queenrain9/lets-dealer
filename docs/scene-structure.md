# 현재 Godot 씬 구조

```text
Table (Control, table.gd)
├─ Backdrop (Control, table_backdrop.gd)
├─ SafeMargin (MarginContainer)
│  └─ Layout (VBoxContainer)
│     ├─ Header - 제목과 딜러 레벨
│     ├─ MissionPanel - 다음 손님과 배분 안내
│     ├─ Stats - 남은 시간 / 배분 수 / 정확도
│     ├─ PlayArea
│     │  ├─ Felt - 테이블 임시 그래픽
│     │  ├─ Seats (HBoxContainer)
│     │  │  ├─ Seat0 → npc_seat.tscn (지민)
│     │  │  ├─ Seat1 → npc_seat.tscn (맥스)
│     │  │  └─ Seat2 → npc_seat.tscn (소연)
│     │  ├─ TableBrand / DeckShadow
│     │  └─ DealCard → card.tscn
│     └─ Footer - 조작 안내 / 실수 수 / 일시정지 / 처음부터
└─ ResultPanel → result_panel.tscn
   └─ ResultCard - 훈련 결과와 다시 훈련하기
```

| 파일 | 책임 |
|---|---|
| `scripts/deal_round.gd` | 순서, 60초, 실수, 성공·실패, 정확도. 씬이나 그림에 의존하지 않음 |
| `scripts/card.gd` | 마우스·터치 포인터 1개를 추적하고 놓기 좌표를 신호로 전달 |
| `scripts/npc_seat.gd` | 카드 영역, 받은 카드 0~2장 표시, 다음 손님 강조, 인물 교체 지점 |
| `scripts/table.gd` | 입력을 규칙으로 전달하고 HUD, 일시정지, 재시작, 결과를 연결 |
| `scripts/table_backdrop.gd` | 임시 벽·조명·펠트 그림. 이후 이미지로 교체 가능 |

입력 흐름은 `Card.drag_started → DealRound.start`와 `Card.dropped → Table의 영역 검사 → DealRound.attempt_drop → NpcSeat/HUD 갱신`입니다.

결과 씬 내부 노드는 그 씬의 경로로 참조합니다. 다른 씬 내부의 `%고유이름`을 Table의 고유 이름처럼 사용하지 않습니다.

후속 승자 판정과 지급액 계산은 별도 규칙 스크립트로 추가하고 Table은 그 결과를 화면에 연결합니다. 현재 테스트와 카드 입력을 유지하면서 한 단계씩 확장할 수 있습니다.
