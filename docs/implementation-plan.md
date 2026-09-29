# Lucky Dealer 카드 배분 훈련 Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans to implement this plan task-by-task. The user explicitly requested finalizing the design and implementing immediately; proceed inline in the current session.

**Goal:** Godot에서 마우스와 터치로 NPC 3명에게 카드 6장을 배분하는 훈련을 실행한다.

**Architecture:** 규칙은 RefCounted 모델, 입력은 Card 씬, 좌석 표시는 NpcSeat 씬, 흐름과 HUD는 Table 씬이 맡는다. 화면 연출은 규칙 계산과 분리한다.

**Tech Stack:** Godot 4.7.2, GDScript, Compatibility, 외부 애드온 없음.

**Spec:** `docs/game-design.md`

## Global Constraints

- 2D 세로 화면, Android 우선. 기본 작업 크기 720 × 1280.
- NPC 3명, 지민 → 맥스 → 소연을 2회 반복, 총 6장.
- 첫 유효한 집기부터 60초, 실수 3회 실패. 빈 영역은 무벌점.
- 두 번째 포인터는 첫 포인터의 카드를 이동하거나 배분할 수 없다.
- 일시정지·포커스 이탈은 타이머 정지와 드래그 취소. 직접 계속하기.
- 이번 완료는 카드 배분 단계의 완료이며 한 판 전체의 완료가 아니다.
- 프로젝트는 `outputs/lucky-dealer`, 중간 도구·로그는 `work/`에 저장.

## Review Focus

- 시간 초과 직후의 놓기 입력이 배분으로 인정되지 않아야 한다.
- 입력 취소와 다른 손가락의 release가 실수·배분을 만들지 않아야 한다.
- 일시정지 중 놓기와 재시작 전 드래그의 놓기가 새 훈련에 영향을 주지 않아야 한다.
- 마지막 카드 후 추가 입력이 카드 수를 6보다 늘리지 않아야 한다.
- 화면 비율이 바뀌어도 좌석의 실제 카드 영역으로 드롭을 판정해야 한다.

## Task 1: 배분 규칙

**Files:** `scripts/deal_round.gd`, `tests/test_deal_round.gd`.

**Interfaces:** `start()`, `attempt_drop(seat_index: int) -> String`, `tick(delta: float)`, `set_paused(value: bool)`, `reset()`, `expected_seat() -> int`, `accuracy() -> int`.

- [x] 실제 모델의 배분 순서, 오배분, 빈 영역, 시간 초과, 일시정지, 완료 후 입력, 초기화 검사를 작성한다.
- [x] `godot --headless --path . --script tests/test_deal_round.gd`로 구현 부재 실패를 확인한다.
- [x] 규칙 모델을 구현한다.
- [x] 같은 검사에서 실패 0과 종료 코드 0을 확인한다.

## Task 2: 씬과 드래그 연결

**Files:** `project.godot`, `scenes/table.tscn`, `scenes/card.tscn`, `scenes/npc_seat.tscn`, `scenes/result_panel.tscn`, `scripts/table.gd`, `scripts/card.gd`, `scripts/npc_seat.gd`, `scripts/table_backdrop.gd`, `tests/test_table_input.gd`.

**Interfaces:** Card의 `drag_started`와 `dropped(global_point: Vector2)` 신호, `set_enabled(value: bool)`, `return_home()`, `cancel_drag()`. NpcSeat의 `get_drop_rect() -> Rect2`, `receive_card()`, `reset_cards()`, `set_target(value: bool)`.

- [x] 실제 씬에 마우스·터치 입력을 전달하는 검사를 작성하고 씬 부재 실패를 확인한다.
- [x] 편집 가능한 씬, 임시 벡터 그래픽, 상태 HUD, 드래그, 일시정지와 훈련 결과를 구현한다.
- [x] 모델 검사와 입력 검사를 모두 실행한다. 위 Review Focus를 입력 검사에서 확인한다.
- [x] Godot headless import와 일반 렌더러 스크린샷으로 파싱과 화면 배치를 검증한다.

## Task 3: 전달

**Files:** `README.md`, `docs/scene-structure.md`, `docs/game-design.pdf`, `docs/asset-guide.md`, `docs/verification.md`.

- [x] 1페이지 기획서 PDF를 만들고 페이지 수와 렌더링을 확인한다.
- [x] 씬 구조, 실행법, 에셋 교체 위치와 현재 기능 범위를 기록한다.
- [x] 전체 변경을 독립 검토하고 중요한 문제를 수정·재검증한다.
- [x] `.godot` 캐시를 제외한 ZIP을 만들고 캐시 없는 압축 해제본에서 전체 55개 검사와 메인 씬 시작을 확인했다.

이 작업은 기존 Git 저장소가 없는 프로젝트리스 폴더에서 새 프로젝트를 생성한다. 실행 기록은 `work/progress.md`에 남긴다.
