extends RefCounted
class_name RookieShiftScenario


static func build() -> Array[DealerTask]:
	var tasks: Array[DealerTask] = []

	tasks.append(DealerTask.new({
		"id": "deal",
		"phase": "PREFLOP",
		"headline": "새 핸드가 시작됩니다.",
		"prompt": "셔플과 컷이 끝났습니다. 딜러가 가장 먼저 해야 할 일은?",
		"choices": ["카드 배분", "팟 정리", "쇼다운"],
		"correct_index": 0,
		"time_limit": 9.0,
		"base_tip": 120,
		"action_kind": "deal",
		"success_text": "GOOD DEAL",
		"state": {
			"board_count": 0,
			"main_pot": 0,
			"side_pot": 0,
			"request": "",
			"seat_states": ["WAIT", "WAIT", "WAIT", "WAIT", "WAIT", "WAIT"],
			"bets": [0, 0, 0, 0, 0, 0],
		},
	}))

	tasks.append(DealerTask.new({
		"id": "preflop_collect",
		"phase": "PREFLOP",
		"headline": "프리플랍 액션 종료",
		"prompt": "베팅이 끝났습니다. 테이블을 정리하려면 다음 업무는?",
		"choices": ["베팅 회수", "플랍 오픈", "승자 지급"],
		"correct_index": 0,
		"time_limit": 8.0,
		"base_tip": 140,
		"action_kind": "collect",
		"success_text": "POT 정리",
		"state": {
			"board_count": 0,
			"main_pot": 0,
			"side_pot": 0,
			"request": "",
			"seat_states": ["CALL 400", "CALL 400", "CALL 400", "FOLD", "CALL 400", "CALL 400"],
			"bets": [400, 400, 400, 0, 400, 400],
		},
	}))

	tasks.append(DealerTask.new({
		"id": "sidepot_detect",
		"phase": "PREFLOP",
		"headline": "올인 발생 · 금액이 다릅니다.",
		"prompt": "소연은 1,800 ALL IN, 토니와 찰리는 4,300까지 콜했습니다. 먼저 확인할 것은?",
		"choices": ["사이드팟 분리", "바로 플랍 오픈", "소연에게 전부 지급"],
		"correct_index": 0,
		"time_limit": 9.0,
		"base_tip": 180,
		"action_kind": "sidepot",
		"success_text": "SIDE POT READY",
		"state": {
			"board_count": 0,
			"main_pot": 7400,
			"side_pot": 5000,
			"request": "",
			"seat_states": ["FOLD", "FOLD", "ALL IN 1,800", "CALL 4,300", "FOLD", "CALL 4,300"],
			"bets": [0, 0, 0, 0, 0, 0],
			"highlight_seats": [2, 3, 5],
		},
	}))

	tasks.append(DealerTask.new({
		"id": "flop",
		"phase": "FLOP",
		"headline": "팟 정리 완료",
		"prompt": "다음 스트리트를 진행할 차례입니다.",
		"choices": ["번 + 플랍 오픈", "턴 오픈", "쇼다운"],
		"correct_index": 0,
		"time_limit": 8.0,
		"base_tip": 130,
		"action_kind": "flop",
		"success_text": "FLOP OPEN",
		"state": {
			"board_count": 0,
			"main_pot": 7400,
			"side_pot": 5000,
			"request": "",
			"seat_states": ["FOLD", "FOLD", "ALL IN", "ACTIVE", "FOLD", "ACTIVE"],
			"bets": [0, 0, 0, 0, 0, 0],
		},
	}))

	tasks.append(DealerTask.new({
		"id": "flop_collect",
		"phase": "FLOP",
		"headline": "플랍 베팅 종료",
		"prompt": "토니 1,200, 찰리 1,200. 다음 딜러 업무는?",
		"choices": ["베팅 회수", "리버 오픈", "칩 교환"],
		"correct_index": 0,
		"time_limit": 7.0,
		"base_tip": 140,
		"action_kind": "collect",
		"success_text": "BET COLLECTED",
		"state": {
			"board_count": 3,
			"main_pot": 7400,
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
		"prompt": "“5,000 칩을 잔칩으로 바꿔주세요.” 다음 스트리트 전에 처리할 업무는?",
		"choices": ["칩 교환", "턴부터 오픈", "쇼다운 선언"],
		"correct_index": 0,
		"time_limit": 7.0,
		"base_tip": 170,
		"action_kind": "chip_change",
		"success_text": "CHIP CHANGE",
		"state": {
			"board_count": 3,
			"main_pot": 7400,
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
		"headline": "요청 처리 완료",
		"prompt": "테이블이 준비됐습니다. 다음 스트리트를 진행하세요.",
		"choices": ["번 + 턴 오픈", "베팅 회수", "메인팟 지급"],
		"correct_index": 0,
		"time_limit": 7.0,
		"base_tip": 130,
		"action_kind": "turn",
		"success_text": "TURN OPEN",
		"state": {
			"board_count": 3,
			"main_pot": 7400,
			"side_pot": 7400,
			"request": "",
			"seat_states": ["FOLD", "FOLD", "ALL IN", "ACTIVE", "FOLD", "ACTIVE"],
			"bets": [0, 0, 0, 0, 0, 0],
		},
	}))

	tasks.append(DealerTask.new({
		"id": "turn_collect",
		"phase": "TURN",
		"headline": "턴 베팅 종료",
		"prompt": "토니가 2,000을 베팅했고 찰리가 콜했습니다.",
		"choices": ["베팅 회수", "리버 오픈", "사이드팟 지급"],
		"correct_index": 0,
		"time_limit": 7.0,
		"base_tip": 150,
		"action_kind": "collect",
		"success_text": "BET COLLECTED",
		"state": {
			"board_count": 4,
			"main_pot": 7400,
			"side_pot": 7400,
			"request": "",
			"seat_states": ["FOLD", "FOLD", "ALL IN", "BET 2,000", "FOLD", "CALL 2,000"],
			"bets": [0, 0, 0, 2000, 0, 2000],
		},
	}))

	tasks.append(DealerTask.new({
		"id": "river",
		"phase": "RIVER",
		"headline": "턴 팟 정리 완료",
		"prompt": "마지막 커뮤니티 카드를 진행할 차례입니다.",
		"choices": ["번 + 리버 오픈", "쇼다운", "카드 재배분"],
		"correct_index": 0,
		"time_limit": 7.0,
		"base_tip": 130,
		"action_kind": "river",
		"success_text": "RIVER OPEN",
		"state": {
			"board_count": 4,
			"main_pot": 7400,
			"side_pot": 11400,
			"request": "",
			"seat_states": ["FOLD", "FOLD", "ALL IN", "ACTIVE", "FOLD", "ACTIVE"],
			"bets": [0, 0, 0, 0, 0, 0],
		},
	}))

	tasks.append(DealerTask.new({
		"id": "river_collect",
		"phase": "RIVER",
		"headline": "리버 액션 종료",
		"prompt": "찰리가 1,500을 베팅했고 토니가 콜했습니다.",
		"choices": ["베팅 회수", "소연에게 전액 지급", "새 핸드 시작"],
		"correct_index": 0,
		"time_limit": 7.0,
		"base_tip": 150,
		"action_kind": "collect",
		"success_text": "FINAL BET COLLECTED",
		"state": {
			"board_count": 5,
			"main_pot": 7400,
			"side_pot": 11400,
			"request": "",
			"seat_states": ["FOLD", "FOLD", "ALL IN", "CALL 1,500", "FOLD", "BET 1,500"],
			"bets": [0, 0, 0, 1500, 0, 1500],
		},
	}))

	tasks.append(DealerTask.new({
		"id": "main_payout",
		"phase": "SHOWDOWN",
		"headline": "SHOWDOWN · 메인팟",
		"prompt": "소연 A♠ K♠ · 토니 Q♦ Q♣ · 찰리 J♣ 10♣. 메인팟 7,400의 승자는?",
		"choices": ["소연", "토니", "찰리"],
		"correct_index": 0,
		"time_limit": 10.0,
		"base_tip": 220,
		"action_kind": "main_payout",
		"success_text": "MAIN POT → 소연",
		"state": {
			"board_count": 5,
			"main_pot": 7400,
			"side_pot": 14400,
			"request": "메인팟과 사이드팟의 eligible player가 다릅니다.",
			"seat_states": ["FOLD", "FOLD", "A♠ K♠", "Q♦ Q♣", "FOLD", "J♣ 10♣"],
			"bets": [0, 0, 0, 0, 0, 0],
			"highlight_seats": [2, 3, 5],
		},
	}))

	tasks.append(DealerTask.new({
		"id": "side_payout",
		"phase": "SHOWDOWN",
		"headline": "SHOWDOWN · 사이드팟",
		"prompt": "소연은 ALL IN이라 사이드팟 대상이 아닙니다. 14,400은 누구에게 지급?",
		"choices": ["소연", "토니", "찰리"],
		"correct_index": 2,
		"time_limit": 9.0,
		"base_tip": 260,
		"action_kind": "side_payout",
		"success_text": "SIDE POT → 찰리",
		"state": {
			"board_count": 5,
			"main_pot": 0,
			"side_pot": 14400,
			"request": "SIDE POT eligible: 토니 / 찰리",
			"seat_states": ["FOLD", "FOLD", "MAIN WIN", "SIDE LOSE", "FOLD", "SIDE WIN"],
			"bets": [0, 0, 0, 0, 0, 0],
			"highlight_seats": [3, 5],
		},
	}))

	return tasks
