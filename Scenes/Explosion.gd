extends Area3D

@export var explosion_damage: int = 50
@onready var sprite = $AnimatedSprite3D

func _ready() -> void:
	sprite.play("explode")
	
	# Wait one physics frame so the collision shape can register overlapping bodies
	await get_tree().physics_frame
	
	# Get everything inside the blast radius
	var bodies = get_overlapping_bodies()
	
	for body in bodies:
		if body.has_method("take_damage"):
			# Deal damage and pass the explosion's position for knockback calculation
			body.take_damage(explosion_damage, global_position)
			
	# Wait for the animation to finish, then delete the explosion
	await sprite.animation_finished
	queue_free()
