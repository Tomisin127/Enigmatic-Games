extends Node



#load the player scene
onready var playerSC = load("res://scenes/player.tscn")

#load the gem scene
onready var gems = preload("res://scenes/gems.tscn")

#gem container
onready var gem_container = $gem_container

#preload the hud for joystick
onready var hud = preload("res://scenes/hud.tscn")

onready var police_enemy_scene = preload("res://scenes/enemy.tscn")

onready var flying_gizmo = preload("res://scenes/flying_gizmo.tscn")

onready var fast_zombies = preload("res://scenes/fast_zombies.tscn")

var fast_zombs

var list_of_police_enemy=[]

var list_of_police_enemy_position =[]

var list_of_flying_gizmo = []

onready var gizmo_line = $gizmo_line

onready var gizmo

func _ready():
	#all level1 signals are in this function
	all_signals()
	
	#spawn the enemy at a position and add it to a dictionary
	spawn_police_enemy_at_position()
	
	spawn_gizmo_at_position()
	
	spawn_fast_zombies()
	

	
	if global.use_joystick ==true:
		print("using joystick is true")
		
	else:
		print("use_buttons")
		
	
	#spawn a gem upon start game
	_on_gem_spawn_time_timeout()
	
	#setting the target to player
	get_node("enemy_z").target_player = get_node("player")

	

	set_process(true)
	
	pass
	
func _process(delta):
	
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
		
		print("tile name were gem collide: ", tile_name)
		
		#if the gem does not spawn on the tile , then it should spawn somewhere else
		if !tile_name :
			gem.position = position_to_spawn
			
		#if the gem spawn on the tile, then it should delete that gem that spawn on that tile
		elif tile_name == "floor0" or "floor1" or "floor2" or "floor3" or "floor4" or "floor5" or "floor6" or "floor7" or "wall":
			gem.queue_free()
			
			print("spawned in wall")
			return
			
			
		#the gem will spawn every 7 seconds
		$gem_spawn_time.wait_time=7
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
			
func all_signals():
	#connect the health changes signal to the player
	$player.connect("sg_health_change",$hud,"health_change")
	
	#check the direction at which the move joystick analog is dragged too
	$hud/CanvasLayer/Control/Analog.connect("dir_changed",$player,"joystick_motion")
	
	#when the player dies, drop the collected gems
	get_node("player").connect("drop_gems",self, "drop_collected_gems")
	
	#checking player collision points
	$player.connect("collided",self, "on_character_collided")
	
	pass
	
func spawn_police_enemy_at_position():
	list_of_police_enemy = []
	
	for i in range(1):
		
		randomize()
		
		#create an instance of the police_enemy_scene
		var police_enemy = police_enemy_scene.instance()
		$police_enemy_container.add_child(police_enemy)
		
		#set the target of that enemy to the player
		police_enemy.target_player=get_node("player")
		
		#add the enemy to a list
		list_of_police_enemy.append(police_enemy)
		
		print("inside the list: ", list_of_police_enemy)
		
		#create a spawn position for the enemy
		var spawn_position = Position2D.new()
		add_child(spawn_position)
		
		#add the position to a list
		list_of_police_enemy_position.append(spawn_position)
		
		#create a variable to spawn the positions at a random_position
		var position_to_spawn_the_created_position = Vector2()
		
		position_to_spawn_the_created_position.x = rand_range(16, get_viewport().get_visible_rect().size.x-16)
		position_to_spawn_the_created_position.y = rand_range(16, get_viewport().get_visible_rect().size.y-16)
		
		#set the spawn position to that random position
		spawn_position.position = position_to_spawn_the_created_position
		
		#set the instances of the police enemy to that spawn position
		police_enemy.position = spawn_position.position
		 
		
		#var number_of_position= randi() % list_of_enemy_position.size()
		
	pass
	
func spawn_gizmo_at_position():
	for i in range(1):
		gizmo = flying_gizmo.instance()
		$"flying gizmo_container".add_child(gizmo)
		gizmo.path = $gizmo_line/PathFollow2D
		
	pass
	#on timer timeout spawn fast zombies
func spawn_fast_zombies():
	print("timer out")
	for i in range(2):
		fast_zombs = fast_zombies.instance()
		$fast_zombies_container.add_child(fast_zombs)
		fast_zombs.position = gizmo.position
		