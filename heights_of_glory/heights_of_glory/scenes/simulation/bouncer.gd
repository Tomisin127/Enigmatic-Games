extends KinematicBody2D

var velocity = Vector2()

var direction = 1

var speed = 300

var gravity = 9.81

func _ready():
	
	
	pass
	
func _physics_process(delta):
	velocity.y += 9.81 *delta
	
#	velocity.x += speed * (direction) * delta
	#velocity.x= direction *speed *delta
	var move_data = move_and_collide(velocity)
	
	if is_on_floor():
		velocity.y =0
		
		
	if move_data and $ray.is_colliding():
		velocity =  Vector2(move_data.normal.x,move_data.normal.y).rotated(move_data.normal.angle())
#	elif !is_on_floor():
#		$ray.enabled = true
#
#	if $ray.is_colliding():
#		velocity = (Vector2(70,70).rotated(velocity.angle())) *delta
#		$ray.enabled =false
		#print("ray colliding")
		#velocity.y -=9.81
		
	
	
	pass
