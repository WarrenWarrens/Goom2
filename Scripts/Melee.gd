
extends Node3D

@onready var weapon_sprite = $CanvasLayer/Control/WeaponSprite
@onready var gun_rays = $GunRays.get_children()


var can_attack = PlayerStats.get_action()


func _ready() -> void:
	weapon_sprite.play("Idle")
	PlayerStats.change_action(1)
	can_attack = true

func _exit_tree() -> void:
	PlayerStats.change_action(1)
	
func check_hit():
	pass

func _process(_delta: float) -> void:
	
	can_attack = PlayerStats.get_action()
	# --- Desperation Attack Math ---
	
	# We can attack if we have 0 deficit, OR enough regular stamina to cover 2x the missing amount
	
	
	
	if Input.is_action_just_pressed("shoot") and can_attack:
		weapon_sprite.play("Attack")
		check_hit()
		
		# Apply the stamina costs
		
		can_attack = false
		PlayerStats.change_action(0)
		
		await(weapon_sprite.animation_finished)
		
		can_attack = true
		PlayerStats.change_action(1)
		weapon_sprite.play("Idle")
