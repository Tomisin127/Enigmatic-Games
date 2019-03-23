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
	#player bullet looks at shoot position
	self.look_at(global.shoot_position)
	#get_parent().get_node(".").get_parent().get_parent().get_node("Node/Sprite").position =get_parent().get_parent().get_parent().get_node(".").get_node("hud/CanvasLayer/Control/shoot_joystick").position
	#get_parent().get_node(".").get_parent().get_parent().get_node("Node/Sprite").position  = global.shoot_position
	
	randomize()


	#when the player is looking right, shoot in that direction
	if player.get_node("sprite").flip_h==false:
			#bullet movement
		position = (position+velocity *delta)
		rotation = (rotation +PI *2 *delta)
		
	#when the player is looking left, shoot in that direction
	elif player.get_node("sprite").flip_h==true and player:

			#bullet movement
		position = (position-velocity *delta)
		rotation = (rotation +PI *2 *delta)
	pass
	
func _on_lifetimer_timeout():
	queue_free()
	pass # Replace with function body.


func _on_player_bullet_area_entered(area):
	if area.is_in_group("enemy"):
		print("player bullet is colliding with the enemy")
		global.magnum_skills += 10
		print(global.magnum_skills)
		
	pass # Replace with function body.
