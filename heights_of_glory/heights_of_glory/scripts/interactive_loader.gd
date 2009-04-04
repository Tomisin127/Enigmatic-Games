extends Node

var loader 
var wait_frames
var time_max =100
var current_scene = null

onready var loadscreen= load("res://scenes/interactive_loader.tscn")

var g

var stage:float
var stage_count:float
var stage_load_percent:float

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
		return
	
	set_process(true)
	
	current_scene.queue_free()
	
	print(current_scene)
	
	wait_frames =200
	
func _process(delta):
	

	if loader ==null:
		set_process(false)
		return


	if wait_frames >0:
		wait_frames -=1
		return

	var t = OS.get_ticks_msec()
	
	#start the fade away effect
	
	is_about_to_finish_loading()
	
	while OS.get_ticks_msec() < t + time_max:
		
		#poll your loader
		var err = loader.poll()
		
		#percentage loader
		stage= float(loader.get_stage()+1)
		
		stage_count = float(loader.get_stage_count())
		
		stage_load_percent = (stage/stage_count) *100
		
		print(stage_load_percent)
		
		#set the percentage on screen and percent as text
		g.get_node("percent_texture_loader").value = stage_load_percent
		g.get_node("text_percent").text = str(stage_load_percent)
		
		
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


func is_about_to_finish_loading():
	if stage_load_percent >0:
		g.get_node("level1/fade_away").interpolate_property($level1,'modulate', Color(1,1,1,1), Color(1,1,1,0),0.1,Tween.TRANS_SINE,Tween.EASE_OUT)
		g.get_node("level1/fade_away").start()
		print("stageiqwei: ",stage_load_percent)
		return true
	


