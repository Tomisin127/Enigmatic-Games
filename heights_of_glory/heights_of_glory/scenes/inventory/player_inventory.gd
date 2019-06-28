extends Node

onready var item_list = get_node("Panel/ItemList")

func _ready():
	#initialize item list
	
	item_list.max_columns =9
	item_list.fixed_icon_size= Vector2(48,48)
	item_list.icon_mode=ItemList.ICON_MODE_TOP
	item_list.select_mode= item_list.SELECT_SINGLE
	item_list.same_column_width = true
	
	# icon = ResourceLoader.load("res://icon.png")
	#item_list.add_item("",icon,true)
#	for i in range(1,200):
#		var icon
#		if i < 200:
#			#icon = ResourceLoader.load("res://icon" + String(i) + ".png")
#			icon = ResourceLoader.load("res://icon.png")
#			item_list.add_item("", icon,true)
#			continue
#
#	pass
	


func _on_Button_pressed():
	item_list.clear()
	
	for slot in range(0,global_player_inventory.inventory_maxslots):
		var inventory_item= global_player_inventory.inventory[String(slot)]
		var item_meta_data = item_database.get_item(inventory_item["id"])
		var icon = ResourceLoader.load(item_meta_data["Icon"])
		var amount = int(inventory_item["Amount"])
		
		item_meta_data["Amount"] = amount
		
		if inventory_item["Id"] == "0": amount = ""
		if !item_meta_data["Stackable"]: amount = ""
		
		item_list.add_item(String(amount),icon,true)
		item_list.set_item_metadata(slot,item_meta_data)
		item_list.set_item_tooltip(slot, item_meta_data["Name"])
		
		
	pass # Replace with function body.
