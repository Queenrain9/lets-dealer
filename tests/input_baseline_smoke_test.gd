extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed: PackedScene = load("res://scenes/input_baseline.tscn") as PackedScene
	if packed == null:
		_fail("input baseline scene failed to load.")
		return

	var scene: Control = packed.instantiate() as Control
	root.add_child(scene)
	await process_frame

	var start: Button = scene.get_node("StartHandButton") as Button
	var card: Button = scene.get_node("CardButton") as Button
	var chip20: Button = scene.get_node("Table/Chip20Button") as Button
	var chip40a: Button = scene.get_node("Table/Chip40AButton") as Button
	var chip40b: Button = scene.get_node("Table/Chip40BButton") as Button
	var flop: Button = scene.get_node("OpenFlopButton") as Button
	var phase_label: Label = scene.get_node("PhaseLabel") as Label
	var pot_label: Label = scene.get_node("Table/PotLabel") as Label
	var build_label: Label = scene.get_node("BuildLabel") as Label

	if build_label.text != "BUILD · input-baseline-001":
		_fail("build stamp mismatch.")
		return

	start.button_down.emit()
	await process_frame
	if phase_label.text != "PHASE · DEALING":
		_fail("START HAND did not enter DEALING.")
		return

	for _i in range(8):
		card.button_down.emit()
		await process_frame

	if phase_label.text != "PHASE · COLLECT BETS":
		_fail("8 card actions did not enter COLLECT BETS.")
		return

	chip20.button_down.emit()
	chip40a.button_down.emit()
	chip40b.button_down.emit()
	await process_frame

	if pot_label.text != "POT 100":
		_fail("chip buttons did not produce POT 100.")
		return

	if phase_label.text != "PHASE · FLOP READY":
		_fail("pot completion did not enter FLOP READY.")
		return

	flop.button_down.emit()
	await process_frame
	if phase_label.text != "PHASE · FLOP":
		_fail("OPEN FLOP did not enter FLOP.")
		return

	print("LET'S DEALER input baseline smoke test passed.")
	scene.queue_free()
	quit(0)

func _fail(message: String) -> void:
	push_error("LET'S DEALER input baseline smoke test failed: " + message)
	quit(1)
