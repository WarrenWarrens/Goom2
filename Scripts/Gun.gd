extends Node3D

@onready var gun_sprite = $CanvasLayer/Control/GunSprite
@onready var gun_rays =$GunRays.get_children()
@onready var flash = preload("res://Scenes/MuzzleFlash.tscn")
@onready var flash_tex_1 = preload("res://Assets/Effects/MF1/qq1.png")
@onready var flash_tex_2 = preload("res://Assets/Effects/MF2/bb1.png")

var can_shoot = true
var damage = 8
var is_gun: bool = true
var left: bool = true

var base_sprite_pos: Vector2
var bob_time: float = 0.0
var bob_frequency: float = 12.0
var bob_amplitude: float = 8.0

var current_recoil: Vector2 = Vector2.ZERO
var recoil_kick: Vector2 = Vector2(0, -30) 

func _ready() -> void:
	gun_sprite.play("Idle")
	PlayerStats.change_action(1)
	can_shoot = true
	# Store the initial position of the gun sprite to use as a baseline for math
	base_sprite_pos = gun_sprite.position
	#gun_sprite.play("Idle")
	#PlayerStats.change_action(1)
	#can_shoot = true
	
func _exit_tree() -> void:
	PlayerStats.change_action(1)
	
func make_flash():
	var f = flash.instantiate()
	# Add the flash to the CanvasLayer so it stays on the screen
	$CanvasLayer/Control.add_child(f)

	# Position the flash near the barrel (Adjust the Vector2 to fit your sprite)
	f.position = gun_sprite.position + Vector2(20, -80) 

	# Randomize the rotation
	f.rotation = randf_range(0.0, TAU) # TAU is 360 degrees in radians

	# Randomly pick between the two textures
	if randi() % 2 == 0:
		f.texture = flash_tex_1
	else:
		f.texture = flash_tex_2
	
func check_hit():
	for ray in gun_rays:
		ray.force_raycast_update()
		if ray.is_colliding():
			var target = ray.get_collider()
			if target.has_method("take_damage"):
				target.take_damage(damage)

				# Terminal output
				print("Hit confirmed! Dealt ", damage, " to ", target.name)

				# Trigger visual hit marker on the player
				var player = get_tree().get_first_node_in_group("player")
				if player.has_method("show_hit_marker"):
					player.show_hit_marker()
					
func _process(delta: float) -> void:
	can_shoot = PlayerStats.get_action()
	
	# --- Weapon Bobbing Logic ---
	var player = get_tree().get_first_node_in_group("player")
	# If the player exists, is on the floor, and is actively moving
	if player and player.is_on_floor() and player.velocity.length() > 1.0:
		bob_time += delta * bob_frequency
	else:
		# Smoothly reset bob time to bring the gun back to center when stopped
		bob_time = lerp(bob_time, 0.0, delta * 5.0)

	# Calculate the figure-8 motion
	var bob_offset = Vector2(
		cos(bob_time / 2.0) * bob_amplitude,
		sin(bob_time) * bob_amplitude
	)
	
	# --- Recoil Recovery Logic ---
	# Smoothly return the recoil offset back to zero over time
	current_recoil = current_recoil.lerp(Vector2.ZERO, delta * 15.0)
	
	# Apply the bob and recoil to the sprite's actual position
	gun_sprite.position = base_sprite_pos + bob_offset + current_recoil
	# -----------------------------
	
	if Input.is_action_just_pressed("shoot") and can_shoot and PlayerInventory.ammo["pistol"] > 0:
		if left == true:
			gun_sprite.play("Shoot")
			left = false
		else:
			gun_sprite.play("Shoot2")
			left = true
			
		# Trigger the recoil kick
		current_recoil = recoil_kick
			
		make_flash()
		
		# Called the cleaned-up check_hit function instead of duplicating the logic
		check_hit()
		
		PlayerInventory.change_ammo("pistol", -1)
		can_shoot = false
		
		await(gun_sprite.animation_finished)
		can_shoot = true
		gun_sprite.play("Idle")
					
#func check_hit():
	#for ray in gun_rays:
		#ray.force_raycast_update()
		#if ray.is_colliding():
			#var target = ray.get_collider()
			#if target.has_method("take_damage"):
				#target.take_damage(damage)
#
				## Terminal output
				#print("Hit confirmed! Dealt ", damage, " to ", target.name)
#
				## Trigger visual hit marker on the player
				#var player = get_tree().get_first_node_in_group("player")
				#if player.has_method("show_hit_marker"):
					#player.show_hit_marker()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
	#can_shoot = PlayerStats.get_action()
	#
	#if Input.is_action_just_pressed("shoot") and can_shoot and PlayerInventory.ammo["pistol"] > 0:
		#if left == true:
			#gun_sprite.play("Shoot")
			#left = false
		#else:
			#gun_sprite.play("Shoot2")
			#left = true
		#make_flash()
		#for ray in gun_rays:
			#ray.force_raycast_update()
			#if ray.is_colliding():
				#var target = ray.get_collider()
				## Assuming your enemy scripts have a take_damage function
				#if target.has_method("take_damage"):
					#target.take_damage(damage)
		##check_hit()
		#PlayerInventory.change_ammo("pistol", -1)
		#can_shoot = false
		#
		#await(gun_sprite.animation_finished)
		#can_shoot = true
		#gun_sprite.play("Idle")
		#
	#pass
