extends Node

func _ready():
	
	#setting the target to player
	get_node("enemy").target_player = get_node("player")
	
	set_process(true)
	pass
	
func _process(delta):
	
	$hud/CanvasLayer/player_health.value=global.player_health
	$hud/CanvasLayer/player_mana.value=global.mana
	pass
