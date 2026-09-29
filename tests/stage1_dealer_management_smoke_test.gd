extends SceneTree

func _init() -> void:
	var exit_code: int = _run()
	quit(exit_code)


func _run() -> int:
	var tasks: Array[DealerTask] = RookieShiftScenario.build()
	if tasks.size() != 11:
		return _fail("Expected 11 live-table tasks, got %d." % tasks.size())

	var expected_ids: Array[String] = [
		"deal",
		"preflop_collect",
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
	var expected_actions: Array[String] = [
		"deal",
		"pot",
		"board",
		"pot",
		"chip_change",
		"board",
		"pot",
		"board",
		"pot",
		"payout",
		"payout",
	]

	for i in range(expected_ids.size()):
		if tasks[i].id != expected_ids[i]:
			return _fail("Task %d expected %s, got %s." % [i, expected_ids[i], tasks[i].id])
		if tasks[i].expected_action != expected_actions[i]:
			return _fail("Task %s expected action %s, got %s." % [
				tasks[i].id,
				expected_actions[i],
				tasks[i].expected_action,
			])
		if tasks[i].time_limit <= 0.0:
			return _fail("Task %s has no table-pressure timer." % tasks[i].id)

	var all_in_task: DealerTask = tasks[1]
	var all_in_state: Dictionary = all_in_task.state
	var raw_bets: Variant = all_in_state.get("bets", [])
	if not raw_bets is Array:
		return _fail("ALL IN task has no visible betting state.")
	var bets: Array = raw_bets as Array
	if bets.size() < 6 or int(bets[2]) != 1800 or int(bets[3]) != 4300 or int(bets[5]) != 4300:
		return _fail("ALL IN task does not expose the uneven contributions needed for side-pot formation.")
	if all_in_task.expected_action != "pot":
		return _fail("Side-pot recognition should happen through the normal POT tool.")

	var service_task: DealerTask = tasks[4]
	if service_task.expected_action != "chip_change":
		return _fail("Customer chip-change request is missing.")
	if String(service_task.state.get("request", "")).is_empty():
		return _fail("Customer request is not visible on the table.")

	var main_payout: DealerTask = tasks[9]
	var side_payout: DealerTask = tasks[10]
	if main_payout.target_seat < 0 or side_payout.target_seat < 0:
		return _fail("Payout tasks require actual seat targets.")
	if main_payout.target_seat == side_payout.target_seat:
		return _fail("Main and side pots should pay different seats in this scenario.")

	var runtime_file := FileAccess.open("res://scripts/gameplay/main_game.gd", FileAccess.READ)
	if runtime_file == null:
		return _fail("Could not inspect current main runtime.")
	var runtime_text: String = runtime_file.get_as_text()

	if runtime_text.contains("choice_buttons"):
		return _fail("Multiple-choice UI returned to the runtime.")
	if runtime_text.contains("지금 해야 할 딜러 업무를 선택하세요"):
		return _fail("Quiz prompt returned to the runtime.")
	if runtime_text.contains("docs/wireframes") or runtime_text.contains("TextureRect"):
		return _fail("Runtime still renders wireframe reference images.")
	if not runtime_text.contains("DEALER TOOLS"):
		return _fail("Persistent dealer tool surface is missing.")
	if not runtime_text.contains("_on_seat_pressed"):
		return _fail("Payout does not target actual table seats.")

	print("LET'S DEALER live-table smoke test passed.")
	return 0


func _fail(message: String) -> int:
	push_error("Live-table smoke test failed: " + message)
	return 1
