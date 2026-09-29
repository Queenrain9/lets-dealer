extends Control

const BUILD_ID: String = "interaction-runtime-v0.1"

const BG := Color("10141b")
const PANEL := Color("191f29")
const PANEL_2 := Color("222a36")
const FELT := Color("183b34")
const LINE := Color("55606e")
const ACCENT := Color("e8b44d")
const TEXT := Color("f2f4f7")
const MUTED := Color("9ca7b5")
const GOOD := Color("64d694")
const BAD := Color("ff6f6f")

const SEAT_POSITIONS: Array[Vector2] = [
	Vector2(40, 480),
	Vector2(88, 290),
	Vector2(278, 238),
	Vector2(468, 290),
	Vector2(516, 480),
	Vector2(278, 650),
]

const SEAT_NAMES: Array[String] = ["SEAT 1", "SEAT 2", "SEAT 3", "SEAT 4", "SEAT 5", "SEAT 6"]
const BOARD_VALUES: Array[String] = ["A♠", "7♥", "4♣", "J♦", "2♠"]
const BET_VALUES: Array[int] = [800, 1200, 1600, 900, 1800, 1400]
const WINNER_SEAT: int = 2
const SIDEPOT_WINNER_SEAT: int = 4

var phase: String = "home"
var drag_mode: String = ""
var pointer_down: bool = false
var pointer_start: Vector2 = Vector2.ZERO
var pointer_now: Vector2 = Vector2.ZERO
var swept_groups: Dictionary = {}

var deal_index: int = 0
var collect_round: int = 0
var burn_done: bool = false
var mistakes: int = 0
var combo: int = 0
var perfect_actions: int = 0
var session_started_ms: int = 0

var top_status: Label
var mission_label: Label
var accuracy_label: Label
var combo_label: Label
var feedback_label: Label

var home_layer: Control
var career_layer: Control
var game_layer: Control
var complete_layer: Control

var table: Panel
var deck: Panel
var deck_label: Label
var pot: Panel
var pot_label: Label
var sidepot_label: Label
var fan_target: Panel
var street_target: Panel

var seats: Array[Panel] = []
var seat_titles: Array[Label] = []
var seat_states: Array[Label] = []
var chip_groups: Array[Panel] = []
var chip_labels: Array[Label] = []
var board_cards: Array[Panel] = []
var board_labels: Array[Label] = []

var drag_proxy: Panel
var drag_proxy_label: Label


func _ready() -> void:
	set_process_input(true)
	_build_ui()
	_show_home()


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = BG
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	_build_top_hud()
	_build_home()
	_build_career()
	_build_game()
	_build_complete()
	_build_feedback()


func _build_top_hud() -> void:
	var top_bar := Panel.new()
	top_bar.position = Vector2(18, 18)
	top_bar.size = Vector2(684, 76)
	top_bar.add_theme_stylebox_override("panel", _style(PANEL, LINE, 1, 14))
	add_child(top_bar)

	var title := Label.new()
	title.position = Vector2(18, 10)
	title.size = Vector2(360, 28)
	title.text = "LET'S DEALER"
	title.add_theme_font_size_override("font_size", 23)
	title.add_theme_color_override("font_color", TEXT)
	top_bar.add_child(title)

	top_status = Label.new()
	top_status.position = Vector2(18, 42)
	top_status.size = Vector2(360, 20)
	top_status.text = "INTERACTION PROTOTYPE"
	top_status.add_theme_font_size_override("font_size", 12)
	top_status.add_theme_color_override("font_color", MUTED)
	top_bar.add_child(top_status)

	accuracy_label = Label.new()
	accuracy_label.position = Vector2(440, 13)
	accuracy_label.size = Vector2(110, 22)
	accuracy_label.text = "ACC 100%"
	accuracy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	accuracy_label.add_theme_color_override("font_color", TEXT)
	top_bar.add_child(accuracy_label)

	combo_label = Label.new()
	combo_label.position = Vector2(550, 13)
	combo_label.size = Vector2(110, 22)
	combo_label.text = "COMBO x0"
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	combo_label.add_theme_color_override("font_color", ACCENT)
	top_bar.add_child(combo_label)

	mission_label = Label.new()
	mission_label.position = Vector2(440, 42)
	mission_label.size = Vector2(220, 22)
	mission_label.text = "READY"
	mission_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	mission_label.add_theme_color_override("font_color", MUTED)
	top_bar.add_child(mission_label)


func _build_home() -> void:
	home_layer = Control.new()
	home_layer.position = Vector2(0, 110)
	home_layer.size = Vector2(720, 1170)
	add_child(home_layer)

	var hero := Panel.new()
	hero.position = Vector2(32, 44)
	hero.size = Vector2(656, 430)
	hero.add_theme_stylebox_override("panel", _style(PANEL, LINE, 1, 22))
	home_layer.add_child(hero)

	var eyebrow := Label.new()
	eyebrow.position = Vector2(28, 28)
	eyebrow.size = Vector2(600, 24)
	eyebrow.text = "SHIFT 01 · ROOKIE TABLE"
	eyebrow.add_theme_color_override("font_color", ACCENT)
	eyebrow.add_theme_font_size_override("font_size", 13)
	hero.add_child(eyebrow)

	var h1 := Label.new()
	h1.position = Vector2(28, 76)
	h1.size = Vector2(600, 110)
	h1.text = "RUN THE TABLE\nLIKE A REAL DEALER"
	h1.add_theme_font_size_override("font_size", 34)
	h1.add_theme_color_override("font_color", TEXT)
	hero.add_child(h1)

	var desc := Label.new()
	desc.position = Vector2(28, 205)
	desc.size = Vector2(600, 84)
	desc.text = "Deal → sweep bets → burn & open board → payout.\nEvery action is direct manipulation. No wireframe images are used at runtime."
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 16)
	desc.add_theme_color_override("font_color", MUTED)
	hero.add_child(desc)

	var start_button := Button.new()
	start_button.position = Vector2(28, 322)
	start_button.size = Vector2(390, 76)
	start_button.text = "START SHIFT"
	start_button.add_theme_font_size_override("font_size", 20)
	start_button.add_theme_stylebox_override("normal", _style(ACCENT, ACCENT, 0, 14))
	start_button.add_theme_color_override("font_color", Color("20170a"))
	start_button.pressed.connect(_start_shift)
	hero.add_child(start_button)

	var career_button := Button.new()
	career_button.position = Vector2(432, 322)
	career_button.size = Vector2(196, 76)
	career_button.text = "CAREER"
	career_button.add_theme_stylebox_override("normal", _style(PANEL_2, LINE, 1, 14))
	career_button.add_theme_color_override("font_color", TEXT)
	career_button.pressed.connect(_show_career)
	hero.add_child(career_button)

	var checklist := Panel.new()
	checklist.position = Vector2(32, 506)
	checklist.size = Vector2(656, 310)
	checklist.add_theme_stylebox_override("panel", _style(PANEL, LINE, 1, 18))
	home_layer.add_child(checklist)

	var ctitle := Label.new()
	ctitle.position = Vector2(24, 20)
	ctitle.size = Vector2(600, 28)
	ctitle.text = "TODAY'S DEALER LOOP"
	ctitle.add_theme_color_override("font_color", TEXT)
	ctitle.add_theme_font_size_override("font_size", 18)
	checklist.add_child(ctitle)

	var lines := [
		"01  DEAL              card → correct seat",
		"02  COLLECT           one continuous sweep → POT",
		"03  BOARD             burn flick → flop packet / single open",
		"04  PAYOUT            POT → winning seat",
		"05  SIDE POT          only eligible seat receives it",
	]
	for i in range(lines.size()):
		var l := Label.new()
		l.position = Vector2(24, 70 + i * 43)
		l.size = Vector2(600, 30)
		l.text = lines[i]
		l.add_theme_color_override("font_color", MUTED if i > 0 else ACCENT)
		l.add_theme_font_size_override("font_size", 15)
		checklist.add_child(l)


func _build_career() -> void:
	career_layer = Control.new()
	career_layer.position = Vector2(0, 110)
	career_layer.size = Vector2(720, 1170)
	career_layer.visible = false
	add_child(career_layer)

	var title := Label.new()
	title.position = Vector2(32, 42)
	title.size = Vector2(500, 40)
	title.text = "CAREER TABLES"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", TEXT)
	career_layer.add_child(title)

	var back := Button.new()
	back.position = Vector2(566, 34)
	back.size = Vector2(122, 54)
	back.text = "HOME"
	back.pressed.connect(_show_home)
	career_layer.add_child(back)

	_make_venue_card(career_layer, Vector2(32, 126), "ROOKIE HALL", "OPEN", true, _start_shift)
	_make_venue_card(career_layer, Vector2(32, 336), "VIP ROOM", "LOCKED · PERFECT 3 SHIFTS", false, Callable())
	_make_venue_card(career_layer, Vector2(32, 546), "FINAL TABLE", "LOCKED · VIP CLEAR", false, Callable())


func _make_venue_card(parent: Control, pos: Vector2, venue_name: String, state_text: String, unlocked: bool, action: Callable) -> void:
	var card := Panel.new()
	card.position = pos
	card.size = Vector2(656, 174)
	card.add_theme_stylebox_override("panel", _style(PANEL if unlocked else Color("141922"), ACCENT if unlocked else LINE, 2 if unlocked else 1, 18))
	parent.add_child(card)

	var name_label := Label.new()
	name_label.position = Vector2(24, 22)
	name_label.size = Vector2(390, 34)
	name_label.text = venue_name
	name_label.add_theme_font_size_override("font_size", 23)
	name_label.add_theme_color_override("font_color", TEXT if unlocked else MUTED)
	card.add_child(name_label)

	var state_label := Label.new()
	state_label.position = Vector2(24, 72)
	state_label.size = Vector2(500, 28)
	state_label.text = state_text
	state_label.add_theme_color_override("font_color", ACCENT if unlocked else MUTED)
	card.add_child(state_label)

	var button := Button.new()
	button.position = Vector2(462, 52)
	button.size = Vector2(164, 68)
	button.text = "ENTER" if unlocked else "LOCKED"
	button.disabled = not unlocked
	card.add_child(button)
	if unlocked and action.is_valid():
		button.pressed.connect(action)


func _build_game() -> void:
	game_layer = Control.new()
	game_layer.position = Vector2(0, 110)
	game_layer.size = Vector2(720, 1170)
	game_layer.visible = false
	add_child(game_layer)

	table = Panel.new()
	table.position = Vector2(28, 92)
	table.size = Vector2(664, 760)
	table.add_theme_stylebox_override("panel", _style(FELT, Color("745b33"), 6, 54))
	game_layer.add_child(table)

	for i in range(6):
		_create_seat(i)

	_create_board()
	_create_pot()
	_create_bet_groups()
	_create_deck()
	_create_drag_proxy()

	var hint := Label.new()
	hint.position = Vector2(32, 884)
	hint.size = Vector2(656, 84)
	hint.name = "Hint"
	hint.text = "Drag from the deck to the highlighted seat."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_color_override("font_color", MUTED)
	hint.add_theme_font_size_override("font_size", 16)
	game_layer.add_child(hint)

	var quit_button := Button.new()
	quit_button.position = Vector2(32, 1000)
	quit_button.size = Vector2(140, 56)
	quit_button.text = "END SHIFT"
	quit_button.pressed.connect(_show_home)
	game_layer.add_child(quit_button)


func _create_seat(index: int) -> void:
	var seat := Panel.new()
	seat.position = SEAT_POSITIONS[index]
	seat.size = Vector2(108, 112)
	seat.add_theme_stylebox_override("panel", _style(PANEL, LINE, 2, 14))
	table.add_child(seat)
	seats.append(seat)

	var n := Label.new()
	n.position = Vector2(8, 10)
	n.size = Vector2(92, 24)
	n.text = SEAT_NAMES[index]
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	n.add_theme_font_size_override("font_size", 13)
	n.add_theme_color_override("font_color", TEXT)
	seat.add_child(n)
	seat_titles.append(n)

	var s := Label.new()
	s.position = Vector2(6, 40)
	s.size = Vector2(96, 58)
	s.text = "WAIT\n□ □"
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	s.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	s.add_theme_font_size_override("font_size", 13)
	s.add_theme_color_override("font_color", MUTED)
	seat.add_child(s)
	seat_states.append(s)


func _create_board() -> void:
	fan_target = Panel.new()
	fan_target.position = Vector2(188, 252)
	fan_target.size = Vector2(288, 126)
	fan_target.add_theme_stylebox_override("panel", _style(Color("15352f"), Color("315f55"), 2, 18))
	table.add_child(fan_target)

	var fan_label := Label.new()
	fan_label.position = Vector2(0, 4)
	fan_label.size = Vector2(288, 24)
	fan_label.text = "BOARD / FAN AREA"
	fan_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fan_label.add_theme_font_size_override("font_size", 11)
	fan_label.add_theme_color_override("font_color", MUTED)
	fan_target.add_child(fan_label)

	for i in range(5):
		var c := Panel.new()
		c.position = Vector2(17 + i * 52, 38)
		c.size = Vector2(44, 70)
		c.visible = false
		c.add_theme_stylebox_override("panel", _style(Color("f3efe6"), Color("cab176"), 2, 7))
		fan_target.add_child(c)
		board_cards.append(c)

		var l := Label.new()
		l.position = Vector2(0, 0)
		l.size = c.size
		l.text = BOARD_VALUES[i]
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.add_theme_color_override("font_color", Color("161a1f"))
		l.add_theme_font_size_override("font_size", 15)
		c.add_child(l)
		board_labels.append(l)

	street_target = Panel.new()
	street_target.position = Vector2(474, 252)
	street_target.size = Vector2(88, 126)
	street_target.visible = false
	street_target.add_theme_stylebox_override("panel", _style(Color("173a33"), ACCENT, 2, 16))
	table.add_child(street_target)


func _create_pot() -> void:
	pot = Panel.new()
	pot.position = Vector2(252, 412)
	pot.size = Vector2(160, 88)
	pot.add_theme_stylebox_override("panel", _style(Color("202832"), ACCENT, 2, 44))
	table.add_child(pot)

	pot_label = Label.new()
	pot_label.position = Vector2(0, 10)
	pot_label.size = Vector2(160, 30)
	pot_label.text = "POT"
	pot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pot_label.add_theme_color_override("font_color", ACCENT)
	pot_label.add_theme_font_size_override("font_size", 18)
	pot.add_child(pot_label)

	sidepot_label = Label.new()
	sidepot_label.position = Vector2(0, 42)
	sidepot_label.size = Vector2(160, 24)
	sidepot_label.text = "0"
	sidepot_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sidepot_label.add_theme_color_override("font_color", TEXT)
	pot.add_child(sidepot_label)


func _create_bet_groups() -> void:
	var positions: Array[Vector2] = [
		Vector2(150, 490),
		Vector2(174, 344),
		Vector2(286, 326),
		Vector2(402, 344),
		Vector2(426, 490),
		Vector2(286, 588),
	]
	for i in range(6):
		var chip := Panel.new()
		chip.position = positions[i]
		chip.size = Vector2(80, 42)
		chip.visible = false
		chip.add_theme_stylebox_override("panel", _style(Color("6d4b17"), ACCENT, 2, 21))
		table.add_child(chip)
		chip_groups.append(chip)

		var l := Label.new()
		l.position = Vector2(0, 0)
		l.size = chip.size
		l.text = str(BET_VALUES[i])
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.add_theme_color_override("font_color", TEXT)
		l.add_theme_font_size_override("font_size", 12)
		chip.add_child(l)
		chip_labels.append(l)


func _create_deck() -> void:
	deck = Panel.new()
	deck.position = Vector2(272, 896)
	deck.size = Vector2(176, 128)
	deck.add_theme_stylebox_override("panel", _style(Color("27313f"), ACCENT, 3, 16))
	game_layer.add_child(deck)

	deck_label = Label.new()
	deck_label.position = Vector2(0, 0)
	deck_label.size = deck.size
	deck_label.text = "DECK\nDRAG CARD"
	deck_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	deck_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	deck_label.add_theme_color_override("font_color", TEXT)
	deck_label.add_theme_font_size_override("font_size", 17)
	deck.add_child(deck_label)


func _create_drag_proxy() -> void:
	drag_proxy = Panel.new()
	drag_proxy.size = Vector2(76, 104)
	drag_proxy.visible = false
	drag_proxy.z_index = 100
	drag_proxy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	drag_proxy.add_theme_stylebox_override("panel", _style(Color("f3efe6"), ACCENT, 2, 10))
	game_layer.add_child(drag_proxy)

	drag_proxy_label = Label.new()
	drag_proxy_label.position = Vector2(0, 0)
	drag_proxy_label.size = drag_proxy.size
	drag_proxy_label.text = "CARD"
	drag_proxy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	drag_proxy_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	drag_proxy_label.add_theme_color_override("font_color", Color("15191e"))
	drag_proxy_label.add_theme_font_size_override("font_size", 14)
	drag_proxy.add_child(drag_proxy_label)


func _build_complete() -> void:
	complete_layer = Control.new()
	complete_layer.position = Vector2(0, 110)
	complete_layer.size = Vector2(720, 1170)
	complete_layer.visible = false
	add_child(complete_layer)

	var panel := Panel.new()
	panel.position = Vector2(52, 184)
	panel.size = Vector2(616, 544)
	panel.add_theme_stylebox_override("panel", _style(PANEL, ACCENT, 2, 24))
	complete_layer.add_child(panel)

	var title := Label.new()
	title.position = Vector2(28, 36)
	title.size = Vector2(560, 60)
	title.text = "SHIFT COMPLETE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", ACCENT)
	panel.add_child(title)

	var result := Label.new()
	result.name = "Result"
	result.position = Vector2(48, 132)
	result.size = Vector2(520, 180)
	result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	result.add_theme_font_size_override("font_size", 19)
	result.add_theme_color_override("font_color", TEXT)
	panel.add_child(result)

	var replay := Button.new()
	replay.position = Vector2(48, 366)
	replay.size = Vector2(248, 76)
	replay.text = "NEXT SHIFT"
	replay.pressed.connect(_start_shift)
	panel.add_child(replay)

	var home := Button.new()
	home.position = Vector2(320, 366)
	home.size = Vector2(248, 76)
	home.text = "HOME"
	home.pressed.connect(_show_home)
	panel.add_child(home)


func _build_feedback() -> void:
	feedback_label = Label.new()
	feedback_label.z_index = 200
	feedback_label.visible = false
	feedback_label.size = Vector2(220, 40)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	feedback_label.add_theme_stylebox_override("normal", _style(Color("11161dcc"), LINE, 1, 10))
	feedback_label.add_theme_font_size_override("font_size", 13)
	add_child(feedback_label)


func _input(event: InputEvent) -> void:
	if not game_layer.visible:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.pressed:
			_pointer_begin(mouse_event.position)
		else:
			_pointer_end(mouse_event.position)
	elif event is InputEventMouseMotion and pointer_down:
		var motion := event as InputEventMouseMotion
		_pointer_move(motion.position)
	elif event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			_pointer_begin(touch.position)
		else:
			_pointer_end(touch.position)
	elif event is InputEventScreenDrag and pointer_down:
		var drag := event as InputEventScreenDrag
		_pointer_move(drag.position)


func _pointer_begin(p: Vector2) -> void:
	pointer_down = true
	pointer_start = p
	pointer_now = p
	swept_groups.clear()
	drag_mode = ""

	if _deck_rect().has_point(p):
		match phase:
			"deal":
				drag_mode = "deal_card"
				_begin_proxy("CARD", Vector2(76, 104), p)
			"flop_burn", "turn_burn", "river_burn":
				drag_mode = "burn"
				_begin_proxy("BURN", Vector2(68, 94), p)
			"flop_packet":
				drag_mode = "flop_packet"
				_begin_proxy("3-CARD\nPACKET", Vector2(138, 96), p)
			"turn_card", "river_card":
				drag_mode = "street_card"
				_begin_proxy("CARD", Vector2(76, 104), p)
	elif phase == "collect" and _table_rect().has_point(p):
		drag_mode = "sweep"
		_track_sweep(p)
	elif (phase == "payout" or phase == "sidepot") and _pot_rect().has_point(p):
		drag_mode = "payout"
		_begin_proxy("CHIPS", Vector2(100, 60), p)


func _pointer_move(p: Vector2) -> void:
	pointer_now = p
	if drag_mode == "sweep":
		_track_sweep(p)
		_show_feedback("SWEEP", p, ACCENT, 0.08)
	elif drag_proxy.visible:
		drag_proxy.position = p - drag_proxy.size * 0.5
		_update_target_highlights(p)


func _pointer_end(p: Vector2) -> void:
	if not pointer_down:
		return
	pointer_down = false
	pointer_now = p

	match drag_mode:
		"deal_card":
			_resolve_deal(p)
		"sweep":
			_resolve_collect(p)
		"burn":
			_resolve_burn(p)
		"flop_packet":
			_resolve_flop_packet(p)
		"street_card":
			_resolve_street_card(p)
		"payout":
			_resolve_payout(p)
		_:
			_hide_proxy()

	drag_mode = ""
	_clear_target_highlights()


func _resolve_deal(p: Vector2) -> void:
	var expected := deal_index % 6
	if _seat_rect(expected).grow(18).has_point(p):
		_hide_proxy()
		perfect_actions += 1
		combo += 1
		var cards_for_seat := int(deal_index / 6) + 1
		seat_states[expected].text = "DEALT\n" + ("■ " if cards_for_seat >= 1 else "□ ") + ("■" if cards_for_seat >= 2 else "□")
		_flash_seat(expected, GOOD)
		_show_feedback("GOOD DEAL", _seat_center(expected), GOOD)
		deal_index += 1
		if deal_index >= 12:
			await get_tree().create_timer(0.25).timeout
			_enter_collect()
		else:
			_refresh_deal_target()
	else:
		_fail_action("WRONG SEAT", p, _deck_rect().get_center())


func _enter_collect() -> void:
	phase = "collect"
	burn_done = false
	_show_bets(true)
	pot_label.text = "POT"
	sidepot_label.text = _format_amount(_current_pot_total())
	_set_hint("Sweep through multiple BetChipGroups, then finish inside POT.")
	mission_label.text = "COLLECT · SWEEP"
	top_status.text = "NPC BETTING COMPLETE"
	_clear_seat_targets()


func _track_sweep(p: Vector2) -> void:
	for i in range(chip_groups.size()):
		if chip_groups[i].visible and _chip_rect(i).grow(18).has_point(p):
			swept_groups[i] = true
			chip_groups[i].modulate = Color(1.25, 1.25, 1.25, 1.0)


func _resolve_collect(p: Vector2) -> void:
	var reached_pot := _pot_rect().grow(24).has_point(p)
	if reached_pot and swept_groups.size() >= 2:
		perfect_actions += 1
		combo += 1
		_show_feedback("POT ABSORB", _pot_rect().get_center(), GOOD)
		for chip in chip_groups:
			chip.visible = false
			chip.modulate = Color.WHITE
		collect_round += 1
		await get_tree().create_timer(0.25).timeout
		match collect_round:
			1:
				_enter_flop_burn()
			2:
				_enter_turn_burn()
			3:
				_enter_river_burn()
			_:
				_enter_payout()
	else:
		for chip in chip_groups:
			chip.modulate = Color.WHITE
		_fail_action("MISSED POT", p, _pot_rect().get_center())


func _enter_flop_burn() -> void:
	phase = "flop_burn"
	burn_done = false
	deck_label.text = "DECK\nFLICK BURN"
	mission_label.text = "FLOP · BURN"
	top_status.text = "BOARD ACTION"
	_set_hint("Flick one burn card upward from the deck.")


func _enter_turn_burn() -> void:
	phase = "turn_burn"
	burn_done = false
	deck_label.text = "DECK\nFLICK BURN"
	mission_label.text = "TURN · BURN"
	top_status.text = "BOARD ACTION"
	street_target.visible = true
	street_target.position = Vector2(474, 252)
	_set_hint("Burn first. Then drag one card to the Turn target.")


func _enter_river_burn() -> void:
	phase = "river_burn"
	burn_done = false
	deck_label.text = "DECK\nFLICK BURN"
	mission_label.text = "RIVER · BURN"
	top_status.text = "BOARD ACTION"
	street_target.visible = true
	street_target.position = Vector2(548, 252)
	_set_hint("Burn first. Then drag one card to the River target.")


func _resolve_burn(p: Vector2) -> void:
	var dy := pointer_start.y - p.y
	if dy >= 110.0:
		_hide_proxy()
		burn_done = true
		combo += 1
		perfect_actions += 1
		_show_feedback("BURN", p, GOOD)
		if phase == "flop_burn":
			phase = "flop_packet"
			deck_label.text = "DECK\nDRAG 3-CARD PACKET"
			mission_label.text = "FLOP · PACKET FAN"
			_set_hint("Drag the 3-card packet into the Board / Fan Area.")
		elif phase == "turn_burn":
			phase = "turn_card"
			deck_label.text = "DECK\nDRAG TURN"
			mission_label.text = "TURN · OPEN"
		else:
			phase = "river_card"
			deck_label.text = "DECK\nDRAG RIVER"
			mission_label.text = "RIVER · OPEN"
	else:
		_fail_action("BURN FIRST", p, _deck_rect().get_center())


func _resolve_flop_packet(p: Vector2) -> void:
	if burn_done and _fan_rect().grow(24).has_point(p):
		_hide_proxy()
		for i in range(3):
			board_cards[i].visible = true
		perfect_actions += 1
		combo += 1
		_show_feedback("FLOP OPEN", _fan_rect().get_center(), GOOD)
		await get_tree().create_timer(0.3).timeout
		_prepare_postflop_betting()
	else:
		_fail_action("FAN AREA", p, _deck_rect().get_center())


func _resolve_street_card(p: Vector2) -> void:
	var target := _street_rect()
	if burn_done and target.grow(24).has_point(p):
		_hide_proxy()
		var index := 3 if phase == "turn_card" else 4
		board_cards[index].visible = true
		combo += 1
		perfect_actions += 1
		_show_feedback("OPEN", target.get_center(), GOOD)
		await get_tree().create_timer(0.3).timeout
		street_target.visible = false
		_prepare_postflop_betting()
	else:
		_fail_action("WRONG TARGET", p, _deck_rect().get_center())


func _prepare_postflop_betting() -> void:
	deck_label.text = "DECK\nWAIT"
	_show_bets(true)
	phase = "collect"
	mission_label.text = "COLLECT · SWEEP"
	top_status.text = "NPC BETTING COMPLETE"
	_set_hint("Sweep the new betting round into POT.")


func _enter_payout() -> void:
	phase = "payout"
	deck_label.text = "DECK\nHAND OVER"
	mission_label.text = "SHOWDOWN · PAYOUT"
	top_status.text = "WINNER: SEAT 3"
	sidepot_label.text = "MAIN 6,400"
	_mark_winner(WINNER_SEAT)
	_set_hint("Drag the POT to the winning seat.")


func _resolve_payout(p: Vector2) -> void:
	var target_index := WINNER_SEAT if phase == "payout" else SIDEPOT_WINNER_SEAT
	if _seat_rect(target_index).grow(22).has_point(p):
		_hide_proxy()
		combo += 1
		perfect_actions += 1
		_show_feedback("PAID", _seat_center(target_index), GOOD)
		if phase == "payout":
			await get_tree().create_timer(0.3).timeout
			_enter_sidepot()
		else:
			await get_tree().create_timer(0.3).timeout
			_finish_shift()
	else:
		_fail_action("NOT ELIGIBLE" if phase == "sidepot" else "WRONG WINNER", p, _pot_rect().get_center())


func _enter_sidepot() -> void:
	phase = "sidepot"
	_clear_seat_targets()
	_mark_winner(SIDEPOT_WINNER_SEAT)
	mission_label.text = "SIDE POT"
	top_status.text = "ELIGIBLE: SEAT 5"
	pot_label.text = "SIDE POT"
	sidepot_label.text = "1,800"
	_set_hint("Only the eligible seat may receive this side pot.")


func _finish_shift() -> void:
	phase = "complete"
	game_layer.visible = false
	complete_layer.visible = true
	home_layer.visible = false
	career_layer.visible = false
	var result := complete_layer.get_node("Panel/Result") as Label
	if result == null:
		result = _find_result_label()
	if result != null:
		var total_actions: int = maxi(perfect_actions + mistakes, 1)
		var accuracy := int(round(float(perfect_actions) / float(total_actions) * 100.0))
		result.text = "ACCURACY  %d%%\nMAX COMBO  x%d\nMISTAKES  %d\n\nDIRECT-MANIPULATION LOOP COMPLETE" % [accuracy, combo, mistakes]
	mission_label.text = "SHIFT COMPLETE"
	top_status.text = BUILD_ID
	_refresh_stats()


func _find_result_label() -> Label:
	for child in complete_layer.get_children():
		if child is Panel:
			var found := (child as Panel).get_node_or_null("Result") as Label
			if found != null:
				return found
	return null


func _start_shift() -> void:
	phase = "deal"
	deal_index = 0
	collect_round = 0
	burn_done = false
	mistakes = 0
	combo = 0
	perfect_actions = 0
	session_started_ms = Time.get_ticks_msec()

	home_layer.visible = false
	career_layer.visible = false
	complete_layer.visible = false
	game_layer.visible = true

	for i in range(6):
		seat_states[i].text = "WAIT\n□ □"
		seat_states[i].add_theme_color_override("font_color", MUTED)
		seats[i].add_theme_stylebox_override("panel", _style(PANEL, LINE, 2, 14))
	for card in board_cards:
		card.visible = false
	for chip in chip_groups:
		chip.visible = false
		chip.modulate = Color.WHITE

	pot_label.text = "POT"
	sidepot_label.text = "0"
	street_target.visible = false
	deck_label.text = "DECK\nDRAG CARD"
	top_status.text = BUILD_ID
	mission_label.text = "DEAL · 1 / 12"
	_set_hint("Drag from the deck to the highlighted seat.")
	_refresh_deal_target()
	_refresh_stats()


func _refresh_deal_target() -> void:
	_clear_seat_targets()
	var expected := deal_index % 6
	seats[expected].add_theme_stylebox_override("panel", _style(PANEL_2, ACCENT, 4, 14))
	mission_label.text = "DEAL · %d / 12" % (deal_index + 1)


func _clear_seat_targets() -> void:
	for i in range(seats.size()):
		seats[i].add_theme_stylebox_override("panel", _style(PANEL, LINE, 2, 14))


func _mark_winner(index: int) -> void:
	_clear_seat_targets()
	seats[index].add_theme_stylebox_override("panel", _style(Color("33270f"), ACCENT, 4, 14))


func _update_target_highlights(p: Vector2) -> void:
	if drag_mode == "deal_card":
		var expected := deal_index % 6
		if _seat_rect(expected).grow(18).has_point(p):
			seats[expected].add_theme_stylebox_override("panel", _style(Color("173222"), GOOD, 4, 14))
	elif drag_mode == "flop_packet" and _fan_rect().grow(24).has_point(p):
		fan_target.add_theme_stylebox_override("panel", _style(Color("183f35"), GOOD, 3, 18))
	elif drag_mode == "street_card" and _street_rect().grow(24).has_point(p):
		street_target.add_theme_stylebox_override("panel", _style(Color("183f35"), GOOD, 3, 16))


func _clear_target_highlights() -> void:
	if phase == "deal":
		_refresh_deal_target()
	fan_target.add_theme_stylebox_override("panel", _style(Color("15352f"), Color("315f55"), 2, 18))
	street_target.add_theme_stylebox_override("panel", _style(Color("173a33"), ACCENT, 2, 16))


func _show_bets(show: bool) -> void:
	for i in range(chip_groups.size()):
		chip_groups[i].visible = show
		chip_groups[i].modulate = Color.WHITE
		chip_labels[i].text = _format_amount(BET_VALUES[i])


func _current_pot_total() -> int:
	var total := 0
	for value in BET_VALUES:
		total += value
	return total


func _begin_proxy(label_text: String, proxy_size: Vector2, p: Vector2) -> void:
	drag_proxy.size = proxy_size
	drag_proxy_label.size = proxy_size
	drag_proxy_label.text = label_text
	drag_proxy.position = p - proxy_size * 0.5
	drag_proxy.visible = true


func _hide_proxy() -> void:
	drag_proxy.visible = false


func _fail_action(message: String, at: Vector2, return_to: Vector2) -> void:
	mistakes += 1
	combo = 0
	_show_feedback(message, at, BAD)
	if drag_proxy.visible:
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(drag_proxy, "position", return_to - drag_proxy.size * 0.5, 0.22)
		tween.tween_callback(_hide_proxy)
	_refresh_stats()


func _flash_seat(index: int, color: Color) -> void:
	seats[index].add_theme_stylebox_override("panel", _style(Color("173222"), color, 4, 14))
	var tween := create_tween()
	tween.tween_interval(0.18)
	tween.tween_callback(_refresh_deal_target)


func _show_feedback(message: String, at: Vector2, color: Color, duration: float = 0.65) -> void:
	feedback_label.text = message
	feedback_label.position = at - Vector2(110, 20)
	feedback_label.add_theme_color_override("font_color", color)
	feedback_label.modulate = Color.WHITE
	feedback_label.visible = true
	var tween := create_tween()
	tween.tween_interval(duration)
	tween.tween_property(feedback_label, "modulate:a", 0.0, 0.18)
	tween.tween_callback(func() -> void: feedback_label.visible = false)


func _set_hint(text: String) -> void:
	var hint := game_layer.get_node_or_null("Hint") as Label
	if hint != null:
		hint.text = text


func _refresh_stats() -> void:
	var total_actions := perfect_actions + mistakes
	var accuracy := 100
	if total_actions > 0:
		accuracy = int(round(float(perfect_actions) / float(total_actions) * 100.0))
	accuracy_label.text = "ACC %d%%" % accuracy
	combo_label.text = "COMBO x%d" % combo


func _show_home() -> void:
	phase = "home"
	home_layer.visible = true
	career_layer.visible = false
	game_layer.visible = false
	complete_layer.visible = false
	top_status.text = BUILD_ID
	mission_label.text = "READY"
	accuracy_label.text = "ACC 100%"
	combo_label.text = "COMBO x0"
	feedback_label.visible = false
	_hide_proxy()


func _show_career() -> void:
	phase = "career"
	home_layer.visible = false
	career_layer.visible = true
	game_layer.visible = false
	complete_layer.visible = false
	top_status.text = "CAREER"
	mission_label.text = "SELECT TABLE"


func _deck_rect() -> Rect2:
	return Rect2(game_layer.position + deck.position, deck.size)


func _table_rect() -> Rect2:
	return Rect2(game_layer.position + table.position, table.size)


func _pot_rect() -> Rect2:
	return Rect2(game_layer.position + table.position + pot.position, pot.size)


func _seat_rect(index: int) -> Rect2:
	return Rect2(game_layer.position + table.position + seats[index].position, seats[index].size)


func _seat_center(index: int) -> Vector2:
	return _seat_rect(index).get_center()


func _chip_rect(index: int) -> Rect2:
	return Rect2(game_layer.position + table.position + chip_groups[index].position, chip_groups[index].size)


func _fan_rect() -> Rect2:
	return Rect2(game_layer.position + table.position + fan_target.position, fan_target.size)


func _street_rect() -> Rect2:
	return Rect2(game_layer.position + table.position + street_target.position, street_target.size)


func _format_amount(value: int) -> String:
	var raw := str(value)
	var out := ""
	var count := 0
	for i in range(raw.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			out = "," + out
		out = raw[i] + out
		count += 1
	return out


func _style(bg: Color, border: Color, width: int, radius: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.border_width_left = width
	s.border_width_top = width
	s.border_width_right = width
	s.border_width_bottom = width
	s.corner_radius_top_left = radius
	s.corner_radius_top_right = radius
	s.corner_radius_bottom_left = radius
	s.corner_radius_bottom_right = radius
	return s
