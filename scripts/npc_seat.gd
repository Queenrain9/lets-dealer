extends Control
## Replace Portrait.texture with a transparent character image later.

var card_count: int = 0
var _target: bool = false
var _accent := Color("70c7b7")

@onready var drop_zone: Panel = %DropZone
@onready var portrait: TextureRect = %Portrait
@onready var slots: Array[Panel] = [%Slot0, %Slot1]

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	_refresh()

func configure(npc_name: String, personality: String, accent: Color) -> void:
	%NameLabel.text = npc_name
	%PersonalityLabel.text = personality
	_accent = accent
	queue_redraw()

func get_drop_rect() -> Rect2:
	return drop_zone.get_global_rect()

func receive_card() -> void:
	card_count = mini(2, card_count + 1)
	_refresh()

func reset_cards() -> void:
	card_count = 0
	_refresh()

func set_target(value: bool) -> void:
	if _target != value:
		_target = value
		_refresh()

func _refresh() -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.028, 0.10, 0.087, 0.87)
	box.border_color = Color("e6bd72") if _target else Color("3e675a")
	box.set_border_width_all(2 if _target else 1)
	box.set_corner_radius_all(18)
	drop_zone.add_theme_stylebox_override("panel", box)
	%TargetLabel.visible = _target
	%CountLabel.text = "%d / 2장" % card_count
	for index in range(2):
		var slot_box := StyleBoxFlat.new()
		slot_box.bg_color = Color("4b2932") if index < card_count else Color("102d24")
		slot_box.border_color = Color("c29d66") if index < card_count else Color("3d6555")
		slot_box.set_border_width_all(1)
		slot_box.set_corner_radius_all(7)
		slots[index].add_theme_stylebox_override("panel", slot_box)
		slots[index].get_node("Mark").text = "♠" if index < card_count else str(index + 1)
	queue_redraw()

func _draw() -> void:
	if not is_node_ready() or portrait.texture != null:
		return
	var center := Vector2(size.x * 0.5, 48)
	draw_circle(center + Vector2(0, 4), 38, Color(0, 0, 0, 0.25))
	draw_circle(center, 37, Color("17372e"))
	draw_arc(center, 37, 0, TAU, 48, Color("e6bd72") if _target else Color("5c7162"), 2.0, true)
	draw_circle(center + Vector2(0, -7), 12, _accent)
	draw_arc(center + Vector2(0, 23), 21, PI, TAU, 24, _accent, 18.0, true)
