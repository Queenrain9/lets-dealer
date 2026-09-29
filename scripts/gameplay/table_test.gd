extends Control

@onready var phase_label: Label = $PhaseLabel
@onready var stats_label: Label = $StatsLabel
@onready var hint_label: Label = $HintLabel
@onready var board_row: HBoxContainer = $TableSurface/BoardRow
@onready var card_drag: DraggableCard = $CardDrag
@onready var start_hand_button: Button = $StartHandButton
@onready var advance_button: Button = $AdvanceButton

var game: DealerGameState = DealerGameState.new()
var seat_views: Array[SeatView] = []

func _ready() -> void:
	var table_config := load("res://data/table_configs/prototype_table.tres") as TableConfig
	if table_config == null:
		push_error("Could not load prototype table configuration.")
		return

	game.configure(table_config)

	seat_views = [
		$TableSurface/Seat0,
		$TableSurface/Seat1,
		$TableSurface/Seat2,
		$TableSurface/Seat3,
	]

	for seat_view in seat_views:
		var seat := game.table.get_seat(seat_view.seat_index)
		seat_view.configure(seat.seat_index, seat.display_name, seat.stack)

	game.phase_changed.connect(_on_phase_changed)
	game.expected_deal_seat_changed.connect(_on_expected_deal_seat_changed)
	game.mistake_recorded.connect(_on_mistake_recorded)
	game.hand_completed.connect(_on_hand_completed)

	card_drag.drag_moved.connect(_on_card_drag_moved)
	card_drag.drag_released.connect(_on_card_released)
	start_hand_button.pressed.connect(_on_start_hand_pressed)
	advance_button.pressed.connect(_on_advance_pressed)

	card_drag.disarm()
	_refresh_ui()
	hint_label.text = "Press START HAND. This scene is a gameplay test, not final UI."

func _on_start_hand_pressed() -> void:
	_clear_hand_visuals()
	game.start_hand()
	_arm_next_card()
	hint_label.text = "Drag the top card to the highlighted seat."
	_refresh_ui()

func _on_advance_pressed() -> void:
	game.advance_prototype_phase()
	_refresh_board()
	_refresh_ui()

	match game.table.hand.phase:
		HandState.Phase.FLOP:
			hint_label.text = "Flop opened. Betting/chip handling is the next milestone."
		HandState.Phase.TURN:
			hint_label.text = "Turn opened."
		HandState.Phase.RIVER:
			hint_label.text = "River opened."
		HandState.Phase.SHOWDOWN:
			hint_label.text = "Showdown hook reached. Hand ranking is still placeholder."
		HandState.Phase.PAYOUT:
			hint_label.text = "Payout hook reached. Manual chip payout comes next."
		HandState.Phase.COMPLETE:
			hint_label.text = "Hand complete. Start the next hand."

func _on_card_drag_moved(pointer_position: Vector2) -> void:
	for seat_view in seat_views:
		seat_view.set_hovered(seat_view.get_drop_rect().has_point(pointer_position))

func _on_card_released(pointer_position: Vector2) -> void:
	var dropped_seat_index := -1

	for seat_view in seat_views:
		seat_view.set_hovered(false)
		if seat_view.get_drop_rect().has_point(pointer_position):
			dropped_seat_index = seat_view.seat_index

	if dropped_seat_index < 0:
		hint_label.text = "Drop the card on a player seat."
	else:
		var dealt := game.try_deal_card_to_seat(dropped_seat_index)
		if dealt:
			var seat := game.table.get_seat(dropped_seat_index)
			seat_views[dropped_seat_index].add_card(seat.hole_cards.back())
			if game.table.hand.phase == HandState.Phase.DEALING:
				hint_label.text = "Good. Continue dealing to the highlighted seat."
			else:
				hint_label.text = "Hole cards complete. Prototype betting phase is ready."

	card_drag.snap_home()
	_arm_next_card()
	_refresh_ui()

func _on_phase_changed(_phase: int) -> void:
	_refresh_ui()

func _on_expected_deal_seat_changed(seat_index: int) -> void:
	for seat_view in seat_views:
		seat_view.set_targeted(seat_view.seat_index == seat_index)

func _on_mistake_recorded(reason: String) -> void:
	hint_label.text = reason

func _on_hand_completed(result: SessionResult) -> void:
	hint_label.text = "Complete in %.1fs · Perfect %d · Mistakes %d · Max combo %d" % [
		result.elapsed_seconds(),
		result.perfect_actions,
		result.mistakes,
		result.max_combo,
	]

func _arm_next_card() -> void:
	if game.table.hand.phase == HandState.Phase.DEALING:
		card_drag.arm(game.peek_next_card())
	else:
		card_drag.disarm()

func _clear_hand_visuals() -> void:
	for seat_view in seat_views:
		seat_view.clear_cards()
		seat_view.set_hovered(false)
		seat_view.set_targeted(false)
	_clear_board()

func _clear_board() -> void:
	for child in board_row.get_children():
		child.queue_free()

func _refresh_board() -> void:
	_clear_board()

	for card_id in game.table.hand.board:
		var card_panel := PanelContainer.new()
		card_panel.custom_minimum_size = Vector2(64, 84)

		var card_label := Label.new()
		card_label.text = card_id
		card_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		card_panel.add_child(card_label)

		board_row.add_child(card_panel)

func _refresh_ui() -> void:
	phase_label.text = "PHASE · " + game.get_phase_label()
	stats_label.text = "Perfect %d   Mistakes %d   Combo x%d" % [
		game.result.perfect_actions,
		game.result.mistakes,
		game.result.combo,
	]

	var phase := game.table.hand.phase
	var can_start := phase == HandState.Phase.IDLE or phase == HandState.Phase.COMPLETE
	start_hand_button.disabled = not can_start
	start_hand_button.text = "NEXT HAND" if phase == HandState.Phase.COMPLETE else "START HAND"

	advance_button.disabled = (
		phase == HandState.Phase.IDLE
		or phase == HandState.Phase.DEALING
		or phase == HandState.Phase.COMPLETE
	)

	if phase == HandState.Phase.DEALING:
		_on_expected_deal_seat_changed(game.expected_deal_seat())
	elif phase != HandState.Phase.IDLE:
		_on_expected_deal_seat_changed(-1)
