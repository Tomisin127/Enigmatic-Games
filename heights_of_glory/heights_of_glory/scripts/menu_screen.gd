extends Node



func _ready():
	
	set_process(true)
	
	#use buttons as default
	_on_game_controller_toggled(false)
	
	pass
	
func _process(delta):
	
	pass


func _on_startgame_pressed():
	get_tree().change_scene("res://scenes/level1.tscn")
	pass # Replace with function body.



func _on_game_controller_toggled(button_pressed):
	
	#if button is pressed, set to use the analog joystick
	if button_pressed==true:
		
		global.use_joystick=true
		
		global.use_button=false
		print("use analog")
		$Control/game_controller.text= "joystick"
		
		
	else:#use the button joystick
		global.use_joystick=false
		
		if global.use_joystick==false:
			global.use_button=true
			
		print("using button keys")
		$Control/game_controller.text= "buttons"
	pass # Replace with function body.
