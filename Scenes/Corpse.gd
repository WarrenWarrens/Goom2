extends CharacterBody3D

func _ready() -> void:
	# Optional: If using AnimatedSprite3D, play the death animation here
	# $AnimatedSprite3D.play("death")
	pass

func _physics_process(delta: float) -> void:
	# If the corpse is in the air, apply gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
		
	else:
		# Once it hits the ground, turn off physics processing to save CPU
		set_physics_process(false)
