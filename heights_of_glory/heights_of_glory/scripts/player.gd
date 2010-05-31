extends KinematicBody2D

class_name tothem

signal activate_magnum_skill

signal revive

signal drop_gems

signal collided


var joystickVector
var screensize

export var speed = 400

var wait_timer= 0

signal damage_enemy

#all the physics variable for the players
const ACCEL =500
const MAX_SPEED = 300
const FRICTION = -50000
var GRAVITY :float = 9.81
const JUMP_HEIGHT =-400
const CLIMB_SPEED = 3




#player's attribute
var player_health : int =5000
var player_mana : int = 100
var mana_regen : int = 100
var player_health_regen : int= 2


# signal works best with health changes using global is overkill and will cause problem later
signal sg_health_change
signal sg_player_dead

const BOOST_UP = -2000

var acceleration = Vector2()

onready var ground_ray = get_node("ground_ray")
onready var player_bullet_container = get_node("player_bullet_container")
onready var player_bullet = preload("res://scenes/player_bullet.tscn")

#bullet script
onready var player_bullet_script = load("res://scripts/player_bullet.gd").new()

#export(Array, String) var starting_skills

#export(PackedScene) var character_skill_scene : PackedScene

#export(float, 0.0, 1.0) var success_chance : float


var on_ladder:bool = false
var on_boost_up:bool = true
var is_shooting:bool = true

var is_dead:bool = true




var joystick_direction : Vector2




func _ready() -> void:
	
	#player shoot by dragging shoot button
	get_parent().get_node("hud/CanvasLayer/Control/shoot_joystick").connect("player_shoot",self,"shoot")
	
	#revive  the player after death, signal
	connect("revive",self,"revive_player")
	
	#this emits signal for the player to be moved by the joysick
	
	
	connect("sg_player_dead",get_parent(),"revive_player")
	connect("sg_health_change",get_parent().get_node("hud"),"health_change")
	
	#set the health to 5000 at the beginning of the game
	emit_signal("sg_health_change",player_health)
	
	
	screensize = get_viewport_rect().size
	
	set_physics_process(true)
	
	pass









func _physics_process(delta):

	
	#update the player's mana bar
	get_parent().get_node("hud/CanvasLayer/Control/player_mana").value =player_mana
	
	#this function for the shoot joystick
	
	
	#rotation = (rotation +PI *2 *delta)
	#get_node("bullet_spawn_pos").global_position = (get_node("bullet_spawn_pos").global_position+t.velocity *delta)
	
	#this will be used to know the tile that the player steps on
	#its not working well yet
	get_tile_on_position(position.x,position.y)
	
	#drag player down by gravity
	acceleration.y += GRAVITY
	if Input.is_action_pressed("ui_left"):
		acceleration.x -= ACCEL 
		get_node("sprite").flip_h=1
		
	elif Input.is_action_pressed("ui_right"):
		acceleration.x += ACCEL 
		get_node("sprite").flip_h =0
		
	
	#adding joystick control
	
	if joystick_direction:
		if joystick_direction.x == 1:
			acceleration.x += ACCEL
			get_node("sprite").flip_h =0
			
		elif joystick_direction.x  == -1:
			acceleration.x -= ACCEL
			get_node("sprite").flip_h =1
			
		#elif joystick_direction.y ==-1:
			#acceleration.y =JUMP_HEIGHT

	
	
	
	
	
	elif Input.is_action_pressed("ui_accept"):
		
		#if the player still as mana , then he is able to shoot
		if player_mana > 0:
			is_shooting=true
			
		#if the player is shooting while mana is low
		#disable shooting
		elif is_shooting and player_mana <= 5:
			is_shooting =false
			
		#if the mana recharges when its low, enable shooting
		elif player_mana>=5 :
			is_shooting=true
		
		shoot(is_shooting)
		
		
	elif Input.is_action_pressed("ui_home"):
		boost_up_super(on_boost_up)
		#if its boosting up then set it to false
		#this means you can only boost up once tru out the game
		if on_boost_up:
			#after using boost up once, disable it 
			on_boost_up=false
		
	
	
	
	
	#slowing down with linear interpolation
	#this serve as friction even a standing object feels friction
	acceleration.x = lerp(acceleration.x, 0, 0.2)
	
	
	
	
	
	#jumping settings
	if is_on_floor() and ground_ray.is_colliding():
		if Input.is_action_pressed("ui_up"):
			acceleration.y = JUMP_HEIGHT
	
	#clamping the velocity to a max speed in both negative and positive x direction
	acceleration.x = clamp(acceleration.x,-MAX_SPEED,MAX_SPEED)
	
	#move and slide the velocity and detect the floor
	acceleration = move_and_slide(acceleration,Vector2(0,-1))
	
	#getting the number of times the player collided with a body
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision:
			emit_signal("collided", collision)
	
	#using the magnum skill
	if is_able_to_use_magnum_skills():
		global.magnum_skills = 0
		#skill animation here and damage here
		
		#activate the skill button
		emit_signal("activate_magnum_skill", true)
		
	elif not is_able_to_use_magnum_skills():
		emit_signal("activate_magnum_skill",false)

		
	#this is use to delay and regenerate mana, see the function below
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
	
	#if player is dead or alive
	dead_or_alive()
	
	pass






func joystick_motion(dir :Vector2):
	
	joystick_direction = dir







#this function helps to know the exact tile the player is stepping on
#this function isnt working well yet but it will soon
func get_tile_on_position(x,y):
	var tilemap = get_parent().get_node("tilemap")
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









#this is another shoot function for testing the second shoot joystick
#but it will be removed
func shoot_a():
	var b= player_bullet.instance()
	player_bullet_container.add_child(b)
	b.start(rotation,get_node("bullet_spawn_pos").global_position)
	#reduce shooting mana
	player_mana -= 10
	pass

	
	
	
	
	
	
	
	
	# this is the real shoot function////shooting bullet 
func shoot(shoot_activate):
	
	#if shoot is true, then shoot, dont mind all the nonsense like "if $sprite.flip_h==false"
	#it is used for testing something, like wen the player flips position,
	#the shoot direction should flip too
	
	if shoot_activate==true:
		#reduce shooting mana
		player_mana -= 10
		
		var b= player_bullet.instance()
		player_bullet_container.add_child(b)
		
		
		b.start(global.shoot_position.angle(),get_node("bullet_spawn_pos").global_position)
		
		
	#if shoot is false, return keyword means, it shouldnt do anything(no shooting)
	elif shoot_activate==false:
		
		print("disable shooting")
		
		return
		



#magmum skill is the super ability of the player
func is_able_to_use_magnum_skills() -> bool:
	"""
	Returns true if the battler can perform an action
	"""
	return global.magnum_skills == 100






#this is the function that takes
func take_damage(hit:int):
	#Lazy 
	#clamp set a limit for the value
	player_health = clamp((player_health - hit),0,100)
	emit_signal("sg_health_change",player_health)
	
	#stagger animation can go here too
	
	print(player_health)
	pass





#dead or alive function called in the processs function
func dead_or_alive():
	
	if is_alive():
		#regenerate player health a little
		player_health = min(player_health + player_health_regen * get_physics_process_delta_time()  ,100)
	
	# player_dies
	if not is_alive():
		die(is_dead)
		
	pass


#player as died called in the dead or alive function
func die(is_dead):
	#player died 
	if is_dead==true:
		
		#upon dying, spawn the collected gems
		emit_signal("drop_gems",global.collected_gems)
		
		global.collected_gems =0
		
		#a dead man cant be walking around, downside is that no gravity is also applied to the body
		set_physics_process(false)
		
		#plays death animation
		#use yield to hold the method
		emit_signal("sg_player_dead",position)
		print("I AM THE PLAYER AND I HAVE DIED")
		#disable all collisions
		$player_area.monitorable=false
		$player_area.monitoring=false
		
		$death_wait_time.wait_time =3
		$death_wait_time.start()
	
	$collision.disabled=true
	
	
	pass

func mana_delay_and_regenerate(change):
	if player_mana >=5:
	#	regenerate mana very time the player mana goes down but not below 5
		player_mana = min(player_mana + mana_regen * get_physics_process_delta_time(),100)
		
	#when the player_mana is low, wait for 5 seconds and recharge the mana
	elif player_mana <=5:
		
		#update wait_timer with delta(change)
		wait_timer +=change
		if wait_timer>1 and wait_timer < 5:
			player_mana = min(player_mana + mana_regen * get_physics_process_delta_time(),100)
			wait_timer=0
			
		
		#print(wait_timer)
		
		
	if player_mana ==0:
		#global.mana = min(global.mana + _get_mana_regen() * get_physics_process_delta_time(),100)
		print("mana is zero")
		
		pass
		
	#check if the player is alive
func is_alive()->bool:
	#dieing is better if the player tells us by itself before dieing
	return player_health >0

#function to make the player fly so high, it works only once, when the value is true 
func boost_up_super(value):
	if value ==true:
		acceleration.y = BOOST_UP
		
	else:
		return 
		
	pass

func _on_JoystickMove(vector):
	joystickVector = vector



func _on_player_area_area_entered(area):
#		#if the enemy is in the player area, the player takes damage
#	if area.is_in_group("enemy"):
#		print("ATTTCGGCGCHCHC")
#		#it takes damage and kills the player
#		take_damage(global.enemy_damage_to_player)
	pass # Replace with function body.
	
func revive_from_death():
	$collision.disabled=false
	$player_area/collision.disabled =false
	set_physics_process(true)
	player_health=5000
	request_ready()
	
	pass
	
	#revive the player to this particular position in the function
func revive_player(revive_pos:Vector2=Vector2(0,100)):
	print("function emits")
	revive_from_death()
	self.position = revive_pos
	
	pass

#waiting after death time as timed out, then the player can now revive
func _on_death_wait_time_timeout():
	print("i am in here, can another")
	set_physics_process(true)
	emit_signal("revive")
	pass # Replace with function body.
