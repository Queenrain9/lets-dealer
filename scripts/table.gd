extends Control

const RoundRules = preload("res://scripts/deal_round.gd")
const NPC_NAMES: Array[String] = ["지민", "맥스", "소연"]

var round = RoundRules.new()
var _message: String = "금색으로 표시된 손님의 카드 영역에 놓아주세요."
var _message_error: bool = false

@onready var card: Control = %DealCard
@onready var seats: Array[Control] = [%Seat0, %Seat1, %Seat2]
@onready var result_panel: Control = %ResultPanel

func _ready() -> void:
	_apply_theme()
	seats[0].configure("지민", "차분한 손님", Color("8bd3b7"))
	seats[1].configure("맥스", "단골 손님", Color("d3ad79"))
	seats[2].configure("소연", "친절한 손님", Color("d5a3b4"))
	card.drag_started.connect(_on_drag_started)
	card.dropped.connect(_on_card_dropped)
	%PauseButton.pressed.connect(toggle_pause)
	%RestartButton.pressed.connect(restart_training)
	result_panel.get_node("ResultCard/AgainButton").pressed.connect(restart_training)
	result_panel.hide()
	_refresh()

func _process(delta: float) -> void:
	var previous_phase: String = round.phase
	round.tick(delta)
	_update_timer()
	if round.phase != previous_phase:
		_refresh()

func _notification(what: int) -> void:
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT and is_node_ready():
		round.set_paused(true)
		card.cancel_drag()
		_refresh()

func _on_drag_started() -> void:
	round.start()
	_message_error = false
	_message = "카드 영역 안에 손가락을 놓아 배분하세요."
	_refresh()

func _on_card_dropped(point: Vector2) -> void:
	var destination: int = -1
	for index in range(seats.size()):
		if seats[index].get_drop_rect().has_point(point):
			destination = index
			break
	var outcome: String = round.attempt_drop(destination)
	_message_error = outcome == "wrong_seat"
	if outcome == "accepted":
		seats[destination].receive_card()
		_message = "정확한 배분! 다음 손님에게 이어서 주세요."
	elif outcome == "wrong_seat":
		_message = "배분 순서를 확인하세요. 실수 %d / 3회" % round.mistakes
	elif outcome == "outside":
		_message = "카드가 돌아왔어요. 손님의 카드 영역에 놓아주세요."
	card.return_home()
	_refresh()

func restart_training() -> void:
	card.cancel_drag()
	round.reset()
	for seat in seats:
		seat.reset_cards()
	result_panel.hide()
	_message_error = false
	_message = "금색으로 표시된 손님의 카드 영역에 놓아주세요."
	_refresh()

func toggle_pause() -> void:
	round.set_paused(not round.paused)
	card.cancel_drag()
	_refresh()

func _update_timer() -> void:
	var seconds: int = ceili(round.remaining)
	%TimerValue.text = "%02d:%02d" % [int(float(seconds) / 60.0), seconds % 60]
	%TimerValue.add_theme_color_override("font_color", Color("e99d80") if seconds <= 10 else Color("f0d9ab"))

func _refresh() -> void:
	_update_timer()
	%ProgressValue.text = "%d / 6" % round.dealt_count
	%AccuracyValue.text = "%d%%" % round.accuracy()
	%MistakesLabel.text = "실수 %d / 3" % round.mistakes
	%PauseButton.text = "계속하기" if round.paused else "일시정지"
	%PauseButton.disabled = round.phase == "completed" or round.phase == "failed"
	card.set_enabled(not round.paused and (round.phase == "ready" or round.phase == "active"))
	for index in range(seats.size()):
		seats[index].set_target(index == round.expected_seat() and not round.paused)
	if round.paused:
		%MissionText.text = "잠시 쉬어가세요"
		%HintLabel.text = "계속하기를 누르면 훈련이 이어집니다."
	else:
		%HintLabel.text = _message
		%HintLabel.add_theme_color_override("font_color", Color("eda18d") if _message_error else Color("c0cebd"))
		var target: int = round.expected_seat()
		if target >= 0:
			var ordinal: String = "첫 번째" if round.dealt_count < 3 else "두 번째"
			%MissionText.text = "%s에게 %s 카드를 주세요" % [NPC_NAMES[target], ordinal]
	if round.phase == "completed" or round.phase == "failed":
		_show_result()

func _show_result() -> void:
	var success: bool = round.phase == "completed"
	%MissionText.text = "배분 훈련 완료" if success else "다시 도전해보세요"
	result_panel.get_node("ResultCard/ResultBadge").text = "PERFECT DEAL" if success and round.mistakes == 0 else ("TRAINING CLEAR" if success else "TRY AGAIN")
	result_panel.get_node("ResultCard/ResultTitle").text = "배분 훈련 완료" if success else "배분 훈련 실패"
	result_panel.get_node("ResultCard/ResultDescription").text = "세 손님에게 카드를 정확히 배분했어요." if success else ("제한 시간이 끝났어요." if round.remaining <= 0.0 else "배분 순서 실수가 3회 누적됐어요.")
	result_panel.get_node("ResultCard/ResultStats").text = "배분 %d / 6장   ·   정확도 %d%%\n실수 %d회   ·   소요 시간 %d초" % [round.dealt_count, round.accuracy(), round.mistakes, ceili(60.0 - round.remaining)]
	result_panel.show()

func _box(background: Color, border: Color, radius: int = 18, width: int = 1) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = background
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(radius)
	return box

func _apply_theme() -> void:
	var ui_theme := Theme.new()
	var system_font := SystemFont.new()
	system_font.font_names = PackedStringArray(["Malgun Gothic", "Noto Sans CJK KR", "Noto Sans KR", "sans-serif"])
	ui_theme.default_font = system_font
	ui_theme.default_font_size = 20
	ui_theme.set_color("font_color", "Label", Color("f3ecd9"))
	ui_theme.set_color("font_color", "Button", Color("f3ecd9"))
	ui_theme.set_color("font_hover_color", "Button", Color("ffffff"))
	ui_theme.set_color("font_disabled_color", "Button", Color("748276"))
	ui_theme.set_stylebox("normal", "Button", _box(Color("233f32"), Color("7b825c"), 14))
	ui_theme.set_stylebox("hover", "Button", _box(Color("315540"), Color("d8bd7b"), 14))
	ui_theme.set_stylebox("pressed", "Button", _box(Color("183024"), Color("f0d49a"), 14, 2))
	ui_theme.set_stylebox("disabled", "Button", _box(Color("1b2924"), Color("3c4a3f"), 14))
	ui_theme.set_stylebox("focus", "Button", _box(Color(0, 0, 0, 0), Color("efca83"), 14, 2))
	theme = ui_theme
	%MissionPanel.add_theme_stylebox_override("panel", _box(Color("16392f"), Color("6aa889"), 20))
	for panel in [%TimePanel, %ProgressPanel, %AccuracyPanel]:
		panel.add_theme_stylebox_override("panel", _box(Color("182a27"), Color("435349"), 16))
	%LevelBadge.add_theme_stylebox_override("panel", _box(Color("312d22"), Color("b89760"), 18))
	result_panel.get_node("ResultCard").add_theme_stylebox_override("panel", _box(Color("172d27"), Color("c9a367"), 24, 2))
