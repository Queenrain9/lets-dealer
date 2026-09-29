extends SceneTree

func _init() -> void:
	var exit_code: int = _run()
	quit(exit_code)


func _run() -> int:
	var hands: Array[Dictionary] = LiveShiftScenario.build()
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

	var first_flop: Dictionary = hands[0]["flop"] as Dictionary
	if not first_flop.has("request"):
		return _fail("Hand 1 flop should overlap a customer request with live betting.")
	var third_turn: Dictionary = hands[2]["turn"] as Dictionary
	if not third_turn.has("request"):
		return _fail("Hand 3 turn should overlap a customer request with live betting.")

	var first_showdown: Dictionary = hands[0]["showdown"] as Dictionary
	var first_payouts: Array = first_showdown["payouts"] as Array
	if first_payouts.size() != 2:
		return _fail("Hand 1 should have main and side payouts.")
	var main: Dictionary = first_payouts[0] as Dictionary
	var side: Dictionary = first_payouts[1] as Dictionary
	if int(main.get("seat", -1)) == int(side.get("seat", -1)):
		return _fail("Main and side pot winners should differ in Hand 1.")
	var side_eligible: Array = side.get("eligible", []) as Array
	if side_eligible.has(int(main.get("seat", -1))):
		return _fail("Hand 1 main winner should be excluded from side-pot eligibility.")

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
		return _fail("Quiz UI returned to the live shift runtime.")
	if runtime_text.contains("지금 해야 할 딜러 업무를 선택하세요"):
		return _fail("Quiz wording returned to the live shift runtime.")
	if runtime_text.contains("docs/wireframes") or runtime_text.contains("TextureRect"):
		return _fail("Runtime should not render wireframe images.")

	print("LET'S DEALER stage 2 live shift smoke test passed.")
	return 0


func _fail(message: String) -> int:
	push_error("Stage 2 live shift smoke test failed: " + message)
	return 1
