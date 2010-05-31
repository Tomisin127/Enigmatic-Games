extends Node2D

var press_count=0
signal dir_changed

var halfBigCircle_x 
var pressed = false
var active = true

var eve_iAn_range = false



onready var player = get_parent().get_parent().get_parent().get_parent().get_node("player")

# Called when the node enters the scene tree for the first time.
func _ready():
	#print("playerL :", player)
	
	self.modulate = Color(1,1,1,0.3)
	halfBigCircle_x = $BigCircle.texture.get_size().x/2
	set_process(true)
	
func _process(delta):
	
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
				print("stop")
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
			print(distance)
				
			if distance > halfBigCircle_x:
				$SmallCircle.set_position(toBeSmallPos.normalized() * halfBigCircle_x)
			else:
				$SmallCircle.set_position(toBeSmallPos)
				
				
			emit_signal("dir_changed",check_small_circle_pos())
	



func getIsDrag(event):
	
	if event is InputEventScreenDrag:
		
		return true
		
	if event is InputEventScreenTouch:
		#print("screen tpuchj")
		
		
		if event.is_pressed() and control_limits(event, "small_circle"):
			
			#increase press count
			
			press_count +=1
			
			#print("press_timer_wait_time: ", $press_timer.time_left)
			
			#if press count is equal to 2 and time is greater than 0, then jump
			if press_count ==2 and $press_timer.time_left >0 and player.is_on_floor():
				
				#print("press_count: ", press_count)
				player.acceleration.y = player.JUMP_HEIGHT
				
				
				


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
		control= Vector2(0,0)
		$SmallCircle.position = Vector2(0,0)
		
	global.move_analog_center = $SmallCircle.position
	global.move_big_circumference = $BigCircle.position
	
	return control


func control_limits(e, type : String):
	var pos = e.position
	
	print(pos)
	if type == "big_circle":
		if (pos.x > 22 && pos.x <333 && pos.y > 335 && pos.y < 535):
			return true
		else:
			return false
	if type == "small_circle":
		if (pos.x > (22-halfBigCircle_x-100) && pos.x <(333 + halfBigCircle_x +100) && pos.y > (335- halfBigCircle_x -100) && pos.y < (535+ halfBigCircle_x +100)):
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

func _on_press_timer_timeout():
	press_count=0
	#print("timeout")
	pass # Replace with function body.
