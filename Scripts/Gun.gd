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
			var target = ray.get_collider()

			
			if is_explosive:
				spawn_explosion(hit_pos)
				ray.target_position = original_target 
				break 
				
			if target.has_method("take_damage"):
				target.take_damage(damage)
				var player = get_tree().get_first_node_in_group("player")
				if player and player.has_method("show_hit_marker"):
					player.show_hit_marker()
				
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
	
