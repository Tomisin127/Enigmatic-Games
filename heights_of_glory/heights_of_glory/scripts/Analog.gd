extends Node2D


signal dir_changed
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var halfBigCircle_x 
var pressed = false
var active = true

var eve_iAn_range = false




# Called when the node enters the scene tree for the first time.
func _ready():
	self.modulate = Color(1,1,1,0.3)
	halfBigCircle_x = $BigCircle.texture.get_size().x/2
	set_process(true)




func _input(event):
	if active:
		
		if event is  InputEventKey:
			pass
		
		if event is InputEventScreenTouch:
		
		
		
			if event.is_pressed() && control_limits(event,"big_circle"):
				$opacityTween.stop(self)
				self.modulate = Color(1,1,1,1)
				self.position = event.position
				pressed = true
				$Timer.stop()
			if  not event.is_pressed() && control_limits(event,"small_circle"):
				pressed = false
				$Timer.start()
				print("stop")
				$SmallCircle.position = $BigCircle.position
				emit_signal("dir_changed",check_small_circle_pos())
				
				
				
				
		
		if getIsDrag(event) && control_limits(event,"small_circle") :
			var event_pos : Vector2 = event.position
			var toBeSmallPos : Vector2 = event.position - self.global_position
			
			var distance : float = event_pos.distance_to(self.global_position)
		
				
			if distance > halfBigCircle_x:
				$SmallCircle.set_position(toBeSmallPos.normalized() * halfBigCircle_x)
			else:
				$SmallCircle.set_position(toBeSmallPos)
		
		
		
			emit_signal("dir_changed",check_small_circle_pos())
	



func getIsDrag(event):
	
	if event is InputEventScreenDrag:
		return true


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
	
	if smallPos_bigPos.x < -30:
		control.x = -1
	
#	if smallPos_bigPos.x <30 and small_pos.x > -30:
#		control.x = 0
	
	if smallPos_bigPos.y > 30:
		control.y = 1
	
	if smallPos_bigPos.y < -30:
		control.y = -1
	
#	if smallPos_bigPos.y <30 and small_pos.y > -30:
#		control.y = 0
	
	
	print(control)
	return control


func control_limits(e, type : String):
	var pos = e.position
	
	
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