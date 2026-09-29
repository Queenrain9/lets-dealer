# LET'S DEALER

Godot 4.7.2 기반의 모바일 딜러 게임 프로토타입입니다.

현재 메인 실행본은 `scenes/main.tscn`이며, `docs/wireframes/lets_dealer_interaction_wireframes_v1_2`는 **개발 참고자료로만 사용**합니다. 와이어프레임 PNG 자체를 런타임 화면에 표시하지 않습니다.

## 현재 구현

- Home → Career → Shift 진입
- Deal: 덱에서 카드를 잡아 순서대로 올바른 좌석에 배분
- Collect: 개별 칩 클릭이 아니라 여러 BetChipGroup을 한 번에 훑어 POT으로 보내는 sweep gesture
- Flop: Burn Flick → 3-card packet → Fan Area
- Turn / River: Burn Flick → single-card open
- Payout: POT을 승자 좌석으로 직접 이동
- Side Pot: eligible seat만 유효
- 잘못된 조작은 중앙 모달 없이 local feedback + spring-back + 상태 유지
- 마우스와 모바일 터치 입력 지원

## 바로 실행

1. Godot 4.7.2 일반판에서 이 저장소의 `project.godot`를 엽니다.
2. F5를 누릅니다.
3. 메인 씬은 `scenes/main.tscn` 하나입니다.

## 와이어프레임 사용 원칙

`docs/wireframes/lets_dealer_interaction_wireframes_v1_2/`의 PNG는 레이아웃·상태·인터랙션 기준입니다.

- 런타임 TextureRect 배경으로 사용하지 않음
- 화면 전체를 이미지로 교체하지 않음
- Godot Control / Panel / Label / 실제 입력 상태로 재구현
- 이후 비주얼 에셋을 교체해도 게임 로직과 터치 영역이 유지되는 구조를 목표로 함

## 저장소 구조

- `scenes/main.tscn`: 현재 메인 실행 씬
- `scripts/gameplay/main_game.gd`: 현재 Interaction Wireframe v1.2 기반 런타임
- `docs/wireframes/lets_dealer_interaction_wireframes_v1_2/`: Interaction Wireframe Pack
- `scenes/table.tscn`, `scenes/dealer_vertical_slice.tscn`: 과거 프로토타입 참고/테스트용
- `tests/`: 기존 규칙 및 입력 회귀 검사

## 자동 검사

GitHub Actions의 `Godot project check`가 다음을 확인합니다.

- Godot 프로젝트 import / parse
- 기존 card-dealing 규칙
- mouse / touch input
- 현재 main scene 실행

현재 clean runtime 메인 씬은 위 검사를 통과한 상태입니다.
