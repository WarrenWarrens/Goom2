extends Sprite2D

func _ready() -> void:
	# Delete the flash after 0.05 seconds
	await get_tree().create_timer(0.05).timeout
	queue_free()
