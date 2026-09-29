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
	var zones: Array[Control] = scene.get("card_zone_panels") as Array[Control]

	if game == null or card == null or zones.is_empty():
		_fail("Prototype scene did not initialize expected gameplay references.")
		return

	for deal_index in range(2):
		var expected_seat: int = game.expected_deal_seat()
		if expected_seat < 0:
			_fail("Expected seat was invalid before deal %d." % (deal_index + 1))
			return

		var start_position: Vector2 = card.global_position + (card.size * 0.5)
		var target_position: Vector2 = zones[expected_seat].get_global_rect().get_center()
		var swipe_direction: Vector2 = (target_position - start_position).normalized()
		var end_position: Vector2 = start_position + (swipe_direction * 120.0)

		scene.call("_on_card_swipe_released", start_position, end_position)
		await process_frame

		if game.table.hand.cards_dealt != deal_index + 1:
			_fail(
				"Deal %d did not advance. cards_dealt=%d."
				% [deal_index + 1, game.table.hand.cards_dealt]
			)
			return

		if not card.visible:
			_fail("Card source disappeared after deal %d." % (deal_index + 1))
			return

		if card.mouse_filter != Control.MOUSE_FILTER_STOP:
			_fail("Card source did not re-enable input after deal %d." % (deal_index + 1))
			return

	print("LET'S DEALER repeated deal UI smoke test passed.")
	scene.queue_free()
	quit(0)

func _fail(message: String) -> void:
	push_error("LET'S DEALER repeated deal UI smoke test failed: " + message)
	quit(1)
