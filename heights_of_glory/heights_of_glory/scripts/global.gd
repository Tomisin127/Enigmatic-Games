extends Node

func _ready():
	pass

#gems collected by the player
var collected_gems = 0

#first player
var endurance : int = 300



var enemy_damage_to_player: int =100

var player_damage_to_enemy:int =70

var shoot_position 

var control_vec:Vector2

var magnum_skills:int = 0

var gem_life_time : float