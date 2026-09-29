extends SceneTree

func _init() -> void:
	var exit_code: int = _run()
	quit(exit_code)


func _run() -> int:
	var runtime_file := FileAccess.open("res://scripts/gameplay/main_game.gd", FileAccess.READ)
	if runtime_file == null:
		return _fail("Could not inspect wireframe reconciliation runtime.")
	var runtime_text: String = runtime_file.get_as_text()

	for required in [
		'const BUILD_ID: String = "wireframe-reconcile-stage7-v0.8"',
		'h1.text = "RIVER PUB"',
		'goal_kicker.text = "TODAY GOAL"',
		'reward_kicker.text = "SHIFT REWARD"',
		'start.text = "근무 시작"',
		'nav_names: Array[String] = ["HOME", "CAREER", "GUESTS", "GEAR"]',
		'func _build_career()',
		'"REGULAR NIGHT"',
		'"VIP TABLE"',
		'"TOURNAMENT FINAL"',
		'dealer_hand_left',
		'dealer_hand_right',
		'burn_panel',
		'burn_label',
		'_sync_wireframe_state',
		'_sync_wireframe_betting_state',
		'_show_local_feedback',
		'return "COLLECT"',
		'return "BOARD"',
		'return "PAYOUT"',
		'NEXT UNLOCK',
	]:
		if not runtime_text.contains(required):
			return _fail("Missing reconciled wireframe anchor: %s" % required)

	if runtime_text.contains("_build_tool_panel"):
		return _fail("Wireframe reconciliation must not restore the old dealer toolbar.")
	if runtime_text.contains("seat_trait_labels"):
		return _fail("Wireframe reconciliation must not restore permanent NPC tutorial labels.")
	if not runtime_text.contains("_try_action_dialogue"):
		return _fail("Stage 6 NPC life was lost during wireframe reconciliation.")
	if not runtime_text.contains("LiveShiftScenario.build(shift_seed, roster)"):
		return _fail("Dynamic live-shift gameplay was lost during wireframe reconciliation.")

	var doc_file := FileAccess.open("res://docs/wireframes/WIREFRAME_RECONCILIATION.md", FileAccess.READ)
	if doc_file == null:
		return _fail("Wireframe reconciliation decisions are not documented.")
	var doc_text: String = doc_file.get_as_text()
	for phrase in [
		"The wireframe pack owns",
		"The current runtime owns",
		"Explicitly not restored",
		"Gameplay base contract",
	]:
		if not doc_text.contains(phrase):
			return _fail("Reconciliation document is missing section: %s" % phrase)

	print("LET'S DEALER stage 7 wireframe reconciliation smoke test passed.")
	return 0


func _fail(message: String) -> int:
	push_error("Stage 7 wireframe reconciliation smoke test failed: " + message)
	return 1
