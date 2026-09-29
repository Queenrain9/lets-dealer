extends Control

const MIN_CARD_SWIPE_DISTANCE: float = 42.0
const MIN_CARD_DIRECTION_SCORE: float = 0.35
const MIN_CHIP_SWEEP_DISTANCE: float = 34.0
const MIN_CHIP_DIRECTION_SCORE: float = 0.25

@onready var phase_label: Label = $PhaseLabel
@onready var stats_label: Label = $StatsLabel
@onready var hint_label: Label = $HintLabel
@onready var board_row: HBoxContainer = $TableSurface/BoardRow
@onready var pot_label: Label = $TableSurface/PotLabel
@onready var card_drag: DraggableCard = $CardDrag
@onready var start_hand_button: Button = $StartHandButton
@onready var advance_button: Button = $AdvanceButton

var game: DealerGameState = DealerGameState.new()
var seat_views: Array[SeatView] = []
var card_zone_panels: Array[Control] = []
var card_rows: Array[HBoxContainer] = []
var chip_stacks: Array[SwipeChipStack] = []

func _ready() -> void:
	var table_config: TableConfig = load("res://data/table_configs/prototype_table.tres") as TableConfig
	var hand_config: PrototypeHandConfig = load(
		"res://data/prototype_hands/core_hand_01.tres"
	) as PrototypeHandConfig

	if table_config == null or hand_config == null:
		push_error("Could not load prototype gameplay configuration.")
		return

	game.configure(table_config)
	game.configure_prototype_hand(hand_config)

	seat_views = [
		$TableSurface/Seat0,
		$TableSurface/Seat1,
		$TableSurface/Seat2,
		$TableSurface/Seat3,
	]

	card_zone_panels = [
		$TableSurface/CardZone0,
		$TableSurface/CardZone1,
		$TableSurface/CardZone2,
		$TableSurface/CardZone3,
	]

	card_rows = [
		$TableSurface/CardZone0/Cards,
		$TableSurface/CardZone1/Cards,
		$TableSurface/CardZone2/Cards,
		$TableSurface/CardZone3/Cards,
	]

	chip_stacks = [
		$TableSurface/ChipStack0,
		$TableSurface/ChipStack1,
		$TableSurface/ChipStack2,
		$TableSurface/ChipStack3,
	]

	for seat_view in seat_views:
		var seat: PlayerSeat = game.table.get_seat(seat_view.seat_index)
		seat_view.configure(seat.seat_index, seat.display_name, seat.stack)

	for chip_stack in chip_stacks:
		chip_stack.sweep_released.connect(_on_chip_sweep_released)

	game.phase_changed.connect(_on_phase_changed)
	game.expected_deal_seat_changed.connect(_on_expected_deal_seat_changed)
	game.betting_ready.connect(_on_betting_ready)
	game.bet_collected.connect(_on_bet_collected)
	game.mistake_recorded.connect(_on_mistake_recorded)
	game.hand_completed.connect(_on_hand_completed)

	card_drag.swipe_released.connect(_on_card_swipe_released)
	start_hand_button.pressed.connect(_on_start_hand_pressed)
	advance_button.pressed.connect(_on_advance_pressed)

	card_drag.disarm()
	for chip_stack in chip_stacks:
		chip_stack.disarm()

	_refresh_pot()
	_refresh_ui()
	hint_label.text = "Press START HAND. This scene is a gameplay test, not final UI."

func _on_start_hand_pressed() -> void:
	_clear_hand_visuals()
	game.start_hand()
	_arm_next_card()
	hint_label.text = "Swipe the card toward the highlighted player."
	_refresh_all_seat_views()
	_refresh_pot()
	_refresh_ui()

func _on_advance_pressed() -> void:
	if not game.advance_prototype_phase():
		if game.table.hand.phase == HandState.Phase.BETTING_PREFLOP:
			hint_label.text = "Collect every betting stack into the pot first."
		_refresh_ui()
		return

	_refresh_board()
	_refresh_ui()

	match game.table.hand.phase:
		HandState.Phase.FLOP:
			hint_label.text = "Flop opened. Postflop betting is still placeholder."
		HandState.Phase.TURN:
			hint_label.text = "Turn opened."
		HandState.Phase.RIVER:
			hint_label.text = "River opened."
		HandState.Phase.SHOWDOWN:
			hint_label.text = "Showdown hook reached. Hand ranking is still placeholder."
		HandState.Phase.PAYOUT:
			hint_label.text = "Payout hook reached. Manual pot payout comes next."
		HandState.Phase.COMPLETE:
			hint_label.text = "Hand complete. Start the next hand."

func _on_card_swipe_released(start_position: Vector2, end_position: Vector2) -> void:
	if game.table.hand.phase != HandState.Phase.DEALING:
		card_drag.snap_home()
		return

	var swipe_delta: Vector2 = end_position - start_position
	if swipe_delta.length() < MIN_CARD_SWIPE_DISTANCE:
		card_drag.snap_home()
		hint_label.text = "Use a short swipe toward the highlighted player."
		return

	var target_seat_index: int = _resolve_card_swipe_target(start_position, end_position)
	if target_seat_index < 0:
		card_drag.snap_home()
		hint_label.text = "Swipe toward a player, then release."
		return

	var dealt: bool = game.try_deal_card_to_seat(target_seat_index)
	if not dealt:
		card_drag.snap_home()
		_refresh_ui()
		return

	var seat: PlayerSeat = game.table.get_seat(target_seat_index)
	var dealt_card_id: String = String(seat.hole_cards.back())
	var flight_start: Vector2 = card_drag.global_position

	card_drag.snap_home()
	_arm_next_card()
	_animate_dealt_card_to_zone(target_seat_index, dealt_card_id, flight_start)

	if game.table.hand.phase == HandState.Phase.DEALING:
		hint_label.text = "Good. Swipe the next card toward the highlighted player."

	_refresh_ui()

func _on_betting_ready() -> void:
	_refresh_all_seat_views()
	_refresh_pot()

	for seat_index in range(chip_stacks.size()):
		var seat: PlayerSeat = game.table.get_seat(seat_index)
		chip_stacks[seat_index].arm(seat.current_bet)

	hint_label.text = "Bets are in. Sweep each chip stack toward the center pot."
	_refresh_ui()

func _on_chip_sweep_released(
	seat_index: int,
	start_position: Vector2,
	end_position: Vector2
) -> void:
	if game.table.hand.phase != HandState.Phase.BETTING_PREFLOP:
		return

	var chip_stack: SwipeChipStack = chip_stacks[seat_index]
	var sweep_delta: Vector2 = end_position - start_position

	if sweep_delta.length() < MIN_CHIP_SWEEP_DISTANCE:
		chip_stack.snap_home()
		hint_label.text = "Sweep the chips toward the center pot."
		return

	var pot_center: Vector2 = pot_label.get_global_rect().get_center()
	var target_vector: Vector2 = pot_center - start_position

	if target_vector.length_squared() <= 0.001:
		chip_stack.snap_home()
		return

	var direction_score: float = sweep_delta.normalized().dot(target_vector.normalized())
	if direction_score < MIN_CHIP_DIRECTION_SCORE:
		chip_stack.snap_home()
		hint_label.text = "Move that betting stack toward POT."
		return

	var seat: PlayerSeat = game.table.get_seat(seat_index)
	var amount: int = seat.current_bet
	var flight_start: Vector2 = chip_stack.global_position

	if not game.try_collect_bet_from_seat(seat_index):
		chip_stack.snap_home()
		return

	chip_stack.disarm()
	_animate_chip_to_pot(amount, flight_start)
	_refresh_all_seat_views()
	_refresh_pot()
	_refresh_ui()

func _on_bet_collected(_seat_index: int, _amount: int, pot_total: int) -> void:
	if game.all_bets_collected():
		hint_label.text = "Pot complete: %d. Open the flop." % pot_total
	else:
		hint_label.text = "Good. Collect the remaining betting stacks."

func _resolve_card_swipe_target(start_position: Vector2, end_position: Vector2) -> int:
	var swipe_vector: Vector2 = end_position - start_position
	if swipe_vector.length() < MIN_CARD_SWIPE_DISTANCE:
		return -1

	var swipe_direction: Vector2 = swipe_vector.normalized()
	var best_index: int = -1
	var best_score: float = -1.0

	for index in range(card_zone_panels.size()):
		var zone: Control = card_zone_panels[index]
		var target_vector: Vector2 = zone.get_global_rect().get_center() - start_position
		if target_vector.length_squared() <= 0.001:
			continue

		var score: float = swipe_direction.dot(target_vector.normalized())
		if score > best_score:
			best_score = score
			best_index = index

	if best_score < MIN_CARD_DIRECTION_SCORE:
		return -1

	return best_index

func _animate_dealt_card_to_zone(
	seat_index: int,
	card_id: String,
	start_global_position: Vector2
) -> void:
	var zone: Control = card_zone_panels[seat_index]
	var flying_card: PanelContainer = _build_card_panel(card_id, card_drag.size)
	add_child(flying_card)
	flying_card.z_index = 19
	flying_card.global_position = start_global_position

	var target_center: Vector2 = zone.get_global_rect().get_center()
	var target_position: Vector2 = target_center - (flying_card.size * 0.5)

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(flying_card, "global_position", target_position, 0.13)
	tween.finished.connect(
		_finish_dealt_card_animation.bind(flying_card, seat_index, card_id),
		CONNECT_ONE_SHOT
	)

func _finish_dealt_card_animation(
	flying_card: Control,
	seat_index: int,
	card_id: String
) -> void:
	if is_instance_valid(flying_card):
		flying_card.queue_free()
	_add_card_to_zone(seat_index, card_id)

func _animate_chip_to_pot(amount: int, start_global_position: Vector2) -> void:
	var flying_chip: PanelContainer = _build_chip_panel(amount)
	add_child(flying_chip)
	flying_chip.z_index = 18
	flying_chip.global_position = start_global_position

	var target_center: Vector2 = pot_label.get_global_rect().get_center()
	var target_position: Vector2 = target_center - (flying_chip.size * 0.5)

	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(flying_chip, "global_position", target_position, 0.14)
	tween.finished.connect(flying_chip.queue_free, CONNECT_ONE_SHOT)

func _add_card_to_zone(seat_index: int, card_id: String) -> void:
	var card_panel: PanelContainer = _build_card_panel(card_id, Vector2(44, 58))
	card_rows[seat_index].add_child(card_panel)

func _build_card_panel(card_id: String, card_size: Vector2) -> PanelContainer:
	var card_panel: PanelContainer = PanelContainer.new()
	card_panel.custom_minimum_size = card_size
	card_panel.size = card_size
	card_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var card_style: StyleBoxFlat = StyleBoxFlat.new()
	card_style.bg_color = Color(0.94, 0.94, 0.91, 1.0)
	card_style.border_width_left = 2
	card_style.border_width_top = 2
	card_style.border_width_right = 2
	card_style.border_width_bottom = 2
	card_style.border_color = Color(0.2, 0.22, 0.26, 1.0)
	card_style.corner_radius_top_left = 7
	card_style.corner_radius_top_right = 7
	card_style.corner_radius_bottom_left = 7
	card_style.corner_radius_bottom_right = 7
	card_panel.add_theme_stylebox_override("panel", card_style)

	var card_label: Label = Label.new()
	card_label.text = card_id
	card_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card_label.add_theme_color_override("font_color", Color(0.08, 0.09, 0.11, 1.0))
	card_panel.add_child(card_label)

	return card_panel

func _build_chip_panel(amount: int) -> PanelContainer:
	var chip_panel: PanelContainer = PanelContainer.new()
	chip_panel.custom_minimum_size = Vector2(70, 46)
	chip_panel.size = Vector2(70, 46)
	chip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var chip_style: StyleBoxFlat = StyleBoxFlat.new()
	chip_style.bg_color = Color(0.62, 0.16, 0.15, 1.0)
	chip_style.border_width_left = 3
	chip_style.border_width_top = 3
	chip_style.border_width_right = 3
	chip_style.border_width_bottom = 3
	chip_style.border_color = Color(0.95, 0.75, 0.45, 1.0)
	chip_style.corner_radius_top_left = 22
	chip_style.corner_radius_top_right = 22
	chip_style.corner_radius_bottom_left = 22
	chip_style.corner_radius_bottom_right = 22
	chip_panel.add_theme_stylebox_override("panel", chip_style)

	var amount_label: Label = Label.new()
	amount_label.text = str(amount)
	amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	amount_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	chip_panel.add_child(amount_label)
	return chip_panel

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

	for card_row in card_rows:
		for child in card_row.get_children():
			child.queue_free()

	for chip_stack in chip_stacks:
		chip_stack.disarm()

	_clear_board()

func _clear_board() -> void:
	for child in board_row.get_children():
		child.queue_free()

func _refresh_board() -> void:
	_clear_board()

	for card_id in game.table.hand.board:
		var card_panel: PanelContainer = PanelContainer.new()
		card_panel.custom_minimum_size = Vector2(64, 84)

		var card_label: Label = Label.new()
		card_label.text = card_id
		card_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		card_panel.add_child(card_label)

		board_row.add_child(card_panel)

func _refresh_all_seat_views() -> void:
	for seat_view in seat_views:
		var seat: PlayerSeat = game.table.get_seat(seat_view.seat_index)
		seat_view.configure(seat.seat_index, seat.display_name, seat.stack)

func _refresh_pot() -> void:
	pot_label.text = "POT  %d" % game.table.hand.pot.total_amount()

func _refresh_ui() -> void:
	phase_label.text = "PHASE · " + game.get_phase_label()
	stats_label.text = "Perfect %d   Mistakes %d   Combo x%d" % [
		game.result.perfect_actions,
		game.result.mistakes,
		game.result.combo,
	]

	var phase: HandState.Phase = game.table.hand.phase
	var can_start: bool = phase == HandState.Phase.IDLE or phase == HandState.Phase.COMPLETE
	start_hand_button.disabled = not can_start
	start_hand_button.text = "NEXT HAND" if phase == HandState.Phase.COMPLETE else "START HAND"

	match phase:
		HandState.Phase.BETTING_PREFLOP:
			advance_button.text = "OPEN FLOP"
			advance_button.disabled = not game.all_bets_collected()
		HandState.Phase.FLOP:
			advance_button.text = "OPEN TURN"
			advance_button.disabled = false
		HandState.Phase.TURN:
			advance_button.text = "OPEN RIVER"
			advance_button.disabled = false
		HandState.Phase.RIVER:
			advance_button.text = "SHOWDOWN"
			advance_button.disabled = false
		HandState.Phase.SHOWDOWN:
			advance_button.text = "PAYOUT"
			advance_button.disabled = false
		HandState.Phase.PAYOUT:
			advance_button.text = "END HAND"
			advance_button.disabled = false
		_:
			advance_button.text = "ADVANCE PHASE"
			advance_button.disabled = true

	if phase == HandState.Phase.DEALING:
		_on_expected_deal_seat_changed(game.expected_deal_seat())
	elif phase != HandState.Phase.IDLE:
		_on_expected_deal_seat_changed(-1)
