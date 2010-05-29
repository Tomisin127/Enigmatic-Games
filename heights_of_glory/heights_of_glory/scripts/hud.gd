extends Node





# Called when the node enters the scene tree for the first time.
func _ready():
	#if user did not select joystick analog
	joystick_analog_not_selected()
	
	
	#this signal will activate the magnum button when the abillity as charged
	get_parent().get_node("player").connect("activate_magnum_skill",self, "activate_skill_button")
	
	
	pass

#change player health upon attack from enemy
func health_change(health: int):
	$CanvasLayer/Control/player_health/health_tween.interpolate_property($CanvasLayer/Control/player_health,"value",$CanvasLayer/Control/player_health.value,health,0.5,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$CanvasLayer/Control/player_health/health_tween.start()
	#print("change in health",health)
	
	
	
func activate_skill_button(button_pressed):
	#if ability is charged, disable the skill button
	if button_pressed == true:
		$CanvasLayer/Control/super_attack.disabled=false
		
		#if skill is pressed, then player will use the skills and set the ability to zero again
		if $CanvasLayer/Control/super_attack.pressed==true:
			#print("skill button is activated")
			global.magnum_skills=0
			
		
	else:
		#print("deactivate skill")
		$CanvasLayer/Control/super_attack.disabled = true
		$CanvasLayer/Control/super_attack.pressed=false
	pass


func joystick_analog_not_selected():
	
	if global.use_joystick==false:
		$CanvasLayer/Control.hide()
		get_viewport().gui_disable_input=true
	
	pass


