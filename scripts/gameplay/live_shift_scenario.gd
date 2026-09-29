extends RefCounted
class_name LiveShiftScenario


static func build() -> Array[Dictionary]:
	var hands: Array[Dictionary] = []

	hands.append({
		"id": "hand_01",
		"label": "HAND 1 / 3",
		"board": ["J♦", "10♥", "7♠", "3♦", "2♣"],
		"preflop": {
			"events": [
				{"t": 0.45, "seat": 0, "state": "FOLD", "bet": 0},
				{"t": 0.90, "seat": 1, "state": "FOLD", "bet": 0},
				{"t": 1.35, "seat": 2, "state": "ALL IN 1,800", "bet": 1800},
				{"t": 1.80, "seat": 3, "state": "CALL 4,300", "bet": 4300},
				{"t": 2.25, "seat": 4, "state": "FOLD", "bet": 0},
				{"t": 2.70, "seat": 5, "state": "CALL 4,300", "bet": 4300},
			],
			"collect": {"main_after": 5400, "side_after": 5000, "tip": 180},
		},
		"flop": {
			"events": [
				{"t": 0.55, "seat": 3, "state": "BET 1,200", "bet": 1200},
				{"t": 1.20, "seat": 5, "state": "CALL 1,200", "bet": 1200},
			],
			"request": {
				"t": 0.70,
				"seat": 3,
				"text": "토니 · 5,000 칩 교환 요청",
				"patience": 5.5,
			},
			"collect": {"main_after": 5400, "side_after": 7400, "tip": 140},
		},
		"turn": {
			"events": [
				{"t": 0.55, "seat": 3, "state": "CHECK", "bet": 0},
				{"t": 1.05, "seat": 5, "state": "BET 2,000", "bet": 2000},
				{"t": 1.65, "seat": 3, "state": "CALL 2,000", "bet": 2000},
			],
			"collect": {"main_after": 5400, "side_after": 11400, "tip": 150},
		},
		"river": {
			"events": [
				{"t": 0.45, "seat": 3, "state": "CHECK", "bet": 0},
				{"t": 0.95, "seat": 5, "state": "BET 1,500", "bet": 1500},
				{"t": 1.55, "seat": 3, "state": "CALL 1,500", "bet": 1500},
			],
			"collect": {"main_after": 5400, "side_after": 14400, "tip": 150},
		},
		"showdown": {
			"text": "소연  A♠ A♥\n토니  9♠ 9♥\n찰리  K♣ J♣",
			"payouts": [
				{"pot": "MAIN", "amount": 5400, "seat": 2, "tip": 220, "eligible": [2, 3, 5]},
				{"pot": "SIDE", "amount": 14400, "seat": 5, "tip": 260, "eligible": [3, 5]},
			],
		},
	})

	hands.append({
		"id": "hand_02",
		"label": "HAND 2 / 3",
		"board": ["Q♣", "8♣", "4♥", "8♦", "K♠"],
		"preflop": {
			"events": [
				{"t": 0.35, "seat": 0, "state": "CALL 600", "bet": 600},
				{"t": 0.70, "seat": 1, "state": "RAISE 1,800", "bet": 1800},
				{"t": 1.05, "seat": 2, "state": "FOLD", "bet": 0},
				{"t": 1.40, "seat": 3, "state": "CALL 1,800", "bet": 1800},
				{"t": 1.75, "seat": 4, "state": "FOLD", "bet": 0},
				{"t": 2.10, "seat": 5, "state": "CALL 1,800", "bet": 1800},
				{"t": 2.50, "seat": 0, "state": "CALL 1,800", "bet": 1800},
			],
			"collect": {"main_after": 7200, "side_after": 0, "tip": 150},
		},
		"flop": {
			"events": [
				{"t": 0.40, "seat": 0, "state": "CHECK", "bet": 0},
				{"t": 0.80, "seat": 1, "state": "BET 2,200", "bet": 2200},
				{"t": 1.20, "seat": 3, "state": "FOLD", "bet": 0},
				{"t": 1.60, "seat": 5, "state": "CALL 2,200", "bet": 2200},
				{"t": 2.15, "seat": 0, "state": "FOLD", "bet": 0},
			],
			"request": {
				"t": 0.95,
				"seat": 4,
				"text": "김사장 · 1,000칩 5개 요청",
				"patience": 4.8,
			},
			"collect": {"main_after": 11600, "side_after": 0, "tip": 160},
		},
		"turn": {
			"events": [
				{"t": 0.45, "seat": 1, "state": "CHECK", "bet": 0},
				{"t": 0.95, "seat": 5, "state": "BET 3,000", "bet": 3000},
				{"t": 1.45, "seat": 1, "state": "CALL 3,000", "bet": 3000},
			],
			"collect": {"main_after": 17600, "side_after": 0, "tip": 160},
		},
		"river": {
			"events": [
				{"t": 0.50, "seat": 1, "state": "CHECK", "bet": 0},
				{"t": 1.00, "seat": 5, "state": "CHECK", "bet": 0},
			],
			"collect": {"main_after": 17600, "side_after": 0, "tip": 0, "skip_if_zero": true},
		},
		"showdown": {
			"text": "맥스  Q♠ J♠\n찰리  K♦ 10♦",
			"payouts": [
				{"pot": "MAIN", "amount": 17600, "seat": 5, "tip": 230, "eligible": [1, 5]},
			],
		},
	})

	hands.append({
		"id": "hand_03",
		"label": "HAND 3 / 3",
		"board": ["A♦", "9♣", "6♣", "Q♥", "6♠"],
		"preflop": {
			"events": [
				{"t": 0.30, "seat": 0, "state": "RAISE 1,200", "bet": 1200},
				{"t": 0.60, "seat": 1, "state": "CALL 1,200", "bet": 1200},
				{"t": 0.90, "seat": 2, "state": "CALL 1,200", "bet": 1200},
				{"t": 1.20, "seat": 3, "state": "ALL IN 3,400", "bet": 3400},
				{"t": 1.50, "seat": 4, "state": "FOLD", "bet": 0},
				{"t": 1.80, "seat": 5, "state": "CALL 3,400", "bet": 3400},
				{"t": 2.10, "seat": 0, "state": "CALL 3,400", "bet": 3400},
				{"t": 2.40, "seat": 1, "state": "FOLD", "bet": 0},
				{"t": 2.70, "seat": 2, "state": "CALL 3,400", "bet": 3400},
			],
			"collect": {"main_after": 13600, "side_after": 0, "tip": 190},
		},
		"flop": {
			"events": [
				{"t": 0.35, "seat": 0, "state": "CHECK", "bet": 0},
				{"t": 0.70, "seat": 2, "state": "BET 2,500", "bet": 2500},
				{"t": 1.05, "seat": 5, "state": "CALL 2,500", "bet": 2500},
				{"t": 1.40, "seat": 0, "state": "FOLD", "bet": 0},
			],
			"collect": {"main_after": 18600, "side_after": 0, "tip": 170},
		},
		"turn": {
			"events": [
				{"t": 0.35, "seat": 2, "state": "BET 4,000", "bet": 4000},
				{"t": 0.70, "seat": 5, "state": "ALL IN 1,600", "bet": 1600},
				{"t": 1.10, "seat": 2, "state": "CALL", "bet": 4000},
			],
			"request": {
				"t": 0.55,
				"seat": 1,
				"text": "맥스 · 다음 핸드 칩 교환 요청",
				"patience": 4.2,
			},
			"collect": {"main_after": 21800, "side_after": 2400, "tip": 200},
		},
		"river": {
			"events": [
				{"t": 0.40, "seat": 2, "state": "CHECK", "bet": 0},
			],
			"collect": {"main_after": 21800, "side_after": 2400, "tip": 0, "skip_if_zero": true},
		},
		"showdown": {
			"text": "소연  A♣ Q♣\n찰리  9♦ 9♥",
			"payouts": [
				{"pot": "MAIN", "amount": 21800, "seat": 2, "tip": 260, "eligible": [2, 5]},
				{"pot": "SIDE", "amount": 2400, "seat": 2, "tip": 180, "eligible": [2]},
			],
		},
	})

	return hands
