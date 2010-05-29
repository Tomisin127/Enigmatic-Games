extends Node

onready var player = get_parent().get_node("player")

func _ready():
	
	#initially we use the buttons but
	#if use button is selected again after changing from joystick to use_buttons in the menu screen, then use the buttons
	if global.use_button==false:
		$CanvasLayer/Control.hide()
		print("BUTTON HUD DELETED")
		queue_free()
		#$CanvasLayer/Control.get_viewport().gui_disable_input=true
		
		
	elif global.use_button==true:
		$CanvasLayer/Control.show()
		#$CanvasLayer/Control.get_viewport().gui_disable_input=false
		
		
		

	
	set_process(true)
	
	pass

func _process(delta):
	
	
	pass

func _on_up_pressed():
	#jumping settings
	if player.is_on_floor() and player.ground_ray.is_colliding():
		player.acceleration.y = player.JUMP_HEIGHT
		
	pass # Replace with function body.


func _on_left_button_down():
	player.acceleration.x -= player.ACCEL 
	player.get_node("sprite").flip_h=1
	pass # Replace with function body.
	



func _on_right_pressed():

	player.acceleration.x += player.ACCEL 
	player.get_node("sprite").flip_h=0
	pass # Replace with function body.


#func _on_left_gui_input(event):
	#if event is InputEvent:
		#if event.get_action_strength(str(_on_left_button_down())):
			#print("alwways")
	#pass # Replace with function body.


func _on_center_pressed():
	if player.get_node("sprite").flip_h==false:
		print(" center is pressed ")
		player.acceleration= (Vector2(400,-400).rotated(0)) 
		
	elif player.get_node("sprite").flip_h==true:
		player.acceleration= (Vector2(-400,-400).rotated(0)) 
	pass # Replace with function body.
