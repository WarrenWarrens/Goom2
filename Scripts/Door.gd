extends AnimatableBody3D

enum OpenDirection { UP, DOWN, LEFT, RIGHT }

@export var requires_key: bool = false
@export var required_key: String = "red"
@export_group("Door Movement")
@export var direction: OpenDirection = OpenDirection.UP
@export var open_distance: float = 3.0
@export var speed: float = 0.5

@onready var detection_area = $DetectionArea
var start_pos: Vector3
var tween: Tween
var players_in_zone: int = 0

func _ready():
	start_pos = global_position
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		if requires_key and not PlayerInventory.has_key(required_key):
			print("You need the " + required_key + " keycard!")
			return
		
		players_in_zone += 1
		open_door()

func _on_body_exited(body):
	if body.is_in_group("player"):
		if requires_key and not PlayerInventory.has_key(required_key):
			return
			
		players_in_zone -= 1
		if players_in_zone <= 0:
			close_door()

func get_target_position() -> Vector3:
	var offset = Vector3.ZERO
	match direction:
		OpenDirection.UP: offset.y = open_distance
		OpenDirection.DOWN: offset.y = -open_distance
		OpenDirection.LEFT: offset.x = -open_distance
		OpenDirection.RIGHT: offset.x = open_distance
		
	# transform.basis ensures the door slides correctly even if you rotate it in the level
	return start_pos + (transform.basis * offset)

func open_door():
	if tween: tween.kill() 
	tween = create_tween()
	tween.tween_property(self, "global_position", get_target_position(), speed)

func close_door():
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "global_position", start_pos, speed)
