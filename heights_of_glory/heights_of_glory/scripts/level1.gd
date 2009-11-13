extends Node



#load the player scene
onready var playerSC = load("res://scenes/player.tscn")

#load the gem scene
onready var gems = preload("res://scenes/gems.tscn")

#gem container
onready var gem_container = $gem_container


func _ready():

	
	_on_gem_spawn_time_timeout()
	
	#setting the target to player
	get_node("enemy").target_player = get_node("player")
	
	#connect the health changes signal to the player
	$player.connect("sg_health_change",$hud,"health_change")
	$hud/CanvasLayer/Control/Analog.connect("dir_changed",$player,"joystick_motion")
	set_process(true)
	

	pass
	
func _process(delta):
	#set the collected gems on the screen
	$hud/CanvasLayer/Control/gems_collected.text=str(global.collected_gems)
	

	pass
	
	#function that spawns the gems 
func spawn_gems(amount):
	
	randomize()
	
	for i in range(amount):
		#instance the amount of gems that was passed in the amount variable
		var gem = gems.instance()
		gem_container.add_child(gem)
		
		#set the spawn position of the gems to a random spot
		var position_to_spawn = Vector2()
		
		position_to_spawn.x = rand_range(16, get_viewport().get_visible_rect().size.x-16)
		position_to_spawn.y = rand_range(16, get_viewport().get_visible_rect().size.y-16)
		
		#set gems postion to the spawn position 
		gem.position = position_to_spawn
		
		#the gem will spawn every 7 seconds
		$gem_spawn_time.wait_time=7
		$gem_spawn_time.start()
		print($gem_spawn_time.time_left)
		
	pass

#revive the player to a initial position after the player dies
func revive(pos : Vector2= Vector2(0,100)):
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


#on delay time timrout, spawn one gem
func _on_gem_spawn_time_timeout():
	spawn_gems(1)
	pass # Replace with function body.
