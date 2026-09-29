extends SceneTree

func _init() -> void:
	var exit_code: int = _run()
	quit(exit_code)


func _run() -> int:
	var roster: Array[NPCProfile] = NPCRoster.build(9029)
	if roster.size() != 6:
		return _fail("Expected six NPCs in dialogue roster.")

	for profile in roster:
		for category in [
			"call",
			"raise",
			"fold",
			"all_in",
			"all_in_react",
			"request",
			"request_done",
			"fast",
			"win",
			"delay",
		]:
			if profile.lines_for(category).is_empty():
				return _fail("%s is missing dialogue category %s." % [profile.id, category])

	var runtime_file := FileAccess.open("res://scripts/gameplay/main_game.gd", FileAccess.READ)
	if runtime_file == null:
		return _fail("Could not inspect Stage 6 runtime.")
	var runtime_text: String = runtime_file.get_as_text()

	for required in [
		"SPEECH_POSITIONS",
		"speech_panels",
		"speech_cooldowns",
		"global_speech_cooldown",
		"_create_speech_bubbles",
		"_try_action_dialogue",
		"_try_fast_service_dialogue",
		"_say_npc",
		"_say_text",
		"_pick_reaction_seat",
		"_update_speech_cooldowns",
		"_say_npc(seat, \"request\", true)",
		"_say_npc(duty.source_seat, \"request_done\", true)",
		"_say_npc(duty.target_seat, \"win\", true)",
	]:
		if not runtime_text.contains(required):
			return _fail("Stage 6 dialogue feature is missing: %s" % required)

	if runtime_text.contains("seat_trait_labels"):
		return _fail("Permanent personality labels should stay removed.")
	if runtime_text.contains("DECK을 탭하면"):
		return _fail("Tutorial copy returned while restoring NPC dialogue.")

	print("LET'S DEALER stage 6 NPC dialogue smoke test passed.")
	return 0


func _fail(message: String) -> int:
	push_error("Stage 6 NPC dialogue smoke test failed: " + message)
	return 1
