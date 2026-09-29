extends SceneTree

func _init() -> void:
	var exit_code: int = _run()
	quit(exit_code)


func _run() -> int:
	var runtime_file := FileAccess.open("res://scripts/gameplay/main_game.gd", FileAccess.READ)
	if runtime_file == null:
		return _fail("Could not inspect Stage 5 runtime.")
	var runtime_text: String = runtime_file.get_as_text()

	for forbidden in [
		"DEALER RAIL",
		"TABLE LOG",
		"POT 선택됨",
		"DECK · 새 핸드 시작",
		"DECK 또는 BOARD로 다음 스트리트",
		"테이블 위 칩을 보고 POT을 처리",
		"플레이어들이 딜을 기다리고 있습니다.",
		"seat_trait_labels",
		"DECK을 탭하면",
		"POT을 탭하면",
		"손님 요청은 해당 좌석",
	]:
		if runtime_text.contains(forbidden):
			return _fail("Tutorial-facing copy remains: %s" % forbidden)

	for required in [
		"REQUEST_POSITIONS",
		"_signal_duty_affordance",
		"_soft_nudge",
		"event_label.visible = false",
		"pressure_label.visible = false",
		"var urgent: bool = false",
		"floor_button.visible = session_active and urgent",
		"request_panel.position = REQUEST_POSITIONS[seat]",
	]:
		if not runtime_text.contains(required):
			return _fail("Stage 5 game-feel feature is missing: %s" % required)

	if not runtime_text.contains('h1.text = "RIVER PUB"'):
		return _fail("Home screen should be venue-first rather than tutorial-first.")
	if not runtime_text.contains('goal_kicker.text = "TODAY GOAL"'):
		return _fail("Home screen should present a game goal, not instructions.")
	if not runtime_text.contains('reward_kicker.text = "SHIFT REWARD"'):
		return _fail("Home screen should present shift rewards, not tutorial copy.")
	if not runtime_text.contains('context_label.visible = false'):
		return _fail("Context instruction label should stay hidden.")
	if not runtime_text.contains('hidden_log.visible = false'):
		return _fail("Developer table log should be hidden from gameplay.")

	print("LET'S DEALER stage 5 tutorial removal smoke test passed.")
	return 0


func _fail(message: String) -> int:
	push_error("Stage 5 tutorial removal smoke test failed: " + message)
	return 1
