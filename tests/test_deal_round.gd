extends SceneTree

var failures: int = 0
var checks: int = 0

func _init() -> void:
	call_deferred("_run")

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL: " + message)

func _run() -> void:
	if not ResourceLoader.exists("res://scripts/deal_round.gd"):
		_check(false, "card-dealing rules have not been implemented")
		quit(1)
		return
	var rules: GDScript = load("res://scripts/deal_round.gd")
	var game = rules.new()
	game.tick(8.0)
	_check(game.remaining == 60.0, "waiting for the first pickup must not consume time")
	_check(game.attempt_drop(0) == "inactive", "a drop without pickup must not deal a card")
	game.start()
	_check(game.attempt_drop(1) == "wrong_seat", "the first card belongs to the left seat")
	_check(game.dealt_count == 0 and game.mistakes == 1, "wrong seat must not receive a card")
	_check(game.attempt_drop(-1) == "outside", "empty table must cancel without penalty")
	_check(game.attempt_drop(8) == "outside" and game.mistakes == 1, "unknown seats must not penalize or deal")
	for seat in [0, 1, 2, 0, 1, 2]:
		_check(game.expected_seat() == seat, "two passes must preserve the deal order")
		_check(game.attempt_drop(seat) == "accepted", "correctly ordered card must be accepted")
	_check(game.phase == "completed" and game.dealt_count == 6, "six cards must complete the training")
	_check(game.accuracy() == 86, "six correct actions and one error must show rounded 86 percent")
	_check(game.attempt_drop(0) == "inactive" and game.dealt_count == 6, "completed training must reject extra cards")
	game.reset()
	_check(game.phase == "ready" and game.dealt_count == 0 and game.mistakes == 0 and game.remaining == 60.0, "restart must clear the previous training")
	game.start()
	for error_index in range(3):
		game.attempt_drop(2)
	_check(game.phase == "failed" and game.dealt_count == 0, "three wrong-seat attempts must fail")
	game.reset()
	game.start()
	game.set_paused(true)
	game.tick(100.0)
	_check(game.remaining == 60.0 and game.phase == "active", "pause must freeze the timer")
	_check(game.attempt_drop(0) == "inactive", "pause must reject dealing")
	game.set_paused(false)
	game.tick(-5.0)
	_check(game.remaining == 60.0, "negative elapsed time must not extend the round")
	game.tick(59.75)
	_check(is_equal_approx(game.remaining, 0.25), "elapsed time must reduce the remaining budget")
	game.tick(0.25)
	_check(game.phase == "failed" and game.remaining == 0.0, "exactly sixty seconds must fail")
	_check(game.attempt_drop(0) == "inactive" and game.dealt_count == 0, "release after timeout must not deal")
	game.reset()
	game.start()
	game.attempt_drop(0)
	game.tick(90.0)
	_check(game.remaining == 0.0 and game.phase == "failed", "large frame delta must clamp at zero")
	print("DealRound: %d checks, %d failures" % [checks, failures])
	quit(0 if failures == 0 else 1)
