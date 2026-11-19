extends StaticBody2D
## Eine Wand mit einstellbarer Größe.
## Geometrie (Polygon + Kollisionsform) wird im Code erzeugt, damit die
## Szene als wiederverwendbare Vorlage mit beliebigen Maßen dienen kann.

@export var size := Vector2(40.0, 20.0)

@onready var _visual: Polygon2D = $Visual
@onready var _shape: CollisionShape2D = $Shape


func _ready() -> void:
	_visual.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(size.x, 0.0),
		size,
		Vector2(0.0, size.y)
	])
	var rect := RectangleShape2D.new()
	rect.size = size
	_shape.shape = rect
	_shape.position = size / 2.0
