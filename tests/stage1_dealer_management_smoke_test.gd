extends SceneTree

func _init() -> void:
	var exit_code: int = _run()
	quit(exit_code)


func _run() -> int:
	var tasks: Array[DealerTask] = RookieShiftScenario.build()
	if tasks.size() != 12:
		return _fail("Expected 12 dealer-management tasks, got %d." % tasks.size())

	var expected_ids: Array[String] = [
		"deal",
		"preflop_collect",
		"sidepot_detect",
		"flop",
		"flop_collect",
		"chip_change",
		"turn",
		"turn_collect",
		"river",
		"river_collect",
		"main_payout",
		"side_payout",
	]

	for i in range(expected_ids.size()):
		if tasks[i].id != expected_ids[i]:
			return _fail("Task %d expected %s, got %s." % [i, expected_ids[i], tasks[i].id])
		if tasks[i].choices.size() != 3:
			return _fail("Task %s does not expose three decision choices." % tasks[i].id)
		if tasks[i].correct_index < 0 or tasks[i].correct_index >= tasks[i].choices.size():
			return _fail("Task %s has invalid correct_index." % tasks[i].id)
		if tasks[i].time_limit <= 0.0:
			return _fail("Task %s has no time pressure." % tasks[i].id)

	var side_task: DealerTask = tasks[2]
	if side_task.action_kind != "sidepot":
		return _fail("ALL IN scenario is not wired to side-pot recognition.")
	var side_state: Dictionary = side_task.state
	if int(side_state.get("side_pot", 0)) <= 0:
		return _fail("Side-pot task does not display a side pot.")

	var service_task: DealerTask = tasks[5]
	if service_task.action_kind != "chip_change":
		return _fail("Customer service interruption is missing.")
	if String(service_task.state.get("request", "")).is_empty():
		return _fail("Customer request task has no visible request.")

	var main_payout: DealerTask = tasks[10]
	var side_payout: DealerTask = tasks[11]
	if main_payout.correct_index == side_payout.correct_index:
		return _fail("Main pot and side pot should require different winner decisions.")

	var runtime_file := FileAccess.open("res://scripts/gameplay/main_game.gd", FileAccess.READ)
	if runtime_file == null:
		return _fail("Could not inspect current main runtime.")
	var runtime_text: String = runtime_file.get_as_text()
	if runtime_text.contains("docs/wireframes") or runtime_text.contains("TextureRect"):
		return _fail("Runtime still renders wireframe reference images.")

	print("LET'S DEALER stage 1 dealer-management smoke test passed.")
	return 0


func _fail(message: String) -> int:
	push_error("Stage 1 smoke test failed: " + message)
	return 1
