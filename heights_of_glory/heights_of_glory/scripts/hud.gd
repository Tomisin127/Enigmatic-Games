extends Node





# Called when the node enters the scene tree for the first time.
func _ready():
	pass

#change player health upon attack from enemy
func health_change(health: int):
	$CanvasLayer/Control/player_health/health_tween.interpolate_property($CanvasLayer/Control/player_health,"value",$CanvasLayer/Control/player_health.value,health,0.5,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$CanvasLayer/Control/player_health/health_tween.start()
	#print("change in health",health)