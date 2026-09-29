extends Control

const BUILD_ID: String = "dealer-management-stage1-v0.2"

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

const PLAYER_NAMES: Array[String] = ["지민", "맥스", "소연", "토니", "김사장", "찰리"]
const PLAYER_STACKS: Array[int] = [12500, 8900, 4300, 9600, 6800, 3200]
const BOARD_VALUES: Array[String] = ["J♣", "10♥", "7♠", "A♠", "2♦"]
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

var tasks: Array[DealerTask] = []
var current_task_index: int = -1
var time_left: float = 0.0
var session_active: bool = false
var resolving: bool = false

var correct_actions: int = 0
var mistakes: int = 0
var combo: int = 0
var max_combo: int = 0
var tips: int = 0
var cash: int = 12480

var home_layer: Control
var game_layer: Control
var complete_layer: Control

var level_label: Label
var cash_label: Label
var crown_label: Label
var accuracy_label: Label
var combo_label: Label
var timer_label: Label

var phase_label: Label
var headline_label: Label
var prompt_label: Label
var feedback_label: Label

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

var choice_buttons: Array[Button] = []
var history_labels: Array[Label] = []


func _ready() -> void:
	_build_ui()
	_show_home()


func _process(delta: float) -> void:
	if not session_active or resolving or current_task_index < 0:
		return

	time_left = maxf(time_left - delta, 0.0)
	_refresh_timer()

	if time_left <= 0.0:
		_handle_timeout()


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
	level_label.size = Vector2(230, 22)
	level_label.text = "LV.1  신입 딜러"
	level_label.add_theme_font_size_override("font_size", 13)
	level_label.add_theme_color_override("font_color", MUTED)
	top.add_child(level_label)

	cash_label = Label.new()
	cash_label.position = Vector2(260, 13)
	cash_label.size = Vector2(120, 22)
	cash_label.text = "TIP  12,480"
	cash_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cash_label.add_theme_color_override("font_color", ACCENT)
	top.add_child(cash_label)

	crown_label = Label.new()
	crown_label.position = Vector2(260, 42)
	crown_label.size = Vector2(120, 20)
	crown_label.text = "REP  120"
	crown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crown_label.add_theme_color_override("font_color", MUTED)
	top.add_child(crown_label)

	accuracy_label = Label.new()
	accuracy_label.position = Vector2(398, 10)
	accuracy_label.size = Vector2(90, 24)
	accuracy_label.text = "ACC 100%"
	accuracy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	accuracy_label.add_theme_color_override("font_color", TEXT)
	top.add_child(accuracy_label)

	combo_label = Label.new()
	combo_label.position = Vector2(496, 10)
	combo_label.size = Vector2(88, 24)
	combo_label.text = "COMBO x0"
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	combo_label.add_theme_color_override("font_color", ACCENT)
	top.add_child(combo_label)

	timer_label = Label.new()
	timer_label.position = Vector2(596, 9)
	timer_label.size = Vector2(70, 50)
	timer_label.text = "00:00"
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	timer_label.add_theme_font_size_override("font_size", 18)
	timer_label.add_theme_color_override("font_color", GOOD)
	top.add_child(timer_label)


func _build_home() -> void:
	home_layer = Control.new()
	home_layer.position = Vector2(0, 104)
	home_layer.size = Vector2(720, 1176)
	add_child(home_layer)

	var hero := Panel.new()
	hero.position = Vector2(24, 36)
	hero.size = Vector2(672, 450)
	hero.add_theme_stylebox_override("panel", _style(PANEL, LINE, 1, 24))
	home_layer.add_child(hero)

	var badge := Label.new()
	badge.position = Vector2(24, 22)
	badge.size = Vector2(620, 26)
	badge.text = "ROOKIE HALL · SHIFT 01"
	badge.add_theme_color_override("font_color", ACCENT)
	badge.add_theme_font_size_override("font_size", 13)
	hero.add_child(badge)

	var h1 := Label.new()
	h1.position = Vector2(24, 76)
	h1.size = Vector2(620, 105)
	h1.text = "테이블을 읽고\n딜러 업무를 처리하세요"
	h1.add_theme_font_size_override("font_size", 31)
	h1.add_theme_color_override("font_color", TEXT)
	hero.add_child(h1)

	var desc := Label.new()
	desc.position = Vector2(24, 204)
	desc.size = Vector2(620, 105)
	desc.text = "정확한 좌표에 카드를 놓는 게임이 아닙니다.\n손님과 베팅 상태를 보고 지금 해야 할 일을 판단하세요."
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 16)
	desc.add_theme_color_override("font_color", MUTED)
	hero.add_child(desc)

	var start := Button.new()
	start.position = Vector2(24, 336)
	start.size = Vector2(624, 78)
	start.text = "첫 근무 시작"
	start.add_theme_font_size_override("font_size", 20)
	start.add_theme_stylebox_override("normal", _style(ACCENT, ACCENT, 0, 16))
	start.add_theme_color_override("font_color", Color("261b08"))
	start.pressed.connect(_start_shift)
	hero.add_child(start)

	var preview := Panel.new()
	preview.position = Vector2(24, 514)
	preview.size = Vector2(672, 356)
	preview.add_theme_stylebox_override("panel", _style(PANEL, LINE, 1, 20))
	home_layer.add_child(preview)

	var ptitle := Label.new()
	ptitle.position = Vector2(20, 18)
	ptitle.size = Vector2(620, 28)
	ptitle.text = "이번 근무에서 생기는 일"
	ptitle.add_theme_font_size_override("font_size", 18)
	ptitle.add_theme_color_override("font_color", TEXT)
	preview.add_child(ptitle)

	var lines: Array[String] = [
		"카드 배분 → 베팅 회수",
		"ALL IN 금액 차이 → 사이드팟 판단",
		"플랍 진행 중 손님의 칩 교환 요청",
		"턴 / 리버 진행과 추가 베팅 정리",
		"쇼다운 → 메인팟 / 사이드팟 각각 지급",
	]
	for i in range(lines.size()):
		var item := Label.new()
		item.position = Vector2(22, 72 + i * 51)
		item.size = Vector2(620, 34)
		item.text = "0%d   %s" % [i + 1, lines[i]]
		item.add_theme_font_size_override("font_size", 15)
		item.add_theme_color_override("font_color", ACCENT if i == 0 else MUTED)
		preview.add_child(item)


func _build_game() -> void:
	game_layer = Control.new()
	game_layer.position = Vector2(0, 104)
	game_layer.size = Vector2(720, 1176)
	game_layer.visible = false
	add_child(game_layer)

	_build_mission_panel()
	_build_table()
	_build_decision_panel()
	_build_history_panel()


func _build_mission_panel() -> void:
	var mission := Panel.new()
	mission.position = Vector2(24, 10)
	mission.size = Vector2(672, 118)
	mission.add_theme_stylebox_override("panel", _style(PANEL, INFO, 2, 17))
	game_layer.add_child(mission)

	phase_label = Label.new()
	phase_label.position = Vector2(18, 12)
	phase_label.size = Vector2(120, 24)
	phase_label.text = "PREFLOP"
	phase_label.add_theme_color_override("font_color", INFO)
	phase_label.add_theme_font_size_override("font_size", 12)
	mission.add_child(phase_label)

	headline_label = Label.new()
	headline_label.position = Vector2(18, 38)
	headline_label.size = Vector2(636, 28)
	headline_label.text = "현재 미션"
	headline_label.add_theme_font_size_override("font_size", 18)
	headline_label.add_theme_color_override("font_color", TEXT)
	mission.add_child(headline_label)

	prompt_label = Label.new()
	prompt_label.position = Vector2(18, 70)
	prompt_label.size = Vector2(636, 38)
	prompt_label.text = ""
	prompt_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prompt_label.add_theme_font_size_override("font_size", 13)
	prompt_label.add_theme_color_override("font_color", MUTED)
	mission.add_child(prompt_label)


func _build_table() -> void:
	table = Panel.new()
	table.position = Vector2(34, 148)
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
	seat.add_child(name_label)
	seat_name_labels.append(name_label)

	var stack_label := Label.new()
	stack_label.position = Vector2(8, 30)
	stack_label.size = Vector2(138, 22)
	stack_label.text = "%s" % _format_amount(PLAYER_STACKS[index])
	stack_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stack_label.add_theme_font_size_override("font_size", 13)
	stack_label.add_theme_color_override("font_color", ACCENT)
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
	seat.add_child(state_label)
	seat_state_labels.append(state_label)


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
		label.text = BOARD_VALUES[i]
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 15)
		label.add_theme_color_override("font_color", Color("171b20"))
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
	request_panel.add_theme_stylebox_override("panel", _style(Color("282136"), Color("a77fe8"), 2, 13))
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


func _build_decision_panel() -> void:
	var panel := Panel.new()
	panel.position = Vector2(24, 794)
	panel.size = Vector2(672, 230)
	panel.add_theme_stylebox_override("panel", _style(PANEL, LINE, 1, 18))
	game_layer.add_child(panel)

	var title := Label.new()
	title.position = Vector2(18, 12)
	title.size = Vector2(636, 24)
	title.text = "지금 해야 할 딜러 업무를 선택하세요"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", MUTED)
	panel.add_child(title)

	for i in range(3):
		var button := Button.new()
		button.position = Vector2(18, 52 + i * 54)
		button.size = Vector2(636, 46)
		button.text = "-"
		button.add_theme_font_size_override("font_size", 15)
		button.add_theme_stylebox_override("normal", _style(PANEL_2, LINE, 1, 12))
		button.add_theme_stylebox_override("hover", _style(Color("283446"), ACCENT, 1, 12))
		button.add_theme_stylebox_override("pressed", _style(Color("33270f"), ACCENT, 2, 12))
		button.add_theme_color_override("font_color", TEXT)
		button.pressed.connect(_on_choice_pressed.bind(i))
		panel.add_child(button)
		choice_buttons.append(button)


func _build_history_panel() -> void:
	var panel := Panel.new()
	panel.position = Vector2(24, 1042)
	panel.size = Vector2(672, 116)
	panel.add_theme_stylebox_override("panel", _style(Color("111820"), LINE, 1, 15))
	game_layer.add_child(panel)

	var title := Label.new()
	title.position = Vector2(14, 8)
	title.size = Vector2(120, 20)
	title.text = "SHIFT LOG"
	title.add_theme_font_size_override("font_size", 11)
	title.add_theme_color_override("font_color", MUTED)
	panel.add_child(title)

	for i in range(3):
		var line := Label.new()
		line.position = Vector2(14, 32 + i * 25)
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
	subtitle.text = "신입 딜러 첫 근무 완료"
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
	feedback_label.position = Vector2(210, 510)
	feedback_label.size = Vector2(300, 54)
	feedback_label.visible = false
	feedback_label.z_index = 200
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback_label.add_theme_font_size_override("font_size", 17)
	feedback_label.add_theme_stylebox_override("normal", _style(Color("10161de8"), LINE, 1, 14))
	add_child(feedback_label)


func _show_home() -> void:
	session_active = false
	resolving = false
	home_layer.visible = true
	game_layer.visible = false
	complete_layer.visible = false
	level_label.text = "LV.1  신입 딜러"
	cash_label.text = "TIP  %s" % _format_amount(cash)
	crown_label.text = "REP  120"
	accuracy_label.text = "ACC 100%"
	combo_label.text = "COMBO x0"
	timer_label.text = "READY"
	timer_label.add_theme_color_override("font_color", GOOD)


func _start_shift() -> void:
	tasks = RookieShiftScenario.build()
	current_task_index = 0
	session_active = true
	resolving = false
	correct_actions = 0
	mistakes = 0
	combo = 0
	max_combo = 0
	tips = 0

	home_layer.visible = false
	game_layer.visible = true
	complete_layer.visible = false

	for i in range(history_labels.size()):
		history_labels[i].text = "—"

	_apply_task(tasks[current_task_index])
	_refresh_hud()


func _apply_task(task: DealerTask) -> void:
	time_left = task.time_limit
	phase_label.text = task.phase
	headline_label.text = task.headline
	prompt_label.text = task.prompt

	for i in range(choice_buttons.size()):
		if i < task.choices.size():
			choice_buttons[i].text = task.choices[i]
			choice_buttons[i].visible = true
			choice_buttons[i].disabled = false
		else:
			choice_buttons[i].visible = false

	_apply_table_state(task.state)
	_refresh_timer()


func _apply_table_state(state: Dictionary) -> void:
	var board_count: int = int(state.get("board_count", 0))
	for i in range(board_panels.size()):
		board_panels[i].visible = i < board_count

	var main_pot: int = int(state.get("main_pot", 0))
	var side_pot: int = int(state.get("side_pot", 0))
	main_pot_label.text = "MAIN POT  %s" % _format_amount(main_pot)
	side_pot_label.text = "SIDE POT  %s" % _format_amount(side_pot)

	var request_text: String = String(state.get("request", ""))
	request_panel.visible = not request_text.is_empty()
	request_label.text = request_text

	var raw_states: Variant = state.get("seat_states", [])
	if raw_states is Array:
		var values: Array = raw_states as Array
		for i in range(seat_state_labels.size()):
			seat_state_labels[i].text = String(values[i]) if i < values.size() else "WAIT"

	var raw_bets: Variant = state.get("bets", [])
	if raw_bets is Array:
		var bet_values: Array = raw_bets as Array
		for i in range(bet_panels.size()):
			var amount: int = int(bet_values[i]) if i < bet_values.size() else 0
			bet_panels[i].visible = amount > 0
			bet_labels[i].text = _format_amount(amount)

	_reset_seat_styles()
	var raw_highlights: Variant = state.get("highlight_seats", [])
	if raw_highlights is Array:
		for value: Variant in raw_highlights:
			var seat_index: int = int(value)
			if seat_index >= 0 and seat_index < seat_panels.size():
				seat_panels[seat_index].add_theme_stylebox_override(
					"panel",
					_style(Color("2b2618"), ACCENT, 3, 14)
				)

	showdown_panel.visible = current_task_index >= 10
	if showdown_panel.visible:
		showdown_label.text = "SHOWDOWN\n소연  A♠ K♠\n토니  Q♦ Q♣\n찰리  J♣ 10♣"


func _on_choice_pressed(choice_index: int) -> void:
	if not session_active or resolving or current_task_index < 0:
		return

	var task: DealerTask = tasks[current_task_index]
	if choice_index == task.correct_index:
		_resolve_correct(task)
	else:
		_resolve_wrong(task, choice_index)


func _resolve_correct(task: DealerTask) -> void:
	resolving = true
	correct_actions += 1
	combo += 1
	max_combo = maxi(max_combo, combo)

	var ratio: float = time_left / maxf(task.time_limit, 0.01)
	var speed_bonus: int = 0
	if ratio >= 0.65:
		speed_bonus = 80
	elif ratio >= 0.35:
		speed_bonus = 30

	var earned: int = task.base_tip + speed_bonus
	tips += earned
	cash += earned

	_show_feedback(
		("%s  ·  TIP +%d" % [task.success_text, earned]),
		GOOD
	)
	_append_history("✓ %s  +%d" % [task.success_text, earned], GOOD)
	_disable_choices()
	_refresh_hud()

	await _play_action_feedback(task.action_kind)
	await get_tree().create_timer(0.18).timeout

	current_task_index += 1
	if current_task_index >= tasks.size():
		_finish_shift()
		return

	resolving = false
	_apply_task(tasks[current_task_index])


func _resolve_wrong(task: DealerTask, choice_index: int) -> void:
	mistakes += 1
	combo = 0
	time_left = maxf(time_left - 1.5, 0.5)

	var chosen: String = "-"
	if choice_index >= 0 and choice_index < task.choices.size():
		chosen = task.choices[choice_index]

	_show_feedback("잘못된 처리 · %s" % chosen, BAD)
	_append_history("× %s  · 다시 판단" % chosen, BAD)
	_flash_mission(BAD)
	_refresh_hud()


func _handle_timeout() -> void:
	if resolving or current_task_index < 0:
		return

	resolving = true
	var task: DealerTask = tasks[current_task_index]
	mistakes += 1
	combo = 0
	_show_feedback("TIME OUT · FLOOR ASSIST", BAD)
	_append_history("× 시간 초과 · FLOOR ASSIST", BAD)
	_disable_choices()
	_refresh_hud()

	await _play_action_feedback(task.action_kind)
	await get_tree().create_timer(0.35).timeout

	current_task_index += 1
	if current_task_index >= tasks.size():
		_finish_shift()
		return

	resolving = false
	_apply_task(tasks[current_task_index])


func _play_action_feedback(kind: String) -> void:
	match kind:
		"deal":
			for i in range(seat_panels.size()):
				seat_state_labels[i].text = "DEALT 2"
				_flash_panel(seat_panels[i], GOOD)
				await get_tree().create_timer(0.055).timeout
		"collect":
			for bet in bet_panels:
				bet.visible = false
			_pulse_pot(GOOD)
			await get_tree().create_timer(0.32).timeout
		"sidepot":
			main_pot_label.add_theme_color_override("font_color", GOOD)
			side_pot_label.add_theme_color_override("font_color", ACCENT)
			_pulse_pot(ACCENT)
			await get_tree().create_timer(0.38).timeout
		"flop":
			for i in range(3):
				board_panels[i].visible = true
				await get_tree().create_timer(0.10).timeout
		"turn":
			board_panels[3].visible = true
			await get_tree().create_timer(0.30).timeout
		"river":
			board_panels[4].visible = true
			await get_tree().create_timer(0.30).timeout
		"chip_change":
			request_label.text = "칩 교환 완료"
			request_panel.add_theme_stylebox_override("panel", _style(Color("153126"), GOOD, 2, 13))
			await get_tree().create_timer(0.38).timeout
		"main_payout":
			main_pot_label.text = "MAIN POT  지급 완료"
			_flash_panel(seat_panels[2], GOOD)
			await get_tree().create_timer(0.40).timeout
		"side_payout":
			side_pot_label.text = "SIDE POT  지급 완료"
			_flash_panel(seat_panels[5], GOOD)
			await get_tree().create_timer(0.40).timeout
		_:
			await get_tree().create_timer(0.25).timeout


func _finish_shift() -> void:
	session_active = false
	resolving = false
	game_layer.visible = false
	complete_layer.visible = true

	var total: int = maxi(correct_actions + mistakes, 1)
	var accuracy: int = int(round(float(correct_actions) / float(total) * 100.0))
	var result := complete_layer.get_node("Panel/Result") as Label
	if result != null:
		var grade: String = "GOOD SHIFT"
		if accuracy >= 95 and mistakes == 0:
			grade = "PERFECT SHIFT"
		elif accuracy < 70:
			grade = "KEEP TRAINING"
		result.text = "%s\n\n정확도  %d%%\n최대 콤보  x%d\n실수  %d\nTIP BONUS  +%s" % [
			grade,
			accuracy,
			max_combo,
			mistakes,
			_format_amount(tips),
		]

	timer_label.text = "DONE"
	accuracy_label.text = "ACC %d%%" % accuracy
	combo_label.text = "MAX x%d" % max_combo
	cash_label.text = "TIP  %s" % _format_amount(cash)


func _refresh_hud() -> void:
	var total: int = correct_actions + mistakes
	var accuracy: int = 100
	if total > 0:
		accuracy = int(round(float(correct_actions) / float(total) * 100.0))
	accuracy_label.text = "ACC %d%%" % accuracy
	combo_label.text = "COMBO x%d" % combo
	cash_label.text = "TIP  %s" % _format_amount(cash)


func _refresh_timer() -> void:
	timer_label.text = "%04.1f" % time_left
	if time_left <= 2.5:
		timer_label.add_theme_color_override("font_color", BAD)
	elif time_left <= 5.0:
		timer_label.add_theme_color_override("font_color", ACCENT)
	else:
		timer_label.add_theme_color_override("font_color", GOOD)


func _disable_choices() -> void:
	for button in choice_buttons:
		button.disabled = true


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


func _flash_mission(color: Color) -> void:
	var original: Color = prompt_label.get_theme_color("font_color")
	prompt_label.add_theme_color_override("font_color", color)
	var tween := create_tween()
	tween.tween_interval(0.20)
	tween.tween_callback(func() -> void:
		prompt_label.add_theme_color_override("font_color", original)
	)


func _flash_panel(panel: Panel, color: Color) -> void:
	var original_scale: Vector2 = panel.scale
	panel.pivot_offset = panel.size * 0.5
	panel.add_theme_stylebox_override("panel", _style(Color("183126"), color, 3, 14))
	var tween := create_tween()
	tween.tween_property(panel, "scale", Vector2(1.05, 1.05), 0.10)
	tween.tween_property(panel, "scale", original_scale, 0.12)


func _pulse_pot(color: Color) -> void:
	pot_panel.add_theme_stylebox_override("panel", _style(Color("203027"), color, 3, 24))
	var tween := create_tween()
	tween.tween_property(pot_panel, "scale", Vector2(1.08, 1.08), 0.12)
	tween.tween_property(pot_panel, "scale", Vector2.ONE, 0.14)


func _reset_seat_styles() -> void:
	for panel in seat_panels:
		panel.scale = Vector2.ONE
		panel.add_theme_stylebox_override("panel", _style(PANEL, LINE, 2, 14))
	request_panel.add_theme_stylebox_override("panel", _style(Color("282136"), Color("a77fe8"), 2, 13))
	main_pot_label.add_theme_color_override("font_color", ACCENT)
	side_pot_label.add_theme_color_override("font_color", TEXT)
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
