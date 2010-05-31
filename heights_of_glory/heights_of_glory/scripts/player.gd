extends KinematicBody2D

class_name player

var t = player_bullet_class.new()
var wait_timer= 0

signal damage_enemy

const ACCEL =500
const MAX_SPEED = 300
const FRICTION = -50000
var GRAVITY :float = 9.81
const JUMP_HEIGHT =-400
const CLIMB_SPEED = 3

const BOOST_UP = -2000

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
var on_boost_up:bool = true
var is_shooting:bool = true

func _ready() -> void:
	

	

	set_physics_process(true)
	
	pass

func _physics_process(delta):
	
	#rotation = (rotation +PI *2 *delta)
	get_node("bullet_spawn_pos").global_position = (get_node("bullet_spawn_pos").global_position+t.velocity *delta)

	get_tile_on_position(position.x,position.y)
	
	#drag player down by gravity
	acceleration.y += GRAVITY
	
	if Input.is_action_pressed("ui_left"):
		acceleration.x -= ACCEL *delta
		get_node("sprite").flip_h=1
		
	elif Input.is_action_pressed("ui_right"):
		acceleration.x += ACCEL *delta
		get_node("sprite").flip_h =0
		
	elif Input.is_action_pressed("ui_accept"):
		#if $shoot_timer.time_left==0:
		if global.mana > 0:
			is_shooting=true
			
		
		elif is_shooting and global.mana <= 5:
			print("so freaking true")
			is_shooting =false
			
		elif global.mana>=5 :
			is_shooting=true
		
		shoot(is_shooting)
		
		
	elif Input.is_action_pressed("ui_home"):
		boost_up_super(on_boost_up)
		#if its boosting up then set it to false
		#this means you can only boost up once tru out the game
		if on_boost_up:
			on_boost_up=false
		
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
		
	
	mana_delay_and_regenerate(delta)
	
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
		
		if $sprite.flip_h==false:
			b.start(rotation,get_node("bullet_spawn_pos").global_position)
		elif $sprite.flip_h==true:
			b.start(rotation,get_node("bullet_spawn_pos").global_position)
			t.velocity=Vector2(t.speed,0).rotated(t.rotation -PI)
			
			
			
		
		#reduce shooting mana
		global.mana -= 10
		
	elif shoot_activate==false:
		print("did i return here")
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
		

func mana_delay_and_regenerate(change):
	if global.mana >=1:
	#	regenerate mana 
		global.mana = min(global.mana + _get_mana_regen() * get_physics_process_delta_time(),100)
		#print("VALUE OF MANA",global.mana)
		
	elif global.mana <=5:
		global.mana =0
		
		wait_timer +=change
		
		if wait_timer>5:
			global.mana = min(global.mana + _get_mana_regen() * get_physics_process_delta_time(),100)
			wait_timer=0
			
		print(wait_timer)
		
		#global.mana = min(global.mana + 0 * get_physics_process_delta_time(),100)
		
	if global.mana ==0:
		
		#global.mana = min(global.mana + _get_mana_regen() * get_physics_process_delta_time(),100)
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

func boost_up_super(value):
	if value ==true:
		acceleration.y = BOOST_UP
		
	else:
		return 
		
	pass

