extends RefCounted
class_name LiveShiftScenario


static func build(seed: int = 1, roster: Array[NPCProfile] = []) -> Array[Dictionary]:
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

	if roster.is_empty():
		roster = NPCRoster.build(seed)

	_randomize_shift(hands, seed, roster)
	return hands


static func _randomize_shift(hands: Array[Dictionary], seed: int, roster: Array[NPCProfile]) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed

	for i in range(hands.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var temp: Dictionary = hands[i]
		hands[i] = hands[j]
		hands[j] = temp

	for hand_index in range(hands.size()):
		var hand: Dictionary = hands[hand_index]
		hand["label"] = "HAND %d / %d" % [hand_index + 1, hands.size()]
		_relocate_request(hand, rng)
		for street in ["preflop", "flop", "turn", "river"]:
			if hand.has(street):
				_randomize_round(hand[street] as Dictionary, rng, roster)
		_rebuild_showdown_text(hand, roster)



static func _relocate_request(hand: Dictionary, rng: RandomNumberGenerator) -> void:
	var source_street: String = ""
	var request_data: Dictionary = {}
	for street in ["flop", "turn", "river"]:
		if not hand.has(street):
			continue
		var round_data: Dictionary = hand[street] as Dictionary
		var raw_request: Variant = round_data.get("request", {})
		if raw_request is Dictionary and not (raw_request as Dictionary).is_empty():
			source_street = street
			request_data = (raw_request as Dictionary).duplicate(true)
			round_data.erase("request")
			break

	if request_data.is_empty():
		return

	var candidates: Array[String] = ["flop", "turn", "river"]
	var target_street: String = candidates[rng.randi_range(0, candidates.size() - 1)]
	if not hand.has(target_street):
		target_street = source_street
	var target_round: Dictionary = hand[target_street] as Dictionary
	target_round["request"] = request_data


static func _randomize_round(round_data: Dictionary, rng: RandomNumberGenerator, roster: Array[NPCProfile]) -> void:
	var raw_events: Variant = round_data.get("events", [])
	if raw_events is Array:
		var events: Array = raw_events as Array
		var previous_base: float = 0.0
		var current_time: float = 0.0
		for raw: Variant in events:
			if not raw is Dictionary:
				continue
			var event: Dictionary = raw as Dictionary
			var base_time: float = float(event.get("t", previous_base + 0.4))
			var delta: float = maxf(base_time - previous_base, 0.18)
			var seat: int = int(event.get("seat", -1))
			var speed: float = 1.0
			if seat >= 0 and seat < roster.size():
				speed = roster[seat].action_speed
			current_time += maxf(0.18, delta * speed * rng.randf_range(0.88, 1.12))
			event["t"] = current_time
			previous_base = base_time

	var raw_request: Variant = round_data.get("request", {})
	if raw_request is Dictionary and not (raw_request as Dictionary).is_empty():
		var request: Dictionary = raw_request as Dictionary
		var seat: int = _pick_request_seat(rng, roster)
		var profile: NPCProfile = roster[seat]
		var request_types: Array[String] = [
			"5,000 칩 교환 요청",
			"1,000칩 5개 요청",
			"500칩 10개 요청",
			"큰 칩을 잔칩으로 교환 요청",
		]
		request["seat"] = seat
		request["text"] = "%s · %s" % [
			profile.display_name,
			request_types[rng.randi_range(0, request_types.size() - 1)],
		]
		request["patience"] = maxf(2.8, 5.0 * profile.patience * rng.randf_range(0.90, 1.10))
		request["tip"] = int(round(150.0 * profile.tip_multiplier))
		request["t"] = maxf(0.45, float(request.get("t", 0.8)) * profile.action_speed * rng.randf_range(0.85, 1.10))


static func _pick_request_seat(rng: RandomNumberGenerator, roster: Array[NPCProfile]) -> int:
	if roster.is_empty():
		return 0
	var total: float = 0.0
	for profile in roster:
		total += maxf(profile.request_bias, 0.05)

	var roll: float = rng.randf() * total
	var cursor: float = 0.0
	for i in range(roster.size()):
		cursor += maxf(roster[i].request_bias, 0.05)
		if roll <= cursor:
			return i
	return roster.size() - 1


static func _rebuild_showdown_text(hand: Dictionary, roster: Array[NPCProfile]) -> void:
	if not hand.has("showdown"):
		return
	var showdown: Dictionary = hand["showdown"] as Dictionary
	var cards: Dictionary = {}
	match String(hand.get("id", "")):
		"hand_01":
			cards = {2: "A♠ A♥", 3: "9♠ 9♥", 5: "K♣ J♣"}
		"hand_02":
			cards = {1: "Q♠ J♠", 5: "K♦ 10♦"}
		"hand_03":
			cards = {2: "A♣ Q♣", 5: "9♦ 9♥"}

	var lines: Array[String] = []
	for raw_seat: Variant in cards.keys():
		var seat: int = int(raw_seat)
		var name: String = "SEAT %d" % (seat + 1)
		if seat >= 0 and seat < roster.size():
			name = roster[seat].display_name
		lines.append("%s  %s" % [name, String(cards[raw_seat])])
	showdown["text"] = "\n".join(lines)
