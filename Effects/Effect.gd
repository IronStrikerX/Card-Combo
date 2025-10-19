extends Resource
class_name CardEffectResource

enum Trigger {ON_PLAY, ON_DISCARD, ON_DRAW, IN_DECK}
enum Type {ADD, MULTIPLY, DISCARD_SIZE, AMPLIFY, PERMANENT}
enum Condition {NONE, DECK_SIZE_ZERO, AFTER_DISCARD, NO_DISCARD, DISCARD_DECK_SIZE_GREATER_THAN5, PLAYED_DECK_SIZE_ZERO, AFTER_PLAY}

@export var name: String = "Unnamed Effect"
@export var trigger: Trigger
@export var type: Type
@export var condition: Condition
@export var start_duration: int = 1
@export var duration: int
@export var value_bonus: int
@export var mult_bonus: int

func on_play(card: Card):
	if trigger == Trigger.ON_PLAY:
		if check_conditions():
			print("Effect triggered ONPLAY:", name, "from card:", card.name)
			DeckManager.emit_signal("effect_triggered", card)
			for i in range(start_duration, duration):
				if i < DeckManager.next_card_add.size():
					apply_type(i, card)
					print("  Buff applied to next_card_add[", i, "]: +", value_bonus, "value, +", mult_bonus, "mult")

func on_discard(card: Card):
	if trigger == Trigger.ON_DISCARD:
		if check_conditions():
			print("Effect triggered ONDISCARD:", name, "from card:", card.name)
			DeckManager.emit_signal("effect_triggered", card)
			for i in range(start_duration, duration):
				if i < DeckManager.next_card_add.size():
					apply_type(i, card)
					print("  Buff applied to next_card_add[", i, "]: +", value_bonus, "value, +", mult_bonus, "mult")
					
func in_deck(card: Card):
	if trigger == Trigger.IN_DECK:
		if check_conditions():
			print("Effect triggered INDECK:", name, "from card:", card.name)
			DeckManager.emit_signal("effect_triggered", card)
			for i in range(start_duration, duration):
				apply_type(i, card)
				
func on_draw(card: Card):
	if trigger == Trigger.ON_DRAW:
		if check_conditions():
			print("Effect triggered ONDRAW:", name, "from card:", card.name)
			DeckManager.emit_signal("effect_triggered", card)
			for i in range(start_duration, duration):
				apply_type(i, card)
				
func apply_type(i: int, card: Card):
	match type:
		Type.ADD: 
			DeckManager.next_card_add[i][0] += value_bonus
			DeckManager.next_card_add[i][1] += mult_bonus
		Type.MULTIPLY:
			DeckManager.next_card_mult[i][0] += value_bonus
			DeckManager.next_card_mult[i][1] += mult_bonus
		Type.DISCARD_SIZE:
			@warning_ignore("integer_division")
			DeckManager.next_card_add[0][0] += DeckManager.discard_deck.size() * int(value_bonus / 2)
			@warning_ignore("integer_division")
			DeckManager.next_card_add[0][1] += DeckManager.discard_deck.size() * int(mult_bonus / 2)
		Type.AMPLIFY:
			var sum_value := 0
			var sum_mult := 0
			for add in range(value_bonus):
				sum_value += DeckManager.next_card_add[add][0]
				sum_mult += DeckManager.next_card_add[add][1]
			for distribute in range(mult_bonus):
				DeckManager.next_card_add[distribute][0] += sum_value
				DeckManager.next_card_add[distribute][1] += sum_mult
				
func check_conditions() -> bool:
	match condition:
		Condition.NONE: return true
		Condition.DECK_SIZE_ZERO: return DeckManager.inplay_deck.size() == 0
		Condition.AFTER_DISCARD: return DeckManager.just_discarded
		Condition.NO_DISCARD: return DeckManager.discard_deck.size() == 0
		Condition.DISCARD_DECK_SIZE_GREATER_THAN5: return DeckManager.discard_deck.size() >= 5
		Condition.PLAYED_DECK_SIZE_ZERO: return DeckManager.played_deck.size() == 0
		Condition.AFTER_PLAY: return DeckManager.just_played
		_: return false
		
