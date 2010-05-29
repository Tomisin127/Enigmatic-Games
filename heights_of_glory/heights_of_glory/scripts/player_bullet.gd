extends Area2D

class_name player_bullet_class


var velocity = Vector2()
var speed =400

func _ready():
	
	set_process(true)
	
	# getting players position and rotation
func start(dir,pos):
	rotation = dir
	position = pos
	velocity = Vector2(speed,0).rotated(dir + 2*PI)
	
func _process(delta):
	
	#look_at(Vector2())
	
	randomize()
	rotation = (rotation +PI *2 *delta)
	
	#bullet movement
	position = (position+velocity *delta)
	
	pass
	
func _on_lifetimer_timeout():
	queue_free()
	pass # Replace with function body.
