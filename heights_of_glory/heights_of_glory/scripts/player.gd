extends KinematicBody2D

signal damage_enemy

const ACCEL =500
const MAX_SPEED = 300
const FRICTION = -50000
var GRAVITY :float = 9.81
const JUMP_HEIGHT =-400
const CLIMB_SPEED = 3

var acceleration = Vector2()

onready var ground_ray = get_node("ground_ray")
onready var player_bullet_container = get_node("player_bullet_container")
onready var player_bullet = preload("res://scenes/player_bullet.tscn")

#bullet script
onready var player_bullet_script = load("res://scripts/player_bullet.gd").new()

#export var starting_stats : Resource

#export(Array, String) var starting_skills

#export(PackedScene) var character_skill_scene : PackedScene

#export(float, 0.0, 1.0) var success_chance : float


var on_ladder:bool = false


func _ready() -> void:
	

	set_physics_process(true)
	
	pass

func _physics_process(delta):
	
	print(on_ladder)
	 

	#drag player down by gravity
	acceleration.y += GRAVITY
	
	if Input.is_action_pressed("ui_left"):
		acceleration.x -= ACCEL *delta
		get_node("sprite").flip_h=1
		
	elif Input.is_action_pressed("ui_right"):
		acceleration.x += ACCEL *delta
		get_node("sprite").flip_h =0
		
	elif Input.is_action_pressed("ui_accept") and global.mana>0:
		if $shoot_timer.time_left<0.1:
			shoot(true)
		
	elif Input.is_action_pressed("ui_accept") and global.mana<=0:
		shoot(false)
		
		
		
	#slowing down with linear interpolation
	else:
		acceleration.x = lerp(acceleration.x, 0, 0.2)
	
	
	if is_on_floor() and ground_ray.is_colliding():
		if Input.is_action_pressed("ui_up"):
			acceleration.y = JUMP_HEIGHT
	
	#clamping the velocity to a max speed in both negative and positive x direction
	acceleration.x = clamp(acceleration.x,-MAX_SPEED,MAX_SPEED)
	
	#move and slide the velocity and detect the floor
	acceleration = move_and_slide(acceleration,Vector2(0,-1))
	
	
	#using the magnum skill
	if is_able_to_use_magmum_skills():
		global.magmum_skills = 0
		
		#skill animation here and damage here
		emit_signal("damage_enemy")
		player_bullet_script.start()
		
	
	mana_delay_and_regenerate()
	
	#ladder_climbing
	if on_ladder ==true:
		GRAVITY=0
		if Input.is_action_pressed("climb_up"):
			acceleration.y -=CLIMB_SPEED
			
		elif  Input.is_action_pressed("climb_down"):
			acceleration.y +=CLIMB_SPEED
			
		else:
			acceleration.y =0
		
	else:
		GRAVITY=9.81
	
	

	
	pass

func get_tile_on_position(x,y):
	var tilemap = get_parent().get_node("TileMap")
	if not tilemap == null:
		var map_pos = tilemap.world_to_map(Vector2(x,y))
		var id = tilemap.get_cellv(map_pos)
		if id > -1:
			var tilename = tilemap.get_tileset().tile_get_name(id)
			print("tilename : ", tilename)
			return tilename
		else:
			return ""

	
	# shooting bullet 
func shoot(shoot_activate):
	
	if shoot_activate==true:
		var b= player_bullet.instance()
		player_bullet_container.add_child(b)
		b.start(rotation,get_node("bullet_spawn_pos").global_position)
		
		#reduce shooting mana
		global.mana -= 10
		
	else:
		return

func is_able_to_use_magmum_skills() -> bool:
	"""
	Returns true if the battler can perform an action
	"""
	return global.magnum_skills == 500

func take_damage(hit:int):
	global.player_health -= hit
	
	if _get_player_health() > 0:
		global.player_health = min(_get_player_health() + _get_player_health_regen() * get_physics_process_delta_time()  ,5000)
	# prevent playing both stagger and death animation if health <= 0
	"""if global.player_health > 0:
		self.player_stagger_animation()
		
	else:
		self.player_death_animation()"""

func _on_health_depleted():
	if global.player_health < 0:
		set_physics_process(false)
		

func mana_delay_and_regenerate():
	if global.mana >=1:
	#	regenerate mana 
		global.mana = min(global.mana + _get_mana_regen() * get_physics_process_delta_time(),100)
		#print("VALUE OF MANA",global.mana)
		
	elif global.mana <=0:
		global.mana =0
		#global.mana = min(global.mana + 0 * get_physics_process_delta_time(),100)
		
	if global.mana ==0:
		print("mana is zero")
		
func is_alive()->bool:
	return global.player_health >0
	
func _get_player_health():
	return global.player_health
func _get_mana():
	return global.mana
	
func _get_mana_regen():
	return global.mana_regen
	
func _get_player_health_regen():
	return global.player_health_regen


