extends Node2D
## Ein NPC mit ständig wiederholendem Wegpunkt-Muster.
## Die Fliege muss das Muster beobachten und die Lücken nutzen.

@export var waypoints: Array[Vector2] = [Vector2(120, 500), Vector2(460, 500)]
@export var speed := 130.0
@export var pause_time := 2.0

var _target_index := 0
var _waiting := false
var _timer := 0.0

@onready var _visual: Node2D = $Visual


func _ready() -> void:
	_face_toward(waypoints[_target_index])


func _process(delta: float) -> void:
	if _waiting:
		_timer -= delta
		if _timer <= 0.0:
			_waiting = false
			_pick_next_waypoint()
		return

	var target: Vector2 = waypoints[_target_index]
	var step := speed * delta
	if global_position.distance_to(target) <= step:
		global_position = target
		_waiting = true
		_timer = pause_time
	else:
		global_position += (target - global_position).normalized() * step


func _pick_next_waypoint() -> void:
	_target_index = (_target_index + 1) % waypoints.size()
	_face_toward(waypoints[_target_index])


func _face_toward(target: Vector2) -> void:
	_visual.scale.x = 1.0 if target.x >= global_position.x else -1.0
