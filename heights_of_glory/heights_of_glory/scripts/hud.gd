extends Node





# Called when the node enters the scene tree for the first time.
func _ready():
	
	#this signal will activate the magnum button when the abillity as charged
	get_parent().get_node("player").connect("activate_magnum_skill",self, "activate_skill_button")
	pass

#change player health upon attack from enemy
func health_change(health: int):
	$CanvasLayer/Control/player_health/health_tween.interpolate_property($CanvasLayer/Control/player_health,"value",$CanvasLayer/Control/player_health.value,health,0.5,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$CanvasLayer/Control/player_health/health_tween.start()
	#print("change in health",health)
	
	
	
func activate_skill_button(boolean):
	if boolean == true:
		print("skill button is activated")
		global.magnum_skills = 0
		$CanvasLayer/Control/super_attack.disabled=false
		$CanvasLayer/Control/super_attack.pressed=true
		
		
	elif boolean ==false:
		#print("deactivate skill")
		$CanvasLayer/Control/super_attack.disabled = true
		$CanvasLayer/Control/super_attack.pressed=false
	pass

func _on_super_attack_pressed():
	print("SKILL is pressed")
	pass # Replace with function body.
