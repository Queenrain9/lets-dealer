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

	scene.call("_on_start_hand_pressed")
	await process_frame

	var game: DealerGameState = scene.get("game") as DealerGameState
	var card: DraggableCard = scene.get_node("CardDrag") as DraggableCard
	if game == null or card == null:
		_fail("Prototype scene did not initialize.")
		return

	var start_position: Vector2 = card.global_position + (card.size * 0.5)

	# Intentionally swipe sideways. Dealing should still go to the expected seat:
	# the gesture is tactile intent, not an aiming challenge.
	scene.call(
		"_on_card_swipe_released",
		start_position,
		start_position + Vector2(100.0, 0.0)
	)
	await process_frame

	if game.table.hand.cards_dealt != 1:
		_fail("A deliberate swipe did not deal the first card.")
		return

	if game.expected_deal_seat() != 1:
		_fail("Deal order did not advance to the second seat.")
		return

	if not card.visible:
		_fail("Next card was not immediately ready after the first swipe.")
		return

	if card.get_input_rect().size.x <= 0.0 or card.get_input_rect().size.y <= 0.0:
		_fail("Next card lost its pointer hit area after the first swipe.")
		return

	print("LET'S DEALER forgiving card gesture smoke test passed.")
	scene.queue_free()
	quit(0)

func _fail(message: String) -> void:
	push_error("LET'S DEALER forgiving card gesture smoke test failed: " + message)
	quit(1)
