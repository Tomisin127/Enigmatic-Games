extends Node

var loader 
var wait_frames
var time_max =100
var current_scene = null

onready var loadscreen= load("res://scenes/interactive_loader.tscn")

var g

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child(root.get_child_count()-1)
	
	pass
	
	

func goto_scene(path):

	
	g = loadscreen.instance()
	add_child(g)
	
	
	#if this particular path going to the game, show the neccessary picture
	if path == "res://scenes/level1.tscn":
		g.get_node("level1").show()
		
	#elif path== "res://scenes/overmain.tscn" or path=="res://scenes/themain.tscn":
		#g.get_node("load").show()
		
	loader = ResourceLoader.load_interactive(path)
	
	
	if loader == null:
		print("null")
		return
	
	set_process(true)
	
	current_scene.queue_free()
	
	print(current_scene)
	
	wait_frames =25
	
func _process(delta):

	if loader ==null:
		print(loader)
		print("its null")
		set_process(false)
		return


	if wait_frames >0:
		wait_frames -=50
		return


	if wait_frames <=2:
		wait_frames=0
		
		print("wait frames is zero")
	
	var t = OS.get_ticks_msec()
	
	while OS.get_ticks_msec() < t + time_max:
		
		#poll your loader
		var err = loader.poll()
		
		#load finishes
		if err == ERR_FILE_EOF:
			var resource = loader.get_resource()
			loader = null
			remove_child(g)
			set_new_scene(resource)
			
			break

func set_new_scene(scene_resource):
	current_scene = scene_resource.instance()
	get_node("/root").add_child(current_scene)
	pass

