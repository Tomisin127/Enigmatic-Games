extends KinematicBody2D

#gravity vector and floor normal vectors
var GRAVITY_VEC:Vector2 = Vector2(0,900)
const FLOOR_NORMAL = Vector2(0,-1)

#walk speed and active states
var WALK_SPEED:int= 70
const STATE_WALKING = 0
const STATE_KILLED =1

#move within the x positive and negative axis and the direction viarable
var linear_velocity = Vector2()
var direction = -1
var anim=""

#the present state
var state= STATE_WALKING

var target_player

onready var bullet = preload("res://scenes/enemy_bullet.tscn")
onready var enemy_bullet_container = get_node("enemy_bullet_container")
onready var bubble_gems = preload("res://scenes/gems.tscn")

#raycast to detect collision
onready var detect_floor_left = $detect_floor_left
onready var detect_wall_left = $detect_wall_left
onready var detect_floor_right = $detect_floor_right
onready var detect_wall_right = $detect_wall_right


onready var sprite = $zombie/sprite



#player damage variables
var player_body : Object
export (int) var damage_point = 20
export (float) var damage_time = 0.4
var in_damage_time = 0

#boolean to check if box is colliding
var box_collide:bool =false

var enemy_health : int =1000



#Animated sprite variables
var default_sprite_scale : Vector2






func _ready():
	
	
	
	#there is no need to set physics process to true it true by defualt
#	set_physics_process(true)
	
	#setting default scale of sprite
	default_sprite_scale = $zombie/enemyBody_Part.scale
	pass


func _physics_process(delta):
	
	
	
	#player damage code
	#this code allow the enemy to do damage but at a time interval 
	if player_body:
		if in_damage_time == 0:
			player_body.take_damage(damage_point)
			in_damage_time = damage_time
		else:
			in_damage_time = clamp((in_damage_time - delta),0,damage_time)
	elif player_body == null:
		in_damage_time = 0
	
	
	
	
	
	var new_anim = "idle"
	#if the enemy is presently walking
	if state==STATE_WALKING:
		#gravity holds the enemy to the ground and he moves from positive to negative side of x axis
		linear_velocity += GRAVITY_VEC *delta
		linear_velocity.x = direction *WALK_SPEED
		linear_velocity = move_and_slide(linear_velocity,FLOOR_NORMAL)
		
		#if the ray cast is colliding the enemy changes direction and flips 
		if detect_wall_left.is_colliding():
			direction =1.0
			#instead of flip_h we will be playing with scale here
			$zombie/enemyBody_Part.scale.x = -default_sprite_scale.x
			
			
			#if the collider on the left is player, the enemy stops walking
			var c = detect_wall_left.get_collider()
			if c.name == "player":
				WALK_SPEED =0
				#animation to attack
			
		#if the ray cast is colliding the enemy changes direction and flips 
		if detect_wall_right.is_colliding():
			direction = -1.0
			#instead of flip_h we will be playing with scale here
			$zombie/enemyBody_Part.scale.x = default_sprite_scale.x
			var c = detect_wall_right.get_collider()
			#if the collider on the left is player, the enemy stops walking
			if c.name == "player":
				WALK_SPEED =0
				#animation to attack
			
			
		
		#this is the bullet ray for the enemy, it will be removed
		#because the enemy is a zombie and zombies dont shoot
		#lazy: lols
	if get_node("bullet_ray").is_colliding():
		
		get_node("bullet_ray/timer").start()
		get_node("bullet_ray/timer").wait_time = 0.5
		
		
	#enemy_jump_over_boxes(box_collide)
	
	#get the bodies that are in the attack area of the enemy
	var body = $attack_area.get_overlapping_bodies()
	
	#if the bodies in this area are not empty
	if body.size() !=0:
		
		for t in body:
			#if one of the bodies in this area is the player
			if t.is_in_group("player"):
				#increase the gravity of the enemy so that he doesnt fly while moving
				GRAVITY_VEC.y =10000
				
				#translate the enemy to the player position
				var dirx = target_player.global_position.x -global_position.x
				var diry = target_player.global_position.y- global_position.y
				translate(Vector2(dirx,diry) * get_physics_process_delta_time())
				#print("attack area body is in player area")
		
		#enemy is dead
	enemy_death()

	pass
	
		#enemy shoot function
func shoot():
	var dir = position - target_player.position
	var b = bullet.instance()
	enemy_bullet_container.add_child(b)
	b.start(dir.angle(),get_node("bullet_spawn_pos").global_position)

	
#on ray timer timeout,shoot at player, this will be removed too
#because zombies dont shoot
func _on_timer_timeout():
	shoot()
	#pass # Replace with function body.


func enemy_take_damage(hit:int):
	if is_alive():
		enemy_health -= hit
		print("enemyhealth: ",enemy_health)
	else:
		return
		
	pass

#THIS FUNCTION IS NOT NECCESSARY , IT DOESNT AFFECT THE GAME BUT I DECIDED TO LEAVE IT
#BECAUSE ITS COOL, LOL :)

func is_alive()->bool:
	return enemy_health >0
	
	pass
	
#zombie disintegrate after death
func disintegrate():
	#spawn gems upon enemy_death
	randomize()
	spawn_bubble_gem(rand_range(1,5))
	
	set_physics_process(false)
	print("enemy is dead")
	enemy_health=0
	
	$physics_collision.disabled=true
	$attack_area/collision.disabled=true
	
	$zombie.monitorable=false
	$zombie.monitoring =false
	
	$attack_area.monitorable=false
	$attack_area.monitoring=false
	
	#hide enemy
	self.modulate=Color(1,1,1,0)
	
	pass

#check if player is dead, called in the physics process function
func enemy_death():
		#enemy is dead
	if not is_alive():
		disintegrate()
	pass
	
func enemy_jump_over_boxes(box_collision):
	if box_collide==true:
		#print("jump over boxes")
		linear_velocity.y-=10

	
	elif box_collide==false:
		box_collide=false
		#print("body collide is now false")

	pass


func _on_zombie_body_entered(body):
		
	#if zombie body is in body of box
	if body.is_in_group("box"):
		print("BOXES COLLIDE")
		#disable the gravity and box collide variable reads true
		GRAVITY_VEC.y=0
		
		box_collide=true
		#stop the enemy from walking and and make the linear movement point up to the y-axis
		WALK_SPEED=0
		linear_velocity.y-=30
		
		#once the fly time is up, it returns to normal
		$flytimer.wait_time=3
		$flytimer.start()
	
	
	
	#let the enemy sense the player and tell the player get hurt
	if body.name == "player":
		player_body = body
	
	pass # Replace with function body.

#on fly timer timeout, revert the fly effect
func _on_flytimer_timeout():
	print("NOT IN GROUP OF BOX AGAIN")
	box_collide=false
	linear_velocity.y +=9.81
	GRAVITY_VEC.y +=98
	WALK_SPEED=70
	pass # Replace with function body.


func _on_attack_area_body_entered(body):
	pass # Replace with function body.


func _on_zombie_area_entered(area):
	#when the zombie is hit by the player_bullet
	if area.is_in_group("player_bullet"):
		print("kill enemy")
		enemy_take_damage(global.player_damage_to_enemy)
		
	pass # Replace with function body
	
#enemy spawn gems upon enemy death
func spawn_bubble_gem(amount):
	
	for i in range(amount):
		var bub = bubble_gems.instance()
		$bubble_gem_container.add_child(bub)
		bub.position = self.position
	
	pass 
	





func _on_zombie_body_exited(body):
	
	#i want to run the damage code per frame so i will run it in a process of physics process method
	if body.name == "player":
		player_body = null
