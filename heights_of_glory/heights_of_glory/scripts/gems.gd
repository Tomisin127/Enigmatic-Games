extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	#set a random angular velocity upon spawning
	self.angular_velocity= rand_range(-10,10)
	
	#print(get_parent().get_parent().name)
	
	#gem effects
	$effect.interpolate_property($gem_sprite, 'scale', $gem_sprite.scale,$gem_sprite.scale + Vector2(0.2,0.2),1,Tween.TRANS_SINE,Tween.EASE_OUT)
	$effect.interpolate_property($gem_sprite, 'modulate', Color(1,1,1,1), Color(1,1,1,0),1,Tween.TRANS_SINE,Tween.EASE_OUT)
	#$effect.interpolate_property($gem_sprite, 'rotation_degrees', $gem_sprite.rotation_degrees, 360,1,Tween.TRANS_SINE,Tween.EASE_OUT)
	$effect.interpolate_property($glow, 'modulate', Color(1,1,1,1), Color(1,1,1,0),1,Tween.TRANS_SINE,Tween.EASE_OUT)
	
	set_process(true)
	pass # Replace with function body.
	
func _process(delta):
	#pass the life_time of the gem to the global script,// experimental but works :)
	global.gem_life_time= $life_time.time_left
	
	#if the gem is about to disappear play some animation
	if is_about_to_disappear():
		$gem_particles.emitting=true
		$gem_particles.radial_accel =60
		#start the tween if the gem is about to disappear
		$effect.start()
		
	pass

func _on_life_time_timeout():
	queue_free()
	pass # Replace with function body.

#if the body that enters the gem is player
#increase gem count
func _on_gem_area_body_entered(body):
	
	if body.is_in_group("player"):
		global.collected_gems +=1
		$effect.start()
		
	if body.is_in_group("enemy"):
		global.collected_gems += 1
		$effect.start()
		
		
	pass # Replace with function body.
	
	#life time of the gem is almost out
func is_about_to_disappear():
	if $life_time.time_left <2:
		return true
	pass

#when tween is completed ,delete the gem
func _on_effect_tween_completed(object, key):
	queue_free()
	pass # Replace with function body.
