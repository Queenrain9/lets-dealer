extends RefCounted
class_name RookieShiftScenario


static func build() -> Array[DealerTask]:
	var tasks: Array[DealerTask] = []

	tasks.append(DealerTask.new({
		"id": "deal",
		"phase": "PREFLOP",
		"headline": "NEW HAND · 셔플과 컷 완료",
		"event_text": "6명의 플레이어가 딜을 기다리고 있습니다.",
		"time_limit": 9.0,
		"base_tip": 120,
		"expected_action": "deal",
		"success_text": "FAST DEAL",
		"state": {
			"board_count": 0,
			"main_pot": 0,
			"side_pot": 0,
			"request": "",
			"seat_states": ["READY", "READY", "READY", "READY", "READY", "READY"],
			"bets": [0, 0, 0, 0, 0, 0],
		},
	}))

	tasks.append(DealerTask.new({
		"id": "preflop_collect",
		"phase": "PREFLOP",
		"headline": "소연 ALL IN 1,800 · 토니 CALL 4,300 · 찰리 CALL 4,300",
		"event_text": "프리플랍 액션이 종료되었습니다.",
		"time_limit": 8.0,
		"base_tip": 180,
		"expected_action": "pot",
		"success_text": "MAIN + SIDE POT",
		"state": {
			"board_count": 0,
			"main_pot": 0,
			"side_pot": 0,
			"request": "",
			"seat_states": ["FOLD", "FOLD", "ALL IN 1,800", "CALL 4,300", "FOLD", "CALL 4,300"],
			"bets": [0, 0, 1800, 4300, 0, 4300],
			"highlight_seats": [2, 3, 5],
		},
	}))

	tasks.append(DealerTask.new({
		"id": "flop",
		"phase": "FLOP",
		"headline": "MAIN 5,400 · SIDE 5,000",
		"event_text": "토니와 찰리는 계속 플레이 중입니다.",
		"time_limit": 8.0,
		"base_tip": 130,
		"expected_action": "board",
		"success_text": "FLOP OPEN",
		"state": {
			"board_count": 0,
			"main_pot": 5400,
			"side_pot": 5000,
			"request": "",
			"seat_states": ["FOLD", "FOLD", "ALL IN", "ACTIVE", "FOLD", "ACTIVE"],
			"bets": [0, 0, 0, 0, 0, 0],
		},
	}))

	tasks.append(DealerTask.new({
		"id": "flop_collect",
		"phase": "FLOP",
		"headline": "토니 BET 1,200 · 찰리 CALL 1,200",
		"event_text": "플랍 액션 종료.",
		"time_limit": 7.0,
		"base_tip": 140,
		"expected_action": "pot",
		"success_text": "BET COLLECTED",
		"state": {
			"board_count": 3,
			"main_pot": 5400,
			"side_pot": 5000,
			"request": "",
			"seat_states": ["FOLD", "FOLD", "ALL IN", "BET 1,200", "FOLD", "CALL 1,200"],
			"bets": [0, 0, 0, 1200, 0, 1200],
		},
	}))

	tasks.append(DealerTask.new({
		"id": "chip_change",
		"phase": "SERVICE",
		"headline": "토니가 딜러를 부릅니다.",
		"event_text": "“5,000 칩 하나만 잔칩으로 바꿔주세요.”",
		"time_limit": 7.0,
		"base_tip": 170,
		"expected_action": "chip_change",
		"success_text": "CHIP CHANGE",
		"state": {
			"board_count": 3,
			"main_pot": 5400,
			"side_pot": 7400,
			"request": "토니 · 5,000 칩 교환 요청",
			"seat_states": ["FOLD", "FOLD", "ALL IN", "REQUEST", "FOLD", "ACTIVE"],
			"bets": [0, 0, 0, 0, 0, 0],
			"highlight_seats": [3],
		},
	}))

	tasks.append(DealerTask.new({
		"id": "turn",
		"phase": "TURN",
		"headline": "칩 교환 완료 · 테이블 진행 대기",
		"event_text": "토니와 찰리가 준비되었습니다.",
		"time_limit": 7.0,
		"base_tip": 130,
		"expected_action": "board",
		"success_text": "TURN OPEN",
		"state": {
			"board_count": 3,
			"main_pot": 5400,
			"side_pot": 7400,
			"request": "",
			"seat_states": ["FOLD", "FOLD", "ALL IN", "ACTIVE", "FOLD", "ACTIVE"],
			"bets": [0, 0, 0, 0, 0, 0],
		},
	}))

	tasks.append(DealerTask.new({
		"id": "turn_collect",
		"phase": "TURN",
		"headline": "토니 BET 2,000 · 찰리 CALL 2,000",
		"event_text": "턴 액션 종료.",
		"time_limit": 7.0,
		"base_tip": 150,
		"expected_action": "pot",
		"success_text": "BET COLLECTED",
		"state": {
			"board_count": 4,
			"main_pot": 5400,
			"side_pot": 7400,
			"request": "",
			"seat_states": ["FOLD", "FOLD", "ALL IN", "BET 2,000", "FOLD", "CALL 2,000"],
			"bets": [0, 0, 0, 2000, 0, 2000],
		},
	}))

	tasks.append(DealerTask.new({
		"id": "river",
		"phase": "RIVER",
		"headline": "MAIN 5,400 · SIDE 11,400",
		"event_text": "마지막 스트리트 진행 대기.",
		"time_limit": 7.0,
		"base_tip": 130,
		"expected_action": "board",
		"success_text": "RIVER OPEN",
		"state": {
			"board_count": 4,
			"main_pot": 5400,
			"side_pot": 11400,
			"request": "",
			"seat_states": ["FOLD", "FOLD", "ALL IN", "ACTIVE", "FOLD", "ACTIVE"],
			"bets": [0, 0, 0, 0, 0, 0],
		},
	}))

	tasks.append(DealerTask.new({
		"id": "river_collect",
		"phase": "RIVER",
		"headline": "찰리 BET 1,500 · 토니 CALL 1,500",
		"event_text": "리버 액션 종료. 세 플레이어의 핸드가 공개됩니다.",
		"time_limit": 7.0,
		"base_tip": 150,
		"expected_action": "pot",
		"success_text": "FINAL BET COLLECTED",
		"state": {
			"board_count": 5,
			"main_pot": 5400,
			"side_pot": 11400,
			"request": "",
			"seat_states": ["FOLD", "FOLD", "ALL IN", "CALL 1,500", "FOLD", "BET 1,500"],
			"bets": [0, 0, 0, 1500, 0, 1500],
		},
	}))

	tasks.append(DealerTask.new({
		"id": "main_payout",
		"phase": "SHOWDOWN",
		"headline": "MAIN POT 5,400",
		"event_text": "소연 A♠ A♥ · 토니 9♠ 9♥ · 찰리 K♣ J♣",
		"time_limit": 10.0,
		"base_tip": 220,
		"expected_action": "payout",
		"success_text": "MAIN POT → 소연",
		"target_seat": 2,
		"state": {
			"board_count": 5,
			"main_pot": 5400,
			"side_pot": 14400,
			"request": "",
			"seat_states": ["FOLD", "FOLD", "A♠ A♥", "9♠ 9♥", "FOLD", "K♣ J♣"],
			"bets": [0, 0, 0, 0, 0, 0],
			"highlight_seats": [2, 3, 5],
			"eligible_seats": [2, 3, 5],
		},
	}))

	tasks.append(DealerTask.new({
		"id": "side_payout",
		"phase": "SHOWDOWN",
		"headline": "SIDE POT 14,400",
		"event_text": "소연은 ALL IN 금액을 초과한 사이드팟에는 참여하지 않습니다.",
		"time_limit": 9.0,
		"base_tip": 260,
		"expected_action": "payout",
		"success_text": "SIDE POT → 찰리",
		"target_seat": 5,
		"state": {
			"board_count": 5,
			"main_pot": 0,
			"side_pot": 14400,
			"request": "",
			"seat_states": ["FOLD", "FOLD", "MAIN WIN", "9♠ 9♥", "FOLD", "K♣ J♣"],
			"bets": [0, 0, 0, 0, 0, 0],
			"highlight_seats": [3, 5],
			"eligible_seats": [3, 5],
		},
	}))

	return tasks
