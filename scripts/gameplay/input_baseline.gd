extends Control

const BUILD_ID: String = "input-baseline-001"

@onready var build_label: Label = $BuildLabel
@onready var phase_label: Label = $PhaseLabel
@onready var status_label: Label = $StatusLabel
@onready var pot_label: Label = $Table/PotLabel
@onready var target_label: Label = $Table/TargetLabel
@onready var card_button: Button = $CardButton
@onready var start_button: Button = $StartHandButton
@onready var chip20_button: Button = $Table/Chip20Button
@onready var chip40a_button: Button = $Table/Chip40AButton
@onready var chip40b_button: Button = $Table/Chip40BButton
@onready var flop_button: Button = $OpenFlopButton

var deal_count: int = 0
var pot: int = 0
var phase: String = "IDLE"

func _ready() -> void:
	build_label.text = "BUILD · " + BUILD_ID
	_reset_ui()

func _reset_ui() -> void:
	phase = "IDLE"
	deal_count = 0
	pot = 0
	phase_label.text = "PHASE · IDLE"
	status_label.text = "START HAND를 누르면 바로 입력 테스트가 시작됩니다."
	target_label.text = "NEXT · —"
	pot_label.text = "POT 0"

	start_button.disabled = false
	card_button.visible = false
	card_button.disabled = true
	flop_button.visible = false
	flop_button.disabled = true

	_reset_chip_button(chip20_button, "20")
	_reset_chip_button(chip40a_button, "40")
	_reset_chip_button(chip40b_button, "40")

func _reset_chip_button(button: Button, amount_text: String) -> void:
	button.text = amount_text
	button.visible = false
	button.disabled = true

func _on_start_hand_button_down() -> void:
	phase = "DEALING"
	deal_count = 0
	pot = 0

	phase_label.text = "PHASE · DEALING"
	status_label.text = "입력 OK · 카드 버튼을 8번 눌러주세요."
	pot_label.text = "POT 0"
	start_button.disabled = true
	card_button.visible = true
	card_button.disabled = false
	card_button.text = "DEAL CARD · 0 / 8"
	_update_deal_target()

func _on_card_button_down() -> void:
	if phase != "DEALING":
		return

	deal_count += 1
	var player_number: int = ((deal_count - 1) % 4) + 1
	status_label.text = "CARD %d / 8 → Player %d" % [deal_count, player_number]
	card_button.text = "DEAL CARD · %d / 8" % deal_count

	if deal_count >= 8:
		_enter_collect_bets()
	else:
		_update_deal_target()

func _update_deal_target() -> void:
	var next_player: int = (deal_count % 4) + 1
	target_label.text = "NEXT · Player %d" % next_player

func _enter_collect_bets() -> void:
	phase = "COLLECT_BETS"
	phase_label.text = "PHASE · COLLECT BETS"
	status_label.text = "카드 8장 완료 · 20 / 40 / 40 칩을 눌러주세요."
	target_label.text = "BETTING STACKS"
	card_button.visible = false
	card_button.disabled = true

	chip20_button.visible = true
	chip20_button.disabled = false
	chip40a_button.visible = true
	chip40a_button.disabled = false
	chip40b_button.visible = true
	chip40b_button.disabled = false

func _on_chip20_button_down() -> void:
	_collect_chip(chip20_button, 20)

func _on_chip40a_button_down() -> void:
	_collect_chip(chip40a_button, 40)

func _on_chip40b_button_down() -> void:
	_collect_chip(chip40b_button, 40)

func _collect_chip(button: Button, amount: int) -> void:
	if phase != "COLLECT_BETS" or button.disabled:
		return

	button.disabled = true
	button.visible = false
	pot += amount
	pot_label.text = "POT %d" % pot
	status_label.text = "칩 수거 +%d · POT %d" % [amount, pot]

	if pot >= 100:
		phase = "FLOP_READY"
		phase_label.text = "PHASE · FLOP READY"
		status_label.text = "POT 100 완료 · OPEN FLOP을 눌러주세요."
		target_label.text = "POT COMPLETE"
		flop_button.visible = true
		flop_button.disabled = false

func _on_open_flop_button_down() -> void:
	if phase != "FLOP_READY":
		return

	phase = "FLOP"
	phase_label.text = "PHASE · FLOP"
	status_label.text = "INPUT BASELINE COMPLETE · 클릭 입력 정상"
	target_label.text = "FLOP · [ ? ] [ ? ] [ ? ]"
	flop_button.disabled = true
	flop_button.text = "FLOP OPENED"
