extends Node2D
## Eine Gefahren-Tür mit klarem, wiederholtem Zyklus:
##   OFFEN   (passierbar) -> WARNUNG (blinkt orange) -> ZU
##   (blockiert + tötet, wer beim Zuschnappen erwischt wird) -> wieder OFFEN
## Die Fliege muss das Timing lesen und die Tür rechtzeitig nutzen.

enum State { OFFEN, WARNUNG, ZU }

const COLOR_OPEN := Color(0.18, 0.55, 0.28, 0.35)
const COLOR_WARNING := Color(0.95, 0.6, 0.1, 0.9)
const COLOR_CLOSED := Color(0.75, 0.15, 0.15, 1.0)

@export var size := Vector2(20.0, 80.0)
@export var open_time := 3.5
@export var warning_time := 1.2
@export var closed_time := 2.3

var _state := State.OFFEN
var _timer := 0.0

@onready var _visual: Polygon2D = $Visual
@onready var _trigger: Area2D = $Trigger
@onready var _block: StaticBody2D = $Block


func _ready() -> void:
	var points := PackedVector2Array(
		Vector2.ZERO,
		Vector2(size.x, 0.0),
		size,
		Vector2(0.0, size.y)
	)
	_visual.polygon = points

	var rect := RectangleShape2D.new()
	rect.size = size
	_trigger.get_node("Shape").shape = rect
	_trigger.get_node("Shape").position = size / 2.0
	_block.get_node("Shape").shape = rect
	_block.get_node("Shape").position = size / 2.0

	_set_state(State.OFFEN)


func _physics_process(delta: float) -> void:
	_timer -= delta
	match _state:
		State.OFFEN:
			if _timer <= 0.0:
				_set_state(State.WARNUNG)
		State.WARNUNG:
			_visual.modulate.a = 0.5 + 0.5 * absf(sin(Time.total_runtime * 12.0))
			if _timer <= 0.0:
				_set_state(State.ZU)
		State.ZU:
			if _timer <= 0.0:
				_set_state(State.OFFEN)


func _set_state(next: State) -> void:
	_state = next
	match _state:
		State.OFFEN:
			_timer = open_time
			_visual.color = COLOR_OPEN
			_visual.modulate.a = 1.0
			_block.get_node("Shape").set_deferred("disabled", true)
		State.WARNUNG:
			_timer = warning_time
			_visual.color = COLOR_WARNING
			_block.get_node("Shape").set_deferred("disabled", true)
		State.ZU:
			_timer = closed_time
			_visual.color = COLOR_CLOSED
			_visual.modulate.a = 1.0
			_block.get_node("Shape").set_deferred("disabled", false)
			_squish_overlapping_flies()


func _squish_overlapping_flies() -> void:
	for body in _trigger.get_overlapping_bodies():
		if body.is_in_group("fly"):
			body.die()
