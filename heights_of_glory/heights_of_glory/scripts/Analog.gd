extends Node2D

const INACTIVE_IDX = -1;
export var isDynamicallyShowing = false
export var listenerNodePath = ""
export var nam = ""

var ball
var bg 
var animation_player
var parent
var listenerNode

var centerPoint = Vector2(0,0)
var currentForce = Vector2(0,0)
var halfSize = Vector2()
var ballPos = Vector2()
var squaredHalfSizeLenght = 0
var currentPointerIDX = INACTIVE_IDX;

func _ready():
	
	
	set_process_input(true)
	bg = get_node("bg")
	ball = get_node("ball")
	animation_player = get_node("AnimationPlayer")
	parent = get_parent();
	halfSize = bg.texture.get_size()/2;
	squaredHalfSizeLenght = halfSize.x*halfSize.y;
	
	
	if (listenerNodePath != "" && listenerNodePath!=null):
		listenerNodePath = get_node(listenerNodePath)
	elif listenerNodePath=="":
		listenerNodePath = null

	#isDynamicallyShowing = isDynamicallyShowing and parent extends Control
	
	if isDynamicallyShowing:
		modulate = Color(1,1,1,0);
#		hide()

func get_force():
	return currentForce
	
func _input(event):
	
	var incomingPointer = extractPointerIdx(event)
	if incomingPointer == INACTIVE_IDX:
		
		return
	
	if need2ChangeActivePointer(event):
		if (currentPointerIDX != incomingPointer) and event.is_pressed():
			currentPointerIDX = incomingPointer;
			showAtPos(Vector2(event.x, event.y));
			

	var theSamePointer = currentPointerIDX == incomingPointer
	if isActive() and theSamePointer:
		process_input(event)

func need2ChangeActivePointer(event): #touch down inside analog
	var mouseButton = event.type == InputEventMouseButton
	var touch = event.type == InputEventScreenTouch
	
	if mouseButton or touch:
		if isDynamicallyShowing:
			
			return get_parent().get_visible_rect().has_point(Vector2(event.x, event.y))
		else:
			var lenght = (global_position - Vector2(event.x, event.y)).length_squared();
			return lenght < squaredHalfSizeLenght
	else:
	 return false

func isActive():
	return currentPointerIDX != INACTIVE_IDX


func extractPointerIdx(event):
	var touch = event == InputEventScreenTouch
	var drag = event == InputEventScreenDrag
	var mouseButton = event == InputEventMouseButton
	var mouseMove = event == InputEventMouseMotion
	
	if touch or drag:
		return event.index
	elif mouseButton or mouseMove:
		#plog("SOMETHING IS VERYWRONG??, I HAVE MOUSE ON TOUCH DEVICE")
		return 0
	else:
		return INACTIVE_IDX
		
func process_input(event):
	calculateForce(event.x - self.global_position.x, event.y - self.global_position.y)
	updateBallPos()
	
	var isReleased = isReleased(event)
	if isReleased:
		reset()


func reset():
	currentPointerIDX = INACTIVE_IDX
	calculateForce(0, 0)

	if isDynamicallyShowing:
		hide()
	else:
		updateBallPos()

func showAtPos(pos):
	if isDynamicallyShowing:
		animation_player.play("alpha_in", 0.2)
		global_position=pos
	
#func hide():
	#animation_player.play("alpha_out", 0.2) 

func updateBallPos():
	ballPos.x = halfSize.x * currentForce.x #+ halfSize.x
	ballPos.y = halfSize.y * -currentForce.y #+ halfSize.y
	#ball.set_pos(ballPos)
	get_node("ball").position=ballPos
func calculateForce(var x, var y):
	#get direction
	currentForce.x = (x - centerPoint.x)/halfSize.x
	
	currentForce.y = -(y - centerPoint.y)/halfSize.y
	
	#limit 
	if currentForce.length_squared()>1:
		currentForce=currentForce/currentForce.length()
	
	sendSignal2Listener()

func sendSignal2Listener():
	if (listenerNodePath != null):
		listenerNodePath.analog_force_change(currentForce, self)

func isPressed(event):
	if event.type == InputEventMouseMotion:
		return (event.button_mask==1)
	elif event.type == InputEventScreenTouch:
		return event.pressed

func isReleased(event):
	if event.type == InputEventScreenTouch:
		return !event.pressed
	elif event.type == InputEventMouseButton:
		return !event.pressed