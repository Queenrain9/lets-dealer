extends SceneTree

func _init() -> void:
	var exit_code: int = _run()
	quit(exit_code)


func _run() -> int:
	if not _test_main_and_side_pot():
		return 1
	if not _test_folded_dead_money():
		return 1
	if not _test_blinds_positions_and_payout():
		return 1
	if not _test_scenario_and_runtime_hooks():
		return 1

	print("LET'S DEALER stage 8 real table state smoke test passed.")
	return 0


func _test_main_and_side_pot() -> bool:
	var state := DealerTableState.new(3)
	state.begin_hand([1800, 4300, 4300], 0, 0, 0)
	state.apply_action(0, "ALL IN 1,800", 1800)
	state.apply_action(1, "CALL 4,300", 4300)
	state.apply_action(2, "CALL 4,300", 4300)

	var layers: Array[Dictionary] = state.pot_layers()
	if layers.size() != 2:
		return _fail_bool("Expected main + side pot layers.")
	if int(layers[0].get("amount", 0)) != 5400:
		return _fail_bool("Main pot should be computed as 5,400.")
	if int(layers[1].get("amount", 0)) != 5000:
		return _fail_bool("Side pot should be computed as 5,000.")
	if state.main_pot_amount() != 5400 or state.side_pot_amount() != 5000:
		return _fail_bool("Derived main/side totals are incorrect.")
	return true


func _test_folded_dead_money() -> bool:
	var state := DealerTableState.new(4)
	state.begin_hand([10000, 10000, 10000, 10000], 0, 0, 0)
	state.apply_action(0, "CALL 300", 300)
	state.apply_action(0, "FOLD", 300)
	state.apply_action(1, "CALL 1,800", 1800)
	state.apply_action(2, "CALL 1,800", 1800)
	state.apply_action(3, "CALL 1,800", 1800)

	var layers: Array[Dictionary] = state.pot_layers()
	if layers.size() != 1:
		return _fail_bool("Dead money with identical eligibility should merge into one main pot.")
	if int(layers[0].get("amount", 0)) != 5700:
		return _fail_bool("Folded chips should remain in the pot.")
	var eligible: Array = layers[0].get("eligible", []) as Array
	if eligible.has(0):
		return _fail_bool("Folded player must not remain eligible for the pot.")
	return true


func _test_blinds_positions_and_payout() -> bool:
	var state := DealerTableState.new(6)
	state.begin_hand([5000, 5000, 5000, 5000, 5000, 5000], 2, 300, 600)
	if state.button_seat != 2 or state.small_blind_seat != 3 or state.big_blind_seat != 4:
		return _fail_bool("Button/SB/BB positions did not rotate correctly.")
	if state.position_for(2) != "D" or state.position_for(3) != "SB" or state.position_for(4) != "BB":
		return _fail_bool("Seat position labels are incorrect.")
	if state.contribution_for(3) != 300 or state.contribution_for(4) != 600:
		return _fail_bool("Blinds were not posted into real table state.")
	if state.stack_for(3) != 4700 or state.stack_for(4) != 4400:
		return _fail_bool("Blind posting did not reduce stacks.")

	state.payout(3, 1200)
	if state.stack_for(3) != 5900:
		return _fail_bool("Payout did not mutate the winner stack.")
	return true


func _test_scenario_and_runtime_hooks() -> bool:
	var roster: Array[NPCProfile] = NPCRoster.build(808)
	for profile in roster:
		if profile.aggression <= 0.0:
			return _fail_bool("NPC betting aggression must be positive.")

	var hands: Array[Dictionary] = LiveShiftScenario.build(808, roster)
	for hand in hands:
		var stacks: Variant = hand.get("starting_stacks", [])
		var blinds: Variant = hand.get("blinds", [])
		if not stacks is Array or (stacks as Array).size() != 6:
			return _fail_bool("Every hand needs six real starting stacks.")
		if not blinds is Array or (blinds as Array).size() != 2:
			return _fail_bool("Every hand needs SB/BB data.")

	var runtime_file := FileAccess.open("res://scripts/gameplay/main_game.gd", FileAccess.READ)
	if runtime_file == null:
		return _fail_bool("Could not inspect Stage 8 runtime.")
	var runtime_text: String = runtime_file.get_as_text()

	for required in [
		"DealerTableState.new(6)",
		"table_state.begin_hand",
		"table_state.apply_action",
		"table_state.begin_street",
		"table_state.main_pot_amount",
		"table_state.side_pot_amount",
		"table_state.pot_layers",
		"table_state.payout",
		"_build_dynamic_payouts",
		"_refresh_stack_position_ui",
		"_refresh_bet_ui",
		"seat_position_labels",
	]:
		if not runtime_text.contains(required):
			return _fail_bool("Missing real table-state runtime hook: %s" % required)

	if runtime_text.contains('duty.state.get("main_after"'):
		return _fail_bool("Runtime still reads hardcoded main pot totals.")
	if runtime_text.contains('duty.state.get("side_after"'):
		return _fail_bool("Runtime still reads hardcoded side pot totals.")

	return true


func _fail_bool(message: String) -> bool:
	push_error("Stage 8 real table state smoke test failed: " + message)
	return false
