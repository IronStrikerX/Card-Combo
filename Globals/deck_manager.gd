extends Node

const CARD_UI = preload("uid://y8buv1lbsbcc")

signal effect_triggered(card: Card)
signal effect_subtract()

var starting_deck: StartingDeck

var current_round := 1

var current_deck: Array[CardInstance] = []
var inplay_deck: Array[CardInstance] = []
var discard_deck: Array[CardInstance] = []
var played_deck: Array[CardInstance] = []

var score: int = 0
var has_started := false
var in_game := false
var just_discarded:= false
var just_played:= false
var first_discard := false

var next_card_add: Array[Array] = [[0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]]
var next_card_mult: Array[Array] = [[1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1]]

func start_new_game(deck_resource: StartingDeck) -> void:
	if not has_started:
		has_started = true
		starting_deck = deck_resource
		current_deck.clear()
		inplay_deck.clear()
		discard_deck.clear()
		played_deck.clear()
		
		# Create runtime instances from resource
		for card_resource in starting_deck.deck:
			var card_instance = CardInstance.new(card_resource)
			current_deck.append(card_instance)

func start_round():
	next_card_add = [[0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0], [0, 0]]
	next_card_mult = [[1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1], [1, 1]]
	inplay_deck = current_deck.duplicate()

func draw_card() -> CardInstance:
	if inplay_deck.is_empty():
		return null

	var drawn_card = inplay_deck.pop_front()
	drawn_card.data.effect.on_draw(drawn_card.data)

	return drawn_card


func play_card(card: CardInstance) -> void:
	just_discarded = false
	just_played = true
	played_deck.append(card)

func discard_card(card: CardInstance) -> void:
	just_discarded = true
	just_played = false
	card.data.effect.on_discard(card.data)
	discard_deck.append(card)

func reshuffle_discard() -> void:
	inplay_deck = discard_deck.duplicate()
	discard_deck.clear()
	inplay_deck.shuffle()
	
func apply_score(card: CardInstance) -> int:
	card.data.effect.on_play(card.data)
	next_card_add[0][0] += card.value
	next_card_add[0][1] += card.mult
	
	var round_score = next_card_add[0][0] * next_card_add[0][1] * next_card_mult[0][0] * next_card_mult[0][1] 
	for i in range(5):
		next_card_add[i][0] = next_card_add[i + 1][0]
		next_card_add[i][1] = next_card_add[i + 1][1]
		next_card_mult[i][0] = next_card_mult[i + 1][0]
		next_card_mult[i][1] = next_card_mult[i + 1][1]
		
	if card.data.effect.type == CardEffectResource.Type.PERMANENT:
		card.value += card.data.effect.value_bonus
		card.mult += card.data.effect.mult_bonus

	
	emit_signal("effect_subtract")
	return round_score

func in_deck_effect(initializing: bool = true):
	if not initializing:
		first_discard = true
		for card in inplay_deck:
			card.data.effect.in_deck(card.data)
func show_current_buffs():
	for i in range(next_card_add.size()):
		print(i, ". +", next_card_add[i], " add\n", "   +",next_card_mult[i], " multiply" )
