extends Area3D

@export var destination: Node3D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	# Check if the player stepped in, and ensure a destination is set
	if body.is_in_group("player") and destination:
		# Instantly snap the player's position to the destination
		body.global_position = destination.global_position
