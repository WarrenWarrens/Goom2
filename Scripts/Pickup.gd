extends Area3D

@export_enum("Health", "Armor", "Pistol Ammo") var pickup_type: String = "Health"
@export var amount: int = 10

@onready var sprite = $Sprite3D
var start_y: float

func _ready():
	# Connect the body_entered signal via code or the Node panel
	body_entered.connect(_on_body_entered)
	start_y = sprite.position.y

func _process(delta):
	# Creates a gentle floating bob effect
	sprite.position.y = start_y + (sin(Time.get_ticks_msec() / 200.0) * 0.2)

func _on_body_entered(body):
	if body.is_in_group("player"):
		match pickup_type:
			"Health":
				PlayerStats.change_health(amount)
			"Armor":
				# Assuming standard green armor
				PlayerStats.pickup_armor(amount, false) 
			"Pistol Ammo":
				PlayerInventory.change_ammo("pistol", amount)
		
		# Play a pickup sound globally here if desired
		queue_free()
