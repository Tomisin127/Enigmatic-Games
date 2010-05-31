extends Node

func _ready():
	#setting the target to player
	get_node("enemy").target_player = get_node("player")
	
	set_process(true)
	pass
	
func _process(delta):
	
	$hud/CanvasLayer/Control/player_health.value=global.player_health
	$hud/CanvasLayer/Control/player_mana.value=global.mana
	pass


func _on_ladder_area_body_entered(body):
	if body.name == "player":
		$player.on_ladder=true
	pass # Replace with function body.
	

	
func _on_ladder_area_body_exited(body):
	if body.name == "player":
		$player.on_ladder=false
		pass
	pass # Replace with function body.
	
func _on_door_area_body_entered(body):
	if body.name =="player":
		print("player opens")
	pass # Replace with function body.
	
