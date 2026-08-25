extends AnimatableBody3D

@export var requires_key: bool = false
@export var required_key: String = "red"
# How far the door moves when opened. Adjust for sliding up, down, or sideways.
@export var open_offset: Vector3 = Vector3(14, 0, 0) 
@export var speed: float = 1

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
		# Check the dictionary from PlayerInventory
		if requires_key and not PlayerInventory.has_key(required_key):
			print("You need the " + required_key + " key")
			# Optional: Play a "locked" sound effect here
			return
		
		players_in_zone += 1
		open_door()

func _on_body_exited(body):
	if body.is_in_group("player"):
		# If they didn't have the key, they were never officially counted in the zone
		if requires_key and not PlayerInventory.has_key(required_key):
			return
			
		players_in_zone -= 1
		if players_in_zone <= 0:
			close_door()

func open_door():
	if tween: tween.kill() # Stop any current movement
	tween = create_tween()
	# Smoothly interpolate to the open position
	tween.tween_property(self, "global_position", start_pos + open_offset, speed)

func close_door():
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "global_position", start_pos, speed)
