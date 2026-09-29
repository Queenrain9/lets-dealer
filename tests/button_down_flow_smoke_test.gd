extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed_scene: PackedScene = load("res://scenes/table_test.tscn") as PackedScene
	if packed_scene == null:
		_fail("table_test.tscn failed to load.")
		return

	var scene: Control = packed_scene.instantiate() as Control
	root.add_child(scene)
	await process_frame

	var game: DealerGameState = scene.get("game") as DealerGameState
	var start_button: Button = scene.get_node("StartHandButton") as Button
	var card_button: DraggableCard = scene.get_node("CardDrag") as DraggableCard

	if game == null or start_button == null or card_button == null:
		_fail("Prototype scene did not initialize expected controls.")
		return

	if game.table.hand.phase != HandState.Phase.IDLE:
		_fail("Expected IDLE before pressing START HAND.")
		return

	start_button.button_down.emit()
	await process_frame

	if game.table.hand.phase != HandState.Phase.DEALING:
		_fail("START HAND button_down did not enter DEALING.")
		return

	if not card_button.visible or card_button.disabled:
		_fail("Card button was not ready after START HAND.")
		return

	card_button.button_down.emit()
	await process_frame

	if game.table.hand.cards_dealt != 1:
		_fail("Card button_down did not deal the first card.")
		return

	print("LET'S DEALER button-down flow smoke test passed.")
	scene.queue_free()
	quit(0)

func _fail(message: String) -> void:
	push_error("LET'S DEALER button-down flow smoke test failed: " + message)
	quit(1)
