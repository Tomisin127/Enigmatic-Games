extends KinematicBody2D

onready var level1 = get_parent().get_parent()


var gizmo_points

var speed
var direction = 0

var path =null
var path_index =0

func _ready():
	path_index = randi() % 10000
	speed = (randi() % 3 + 1)*50
	direction = randi() % 2
	
	
	pass

func _physics_process(delta):
	if not path == null:
		path.set_offset(path_index)
		position = path.position
		
		if direction == 0:
			path_index += speed*delta
			
		else:
			path_index -= speed*delta
	pass
	
		