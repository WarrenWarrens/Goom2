extends CharacterBody3D

@export var speed: float = 4.0
@export var damage: int = 10
@export var attack_range: float = 2.5
@export var detection_range: float = 25.0
@export var attack_cooldown: float = 1.0

@onready var los_ray = $RayCast3D
@onready var attack_timer = $AttackTimer

@export var max_health: int = 30
var current_health: int

var player: CharacterBody3D

# A simple State Machine keeps behavior cleanly separated
enum State { IDLE, CHASE, ATTACK }
var current_state = State.IDLE

func _ready():
	# Make sure your Player node is in the "player" group!
	current_health = max_health
	player = get_tree().get_first_node_in_group("player")

func take_damage(amount: int):
	current_health -= amount
	
	# Optional: Play a pain sound or flash the sprite red here
	
	if current_health <= 0:
		die()

func die():
	# Optional: Spawn a corpse sprite or play a death sound before freeing
	queue_free()
	
	
#regular on the ground
#func _physics_process(_delta):
	#if not player: return
	#
	#var distance_to_player = global_position.distance_to(player.global_position)
	#
	## 1. Dynamically aim the RayCast at the player's chest/head
	## We add 1.0 to the Y axis so the ray doesn't hit the floor
	#var target_center = player.global_position + Vector3(0, 1.0, 0)
	#los_ray.target_position = los_ray.to_local(target_center)
	#los_ray.force_raycast_update() # Forces the ray to update immediately this frame
	#
	#match current_state:
		#State.IDLE:
			## 2. Wake up the enemy if the player is close enough AND visible
			#if distance_to_player <= detection_range:
				#if los_ray.get_collider() == player:
					#current_state = State.CHASE
					#
		#State.CHASE:
			## 3. Transition to attack if close enough
			#if distance_to_player <= attack_range:
				#current_state = State.ATTACK
			#else:
				## Move towards the player
				#var direction = (player.global_position - global_position).normalized()
				#direction.y = 0 # Prevent the enemy from floating up or pushing into the floor
				#velocity = direction * speed
				#move_and_slide()
				#
		#State.ATTACK:
			## 4. Attack, or resume chasing if the player backs away
			#if distance_to_player > attack_range:
				#current_state = State.CHASE
			#elif attack_timer.is_stopped():
				#perform_attack()

func _physics_process(_delta):
	if not player: return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Target the player's chest/head area
	var target_center = player.global_position + Vector3(0, 1.0, 0)
	los_ray.target_position = los_ray.to_local(target_center)
	los_ray.force_raycast_update() 
	
	match current_state:
		State.IDLE:
			if distance_to_player <= detection_range:
				if los_ray.get_collider() == player:
					current_state = State.CHASE
					
		State.CHASE:
			if distance_to_player <= attack_range:
				current_state = State.ATTACK
			else:
				# FLYING MOVEMENT: Move directly toward the target_center in full 3D space
				var direction = (target_center - global_position).normalized()
				
				# Notice we removed "direction.y = 0" 
				# We also DO NOT add gravity to velocity.
				
				velocity = direction * speed
				move_and_slide()
				
		State.ATTACK:
			if distance_to_player > attack_range:
				current_state = State.CHASE
			elif attack_timer.is_stopped():
				perform_attack()
				
func perform_attack():
	# Trigger your attack Sprite3D animation and audio here
	
	# Verify the player hasn't dodged behind a wall at the last second
	if los_ray.get_collider() == player:
		if player.has_method("take_damage"):
			player.take_damage(damage, global_position)
			
	attack_timer.start(attack_cooldown)
