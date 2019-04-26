extends KinematicBody2D

var p =0

var revive_timer = 0

class_name tothem

signal activate_magnum_skill

signal revive

signal drop_gems

signal collided

var diagonal_timer=0

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
var player_mana : float = 100
var mana_regen : float = 4.0
var player_health_regen : int= 2

var player_mana_divisions : int = player_mana /4

# signal works best with health changes using global is overkill and will cause problem later
signal sg_health_change
signal sg_player_dead

const BOOST_UP = -1000

var acceleration = Vector2()

onready var ground_ray = get_node("ground_ray")
onready var player_bullet_container = get_node("player_bullet_container")
onready var player_bullet = preload("res://scenes/player_bullet.tscn")

onready var joystick_hud = get_parent().get_node("hud")
onready var button_hud = get_parent().get_node("button_hud")

#export(Array, String) var starting_skills

#export(PackedScene) var character_skill_scene : PackedScene

#export(float, 0.0, 1.0) var success_chance : float


var on_ladder:bool = false
var on_boost_up:bool = true
var is_shooting:bool = true
var is_dead:bool = false

var joystick_direction : Vector2

export (NodePath) var joystick_one_path;
export (NodePath) var joystick_two_path;

var joystick_one;
var joystick_two;

var JOYSTICK_DEADZONE = 0.4
var SHOOT_JOYSTICK_DEADZONE = 0.7

func _ready() -> void:
	
	player_signals()
	
	player_mana = clamp(player_mana, 1,player_mana)
	screensize = get_viewport_rect().size
	
	set_physics_process(true)
	
	joystick_one = get_node(joystick_one_path);
	joystick_two = get_node(joystick_two_path);
	
	pass





func _physics_process(delta):
	print("the shoot state: ", joystick_two.shoot_pressed_and_release)
		# Move based on the joystick, only if the joystick is farther than the dead zone.
	if (joystick_one.joystick_vector.length() > JOYSTICK_DEADZONE/2):
		move_and_slide(-joystick_one.joystick_vector * ACCEL);
		
	
	#shoot based on drag 
	
	if joystick_two.joystick_vector.length()>SHOOT_JOYSTICK_DEADZONE:
		p = joystick_two.joystick_vector.length()
	
	print("value in p : ", p)
	
	if (joystick_two.joystick_vector.length() >SHOOT_JOYSTICK_DEADZONE) and $shoot_timer.time_left<0.7 and is_mana_full():

		shoot(true)

	
	elif (joystick_two.shoot_pressed_and_release==true  and $shoot_timer.time_left<0.3 and is_mana_full()):
		auto_shoot(true if not p > SHOOT_JOYSTICK_DEADZONE else false)
		p=0
		joystick_two.shoot_pressed_and_release=false
		
		
		
	if not is_mana_full():
		
		auto_shoot(false)
		shoot(false)
		
		pass
		
		
	#pass player mana status to global script
	global.player_mana_copy = player_mana
	
	#if the shoot analog is dragged in the left or the right direction 
	#the player faces that direction
	if global.control_vec.x ==1:
		$sprite.flip_h=false
		
	elif global.control_vec.x == -1:
		$sprite.flip_h=true
		
	
	
	
	#this function for the shoot joystick
	#rotation = (rotation +PI *2 *delta)
	#get_node("bullet_spawn_pos").global_position = (get_node("bullet_spawn_pos").global_position+t.velocity *delta)

	
	
	#this will be used to know the tile that the player steps on
	#its not working well yet
	get_tile_on_position(position.x,position.y+35)
	
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
		
		
		#the distance from the center of the move analog which is the small_circle
		#from the direction that the joystick is pointing
		var joy_distance = (global.move_analog_center - joystick_direction)
		
		var joy_diagonal =(joystick_direction.x-joystick_direction.y)/2
		
		#print("joy diagonal length: ", joy_diagonal)
		var joy_angle = rad2deg(global.move_analog_center.angle_to(joystick_direction))
		
		#rotate the player acceleration to the angle where the joystick is pointing
		acceleration.rotated(joy_distance.angle())
		#print("joystick angle: ",joy_angle)
		

			
		
		#print("joy_diagonal: ", joy_diagonal)
		
		#if the analog is dragged diagonally
		if joy_diagonal==0.5:
			
			#start the timer
			diagonal_timer +=delta
			
			#if timer is less than 1, jump diagonally
			if diagonal_timer < 1:
				acceleration = Vector2(joy_distance.x, joy_distance.y)*5
				
			#if timer is more than 1 and is on the floor jump immediately upon landing
			#reset the timer back to zero
			
			elif diagonal_timer >1 and is_on_floor():
				diagonal_timer=0
				
		if joy_diagonal==-0.5:
			diagonal_timer +=delta
			#print(diagonal_timer)
			if diagonal_timer < 1:
				acceleration = Vector2(joy_distance.x, joy_distance.y)*5
			elif diagonal_timer >1 and is_on_floor():
				diagonal_timer=0
			
			
			#if  up, the jump up
		elif joystick_direction.y ==-1 and is_on_floor():
			
			#print(joy_diagonal)
			acceleration.y =JUMP_HEIGHT
			
			#move right
		elif joystick_direction.x ==1 and is_on_floor():
			acceleration.x += ACCEL 
			$sprite.flip_h=0
			
			#move left
		elif joystick_direction.x ==-1 and is_on_floor():
			acceleration.x -=ACCEL
			$sprite.flip_h=1
			
		
	
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
		
		#if global.shoot_position.length() > 70:
		shoot(is_shooting)
		
		
	elif Input.is_action_pressed("ui_home"):
		boost_up_super(on_boost_up)
		#if its boosting up then set it to false
		#this means you can only boost up once tru out the game
		if on_boost_up:
			#after using boost up once, disable it 
			on_boost_up=true
		
	#print("joystick_direction: ",joystick_direction)
	
	
	
	
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
	dead_or_alive(delta)
	
	#revive after 3 seconds
	revive_player()
	
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
		if id > -1:
			var tilename = tilemap.get_tileset().tile_get_name(id)
			return tilename
		else:
			return ""









#the player can auto attack when the taps on the joystick and if he is close
#to an enemy nearby
func auto_shoot(activate):
	
	$shoot_timer.start()
	
	if activate==true:
		var b= player_bullet.instance()
		player_bullet_container.add_child(b)
		
		#the enemy is the police zombie(the one animated by lazy programmer while the enemy z is the enemy_zombie
		#(the previous one)
		
		#get the distance from the player bullet position to the enemies
		var bullet_distance_to_enemy= self.position.distance_to(get_parent().get_node("enemy").position if get_parent().get_node("enemy") else Vector2(0,0))
		var bullet_distance_to_enemy_zombie = self.position.distance_to(get_parent().get_node("enemy_z").position if get_parent().get_node("enemy_z") else Vector2(0,0))
		
		
		#if the distance of an enemy is shorter target the nearby one
		#rotate the player bullet in the direction of that nearby 
		
		#var enemy_angle = get_parent().get_node("enemy").position.angle() if get_parent().get_node("enemy") else 0
		#enemy_angle = rad2deg(enemy_angle)
		
		#var enemy_z_angle = get_parent().get_node("enemy_z").position.angle() if get_parent().get_node("enemy_z") else 0
		#enemy_z_angle = rad2deg(enemy_z_angle)
		
		#bullet should travel in direction of shooting and where the player is facing
		if $sprite.flip_h==false:
			b.start(0,get_node("bullet_spawn_pos").global_position)
			
		elif $sprite.flip_h==true:
			b.start(-PI,get_node("bullet_spawn_pos").global_position)
			
		
		#if bullet_distance_to_enemy < bullet_distance_to_enemy_zombie:
			#b.start(enemy_angle,get_node("bullet_spawn_pos").global_position)
			#print("police enemy is less than zombie: ", bullet_distance_to_enemy)
		
		#elif bullet_distance_to_enemy_zombie < bullet_distance_to_enemy:
			#b.start(enemy_z_angle,get_node("bullet_spawn_pos").global_position)
			#print("zombie distance is less: ", bullet_distance_to_enemy_zombie )
			
		#reduce shooting mana
		player_mana -= player_mana_divisions
		
	else:
		
		return
		
	pass

	
	
	
	
	
	
	
	
	# this is the real shoot function for when the shoot analog is dragged////shooting bullet 
func shoot(shoot_activate):
	
	$shoot_timer.start()
	#if shoot is true, then shoot, dont mind all the nonsense like "if $sprite.flip_h==false"
	#it is used for testing something, like wen the player flips position,
	#the shoot direction should flip too
	
	if shoot_activate==true:
		#reduce shooting mana
		player_mana -= player_mana_divisions
		
		var b= player_bullet.instance()
		player_bullet_container.add_child(b)
		
		
		b.start(global.shoot_position.angle(),get_node("bullet_spawn_pos").global_position)
		
		
	#if shoot is false, return keyword means, it shouldnt do anything(no shooting)
	elif shoot_activate==false:
		#print("disable shooting")
		return
		



#magmum skill is the super ability of the player
func is_able_to_use_magnum_skills() -> bool:
	return global.magnum_skills == 100






#this is the function that takes
func take_damage(hit:int):
	#Lazy 
	#clamp set a limit for the value
	player_health = clamp((player_health - hit),0,100)
	emit_signal("sg_health_change",player_health)
	
	#stagger animation can go here too
	
	#print(player_health)
	pass





#dead or alive function called in the processs function
func dead_or_alive(change_in_time):
	
	if is_alive():
		#regenerate player health a little
		#player_health = min(player_health + player_health_regen * get_physics_process_delta_time()  ,100)
		pass
	# player_dies
	if not is_alive():
		die(change_in_time)
		
	pass


#player as died called in the dead or alive function
func die(change_in_time):
	#player died 
	if not is_alive():
		print("NO LONGER ALIVE")
		#upon dying, drop the collected gems
		emit_signal("drop_gems",global.collected_gems)
		
		global.collected_gems =0
		
		#a dead man cant be walking around, downside is that no gravity is also applied to the body
		#set_physics_process(false)
		
		$collision.disabled=true
		$player_area/collision.disabled=true
		
		revive_timer +=change_in_time
		
		get_viewport().gui_disable_input=true
		
		#plays death animation
		#use yield to hold the method
		emit_signal("sg_player_dead",position)
		#print("I AM THE PLAYER AND I HAVE DIED")
		#disable all collisions
		$player_area.monitorable=false
		$player_area.monitoring=false
		
		position= Vector2(20,20)
		
		hide()
	
	
	pass

func mana_delay_and_regenerate(change):
	#print("the player mana : " , player_mana)
	#print("the divisions: ",player_mana_divisions)
	
	
	if player_mana >=0.1:
		player_mana = min(player_mana + mana_regen *change ,100)
		
	elif player_mana <=0:
		player_mana =0
		wait_timer +=change
		if wait_timer > 4:
			player_mana = 100
			wait_timer=0
			print("playermana: ",player_mana)

		
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
	
	pass # Replace with function body.
	
func revive_from_death():
	if revive_timer >3:
		request_ready()
		$collision.disabled=false
		$player_area/collision.disabled =false
		#set_physics_process(true)
		player_health=5000
		show()
		get_viewport().gui_disable_input=false
	
	pass
	
	#revive the player to this particular position in the function
func revive_player():
	#print("function emits")
	revive_from_death()
	
	pass

#waiting after death time as timed out, then the player can now revive
func _on_death_wait_time_timeout():
	#print("i am in here, can another")
	set_physics_process(true)
	emit_signal("revive")
	pass # Replace with function body.

func player_signals():
	
	#player shoot by button
	#button_hud.connect("shoot_by_button",self,"auto_shoot")
	
	#player shoot by dragging shoot button
	#joystick_hud.get_node("CanvasLayer/Control/shoot_joystick").connect("player_shoot",self,"shoot")
	
	#auto attack for the player when he taps the shoot analog
	#joystick_hud.get_node("CanvasLayer/Control/shoot_joystick").connect("auto_attack",self,"auto_shoot")
	
	#revive  the player after death, signal
	connect("revive",self,"revive_player")
	
	#this emits signal for the player to be moved by the joysick
	
	connect("sg_player_dead",get_parent(),"revive_player")
	
	connect("sg_health_change",get_parent().get_node("hud"),"health_change")
	
	#set the health to 5000 at the beginning of the game
	emit_signal("sg_health_change",player_health)
	
	pass
	
func is_mana_full():
	return player_mana > 0
	pass