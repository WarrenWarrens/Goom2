extends Area3D

enum PickupType { HEALTH, AMMO, WEAPON }

@export var type: PickupType = PickupType.WEAPON
@export var weapon_name: String = "shotgun"
@export var amount: int = 1

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		match type:
			PickupType.HEALTH:
				if body.has_method("add_health"):
					body.add_health(amount)
					queue_free()
			PickupType.AMMO:
				if body.has_method("add_ammo"):
					body.add_ammo(amount)
					queue_free()
			PickupType.WEAPON:
				if body.has_method("unlock_weapon"):
					body.unlock_weapon(weapon_name)
					queue_free()
