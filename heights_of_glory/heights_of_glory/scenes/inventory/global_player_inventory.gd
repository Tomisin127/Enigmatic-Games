extends Node

var url_playerdata = "user://playerdata.bin"
var inventory = {}
var inventory_maxslots = 40
onready var playerdata = data_parser.load_data(url_playerdata)

func _ready():
	
	load_data()
	
	pass
	
func load_data():
	if playerdata == null:
		var dict = {"inventory": {}}
		
		for slot in range(0, inventory_maxslots):
			dict["inventory"][String(slot)]= {"Id" : "0", "Amount":0}
			
		data_parser.write_data(url_playerdata,dict)
		inventory = dict["inventory"]
		
	else:
		inventory = playerdata["inventory"]
