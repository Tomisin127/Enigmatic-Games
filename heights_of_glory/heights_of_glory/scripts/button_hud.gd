extends Node

signal shoot_by_button

onready var player = get_parent().get_node("player")

var button_left: bool
var button_right: bool
var button_center:bool
var button_up:bool

var is_shooting:bool

var on_floor_timer =0


onready var level1 = get_parent()

func _ready():
	
	#var cont_rect = get_node("CanvasLayer/Control/button_container").rect_size
	#print("cont_rect: ", cont_rect)
	
	#this signal will activate the magnum button when the abillity as charged
	get_parent().get_node("player").connect("activate_magnum_skill",self, "activate_skill_button")
	
	
	
	#initially we use the buttons but
	#if use button is selected again after changing from joystick to use_buttons in the menu screen, then use the buttons
	if global.use_button==false:
		$CanvasLayer/Control.hide()
		print("BUTTON HUD DELETED")
		queue_free()
		
		
	elif global.use_button==true:
		$CanvasLayer/Control.show()
		
	
	set_process(true)
	
	pass

func _process(delta):
	
	check_shooting_by_button()
	
	button_controller()
	#calculate the distance to the first and second enemy in the list
	
	#var player_distance_to_police0 = player.position.distance_to(level1.list_of_enemy[0].position if level1.list_of_enemy[0] else null)
	#print("distance to the enemy: ", player_distance_to_police0 , level1.list_of_enemy[0])
	
	pass

func _on_up_button_down():
	button_up=true
	pass # Replace with function body.

func _on_up_button_up():
	button_up=false
	pass
	
func _on_left_button_down():
	button_left =true
	pass # Replace with function body.
	
func _on_left_button_up():
	button_left=false
	pass # Replace with function body..

func _on_right_button_down():
	button_right=true
	pass # Replace with function body.

func _on_right_button_up():
	button_right= false
	pass # Replace with function body.

func _on_center_button_down():
	button_center=true
	pass # Replace with function body.


func _on_center_button_up():
	button_center=false
	pass # Replace with function body.



func _on_shoot_button_down():
	is_shooting = true
	pass # Replace with function body.


func _on_shoot_button_up():
	is_shooting=false
	pass # Replace with function body.

func check_shooting_by_button():
	
	if is_shooting==true and player.player_mana > 0:
		print("i am shooting")
		emit_signal("shoot_by_button",true)
		
	elif is_shooting==true and player.player_mana<=0:
		emit_signal("shoot_by_button",false)
		
	elif is_shooting==false:
		emit_signal("shoot_by_button",false)
		
	pass
	
func button_controller():
	
	if button_up==true:
			#jumping settings
		if player.is_on_floor() and player.ground_ray.is_colliding():
			player.acceleration.y = player.JUMP_HEIGHT
			
	
	if button_left==true:
		player.acceleration.x -= player.ACCEL 
		player.get_node("sprite").flip_h=1
	
	if button_right==true:
		player.acceleration.x += player.ACCEL 
		player.get_node("sprite").flip_h=0
		
	if button_center==true:
		#start the timer
		on_floor_timer +=get_process_delta_time()
		
		#if the player is facing right and the timer is less than 1
		#rotate the acceleration in 45 degree to the right and jump
		if player.get_node("sprite").flip_h==false and on_floor_timer<1:
			player.acceleration.rotated(Vector2(1,-1).angle())
			player.acceleration.x =200
			player.acceleration.y =-200
			
		#if the player is facing right and the timer is less than 1
		#rotate the acceleration in 45 degree to the right and jump
		
		elif player.get_node("sprite").flip_h==true and on_floor_timer<1:
			player.acceleration.rotated(Vector2(1,-1).angle())
			player.acceleration.x =200
			player.acceleration.y =-200
			
		#if is still jumping and it as landed after time reset, jump immediately again
		elif on_floor_timer > 1 and player.is_on_floor():
			on_floor_timer=0
		
	pass
	
func activate_skill_button(button_pressed):
	#if ability is charged, disable the skill button
	if button_pressed == true:
		$CanvasLayer/Control/keys/super_attack.disabled=false
		
		#if skill is pressed, then player will use the skills and set the ability to zero again
		if $CanvasLayer/Control/keys/super_attack.pressed==true:
			print("skill button is activated")
			global.magnum_skills=0
			
		
	else:
		#print("deactivate skill")
		$CanvasLayer/Control/keys/super_attack.disabled = true
		$CanvasLayer/Control/keys/super_attack.pressed=false
	pass