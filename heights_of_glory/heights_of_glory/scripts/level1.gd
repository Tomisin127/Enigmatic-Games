extends Node



#load the player scene
onready var playerSC = load("res://scenes/player.tscn")

#load the gem scene
onready var gems = preload("res://scenes/gems.tscn")

#gem container
onready var gem_container = $gem_container


func _ready():
	$player.connect("collided",self, "on_character_collided")
	
	_on_gem_spawn_time_timeout()
	
	#setting the target to player
	get_node("enemy").target_player = get_node("player")
	get_node("enemy_z").target_player = get_node("player")
	
	#connect the health changes signal to the player
	$player.connect("sg_health_change",$hud,"health_change")
	$hud/CanvasLayer/Control/Analog.connect("dir_changed",$player,"joystick_motion")
	set_process(true)
	
	#when the player dies, drop the collected gems
	get_node("player").connect("drop_gems",self, "drop_collected_gems")
	

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
		
		#detect if the gem spawn on the tile
		var tile_name = get_tile_on_position(position_to_spawn.x, position_to_spawn.y)
		
		#print(tile_name)
		#if the gem does not spawn on the tile , then it should spawn somewhere else
		if !tile_name :
			gem.position = position_to_spawn
			
		#if the gem spawn on the tile, then it should delete that gem that spawn on that tile
		elif tile_name == "floor1" or "floor2" or "floor3" or "floor4" or "floor5" or "floor6" or "wall":
			gem.queue_free()
			
			#print("spawned in wall")
			return
			
			
		#the gem will spawn every 7 seconds
		$gem_spawn_time.wait_time=1
		$gem_spawn_time.start()
		print($gem_spawn_time.time_left)
		

	pass

func drop_collected_gems(amount):
	
	randomize()
	
	for i in range(amount):
		#instance the amount of gems that was passed in the amount variable
		var gem = gems.instance()
		
		$gems_dropped_container.add_child(gem)
		
		#drop collected gems at the position where player died
		gem.position = $player.position
		
		
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

#player collide with tilemap
func on_character_collided(collision):
	if collision.collider is TileMap:
		var tile_pos = collision.collider.world_to_map($player.position)
		tile_pos -= collision.normal
		var tile= collision.collider.get_cellv(tile_pos)
		var tile_name = $tilemap.get_tileset().tile_get_name(tile)
		if tile > 0:
			print(tile_name)
			
			$tilemap.set_cellv(tile_pos, tile)
		
	pass
	
	
	#second code for player colliding on tile map
func get_tile_on_position(x,y):
	var tilemap = get_node("tilemap")
	if not tilemap == null:
		var map_pos = tilemap.world_to_map(Vector2(x,y))
		var id = tilemap.get_cellv(map_pos)
		#print(id)
		if id > -1:
			var tilename = tilemap.get_tileset().tile_get_name(id)
			print("tilename :", tilename)
			return tilename
			
		else:
			return ""