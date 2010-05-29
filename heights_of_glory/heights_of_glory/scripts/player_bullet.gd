extends Area2D

class_name player_bullet_class

onready var player = get_parent().get_parent()

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
	
	randomize()
	#bullet movement
	position = (position+velocity *delta)
	rotation = (rotation +PI *2 *delta)

	pass
	
func _on_lifetimer_timeout():
	queue_free()
	pass # Replace with function body.


func _on_player_bullet_area_entered(area):
	if area.is_in_group("enemy"):
		
		#add a  minimum of 10 for the magum skill every time the bullet hit the enemy
		#add it should not pass 100, if it reach 100 it should stay at 100
		
		global.magnum_skills += min(10,100) if !player.is_able_to_use_magnum_skills() else 0
		
		print("the magnum: ",global.magnum_skills)
		
		
	pass # Replace with function body.


func _on_bullet_exit_screen_exited():
	queue_free()
	pass # Replace with function body.
