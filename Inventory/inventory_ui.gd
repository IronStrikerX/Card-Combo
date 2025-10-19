class_name InventoryUI
extends Control

@onready var grid_container: GridContainer = %GridContainer
@onready var selected_slot: Control = %SelectedSlot
@onready var description: Label = %Description
@onready var selected_card_name: Label = %SelectedCardName

@export var starting_deck: StartingDeck

var selected_card: CardUI = null

func _ready() -> void:
	DeckManager.start_new_game(starting_deck)
	spawn_cards()
	
func spawn_cards():
	for child in grid_container.get_children():
		child.queue_free()
	
	for card_instance in DeckManager.current_deck:
		var card_ui = DeckManager.CARD_UI.instantiate()
		grid_container.add_child(card_ui)
		card_ui.set_up(card_instance, card_ui.Source.INVENTORY)
		card_ui.connect("select_card", Callable(self, "_on_card_selected"))
		card_ui.connect("right_click", Callable(self, "_on_card_discard"))

func _on_card_selected(card_ui: CardUI) -> void:
	card_ui.is_animating = true
	var old_global_pos = card_ui.global_position 
	if card_ui.source == card_ui.Source.INVENTORY:
		if selected_card:
			deselect(selected_card)

		selected_card = card_ui
		
		if card_ui.get_parent():
			card_ui.get_parent().remove_child(card_ui)
		selected_slot.add_child(card_ui)
		
		card_ui.global_position = old_global_pos
		card_ui.source = card_ui.Source.SELECT
		
		var target_global_pos = selected_slot.global_position
		var tween = create_tween()
		tween.tween_property(card_ui, "global_position", target_global_pos, 0.3)
		tween.tween_property(card_ui, "scale", Vector2(1, 1), 0.3)
		
		description.text = card_ui.card.data.description
		selected_card_name.text = card_ui.card.data.name

	elif card_ui.source == card_ui.Source.SELECT:
		deselect(card_ui)
	
	card_ui.is_animating = false
		
func deselect(card_ui: CardUI):
	if card_ui.get_parent():
		card_ui.get_parent().remove_child(card_ui)
		grid_container.add_child(card_ui)
		card_ui.source = card_ui.Source.INVENTORY
		description.text = ""
		selected_card_name.text = ""

func _on_card_discard(card_ui: CardUI):
	DeckManager.current_deck.erase(card_ui.card)
	
func _on_play_button_pressed() -> void:
	DeckManager.in_game = true
	get_tree().change_scene_to_file("res://game.tscn")
