extends Node

var url_database_item = "res://database/inventory_items.json"

#func _ready():
#	var item = get_item(1)
#
#	if item ==null:
#		return
#
#	print("ID: " + String(item['Id']))
#	print("Name: " + item['Name'])
#	print("Type: " + item['Type'])
#	print("Description: ", item['Description'])

func get_item(id):
	var item_data = {}
	
	item_data = data_parser.load_data(url_database_item)

	if !item_data.has(String(id)):
		print("item does not exist")
		return

	item_data[String(id)]["Id"]= int(id)
	return item_data[String(id)]