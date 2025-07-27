extends Area2D

# This script can be attached to stump, rock, and barrel obstacles
# It provides basic functionality for ground obstacles

func _ready():
	# Connect the body_entered signal to handle collisions
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# This will be handled by the main scene
	pass 