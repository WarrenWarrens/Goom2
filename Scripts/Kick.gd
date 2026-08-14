
extends Node3D

@onready var weapon_sprite = $CanvasLayer/Control/KickSprite
# Since kicking doesn't use gun rays, you can remove that variable if you don't need it
@onready var gun_rays = $GunRays.get_children()

var can_attack = true
var damage: int = 15 # Set this to whatever melee damage you prefer

func _ready() -> void:
	weapon_sprite.play("Idle")
	
func _exit_tree() -> void:
	PlayerStats.change_action(1)
	
func check_hit():
	for ray in gun_rays:
		ray.force_raycast_update()
		if ray.is_colliding():
			var target = ray.get_collider()
			if target.has_method("take_damage"):
				target.take_damage(damage)

# THIS WAS MISSING: We need this so the game checks for the input every frame!
func _process(_delta: float) -> void:
	# Always read the global action state so the kick knows if we are busy
	can_attack = PlayerStats.get_action()
	#var is_prone = PlayerStats.get_prone() # Read the prone state
	
	# --- Desperation Attack Math ---
	
	
	# We use "kick" instead of "shoot"
	if Input.is_action_just_pressed("kick") and can_attack:
		weapon_sprite.play("Kick")
		check_hit()
		
		can_attack = false
		PlayerStats.change_action(0)
		
		# Apply the stamina costs
		

		# Lock global actions so we can't shoot our gun while kicking!
		
		await weapon_sprite.animation_finished
		
		# Unlock global actions
		PlayerStats.change_action(1)
		weapon_sprite.play("Idle")
