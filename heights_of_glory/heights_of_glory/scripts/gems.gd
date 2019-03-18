extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


func _on_life_time_timeout():
	queue_free()
	pass # Replace with function body.

#if the body that enters the gem is player
#increase gem count
func _on_gem_area_body_entered(body):
	if body.is_in_group("player"):
		global.collected_gems +=1
		queue_free()
	pass # Replace with function body.
