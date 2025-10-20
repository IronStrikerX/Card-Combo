extends Resource
class_name CardEffectResource

enum Trigger {ON_PLAY, ON_DISCARD, ON_DRAW, IN_DECK, IN_PLAYED_DECK}
enum Type {ADD, MULTIPLY, DISCARD_SIZE, AMPLIFY, PERMANENT, MAX_DECK_SIZE_ADD, EFFECT_SIZE, EFFECT_SIZE_MULT, AMPLIFY_MULT, DUPLICATE_CARDS}
enum Condition {NONE, DECK_SIZE_ZERO, AFTER_DISCARD, NO_DISCARD, DISCARD_DECK_SIZE_GREATER_THAN5, PLAYED_DECK_SIZE_ZERO, AFTER_PLAY, DECK_SIZE_NOT_ZERO}

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

func on_discard(card: Card):
	if trigger == Trigger.ON_DISCARD:
		if check_conditions():
			print("Effect triggered ONDISCARD:", name, "from card:", card.name)
			DeckManager.emit_signal("effect_triggered", card)
			for i in range(start_duration, duration):
				if i < DeckManager.next_card_add.size():
					apply_type(i, card)
					
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
				
func in_played_deck(card: Card):
	if trigger == Trigger.IN_PLAYED_DECK:
		if check_conditions():
			print("Effect triggered PLAYED:", name, "from card:", card.name)
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
			DeckManager.next_card_add[0][0] += DeckManager.discard_deck.size() * value_bonus
			DeckManager.next_card_add[0][1] += DeckManager.discard_deck.size() * mult_bonus
		Type.DISCARD_SIZE:
			DeckManager.next_card_mult[0][0] += DeckManager.discard_deck.size() * value_bonus
			DeckManager.next_card_mult[0][1] += DeckManager.discard_deck.size() * mult_bonus
		Type.AMPLIFY:
			var sum_value := 0
			var sum_mult := 0
			for add in range(value_bonus):	
				sum_value += DeckManager.next_card_add[add][0]
				sum_mult += DeckManager.next_card_add[add][1]
			for distribute in range(1, mult_bonus):
				DeckManager.next_card_add[distribute][0] += sum_value
				DeckManager.next_card_add[distribute][1] += sum_mult
		Type.PERMANENT:
			if not trigger == Trigger.ON_PLAY:
				card.value += value_bonus
				card.mult += mult_bonus
		Type.MAX_DECK_SIZE_ADD:
			DeckManager.max_deck_size += 1
		Type.EFFECT_SIZE:
			DeckManager.next_card_add[0][0] += DeckManager.active_effects.size() * value_bonus
			DeckManager.next_card_add[0][1] += DeckManager.active_effects.size() * mult_bonus
		Type.EFFECT_SIZE_MULT:
			DeckManager.next_card_mult[0][0] += DeckManager.active_effects.size() * value_bonus
			DeckManager.next_card_mult[0][1] += DeckManager.active_effects.size() * mult_bonus
		Type.AMPLIFY_MULT:
			var sum_value := 0
			var sum_mult := 0
			for mult in range(value_bonus):	
				sum_value += DeckManager.next_card_mult[mult][0]
				sum_mult += DeckManager.next_card_mult[mult][1]
			for distribute in range(1, mult_bonus):
				DeckManager.next_card_mult[distribute][0] += sum_value
				DeckManager.next_card_mult[distribute][1] += sum_mult
		Type.DUPLICATE_CARDS:
			var card_count = value_bonus
			while card_count > 0:
				var random_card = DeckManager.current_deck.pick_random()
				if random_card.data.effect.type != Type.DUPLICATE_CARDS:
					card_count -= 1
					DeckManager.inplay_deck.append(random_card)

func check_conditions() -> bool:
	match condition:
		Condition.NONE: return true
		Condition.DECK_SIZE_ZERO: return DeckManager.inplay_deck.size() == 0
		Condition.AFTER_DISCARD: return DeckManager.just_discarded
		Condition.NO_DISCARD: return DeckManager.discard_deck.size() == 0
		Condition.DISCARD_DECK_SIZE_GREATER_THAN5: return DeckManager.discard_deck.size() >= 5
		Condition.PLAYED_DECK_SIZE_ZERO: return DeckManager.played_deck.size() == 0
		Condition.AFTER_PLAY: return DeckManager.just_played
		Condition.DECK_SIZE_NOT_ZERO: return DeckManager.inplay_deck.size() != 0
		_: return false
		
