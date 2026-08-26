extends StaticBody3D

@export var health: int = 25
@export var drop_item: PackedScene # Drag your Universal Pickup.tscn into this slot in the Inspector

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		break_crate()

func break_crate():
	if drop_item:
		var item = drop_item.instantiate()
		get_tree().current_scene.add_child(item)
		
		# Spawn the item exactly where the crate was
		item.global_position = global_position 
		
	# Optional: Play a smash sound effect or spawn splinters
	queue_free()
