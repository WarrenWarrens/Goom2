extends Node3D

@onready var gun_sprite = $CanvasLayer/Control/GunSprite
@onready var gun_rays =$GunRays.get_children()
@onready var flash = preload("res://Scenes/MuzzleFlash.tscn")

var can_shoot = true
var damage = 8
var is_gun: bool = true
var left: bool = true

func _ready() -> void:
	gun_sprite.play("Idle")
	PlayerStats.change_action(1)
	can_shoot = true
	
func _exit_tree() -> void:
	PlayerStats.change_action(1)
	
func make_flash():
	var f = flash.instantiate()
	add_child(f)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	can_shoot = PlayerStats.get_action()
	
	if Input.is_action_just_pressed("shoot") and can_shoot and PlayerInventory.ammo["pistol"] > 0:
		if left == true:
			gun_sprite.play("Shoot")
			left = false
		else:
			gun_sprite.play("Shoot2")
			left = true
		make_flash()
		for ray in gun_rays:
			ray.force_raycast_update()
			if ray.is_colliding():
				var target = ray.get_collider()
				# Assuming your enemy scripts have a take_damage function
				if target.has_method("take_damage"):
					target.take_damage(damage)
		#check_hit()
		PlayerInventory.change_ammo("pistol", -1)
		can_shoot = false
		
		await(gun_sprite.animation_finished)
		can_shoot = true
		gun_sprite.play("Idle")
		
	pass
