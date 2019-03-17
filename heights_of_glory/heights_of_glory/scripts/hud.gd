extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func health_change(health: int):
	$CanvasLayer/Control/player_health/health_tween.interpolate_property($CanvasLayer/Control/player_health,"value",$CanvasLayer/Control/player_health.value,health,3,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$CanvasLayer/Control/player_health/health_tween.start()
	print("change in health",health)