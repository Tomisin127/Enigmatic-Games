extends Node

#load the player scene
onready var playerSC = load("res://scenes/player.tscn")


func _ready():
	
	#setting the target to player
	get_node("enemy").target_player = get_node("player")
	
	#connect the health changes signal to the player
	$player.connect("sg_health_change",$hud,"health_change")
	
	set_process(true)
	pass
	
func _process(delta):
	pass

#revive the player to a initial position after the player dies
func revive(pos : Vector2):
	var player = playerSC.instance()
	player.position = pos
	add_child(player)
	_ready()
	
	
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
	
