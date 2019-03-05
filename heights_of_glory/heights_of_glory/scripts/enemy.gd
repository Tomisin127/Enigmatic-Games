extends KinematicBody2D


var GRAVITY_VEC:Vector2 = Vector2(0,900)
const FLOOR_NORMAL = Vector2(0,-1)

const WALK_SPEED= 70
const STATE_WALKING = 0
const STATE_KILLED =1

var linear_velocity = Vector2()
var direction = -1
var anim=""

var state= STATE_WALKING

var target_player

onready var bullet = preload("res://scenes/enemy_bullet.tscn")
onready var enemy_bullet_container = get_node("enemy_bullet_container")

onready var detect_floor_left = $detect_floor_left
onready var detect_wall_left = $detect_wall_left
onready var detect_floor_right = $detect_floor_right
onready var detect_wall_right = $detect_wall_right

onready var sprite = $zombie/sprite

var box_collide:bool =false

func _ready():
	
	set_physics_process(true)

	pass


func _physics_process(delta):
	
	var new_anim = "idle"
	if state==STATE_WALKING:
		linear_velocity += GRAVITY_VEC *delta
		linear_velocity.x = direction *WALK_SPEED
		linear_velocity = move_and_slide(linear_velocity,FLOOR_NORMAL)
		
		if not detect_floor_left.is_colliding() or detect_wall_left.is_colliding():
			direction =1.0
			
			
		if not detect_floor_right.is_colliding() or detect_wall_right.is_colliding():
			direction = -1.0
			#print("the enemy is colliding")
			
		
		
	if get_node("bullet_ray").is_colliding():
		
		get_node("bullet_ray/timer").start()
		get_node("bullet_ray/timer").wait_time = 0.5
		
	if detect_wall_left.is_colliding():
		GRAVITY_VEC.y=0
		var c = detect_wall_left.get_collider()
		if c.name == "box":
			#print("box collider")
			box_collide=true
			
		else:
			box_collide=false
			GRAVITY_VEC.y +=900

	enemy_jump_over_boxes(box_collide)
	
	
	
	pass
	
		#enemy shoot function
func shoot():
	var dir = position - target_player.position
	var b = bullet.instance()
	enemy_bullet_container.add_child(b)
	b.start(dir.angle(),get_node("bullet_spawn_pos").global_position)

	
#on ray timer timeout,shoot at player
func _on_timer_timeout():
	shoot()
	#pass # Replace with function body.




	
func enemy_jump_over_boxes(box_collision):
	if box_collide==true:
		#print("jump over boxes")
		linear_velocity.y-=20

	
	elif box_collide==false:
		#print("box collide is now false")
		linear_velocity.y +=GRAVITY_VEC.y

	pass


func _on_fall_timer_timeout():
	pass # Replace with function body.
