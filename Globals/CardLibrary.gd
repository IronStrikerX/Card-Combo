extends Node

const RARITY_WEIGHTS= {"COMMON" : 34, "RARE" : 24, "EPIC" : 20, "LEGENDARY": 12, "MYTHIC" : 8}
	
var card_library = preload("res://Card/StartingDecks/all_cards.tres")
var common: Array[Card]
var rare: Array[Card]
var epic: Array[Card]
var legendary: Array[Card]
var mythic: Array[Card]

func _ready() -> void:
	for card in card_library.deck:
		match card.rarity:
			card.Rarity.COMMON:
				common.append(card)
				
			card.Rarity.RARE:
				rare.append(card)
				
			card.Rarity.EPIC:
				epic.append(card)
				
			card.Rarity.LEGENDARY:
				legendary.append(card)
				
			card.Rarity.MYTHIC:
				mythic.append(card)

func pick_rarity() -> String:
	var total_weight = 0
	for weight in RARITY_WEIGHTS.values():
		total_weight += weight
	
	var roll = randi_range(1, total_weight)
	var cumulative = 0
	
	for rarity in RARITY_WEIGHTS.keys():
		cumulative += RARITY_WEIGHTS[rarity]
		if roll <= cumulative:
			return rarity
	
	return "COMMON"
	
func pick_card_from_rarity(rarity: String):
	var card: Card
	match rarity:
		"COMMON": 
			card = common.pick_random()
		"RARE":
			card = rare.pick_random()
		"EPIC":
			card = epic.pick_random()
		"LEGENDARY":
			card = legendary.pick_random()
		"MYTHIC":
			card = mythic.pick_random()
			
	var card_instance := CardInstance.new(card)
	card_instance.data = card
	card_instance.mult = card.mult
	card_instance.value = card.value
	return card_instance
