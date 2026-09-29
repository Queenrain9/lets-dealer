extends Control

const BUILD_ID: String = "live-shift-stage2-v0.4"

const BG: Color = Color("0d1218")
const PANEL: Color = Color("171e27")
const PANEL_2: Color = Color("202936")
const FELT: Color = Color("163d33")
const FELT_2: Color = Color("1c4a3e")
const LINE: Color = Color("465466")
const ACCENT: Color = Color("e9b64c")
const TEXT: Color = Color("f3f5f7")
const MUTED: Color = Color("9aa7b6")
const GOOD: Color = Color("5bd28d")
const BAD: Color = Color("ff6d72")
const INFO: Color = Color("67a8ff")
const PURPLE: Color = Color("a77fe8")

const PLAYER_NAMES: Array[String] = ["지민", "맥스", "소연", "토니", "김사장", "찰리"]
const PLAYER_STACKS: Array[int] = [12500, 8900, 4300, 9600, 6800, 3200]
const SEAT_POSITIONS: Array[Vector2] = [
	Vector2(22, 390),
	Vector2(74, 174),
	Vector2(250, 112),
	Vector2(426, 174),
	Vector2(478, 390),
	Vector2(250, 510),
]
const BET_POSITIONS: Array[Vector2] = [
	Vector2(142, 412),
	Vector2(175, 286),
	Vector2(284, 250),
	Vector2(392, 286),
	Vector2(425, 412),
	Vector2(284, 484),
]
const ACTION_ORDER: Array[String] = ["deal", "pot", "board", "chip_change", "payout", "floor"]
const ACTION_LABELS: Dictionary = {
	"deal": "DEAL",
	"pot": "POT",
	"board": "BOARD",
	"chip_change": "CHANGE",
	"payout": "PAYOUT",
	"floor": "FLOOR",
}
const STREET_ORDER: Array[String] = ["preflop", "flop", "turn", "river"]

var hands: Array[Dictionary] = []
var hand_index: int = -1
var street_index: int = 0
var shift_elapsed: float = 0.0
var street_elapsed: float = 0.0
var session_active: bool = false
var resolving: bool = false
var betting_running: bool = false
var payout_targeting: bool = false

var pending_duties: Array[DealerTask] = []
var scheduled_events: Array[Dictionary] = []
var active_payout_duty: DealerTask

var correct_actions: int = 0
var mistakes: int = 0
var flow_combo: int = 0
var max_flow_combo: int = 0
var tips: int = 0
var cash: int = 12480

var home_layer: Control
var game_layer: Control
var complete_layer: Control

var level_label: Label
var cash_label: Label
var rep_label: Label
var accuracy_label: Label
var flow_label: Label
var timer_label: Label

var phase_label: Label
var headline_label: Label
var event_label: Label
var pressure_label: Label
var feedback_label: Label
var tool_mode_label: Label

var table: Panel
var pot_panel: Panel
var main_pot_label: Label
var side_pot_label: Label
var request_panel: Panel
var request_label: Label
var showdown_panel: Panel
var showdown_label: Label

var seat_panels: Array[Panel] = []
var seat_name_labels: Array[Label] = []
var seat_stack_labels: Array[Label] = []
var seat_state_labels: Array[Label] = []
var bet_panels: Array[Panel] = []
var bet_labels: Array[Label] = []
var board_panels: Array[Panel] = []
var board_labels: Array[Label] = []
var seat_hit_buttons: Array[Button] = []

var action_buttons: Dictionary = {}
var history_labels: Array[Label] = []


func _ready() -> void:
	_build_ui()
	_show_home()


func _process(delta: float) -> void:
	if not session_active:
		return

	shift_elapsed += delta
	_refresh_shift_clock()
	_age_pending_duties(delta)

	if betting_running:
		street_elapsed += delta
		_process_scheduled_events()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	_build_top_bar()
	_build_home()
	_build_game()
	_build_complete()
	_build_feedback()


func _build_top_bar() -> void:
	var top := Panel.new()
	top.position = Vector2(18, 16)
	top.size = Vector2(684, 76)
	top.add_theme_stylebox_override("panel", _style(PANEL, LINE, 1, 15))
	add_child(top)

	var title := Label.new()
	title.position = Vector2(16, 8)
	title.size = Vector2(180, 25)
	title.text = "LET'S DEALER"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", TEXT)
	top.add_child(title)

	level_label = Label.new()
	level_label.position = Vector2(16, 39)
	level_label.size = Vector2(220, 22)
	level_label.text = "LV.1  신입 딜러"
	level_label.add_theme_font_size_override("font_size", 13)
	level_label.add_theme_color_override("font_color", MUTED)
	top.add_child(level_label)

	cash_label = Label.new()
	cash_label.position = Vector2(234, 13)
	cash_label.size = Vector2(140, 22)
	cash_label.text = "TIP  12,480"
	cash_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cash_label.add_theme_color_override("font_color", ACCENT)
	top.add_child(cash_label)

	rep_label = Label.new()
	rep_label.position = Vector2(234, 42)
	rep_label.size = Vector2(140, 20)
	rep_label.text = "REP  120"
	rep_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rep_label.add_theme_color_override("font_color", MUTED)
	top.add_child(rep_label)

	accuracy_label = Label.new()
	accuracy_label.position = Vector2(382, 10)
	accuracy_label.size = Vector2(94, 24)
	accuracy_label.text = "ACC 100%"
	accuracy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	accuracy_label.add_theme_color_override("font_color", TEXT)
	top.add_child(accuracy_label)

	flow_label = Label.new()
	flow_label.position = Vector2(480, 10)
	flow_label.size = Vector2(105, 24)
	flow_label.text = "FLOW x0"
	flow_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	flow_label.add_theme_color_override("font_color", ACCENT)
	top.add_child(flow_label)

	timer_label = Label.new()
	timer_label.position = Vector2(592, 9)
	timer_label.size = Vector2(74, 50)
	timer_label.text = "00:00"
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	timer_label.add_theme_font_size_override("font_size", 16)
	timer_label.add_theme_color_override("font_color", GOOD)
	top.add_child(timer_label)


func _build_home() -> void:
	home_layer = Control.new()
	home_layer.position = Vector2(0, 104)
	home_layer.size = Vector2(720, 1176)
	add_child(home_layer)

	var hero := Panel.new()
	hero.position = Vector2(24, 34)
	hero.size = Vector2(672, 466)
	hero.add_theme_stylebox_override("panel", _style(PANEL, LINE, 1, 24))
	home_layer.add_child(hero)

	var badge := Label.new()
	badge.position = Vector2(24, 22)
	badge.size = Vector2(620, 26)
	badge.text = "ROOKIE HALL · LIVE SHIFT"
	badge.add_theme_color_override("font_color", ACCENT)
	badge.add_theme_font_size_override("font_size", 13)
	hero.add_child(badge)

	var h1 := Label.new()
	h1.position = Vector2(24, 76)
	h1.size = Vector2(620, 105)
	h1.text = "테이블은 당신을\n기다려주지 않습니다"
	h1.add_theme_font_size_override("font_size", 31)
	h1.add_theme_color_override("font_color", TEXT)
	hero.add_child(h1)

	var desc := Label.new()
	desc.position = Vector2(24, 198)
	desc.size = Vector2(620, 110)
	desc.text = "손님들은 자동으로 Fold / Call / Raise / All-in 합니다.\n요청도 끼어듭니다. 테이블을 보고 필요한 업무를 직접 처리하세요."
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 16)
	desc.add_theme_color_override("font_color", MUTED)
	hero.add_child(desc)

	var start := Button.new()
	start.position = Vector2(24, 350)
	start.size = Vector2(624, 80)
	start.text = "LIVE SHIFT 시작"
	start.add_theme_font_size_override("font_size", 20)
	start.add_theme_stylebox_override("normal", _style(ACCENT, ACCENT, 0, 16))
	start.add_theme_color_override("font_color", Color("261b08"))
	start.pressed.connect(_start_shift)
	hero.add_child(start)

	var info := Panel.new()
	info.position = Vector2(24, 528)
	info.size = Vector2(672, 330)
	info.add_theme_stylebox_override("panel", _style(PANEL, LINE, 1, 20))
	home_layer.add_child(info)

	var ititle := Label.new()
	ititle.position = Vector2(20, 18)
	ititle.size = Vector2(620, 28)
	ititle.text = "이번 버전의 변화"
	ititle.add_theme_font_size_override("font_size", 18)
	ititle.add_theme_color_override("font_color", TEXT)
	info.add_child(ititle)

	var lines: Array[String] = [
		"3 HAND가 한 근무 안에서 자동으로 이어짐",
		"NPC 액션이 실시간으로 진행됨",
		"칩 교환 요청과 베팅 정리가 겹칠 수 있음",
		"늦으면 손님이 재촉하고 FLOW가 끊김",
		"정답 버튼이 아니라 DEALER TOOLS로 직접 운영",
	]
	for i in range(lines.size()):
		var item := Label.new()
		item.position = Vector2(22, 68 + i * 48)
		item.size = Vector2(620, 34)
		item.text = "•  " + lines[i]
		item.add_theme_font_size_override("font_size", 14)
		item.add_theme_color_override("font_color", ACCENT if i == 0 else MUTED)
		info.add_child(item)


func _build_game() -> void:
	game_layer = Control.new()
	game_layer.position = Vector2(0, 104)
	game_layer.size = Vector2(720, 1176)
	game_layer.visible = false
	add_child(game_layer)

	_build_table_status()
	_build_table()
	_build_tool_panel()
	_build_history_panel()


func _build_table_status() -> void:
	var status := Panel.new()
	status.position = Vector2(24, 10)
	status.size = Vector2(672, 108)
	status.add_theme_stylebox_override("panel", _style(PANEL, INFO, 2, 17))
	game_layer.add_child(status)

	phase_label = Label.new()
	phase_label.position = Vector2(18, 10)
	phase_label.size = Vector2(170, 22)
	phase_label.text = "HAND 1 / 3"
	phase_label.add_theme_color_override("font_color", INFO)
	phase_label.add_theme_font_size_override("font_size", 12)
	status.add_child(phase_label)

	pressure_label = Label.new()
	pressure_label.position = Vector2(470, 10)
	pressure_label.size = Vector2(184, 22)
	pressure_label.text = "TABLE CLEAR"
	pressure_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pressure_label.add_theme_color_override("font_color", GOOD)
	pressure_label.add_theme_font_size_override("font_size", 12)
	status.add_child(pressure_label)

	headline_label = Label.new()
	headline_label.position = Vector2(18, 34)
	headline_label.size = Vector2(636, 28)
	headline_label.text = ""
	headline_label.add_theme_font_size_override("font_size", 17)
	headline_label.add_theme_color_override("font_color", TEXT)
	status.add_child(headline_label)

	event_label = Label.new()
	event_label.position = Vector2(18, 67)
	event_label.size = Vector2(636, 30)
	event_label.text = ""
	event_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	event_label.add_theme_font_size_override("font_size", 13)
	event_label.add_theme_color_override("font_color", MUTED)
	status.add_child(event_label)


func _build_table() -> void:
	table = Panel.new()
	table.position = Vector2(34, 134)
	table.size = Vector2(652, 628)
	table.add_theme_stylebox_override("panel", _style(FELT, Color("755b32"), 6, 54))
	game_layer.add_child(table)

	for i in range(6):
		_create_seat(i)

	_create_board()
	_create_pots()
	_create_request_panel()
	_create_showdown_panel()
	_create_bets()


func _create_seat(index: int) -> void:
	var seat := Panel.new()
	seat.position = SEAT_POSITIONS[index]
	seat.size = Vector2(154, 104)
	seat.add_theme_stylebox_override("panel", _style(PANEL, LINE, 2, 14))
	table.add_child(seat)
	seat_panels.append(seat)

	var name_label := Label.new()
	name_label.position = Vector2(8, 7)
	name_label.size = Vector2(138, 23)
	name_label.text = PLAYER_NAMES[index]
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 15)
	name_label.add_theme_color_override("font_color", TEXT)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	seat.add_child(name_label)
	seat_name_labels.append(name_label)

	var stack_label := Label.new()
	stack_label.position = Vector2(8, 30)
	stack_label.size = Vector2(138, 22)
	stack_label.text = _format_amount(PLAYER_STACKS[index])
	stack_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stack_label.add_theme_font_size_override("font_size", 13)
	stack_label.add_theme_color_override("font_color", ACCENT)
	stack_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	seat.add_child(stack_label)
	seat_stack_labels.append(stack_label)

	var state_label := Label.new()
	state_label.position = Vector2(8, 56)
	state_label.size = Vector2(138, 38)
	state_label.text = "WAIT"
	state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	state_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	state_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	state_label.add_theme_font_size_override("font_size", 12)
	state_label.add_theme_color_override("font_color", MUTED)
	state_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	seat.add_child(state_label)
	seat_state_labels.append(state_label)

	var hit := Button.new()
	hit.position = Vector2.ZERO
	hit.size = seat.size
	hit.flat = true
	hit.focus_mode = Control.FOCUS_NONE
	hit.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	hit.pressed.connect(_on_seat_pressed.bind(index))
	seat.add_child(hit)
	seat_hit_buttons.append(hit)


func _create_board() -> void:
	var board_bg := Panel.new()
	board_bg.position = Vector2(166, 258)
	board_bg.size = Vector2(320, 104)
	board_bg.add_theme_stylebox_override("panel", _style(FELT_2, Color("346859"), 1, 18))
	table.add_child(board_bg)

	for i in range(5):
		var card := Panel.new()
		card.position = Vector2(15 + i * 61, 18)
		card.size = Vector2(50, 70)
		card.visible = false
		card.add_theme_stylebox_override("panel", _style(Color("f1eee5"), Color("c8ac70"), 2, 7))
		board_bg.add_child(card)
		board_panels.append(card)

		var label := Label.new()
		label.position = Vector2.ZERO
		label.size = card.size
		label.text = "?"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 15)
		label.add_theme_color_override("font_color", Color("171b20"))
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(label)
		board_labels.append(label)


func _create_pots() -> void:
	pot_panel = Panel.new()
	pot_panel.position = Vector2(218, 384)
	pot_panel.size = Vector2(216, 92)
	pot_panel.pivot_offset = pot_panel.size * 0.5
	pot_panel.add_theme_stylebox_override("panel", _style(Color("1d2630"), ACCENT, 2, 24))
	table.add_child(pot_panel)

	main_pot_label = Label.new()
	main_pot_label.position = Vector2(8, 10)
	main_pot_label.size = Vector2(200, 30)
	main_pot_label.text = "MAIN POT  0"
	main_pot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_pot_label.add_theme_color_override("font_color", ACCENT)
	main_pot_label.add_theme_font_size_override("font_size", 16)
	pot_panel.add_child(main_pot_label)

	side_pot_label = Label.new()
	side_pot_label.position = Vector2(8, 48)
	side_pot_label.size = Vector2(200, 28)
	side_pot_label.text = "SIDE POT  0"
	side_pot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	side_pot_label.add_theme_color_override("font_color", TEXT)
	side_pot_label.add_theme_font_size_override("font_size", 14)
	pot_panel.add_child(side_pot_label)


func _create_request_panel() -> void:
	request_panel = Panel.new()
	request_panel.position = Vector2(440, 500)
	request_panel.size = Vector2(184, 76)
	request_panel.visible = false
	request_panel.add_theme_stylebox_override("panel", _style(Color("282136"), PURPLE, 2, 13))
	table.add_child(request_panel)

	request_label = Label.new()
	request_label.position = Vector2(8, 7)
	request_label.size = Vector2(168, 62)
	request_label.text = ""
	request_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	request_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	request_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	request_label.add_theme_font_size_override("font_size", 11)
	request_label.add_theme_color_override("font_color", TEXT)
	request_panel.add_child(request_label)


func _create_showdown_panel() -> void:
	showdown_panel = Panel.new()
	showdown_panel.position = Vector2(18, 500)
	showdown_panel.size = Vector2(220, 94)
	showdown_panel.visible = false
	showdown_panel.add_theme_stylebox_override("panel", _style(Color("151e27"), LINE, 1, 13))
	table.add_child(showdown_panel)

	showdown_label = Label.new()
	showdown_label.position = Vector2(8, 6)
	showdown_label.size = Vector2(204, 82)
	showdown_label.text = ""
	showdown_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	showdown_label.add_theme_font_size_override("font_size", 11)
	showdown_label.add_theme_color_override("font_color", MUTED)
	showdown_panel.add_child(showdown_label)


func _create_bets() -> void:
	for i in range(6):
		var bet := Panel.new()
		bet.position = BET_POSITIONS[i]
		bet.size = Vector2(84, 34)
		bet.visible = false
		bet.add_theme_stylebox_override("panel", _style(Color("6a4818"), ACCENT, 1, 17))
		table.add_child(bet)
		bet_panels.append(bet)

		var label := Label.new()
		label.position = Vector2.ZERO
		label.size = bet.size
		label.text = "0"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 11)
		label.add_theme_color_override("font_color", TEXT)
		bet.add_child(label)
		bet_labels.append(label)


func _build_tool_panel() -> void:
	var panel := Panel.new()
	panel.position = Vector2(24, 780)
	panel.size = Vector2(672, 250)
	panel.add_theme_stylebox_override("panel", _style(PANEL, LINE, 1, 18))
	game_layer.add_child(panel)

	tool_mode_label = Label.new()
	tool_mode_label.position = Vector2(18, 10)
	tool_mode_label.size = Vector2(636, 24)
	tool_mode_label.text = "DEALER TOOLS"
	tool_mode_label.add_theme_font_size_override("font_size", 13)
	tool_mode_label.add_theme_color_override("font_color", MUTED)
	panel.add_child(tool_mode_label)

	for i in range(ACTION_ORDER.size()):
		var action_id: String = ACTION_ORDER[i]
		var button := Button.new()
		var col: int = i % 3
		var row: int = int(i / 3)
		button.position = Vector2(18 + col * 211, 48 + row * 86)
		button.size = Vector2(194, 70)
		button.text = String(ACTION_LABELS[action_id])
		button.add_theme_font_size_override("font_size", 16)
		button.add_theme_stylebox_override("normal", _style(PANEL_2, LINE, 1, 13))
		button.add_theme_stylebox_override("hover", _style(Color("283446"), ACCENT, 1, 13))
		button.add_theme_stylebox_override("pressed", _style(Color("33270f"), ACCENT, 2, 13))
		button.add_theme_color_override("font_color", TEXT)
		button.pressed.connect(_on_action_pressed.bind(action_id))
		panel.add_child(button)
		action_buttons[action_id] = button


func _build_history_panel() -> void:
	var panel := Panel.new()
	panel.position = Vector2(24, 1046)
	panel.size = Vector2(672, 112)
	panel.add_theme_stylebox_override("panel", _style(Color("111820"), LINE, 1, 15))
	game_layer.add_child(panel)

	var title := Label.new()
	title.position = Vector2(14, 8)
	title.size = Vector2(120, 20)
	title.text = "TABLE LOG"
	title.add_theme_font_size_override("font_size", 11)
	title.add_theme_color_override("font_color", MUTED)
	panel.add_child(title)

	for i in range(3):
		var line := Label.new()
		line.position = Vector2(14, 31 + i * 24)
		line.size = Vector2(644, 22)
		line.text = "—"
		line.add_theme_font_size_override("font_size", 11)
		line.add_theme_color_override("font_color", MUTED)
		panel.add_child(line)
		history_labels.append(line)


func _build_complete() -> void:
	complete_layer = Control.new()
	complete_layer.position = Vector2(0, 104)
	complete_layer.size = Vector2(720, 1176)
	complete_layer.visible = false
	add_child(complete_layer)

	var panel := Panel.new()
	panel.name = "Panel"
	panel.position = Vector2(46, 130)
	panel.size = Vector2(628, 610)
	panel.add_theme_stylebox_override("panel", _style(PANEL, ACCENT, 2, 24))
	complete_layer.add_child(panel)

	var title := Label.new()
	title.position = Vector2(24, 34)
	title.size = Vector2(580, 50)
	title.text = "SHIFT COMPLETE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", ACCENT)
	panel.add_child(title)

	var subtitle := Label.new()
	subtitle.position = Vector2(24, 95)
	subtitle.size = Vector2(580, 40)
	subtitle.text = "ROOKIE HALL · 3 HANDS"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", MUTED)
	panel.add_child(subtitle)

	var result := Label.new()
	result.name = "Result"
	result.position = Vector2(54, 170)
	result.size = Vector2(520, 235)
	result.text = ""
	result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result.add_theme_font_size_override("font_size", 19)
	result.add_theme_color_override("font_color", TEXT)
	panel.add_child(result)

	var replay := Button.new()
	replay.position = Vector2(54, 452)
	replay.size = Vector2(520, 70)
	replay.text = "다시 근무하기"
	replay.add_theme_font_size_override("font_size", 18)
	replay.add_theme_stylebox_override("normal", _style(ACCENT, ACCENT, 0, 14))
	replay.add_theme_color_override("font_color", Color("261b08"))
	replay.pressed.connect(_start_shift)
	panel.add_child(replay)

	var home := Button.new()
	home.position = Vector2(54, 538)
	home.size = Vector2(520, 50)
	home.text = "HOME"
	home.pressed.connect(_show_home)
	panel.add_child(home)


func _build_feedback() -> void:
	feedback_label = Label.new()
	feedback_label.position = Vector2(180, 498)
	feedback_label.size = Vector2(360, 58)
	feedback_label.visible = false
	feedback_label.z_index = 200
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback_label.add_theme_font_size_override("font_size", 16)
	feedback_label.add_theme_stylebox_override("normal", _style(Color("10161de8"), LINE, 1, 14))
	add_child(feedback_label)


func _show_home() -> void:
	session_active = false
	resolving = false
	betting_running = false
	payout_targeting = false
	pending_duties.clear()
	scheduled_events.clear()
	home_layer.visible = true
	game_layer.visible = false
	complete_layer.visible = false
	level_label.text = "LV.1  신입 딜러"
	cash_label.text = "TIP  %s" % _format_amount(cash)
	rep_label.text = "REP  120"
	accuracy_label.text = "ACC 100%"
	flow_label.text = "FLOW x0"
	timer_label.text = "READY"
	timer_label.add_theme_color_override("font_color", GOOD)


func _start_shift() -> void:
	hands = LiveShiftScenario.build()
	hand_index = 0
	shift_elapsed = 0.0
	session_active = true
	resolving = false
	betting_running = false
	payout_targeting = false
	pending_duties.clear()
	scheduled_events.clear()
	correct_actions = 0
	mistakes = 0
	flow_combo = 0
	max_flow_combo = 0
	tips = 0

	home_layer.visible = false
	game_layer.visible = true
	complete_layer.visible = false
	for label in history_labels:
		label.text = "—"

	_start_hand()


func _start_hand() -> void:
	if hand_index >= hands.size():
		_finish_shift()
		return

	resolving = false
	betting_running = false
	payout_targeting = false
	pending_duties.clear()
	scheduled_events.clear()
	street_index = 0
	street_elapsed = 0.0

	var hand: Dictionary = hands[hand_index]
	phase_label.text = String(hand.get("label", "HAND"))
	headline_label.text = "NEW HAND · 셔플과 컷 완료"
	event_label.text = "플레이어들이 딜을 기다리고 있습니다."
	tool_mode_label.text = "DEALER TOOLS"
	showdown_panel.visible = false
	request_panel.visible = false
	main_pot_label.text = "MAIN POT  0"
	side_pot_label.text = "SIDE POT  0"

	var raw_board: Variant = hand.get("board", [])
	if raw_board is Array:
		var board_values: Array = raw_board as Array
		for i in range(board_labels.size()):
			board_labels[i].text = String(board_values[i]) if i < board_values.size() else "?"
			board_panels[i].visible = false

	for i in range(seat_panels.size()):
		seat_state_labels[i].text = "READY"
		bet_panels[i].visible = false
		seat_panels[i].add_theme_stylebox_override("panel", _style(PANEL, LINE, 2, 14))

	_enqueue_duty(DealerTask.new({
		"id": "deal",
		"phase": "PREFLOP",
		"expected_action": "deal",
		"success_text": "FAST DEAL",
		"base_tip": 120,
		"blocking": true,
		"patience_limit": 6.0,
	}))

	_append_history("— %s START" % String(hand.get("label", "HAND")), INFO)
	_refresh_hud()
	_refresh_pressure()


func _schedule_betting_round(street: String) -> void:
	if hand_index < 0 or hand_index >= hands.size():
		return
	var hand: Dictionary = hands[hand_index]
	var raw_round: Variant = hand.get(street, {})
	if not raw_round is Dictionary:
		return

	var round_data: Dictionary = raw_round as Dictionary
	scheduled_events.clear()
	street_elapsed = 0.0
	betting_running = true
	headline_label.text = "%s · PLAYER ACTION" % street.to_upper()
	event_label.text = "플레이어 액션이 진행 중입니다."

	var raw_events: Variant = round_data.get("events", [])
	var last_time: float = 0.0
	if raw_events is Array:
		for raw: Variant in raw_events:
			if raw is Dictionary:
				var action: Dictionary = (raw as Dictionary).duplicate(true)
				action["kind"] = "npc_action"
				scheduled_events.append(action)
				last_time = maxf(last_time, float(action.get("t", 0.0)))

	var raw_request: Variant = round_data.get("request", {})
	if raw_request is Dictionary and not (raw_request as Dictionary).is_empty():
		var request_event: Dictionary = (raw_request as Dictionary).duplicate(true)
		request_event["kind"] = "request"
		scheduled_events.append(request_event)

	scheduled_events.append({
		"kind": "betting_closed",
		"t": last_time + 0.35,
		"street": street,
	})


func _process_scheduled_events() -> void:
	for i in range(scheduled_events.size() - 1, -1, -1):
		var event: Dictionary = scheduled_events[i]
		if street_elapsed < float(event.get("t", 0.0)):
			continue

		scheduled_events.remove_at(i)
		_fire_scheduled_event(event)


func _fire_scheduled_event(event: Dictionary) -> void:
	var kind: String = String(event.get("kind", ""))
	match kind:
		"npc_action":
			var seat: int = int(event.get("seat", -1))
			var state: String = String(event.get("state", ""))
			var bet: int = int(event.get("bet", 0))
			if seat >= 0 and seat < seat_state_labels.size():
				seat_state_labels[seat].text = state
				_flash_panel(seat_panels[seat], INFO)
				bet_panels[seat].visible = bet > 0
				bet_labels[seat].text = _format_amount(bet)
				headline_label.text = "%s · %s" % [PLAYER_NAMES[seat], state]
		"request":
			_spawn_service_request(event)
		"betting_closed":
			betting_running = false
			_on_betting_closed(String(event.get("street", "preflop")))


func _spawn_service_request(event: Dictionary) -> void:
	var seat: int = int(event.get("seat", -1))
	var text_value: String = String(event.get("text", "칩 교환 요청"))
	var patience: float = float(event.get("patience", 5.0))
	request_panel.visible = true
	request_label.text = text_value
	if seat >= 0 and seat < seat_panels.size():
		seat_panels[seat].add_theme_stylebox_override("panel", _style(Color("282136"), PURPLE, 3, 14))
		seat_state_labels[seat].text = "REQUEST"

	_enqueue_duty(DealerTask.new({
		"id": "service_%d_%s" % [hand_index, str(Time.get_ticks_msec())],
		"phase": "SERVICE",
		"expected_action": "chip_change",
		"success_text": "CHIP CHANGE",
		"base_tip": 150,
		"source_seat": seat,
		"blocking": false,
		"patience_limit": patience,
		"state": {"request_text": text_value},
	}))
	_append_history("! %s" % text_value, PURPLE)


func _on_betting_closed(street: String) -> void:
	var hand: Dictionary = hands[hand_index]
	var round_data: Dictionary = hand[street] as Dictionary
	var collect: Dictionary = round_data.get("collect", {}) as Dictionary
	var has_bets: bool = false
	for bet in bet_panels:
		if bet.visible:
			has_bets = true
			break

	if not has_bets and bool(collect.get("skip_if_zero", false)):
		headline_label.text = "%s · CHECKED THROUGH" % street.to_upper()
		event_label.text = "베팅칩이 없습니다."
		_after_collect(street, collect)
		return

	headline_label.text = "%s · ACTION CLOSED" % street.to_upper()
	event_label.text = "테이블 위 베팅칩은 그대로 남아 있습니다."
	_enqueue_duty(DealerTask.new({
		"id": "collect_%s_%d" % [street, hand_index],
		"phase": street.to_upper(),
		"expected_action": "pot",
		"success_text": "POT COLLECTED",
		"base_tip": int(collect.get("tip", 150)),
		"blocking": true,
		"patience_limit": 5.5,
		"state": {
			"street": street,
			"main_after": int(collect.get("main_after", 0)),
			"side_after": int(collect.get("side_after", 0)),
		},
	}))


func _enqueue_board_duty(next_street: String) -> void:
	var label: String = next_street.to_upper()
	headline_label.text = "%s · TABLE READY" % label
	event_label.text = "다음 스트리트를 진행할 수 있습니다."
	_enqueue_duty(DealerTask.new({
		"id": "board_%s_%d" % [next_street, hand_index],
		"phase": label,
		"expected_action": "board",
		"success_text": "%s OPEN" % label,
		"base_tip": 120,
		"blocking": true,
		"patience_limit": 6.0,
		"state": {"street": next_street},
	}))


func _enqueue_showdown() -> void:
	var hand: Dictionary = hands[hand_index]
	var showdown: Dictionary = hand.get("showdown", {}) as Dictionary
	showdown_panel.visible = true
	showdown_label.text = String(showdown.get("text", "SHOWDOWN"))
	headline_label.text = "SHOWDOWN"
	event_label.text = "핸드가 공개되었습니다. 팟을 정산하세요."
	var payouts: Array = showdown.get("payouts", []) as Array
	if payouts.is_empty():
		_finish_hand()
		return

	_enqueue_payout_from_data(payouts[0], 0)


func _enqueue_payout_from_data(raw: Variant, payout_index: int) -> void:
	if not raw is Dictionary:
		return
	var data: Dictionary = raw as Dictionary
	var pot_name: String = String(data.get("pot", "MAIN"))
	_enqueue_duty(DealerTask.new({
		"id": "payout_%d_%d" % [hand_index, payout_index],
		"phase": "SHOWDOWN",
		"expected_action": "payout",
		"success_text": "%s POT PAID" % pot_name,
		"base_tip": int(data.get("tip", 200)),
		"target_seat": int(data.get("seat", -1)),
		"blocking": true,
		"patience_limit": 7.0,
		"state": {
			"pot_name": pot_name,
			"amount": int(data.get("amount", 0)),
			"payout_index": payout_index,
		},
	}))
	headline_label.text = "%s POT  %s" % [pot_name, _format_amount(int(data.get("amount", 0)))]


func _enqueue_duty(duty: DealerTask) -> void:
	duty.reset_clock()
	pending_duties.append(duty)
	_refresh_pressure()


func _age_pending_duties(delta: float) -> void:
	for i in range(pending_duties.size() - 1, -1, -1):
		var duty: DealerTask = pending_duties[i]
		duty.age += delta

		if not duty.warned and duty.age >= duty.patience_limit * 0.65:
			duty.warned = true
			if duty.expected_action == "chip_change":
				var seat_name: String = "손님"
				if duty.source_seat >= 0 and duty.source_seat < PLAYER_NAMES.size():
					seat_name = PLAYER_NAMES[duty.source_seat]
				_show_feedback("%s: 딜러?" % seat_name, ACCENT)
			elif duty.blocking:
				_show_feedback("TABLE WAITING...", ACCENT)

		if duty.age < duty.patience_limit:
			continue

		if duty.blocking:
			var penalized: bool = bool(duty.state.get("overdue_penalized", false))
			if not penalized:
				duty.state["overdue_penalized"] = true
				mistakes += 1
				flow_combo = 0
				_append_history("× TABLE DELAY · FLOW LOST", BAD)
				_show_feedback("TABLE DELAY", BAD)
				_refresh_hud()
		else:
			pending_duties.remove_at(i)
			mistakes += 1
			flow_combo = 0
			tips = maxi(tips - 80, 0)
			_append_history("× 요청 놓침 · TIP -80", BAD)
			_show_feedback("REQUEST MISSED", BAD)
			_refresh_request_panel_from_duties()
			_refresh_hud()
			_refresh_pressure()


func _on_action_pressed(action_id: String) -> void:
	if not session_active or resolving:
		return

	if payout_targeting:
		if action_id == "floor":
			_use_floor_assist()
		elif action_id == "payout":
			_cancel_payout_targeting()
		else:
			_register_invalid_action(action_id)
		return

	if action_id == "floor":
		_use_floor_assist()
		return

	var duty: DealerTask = _find_pending_duty(action_id)
	if duty == null:
		_register_invalid_action(action_id)
		return

	if action_id == "payout":
		_begin_payout_targeting(duty)
	else:
		_resolve_duty(duty)


func _find_pending_duty(action_id: String) -> DealerTask:
	var best: DealerTask
	var best_age: float = -1.0
	for duty in pending_duties:
		if duty.expected_action == action_id and duty.age > best_age:
			best = duty
			best_age = duty.age
	return best


func _begin_payout_targeting(duty: DealerTask) -> void:
	active_payout_duty = duty
	payout_targeting = true
	tool_mode_label.text = "PAYOUT · 지급할 좌석 선택"
	_show_feedback("PAYOUT MODE", INFO)
	_apply_payout_eligibility(duty)


func _cancel_payout_targeting() -> void:
	payout_targeting = false
	active_payout_duty = null
	tool_mode_label.text = "DEALER TOOLS"
	_reset_seat_styles()


func _on_seat_pressed(seat_index: int) -> void:
	if not session_active or resolving or not payout_targeting or active_payout_duty == null:
		return

	if seat_index == active_payout_duty.target_seat:
		var duty: DealerTask = active_payout_duty
		payout_targeting = false
		active_payout_duty = null
		tool_mode_label.text = "DEALER TOOLS"
		_resolve_duty(duty)
	else:
		mistakes += 1
		flow_combo = 0
		_show_feedback("잘못된 지급 대상", BAD)
		_append_history("× PAYOUT TARGET ERROR", BAD)
		_refresh_hud()


func _resolve_duty(duty: DealerTask) -> void:
	if not pending_duties.has(duty):
		return

	resolving = true
	var fast: bool = duty.age <= duty.patience_limit * 0.65
	var speed_bonus: int = 60 if fast else 0
	var earned: int = duty.base_tip + speed_bonus
	correct_actions += 1
	tips += earned
	cash += earned

	if fast:
		flow_combo += 1
		max_flow_combo = maxi(max_flow_combo, flow_combo)

	_append_history("✓ %s  +%d" % [duty.success_text, earned], GOOD)
	_show_feedback("%s  ·  +%d" % [duty.success_text, earned], GOOD)
	await _play_duty_feedback(duty)

	pending_duties.erase(duty)
	_after_duty_resolved(duty)
	resolving = false
	_refresh_request_panel_from_duties()
	_refresh_pressure()
	_refresh_hud()


func _after_duty_resolved(duty: DealerTask) -> void:
	match duty.expected_action:
		"deal":
			for i in range(seat_state_labels.size()):
				seat_state_labels[i].text = "CARDS"
			_schedule_betting_round("preflop")
		"pot":
			var street: String = String(duty.state.get("street", "preflop"))
			var main_after: int = int(duty.state.get("main_after", 0))
			var side_after: int = int(duty.state.get("side_after", 0))
			main_pot_label.text = "MAIN POT  %s" % _format_amount(main_after)
			side_pot_label.text = "SIDE POT  %s" % _format_amount(side_after)
			_after_collect(street, duty.state)
		"board":
			var street: String = String(duty.state.get("street", "flop"))
			_open_board(street)
			_schedule_betting_round(street)
		"chip_change":
			if duty.source_seat >= 0 and duty.source_seat < seat_state_labels.size():
				seat_state_labels[duty.source_seat].text = "ACTIVE"
		"payout":
			_after_payout(duty)


func _after_collect(street: String, _collect_data: Dictionary) -> void:
	match street:
		"preflop":
			_enqueue_board_duty("flop")
		"flop":
			_enqueue_board_duty("turn")
		"turn":
			_enqueue_board_duty("river")
		"river":
			_enqueue_showdown()


func _after_payout(duty: DealerTask) -> void:
	var pot_name: String = String(duty.state.get("pot_name", "MAIN"))
	if pot_name == "MAIN":
		main_pot_label.text = "MAIN POT  PAID"
	else:
		side_pot_label.text = "SIDE POT  PAID"

	var hand: Dictionary = hands[hand_index]
	var showdown: Dictionary = hand.get("showdown", {}) as Dictionary
	var payouts: Array = showdown.get("payouts", []) as Array
	var next_index: int = int(duty.state.get("payout_index", 0)) + 1
	if next_index < payouts.size():
		_enqueue_payout_from_data(payouts[next_index], next_index)
	else:
		_finish_hand()


func _finish_hand() -> void:
	betting_running = false
	scheduled_events.clear()
	headline_label.text = "HAND COMPLETE"
	event_label.text = "다음 핸드를 준비합니다."
	_append_history("— HAND %d COMPLETE" % (hand_index + 1), INFO)
	hand_index += 1
	if hand_index >= hands.size():
		await get_tree().create_timer(0.7).timeout
		_finish_shift()
	else:
		await get_tree().create_timer(0.7).timeout
		_start_hand()


func _open_board(street: String) -> void:
	match street:
		"flop":
			for i in range(3):
				board_panels[i].visible = true
		"turn":
			board_panels[3].visible = true
		"river":
			board_panels[4].visible = true


func _play_duty_feedback(duty: DealerTask) -> void:
	match duty.expected_action:
		"deal":
			for i in range(seat_panels.size()):
				_flash_panel(seat_panels[i], GOOD)
				await get_tree().create_timer(0.045).timeout
		"pot":
			for bet in bet_panels:
				bet.visible = false
			_pulse_pot(GOOD)
			await get_tree().create_timer(0.22).timeout
		"board":
			_pulse_pot(INFO)
			await get_tree().create_timer(0.18).timeout
		"chip_change":
			if duty.source_seat >= 0 and duty.source_seat < seat_panels.size():
				_flash_panel(seat_panels[duty.source_seat], GOOD)
			await get_tree().create_timer(0.22).timeout
		"payout":
			if duty.target_seat >= 0 and duty.target_seat < seat_panels.size():
				_flash_panel(seat_panels[duty.target_seat], GOOD)
			await get_tree().create_timer(0.28).timeout


func _register_invalid_action(action_id: String) -> void:
	mistakes += 1
	flow_combo = 0
	var message: String = "지금은 그 업무가 필요하지 않습니다"
	if action_id == "board" and _find_pending_duty("pot") != null:
		message = "베팅칩이 아직 테이블에 있습니다"
	elif action_id == "pot" and not _visible_bets_exist():
		message = "회수할 베팅칩이 없습니다"
	elif action_id == "chip_change" and _find_pending_duty("chip_change") == null:
		message = "칩 교환 요청이 없습니다"
	elif action_id == "payout":
		message = "아직 정산할 팟이 없습니다"
	elif action_id == "deal":
		message = "현재 핸드가 진행 중입니다"
	_show_feedback(message, BAD)
	_append_history("× %s" % message, BAD)
	_refresh_hud()


func _use_floor_assist() -> void:
	if pending_duties.is_empty():
		_register_invalid_action("floor")
		return

	var duty: DealerTask = pending_duties[0]
	for candidate in pending_duties:
		if candidate.blocking and candidate.age > duty.age:
			duty = candidate

	mistakes += 1
	flow_combo = 0
	tips = maxi(tips - 50, 0)
	_append_history("! FLOOR ASSIST · TIP -50", INFO)
	_show_feedback("FLOOR ASSIST", INFO)
	await _resolve_duty_without_reward(duty)
	_refresh_hud()


func _resolve_duty_without_reward(duty: DealerTask) -> void:
	if not pending_duties.has(duty):
		return
	resolving = true
	await _play_duty_feedback(duty)
	pending_duties.erase(duty)
	_after_duty_resolved(duty)
	resolving = false
	_refresh_request_panel_from_duties()
	_refresh_pressure()


func _apply_payout_eligibility(duty: DealerTask) -> void:
	_reset_seat_styles()
	var hand: Dictionary = hands[hand_index]
	var showdown: Dictionary = hand.get("showdown", {}) as Dictionary
	var payouts: Array = showdown.get("payouts", []) as Array
	var payout_index: int = int(duty.state.get("payout_index", 0))
	var eligible: Array[int] = []

	if payout_index == 0:
		for raw: Variant in payouts:
			if raw is Dictionary:
				var seat: int = int((raw as Dictionary).get("seat", -1))
				if seat >= 0 and not eligible.has(seat):
					eligible.append(seat)
		for i in [0, 1, 2, 3, 4, 5]:
			if not seat_state_labels[i].text.begins_with("FOLD"):
				if not eligible.has(i):
					eligible.append(i)
	else:
		for raw: Variant in payouts:
			if raw is Dictionary:
				var seat: int = int((raw as Dictionary).get("seat", -1))
				if seat >= 0 and not eligible.has(seat):
					eligible.append(seat)

	for seat_index in eligible:
		seat_panels[seat_index].add_theme_stylebox_override(
			"panel",
			_style(Color("1c2c39"), INFO, 3, 14)
		)


func _refresh_request_panel_from_duties() -> void:
	var request_duty: DealerTask
	for duty in pending_duties:
		if duty.expected_action == "chip_change":
			request_duty = duty
			break

	if request_duty == null:
		request_panel.visible = false
		return

	request_panel.visible = true
	request_label.text = String(request_duty.state.get("request_text", "칩 교환 요청"))


func _refresh_pressure() -> void:
	var blocking_count: int = 0
	var request_count: int = 0
	for duty in pending_duties:
		if duty.blocking:
			blocking_count += 1
		else:
			request_count += 1

	var total: int = blocking_count + request_count
	if total == 0:
		pressure_label.text = "TABLE MOVING" if betting_running else "TABLE CLEAR"
		pressure_label.add_theme_color_override("font_color", GOOD)
	elif total == 1:
		pressure_label.text = "PRESSURE 1"
		pressure_label.add_theme_color_override("font_color", ACCENT)
	else:
		pressure_label.text = "PRESSURE %d" % total
		pressure_label.add_theme_color_override("font_color", BAD)


func _visible_bets_exist() -> bool:
	for bet in bet_panels:
		if bet.visible:
			return true
	return false


func _finish_shift() -> void:
	session_active = false
	resolving = false
	betting_running = false
	payout_targeting = false
	pending_duties.clear()
	scheduled_events.clear()
	game_layer.visible = false
	complete_layer.visible = true

	var total: int = maxi(correct_actions + mistakes, 1)
	var accuracy: int = int(round(float(correct_actions) / float(total) * 100.0))
	var result := complete_layer.get_node("Panel/Result") as Label
	if result != null:
		var grade: String = "GOOD SHIFT"
		if accuracy >= 92 and mistakes <= 1:
			grade = "SMOOTH OPERATOR"
		elif accuracy < 70:
			grade = "ROUGH SHIFT"
		result.text = "%s\n\n3 HANDS COMPLETE\n정확도  %d%%\n최대 FLOW  x%d\n실수/지연  %d\nTIP BONUS  +%s" % [
			grade,
			accuracy,
			max_flow_combo,
			mistakes,
			_format_amount(tips),
		]

	timer_label.text = "DONE"
	accuracy_label.text = "ACC %d%%" % accuracy
	flow_label.text = "MAX x%d" % max_flow_combo
	cash_label.text = "TIP  %s" % _format_amount(cash)


func _refresh_hud() -> void:
	var total: int = correct_actions + mistakes
	var accuracy: int = 100
	if total > 0:
		accuracy = int(round(float(correct_actions) / float(total) * 100.0))
	accuracy_label.text = "ACC %d%%" % accuracy
	flow_label.text = "FLOW x%d" % flow_combo
	cash_label.text = "TIP  %s" % _format_amount(cash)


func _refresh_shift_clock() -> void:
	var seconds: int = int(floor(shift_elapsed))
	var minutes: int = int(seconds / 60)
	var remain: int = seconds % 60
	timer_label.text = "%02d:%02d" % [minutes, remain]
	timer_label.add_theme_color_override("font_color", GOOD)


func _append_history(text_value: String, color: Color) -> void:
	for i in range(history_labels.size() - 1, 0, -1):
		history_labels[i].text = history_labels[i - 1].text
		history_labels[i].add_theme_color_override(
			"font_color",
			history_labels[i - 1].get_theme_color("font_color")
		)
	history_labels[0].text = text_value
	history_labels[0].add_theme_color_override("font_color", color)


func _show_feedback(text_value: String, color: Color) -> void:
	feedback_label.text = text_value
	feedback_label.add_theme_color_override("font_color", color)
	feedback_label.modulate = Color.WHITE
	feedback_label.visible = true
	var tween := create_tween()
	tween.tween_interval(0.55)
	tween.tween_property(feedback_label, "modulate:a", 0.0, 0.20)
	tween.tween_callback(func() -> void:
		feedback_label.visible = false
		feedback_label.modulate = Color.WHITE
	)


func _flash_panel(panel: Panel, color: Color) -> void:
	var original_scale: Vector2 = panel.scale
	panel.pivot_offset = panel.size * 0.5
	panel.add_theme_stylebox_override("panel", _style(Color("183126"), color, 3, 14))
	var tween := create_tween()
	tween.tween_property(panel, "scale", Vector2(1.05, 1.05), 0.08)
	tween.tween_property(panel, "scale", original_scale, 0.10)


func _pulse_pot(color: Color) -> void:
	pot_panel.add_theme_stylebox_override("panel", _style(Color("203027"), color, 3, 24))
	var tween := create_tween()
	tween.tween_property(pot_panel, "scale", Vector2(1.07, 1.07), 0.10)
	tween.tween_property(pot_panel, "scale", Vector2.ONE, 0.12)


func _reset_seat_styles() -> void:
	for panel in seat_panels:
		panel.scale = Vector2.ONE
		panel.add_theme_stylebox_override("panel", _style(PANEL, LINE, 2, 14))
	request_panel.add_theme_stylebox_override("panel", _style(Color("282136"), PURPLE, 2, 13))
	pot_panel.scale = Vector2.ONE
	pot_panel.add_theme_stylebox_override("panel", _style(Color("1d2630"), ACCENT, 2, 24))


func _format_amount(value: int) -> String:
	var raw: String = str(value)
	var result: String = ""
	var count: int = 0
	for i in range(raw.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = raw[i] + result
		count += 1
	return result


func _style(bg: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = width
	style.border_width_top = width
	style.border_width_right = width
	style.border_width_bottom = width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	return style
