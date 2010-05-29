extends Node


onready var player = get_parent().get_node("player")


# Called when the node enters the scene tree for the first time.
func _ready():
	print("player: ", player)
	#if user did not select joystick analog
	joystick_analog_selected()
	
	set_process(true)
	#this signal will activate the magnum button when the abillity as charged
	get_parent().get_node("player").connect("activate_magnum_skill",self, "activate_skill_button")
	
	
	pass

func _process(delta):
	#set the player mana bar
	get_node("CanvasLayer/Control/player_mana").value = player.player_mana
	
	#set the collected gems on the screen
	get_node("CanvasLayer/Control/gems_collected").text=str(global.collected_gems)
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


func joystick_analog_selected():
	
	if global.use_joystick==false:
		$CanvasLayer/Control.hide()
		queue_free()
		print("JOYSTICK HUD DELETED")
		#get_viewport().gui_disable_input=true
		

	elif global.use_joystick==true:
		$CanvasLayer/Control.show()
		#get_viewport().gui_disable_input=false
	
	pass




