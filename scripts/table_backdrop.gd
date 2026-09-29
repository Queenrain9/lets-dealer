extends Control

@export var table_only: bool = false

func _ready() -> void:
	resized.connect(queue_redraw)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	if table_only:
		_draw_felt()
	else:
		draw_rect(Rect2(Vector2.ZERO, size), Color("101a1b"))
		for column in range(8):
			var x: float = float(column) * size.x / 7.0
			draw_line(Vector2(x, 0), Vector2(x, size.y), Color(0.45, 0.29, 0.16, 0.12), 2.0)
		for index in range(6):
			var point := Vector2((float(index) + 0.5) * size.x / 6.0, 6)
			draw_circle(point, 57, Color(0.89, 0.58, 0.20, 0.035))
			draw_circle(point, 26, Color(0.89, 0.58, 0.20, 0.045))
			draw_circle(point, 4, Color("c4a065"))

func _ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	draw_set_transform(center, 0.0, radii)
	draw_circle(Vector2.ZERO, 1.0, color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_felt() -> void:
	var center := Vector2(size.x * 0.5, size.y * 0.52)
	var radii := Vector2(size.x * 0.49, size.y * 0.46)
	_ellipse(center + Vector2(0, 15), radii, Color(0, 0, 0, 0.38))
	_ellipse(center, radii, Color("513b27"))
	_ellipse(center, radii - Vector2(5, 5), Color("b58c53"))
	_ellipse(center, radii - Vector2(12, 12), Color("1a4434"))
	_ellipse(center, radii - Vector2(28, 26), Color("296346"))
	_ellipse(center, radii - Vector2(30, 28), Color("164d37"))
	_ellipse(center + Vector2(0, 16), radii - Vector2(66, 90), Color(0.10, 0.33, 0.23, 0.46))
