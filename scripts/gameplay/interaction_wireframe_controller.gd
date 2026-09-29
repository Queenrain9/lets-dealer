extends Control

const BUILD_ID := "interaction-wireframes-v1.2"
const WIREFRAME_DIR := "res://docs/wireframes/lets_dealer_interaction_wireframes_v1_2/"

const SCREEN_FILES := {
	"home": "01_HOME_DEFAULT.png",
	"deal_default": "02A_DEAL_DEFAULT.png",
	"deal_dragging": "02B_DEAL_DRAGGING.png",
	"deal_valid": "02C_DEAL_VALID_TARGET.png",
	"deal_success": "02D_DEAL_SUCCESS.png",
	"deal_failure": "02E_DEAL_FAILURE.png",
	"collect_default": "03A_COLLECT_DEFAULT.png",
	"collect_sweeping": "03B_COLLECT_SWEEPING.png",
	"collect_absorb": "03C_COLLECT_POT_ABSORB.png",
	"collect_success": "03D_COLLECT_SUCCESS.png",
	"collect_failure": "03E_COLLECT_FAILURE.png",
	"flop_default": "04A_FLOP_DEFAULT.png",
	"flop_burn": "04B_FLOP_BURN_FLICK.png",
	"flop_packet": "04C_FLOP_PACKET_SELECTED.png",
	"flop_valid": "04D_FLOP_VALID_FAN.png",
	"flop_success": "04E_FLOP_SUCCESS.png",
	"turn_default": "04F_TURN_DEFAULT.png",
	"turn_single": "04G_TURN_SINGLE_OPEN.png",
	"river_success": "04H_RIVER_SUCCESS.png",
	"board_failure": "04I_BOARD_FAILURE_SEQUENCE.png",
	"payout_default": "05A_PAYOUT_DEFAULT.png",
	"payout_dragging": "05B_PAYOUT_DRAGGING.png",
	"payout_success": "05C_PAYOUT_SUCCESS.png",
	"payout_failure": "05D_PAYOUT_FAILURE.png",
	"sidepot_default": "06A_SIDEPOT_DEFAULT.png",
	"sidepot_dragging": "06B_SIDEPOT_DRAGGING.png",
	"sidepot_valid": "06C_SIDEPOT_VALID_TARGET.png",
	"sidepot_success": "06D_SIDEPOT_SUCCESS.png",
	"sidepot_failure": "06E_SIDEPOT_FAILURE.png",
	"shift_complete": "07_SHIFT_COMPLETE.png",
	"career": "08A_CAREER_DEFAULT.png",
	"career_locked": "08B_CAREER_SELECT_LOCKED.png",
	"vip_default": "09A_VIP_DEFAULT.png",
	"vip_success": "09B_VIP_SUCCESS.png",
	"final_default": "10A_FINAL_DEFAULT.png",
	"final_success": "10B_FINAL_SUCCESS.png",
}

const SEAT_TARGETS := [
	Vector2(0.17, 0.58),
	Vector2(0.20, 0.37),
	Vector2(0.50, 0.30),
	Vector2(0.80, 0.37),
	Vector2(0.83, 0.58),
	Vector2(0.50, 0.69),
]
const CHIP_GROUPS := [
	Vector2(0.27, 0.56),
	Vector2(0.30, 0.42),
	Vector2(0.50, 0.38),
	Vector2(0.70, 0.42),
	Vector2(0.73, 0.56),
	Vector2(0.50, 0.61),
]
const DECK_CENTER := Vector2(0.50, 0.82)
const POT_CENTER := Vector2(0.50, 0.50)
const FLOP_FAN_CENTER := Vector2(0.50, 0.46)
const TURN_TARGET := Vector2(0.66, 0.46)
const RIVER_TARGET := Vector2(0.76, 0.46)

@onready var screen: TextureRect = $Screen

var phase := "home"
var current_visual := ""
var feedback_locked := false

var pointer_down := false
var pointer_start := Vector2.ZERO
var pointer_last := Vector2.ZERO
var pointer_path: Array[Vector2] = []

var deal_index := 0
var collect_round := 0
var burn_done := false
var swept_groups: Dictionary = {}

var mistakes := 0
var combo := 0


func _ready() -> void:
	set_process_input(true)
	_show_visual("home")


func _input(event: InputEvent) -> void:
	if feedback_locked:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		_handle_debug_key(event.keycode)
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var p := _normalized(event.position)
		if event.pressed:
			_begin_pointer(p)
		else:
			_end_pointer(p)
		return

	if event is InputEventMouseMotion and pointer_down:
		_move_pointer(_normalized(event.position))
		return

	if event is InputEventScreenTouch:
		var p := _normalized(event.position)
		if event.pressed:
			_begin_pointer(p)
		else:
			_end_pointer(p)
		return

	if event is InputEventScreenDrag and pointer_down:
		_move_pointer(_normalized(event.position))


func _begin_pointer(p: Vector2) -> void:
	pointer_down = true
	pointer_start = p
	pointer_last = p
	pointer_path.clear()
	pointer_path.append(p)
	swept_groups.clear()
	_track_collect_groups(p)


func _move_pointer(p: Vector2) -> void:
	pointer_last = p
	pointer_path.append(p)

	match phase:
		"deal":
			var expected: Vector2 = SEAT_TARGETS[deal_index % SEAT_TARGETS.size()]
			if p.distance_to(expected) <= 0.16:
				_show_visual("deal_valid")
			else:
				_show_visual("deal_dragging")
		"collect":
			_track_collect_groups(p)
			if p.distance_to(POT_CENTER) <= 0.18:
				_show_visual("collect_absorb")
			else:
				_show_visual("collect_sweeping")
		"flop_burn":
			_show_visual("flop_burn")
		"flop_packet":
			if p.distance_to(FLOP_FAN_CENTER) <= 0.20:
				_show_visual("flop_valid")
			else:
				_show_visual("flop_packet")
		"turn_card":
			_show_visual("turn_single")
		"river_card":
			_show_visual("turn_single")
		"payout":
			_show_visual("payout_dragging")
		"sidepot":
			if p.distance_to(SEAT_TARGETS[4]) <= 0.18:
				_show_visual("sidepot_valid")
			else:
				_show_visual("sidepot_dragging")


func _end_pointer(p: Vector2) -> void:
	if not pointer_down:
		return

	pointer_down = false
	pointer_last = p
	pointer_path.append(p)

	var travel := pointer_start.distance_to(p)
	if travel < 0.035:
		_handle_tap(p)
		return

	match phase:
		"deal":
			_resolve_deal(p)
		"collect":
			_resolve_collect(p)
		"flop_burn":
			_resolve_burn(p, "flop_packet")
		"flop_packet":
			_resolve_flop_packet(p)
		"turn_burn":
			_resolve_burn(p, "turn_card")
		"turn_card":
			_resolve_single_board(p, TURN_TARGET, false)
		"river_burn":
			_resolve_burn(p, "river_card")
		"river_card":
			_resolve_single_board(p, RIVER_TARGET, true)
		"payout":
			_resolve_payout(p)
		"sidepot":
			_resolve_sidepot(p)
		"vip":
			_resolve_special_table(p, false)
		"final":
			_resolve_special_table(p, true)


func _handle_tap(p: Vector2) -> void:
	match phase:
		"home":
			if p.x > 0.58 and p.y < 0.48:
				_enter_career()
			else:
				_start_shift()
		"shift_complete":
			if p.x >= 0.5:
				_enter_career()
			else:
				_show_home()
		"career":
			if p.x < 0.46:
				phase = "career_locked"
				_show_visual("career_locked")
			else:
				phase = "vip"
				_show_visual("vip_default")
		"career_locked":
			phase = "career"
			_show_visual("career")
		"vip":
			# The same gameplay base is reused; a tap resets the special-table prompt.
			_show_visual("vip_default")
		"final":
			_show_visual("final_default")
		_:
			pass


func _start_shift() -> void:
	deal_index = 0
	collect_round = 0
	burn_done = false
	mistakes = 0
	combo = 0
	phase = "deal"
	_show_visual("deal_default")


func _resolve_deal(end: Vector2) -> void:
	var expected: Vector2 = SEAT_TARGETS[deal_index % SEAT_TARGETS.size()]
	var started_from_deck := pointer_start.distance_to(DECK_CENTER) <= 0.34
	var valid_target := end.distance_to(expected) <= 0.18

	if started_from_deck and valid_target:
		deal_index += 1
		combo += 1
		await _feedback("deal_success", 0.24)
		if deal_index >= 12:
			_enter_collect()
		else:
			_show_visual("deal_default")
	else:
		_register_mistake()
		await _feedback("deal_failure", 0.34)
		_show_visual("deal_default")


func _enter_collect() -> void:
	phase = "collect"
	swept_groups.clear()
	_show_visual("collect_default")


func _track_collect_groups(p: Vector2) -> void:
	if phase != "collect":
		return
	for index in range(CHIP_GROUPS.size()):
		if p.distance_to(CHIP_GROUPS[index]) <= 0.14:
			swept_groups[index] = true


func _resolve_collect(end: Vector2) -> void:
	var x_min := pointer_start.x
	var x_max := pointer_start.x
	for point in pointer_path:
		x_min = minf(x_min, point.x)
		x_max = maxf(x_max, point.x)

	var crossed_felt := (x_max - x_min) >= 0.38
	var gathered_multiple := swept_groups.size() >= 2
	var reached_pot := end.distance_to(POT_CENTER) <= 0.20

	if reached_pot and (crossed_felt or gathered_multiple):
		combo += 1
		await _feedback("collect_absorb", 0.16)
		await _feedback("collect_success", 0.26)
		collect_round += 1
		match collect_round:
			1:
				_enter_flop()
			2:
				_enter_turn()
			3:
				_enter_river()
			_:
				_enter_payout()
	else:
		_register_mistake()
		await _feedback("collect_failure", 0.34)
		_show_visual("collect_default")


func _enter_flop() -> void:
	burn_done = false
	phase = "flop_burn"
	_show_visual("flop_default")


func _enter_turn() -> void:
	burn_done = false
	phase = "turn_burn"
	_show_visual("turn_default")


func _enter_river() -> void:
	burn_done = false
	phase = "river_burn"
	_show_visual("turn_default")


func _resolve_burn(end: Vector2, next_phase: String) -> void:
	var upward_flick := pointer_start.y - end.y >= 0.12
	var started_low := pointer_start.y >= 0.62

	if upward_flick and started_low:
		combo += 1
		burn_done = true
		if phase == "flop_burn":
			await _feedback("flop_burn", 0.20)
			phase = next_phase
			_show_visual("flop_packet")
		else:
			await _feedback("turn_default", 0.16)
			phase = next_phase
			_show_visual("turn_default")
	else:
		_register_mistake()
		await _feedback("board_failure", 0.34)
		_show_visual("flop_default" if phase == "flop_burn" else "turn_default")


func _resolve_flop_packet(end: Vector2) -> void:
	var started_from_deck := pointer_start.distance_to(DECK_CENTER) <= 0.36
	var valid_fan := end.distance_to(FLOP_FAN_CENTER) <= 0.22

	if burn_done and started_from_deck and valid_fan:
		combo += 1
		await _feedback("flop_valid", 0.14)
		await _feedback("flop_success", 0.34)
		_after_board_open()
	else:
		_register_mistake()
		await _feedback("board_failure", 0.34)
		_show_visual("flop_packet")


func _resolve_single_board(end: Vector2, target: Vector2, is_river: bool) -> void:
	var started_from_deck := pointer_start.distance_to(DECK_CENTER) <= 0.36
	var valid_target := end.distance_to(target) <= 0.22

	if burn_done and started_from_deck and valid_target:
		combo += 1
		await _feedback("river_success" if is_river else "turn_single", 0.34)
		_after_board_open()
	else:
		_register_mistake()
		await _feedback("board_failure", 0.34)
		_show_visual("turn_default")


func _after_board_open() -> void:
	# NPC betting is automatic in this interaction prototype. The next player
	# input begins at the reusable COLLECT sweep state, matching HAND_STATE_FLOW.
	await get_tree().create_timer(0.18).timeout
	_enter_collect()


func _enter_payout() -> void:
	phase = "payout"
	_show_visual("payout_default")


func _resolve_payout(end: Vector2) -> void:
	var started_from_pot := pointer_start.distance_to(POT_CENTER) <= 0.28
	var winner_target: Vector2 = SEAT_TARGETS[2]
	var valid_winner := end.distance_to(winner_target) <= 0.20

	if started_from_pot and valid_winner:
		combo += 1
		await _feedback("payout_success", 0.36)
		phase = "sidepot"
		_show_visual("sidepot_default")
	else:
		_register_mistake()
		await _feedback("payout_failure", 0.34)
		_show_visual("payout_default")


func _resolve_sidepot(end: Vector2) -> void:
	var started_near_pot := pointer_start.distance_to(POT_CENTER) <= 0.34
	var valid_target := end.distance_to(SEAT_TARGETS[4]) <= 0.20

	if started_near_pot and valid_target:
		combo += 1
		await _feedback("sidepot_valid", 0.14)
		await _feedback("sidepot_success", 0.36)
		phase = "shift_complete"
		_show_visual("shift_complete")
	else:
		_register_mistake()
		await _feedback("sidepot_failure", 0.34)
		_show_visual("sidepot_default")


func _enter_career() -> void:
	phase = "career"
	_show_visual("career")


func _resolve_special_table(end: Vector2, is_final: bool) -> void:
	var started_from_deck := pointer_start.distance_to(DECK_CENTER) <= 0.40
	var target: Vector2 = SEAT_TARGETS[1] if is_final else SEAT_TARGETS[3]
	var valid := end.distance_to(target) <= 0.22

	if started_from_deck and valid:
		combo += 1
		await _feedback("final_success" if is_final else "vip_success", 0.46)
		if is_final:
			phase = "shift_complete"
			_show_visual("shift_complete")
		else:
			phase = "final"
			_show_visual("final_default")
	else:
		_register_mistake()
		await _feedback("board_failure", 0.30)
		_show_visual("final_default" if is_final else "vip_default")


func _show_home() -> void:
	phase = "home"
	_show_visual("home")


func _register_mistake() -> void:
	mistakes += 1
	combo = 0


func _feedback(visual_key: String, seconds: float) -> void:
	feedback_locked = true
	_show_visual(visual_key)
	await get_tree().create_timer(seconds).timeout
	feedback_locked = false


func _show_visual(key: String) -> void:
	if key == current_visual:
		return
	if not SCREEN_FILES.has(key):
		push_error("Unknown wireframe screen: %s" % key)
		return

	var texture_path: String = WIREFRAME_DIR + String(SCREEN_FILES[key])
	var texture: Texture2D = load(texture_path) as Texture2D
	if texture == null:
		push_error("Could not load wireframe: %s" % texture_path)
		return

	screen.texture = texture
	current_visual = key


func _normalized(position: Vector2) -> Vector2:
	var size: Vector2 = get_viewport_rect().size
	return Vector2(
		position.x / maxf(size.x, 1.0),
		position.y / maxf(size.y, 1.0)
	)


func _handle_debug_key(keycode: Key) -> void:
	match keycode:
		KEY_H:
			_show_home()
		KEY_D:
			deal_index = 0
			phase = "deal"
			_show_visual("deal_default")
		KEY_C:
			phase = "collect"
			_show_visual("collect_default")
		KEY_F:
			_enter_flop()
		KEY_T:
			_enter_turn()
		KEY_P:
			_enter_payout()
		KEY_S:
			phase = "sidepot"
			_show_visual("sidepot_default")
		KEY_K:
			_enter_career()
		KEY_V:
			phase = "vip"
			_show_visual("vip_default")
		KEY_N:
			phase = "final"
			_show_visual("final_default")
