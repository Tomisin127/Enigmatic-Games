extends Node2D


signal player_shoot

signal auto_attack

signal dir_changed
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var halfBigCircle_x 
var pressed = false
var active = true

var eve_iAn_range = false

onready var player = get_parent().get_parent().get_parent().get_parent().get_node("player")

# Called when the node enters the scene tree for the first time.
func _ready(): 
	print()
	self.modulate = Color(1,1,1,0.3)
	halfBigCircle_x = $BigCircle.texture.get_size().x/2
	set_process(true)
	



func _process(delta):

	
	#pass the shoot position in the function to the global script
	check_small_circle_pos()

	pass
	
func _input(event):
	if active:
		if event is  InputEventKey:
			pass
		
		if event is InputEventScreenTouch:
			
				
			if event.is_pressed() && control_limits(event,"small_circle"):
				
				$opacityTween.stop(self)
				self.modulate = Color(1,1,1,1)
				self.position = event.position
				pressed = true
				
				$Timer.stop()
				
				
			elif  not event.is_pressed() && control_limits(event,"small_circle"):
				pressed = false
				$Timer.start()
				print("not pressed")
				$SmallCircle.position = $BigCircle.position
				
				emit_signal("dir_changed",check_small_circle_pos())
			
			#if the pressed while still drag set the small circle position back to Vector(0,0)
			#but this will only happen when the small circle is released
			elif pressed==true:
				$SmallCircle.position = Vector2(0,0)
				
		
		if getIsDrag(event) && control_limits(event,"small_circle") :
			var event_pos : Vector2 = event.position
			var toBeSmallPos : Vector2 = event.position - self.global_position
			
			var distance : float = event_pos.distance_to(self.global_position)
			
			
			if distance > halfBigCircle_x:
				$SmallCircle.position = toBeSmallPos.normalized() * halfBigCircle_x
			else:
				$SmallCircle.position =toBeSmallPos
				
			
			#emit_signal("dir_changed",check_small_circle_pos())
	



func getIsDrag(event):
	
	#shoot if the small circle  is dragged 75m away from the the center
	#then it shoots the target in any direction
	if event is InputEventScreenDrag:
		print("relative event: ", event.relative.length())
		if control_limits(event,"small_circle"):
			#is shoot analog is dragged and player mana is above 0, shoot
			if global.shoot_position.length()>75 and global.player_mana_copy > 0:
				emit_signal("player_shoot", true)
				print("player_mana: ", global.player_mana_copy)
			
			#elif the above statement is not true, disable shooting
			elif global.shoot_position.length()>75 and global.player_mana_copy <0:
				emit_signal("player_shoot",false)
				
		
		elif !control_limits(event,"small_circle"):
			if global.shoot_position.length()<75:
				emit_signal("player_shoot",false)
				#global.control_vec=Vector2(0,0)
		
		return true
		
	#if the shoot button is tapped once, it shoot,
	#if its released , it stops shooting
	if event is InputEventScreenTouch and control_limits(event,"small_circle"):
		
		if event.pressed==true and global.player_mana_copy >0:
			emit_signal("auto_attack",false)
		
		elif  !event.pressed and global.control_vec==Vector2(0,0) and global.player_mana_copy >0:
			emit_signal("auto_attack",true)
			
		elif event.pressed== true and global.player_mana_copy < 0:
			emit_signal("auto_attack",false)
			
			


func _on_Timer_timeout():
	$opacityTween.interpolate_property(self,"modulate",Color(1,1,1,1),Color(1,1,1,0.3),0.4,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$opacityTween.start()
	






func check_small_circle_pos() -> Vector2:
	var small_pos = $SmallCircle.global_position
	var big_pos = $BigCircle.global_position
	var smallPos_bigPos = small_pos - big_pos
	
	var control : Vector2 = Vector2(0,0)
	
	if smallPos_bigPos.x > 30:
		control.x = 1
		
	
	elif smallPos_bigPos.x < -30:
		control.x = -1
	
	elif smallPos_bigPos.y > 30:
		control.y = 1
	
	elif smallPos_bigPos.y < -30:
		control.y = -1
		
	else:
		control = Vector2(0,0)
		smallPos_bigPos=Vector2(0,0)
		

	#passs shoot position to the global script
	global.shoot_position = smallPos_bigPos
	
	#pass control value to the global script
	global.control_vec = control
	
	return control


func control_limits(e, type : String):
	var pos = e.position
	
	
	if type == "big_circle":
		if (pos.x > 806 && pos.x <903 && pos.y > 400 && pos.y < 450):
			return true
		else:
			return false
	if type == "small_circle":
		if (pos.x > (806-halfBigCircle_x-50) && pos.x <(903 + halfBigCircle_x +50) && pos.y > (400- halfBigCircle_x -50) && pos.y < (450+ halfBigCircle_x +50)):
			return true
		else:
			return false
	
	


func hide_control():
	active = false
	self.hide()


func show_control():
	active = true




func manage_events(event):
	
	if event is InputEventScreenTouch and control_limits(event,"small_circle"):
		pass
		