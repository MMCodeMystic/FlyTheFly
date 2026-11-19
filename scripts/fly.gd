extends CharacterBody2D
## Die Fliege: unsere Heldin.
## Steuert Schweben, Sprint (verbraucht Ausdauer), Regeneration im
## Stillstand und nimmt Windstöße von der Lüftung entgegen.

signal died
signal stamina_changed(value: float)

const ACCEL := 1400.0
const FRICTION := 800.0
const MAX_SPEED := 420.0
const SPRINT_MULT := 1.7
const SPRINT_DRAIN := 0.30
const REGEN_FLYING := 0.06
const REGEN_RESTING := 0.28
const REST_SPEED := 40.0

var stamina := 1.0
var _is_dead := false

@onready var _wings: Polygon2D = $Fluegel


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	var input_dir := Input.get_vector("links", "rechts", "hoch", "runter")
	var sprinting := Input.is_action_pressed("sprint") and stamina > 0.0 and input_dir != Vector2.ZERO

	velocity += input_dir * ACCEL * (SPRINT_MULT if sprinting else 1.0) * delta
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	velocity = velocity.limit_length(MAX_SPEED)

	if sprinting:
		stamina = maxf(stamina - SPRINT_DRAIN * delta, 0.0)
	elif velocity.length() < REST_SPEED:
		stamina = minf(stamina + REGEN_RESTING * delta, 1.0)
	else:
		stamina = minf(stamina + REGEN_FLYING * delta, 1.0)

	stamina_changed.emit(stamina)
	_flutter_wings()
	move_and_slide()


func apply_wind(force: Vector2) -> void:
	velocity += force


func die() -> void:
	if _is_dead:
		return
	_is_dead = true
	velocity = Vector2.ZERO
	died.emit()


func _flutter_wings() -> void:
	var flap := 1.0 + 0.35 * absf(sin(Time.total_runtime * 30.0))
	_wings.scale = Vector2(1.0, flap)
	_wings.rotation = sin(Time.total_runtime * 20.0) * 0.15
