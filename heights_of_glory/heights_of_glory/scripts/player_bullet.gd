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
	
	look_at(Vector2())
	
	randomize()
	rotation = (rotation +PI *2 *delta)
	#tween.interpolate_property(sprite, 'transform/scale',sprite.get_scale(),Vector2(0.1,0.0),0.3,Tween.TRANS_QUAD,Tween.EASE_IN_OUT)
	#tween.interpolate_property(sprite, 'modulate',sprite.get_modulate(),sprite.set_modulate(290),0.5,Tween.TRANS_ELASTIC,Tween.EASE_OUT)
	#bullet movement
	
	
	position = (position+velocity *delta)
	

func _on_tween_tween_complete( object, key ):
	queue_free()
	
	print("complete")
	pass # replace with function body




func _on_lifetimer_timeout():
	queue_free()
	pass # Replace with function body.
