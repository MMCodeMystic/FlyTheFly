extends Node2D
## TestLevel: verbindet alle Systeme und regelt Neustart und Sieg.

const RESTART_DELAY := 1.0

var _restarting := false

@onready var _fly: CharacterBody2D = $Fly
@onready var _stamina_bar: ProgressBar = $Hud/StaminaBar
@onready var _health_bar: ProgressBar = $Hud/HealthBar
@onready var _message: Label = $Hud/Message
@onready var _exit: Area2D = $Exit


func _ready() -> void:
	_fly.died.connect(_on_fly_died)
	_fly.stamina_changed.connect(_on_stamina_changed)
	_fly.health_changed.connect(_on_health_changed)
	_exit.body_entered.connect(_on_exit_entered)
	_message.text = "Beobachte die Muster – dann flieg LOS."


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("neustart"):
		get_tree().reload_current_scene()


func _on_stamina_changed(value: float) -> void:
	_stamina_bar.value = value * 100.0


func _on_health_changed(value: float) -> void:
	_health_bar.value = value * 100.0


func _on_fly_died() -> void:
	if _restarting:
		return
	_restarting = true
	_message.text = "Erwischt! Neustart ..."
	await get_tree().create_timer(RESTART_DELAY).timeout
	get_tree().reload_current_scene()


func _on_exit_entered(body: Node2D) -> void:
	if body.is_in_group("fly") and not _restarting:
		_restarting = true
		_message.text = "GESCHAFFT! Fenster erreicht - Neustart ..."
		await get_tree().create_timer(2.0).timeout
		get_tree().reload_current_scene()
