
extends Area3D

# 1. Expand the enum to include all your pickup types
enum PickupType { HEALTH, ARMOUR, AMMO, WEAPON, KEYCARD }

@export var type: PickupType = PickupType.WEAPON

# 2. Use a generic name variable. 
# This will be used as the weapon  name, ammo type, OR keycard color!
@export var item_name: String = "shotgun" 
@export var amount: int = 10

# 3. A specific toggle just for the classic Doom Megaarmor
@export var is_megaarmor: bool = false 

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	# Make sure this string exactly matches the group name on your Player node
	if body.is_in_group("player"): 
		var hud = body.get_node("HUD")
		var picked_up = false
		
		match type:
			PickupType.HEALTH:
				PlayerStats.change_health(amount)
				if hud and hud.has_method("add_message"):
					hud.add_message("Picked up +" + str(amount) + " Health!")
				picked_up = true
				
			PickupType.ARMOUR:
				PlayerStats.pickup_armor(amount, is_megaarmor)
				if hud and hud.has_method("add_message"):
					var msg = "Megaarmor!" if is_megaarmor else "Picked up Armor!"
					hud.add_message(msg)
				picked_up = true
				
			PickupType.AMMO:
				# Route directly to your PlayerInventory singleton
				PlayerInventory.change_ammo(item_name, amount)
				if hud and hud.has_method("add_message"):
					hud.add_message("Picked up " + str(amount) + " " + item_name.capitalize() + " ammo!")
				picked_up = true
				
			PickupType.WEAPON:
				# Reach out to the player script to unlock the weapon
				if body.has_method("unlock_weapon"):
					body.unlock_weapon(item_name)
					if hud and hud.has_method("add_message"):
						hud.add_message("Acquired the " + item_name.capitalize() + "!")
					picked_up = true
					
			PickupType.KEYCARD:
				# Route directly to your PlayerInventory singleton
				PlayerInventory.add_key(item_name)
				if hud and hud.has_method("add_message"):
					hud.add_message("Picked up the " + item_name.capitalize() + " keycard!")
				picked_up = true

		# If the item was successfully collected, delete it from the world
		if picked_up:
			# You can play a global pickup sound effect right here before freeing
			queue_free()
