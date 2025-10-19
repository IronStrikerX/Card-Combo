extends RefCounted
class_name CardInstance

var data: Card           # reference to Card resource
var value: int
var mult: float

func _init(card_data: Card):
	data = card_data
	value = card_data.value
	mult = card_data.mult
