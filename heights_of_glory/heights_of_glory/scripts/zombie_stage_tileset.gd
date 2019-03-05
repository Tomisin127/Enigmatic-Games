extends Node

func _ready():
	
	pass # Replace with function body.


func _on_ladder_area_body_entered(body):
	if body.name =="player":
		print("player is in ladder area")
	pass # Replace with function body.
