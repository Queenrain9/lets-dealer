extends SceneTree

func _init() -> void:
	var exit_code: int = _run()
	quit(exit_code)


func _run() -> int:
	var roster_a: Array[NPCProfile] = NPCRoster.build(777)
	var roster_b: Array[NPCProfile] = NPCRoster.build(777)
	var roster_c: Array[NPCProfile] = NPCRoster.build(778)

	if roster_a.size() != 6:
		return _fail("Expected six NPC profiles.")

	var ids: Dictionary = {}
	for profile in roster_a:
		ids[profile.id] = true
		if profile.display_name.is_empty() or profile.trait_label.is_empty():
			return _fail("NPC profile is missing visible identity data.")
		if profile.action_speed <= 0.0 or profile.patience <= 0.0:
			return _fail("NPC personality modifiers must be positive.")
	if ids.size() != 6:
		return _fail("NPC roster should contain six distinct personalities.")

	for i in range(roster_a.size()):
		if roster_a[i].id != roster_b[i].id:
			return _fail("NPC roster should be deterministic for the same seed.")

	var different_order: bool = false
	for i in range(roster_a.size()):
		if roster_a[i].id != roster_c[i].id:
			different_order = true
			break
	if not different_order:
		return _fail("Different seeds should produce a different seat roster.")

	var hands_a: Array[Dictionary] = LiveShiftScenario.build(777, roster_a)
	var hands_b: Array[Dictionary] = LiveShiftScenario.build(777, roster_b)
	if hands_a.size() != 3 or hands_b.size() != 3:
		return _fail("Dynamic shift must still contain three hands.")

	for i in range(hands_a.size()):
		if String(hands_a[i].get("id", "")) != String(hands_b[i].get("id", "")):
			return _fail("Hand order should be deterministic for the same seed.")

	var request_count: int = 0
	for hand in hands_a:
		for street in ["flop", "turn", "river"]:
			var round_data: Dictionary = hand[street] as Dictionary
			var raw_request: Variant = round_data.get("request", {})
			if raw_request is Dictionary and not (raw_request as Dictionary).is_empty():
				request_count += 1
				var request: Dictionary = raw_request as Dictionary
				var seat: int = int(request.get("seat", -1))
				if seat < 0 or seat >= roster_a.size():
					return _fail("Dynamic request has invalid source seat.")
				if not String(request.get("text", "")).contains(roster_a[seat].display_name):
					return _fail("Request text should use the seated NPC name.")
				if float(request.get("patience", 0.0)) <= 0.0:
					return _fail("Request patience was not personality-adjusted.")
				if int(request.get("tip", 0)) <= 0:
					return _fail("Request tip value was not personality-adjusted.")

	if request_count != 3:
		return _fail("Expected one relocated request per hand.")

	var runtime_file := FileAccess.open("res://scripts/gameplay/main_game.gd", FileAccess.READ)
	if runtime_file == null:
		return _fail("Could not inspect Stage 3 runtime.")
	var runtime_text: String = runtime_file.get_as_text()

	for required in [
		"seat_trait_labels",
		"NPCRoster.build",
		"LiveShiftScenario.build(shift_seed, roster)",
		"warning_line",
		"miss_line",
		"_apply_roster_to_seats",
	]:
		if not runtime_text.contains(required):
			return _fail("Runtime is missing Stage 3 personality feature: %s" % required)

	if runtime_text.contains("choice_buttons"):
		return _fail("Quiz UI returned during Stage 3.")

	print("LET'S DEALER stage 3 NPC personality smoke test passed.")
	return 0


func _fail(message: String) -> int:
	push_error("Stage 3 NPC personality smoke test failed: " + message)
	return 1
