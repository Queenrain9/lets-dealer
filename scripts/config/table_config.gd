extends Resource
class_name TableConfig

@export var id: StringName = &"prototype"
@export var display_name: String = "Prototype Table"
@export_range(2, 10, 1) var seat_count: int = 4
@export var starting_stack: int = 1000
@export var small_blind: int = 10
@export var big_blind: int = 20
@export_range(1, 4, 1) var cards_per_player: int = 2
