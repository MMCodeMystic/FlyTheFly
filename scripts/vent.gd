extends Node2D
## Eine Lüftung mit wiederholtem Blow-Rhythmus.
## Während des Gusts wird alles weggedrückt, was im Windkegel steht.

enum State { RUHET, BLAEST }

@export var idle_time := 2.8
@export var blow_time := 1.6
@export var strength := 900.0
@export var direction := Vector2.RIGHT

var _state := State.RUHET
var _timer := 0.0

@onready var _visual: Polygon2D = $Visual
@onready var _gust: Polygon2D = $Gust
@onready var _wind_zone: Area2D = $WindZone


func _ready() -> void:
	direction = direction.normalized()
	_timer = idle_time


func _physics_process(delta: float) -> void:
	_timer -= delta
	match _state:
		State.RUHET:
			_gust.modulate.a = lerpf(_gust.modulate.a, 0.0, 10.0 * delta)
			if _timer <= 0.0:
				_state = State.BLAEST
				_timer = blow_time
				_visual.modulate = Color(1.4, 1.4, 1.4)
		State.BLAEST:
			_gust.modulate.a = lerpf(_gust.modulate.a, 0.5, 12.0 * delta)
			_push_overlapping_flies(delta)
			if _timer <= 0.0:
				_state = State.RUHET
				_timer = idle_time
				_visual.modulate = Color(1.0, 1.0, 1.0)


func _push_overlapping_flies(delta: float) -> void:
	for body in _wind_zone.get_overlapping_bodies():
		if body.has_method("apply_wind"):
			body.apply_wind(direction * strength * delta)
