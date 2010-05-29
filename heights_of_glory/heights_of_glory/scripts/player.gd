extends KinematicBody2D

class_name player

var joystickVector
var screensize
export var speed = 400

#getting the player_bullet_class
var t = player_bullet_class.new()

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

func _ready() -> void:
	#this emits signal for the player to be moved by the joysick
	get_parent().get_node('hud/CanvasLayer/Control/Analog').connect('move', self, '_on_JoystickMove')
	get_parent().get_node('hud/CanvasLayer/Control/shoot_joystick').connect('shoot_signal', self, 'shoot_a')
	
	
	connect("sg_player_dead",get_parent(),"revive_player")
	connect("sg_health_change",get_parent().get_node("hud"),"health_change")
	
	emit_signal("sg_health_change",player_health)
	
	
	screensize = get_viewport_rect().size
	
	set_physics_process(true)
	
	pass

func _physics_process(delta):
	
	#update the player's mana bar
	get_parent().get_node("hud/CanvasLayer/Control/player_mana").value =player_mana
	
	#this function for the shoot joystick
	move(delta)
	
	#rotation = (rotation +PI *2 *delta)
	#get_node("bullet_spawn_pos").global_position = (get_node("bullet_spawn_pos").global_position+t.velocity *delta)
	
	#this will be used to know the tile that the player steps on
	#its not working well yet
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
		
		#if the player still as mana , then he is able to shoot
		if player_mana > 0:
			is_shooting=true
			
		#if the player is shooting while mana is low
		#disable shooting
		elif is_shooting and player_mana <= 5:
			is_shooting =false
			
		#if the mana recharges when its low, enable shooting
		elif global.mana>=5 :
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
	else:
		acceleration.x = lerp(acceleration.x, 0, 0.2)
	
	#jumping settings
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
		#player_bullet_script.start()
		
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
	pass

#this function helps to know the exact tile the player is stepping on
#this function isnt working well yet but it will soon
func get_tile_on_position(x,y):
	var tilemap = get_parent().get_node("TileMap")
	if not tilemap == null:
		var map_pos = tilemap.world_to_map(Vector2(x,y))
		var id = tilemap.get_cellv(map_pos)
		if id > -1:
			var tilename = tilemap.get_tileset().tile_get_name(id)
#			print("tilename : ", tilename)
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
		
		if $sprite.flip_h==false:
			b.start(rotation,get_node("bullet_spawn_pos").global_position)
		elif $sprite.flip_h==true:
			b.start(rotation,get_node("bullet_spawn_pos").global_position)
			t.velocity=Vector2(t.speed,0).rotated(t.rotation -PI)
			
	#if shoot is false, return keyword means, it shouldnt do anything(no shooting)
	elif shoot_activate==false:
		print("disable shooting")
		return
#magmum skill is the super ability of the player
func is_able_to_use_magmum_skills() -> bool:
	"""
	Returns true if the battler can perform an action
	"""
	return global.magnum_skills == 500

#this is the function that takes
func take_damage(hit:int):
	player_health -= hit
	
	if player_health > 0:
		player_health = min(player_health + player_health_regen * get_physics_process_delta_time()  ,5000)
	# prevent playing both stagger and death animation if health <= 0
	"""if global.player_health > 0:
		self.player_stagger_animation()
		
	else:
		self.player_death_animation()"""
		
	
	#Lazy 
	
	#clamp set a limit for the value
	player_health = clamp((player_health - hit),0,5000)
	emit_signal("sg_health_change",player_health)
	if player_health == 0:
		die()
	else:
		#play hurt animation
		pass

#player as died
func _on_health_depleted():
	if player_health < 0:
		set_physics_process(false)
		

func mana_delay_and_regenerate(change):
	if player_mana >=5:
	#	regenerate mana very time the player mana goes down but not below 5
		player_mana = min(player_mana + mana_regen * get_physics_process_delta_time(),100)
		
	#when the player_mana is low, wait for 5 seconds and recharge the mana
	elif player_mana <=5:
		player_mana =0
		
		#update wait_timer with delta(change)
		wait_timer +=change
		if wait_timer>5:
			player_mana = min(player_mana + mana_regen * get_physics_process_delta_time(),100)
			wait_timer=0
			
		
		print(wait_timer)
		
		
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

#lazy
func die():
	#a dead man cant be walking around, downside is that no gravity is also applied to the body
	set_physics_process(false)
	#plays death animation
	#use yield to hold the method
	emit_signal("sg_player_dead",position)
	queue_free()
	
	pass
	
	#no explanation yet
func move(delta):
	var velocity = Vector2()
	var nextPosition = position

	if joystickVector and joystickVector.length() != 0:
		velocity += joystickVector
	if velocity.length() > 0:
		velocity = velocity * speed
	
	nextPosition += velocity * delta
	nextPosition.x = clamp(nextPosition.x, 0, screensize.x)
	nextPosition.y = clamp(nextPosition.y, 0, screensize.y)

	position = nextPosition

func _on_JoystickMove(vector):
	joystickVector = vector

