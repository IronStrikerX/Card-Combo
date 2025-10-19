class_name GameState
extends Node

signal card_played(card_instance)
signal card_drawn(card_instance)
signal card_discarded(card_instance)
signal round_started()

var modifiers = {
	"value_bonus": 0.0,
	"mult_bonus": 0.0,
}

func trigger_card_played(card_instance):
	card_played.emit(card_instance)

func trigger_card_drawn(card_instance):
	card_drawn.emit(card_instance)

func trigger_card_discarded(card_instance):
	card_discarded.emit(card_instance)
