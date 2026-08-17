extends CanvasLayer


@onready var armour = $MarginContainer/Stats/Values/ArmourValue
@onready var health = $MarginContainer/Stats/Values/HealthValue
@onready var event_log = $EventLog 

func _process(_delta):
	armour.text = PlayerStats.get_armour()
	health.text = PlayerStats.get_health()
	
func add_message(text: String) -> void:
	var new_label = Label.new()
	new_label.text = text

	# Optional: Add retro styling
	new_label.add_theme_font_size_override("font_size", 16)
	new_label.add_theme_color_override("font_color", Color(0.8, 1.0, 0.8)) # Light green terminal text

	# Add it to the VBoxContainer (it will automatically stack)
	event_log.add_child(new_label)

	# Wait 3 seconds, then delete the message
	await get_tree().create_timer(3.0).timeout
	if is_instance_valid(new_label):
		new_label.queue_free()
