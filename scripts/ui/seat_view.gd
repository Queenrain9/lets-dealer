extends PanelContainer
class_name SeatView

@export var seat_index: int = 0

@onready var name_label: Label = $Content/NameLabel
@onready var stack_label: Label = $Content/StackLabel
@onready var card_row: HBoxContainer = $Content/CardRow

var _targeted: bool = false
var _hovered: bool = false

func configure(index: int, player_name: String, stack: int) -> void:
	seat_index = index
	name_label.text = player_name
	stack_label.text = "Stack %d" % stack
	_update_tint()

func get_drop_rect() -> Rect2:
	return get_global_rect()

func set_targeted(value: bool) -> void:
	_targeted = value
	_update_tint()

func set_hovered(value: bool) -> void:
	_hovered = value
	_update_tint()

func clear_cards() -> void:
	for child in card_row.get_children():
		child.queue_free()

func add_card(card_id: String) -> void:
	var card_panel := PanelContainer.new()
	card_panel.custom_minimum_size = Vector2(44, 58)

	var card_label := Label.new()
	card_label.text = card_id
	card_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	card_panel.add_child(card_label)

	card_row.add_child(card_panel)

func _update_tint() -> void:
	if _hovered:
		self_modulate = Color(0.72, 1.0, 0.80, 1.0)
	elif _targeted:
		self_modulate = Color(1.0, 0.92, 0.55, 1.0)
	else:
		self_modulate = Color.WHITE
