extends Node

var health = 100
var max_health = 200

var armour = 0
var max_armour = 200

# Set to 0.33 for Green Armor, 0.50 for Blue Armor
var armor_absorption: float = 0.33 
var action = true

func reset():
	health = 100
	armour = 0
	armor_absorption = 0.33
	action = true
	
func take_damage(amount: int):
	# Calculate how much damage the armor absorbs
	var damage_to_armor = int(amount * armor_absorption)
	var damage_to_health = amount - damage_to_armor
	
	if damage_to_armor > armour:
		var leftover_damage = damage_to_armor - armour
		damage_to_health += leftover_damage
		armour = 0
	else:
		armour -= damage_to_armor
		
	change_health(-damage_to_health)
	
	if health <= 0:
		game_over()

func pickup_armor(amount: int, is_megaarmor: bool = false):
	if is_megaarmor:
		armor_absorption = 0.50
	elif armour == 0:
		armor_absorption = 0.33
	
	armour = clamp(armour + amount, 0, max_armour)

func game_over():
	reset()
	get_tree().reload_current_scene()

func change_health(amount: int):
	health = clamp(health + amount, 0, max_health)

func change_action(value: int):
	action = (value == 1)

func get_health() -> String:
	return str(health)

func get_armour() -> String:
	return str(armour)

func get_action() -> bool:
	return action
