extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed_scene: PackedScene = load("res://scenes/table_test.tscn") as PackedScene
	if packed_scene == null:
		_fail("table_test.tscn failed to load.")
		return

	var scene: Node = packed_scene.instantiate()
	root.add_child(scene)
	await process_frame

	var card: Control = scene.get_node_or_null("CardDrag") as Control
	if card == null:
		_fail("CardDrag node was not found.")
		return

	var expected_position := Vector2(318.0, 976.0)
	if card.position.distance_to(expected_position) > 1.0:
		_fail(
			"CardDrag home position moved during initialization. Expected %s, got %s."
			% [expected_position, card.position]
		)
		return

	print("LET'S DEALER UI card home smoke test passed.")
	scene.queue_free()
	quit(0)

func _fail(message: String) -> void:
	push_error("LET'S DEALER UI smoke test failed: " + message)
	quit(1)
