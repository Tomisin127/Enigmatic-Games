extends Area2D

var velocity = Vector2()
var speed =300


func _ready():
	
	set_process(true)
	pass
	
	
	# getting players position and rotation
func start(dir,pos):
	rotation= dir
	position= pos
	velocity = Vector2(speed,0).rotated(dir -PI)
	
	pass
func _process(delta):
	randomize()

	#bullet movement
	position = (position +velocity *delta)
	rotation = (rotation+ PI*5 * delta)



#once the bullet as reached a certain time after travel, it destroys
func _on_bullet_lifetime_timeout():
	queue_free()
	pass # Replace with function body.

