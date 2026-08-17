extends Node

# Scalable dictionaries for ammo and keys
var ammo = {
	"pistol": 50,
	"rifle": 100,
	"shotgun": 100,
	"rpg": 100
}

var max_ammo = {
	"pistol": 200,
	"rifle": 500,
	"shotgun": 50,
	"rpg": 200
}

var keys = {
	"red": false,
	"blue": false,
	"yellow": false
}

func change_ammo(type: String, amount: int):
	if ammo.has(type):
		ammo[type] = clamp(ammo[type] + amount, 0, max_ammo[type])

func get_ammo(type: String) -> String:
	return str(ammo.get(type, 0))

func add_key(color: String):
	if keys.has(color):
		keys[color] = true

func has_key(color: String) -> bool:
	return keys.get(color, false)
