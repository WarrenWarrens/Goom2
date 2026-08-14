extends Node3D

@onready var weapon_sprite = $CanvasLayer/Control/WeaponSprite
@onready var gun_rays = $GunRays.get_children()

var can_attack: bool = true
var damage: int = 15 # Set this to whatever melee damage you prefer

func _ready() -> void:
	weapon_sprite.play("Idle")
	PlayerStats.change_action(1)
	can_attack = true

func _exit_tree() -> void:
	PlayerStats.change_action(1)

func check_hit():
	for ray in gun_rays:
		ray.force_raycast_update()
		if ray.is_colliding():
			var target = ray.get_collider()
			if target.has_method("take_damage"):
				target.take_damage(damage)

func _process(_delta: float) -> void:
	can_attack = PlayerStats.get_action()
	
	if Input.is_action_just_pressed("shoot") and can_attack:
		weapon_sprite.play("Attack")
		check_hit()
		
		can_attack = false
		PlayerStats.change_action(0)
		
		await(weapon_sprite.animation_finished)
		
		can_attack = true
		PlayerStats.change_action(1)
		weapon_sprite.play("Idle")
