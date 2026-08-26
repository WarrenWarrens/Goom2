extends StaticBody3D

# Your kick does 25 damage, so 25 health means it breaks in 1 hit.
# If you want it to take 2 kicks, set this to 50.
@export var health: int = 25 

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		break_door()

func break_door():
	# Optional: Spawn some wood debris sprites or play a breaking sound here
	queue_free()
