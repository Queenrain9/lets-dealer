extends SceneTree

func _init() -> void:
	var exit_code: int = _run()
	quit(exit_code)


func _run() -> int:
	var runtime_file := FileAccess.open("res://scripts/gameplay/main_game.gd", FileAccess.READ)
	if runtime_file == null:
		return _fail("Could not inspect table-first runtime.")
	var runtime_text: String = runtime_file.get_as_text()

	for forbidden in [
		"ACTION_ORDER",
		"ACTION_LABELS",
		"_build_tool_panel",
		"action_buttons",
		"DEALER TOOLS",
	]:
		if runtime_text.contains(forbidden):
			return _fail("Legacy toolbar surface remains: %s" % forbidden)

	for required in [
		"_build_dealer_rail",
		"_on_deck_pressed",
		"_on_board_pressed",
		"_on_pot_pressed",
		"_on_request_pressed",
		"_on_seat_pressed",
		"_refresh_floor_affordance",
		"CALL FLOOR",
		"POT 선택됨",
	]:
		if not runtime_text.contains(required):
			return _fail("Missing table-first interaction feature: %s" % required)

	if not runtime_text.contains('deck_hit.pressed.connect(_on_deck_pressed)'):
		return _fail("Deck area is not directly interactive.")
	if not runtime_text.contains('board_hit.pressed.connect(_on_board_pressed)'):
		return _fail("Board area is not directly interactive.")
	if not runtime_text.contains('pot_hit.pressed.connect(_on_pot_pressed)'):
		return _fail("Pot area is not directly interactive.")
	if not runtime_text.contains('request_hit.pressed.connect(_on_request_pressed)'):
		return _fail("Request bubble is not directly interactive.")
	if not runtime_text.contains('floor_button.visible = false'):
		return _fail("Floor affordance should start hidden and appear contextually.")

	print("LET'S DEALER stage 4 table-first interaction smoke test passed.")
	return 0


func _fail(message: String) -> int:
	push_error("Stage 4 table-first smoke test failed: " + message)
	return 1
