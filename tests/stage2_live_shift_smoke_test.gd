extends SceneTree

func _init() -> void:
	var exit_code: int = _run()
	quit(exit_code)


func _run() -> int:
	var roster: Array[NPCProfile] = NPCRoster.build(101)
	var hands: Array[Dictionary] = LiveShiftScenario.build(101, roster)
	if hands.size() != 3:
		return _fail("Expected a 3-hand live shift.")

	for hand_index in range(hands.size()):
		var hand: Dictionary = hands[hand_index]
		for street in ["preflop", "flop", "turn", "river"]:
			if not hand.has(street):
				return _fail("Hand %d is missing %s." % [hand_index, street])
			var round_data: Dictionary = hand[street] as Dictionary
			if not round_data.has("events"):
				return _fail("Hand %d %s has no autonomous NPC event timeline." % [hand_index, street])
		if not hand.has("showdown"):
			return _fail("Hand %d has no showdown." % hand_index)

	var hand_01: Dictionary = _find_hand(hands, "hand_01")
	var hand_03: Dictionary = _find_hand(hands, "hand_03")
	if hand_01.is_empty() or hand_03.is_empty():
		return _fail("Required live-shift hand templates were lost during shuffle.")

	if not _hand_has_live_request(hand_01):
		return _fail("Hand 01 should contain an overlapping customer request.")
	if not _hand_has_live_request(hand_03):
		return _fail("Hand 03 should contain an overlapping customer request.")

	var first_showdown: Dictionary = hand_01["showdown"] as Dictionary
	var first_payouts: Array = first_showdown["payouts"] as Array
	if first_payouts.size() != 2:
		return _fail("Hand 01 should have main and side payouts.")
	var main: Dictionary = first_payouts[0] as Dictionary
	var side: Dictionary = first_payouts[1] as Dictionary
	if int(main.get("seat", -1)) == int(side.get("seat", -1)):
		return _fail("Main and side pot winners should differ in Hand 01.")
	var side_eligible: Array = side.get("eligible", []) as Array
	if side_eligible.has(int(main.get("seat", -1))):
		return _fail("Hand 01 main winner should be excluded from side-pot eligibility.")

	var runtime_file := FileAccess.open("res://scripts/gameplay/main_game.gd", FileAccess.READ)
	if runtime_file == null:
		return _fail("Could not inspect live shift runtime.")
	var runtime_text: String = runtime_file.get_as_text()

	for required in [
		"pending_duties",
		"scheduled_events",
		"_schedule_betting_round",
		"_spawn_service_request",
		"_age_pending_duties",
		"FLOW x",
		"_start_hand",
	]:
		if not runtime_text.contains(required):
			return _fail("Runtime is missing stage 2 feature: %s" % required)

	if runtime_text.contains("choice_buttons"):
		return _fail("Multiple-choice UI returned to the runtime.")
	if runtime_text.contains("지금 해야 할 딜러 업무를 선택하세요"):
		return _fail("Quiz wording returned to the live shift runtime.")
	if runtime_text.contains("docs/wireframes") or runtime_text.contains("TextureRect"):
		return _fail("Runtime should not render wireframe images.")

	print("LET'S DEALER stage 2 live shift smoke test passed.")
	return 0


func _find_hand(hands: Array[Dictionary], target_id: String) -> Dictionary:
	for hand in hands:
		if String(hand.get("id", "")) == target_id:
			return hand
	return {}


func _hand_has_live_request(hand: Dictionary) -> bool:
	for street in ["flop", "turn", "river"]:
		if not hand.has(street):
			continue
		var round_data: Dictionary = hand[street] as Dictionary
		var raw_request: Variant = round_data.get("request", {})
		if raw_request is Dictionary and not (raw_request as Dictionary).is_empty():
			return true
	return false


func _fail(message: String) -> int:
	push_error("Stage 2 live shift smoke test failed: " + message)
	return 1
