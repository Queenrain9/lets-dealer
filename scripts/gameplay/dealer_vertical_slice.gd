extends Control

const BUILD_ID: String = "vertical-slice-003"
const PLAYER_NAMES: Array[String] = ["지민", "맥스", "소연", "토니", "김사장", "찰리"]
const DISPLAY_STACKS: Array[int] = [12500, 8900, 4300, 9600, 6800, 3200]
const WINNER_SEAT_INDEX: int = 2
const SESSION_SECONDS: float = 45.0

@onready var build_label: Label = $TopBar/BuildLabel
@onready var level_label: Label = $TopBar/LevelLabel
@onready var exp_label: Label = $TopBar/ExpLabel
@onready var cash_label: Label = $TopBar/CashLabel
@onready var crown_label: Label = $TopBar/CrownLabel
@onready var mission_label: Label = $MissionPanel/MissionLabel
@onready var mission_value_label: Label = $MissionPanel/MissionValueLabel
@onready var accuracy_label: Label = $StatsBar/AccuracyLabel
@onready var combo_label: Label = $StatsBar/ComboLabel
@onready var timer_label: Label = $StatsBar/TimerLabel
@onready var pot_label: Label = $Table/PotLabel
@onready var board_row: HBoxContainer = $Table/BoardRow
@onready var deal_button: Button = $DealerDock/DealButton
@onready var action_button: Button = $DealerDock/ActionButton
@onready var start_button: Button = $DealerDock/StartButton
@onready var task_log: Label = $TaskLog
@onready var result_panel: PanelContainer = $ResultPanel
@onready var result_title: Label = $ResultPanel/Content/ResultTitle
@onready var result_detail: Label = $ResultPanel/Content/ResultDetail
@onready var next_hand_button: Button = $ResultPanel/Content/NextHandButton

var game: DealerGameState = DealerGameState.new()
var seat_panels: Array[PanelContainer] = []
var seat_name_labels: Array[Label] = []
var seat_stack_labels: Array[Label] = []
var seat_state_labels: Array[Label] = []
var seat_card_a_labels: Array[Label] = []
var seat_card_b_labels: Array[Label] = []
var chip_buttons: Array[Button] = []
var board_card_panels: Array[PanelContainer] = []
var board_card_labels: Array[Label] = []

var session_active: bool = false
var seconds_left: float = SESSION_SECONDS

func _ready() -> void:
	build_label.text = "BUILD · " + BUILD_ID
	_setup_state()
	_cache_seat_nodes()
	_connect_native_inputs()
	_reset_slice()

func _process(delta: float) -> void:
	if not session_active:
		return

	seconds_left = maxf(seconds_left - delta, 0.0)
	timer_label.text = _format_timer(seconds_left)

func _setup_state() -> void:
	var table_config: TableConfig = load(
		"res://data/table_configs/vertical_slice_table.tres"
	) as TableConfig
	var hand_config: PrototypeHandConfig = load(
		"res://data/prototype_hands/vertical_slice_hand_01.tres"
	) as PrototypeHandConfig

	if table_config == null or hand_config == null:
		push_error("Vertical slice configuration failed to load.")
		return

	game.configure(table_config)
	game.configure_prototype_hand(hand_config)
	game.phase_changed.connect(_on_phase_changed)
	game.expected_deal_seat_changed.connect(_on_expected_deal_seat_changed)
	game.betting_ready.connect(_on_betting_ready)
	game.bet_collected.connect(_on_bet_collected)

func _cache_seat_nodes() -> void:
	for index in range(6):
		var seat_root: PanelContainer = get_node("Table/Seat%d" % index) as PanelContainer
		seat_panels.append(seat_root)
		seat_name_labels.append(seat_root.get_node("Content/Name") as Label)
		seat_stack_labels.append(seat_root.get_node("Content/Stack") as Label)
		seat_state_labels.append(seat_root.get_node("Content/State") as Label)
		seat_card_a_labels.append(
			seat_root.get_node("Content/Cards/CardA") as Label
		)
		seat_card_b_labels.append(
			seat_root.get_node("Content/Cards/CardB") as Label
		)
		chip_buttons.append(get_node("Table/Chip%d" % index) as Button)

	for index in range(5):
		var card_panel: PanelContainer = board_row.get_node(
			"Card%d" % index
		) as PanelContainer
		board_card_panels.append(card_panel)
		board_card_labels.append(card_panel.get_node("Label") as Label)

func _connect_native_inputs() -> void:
	start_button.button_down.connect(_start_hand)
	deal_button.button_down.connect(_deal_next_card)
	action_button.button_down.connect(_on_action_button_down)
	next_hand_button.button_down.connect(_start_hand)

	for index in range(chip_buttons.size()):
		chip_buttons[index].button_down.connect(_collect_bet.bind(index))

func _reset_slice() -> void:
	session_active = false
	seconds_left = SESSION_SECONDS
	timer_label.text = _format_timer(seconds_left)
	accuracy_label.text = "정확도 100%"
	combo_label.text = "콤보 x0"
	level_label.text = "LV.12  신뢰받는 딜러"
	exp_label.text = "EXP 420 / 1,000"
	cash_label.text = "12,480"
	crown_label.text = "3,290"

	mission_label.text = "현재 미션"
	mission_value_label.text = "첫 핸드를 시작하세요"
	pot_label.text = "POT 0"
	task_log.text = "□ 카드 딜\n□ 칩 수거\n□ 보드 오픈\n□ 승자 지급"

	start_button.visible = true
	start_button.disabled = false
	deal_button.visible = false
	deal_button.disabled = true
	action_button.visible = false
	action_button.disabled = true
	result_panel.visible = false
	_clear_board()

	for index in range(6):
		seat_name_labels[index].text = PLAYER_NAMES[index]
		seat_stack_labels[index].text = "Stack %s" % _format_number(DISPLAY_STACKS[index])
		seat_state_labels[index].text = "WAIT"
		seat_card_a_labels[index].text = "—"
		seat_card_b_labels[index].text = "—"
		chip_buttons[index].visible = false
		chip_buttons[index].disabled = true
		chip_buttons[index].text = ""
		_set_seat_targeted(index, false)
		_set_seat_winner(index, false)

func _start_hand() -> void:
	_clear_board()
	result_panel.visible = false
	game.start_hand()
	session_active = true
	seconds_left = SESSION_SECONDS
	start_button.visible = false
	start_button.disabled = true
	deal_button.visible = true
	deal_button.disabled = false
	action_button.visible = false
	action_button.disabled = true
	pot_label.text = "POT 0"
	mission_value_label.text = "카드를 정확한 순서로 배분하세요"
	task_log.text = "□ 카드 딜\n□ 칩 수거\n□ 보드 오픈\n□ 승자 지급"

	for index in range(6):
		seat_state_labels[index].text = "WAIT"
		seat_card_a_labels[index].text = "—"
		seat_card_b_labels[index].text = "—"
		chip_buttons[index].visible = false
		chip_buttons[index].disabled = true
		_set_seat_winner(index, false)

	_refresh_hud()

func _deal_next_card() -> void:
	if game.table.hand.phase != HandState.Phase.DEALING:
		return

	var seat_index: int = game.expected_deal_seat()
	if seat_index < 0:
		return

	if not game.try_deal_card_to_seat(seat_index):
		return

	var seat: PlayerSeat = game.table.get_seat(seat_index)
	var card_count: int = seat.hole_cards.size()
	if card_count == 1:
		seat_card_a_labels[seat_index].text = seat.hole_cards[0]
	elif card_count >= 2:
		seat_card_b_labels[seat_index].text = seat.hole_cards[1]

	seat_state_labels[seat_index].text = "DEALT"
	_refresh_hud()

func _collect_bet(seat_index: int) -> void:
	if game.table.hand.phase != HandState.Phase.BETTING_PREFLOP:
		return

	var seat: PlayerSeat = game.table.get_seat(seat_index)
	if seat == null or seat.current_bet <= 0:
		return

	if not game.try_collect_bet_from_seat(seat_index):
		return

	chip_buttons[seat_index].visible = false
	chip_buttons[seat_index].disabled = true
	seat_state_labels[seat_index].text = "COLLECTED"
	pot_label.text = "POT %s" % _format_number(game.table.hand.pot.total_amount())
	_refresh_hud()

func _on_action_button_down() -> void:
	match game.table.hand.phase:
		HandState.Phase.BETTING_PREFLOP:
			if not game.all_bets_collected():
				return
			game.advance_prototype_phase()
			_refresh_board()
		HandState.Phase.FLOP:
			game.advance_prototype_phase()
			_refresh_board()
		HandState.Phase.TURN:
			game.advance_prototype_phase()
			_refresh_board()
		HandState.Phase.RIVER:
			game.advance_prototype_phase()
			_mark_showdown_winner()
		HandState.Phase.SHOWDOWN:
			game.advance_prototype_phase()
		HandState.Phase.PAYOUT:
			game.advance_prototype_phase()
			_finish_slice()
		_:
			pass

	_refresh_hud()

func _on_phase_changed(_phase: int) -> void:
	_refresh_hud()

func _on_expected_deal_seat_changed(seat_index: int) -> void:
	for index in range(6):
		_set_seat_targeted(index, index == seat_index)

func _on_betting_ready() -> void:
	deal_button.visible = false
	deal_button.disabled = true
	mission_value_label.text = "베팅 칩을 POT으로 수거하세요"
	task_log.text = "✓ 카드 딜       +1 콤보\n□ 칩 수거\n□ 보드 오픈\n□ 승자 지급"

	for index in range(6):
		var seat: PlayerSeat = game.table.get_seat(index)
		_set_seat_targeted(index, false)

		if seat.folded:
			seat_state_labels[index].text = "FOLD"
			chip_buttons[index].visible = false
			chip_buttons[index].disabled = true
		elif seat.current_bet > 0:
			seat_state_labels[index].text = "BET %s" % _format_number(seat.current_bet)
			chip_buttons[index].text = _format_number(seat.current_bet)
			chip_buttons[index].visible = true
			chip_buttons[index].disabled = false

	_refresh_hud()

func _on_bet_collected(_seat_index: int, _amount: int, _pot_total: int) -> void:
	if game.all_bets_collected():
		task_log.text = "✓ 카드 딜       +1 콤보\n✓ 칩 수거       +1 콤보\n□ 보드 오픈\n□ 승자 지급"
		mission_value_label.text = "플랍을 오픈하세요"
		action_button.visible = true
		action_button.disabled = false
		action_button.text = "OPEN FLOP"

func _refresh_hud() -> void:
	accuracy_label.text = "정확도 100%"
	combo_label.text = "콤보 x%d" % game.result.combo

	match game.table.hand.phase:
		HandState.Phase.DEALING:
			deal_button.text = "DEAL CARD  %d / 12" % game.table.hand.cards_dealt
		HandState.Phase.BETTING_PREFLOP:
			if game.all_bets_collected():
				action_button.text = "OPEN FLOP"
		HandState.Phase.FLOP:
			mission_value_label.text = "턴 카드를 오픈하세요"
			action_button.visible = true
			action_button.disabled = false
			action_button.text = "OPEN TURN"
			task_log.text = "✓ 카드 딜       +1 콤보\n✓ 칩 수거       +1 콤보\n✓ FLOP 오픈\n□ TURN / RIVER\n□ 승자 지급"
		HandState.Phase.TURN:
			mission_value_label.text = "리버 카드를 오픈하세요"
			action_button.text = "OPEN RIVER"
		HandState.Phase.RIVER:
			mission_value_label.text = "쇼다운을 진행하세요"
			action_button.text = "SHOWDOWN"
			task_log.text = "✓ 카드 딜       +1 콤보\n✓ 칩 수거       +1 콤보\n✓ 보드 5장 오픈\n□ 승자 지급"
		HandState.Phase.SHOWDOWN:
			mission_value_label.text = "%s 승리 · POT을 지급하세요" % PLAYER_NAMES[WINNER_SEAT_INDEX]
			action_button.text = "PAY %s" % _format_number(game.table.hand.pot.total_amount())
		HandState.Phase.PAYOUT:
			mission_value_label.text = "%s에게 %s 지급" % [
				PLAYER_NAMES[WINNER_SEAT_INDEX],
				_format_number(game.table.hand.pot.total_amount()),
			]
			action_button.text = "CONFIRM PAYOUT"
		HandState.Phase.COMPLETE:
			action_button.visible = false
			action_button.disabled = true
		_:
			pass

func _refresh_board() -> void:
	_clear_board()
	for index in range(game.table.hand.board.size()):
		if index >= board_card_panels.size():
			break
		board_card_panels[index].visible = true
		board_card_labels[index].text = game.table.hand.board[index]

func _clear_board() -> void:
	for index in range(board_card_panels.size()):
		board_card_panels[index].visible = false
		board_card_labels[index].text = ""

func _mark_showdown_winner() -> void:
	for index in range(6):
		_set_seat_winner(index, index == WINNER_SEAT_INDEX)
		seat_state_labels[index].text = "WIN" if index == WINNER_SEAT_INDEX else "SHOW"

func _finish_slice() -> void:
	session_active = false
	task_log.text = "✓ 카드 딜\n✓ 칩 수거\n✓ 보드 오픈\n✓ 승자 지급      PERFECT!"
	result_title.text = "PERFECT  x%d" % game.result.max_combo
	result_detail.text = "정확도 100%   ·   TIP +200   ·   EXP +2,300\n%s에게 %s 지급 완료" % [
		PLAYER_NAMES[WINNER_SEAT_INDEX],
		_format_number(game.table.hand.pot.total_amount()),
	]
	result_panel.visible = true
	next_hand_button.text = "NEXT HAND"
	mission_value_label.text = "핸드 완료 · 다음 테이블을 준비하세요"

func _set_seat_targeted(index: int, targeted: bool) -> void:
	var panel: PanelContainer = seat_panels[index]
	var style: StyleBoxFlat = _make_seat_style(
		Color(0.13, 0.16, 0.21, 0.98),
		Color(0.96, 0.72, 0.25, 1.0) if targeted else Color(0.31, 0.35, 0.42, 1.0),
		4 if targeted else 2
	)
	panel.add_theme_stylebox_override("panel", style)

func _set_seat_winner(index: int, winner: bool) -> void:
	if winner:
		seat_panels[index].add_theme_stylebox_override(
			"panel",
			_make_seat_style(
				Color(0.24, 0.17, 0.08, 0.98),
				Color(1.0, 0.74, 0.18, 1.0),
				4
			)
		)

func _make_seat_style(
	background: Color,
	border: Color,
	border_width: int
) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	return style

func _format_number(value: int) -> String:
	var raw: String = str(value)
	var result: String = ""
	var count: int = 0
	for index in range(raw.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = raw[index] + result
		count += 1
	return result

func _format_timer(value: float) -> String:
	var seconds: int = int(ceil(value))
	return "00:%02d" % seconds
