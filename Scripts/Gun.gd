extends Node3D

@onready var gun_sprite = $CanvasLayer/Control/GunSprite
@onready var muzzle_pos = $CanvasLayer/Control/GunSprite/MuzzlePos # The new Marker2D
@onready var gun_rays = $GunRays.get_children()

@onready var flash = preload("res://Scenes/MuzzleFlash.tscn")
@onready var flash_tex_1 = preload("res://Assets/Effects/MF1/qq1.png")
@onready var flash_tex_2 = preload("res://Assets/Effects/MF2/bb1.png")
const EXPLOSION_SCENE = preload("res://Scenes/Explosion.tscn")

#--- WEAPON CONFIGURATION ---
@export var weapon_name: String = "pistol"
@export var damage: int = 8
@export var ammo_cost: int = 1

@export_group("Fire Mode")
@export var is_automatic: bool = false
@export var fire_rate: float = 0.15 # Now controls the cooldown for ALL weapons

@export_group("Shotgun Spread")
@export var pellet_count: int = 1 
@export var spread_angle: float = 0.08 

@export_group("Explosive")
@export var is_explosive: bool = false

var can_shoot: bool = true

# --- Bob & Recoil Variables ---
var base_sprite_pos: Vector2
var bob_time: float = 0.0
var bob_frequency: float = 12.0
var bob_amplitude: float = 8.0

var current_recoil: Vector2 = Vector2.ZERO
@export var recoil_kick: Vector2 = Vector2(10, -30) # Kicks right and up


func _ready() -> void:
	can_shoot = true
	base_sprite_pos = gun_sprite.position

func _process(delta: float) -> void:
	# Weapon Bobbing
	var player = get_tree().get_first_node_in_group("player")
	if player and player.is_on_floor() and player.velocity.length() > 1.0:
		bob_time += delta * bob_frequency
	else:
		bob_time = lerp(bob_time, 0.0, delta * 5.0)

	var bob_offset = Vector2(cos(bob_time / 2.0) * bob_amplitude, sin(bob_time) * bob_amplitude)
	current_recoil = current_recoil.lerp(Vector2.ZERO, delta * 15.0)
	
	# Apply bob and recoil
	gun_sprite.position = base_sprite_pos + bob_offset + current_recoil
	
	var wants_to_shoot = Input.is_action_pressed("shoot") if is_automatic else Input.is_action_just_pressed("shoot")
	
	if wants_to_shoot and can_shoot and PlayerInventory.ammo[weapon_name] >= ammo_cost:
		fire_weapon()

func fire_weapon() -> void:
	can_shoot = false
	current_recoil = recoil_kick
	make_flash()
	
	PlayerInventory.change_ammo(weapon_name, -ammo_cost)
	check_hit()
	
	# Universal cooldown timer using the fire_rate
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func check_hit():
	for i in pellet_count:
		var ray = gun_rays[0]
		var original_target = ray.target_position
		
		if pellet_count > 1:
			var spread_x = randf_range(-spread_angle, spread_angle)
			var spread_y = randf_range(-spread_angle, spread_angle)
			var direction = original_target.normalized() + Vector3(spread_x, spread_y, 0)
			ray.target_position = direction.normalized() * original_target.length()
			
		ray.force_raycast_update()
		
		if ray.is_colliding():
			var hit_pos = ray.get_collision_point()
			
			if is_explosive:
				spawn_explosion(hit_pos)
				ray.target_position = original_target 
				break 
				
			var target = ray.get_collider()
			if target.has_method("take_damage"):
				target.take_damage(damage)
				
		ray.target_position = original_target

func spawn_explosion(pos: Vector3):
	var exp1 = EXPLOSION_SCENE.instantiate()
	get_tree().current_scene.add_child(exp1)
	exp1.global_position = pos

func make_flash():
	var f = flash.instantiate()
	$CanvasLayer/Control.add_child(f)
	
	# Snap the flash perfectly to the Marker2D
	f.global_position = muzzle_pos.global_position
	f.rotation = randf_range(0.0, TAU)
	f.texture = flash_tex_1 if randi() % 2 == 0 else flash_tex_2
	
#extends Node3D
#
#@onready var gun_sprite = $CanvasLayer/Control/GunSprite
#@onready var gun_rays =$GunRays.get_children()
#@onready var flash = preload("res://Scenes/MuzzleFlash.tscn")
#@onready var flash_tex_1 = preload("res://Assets/Effects/MF1/qq1.png")
#@onready var flash_tex_2 = preload("res://Assets/Effects/MF2/bb1.png")
#const EXPLOSION_SCENE = preload("res://Scenes/Explosion.tscn")
#
##--- WEAPON CONFIGURATION (Set in Inspector) ---
#@export var weapon_name: String = "pistol"
#@export var damage: int = 8
#@export var ammo_cost: int = 1
#
#@export_group("Fire Mode")
#@export var is_automatic: bool = false
#@export var fire_rate: float = 0.15 # Only used if is_automatic is true
#
#@export_group("Shotgun Spread")
#@export var pellet_count: int = 1 # Keep at 1 for normal guns
#@export var spread_angle: float = 0.08 # Spread radius
#
#@export_group("Explosive")
#@export var is_explosive: bool = false
#
#var can_shoot: bool = true
#var left: bool = true
#
## --- Bob & Recoil Variables ---
#var base_sprite_pos: Vector2
#var bob_time: float = 0.0
#var bob_frequency: float = 12.0
#var bob_amplitude: float = 8.0
#
#var current_recoil: Vector2 = Vector2.ZERO
#var recoil_kick: Vector2 = Vector2(0, -30)
#
#
#func _ready() -> void:
	##gun_sprite.play("Idle")
	#can_shoot = true
	#base_sprite_pos = gun_sprite.position
#
#func _process(delta: float) -> void:
	## Weapon Bobbing
	#var player = get_tree().get_first_node_in_group("player")
	#if player and player.is_on_floor() and player.velocity.length() > 1.0:
		#bob_time += delta * bob_frequency
	#else:
		#bob_time = lerp(bob_time, 0.0, delta * 5.0)
#
	#var bob_offset = Vector2(cos(bob_time / 2.0) * bob_amplitude, sin(bob_time) * bob_amplitude)
	#current_recoil = current_recoil.lerp(Vector2.ZERO, delta * 15.0)
	#gun_sprite.position = base_sprite_pos + bob_offset + current_recoil
	#
	## Determine if we check for holding the button or just clicking it
	#var wants_to_shoot = Input.is_action_pressed("shoot") if is_automatic else Input.is_action_just_pressed("shoot")
	#
	#if wants_to_shoot and can_shoot and PlayerInventory.ammo[weapon_name] >= ammo_cost:
		#fire_weapon()
#
#func fire_weapon() -> void:
	#can_shoot = false
	#current_recoil = recoil_kick
	#make_flash()
	#
	#PlayerInventory.change_ammo(weapon_name, -ammo_cost)
	#
	## Handle standard/shotgun hitscan
	#check_hit()
	#
	## Handle firing cooldowns
	#if is_automatic:
		#await get_tree().create_timer(fire_rate).timeout
		##if gun_sprite.animation != "Shoot" and gun_sprite.animation != "Shoot2":
			##gun_sprite.play("Idle")
		#can_shoot = true
	#else:
		#await gun_sprite.animation_finished
		##gun_sprite.play("Idle")
		#can_shoot = true
#
#func check_hit():
	## Loop through however many pellets the weapon fires (1 for pistol, 8+ for shotgun)
	#for i in pellet_count:
		## Use the first raycast in the GunRays node
		#var ray = gun_rays[0]
		#var original_target = ray.target_position
		#
		## Apply spread if pellet_count > 1
		#if pellet_count > 1:
			#var spread_x = randf_range(-spread_angle, spread_angle)
			#var spread_y = randf_range(-spread_angle, spread_angle)
			#var direction = original_target.normalized() + Vector3(spread_x, spread_y, 0)
			#ray.target_position = direction.normalized() * original_target.length()
			#
		#ray.force_raycast_update()
		#
		#if ray.is_colliding():
			#var hit_pos = ray.get_collision_point()
			#
			## If it's a hitscan rocket, spawn the explosion and ignore direct damage
			#if is_explosive:
				#spawn_explosion(hit_pos)
				## Reset target and break the loop so we only spawn one explosion
				#ray.target_position = original_target 
				#break 
				#
			## Standard direct damage
			#var target = ray.get_collider()
			#if target.has_method("take_damage"):
				#target.take_damage(damage)
				## If you have a blood splatter function, call it here:
				## spawn_blood(hit_pos)
				#
		## Reset raycast target position
		#ray.target_position = original_target
#
#func spawn_explosion(pos: Vector3):
	#var exp = EXPLOSION_SCENE.instantiate()
	#get_tree().current_scene.add_child(exp)
	#exp.global_position = pos
#
#func make_flash():
	#var f = flash.instantiate()
	#$CanvasLayer/Control.add_child(f)
	#f.position = gun_sprite.position + Vector2(20, -80)
	#f.rotation = randf_range(0.0, TAU)
	#f.texture = flash_tex_1 if randi() % 2 == 0 else flash_tex_2
	#
	#
##var can_shoot = true
##var damage = 8
##var is_gun: bool = true
##var left: bool = true
##
##var base_sprite_pos: Vector2
##var bob_time: float = 0.0
##var bob_frequency: float = 12.0
##var bob_amplitude: float = 8.0
##
##var current_recoil: Vector2 = Vector2.ZERO
##var recoil_kick: Vector2 = Vector2(0, -30) 
##
##func _ready() -> void:
	##gun_sprite.play("Idle")
	##PlayerStats.change_action(1)
	##can_shoot = true
	### Store the initial position of the gun sprite to use as a baseline for math
	##base_sprite_pos = gun_sprite.position
	###gun_sprite.play("Idle")
	###PlayerStats.change_action(1)
	###can_shoot = true
	##
##func _exit_tree() -> void:
	##PlayerStats.change_action(1)
	##
##func make_flash():
	##var f = flash.instantiate()
	### Add the flash to the CanvasLayer so it stays on the screen
	##$CanvasLayer/Control.add_child(f)
##
	### Position the flash near the barrel (Adjust the Vector2 to fit your sprite)
	##f.position = gun_sprite.position + Vector2(20, -80) 
##
	### Randomize the rotation
	##f.rotation = randf_range(0.0, TAU) # TAU is 360 degrees in radians
##
	### Randomly pick between the two textures
	##if randi() % 2 == 0:
		##f.texture = flash_tex_1
	##else:
		##f.texture = flash_tex_2
	##
##func check_hit():
	##for ray in gun_rays:
		##ray.force_raycast_update()
		##if ray.is_colliding():
			##var target = ray.get_collider()
			##if target.has_method("take_damage"):
				##target.take_damage(damage)
##
				### Terminal output
				##print("Hit confirmed! Dealt ", damage, " to ", target.name)
##
				### Trigger visual hit marker on the player
				##var player = get_tree().get_first_node_in_group("player")
				##if player.has_method("show_hit_marker"):
					##player.show_hit_marker()
					##
##func _process(delta: float) -> void:
	##can_shoot = PlayerStats.get_action()
	##
	### --- Weapon Bobbing Logic ---
	##var player = get_tree().get_first_node_in_group("player")
	### If the player exists, is on the floor, and is actively moving
	##if player and player.is_on_floor() and player.velocity.length() > 1.0:
		##bob_time += delta * bob_frequency
	##else:
		### Smoothly reset bob time to bring the gun back to center when stopped
		##bob_time = lerp(bob_time, 0.0, delta * 5.0)
##
	### Calculate the figure-8 motion
	##var bob_offset = Vector2(
		##cos(bob_time / 2.0) * bob_amplitude,
		##sin(bob_time) * bob_amplitude
	##)
	##
	### --- Recoil Recovery Logic ---
	### Smoothly return the recoil offset back to zero over time
	##current_recoil = current_recoil.lerp(Vector2.ZERO, delta * 15.0)
	##
	### Apply the bob and recoil to the sprite's actual position
	##gun_sprite.position = base_sprite_pos + bob_offset + current_recoil
	### -----------------------------
	##
	##if Input.is_action_just_pressed("shoot") and can_shoot and PlayerInventory.ammo["pistol"] > 0:
		##if left == true:
			##gun_sprite.play("Shoot")
			##left = false
		##else:
			##gun_sprite.play("Shoot2")
			##left = true
			##
		### Trigger the recoil kick
		##current_recoil = recoil_kick
			##
		##make_flash()
		##
		### Called the cleaned-up check_hit function instead of duplicating the logic
		##check_hit()
		##
		##PlayerInventory.change_ammo("pistol", -1)
		##can_shoot = false
		##
		##await(gun_sprite.animation_finished)
		##can_shoot = true
		##gun_sprite.play("Idle")
					##
###func check_hit():
	###for ray in gun_rays:
		###ray.force_raycast_update()
		###if ray.is_colliding():
			###var target = ray.get_collider()
			###if target.has_method("take_damage"):
				###target.take_damage(damage)
###
				#### Terminal output
				###print("Hit confirmed! Dealt ", damage, " to ", target.name)
###
				#### Trigger visual hit marker on the player
				###var player = get_tree().get_first_node_in_group("player")
				###if player.has_method("show_hit_marker"):
					###player.show_hit_marker()
##
### Called every frame. 'delta' is the elapsed time since the previous frame.
###func _process(_delta: float) -> void:
	###can_shoot = PlayerStats.get_action()
	###
	###if Input.is_action_just_pressed("shoot") and can_shoot and PlayerInventory.ammo["pistol"] > 0:
		###if left == true:
			###gun_sprite.play("Shoot")
			###left = false
		###else:
			###gun_sprite.play("Shoot2")
			###left = true
		###make_flash()
		###for ray in gun_rays:
			###ray.force_raycast_update()
			###if ray.is_colliding():
				###var target = ray.get_collider()
				#### Assuming your enemy scripts have a take_damage function
				###if target.has_method("take_damage"):
					###target.take_damage(damage)
		####check_hit()
		###PlayerInventory.change_ammo("pistol", -1)
		###can_shoot = false
		###
		###await(gun_sprite.animation_finished)
		###can_shoot = true
		###gun_sprite.play("Idle")
		###
	###pass
