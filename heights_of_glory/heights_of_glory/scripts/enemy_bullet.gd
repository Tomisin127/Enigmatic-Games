extends Area2D

var velocity = Vector2()
var speed =300

onready var sprite = get_node("sprite")
func _ready():
	
	set_process(true)


	pass
	# getting players position and rotation
func start(dir,pos):
	rotation= dir
	position= pos
	velocity = Vector2(speed,0).rotated(dir -PI)
func _process(delta):
	randomize()
	#tween.interpolate_property(sprite, 'transform/scale',sprite.get_scale(),Vector2(0.06,0.06),0.4,Tween.TRANS_QUAD,Tween.EASE_OUT)
	#tween.interpolate_property(sprite, 'transform/rot', sprite.get_rot(),sprite.get_rot()*PI,0.4,Tween.TRANS_QUAD,Tween.EASE_OUT)
	
	#bullet movement
	
	position = (position +velocity *delta)
	rotation = (rotation+ PI*5 * delta)


# life time or range of bullet before it deletes itself 
#func _on_lifetime_timeout():
	#tween.start()
	
	#pass # replace with function body


#func _on_tween_tween_complete( object, key ):
	#queue_free()
	#pass # replace with function body



func _on_bullet_lifetime_timeout():
	queue_free()
	pass # Replace with function body.

#if its colliding with a body ,lets say the walls
func _on_enemy_bullet_body_shape_entered(body_id, body, body_shape, area_shape):
	#if body.is_in_group("wall"):
		#do something
		
	pass # Replace with function body.
