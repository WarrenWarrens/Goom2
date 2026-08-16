extends CharacterBody3D

# --- Movement Variables ---
const WALK_SPEED: float = 7.0
const MOUSE_SENS: float = 0.002
const BASE_FOV: float = 75.0

# --- Node References ---
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var interact_ray = $Head/Camera3D/InteractionRay
@onready var pistol = $Head/Pistol
@onready var weapons = [pistol]
@onready var ammo_counter = $HUD/MarginContainer/Stats/Values/AmmoValue
@onready var ammo_label = $HUD/MarginContainer/Stats/Labels/AmmoLabel
@onready var speed_label = $HUD/SpeedLabel
@onready var state_label = $HUD/StateLabel
@onready var health_label = $HUD/MarginContainer/Stats/Values/HealthValue

var current_weapon_index: int = 0
var cursor_locked = true
var knockback_velocity: Vector3 = Vector3.ZERO
var last_y_velocity: float = 0.0


func _ready() -> void:
	get_window().grab_focus()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	interact_ray.add_exception(self)
	
	equip_weapon(current_weapon_index)
	
	camera.current = true
	camera.fov = BASE_FOV
	
	floor_constant_speed = true 
	floor_stop_on_slope = true
	floor_max_angle = deg_to_rad(45.0)
	floor_snap_length = 0.5

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	last_y_velocity = velocity.y

	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * WALK_SPEED
		velocity.z = direction.z * WALK_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, WALK_SPEED)
		velocity.z = move_toward(velocity.z, 0, WALK_SPEED)

	knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, delta * 50)
	velocity += knockback_velocity
	
	move_and_slide()
	update_hud_stats()
	if is_on_floor() and last_y_velocity < -15.0:
		var fall_damage = int(abs(last_y_velocity) * 1.5)

		take_damage(fall_damage, global_position - Vector3(0, 1, 0))
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and cursor_locked:
		rotate_y(-event.relative.x * MOUSE_SENS)
		head.rotate_x(-event.relative.y * MOUSE_SENS)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89.0), deg_to_rad(89.0))

func _process(_delta: float) -> void:
	# Direct weapon switching using number keys
	if Input.is_action_just_pressed("weapon_1") and weapons.size() > 0:
		current_weapon_index = 0
		equip_weapon(current_weapon_index)
	elif Input.is_action_just_pressed("weapon_2") and weapons.size() > 1:
		current_weapon_index = 1
		equip_weapon(current_weapon_index)
	# Add more elif statements as you expand your weapons array
	

#func show_hit_marker():
	#hit_marker.visible = true
	## Hide it again after a brief moment
	#await get_tree().create_timer(0.1).timeout
	#hit_marker.visible = false
	
func equip_weapon(index: int) -> void:
	for i in range(weapons.size()):
		if i == index:
			weapons[i].visible = true
			weapons[i].set_process(true)
			weapons[i].set_physics_process(true)
			
			if weapons[i].has_node("CanvasLayer"):
				weapons[i].get_node("CanvasLayer").visible = true
		else:
			weapons[i].visible = false
			weapons[i].set_process(false)
			weapons[i].set_physics_process(false)
			
			if weapons[i].has_node("CanvasLayer"):
				weapons[i].get_node("CanvasLayer").visible = false
			
func hide_current_weapon() -> void:
	var w = weapons[current_weapon_index]
	w.visible = false
	w.set_process(false)
	w.set_physics_process(false)
	
	if w.has_node("CanvasLayer"):
		w.get_node("CanvasLayer").visible = false
		
	ammo_counter.visible = false
	ammo_label.visible = false
			
func update_hud_stats() -> void:
	var current_speed = Vector2(velocity.x, velocity.z).length()
	
	if speed_label:
		speed_label.text = "Speed: %.1f" % current_speed
	
	if state_label:
		state_label.text = "State: Walking"
		
	if health_label:
		health_label.text = "HP: " + PlayerStats.get_health()

func take_damage(amount: int, attacker_pos: Vector3):
	PlayerStats.take_damage(amount)
	
	var kb_dir = (global_position - attacker_pos).normalized()
	kb_dir.y = 0
	knockback_velocity = kb_dir * 5.0
