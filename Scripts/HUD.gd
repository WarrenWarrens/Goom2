extends CanvasLayer


@onready var armour = $MarginContainer/Stats/Values/ArmourValue
@onready var health = $MarginContainer/Stats/Values/HealthValue
@onready var ammo = $MarginContainer/Stats/Values/AmmoValue

func _process(_delta):
	armour.text = PlayerStats.get_armour()
	health.text = PlayerStats.get_health()
	ammo.text = PlayerInventory.get_ammo('pistol')
	
