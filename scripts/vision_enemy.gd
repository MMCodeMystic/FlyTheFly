extends Node2D
## Die Spinne: eine Jägerin mit Sichtkegel.
##	SCAN        Kegel pendelt gleichmäßig hin und her (Muster!)
##	ALARM       Fliege gesehen -> kurzes Erstarren (Chance!)
##	JAGD        verfolgt die zuletzt gesehene Position
##	RUECKKEHR   gibt auf, kehrt zum Ausgangspunkt zurück, dann SCAN

enum State { SCAN, ALARM, JAGD, RUECKKEHR }

@export var sweep_radius := 0.9
@export var sweep_speed := 0.9
@export var pause_at_end := 0.7
@export var alarm_time := 0.45
@export var chase_speed := 230.0
@export var return_speed := 120.0
@export var give_up_time := 3.0

var _state := State.SCAN
var _sweep := 0.0
var _sweep_dir := 1.0
var _timer := 0.0
var _lost_timer := 0.0
var _last_seen := Vector2.ZERO
var _home := Vector2.ZERO

@onready var _head: Node2D = $Head
@onready var _cone_visual: Polygon2D = $Head/ConeVisual
@onready var _vision_cone: Area2D = $Head/VisionCone
@onready var _mouth: Area2D = $Mouth


func _ready() -> void:
	_home = global_position
	_vision_cone.body_entered.connect(_on_vision_body_entered)
	_mouth.body_entered.connect(kill_fly_if_caught)


func _physics_process(delta: float) -> void:
	match _state:
		State.SCAN:
			_sweep_head(delta)
		State.ALARM:
			_timer -= delta
			if _timer <= 0.0:
				_start_chase()
		State.JAGD:
			_chase(delta)
		State.RUECKKEHR:
			global_position = global_position.move_toward(_home, return_speed * delta)
			if global_position == _home:
				_enter_state(State.SCAN)
				_cone_visual.modulate = Color(1, 1, 1, 0.22)


func _sweep_head(delta: float) -> void:
	if _timer > 0.0:
		_timer -= delta
		return
	_sweep += _sweep_dir * sweep_speed * delta
	if absf(_sweep) >= sweep_radius:
		_sweep_dir *= -1.0
		_timer = pause_at_end
	_head.rotation = _sweep


func _start_chase() -> void:
	_last_seen = _fly_position()
	_lost_timer = 0.0
	_enter_state(State.JAGD)


func _chase(delta: float) -> void:
	if _fly_in_cone():
		_last_seen = _fly_position()
		_lost_timer = 0.0
	else:
		_lost_timer += delta
		if _lost_timer >= give_up_time and global_position.distance_to(_last_seen) < 8.0:
			_cone_visual.modulate = Color(1, 1, 1, 0.22)
			_enter_state(State.RUECKKEHR)
			return

	global_position = global_position.move_toward(_last_seen, chase_speed * delta)


func _fly_in_cone() -> bool:
	return _vision_cone.get_overlapping_bodies().any(func(b): return b.is_in_group("fly"))


func _fly_position() -> Vector2:
	var flies := _vision_cone.get_overlapping_bodies().filter(func(b): return b.is_in_group("fly"))
	if not flies.is_empty():
		return flies[0].global_position
	return _last_seen


func _on_vision_body_entered(body: Node2D) -> void:
	if not body.is_in_group("fly"):
		return
	match _state:
		State.SCAN:
			_last_seen = body.global_position
			_cone_visual.modulate = Color(1.5, 0.4, 0.4, 0.5)
			_enter_state(State.ALARM)


func kill_fly_if_caught(body: Node2D) -> void:
	if body.is_in_group("fly"):
		body.die()
